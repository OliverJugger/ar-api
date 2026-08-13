CREATE OR REPLACE PACKAGE ARTHUS."PK_IMPORT_VIREMENT"
AS
/*============================================================================*/
/* PACKAGE      : PK_IMPORT_VIREMENT.sql                                      */
/* Domaine      : Interface                                                   */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 23/04/2018                                                  */
/* Description  : Package permettant l import technique d un fichier contenant*/
/*                des virements externes à destination de ARTHUS              */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

  TYPE T_ligne IS TABLE OF VARCHAR2(2004) INDEX BY BINARY_INTEGER ; --ligne sous forme de tableau
  TYPE T_entite IS TABLE OF VARCHAR2(2004)  INDEX BY  VARCHAR2(80) ;
  TYPE T_import IS TABLE OF T_entite  INDEX BY BINARY_INTEGER ;--toutes les données importées in indéxé par numéro de ligne

PROCEDURE importVIREMENT ( i_repertoire   IN   VARCHAR2
                         , i_fichier      IN   VARCHAR2
                         , i_Porte        IN   VIR_PORTE.NUMPORTE%TYPE
                         , i_echange      IN   PORTE_ECHANGE.IDECHANGE%TYPE
                         , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                         , i_nature       IN   NUMBER
                         , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                         , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                         , o_remise       OUT  PORTE_REMISE.NUMREMISE%TYPE
                         , o_erreur       OUT  VARCHAR2);

PROCEDURE P_GestionVIREMENT ( i_numremise     IN   VIR_PORTE.NUMREMISE%TYPE
                            , i_Porte         IN   VIR_PORTE.NUMPORTE%TYPE
                            , i_numligne      IN   VIR_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                            , i_flag_do       IN   NUMBER
                            , i_flag_encaismt IN   NUMBER
                            , i_session       IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement    IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                            , i_idligne       IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , o_erreur        OUT  VARCHAR2
                            , o_warning       OUT  VARCHAR2);

FUNCTION F_IdentSocGestion( rec_VIR_FICHIER  IN    VIR_FICHIER%ROWTYPE
                          , o_erreur         OUT   VARCHAR2)
RETURN VIR_FICHIER.NUMCPTE%TYPE;

PROCEDURE P_MAJ_VIR_PORTE_CODOPE( i_numremise            IN   VIR_PORTE.NUMREMISE%TYPE
                                , o_erreur               OUT  VARCHAR2);

PROCEDURE P_MAJ_VIR_PORTE_CODOPE_CFE( rec_VIR_PORTE    IN         VIR_PORTE%ROWTYPE
                                    , loc_codope             OUT  NUMBER
                                    , o_erreur               OUT  VARCHAR2);

PROCEDURE P_MAJ_VIR_FICHIER_NUMCOMPTE(i_numcompte      IN    VIR_FICHIER.NUMCPTE%TYPE
                                    , rec_VIR_FICHIER  IN    VIR_FICHIER%ROWTYPE
                                    , o_erreur         OUT   VARCHAR2);

PROCEDURE P_MAJ_VALIDE_VIR_FICHIER( rec_VIR_FICHIER  IN    VIR_FICHIER%ROWTYPE
                                  , i_valide         IN    VIR_FICHIER.VALIDE%TYPE
                                  , o_erreur         OUT   VARCHAR2);

PROCEDURE P_MAJ_VIR_PORTE_NUMDONORDRE(i_numdonordre     IN   VIR_PORTE.NUMDONORDRE%TYPE
                                    , i_numcompte       IN   VIR_PORTE.NUMCPTE%TYPE
                                    , i_numligne        IN   VIR_PORTE.NUMLIGNE%TYPE
                                    , i_numremise       IN   VIR_PORTE.NUMREMISE%TYPE
                                    , i_journal     IN OUT   JOURNAL_ADM%ROWTYPE
                                    , o_erreur          OUT  VARCHAR2);

PROCEDURE P_init_Encaissement ( rec_VIR_PORTE  IN         VIR_PORTE%ROWTYPE
                              , i_ENCAISMT    IN OUT     ENCAISMT%ROWTYPE
                              , o_erreur          OUT     VARCHAR2);

PROCEDURE P_Ins_encaismt( i_ENCAISMT    IN         ENCAISMT%ROWTYPE
                        , o_erreur          OUT     VARCHAR2);

PROCEDURE P_Ins_compte_client( i_ENCAISMT    IN         ENCAISMT%ROWTYPE
                             , o_erreur          OUT     VARCHAR2);

PROCEDURE P_CTRL_fournisseur( i_numcli    IN         ENCAISMT.NUMCLI%TYPE
                            , o_erreur          OUT  VARCHAR2);

PROCEDURE P_MAJ_VIR_PORTE_NUMENCAISMT( rec_VIR_PORTE  IN         VIR_PORTE%ROWTYPE
                                     , loc_encaismt   IN         VIR_PORTE.NUMENCAISMT%TYPE
                                     , o_erreur       OUT        VARCHAR2);

FUNCTION F_IdentNumDonOrdre ( rec_VIR_PORTE  IN   VIR_PORTE%ROWTYPE
                            , o_erreur       OUT  VARCHAR2)
RETURN  VIR_PORTE.NumDonOrdre%TYPE;

PROCEDURE P_MAJ_ETAT_VIR_PORTE( rec_VIR_PORTE  IN         VIR_PORTE%ROWTYPE
                              , loc_etat       IN         VIR_PORTE.ETAT%TYPE
                              , o_erreur       OUT        VARCHAR2);

PROCEDURE P_creer_Encaissement ( rec_VIR_PORTE  IN    VIR_PORTE%ROWTYPE
                               , i_numdonordre  IN    VIR_PORTE.NUMDONORDRE%TYPE
                               , i_numencaismt  OUT   VIR_PORTE.NUMENCAISMT%TYPE
                               , o_erreur       OUT   VARCHAR2
                               , o_warning      OUT   VARCHAR2);

PROCEDURE AnnulimportVIREMENT ( i_numremise    IN   VIR_PORTE.NUMREMISE%TYPE
                              , i_numporte     IN   VIR_PORTE.NUMPORTE%TYPE
                              , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                              , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                              , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                              , o_erreur       OUT  VARCHAR2);

PROCEDURE P_InsertDonneesPorte ( i_repertoire  IN       VARCHAR2
                               , i_fichier     IN       VIR_FICHIER.FICHIER%TYPE
                               , i_Porte       IN       VIR_FICHIER.NUMPORTE%TYPE
                               , i_echange     IN       PORTE_ENTITE.IDECHANGE%TYPE
                               , i_nature      IN       NUMBER
                               , i_remise      IN       PORTE_REMISE.NUMREMISE%TYPE
                               , i_hfichier    IN       UTL_FILE.file_type
                               , i_journal     IN OUT   JOURNAL_ADM%ROWTYPE
                               , o_erreur         OUT   VARCHAR2);

PROCEDURE  P_Verif_doublons_Virements( i_remise      IN       PORTE_REMISE.NUMREMISE%TYPE
                                     , i_Porte       IN       VIR_FICHIER.NUMPORTE%TYPE
                                     , i_journal     IN OUT   JOURNAL_ADM%ROWTYPE
                                     , o_erreur         OUT   VARCHAR2);

PROCEDURE P_FRAGMENT(i_numremise    IN vir_fichier.numremise%type
                    ,i_id_cpt    IN vir_porte.id_cpt%type
                    ,i_numligne     IN vir_porte.numligne%type
                    ,i_numfragment  IN vir_porte.num_fragment%type
                    ,i_montant1     IN NUMBER
                    ,i_montant2     IN NUMBER
                    ,o_numfragment  OUT vir_porte.num_fragment%type);


PROCEDURE P_EXCLURE( i_numremise      IN vir_fichier.numremise%type
                    ,i_id_cpt      IN vir_porte.id_cpt%type
                    ,i_numligne       IN vir_porte.numligne%type
                    ,i_numfragment    IN vir_porte.num_fragment%type
                    ,i_motif          IN NUMBER
                    ,o_erreur         OUT number);
PROCEDURE P_ANNUL_EXCLURE( i_numremise      IN vir_fichier.numremise%type
                          ,i_id_cpt      IN vir_porte.id_cpt%type
                          ,i_numligne       IN vir_porte.numligne%type
                          ,i_numfragment    IN vir_porte.num_fragment%type
                          ,o_erreur         OUT number);

PROCEDURE P_ANNUL_FRAGMENT(i_numremise IN vir_fichier.numremise%type
                          ,i_id_cpt IN vir_porte.id_cpt%type
                          ,i_numligne IN vir_porte.numligne%type
                          ,o_erreur OUT number )  ;

FUNCTION P_Decoupe (I_string VARCHAR2, I_echange PORTE_ENTITE.idechange%TYPE, i_table PORTE_ENTITE.ENTITE%TYPE, i_journal     IN OUT   JOURNAL_ADM%ROWTYPE)
RETURN pk_import_virement.T_ligne;

