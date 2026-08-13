CREATE OR REPLACE PACKAGE ARTHUS."PK_IMPORT_AFFIL"
AS
/*============================================================================*/
/* PACKAGE      : PK_IMPORT_AFFIL.sql                                         */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 15/05/2013                                                  */
/* Description  : Package permettant l import d un fichier contenant des      */
/*                affiliations dans Arthus ainsi que l intégration des données*/
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 22/09/2014 / Mantis 4436                              */
/*============================================================================*/

TYPE T_ligne IS TABLE OF VARCHAR2(2004) INDEX BY BINARY_INTEGER ; --ligne sous forme de tableau

PROCEDURE importAFFILIATION ( i_repertoire   IN   VARCHAR2
                            , i_fichier      IN   VARCHAR2
                            , i_Entreprise   IN   AFFIL_PORTE.ENTREPRISE%TYPE
                            , i_Trimestre    IN   NUMBER
                            , i_Porte        IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                            , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , o_erreur       OUT  VARCHAR2);

PROCEDURE AnnulImportAFFILIATION ( i_numremise    IN   AFFIL_PORTE.NUMREMISE%TYPE
                                 , i_numporte     IN   AFFIL_PORTE.NUMPORTE%TYPE
                                 , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                                 , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                                 , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                                 , o_erreur       OUT  VARCHAR2);

FUNCTION f_InsertDonneesPorte ( i_repertoire  IN       VARCHAR2
                              , i_fichier     IN       VARCHAR2
                              , i_echange     IN       PORTE_ENTITE.IDECHANGE%TYPE
                              , o_erreur         OUT   VARCHAR2)
RETURN NUMBER;

FUNCTION f_ctrlAFFIL_PORTE( i_numporte        IN       AFFIL_PORTE.NUMPORTE%TYPE
                          , i_numremise       IN       AFFIL_PORTE.NUMREMISE%TYPE
                          , i_Entreprise      IN       AFFIL_PORTE.ENTREPRISE%TYPE
                          , i_numligne        IN       AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                          , i_etat            IN       AFFIL_PORTE.ETAT%TYPE DEFAULT NULL
                          , o_ano                OUT   AFFIL_ANO.NUMANO%TYPE
                          , o_erreur             OUT   VARCHAR2)
RETURN NUMBER;

FUNCTION createTableEchange( i_entite         IN       PORTE_ENTITE.ENTITE%TYPE, i_echange IN PORTE_ENTITE.IDECHANGE%TYPE)
RETURN NUMBER;

FUNCTION S2A (I_string VARCHAR2, I_delim VARCHAR2)
RETURN T_ligne;

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

-- ------------------------------------------------- Fin des procedures publiques --
END PK_IMPORT_AFFIL;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_IMPORT_AFFIL
As
/*============================================================================*/
/* PACKAGE      : PK_IMPORT_AFFIL.sql                                         */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 15/05/2013                                                  */
/* Description  : Package permettant l import d un fichier contenant des      */
/*                affiliations dans Arthus ainsi que l intégration des données*/
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 22/09/2014 / Mantis 4436                              */
/*============================================================================*/

   -- -- TYPES PRIVEES ------------------------------------------------------


  TYPE T_entite IS TABLE OF VARCHAR2(2004)  INDEX BY  VARCHAR2(80) ;
  TYPE T_import IS TABLE OF T_entite  INDEX BY BINARY_INTEGER ;--toutes les données importées in indéxé par numéro de ligne

   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
   -- -- PROCEDURES ET FONCTIONS PRIVEES -----------------------------------------
--

/*
  PROCEDURE P_insert_donnees ( s_entite       IN  PORTE_ENTITE.ENTITE%TYPE
                             , s_T_entite     IN  PORTE_ENTITE.DONNEE%TYPE);*/

  FUNCTION f_ctrlFichierAffil ( i_repertoire  IN       VARCHAR2
                              , i_Entreprise  IN       AFFIL_PORTE.ENTREPRISE%TYPE
                              , i_Trimestre   IN       NUMBER
                              , i_fichier     IN OUT   VARCHAR2
                              , o_erreur         OUT   VARCHAR2)
  RETURN NUMBER;

  FUNCTION f_insertAFFIL_PORTE( i_echange         IN       PORTE_ENTITE.IDECHANGE%TYPE
                              , i_numporte        IN       AFFIL_PORTE.NUMPORTE%TYPE
                              , i_fichier         IN       VARCHAR2
                              , o_numremise          OUT   AFFIL_PORTE.NUMREMISE%TYPE
                              , o_erreur             OUT   VARCHAR2)
  RETURN NUMBER;


   -- -- Déclaration des variables globales   ----------------------------------
  g_session         journal_adm.id_session%TYPE          DEFAULT 1;
  g_nom_traitement  journal_adm.nom_traitement%TYPE:=NULL;
  g_niv_msg         journal_adm.niv_msg%TYPE;
  g_idligne         journal_adm.idligne%TYPE;
  g_msg_adm         journal_adm.msg_adm%TYPE;

  G_trimestre                 NUMBER:=NULL;
  G_annee                     NUMBER:=NULL;
  g_fichier                   VARCHAR2 (200);
  g_date                      VARCHAR2 (8);
  g_echange                   PORTE_ECHANGE.IDECHANGE%TYPE:=2;
  g_extension                 LIBELLE.LIBELLE%TYPE:=NULL;
  g_numutil                   PORTE_PARAM.NUMUTIL%TYPE:=0;


  -- Chaine de reconnaissance SCCS
  -- %W%  %E%
  -- ---------------------------------------------- Fin des constantes privees --

  -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
  -- Aucune
  -- ---------------------------------------------- Fin des exceptions privees --

  -- -- TYPES PRIVEES -----------------------------------------------------------
  -- Aucun
  -- --------------------------------------------------- Fin des types privees --

  -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PUBLIQUES --------------------------

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  importAFFILIATION                                         */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l  import d un fichier contenant des      */
/*                 affiliations dans ainsi que l intégration des données     */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichier , fichier des affiliations                      */
/*                 i_Entreprise, contenu dans le nom du fichier              */
/*                 i_Trimestre, contenu dans le nom du fichier               */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE importAFFILIATION ( i_repertoire   IN   VARCHAR2
                            , i_fichier      IN   VARCHAR2
                            , i_Entreprise   IN   AFFIL_PORTE.ENTREPRISE%TYPE
                            , i_Trimestre    IN   NUMBER
                            , i_Porte        IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                            , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , o_erreur       OUT  VARCHAR2)
IS
  loc_ok             NUMBER:=0;
  loc_fichier        VARCHAR2(50);
  loc_numremise      AFFIL_PORTE.NUMREMISE%TYPE:=NULL;
  loc_AFFIL_PORTE    AFFIL_PORTE%ROWTYPE;
  loc_ano            NUMBER:=0;

BEGIN

  G_nom_traitement:=i_traitement;
  G_idligne:=i_idligne;
  G_Session := i_session;
  G_trimestre:=i_Trimestre;
  loc_fichier:=i_fichier;
  P_INS_journal(3, 'DEBUT PK_IMPORT_AFFIL.importAFFILIATION le '||TO_CHAR(SYSDATE));
  P_INS_journal(3, 'G_nom_traitement :'||G_nom_traitement);
  P_INS_journal(3, 'G_Session :'||TO_CHAR(G_Session));
  P_INS_journal(3, 'i_Entreprise :'||TO_CHAR(i_Entreprise));
  P_INS_journal(3, 'i_Trimestre '||TO_CHAR(i_Trimestre));
  P_INS_journal(3, 'i_Porte '||TO_CHAR(i_Porte));


    --------------- Récupération de l utilisateur de la porte  ------------------------
  g_numutil:=PK_CTRL_AFFIL.F_FIND_PORTE_NUMUTIL(i_Porte);
  P_INS_journal(3, 'g_numutil '||TO_CHAR(g_numutil));
  --------------------------------------------------------------------------------------------------------------------------------------
  -- Controle de la structure global du fichier, et insertion dans la table temporaire à partir de la table de paramétrage PORTE_ENTITE
  --------------------------------------------------------------------------------------------------------------------------------------
  loc_ok := f_ctrlFichierAffil (i_repertoire, i_Entreprise, i_Trimestre, loc_fichier, o_erreur);
  IF loc_ok = 0 THEN
    P_INS_journal(1, 'Erreur de format du nom de fichier : '||o_erreur);
  ELSE
    -- Insertion des donnes du fichier dans une table temporaire à l image du fichier avec l idechange de la table de paramétrage PORTE_ENTITE
    P_INS_journal(3, 'Controles des données du fichier ');
    loc_ok := f_InsertDonneesPorte (i_repertoire, loc_fichier,g_echange, o_erreur);
    IF loc_ok = 0 THEN
      P_INS_journal(1, 'Erreur de structure du fichier : '||o_erreur);
      ROLLBACK;
      DELETE AFFIL_FICHIER WHERE UPPER(ENTREPRISE)=UPPER(i_Entreprise)
                             AND UPPER(TRIMESTRE)=UPPER(G_trimestre)
                             AND UPPER(ANNEE)=UPPER(TO_CHAR(G_annee));
      COMMIT;
    ELSE
      -- On valide les donnes dans la table temporaire
      COMMIT;
    END IF;
  END IF;

  --------------------------------------------------------------------------------------------------------------------------------------
  -- Intégration des données dans la tables des affiliation : AFFIL_PORTE
  --------------------------------------------------------------------------------------------------------------------------------------
  IF loc_ok = 1 THEN
    loc_ok:=f_insertAFFIL_PORTE(g_echange,i_Porte, loc_fichier, loc_numremise ,o_erreur);
    IF loc_ok=1 THEN
      UPDATE AFFIL_FICHIER SET NUMREMISE=loc_numremise
       WHERE UPPER(FICHIER)=UPPER(loc_fichier)
         AND UPPER(ENTREPRISE)=UPPER(i_Entreprise)
         AND UPPER(TRIMESTRE)=UPPER(G_trimestre)
         AND UPPER(ANNEE)=UPPER(TO_CHAR(G_annee));
      COMMIT;
    ELSE
      P_INS_journal(1, 'Erreur d''insertion dans la table des AFFILIATIONS(AFFIL_PORTE) : '||o_erreur);
      ROLLBACK;
    END IF;
  END IF;
  --------------------------------------------------------------------------------------------------------------------------------------
  -- Controle de l intégration des données dans la tables des affiliation : AFFIL_PORTE ==> BLOCAGE ou DEBLOCAGE
  --------------------------------------------------------------------------------------------------------------------------------------
  IF loc_ok = 1 THEN
    loc_ok:=f_ctrlAFFIL_PORTE(i_Porte,loc_numremise,i_Entreprise,null,null,loc_ano,o_erreur);
    IF loc_ok=1 THEN
        P_INS_journal(3, 'COMMIT f_ctrlAFFIL_PORTE ');
      COMMIT;
    ELSE
        P_INS_journal(3, 'ROLLBACK f_ctrlAFFIL_PORTE ');
      ROLLBACK;
    END IF;
  END IF;


  P_INS_journal(3, 'FIN PK_IMPORT_AFFIL.importAFFILIATION le '||TO_CHAR(SYSDATE));

