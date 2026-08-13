CREATE OR REPLACE PACKAGE ARTHUS.PK_SP_ISANTE
AS
/*============================================================================*/
/* Package      : PK_SP_ISANTE.sql                                            */
/* Domaine      : TP Hospitalier                                              */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 27/08/2014                                                  */
/* Description  :                                                             */
/*              :                                                             */
/*              :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/

PROCEDURE P_CONST_BENE ( i_traitement   IN    VARCHAR2,
                         i_numporte     IN    remise_externe.numporte%TYPE,
                         i_session      IN    NUMBER DEFAULT 1,
                         i_param1       IN    NUMBER,
                         i_niv_msg      IN    NUMBER DEFAULT 1,
                         o_found        OUT   NUMBER,
                         o_erreur       OUT   VARCHAR2);

PROCEDURE P_EXPORT_BENE ( i_traitement   IN    VARCHAR2,
                          i_remise_exp   IN    remise_externe.numremise%TYPE,
                          i_session      IN    NUMBER DEFAULT 1,
                          i_niv_msg      IN    NUMBER DEFAULT 1,
                          i_repertoire   IN    VARCHAR2 DEFAULT NULL,
                          i_fichier      IN    VARCHAR2 DEFAULT NULL,
                          o_found        OUT   NUMBER,
                          o_erreur       OUT   VARCHAR2);

PROCEDURE P_CTRL_PS( i_NNI        IN VARCHAR2,
                     i_ad1        IN VARCHAR2 DEFAULT NULL,
                     i_ad2        IN VARCHAR2 DEFAULT NULL,
                     i_ad3        IN VARCHAR2 DEFAULT NULL,
                     i_ad4        IN VARCHAR2 DEFAULT NULL,
                     i_ad5        IN VARCHAR2 DEFAULT NULL,
                     i_cp         IN VARCHAR2 DEFAULT NULL,
                     i_ville      IN VARCHAR2 DEFAULT NULL,
                     o_numindivPS OUT individu.numindiv%TYPE);                          
                          
PROCEDURE P_IMPORT_PS ( i_traitement   IN       VARCHAR2,
                        i_numporte     IN       remise_externe.numporte%TYPE,
                        i_session      IN       NUMBER DEFAULT 1,
                        i_niv_msg      IN       NUMBER DEFAULT 1,
                        i_repertoire   IN       VARCHAR2 DEFAULT NULL,
                        i_fichier      IN       VARCHAR2 DEFAULT NULL,
                        io_idligne     IN OUT   journal_adm.idligne%TYPE,
                        o_found        OUT      NUMBER,
                        o_erreur       OUT      VARCHAR2);

FUNCTION f_ctrlFichier ( i_repertoire  IN       VARCHAR2
                       , i_fichier     IN OUT   VARCHAR2
                       , o_erreur         OUT   VARCHAR2)
RETURN NUMBER;

FUNCTION f_entete_DFI ( i_repertoire  IN       VARCHAR2
                      , i_fichier     IN       VARCHAR2
                      , i_remise      IN       NUMBER
                      , i_buffer      IN OUT   VARCHAR2
                      , o_erreur         OUT   VARCHAR2)
RETURN NUMBER;

FUNCTION f_entete_FFI ( i_repertoire  IN       VARCHAR2
                      , i_fichier     IN       VARCHAR2
                      , i_remise      IN       NUMBER
                      , i_buffer      IN OUT   VARCHAR2
                      , i_cpt         IN       NUMBER
                      , o_erreur         OUT   VARCHAR2)
RETURN NUMBER;

PROCEDURE P_INS_journal( i_niv  in NUMBER,
                         i_msg  in VARCHAR2,
                         i_msg2 in varchar2 := null);

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_SP_ISANTE AS
/*============================================================================*/
/* Package      : PK_SP_ISANTE.sql                                            */
/* Domaine      : TP Hospitalier                                              */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 27/08/2014                                                  */
/* Description  :                                                             */
/*              :                                                             */
/*              :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/

--VARIABLES GLOBALES
g_nom_traitement  journal_adm.nom_traitement%TYPE DEFAULT 'SP05T';
g_niv_msg         journal_adm.niv_msg%TYPE := NULL;
g_idligne         journal_adm.idligne%TYPE := 0;
g_msg_adm         journal_adm.msg_adm%TYPE;
g_session         NUMBER;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CONST_BENE                                              */
/* Type         :  Public                                                    */
/* Description  :  procedure de constitution aiguillage bénéficiaires        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CONST_BENE ( i_traitement   IN    VARCHAR2,
                         i_numporte     IN    remise_externe.numporte%TYPE,
                         i_session      IN    NUMBER DEFAULT 1,
                         i_param1       IN    NUMBER,
                         i_niv_msg      IN    NUMBER DEFAULT 1,
                         o_found        OUT   NUMBER,
                         o_erreur       OUT   VARCHAR2
)
IS

  -- On recupere les infos tiers payant hospi.
  CURSOR c_bene_tp_hospi
      IS
   SELECT pa.numremise
        , pa.idporte
        , pa.numporte
        , pt.type_carte
     FROM porte_adhesion pa, demande_tp tp, param_tiers_payant pt
    WHERE pa.numremise = 0
      AND pa.numporte  = i_numporte
      AND pa.transmis  = 2
      AND tp.idporte   = pa.idporte
      AND pt.idparam_tp = tp.idparam_tp
 ORDER BY pa.numremise,
          pa.numporte,
          pt.type_carte;

  r_bene_tp_hospi         c_bene_tp_hospi%ROWTYPE;
  loc_numremise           remise_externe.numremise%TYPE:=0;
  loc_erreur1             journal_adm.msg_adm%TYPE:=NULL;
  cpt_OD                   NUMBER:=0; -- compteur des ouvreurs de droits
  cpt_AD                   NUMBER:=0; -- compteur des ayants droits
  cpt_tot_AD               NUMBER:=0; -- compteur des ayants droits

BEGIN

  -----------------------------------------------------------------------------
  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=i_niv_msg;
  G_idligne:=0;
  G_session:=i_session;
  P_INS_journal(1,'Début du traitement <'||i_traitement||'> de constitution aiguillage bénéficiaires sur la porte <'||i_numporte||'>');
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Selection et insertion de la remise externe
  PK_TPE.P_gestion_remise_externe(i_numporte,i_param1, loc_numremise, loc_erreur1);
  P_INS_journal(1,'Numéro de remise externe <'||loc_numremise||'> ');
  -----------------------------------------------------------------------------
  IF NVL(loc_numremise,0) <> 0 THEN

    -----------------------------------------------------------------------------
    FOR r_bene_tp_hospi IN c_bene_tp_hospi LOOP
      PK_TPE.P_MAJ_PORTE_ADHESION_REMISE(loc_numremise,i_numporte,r_bene_tp_hospi.idporte);
      cpt_OD:=cpt_OD+1;

      -- compteur des ayants droits
       SELECT COUNT(*)-1
         INTO cpt_AD
         FROM demande_tp_ad
        WHERE idporte=r_bene_tp_hospi.idporte;
       cpt_tot_AD:=cpt_tot_AD+cpt_AD;
    END LOOP;

    -- mise à jour du champ nombre dans remise_externe qui correspond au nombre de déclarations de bénéficiaires
    PK_TPE.P_MAJ_PORTE_ADHESION_NOMBRE(loc_numremise,i_numporte,cpt_OD);

    P_INS_journal(1,'Le nombre de déclarations d''ouvreurs de droit est de <'||cpt_OD||'> ');
    P_INS_journal(1,'Le nombre de déclarations d''ayants droit est de <'||cpt_tot_AD||'> ');

  ELSE
    ROLLBACK;
    P_INS_journal(1,'loc_erreur1:'||loc_erreur1);
    P_INS_journal(1,'ROLLBACK');
  END IF;

  -----------------------------------------------------------------------------

  P_INS_journal(1,'Fin du traitement ');

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'Début du traitement <'||i_traitement||'> KO');
END P_CONST_BENE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EXPORT_BENE                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure de génération aiguillage bénéficiaires          */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_EXPORT_BENE ( i_traitement   IN    VARCHAR2,
                          i_remise_exp   IN    remise_externe.numremise%TYPE,
                          i_session      IN    NUMBER DEFAULT 1,
                          i_niv_msg      IN    NUMBER DEFAULT 1,
                          i_repertoire   IN    VARCHAR2 DEFAULT NULL,
                          i_fichier      IN    VARCHAR2 DEFAULT NULL,
                          o_found        OUT   NUMBER,
                          o_erreur       OUT   VARCHAR2
)
IS

  -- On recupere les infos tiers payant hospi.
  CURSOR c_exp_bene_tp_hospi
      IS
  SELECT i.matorg matorg
       , SUBSTR (TO_CHAR (i.cless, '00'), 2, 2) cless
       , i.datnais
       , i.rang
       , nvl(i.nomjf, i.nom) nom
       , i.prenom
       , i.numindiv
       , d.debut
       , d.fin
       , pa.numporte
       , pt.numamc
       , pt.idparam_tp
    FROM individu i
       , demande_tp_ad d
       , demande_tp tp
       , param_tiers_payant pt
       , porte_adhesion pa
       , remise_externe r
   WHERE d.numindiv = i.numindiv
     AND pt.idparam_tp = tp.idparam_tp
     AND d.idporte = tp.idporte
     AND pa.idporte = d.idporte
     AND  pa.transmis = 2
     AND pa.numremise != 0
     AND pa.numporte = r.numporte
     AND r.numremise= i_remise_exp
     AND r.numremise=pa.numremise
     AND r.valide = 'O'
   ORDER BY pt.idparam_tp 
          ;

  r_exp_bene_tp_hospi         c_exp_bene_tp_hospi%ROWTYPE;

  -- On recupere les domaines de la carte tiers payant hospi.
  CURSOR c_domaine_carte(i_idparam_tp NUMBER)
      IS
  SELECT DISTINCT dt.domaine
   FROM param_demande_tp dt
  WHERE dt.idparam_tp= i_idparam_tp
  ;

  r_domaine_carte         c_domaine_carte%ROWTYPE;

  loc_ok                      NUMBER:=0;
  loc_fichier                 VARCHAR2(50):=NULL;
  h_fichier                   UTL_FILE.file_type;
  loc_cpt                     NUMBER:=0;
  loc_buffer                  VARCHAR2 (32767);
  loc_domaine                 VARCHAR2(3);
  loc_domaineConcat           VARCHAR2(60);
  loc_erreur                  NUMBER:=0;
  loc_tot_erreur              NUMBER:=0;
  loc_nb_remise               NUMBER :=0;