FUNCTION F_INS_VIR_FICHIER(P_VIR_FICHIER      VIR_FICHIER%ROWTYPE ,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_FIND_PORTE_NUMUTIL( P_porte          IN    LIBELLE.CODE%TYPE)
RETURN NUMBER;

FUNCTION F_INS_PORTE_REMISE(P_porte_remise      PORTE_REMISE%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_CTRL_NUMBER_VARCHAR_AFF(
      i_chaine IN VARCHAR2,
      i_ligne  IN NUMBER,
      I_entite    IN PORTE_ENTITE%ROWTYPE,
      p_journal IN OUT JOURNAL_ADM%ROWTYPE,
      I_cptligne_fichier IN NUMBER
   )   RETURN VARCHAR2;

PROCEDURE P_ANNULATION_NUMENCAISMT( i_encaismt          IN    ENCAISMT%ROWTYPE
                                  , i_motif             IN    ANNUL_ENCAIS.MOTIF%TYPE
                                  , o_erreur            OUT   VARCHAR2
                                  , i_annul_encais_actif IN VARCHAR2 DEFAULT 'N'--flag ajouté pour activer l'insert dans annul_encais dans le cadre du projet rejets de prelev.
                                  );

PROCEDURE p_rejet_mandat ( i_encaismt       IN    ENCAISMT%ROWTYPE
                         , i_motif          IN    ANNUL_ENCAIS.MOTIF%TYPE
                         , o_erreur         OUT   VARCHAR2);

PROCEDURE P_ANNUL_attente( i_encaismt       IN    ENCAISMT%ROWTYPE
                         , o_erreur         OUT   VARCHAR2);

PROCEDURE P_INS_annul_cptcli ( I_numencaismt IN annul_cptcli.numencaismt%TYPE,
                               I_idaffec     IN annul_cptcli.idaffec%TYPE);

PROCEDURE P_ANNUL_compte_tiers2( i_encaismt       IN    ENCAISMT%ROWTYPE
                               , o_erreur         OUT   VARCHAR2);

PROCEDURE P_ANNUL_affectations( i_encaismt       IN    ENCAISMT%ROWTYPE
                               , o_erreur         OUT   VARCHAR2);

PROCEDURE P_Insert_Annul_ENCAIS ( i_encaismt       IN    ENCAISMT%ROWTYPE
                                , i_motif          IN    ANNUL_ENCAIS.MOTIF%TYPE
                                , o_erreur         OUT   VARCHAR2);

PROCEDURE P_ANNUL_encais(i_numencaismt   IN      ENCAISMT.NUMENCAISMT%TYPE
                       , i_motif         IN      ANNUL_ENCAIS.MOTIF%TYPE
                       , o_erreur        OUT     VARCHAR2
                       , i_annul_encsmt_actif IN VARCHAR2 DEFAULT 'N');

PROCEDURE P_ANNUL_encaismt(i_numencais   IN      ENCAISMT.NUMENCAISMT%TYPE
                          , i_motif_annul  IN      ANNUL_ENCAIS.MOTIF%TYPE
                          , o_erreur       OUT     VARCHAR2
                          , i_annul_encaismt_actif IN VARCHAR2 DEFAULT 'N');

PROCEDURE P_TEST_annulation ( i_encaismt        IN     ENCAISMT%ROWTYPE,
                              IO_flag_annul     IN OUT NUMBER,
                              IO_code_msg       IN OUT NUMBER);

FUNCTION F_CTRL_FORMAT_DATE(i_chaine IN VARCHAR2) RETURN NUMBER;
FUNCTION F_CTRL_FORMAT_NUMBER(i_chaine IN VARCHAR2) RETURN NUMBER;

PROCEDURE P_ANNUL_compte_tiers( I_numencaismt IN    ENCAISMT.NUMENCAISMT%TYPE,
                                o_erreur      OUT   VARCHAR2);

PROCEDURE QTTC_VENTIL (a_numquit IN NUMBER) ;

PROCEDURE QTTC_VENTIL (a_numquit IN NUMBER,a_signe IN NUMBER) ;

PROCEDURE P_INS_journal(P_niv     IN NUMBER,
                        p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                        P_msg     IN VARCHAR2,
                        p_msg2    IN VARCHAR2 := NULL);


PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL(  i_date_session DATE,
                                      i_message VARCHAR2,
                                      i_nb_total number);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_IMPORT_VIREMENT;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_IMPORT_VIREMENT
As
/*============================================================================*/
/* PACKAGE      : PK_IMPORT_VIREMENT.sql                                      */
/* Domaine      : Interface                                                   */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 23/04/2018                                                  */
/* Description  : Package permettant l import technique d un fichier contenant*/
/*                des virements externes à destination de ARTHUS              */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

   -- -- TYPES PRIVEES ------------------------------------------------------



   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
   -- -- PROCEDURES ET FONCTIONS PRIVEES -----------------------------------------
--

  PROCEDURE p_ctrlFichierAffil( i_repertoire IN VARCHAR2,
                                i_fichier    IN OUT VARCHAR2,
                                i_format     IN NUMBER,
                                o_erreur OUT VARCHAR2);
  RETURN NUMBER;
   -- -- Déclaration des variables globales   ----------------------------------
  g_numutil                   PORTE_PARAM.NUMUTIL%TYPE:=0;

  -- Chaine de reconnaissance SCCS
  -- %W%  %E%
  -- ---------------------------------------------- Fin des constantes privees --

  -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
  exc_fin_remise      EXCEPTION;
  -- ---------------------------------------------- Fin des exceptions privees --

  -- -- TYPES PRIVEES -----------------------------------------------------------
  -- Aucun
  -- --------------------------------------------------- Fin des types privees --

  -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PUBLIQUES --------------------------

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  importVIREMENT                                            */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l  import d un fichier contenant des      */
/*                 affiliations dans ainsi que l intégration des données     */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichier , fichier des affiliations                      */
/*                 i_Entreprise, contenu dans le nom du fichier              */
/*                 i_Trimestre, contenu dans le nom du fichier               */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE importVIREMENT ( i_repertoire   IN   VARCHAR2
                         , i_fichier      IN   VARCHAR2
                         , i_Porte        IN   VIR_PORTE.NUMPORTE%TYPE
                         , i_echange      IN   PORTE_ECHANGE.IDECHANGE%TYPE
                         , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                         , i_nature       IN   NUMBER
                         , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                         , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                         , o_remise       OUT  PORTE_REMISE.NUMREMISE%TYPE
                         , o_erreur       OUT  VARCHAR2)
IS
  loc_numremise_doublon VIR_FICHIER.NUMREMISE%TYPE:=0;
  Loc_repertoire        TYP_BATCH.REPERTOIRE%TYPE:=NULL;
  loc_fichier           VARCHAR2(50);
  loc_numremise         VIR_FICHIER.NUMREMISE%TYPE:=NULL;
  loc_format            PORTE_ECHANGE.TYPE_FORMAT%TYPE;
  loc_ano               NUMBER:=0;
  loc_erreur            VARCHAR2(2000);
  h_fichier             UTL_FILE.file_type;
  loc_PORTE_REMISE      PORTE_REMISE%ROWTYPE;
  loc_journal           JOURNAL_ADM%ROWTYPE;

  exc_nature          EXCEPTION;
  exc_devise          EXCEPTION;
  exc_code_fichier    EXCEPTION;
  exc_doublon_fichier EXCEPTION;
  exc_type_envoi      EXCEPTION;
  exc_remise_importe  EXCEPTION;
  exc_rep             EXCEPTION;
  exc_ins_remise      EXCEPTION;
  exc_ins_Porte_remise EXCEPTION;


BEGIN

  loc_journal.id_session := i_session;
  loc_journal.idligne := i_idligne;
  loc_journal.nom_traitement := i_traitement;

  BEGIN
    SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
    INTO loc_journal.niv_msg
    FROM PARAM_BATCH
    WHERE NUMBATCH = loc_journal.nom_traitement;
  EXCEPTION
    WHEN OTHERS THEN
      loc_journal.niv_msg:=3;
  END;


  loc_fichier:=i_fichier;
  P_INS_journal(3, loc_journal, 'DEBUT PK_IMPORT_VIREMENT.importVIREMENT le '||TO_CHAR(SYSDATE));

  --------------- Récupération de l utilisateur de la porte  ------------------------
  P_INS_journal(3, loc_journal, 'i_fichier '||i_fichier );

  --------------- Récupération de l utilisateur de la porte  ------------------------
  g_numutil:=F_FIND_PORTE_NUMUTIL(i_Porte);
  P_INS_journal(3, loc_journal, 'g_numutil '||TO_CHAR(g_numutil));

  --------------------------------------------------------------------------------------------------------------------------------------
  -- Controle de la structure globale du fichier et contrôle d'unicité par rapport au nom du fichier physique
  --------------------------------------------------------------------------------------------------------------------------------------
  BEGIN
    SELECT repertoire
      INTO Loc_repertoire
      FROM TYP_BATCH
     WHERE BATCHID=i_traitement;
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(1, loc_journal,'Répertoire d''importation non paramétré');
      RAISE exc_fin_remise;
  END ;

  BEGIN
   SELECT type_format
     INTO loc_format
     FROM PORTE_ECHANGE e
    WHERE e.idechange = i_echange;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
      --------------------------------------------------------------------------------------------------------------------------------------
  -- Controle de la structure global du fichier, et insertion dans la table temporaire à partir de la table de paramétrage PORTE_ENTITE
  --------------------------------------------------------------------------------------------------------------------------------------
  p_ctrlFichierAffil (Loc_repertoire, loc_fichier, loc_format, loc_erreur);

  IF loc_erreur IS NOT NULL THEN
    P_INS_journal(1, loc_journal,loc_erreur);
    o_erreur:= loc_erreur;
  --  dbms_output.put_line(loc_erreur);
    RAISE exc_fin_remise;
  END IF;

  h_fichier := UTL_FILE.fopen (Loc_repertoire, i_fichier, 'R', 32767);


  -- création de la porte_remise
  -- Initialise PORTE_REMISE de la remise en cours
  SELECT MAX(Numremise)   +1
  INTO loc_PORTE_REMISE.numremise
  FROM PORTE_REMISE
  WHERE NUMPORTE=i_Porte;
  P_INS_journal(3, loc_journal,'Importation du fichier dans la remise :'||loc_PORTE_REMISE.numremise);

  loc_PORTE_REMISE.NUMPORTE   := i_Porte;
  loc_PORTE_REMISE.DATEREMISE := SYSDATE;
  loc_PORTE_REMISE.DATEPORTE  := NULL;
  loc_PORTE_REMISE.BATCH      := i_traitement;
  loc_PORTE_REMISE.NATURE     := NULL;
  loc_PORTE_REMISE.REF_EXT    := loc_fichier;


  --unicité de porte_remise sur le nom de fichier uniquement
  SELECT MAX(Numremise)
    INTO loc_numremise_doublon
    FROM PORTE_REMISE
   WHERE UPPER(ref_ext) = UPPER(i_fichier)
     AND NUMPORTE = i_porte;

  IF loc_numremise_doublon > 0 THEN
    RAISE exc_remise_importe;
  END IF;


  /*INSERTION DE PORTE_REMISE 1 remise par fichier physique*/
  IF NOT F_INS_PORTE_REMISE(loc_PORTE_REMISE) THEN
    RAISE exc_ins_Porte_remise;
  END IF;

  -- Insertion des donnes du fichier dans une table temporaire à l image du fichier avec l idechange de la table de paramétrage PORTE_ENTITE
  P_InsertDonneesPorte (loc_repertoire, i_fichier ,i_Porte,i_echange,i_nature, loc_PORTE_REMISE.numremise,h_fichier, loc_journal, o_erreur);
  IF o_erreur IS NOT NULL THEN
    RAISE exc_fin_remise;
  ELSE
    P_Verif_doublons_Virements(loc_PORTE_REMISE.numremise, i_Porte, loc_journal, o_erreur);
  END IF;

  IF UTL_FILE.is_open (h_fichier) THEN
    P_INS_journal(3, loc_journal,'Fermeture normale du fichier');
    UTL_FILE.fclose (h_fichier);
  END IF;

  IF o_erreur IS NOT NULL THEN
    P_INS_journal(1, loc_journal, 'o_erreur: '||o_erreur);
    P_INS_journal(1, loc_journal, 'loc_fichier: '||loc_fichier);
    P_INS_journal(1, loc_journal, 'Importation impossible');
    ROLLBACK;
    o_remise :=NULL;
    RETURN;
  ELSE
    COMMIT;
    o_remise := loc_porte_remise.numremise;
    P_INS_journal(1, loc_journal, 'loc_fichier: '||loc_fichier);
    UTL_FILE.FCOPY ( 'VIR_IN',
                     loc_fichier,
                     'VIR_DONE',
                     loc_fichier);
    UTL_FILE.FREMOVE ('VIR_IN',loc_fichier);

    P_INS_journal(3, loc_journal,  'FIN PK_IMPORT_VIREMENT.importVIREMENT le '||TO_CHAR(SYSDATE));
  END IF;


EXCEPTION
  WHEN exc_rep THEN
    ROLLBACK;
    IF UTL_FILE.is_open (h_fichier) THEN
      UTL_FILE.fclose (h_fichier);
    END IF;
    P_INS_journal(1, loc_journal, 'Répertoire d''importation non paramétré');
    o_erreur:='Répertoire d''importation non paramétré';
  WHEN exc_fin_remise THEN
    ROLLBACK;
   IF UTL_FILE.is_open (h_fichier) THEN
     UTL_FILE.fclose (h_fichier);
    END IF;
    P_INS_journal(1, loc_journal,'Intégration impossible, fermeture du fichier');
      --o_erreur:='Intégration impossible, fermeture du fichier';
      ROLLBACK;
  WHEN exc_ins_Porte_remise THEN
    ROLLBACK;
   IF UTL_FILE.is_open (h_fichier) THEN
     UTL_FILE.fclose (h_fichier);
    END IF;
    P_INS_journal(1, loc_journal,'Insertion porte remise impossible');
    o_erreur:='Insertion porte remise impossible';
  WHEN exc_ins_remise THEN
    ROLLBACK;
    IF UTL_FILE.is_open (h_fichier) THEN
      UTL_FILE.fclose (h_fichier);
    END IF;
    P_INS_journal(1, loc_journal,'Insertion remise fichier impossible');
    o_erreur:='Insertion remise fichier impossible';
  WHEN exc_remise_importe THEN
    ROLLBACK;
    P_INS_journal(1, loc_journal, 'Le fichier physique a déjà été importé sous ce nom de fichier, remise :'||loc_numremise_doublon);
    o_erreur:='Le fichier physique a déjà été importé sous ce nom de fichier, remise :'||loc_numremise_doublon;
  WHEN OTHERS THEN
    IF UTL_FILE.is_open (h_fichier) THEN
      UTL_FILE.fclose (h_fichier);
    END IF;
    ROLLBACK;
     o_erreur:=SQLERRM;
    P_INS_journal(1, loc_journal,  SUBSTR(SQLERRM,1,132));
END importVIREMENT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  AnnulimportVIREMENT                                       */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l' annulation de l import du fichier des  */
/*                 affiliations                                              */
/* Entree       :  i_numremise, numéro de remise                             */
/*                 i_session ,                                               */
/*                 i_traitement                                              */
/*                 i_idligne                                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE AnnulimportVIREMENT ( i_numremise    IN   VIR_PORTE.NUMREMISE%TYPE
                              , i_numporte     IN   VIR_PORTE.NUMPORTE%TYPE
                              , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                              , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                              , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                              , o_erreur       OUT  VARCHAR2)
IS
  loc_journal        JOURNAL_ADM%ROWTYPE;
BEGIN

  loc_journal.id_session := i_session;
  loc_journal.idligne := i_idligne;
  loc_journal.nom_traitement := i_traitement;

  BEGIN
    SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
    INTO loc_journal.niv_msg
    FROM PARAM_BATCH
    WHERE NUMBATCH = loc_journal.nom_traitement;
  EXCEPTION
    WHEN OTHERS THEN
      loc_journal.niv_msg:=3;
  END;

  P_INS_journal(3, loc_journal,  'DEBUT PK_IMPORT_VIREMENT.AnnulimportVIREMENT le '||TO_CHAR(SYSDATE));
  P_INS_journal(3, loc_journal,  'NUMREMISE en cours d annulation '||TO_CHAR(i_numremise));
  -- Annulation de l import et de l'ensemble des transactions dans Arthus


  -------------------- Suppression dans VIR_PORTE_FORCAGE ---------------------
  DELETE VIR_PORTE_FORCAGE
   WHERE numremise = i_numremise
     AND numporte = i_numporte;
  -------------------- Suppression dans VIR_EXLCUSION -------------------------
  DELETE VIR_PORTE_EXCLU
   WHERE numremise = i_numremise
     AND numporte = i_numporte;
  -------------------- Suppression dans VIR_PORTE -----------------------------
  DELETE VIR_PORTE
   WHERE numremise = i_numremise
     AND numporte = i_numporte;
  -------------------- Suppression dans VIR_FICHIER ---------------------------
  DELETE VIR_FICHIER
   WHERE numremise = i_numremise
     AND numporte = i_numporte;
  -------------------- Suppression dans PORTE_REMISE -------------------------
  DELETE PORTE_REMISE
   WHERE  numremise = i_numremise
     AND numporte = i_numporte;


  IF  o_erreur IS NOT NULL THEN
    P_INS_journal(3, loc_journal, o_erreur);
    ROLLBACK;
  ELSE
    COMMIT;
  END IF;

  P_INS_journal(3, loc_journal,  'FIN PK_IMPORT_VIREMENT.AnnulimportVIREMENT le '||TO_CHAR(SYSDATE));

EXCEPTION
  WHEN OTHERS THEN
    -- Annulation de l annulation de l import
    ROLLBACK;
    P_INS_journal(3, loc_journal,  SUBSTR(SQLERRM,1,132));
END AnnulimportVIREMENT;


-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  p_ctrlFichierAffil                                        */
/* Type         :  Privee                                                    */
/* Description  :  Controle du nom de fichier, du répertoire, de la structure*/
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_Entreprise, Numéro d'entreprise                         */
/*                 i_Trimestre, Numéro de trimestre                          */
/*                 s_fichier, Nom du fichier                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
PROCEDURE p_ctrlFichierAffil( i_repertoire IN VARCHAR2,
                              i_fichier    IN OUT VARCHAR2,
                              i_format     IN NUMBER,
                              o_erreur OUT VARCHAR2)
IS
   h_fichier               UTL_FILE.file_type;
   exc_extension           EXCEPTION;
   exc_par_repertoire_vide EXCEPTION;
   exc_par_fichier_vide    EXCEPTION;
   exc_fichierImport       EXCEPTION;


   l_numremise porte_remise.numremise%TYPE;

BEGIN
  --------------- Controle du repertoire et du fichier ------------------------
  IF i_repertoire IS NULL THEN
     RAISE exc_par_repertoire_vide;
  END IF;

  IF i_fichier IS NULL OR i_fichier = '' THEN
     RAISE exc_par_fichier_vide;
  END IF;

   --------------- Controle de la préscence physique du fichier ------------------------
  h_fichier := UTL_FILE.fopen (i_repertoire, i_fichier, 'R', 32767);
  UTL_FILE.fclose (h_fichier);


EXCEPTION
  WHEN exc_fichierImport THEN
     O_erreur := O_erreur|| ' Fichier déjà importé ';

  WHEN exc_extension THEN
     O_erreur := O_erreur|| ' Extension du fichier non valide ou non paramétrée:  '||F_LIBELLE_FORMAT('TYPFORMAT',3);
  WHEN exc_par_repertoire_vide THEN
     o_erreur:= O_erreur||'Nom du répertoire d''entrée manquant';
  WHEN exc_par_fichier_vide THEN
     o_erreur:= O_erreur||'Nom du fichier d''entrée manquant';
  WHEN DBMS_LOB.operation_failed THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:=O_erreur||'Fichier '||i_fichier||' non présent dans le répertoire d''import';
  WHEN UTL_FILE.internal_error THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:='UTL_FILE.INTERNAL_ERROR';
  WHEN UTL_FILE.invalid_filehandle THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:='UTL_FILE.INVALID_FILEHANDLE';
  WHEN UTL_FILE.invalid_mode THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:='UTL_FILE.INVALID_MODE';
  WHEN UTL_FILE.invalid_operation THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:=' Nom de fichier invalide';
  WHEN UTL_FILE.invalid_path THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:='UTL_FILE.INVALID_PATH';
  WHEN UTL_FILE.read_error THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:='UTL_FILE.READ_ERROR';
  WHEN UTL_FILE.write_error THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:='UTL_FILE.WRITE_ERROR';
  WHEN VALUE_ERROR THEN
     UTL_FILE.fclose (h_fichier);
     o_erreur:='VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  WHEN OTHERS THEN
     IF UTL_FILE.is_open (h_fichier) THEN
        UTL_FILE.fclose (h_fichier);
     END IF;
     o_erreur:=SUBSTR (SQLERRM (SQLCODE), 1, 128);

END p_ctrlFichierAffil ;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_InsertDonneesPorte                                      */
/* Type         :  Privee                                                    */
/* Description  :  Controle des données du fichier                           */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 s_fichier, Nom du fichier                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_InsertDonneesPorte ( i_repertoire  IN       VARCHAR2
                               , i_fichier     IN       VIR_FICHIER.FICHIER%TYPE
                               , i_Porte       IN       VIR_FICHIER.NUMPORTE%TYPE
                               , i_echange     IN       PORTE_ENTITE.IDECHANGE%TYPE
                               , i_nature      IN       NUMBER
                               , i_remise      IN       PORTE_REMISE.NUMREMISE%TYPE
                               , i_hfichier    IN       UTL_FILE.file_type
                               , i_journal     IN OUT   JOURNAL_ADM%ROWTYPE
                               , o_erreur         OUT   VARCHAR2)
IS


  s_ligne            VARCHAR2(5000):='';

  cpt_ano               NUMBER:=0;
  cpt_fic               NUMBER:=0;
  cpt_31                NUMBER:=0;
  cpt_34                NUMBER:=0;
  cpt_39                NUMBER:=0;

  Go_fin_fichier NUMBER;
  cpt_ligne      NUMBER(9);
  cpt_entete     NUMBER(9);

  --cpt_entite  NUMBER(9);
 --cpt_insert  NUMBER(9) :=1;
  cpt_bad_entete         NUMBER:=0;--compteur de rejet
  cpt_bad_ligne          NUMBER:=0;--compteur de rejet
  cpt_bad_entite         NUMBER:=0;--compteur de rejet
  cpt_bad_insert         NUMBER:=0;--compteur de rejet
  cpt_bad_param          NUMBER:=0;--compteur de rejet
  cpt_rejet              NUMBER:=0;--Compteur global des rejets
  s_nb_separateur   NUMBER:=0;


  l_T_ligne         pk_import_virement.T_ligne;
  l_T_entite        pk_import_virement.T_ligne;
  l_T_entite_empty  pk_import_virement.T_ligne;
  stmt            VARCHAR2(6000);
  stmt_init       VARCHAR2(600);
  stmt_value      VARCHAR2(600);
  stmt_clef       VARCHAR2(600);
  s_entite        PORTE_ENTITE.ENTITE%TYPE;
  s_donnee        PORTE_ENTITE.DONNEE%TYPE;
  loc_VIR_FICHIER VIR_FICHIER%ROWTYPE;
  loc_VIR_PORTE   VIR_PORTE%ROWTYPE;
  loc_table       PORTE_ENTITE.ENTITE%TYPE;
  loc_value       VARCHAR2(500);
  loc_test_date   DATE;

  exc_bad_separateur EXCEPTION;
  exc_bad_fichier    EXCEPTION;
  exc_ins_remise     EXCEPTION;
  exc_mauvaise_ligne EXCEPTION;
  exc_format_date    EXCEPTION;
  exc_format_number  EXCEPTION;

  CURSOR C_ENTITE (p_echange NUMBER, i_loc_table varchar2) IS
  SELECT e.*
    FROM PORTE_ENTITE_ORDRE o , PORTE_ENTITE e
   WHERE o.idechange = i_echange
     AND o.idechange = e.idechange
     AND o.entite = e.entite
     and o.entite = i_loc_table
     AND e.position>=1 --exclu le numligne clef primaire en 0 pour affil porte
    ORDER BY o.ordre,e.position,e.contrainte desc;

  CURSOR C_ECHANGE (p_echange NUMBER) IS
  SELECT e.TYPE_FORMAT, e.SEPARATEUR, e.LONGUEUR, e.ENTETE,e.APOSTROPHE
    FROM PORTE_ECHANGE e
   WHERE e.idechange = i_echange;

  Rec_C_ECHANGE C_ECHANGE%ROWTYPE;
  l_id_fic_cpt  NUMBER(9) :=0; --identifiant de fichier lorigique pour identification interne.
  l_id_virement  number(9);
BEGIN

 -- P_INS_journal(1, i_journal,  'P_InsertDonneesPorte');

  cpt_ligne :=0;
  Go_fin_fichier:=0;
  OPEN C_ECHANGE(i_echange);
  FETCH C_ECHANGE INTO Rec_C_ECHANGE;
  CLOSE C_ECHANGE;

  cpt_entete:=0;


   --parcourt du fichier
  WHILE PK_FICHIER.fGetLine(i_hfichier,s_ligne) LOOP
    BEGIN
      loc_table :=null;
      cpt_ligne:=cpt_ligne+1;
      --tableau par ligne du fichier

      -- verifie si la ligne est de la bonne taille
      IF length(s_ligne) <> Rec_C_ECHANGE.longueur THEN
         RAISE exc_mauvaise_ligne;
      END IF;

      IF SUBSTR(s_ligne, 1,2) = '31' THEN
        loc_table:='VIR_FICHIER';
        l_T_ligne:= P_Decoupe(s_ligne,i_echange,loc_table,i_journal);
        -- incrémentation de l'identifiant _cpt
        l_id_fic_cpt := l_id_fic_cpt+1;
        cpt_31:=cpt_31+1;
      ELSIF SUBSTR(s_ligne, 1,2) = '34' THEN
        loc_table:='VIR_PORTE';
        cpt_34:=cpt_34+1;
      ELSIF SUBSTR(s_ligne, 1,2) = '39' THEN
        cpt_39:=cpt_39+1;
      END IF;
        --parcourt des entités suivant l'odre paramétré et en tenant compte de l'action
      BEGIN
        s_entite:=NULL;
     --   cpt_entite:=0;
        --boucle sur les entités et colonne par ordre d'insertion des tables pour une ligne de fichier !
        --initialisé les objets ? numremise, numadh...numporte selon les Entité
        FOR Rec_C_ENTITE IN C_ENTITE(i_echange,loc_table) LOOP
          BEGIN
          -- dbms_output.put_line('table :'||loc_table||' donnée:'||s_donnee);
            --***GESTION DES RUPTURES VIA LES CONTRAINTES
            ---------------------------------------------------------------------
            -------------------- VIR_FICHIER ------------------------------------
            ---------------------------------------------------------------------
            IF   Rec_C_ENTITE.entite ='VIR_FICHIER' AND Rec_C_ENTITE.contrainte='31' THEN
                cpt_entete:=cpt_entete +1 ;
                loc_VIR_FICHIER.NUMREMISE :=i_remise;
                loc_VIR_FICHIER.NUMPORTE := i_Porte;
                loc_VIR_FICHIER.NATURE :=i_nature;--dans param1 ?
                loc_VIR_FICHIER.DATEFIC := sysdate;
                loc_VIR_FICHIER.FICHIER := i_fichier;
                loc_VIR_FICHIER.NBRE_FIC:=cpt_entete;
                loc_VIR_FICHIER.USERNAME:=g_numutil;
                --loc_VIR_FICHIER.CODERECORD:=l_T_ligne(Rec_C_ENTITE.position);
                loc_VIR_FICHIER.NUMSEQUENCE:=l_T_ligne(Rec_C_ENTITE.position+1) ;
                loc_VIR_FICHIER.CODEOPERATION:=l_T_ligne(Rec_C_ENTITE.position+2);
                loc_VIR_FICHIER.DATEFICPREC:=l_T_ligne(Rec_C_ENTITE.position+3);
                loc_VIR_FICHIER.INDICEMONAIE:=l_T_ligne(Rec_C_ENTITE.position+4);
                loc_VIR_FICHIER.CODBQUE_CRED:=l_T_ligne(Rec_C_ENTITE.position+5);
                loc_VIR_FICHIER.GUICHET_CRED:=l_T_ligne(Rec_C_ENTITE.position+6);
                loc_VIR_FICHIER.COMPTE_CRED:=l_T_ligne(Rec_C_ENTITE.position+7);
                loc_VIR_FICHIER.NOM_CRED:=l_T_ligne(Rec_C_ENTITE.position+8);
                loc_VIR_FICHIER.CODECENTRE:= l_T_ligne(Rec_C_ENTITE.position+9);
                loc_VIR_FICHIER.ID_CPT := l_id_fic_cpt;
             --  o_erreur:= 'Création fichier n°'||loc_VIR_FICHIER.NBRE_FIC;
             --  dbms_output.put_line('Création fichier n°'||loc_VIR_FICHIER.NBRE_FIC);

                IF F_CTRL_FORMAT_DATE(loc_VIR_FICHIER.DATEFICPREC) <> 1 THEN
                  raise EXC_FORMAT_DATE;
                END IF;

                IF NOT F_INS_VIR_FICHIER(loc_VIR_FICHIER,i_journal) THEN
                  RAISE exc_ins_remise;
                END IF;
             -- END IF;
            ---------------------------------------------------------------------
            -------------------- VIR_PORTE --------------------------------------
            ---------------------------------------------------------------------
            ELSIF   Rec_C_ENTITE.entite ='VIR_PORTE' THEN
              s_entite := Rec_C_ENTITE.entite;
              s_donnee := Rec_C_ENTITE.donnee;



              IF Rec_C_ENTITE.contrainte='34' THEN
                stmt_init := 'INSERT INTO '||s_entite||' (';
                stmt_clef := 'NUMREMISE,NUMPORTE,DATRAIT,ETAT,NUMLIGNE,ID_CPT,NUM_FRAGMENT,';
                stmt_value := ') VALUES ('|| i_remise ||','|| i_porte ||',e2d('''||to_char(sysdate,'dd/mm/yyyy')||'''),2,'|| cpt_34 ||','||l_id_fic_cpt||','||1||',';
                stmt_init:= stmt_init ||stmt_clef;
              ELSE
                stmt_init := stmt_init ||Rec_C_ENTITE.donnee||',';
                loc_value := trim(substr(s_ligne,Rec_C_ENTITE.position,Rec_C_ENTITE.taille));

                IF loc_value IS NULL  THEN
                  stmt_value := stmt_value||'NULL,';
                ELSE
                  IF Rec_C_ENTITE.TYPE = 'D' THEN
                    IF F_CTRL_FORMAT_DATE(loc_value) <> 1 THEN  -- controle sur la date
                      RAISE exc_format_date;
                    END IF;
                  ELSIF Rec_C_ENTITE.TYPE = 'N' THEN
                    IF F_CTRL_FORMAT_NUMBER(loc_value) <> 1 THEN  -- controle sur la date
                      RAISE exc_format_number;
                    END IF;

                  END IF;
                  stmt_value := stmt_value||''''||F_CTRL_NUMBER_VARCHAR_AFF(loc_value,l_id_fic_cpt, Rec_C_ENTITE, i_journal, cpt_ligne) ||''',';
                END IF;
              END IF;
              IF  Rec_C_ENTITE.contrainte ='END' THEN
                l_T_entite(1) :=RTRIM(stmt_init,',') || RTRIM(stmt_value,',')||')';
              END IF;
            ELSE
              stmt_clef:='';
              stmt_value:='';
            END IF;

          EXCEPTION
            WHEN exc_format_number THEN
              dbms_output.put_line('RAISE exc_format_number');
              P_INS_journal(1,i_journal, 'RAISE exc_format_number');
              RAISE exc_format_number;
            WHEN exc_format_date THEN
              dbms_output.put_line('RAISE exc_format_date');
              P_INS_journal(1,i_journal, 'RAISE exc_format_date');
              RAISE exc_format_date;
            WHEN exc_mauvaise_ligne THEN
              dbms_output.put_line('RAISE exc_mauvaise_ligne');
              P_INS_journal(1,i_journal, 'RAISE exc_mauvaise_ligne');
              RAISE exc_mauvaise_ligne ;
            WHEN OTHERS THEN
              --dbms_output.put_line('Ligne <'||TO_CHAR(cpt_ligne)||'>  <'||s_entite||'.'||s_donnee||'>'||l_T_entite(Rec_C_ENTITE.position)||'-'||SQLERRM);
              P_INS_journal(3,i_journal, ' 2 Ligne <'||TO_CHAR(cpt_ligne)||'>  <'||s_entite||'.'||s_donnee||'>'||l_T_entite(Rec_C_ENTITE.position)||'-'||SQLERRM);
          END;
        --INSERT INTO VIR_PORTE (NUMREMISE,NUMPORTE,DATRAIT,ETAT,NUMLIGNE,id_cpt,NUM_FRAGMENT,MONTANT_OPE,
        END LOOP;

      EXCEPTION
        WHEN exc_format_number THEN
          dbms_output.put_line('RAISE exc_format_number 2');
          P_INS_journal(1,i_journal, 'RAISE exc_format_number 2');
          RAISE exc_format_number;
        WHEN exc_format_date THEN
          dbms_output.put_line('RAISE exc_format_date 2');
          P_INS_journal(1,i_journal, 'RAISE exc_format_date 2');
          RAISE exc_format_date;
        WHEN exc_mauvaise_ligne THEN
          dbms_output.put_line('RAISE exc_format_date 2');
          P_INS_journal(1,i_journal, 'RAISE exc_format_date 2');
          RAISE exc_mauvaise_ligne ;
        WHEN OTHERS THEN
          P_INS_journal(1,i_journal, ' 1 Ligne <'||TO_CHAR(cpt_ligne)||'>  <'||s_entite||'.'||s_donnee||'> '||SQLERRM);
          cpt_bad_ligne:=cpt_bad_ligne+1;
      END;
      /****INSERTION DE CHAQUE LIGNE****/
     FOR i in 1..l_T_entite.count LOOP
     --   o_erreur:='-----';
       -- dbms_output.put_line('-----'||l_T_entite(i));
       -- P_INS_journal(3,i_journal, l_T_entite(i));

      BEGIN
        EXECUTE IMMEDIATE trim(l_T_entite(i)) ;
      --  COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          CASE SQLCODE
            WHEN '-917'   THEN P_INS_journal(1,i_journal,' Ligne <'||TO_CHAR(cpt_ligne)||'> invalide(Problème d''apostrophe)');
            WHEN '-947'   THEN P_INS_journal(1,i_journal,' Ligne <'||TO_CHAR(cpt_ligne)||'> invalide(Nb colonnes insuffisantes)');
            WHEN '-12899' THEN P_INS_journal(1,i_journal,' Ligne <'||TO_CHAR(cpt_ligne)||'> invalide(nb caractères trop long pour la colonne<'||SUBSTR (SQLERRM (SQLCODE), 68, 128)||'>)');
          ELSE
            P_INS_journal(1, i_journal,' ins Ligne <'||TO_CHAR(cpt_ligne)||'> : Erreur indéterminée :' ||SQLERRM);
             o_erreur:='ins Ligne <'||TO_CHAR(cpt_ligne)||'> : Erreur indéterminée :' ||SQLERRM;
          --   dbms_output.put_line('ins Ligne <'||TO_CHAR(cpt_ligne)||'> : Erreur indéterminée :' ||SQLERRM);
          END CASE;
          cpt_bad_insert:=cpt_bad_insert+1;
      END;
      END LOOP;
      END;
      l_T_entite:=l_T_entite_empty; --réinitialisation
    END LOOP;


  -- Gestion des compteurs de rejet
    P_INS_journal(1,i_journal, 'Le nombre de Lignes avec une structure invalide est de  <'||TO_CHAR(cpt_bad_insert)||'> ');
    P_INS_journal(1,i_journal, 'Le nombre de Lignes avec une colonne invalide est de  <'||TO_CHAR(cpt_bad_ligne)||'>');
    IF cpt_bad_entete>0 THEN
      P_INS_journal(1,i_journal, 'Entete du fichier non valide ou inexistante');
      cpt_rejet:=cpt_rejet+cpt_bad_entete;
    END IF;
    IF cpt_bad_param>0 THEN
      P_INS_journal(1,i_journal, 'Mauvais echange dans la table de paramétrage');
      cpt_rejet:=cpt_rejet+cpt_bad_param;
    END IF;
    IF cpt_bad_insert>0 THEN
      cpt_rejet:=cpt_rejet+cpt_bad_insert;
    END IF;
    IF cpt_bad_ligne>0 THEN
      cpt_rejet:=cpt_rejet+cpt_bad_ligne;
    END IF;

    P_INS_journal(1,i_journal, 'Le nombre de début de fichiers logiques traitées dans le fichier est de <'||cpt_31||'>');
    P_INS_journal(1,i_journal, 'Le nombre de fin de fichiers logiques traitées dans le fichier est de <'||cpt_39||'>');
    P_INS_journal(1,i_journal, 'Le nombre de virements traitées dans le fichier est de <'||cpt_34||'>');
    P_INS_journal(1,i_journal, 'Le nombre de lignes traitées dans le fichier est de <'||cpt_ligne||'>');


    IF cpt_rejet>0 THEN
      RAISE exc_bad_fichier;
    ELSE
      P_INS_journal(3,i_journal, 'Fichier des virements traité avec succès');
    END IF;

EXCEPTION
  WHEN exc_format_date THEN
    o_erreur:='Insertion remise fichier impossible, erreur : (Erreur sur le format d''une date)';
    dbms_output.put_line('Insertion remise fichier impossible, erreur : (Erreur sur le format d''une date)');
    P_INS_journal(1, i_journal,'Insertion remise fichier impossible, erreur : (Erreur sur le format d''une date)');
  WHEN exc_mauvaise_ligne THEN
    o_erreur:='Insertion remise fichier impossible, erreur : (Une des lignes du fichier ne fait pas '||Rec_C_ECHANGE.longueur||' caractères)';
    dbms_output.put_line('Insertion remise fichier impossible, erreur : <Une des lignes du fichier ne fait pas '||Rec_C_ECHANGE.longueur||' caractères>');
    P_INS_journal(1, i_journal,'Insertion remise fichier impossible, erreur : <Une des lignes du fichier ne fait pas '||Rec_C_ECHANGE.longueur||' caractères>');
  WHEN exc_ins_remise THEN
    o_erreur:='Insertion remise fichier impossible, erreur : < '||SQLERRM;
  dbms_output.put_line('Insertion remise fichier impossible, erreur : < '||SQLERRM);
    P_INS_journal(1, i_journal,'Insertion remise fichier impossible, erreur : < '||SQLERRM||' >');
   -- RAISE exc_fin_remise;
  WHEN exc_bad_fichier THEN
    o_erreur:=  'Le nombre total de Lignes invalide est de  <'||TO_CHAR(cpt_bad_insert)||'>' ;
  dbms_output.put_line('Le nombre total de Lignes invalide est de  <'||TO_CHAR(cpt_bad_insert)||'>');
    P_INS_journal(1, i_journal,'Le nombre total de Lignes invalide est de  <'||TO_CHAR(cpt_bad_insert)||'>');
   -- RAISE exc_fin_remise;
  WHEN exc_bad_separateur THEN
    o_erreur:=  'Mauvais Nombre de colonne identifiée ';
  dbms_output.put_line('Mauvais Nombre de colonne identifiée ');
    P_INS_journal(1, i_journal,'Nombre de colonne identifiée :'||s_nb_separateur||',attentue :'||Rec_C_ECHANGE.longueur||'. Vérifier la structure du fichier');
  --  RAISE exc_fin_remise;
  WHEN OTHERS THEN
    P_INS_journal(1, i_journal, 'Lig:'||cpt_ligne||'- erreur :'||SQLERRM);
    o_erreur:=  'Lig:'||cpt_ligne||'- erreur :'||SQLERRM;
     dbms_output.put_line('Lig:'||cpt_ligne||'- erreur :'||SQLERRM);
    cpt_ano:=cpt_ano+1;
   -- RAISE exc_fin_remise;
END p_InsertDonneesPorte;

-----------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Verif_doublons_Virements                                */
/* Type         :  Privee                                                    */
/* Description  :                                                            */
/* Entree       :          ,                                                 */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE  P_Verif_doublons_Virements( i_remise      IN       PORTE_REMISE.NUMREMISE%TYPE
                                     , i_Porte       IN       VIR_FICHIER.NUMPORTE%TYPE
                                     , i_journal     IN OUT   JOURNAL_ADM%ROWTYPE
                                     , o_erreur         OUT   VARCHAR2)
IS
  loc_dateficrglt     VIR_PORTE.DATEFICRGLT%TYPE:=NULL;

  CURSOR c_virement
      IS
  SELECT vf.NUMREMISE
       , vp.NUMPORTE
       , vp.COMPTE_DO
       , vf.COMPTE_CRED
       , vp.DATEFICRGLT
       , vp.MONTANT_INIT
       , vp.numligne
    FROM VIR_FICHIER vf
       , VIR_PORTE vp
   WHERE vf.NUMREMISE = i_remise
     AND vf.NUMPORTE  = i_Porte
    -- AND vp.DATEFICRGLT = '020218'
     AND vf.NUMREMISE = vp.NUMREMISE
     AND vf.NUMPORTE  = vp.NUMPORTE
    AND vp.ID_CPT     = vf.ID_CPT
   ORDER BY vp.numligne;

  CURSOR c_virement_doublons(rec_virement IN c_virement%ROWTYPE/*, i_dateficrglt   IN  VIR_PORTE.DATEFICRGLT%TYPE*/)
      IS
    SELECT numligne, vp.numremise --NVL(MAX(vp.numligne),0)
   --   INTO loc_numligne
      FROM VIR_PORTE vp
         , VIR_FICHIER vf
     WHERE vp.NUMREMISE   = rec_virement.numremise
       AND vf.NUMREMISE    = vp.NUMREMISE
       AND vf.NUMPORTE     = vp.NUMPORTE
       AND vp.ID_CPT       = vf.ID_CPT
       AND vp.numligne <> rec_virement.numligne
       AND vp.NUMPORTE     = rec_virement.numporte
       AND vp.COMPTE_DO    = rec_virement.compte_DO
       AND vf.COMPTE_CRED  = rec_virement.compte_cred
       AND vp.DATEFICRGLT  = rec_virement.dateficrglt
       AND vp.MONTANT_INIT = rec_virement.montant_init
       AND vp.ETAT         <> 3    -- bloqué (exclu)
    UNION
    -- doublons dans les autres fichiers
    SELECT numligne,vp.numremise --NVL(MAX(vp.numligne),0)
   --   INTO loc_numligne
      FROM VIR_PORTE vp
         , VIR_FICHIER vf
     WHERE vp.NUMREMISE    <> rec_virement.numremise
       AND vf.NUMREMISE    = vp.NUMREMISE
       AND vf.NUMPORTE     = vp.NUMPORTE
       AND vp.ID_CPT       = vf.ID_CPT
       AND vp.numligne     = rec_virement.numligne
       AND vp.NUMPORTE     = rec_virement.numporte
       AND vp.COMPTE_DO    = rec_virement.compte_DO
       AND vf.COMPTE_CRED  = rec_virement.compte_cred
       AND vp.DATEFICRGLT  = rec_virement.dateficrglt
       AND vp.MONTANT_INIT = rec_virement.montant_init
       AND vp.ETAT         <> 3    -- bloqué (exclu)
       ;


 -- rec_virement  c_virement%ROWTYPE;
  loc_numligne  VIR_PORTE.NUMLIGNE%TYPE:=0;
  exc_doublons  EXCEPTION;

BEGIN

  FOR rec_virement IN c_virement LOOP
    P_INS_journal(3, i_journal, 'rec_virement.compte_DO: '||rec_virement.compte_DO);
    P_INS_journal(3, i_journal, 'rec_virement.compte_cred: '||rec_virement.compte_cred);
    P_INS_journal(3, i_journal, 'rec_virement.dateficrglt: '||rec_virement.dateficrglt);
    P_INS_journal(3, i_journal, 'rec_virement.montant_init: '||rec_virement.montant_init);
 /*
    loc_dateficrglt:=NULL;
    BEGIN
      SELECT VIR_PORTE.DATEFICRGLT
       INTO loc_dateficrglt
       FROM VIR_PORTE
      WHERE VIR_PORTE.NUMPORTE     = i_Porte
        AND VIR_PORTE.NUMREMISE    = i_remise
        AND VIR_PORTE.NUMLIGNE     = rec_virement.numligne;
    EXCEPTION
      WHEN OTHERS THEN
        loc_dateficrglt:=NULL;
    END;
    */
   -- doublon dans le fichier
    FOR rec_virement_doublons IN c_virement_doublons(rec_virement/*,loc_dateficrglt*/) LOOP
      P_INS_journal(3, i_journal, 'loc_numligne: '||loc_numligne);
      -- Si un doublon est trouvé pour un virement, alors on mets l'atat de la ligne à 8
      -- cela nous permettre d'avoir un flag pour afficher au gestionnaire la préscence d'un doublon pour le forcer ou non
      IF rec_virement_doublons.numligne > 0 THEN
        UPDATE VIR_PORTE vp
           SET vp.ETAT = 8       -- doublons
         WHERE vp.NUMREMISE    = i_remise
           AND vp.NUMPORTE     = i_Porte
           AND vp.NUMLIGNE     = rec_virement_doublons.numligne;

      END IF;
    END LOOP;
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3, i_journal, 'P_Verif_doublons_Virements KO '||SUBSTR(SQLERRM,1,132));
END P_Verif_doublons_Virements;

---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  P_Decoupe                                                 */
/* Type         :  Privee                                                    */
/* Description  :  Convertie une chaine de caratère en tableau               */
/* Entree       :  I_string,                                                 */
/* Retour       :  Un tableau de ligne                                       */
/*---------------------------------------------------------------------------*/
FUNCTION P_Decoupe (I_string VARCHAR2, I_echange PORTE_ENTITE.idechange%TYPE, i_table PORTE_ENTITE.ENTITE%TYPE, i_journal     IN OUT   JOURNAL_ADM%ROWTYPE)
RETURN pk_import_virement.T_ligne
IS


  strings  pk_import_virement.T_ligne;
  i        NUMBER:=0;

  CURSOR  c_echange
     IS
   SELECT e.*
    FROM PORTE_ENTITE e
   WHERE e.idechange = I_echange
     AND e.position>=1
     AND e.entite = i_table
    ORDER BY e.contrainte,e.position;

  rec_echange  c_echange%ROWTYPE;

BEGIN

  FOR rec_echange IN c_echange LOOP
    i := i + 1;
    strings(i) := SUBSTR(I_string,rec_echange.position,rec_echange.taille);
  END LOOP;

  RETURN strings;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3, i_journal, 'P_Decoupe KO '||SUBSTR(SQLERRM,1,132));
    RETURN strings;
END P_Decoupe;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GestionVIREMENT                                         */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l identification du donneur d ordre ainsi */
/*                 que la création de l encaissement en automatique          */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestionVIREMENT ( i_numremise     IN   VIR_PORTE.NUMREMISE%TYPE
                            , i_Porte         IN   VIR_PORTE.NUMPORTE%TYPE
                            , i_numligne      IN   VIR_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                            , i_flag_do       IN   NUMBER
                            , i_flag_encaismt IN   NUMBER
                            , i_session       IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement    IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                            , i_idligne       IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , o_erreur        OUT  VARCHAR2
                            , o_warning       OUT  VARCHAR2)
IS

  loc_journal            JOURNAL_ADM%ROWTYPE;
  loc_vir_porte          VIR_PORTE%ROWTYPE;
  loc_cpt                NUMBER:=0;
  loc_numcompteSoc       VIR_FICHIER.NUMCPTE%TYPE:=NULL;
  loc_numcompte          VIR_PORTE.NUMCPTE%TYPE:=NULL;
  loc_numdonordre        VIR_PORTE.NUMDONORDRE%TYPE:=NULL;
  loc_numencaismt        VIR_PORTE.NUMENCAISMT%TYPE:=NULL;
  loc_etat               VIR_PORTE.ETAT%TYPE:=NULL;
  loc_codope             NUMBER:=NULL;

  exc_codeope            EXCEPTION;
  exc_numcompteSoc       EXCEPTION;
  exc_numdonordre        EXCEPTION;
  exc_numdonordre_null   EXCEPTION;
  exc_encaismt_ext       EXCEPTION;
  exc_encaismt           EXCEPTION;
  exc_etat               EXCEPTION;


  CURSOR C_VIR_FICHIER
      IS
  SELECT *
   FROM VIR_FICHIER
  WHERE  VIR_FICHIER.NUMREMISE = i_numremise
    AND VIR_FICHIER.NUMPORTE = i_Porte
  ORDER BY ID_CPT ASC;


  CURSOR C_VIR_PORTE
      IS
  SELECT *
   FROM VIR_PORTE
  WHERE  VIR_PORTE.NUMREMISE = i_numremise
    AND VIR_PORTE.NUMPORTE = i_Porte
    AND VIR_PORTE.NUMLIGNE = NVL(i_numligne,VIR_PORTE.NUMLIGNE)
    AND VIR_PORTE.NUMENCAISMT IS NULL
    AND NOT EXISTS (
         SELECT 1
           FROM VIR_PORTE_EXCLU
          WHERE numremise = VIR_PORTE.NUMREMISE
            AND id_cpt = VIR_PORTE.id_cpt
            AND numligne = VIR_PORTE.numligne
            AND num_fragment = VIR_PORTE.num_fragment
                   )
  ORDER BY NUMREMISE, NUMLIGNE  ASC, NUM_FRAGMENT ASC;


BEGIN

  loc_journal.id_session := i_session;
  loc_journal.idligne := i_idligne;
  loc_journal.nom_traitement := i_traitement;

  BEGIN
    SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
    INTO loc_journal.niv_msg
    FROM PARAM_BATCH
    WHERE NUMBATCH = loc_journal.nom_traitement;
  EXCEPTION
    WHEN OTHERS THEN
      loc_journal.niv_msg:=3;
  END;


  P_INS_journal(3, loc_journal, 'DEBUT PK_IMPORT_VIREMENT.P_GestionVIREMENT le '||TO_CHAR(SYSDATE));

  --------------- Récupération de l utilisateur de la porte  ------------------------
  g_numutil:=f_numutil;
  P_INS_journal(3, loc_journal, 'g_numutil '||TO_CHAR(g_numutil));
  P_INS_journal(3, loc_journal, 'i_Porte '||TO_CHAR(i_Porte));
  P_INS_journal(3, loc_journal, 'i_numremise :'||i_numremise);
  P_INS_journal(3, loc_journal, 'i_flag_do :'||i_flag_do);
  P_INS_journal(3, loc_journal, 'i_flag_encaismt :'||i_flag_encaismt);

  BEGIN
    IF (NVL(i_flag_do,0) = 1 AND NVL(i_flag_encaismt,0) = 0) THEN
      -- Mise à jour par défaut du code opération à 4 - Encaissements de cotisations
      P_MAJ_VIR_PORTE_CODOPE(i_numremise , o_erreur);
    END IF;

    P_INS_journal(3, loc_journal, 'P_MAJ_VIR_PORTE_CODOPE '||o_erreur);
    IF TRIM(o_erreur) IS NOT NULL THEN
      P_INS_journal(3, loc_journal, 'RAISE exc_codeope '||o_erreur);
      RAISE exc_codeope;
    END IF;
    --------------- Identification de la société de gestion : entité 31 : VIR_FICHIER -
    FOR rec_VIR_FICHIER  IN  c_VIR_FICHIER  LOOP
      loc_cpt:= loc_cpt +1;
      loc_numcompteSoc:=F_IdentSocGestion(rec_VIR_FICHIER, o_erreur);

      IF NVL(loc_numcompteSoc,0) > 0 THEN
        -- mise à jour du compte de la société de gestion dans VIR_FICHIER
        P_MAJ_VIR_FICHIER_NUMCOMPTE(loc_numcompteSoc, rec_VIR_FICHIER , o_erreur);
      --  P_INS_journal(3, loc_journal, 'compte de trésorerie trouvé :'||loc_numcompteSoc);
        IF TRIM(o_erreur) IS NOT NULL THEN
          P_MAJ_VALIDE_VIR_FICHIER(rec_VIR_FICHIER, 'N', o_erreur);
          IF TRIM(o_erreur)  IS NULL THEN
            COMMIT;
          ELSE
            RAISE exc_numcompteSoc;
          END IF;
        ELSE
          COMMIT;
        END IF;
      ELSE
        P_MAJ_VALIDE_VIR_FICHIER(rec_VIR_FICHIER, 'N', o_erreur);
        IF TRIM(o_erreur)  IS NULL THEN
          COMMIT;
        ELSE
          RAISE exc_numcompteSoc;
        END IF;
      END IF;

    END LOOP;
  END;


  P_INS_journal(3, loc_journal, ' Identification du tiers payeur, numremise :'||i_numremise);

  --------------- Identification du tiers payeur : entité 34 : VIR_PORTE ------
  FOR rec_VIR_PORTE  IN  c_VIR_PORTE  LOOP
    BEGIN

      -- mise à jour du compte opération à 12 si c'est un compte de trésorerie est CFE
      P_MAJ_VIR_PORTE_CODOPE_CFE(rec_VIR_PORTE ,loc_codope, o_erreur);


      IF i_flag_do IN (1,2) THEN -- permet de faire uniquement l identification du donneur d'ordre
        loc_cpt:= loc_cpt +1;
        P_INS_journal(3, loc_journal, ' F_IdentNumDonOrdre, rec_VIR_PORTE.compte_do :'||rec_VIR_PORTE.compte_do);
        P_INS_journal(3, loc_journal, ' F_IdentNumDonOrdre, rec_VIR_PORTE.guichet_do :'||rec_VIR_PORTE.guichet_do);
        loc_numdonordre:=F_IdentNumDonOrdre(rec_VIR_PORTE, o_erreur);
        P_INS_journal(3, loc_journal, ' loc_numdonordre :'||loc_numdonordre);
        P_INS_journal(3, loc_journal, ' o_erreur :'||o_erreur);
        IF NVL(loc_numdonordre,0) > 0 THEN
          P_INS_journal(3, loc_journal, ' loc_numdonordre2 :'||loc_numdonordre);
          -- mise à jour du compte de la société de gestion dans VIR_FICHIER
          P_MAJ_VIR_PORTE_NUMDONORDRE(loc_numdonordre, loc_numcompte, rec_VIR_PORTE.numligne, i_numremise, loc_journal,o_erreur);
          P_INS_journal(3, loc_journal, ' o_erreur2 :'||o_erreur);
          IF TRIM(o_erreur) IS NOT NULL THEN
            RAISE exc_numdonordre;
          ELSE
            loc_etat:=1;
            P_MAJ_ETAT_VIR_PORTE(rec_VIR_PORTE, loc_etat, o_erreur);
            P_INS_journal(3, loc_journal, ' o_erreur3 :'||o_erreur);
            IF TRIM(o_erreur)  IS NULL THEN
              COMMIT;
            ELSE
              RAISE exc_etat;
            END IF;
          END IF;
        ELSE
          RAISE exc_numdonordre;
        END IF;
      END IF;

      IF i_flag_encaismt = 1 OR loc_numdonordre=103 THEN -- permet de faire uniquement la création de l'encaissement et la validation du virement externe
        --------------- CREATION DE L ENCAISSEMENT -------------------------------
        IF NVL(loc_numdonordre,0) = 0 AND NVL(rec_VIR_PORTE.numdonordre,0)= 0 THEN
          RAISE exc_numdonordre_null;
        END IF;
        P_Creer_Encaissement (rec_VIR_PORTE,  NVL(loc_numdonordre,rec_VIR_PORTE.numdonordre),loc_numencaismt, o_erreur, o_warning);
        IF NVL(loc_numencaismt,0)> 0 THEN
          P_MAJ_VIR_PORTE_NUMENCAISMT(rec_VIR_PORTE, loc_numencaismt, o_erreur);
        ELSE
          RAISE exc_encaismt_ext;
        END IF;

        P_INS_journal(3, loc_journal, ' o_erreur :'||o_erreur);
        P_INS_journal(3, loc_journal, ' o_warning :'||o_warning);
        --------------- CHANGEMENT DE L ETAT -------------------------------------
        IF TRIM(o_erreur)  IS NULL THEN

        --------------------------------------------------------------------------
          IF TRIM(o_warning) IS NOT NULL THEN
            loc_etat:=7;
          ELSE
            loc_etat:=1;
          END IF;
          P_INS_journal(3, loc_journal, ' loc_etat :'||loc_etat);
          P_MAJ_ETAT_VIR_PORTE(rec_VIR_PORTE, loc_etat, o_erreur);
          IF TRIM(o_erreur)  IS NULL THEN
            COMMIT;
          ELSE
            RAISE exc_etat;
          END IF;

        ELSE
          RAISE exc_encaismt;
        END IF;
      END IF;

    EXCEPTION
      WHEN exc_codeope THEN
        P_INS_journal(1, loc_journal, o_erreur);
        o_erreur:=2345;
      WHEN exc_encaismt_ext THEN
        P_INS_journal(1, loc_journal, o_erreur);
        o_erreur:=2334;
        ROLLBACK;
      WHEN exc_etat THEN
        P_INS_journal(1, loc_journal, o_erreur);
        o_erreur:=2335;
        ROLLBACK;
      WHEN exc_encaismt THEN
        P_INS_journal(1, loc_journal, o_erreur);
        o_erreur:=2336;
        ROLLBACK;
      WHEN exc_numcompteSoc THEN
        P_INS_journal(1, loc_journal, o_erreur);
        o_erreur:=2337;
        ROLLBACK;
      WHEN exc_numdonordre THEN
        P_INS_journal(1, loc_journal, o_erreur);
       -- o_erreur:=2338;
      --  ROLLBACK;
      WHEN exc_numdonordre_null THEN
        P_INS_journal(1, loc_journal, 'Le donneur d''ordre est d''abord à identifier', o_erreur);
        o_erreur:=2339;
        ROLLBACK;
    END;

    IF  rec_VIR_PORTE.etat = 8 THEN
      o_warning := 'Un doublon de virement est présent dans cette remise';
    END IF ;
    IF /*i_flag_encaismt = 1 AND */ F_CLIENT = 4 THEN
      EXIT; -- afin de traiter qu'un seul encaissement en cas de fragmentation en plusieurs montant d un encaissement sur un même numéro de ligne
    END IF;
  END LOOP;



EXCEPTION
  WHEN OTHERS THEN
  -- Annulation de la validation de l import CFE et de l'ensemble des transactions dans Arthus
    ROLLBACK;
     o_erreur:=SQLERRM;
    P_INS_journal(1, loc_journal,  SUBSTR(SQLERRM,1,132));
END P_GestionVIREMENT;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_IdentSocGestion                                         */
/* Type         :  Public                                                    */
/* Description  :  fonction Identification de la société de gestion : entité */
/*                 31 : VIR_FICHIER                                          */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_IdentSocGestion( rec_VIR_FICHIER  IN    VIR_FICHIER%ROWTYPE
                          , o_erreur         OUT   VARCHAR2)
RETURN VIR_FICHIER.NUMCPTE%TYPE

IS

  loc_numcpte        COMPTE.NUMCPTE%TYPE:=0;

BEGIN

  BEGIN
    SELECT DISTINCT c.numcpte
      INTO loc_numcpte
      FROM COMPTE c
         , PERS_SOCIETE p
     WHERE (c.bban = rec_VIR_FICHIER.COMPTE_CRED OR  c.compte = rec_VIR_FICHIER.COMPTE_CRED)
       AND c.numsoc = p.numsoc;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      o_erreur:='Plusieurs comptes de trouvés pour la société de gestion';
      RETURN 0;
    WHEN NO_DATA_FOUND THEN
      SELECT DISTINCT c.numcpte
        INTO loc_numcpte
        FROM COMPTE c
           , PERS_SOCIETE p
       WHERE c.bban LIKE '%'||SUBSTR(rec_VIR_FICHIER.COMPTE_CRED,1,8)||'%' --LIKE '%'||SUBSTR('08115120',1,8)||'%'
       --  AND c.bban LIKE '%'||rec_VIR_FICHIER.COMPTE_CRED||'%'
         AND c.numsoc = p.numsoc;
  END;

  RETURN loc_numcpte;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    o_erreur:='Aucun compte de trouvé pour la société de gestion';
    RETURN 0;
  WHEN OTHERS THEN
    o_erreur:=SQLERRM;
    RETURN 0;
END F_IdentSocGestion;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_VIR_PORTE_CODOPE                                    */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_VIR_PORTE_CODOPE( i_numremise     IN       VIR_PORTE.NUMREMISE%TYPE
                                , o_erreur            OUT  VARCHAR2)
IS

BEGIN

  UPDATE VIR_PORTE
     SET CODOPE = 4 -- encaissements de cotisations
   WHERE NUMREMISE = i_numremise;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
     o_erreur:=SQLERRM;
END P_MAJ_VIR_PORTE_CODOPE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_VIR_PORTE_CODOPE_CFE                                */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_VIR_PORTE_CODOPE_CFE( rec_VIR_PORTE    IN         VIR_PORTE%ROWTYPE
                                    , loc_codope             OUT  NUMBER
                                    , o_erreur               OUT  VARCHAR2)
IS

BEGIN

  SELECT NVL(MAX(1),0)
    INTO loc_codope
    FROM rib, porte_param
   WHERE codbque||guichet||compte = rec_VIR_PORTE.codbque_DO||rec_VIR_PORTE.guichet_DO||rec_VIR_PORTE.compte_DO
     AND numbene=numindiv
     AND numporte=rec_VIR_PORTE.numporte;

  IF loc_codope = 1 THEN
    UPDATE VIR_PORTE
       SET CODOPE = 12 -- encaissements de CFE
     WHERE NUMREMISE = rec_VIR_PORTE.numremise
       AND NUMLIGNE  = rec_VIR_PORTE.numligne;
       loc_codope:=12;
  ELSE
    loc_codope:=4;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
     o_erreur:=SQLERRM;
END P_MAJ_VIR_PORTE_CODOPE_CFE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_VIR_FICHIER_NUMCOMPTE                               */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_VIR_FICHIER_NUMCOMPTE(i_numcompte      IN    VIR_FICHIER.NUMCPTE%TYPE
                                    , rec_VIR_FICHIER  IN    VIR_FICHIER%ROWTYPE
                                    , o_erreur         OUT   VARCHAR2)
IS

BEGIN

  UPDATE VIR_FICHIER
     SET NUMCPTE = i_numcompte
   WHERE NUMREMISE = rec_VIR_FICHIER.numremise
     AND NUMPORTE = rec_VIR_FICHIER.numporte;

  UPDATE VIR_PORTE
     SET NUMCPTE = i_numcompte
   WHERE NUMREMISE = rec_VIR_FICHIER.numremise
     AND NUMPORTE = rec_VIR_FICHIER.numporte
     AND ID_CPT = rec_VIR_FICHIER.ID_CPT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
     o_erreur:=SQLERRM;
END P_MAJ_VIR_FICHIER_NUMCOMPTE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_VALIDE_VIR_FICHIER                                  */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_VALIDE_VIR_FICHIER( rec_VIR_FICHIER  IN    VIR_FICHIER%ROWTYPE
                                  , i_valide         IN    VIR_FICHIER.VALIDE%TYPE
                                  , o_erreur         OUT   VARCHAR2)
IS

BEGIN

  UPDATE VIR_FICHIER
     SET VALIDE = i_valide
   WHERE NUMREMISE = rec_VIR_FICHIER.numremise
     AND NUMPORTE  = rec_VIR_FICHIER.numporte
     AND ID_CPT    = rec_VIR_FICHIER.id_cpt;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
     o_erreur:=SQLERRM;
END P_MAJ_VALIDE_VIR_FICHIER;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_IdentNumDonOrdre                                        */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l identification du donneur d ordre       */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
FUNCTION F_IdentNumDonOrdre ( rec_VIR_PORTE  IN   VIR_PORTE%ROWTYPE
                            , o_erreur       OUT  VARCHAR2)
RETURN  VIR_PORTE.NumDonOrdre%TYPE

IS
  loc_journal           JOURNAL_ADM%ROWTYPE;
  loc_numdonordre       VIR_PORTE.NumDonOrdre%TYPE:=NULL;

  CURSOR C_DonneurOrdreAuto
      IS
  SELECT r.numindiv
    FROM vir_porte v
       , rib r
   WHERE v.compte_do= rec_VIR_PORTE.compte_do -- '00650910382'
     AND r.compte = v.compte_do
     AND r.guichet = rec_VIR_PORTE.guichet_do --'10921'
     AND v.NUMREMISE = rec_VIR_PORTE.numremise
     AND v.NUMPORTE = rec_VIR_PORTE.numPorte
     AND v.NUMLIGNE = rec_VIR_PORTE.numligne
    ORDER BY r.numindiv
     ;


  CURSOR C_DonneurOrdreAuto2
      IS
  SELECT DISTINCT v.numdonordre, f.datefic
    FROM VIR_PORTE v
       , VIR_FICHIER f
   WHERE v.NUMREMISE = f.numremise
     AND v.NUMPORTE  = f.numPorte
     AND v.compte_do = rec_VIR_PORTE.compte_do
     AND v.guichet_do = rec_VIR_PORTE.guichet_do
     AND v.numdonordre IS NOT NULL
     AND v.ETAT = 1
     AND v.NUMPORTE  = rec_VIR_PORTE.numPorte
     ORDER BY f.datefic
     ;

  CURSOR C_DonneurOrdreAutoCFE     -- recherche si le donneur provient d un compte de trésorerie CFE
      IS
  SELECT r.numindiv
    FROM vir_porte v
       , rib r
       , porte_param p
   where /*v.compte_do='00650910382'
     AND */r.compte = v.compte_do
   --  AND numligne = '83'
     AND p.numporte=1
     AND p.numbene=r.numindiv
     AND v.NUMREMISE = rec_VIR_PORTE.numremise
     AND v.NUMPORTE = rec_VIR_PORTE.numPorte
     AND v.NUMLIGNE = rec_VIR_PORTE.numligne
  --   AND v.ETAT = 2
     ORDER BY r.numindiv
     ;
BEGIN
  -- 1ère recherche dans VIR_PORTE et RIB
  FOR rec_DonneurOrdreAuto  IN   C_DonneurOrdreAuto  LOOP

    loc_numdonordre:= rec_DonneurOrdreAuto.numindiv;
    EXIT;

  END LOOP;

  IF NVL(loc_numdonordre,0) = 0 THEN
  --  2ème recherche dans VIR_PORTE en prenant la dernière saisie sur les 6 derniers mois
    FOR rec_DonneurOrdreAuto2  IN   C_DonneurOrdreAuto2  LOOP

      loc_numdonordre:= rec_DonneurOrdreAuto2.numdonordre;
      EXIT;
    END LOOP;
  END IF;

  RETURN loc_numdonordre;

EXCEPTION
  WHEN OTHERS THEN
  -- Annulation de la validation de l import CFE et de l'ensemble des transactions dans Arthus
    ROLLBACK;
     o_erreur:=SQLERRM;
    P_INS_journal(1, loc_journal,  SUBSTR(SQLERRM,1,132));
    RETURN 0;
END F_IdentNumDonOrdre;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_VIR_PORTE_NUMDONORDRE                               */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_VIR_PORTE_NUMDONORDRE(i_numdonordre     IN   VIR_PORTE.NUMDONORDRE%TYPE
                                    , i_numcompte       IN   VIR_PORTE.NUMCPTE%TYPE
                                    , i_numligne        IN   VIR_PORTE.NUMLIGNE%TYPE
                                    , i_numremise       IN   VIR_PORTE.NUMREMISE%TYPE
                                    , i_journal         IN OUT   JOURNAL_ADM%ROWTYPE
                                    , o_erreur          OUT  VARCHAR2)
IS

BEGIN
/*
  P_INS_journal(3, i_journal, ' P_MAJ_VIR_PORTE_NUMDONORDRE début :'||i_numligne);
  P_INS_journal(3, i_journal, ' i_numdonordre :'||i_numdonordre);
  P_INS_journal(3, i_journal, ' i_numremise :'||i_numremise);
  P_INS_journal(3, i_journal, ' i_numligne :'||i_numligne);
*/
  UPDATE VIR_PORTE
     SET NUMDONORDRE = i_numdonordre
     --  , COMPTE_DO   = i_numcompte
   WHERE NUMREMISE = i_numremise
     AND NUMLIGNE = i_numligne;
  COMMIT;
--  P_INS_journal(3, i_journal, ' P_MAJ_VIR_PORTE_NUMDONORDRE fin :'||i_numligne);
EXCEPTION
  WHEN OTHERS THEN
--  P_INS_journal(3, i_journal, ' P_MAJ_VIR_PORTE_NUMDONORDRE ROLLBACK :'||i_numligne);
    ROLLBACK;
     o_erreur:=SQLERRM;
END P_MAJ_VIR_PORTE_NUMDONORDRE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_creer_Encaissement                                      */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_creer_Encaissement ( rec_VIR_PORTE  IN    VIR_PORTE%ROWTYPE
                               , i_numdonordre  IN    VIR_PORTE.NUMDONORDRE%TYPE
                               , i_numencaismt  OUT   VIR_PORTE.NUMENCAISMT%TYPE
                               , o_erreur       OUT   VARCHAR2
                               , o_warning      OUT   VARCHAR2)
IS
  loc_ENCAISMT      ENCAISMT%ROWTYPE;
  loc_numdonordre   VIR_PORTE.NUMDONORDRE%TYPE:=0;

  CURSOR c_frag
      IS
   SELECT  MAX(NUMDONORDRE) numdonordre,  NVL(montant_ope/100 ,0) montant
     FROM VIR_PORTE
    WHERE numremise= rec_VIR_PORTE.numremise
      AND numligne =  rec_VIR_PORTE.numligne
      AND num_fragment >1
 GROUP BY montant_ope;

  p_journal         JOURNAL_ADM%ROWTYPE;
BEGIN

  p_journal.id_session := sid;
  p_journal.idligne := 1;
  p_journal.nom_traitement := 'VR18T_JBO';

  P_INS_journal(3, p_journal,' P_creer_Encaissement ');
  P_INS_journal(3, p_journal,' i_numdonordre: '||i_numdonordre);

  loc_ENCAISMT.NUMCLI:=i_numdonordre;

  SELECT SUM (NVL(montant_ope/100 ,0)) montant
    INTO loc_ENCAISMT.MONTANT_D
    FROM VIR_PORTE
   WHERE numremise= rec_VIR_PORTE.numremise
      AND numligne =  rec_VIR_PORTE.numligne;

  loc_ENCAISMT.MONTANT:=loc_ENCAISMT.MONTANT_D;


  P_init_Encaissement(rec_VIR_PORTE, loc_ENCAISMT, o_erreur);
  P_INS_journal(3, p_journal,' loc_ENCAISMT.numencaismt;: '||loc_ENCAISMT.numencaismt);

  IF TRIM(o_erreur) IS NULL THEN
    P_Ins_encaismt(loc_ENCAISMT, o_erreur);
    IF TRIM(o_erreur) IS NULL THEN


  SELECT SUM (NVL(montant_ope/100 ,0)) montant
    INTO loc_ENCAISMT.MONTANT_D
    FROM VIR_PORTE
   WHERE numremise= rec_VIR_PORTE.numremise
      AND numligne =  rec_VIR_PORTE.numligne
      AND num_fragment=rec_VIR_PORTE.num_fragment;

  loc_ENCAISMT.MONTANT:=loc_ENCAISMT.MONTANT_D;

      P_Ins_compte_client(loc_ENCAISMT, o_erreur);

      i_numencaismt:=loc_ENCAISMT.numencaismt;

      IF TRIM(o_erreur) IS NULL THEN
        P_CTRL_fournisseur(loc_ENCAISMT.numcli, o_warning);
      END IF;
    END IF;

  END IF;

  P_INS_journal(3, p_journal,' FOR rec_frag  IN  c_frag    LOOP ');
  -- Insertion d'une nouvelle ligne dans COMPTE_CLIENT si le donneur d'ordre est différent sur 1 meme encaissment suite à une fragementation
/*  SELECT DISTINCT NVL(MAX(NUMDONORDRE) ,0)
    INTO loc_numdonordre
    FROM vir_porte
   where numencaismt =  i_numencaismt
     AND NUMDONORDRE <> i_numdonordre
     AND NUMREMISE = rec_VIR_PORTE.numremise
     AND NUMLIGNE = rec_VIR_PORTE.numligne
     ;
  P_INS_journal(3, p_journal,' loc_numdonordre: '||loc_numdonordre);

  SELECT DISTINCT NVL(MAX(montant_ope/100) ,0)
    INTO loc_ENCAISMT.MONTANT
    FROM vir_porte
   where numencaismt =  i_numencaismt
     AND NUMDONORDRE <> i_numdonordre
     AND NUMREMISE = rec_VIR_PORTE.numremise
     AND NUMLIGNE = rec_VIR_PORTE.numligne
     ;
*/
  FOR rec_frag  IN  c_frag    LOOP
    P_INS_journal(3, p_journal,' P_Ins_compte_client loc_numdonordre: '||rec_frag.numdonordre);
    IF NVL(rec_frag.numdonordre,0) > 0 THEN

      loc_ENCAISMT.NUMCLI:=rec_frag.numdonordre;
      loc_ENCAISMT.MONTANT_D:=rec_frag.MONTANT;
    --  P_init_Encaissement(rec_VIR_PORTE, loc_ENCAISMT, o_erreur);
    --  IF TRIM(o_erreur) IS NULL THEN
     --   P_Ins_encaismt(loc_ENCAISMT, o_erreur);
     --   IF TRIM(o_erreur) IS NULL THEN

       P_INS_journal(3, p_journal,' P_Ins_compte_client rec_frag.MONTANT: '||rec_frag.MONTANT);
          P_Ins_compte_client(loc_ENCAISMT, o_erreur);
   --    P_INS_journal(3, p_journal,' P_Ins_compte_client o_erreur: '||o_erreur);
      --    i_numencaismt:=loc_ENCAISMT.numencaismt;

          IF TRIM(o_erreur) IS NULL THEN
            P_CTRL_fournisseur(loc_numdonordre, o_warning);
          END IF;
       -- END IF;

    --  END IF;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
     o_erreur:=SQLERRM;
END P_creer_Encaissement;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_init_Encaissement                                       */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_init_Encaissement ( rec_VIR_PORTE  IN         VIR_PORTE%ROWTYPE
                              , i_ENCAISMT     IN OUT     ENCAISMT%ROWTYPE
                              , o_erreur          OUT     VARCHAR2)
IS
  p_journal         JOURNAL_ADM%ROWTYPE;
BEGIN
  P_INS_journal(3, p_journal,' P_init_Encaissement ');
  BEGIN
    SELECT codope INTO i_ENCAISMT.CODOPE FROM VIR_PORTE where numremise = rec_VIR_PORTE.numremise and numligne = rec_VIR_PORTE.numligne;
  EXCEPTION
    WHEN OTHERS THEN
      i_ENCAISMT.CODOPE:=4;
  END;
  SELECT numencaismt.nextval
  INTO  i_ENCAISMT.NUMENCAISMT
  FROM DUAL;
  P_INS_journal(3,p_journal, ' i_ENCAISMT.NUMENCAISMT :'||i_ENCAISMT.NUMENCAISMT);
 -- i_ENCAISMT.NUMCLI:= rec_VIR_PORTE.NUMDONORDRE;
  i_ENCAISMT.ROLE:=NULL;

  /*SELECT DISTINCT NVL(MAX(NUMCPTE),0)
    INTO i_ENCAISMT.NUMCPTE
    FROM VIR_FICHIER
   WHERE NUMREMISE = rec_VIR_PORTE.NUMREMISE
     AND NUMPORTE = rec_VIR_PORTE.NUMPORTE;
  P_INS_journal(3, p_journal,' i_ENCAISMT.NUMCPTE :'||i_ENCAISMT.NUMCPTE);*/
  i_ENCAISMT.NUMCHQ:=NULL;
  i_ENCAISMT.MODPMT:=5;
  i_ENCAISMT.NUMCPTE :=rec_VIR_PORTE.NUMCPTE;
  IF NVL(i_ENCAISMT.MONTANT,0) = 0 THEN
    i_ENCAISMT.MONTANT:=rec_VIR_PORTE.MONTANT_OPE*0.01;
    i_ENCAISMT.MONTANT_D:=rec_VIR_PORTE.MONTANT_OPE*0.01;
  END IF;
  i_ENCAISMT.MONNAIE:=pk_devise.devise_ref;
  i_ENCAISMT.REFPMT:=NULL;
  i_ENCAISMT.DATPAY:=rec_VIR_PORTE.DATRAIT;

  BEGIN
    SELECT DISTINCT DATE_REGLEMENT         -- M5726/JBO/14/11/2018
      INTO i_ENCAISMT.DATPAY
     FROM V_VIR_PORTE WHERE numremise = rec_VIR_PORTE.numremise
      AND numligne = rec_VIR_PORTE.numligne;
  EXCEPTION
    WHEN OTHERS THEN
      i_ENCAISMT.DATPAY:=SYSDATE;
  END;

  i_ENCAISMT.DEBIT:=NULL;
  i_ENCAISMT.DATCOMP:=NULL;
  i_ENCAISMT.DATCOMPTA:=NULL;
  i_ENCAISMT.NUMUTIL:=g_numutil;
  i_ENCAISMT.IDCOMPTA:=-1;
  i_ENCAISMT.DEBIT_D:=NULL;
  i_ENCAISMT.MONNAIE_D:=pk_devise.devise_ref;
  i_ENCAISMT.ID_CREDIT:=NULL;
  i_ENCAISMT.DATE_CREDIT:=NULL;
  i_ENCAISMT.CREATION:= SYSDATE;
  i_ENCAISMT.CREATEUR:=g_numutil;
  i_ENCAISMT.MODIFICATION:=NULL;
  i_ENCAISMT.MODIFICATEUR:=NULL;
  i_ENCAISMT.VALIDATION:=NULL;
  i_ENCAISMT.VALIDATEUR:=NULL;
    P_INS_journal(3, p_journal,' FIN P_init_Encaissement ');
EXCEPTION
  WHEN OTHERS THEN
    o_erreur:='Initialisation impossible de l encaissement';
    ROLLBACK;
     o_erreur:=SQLERRM;
END P_init_Encaissement;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Ins_encaismt                                            */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_Ins_encaismt( i_ENCAISMT    IN         ENCAISMT%ROWTYPE
                        , o_erreur          OUT     VARCHAR2)
IS

BEGIN

  INSERT INTO ENCAISMT VALUES i_ENCAISMT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
     o_erreur:=SQLERRM;
END P_Ins_encaismt;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Ins_encaismt                                            */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_Ins_compte_client( i_ENCAISMT    IN         ENCAISMT%ROWTYPE
                             , o_erreur          OUT     VARCHAR2)
IS

  loc_idaffec     COMPTE_CLIENT.IDAFFEC%TYPE;

BEGIN
  IF ( NVL(i_ENCAISMT.montant, 0) != 0 ) THEN
     BEGIN
       SELECT idaffec.nextval
         INTO loc_idaffec
         FROM  DUAL;

       INSERT INTO COMPTE_CLIENT
                ( idaffec, codope, numcli, numencaismt,    montant, monnaie
                , montant_d, monnaie_d, datope, idcompta)
         VALUES ( loc_idaffec, 8, i_ENCAISMT.numcli, i_ENCAISMT.numencaismt, i_ENCAISMT.montant, i_ENCAISMT.monnaie
                , i_ENCAISMT.montant_d,i_ENCAISMT.monnaie_d, i_ENCAISMT.DATPAY, -1 );

     EXCEPTION
       WHEN OTHERS THEN
         o_erreur:=SQLERRM;
     END;
  END IF;
END;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CTRL_fournisseur                                        */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CTRL_fournisseur( i_numcli    IN         ENCAISMT.NUMCLI%TYPE
                            , o_erreur          OUT  VARCHAR2)
IS
  loc_flag     NUMBER:=0;
BEGIN

  SELECT 1
    INTO loc_flag
    FROM DUAL
   WHERE NOT EXISTS (
     SELECT 1
       FROM v_fournisseur
      WHERE v_fournisseur.numindiv = i_numcli);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    o_erreur:='Cet encaissement ne devrait il pas être saisi en encaissement fournisseur ?';
  WHEN OTHERS THEN
     o_erreur:=SQLERRM;
END P_CTRL_fournisseur;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_ETAT_VIR_PORTE                                      */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_VIR_PORTE_NUMENCAISMT( rec_VIR_PORTE  IN         VIR_PORTE%ROWTYPE
                                     , loc_encaismt   IN         VIR_PORTE.NUMENCAISMT%TYPE
                                     , o_erreur       OUT        VARCHAR2)
IS

BEGIN

  UPDATE VIR_PORTE
     SET NUMENCAISMT = loc_encaismt
       , VALIDE = 'O'
       , USER_VALIDE = g_numutil
       , DAT_VALIDE = SYSDATE
   WHERE NUMREMISE = rec_VIR_PORTE.numremise
     AND NUMLIGNE  = rec_VIR_PORTE.numligne
     AND NUMPORTE  = rec_VIR_PORTE.numporte;

EXCEPTION
  WHEN OTHERS THEN
    o_erreur:='Impossible de mettre à jour l encaissement externe de la ligne '||rec_VIR_PORTE.numligne ||'-'||SQLERRM;
END P_MAJ_VIR_PORTE_NUMENCAISMT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_ETAT_VIR_PORTE                                      */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_ETAT_VIR_PORTE( rec_VIR_PORTE  IN         VIR_PORTE%ROWTYPE
                              , loc_etat       IN         VIR_PORTE.ETAT%TYPE
                              , o_erreur       OUT        VARCHAR2)
IS

BEGIN

  UPDATE VIR_PORTE
     SET ETAT = loc_etat
   WHERE NUMREMISE = rec_VIR_PORTE.numremise
     AND NUMLIGNE  = rec_VIR_PORTE.numligne
     AND NUMPORTE  = rec_VIR_PORTE.numporte;

EXCEPTION
  WHEN OTHERS THEN
    o_erreur:='Impossible de mettre à jour l état de la ligne '||rec_VIR_PORTE.numligne ||'-'||SQLERRM;
END P_MAJ_ETAT_VIR_PORTE;

/*---------------------------------------------------------------------------       */
/* PROCEDURE                                                                        */
/* Nom          :  P_FRAGMENT                                                       */
/* Type         :  PUBLIC                                                           */
/* Description  :  Permet de fragmenter un virement en deux virement                */
/* Entree       :                                                                   */
/*              :  i_numfragment : numéro du fragement de virement a découper       */
/*              :  i_montant1 : montant du fragment 1                               */
/*              :  i_montant2 : montant du fragment 2                               */
/* Retour       :  o_numfragment : Numéro du fragment généré                        */
/*                     valeur 2317: -1 = les nouveaux montants ne sont pas corrects */
/*                     valeur 2318: -2 = Le fragement est deja validé               */
/*                     valeur 2319: -3 = Le fragment est lié a un encaissement      */
/*                     valeur 2320: -4 = Le fragement est exclu                     */
/*---------------------------------------------------------------------------       */
PROCEDURE P_FRAGMENT(i_numremise IN vir_fichier.numremise%type
                    ,i_id_cpt IN vir_porte.id_cpt%type
                    ,i_numligne IN vir_porte.numligne%type
                    ,i_numfragment IN vir_porte.num_fragment%type
                    ,i_montant1 IN NUMBER
                    ,i_montant2 IN NUMBER
                    ,o_numfragment OUT vir_porte.num_fragment%type)
AS
l_new_num_frag number(3);
l_frag_exclu number(1);
l_new_frag vir_porte%ROWTYPE;
loc_journal journal_adm%rowtype;
BEGIN

  loc_journal.id_session := 1;
  loc_journal.idligne := 1;
  loc_journal.nom_traitement := 'VR16T';

  -- Récuperation du virement a fragmenter pour le dupliquer ensuite
  SELECT * INTO l_new_frag
    FROM vir_porte
    WHERE numremise = i_numremise
    AND   id_cpt = i_id_cpt
    AND   numligne = i_numligne
    AND   num_fragment = i_numfragment
   ;


-- VERIFICATIONS SUR LE MONTANT
 -- Il faut que la somme des deux nouveaux montants soit égale au montant du fragment a découper pur continuer

 IF i_montant1 + i_montant2 <> to_number(l_new_frag.montant_ope)/100 THEN
     o_numfragment:= -1;
     dbms_output.put_line('Fragmentation impossible de la ligne : montants incorrects ['|| i_montant1||' + '||i_montant2 ||' <> '|| to_number(l_new_frag.montant_ope)/100 ||']');
    P_INS_journal(3, loc_journal,'Fragmentation impossible de la ligne : montants incorrects ['|| i_montant1||' + '||i_montant2 ||' <> '|| to_number(l_new_frag.montant_ope)/100 ||']');
    RETURN;
 END IF;
  --Le fragment ne dois pas être validé
 IF nvl(l_new_frag.valide,'N') ='O' THEN
    o_numfragment:= -2;
    P_INS_journal(3, loc_journal,'Fragmentation impossible de la ligne : Le fragement est validé' );
    RETURN;
  END IF;
 --Le fragment ne doit pas être lié a un encaissement ARTHUS
 IF l_new_frag.numencaismt IS NOT NULL THEN
    o_numfragment:= -3;
    P_INS_journal(3, loc_journal,'Fragmentation impossible de la ligne : Le virement est lié a un encaissement' );
    RETURN;
 END IF;

 -- Verifie si le fragment n'est pas exclu
 BEGIN
 SELECT 1 into l_frag_exclu FROM VIR_PORTE_EXCLU
              WHERE numremise = i_numremise
                AND   id_cpt = i_id_cpt
                AND   numligne = i_numligne
                AND   num_fragment = i_numfragment ;

    o_numfragment :=-4; -- le fragement est déjà exclu

    return ;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    null; -- Si on ne trouve pas d'exclusion on continue.
 END;

-- récupération du numéro de fragment max
    SELECT MAX(num_fragment)+1 INTO l_new_num_frag
    FROM vir_porte
    WHERE numremise = i_numremise
    AND   numligne = i_numligne
    AND   id_cpt = i_id_cpt;

    -- UPDATE du premier
    update vir_porte SET montant_ope = to_char(i_montant1*100)
    where numremise = i_numremise
    AND   id_cpt = i_id_cpt
    AND   numligne = i_numligne
    AND   num_fragment = i_numfragment;

    l_new_frag.num_fragment :=l_new_num_frag;
    l_new_frag.montant_ope := to_char(i_montant2*100);
    -- INSERTION DU NOUVEAU FRAGEMENT
    INSERT INTO VIR_PORTE VALUES l_new_frag;
    o_numfragment := l_new_num_frag;


   COMMIT;
EXCEPTION
WHEN NO_DATA_FOUND THEN -- si le fragement est introuvable
  o_numfragment:= 0;
  ROLLBACK;
END P_FRAGMENT;


/*---------------------------------------------------------------------------       */
/* PROCEDURE                                                                        */
/* Nom          :  P_ANNUL_FRAGMENT                                                 */
/* Type         :  PUBLIC                                                           */
/* Description  :  Permet d'annuler toute la fragmentation d'un virement            */
/*                                                                                  */
/* Entree       :                                                                   */
/*              :  i_numfragment : numéro du fragement de virement a découper       */
/*              :  i_montant1 : montant du fragment 1                               */
/*              :  i_montant2 : montant du fragment 2                               */
/* Retour       :  o_erreur : code erreur                        */
/*---------------------------------------------------------------------------       */
PROCEDURE P_ANNUL_FRAGMENT(i_numremise IN vir_fichier.numremise%type
                          ,i_id_cpt IN vir_porte.id_cpt%type
                          ,i_numligne IN vir_porte.numligne%type
                          ,o_erreur OUT NUMBER)
AS
l_frag_incompatible number(1);
loc_journal journal_adm%rowtype;
BEGIN

  loc_journal.id_session := 1;
  loc_journal.idligne := 1;
  loc_journal.nom_traitement := 'VR16T';

  BEGIN
   -- Vérification de l'inxistance d'un fragment incomptabile avec le regroupement de tout les fragments de virement externe
    SELECT DISTINCT 1
    INTO l_frag_incompatible
    FROM vir_porte
    WHERE numremise = i_numremise
      AND   id_cpt = i_id_cpt
      AND   numligne = i_numligne
      AND
      (     NUMENCAISMT IS NOT null
        OR  NVL(VALIDE,'N') ='O'
        OR  EXISTS (  -- un fragement ne peut pas être rassemblé si un des fragments est exclu.
                      SELECT 1 FROM VIR_PORTE_EXCLU
                      WHERE numremise = i_numremise
                        AND   id_cpt = i_id_cpt
                        AND   numligne = i_numligne
                 )
      )
     ;
   IF l_frag_incompatible = 1 THEN
     o_erreur := 2324; -- Annulation de fragmentation impossible si un fragment validé, exclu ou lié à un encaissement
     RETURN;
   END IF;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
  END;

    -- UPDATE du premier fragment, remise au montant initial
    update vir_porte SET montant_ope = montant_INIT
    WHERE numremise = i_numremise
    AND   id_cpt = i_id_cpt
    AND   numligne = i_numligne
    AND   num_fragment = 1;

    DELETE vir_porte
    WHERE numremise = i_numremise
    AND   id_cpt = i_id_cpt
    AND   numligne = i_numligne
    AND   num_fragment > 1;  -- suppression des autres virements


   COMMIT;
END P_ANNUL_FRAGMENT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EXCLURE                                                 */
/* Type         :  PUBLIC                                                    */
/* Description  :  Permet d'exclure un fragement de virement                 */
/* Entree       :  i_numremise : Numéro de la remise                         */
/*              :  i_id_cpt : identifiant du fichier logique de la remise */
/*              :  i_numligne : Numéro de ligne du virement                  */
/*              :  i_numfragment : numéro du fragement de virement a EXCLURE */
/* Retour       :  o_erreur : Message d'erreur                               */
/*                   valeur     : -2 = Le fragement est deja validé          */
/*                   valeur     : -3 = Le fragement est lié a un encaissement*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_EXCLURE( i_numremise IN vir_fichier.numremise%type
                    ,i_id_cpt IN vir_porte.id_cpt%type
                    ,i_numligne IN vir_porte.numligne%type
                    ,i_numfragment IN vir_porte.num_fragment%type
                    ,i_motif        IN NUMBER
                    ,o_erreur OUT number) AS
l_frag_to_exclu vir_porte%ROWTYPE;
l_frag_exclu VIR_PORTE_EXCLU%ROWTYPE :=null;
loc_journal journal_adm%rowtype;
BEGIN
  -- Récuperation du virement a fragmenter pour le dupliquer ensuite
  select   vir_porte.* INTO l_frag_to_exclu from vir_porte
    WHERE numremise = i_numremise
    AND   id_cpt = i_id_cpt
    AND   numligne = i_numligne
    AND   num_fragment = i_numfragment
    AND NOT EXISTS (  -- un fragement ne peut pas être exclu deux fois.
              SELECT 1 FROM VIR_PORTE_EXCLU
              WHERE numremise = i_numremise
                AND   id_cpt = i_id_cpt
                AND   numligne = i_numligne
                AND   num_fragment = i_numfragment );

  l_frag_exclu.NUMREMISE   := l_frag_to_exclu.NUMREMISE   ;
  l_frag_exclu.NUMPORTE    := l_frag_to_exclu.NUMPORTE    ;
  l_frag_exclu.NUMLIGNE    := l_frag_to_exclu.NUMLIGNE    ;
  l_frag_exclu.NUMDONORDRE := l_frag_to_exclu.NUMDONORDRE ;
  l_frag_exclu.NUMENCAISMT := l_frag_to_exclu.NUMENCAISMT ;
  l_frag_exclu.NUM_FRAGMENT:= l_frag_to_exclu.NUM_FRAGMENT;
  l_frag_exclu.ID_CPT      := l_frag_to_exclu.ID_CPT      ;
  l_frag_exclu.USERNAME    := l_frag_to_exclu.USERNAME    ;
  l_frag_exclu.CODERECORD  := l_frag_to_exclu.CODERECORD  ;
  l_frag_exclu.NUMSEQUENCE := l_frag_to_exclu.NUMSEQUENCE ;
  l_frag_exclu.MONTANT_OPE := l_frag_to_exclu.MONTANT_OPE ;
  l_frag_exclu.MONTANT_INIT:= l_frag_to_exclu.MONTANT_INIT;
  l_frag_exclu.DATE_EXCLU  := sysdate ;
  l_frag_exclu.MOTIF_EXCLU := i_motif ;
  l_frag_exclu.USER_EXCLU  := f_numutil ;


-- VERIFICATIONS
  --Le fragment ne dois pas être validé
 IF nvl(l_frag_to_exclu.valide,'N') ='O' THEN
    o_erreur:= 2315; -- Un fragment validé ne peut pas être exclu
    P_INS_journal(3, loc_journal,'Exclusion impossible de la ligne : Le fragement est validé' );
    RETURN;
  END IF;
 --Le fragment ne doit pas être lié a un encaissement ARTHUS
 IF l_frag_to_exclu.numencaismt IS NOT NULL THEN
    o_erreur:= 2316; -- Un fragment lié a un encaissement ne peut pas être exclu
    P_INS_journal(3, loc_journal,'Exclusion impossible de la ligne : Le virement est lié a un encaissement' );
    RETURN;
 END IF;
    INSERT INTO VIR_PORTE_EXCLU VALUES l_frag_exclu;

    COMMIT;

    EXCEPTION WHEN NO_DATA_FOUND THEN
    o_erreur := 2321; -- Le fragment est déjà exclu.
END P_EXCLURE;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNUL_EXCLURE                                           */
/* Type         :  PUBLIC                                                    */
/* Description  :  Annule l'exclusion d'un fragement                         */
/* Entree       :  i_numremise : Numéro de la remise                         */
/*              :  i_id_cpt : identifiant du fichier logique de la remise */
/*              :  i_numligne : Numéro de ligne du virement                  */
/*              :  i_numfragment : numéro du fragement de virement a EXCLURE */
/* Retour       :  o_erreur : Message d'erreur                               */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_EXCLURE( i_numremise      IN vir_fichier.numremise%type
                          ,i_id_cpt      IN vir_porte.id_cpt%type
                          ,i_numligne       IN vir_porte.numligne%type
                          ,i_numfragment    IN vir_porte.num_fragment%type
                          ,o_erreur         OUT number)
AS

BEGIN
  DELETE VIR_PORTE_EXCLU
   WHERE numremise = i_numremise
      AND   id_cpt = i_id_cpt
      AND   numligne = i_numligne
      AND   num_fragment = i_numfragment;

END P_ANNUL_EXCLURE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_VIR_FICHIER                                         */
/* Type         :  Public                                                    */
/* Description  :  fonction d'insertion dans VIR_FICHIER                     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_VIR_FICHIER(P_VIR_FICHIER      VIR_FICHIER%ROWTYPE ,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN

  INSERT INTO VIR_FICHIER VALUES P_VIR_FICHIER ;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible fichier  :' || P_VIR_FICHIER.FICHIER ||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_VIR_FICHIER;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FIND_PORTE_NUMUTIL                                      */
/* Type         :  Public                                                    */
/* Description  :  fonction de recherche du numéro utilisateur a partir de la*/
/*                 porte passé en parametre                                  */
/* Retour       :  loc_numutil, Utilisateur de la porte                      */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_PORTE_NUMUTIL( P_porte          IN    LIBELLE.CODE%TYPE)
RETURN NUMBER
IS
  loc_numutil PORTE_PARAM.NUMUTIL%TYPE;
BEGIN

  SELECT pp.numutil
    INTO loc_numutil
    FROM LIBELLE l
       , PORTE_PARAM pp
    WHERE l.mnemo='PORTE'
      AND l.code=pp.numporte
      AND pp.numporte=P_porte;

  RETURN loc_numutil;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0 ;
END F_FIND_PORTE_NUMUTIL;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_INS_PORTE_REMISE                                        */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans PORTE_REMISE                   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_PORTE_REMISE(P_porte_remise      PORTE_REMISE%ROWTYPE)
RETURN BOOLEAN
IS
       p_journal   journal_adm%rowtype;
BEGIN
  INSERT INTO PORTE_REMISE VALUES P_porte_remise;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
 P_INS_journal(1, p_journal,'F_INS_PORTE_REMISE , Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_PORTE_REMISE;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_NUMBER_VARCHAR                                     */
/* Type         :  Public                                                    */
/* Description  :  Fonction qui verifie si chaine est un nombre  et retourne */
/*                 un varchar                                                */
/*                                                                           */
/* Retour       :   0 si erreur ; va                             */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_NUMBER_VARCHAR_AFF(
      i_chaine IN VARCHAR2, -- ex = i_chaine = S21.G00.06.001,'999100019'
      i_ligne  IN NUMBER,
      I_entite    IN PORTE_ENTITE%ROWTYPE,
      p_journal IN OUT JOURNAL_ADM%ROWTYPE,
      I_cptligne_fichier IN NUMBER
   )   RETURN VARCHAR2 IS
   v_chaine VARCHAR2(500);
 --  nb       NUMBER;
   erreur VARCHAR2(50);
BEGIN
   --si la chaine est trop longue, on le remonte mais ce n'est pas bloquant pour l'intégration
   IF length(TRIM(i_chaine)) > I_entite.taille THEN
     P_INS_journal(1,p_journal,
               'Attention Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur, chaine trop longue. Réelle '||length(TRIM(i_chaine)) ||' attendue : ' || I_entite.taille );
   END IF;
   v_chaine := substr(TRIM(i_chaine),0,I_entite.taille);
   -- On essaie de caster la chaine. Si on peut, on renvoie un to_char de la chaine.
   --                                Sinon, on part en exception et on renvoie 0
   --nb := to_number(v_chaine);
  IF I_entite.donnee like '%MAIL%' THEN
    RETURN TO_CHAR(replace(v_chaine,'''',''''''));
  ELSE
    RETURN TO_CHAR(UPPER(replace(v_chaine,'''','''''')));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF NVL(i_ligne,0) =0 THEN
      erreur:='';
     ELSE erreur:='Ligne virement n°'||(NVL(i_ligne,0)+1);
     END IF;
     P_INS_journal(1,p_journal,
                   'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur,'||erreur ||' Donnee : ' || I_entite.donnee || ' chaine : ' || v_chaine);

    RETURN TO_CHAR(0);
END F_CTRL_NUMBER_VARCHAR_AFF;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNUL_encais                                            */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_encais(i_numencaismt   IN      ENCAISMT.NUMENCAISMT%TYPE
                       , i_motif         IN      ANNUL_ENCAIS.MOTIF%TYPE
                       , o_erreur        OUT     VARCHAR2
                       , i_annul_encsmt_actif IN VARCHAR2 DEFAULT 'N')
IS

  L_code_msg      NUMBER(5);
  exc_flag_annul  EXCEPTION;
  exc_annul_ko    EXCEPTION;

BEGIN
    P_ANNUL_encaismt(i_numencaismt,i_motif, o_erreur, i_annul_encsmt_actif);
    COMMIT;
EXCEPTION
  WHEN exc_annul_ko THEN
    o_erreur:='Impossible d annuler l encaissement, erreur :'||SQLERRM;
  WHEN exc_flag_annul THEN
    o_erreur:=L_code_msg;
  WHEN OTHERS THEN
    o_erreur:=SQLERRM;
END P_ANNUL_encais;

/*---------------------------------------------------------------------------------*/
/* PROCEDURE                                                                       */
/* Nom          :  P_ANNUL_encaismt                                                */
/* Type         :  Public                                                          */
/* Description  :   annulation d'encaissement sans commit afin de pouvoir appeler  */
/*cette procédure dans le traitement des rejets de prélèvement                     */
/* Entree       :                                                                  */
/* Retour       :  o_erreur, Message d erreur en cas d echec                       */
/*---------------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_encaismt(i_numencais   IN      ENCAISMT.NUMENCAISMT%TYPE
                          , i_motif_annul         IN      ANNUL_ENCAIS.MOTIF%TYPE
                          , o_erreur        OUT     VARCHAR2
                          , i_annul_encaismt_actif IN VARCHAR2 DEFAULT 'N')
IS

  L_code_msg      NUMBER(5);
  L_flag_annul    NUMBER;
  C_cptcli        COMPTE_CLIENT%ROWTYPE;
  C_affec         QTTC_AFFEC%ROWTYPE;
  exc_flag_annul  EXCEPTION;
  exc_annul_ko    EXCEPTION;
  loc_encaismt    ENCAISMT%ROWTYPE;

BEGIN

  SELECT e.*
    INTO loc_encaismt
    FROM ENCAISMT e
   WHERE e.numencaismt = i_numencais;


  IF i_motif_annul IS NOT NULL THEN   -- Annulation de l'encaissement

    P_ANNULATION_NUMENCAISMT(loc_encaismt,i_motif_annul,o_erreur, i_annul_encaismt_actif);
  END IF;
    UPDATE VIR_PORTE SET NUMENCAISMT = NULL, ETAT = 2 , VALIDE = 'N', USER_VALIDE = NULL, DAT_VALIDE = NULL
     WHERE NUMENCAISMT = i_numencais;
END P_ANNUL_encaismt;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNULATION_NUMENCAISMT                                  */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNULATION_NUMENCAISMT( i_encaismt          IN    ENCAISMT%ROWTYPE
                                  , i_motif             IN    ANNUL_ENCAIS.MOTIF%TYPE
                                  , o_erreur            OUT   VARCHAR2
                                  , i_annul_encais_actif IN VARCHAR2 DEFAULT 'N')
IS

BEGIN
  p_rejet_mandat(i_encaismt,i_motif,o_erreur);

  --activation de l'insertion dans annul_encais dans le cadre d'un annul d'encaissement de rejet de prelev
  IF i_annul_encais_actif ='O' THEN
    BEGIN
      P_Insert_Annul_ENCAIS(i_encaismt,i_motif,o_erreur);

    EXCEPTION
      WHEN OTHERS THEN
        o_erreur:='P_Insert_Annul_ENCAIS';
    END;
  END IF;

  -- Annulation des écritures en compte d'attente
  BEGIN
    P_ANNUL_attente(i_encaismt,o_erreur);

  EXCEPTION
    WHEN OTHERS THEN
      o_erreur:='P_ANNUL_Attente';
  END;

  -- Compensation du montant compte tiers non affecté
  BEGIN

    P_ANNUL_compte_tiers2(i_encaismt,o_erreur);

  EXCEPTION
    WHEN OTHERS THEN
      o_erreur:='P_ANNUL_Compte_Tiers';
  END;
  -- Annulation des écritures d'affectation
  BEGIN

    P_ANNUL_affectations(i_encaismt,o_erreur);

  EXCEPTION
    WHEN OTHERS THEN
      o_erreur:='P_ANNUL_Affectations';
  END;
EXCEPTION
  WHEN OTHERS THEN
    o_erreur:=SQLERRM;
END P_ANNULATION_NUMENCAISMT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_rejet_mandat                                            */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE p_rejet_mandat ( i_encaismt       IN    ENCAISMT%ROWTYPE
                         , i_motif          IN    ANNUL_ENCAIS.MOTIF%TYPE
                         , o_erreur         OUT   VARCHAR2)
IS

  LOC_TYPESEPA               REMISE_PRELEV.TYPESEPA%TYPE;
  LOC_mandat                 prelevement.mandat%TYPE;
  LOC_IDHISTOMANDAT          prelevement.IDHISTOMANDAT%TYPE;
  LOC_NUMREMISE_PREC         prelevement.NUMREMISE_PREC%TYPE;
  LOC_MVT                    prelevement.MVT%TYPE;
  LOC_MAJ                    prelevement.MAJ%TYPE;
  LOC_IDHISTOMANDAT_UPDT     histo_mandat.IDHISTOMANDAT%TYPE;
  LOC_NUMREMISE              histo_mandat.NUMREMISE%TYPE;
  loc_rejet                  libelle.sens%TYPE;
  -- Annulation des modifications du mandat lors du rejet
BEGIN
  BEGIN
    SELECT REMISE_PRELEV.TYPESEPA, REMISE_PRELEV.NUMREMISE
    INTO LOC_TYPESEPA, LOC_NUMREMISE
    FROM REMISE_PRELEV ,PRELEVEMENT
    WHERE  REMISE_PRELEV.NUMREMISE = PRELEVEMENT.NUMREMISE
    AND PRELEVEMENT.NUMENCAISMT = i_encaismt.numencaismt
    AND PRELEVEMENT.NUMPRELEV = i_encaismt.refpmt;
  EXCEPTION
    WHEN OTHERS THEN LOC_TYPESEPA:=0;
  END;
  IF LOC_TYPESEPA in(1,2) THEN --RKO 28/01/2020 SEPA B2B Prise en compte du typage b2b
    SELECT NVL(SENS ,0)
      INTO loc_rejet
      FROM libelle
     WHERE code = i_motif
       AND mnemo='PREVANN';

    IF loc_rejet =0 THEN
      SELECT prelevement.mandat ,
             prelevement.IDHISTOMANDAT ,
             prelevement.NUMREMISE_PREC ,
             prelevement.MVT ,
             prelevement.MAJ ,
             histo_mandat.IDHISTOMANDAT AS IDHISTOMANDAT_UPDT
        INTO LOC_mandat,
             LOC_IDHISTOMANDAT,
             LOC_NUMREMISE_PREC,
             LOC_MVT,
             LOC_MAJ,
             LOC_IDHISTOMANDAT_UPDT
        FROM prelevement, histo_mandat
       WHERE prelevement.mandat = histo_mandat.mandat
         AND prelevement.numencaismt = i_encaismt.numencaismt
         AND prelevement.numprelev = i_encaismt.refpmt
         AND histo_mandat.numremise = LOC_NUMREMISE;

      PK_DEV_PV03B.P_ANNUL_CONSTIT_MANDAT(LOC_NUMREMISE_PREC,
                                          LOC_IDHISTOMANDAT,
                                          LOC_IDHISTOMANDAT_UPDT,
                                          LOC_MVT,
                                          LOC_MAJ
                                          );
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN NULL;
  o_erreur:=SQLERRM;
END p_rejet_mandat;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNUL_attente                                           */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_attente( i_encaismt       IN    ENCAISMT%ROWTYPE
                         , o_erreur         OUT   VARCHAR2)
IS
  cptcli        COMPTE_CLIENT%ROWTYPE;
  L_idaffec     COMPTE_CLIENT.IDAFFEC%TYPE;
  L_nb_cpt      NUMBER:=0;
BEGIN
  -- en cas d'annulation, si il n'existe qu'une ligne en attente d'affectation,
  -- la mettre à 0. PHA 09/11/2011
  L_nb_cpt := 0;
  SELECT COUNT(*)
    INTO L_nb_cpt
    FROM compte_client WHERE compte_client.numencaismt = i_encaismt.numencaismt;

    FOR cptcli IN
       (SELECT compte_client.montant,
                compte_client.montant_d,
               compte_client.codope,
               compte_client.numcli,
               compte_client.numencaismt,
               compte_client.monnaie,
               compte_client.monnaie_d
          FROM compte_client
         WHERE compte_client.numencaismt =i_encaismt.numencaismt
           AND compte_client.codope = 8
           AND compte_client.numfact IS NULL
       )
    LOOP
       --
      IF L_nb_cpt = 1 THEN
        UPDATE compte_client SET montant = 0, montant_d = 0
              WHERE numencaismt = i_encaismt.numencaismt
                AND codope = 8
                AND numfact IS NULL
                AND ROWNUM = 1;
      ELSE
        SELECT idaffec.nextval
          INTO L_idaffec
          FROM DUAL;


        --
        INSERT INTO COMPTE_CLIENT
            (idaffec,codope,numcli,numencaismt,
             monnaie,monnaie_d,datope,montant,montant_d,numfact,idcompta)
         Values (
                L_idaffec,
                cptcli.codope,
                cptcli.numcli,
                cptcli.numencaismt,
                cptcli.monnaie,
                cptcli.monnaie_d,
                Sysdate,
                -cptcli.montant,
                -cptcli.montant_d,
                NULL,
                -1 );
        --
        P_INS_annul_cptcli ( cptcli.numencaismt,
                             L_idaffec
                           );
         --
      END IF;
    END LOOP;
END P_ANNUL_attente;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_annul_cptcli                                        */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_annul_cptcli ( I_numencaismt IN annul_cptcli.numencaismt%TYPE,
                               I_idaffec     IN annul_cptcli.idaffec%TYPE)
IS
BEGIN
  INSERT INTO ANNUL_CPTCLI ( numencaismt, idaffec )
      Values ( I_numencaismt, I_idaffec );

END P_INS_annul_cptcli;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNUL_compte_tiers2                                     */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_compte_tiers2( i_encaismt       IN    ENCAISMT%ROWTYPE
                               , o_erreur         OUT   VARCHAR2)
IS
  L_idmvt       NUMBER:=0;
  L_solde       NUMBER:=0;
  L_solde_d     NUMBER:=0;
  cptfour       COMPTE_TIERS%ROWTYPE;
BEGIN
  FOR cptfour IN
       (SELECT compte_tiers.montant,
               compte_tiers.codope,
               compte_tiers.numcli,
               compte_tiers.montant_d,
               compte_tiers.monnaie,
               compte_tiers.monnaie_d,
               compte_tiers.idmvt
          FROM compte_tiers
         WHERE compte_tiers.cle=i_encaismt.numencaismt
           AND compte_tiers.codope=10
       )
  LOOP
    L_solde := cptfour.montant + f_contrepartie(cptfour.idmvt);
    L_solde_d := cptfour.montant_d + f_contrepartie_d(cptfour.idmvt);
    IF ( L_solde > 0 ) THEN
        --

      SELECT idmvt.nextval
        INTO L_idmvt
        FROM dual;

      --
      INSERT INTO COMPTE_TIERS
        (idmvt,numcli,codope,cle,datope,sens,montant,numutil,creation,idcompta,monnaie_d,montant_d,monnaie)
        Values (L_idmvt,cptfour.numcli,cptfour.codope,i_encaismt.numencaismt,
                trunc(sysdate),-1,L_solde,f_numutil,trunc(sysdate),-1,cptfour.monnaie_d,
                L_Solde_d, cptfour.monnaie );
        --
      INSERT INTO COMPENSATION(idmvt,idcomp)
        Values ( cptfour.idmvt, L_idmvt );
        --
    END IF;
  END LOOP;

END P_ANNUL_compte_tiers2;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNUL_affectations                                      */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_affectations( i_encaismt       IN    ENCAISMT%ROWTYPE
                              , o_erreur         OUT   VARCHAR2)
IS

  CURSOR C_affec
     IS
  SELECT compte_client.codope,
         compte_client.numfact,
         compte_client.numcli,
         compte_client.numencaismt,
         - Sum(compte_client.montant)   montant,
         - sum(compte_client.montant_d)   montant_d,
         compte_client.monnaie,
         compte_client.monnaie_d
    FROM compte_client
   WHERE compte_client.numencaismt = i_encaismt.numencaismt
  GROUP BY
         compte_client.codope,
         compte_client.numfact,
         compte_client.numcli,
         compte_client.numencaismt,
         compte_client.monnaie,
         compte_client.monnaie_d;
  --
  Rec_C_affec  C_AFFEC%ROWTYPE;
  L_idaffec    COMPTE_CLIENT.IDAFFEC%TYPE;
  loc_cot_null NUMBER;
  --
BEGIN
  OPEN C_affec;
    LOOP
      Fetch C_affec INTO Rec_C_affec;
      EXIT WHEN C_affec%NOTFOUND;
      --
        loc_cot_null:=1;

        --meme si le montant de la cotisaiton est nulle, elle peut portée des commissions
        IF Rec_C_affec.codope = 4 AND Rec_C_affec.montant = 0 THEN
          BEGIN
            SELECT -1
              INTO loc_cot_null
              FROM  qttc_global
             WHERE numquit = Rec_C_affec.numfact
               AND qttc_global.mt_ttc =0;

          EXCEPTION
            WHEN OTHERS THEN NULL;
          END;
        END IF;

         If ( Rec_C_affec.montant != 0 OR loc_cot_null <>1 ) then

        SELECT idaffec.nextval
          INTO L_idaffec
          FROM DUAL;
        --
        BEGIN
          pk_treso.P_affecte( I_idaffec     => L_idaffec,
                              I_codope      => Rec_C_affec.codope,
                              I_numfact     => Rec_C_affec.numfact,
                              I_numcli      => Rec_C_affec.numcli,
                              I_numencaismt => Rec_C_affec.numencaismt,
                              I_montant     => Rec_C_affec.montant,
                              I_montant_d   => Rec_C_affec.montant_d,
                              I_monnaie     => Rec_C_affec.monnaie,
                              I_monnaie_d   => Rec_C_affec.monnaie_d,
                              I_datope      => trunc(sysdate)
                           );
        EXCEPTION
          WHEN OTHERS THEN
            o_erreur:='PK_TRESO.P_Affecte';
        END;

        BEGIN
          IF ( Rec_C_affec.codope = 4 ) THEN
            --ajout du paramètre loc_cot_null pour influer sur le signe du ratio pour les cotisations=0
            IF f_client = 12 THEN             -- Welcare pour la gestion du commissionnement
              PK_IMPORT_VIREMENT.Qttc_ventil( Rec_C_affec.numfact ,loc_cot_null);
            ELSE
              PK_IMPORT_VIREMENT.Qttc_ventil( Rec_C_affec.numfact);
            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            o_erreur:='QTTC_Ventil, Numero Facture : '||Rec_C_Affec.Numfact ;
        END;
        --
        BEGIN
          P_INS_annul_cptcli ( I_numencaismt => Rec_C_affec.numencaismt, I_idaffec     => L_idaffec );
        EXCEPTION
          WHEN OTHERS THEN
            o_erreur:='P_INS_Annul_CptCli';
        END;
        --
      END IF;
    END LOOP;
  CLOSE C_affec;

END P_ANNUL_affectations;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Insert_Annul_ENCAIS                                     */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_Insert_Annul_ENCAIS ( i_encaismt       IN    ENCAISMT%ROWTYPE
                                , i_motif          IN    ANNUL_ENCAIS.MOTIF%TYPE
                                , o_erreur         OUT   VARCHAR2)
IS

BEGIN

  INSERT INTO ANNUL_ENCAIS(NUMENCAISMT,MOTIF,DATE_ANNUL,MONTANT_FRAIS,MODPMT
                          ,IDCOMPTA,MONNAIE,MONNAIE_D,MONTANT_FRAIS_D,DATOPE)
    VALUES (i_encaismt.NUMENCAISMT,i_motif,SYSDATE,NULL,i_encaismt.MODPMT
          , i_encaismt.IDCOMPTA, i_ENCAISMT.MONNAIE,i_ENCAISMT.MONNAIE_D,NULL,SYSDATE);

EXCEPTION
  WHEN OTHERS THEN NULL;
  o_erreur:=SQLERRM;
END P_Insert_Annul_ENCAIS;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TEST_annulation                                         */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_TEST_annulation ( i_encaismt        IN     ENCAISMT%ROWTYPE,
                              IO_flag_annul     IN OUT NUMBER,
                              IO_code_msg       IN OUT NUMBER)
IS
BEGIN
  IF ( i_encaismt.MODPMT = 1 ) THEN  -- avant : IF ( i_encaismt.numremise != 0 ) THEN
     IO_flag_annul := 1;
     IO_code_msg := 661;
  ELSIF ( i_encaismt.idcompta != -1 ) THEN
     IO_flag_annul := 1;
     IO_code_msg:= 662;
  ELSIF ( i_encaismt.modpmt = 2 ) THEN
     IO_flag_annul := 1;
     IO_code_msg:= 663;
  ELSE
    BEGIN
      SELECT 1,
             664
        INTO IO_flag_annul,
             IO_code_msg
        FROM annul_encais
       WHERE numencaismt = i_encaismt.numencaismt;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IO_flag_annul := 0;
    END;
    IF ( IO_flag_annul = 0 ) THEN
      BEGIN
        SELECT 1,
              665
         INTO IO_flag_annul,
              IO_code_msg
         FROM DUAL
        WHERE EXISTS (
              SELECT 1
                FROM qttc_affec,
                     compte_client
               WHERE qttc_affec.idrevers NOT IN(0,-1)
                 AND qttc_affec.idaffec = compte_client.idaffec
                 AND compte_client.numencaismt = i_encaismt.numencaismt
                    );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IO_flag_annul := 0;
      END;
    END IF;
    IF ( IO_flag_annul = 0 ) THEN
      BEGIN
        SELECT 1,
               666
          INTO IO_flag_annul,
               IO_code_msg
          FROM DUAL
         WHERE EXISTS (
                        SELECT 1
                          FROM rbtcptcli,
                               compte_client
                         WHERE rbtcptcli.idaffec = compte_client.idaffec
                           AND compte_client.numencaismt = i_encaismt.numencaismt
                       );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IO_flag_annul := 0;
      END;
    END IF;
  END IF;
END P_TEST_annulation;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FORMAT_NUMBER                                           */
/* Type         :  Public                                                    */
/* Description  :  format une chaine en DATE                                 */
/*                   en entrée une chaine de format AAMMJJ ou AAMMJJHH       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_FORMAT_DATE(i_chaine IN VARCHAR2) RETURN number
IS
  v_test   VARCHAR2(1);
 -- v_chaine VARCHAR2(8);
  v_longueur NUMBER;
  v_date DATE;
BEGIN
--dbms_output.put_line('dans procédure de controle date');
    BEGIN
      SELECT *
      INTO v_test
      FROM DUAL
      WHERE REGEXP_LIKE (i_chaine,'^[0-9]*$');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('NO_DATA_FOUND dans procédure de controle date '||i_chaine);
        RETURN 0;
    END;

   IF length(i_chaine) = 6 THEN
     V_DATE:= TO_DATE(i_chaine,'DDMMYY');
   ELSE
     V_DATE:= TO_DATE(i_chaine,'DDMMYYYY');
   END IF;
  return 1;
EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line('When others procédure de controle date');
    RETURN 0;
END F_CTRL_FORMAT_DATE;


/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FORMAT_NUMBER                                           */
/* Type         :  Public                                                    */
/* Description  :  format une chaine en NUMBER                               */
/*                 en entrée une chaine de format AAMMJJ ou AAMMJJHH         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_FORMAT_NUMBER(i_chaine IN VARCHAR2) RETURN number
IS
  v_test   VARCHAR2(1);
  v_chaine VARCHAR2(8);
  v_longueur NUMBER;
  v_NUMBER NUMBER;
BEGIN
  BEGIN
    SELECT *
    INTO v_test
    FROM DUAL
    WHERE REGEXP_LIKE (i_chaine,'^[0-9]*[.]?[0-9]*$');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END;

  v_NUMBER := TO_NUMBER(i_chaine);
  RETURN 1;
EXCEPTION
    WHEN OTHERS THEN RETURN 0;
END F_CTRL_FORMAT_NUMBER;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TEST_annulation                                         */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
Procedure P_ANNUL_compte_tiers( I_numencaismt IN    ENCAISMT.NUMENCAISMT%TYPE,
                                o_erreur      OUT   VARCHAR2)
IS
  C_compte_tiers      compte_tiers%Rowtype;
  C_compensation      compensation%Rowtype;
BEGIN
  FOR C_compte_tiers IN (
    SELECT idmvt
      FROM compte_tiers
     WHERE codope = 10
       AND cle = I_numencaismt )
  LOOP
    FOR C_compensation IN (
      SELECT idcomp
        FROM compensation
       WHERE idmvt = C_compte_tiers.idmvt )
    LOOP
      BEGIN
        DELETE compensation
         WHERE idmvt = C_compte_tiers.idmvt;
      EXCEPTION WHEN OTHERS THEN
        o_erreur:='Impossible d annuler la compensation, erreur :'||SQLERRM;
      END;
      BEGIN
        DELETE compte_tiers
         WHERE idmvt = C_compensation.idcomp;
      EXCEPTION WHEN OTHERS THEN
        o_erreur:='Impossible d annuler le compte tiers, erreur :'||SQLERRM;
      END;
    END LOOP;
    BEGIN
      DELETE compte_tiers
       WHERE idmvt = C_compte_tiers.idmvt;
    EXCEPTION WHEN OTHERS THEN
      o_erreur:='Impossible d annuler le compte tiers, erreur :'||SQLERRM;
    END;
  END LOOP;
END P_ANNUL_compte_tiers;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_SEND_RAPPORT_ENVOI_MAIL                                 */
/* Type         :  Privee                                                    */
/* Description  :  Insertion dans journal_adm                                */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL(i_date_session DATE, i_message VARCHAR2, i_nb_total number)
IS
  loc_envoi envoi_mail%ROWTYPE;
  l_ERROR   VARCHAR2(200);
  text  CLOB;
  list_email varchar(4000) :='';
  list_email_unit varchar(1000) :='';

  list_email_m varchar(4000) :='';
  list_email_unit_m varchar(1000) :='';
  l_nom_machine  param_machine.nom_machine%type;

  l_destinataire varchar2(60);
  loc_interloc individu.numindiv%type;
  i number :=1;
  l_s varchar2(1) :='';

  loc_journal journal_adm%rowtype;

BEGIN

  loc_journal.id_session := sid;
  loc_journal.idligne := 1;
  loc_journal.nom_traitement := 'RAPPORT_VIREMENT';

 -- IF i_nb_total > 0 THEN

    SELECT 1, 1, compte_mail
    INTO loc_envoi.NUMINDIV_DEST, loc_envoi.NUMBENE, loc_envoi.destinataire
    FROM param_machine
    WHERE id_machine= 'SERVEUR_MAIL';

    SELECT instance into l_nom_machine
    FROM parametres;


    SELECT DISTINCT NVL(MAX(interlocuteur),0)
    INTO loc_interloc
    FROM interlocuteur
    WHERE numindiv= 1 --
      AND OPE_CRRR=1  -- Cotisations
      AND valide='O'
      AND defaut='O';


    if i_nb_total > 1 THEN
      l_s :='s';
    END IF;

    loc_envoi.sujet :='[Rapport_ARTHUS] Rapport d''intégration automatique de virement du '||d2e(i_date_session) || ' sur l''instance '||l_nom_machine;
    loc_envoi.corps := i_nb_total||' Fichier'||l_s||' de virement automatiquement importé'||l_s||':'|| CHR(10)||CHR(13)||   i_message ;

    IF F_CLIENT = 4 THEN
      GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', text);
      l_destinataire:=  'cotisation@gerep.fr';
      PK_MAIL.transcode_template( template_mail=>text,
                                  corps_msg =>loc_envoi.corps,
                                  numindiv=>'',
                                  numbene=>'',
                                  sujet_msg =>loc_envoi.sujet);

      pk_mail.SEND_EMAIL(
                          P_RECIPIENT     => l_destinataire,--'testcl@cat-amania.com',--loc_envoi.destinataire ,
                          P_CC            => null,
                          P_BCC           => null, --'Support@arthus-progiciels.com',
                          P_SUBJECT       => '[Rapport_ARTHUS] Rapport d''intégration automatique de virement du '||d2e(i_date_session),
                          P_BODY          => text,
                          P_NUMUTIL       =>8,
                          P_SENDER        =>l_destinataire, --'no-reply@gerep.fr',
                          P_ERROR        => l_ERROR,
                          p_numindiv_dest => null
                          );
    ELSIF F_CLIENT = 12 THEN
      GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', text);
      l_destinataire:=  'MOADAIOM@humanis.com';
  --    text := '#SUJET'||CHR(10) || CHR(13) ||'#CORPS_MESSAGE';
      PK_MAIL.transcode_template( template_mail=>text,
                                  corps_msg =>loc_envoi.corps,
                                  numindiv=>'',
                                  numbene=>'',
                                  sujet_msg =>loc_envoi.sujet);

      pk_mail.SEND_EMAIL(
                          P_RECIPIENT     => l_destinataire,--'testcl@cat-amania.com',--loc_envoi.destinataire ,
                          P_CC            => 'souscription@welcare.fr',
                          P_BCC           => 'claimcenter@welcare.fr', --'Support@arthus-progiciels.com',
                          P_SUBJECT       => '[Rapport_ARTHUS] Rapport d''intégration automatique de virement du '||d2e(i_date_session),
                          P_BODY          =>text,
                          P_NUMUTIL       =>8,
                          P_SENDER        =>l_destinataire, --'no-reply@gerep.fr',
                          P_ERROR        => l_ERROR,
                          p_numindiv_dest => null
                          );
    END IF;



--  END IF;
   EXCEPTION
      WHEN  OTHERS THEN
      P_INS_journal(3, loc_journal, 'Envoie de mail '||SQLERRM);

END P_SEND_RAPPORT_ENVOI_MAIL;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  QTTC_VENTIL                                               */
/* Type         :  Privee                                                    */
/* Description  :  QTTC_VENTIL ==> surcharge pour la V7                      */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
procedure qttc_ventil (a_numquit in number )
is
-- Variable de reconnaissance SCCS
-- @(#)qttc_ventil.sql  1.4    00/11/20
loc_ratio  number;
loc_delta  number;
loc_ratio_d  number;
loc_delta_d  number;
loc_mt_frais  number;
loc_mt_reel  number;
loc_mt_affec  number;
loc_mt_frais_d  number;
loc_mt_reel_d  number;
loc_mt_affec_d  number;
loc_monnaie  number;
loc_monnaie_d  number;

Cursor fetch_affec is
  Select  idaffec,
      montant,
            monnaie,
            montant_d,
            monnaie_d
  From  qttc_affec
  Where  numquit = a_numquit
  And  numfor = -1;
loc_affec  fetch_affec%Rowtype;
BEGIN
For loc_affec in fetch_affec
loop
  /* On determine le ratio du reste a affecter   */

  Begin
     Select  loc_affec.montant / decode( qttc_global.mt_ttc,0,1,
          pk_funct.f_arrondi(4,
            qttc_global.numquit,
            qttc_global.mt_ttc) ),

      loc_affec.montant_d / decode( qttc_global.mt_ttc_d,0,1,
          pk_funct.f_arrondi(4,
            qttc_global.numquit,
            qttc_global.mt_ttc_d) ),
    qttc_global.mt_ttc,
                qttc_global.monnaie,
                qttc_global.mt_ttc_d,
                qttc_global.monnaie_d
  Into  loc_ratio,
            loc_ratio_d,
      loc_mt_reel,
            loc_monnaie,
            loc_mt_reel_d,
            loc_monnaie_d
  From  qttc_global
  Where  qttc_global.numquit = a_numquit
  And  qttc_global.mt_ttc is not null
        And  qttc_global.mt_ttc_d is not null;
  Exception When No_data_found then Exit;
  End;

  /* On retablit le montant a affecter par rapport au montant calcule */

   loc_mt_affec   := loc_mt_reel * loc_ratio;
   loc_mt_affec_d := loc_mt_reel_d * loc_ratio_d;

  /* On insere dans qttc_affec une ligne par garantie /assure */
  BEGIN
      Insert into qttc_affec
    (idaffec, idgar, numquit, numfor,
     numindiv, montant,monnaie,montant_d,monnaie_d,idrevers)
   ----- Revu par NS 25-07-2005 --- ---
   SELECT ALL loc_affec.idaffec,
         QTTC_GAR.IDGAR,
         a_numquit,
         QTTC_GAR.NUMFOR,
         QTTC_GAR.NUMINDIV,
         QTTC_GAR.MT_TTC*loc_ratio,
         QTTC_GAR.MONNAIE,
         QTTC_GAR.MT_TTC_D*loc_ratio_d,
         QTTC_GAR.MONNAIE_D,
         0
    FROM QTTC_GAR
    WHERE (QTTC_GAR.NUMQUIT = a_numquit
      AND QTTC_GAR.MT_TTC<>0
      AND QTTC_GAR.MT_TTC_D<>0);
  END;
   ----- Revu par NS 25-07-2005 --- ---

  /* On insere les frais dans affec_tfc */

  Begin
    BEGIN
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv,tfc, type_tfc, numbene,
                          montant,monnaie,montant_d,monnaie_d,idrevers)
        ----- Revu par NS 25-07-2005 --- --------------------
    SELECT ALL loc_affec.idaffec,
           a_numquit,
           QTTC_FRAIS.NUMFOR,
           0,
           DECODE(QTTC_FRAIS.NUMFOR, 0, 4, 3),
           QTTC_FRAIS.TYPE_FRAIS,
           QTTC_FRAIS.NUMBENE,
           SUM(QTTC_FRAIS.MONTANT)*loc_ratio,
           QTTC_FRAIS.MONNAIE,
           SUM(QTTC_FRAIS.MONTANT_D)*loc_ratio_d,
           QTTC_FRAIS.MONNAIE_D,
           0
      FROM QTTC_FRAIS
      WHERE QTTC_FRAIS.NUMQUIT = a_numquit
      GROUP BY QTTC_FRAIS.NUMFOR,
          DECODE(QTTC_FRAIS.NUMFOR, 0, 4, 3),
          QTTC_FRAIS.TYPE_FRAIS,
          QTTC_FRAIS.NUMBENE,
          QTTC_FRAIS.MONNAIE,
          QTTC_FRAIS.MONNAIE_D
      HAVING (SUM(QTTC_FRAIS.MONTANT)<>0
        AND SUM(QTTC_FRAIS.MONTANT_D)<>0) ;
    END;

    ----- Revu par NS 25-07-2005 --- --------------------

  /* On re-calcule la somme des frais affectes */
  ----- Revu par NS 25-07-2005 --- ----
    BEGIN
     SELECT ALL NVL(SUM(QTTC_AFFEC_TFC.MONTANT), 0),
            QTTC_AFFEC_TFC.MONNAIE,
            NVL(SUM(QTTC_AFFEC_TFC.MONTANT_D), 0),
            QTTC_AFFEC_TFC.MONNAIE_D
      Into  loc_mt_frais,
          loc_monnaie,
          loc_mt_frais_d,
          loc_monnaie_d
      FROM QTTC_AFFEC_TFC
      WHERE (QTTC_AFFEC_TFC.IDAFFEC = loc_affec.idaffec
        AND QTTC_AFFEC_TFC.TFC IN (3, 4))
      GROUP BY QTTC_AFFEC_TFC.MONNAIE,
           QTTC_AFFEC_TFC.MONNAIE_D ;
    EXCEPTION
       WHEN No_Data_Found THEN
        loc_monnaie   := 1;
        loc_monnaie_d  := 1;
                loc_mt_frais   := 0;
                loc_mt_frais_d := 0;
    END;
    ----- Revu par NS 25-07-2005 --- ---
  End;

  /* On determine le delta eventuel (Total encaisse - total affecte) */
  ----- Revu par NS 25-07-2005 --- -------
  BEGIN
  SELECT ALL loc_mt_affec - SUM(QTTC_AFFEC.MONTANT) - loc_mt_frais,
        QTTC_AFFEC.MONNAIE,
        loc_mt_affec_d - SUM(QTTC_AFFEC.MONTANT_D) - loc_mt_frais_d,
        QTTC_AFFEC.MONNAIE_D
    Into  loc_delta,
                loc_monnaie,
                loc_delta_d,
                loc_monnaie_d
    FROM QTTC_AFFEC
    WHERE (QTTC_AFFEC.IDAFFEC = loc_affec.idaffec
      AND QTTC_AFFEC.IDGAR<>0)
    GROUP BY QTTC_AFFEC.MONNAIE,
         QTTC_AFFEC.MONNAIE_D;
  Exception When No_data_found then
       loc_monnaie   := 1;
       loc_monnaie_d  := 1;
       loc_mt_frais  := 0;
       loc_mt_frais_d  := 0;
  END;
  ----- Revu par NS 25-07-2005 --- -------

  /* Qu'on affecte sur la premiere garantie */

  If ( loc_delta != 0 or loc_delta_d != 0) Then

    Begin
         Update  qttc_affec
         Set  montant   = montant + loc_delta,
                                monnaie   =loc_monnaie,
                                montant_d = montant_d + loc_delta_d,
                                monnaie_d =loc_monnaie_d
         Where  qttc_affec.idaffec = loc_affec.idaffec
         And  qttc_affec.idgar != 0
         and  rownum = 1;
         Exception When No_data_found then null;
    End;
  End if;

  /*  On met a jour le montant total affecte pour la garantie  */

     Update  qttc_gar
  Set  qttc_gar.mt_affec   = (select  sum(nvl(qttc_affec.montant,0))
                     from   qttc_affec
                     where  qttc_affec.numquit = a_numquit
                     and  qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.monnaie    = (select distinct(qttc_affec.monnaie)
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.mt_affec_d = (select sum(nvl(qttc_affec.montant_d,0))
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.monnaie_d  = (select distinct( qttc_affec.monnaie_d)
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     )
  Where  qttc_gar.numquit = a_numquit
  and qttc_gar.mt_ttc<>0
  and qttc_gar.mt_ttc_d<>0;

  /* On affecte les comm et les taxes */

  Begin
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv, tfc,
              type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers, prelev_revers)
    ----- Revu par NS 25-07-2005 --- --------------
    SELECT ALL loc_affec.idaffec,
          a_numquit,
          QTTC_COMM.NUMFOR,
          0,
          2,
          QTTC_COMM.TYPE_COMM,
          QTTC_COMM.NUMBENE,
          SUM(QTTC_COMM.MONTANT)*loc_ratio,
          QTTC_COMM.MONNAIE,
          SUM(QTTC_COMM.MONTANT_D)*loc_ratio_d,
          QTTC_COMM.MONNAIE_D,
          0,
          QTTC_COMM.PRELEV_REVERS
      FROM QTTC_COMM
      WHERE QTTC_COMM.NUMQUIT = a_numquit
      GROUP BY QTTC_COMM.NUMFOR,
           QTTC_COMM.TYPE_COMM,
           QTTC_COMM.NUMBENE,
           QTTC_COMM.PRELEV_REVERS,
           QTTC_COMM.MONNAIE,
           QTTC_COMM.MONNAIE_D
      HAVING (SUM(QTTC_COMM.MONTANT)<>0
        AND SUM(QTTC_COMM.MONTANT_D)<>0);
    ----- Revu par NS 25-07-2005 --- --------------

  Exception When No_data_found then null;
  End;

  Begin
      Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv, tfc,
              type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers, prelev_revers)
    ----- Revu par NS 25-07-2005 --- -------------
    SELECT ALL loc_affec.idaffec,
          a_numquit,
          QTTC_RETRO.NUMFOR,
          0,
          5,
          QTTC_RETRO.TYPE_COMM,
          QTTC_RETRO.NUMBENE,
          SUM(QTTC_RETRO.MONTANT)*loc_ratio,
          QTTC_RETRO.MONNAIE,
          SUM(QTTC_RETRO.MONTANT_D)*loc_ratio_d,
          QTTC_RETRO.MONNAIE_D,
          DECODE(QTTC_RETRO.PRELEV_REVERS, 1, -1, 0),
          QTTC_RETRO.PRELEV_REVERS
      FROM QTTC_RETRO
      WHERE QTTC_RETRO.NUMQUIT = a_numquit
      GROUP BY QTTC_RETRO.NUMFOR,
           QTTC_RETRO.TYPE_COMM,
           QTTC_RETRO.NUMBENE,
           QTTC_RETRO.MONNAIE,
           QTTC_RETRO.MONNAIE_D,
           DECODE(QTTC_RETRO.PRELEV_REVERS, 1, -1, 0),
           QTTC_RETRO.PRELEV_REVERS
      HAVING (SUM(QTTC_RETRO.MONTANT)<>0
        AND SUM(QTTC_RETRO.MONTANT_D)<>0);
   ----- Revu par NS 25-07-2005 --- ------------------

  Exception When No_data_found then null;

  End;

  Begin
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv,
              tfc, type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers)
          ----- Revu par NS 25-07-2005 ---
          SELECT ALL loc_affec.idaffec,
                     a_numquit,
               QTTC_TAXE.NUMFOR,
               0,
               1,
               QTTC_TAXE.TYPE_TAXE,
               QTTC_TAXE.NUMBENE,
               SUM(QTTC_TAXE.MONTANT)* loc_ratio,
               QTTC_TAXE.MONNAIE,
               SUM(QTTC_TAXE.MONTANT_D)*loc_ratio_d,
               QTTC_TAXE.MONNAIE_D,
               0
          FROM QTTC_TAXE
          WHERE QTTC_TAXE.NUMQUIT = a_numquit
          GROUP BY QTTC_TAXE.NUMFOR,
               QTTC_TAXE.TYPE_TAXE,
               QTTC_TAXE.NUMBENE,
               QTTC_TAXE.MONNAIE,
               QTTC_TAXE.MONNAIE_D
          HAVING (SUM(QTTC_TAXE.MONTANT)<>0
            AND SUM(QTTC_TAXE.MONTANT_D)<>0) ;
          ----- Revu par NS 25-07-2005 ---
  Exception When No_data_found then null;

  End;

  /* On marque l'idaffec comme etant ventile */

  Update  qttc_affec
  Set  numfor = 0,
    idrevers = -1
  Where  qttc_affec.idaffec = loc_affec.idaffec
  And  qttc_affec.numquit = a_numquit
  and  qttc_affec.idgar = 0;

end loop;
END QTTC_VENTIL;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  QTTC_VENTIL                                               */
/* Type         :  Privee                                                    */
/* Description  :  QTTC_VENTIL ==> surcharge pour la V6                      */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE QTTC_VENTIL (a_numquit in number,a_signe   in number)
is

loc_ratio  number;
loc_delta  number;
loc_ratio_d  number;
loc_delta_d  number;
loc_mt_frais  number;
loc_mt_reel  number;
loc_mt_affec  number;
loc_mt_frais_d  number;
loc_mt_reel_d  number;
loc_mt_affec_d  number;
loc_monnaie  number;
loc_monnaie_d  number;
loc_cot_null number;

Cursor fetch_affec is
  Select  idaffec,
      montant,
            monnaie,
            montant_d,
            monnaie_d
  From  qttc_affec
  Where  numquit = a_numquit
  And  numfor = -1;
loc_affec  fetch_affec%Rowtype;
BEGIN

For loc_affec in fetch_affec
loop
  /* On determine le ratio du reste a affecter   */

  Begin
     Select  loc_affec.montant / decode( qttc_global.mt_ttc,0,1,
          pk_funct.f_arrondi(4,
            qttc_global.numquit,
            qttc_global.mt_ttc) ),

      loc_affec.montant_d / decode( qttc_global.mt_ttc_d,0,1,
          pk_funct.f_arrondi(4,
            qttc_global.numquit,
            qttc_global.mt_ttc_d) ),
    qttc_global.mt_ttc,
                qttc_global.monnaie,
                qttc_global.mt_ttc_d,
                qttc_global.monnaie_d
  Into  loc_ratio,
        loc_ratio_d,
        loc_mt_reel,
            loc_monnaie,
            loc_mt_reel_d,
            loc_monnaie_d
  From  qttc_global
  Where  qttc_global.numquit = a_numquit
  And  qttc_global.mt_ttc is not null
        And  qttc_global.mt_ttc_d is not null;
  Exception When No_data_found then Exit;
  End;

  IF a_signe =-1 AND loc_mt_reel = 0 THEN
    loc_cot_null := -1;
    loc_cot_null := -1;
  ELSE loc_cot_null:=1;
  END IF;
  /* On retablit le montant a affecter par rapport au montant calcule */

   loc_mt_affec   := loc_mt_reel * loc_ratio;
   loc_mt_affec_d := loc_mt_reel_d * loc_ratio_d;

  /* On insere dans qttc_affec une ligne par garantie /assure */
  BEGIN
      Insert into qttc_affec
    (idaffec, idgar, numquit, numfor,
     numindiv, montant,monnaie,montant_d,monnaie_d,idrevers)
   ----- Revu par NS 25-07-2005 --- ---
   SELECT ALL loc_affec.idaffec,
         QTTC_GAR.IDGAR,
         a_numquit,
         QTTC_GAR.NUMFOR,
         QTTC_GAR.NUMINDIV,
         QTTC_GAR.MT_TTC*loc_ratio,
         QTTC_GAR.MONNAIE,
         QTTC_GAR.MT_TTC_D*loc_ratio_d,
         QTTC_GAR.MONNAIE_D,
         0
    FROM QTTC_GAR
    WHERE (QTTC_GAR.NUMQUIT = a_numquit
      AND QTTC_GAR.MT_TTC   IS NOT NULL
      AND QTTC_GAR.MT_TTC_D IS NOT NULL
      /*AND QTTC_GAR.MT_TTC<>0
      AND QTTC_GAR.MT_TTC_D<>0*/);
  END;
   ----- Revu par NS 25-07-2005 --- ---

  /* On insere les frais dans affec_tfc */

  Begin
    BEGIN
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv,tfc, type_tfc, numbene,
                          montant,monnaie,montant_d,monnaie_d,idrevers)
        ----- Revu par NS 25-07-2005 --- --------------------
    SELECT ALL loc_affec.idaffec,
           a_numquit,
           QTTC_FRAIS.NUMFOR,
           0,
           DECODE(QTTC_FRAIS.NUMFOR, 0, 4, 3),
           QTTC_FRAIS.TYPE_FRAIS,
           QTTC_FRAIS.NUMBENE,
           SUM(QTTC_FRAIS.MONTANT)*loc_ratio,
           QTTC_FRAIS.MONNAIE,
           SUM(QTTC_FRAIS.MONTANT_D)*loc_ratio_d,
           QTTC_FRAIS.MONNAIE_D,
           0
      FROM QTTC_FRAIS
      WHERE QTTC_FRAIS.NUMQUIT = a_numquit
      GROUP BY QTTC_FRAIS.NUMFOR,
          DECODE(QTTC_FRAIS.NUMFOR, 0, 4, 3),
          QTTC_FRAIS.TYPE_FRAIS,
          QTTC_FRAIS.NUMBENE,
          QTTC_FRAIS.MONNAIE,
          QTTC_FRAIS.MONNAIE_D
      HAVING (SUM(QTTC_FRAIS.MONTANT)<>0
        AND SUM(QTTC_FRAIS.MONTANT_D)<>0) ;
    END;

    ----- Revu par NS 25-07-2005 --- --------------------

  /* On re-calcule la somme des frais affectes */
  ----- Revu par NS 25-07-2005 --- ----
    BEGIN
     SELECT ALL NVL(SUM(QTTC_AFFEC_TFC.MONTANT), 0),
            QTTC_AFFEC_TFC.MONNAIE,
            NVL(SUM(QTTC_AFFEC_TFC.MONTANT_D), 0),
            QTTC_AFFEC_TFC.MONNAIE_D
      Into  loc_mt_frais,
          loc_monnaie,
          loc_mt_frais_d,
          loc_monnaie_d
      FROM QTTC_AFFEC_TFC
      WHERE (QTTC_AFFEC_TFC.IDAFFEC = loc_affec.idaffec
        AND QTTC_AFFEC_TFC.TFC IN (3, 4))
      GROUP BY QTTC_AFFEC_TFC.MONNAIE,
           QTTC_AFFEC_TFC.MONNAIE_D ;
    EXCEPTION
       WHEN No_Data_Found THEN
        loc_monnaie   := 1;
        loc_monnaie_d  := 1;
                loc_mt_frais   := 0;
                loc_mt_frais_d := 0;
    END;
    ----- Revu par NS 25-07-2005 --- ---
  End;

  /* On determine le delta eventuel (Total encaisse - total affecte) */
  ----- Revu par NS 25-07-2005 --- -------
  BEGIN
  SELECT ALL loc_mt_affec - SUM(QTTC_AFFEC.MONTANT) - loc_mt_frais,
        QTTC_AFFEC.MONNAIE,
        loc_mt_affec_d - SUM(QTTC_AFFEC.MONTANT_D) - loc_mt_frais_d,
        QTTC_AFFEC.MONNAIE_D
    Into  loc_delta,
                loc_monnaie,
                loc_delta_d,
                loc_monnaie_d
    FROM QTTC_AFFEC
    WHERE (QTTC_AFFEC.IDAFFEC = loc_affec.idaffec
      AND QTTC_AFFEC.IDGAR<>0)
    GROUP BY QTTC_AFFEC.MONNAIE,
         QTTC_AFFEC.MONNAIE_D;
  Exception When No_data_found then
       loc_monnaie   := 1;
       loc_monnaie_d  := 1;
       loc_mt_frais  := 0;
       loc_mt_frais_d  := 0;
  END;
  ----- Revu par NS 25-07-2005 --- -------

  /* Qu'on affecte sur la premiere garantie */

  If ( loc_delta != 0 or loc_delta_d != 0) Then

    Begin
         Update  qttc_affec
         Set  montant   = montant + loc_delta,
                                monnaie   =loc_monnaie,
                                montant_d = montant_d + loc_delta_d,
                                monnaie_d =loc_monnaie_d
         Where  qttc_affec.idaffec = loc_affec.idaffec
         And  qttc_affec.idgar != 0
         and  rownum = 1;
         Exception When No_data_found then null;
    End;
  End if;

  /*  On met a jour le montant total affecte pour la garantie  */

     Update  qttc_gar
  Set  qttc_gar.mt_affec   = (select  sum(nvl(qttc_affec.montant,0))
                     from   qttc_affec
                     where  qttc_affec.numquit = a_numquit
                     and  qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.monnaie    = (select distinct(qttc_affec.monnaie)
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.mt_affec_d = (select sum(nvl(qttc_affec.montant_d,0))
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.monnaie_d  = (select distinct( qttc_affec.monnaie_d)
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     )
  Where  qttc_gar.numquit = a_numquit
    AND qttc_gar.mt_ttc <> 0
    AND qttc_gar.mt_ttc_d <> 0;

  /* On affecte les comm et les taxes */

  Begin
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv, tfc,
              type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers, prelev_revers)
    ----- Revu par NS 25-07-2005 --- --------------
    SELECT ALL loc_affec.idaffec,
          a_numquit,
          QTTC_COMM.NUMFOR,
          0,
          2,
          QTTC_COMM.TYPE_COMM,
          QTTC_COMM.NUMBENE,
          SUM(QTTC_COMM.MONTANT)*decode(loc_mt_reel,0,loc_cot_null,loc_ratio),
          QTTC_COMM.MONNAIE,
          SUM(QTTC_COMM.MONTANT_D)*decode(loc_mt_reel,0,loc_cot_null,loc_ratio_d),
          QTTC_COMM.MONNAIE_D,
          0,
          QTTC_COMM.PRELEV_REVERS
      FROM QTTC_COMM
      WHERE QTTC_COMM.NUMQUIT = a_numquit
      GROUP BY QTTC_COMM.NUMFOR,
           QTTC_COMM.TYPE_COMM,
           QTTC_COMM.NUMBENE,
           QTTC_COMM.PRELEV_REVERS,
           QTTC_COMM.MONNAIE,
           QTTC_COMM.MONNAIE_D
      /*HAVING (SUM(QTTC_COMM.MONTANT)<>0
        AND SUM(QTTC_COMM.MONTANT_D)<>0)*/;
    ----- Revu par NS 25-07-2005 --- --------------

  Exception When No_data_found then null;
  End;

  Begin
      Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv, tfc,
              type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers, prelev_revers)
    ----- Revu par NS 25-07-2005 --- -------------
    SELECT ALL loc_affec.idaffec,
          a_numquit,
          QTTC_RETRO.NUMFOR,
          0,
          5,
          QTTC_RETRO.TYPE_COMM,
          QTTC_RETRO.NUMBENE,
          SUM(QTTC_RETRO.MONTANT)*loc_ratio,
          QTTC_RETRO.MONNAIE,
          SUM(QTTC_RETRO.MONTANT_D)*loc_ratio_d,
          QTTC_RETRO.MONNAIE_D,
          DECODE(QTTC_RETRO.PRELEV_REVERS, 1, -1, 0),
          QTTC_RETRO.PRELEV_REVERS
      FROM QTTC_RETRO
      WHERE QTTC_RETRO.NUMQUIT = a_numquit
      GROUP BY QTTC_RETRO.NUMFOR,
           QTTC_RETRO.TYPE_COMM,
           QTTC_RETRO.NUMBENE,
           QTTC_RETRO.MONNAIE,
           QTTC_RETRO.MONNAIE_D,
           DECODE(QTTC_RETRO.PRELEV_REVERS, 1, -1, 0),
           QTTC_RETRO.PRELEV_REVERS
      HAVING (SUM(QTTC_RETRO.MONTANT)<>0
        AND SUM(QTTC_RETRO.MONTANT_D)<>0);
   ----- Revu par NS 25-07-2005 --- ------------------

  Exception When No_data_found then null;

  End;

  Begin
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv,
              tfc, type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers)
          ----- Revu par NS 25-07-2005 ---
          SELECT ALL loc_affec.idaffec,
                     a_numquit,
               QTTC_TAXE.NUMFOR,
               0,
               1,
               QTTC_TAXE.TYPE_TAXE,
               QTTC_TAXE.NUMBENE,
               SUM(QTTC_TAXE.MONTANT)* loc_ratio,
               QTTC_TAXE.MONNAIE,
               SUM(QTTC_TAXE.MONTANT_D)*loc_ratio_d,
               QTTC_TAXE.MONNAIE_D,
               0
          FROM QTTC_TAXE
          WHERE QTTC_TAXE.NUMQUIT = a_numquit
          GROUP BY QTTC_TAXE.NUMFOR,
               QTTC_TAXE.TYPE_TAXE,
               QTTC_TAXE.NUMBENE,
               QTTC_TAXE.MONNAIE,
               QTTC_TAXE.MONNAIE_D
          HAVING (SUM(QTTC_TAXE.MONTANT)<>0
            AND SUM(QTTC_TAXE.MONTANT_D)<>0) ;
          ----- Revu par NS 25-07-2005 ---
  Exception When No_data_found then null;

  End;

  /* On marque l'idaffec comme etant ventile */

  Update  qttc_affec
  Set  numfor = 0,
    idrevers = -1
  Where  qttc_affec.idaffec = loc_affec.idaffec
  And  qttc_affec.numquit = a_numquit
  and  qttc_affec.idgar = 0;

end loop;
END;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Privee                                                    */
/* Description  :  Insertion dans journal_adm                                */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(P_niv     IN NUMBER,
                        p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                        P_msg     IN VARCHAR2,
                        p_msg2    IN VARCHAR2 := NULL)
IS
BEGIN

   IF p_journal.nom_traitement IS NULL THEN
     p_journal.nom_traitement:='VR18T';
   END IF;

   IF p_journal.niv_msg >= P_niv THEN
      p_journal.idligne := p_journal.idligne +1;
      PK_trace.P_INS_journal_adm ( I_nom_traitement => p_journal.nom_traitement, I_session => NVL(p_journal.id_session,SID), I_niv_msg => P_niv, I_msg_adm => SUBSTR(P_msg||' '||P_msg2,1,132), I_idligne => p_journal.idligne);
   END IF;
END P_INS_journal;



END PK_IMPORT_VIREMENT;
/