EXCEPTION
  WHEN OTHERS THEN



    -- Annulation de la validation de l import CFE et de l'ensemble des transactions dans Arthus
    ROLLBACK;
    P_INS_journal(1,'importAFFILIATION '||SUBSTR(SQLERRM,1,132));
END importAFFILIATION;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  AnnulImportAFFILIATION                                    */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l' annulation de l import du fichier des  */
/*                 affiliations                                              */
/* Entree       :  i_numremise, numéro de remise                             */
/*                 i_session ,                                               */
/*                 i_traitement                                              */
/*                 i_idligne                                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE AnnulImportAFFILIATION ( i_numremise    IN   AFFIL_PORTE.NUMREMISE%TYPE
                                 , i_numporte     IN   AFFIL_PORTE.NUMPORTE%TYPE
                                 , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                                 , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                                 , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                                 , o_erreur       OUT  VARCHAR2)
IS

BEGIN

  G_nom_traitement:=i_traitement;
  G_Session := i_session;
  G_idligne:=i_idligne;
  P_INS_journal(3, 'DEBUT PK_IMPORT_AFFIL.AnnulImportAFFILIATION le '||TO_CHAR(SYSDATE));
  P_INS_journal(3, 'NUMREMISE en cours d annulation '||TO_CHAR(i_numremise));

  -- Annulation de l import CFE et de l'ensemble des transactions dans Arthus
  PK_CTRL_AFFIL.P_ANNULATION_AFFILIATION(i_numremise,NULL,NULL,NULL,NULL,NULL,i_numporte,i_session,i_traitement,G_idligne,o_erreur);

  IF  o_erreur IS NOT NULL THEN
    P_INS_journal(1, o_erreur);
  END IF;
  COMMIT;
  P_INS_journal(3, 'Fin de l''annulation le '||TO_CHAR(SYSDATE));

EXCEPTION
  WHEN OTHERS THEN
    -- Annulation de l annulation de l import CFE et de l'ensemble des transactions dans Arthus
    ROLLBACK;
    P_INS_journal(1,SUBSTR(SQLERRM,1,132));
END AnnulImportAFFILIATION;


-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_ctrlFichierAffil                                        */
/* Type         :  Privee                                                    */
/* Description  :  Controle du nom de fichier, du répertoire, de la structure*/
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_Entreprise, Numéro d'entreprise                         */
/*                 i_Trimestre, Numéro de trimestre                          */
/*                 s_fichier, Nom du fichier                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_ctrlFichierAffil ( i_repertoire  IN       VARCHAR2
                            , i_Entreprise  IN       AFFIL_PORTE.ENTREPRISE%TYPE
                            , i_Trimestre   IN       NUMBER
                            , i_fichier     IN OUT   VARCHAR2
                            , o_erreur         OUT   VARCHAR2)
RETURN NUMBER
IS

  h_fichier                     UTL_FILE.file_type;

  exc_extension                 EXCEPTION;
  exc_par_repertoire_vide       EXCEPTION;
  exc_par_fichier_vide          EXCEPTION;
  exc_fichierImport             EXCEPTION;

  i_ok_import                   NUMBER:=0;

BEGIN
  i_ok_import:=0;
  P_INS_journal(3, 'i_fichier: '||i_fichier);


  IF i_Trimestre =4 THEN
  ------------------- Formatage du nom du fichier -----------------------------
    SELECT REPLACE(REPLACE(REPLACE (i_fichier, '#ADH', TO_CHAR(i_Entreprise)),'#TRIM',TO_CHAR(i_Trimestre)),'#DT',TO_CHAR(SYSDATE,'YYYY')-1)
      INTO i_fichier
      FROM DUAL;
    G_annee:=SUBSTR(i_fichier,19,4);
  ELSE
    SELECT REPLACE(REPLACE(REPLACE (i_fichier, '#ADH', TO_CHAR(i_Entreprise)),'#TRIM',TO_CHAR(i_Trimestre)),'#DT',TO_CHAR(SYSDATE,'YYYY'))
      INTO i_fichier
      FROM DUAL;
    G_annee:=SUBSTR(i_fichier,19,4);
  END IF;

  P_INS_journal(3, 'i_fichier: '||i_fichier);
  P_INS_journal(3, 'G_annee: '||TO_CHAR(G_annee));

  --------------- Controle du repertoire et du fichier ------------------------
  IF i_repertoire IS NULL THEN
     RAISE exc_par_repertoire_vide;
  END IF;

  IF i_fichier IS NULL OR i_fichier = ''
  THEN
     RAISE exc_par_fichier_vide;
  END IF;

  --------------- Controle de la préscence physique du fichier ------------------------
  g_extension:=F_LIBELLE_FORMAT('TYPFORMAT',1);
  IF TRIM(g_extension) IS NULL THEN
    RAISE exc_extension;
  END IF;
  h_fichier := UTL_FILE.fopen (i_repertoire, i_fichier||g_extension, 'R', 32767);
  UTL_FILE.fclose (h_fichier);


  P_INS_journal(3, 'i_fichier :'||i_fichier);

  --------------- Vérification que le fichier n a pas déja été importé ---------------
  SELECT NVL(MAX(1),0)
    INTO i_ok_import
    FROM AFFIL_FICHIER
   WHERE UPPER(FICHIER)=UPPER(i_fichier)
     AND UPPER(ENTREPRISE)=UPPER(i_Entreprise)
     AND UPPER(TRIMESTRE)=UPPER(i_Trimestre)
     AND UPPER(ANNEE)=UPPER(TO_CHAR(G_annee));

  IF i_ok_import=0 THEN
    INSERT INTO AFFIL_FICHIER(FICHIER,ENTREPRISE,TRIMESTRE,ANNEE)
       VALUES(i_fichier,TRIM(i_Entreprise),TO_CHAR(i_Trimestre),TO_CHAR(G_annee));
  ELSE
    RAISE exc_fichierImport;
  END IF;


  RETURN 1;

EXCEPTION
  WHEN exc_fichierImport THEN
    O_erreur := O_erreur|| ' Fichier déjà importé ';
    RETURN 0;
  WHEN exc_extension THEN
    O_erreur := O_erreur|| ' Extension du fichier non valide ou inexistante ';
    RETURN 0;
  WHEN exc_par_repertoire_vide THEN
    o_erreur:= O_erreur||'Nom du répertoire d''entrée manquant';
    RETURN 0;
  WHEN exc_par_fichier_vide THEN
    o_erreur:= O_erreur||'Nom du fichier d''entrée manquant';
    RETURN 0;
  WHEN DBMS_LOB.operation_failed THEN
    P_INS_journal(3, '1 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:=O_erreur||'Fichier '||i_fichier||' non présent dans le répertoire d''import';
    RETURN 0;
  WHEN UTL_FILE.internal_error THEN
    P_INS_journal(3, '2 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INTERNAL_ERROR';
    RETURN 0;
  WHEN UTL_FILE.invalid_filehandle THEN
    P_INS_journal(3, '3 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_FILEHANDLE';
    RETURN 0;
  WHEN UTL_FILE.invalid_mode THEN
    P_INS_journal(3, '4 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_MODE';
    RETURN 0;
  WHEN UTL_FILE.invalid_operation THEN
    P_INS_journal(3, '5 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:=' Nom de fichier invalide';
    RETURN 0;
  WHEN UTL_FILE.invalid_path THEN
    P_INS_journal(3, '6 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_PATH';
    RETURN 0;
  WHEN UTL_FILE.read_error THEN
    P_INS_journal(3, '7 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.READ_ERROR';
    RETURN 0;
  WHEN UTL_FILE.write_error THEN
    P_INS_journal(3, '8 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.WRITE_ERROR';
    RETURN 0;
  WHEN VALUE_ERROR THEN
    P_INS_journal(3, '9 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN 0;
  WHEN OTHERS THEN
    IF UTL_FILE.is_open (h_fichier) THEN
      P_INS_journal(3, '10 Fermeture du fichier');
      UTL_FILE.fclose (h_fichier);
    END IF;
    o_erreur:=G_nom_traitement||',' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN 0;
END f_ctrlFichierAffil ;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_InsertDonneesPorte                                        */
/* Type         :  Privee                                                    */
/* Description  :  Controle des données du fichier                           */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_Entreprise, Numéro d'entreprise                         */
/*                 i_Trimestre, Numéro de trimestre                          */
/*                 s_fichier, Nom du fichier                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_InsertDonneesPorte ( i_repertoire  IN       VARCHAR2
                              , i_fichier     IN       VARCHAR2
                              , i_echange     IN       PORTE_ENTITE.IDECHANGE%TYPE
                              , o_erreur         OUT   VARCHAR2)
RETURN NUMBER
IS

  h_fichier         UTL_FILE.file_type;
  nbligne           NUMBER(6);
  cpt               NUMBER(6);
  cpt2              NUMBER(6);
  s_ligne           VARCHAR2(453):=NULL;
  s_nb_separateur   NUMBER:=0;


  CURSOR C_ENTITE (p_echange NUMBER) IS
  SELECT e.entite,e.donnee,e.taille,e.statut,e.balise,e.position,e.contrainte,o.action
    FROM PORTE_ENTITE_ORDRE o , PORTE_ENTITE e
   WHERE o.idechange = p_echange
     AND o.idechange = e.idechange
     AND o.entite = e.entite
     AND e.position>=1
    ORDER BY e.position;

  CURSOR C_ECHANGE (p_echange NUMBER) IS
  SELECT e.TYPE_FORMAT, e.SEPARATEUR, e.LONGUEUR, e.ENTETE,e.APOSTROPHE
    FROM PORTE_ECHANGE e
   WHERE e.idechange = p_echange;

  CURSOR C_PORTE_ENTITE (p_entite PORTE_ENTITE.ENTITE%TYPE) IS
  SELECT COLUMN_NAME
    FROM USER_TAB_COLUMNS WHERE TABLE_NAME=p_entite
   ORDER BY COLUMN_ID;


  Rec_C_ENTITE       C_ENTITE%ROWTYPE;
  Rec_C_ECHANGE      C_ECHANGE%ROWTYPE;
  Rec_C_PORTE_ENTITE C_PORTE_ENTITE%ROWTYPE;

  l_T_ligne T_ligne;
  l_T_import T_import;
  l_T_entite T_entite;
  l_T_entite_empty T_entite;

  --objet
  Imp_AFFIL_PORTE AFFIL_PORTE%ROWTYPE;
  stmt            VARCHAR2(600);
  s_entite        PORTE_ENTITE.ENTITE%TYPE;
  s_donnee        PORTE_ENTITE.DONNEE%TYPE;
  s_colonne       PORTE_ENTITE.DONNEE%TYPE;


  exc_bad_fichier        EXCEPTION;
  exc_bad_separateur     EXCEPTION;
  cpt_bad_entete         NUMBER:=0;--compteur de rejet
  cpt_bad_param          NUMBER:=0;--compteur de rejet
  cpt_bad_ligne          NUMBER:=0;--compteur de rejet
  cpt_bad_entite         NUMBER:=0;--compteur de rejet
  cpt_bad_insert         NUMBER:=0;--compteur de rejet
  cpt_rejet              NUMBER:=0;--Compteur global des rejets

BEGIN
  P_INS_journal(3, 'f_InsertDonneesPorte :'||i_fichier);
  cpt_rejet:=0;
  ---------------------Récupération de l'entité à traiter et de la colonne donnee pour gérer l'entete
  BEGIN
    SELECT e.entite,e.donnee
      INTO s_entite, s_donnee
      FROM PORTE_ENTITE e
     WHERE e.idechange=i_echange
       AND e.position=1;

    --**************************************************************************************************************
    -- Création de la table temporaire dynamiquement(AFFIL_TMP) afin de pouvoir géréer l'ajout d'une future nouvelle
    -- colonne dans la table PORTE_ENTITE
    --**************************************************************************************************************
    cpt_bad_param:=createTableEchange(s_entite,i_echange);
    IF cpt_bad_param=0 THEN
      P_INS_journal(3, 'Impossible de créer la table temporaire');
      cpt_bad_param:=cpt_bad_param+1;
    ELSE
      cpt_bad_param:=0;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(3, 'Mauvais echange dans la table de paramétrage');
      cpt_bad_param:=cpt_bad_param+1;
  END;


  FOR Rec_C_ECHANGE IN C_ECHANGE(i_echange) LOOP
    ------------------- Ouverture du fichier ------------------------------------
    h_fichier := UTL_FILE.fopen (i_repertoire, i_fichier||g_extension, 'R', 32767);
    ---------------- Parcours de chaque ligne du fichier ------------------------
    P_INS_journal(3, 'Ouverture du fichier');

    nbligne:=0;
    cpt:=0;
    cpt2:=0;
    --parcourt des lignes d'un fichier
    WHILE PK_FICHIER.fGetLine(h_fichier,s_ligne) LOOP
      -- Vérification du bon nombre de séparateur
      s_nb_separateur:=(length(s_ligne) - length(replace(s_ligne, ';')));
      IF s_nb_separateur=25 THEN
        s_ligne:=s_ligne||';';
      ELSIF s_nb_separateur>26 THEN
        RAISE exc_bad_separateur;
      END IF;

      cpt:=cpt+1;
      --manipulation de la lgine sous forme de tableau
     -- P_INS_journal(3, 'avant cpt <'||cpt||'> ');
    --  P_INS_journal(3, 'avant cpt2 <'||cpt2||'> ');
      l_T_ligne:= S2A(s_ligne,Rec_C_ECHANGE.SEPARATEUR);
      -- Parcour de l objet
      stmt:=NULL;
      s_colonne:=NULL;

      -- On exclut l entete et on vérifie le parametrage de celle ci dans la table
      IF Rec_C_ECHANGE.ENTETE != cpt THEN
        cpt2:=cpt2+1;
        BEGIN
          FOR Rec_C_PORTE_ENTITE IN C_PORTE_ENTITE(s_entite) LOOP
            stmt:=stmt||Rec_C_PORTE_ENTITE.COLUMN_NAME||',';
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            cpt_bad_entite:=cpt_bad_entite+1;
        END;
        stmt:=RTRIM(stmt,',');
       --ABO 26/08/2013 forçage d'un auto incrément pour conserver l'ordre originel du fichier
        stmt:='INSERT INTO '||s_entite||' ('|| stmt ||') VALUES ('||cpt2||', ';
        --parcourt des entités suivant l'odre paramétré et en tenant compte de l'action
        BEGIN
          FOR Rec_C_ENTITE IN C_ENTITE(g_echange) LOOP
            s_colonne:=Rec_C_ENTITE.donnee;
            l_T_entite(Rec_C_ENTITE.entite||'.'||Rec_C_ENTITE.donnee):=l_T_ligne(Rec_C_ENTITE.position);
            stmt:=stmt||''''|| SUBSTR(TRIM(REPLACE(l_T_entite(Rec_C_ENTITE.entite||'.'||Rec_C_ENTITE.donnee)
                                      ,Rec_C_ECHANGE.APOSTROPHE
                                      ,Rec_C_ECHANGE.APOSTROPHE||Rec_C_ECHANGE.APOSTROPHE)),1,Rec_C_ENTITE.taille)||''',';

         /*   P_INS_journal(3, 'cpt <'||cpt||'> ');
            P_INS_journal(3, 'cpt2 <'||cpt2||'> ');
            P_INS_journal(3, 'stmt <'||stmt||'> ');
            P_INS_journal(3, 'entite <'||to_char(l_T_entite(Rec_C_ENTITE.entite||'.'||Rec_C_ENTITE.donnee))||'> ');*/

          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            --insert into TMP_AFFIL_ANO values(stmt);commit;
            P_INS_journal(3, ' Ligne <'||TO_CHAR(cpt)||'> du fichier invalide,Infos de la colonne <'||s_colonne||'> mal placée ou trop longue ');
            s_colonne:=Rec_C_ENTITE.donnee;
            cpt_bad_ligne:=cpt_bad_ligne+1;
        END;
        stmt:=RTRIM(stmt,',');
        stmt:=stmt||')';
        --insert into TMP_AFFIL_ANO values(stmt);commit;
        --P_INS_journal(3, 'stmt:'||stmt);
        nbligne:=nbligne+1;
        BEGIN
          EXECUTE IMMEDIATE stmt ;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            --P_INS_journal(3, SUBSTR (SQLERRM (SQLCODE), 1, 128));
            --P_INS_journal(3,'SQLCODE:'|| SQLCODE);
            CASE SQLCODE
              WHEN '-917'   THEN P_INS_journal(3,' Ligne <'||TO_CHAR(cpt)||'> invalide(Problème d''apostrophe)');
              WHEN '-947'   THEN P_INS_journal(3,' Ligne <'||TO_CHAR(cpt)||'> invalide(Nb colonnes insuffisantes)');
              WHEN '-12899' THEN P_INS_journal(3,' Ligne <'||TO_CHAR(cpt)||'> invalide(nb caractères trop long pour la colonne<'||SUBSTR (SQLERRM (SQLCODE), 68, 128)||'>)');
            ELSE
              P_INS_journal(3, 'Ligne <'||TO_CHAR(cpt)||'> : Erreur indéterminée :' ||SQLERRM);
            END CASE;
            cpt_bad_insert:=cpt_bad_insert+1;
        END;
        l_T_import(nbligne):=l_T_entite;
        l_T_entite:=l_T_entite_empty; --réinitialisation
      ELSE
        IF SUBSTR(s_ligne, 1, LENGTH(s_donnee)) != s_donnee /*AND Rec_C_ECHANGE.ENTETE != cpt*/ THEN
          cpt_bad_entete:=cpt_bad_entete+1;
        END IF;
      END IF;
    END LOOP;

  END LOOP;

  -- Gestion des compteurs de rejet
  P_INS_journal(1, 'Le nombre de Lignes avec une structure invalide est de  <'||TO_CHAR(cpt_bad_insert)||'> ');
  P_INS_journal(1, 'Le nombre de Lignes avec une colonne invalide est de  <'||TO_CHAR(cpt_bad_ligne)||'>');
  IF cpt_bad_entete>0 THEN
    P_INS_journal(1, 'Entete du fichier non valide ou inexistante');
    cpt_rejet:=cpt_rejet+cpt_bad_entete;
  END IF;
  IF cpt_bad_param>0 THEN
    P_INS_journal(1, 'Mauvais echange dans la table de paramétrage');
    cpt_rejet:=cpt_rejet+cpt_bad_param;
  END IF;
  IF cpt_bad_insert>0 THEN
    cpt_rejet:=cpt_rejet+cpt_bad_insert;
  END IF;
  IF cpt_bad_ligne>0 THEN
    cpt_rejet:=cpt_rejet+cpt_bad_ligne;
  END IF;