BEGIN

  -----------------------------------------------------------------------------
  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=i_niv_msg;
  G_idligne:=0;
  G_session:=i_session;

  P_INS_journal(1, 'Début de la génération du fichier des bénéficiaires aiguillage');
  -----------------------------------------------------------------------------
  -- Controle du répertoire d écriture et récupération du nom du fichier
  loc_fichier:=i_fichier;
  loc_ok := f_ctrlFichier (i_repertoire, loc_fichier, o_erreur);
  IF loc_ok = 0 THEN
    P_INS_journal(1, 'Erreur de format ou de nom de fichier : '||o_erreur);
  ELSE
    P_INS_journal(1, 'Le nom du fichier à récupérer dans le dossier EXPORT: '||loc_fichier);
  END IF;

  -----------------------------------------------------------------------------
  -- Parcours des bénéficiaires à exporter
  IF loc_ok = 1 THEN
    h_fichier := UTL_FILE.FOPEN (i_repertoire, loc_fichier, 'W', 32767);

    FOR r_exp_bene_tp_hospi IN c_exp_bene_tp_hospi LOOP
      loc_cpt:=loc_cpt+1;
      IF loc_cpt=1 THEN
      -- écriture de l entete du fichier
        loc_buffer:='';
        
        SELECT COUNT(numremise) INTO loc_nb_remise 
        FROM remise_externe
        WHERE nature IN (SELECT nature FROM  remise_externe WHERE numremise = i_remise_exp)
        AND  numremise <= i_remise_exp;
        
        loc_ok:=f_entete_DFI(i_repertoire, loc_fichier, loc_nb_remise, loc_buffer, o_erreur);
        IF loc_ok = 0 THEN
          P_INS_journal(2, 'Erreur d ecriture de l entete ');
        ELSE
          P_INS_journal(2, 'Ecriture de l entete ');
          UTL_FILE.PUT_LINE (h_fichier, loc_buffer);
          loc_buffer:='';
        END IF;
      ELSE
        P_INS_journal(2, 'Ecriture du fichier ');

        loc_erreur:=0;
        -- Gestion des erreurs
        -- si des infos obligatoires sont manquantes alors on rejette la ligne
        IF TRIM(TO_CHAR(r_exp_bene_tp_hospi.matorg)) IS NULL OR TRIM(TO_CHAR(r_exp_bene_tp_hospi.cless)) IS NULL THEN
          P_INS_journal(1, 'Numéro de sécurité social ou clés imcomplète pour l''individu <'||r_exp_bene_tp_hospi.numindiv||'>');
          loc_erreur:=loc_erreur+1;
        END IF;
        IF TRIM(TO_CHAR(r_exp_bene_tp_hospi.datnais, 'YYYYMMDD')) IS NULL THEN
          P_INS_journal(1, 'Date de naissance manquante pour l''individu <'||r_exp_bene_tp_hospi.numindiv||'>');
          loc_erreur:=loc_erreur+1;
        END IF;
        IF TRIM(TO_CHAR(r_exp_bene_tp_hospi.rang)) IS NULL THEN
          P_INS_journal(1, 'Rang manquant pour l''individu <'||r_exp_bene_tp_hospi.numindiv||'>');
          loc_erreur:=loc_erreur+1;
        END IF;
        IF TRIM(TO_CHAR(r_exp_bene_tp_hospi.prenom)) IS NULL THEN
          P_INS_journal(1, 'Prénom manquant pour l''individu <'||r_exp_bene_tp_hospi.numindiv||'>');
          loc_erreur:=loc_erreur+1;
        END IF;

        IF loc_erreur > 0 THEN
          loc_tot_erreur:=loc_tot_erreur+1;
        END IF;

        IF loc_erreur = 0 THEN

          -- longueur totale de l entete: 255

          -- Type Entité  : Longueur d'enregistrement     X(3)
          loc_buffer := 'BEN';
          -- Numéro INSEE : Longueur d'enregistrement         X(15)
          loc_buffer := loc_buffer || RPAD(TO_CHAR(r_exp_bene_tp_hospi.matorg), 13, ' ') || TO_CHAR(r_exp_bene_tp_hospi.cless);
          -- Date Naissance : Longueur d'enregistrement         X(8)
          loc_buffer := loc_buffer || RPAD(TO_CHAR(r_exp_bene_tp_hospi.datnais, 'YYYYMMDD'), 8,  ' ');
          -- Rang de Naissance : Longueur d'enregistrement         X(1)
          loc_buffer := loc_buffer || RPAD(TO_CHAR(r_exp_bene_tp_hospi.rang), 1,  ' ');
          -- Nom Patronymique  : Longueur d'enregistrement         X(25)
          loc_buffer := loc_buffer || RPAD(r_exp_bene_tp_hospi.nom, 25,  ' ');
          -- Nom Usage   : Longueur d'enregistrement         X(25)
          loc_buffer := loc_buffer || RPAD(r_exp_bene_tp_hospi.nom, 25,  ' ');
          -- Prénom   : Longueur d'enregistrement         X(15)
          loc_buffer := loc_buffer || RPAD(r_exp_bene_tp_hospi.prenom, 15,  ' ');
          -- Numéro Adhérent   : Longueur d'enregistrement         X(8)
          loc_buffer := loc_buffer || LPAD(TO_CHAR(r_exp_bene_tp_hospi.numindiv), 8, '0');
          -- Date début : Longueur d'enregistrement         X(8)
          loc_buffer := loc_buffer || RPAD(TO_CHAR(r_exp_bene_tp_hospi.debut, 'YYYYMMDD'), 8,  ' ');
          -- Date fin : Longueur d'enregistrement         X(8)
          loc_buffer := loc_buffer || RPAD(TO_CHAR(r_exp_bene_tp_hospi.fin, 'YYYYMMDD'), 8,  ' ');
          -- Zone réservée  : Longueur d'enregistrement           X(19)
          loc_buffer := loc_buffer || RPAD(' ', 19, ' ') ;
          -- N° d’AMC destinataire  : Longueur d'enregistrement           X(10)
          loc_buffer := loc_buffer || LPAD('00401554', 10, '0'); -- LPAD(r_exp_bene_tp_hospi.numamc, 10,  '0');
          -- Zone réservée  : Longueur d'enregistrement           X(20)
          loc_buffer := loc_buffer || RPAD(' ', 20, ' ') ;
          -- Domaines tiers-payant    : Longueur d'enregistrement         X(60)
         loc_domaine:=NULL;
         loc_domaineConcat:=NULL;
         -- Parcours des domaines de la carte pour faire une transco qui est écrite dans le fichier
         FOR r_domaine_carte IN c_domaine_carte(r_exp_bene_tp_hospi.idparam_tp) LOOP

           CASE r_domaine_carte.domaine
             WHEN 'EXTE' THEN loc_domaine := 'SE'; -- Soins externes
             WHEN 'RADL' THEN loc_domaine := 'RD'; -- Radiologie
             WHEN 'PHAR' THEN loc_domaine := 'PH'; -- Pharmacie
             WHEN 'LABO' THEN loc_domaine := 'LB'; -- Laboratoire
             WHEN 'AMM'  THEN loc_domaine := 'MK'; -- Kiné
             WHEN 'DENT' THEN loc_domaine := 'SD'; -- Dentaire
             WHEN 'OPTI' THEN loc_domaine := 'OP'; -- Opticien
             ELSE
               loc_domaine:='';
           END CASE;
          loc_domaineConcat:=loc_domaineConcat||loc_domaine;
         END LOOP;
          loc_buffer := loc_buffer || RPAD(loc_domaineConcat, 60,  ' ');
          -- Complément 1  : Longueur d'enregistrement           X(10)
          loc_buffer := loc_buffer || RPAD(' ', 10, ' ') ;
          -- Complément 2  : Longueur d'enregistrement           X(10)
          loc_buffer := loc_buffer || RPAD(' ', 10, ' ') ;
          -- Complément 3  : Longueur d'enregistrement           X(10)
          loc_buffer := loc_buffer || RPAD(' ', 10, ' ') ;

          P_INS_journal(2, 'Ecriture de la ligne pour le bénéficiaire <'||r_exp_bene_tp_hospi.numindiv||'>');
          UTL_FILE.PUT_LINE (h_fichier, loc_buffer);
        END IF;
      END IF;
    END LOOP;
    IF loc_cpt > 0 THEN
      -- Ecriture de l entete de fin
	  --Compteur de bene - l'entete
      loc_ok:=f_entete_FFI(i_repertoire, loc_fichier, loc_nb_remise, loc_buffer, loc_cpt-1, o_erreur);
      loc_cpt:=loc_cpt+1;
      IF loc_ok = 0 THEN
        P_INS_journal(2, 'Erreur d ecriture de l entete de fin ');
      ELSE
       P_INS_journal(2, 'Ecriture de l entete de fin');
        UTL_FILE.PUT_LINE (h_fichier, loc_buffer);
      END IF;
	ELSE 
	  P_INS_journal(1, 'Le fichier ne contient aucun bénéficiaire ');
	END IF;

    UTL_FILE.fclose (h_fichier);
  END IF;


  PK_TPE.P_MAJ_PORTE_ADHESION_TRANSMIS(i_remise_exp);

  PK_TPE.P_MAJ_REMISE_EXTERN_DATE_TRANS(i_remise_exp);

  IF loc_tot_erreur > 0 THEN
	ROLLBACK;
    P_INS_journal(1, 'Le nombre d assurés contenant des informations manquantes obligatoires est de <'||loc_tot_erreur||'>'); 
	UTL_FILE.fremove (i_repertoire, loc_fichier);
	P_INS_journal(1, 'Le fichier ne peut être généré');
  ELSE
    COMMIT;
    P_INS_journal(1, 'Le nombre d assurés dans le fichier est de <'||TO_CHAR(greatest (loc_cpt-2),0)||'>'); -- On exclut l entete de début et de fin
    P_INS_journal(1, 'Fin de la génération du fichier des bénéficiaires aiguillage');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, 'Fin KO de la génération du fichier des bénéficiaires aiguillage');
    UTL_FILE.fclose (h_fichier);
    ROLLBACK;