/*
  CASE
    WHEN cpt_bad_entete>0 THEN
      P_INS_journal(3, 'Entete du fichier non valide ou inexistante');
      cpt_rejet:=cpt_rejet+1;
    WHEN cpt_bad_param>0 THEN
      P_INS_journal(3, 'Mauvais echange dans la table de paramétrage');
      cpt_rejet:=cpt_rejet+1;
    WHEN cpt_bad_insert>0 THEN
      P_INS_journal(3, 'Le nombre de Lignes invalide est de  <'||TO_CHAR(cpt_bad_insert)||'> (nb caractères trop long pour 1 colonne)');
      cpt_rejet:=cpt_rejet+1;
    WHEN cpt_bad_ligne>0 THEN
      P_INS_journal(3, ' Le nombre de Lignes avec une colonne invalide est de  <'||TO_CHAR(cpt_bad_ligne)||'>');
      cpt_rejet:=cpt_rejet+1;
    ELSE
      P_INS_journal(3, 'Erreur indéterminée');
      cpt_rejet:=cpt_rejet+1;
  END CASE;
*/

  P_INS_journal(1, 'Le nombre de lignes traité dans le fichier est de <'||cpt||'>');
  P_INS_journal(1, 'Le nombre de lignes traité sans entête dans le fichier est de <'||cpt2||'>');

  IF cpt_rejet>0 THEN
    RAISE exc_bad_fichier;
  ELSE
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    RETURN 1;
  END IF;


EXCEPTION
  WHEN exc_bad_fichier THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    O_erreur := O_erreur|| ' Le nombre total de Lignes invalide est de  <'||TO_CHAR(cpt_bad_insert)||'>';
    RETURN 0;
  WHEN exc_bad_separateur THEN
    O_erreur := O_erreur|| ' Le nombre total de colonne invalide.Vérifier la structure du fichier';
    RETURN 0;
  WHEN DBMS_LOB.operation_failed THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:=O_erreur||'Fichier '||i_fichier||' non présent dans le répertoire d''import';
    RETURN 0;
  WHEN UTL_FILE.internal_error THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INTERNAL_ERROR';
    RETURN 0;
  WHEN UTL_FILE.invalid_filehandle THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_FILEHANDLE';
    RETURN 0;
  WHEN UTL_FILE.invalid_mode THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_MODE';
    RETURN 0;
  WHEN UTL_FILE.invalid_operation THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_OPERATION';
    RETURN 0;
  WHEN UTL_FILE.invalid_path THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_PATH';
    RETURN 0;
  WHEN UTL_FILE.read_error THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.READ_ERROR';
    RETURN 0;
  WHEN UTL_FILE.write_error THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.WRITE_ERROR';
    RETURN 0;
  WHEN VALUE_ERROR THEN
    P_INS_journal(3, 'Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN 0;
  WHEN OTHERS THEN
    IF UTL_FILE.is_open (h_fichier) THEN
      P_INS_journal(3, 'Fermeture du fichier');
      UTL_FILE.fclose (h_fichier);
    END IF;
    o_erreur:=G_nom_traitement||',' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN 0;
END f_InsertDonneesPorte;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  createTableEchange                                        */
/* Type         :  Privee                                                    */
/* Description  :  Création d une table temporaire à partir de la table de   */
/*                 paramétrage PORTE_ENTITE                                  */
/* Entree       :  i_entite,table a creer                                    */
/* Retour       :  retourne 1 ok, 0 Ko                                        */
/*---------------------------------------------------------------------------*/
FUNCTION createTableEchange( i_entite         IN       PORTE_ENTITE.ENTITE%TYPE, i_echange IN PORTE_ENTITE.IDECHANGE%TYPE)
RETURN NUMBER
IS
  CURSOR C_PORTE_ENTITE ( p_entite PORTE_ENTITE.ENTITE%TYPE, p_echange  PORTE_ENTITE.IDECHANGE%TYPE)
      IS
  SELECT pe.DONNEE, pe.TAILLE
    FROM PORTE_ENTITE pe
   WHERE pe.ENTITE = p_entite
   AND pe.idechange = p_echange
  ORDER BY pe.position;

  Rec_C_PORTE_ENTITE       C_PORTE_ENTITE%ROWTYPE;
  stmt                     VARCHAR2(5000);

BEGIN
  -----------------------------------------------------------------------------
  -- Suppression de la table de travail
  -----------------------------------------------------------------------------
  BEGIN
     stmt:=NULL;
     stmt:='DROP TABLE '||i_entite;
     EXECUTE IMMEDIATE stmt ;
  EXCEPTION
   WHEN OTHERS THEN  dbms_output.put_line( 'DROP'||SQLERRM);
  END;
  -----------------------------------------------------------------------------
  -- Création de la table de travail dynamiquement
  -----------------------------------------------------------------------------
  stmt:=NULL;
  stmt:='CREATE TABLE ARTHUS.'||i_entite||' (';
  FOR Rec_C_AFFIL_TMP IN C_PORTE_ENTITE (i_entite,i_echange) LOOP
    stmt:=stmt||Rec_C_AFFIL_TMP.DONNEE||' VARCHAR2('||Rec_C_AFFIL_TMP.TAILLE||'),';
  END LOOP;
  stmt:=RTRIM(stmt,',');
  stmt:=stmt||')';
  dbms_output.put_line(stmt);

  EXECUTE IMMEDIATE stmt ;

  RETURN 1;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1 ,'createTableEchange '||SUBSTR(SQLERRM,1,132));
    RETURN 0;
END createTableEchange;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_insertAFFIL_PORTE                                       */
/* Type         :  Privee                                                    */
/* Description  :  Insere les donnees issues du fichier des affiliation dans */
/*                 la table AFFIL_PORTE                                      */
/* Entree       :  I_string,                                                 */
/*                 I_delim, delimitateur du fichier à traiter                */
/* Retour       :  Un tableau de ligne                                       */
/*---------------------------------------------------------------------------*/
FUNCTION f_insertAFFIL_PORTE( i_echange         IN       PORTE_ENTITE.IDECHANGE%TYPE
                            , i_numporte        IN       AFFIL_PORTE.NUMPORTE%TYPE
                            , i_fichier         IN       VARCHAR2
                            , o_numremise          OUT   AFFIL_PORTE.NUMREMISE%TYPE
                            , o_erreur             OUT   VARCHAR2)
RETURN NUMBER
IS
  cpt                NUMBER:=0;
  cpt_ano            NUMBER:=0;
  loc_AFFIL_PORTE    AFFIL_PORTE%ROWTYPE;
  loc_PORTE_REMISE   PORTE_REMISE%ROWTYPE;
  loc_dateporte      PORTE_REMISE.DATEPORTE%TYPE:=NULL;
  loc_journal        JOURNAL_ADM%ROWTYPE;


  CURSOR C_AFFIL_TMP IS
  SELECT NUMLIGNE
       , ENTREPRISE
       , NUMSSA
       , NUMCLE
       , NOMSAL
       , PRENOM
       , NOMNAIS
       , CADRNC
       , CATEGP
       , MATRIC
       , ETABLI
       , DEBUTC
       , FINCON
       , SALATA
       , SALATB
       , DATNAI
       , SITFAM
       , NBENFA
       , COMPLAD
       , ADREVOIE
       , COMPLAD2
       , CODPOS
       , VILLE
       , MOTIFS
       , MOTIFA
       , DEBEFF
       , FINEFF
   FROM AFFIL_TMP
  ORDER BY TO_NUMBER(NUMLIGNE) ASC;

  Rec_C_AFFIL_TMP       C_AFFIL_TMP%ROWTYPE;