END P_EXPORT_BENE;

  
/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRLFICHIERPS                                        */
/* Type         :  Privee                                                    */
/* Description  :  Controle du nom de fichier, du répertoire, de la structure*/
/* Entree       :  i_repertoire, répertoire IMPORT                          */
/*                 i_fichier, Nom du fichier                                 */
/*                 i_date_import, date d'import du fichier                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRLFICHIERPS ( i_repertoire     IN    VARCHAR2
                            , i_fichier     IN    VARCHAR2
                            , o_erreur      OUT   VARCHAR2)
RETURN NUMBER
IS

  h_fichier                     UTL_FILE.file_type;
  
  exc_extension                 EXCEPTION;
  exc_par_repertoire_vide       EXCEPTION;
  exc_par_fichier_vide          EXCEPTION;
  exc_fichierImport             EXCEPTION;
  
  v_ok_import                   NUMBER:=0;
  v_extension                   LIBELLE.LIBELLE%TYPE:=NULL;
  

BEGIN
  v_ok_import:=0;
  P_INS_journal(3,'F_CTRLFICHIERPS','CTRL FICHIER : '||i_fichier);

  --------------- Controle du repertoire et du fichier ------------------------
  IF i_repertoire IS NULL THEN
     RAISE exc_par_repertoire_vide;
  END IF;

  IF i_fichier IS NULL OR i_fichier = ''
  THEN
     RAISE exc_par_fichier_vide;
  END IF;

  --------------- Controle de la préscence physique du fichier ------------------------
  v_extension:=F_LIBELLE_FORMAT('TYPFORMAT',1);
  IF TRIM(v_extension) IS NULL THEN
    RAISE exc_extension;
  END IF;
  h_fichier := UTL_FILE.fopen (i_repertoire, i_fichier||v_extension, 'R', 32767);
  UTL_FILE.fclose (h_fichier);

  --------------- Vérification que le fichier n a pas déja été importé ---------------
  /*SELECT NVL(MAX(1),0)
    INTO v_ok_import
    FROM IMPORT_PS_FICHIER
   WHERE UPPER(FICHIER)=UPPER(i_fichier)
   AND DATE_IMPORT = i_date_import;

  IF v_ok_import=0 THEN
    INSERT INTO IMPORT_PS_FICHIER(FICHIER,DATE_IMPORT)
       VALUES(i_fichier,i_date_import);
  ELSE
    RAISE exc_fichierImport;
  END IF;*/
  
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
    P_INS_journal(3,'F_CTRLFICHIERPS', '1 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:=O_erreur||'Fichier '||i_fichier||' non présent dans le répertoire d''import';
    RETURN 0;
  WHEN UTL_FILE.internal_error THEN
    P_INS_journal(3,'F_CTRLFICHIERPS', '2 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INTERNAL_ERROR';
    RETURN 0;
  WHEN UTL_FILE.invalid_filehandle THEN
    P_INS_journal(3,'F_CTRLFICHIERPS', '3 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_FILEHANDLE';
    RETURN 0;
  WHEN UTL_FILE.invalid_mode THEN
    P_INS_journal(3,'F_CTRLFICHIERPS', '4 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_MODE';
    RETURN 0;
  WHEN UTL_FILE.invalid_operation THEN
    P_INS_journal(3,'F_CTRLFICHIERPS', '5 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:=' Nom de fichier invalide';
    RETURN 0;
  WHEN UTL_FILE.invalid_path THEN
    P_INS_journal(3,'F_CTRLFICHIERPS', '6 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.INVALID_PATH';
    RETURN 0;
  WHEN UTL_FILE.read_error THEN
    P_INS_journal(3,'F_CTRLFICHIERPS', '7 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.READ_ERROR';
    RETURN 0;
  WHEN UTL_FILE.write_error THEN
    P_INS_journal(3,'F_CTRLFICHIERPS', '8 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='UTL_FILE.WRITE_ERROR';
    RETURN 0;
  WHEN VALUE_ERROR THEN
    P_INS_journal(3,'F_CTRLFICHIERPS', '9 Fermeture du fichier');
    UTL_FILE.fclose (h_fichier);
    o_erreur:='VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN 0;
  WHEN OTHERS THEN
    IF UTL_FILE.is_open (h_fichier) THEN
      P_INS_journal(3,'F_CTRLFICHIERPS', '10 Fermeture du fichier');
      UTL_FILE.fclose (h_fichier);
    END IF;
    o_erreur:=g_nom_traitement||',' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN 0;  

END F_CTRLFICHIERPS; 

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_FIND_TIERS, ABO / FNI                                   */
/* Type         :  Public                                                    */
/* Description  :  procedure de crontrôle d'existence du praticien,          */
/*                 si il existe, vérfier adresse et créer si inexistante     */
/* Entree       :  i_NNI, numéro ADELI de l opticien                         */
/* Entree       :  i_ad1, adresse 1                                          */
/* Entree       :  i_ad2, adresse 2                                          */
/* Entree       :  i_ad3, adresse 3                                          */
/* Entree       :  i_ad4, adresse 4                                          */
/* Entree       :  i_ad5, adresse 5                                          */
/* Entree       :  i_cp, code postal du PS                                   */
/* Entree       :  i_ville, ville du PS                                      */
/* Retour       :  Retourne le n° du practicien                              */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CTRL_PS(
  i_NNI IN varchar2,
  i_ad1 In varchar2 default null,
  i_ad2 In varchar2 default null,
  i_ad3 In varchar2 default null,
  i_ad4 In varchar2 default null,
  i_ad5 In varchar2 default null,
  i_cp In varchar2 default null,
  i_ville In varchar2 default null,
  o_numindivPS OUT individu.numindiv%TYPE) IS

  loc_numindiv individu.numindiv%TYPE;
  loc_user utilisateurs.numutil%TYPE;
  loc_idadresse pers_adresse.idadresse%TYPE;
  
  loc_adr_existante NUMBER(1) := 0;

   CURSOR c_adresse IS
     SELECT idadresse
     FROM pers_adresse
     WHERE idadresse = pk_personne.f_idadresse (loc_numindiv, 0, sysdate, 'O', 0, -1 )
     AND NVL(no_voie,-1)  = NVL(pk_personne.f_appel_decompose(substr(trim(i_ad3||' '||i_ad4),1,30),1),-1)
     AND NVL(bis,-1)       = NVL(pk_personne.f_appel_decompose(substr(trim(i_ad3||' '||i_ad4),1,30),2),-1)
     AND NVL(type_voie,-1) = NVL(pk_personne.f_appel_decompose(substr(trim(i_ad3||' '||i_ad4),1,30),3),-1)
     AND NVL(nom_voie,-1)  = NVL(pk_personne.f_appel_decompose(substr(trim(i_ad3||' '||i_ad4),1,30),4),-1)
     AND NVL(adresse_2,-1) = NVL(substr(i_ad5,1,30),-1)
     AND NVL(codpos,-1)    = NVL(i_cp,-1)
     AND NVL(ville,-1)     = NVL(i_ville,-1)
     AND codpays   = 1;

  Rec_c_adresse                  c_adresse%ROWTYPE;

BEGIN
  BEGIN

    SELECT numindiv INTO loc_numindiv
    FROM pers_tiers
    WHERE  numdpt = SUBSTR(i_NNI,1,2)
    AND numactv = SUBSTR(i_NNI,3,1)
    AND numinser = SUBSTR(i_NNI,4,5)
    AND numcle = SUBSTR(i_NNI,9,1);

    EXCEPTION
      When no_data_found THEN o_numindivPS := NULL;
      When too_many_rows THEN o_numindivPS:=-1; RETURN;
  END;
  
  -- S'il existe comparer l'adresse
  IF(loc_numindiv IS NOT NULL) THEN
    -- Si on rentre dans le curseur, c'est que l'adresse passée existe pour cette individu.
    FOR Rec_c_adresse IN c_adresse LOOP
      loc_adr_existante := 1;
    END LOOP;
    
    -- Si elle n'existe pas, alors on met defaut à N sur l'ancienne et on créer la nouvelle
    IF(loc_adr_existante = 0) THEN
      UPDATE pers_adresse set DEFAUT = 'N' where numindiv = loc_numindiv and DEFAUT = 'O';
      PK_CTRL_TP.P_NEW_ADRESSE(loc_numindiv,i_ad1,i_ad2,i_ad3,i_ad4,i_ad5,i_cp,i_ville,loc_user);
      loc_numindiv := 0;
    END IF;
    
  ELSE
     loc_numindiv := 0;
  END IF;

  -- si inexistant OU SI UNE ADRESSE EST AJOUTEE on retourne 0, si existant on retourne le numindiv
  o_numindivPS:=loc_numindiv;
  EXCEPTION
    when others then  --dbms_output.put_line('erreur création PS'||SQLERRM);
    P_INS_journal(2,' CTRL PS error' , SQLERRM);
    CLOSE c_adresse;
END P_CTRL_PS;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_IMPORT_PS                                               */
/* Type         :  Public                                                    */
/* Description  :  procedure d'import PS concentionné                        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_IMPORT_PS ( i_traitement   IN       VARCHAR2,
                        i_numporte     IN       remise_externe.numporte%TYPE,
                        i_session      IN       NUMBER DEFAULT 1,
                        i_niv_msg      IN       NUMBER DEFAULT 1,
                        i_repertoire   IN       VARCHAR2 DEFAULT NULL,
                        i_fichier      IN       VARCHAR2 DEFAULT NULL,
                        io_idligne     IN OUT   journal_adm.idligne%TYPE,
                        o_found        OUT      NUMBER,
                        o_erreur       OUT      VARCHAR2
)
IS

v_nat_porte          porte_remise.nature%TYPE := 5; -- Nature du fichier
v_ret_ctrlfichier    NUMBER;
v_err_ctrlfichier    VARCHAR2(50);
v_openfile           UTL_FILE.FILE_TYPE:=NULL;
v_o_items            PK_FICHIER.TV_ITEMS;
v_nblignes           NUMBER;
v_extension          LIBELLE.LIBELLE%TYPE:=NULL;
v_numremise          porte_remise.numremise%TYPE;
v_test_nni           NUMBER(1) := 0;

exc_ctrlfichier      EXCEPTION;
--exc_tiers_exist      EXCEPTION; 
exc_ins_porte_remise EXCEPTION;

v_o_donnees          VARCHAR2(5000):='';
v_o_numindiv         individu.numindiv%TYPE;


-- Données générales
v_type_enr           VARCHAR2(1);  -- Type d'enregistrement "E" entête "D" Détails "F" Fin
-- Données entete et fin
v_dateporte          NUMBER(8);    -- colonne 2 -- Date de création - Date du jour 
v_numseq             NUMBER(4);    -- colonne 3 -- Numéro de séquence du fichier - compteur - porte_remise.ref_ext

-- Données de détails
v_num_ps             VARCHAR2(9);  -- colonne 2 -- Numéro du PS ou del’établissement (ADELI ou FINESS)
v_categorie_ps       VARCHAR2(2);  -- colonne 3 -- Catégorie de PS
v_nom                VARCHAR2(38); -- colonne 5 -- Concaténation de la civilité, nom, prénom
v_adr_rue            VARCHAR2(38); -- colonne 6 -- Champ complément de remise
v_adr_cmplt1         VARCHAR2(38); -- colonne 7 -- Champ complément de distribution    
v_adr_cmplt2         VARCHAR2(38); -- colonne 8 -- Champ numéro et libellé de voie 
v_adr_cmplt3         VARCHAR2(38); -- colonne 9 -- Champ Lieu dit
v_adr_cp             VARCHAR2(5);  -- colonne 10 -- Code postal
v_adr_bur_d          VARCHAR2(32); -- colonne 11 -- bureau distributeur - Champ ville
v_etat_conv          VARCHAR2(1);  -- colonne 13 -- Etat conventionnel actuel -- « T » : non conventionné « O » : conventionné « D » : déconventionné
v_date_creation      NUMBER(8);    -- colonne 70 -- Date de création du tiers
v_tel_interloc       VARCHAR2(10); -- colonne 36 -- Téléphone de l'interlocuteur principal
v_mail_interloc      VARCHAR2(100);-- colonne 38 -- Mail de l'interlocuteur principal

v_cpt NUMBER := 0;
BEGIN
  
  g_nom_traitement := i_traitement;
  g_session        := i_session;
  v_nblignes       := 0;
  g_idligne        := io_idligne;
  
  
  -- Contrôle du fichier 
  v_ret_ctrlfichier := F_CTRLFICHIERPS(i_repertoire,i_fichier,v_err_ctrlfichier);

  IF(v_ret_ctrlfichier = 0) THEN
    RAISE exc_ctrlfichier;
  END IF;
  
  -- Récupération de l'extension
  v_extension:=F_LIBELLE_FORMAT('TYPFORMAT',1);
  -- Ouverture du fichier
  v_openfile := PK_FICHIER.fOpen (i_repertoire, i_fichier||v_extension,'R');
  
  -- Boucle sur chaque ligne
  WHILE PK_FICHIER.fGetLine  ( v_openfile, v_o_donnees) LOOP
    BEGIN    
      
      v_test_nni := 0;
      --v_o_donnees:= v_o_donnees||';';
      -- Pour les chiffres mettre des . au lieu de ,
      --v_o_donnees:=REPLACE(v_o_donnees, ',','.');
      
      -- Convertire la ligne (avec séparateur) en tableau 
      PK_FICHIER.pCreerTableau(v_o_donnees,v_o_items,';');    
      v_type_enr := v_o_items(1);
      P_INS_journal(2,'P_IMPORT_PS','TEST : v_type_enr : '||v_type_enr);
      
      -- Récupération de l'entête BESOIN DES INFOS DE L'ENTETE ?
      IF (v_type_enr = 'E') THEN
        v_dateporte   := v_o_items(2);
        v_numseq      := v_o_items(3);
      
        --------------- Vérification que le fichier n a pas déja été importé ---------------
        v_ret_ctrlfichier := PK_TPE.F_VERIF_PORTE_REMISE(  i_numporte
                                                          ,v_nat_porte
                                                          ,e2d(v_dateporte)
                                                          ,v_numseq
                                                        );
        P_INS_journal(2,'P_IMPORT_PS','TEST : v_ret_ctrlfichier : '||v_ret_ctrlfichier);
        IF(v_ret_ctrlfichier > 1) THEN
          v_err_ctrlfichier := 'Fichier déjà importé';
          RAISE exc_ctrlfichier;
        END IF;
        
        ------------------- Si jamais importé, insertion dans porte_remise ------------------- 
        IF(v_ret_ctrlfichier = 1) THEN

          BEGIN
            SELECT MAX(NUMREMISE)+1 INTO v_numremise FROM PORTE_REMISE;      
            
            INSERT INTO PORTE_REMISE (NUMREMISE,NUMPORTE,DATEREMISE,BATCH,DATEPORTE,NATURE,REF_EXT)
            VALUES (v_numremise,i_numporte,e2d(v_dateporte),i_traitement,e2d(v_dateporte),v_nat_porte,v_numseq); -- i_date_import pour DATEPORTE ET DATEREMISE
          
          EXCEPTION
            WHEN OTHERS THEN
              o_found := 1;
          END;
        ELSE
          v_err_ctrlfichier := 'VERIF porte_remise KO';
          RAISE exc_ctrlfichier;
        END IF;
        
        IF (o_found = 1) THEN
          RAISE exc_ins_porte_remise;
        END IF;
      
      END IF;
      
      
      -- Récupération des détails du PS
      IF (v_type_enr = 'D') THEN

          /*FOR v_cpt IN 1..v_o_items.count
          LOOP
            --v_cpt := v_cpt +1;
            P_INS_journal(1,'P_IMPORT_PS','------------ TEST : Taille '||v_o_items.count);
            P_INS_journal(1,'P_IMPORT_PS','------------ TEST : '||v_o_items(v_cpt));
          END LOOP;*/

         v_num_ps         := v_o_items(2); 
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_num_ps : '||v_num_ps);
         v_categorie_ps   := v_o_items(3);
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_categorie_ps : '||v_categorie_ps);
         v_nom            := v_o_items(5); 
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_nom : '||v_nom);
         v_adr_rue        := v_o_items(6);
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_adr_rue : '||v_adr_rue);
         v_adr_cmplt1     := v_o_items(7);
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_adr_cmplt1 : '||v_adr_cmplt1);
         v_adr_cmplt2     := v_o_items(8);
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_adr_cmplt2 : '||v_adr_cmplt2);
         v_adr_cmplt3     := v_o_items(9); 
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_adr_cmplt3 : '||v_adr_cmplt3);
         v_adr_cp         := v_o_items(10);
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_adr_cp : '||v_adr_cp);
         v_adr_bur_d      := v_o_items(11);
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_adr_bur_d : '||v_adr_bur_d);
         v_etat_conv      := v_o_items(13);
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_etat_conv : '||v_etat_conv);
         v_date_creation  := v_o_items(70); 
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_date_creation : '||v_date_creation);
         v_tel_interloc   := v_o_items(36);
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_tel_interloc : '||v_tel_interloc);
         v_mail_interloc  := v_o_items(38); 
         --P_INS_journal(2,'P_IMPORT_PS','----- TEST : v_mail_interloc : '||v_mail_interloc);
       
        -- Contrôle de doublon de tiers et son adresse, insertion s'il n'existe pas
        P_CTRL_PS(
          v_num_ps,
          '',
          '',
          UPPER(v_adr_cmplt2),
          UPPER(v_adr_rue),
          UPPER(v_adr_cmplt1),
          v_adr_cp,
          UPPER(v_adr_bur_d),
          v_o_numindiv
        );
        
        IF(v_o_numindiv > 0) THEN
           P_INS_journal(1,'','Professionnel de santé existant - NNI : '||v_num_ps||'   - N°Individu : '||v_o_numindiv);
           
        ELSE
          PK_CTRL_TP.P_FIND_TIERS(
            v_num_ps,
            v_nom,
            F_GET_TRANSCO('ISANTE','TT',v_categorie_ps,2),
            '',
            '',
            UPPER(v_adr_cmplt2),
            UPPER(v_adr_rue),
            UPPER(v_adr_cmplt1),
            v_adr_cp,
            UPPER(v_adr_bur_d),
            '',
            '',
            v_o_numindiv
        );
        
        END IF;
      
      
      END IF;
      
      -- Sortir l'idligne pour la ba21
      io_idligne := g_idligne;
       -- Récupération de la ligne de fin BESOIN DES INFOS DE FIN ?
      --IF (v_type_enr = 'F') THEN
      --END IF;
      
    EXCEPTION
       WHEN exc_ctrlfichier THEN
         o_found := 1;
         P_INS_journal(2,'P_IMPORT_PS','ERREUR : contrôle de fichier KO : '||v_err_ctrlfichier);
         o_erreur:='ERREUR : contrôle de fichier KO : '||v_err_ctrlfichier;
         io_idligne := g_idligne;
         IF UTL_FILE.is_open (v_openfile) THEN
         UTL_FILE.fclose (v_openfile);
        END IF;
        EXIT;
      WHEN exc_ins_porte_remise THEN
        UTL_FILE.FCLOSE(v_openfile);
        o_found := 1;
        o_erreur:='ERREUR : insertion dans porte_remise KO';
        P_INS_journal(2,'P_IMPORT_PS','ERREUR : insertion dans porte_remise KO');
        io_idligne := g_idligne;
        EXIT;
      WHEN OTHERS THEN
        UTL_FILE.FCLOSE(v_openfile);
        o_found := 1;
        P_INS_journal(2,'P_IMPORT_PS','ERREUR : Traitement des données du fichier : '||i_fichier||' KO');
        o_erreur:='ERREUR : Traitement des données du fichier : '||i_fichier||' KO';
        io_idligne := g_idligne;
        EXIT;
    END;
    
  END LOOP;

EXCEPTION
  WHEN exc_ctrlfichier THEN
    o_found := 1;
    P_INS_journal(2,'P_IMPORT_PS','ERREUR : contrôle de fichier KO : '||v_err_ctrlfichier);
    o_erreur:='ERREUR : contrôle de fichier KO : '||v_err_ctrlfichier;
    io_idligne := g_idligne;
    IF UTL_FILE.is_open (v_openfile) THEN
      UTL_FILE.fclose (v_openfile);
    END IF;
  WHEN OTHERS THEN
    o_found := 1;
    P_INS_journal(2,'P_IMPORT_PS','ERREUR : '|| SUBSTR (SQLERRM (SQLCODE), 1, 256));
    o_erreur:='ERREUR : '|| SUBSTR (SQLERRM (SQLCODE), 1, 256);
    io_idligne := g_idligne;
    IF UTL_FILE.is_open (v_openfile) THEN
      UTL_FILE.fclose (v_openfile);
    END IF;
END P_IMPORT_PS;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_entete_DFI                                              */
/* Type         :  Privee                                                    */
/* Description  :  écriture de l entete du fichier                           */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_entete_DFI ( i_repertoire  IN       VARCHAR2
                      , i_fichier     IN       VARCHAR2
                      , i_remise      IN       NUMBER
                      , i_buffer      IN OUT   VARCHAR2
                      , o_erreur         OUT   VARCHAR2)
RETURN NUMBER
IS

BEGIN

  -- longueur totale de l entete: 255

  -- Type Entité  : Longueur d'enregistrement     X(3)
  i_buffer := 'DFI';
  -- Référence Fichier : Longueur d'enregistrement         X(6)
  i_buffer := i_buffer || 'DCLBEN';
  -- Numéro de version  : Longueur d'enregistrement     X(3)
  i_buffer := i_buffer || '003';
  -- Numéro d’émetteur  : Longueur d'enregistrement     X(14)
  i_buffer := i_buffer || LPAD('00401554', 14, '0');
  -- Date de génération du Fichier  : Longueur d'enregistrement     X(8)
  i_buffer := i_buffer || TO_CHAR(SYSDATE,'YYYYMMDD');
  -- Identifiant unique Fichier  : Longueur d'enregistrement     X(8)
  i_buffer := i_buffer || LPAD(TO_CHAR(i_remise),8,'0');
  -- Filler  : Longueur d'enregistrement     X(213)
  i_buffer :=  RPAD(i_buffer, 255 ,' ');

  RETURN 1;

EXCEPTION
  WHEN OTHERS THEN
    o_erreur:=G_nom_traitement||',' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN 0;
END f_entete_DFI ;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_entete_FFI                                              */
/* Type         :  Privee                                                    */
/* Description  :  écriture de l entite BEN qui contient les beneficiaires   */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_entete_FFI ( i_repertoire  IN       VARCHAR2
                      , i_fichier     IN       VARCHAR2
                      , i_remise      IN       NUMBER
                      , i_buffer      IN OUT   VARCHAR2
                      , i_cpt         IN       NUMBER
                      , o_erreur         OUT   VARCHAR2)
RETURN NUMBER
IS


BEGIN

  -- longueur totale de l entete: 255

  -- Type Entité  : Longueur d'enregistrement     X(3)
  i_buffer := 'FFI';
  -- Référence Fichier : Longueur d'enregistrement         X(6)
  i_buffer := i_buffer || 'DCLBEN';
  -- Numéro de version  : Longueur d'enregistrement     X(3)
  i_buffer := i_buffer || '003';
  -- Numéro d’émetteur  : Longueur d'enregistrement     X(14)
  i_buffer := i_buffer || LPAD('00401554', 14, '0');
  -- Date de génération du Fichier  : Longueur d'enregistrement     X(8)
  i_buffer := i_buffer || TO_CHAR(SYSDATE,'YYYYMMDD');
  -- Identifiant unique Fichier  : Longueur d'enregistrement     X(8)
  i_buffer := i_buffer || LPAD(TO_CHAR(i_remise),8,'0');
  -- INombre de bénéficiaires   : Longueur d'enregistrement     X(8)
  i_buffer := i_buffer || LPAD(TO_CHAR(i_cpt),8,'0');
  -- Filler  : Longueur d'enregistrement     X(205)
  i_buffer :=  RPAD(i_buffer, 255 ,' ');

  RETURN 1;

EXCEPTION
  WHEN OTHERS THEN
    o_erreur:=G_nom_traitement||',' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN 0;
END f_entete_FFI ;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_ctrlFichier                                             */
/* Type         :  Privee                                                    */
/* Description  :  Controle du nom de fichier, du répertoire, de la structure*/
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 s_fichier, Nom du fichier                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_ctrlFichier ( i_repertoire  IN       VARCHAR2
                       , i_fichier     IN OUT   VARCHAR2
                       , o_erreur         OUT   VARCHAR2)
RETURN NUMBER
IS

  h_fichier                     UTL_FILE.file_type;
  i_date                        VARCHAR2 (8);
  i_heure                       VARCHAR2 (8);

  exc_par_repertoire_vide       EXCEPTION;
  exc_par_fichier_vide          EXCEPTION;

  i_ok_import                   NUMBER:=0;

BEGIN
  i_ok_import:=0;
  P_INS_journal(3, 'i_fichier: '||i_fichier);

  ------------------- Formatage du nom du fichier -----------------------------
  i_date := TO_CHAR (SYSDATE, 'YYYYMMDD');
      --
  SELECT REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
    INTO i_heure
    FROM DUAL;

  SELECT REPLACE (REPLACE (i_fichier, '#DT', i_date), '#HR', i_heure)
    INTO i_fichier
    FROM DUAL;

  P_INS_journal(3, 'i_fichier: '||i_fichier);

  --------------- Controle du repertoire et du fichier ------------------------
  IF i_repertoire IS NULL THEN
     RAISE exc_par_repertoire_vide;
  END IF;

  IF i_fichier IS NULL OR i_fichier = ''
  THEN
     RAISE exc_par_fichier_vide;
  END IF;

  --------------- Controle de la préscence physique du fichier ------------------------
  --h_fichier := UTL_FILE.fopen (i_repertoire, i_fichier, 'R', 32767);
  --UTL_FILE.fclose (h_fichier);


  RETURN 1;

EXCEPTION
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
END f_ctrlFichier ;
  
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure d'insertion dans journal ADM                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(i_niv in NUMBER,
                        i_msg in VARCHAR2,
                        i_msg2 in varchar2 := null
                       )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF g_niv_msg IS NULL THEN
     BEGIN
       SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
       INTO g_niv_msg
       FROM PARAM_BATCH
       WHERE NUMBATCH = g_nom_traitement;
     EXCEPTION
       WHEN OTHERS THEN
            g_niv_msg := 1;
    END;
  END IF;

  IF g_niv_msg >= i_niv THEN
     g_idligne := g_idligne +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => g_nom_traitement,
        I_session  => nvl(g_session,SID),
        I_niv_msg  => i_niv,
        I_msg_adm  => substr(i_msg||' '||i_msg2,1,132),
        I_idligne  => g_idligne);
  END IF;
  COMMIT;
END P_INS_journal;


END PK_SP_ISANTE;
/