BEGIN
  SELECT SEQ_AFFIL_PORTE.NEXTVAL INTO o_numremise FROM DUAL;

  FOR Rec_C_AFFIL_TMP IN C_AFFIL_TMP LOOP
    loc_AFFIL_PORTE.NUMREMISE:=o_numremise;
    loc_AFFIL_PORTE.NUMPORTE:=i_numporte;
    loc_AFFIL_PORTE.DATRAIT:=TRUNC(SYSDATE);
    loc_AFFIL_PORTE.ETAT:=1;-- Importée
    loc_AFFIL_PORTE.NUMLIGNE:=TO_NUMBER(Rec_C_AFFIL_TMP.NUMLIGNE);
    loc_AFFIL_PORTE.NUMINDIV:=NULL;
    loc_AFFIL_PORTE.NUMCLI:=NULL;
    loc_AFFIL_PORTE.MATORGINDIV:=0;
    loc_AFFIL_PORTE.USERNAME_FORCAGE:=g_numutil;
    loc_AFFIL_PORTE.IDADHESION:=NULL;
    loc_AFFIL_PORTE.DEBUT:=loc_AFFIL_PORTE.DATRAIT;
    loc_AFFIL_PORTE.MOTIF:=NULL;
    loc_AFFIL_PORTE.ENTREPRISE:=Rec_C_AFFIL_TMP.ENTREPRISE;
    loc_AFFIL_PORTE.NUMSSA:=Rec_C_AFFIL_TMP.NUMSSA;
    loc_AFFIL_PORTE.NUMCLE:=Rec_C_AFFIL_TMP.NUMCLE;
    loc_AFFIL_PORTE.NOMSAL:=Rec_C_AFFIL_TMP.NOMSAL;
    loc_AFFIL_PORTE.PRENOM:=Rec_C_AFFIL_TMP.PRENOM;
    loc_AFFIL_PORTE.NOMNAIS:=Rec_C_AFFIL_TMP.NOMNAIS;
    loc_AFFIL_PORTE.CADRNC:=Rec_C_AFFIL_TMP.CADRNC;
    loc_AFFIL_PORTE.CATEGP:=Rec_C_AFFIL_TMP.CATEGP;
    loc_AFFIL_PORTE.MATRIC:=Rec_C_AFFIL_TMP.MATRIC;
    loc_AFFIL_PORTE.ETABLI:=Rec_C_AFFIL_TMP.ETABLI;
    loc_AFFIL_PORTE.DEBUTC:=Rec_C_AFFIL_TMP.DEBUTC;
    loc_AFFIL_PORTE.FINCON:=Rec_C_AFFIL_TMP.FINCON;
    loc_AFFIL_PORTE.SALATA:=Rec_C_AFFIL_TMP.SALATA;
    loc_AFFIL_PORTE.SALATB:=Rec_C_AFFIL_TMP.SALATB;
    loc_AFFIL_PORTE.DATNAI:=Rec_C_AFFIL_TMP.DATNAI;
    loc_AFFIL_PORTE.SITFAM:=Rec_C_AFFIL_TMP.SITFAM;
    loc_AFFIL_PORTE.NBENFA:=Rec_C_AFFIL_TMP.NBENFA;
    loc_AFFIL_PORTE.COMPLAD:=Rec_C_AFFIL_TMP.COMPLAD;
    loc_AFFIL_PORTE.ADREVOIE:=Rec_C_AFFIL_TMP.ADREVOIE;
    loc_AFFIL_PORTE.VILLE:=Rec_C_AFFIL_TMP.VILLE;
    loc_AFFIL_PORTE.CODPOS:=Rec_C_AFFIL_TMP.CODPOS;
    loc_AFFIL_PORTE.COMPLAD2:=Rec_C_AFFIL_TMP.COMPLAD2;
    loc_AFFIL_PORTE.MOTIFS:=Rec_C_AFFIL_TMP.MOTIFS;
    loc_AFFIL_PORTE.MOTIFA:=Rec_C_AFFIL_TMP.MOTIFA;
    loc_AFFIL_PORTE.DEBEFF:=Rec_C_AFFIL_TMP.DEBEFF;
    loc_AFFIL_PORTE.FINEFF:=Rec_C_AFFIL_TMP.FINEFF;

    IF PK_CTRL_AFFIL.F_INS_AFFIL_PORTE(loc_AFFIL_PORTE,loc_journal) THEN
      cpt_ano:=cpt_ano;
    ELSE
      P_INS_journal(1 ,'Infos oblig. manquantes dans le fichier, ligne : <'||TO_CHAR(TO_NUMBER(Rec_C_AFFIL_TMP.NUMLIGNE)+1)||'>');
      cpt_ano:=cpt_ano+1;
    END IF;
  END LOOP;

  BEGIN
    SELECT TRUNC(ADD_MONTHS(e2d('01/01/'||SUBSTR(i_fichier,19,4)),(SUBSTR(i_fichier,17,1)-1)*3))
      INTO loc_dateporte
      FROM DUAL;
  EXCEPTION
    WHEN OTHERS THEN
      loc_dateporte:=loc_AFFIL_PORTE.DATRAIT;
  END;

  -- Insertion dans PORTE_REMISE de la remise en cours
  loc_PORTE_REMISE.NUMREMISE:=loc_AFFIL_PORTE.NUMREMISE;
  loc_PORTE_REMISE.NUMPORTE:=loc_AFFIL_PORTE.NUMPORTE;
  loc_PORTE_REMISE.DATEREMISE:=loc_AFFIL_PORTE.DATRAIT;
  loc_PORTE_REMISE.BATCH:=G_nom_traitement;
  loc_PORTE_REMISE.DATEPORTE:=loc_dateporte;
  loc_PORTE_REMISE.NATURE:=NULL;
  loc_PORTE_REMISE.REF_EXT:=i_fichier;
  g_fichier:=i_fichier;
  IF PK_CTRL_AFFIL.F_INS_PORTE_REMISE(loc_PORTE_REMISE) THEN
    cpt_ano:=cpt_ano;
  ELSE
    P_INS_journal(1 ,'Infos oblig. manquantes dans le fichier, ligne : <'||TO_CHAR(TO_NUMBER(loc_AFFIL_PORTE.NUMLIGNE)+1)||'>');
    cpt_ano:=cpt_ano+1;
  END IF;

  P_INS_journal(1 ,'La remise importée pour les affiliations est <'||loc_AFFIL_PORTE.NUMREMISE||'>');


  IF cpt_ano>1 THEN
    RETURN 0;
  ELSE
    RETURN 1;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1 ,'f_insertAFFIL_PORTE '||SUBSTR(SQLERRM,1,132));
    o_erreur:='f_insertAFFIL_PORTE '||SUBSTR(SQLERRM,1,132);
    RETURN 0;
END f_insertAFFIL_PORTE;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_ctrlAFFIL_PORTE                                         */
/* Type         :  Privee                                                    */
/* Description  :  Controles des affiliations dans la table AFFIL_PORTE.     */
/*                 Si controle OK, insertion ou mise à jour des donnes, si   */
/*                 controles KO mise blocage de l affiliation avec un message*/
/*                 d anomalie dans AFFIL_ANO                                 */
/* Entree       :  i_echange                                                 */
/*                 i_numporte                                                */
/*                 i_numremise                                               */
/* Retour       :  o_erreur                                                  */
/* Retour       :  1 ok, 0 ko                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_ctrlAFFIL_PORTE( i_numporte        IN       AFFIL_PORTE.NUMPORTE%TYPE
                          , i_numremise       IN       AFFIL_PORTE.NUMREMISE%TYPE
                          , i_Entreprise      IN       AFFIL_PORTE.ENTREPRISE%TYPE
                          , i_numligne        IN       AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                          , i_etat            IN       AFFIL_PORTE.ETAT%TYPE DEFAULT NULL
                          , o_ano                OUT   AFFIL_ANO.NUMANO%TYPE
                          , o_erreur             OUT   VARCHAR2)
RETURN NUMBER
IS

  cpt                NUMBER:=0;
  cpt_ano            NUMBER:=0;
  cpt_ano_tot        NUMBER:=0;


  -- Objets
  loc_AFFIL_ANO         AFFIL_ANO%ROWTYPE;
  loc_AFFIL_PORTE       AFFIL_PORTE%ROWTYPE;
  loc_INDIVIDU          INDIVIDU%ROWTYPE;
  loc_PERS_HISTO_PHYS   PERS_HISTO_PHYS%ROWTYPE;
  loc_PERS_ADRESSE      PERS_ADRESSE%ROWTYPE;
  loc_VAL_VARIABLE      VAL_VARIABLE%ROWTYPE;
  loc_dateff            CONTRAT.DATEFF%TYPE;
  loc_MVT               NUMBER;
  loc_trimestre         NUMBER:=0;

  -- Données
  loc_numgar         ADHE_CNTRT.NUMGAR%TYPE:=NULL;
  loc_idadhesion     ADHESION.IDADHESION%TYPE:=NULL;
  loc_numcli         CONTRAT.NUMCLI%TYPE:=NULL;

  -- Anomalies
  loc_ano_affil_ano  AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_affiporte  AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_indiv      AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_adr        AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_numindiv   AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_histophys  AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_valvar     AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_contrat    AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_adhesion   AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_majadhes   AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_majaffil   AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_qualite        AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_regul          AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_refcie     AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_matorg     AFFIL_ANO.NUMANO%TYPE:=NULL;


  loc_erreur VARCHAR2(200);

  -- Anomalies avec avertissement (état 7)
  loc_anoSalaireA   AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_anoSalaireB   AFFIL_ANO.NUMANO%TYPE:=NULL;

  -- exceptions
  exc_societe              EXCEPTION;
  exc_participant          EXCEPTION;
  exc_affil                EXCEPTION;
  exc_individu             EXCEPTION;
  exc_histophys            EXCEPTION;
  exc_val_variable         EXCEPTION;
  exc_pers_adresse         EXCEPTION;
  exc_numgar               EXCEPTION;
  exc_souscripteur         EXCEPTION;
  exc_numgar_ko            EXCEPTION;
  exc_contrat              EXCEPTION;
  exc_adhesion             EXCEPTION;
  exc_regul                EXCEPTION;
  exc_regime_noRU          EXCEPTION;
  exc_refcie               EXCEPTION;
  exc_matorg               EXCEPTION;
  exc_affil_salTA          EXCEPTION;

 -- Flag
  loc_flag_integ           NUMBER:=0;

  CURSOR C_AFFIL_PORTE
      IS
  SELECT NUMLIGNE
   FROM AFFIL_PORTE
  WHERE AFFIL_PORTE.NUMREMISE=i_numremise
    AND AFFIL_PORTE.NUMPORTE=i_numporte
    AND AFFIL_PORTE.NUMLIGNE=NVL(i_numligne,AFFIL_PORTE.NUMLIGNE)
    AND AFFIL_PORTE.ETAT=NVL(i_etat,AFFIL_PORTE.ETAT)
  ORDER BY NUMLIGNE ASC;

  Rec_C_AFFIL_PORTE       C_AFFIL_PORTE%ROWTYPE;

BEGIN

  cpt:=0;
  o_ano:=0;
  IF i_etat IS NOT NULL THEN
    loc_flag_integ:=1;
  ELSE
    loc_flag_integ:=0;
  END IF;


  FOR Rec_C_AFFIL_PORTE IN C_AFFIL_PORTE LOOP

    BEGIN
      loc_qualite:=0;
      cpt:=cpt+1;
      cpt_ano:=0;
      loc_ano_valvar:=0;
      ---------------------------------------------------------------------------------------------------------
      -- Suppression des anomalies si c'est une intégration manuel des affiliations : état à 2 pour la remise en cours
      ---------------------------------------------------------------------------------------------------------
      IF loc_flag_integ = 1 THEN
        PK_CTRL_AFFIL.P_DEL_AFFIL_ANO( i_numremise
                                     , Rec_C_AFFIL_PORTE.numligne
                                     , i_numporte);
        COMMIT;-- M4436 : suppression des ano car sinon on insère 2 fois l'anomalie lors d'un déblocage ko
      END IF;
      ---------------------------------------------------------------------------------------------------------
      -- Initialisation de l'objet loc_AFFIL_PORTE
      ---------------------------------------------------------------------------------------------------------
      PK_CTRL_AFFIL.P_INIT_AFFIL_PORTE( i_numporte
                                      , i_numremise
                                      , Rec_C_AFFIL_PORTE.NUMLIGNE
                                      , loc_AFFIL_PORTE
                                      , loc_ano_affiporte);
      IF loc_ano_affiporte > 0 THEN
        loc_AFFIL_ANO.NUMANO:=12;-- Recheche du participant : Erreur indéterminé
        RAISE exc_affil;
      END IF;

      ---------------------------------------------------------------------------------------------------------
      -- Initialisation de l'objet loc_AFFIL_ANO pour d eventuelles anomalies d integration fonctionnelle
      ---------------------------------------------------------------------------------------------------------
      loc_AFFIL_ANO.NUMREMISE:=loc_AFFIL_PORTE.NUMREMISE;
      loc_AFFIL_ANO.NUMPORTE:=loc_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_ANO.NUMLIGNE:=loc_AFFIL_PORTE.NUMLIGNE;
      loc_AFFIL_ANO.DATANO:=loc_AFFIL_PORTE.DATRAIT;
      loc_AFFIL_ANO.NUMANO:=NULL;
      loc_AFFIL_ANO.ETATANO:=NULL;

      ---------------------------------------------------------------------------------------------------------
      -- Controle de cohérence entre le numéro de société du fichier le le numéro de société de l affiliation
      ---------------------------------------------------------------------------------------------------------
      loc_AFFIL_ANO.NUMANO:=PK_CTRL_AFFIL.P_CTRL_SOCIETE( loc_AFFIL_PORTE.NUMREMISE
                                                        , loc_AFFIL_PORTE.NUMPORTE
                                                        , loc_AFFIL_PORTE.NUMLIGNE
                                                        , loc_AFFIL_PORTE.ENTREPRISE
                                                        , i_Entreprise);
      P_INS_journal(3, 'Controle de la société :'||i_Entreprise);
      IF loc_AFFIL_ANO.NUMANO> 0 THEN
         RAISE exc_societe;
      END IF;

        ---------------------------------------------------------------------------------
        -- **********************RECHERCHE PARTICIPANT **********************************
        ---------------------------------------------------------------------------------

      ---------------------------------------------------------------------------------------------------------
      -- Recherche du numéro de l assure a partir du nom, prenom, numéro de sécu et de la date de naissance
      ---------------------------------------------------------------------------------------------------------
      loc_AFFIL_ANO.NUMANO:=NULL;
      loc_INDIVIDU.NUMINDIV:=NULL;
      loc_INDIVIDU.NUMINDIV:=PK_CTRL_AFFIL.F_FIND_PARTICIPANT( loc_AFFIL_PORTE.NUMSSA
                                                             , loc_AFFIL_PORTE.NOMSAL
                                                             , loc_AFFIL_PORTE.DATNAI
                                                             , loc_AFFIL_PORTE.NUMINDIV);
      P_INS_journal(3, 'Controle du participant :'||loc_AFFIL_PORTE.NOMSAL);


      -- Anomalie du participant
      IF loc_INDIVIDU.NUMINDIV<0 THEN
        IF loc_INDIVIDU.NUMINDIV = - 1 THEN
          loc_AFFIL_ANO.NUMANO:=2;-- Anomalie de doublon d individu
        ELSIF loc_INDIVIDU.NUMINDIV = - 2 THEN
          loc_AFFIL_ANO.NUMANO:=11;-- Participant non trouvé
        ELSIF loc_INDIVIDU.NUMINDIV = - 2 THEN
          loc_AFFIL_ANO.NUMANO:=41;-- Numéro de sécurité sociale non standard
        ELSE
          loc_AFFIL_ANO.NUMANO:=12;-- Recheche du participant : Erreur indéterminé
        END IF;
        RAISE exc_participant;
      -- Individu trouvé
      ELSIF loc_INDIVIDU.NUMINDIV>0 THEN
        P_INS_journal(3, 'Individu trouvé :'||loc_INDIVIDU.NUMINDIV);
        P_INS_journal(3, 'Individu trouvé loc_AFFIL_PORTE.MATRIC :'||loc_AFFIL_PORTE.MATRIC);

        -- Mise à jour de la REFCIE si elle est absente dans la table individu
        PK_CTRL_AFFIL.P_MAJ_INDIVIDU_REFCIE( loc_INDIVIDU.NUMINDIV
                                           , loc_AFFIL_PORTE.MATRIC
                                           , loc_ano_refcie);
        P_INS_journal(3, 'P_MAJ_INDIVIDU_REFCIE loc_ano_refcie :'||loc_ano_refcie);
        IF loc_ano_refcie>0 THEN
          RAISE exc_refcie;
        END IF;
        -- Mise à jour du numéro de sécu a blanc si il se termine par 999 pour l individu trouvé
        IF SUBSTR(loc_AFFIL_PORTE.NUMSSA,11,3)='999' THEN
        P_INS_journal(3, 'P_MAJ_INDIVIDU_MATORG loc_ano_matorg :'||loc_ano_matorg);
          PK_CTRL_AFFIL.P_MAJ_INDIVIDU_MATORG( loc_INDIVIDU.NUMINDIV
                                             , loc_AFFIL_PORTE.NUMSSA
                                             , loc_ano_matorg);
          IF loc_ano_matorg>0 THEN
            RAISE exc_matorg;
          END IF;
        END IF;
        P_INS_journal(3, '2 P_MAJ_INDIVIDU_MATORG loc_ano_matorg :'||loc_ano_matorg);
      ELSE
        ---------------------------------------------------------------------------------
        -- ********************** INDIVIDU **********************************************
        ---------------------------------------------------------------------------------
        -- Si le numéro de sécu est absent, on passe l affiliation a l état 7
        -- et on met par défaut la civilité à 1 (Masculin))
        IF TRIM(loc_AFFIL_PORTE.NUMSSA) IS NULL THEN
          PK_CTRL_AFFIL.P_AFFIL_ANO(loc_AFFIL_PORTE,52,7,loc_AFFIL_PORTE.DATRAIT);
          loc_qualite:=1;
        END IF;
        PK_CTRL_AFFIL.P_GestionIndividu( loc_AFFIL_PORTE
                                       , NULL -- Pas de AFFIL_PORTE_AYD
                                       , loc_INDIVIDU
                                       , loc_ano_indiv);

        P_INS_journal(3, 'Controle de l individu :'||loc_INDIVIDU.NUMINDIV);
        IF loc_ano_indiv>0 THEN
          RAISE exc_individu;
        END IF;
      END IF;
      PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_NUMINDIV( loc_INDIVIDU.NUMINDIV
                                              , loc_AFFIL_PORTE.NUMREMISE
                                              , loc_AFFIL_PORTE.NUMPORTE
                                              , loc_AFFIL_PORTE.NUMLIGNE
                                              , loc_ano_numindiv);
      loc_AFFIL_PORTE.NUMINDIV:=loc_INDIVIDU.NUMINDIV;
      IF loc_ano_numindiv>0 THEN
        loc_AFFIL_PORTE.NUMINDIV:=NULL;
        RAISE exc_individu;
      END IF;

      ---------------------------------------------------------------------------------
      -- ********************** CONTRAT ********************************************
      ---------------------------------------------------------------------------------
      P_INS_journal(3, 'F_FIND_NUMGAR loc_AFFIL_PORTE.NUMCLI:'||loc_AFFIL_PORTE.NUMCLI);
      -- Recherche du numéro de contrat à partir du numéro de société de l affilié
      loc_numgar:=PK_CTRL_AFFIL.F_FIND_NUMGAR(loc_AFFIL_PORTE.ENTREPRISE, loc_AFFIL_PORTE.NUMCLI,loc_dateff);
      P_INS_journal(3, 'F_FIND_NUMGAR loc_numgar:'||loc_numgar);
      IF loc_numgar = -1 THEN
        RAISE exc_numgar;
      ELSIF loc_numgar = -2 THEN
        RAISE exc_souscripteur;
      ELSIF loc_numgar = -3 THEN
        RAISE exc_numgar_ko;
      ELSIF loc_numgar = -4 THEN
        RAISE exc_regime_noRU;
      ELSE
        P_INS_journal(3, 'Contrat trouvé <'||loc_numgar||'>');
      END IF;
      PK_CTRL_AFFIL.P_ctrl_Contrat( loc_AFFIL_PORTE.DATRAIT
                                  , loc_numgar
                                  , loc_ano_contrat);
      IF loc_ano_contrat>0 THEN
        P_INS_journal(3, 'Contrat ko <'||loc_ano_contrat||'>');
        RAISE exc_contrat;
      ELSE
        PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_NUMGAR( loc_numgar
                                              , loc_AFFIL_PORTE.NUMCLI
                                              , loc_AFFIL_PORTE.NUMINDIV
                                              , loc_AFFIL_PORTE.NUMREMISE
                                              , loc_AFFIL_PORTE.NUMPORTE
                                              , loc_AFFIL_PORTE.NUMLIGNE
                                              , loc_ano_contrat);
        loc_AFFIL_PORTE.NUMGAR:=loc_numgar;
      END IF;
      P_INS_journal(3, 'Contrat controlé <'||loc_numgar||'>');

      ---------------------------------------------------------------------------------
      -- ********************** TYPE MOUVEMENT ***************************************
      ---------------------------------------------------------------------------------
      IF TRIM(loc_AFFIL_PORTE.FINEFF) IS NOT NULL THEN loc_MVT :=2; --absence
      ELSIF TRIM(loc_AFFIL_PORTE.FINCON) IS NOT NULL THEN loc_MVT :=1; --radiation
      ELSE  loc_MVT :=0; --affiliation
      END IF;
      /*
      -- Si on traite une nouvelle affiliation avec un salaire à 0 on bloque
      IF loc_MVT=0 AND NVL(TO_NUMBER(REPLACE(REPLACE(loc_AFFIL_PORTE.SALATA,' ',''),',','.')),0)=0 THEN
        RAISE exc_affil_salTA;
      END IF;*/
      P_INS_journal(3, 'g_fichier <'||g_fichier||'>');
      P_INS_journal(3, 'loc_flag_integ <'||loc_flag_integ||'>');
      IF nvl(loc_flag_integ,0)<>1 THEN
        IF NVL(G_trimestre,0)=0 THEN
          SELECT SUBSTR(g_fichier,17,1) INTO loc_trimestre FROM porte_remise WHERE ref_ext=g_fichier;
        ELSE
          loc_trimestre:=G_trimestre;
        END IF;
      ELSE
        IF NVL(loc_trimestre,0)=0 THEN
          SELECT SUBSTR(porte_remise.ref_ext,17,1) INTO loc_trimestre FROM porte_remise WHERE NUMREMISE=loc_AFFIL_PORTE.NUMREMISE;
        ELSE
          loc_trimestre:=G_trimestre;
        END IF;
      END IF;
      IF TRIM(TO_CHAR(G_annee)) IS NULL THEN
        SELECT SUBSTR(porte_remise.ref_ext,19,4) INTO G_annee FROM porte_remise WHERE NUMREMISE=loc_AFFIL_PORTE.NUMREMISE;
      END IF;
      P_INS_journal(3, 'loc_MVT <'||loc_MVT||'>');
      P_INS_journal(3, 'loc_trimestre <'||loc_trimestre||'>');
      ---------------------------------------------------------------------------------
      -- ********************** PERS_HISTO_PHYS ***************************************
      ---------------------------------------------------------------------------------
      -- Initialisation de PERS_HISTO_PHYS
      loc_PERS_HISTO_PHYS.DEBUT:=E2D(loc_AFFIL_PORTE.DEBUTC);
      loc_PERS_HISTO_PHYS.CREATION:=loc_AFFIL_PORTE.DATRAIT;
      loc_PERS_HISTO_PHYS.SITU_FAM:=F_get_transco('AFFIL','SITFAM',loc_AFFIL_PORTE.SITFAM,2);
      loc_PERS_HISTO_PHYS.SITU_PROF:=F_get_transco('AFFIL','CADRNC',loc_AFFIL_PORTE.CADRNC,2);
      loc_PERS_HISTO_PHYS.CSP_1:=F_get_transco('AFFIL','CATEGP',loc_AFFIL_PORTE.CATEGP,2);
      PK_CTRL_AFFIL.P_Gestion_Pers_histo_phys( loc_AFFIL_PORTE
                                             , NULL --abo
                                             , loc_trimestre
                                             , G_annee
                                             , loc_PERS_HISTO_PHYS
                                             , loc_ano_histophys);
      P_INS_journal(3, 'Controle de Pers_histo_phys :'||loc_INDIVIDU.NUMINDIV);
      P_INS_journal(3, 'Controle de Pers_histo_phys loc_ano_histophys:'||loc_ano_histophys);
      IF loc_ano_histophys>0 THEN
        RAISE exc_histophys;
      END IF;

      ---------------------------------------------------------------------------------
      -- ********************** PERS_ADRESSE ******************************************
      ---------------------------------------------------------------------------------
      -- Gestion de l adresse
      PK_CTRL_AFFIL.P_Gestion_Pers_adresse( loc_AFFIL_PORTE
                                          , loc_PERS_ADRESSE
                                          , loc_dateff
                                          , NULL
                                          , loc_erreur
                                          , loc_ano_adr);
      P_INS_journal(3, 'Controle de Pers_adresse loc_ano_adr :'||loc_ano_adr);
      IF loc_ano_adr>0 THEN
        RAISE exc_pers_adresse;
      END IF;
      P_INS_journal(3, 'loc_MVT :'||loc_MVT);
      ---------------------------------------------------------------------------------
      -- ********************** ADHE_CNTRT, HISTO_ADHESION, ADHE_CNTRT_MEMBRE, ADHESION
      ---------------------------------------------------------------------------------
      PK_CTRL_AFFIL.P_GestionAdhesion( loc_AFFIL_PORTE
                                     , loc_MVT
                                     , loc_dateff
                                     , loc_flag_integ
                                     , loc_ano_adhesion
                                     , loc_regul);

      IF loc_ano_adhesion < 0 THEN
        CASE loc_ano_adhesion
          WHEN -1  THEN loc_AFFIL_ANO.NUMANO:=15;
          WHEN -2  THEN loc_AFFIL_ANO.NUMANO:=16;
          WHEN -3  THEN loc_AFFIL_ANO.NUMANO:=17;
          WHEN -4  THEN loc_AFFIL_ANO.NUMANO:=18;
          WHEN -5  THEN loc_AFFIL_ANO.NUMANO:=19;
          WHEN -6  THEN loc_AFFIL_ANO.NUMANO:=20;
          WHEN -7  THEN loc_AFFIL_ANO.NUMANO:=21;
          WHEN -8  THEN loc_AFFIL_ANO.NUMANO:=22;
          WHEN -9  THEN loc_AFFIL_ANO.NUMANO:=23;
          WHEN -10 THEN loc_AFFIL_ANO.NUMANO:=24;
          WHEN -11 THEN loc_AFFIL_ANO.NUMANO:=25;
          WHEN -12 THEN loc_AFFIL_ANO.NUMANO:=26;
          WHEN -13 THEN loc_AFFIL_ANO.NUMANO:=27;
          WHEN -14 THEN loc_AFFIL_ANO.NUMANO:=28;
          WHEN -15 THEN loc_AFFIL_ANO.NUMANO:=29;
          WHEN -16 THEN loc_AFFIL_ANO.NUMANO:=35;
          WHEN -17 THEN loc_AFFIL_ANO.NUMANO:=36;
          WHEN -18 THEN loc_AFFIL_ANO.NUMANO:=38;
          WHEN -19 THEN loc_AFFIL_ANO.NUMANO:=45;
          WHEN -20 THEN loc_AFFIL_ANO.NUMANO:=47;
          WHEN -21 THEN loc_AFFIL_ANO.NUMANO:=48;
          WHEN -22 THEN loc_AFFIL_ANO.NUMANO:=51;
          WHEN -23 THEN loc_AFFIL_ANO.NUMANO:=55;
          ELSE NULL;
        END CASE;
        RAISE exc_adhesion;
      ELSE
        PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_IDADHESION( loc_AFFIL_PORTE.IDADHESION
                                                  , loc_INDIVIDU.NUMINDIV
                                                  , loc_AFFIL_PORTE.NUMREMISE
                                                  , loc_AFFIL_PORTE.NUMPORTE
                                                  , loc_AFFIL_PORTE.NUMLIGNE
                                                  , loc_ano_majadhes);

        IF loc_ano_majadhes = 1 THEN
          loc_AFFIL_ANO.NUMANO:=8;
          RAISE exc_adhesion;
        END IF;
        IF TRIM (loc_AFFIL_PORTE.IDADHESION) IS NULL THEN
          loc_AFFIL_ANO.NUMANO:=8;
          RAISE exc_adhesion;
        END IF;
      END IF;


      IF NVL(loc_ano_adhesion,0)>=0 THEN
        IF loc_ano_adhesion= 23 THEN
          loc_regul:=1;
        END IF;
        ---------------------------------------------------------------------------------
        -- ********************** VAL_VARIABLE ******************************************
        ---------------------------------------------------------------------------------
        PK_CTRL_AFFIL.P_Gestion_Val_Variable( loc_AFFIL_PORTE
                                            , loc_trimestre
                                            , G_annee
                                            , loc_regul
                                            , loc_AFFIL_ANO
                                            , loc_anoSalaireA
                                            , loc_anoSalaireB
                                            , loc_ano_valvar);
        P_INS_journal(3, 'Données complémentaires gérées <'||loc_AFFIL_PORTE.IDADHESION||'>,loc_ano_valvar:'||loc_ano_valvar);
        IF loc_ano_valvar>0 THEN
          P_INS_journal(3, 'Données complémentaires ko, loc_idadhesion <'||loc_AFFIL_PORTE.IDADHESION||'>');
          RAISE exc_val_variable;
        END IF;
      END IF;


    EXCEPTION
      WHEN exc_societe THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=1;
      WHEN exc_participant OR exc_affil THEN
         cpt_ano:=cpt_ano+1;
      WHEN exc_individu THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=3;
      WHEN exc_histophys THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=4;
      WHEN exc_pers_adresse THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=5;
      WHEN exc_numgar THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=6;
      WHEN exc_contrat THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=7;
      WHEN exc_adhesion THEN
         cpt_ano:=cpt_ano+1;
      WHEN exc_val_variable THEN
         cpt_ano:=cpt_ano+1; -- AFFIL_ANO déja alimenté dans la procédure P_Gestion_Val_Variable
      WHEN exc_souscripteur THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=13;
      WHEN exc_numgar_ko THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=14;
      WHEN exc_regime_noRU THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=44;
      WHEN exc_refcie THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=49;
      WHEN exc_matorg THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=50;
     /* WHEN exc_affil_salTA THEN
         cpt_ano:=cpt_ano+1;
         loc_AFFIL_ANO.NUMANO:=55;*/
      WHEN OTHERS THEN
        P_INS_journal(1 ,'WHEN OTHERS THEN'||SUBSTR(SQLERRM,1,132));
        cpt_ano:=cpt_ano+1;
        loc_AFFIL_ANO.NUMANO:=56;
    END;
    ---------------------------------------------------------------------------------------------------------
    -- Si une ou plusieurs anomalies sont détectées on bloque l affiliation avec l état à 3
    ---------------------------------------------------------------------------------------------------------
    IF cpt_ano>0 THEN
      ROLLBACK;
      IF loc_MVT = 4 THEN
        PK_CTRL_AFFIL.P_AFFIL_ANO(loc_AFFIL_PORTE,46,7,loc_AFFIL_PORTE.DATRAIT);
      END IF;
      IF loc_ano_valvar=1 THEN
        PK_CTRL_AFFIL.P_AFFIL_ANO(loc_AFFIL_PORTE,33,3,SYSDATE);
      ELSIF loc_ano_valvar=2 THEN
        PK_CTRL_AFFIL.P_AFFIL_ANO(loc_AFFIL_PORTE,34,3,SYSDATE);
      ELSIF loc_ano_valvar=3 THEN
        PK_CTRL_AFFIL.P_AFFIL_ANO(loc_AFFIL_PORTE,32,3,SYSDATE);
      ELSIF loc_ano_valvar=4 THEN
        PK_CTRL_AFFIL.P_AFFIL_ANO(loc_AFFIL_PORTE,43,3,SYSDATE);
      END IF;
      o_ano:=loc_AFFIL_ANO.NUMANO;
      cpt_ano_tot:=cpt_ano_tot+1;
      loc_AFFIL_ANO.ETATANO:=3;
      PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
      PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_ETAT( loc_AFFIL_PORTE.NUMREMISE
                                          , 3
                                          , loc_AFFIL_PORTE.NUMLIGNE
                                          , loc_AFFIL_PORTE.NUMPORTE);
      -- Mise à jour des données de AFFIL_PORTE
   /*   PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_AFFIL( loc_AFFIL_PORTE
                                           , loc_AFFIL_PORTE.NUMREMISE
                                           , loc_AFFIL_PORTE.NUMPORTE
                                           , loc_AFFIL_PORTE.NUMLIGNE
                                           , loc_ano_majaffil);*/
      COMMIT;
    ELSE
      IF loc_flag_integ=1 THEN -- Si l affiliation à intégrer provient d un déblocage manuel(etat 2), on le passe à l état 1 'Importée'
        IF loc_anoSalaireA > 0 OR loc_anoSalaireB > 0  OR loc_ano_adhesion=1 OR loc_qualite=1 OR loc_regul in(1,3,4) THEN -- Si affiliation intégrée avec avertissement
          PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_ETAT( loc_AFFIL_PORTE.NUMREMISE
                                              , 7
                                              , loc_AFFIL_PORTE.NUMLIGNE
                                              , loc_AFFIL_PORTE.NUMPORTE);
        ELSE
          PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_ETAT( loc_AFFIL_PORTE.NUMREMISE
                                              , 1
                                              , loc_AFFIL_PORTE.NUMLIGNE
                                              , loc_AFFIL_PORTE.NUMPORTE);
        END IF;
      ELSIF loc_anoSalaireA > 0 OR loc_anoSalaireB > 0 OR loc_ano_adhesion=1 OR loc_qualite=1 OR loc_regul in(1,3,4) THEN -- Si affiliation intégrée avec avertissement
        PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_ETAT( loc_AFFIL_PORTE.NUMREMISE
                                            , 7
                                            , loc_AFFIL_PORTE.NUMLIGNE
                                            , loc_AFFIL_PORTE.NUMPORTE);
      END IF;
      COMMIT;
    END IF;


  END LOOP;

  P_INS_journal(1, 'Le nombre de lignes bloquées fonctionnellement est de <'||cpt_ano_tot||'>');

  RETURN 1;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1 ,'f_ctrlAFFIL_PORTE '||SUBSTR(SQLERRM,1,132));
    o_erreur:='f_ctrlAFFIL_PORTE '||SUBSTR(SQLERRM,1,132);
    RETURN 0;
END f_ctrlAFFIL_PORTE;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  S2A                                                       */
/* Type         :  Privee                                                    */
/* Description  :  Convertie une chaine de caratère en tableau               */
/* Entree       :  I_string,                                                 */
/*                 I_delim, delimitateur du fichier à traiter                */
/* Retour       :  Un tableau de ligne                                       */
/*---------------------------------------------------------------------------*/
FUNCTION S2A (I_string VARCHAR2, I_delim VARCHAR2)
RETURN T_ligne   IS
  i       number :=0;
  pos     number :=0;
  lv_str  varchar2(20000) := I_string;

strings T_ligne;

BEGIN

  pos := instr(lv_str,I_delim,1,1);
  IF pos = 0 THEN
    strings(1) := lv_str;
  END IF ;

  WHILE ( pos != 0) LOOP

    i := i + 1;
    strings(i) := substr(lv_str,1,pos-1);
    lv_str := substr(lv_str,pos+1,length(lv_str));
    pos := instr(lv_str,I_delim,1,1);
    IF pos = 0 THEN
      strings(i+1) := lv_str;
    END IF;

  END LOOP;


  RETURN strings;

END S2A;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Privee                                                    */
/* Description  :  Insertion dans journal_adm                                */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS

BEGIN
  IF G_niv_msg IS NULL THEN
     BEGIN
       SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
       INTO G_niv_msg
       FROM PARAM_BATCH
       WHERE NUMBATCH = G_nom_traitement;
     EXCEPTION
       WHEN OTHERS THEN
            G_niv_msg := 1;
    END;
  END IF;

  IF G_niv_msg >= P_niv THEN
     G_IDLIGNE := G_IDLIGNE +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => G_nom_traitement,
        I_session  => g_session,
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;

END P_INS_journal;

END PK_IMPORT_AFFIL;
/
