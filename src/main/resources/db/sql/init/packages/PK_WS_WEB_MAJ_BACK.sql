CREATE OR REPLACE package ARTHUS.PK_WS_WEB_MAJ_BACK as
/*========================================================================       */
/* Package      : PK_WS_WEB_MAJ_BACK.sql                                         */
/* Domaine      : PACKAGE WEB SERVICE EDAAP                                      */
/* Version      : V2.0                                                           */
/* Auteur       : CLI                                                            */
/* Création     : 09/08/2011                                                     */
/* Description  : Package contenant les services exposés dans le cadre du projet */
/*              : Extranet de gerep. Package responsable des demande de          */
/*              : modification des informations de l'assuré, rib, téléphone..    */
/*                                                                               */
/* Projet       : P201609004_Extranet_assuré_GEREP, modifications                */
/* Evolution    :                                                                */
/* Auteur       : CLI                                                            */
/* Date         : 14/03/2017                                                     */
/* Commentaire  :                                                                */
/*==========================================================================     */
/* Correction   : trigramme / date / commentaire                                 */
/*==========================================================================     */
/* Correction   : CLI / 07/09/2017 / 5354  La modification de l'organisme ss doit*/
/*              : être répercutée sur les ayants droits rattachés par num ss à   */
/*              : l'ouvreur de droit modifié                                     */
/*                PHA 04/10/2017 0005399: EA - ajout de bénéficiaire déjà présent*/
/*                                        sur le groupe familial                 */
/*              : PHA 02/05/2018 5602 EDITION DE PIECES EN DEPOT SPONTANE A TORT */
/*============================================================================== */
/*==========================================================================     */
/* Evolutions   : CLI / 23/05/2018                                               */
/*              : Ajout de la demande bien être    ADD_DOS_CALC                  */
/*============================================================================== */

  -- Types
  TYPE T_SOUSCRIPTION IS RECORD  (
             NUMADHERENT           NUMBER(9),
             PRIX_TOT              NUMBER(11,2),
             TAB_PROSPECT          EXTR_TAB_BENE_PROSPECT,
             NUMINDIV              NUMBER(9),
             TYPBENE               NUMBER(3),
             TAB_CONTRACT          EXTR_TAB_CONTRACT_TO_SIGN_UP,
             NUMGAR                NUMBER(9),
             IDADHESION            NUMBER(9),
             TAB_GARANTIE          EXTR_TAB_GRNT_TO_SIGN_UP,
             NUMFOR                NUMBER(9),
             PRIX_GAR              NUMBER(11,2),
             LIB_PRIX_GAR          VARCHAR2(200),
             CHOIX_GAR             VARCHAR2(3),
             DATEEFFET             DATE,
             MODE_PAIE             NUMBER(3),
             DOCUMENTS             EXT_TAB_DOCUMENT,
             NUMUTIL               NUMBER(3),
             NAT_CALC              NUMBER(2),
             TYPEQUIT              NUMBER(2),
             MOTIF                 NUMBER(3)
                    );


  TYPE T_BENE IS RECORD  (
                           NUMBENE              NUMBER(9),
                           TYPBENE              NUMBER(9),
                           CONTRAT              NUMBER(9),
                           GARANTIES            NUMBER(9),
                           PROVENANCE           VARCHAR2(25),
                           RANG                 NUMBER(2)
                    );
  TYPE TAB_bene IS TABLE OF T_BENE index by binary_integer;
  TYPE TAB_indiv IS TABLE OF NUMBER(9) INDEX BY BINARY_INTEGER ;         -- tableau d individu de l adhésion de base existante

  exc_prestation_null    EXCEPTION;
  exc_couverture_not_exist    EXCEPTION;

/*Libellés des type de demande          */
--WEB_MAJ, 1 : Ajout de coordonnées bancaires
--WEB_MAJ, 2 : Fermeture d'une coordonnée bancaire
--WEB_MAJ, 3 : Ajout de coordonnées
--WEB_MAJ, 4 : Modification de l'adresse
--WEB_MAJ, 5 : Modification des informations personnelles


/******************************************************************************/
FUNCTION CHECK_HEALTH RETURN GENERIQUE_WS_RESP ;

/******************************************************************************/
FUNCTION ADD_RIB(   i_numporte  IN NUMBER,
                    i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                    i_numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                    i_numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                    i_idDemande_ext IN NUMBER,
                    i_bic IN VARCHAR2,
                    i_bban IN VARCHAR2,
                    i_clefIban IN VARCHAR2,
                    i_typeRib IN NUMBER,
                    i_domiciliation IN VARCHAR2,
                    i_nomTitulaire  IN VARCHAR2,
                    i_dateEffet     IN DATE,
                    i_beneficiares  IN EXTR_TAB_BENEFICIAIRE,
                    i_documents       IN EXT_TAB_DOCUMENT
                    )
RETURN GENERIQUE_WS_RESP;
/******************************************************************************/
FUNCTION ADD_BENEFICIAIRE( i_numporte         IN NUMBER,
                           i_id_type          IN TYPE_FLUX.ID_TYPE%TYPE,
                           i_numAdherent      IN NUMBER,
                           i_idDemande_ext    IN NUMBER,
                           i_typebeneficiaire IN NUMBER,
                           i_nom              IN VARCHAR2,
                           i_prenom           IN VARCHAR2,
                           i_datenaiss        IN DATE,
                           i_rangNais         IN NUMBER,
                           i_sexe             IN NUMBER,
                           i_numss            IN VARCHAR2,
                           i_regime           IN VARCHAR2,
                           i_caisse           IN VARCHAR2,
                           i_centre           IN VARCHAR2,
                           i_numss2           IN VARCHAR2,
                           i_regime2          IN VARCHAR2,
                           i_caisse2          IN VARCHAR2,
                           i_centre2          IN VARCHAR2,
                           i_dateeffet        IN DATE,
                           i_mutuelleExist    IN NUMBER,
                           i_documents        IN EXT_TAB_DOCUMENT
                          )
RETURN EXTR_R_ADD_BENEFICIAIRE; --GENERIQUE_WS_RESP;  -- BIA


/*******************************************************************************/

 FUNCTION ADD_INDIVIDU(   i_numporte         IN NUMBER,
                          i_id_type          IN TYPE_FLUX.ID_TYPE%TYPE,
                          i_idDemande_ext    IN NUMBER,
                          i_numcli           IN NUMBER,
                          i_nom              IN VARCHAR2,
                          i_prenom           IN VARCHAR2,
                          i_datenaiss        IN DATE,
                          i_rangNais         IN NUMBER,
                          i_sexe             IN NUMBER,
                          i_numss            IN VARCHAR2,
                          i_regime           IN VARCHAR2,
                          i_caisse           IN VARCHAR2,
                          i_centre           IN VARCHAR2
                    )
  RETURN EXTR_R_ADD_BENEFICIAIRE;


  /******************************************************************************/
 FUNCTION ADD_NUMSS(  i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent     IN NUMBER,
                      i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext   IN NUMBER,
                      i_typeDemande     IN NUMBER,
                      i_numss2          IN VARCHAR2,
                      i_dateeffet       IN DATE,
                      i_regime          IN VARCHAR2,
                      i_caisse          IN VARCHAR2,
                      i_centre          IN VARCHAR2,
                      i_infosocialetomodif IN NUMBER,
                      i_documents        IN EXT_TAB_DOCUMENT
                      )
  RETURN GENERIQUE_WS_RESP;


  /*******************************************************************************/


  FUNCTION ADD_DEVIS (  i_numporte  IN NUMBER,
                        i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                        i_numAdherent     IN NUMBER,
                        i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                        i_idDemande_ext   IN NUMBER,
                        i_mutuelleExist   IN NUMBER,
                        i_natureDossier   IN NUMBER,
                        i_documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP;
  /*******************************************************************************/


  FUNCTION ADD_REMB ( i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent     IN NUMBER,
                      i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext   IN NUMBER,
                      i_mutuelleExist   IN NUMBER,
                      i_natureDossier   IN NUMBER,
                      i_detailsoins     IN NUMBER,
                      i_documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP;

  /******************************************************************/
  FUNCTION ADD_DOS_CALC (  i_numporte      IN NUMBER
                          ,i_id_type       IN TYPE_FLUX.ID_TYPE%TYPE
                          ,i_numAdherent   IN NUMBER
                          ,i_numindiv       IN NUMBER
                          ,i_idDemande_ext IN NUMBER
                          ,i_typeDossier   IN NUMBER
                          ,i_natureDossier IN NUMBER
                          ,i_typeFrais     IN NUMBER
                          ,i_documents     IN EXT_TAB_DOCUMENT
                          ,i_tab_act       IN EXTR_TAB_ACTS_CALC

                          )
  RETURN EXTR_R_ADD_DOS_CALC;  -- reponse générique plus une réponse spécifique





/******************************************************************************/
FUNCTION ADD_CONTACT(  i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      i_numindiv IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext IN NUMBER,
                      i_contact IN VARCHAR2,
                      i_nature IN NUMBER,
                      i_type IN NUMBER,
                      i_dateEffet IN DATE   )
RETURN GENERIQUE_WS_RESP;
/******************************************************************************/
FUNCTION ADD_ADRESSE( i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      i_numindiv IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext IN NUMBER,
                      i_adresse IN EXTR_ADRESSE_TR,
                      i_dateEffet IN DATE
 )
RETURN GENERIQUE_WS_RESP;

 /******************************************************************/
FUNCTION CLOSE_RIB( i_numporte  IN NUMBER,
                    i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                    i_numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                    i_numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                    i_idDemande_ext IN NUMBER,
                    i_idRib IN NUMBER,
                    i_dateEffet     IN DATE
                   )
RETURN GENERIQUE_WS_RESP;
/******************************************************************************/
FUNCTION MAJ_INFO_PERSO(i_numporte  IN NUMBER,
                        i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                        i_numAdherent   IN NUMBER,
                        i_numIndiv      IN NUMBER,
                        i_idDemande_ext IN NUMBER,
                        i_nom           IN INDIVIDU.nom%TYPE,
                        i_nomNais       IN INDIVIDU.nomjf%TYPE,
                        i_prenom        IN INDIVIDU.prenom%TYPE,
                        i_dateEffet     IN DATE,
                        i_dateNaissance IN DATE,
                        i_rangNaissance IN NUMBER,
                        i_regimeSS      IN VARCHAR2,
                        i_caisse        IN VARCHAR2,
                        i_centre        IN VARCHAR2,
                        i_infosocialetomodif IN NUMBER,
                        i_documents       IN EXT_TAB_DOCUMENT
                        )
RETURN GENERIQUE_WS_RESP;


/******************************************************************************/
FUNCTION MAJ_CIRCUIT_INFO(i_numporte  IN NUMBER,
                          i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                          i_numAdherent   IN NUMBER,
                          i_numIndiv      IN NUMBER,
                          i_idDemande_ext IN NUMBER,
                          i_typeCircuit   IN NUMBER,
                          i_ouverture     IN NUMBER
                        )
RETURN GENERIQUE_WS_RESP;

/******************************************************************************************DMNDE*************************************************************************************************/
/******************************************************************************************DMNDE*************************************************************************************************/
/******************************************************************************************DMNDE*************************************************************************************************/

FUNCTION DMNDE_PEC_HOSPI (i_numporte  IN NUMBER,
                          i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                          i_numAdherent   IN NUMBER,
                          i_numIndiv      IN NUMBER,
                          i_idDemande_ext IN NUMBER,
                          i_natHospi      IN NUMBER,
                          i_nomEtHospi    IN VARCHAR2,
                          i_NNI           IN VARCHAR2,
                          i_codPos        IN VARCHAR2,
                          i_dateHospi     IN DATE,
                          i_ville         IN VARCHAR2,
                          i_tel           IN VARCHAR2, -- telephone
                          i_fax           IN VARCHAR2,
                          i_adresse       IN VARCHAR2,
                          i_email         IN VARCHAR2)
RETURN  GENERIQUE_WS_RESP;
/******************************************************************************/

  FUNCTION DEPOT_PIECE (  i_numporte  IN NUMBER,
                          i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                          i_numAdherent     IN NUMBER,
                          i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                          i_idDemande_ext   IN NUMBER,
                          i_typePiece       IN NUMBER,
                          i_contexte        IN NUMBER,
                          i_entite          IN NUMBER,
                          i_id_piece        IN NUMBER,
                          datedebut         IN DATE,
                          datefin           IN DATE,
                          i_documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP;

 /*****************************************************************************/

  PROCEDURE DEPOT_SPONT_PREV (p_typePiece IN NUMBER,
                            p_numIndiv    IN INDIVIDU.NUMINDIV%TYPE,
                            p_numAdherent IN NUMBER,
                            p_piece       IN OUT pieces%ROWTYPE,
                            p_rappel      IN OUT rappel%ROWTYPE,
                            p_numporte    IN NUMBER,
                            p_numutil     IN NUMBER,
                            p_lib         IN VARCHAR2,
                            p_documents   IN EXT_TAB_DOCUMENT) ;

  /*******************************************************************************/


  FUNCTION SUBSCRIBE (  i_numporte      IN NUMBER,
                        i_id_type       IN TYPE_FLUX.ID_TYPE%TYPE,
                        i_numAdherent   IN NUMBER,
                        i_idDemande_ext IN NUMBER,
                        i_TABPROSPECT   IN EXTR_TAB_BENE_PROSPECT,
                        i_dateeffet     IN DATE,
                        I_MODE_PAIE     IN NUMBER,
                        i_PRIX_TOT      IN NUMBER,
                        i_NATURE        IN NUMBER, --1 option, 2 base
                        i_Idadhesion_base IN NUMBER,
                        i_documents     IN EXT_TAB_DOCUMENT
  )
  RETURN EXTR_R_SUBCRIBE;

   /******************************************************************************/

  FUNCTION RAD_BENE ( i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent     IN NUMBER,
                      i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext    IN NUMBER,
                      i_motif           IN NUMBER,
                      i_dateeffet       IN DATE,
                      documents         IN EXT_TAB_DOCUMENT
                            )
  RETURN GENERIQUE_WS_RESP;

   /******************************************************************************/

  FUNCTION VALID_SUBCRIBE_RH( i_numporte       IN NUMBER,
                           i_id_type        IN TYPE_FLUX.ID_TYPE%TYPE,
                           i_numcli           IN NUMBER,
                           i_idDemande_ext    IN NUMBER,
                           infos            IN EXTR_QUALIF_SUBRIBE
                      )
  RETURN GENERIQUE_WS_RESP;

   /******************************************************************************/

  FUNCTION REJECT_SUBCRIBE_RH(  i_numporte       IN NUMBER,
                                i_id_type        IN TYPE_FLUX.ID_TYPE%TYPE,
                                i_numcli           IN NUMBER,
                                i_idDemande_ext    IN NUMBER,
                                infos            IN EXTR_QUALIF_SUBRIBE
                    )
  RETURN GENERIQUE_WS_RESP  ;

   /******************************************************************************/

  FUNCTION MAJ_SUBSCRIBE_RH(   i_numporte       IN NUMBER,
                               i_id_type        IN TYPE_FLUX.ID_TYPE%TYPE,
                               i_numcli           IN NUMBER,
                               i_idDemande_ext    IN NUMBER,
                               i_dateeffet        IN DATE,
                               infos            IN EXTR_QUALIF_SUBRIBE
                     )
  RETURN GENERIQUE_WS_RESP;
/******************************************************************************************UTIL*************************************************************************************************/
/******************************************************************************************UTIL*************************************************************************************************/
/******************************************************************************************UTIL*************************************************************************************************/

FUNCTION GET_RESP_OK(  numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      numindiv IN INDIVIDU.NUMINDIV%TYPE,
                      idDemande_ext IN NUMBER,
                      typeDemande IN NUMBER,
                      message       IN VARCHAR2 DEFAULT NULL
                    )
RETURN GENERIQUE_WS_RESP;


FUNCTION GET_RESP_KO(  numAdherent    IN INDIVIDU.NUMINDIV%TYPE,
                      numindiv       IN INDIVIDU.NUMINDIV%TYPE,
                      idDemande_ext  IN NUMBER,
                      typeDemande    IN NUMBER,
                      mess_erreur    IN VARCHAR2)
RETURN GENERIQUE_WS_RESP;

PROCEDURE P_ANNUL_PIECES(i_idrappel IN NUMBER, o_erreur OUT NUMBER);
PROCEDURE P_RECEPT_PIECES(i_idrappel IN NUMBER, o_erreur OUT NUMBER);


/******************************************************************************/

  FUNCTION F_FORMAT  ( P_Chaine   IN   VARCHAR2)
  RETURN VARCHAR2;



FUNCTION RESPONSE_TO_XML(response GENERIQUE_WS_RESP)
RETURN XMLTYPE;
/************************************UTIL_RIB*******************************************/
FUNCTION IS_RIB_AFTER_CURRENT (i_id_rib IN rib.idrib%type, i_dateeffet IN DATE) RETURN NUMBER;
FUNCTION IS_RIB_DIFFERENT (i_id_rib IN rib.idrib%type, i_BIC IN RIB.BIC%TYPE, i_BBAN IN rib.bban%type, i_clerib  IN RIB.CLERIB%TYPE) RETURN NUMBER;
/************************************UTIL_ADD_BENE*******************************************/
FUNCTION IS_BENE_DOUBLON (i_numAdherent      IN NUMBER,
                         i_nom              IN VARCHAR2,
                         i_prenom           IN VARCHAR2,
                         i_datenaiss        IN DATE,
                         i_numss            IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
FUNCTION IS_BENE_DOUBLON_GROUPE (i_numAdherent      IN NUMBER,
                         i_nom              IN VARCHAR2,
                         i_prenom           IN VARCHAR2,
                         i_datenaiss        IN DATE ,
                         i_numss            IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
FUNCTION IS_NUMSS_OK ( i_numss1 IN individu.matorg%TYPE, i_cless1 IN individu.cless%TYPE, i_numss2  IN individu.matorg2%TYPE, i_cless2 IN  individu.cless2%TYPE)
return NUMBER;

FUNCTION IS_REGIME_CAISSE_OK ( i_regime1 IN individu.regime%TYPE, i_caisse1 IN individu.caisse%TYPE, i_regime2 IN individu.regime2%TYPE, i_caisse2 IN individu.caisse2%TYPE)
return NUMBER;

/*****************************************UTIL_MAJ_INFO_PERSO*****************************************************/
 PROCEDURE VERIF_MAJ_INFO_PERSO(i_numAdherent   IN NUMBER,
                              i_numIndiv      IN NUMBER,
                              i_idDemande_ext IN NUMBER,
                              i_nom           IN INDIVIDU.nom%TYPE,
                              i_nomNais       IN INDIVIDU.nomjf%TYPE,
                              i_prenom        IN INDIVIDU.prenom%TYPE,
                              i_dateEffet     IN DATE,
                              i_dateNaissance IN DATE,
                              i_rangNaissance IN NUMBER,
                              i_regimeSS      IN VARCHAR2,
                              i_caisse        IN VARCHAR2,
                              i_centre        IN VARCHAR2,
                              i_documents     IN EXT_TAB_DOCUMENT,
                              o_etat          OUT NUMBER,
                              o_code_erreur   OUT NUMBER
                              )  ;
/******************************* UTIL SOUSCRIPTION  ***************************************/
FUNCTION F_COMPARE_SOUSCRIPTIONS (tab_benes_sous EXTR_TAB_BENE_PROSPECT, tab_benes_consult EXTR_TAB_BENE_PROSPECT, offre NUMBER)
RETURN NUMBER ;

FUNCTION F_GET_SOUSCRIPTION_EPURE (tab_bene EXTR_TAB_BENE_PROSPECT, NUM_GAR NUMBER, OFFRE NUMBER) return EXTR_TAB_BENE_PROSPECT;

 /****************************************************INTEGRATION FONCTIONNELLE **************************************************/
FUNCTION F_VALIDE_DEPOT_PIECE   (i_idrappel number ,i_numporte number) RETURN NUMBER;
FUNCTION F_VALIDE_DEVIS         (i_idrappel number ,i_numporte number) RETURN NUMBER;
FUNCTION F_VALIDE_REMB          (i_idrappel number ,i_numporte number) RETURN NUMBER;
FUNCTION F_VALIDE_ADD_DOSS_CALC (i_idrappel number ,i_numporte number) RETURN NUMBER;
FUNCTION F_VALIDE_RADIATION     (i_idrappel number ,i_numporte number) RETURN NUMBER;
FUNCTION F_VALIDE_ADD_NUMSS     (i_idrappel number ,i_numporte number) RETURN NUMBER;
FUNCTION F_VALIDE_ADD_RIB (i_idrappel RAPPEL.IDRAPPEL%TYPE , i_numporte PORTE_CONTRAT.NUMPORTE%TYPE) RETURN NUMBER;
FUNCTION F_INSTANCIE_SUBSCRIBE_DEV(i_idrappel RAPPEL.IDRAPPEL%TYPE , i_numporte PORTE_CONTRAT.NUMPORTE%TYPE)RETURN NUMBER;
FUNCTION F_VALIDE_SUBSCRIBE(i_idrappel RAPPEL.IDRAPPEL%TYPE , i_numporte PORTE_CONTRAT.NUMPORTE%TYPE) RETURN NUMBER;
FUNCTION F_VALIDE_MAJ_INFO_PERSO(i_idrappel number , i_numporte number) RETURN NUMBER;
FUNCTION F_VALIDE_PEC_HOSPI     (i_idrappel number , i_numporte number) RETURN NUMBER;
FUNCTION F_VALIDE_ADD_BENE      (i_idrappel number , i_numporte number) RETURN NUMBER;
FUNCTION F_FIND_ADHESION( p_numadherent  IN   NUMBER
                        , P_numfor              IN  ADHESION.NUMFOR%TYPE)
RETURN ADHE_CNTRT.IDADHESION%TYPE;

FUNCTION F_EXIST_DOCUMENT( P_CLEF           IN   LIEN_GED.CLEF%TYPE)
RETURN NUMBER;

FUNCTION F_EXIST_RAC(P_NUMGAR         IN     SINISTRE.NUMGAR%TYPE
                   , P_NUMINDIV       IN     SINISTRE.NUMINDIV%TYPE
                   , P_NUMFOR         IN     SINISTRE.NUMFOR%TYPE
                   , P_DATEEFFET      IN     SINISTRE.DATSIN%TYPE)
RETURN NUMBER;

FUNCTION F_FIND_NAT_CALC_TYPEQUIT(P_NUMGAR         IN     CONTRAT.NUMGAR%TYPE,
                                  P_NAT_CALC       OUT    CONTRAT.NAT_CALC%TYPE,
                                  P_TYPEQUIT       OUT    CONTRAT.TYPEQUIT%TYPE)
RETURN NUMBER;

FUNCTION F_VERIF_NUMFOR( P_NUMFOR           IN   ADHESION.NUMFOR%TYPE
                       , P_ano              OUT  NUMBER)
RETURN NUMBER;

FUNCTION F_VALIDE_ADD_SIN_PREV(i_idrappel number ,i_numporte number) RETURN NUMBER;

FUNCTION F_VALIDE_ADD_EVENT(i_idrappel number ,i_numporte number) RETURN NUMBER;

FUNCTION F_VALIDE_RAD_ADHE(i_idrappel number,i_numporte number) RETURN NUMBER;

PROCEDURE P_INIT_ADHE_CNTRT( P_TAB_T_SOUSCRIPTION  IN   T_SOUSCRIPTION
                           , P_ADHE_CNTRT          OUT  ADHE_CNTRT%ROWTYPE
                           , P_ano                 OUT  NUMBER);

PROCEDURE P_INIT_HISTO_ADHESION( P_TAB_T_SOUSCRIPTION  IN      T_SOUSCRIPTION
                               , P_HISTO_ADHESION      OUT  HISTO_ADHESION%ROWTYPE
                               , P_new_idadhesion      IN      HISTO_ADHESION.IDADHESION%TYPE
                               , P_etat                IN NUMBER
                               , p_mofif               IN NUMBER
                               , P_ano                 OUT  NUMBER);

PROCEDURE P_INIT_ADHE_CNTRT_MEMBRE( P_TAB_T_SOUSCRIPTION     IN      T_SOUSCRIPTION
                                  , P_TAB_T_BENE             IN      TAB_bene
                                  , P_new_idadhesion         IN      HISTO_ADHESION.IDADHESION%TYPE
                                  , P_ADHE_CNTRT_MEMBRE         OUT  ADHE_CNTRT_MEMBRE%ROWTYPE
                                  , P_ano                       OUT  NUMBER);


PROCEDURE P_INIT_ADHE_CNTRT_MEMBRE_DEV( P_souscript                IN      rappel_souscript%rowtype
                                      , P_new_idadhesion      IN      HISTO_ADHESION.IDADHESION%TYPE
                                      , P_ano                       OUT  NUMBER);

PROCEDURE P_INIT_ADHESION( P_TAB_T_SOUSCRIPTION     IN           T_SOUSCRIPTION
                         , P_souscript                 IN           rappel_souscript%rowtype
                         , P_idadhesion             IN           ADHESION.IDADHESION%TYPE
                         , P_numfor_base            IN           ADHESION.NUMFOR%TYPE
                         , P_ADHESION                    OUT     ADHESION%ROWTYPE
                         , P_ano                         OUT     NUMBER);

PROCEDURE P_LANCE_CALCUL_COTIS ( P_traitement    IN  VARCHAR2,
                                 P_log           IN  VARCHAR2     DEFAULT 'notest',
                                 P_ADHE_CNTRT    IN  ADHE_CNTRT%ROWTYPE,
                                 P_DateEffet     IN  DATE,
                                 P_ano           OUT NUMBER
                                 );

PROCEDURE P_VERIF_COMPTANT(P_ADHE_CNTRT   IN  ADHE_CNTRT%ROWTYPE,
                           P_DateEffet    IN      DATE,
                           P_ano          OUT     NUMBER,
                           P_numedit      OUT     FILE_EDITION.NUMEDIT%TYPE);

FUNCTION GET_CODE_DEMANDE( i_id_type IN TYPE_FLUX.ID_TYPE%TYPE , i_numporte NUMBER DEFAULT 25) RETURN NUMBER;

PROCEDURE P_MAIL_RECEPTION (I_NUMINDIV IN individu.numindiv%type, I_type_demande IN RAPPEL.type%type, i_contexte IN NUMBER, i_clef IN varchar2, i_idtexte IN NUMBER default 29, i_template NUMBER default 1 )   ;

PROCEDURE P_MAIL_INTERLOCUTEUR ;

PROCEDURE P_FERMER_DOSSIER_SANTE(i_num_dossier IN number, o_code_err IN OUT number);

PROCEDURE P_INVAL_SOUSCRIPTION (i_idrappel rappel.idrappel%type, o_erreur OUT NUMBER);

PROCEDURE P_CREER_COLLECTION_DOCUSHARE(i_numindiv number,i_societe number)   ;

PROCEDURE P_CREA_SNTR_PREV (p_mensu IN NUMBER, p_rappel IN RAPPEL%ROWTYPE, p_numutil IN NUMBER, /*p_idDemande_ext NUMBER,*/
                            io_numdoss IN OUT DOSSIER_SINISTRE.iddossier%TYPE,
                            o_nosin OUT SNTR_PREV.NOSIN%TYPE );

FUNCTION  f_ctrl_querable(  iv_numindiv  IN  VARCHAR2,
                            i_date IN DATE)
              RETURN number;

FUNCTION F_IS_HORS_BIA(i_numassu IN NUMBER) RETURN number  ;

PROCEDURE P_insert_grnt_dependante(i_idrappel rappel.idrappel%type,
                                            i_numadhe individu.numindiv%type );
FUNCTION ADD_SIN_PREV(i_numporte       IN NUMBER,
                       i_id_type         IN TYPE_FLUX.ID_TYPE%TYPE,
                       i_idDemande_ext   IN NUMBER,
                       i_params          IN EXTR_Q_ADD_SIN_PREV,
                       i_Salaires        IN EXTR_TAB_SALAIRES,
                       i_DocSalaire      IN EXT_TAB_DOCUMENT,
                       i_Documents       IN EXTR_TAB_DOCSINPREV,--EXT_TAB_DOCUMENT,
                       i_Maintien        IN EXTR_TAB_MAINTIEN) RETURN EXTR_TAB_ADD_SIN_PREV;


FUNCTION ADD_EVENT(  i_numporte    IN NUMBER,
                       i_id_type     IN TYPE_FLUX.ID_TYPE%TYPE,
                       i_idDemande_ext   IN NUMBER,
                       i_params      IN EXTR_Q_ADD_EVENT,
                       i_documents   IN EXT_TAB_DOCUMENT ) RETURN GENERIQUE_WS_RESP ;

FUNCTION RAD_ADHESION ( i_numporte        IN NUMBER,
                        i_id_type         IN TYPE_FLUX.ID_TYPE%TYPE,
                        i_idDemande_ext   IN NUMBER,
                        i_numcli          IN NUMBER,
                        i_numindiv        IN INDIVIDU.NUMINDIV%TYPE,
                        i_typeadhesion    IN VARCHAR2,
                        i_etat            IN NUMBER,
                        i_motif           IN NUMBER,
                        i_debut           IN DATE,
                        i_risque          IN NUMBER) RETURN GENERIQUE_WS_RESP;

PROCEDURE P_GEST_RADIA_ADHESION( p_idadhesion        IN adhesion.idadhesion%TYPE
                                ,p_numindiv             IN individu.numindiv%TYPE
                                ,p_debut                IN DATE
                                ,p_motif            IN   NUMBER
                                , p_etat_adhesion   IN   ADHESION.ETAT%TYPE
                                ,p_numutil          IN NUMBER
                                --, P_flag_newindiv IN      NUMBER
                                , p_ctrlcot         IN   NUMBER
                                ,p_type_action      IN   NUMBER
                                , p_ano             OUT  NUMBER
                                , p_warning         OUT  NUMBER
                                );


PROCEDURE P_VERIF_ANNUL_COTIS_ADH ( i_idadhesion        IN adhe_cntrt.idadhesion%TYPE
                                   ,i_numindiv             IN individu.numindiv%TYPE
                                   ,i_debut                IN DATE
                                   , o_cotis               OUT   NUMBER);

PROCEDURE P_ANNUL_COT_PREVI_ADH ( i_idadhesion  IN adhe_cntrt.idadhesion%TYPE
                                 , i_debut     IN DATE
                                 , i_ctrtResil IN NUMBER
                                 , o_warning   OUT NUMBER);

END PK_WS_WEB_MAJ_BACK;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_WS_WEB_MAJ_BACK as

/******************************** PROCEDURES  ET FONCTIONS PRIVEES************************************************/
  PROCEDURE INFO_CVRT_PRCH( i_numindiv IN NUMBER,
                            numgar out number,
                            numfor out number,
                            edatapli out number,
                            idadhesion out number,
                            i_datehospi IN DATE);
  -- insertion d'une nouvelle ligne dans HISTO_adhe
  PROCEDURE P_INS_HISTO_ADHESION(i_idadhesion number, i_datapli DATE , i_etat NUMBER, i_motif NUMBER, i_numutil number);

  PROCEDURE SET_RAPPEL_ERREUR( i_idrappel IN RAPPEL.idrappel%TYPE,i_code_err  IN RAPPEL.code_err%TYPE, i_etat IN RAPPEL.etat%TYPE );

  FUNCTION GET_FIRST_NOT_CHILD( i_beneficiaires  IN EXTR_TAB_BENEFICIAIRE, i_numassu NUMBER, i_numindiv NUMBER ) RETURN NUMBER ;

  PROCEDURE INSERT_LIEN_GED( i_documents  IN EXT_TAB_DOCUMENT, i_etendue IN NUMBER, i_iddemande IN NUMBER, i_numindiv IN NUMBER, i_numporte IN NUMBER, i_numutil IN NUMBER, i_numclef IN NUMBER)  ;

  PROCEDURE DELETE_LIEN_GED( i_etendue IN NUMBER, i_clef IN NUMBER);
  PROCEDURE P_SAVE_TAB_ACT( i_rappel  IN rappel%rowtype,i_tab_act IN EXTR_TAB_ACTS_CALC)  ;

  PROCEDURE P_MAIL_RECEPTION (I_NUMINDIV IN individu.numindiv%type, I_type_demande IN RAPPEL.type%type, i_contexte IN NUMBER, i_clef IN varchar2, i_idtexte IN NUMBER default 29, i_template NUMBER default 1 )
  IS
  loc_envoi      ENVOI_MAIL%ROWTYPE;
  loc_complement_sujet varchar2(100);
  loc_mail_exist NUMBER:=0;

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

      BEGIN
    	  SELECT corps_msg, sujet_msg
    	  INTO loc_envoi.corps,loc_envoi.sujet
    	  FROM mail_texte
    	  WHERE id_texte = nvl(i_idtexte, 29)  -- accusé de reception lambda
        AND NOT EXISTS (SELECT clef FROM ENVOI_MAIL em
         WHERE em.numindiv_dest = I_NUMINDIV
         AND em.idtexte in (5,24,33)
         AND trunc(em.date_creation)=trunc(sysdate));  -- Pas d'AR le même jour qu'un Email de bienvenue (5/24) et/ou d’affiliation Iris (33)  -- PBO M0006253
        loc_complement_sujet := F_GET_TRANSCO ('MAIL','MAILRPL',I_TYPE_DEMANDE);
        IF loc_complement_sujet IS NOT NULL THEN
          loc_envoi.sujet:= REPLACE(loc_envoi.sujet, '#DEMANDE', ' - '||loc_complement_sujet)   ;
        ELSE
          loc_envoi.sujet:= REPLACE(loc_envoi.sujet, '#DEMANDE', '')   ;
        END IF;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN; --doublon

       END;
      loc_envoi.NUMINDIV_DEST:=I_NUMINDIV;
      loc_envoi.NUMBENE:=I_NUMINDIV;
      loc_envoi.NUMUTIL:= 250;
      loc_envoi.etendue:= i_contexte;   -- rendre le contexte dynam
      loc_envoi.clef:= i_clef;        -- changer le contexte
      loc_envoi.IDTEXTE:= nvl(i_idtexte, 29);
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
      loc_envoi.template_mail :=i_template; -- permet de savoir quel template utiliser
      PK_MAIL.CREER_MAIL(loc_envoi);

  COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_MAIL_RECEPTION',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'KO : numindiv :'||I_NUMINDIV ||', i_idtexte:'||i_idtexte ||', I_TYPE_DEMANDE:'||I_TYPE_DEMANDE, I_idligne  => 3);
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_MAIL_RECEPTION',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  substr('KO: '||sqlerrm,1,132), I_idligne  => 4);

  END P_MAIL_RECEPTION;
  /************************************************************************************************/
PROCEDURE P_MAIL_INTERLOCUTEUR
IS
  loc_num_interlocuteur INDIVIDU.numindiv%type;
  loc_envoi             ENVOI_MAIL%ROWTYPE;
  loc_complement_sujet  LIBELLE.libelle%type;
  loc_mail_exist        NUMBER:=0;
  l_corps               ENVOI_MAIL.corps%type;
  PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR c_interlocuteurs( i_numcli individu.numindiv%type ) is
        SELECT interlocuteur
        FROM interlocuteur
        WHERE NUMINDIV =  i_numcli
        AND ope_crrr =8  -- RH
		AND VALIDE= 'O'; -- Interlocuteur validé uniquement -- M0006253 PBO

  CURSOR c_adhesions_instance is
  SELECT count(distinct a.idadhesion ) nb_adh,  c.numcli
     FROM adhe_cntrt a, contrat  c/*, gar_cntrt_ref gc, formule f, adhesion ad  */
    WHERE F_ETAT_ADHE(a.idadhesion , greatest(a.date_adhe,sysdate) )  = 0 --instance
      AND F_ETAT_ADHE(a.idadhesion , greatest(a.date_adhe,sysdate), 2 ) = 58 -- motif préaff
      AND a.numgar = c.numgar
      /*AND gc.numgar = c.numgar
      AND f.numfor = gc.numfor
      AND a.idadhesion = ad.idadhesion
      AND f.typgar = 1                                                     -- garantie de base uniquement : PBO M0006279
      AND ad.creation BETWEEN add_months(trunc(sysdate),-3) and sysdate    -- uniquement les adhésions créées dans les 3 mois glissants -- PBO M0006279 --KO mantis en cours*/
      AND a.DATE_FIN_ADHE is  null
    GROUP BY c.numcli;

  CURSOR c_adhesion_mouvement IS
        SELECT
          count(distinct DATAS.idadhesion) nb_adh ,
          c.numcli
    FROM contrat c, (
         SELECT distinct a.idadhesion ,
                    /*'Nouvelle adhésion'*/ 1 type_mouvement,
                    trunc(a.maj) MAJ,
                    a.numgar,
                    datapli,datper,
                    ad.mregl
          FROM adhesion a , adhe_cntrt ad
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                 -- and numindiv = i_numadhe
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND a.datper is  null
            AND creation BETWEEN add_months(trunc(sysdate),-1) and trunc(sysdate) -- on prend sur le moi
      UNION
      -- radiation
          SELECT distinct a.idadhesion ,
                          /*'Radiation'*/ 2 type_mouvement,
                          trunc( ha.datsai) MAJ,
                          a.numgar,
                          datapli,datper,
                          ad.mregl
          FROM adhesion a , adhe_cntrt ad, histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                 -- AND numindiv = i_numadhe
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND ha.idhistoadhe =  F_ETAT_ADHE(a_idadhesion=> a.idadhesion, a_date        => sysdate,     a_type=>5)
            AND ha.datsai         BETWEEN add_months(trunc(sysdate),-1) and trunc(sysdate) -- on prend sur le mois
            AND ha.etat = 3
            AND EXISTS (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND ad.date_fin_adhe between fps.DEBUT and nvl(fps.fin, ad.date_fin_adhe) and fps.VALIDE ='O')
      UNION
      --  ajout ou cloture de couverture avec cod option liee
        SELECT distinct a.idadhesion ,
                          /*'Ajout de couverture'*/ 3  type_mouvement,
                          trunc(a.maj) MAJ ,
                          a.numgar,
                          datapli,datper,
                          ad.mregl
          FROM adhesion a , adhe_cntrt ad , histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                 -- AND numindiv = i_numadhe
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND ha.idhistoadhe =  F_ETAT_ADHE(a_idadhesion=> a.idadhesion, a_date    => sysdate, a_type=>5)
             AND ha.datsai        BETWEEN add_months(trunc(sysdate),-1) and trunc(sysdate) -- on prend sur le mois
            AND ha.etat <> 3
            and datper is null
            AND a.creation > trunc(sysdate, 'MONTH')
            AND TRUNC(ha.datsai) <> TRUNC(a.creation)
            AND exists (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND sysdate BETWEEN fps.DEBUT and nvl(fps.fin, sysdate) and fps.VALIDE ='O')
      UNION
      -- fermeture de couverture
        SELECT distinct a.idadhesion ,
                          /*'Fermeture de couverture'*/ 4 type_mouvement,
                          trunc(a.maj) MAJ ,
                          a.numgar,
                          datapli,
                          datper,
                          ad.mregl
          FROM adhesion a , adhe_cntrt ad , histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                 -- AND numindiv = i_numadhe
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND ha.idhistoadhe =  F_ETAT_ADHE(a_idadhesion=> a.idadhesion, a_date    => sysdate, a_type=>5)
            AND ha.datsai         BETWEEN add_months(trunc(sysdate),-1) and trunc(sysdate)-- on prend sur le mois
            AND ha.etat <> 3
            AND a.datper is not null
            AND MAJ > trunc(sysdate, 'MONTH')
            AND EXISTS (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND trunc(sysdate) BETWEEN fps.DEBUT and nvl(fps.fin, sysdate) and fps.VALIDE ='O')
            AND  EXISTS(select 1 from adhesion a2 where a2.numindiv = a.numindiv and sysdate BETWEEN a2.DATAPLI and NVL(a2.datper,sysdate) and a2.idadhesion = a.IDADHESION )-- verifie que le bénéficiaire n'a jamais eu de couverture sur cette adhesion
      union
      -- ajout de beneficiaire
        SELECT distinct a.idadhesion ,
                          /*'Ajout de beneficiaire'*/ 5 type_mouvement,
                          trunc(a.maj) MAJ ,
                          a.numgar,
                          datapli,
                          datper,
                          ad.mregl
          FROM adhesion a , adhe_cntrt ad , histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                 -- AND numindiv = i_numadhe
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND ha.idhistoadhe =  F_ETAT_ADHE(a_idadhesion=> a.idadhesion, a_date    => sysdate, a_type=>5)
             AND ha.datsai       BETWEEN add_months(trunc(sysdate),-1) and trunc(sysdate) -- on prend sur le mois
            AND ha.etat <> 3
            AND a.datper is null
            AND a.creation > trunc(sysdate, 'MONTH')
            AND TRUNC(ha.datsai) <> TRUNC(a.creation)
            AND exists (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND trunc(sysdate) BETWEEN fps.DEBUT and nvl(fps.fin, sysdate) and fps.VALIDE ='O')
            and not exists(select 1 from adhesion a2 where a2.numindiv = a.numindiv and  sysdate BETWEEN a2.DATAPLI and NVL(a2.datper,sysdate) and a2.idadhesion = a.IDADHESION )-- verifie que le bénéficiaire n'a jamais eu de couverture sur cette adhesion
--suppression de beneficiaire
union
  SELECT distinct a.idadhesion ,
                    /*'Suppresion de beneficiaire'*/ 6 type_mouvement,
                    trunc(a.maj) MAJ ,
                    a.numgar,
                    datapli,
                    datper,
                    ad.mregl
    FROM adhesion a , adhe_cntrt ad , histo_adhesion ha
    WHERE a.idadhesion IN(  SELECT idadhesion
                            FROM adhesion
                            WHERE 1=1
                            --AND numindiv = i_numadhe
                            AND datapli <> nvl(datper,datapli+1))
      AND a.idadhesion = ad.idadhesion
      AND ha.idhistoadhe =  F_ETAT_ADHE(a_idadhesion=> a.idadhesion, a_date    => sysdate, a_type=>5)
       AND ha.datsai         BETWEEN add_months(trunc(sysdate),-1) and trunc(sysdate) -- on prend sur le mois
      AND ha.etat <> 3
      AND a.datper is null
      AND MAJ > trunc(sysdate, 'MONTH')
      AND exists (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND trunc(sysdate) BETWEEN fps.DEBUT and nvl(fps.fin, sysdate) and fps.VALIDE ='O')
      and not exists(select 1 from adhesion a2 where a2.numindiv = a.numindiv and datapli is  null )-- verifie que le bénéficiaire n'a jamais eu de couverture sur cette adhesion
  )  DATAS
  WHERE c.numgar = datas.numgar
  GROUP BY c.numcli
  HAVING COUNT(DISTINCT datas.idadhesion ) > 0;


BEGIN

  IF TRIM(TO_CHAR(sysdate, 'DAY', 'NLS_DATE_LANGUAGE=French') )='LUNDI' THEN -- on envoi tous les lundis
    FOR r_adhesions_instance in c_adhesions_instance LOOP
      FOR r_interlocuteur IN C_INTERLOCUTEURs(r_adhesions_instance.numcli)  LOOP

        SELECT corps_msg, sujet_msg
        INTO l_corps,loc_envoi.sujet
        FROM mail_texte
        WHERE id_texte = 31;  -- accusé de reception souscription lambda

        loc_envoi.corps:= REPLACE(l_corps, '#NB_ADH', r_adhesions_instance.nb_adh)   ;

        loc_envoi.numenvoimail := null;
       loc_envoi.NUMINDIV_DEST:=r_interlocuteur.interlocuteur;
        loc_envoi.NUMBENE:=r_interlocuteur.interlocuteur;
        loc_envoi.destinataire := f_coordonne_contact(r_interlocuteur.interlocuteur,4,1);
        loc_envoi.NUMUTIL:= F_NUMUTIL;
        loc_envoi.etendue:= 0;   -- rendre le contexte dynam
        loc_envoi.clef:= 0;        -- changer le contexte
        loc_envoi.IDTEXTE:= 31;
        loc_envoi.TYPE_MAIL:=3;   -- Automatique
        loc_envoi.DATE_CREATION:=SYSDATE;
  	    loc_envoi.template_mail :=2;
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_MAIL_INTERLOCUTEUR',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>    loc_envoi.corps, I_idligne  => 4);
        PK_MAIL.CREER_MAIL(loc_envoi);

      END LOOP;
    END LOOP;
   END IF;
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_MAIL_INTERLOCUTEUR',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  => 'Envoi des messages de contrat disponible terminé, debut de l''envoi des message sur les mouveements', I_idligne  => 4);

   IF to_char(SYSDATE,'DD') = '10' THEN -- envoyé tous les 10 du mois
   -- ENVOI de mail concernant les adhésion mouvementés
    FOR r_adhesion_mouvement in c_adhesion_mouvement LOOP
      IF  r_adhesion_mouvement.nb_adh >0 THEN
        FOR r_interlocuteur IN C_INTERLOCUTEURs(r_adhesion_mouvement.numcli)  LOOP

          SELECT corps_msg, sujet_msg
          INTO l_corps,loc_envoi.sujet
          FROM mail_texte
          WHERE id_texte = 32;  --  il y a des adhésions mouvementées, va me voir ça m'in fiu! #Je suis fatigué, on verra bien si quelqu'un vois ce commentaire, si c'est le cas SALUTATION!

         -- loc_envoi.corps:= REPLACE(l_corps, '#NB_ADH', r_adhesions_instance.nb_adh)   ;

          loc_envoi.numenvoimail := null;
          loc_envoi.NUMINDIV_DEST:=r_interlocuteur.interlocuteur;
          loc_envoi.NUMBENE:=r_interlocuteur.interlocuteur;
          loc_envoi.destinataire := f_coordonne_contact(r_interlocuteur.interlocuteur,4,1);
          loc_envoi.NUMUTIL:= 250;
          loc_envoi.etendue:= 0;   -- rendre le contexte dynam
          loc_envoi.clef:= 0;        -- changer le contexte
          loc_envoi.IDTEXTE:= 32;
          loc_envoi.TYPE_MAIL:=3;   -- Automatique
          loc_envoi.DATE_CREATION:=SYSDATE;
    	    loc_envoi.template_mail :=2;
          PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_MAIL_INTERLOCUTEUR',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>    loc_envoi.corps, I_idligne  => 4);
          PK_MAIL.CREER_MAIL(loc_envoi);

        END LOOP;
      END IF;
    END LOOP;
   END IF;
END P_MAIL_INTERLOCUTEUR;

    /******************************************************************************/
FUNCTION CHECK_HEALTH RETURN GENERIQUE_WS_RESP
  IS
  BEGIN

      RETURN  PK_WS_WEB_MAJ_BACK.GET_RESP_OK(0,0,0,19);

  END CHECK_HEALTH;

/*********************************************************/
FUNCTION ADD_RIB( i_numporte  IN NUMBER,
                  i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                  i_numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                  i_numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                  i_idDemande_ext IN NUMBER,
                  i_bic IN VARCHAR2,
                  i_bban IN VARCHAR2,
                  i_clefIban IN VARCHAR2,
                  i_typeRib IN NUMBER,
                  i_domiciliation IN VARCHAR2,
                  i_nomTitulaire  IN VARCHAR2,
                  i_dateEffet     IN DATE,
                  i_beneficiares  IN EXTR_TAB_BENEFICIAIRE ,
                  i_documents       IN EXT_TAB_DOCUMENT
  ) RETURN GENERIQUE_WS_RESP
  IS
 loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  l_code_demande    NUMBER;
  loc_numutil     UTILISATEURS.NUMUTIL%TYPE;
  l_nature        RIB.nature%TYPE;
  l_codbque       RIB.codbque%TYPE;
  l_guichet       RIB.guichet%TYPE;
  l_compte        RIB.compte%TYPE;
  l_clerib        RIB.clerib%TYPE;
  l_codpays       RIB.codpays%TYPE :=1;
  loc_code_erreur loc_rappel.code_err%TYPE;
  Code_Retour     NUMBER;
  i               NUMBER  := 1;
  l_bic           RIB.bic%TYPE;
  l_id_rib        RIB.IDRIB%type;
  lib_type_rib    VARCHAR2(45);
  loc_dateEffet DATE;

  l_numindiv_benerib_parent  INDIVIDU.NUMINDIV%TYPE;
  v_numindiv_rib  INDIVIDU.NUMINDIV%TYPE;

  BEGIN
    l_code_demande := get_code_demande(i_id_type,i_numporte);

    select decode(i_typeRib,1,'Décaissement', 2, 'Encaissement', 'Inconnu' ) INTO lib_type_rib from dual;
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;


  loc_rappel.contexte  := l_context_rappel;
  loc_rappel.type      :=  l_code_demande;
  loc_rappel.reference := i_idDemande_ext;
  loc_rappel.creation  := sysdate;
  loc_rappel.createur  := loc_numutil;
  loc_rappel.etat      := 1 ;
  loc_rappel.origine    := i_numporte;
  loc_rappel.DATEEFFET  := i_dateEffet;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.commentaire :=   'Adhérent : '          || i_numAdherent   ||';'||CHR(13)||CHR(10)||
                              'Individu : '          || i_numIndiv      ||';'||CHR(13)||CHR(10)||
                              'Demande extérieure : '|| i_idDemande_ext ||';'||CHR(13)||CHR(10)||
                              'Bic : '                 ||i_bic            ||';'||CHR(13)||CHR(10)||
                              'Bban : '                ||i_bban           ||';'||CHR(13)||CHR(10)||
                              'Clef iban : '            ||i_clefIban       ||';'||CHR(13)||CHR(10)||
                              'Type de Rib : '             ||i_typeRib        ||';'||CHR(13)||CHR(10)||
                              'Lib Type de Rib : '         ||lib_type_rib     ||';'||CHR(13)||CHR(10)||
                              'Domiciliation : '       ||i_domiciliation  ||';'||CHR(13)||CHR(10)||
                              'Nom titulaire : '        ||i_nomTitulaire   ||';'||CHR(13)||CHR(10)||
                              'Date d''effet : '           ||d2e(i_dateEffet)      ||';'||CHR(13)||CHR(10)||
                              'Bénéficiaires : '
                             ;
  i:=1;
  WHILE i <= i_beneficiares.COUNT LOOP
        loc_rappel.commentaire := loc_rappel.commentaire||  i_beneficiares(i).numIndiv ||',';
        -- on ne met pas a jour les lignes concernant l'assuré lui même
    i:=i+1;
  END LOOP;
  loc_rappel.commentaire :=loc_rappel.commentaire||';'||CHR(13)||CHR(10)|| 'Documents : ';
  WHILE i <= i_documents.COUNT LOOP
    loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
    i:=i+1;
  END LOOP;
  i:=1;

  loc_rappel.commentaire := loc_rappel.commentaire||';';


  /*erreurs :
  La clef IBAN est incorrecte  La clef IBAN est contrôlée par rapport au BBAN. Elle doit être au format SEPA.
  Le BIC est incorrect, il doit être composé 8 ou 11 caractères  Si le BIC est saisi, il doit être de 8 ou 11 caractères.
  */
  -- récupération du porteur du prochain rib
  l_numindiv_benerib_parent := GET_FIRST_NOT_CHILD(i_beneficiares,i_numAdherent,i_numindiv );
  loc_rappel.entite :=  l_numindiv_benerib_parent;
  loc_rappel.numbene := l_numindiv_benerib_parent;

   loc_dateEffet := greatest(i_dateEffet, sysdate);
  -- récupération du rib en cours.
  select f_bene_rib (l_numindiv_benerib_parent, 0, 0, i_typeRib,null,loc_dateEffet) into  l_id_rib  from dual;

   -- récupération des informations du nouveau RIB
  PK_virement.P_sel_rib ( I_codpays    =>  l_codpays,
                          I_clef_iban  =>    i_clefIban,
                          I_bban      =>    i_bban,
                          O_codbque   =>    l_codbque,
                          O_guichet   =>    l_guichet,
                          O_compte    =>    l_compte,
                          O_clerib    =>    l_clerib,
                          O_retour    =>  Code_Retour);

  IF i_clefIban IS NULL THEN
    loc_rappel.code_err:= 2110;
    loc_rappel.etat:=4;--rejeté
  ELSIF I_BBAN IS NULL THEN
    loc_rappel.code_err:= 2111;
    loc_rappel.etat:=4;--rejeté
  /*ELSIF I_BIC IS NULL THEN
    loc_rappel.code_err:= 2112;
    loc_rappel.etat:=4;--rejeté  */
  ELSIF NOT PK_SEPA.F_IS_IBAN(i_clefIban,i_bban) THEN
    loc_rappel.code_err:= 2044;
    loc_rappel.etat:=4;--rejeté
  ELSIF I_BIC IS NOT NULL AND  LENGTH(I_BIC) not in (8,11) THEN
    loc_rappel.code_err:= 2076;
    loc_rappel.etat:=4;--rejeté
  -- verification de la différence entre le nouveau et l'ancien RIB.
  ELSIF IS_RIB_DIFFERENT(l_id_rib,i_BIC, i_BBAN , l_clerib  ) = 2197 THEN
    loc_rappel.code_err:= 2197;
    IF i_beneficiares.COUNT =0 THEN --on rejette uniquement si aucun bénéficaire
      loc_rappel.etat:=4;--rejeté
    END IF;
  ELSIF i_dateEffet IS NULL  THEN
    loc_rappel.code_err:= 2211;
    loc_rappel.etat:=4;--rejeté
  -- verification de la date de chevauchement
  ELSIF IS_RIB_AFTER_CURRENT(l_id_rib,loc_dateEffet) = 2196 THEN
      loc_rappel.code_err:= 2196;
      loc_rappel.etat:=4;--rejeté
  END IF;



  INSERT INTO rappel VALUES loc_rappel;
  IF i_documents.COUNT>0 THEN
    INSERT_LIEN_GED(i_documents, 30,loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil,loc_rappel.idrappel);
  END IF;
  COMMIT;

  IF loc_rappel.etat = 4  THEN
      IF loc_rappel.code_err = 2197 THEN
        RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));
      END IF;
        RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  END IF;


  IF i_typeRib = 1 THEN

    -- 1-  Modification du RIB de l’adhérent : historisation de la coordonnée bancaire de remboursement de prestation santé existante et
    -- parcours des adhésions individuelles existantes pour le cas où l’adhérent est bénéficiaire d’une autre adhésion (cas d’une double adhésion conjoint)
    IF i_numAdherent = i_numIndiv THEN
      -- MISE A jour des bénéficiaires dans ADHECNTRT_MEMBRE
      -- pour chaque adhesion de l'assuré. et pour chaque bénéficiaires passés en paramétre
      UPDATE ADHE_CNTRT_MEMBRE
        SET NUMBENE     = NULL
        WHERE NUMINDIV IN (SELECT NUMINDIV FROM TABLE (i_beneficiares))
        AND IDADHESION IN (
          SELECT idadhesion from adhe_cntrt
          where numadhe = i_numAdherent
          and (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate) OR date_adhe > nvl(loc_dateEffet,sysdate) ))
        AND NUMBENE IS NOT NULL
        AND TYPADR <> 0 ;  -- on ne met pas a jour les lignes concernant l'assuré lui même

       --cas de multiples adhésions pour lesquelles l'adhérent est bénéficiaire
        UPDATE ADHE_CNTRT_MEMBRE
        SET NUMBENE     = i_numAdherent
        WHERE NUMINDIV IN (SELECT NUMINDIV FROM TABLE (i_beneficiares))
        AND IDADHESION NOT IN (
          SELECT idadhesion from adhe_cntrt
          where numadhe = i_numAdherent
          and (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate) OR date_adhe > nvl(loc_dateEffet,sysdate) ))
        AND IDADHESION IN (
          SELECT idadhesion from adhe_cntrt
          where numadhe <> i_numAdherent
          and (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate) OR date_adhe > nvl(loc_dateEffet,sysdate) ))
        ;

      COMMIT;
    -- 2-  Modification du RIB d’un bénéficiaire : process identique au précédent avec en plus une prise en compte du type de bénéficiaire transmis dans le flux.
    -- Si la liste des bénéficiaires contient un conjoint alors le rib est ajouté au conjoint et les rib par défaut des autres bénéficiaires présents dans la liste pointeront sur ce rib.
    ELSE
      -- MISE A jour des bénéficiaires dans ADHECNTRT_MEMBRE
      -- pour chaque adhesion de l'assuré. et pour chaque bénéficiaires passés en paramétre
      UPDATE ADHE_CNTRT_MEMBRE
      SET NUMBENE     = l_numindiv_benerib_parent
      WHERE NUMINDIV  IN (SELECT NUMINDIV FROM TABLE (i_beneficiares))
        OR NUMINDIV = l_numindiv_benerib_parent
      AND IDADHESION IN (
        SELECT idadhesion FROM adhe_cntrt
        WHERE numadhe = i_numAdherent
        AND (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate) OR date_adhe > nvl(loc_dateEffet,sysdate)))
      AND TYPADR <> 0 ;
      -- On remet les anciens bénéficiaires ratachés au détenteur du RIB sur l'assuré Principale
      UPDATE ADHE_CNTRT_MEMBRE
      SET NUMBENE = NULL
      WHERE NUMINDIV  NOT IN (SELECT NUMINDIV FROM TABLE (i_beneficiares))
      AND NUMBENE = l_numindiv_benerib_parent
      AND IDADHESION IN (
        SELECT idadhesion FROM adhe_cntrt
        WHERE numadhe = i_numAdherent
        AND (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate) OR date_adhe > nvl(loc_dateEffet,sysdate) ))
      AND TYPADR <> 0 ;
    END IF;

    IF loc_rappel.code_err IS NULL THEN
      --historisation
      UPDATE RIB SET FIN = nvl(loc_dateEffet-1,sysdate)
      WHERE RIB.IDRIB = l_id_rib   -- fermeture du rib en cours.
      OR (  MODPMT = 1                        -- ou alors les paiment en lettre chéque qui ont la même
        AND trunc(debut) IN (trunc(sysdate),trunc(loc_dateEffet))   -- sysdate pour les individus créés aujourd'hui i_date_effet pour les
        AND type = i_typeRib
        AND numindiv = i_numAdherent
        and fin is  null
      );

      COMMIT;

      --insertion
      INSERT INTO rib(  idrib,
                        type,
                        numindiv,
                        numgar,
                        codope,
                        modpmt,
                        intitule,
                        debut,
                        devise_compte,
                        devise_ope,
                        creation,
                        numutil_creation,
                        nature,
                        codbque,
                        guichet,
                        compte,
                        clerib,
                        bban,
                        clef_iban,
                        codpays,
                        bic,
                        domiciliation)
          SELECT        idrib.nextval,
                        1,--i_typeRib
                        l_numindiv_benerib_parent,
                        0,
                        0,
                        2,
                        i_nomTitulaire,
                        nvl(loc_dateEffet,sysdate),
                        pk_devise.devise_ref,
                        pk_devise.devise_ref,
                        sysdate,
                        loc_numutil,
                        2,
                        l_codbque,
                        l_guichet,
                        l_compte,
                        l_clerib,
                        i_bban,
                        i_clefIban,
                        1,
                        i_bic,
                        i_domiciliation
        FROM  dual;

    END IF;
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 3);
    COMMIT;
  ELSE --i_typeRib=2
  -- automatisation de l'intégration des rib d'encaissement a la demande de Gerep.
    loc_rappel.code_err := F_VALIDE_ADD_RIB(loc_rappel.idrappel,i_numporte);
    IF loc_rappel.code_err <>0     THEN
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 4); -- sinon on laisse le gestionnaire traité la demande
    ELSE
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 3);
    END IF;
  END IF;
   PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));

  EXCEPTION
     WHEN OTHERS THEN
          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'PK_WEB_MAJ.ADD_RIB',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
          I_idligne  => 2);
        SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
        RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2185,1));


  END ADD_RIB;
 /********************************************************************/

  FUNCTION CLOSE_RIB( i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      i_numIndiv IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext IN NUMBER,
                      i_idRib IN NUMBER,
                      i_dateEffet     IN DATE
                   )
  RETURN GENERIQUE_WS_RESP
   IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande    NUMBER;
  l_idrib  RIB.idrib%TYPE;
  v_idrib  RIB.idrib%TYPE;
      BEGIN
          l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;
  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.entite := i_numindiv;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 3 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.DATEEFFET  := i_dateEffet;
  loc_rappel.numbene     := i_numIndiv;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.commentaire :=   'Adhérent : '          || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                              'Individu : '          || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                              'Demande exterieure : '|| i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                              'IdRib :'               ||i_idRib||          ';'||CHR(13)||CHR(10)||
                              'DateEffet: '           ||d2e(i_dateEffet)     || ';'
                             ;
  --loc_rappel.RESPONSABLE := 1234; --TODO Comment determiner le respondable?
  INSERT INTO rappel VALUES loc_rappel;
  COMMIT;


    -----
    IF i_numAdherent = i_numindiv THEN  -- cas de fermeture d'un rib de l'adhérent => pas possible
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2193, 4);
     RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2193,1)/*Il n''est pas possible de repasser en mode chéque via l''espace assuré, merci d''ajouter un autre rib.*/);
    ELSE
    -- verification de l'existance du rib
      BEGIN
        SELECT idrib
        INTO l_idrib
        FROM RIB r
        WHERE r.idrib = i_idrib
        AND r.nature = 2
        and r.numindiv  = i_numindiv;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2194, 4);
          RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2194,1)/*'Le couple RIB/Individu n''a pas pu être trouvé'*/);
      END;
      -- verification de l'ouverture du rib
      l_idrib:=null;
      BEGIN
        SELECT idrib
        INTO l_idrib
        FROM RIB r
        WHERE r.idrib = i_idrib
        AND r.nature = 2
        and r.numindiv  = i_numindiv
        and r.FIN IS NOT NULL;

        IF l_idrib IS NOT NULL THEN
          SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2195, 4);
          RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2195,1)/*'Le RIB a déjà été fermé précédemment.'*/);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           null;
      END;

      -- historisation du rib du bénéficiaire
      UPDATE RIB SET FIN = nvl(i_dateEffet,sysdate)
      WHERE RIB.IDRIB = i_idrib;
      COMMIT;
      -- passage en mode chéque
     SELECT   idrib.nextval
      INTO  v_idrib
      FROM  Dual;
     INSERT INTO rib( idrib,
                      type,
                      numindiv,
                      numgar,
                      codope,
                      modpmt,
                      intitule,
                      debut,
                      devise_compte,
                      devise_ope,
                      creation,
                      numutil_creation,
                      nature,
                      codpays)
      SELECT          v_idrib,
                      1,--i_typeRib
                      i_numindiv,
                      0,
                      0,
                      1,
                      F_nom(i_numindiv),
                      nvl(i_dateEffet,sysdate),
                      pk_devise.devise_ref,
                      pk_devise.devise_ref,
                      sysdate,
                      loc_numutil,
                      1,
                      1
    FROM  dual;


    -- mise a jours des bénéficaires anciennement sur le numindiv
   UPDATE ADHE_CNTRT_MEMBRE
          SET NUMBENE = NULL
          WHERE  NUMBENE = i_numindiv
          AND IDADHESION IN (SELECT idadhesion FROM adhe_cntrt WHERE numadhe = i_numAdherent AND (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate) OR date_adhe > nvl(i_dateEffet,sysdate) ))
          AND TYPADR <> 0 ;

          COMMIT;
    END IF;

   PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));
EXCEPTION
   WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'PK_WEB_MAJ.CLOSE_RIB',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
      I_idligne  => 2);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
    RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
  END CLOSE_RIB;

/**********************************************************/
FUNCTION ADD_CONTACT(  i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      i_numindiv IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext IN NUMBER,
                      i_contact IN VARCHAR2,
                      i_nature IN NUMBER,
                      i_type IN NUMBER,
                      i_dateEffet IN DATE
) RETURN GENERIQUE_WS_RESP
IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  l_code_demande    NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_idcontact CONTACT.IDCONTACT%TYPE;
  l_idNewContact CONTACT.IDCONTACT%TYPE;
  l_is_nature_exist NUMBER;
  l_is_indiv_exist NUMBER;
  l_is_type_exist NUMBER;
  l_message_erreur Varchar2(250) := '';
  l_contact_mail_ok NUMBER(1);
  l_doublon NUMBER :=0;
  l_libelle_nature libelle.libelle%type;
  l_template_mail number:=1; -- permet de faire la distinction entre un interolucteur qui modifie une coordonnée professionel auquel cas on utilise le template société
BEGIN
    l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  BEGIN
   SELECT libelle
   INTO l_libelle_nature
   FROM libelle
   WHERE mnemo = 'NAT_CONT'
   AND CODE =i_nature;
  EXCEPTION WHEN OTHERS THEN
    l_libelle_nature:='Inconnue';
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.entite := i_numindiv;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 3 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.DATEEFFET  := i_dateEffet;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.numbene     := i_numIndiv;
  loc_rappel.commentaire :=  'Adhérent : '          || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '          || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande exterieure : '|| i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Tel ou Mail : '       || i_contact       ||';'|| CHR(13)||CHR(10)||
                             'Nature : '            || i_nature        ||';'|| CHR(13)||CHR(10)||
                             'Lib Nature : '        || l_libelle_nature     ||';'|| CHR(13)||CHR(10)||
                             'Type : '              || i_type          ||';'|| CHR(13)||CHR(10)||
                             'Date d''effet : '     || d2e(i_dateEffet)     ||';'
                             ;

  --loc_rappel.RESPONSABLE := 1234; --TODO Comment determiner le respondable?
  INSERT INTO rappel VALUES loc_rappel;
  COMMIT;


  BEGIN
    -- verification des données
    BEGIN
      IF   i_nature = 4  THEN
        SELECT 1
        INTO l_contact_mail_ok
        FROM DUAL
        WHERE regexp_like(i_contact,'^[A-Za-z0-9]+[A-Za-z0-9._-]+@[A-Za-z0-9._-]+\.[A-Za-z]{2,4}$');
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      l_message_erreur := 'Le format e-mail n''est pas respecté';
    END;

    BEGIN
      SELECT DISTINCT 1
      INTO l_is_nature_exist
      FROM LIBELLE
      WHERE CODE  = i_nature
      AND MNEMO = 'NAT_CONT';  -- verifie que le type de coordonées est bien existant.
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
     IF l_message_erreur IS  NULL THEN
        l_message_erreur := 'La nature de coordonnée n''est pas identifiée' ;
       ELSE
        l_message_erreur := l_message_erreur||', La nature de coordonnée n''est pas identifiée' ;
       END IF;
    END;

    BEGIN
      SELECT DISTINCT 1
      INTO l_is_type_exist
      FROM LIBELLE
      WHERE CODE  = i_type
      AND MNEMO = 'TYPE_CONTA';  -- verifie que le type de coordonées est bien existant.
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
     IF l_message_erreur IS  NULL THEN
        l_message_erreur := 'Le type de coordonnée n''est pas identifié' ;
       ELSE
        l_message_erreur := l_message_erreur||', le type de coordonnée n''est pas identifié' ;
       END IF;
    END;

    BEGIN
      SELECT DISTINCT 1
      INTO l_is_indiv_exist
      FROM INDIVIDU
      WHERE NUMINDIV = i_NUMINDIV;      -- verifie que l'invividu existe
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      IF l_message_erreur IS  NULL THEN
          l_message_erreur := 'Assuré non reconnu' ;
      ELSE
          l_message_erreur := l_message_erreur ||', assuré non reconnu' ;
      END IF;
    END;
    IF l_message_erreur IS NOT  NULL THEN
        SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2187, 4);
        RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2187,1)||' '||l_message_erreur);
    END IF;
  END;

  BEGIN
    SELECT IDCONTACT INTO l_idcontact FROM CONTACT
    WHERE NUMINDIV = i_numindiv
    AND NATURE =   i_nature
    AND TYPE = i_type
    AND FLAG ='O';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_idcontact:=null;
    WHEN TOO_MANY_ROWS THEN
      l_idcontact:= 0 ;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 1);  -- Si il  y a trop de ligne raménée, alors c'est le gestionnaire qui prend la main, grace a un rappel
  END;
    BEGIN
      null;
    EXCEPTION WHEN OTHERS THEN
    l_doublon := 0;
    END;
  /*  Detection des abus   */
  BEGIN
    SELECT distinct 2224 INTO l_doublon
      FROM CONTACT
      WHERE NUMINDIV = i_numindiv
      AND NATURE =   i_nature
      AND TYPE= i_type
     -- AND TYPE = 2   -- CLI on recherche les doublon aussi dans les adresses professionnels
      AND FLAG ='O'
      AND COORDONNEE = i_contact;
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, l_doublon, 4);
    --on ne créé par la coordonnée en doublon, la demande est rejeté mais on renvoie un OK à l'extranet, pas de mail d'accusé réception
    RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      l_idcontact:= 0 ;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 1);
      --RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(l_doublon,1));   -- Si il  y a trop de ligne raménée, alors c'est le gestionnaire qui prend la main, grace a un rappel
    WHEN OTHERS THEN NULL;
  END;


    /** FIN de detection des doublons***/
  IF l_idcontact IS NULL OR l_idcontact <> 0  THEN
   SELECT ARTHUS.IDCONTACT.NEXTVAL INTO l_idNewContact FROM DUAL;
    UPDATE CONTACT
      SET FLAG = 'N'
      WHERE IDCONTACT in (
      select idcontact FROM CONTACT
        WHERE NUMINDIV = i_numindiv
        AND NATURE = i_nature
        AND type = i_type
        AND FLAG ='O');

    INSERT INTO CONTACT (NUMINDIV, NATURE, TYPE, COORDONNEE, FLAG, CREATION, MAJ, NUMUTIL, IDCONTACT)
      VALUES  (i_numIndiv, i_nature, i_type, i_contact, 'O', sysdate, null,loc_numutil, l_idNewContact);
    COMMIT;
  END IF;

   BEGIN
   select 2 into l_template_mail from interlocuteur i where i.interlocuteur = i_numindiv and ope_crrr = 8 and i_type =1 ; -- permet de savoir quel template utiliser
   EXCEPTION WHEN OTHERS THEN null;
   END;
   IF F_IS_HORS_BIA(i_numAdherent) = 1 and i_type = 2  THEN
      PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite, null,l_template_mail ); -- création du mail accusé de reception
   END IF;
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));
EXCEPTION
   WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'PK_WEB_MAJ.ADD_CONTACT',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
        I_idligne  => 2);
        SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
        RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
END ADD_CONTACT;

    /**********************************************************/
FUNCTION ADD_ADRESSE(  i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                      i_numindiv      IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext IN NUMBER,
                      i_adresse       IN EXTR_ADRESSE_TR,
                      i_dateEffet     IN DATE
) RETURN GENERIQUE_WS_RESP
IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  l_code_demande    NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_info_exist      NUMBER := 0;
  loc_idadresse_encours   PERS_ADRESSE.IDADRESSE%TYPE:=NULL;
  loc_adresse_base VARCHAR2(400);
  P_PERS_ADRESSE  PERS_ADRESSE%ROWTYPE;
  loc_numindiv  INDIVIDU.numindiv%TYPE;
BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;
  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.entite := i_numindiv;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.DATEEFFET  := i_dateEffet;
  loc_rappel.numbene     := i_numIndiv;
  loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande exterieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Adresse :'                        || CHR(13)||CHR(10)||
                             'Adresse 1 :'                     || i_adresse.ADRESSE1 ||';'|| CHR(13)||CHR(10)||
                             'Adresse 2 :'                     || i_adresse.ADRESSE2 ||';'|| CHR(13)||CHR(10)||
                             'Adresse 3 :'                     || i_adresse.ADRESSE3 ||';'|| CHR(13)||CHR(10)||
                             'Ville :'                        || i_adresse.VILLE ||';'|| CHR(13)||CHR(10)||
                             'Code postal :'                       || i_adresse.CODPOS ||';'|| CHR(13)||CHR(10)||
                             'Pays :'                         || i_adresse.PAYS ||';'|| CHR(13)||CHR(10)||
                             'Date d''effet :'                || d2e(i_dateEffet) ||';'
                             ;

  --loc_rappel.RESPONSABLE := 1234; --TODO Comment determiner le respondable?
  INSERT INTO rappel VALUES loc_rappel;
  COMMIT;

  loc_idadresse_encours:= PK_PERSONNE.F_IDADRESSE(i_numindiv);


  -- on determine quelle ligne est la ligne porteuse de la rue
  IF PK_PERSONNE.F_DECOMPOSE(UPPER(i_adresse.ADRESSE1),1) IS NOT NULL THEN
    loc_adresse_base := PK_WS_WEB_MAJ_BACK.F_FORMAT(i_adresse.ADRESSE1);
    P_PERS_ADRESSE.ADRESSE_2:=upper(PK_WS_WEB_MAJ_BACK.F_FORMAT(i_adresse.ADRESSE2));
    IF i_adresse.ADRESSE3 IS NOT NULL THEN
    --TODO gestion manuelle
    loc_rappel.code_err     := 1 ;
    END IF;
  ELSIF PK_PERSONNE.F_DECOMPOSE(UPPER(i_adresse.ADRESSE2),1) IS NOT NULL THEN
    loc_adresse_base := upper(PK_WS_WEB_MAJ_BACK.F_FORMAT(i_adresse.ADRESSE2));
    P_PERS_ADRESSE.COMP_ADRESSE:= upper(PK_WS_WEB_MAJ_BACK.F_FORMAT(i_adresse.ADRESSE1));
    P_PERS_ADRESSE.ADRESSE_2:=upper(PK_WS_WEB_MAJ_BACK.F_FORMAT(i_adresse.ADRESSE3));

  ELSIF i_adresse.ADRESSE3 IS NOT NULL THEN --on pas de numéro de rue
    P_PERS_ADRESSE.COMP_ADRESSE:=upper(PK_WS_WEB_MAJ_BACK.F_FORMAT(i_adresse.ADRESSE1));
    P_PERS_ADRESSE.NOM_VOIE:= upper(PK_WS_WEB_MAJ_BACK.F_FORMAT(i_adresse.ADRESSE2));
    P_PERS_ADRESSE.ADRESSE_2:= upper(PK_WS_WEB_MAJ_BACK.F_FORMAT(i_adresse.ADRESSE3));
  ELSE
    P_PERS_ADRESSE.COMP_ADRESSE:=upper(i_adresse.ADRESSE1);
    P_PERS_ADRESSE.ADRESSE_2:=upper(i_adresse.ADRESSE2);
  END IF;

  IF loc_adresse_base IS NOT NULL THEN
    P_PERS_ADRESSE.NO_VOIE:= upper(PK_PERSONNE.F_DECOMPOSE(loc_adresse_base,1));
    P_PERS_ADRESSE.NOM_VOIE:=upper(PK_PERSONNE.F_DECOMPOSE(loc_adresse_base,4));
    P_PERS_ADRESSE.TYPE_VOIE := upper(PK_PERSONNE.F_DECOMPOSE( loc_adresse_base, 3));
    P_PERS_ADRESSE.BIS := upper(PK_PERSONNE.F_DECOMPOSE( loc_adresse_base, 2));
  END IF;

  P_PERS_ADRESSE.CODPOS := i_adresse.CODPOS;
  P_PERS_ADRESSE.VILLE  := UPPER(i_adresse.VILLE);
  P_PERS_ADRESSE.TYPE := 1;   --personnelle
  P_PERS_ADRESSE.NUMGAR := 0;
  P_PERS_ADRESSE.DEFAUT := 'O';
  P_PERS_ADRESSE.FLAG_CEDEX:= 'N';
  P_PERS_ADRESSE.NPAI:= 'N';
  P_PERS_ADRESSE.CODOPE := 0;
  P_PERS_ADRESSE.codpays:= 1;--i_adresse.PAYS;

  -- verification si l'adresse a changé par rapport a l'ancienne
  SELECT NVL(MAX(NUMINDIV),0)
    INTO loc_numindiv
    FROM PERS_ADRESSE p
   WHERE p.NUMINDIV = I_NUMINDIV
     AND p.NO_VOIE  = P_PERS_ADRESSE.NO_VOIE
     AND p.DEFAUT   = 'O'
     AND NVL( PK_WS_WEB_MAJ_BACK.F_FORMAT(p.NOM_VOIE),0) = NVL(PK_WS_WEB_MAJ_BACK.F_FORMAT(P_PERS_ADRESSE.NOM_VOIE),0)
     AND p.CODPOS = P_PERS_ADRESSE.CODPOS
     AND PK_WS_WEB_MAJ_BACK.F_FORMAT(p.VILLE) = PK_WS_WEB_MAJ_BACK.F_FORMAT(P_PERS_ADRESSE.VILLE)
     AND NVL(PK_WS_WEB_MAJ_BACK.F_FORMAT(p.COMP_ADRESSE),0) = NVL(PK_WS_WEB_MAJ_BACK.F_FORMAT(P_PERS_ADRESSE.COMP_ADRESSE),0)
     AND NVL(PK_WS_WEB_MAJ_BACK.F_FORMAT(p.ADRESSE_2),0) = NVL(PK_WS_WEB_MAJ_BACK.F_FORMAT(P_PERS_ADRESSE.ADRESSE_2),0)
     --AND PK_WS_WEB_MAJ_BACK.F_FORMAT(DECODE( nvl(loc_numvoie,1),1,p.COMP_ADRESSE, p.ADRESSE_2))  =  PK_WS_WEB_MAJ_BACK.F_FORMAT(DECODE( nvl(loc_numvoie,1),1, P_PERS_ADRESSE.COMP_ADRESSE, P_PERS_ADRESSE.ADRESSE_2))
     AND p.IDADRESSE = loc_idadresse_encours -- récupère la dernière adresse saisie
     ;

  IF loc_numindiv = 0 OR loc_numindiv IS NULL THEN
    SELECT idadresse.nextval
    INTO P_PERS_ADRESSE.idadresse
    FROM dual;
    P_PERS_ADRESSE.NUMUTIL:= loc_numutil;
    P_PERS_ADRESSE.NUMINDIV :=  i_numindiv;
    P_PERS_ADRESSE.DEBUT:=nvl(i_dateEffet,sysdate);
    P_PERS_ADRESSE.MAJ:= sysdate;

    UPDATE PERS_ADRESSE p         -- Deselection des autres adresse potentiellement par defaut
      SET  p.DEFAUT = 'N'
      WHERE p.NUMINDIV = I_NUMINDIV
      AND DEFAUT = 'O';
    INSERT INTO PERS_ADRESSE VALUES  P_PERS_ADRESSE;
    COMMIT;
   ELSE
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2186, 4);   -- adresse par defaut
    RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));
   END IF;

  SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 3);
  PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));

EXCEPTION
 WHEN VALUE_ERROR THEN
  --traitement manuel
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2185, 1);    --maj corbeille
    IF F_IS_HORS_BIA(i_numAdherent) = 1 THEN
      PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
    END IF;
  RETURN GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte),pk_trace.F_AFF_mess_err(2185,1));
 WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'PK_WEB_MAJ.ADD_ADRESSE', I_session  => SID, I_niv_msg  => 3,   I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),   I_idligne  => 2);
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
  RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
END ADD_ADRESSE;

     /********************************************************/
FUNCTION ADD_BENEFICIAIRE( i_numporte         IN NUMBER,
                           i_id_type          IN TYPE_FLUX.ID_TYPE%TYPE,
                           i_numAdherent      IN NUMBER,
                           i_idDemande_ext    IN NUMBER,
                           i_typebeneficiaire IN NUMBER,
                           i_nom              IN VARCHAR2,
                           i_prenom           IN VARCHAR2,
                           i_datenaiss        IN DATE,
                           i_rangNais         IN NUMBER,
                           i_sexe             IN NUMBER,
                           i_numss            IN VARCHAR2,
                           i_regime           IN VARCHAR2,
                           i_caisse           IN VARCHAR2,
                           i_centre           IN VARCHAR2,
                           i_numss2           IN VARCHAR2,
                           i_regime2          IN VARCHAR2,
                           i_caisse2          IN VARCHAR2,
                           i_centre2          IN VARCHAR2,
                           i_dateeffet        IN DATE,
                           i_mutuelleExist    IN NUMBER,
                           i_documents        IN EXT_TAB_DOCUMENT
                          )
RETURN EXTR_R_ADD_BENEFICIAIRE --GENERIQUE_WS_RESP
 IS
  /*variable de verif*/
  loc_etat    Number;
  L_numgar    Number;
  L_numfor       Number;
  L_edatapli     Number;
  L_idadhesion   Number;
  L_numadhe   INDIVIDU.NUMINDIV%TYPE;

  l_tomany_rows_nni NUMBER :=0;
  /* fin variable de verif*/
  --l_num_indiv_tiers Tiers.numindiv%TYPE := 123456789;

   loc_prch  PRCH%ROWTYPE;
  l_message_erreur mess_erreur.lib_msg%TYPE;
  --l_numsec tiers.numsec%TYPE;

  loc_rappel RAPPEL%ROWTYPE;
  l_type_demande NUMBER := 1;
  l_context_rappel NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande NUMBER;
  l_beneficiaire_existant individu.numindiv%TYPE;
  i NUMBER :=1;
  loc_beneficiaire individu%ROWTYPE;
  loc_erreur  VARCHAR2(4000);
  l_lien_ged  LIEN_GED%ROWTYPE;
  l_err_numss  number;
  l_err_regime NUMBER;
  l_is_od NUMBER;
  loc_nopiece number := null;
  l_IS_BENE_DOUBLON NUMBER;
  l_IS_BENE_DOUBLON_groupe NUMBER;

  l_regime  VARCHAR2(3);
  l_caisse  VARCHAR2(3);
  l_centre  VARCHAR2(3);

BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);

  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
   SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
   WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.dateeffet  := i_dateEffet;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.commentaire := 'Adhérent : '     ||i_numAdherent   ||CHR(13)||CHR(10)||
                            'idDemande_ext : '   ||i_idDemande_ext ||CHR(13)||CHR(10)||
                            'Type de bénéficiaire : '||i_typebeneficiaire||CHR(13)||CHR(10)||
                            'Nom : '              ||i_nom       ||CHR(13)||CHR(10)||
                            'Prénom : '           ||i_prenom    ||CHR(13)||CHR(10)||
                            'Date de naissance : '||d2e(i_datenaiss) ||CHR(13)||CHR(10)||
                            'Rang : '            ||i_rangNais  ||CHR(13)||CHR(10)||
                            'Sexe : '            ||i_sexe      ||CHR(13)||CHR(10)||
                            'Num SS : '           ||i_numss     ||CHR(13)||CHR(10)||
                            'Régime : '          ||i_regime    ||CHR(13)||CHR(10)||
                            'Caisse : '          ||i_caisse    ||CHR(13)||CHR(10)||
                            'Num SS 2 : '          ||i_numss2    ||CHR(13)||CHR(10)||
                            'Régime 2 : '         ||i_regime2   ||CHR(13)||CHR(10)||
                            'Caisse 2 : '         ||i_caisse2   ||CHR(13)||CHR(10)||
                            'Date d''effet : '   ||d2e(i_dateeffet) ||CHR(13)||CHR(10)||
                            'Autre Mutuelle : '   ||i_mutuelleExist|| ' (0: non, 1:oui) '||CHR(13)||CHR(10)||
                            'Documents : ';
  WHILE i <= i_documents.COUNT LOOP
    loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
    i:=i+1;
  END LOOP;
  i:=1;
  loc_rappel.commentaire := loc_rappel.commentaire ||';';
  loc_rappel.entite := i_numAdherent; -- par defaut on prend le numadherent, il faut le mettre a jour si l'enregistrement a eu lieu
    -- FIN DE VERIFICATION DE DOUBLON
  INSERT INTO rappel VALUES loc_rappel;
  INSERT_LIEN_GED(i_documents, 30,loc_rappel.idrappel, i_numadherent,i_numporte, loc_numutil,loc_rappel.idrappel);
  COMMIT;
 -- La soumission dans l’EA d’une demande de nouveau bénéficiaire créé automatiquement une demande dans la corbeille ainsi qu’un individu dans Arthus.
 -- La validation de la demande de la corbeille ne déverse donc aucune information dans la back office.

  -- Avant la création du bénéficiaire, Arthus contrôle son existence grâce au nom, prénom et date de naissance.
  -- S’il existe et qu’il est déjà rattaché à un autre adhérent alors le WS ne créé pas le bénéficiaire et retourne le numéro d'individu trouvé.
  l_IS_BENE_DOUBLON :=IS_BENE_DOUBLON(i_numAdherent,i_nom, i_prenom, i_datenaiss, i_numss );
  l_IS_BENE_DOUBLON_groupe :=IS_BENE_DOUBLON_GROUPE(i_numAdherent, i_nom, i_prenom, i_datenaiss, i_numss);
 BEGIN
    IF l_IS_BENE_DOUBLON_groupe  = 2201  THEN  -- recherche de l'individu sur le groupe familiale de l'assuré
      SELECT numindiv
      INTO l_beneficiaire_existant
      FROM INDIVIDU
      WHERE (UPPER(NOM)   = TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_nom, 'nls_sort=binary_ai')))),chr(0))) OR i_numss = matorg||cless)     /* 26/04/2021 ARO M0007100 ajout TRIM() */
        AND UPPER(PRENOM) = TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_prenom, 'nls_sort=binary_ai')))),chr(0)))                              /* 26/04/2021 ARO M0007100 ajout TRIM() */
        AND TRUNC(DATNAIS)  = TRUNC(i_datenaiss)

        AND numassu = i_numAdherent ;

            SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2187, 1);
    ELSIF l_IS_BENE_DOUBLON = 2198  THEN -- recherche de l'individu en dehors du groupe familliale
      SELECT numindiv
        INTO l_beneficiaire_existant
        FROM INDIVIDU
        WHERE (UPPER(NOM)   = TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_nom, 'nls_sort=binary_ai')))),chr(0))) OR i_numss = matorg||cless)   /* 26/04/2021 ARO M0007100 ajout TRIM() */
          AND UPPER(PRENOM) = TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_prenom, 'nls_sort=binary_ai')))),chr(0)))                            /* 26/04/2021 ARO M0007100 ajout TRIM() */
          AND TRUNC(DATNAIS)  = TRUNC(i_datenaiss)
          AND numassu <> i_numAdherent ;
            SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2187, 1);
    ELSIF 0 IN (l_IS_BENE_DOUBLON,l_IS_BENE_DOUBLON_GROUPE) THEN -- si aucun bénéficiaire n'a été trouvé dans les deux cas, alors on continu
        null;
    ELSE
           PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_WEB_MAJ.ADD_BENEFICIAIRE',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  =>'idrappel=['||loc_rappel.idrappel||']'||' dans le ELSE du controle de doublon ',
            I_idligne  => 2);
        loc_rappel.code_err := 2198;
        SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2198,4);
        RETURN new EXTR_R_ADD_BENEFICIAIRE(
                      GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1))
                      ,null);
    END IF;
  EXCEPTION WHEN TOO_MANY_ROWS THEN

      loc_rappel.code_err := 2198;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2198,4);
      RETURN new EXTR_R_ADD_BENEFICIAIRE(
                      GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1))
                      ,null);
  END ;

  -- valorisation de la caisse, regime, centre en prenant le departement comme code caisse + 1
  BEGIN
    SELECT NVL(i_caisse,substr(codpos,0,2)||'1')
    INTO l_caisse
    FROM pers_adresse
    WHERE idadresse = pk_personne.f_idadresse(i_numAdherent);
  EXCEPTION WHEN OTHERS THEN null;
  END;
  l_regime := nvl(i_regime,'01');
 -- l_centre := nvl(i_centre,'000');
  -- Fin de valorisation de la caisse, regime, centre en prenant le departement comme code caisse + 1


  IF i_regime IS NOT NULL THEN
    l_err_regime := IS_REGIME_CAISSE_OK (l_regime, l_caisse, i_regime2, i_caisse2) ;
  END IF;
  l_err_numss := IS_NUMSS_OK ( substr(i_numss, 1, 13),substr(i_numss, 14, 15),substr(i_numss2, 1, 13),substr(i_numss2, 14, 15));

    -- Le bénéficiaire ne doit pas déjà être existant sur le groupe familial (avec numassu = numadhérent)
  IF i_SEXE NOT IN (1,2) OR I_SEXE IS NULL THEN
    loc_rappel.code_err:= 2202;
    loc_rappel.etat:=1;--Rejeté
  ELSIF i_datenaiss >sysdate  THEN
    loc_rappel.code_err:= 596;
    loc_rappel.etat:=4;--Rejeté
  ELSIF IS_BENE_DOUBLON_GROUPE(i_numAdherent,i_nom,i_prenom,i_datenaiss ) = 2201 THEN
    loc_rappel.code_err:= 2201;
    loc_rappel.etat:=1;
  ELSIF l_err_numss  >0 THEN
    loc_rappel.code_err:= l_err_numss;
    loc_rappel.etat:=4;
/*  ELSIF I_NUMSS2 IS NOT NULL THEN
    -- Si un 2ème n° ss est communiqué alors le régime et la caisse associés sont obligatoire, le type de bénéficiaire doit être un enfant et il doit être mineur.
    IF  I_CAISSE2 IS NULL OR I_REGIME2 IS NULL   THEN
      loc_rappel.code_err:= 2191;
      loc_rappel.etat:=4;
    END IF;*/
  END IF;

  IF l_err_regime > 0 THEN
    loc_rappel.code_err:= l_err_regime;
    loc_rappel.etat:=4;
  ELSIF (F_AGE(i_datenaiss,sysdate) >= 18  OR i_typebeneficiaire <> 2) AND i_numss2 IS NOT NULL THEN
    loc_rappel.code_err:=2192;
    loc_rappel.etat:=4;
  END IF;


  --ajouté un nouvel état => bloqué
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
  IF  loc_rappel.etat=4 THEN
         PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_WEB_MAJ.ADD_BENEFICIAIRE',
            I_session  => SID,
            I_niv_msg  =>1,
            I_msg_adm  =>'idrappel=['||loc_rappel.idrappel||']'||'etat =4',
            I_idligne  => 2);
    RETURN new EXTR_R_ADD_BENEFICIAIRE(
                    GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1))
                    ,null);
  END IF;


  IF  nvl(l_beneficiaire_existant, 0) <> 0 THEN
          UPDATE individu
    SET
        matorg   = substr(i_numss, 1, 13),
        cless    = substr(i_numss, 14, 15),
        regime   = l_regime,
        caisse   = l_caisse,
        GUICHETORG   = l_centre,
        matorg2  = nvl(substr(i_numss2, 1, 13),matorg2),
        cless2   = nvl(substr(i_numss2, 14, 15),cless2),
        regime2  = nvl(i_regime2,regime2),
        caisse2  = nvl(i_caisse2,caisse2)
    WHERE numindiv = l_beneficiaire_existant;
  ELSE
  --M5399 on ne créé pas le bénéficiaire s'il est en doublon ou autres erreur restant en état 1
  IF loc_rappel.code_err IS NULL THEN
    --Pour déterminer le type d'ouvreur de droit

   -- select max(datas.typ_od
   -- ) INTO l_is_od
   -- FROM (

   -- SELECT count(i.numindiv) typ_od
   -- FROM adhe_cntrt_membre m , individu i
   -- WHERE idadhesion IN (
   --   SELECT idadhesion FROM adhe_cntrt
   --   WHERE numadhe = i_numAdherent
   --   AND loc_rappel.dateeffet BETWEEN date_adhe AND NVL(date_fin_adhe,loc_rappel.dateeffet))
   -- AND i.numindiv = m.numindiv
   -- AND  substr(i_numss, 1, 13) in (i.matorg, nvl(i.matorg2,'0'))
   -- UNION
   -- SELECT 1 typ_od  -- si l'individu porte son propre numéro de sécu alors il sera ouvreur de droit nature = 2
   -- FROM dual
   -- WHERE  substr(i_numss,2,2) = To_CHAR(i_datenaiss ,'YY')
   -- AND    substr(i_numss,4,2) = To_CHAR(i_datenaiss ,'MM')
   -- )
   -- datas
   -- ;

    SELECT COUNT(1)  -- si l'individu porte son propre numéro de sécu alors il sera ouvreur de droit nature = 1
    INTO l_is_od
    FROM dual
    WHERE  SUBSTR(i_numss,2,2) = TO_CHAR(i_datenaiss ,'YY')
    AND    SUBSTR(i_numss,4,2) = TO_CHAR(i_datenaiss ,'MM')
    ;


    /************CREATION DE l'individu *************/
    loc_beneficiaire.numindiv := f_numero( 'INDVS' );
    loc_beneficiaire.nom      := TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_nom, 'nls_sort=binary_ai')))),chr(0)));       /* 26/04/2021 ARO M0007100 ajout TRIM() */
    loc_beneficiaire.prenom   := TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_prenom, 'nls_sort=binary_ai')))),chr(0)));    /* 26/04/2021 ARO M0007100 ajout TRIM() */
    loc_beneficiaire.datnais  := UPPER(i_datenaiss);
    loc_beneficiaire.datnais_regime  := to_char(i_datenaiss,'ddmmyy');
    loc_beneficiaire.numassu  := i_numAdherent;
    loc_beneficiaire.typassu  := 2;

    IF l_is_od = 0 THEN
      loc_beneficiaire.natur    := 2;
    ELSE
      loc_beneficiaire.natur    := 1;
     -- loc_beneficiaire.typassu  := 1;
    END IF;

    loc_beneficiaire.typadr   := i_typebeneficiaire;
    loc_beneficiaire.rang     := i_rangNais;
    loc_beneficiaire.type     := 1;
    loc_beneficiaire.sexe     := i_sexe;
    loc_beneficiaire.qualite  := i_sexe;
    loc_beneficiaire.matorg   := substr(i_numss, 1, 13);
    loc_beneficiaire.cless    := substr(i_numss, 14, 15);
    loc_beneficiaire.regime   := l_regime;
    loc_beneficiaire.caisse   := l_caisse;
    loc_beneficiaire.GUICHETORG   := l_centre;
    loc_beneficiaire.matorg2  := substr(i_numss2, 1, 13);
    loc_beneficiaire.cless2   := substr(i_numss2, 14, 15);
    loc_beneficiaire.regime2  := i_regime2;
    loc_beneficiaire.caisse2  := i_caisse2;
    loc_beneficiaire.ORGBASE  :=1; -- sous regime
    IF NOT PK_PERSONNE.F_INSERT_INDIVIDU(loc_beneficiaire,loc_erreur) THEN
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2187, 1);  -- probléme lors de l'insertion mais pas d'envoi de KO
      PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
      RETURN new EXTR_R_ADD_BENEFICIAIRE(
                    PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2189,1))
                    , null); --votre demande est prise en compte
    END IF;
    l_beneficiaire_existant:=  loc_beneficiaire.numindiv;
  END IF;


  END IF;

  -- on met le rappel en traité uniquement si l'assuré principale est créée la même journée (car on est alors dans le contexte)
  UPDATE rappel r
  SET r.entite =  l_beneficiaire_existant,
      r.numbene = l_beneficiaire_existant,
      etat = 3
  WHERE r.IDRAPPEL = loc_rappel.IDRAPPEL
  and exists(select 1 from individu where numindiv =i_numAdherent and trunc(creation)=trunc(sysdate) );
  -- Sinon on est dans l'espace assuré classique et les gesionnaires doivent faire des choses sur l'ajout de beneficiaire
  UPDATE rappel r
  SET r.entite =  l_beneficiaire_existant,
      r.numbene = l_beneficiaire_existant,
      etat = 1
  WHERE r.IDRAPPEL = loc_rappel.IDRAPPEL
  and not exists(select 1 from individu where numindiv =i_numAdherent and trunc(creation)=trunc(sysdate) );


  COMMIT;
  IF F_IS_HORS_BIA(i_numAdherent) = 1 THEN
      PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  END IF;
  RETURN new EXTR_R_ADD_BENEFICIAIRE(
                PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent, l_beneficiaire_existant,i_idDemande_ext, l_code_demande)
                ,l_beneficiaire_existant);

EXCEPTION
 WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'PK_WEB_MAJ.ADD_BENEFICIAIRE',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
    I_idligne  => 2);
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
  RETURN new EXTR_R_ADD_BENEFICIAIRE(
                GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1))
                , null);
END ADD_BENEFICIAIRE;
/*******************************************************************************/

FUNCTION ADD_INDIVIDU(    i_numporte         IN NUMBER,
                          i_id_type          IN TYPE_FLUX.ID_TYPE%TYPE,
                          i_idDemande_ext    IN NUMBER,
                          i_numcli           IN NUMBER,
                          i_nom              IN VARCHAR2,
                          i_prenom           IN VARCHAR2,
                          i_datenaiss        IN DATE,
                          i_rangNais         IN NUMBER,
                          i_sexe             IN NUMBER,
                          i_numss            IN VARCHAR2,
                          i_regime           IN VARCHAR2,
                          i_caisse           IN VARCHAR2,
                          i_centre           IN VARCHAR2
                    )
  RETURN EXTR_R_ADD_BENEFICIAIRE
  IS
    /*variable de verif*/
  loc_etat    Number;
  L_numgar    Number;
  L_numfor       Number;
  L_edatapli     Number;
  L_idadhesion   Number;
  L_numadhe   INDIVIDU.NUMINDIV%TYPE;

  l_tomany_rows_nni NUMBER :=0;
  /* fin variable de verif*/
  --l_num_indiv_tiers Tiers.numindiv%TYPE := 123456789;

   loc_prch  PRCH%ROWTYPE;
  l_message_erreur mess_erreur.lib_msg%TYPE;
  --l_numsec tiers.numsec%TYPE;

  loc_rappel RAPPEL%ROWTYPE;
  l_type_demande NUMBER := 1;
  l_context_rappel NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande NUMBER;
  l_beneficiaire_existant individu.numindiv%TYPE;
  i NUMBER :=1;
  loc_individu individu%ROWTYPE;
  loc_erreur  VARCHAR2(4000);
  l_lien_ged  LIEN_GED%ROWTYPE;
  l_err_numss  number;
  l_err_regime NUMBER;
  l_doublon NUMBER;
  loc_nopiece number := null;
  exc_rejet_demande EXCEPTION; -- exception servant a quitter la procédure si une erreur est declenchée
  loc_idpiece NUMBER;

   l_regime  VARCHAR2(3);
  l_caisse  VARCHAR2(3);
  l_centre  VARCHAR2(3);


   -- on creer les circuit d'information de compte, cartetp et dématerialisation
 cursor c_info is
 SELECT to_number(REGEXP_SUBSTR(('28,50'),'[^,]+', 1, LEVEL)) valeur
    FROM DUAL
    CONNECT BY REGEXP_SUBSTR(('28,50'), '[^,]+', 1, LEVEL) IS NOT NULL;


BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);

  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
   SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
   WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.dateeffet  := sysdate;
  loc_rappel.numassu     := i_numcli;
  loc_rappel.commentaire := 'Société : '          ||i_numcli   ||CHR(13)||CHR(10)||
                            'idDemande_ext : '    ||i_idDemande_ext ||CHR(13)||CHR(10)||
                            'Nom : '              ||i_nom       ||CHR(13)||CHR(10)||
                            'Prénom : '           ||i_prenom    ||CHR(13)||CHR(10)||
                            'Date de naissance : '||d2e(i_datenaiss) ||CHR(13)||CHR(10)||
                            'Rang : '             ||i_rangNais  ||CHR(13)||CHR(10)||
                            'Sexe : '             ||i_sexe      ||CHR(13)||CHR(10)||
                            'Num SS : '           ||i_numss     ||CHR(13)||CHR(10)||
                            'Régime : '           ||i_regime    ||CHR(13)||CHR(10)||
                            'Caisse : '           ||i_caisse    ||CHR(13)||CHR(10);

  i:=1;
  loc_rappel.commentaire := loc_rappel.commentaire ||';';
  loc_rappel.entite := i_numcli; -- par defaut on prend le numadherent, il faut le mettre a jour si l'enregistrement a eu lieu

  INSERT INTO rappel VALUES loc_rappel;


  COMMIT;

    -- valorisation de la caisse, regime, centre en prenant le departement comme code caisse + 1
 /* BEGIN
    SELECT NVL(i_caisse,substr(codpos,0,2)||'1')
    INTO l_caisse
    FROM pers_adresse
    WHERE idadresse = pk_personne.f_idadresse(i_numAdherent);
  EXCEPTION WHEN OTHERS THEN null;
  END;*/
 -- l_regime := nvl(i_regime,'01');
 -- l_centre := nvl(i_centre,'000');
  -- Fin de valorisation de la caisse, regime, centre en prenant le departement comme code caisse + 1



  IF l_regime IS NOT NULL THEN
    l_err_regime := IS_REGIME_CAISSE_OK (l_regime, l_caisse, null, null) ;
  END IF;

  l_err_numss := IS_NUMSS_OK ( substr(i_numss, 1, 13),substr(i_numss, 14, 15),null,null );


  IF i_SEXE NOT IN (1,2) OR I_SEXE IS NULL THEN
    loc_rappel.code_err:= 2202;
    loc_rappel.etat:=4;--Rejeté
    RAISE exc_rejet_demande;
  ELSIF i_datenaiss >sysdate  THEN
    loc_rappel.code_err:= 596;
    loc_rappel.etat:=4;--Rejeté
    RAISE exc_rejet_demande;
  ELSIF l_err_numss  >0 THEN
    loc_rappel.code_err:= l_err_numss;
    loc_rappel.etat:=4;
    RAISE exc_rejet_demande;
  END IF;

  IF l_err_regime > 0 THEN
    loc_rappel.code_err:= l_err_regime;
    loc_rappel.etat:=4;
    RAISE exc_rejet_demande;
  ELSIF F_AGE(i_datenaiss,sysdate) <= 16  THEN
    loc_rappel.code_err:=2353;
    loc_rappel.etat:=4;
    RAISE exc_rejet_demande;
  END IF;

  SELECT COUNT(*)
  INTO l_doublon
  FROM INDIVIDU
  WHERE UPPER(nom) =   TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_nom, 'nls_sort=binary_ai')))),chr(0)))          /* 26/04/2021 ARO M0007100 ajout TRIM() */
    AND UPPER(prenom) =  TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_prenom, 'nls_sort=binary_ai')))),chr(0)))     /* 26/04/2021 ARO M0007100 ajout TRIM() */
    AND matorg||LPAD(to_char(cless),2,'0') = i_numss
    ;
  IF l_doublon > 0 THEN
    loc_rappel.code_err:= 2229; -- doublon d'ouvreur de droit, validation impossible
    loc_rappel.etat:=4;
    RAISE exc_rejet_demande;
   END IF;


  --M5399 on ne créé pas le bénéficiaire s'il est en doublon ou autres erreur restant en état 1
  IF loc_rappel.code_err IS NULL THEN
    /************CREATION DE l'individu *************/
    loc_individu.numindiv := f_numero('INDVS');
    loc_individu.nom      :=  TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_nom, 'nls_sort=binary_ai')))),chr(0))); --UPPER(i_nom);          /* 26/04/2021 ARO M0007100 ajout TRIM() */
    loc_individu.prenom   :=  TRIM(rtrim(upper(utl_raw.cast_to_varchar2((nlssort(i_prenom, 'nls_sort=binary_ai')))),chr(0)));--UPPER(i_prenom);     /* 26/04/2021 ARO M0007100 ajout TRIM() */
    loc_individu.datnais  := UPPER(i_datenaiss);
    loc_individu.datnais_regime  := to_char(i_datenaiss,'ddmmyy');
    loc_individu.numassu  :=  loc_individu.numindiv;
    loc_individu.typassu  := 2;
    loc_individu.natur    := 1;
    loc_individu.typadr   := 0;
    loc_individu.rang     := i_rangNais;
    loc_individu.type     := 1;
    loc_individu.sexe       := i_sexe;
    loc_individu.qualite    := i_sexe;
    loc_individu.matorg     := substr(i_numss, 1, 13);
    loc_individu.cless      := substr(i_numss, 14, 15);
    loc_individu.regime     := l_regime;
    loc_individu.caisse     := l_caisse;
    loc_individu.GUICHETORG := l_centre;
    loc_individu.orgbase := 1;

    IF NOT PK_PERSONNE.F_INSERT_INDIVIDU(loc_individu,loc_erreur) THEN
      PK_trace.P_INS_journal_adm (
                                  I_nom_traitement => 'PK_WEB_MAJ.ADD_INDIVIDU',
                                  I_session  => SID,
                                  I_niv_msg  => 3,
                                  I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(loc_erreur,1,132),
                                  I_idligne  => 2);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2187, 4);  -- probléme lors de l'insertion mais pas d'envoi de KO

     RETURN new EXTR_R_ADD_BENEFICIAIRE(
                GET_RESP_KO(i_numcli,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1)),null);
    END IF;

    UPDATE rappel r
    SET r.entite =  loc_individu.numindiv,
        r.numbene = loc_individu.numindiv,
        etat = 3 -- traité
    WHERE r.IDRAPPEL = loc_rappel.IDRAPPEL;


    -- on met jours le compte, la carte tp et la dématerialisation de l'individu.
  begin
    for ci in c_info loop
      MERGE INTO COURRIER_INFO c
        using  dual  on
            (c.TYPE_CRRR = ci.valeur
            AND   c.NUMINDIV  = loc_individu.numindiv)
        WHEN MATCHED THEN
          UPDATE SET MOYEN_INFO = 2
        WHEN NOT MATCHED THEN
          INSERT  (numindiv, TYPE_CRRR,MOYEN_INFO)
          VALUES (loc_individu.numindiv, ci.valeur,2);
  end loop;
      end;

  END IF;
  COMMIT;
  P_CREER_COLLECTION_DOCUSHARE(i_numindiv =>loc_individu.numindiv,i_societe => i_numcli);
  PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(loc_individu.numindiv, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN new EXTR_R_ADD_BENEFICIAIRE(
                PK_WS_WEB_MAJ_BACK.GET_RESP_OK(loc_individu.numindiv, loc_individu.numindiv,i_idDemande_ext, l_code_demande)
                ,loc_individu.numindiv);

EXCEPTION
 WHEN exc_rejet_demande THEN
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
    RETURN new EXTR_R_ADD_BENEFICIAIRE(
                    GET_RESP_KO(i_numcli,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1))
                    ,null);
 WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'PK_WEB_MAJ.ADD_INDIVIDU',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
    I_idligne  => 2);
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
  RETURN new EXTR_R_ADD_BENEFICIAIRE(
                GET_RESP_KO(i_numcli,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1)),null);

  END ADD_INDIVIDU;


      /******************************************************************************/
FUNCTION ADD_NUMSS( i_numporte  IN NUMBER,
                    i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                    i_numAdherent     IN NUMBER,
                    i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                    i_idDemande_ext   IN NUMBER,
                    i_typeDemande     IN NUMBER,
                    i_numss2          IN VARCHAR2,
                    i_dateeffet       IN DATE,
                    i_regime          IN VARCHAR2,
                    i_caisse          IN VARCHAR2,
                    i_centre          IN VARCHAR2,
                    i_infosocialetomodif IN NUMBER,
                    i_documents       IN EXT_TAB_DOCUMENT
                    )
  RETURN GENERIQUE_WS_RESP IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande    NUMBER;
  l_info_exist     NUMBER :=0;
  i NUMBER :=1;
  l_err_numss  NUMBER;
  l_contexte NUMBER;
  l_nopiece NUMBER;
  loc_idpiece NUMBER;
  l_regime VARCHAR2(3);
  l_caisse VARCHAR2(3);
  l_centre VARCHAR2(3);

  CURSOR C_adhesion(p_numindiv IN NUMBER) IS
    SELECT ad.idadhesion FROM adhesion ad, formule f ,contrat c
    WHERE ad.numindiv = p_numindiv
    AND f.numfor =   pk_qttc.f_sel_numfor(ad.NUMGAR, ad.NUMFOR)
    AND c.numgar = ad.numgar
    AND sysdate BETWEEN ad.datapli AND add_months(NVL(ad.datper, sysdate),9)  --  TODO Les pièces doivent pouvoir être créée 9 mois aprés
    ORDER BY ad.rang, c.gest_prest , f.typgar,ad.datapli ;

  BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;
  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.entite     := i_numindiv;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.dateeffet   := i_dateeffet;
  loc_rappel.numbene     := i_numIndiv;
  loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande exterieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Type de demande : '              || i_typeDemande ||';(1: Ajout, 2: Modification, 3: Dénoémisation, 4:Maj Organisme)'|| CHR(13)||CHR(10)||
                             'Date d''effet : '                || d2e(i_dateeffet) ||';'|| CHR(13)||CHR(10)||
                             'NumSS : '                        || i_numss2 ||';'|| CHR(13)||CHR(10)||
                             'Regime : '                       || i_regime ||';'|| CHR(13)||CHR(10)||
                             'Caisse : '                       || i_caisse ||';'|| CHR(13)||CHR(10)||
                             'Centre : '                       || i_centre ||';'|| CHR(13)||CHR(10)||
                             'Numéro SS concerné : '           ||i_infosocialetomodif ||';'||CHR(13)||CHR(10)||
                             'Documents : ';
  WHILE i <= i_documents.COUNT LOOP
    loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
    i:=i+1;
  END LOOP;
  i:=1;
  loc_rappel.commentaire := loc_rappel.commentaire ||';';

  -- Fin de valorisation de la caisse, regime, centre en prenant le departement comme code caise + 1

  INSERT INTO rappel VALUES loc_rappel;
  INSERT_LIEN_GED(i_documents, 30,loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil,loc_rappel.idrappel);
  COMMIT;
    /*  1 : Ajout
    2 : Modification
    3 : Désactivation*/
  IF  i_numAdherent = i_numindiv THEN
     l_contexte := 4;
     l_nopiece:= 9;
  ELSE
     l_contexte:= 12;
     l_nopiece :=19;
  END IF;

  l_err_numss := IS_NUMSS_OK ( substr(i_numss2, 1, 13),substr(i_numss2, 14, 2),NULL,NULL);
  IF l_err_numss > 0 THEN
    loc_rappel.code_err:= l_err_numss;
    loc_rappel.etat:=4;
  END IF;
 IF i_typeDemande in(1,2) AND i_numss2 IS NOT NULL THEN
     BEGIN
     SELECT DISTINCT 2213    INTO  l_err_numss
      FROM individu
      WHERE (
      (matorg2 = substr(i_numss2, 1, 13) AND  regime2 =i_regime  AND caisse2=i_caisse and guichetorg2 = i_centre)
      OR
      (matorg = substr(i_numss2, 1, 13) AND  regime = i_regime  AND caisse = i_caisse and guichetorg = i_centre)
      ) -- si l'individu a dèjà ce numéro de sécurté sociale sur le premier ou deuxiéme on refuse la demande
      AND numindiv = i_numindiv;
      loc_rappel.code_err:= nvl( loc_rappel.code_err,l_err_numss);
      loc_rappel.etat:=4;
      EXCEPTION WHEN NO_DATA_FOUND THEN
      l_err_numss := NULL;
      END;
  END IF;
   IF i_typeDemande in (2) AND (i_documents is NULL or  i_documents.count < 1 )THEN
    loc_rappel.code_err := 2214;
    loc_rappel.etat:=4;
   END IF;
  IF i_typeDemande in (3) THEN
    BEGIN
        SELECT 2237 INTO  l_err_numss from individu
        WHERE numindiv = i_numIndiv
        AND (regime = '50' OR regime2 = '50');
        loc_rappel.code_err := l_err_numss;
        loc_rappel.etat:=4;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;
   END IF;

  SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
  IF  loc_rappel.etat = 4 THEN
    RETURN GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  END IF;

   -- Ajout d'une pièce a add_numss
  FOR R_adhesion IN C_adhesion(i_numIndiv) LOOP
      INSERT INTO PIECES (
                          CONTEXTE,
                          ENTITE ,
                          NUMFOR ,
                          NUMBENE,
                          NUMINDIV_DEST ,
                          IDREPARTITION,
                          NOPIECE,
                          BLOC,
                          DELAI,
                          PERIOD ,
                          NBREL,
                          DATEENREG )
                VALUES(  l_contexte,--loc_piece.contexte,
                         R_adhesion.idadhesion,
                         0,
                         NVL(i_numindiv,i_numAdherent),
                         i_numAdherent,
                         0,
                         l_nopiece,--loc_piece.nopiece,--TODO
                         'N',
                         DECODE(l_contexte, 12, DECODE(l_nopiece, 19, 0, 30), 4, DECODE(l_nopiece, 9, 0, 30), 30) ,  -- M0005602
                         decode(l_nopiece,3,60,0),
                         NULL,
                        sysdate )
      RETURNING idpiece INTO loc_idpiece ;

      INSERT_LIEN_GED(i_documents, l_contexte, loc_rappel.idrappel, NVL(i_numindiv,i_numAdherent),i_numporte, loc_numutil, loc_idpiece);
      DELETE_LIEN_GED( i_etendue=>30, i_clef=> loc_rappel.idrappel);
      EXIT;
    END LOOP;

    IF i_numporte = 27 THEN    -- si le service est appelé de l'espace Rh on valide directement la modification SS
       l_err_numss:=null;
       l_err_numss:= F_VALIDE_ADD_NUMSS( loc_rappel.idrappel ,i_numporte);

       IF l_err_numss <> 0 THEN
        return  GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(l_err_numss,1));
       END IF;
       SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 3); -- on le passe a traité
    END IF;

  IF F_IS_HORS_BIA(i_numAdherent) = 1 THEN
      PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  END IF;
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,null,i_idDemande_ext, l_code_demande);

EXCEPTION
 WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'PK_WEB_MAJ.ADD_NUMSS',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
        I_idligne  => 2);
   SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
   RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
END ADD_NUMSS;

  /******************************************************************************/

  FUNCTION ADD_DEVIS (  i_numporte  IN NUMBER,
                        i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                        i_numAdherent     IN NUMBER,
                        i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                        i_idDemande_ext   IN NUMBER,
                        i_mutuelleExist   IN NUMBER,
                        i_natureDossier   IN NUMBER,
                        i_documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande    NUMBER;
  l_info_exist     NUMBER :=0;
  loc_num_dossier  DOSSIER_SANTE.NUM_DOSSIER%TYPE;
  loc_libnature VARCHAR2(100);
  loc_nature_dossier dossier_sante.nat_doss%type;
  lib_nature_dossier varchar2(100);
  i number :=1;
  l_id_piece  pieces.idpiece%type;
  couverture_exist NUMBER :=0;

   cursor c_pieces_to_create(i_typedoss number) is    -- récuperer toutes pièces a creer pour une demande de devis
      select * from TRANSCO
      where  tiers = 'NAT_DOSS'
        and  mnemo like 'NO_PIECE%'
        and  val_ext = i_typedoss;

BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
   SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
   WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;
  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel.reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.numbene     := i_numIndiv;

  /*SELECT decode( i_natureDossier,1,'Optique',2,'Dentaire',3,'Hospitalisation',
                4,'Maternité',5,'Prothèses auditives',6,'Examen',7,'Autre devis','Inconnu') INTO loc_libnature from dual;
    */
  IF i_documents IS  NULL OR i_documents.count < 1 THEN
      loc_rappel.code_err := 2214;
      loc_rappel.etat     := 4;
  END IF;


  loc_nature_dossier := f_get_transco('EA','NAT_DOSS', i_natureDossier,2);
  IF loc_nature_dossier IS NULL THEN
    lib_nature_dossier := 'Non Transcodée';
    loc_rappel.code_err := nvl(loc_rappel.code_err,2212);
  ELSE
    lib_nature_dossier:= f_lble('NAT_DOSS',loc_nature_dossier);
  END IF;


  loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande extérieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Autre Mutuelle : '               || i_mutuelleExist ||';(0:non, 1:oui)'|| CHR(13)||CHR(10)||
                             'Nature du dossier : '            || i_natureDossier ||'-'||lib_nature_dossier||';'|| CHR(13)||CHR(10)||
                             'Documents : ';
  WHILE i <= i_documents.COUNT LOOP
    loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
    i:=i+1;
  END LOOP;
  i:=1;
  loc_rappel.commentaire := loc_rappel.commentaire ||';';


  loc_rappel.entite := 0;
  INSERT INTO rappel VALUES loc_rappel;
  INSERT_LIEN_GED(i_documents, 30, loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil,loc_rappel.idrappel);
  COMMIT;
   BEGIN
      SELECT distinct 1 INTO couverture_exist FROM adhesion ad, formule f
        WHERE ad.numindiv = i_numindiv
        AND f.numfor =   pk_qttc.f_sel_numfor(ad.NUMGAR, ad.NUMFOR)
        AND sysdate BETWEEN ad.datapli AND NVL(ad.datper, sysdate)     ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
          loc_rappel.etat := 4;
          loc_rappel.code_err := 2215;
  END ;
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
  IF  loc_rappel.etat=4 THEN
    RETURN GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  END IF;

  IF  loc_nature_dossier IS NOT NULL THEN      -- on creer le dossier uniquement si la transcodification de la nature du dossier est ok.

    PK_CTRL_TP.P_INS_DOSSIER_SANTE( P_ref         => to_char(loc_rappel.reference) ,
                                    P_numindiv    => i_numIndiv,
                                    P_PS          => NULL,
                                    P_numassu     => i_numAdherent,
                                    P_numporte    => i_numporte,
                                    P_natdoss     => loc_nature_dossier, -- TODO Faire un DECODE
                                    P_typedoss    => 5, --devis
                                    P_num_dossier_porte => to_char(loc_rappel.reference),--loc_numdossierPorte, --> av voir si c est le bon numéro
                                    O_num_dossier => loc_num_dossier);

     IF loc_num_dossier = 0 THEN
      loc_rappel.code_err := 2225;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
    ELSE
    -- CLI le 22/03/2018 creéation des pièces en fonction du type de dossier
     IF   i_mutuelleExist = 1 THEN
         loc_nature_dossier := 98; --Si bouton radio oui sur ce bénéf dispose d'une 1ère mutuelle = Devis autre mutuelle
     ELSIF loc_nature_dossier IS NULL  THEN  -- sinon si la nature du dossier n'est pas connu on met une pièce par defaut
         loc_nature_dossier := 99; --Autres devis
     END IF;
      FOR r_piece in c_pieces_to_create(loc_nature_dossier) LOOP      -- pour chaque pièce a creer on insere un lien ged sur chaque document
        INSERT INTO PIECES (
                              CONTEXTE,
                              ENTITE ,
                              NUMFOR ,
                              NUMBENE,
                              NUMINDIV_DEST ,
                              IDREPARTITION,
                              NOPIECE,
                              BLOC,
                              DELAI,
                              PERIOD ,
                              NBREL,
                              DATEENREG )
                    VALUES(  20,
                             loc_num_dossier,
                             0,
                             i_numindiv,
                             i_numAdherent,
                             0,
                             to_number(r_piece.val_int),
                             'N',
                             0,--30,
                             0,
                             NULL,
                            sysdate
                    )
        RETURNING idpiece INTO l_id_piece ;

        INSERT_LIEN_GED(i_documents, 20,   loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil, l_id_piece);
      END LOOP;
      DELETE_LIEN_GED( i_etendue=>30, i_clef=> loc_rappel.idrappel);

      UPDATE RAPPEL
        SET ENTITE = loc_num_dossier
        WHERE IDRAPPEL = loc_rappel.IDRAPPEL;
    END IF;
    COMMIT;

  END IF;
  PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,null,i_idDemande_ext, l_code_demande);

EXCEPTION
 WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'PK_WEB_MAJ.ADD_DEVIS',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
    I_idligne  => 2);
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
  RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));

END ADD_DEVIS;
  /*******************************************************************************/


FUNCTION ADD_REMB (   i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent     IN NUMBER,
                      i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext   IN NUMBER,
                      i_mutuelleExist   IN NUMBER,
                      i_natureDossier   IN NUMBER,
                      i_detailsoins     IN NUMBER,
                      i_documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande    NUMBER;
  l_info_exist     NUMBER :=0;
  loc_num_dossier  DOSSIER_SANTE.NUM_DOSSIER%TYPE;
  loc_libnature VARCHAR2(100);
  loc_libdetail VARCHAR2(100);
  loc_libnature VARCHAR2(100);
  loc_nature_dossier dossier_sante.nat_doss%type;
  lib_nature_dossier varchar2(100);
  i number :=1;
  l_id_piece  pieces.idpiece%type;
  couverture_exist NUMBER :=0;

  cursor c_pieces_to_create(i_typedoss number) is    -- récuperer toutes pièces a creer pour une demande de devis
    select * from TRANSCO
    where tiers = 'NAT_REMB'
     and  mnemo like 'NO_PIECE%'
     and  val_ext = i_typedoss;
BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;
  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;

  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.numbene     := i_numIndiv;
  SELECT decode(i_detailsoins,1,'Lentille',2,'Verre/Monture',3,'Chirurgie correctrice',4,'Prothèse dentaire',
                5,'Implant, parodontie, prothèse NR',6,'Orthodontie',7,'Hopital',8,'Clinique',
        9,'Pharmacie non remboursé',10,'Vaccin non remboursé','Inconnu') INTO loc_libdetail from dual;

 /* SELECT decode(i_natureDossier,1,'Optique',2,'Dentaire',3,'Prothèses auditives',4,'Hospitalisation',5,'Soins externes',
                6,'Médecine douce',7,'Cure thermale',8,'Pharmacie et vaccins non remboursés','Inconnu') INTO loc_libnature from dual;  */
  IF i_documents IS NULL OR i_documents.count < 1 THEN
      loc_rappel.code_err := 2214;
      loc_rappel.etat     := 4;
  END IF;

  loc_nature_dossier := f_get_transco('EA','NAT_REMB', i_natureDossier,2);
  IF loc_nature_dossier IS NULL THEN
    lib_nature_dossier := 'Non Transcodée';
    loc_rappel.code_err := nvl(loc_rappel.code_err,2212);
  ELSE
    lib_nature_dossier:= f_lble('NAT_DOSS',loc_nature_dossier);
  END IF;

  loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande extérieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Autre Mutuelle : '               || i_mutuelleExist ||';(0: non, 1:oui)'|| CHR(13)||CHR(10)||
                             'Nature du dossier : '            || loc_nature_dossier ||'-'||lib_nature_dossier||';'|| CHR(13)||CHR(10)||
                             'Nature d''origine : '            || i_natureDossier ||';'|| CHR(13)||CHR(10)||
                             'Detail soins : '                 || i_detailsoins ||'-'||loc_libdetail||';'|| CHR(13)||CHR(10)||
                             'Documents : ';
  WHILE i <= i_documents.COUNT LOOP
    loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
    i:=i+1;
  END LOOP;
  i:=1;
  loc_rappel.commentaire := loc_rappel.commentaire ||';';

  loc_rappel.entite := 0;
  INSERT INTO rappel VALUES loc_rappel;
  INSERT_LIEN_GED(i_documents, 30, loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil, loc_rappel.idrappel);
  COMMIT;
   -- verification de la couverture
 /*  BEGIN
  SELECT distinct 1 INTO couverture_exist FROM adhesion ad, formule f
    WHERE ad.numindiv = i_numindiv
    AND f.numfor =   pk_qttc.f_sel_numfor(ad.NUMGAR, ad.NUMFOR)
    AND sysdate BETWEEN ad.datapli AND NVL(ad.datper, sysdate);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      loc_rappel.etat := 4;
      loc_rappel.code_err := 2215;
  END ;
            */
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
  IF  loc_rappel.etat = 4 THEN
    RETURN GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  END IF;

  IF  loc_nature_dossier IS NOT NULL THEN      -- on creer le dossier uniquement si la transcodification de la nature du dossier est ok.
    PK_CTRL_TP.P_INS_DOSSIER_SANTE( P_ref         => to_char(loc_rappel.reference ),
                                  P_numindiv    => i_numIndiv,
                                  P_PS          => NULL,
                                  P_numassu     => i_numAdherent,
                                  P_numporte    => i_numporte,
                                  P_natdoss     => loc_nature_dossier,
                                  P_typedoss    => 1, -- dossier de liquidation
                                  P_num_dossier_porte => to_char(loc_rappel.reference),--loc_numdossierPorte, --> av voir si c est le bon numéro
                                  O_num_dossier => loc_num_dossier);

    IF loc_num_dossier = 0 THEN
      loc_rappel.code_err := 2225;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
    ELSE
        -- CLI le 22/03/2018 creéation des pièces en fonction du type de dossier
       PK_trace.P_INS_journal_adm ( I_nom_traitement => 'PK_WEB_MAJ.ADD_REMB',
                                    I_session  => SID,
                                    I_niv_msg  => 3,
                                    I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||' loc_nature_dossier='||loc_nature_dossier,
                                    I_idligne  => 2);

      IF   i_mutuelleExist = 1 THEN
         loc_nature_dossier := 98; --Si bouton radio oui sur ce bénéf dispose d'une 1ère mutuelle = Devis autre mutuelle
      ELSIF loc_nature_dossier IS NULL THEN
         loc_nature_dossier := 99; --Autres devis

     PK_trace.P_INS_journal_adm ( I_nom_traitement => 'PK_WEB_MAJ.ADD_REMB',
                                  I_session  => SID,
                                  I_niv_msg  => 3,
                                  I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||' loc_nature_dossier='||loc_nature_dossier,
                                  I_idligne  => 2);
      END IF;
      FOR r_piece in c_pieces_to_create(loc_nature_dossier) LOOP      -- pour chaque pièce a creer on insere un lien ged sur chaque document
        PK_trace.P_INS_journal_adm (I_nom_traitement => 'PK_WEB_MAJ.ADD_REMB',
                                    I_session  => SID,
                                    I_niv_msg  => 1,
                                    I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||' to_number(r_piece.val_int)='||to_number(r_piece.val_int),
                                    I_idligne  => 2);
        INSERT INTO PIECES (  CONTEXTE,
                              ENTITE ,
                              NUMFOR ,
                              NUMBENE,
                              NUMINDIV_DEST ,
                              IDREPARTITION,
                              NOPIECE,
                              BLOC,
                              DELAI,
                              PERIOD ,
                              NBREL,
                              DATEENREG )
                    VALUES(  20,
                             loc_num_dossier,
                             0,
                             i_numindiv,
                             i_numAdherent,
                             0,
                             to_number(r_piece.val_int),
                             'N',
                             0,--30,
                             0,
                             NULL,
                            sysdate
                    )
        RETURNING idpiece INTO l_id_piece ;
        INSERT_LIEN_GED(i_documents, 20, loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil, l_id_piece);
        DELETE_LIEN_GED( i_etendue=>30, i_clef=> loc_rappel.idrappel);
        END LOOP;



      UPDATE RAPPEL
      SET ENTITE = loc_num_dossier
      WHERE IDRAPPEL = loc_rappel.IDRAPPEL;
    END IF;
    COMMIT;

  END IF;
  PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,null,i_idDemande_ext, l_code_demande);

EXCEPTION
 WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'PK_WEB_MAJ.ADD_REMB',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
    I_idligne  => 2);
   SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
   RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
END ADD_REMB;
/**********************************************************************************************/
  FUNCTION ADD_DOS_CALC (  i_numporte      IN NUMBER
                          ,i_id_type       IN TYPE_FLUX.ID_TYPE%TYPE
                          ,i_numAdherent   IN NUMBER
                          ,i_numindiv       IN NUMBER
                          ,i_idDemande_ext IN NUMBER
                          ,i_typeDossier   IN NUMBER
                          ,i_natureDossier IN NUMBER
                          ,i_typeFrais     IN NUMBER
                          ,i_documents     IN EXT_TAB_DOCUMENT
                          ,i_tab_act       IN EXTR_TAB_ACTS_CALC

                            )
  RETURN EXTR_R_ADD_DOS_CALC

  IS

  loc_rappel RAPPEL%ROWTYPE;
  loc_tab_act EXTR_TAB_ACTS_CALC :=i_tab_act;
  l_context_rappel  NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande    NUMBER;
  l_info_exist     NUMBER :=0;
  i NUMBER :=1;
  l_err_numss  NUMBER;
  l_contexte NUMBER;
  l_nopiece NUMBER;
  loc_idpiece NUMBER;
  loc_num_dossier  DOSSIER_SANTE.NUM_DOSSIER%TYPE;
  l_id_piece pieces.idpiece%type;
  erreur_dossier NUMBER := 0;
  msg_dossier VARCHAR2(200);
  l_etat_sntr NUMBER(1);
  l_mtprest number;
  loc_is_doublon number;
  loc_porte_exist NUMBER;
  loc_acte_inconnu NUMBER;
  loc_doublon_dans_flux NUMBER;
  loc_date_pivot date;
  loc_doublon_detected NUMBER :=0;
  loc_un_acte_est_courvert NUMBER :=0; -- permet de savoir si au moins un acte est couvert ce qui nous fait afficher ou non le message de plafond
  exc_doublon_detected  EXCEPTION;
  exc_porte_not_exist   EXCEPTION;
  exc_dossier_non_cree  EXCEPTION;
  exc_acte_inconnu      EXCEPTION;
  exc_doublon_dans_flux EXCEPTION;

   cursor c_pieces_to_create(i_natureDossier number) is    -- récuperer toutes pièces a creer pour une demande de devis
    select * from TRANSCO
    where tiers = 'NAT_REMB'
     and  mnemo like 'NO_PIECE%'
     and  val_ext = i_natureDossier;

  BEGIN
    l_code_demande := get_code_demande(i_id_type,i_numporte);
    -- creation de l'événement dans la table rappel
    -- Récuperation du  code rappel
    SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
    BEGIN
      SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
    EXCEPTION
      WHEN OTHERS THEN loc_numutil:=f_numutil;
    END;
    SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
    loc_rappel.entite     := i_numindiv;
    loc_rappel.contexte   := l_context_rappel;
    loc_rappel.type       :=  l_code_demande;
    loc_rappel. reference := i_idDemande_ext;
    loc_rappel.creation := sysdate;
    loc_rappel.createur := loc_numutil;
    loc_rappel.etat     := 1 ;
    loc_rappel.origine     := i_numporte;
    loc_rappel.numassu     := i_numAdherent;
    loc_rappel.dateeffet   := sysdate;
    loc_rappel.numbene     := i_numIndiv;
    loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||'-'|| 'Individu : '  || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                               'Demande exterieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                               'Nature du dossier : '            || i_natureDossier  || '-'|| f_lble('NAT_DOSS',i_natureDossier)||';'|| CHR(13)||CHR(10);


   loc_rappel.commentaire := loc_rappel.commentaire ||'[Code acte,Datsin,Parcours,CAS,Spe,RefActe,Coeff,Quantité,Montant,Taux,Base Remb,AR],'|| CHR(13)||CHR(10);

    BEGIN
     --sauvegarde des actes   pourra être supprimé par la suite car sauvegardé dans la table acte_rappel
    i:=1;
    WHILE i <= i_tab_act.COUNT LOOP
      loc_rappel.commentaire := loc_rappel.commentaire||'Acte n°'||i||' : '|| i_tab_act(i).CodeFrais ||', '|| d2e(i_tab_act(i).Datsin)||', '|| i_tab_act(i).pdsqls||', '|| i_tab_act(i).CAS
                                                      ||', '|| i_tab_act(i).Spe||', '|| i_tab_act(i).RefActe||', '|| i_tab_act(i).Coeff||', '|| i_tab_act(i).nbacte||', '|| i_tab_act(i).mtfrais
                                                      ||'€, '|| i_tab_act(i).Taux||', '|| i_tab_act(i).baseRemb||'€ '||', '|| nvl(i_tab_act(i).ar,0)||'€ '|| CHR(13)||CHR(10);
    i:=i+1;
    END LOOP;

    loc_rappel.commentaire := loc_rappel.commentaire||'Type du dossier : ' || i_typeDossier|| '-'|| f_lble('TYPDOS',i_typeDossier) ||';'|| CHR(13)||CHR(10)||
                              'Documents : ';

    -- sauvegarde des documents justificatif
    i:=1;
    WHILE i <= i_documents.COUNT LOOP
      loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
      i:=i+1;
    END LOOP;
    loc_rappel.commentaire := loc_rappel.commentaire ||';'|| CHR(13)||CHR(10);
  EXCEPTION
    WHEN OTHERS THEN NULL; --permet de ne pas peter si on depasse la taille maxi du commentaire
  END;
   -- sauvegarde du rappel
  INSERT INTO rappel VALUES loc_rappel;
  INSERT_LIEN_GED(i_documents, 30,loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil,loc_rappel.idrappel);
  P_SAVE_TAB_ACT(loc_rappel ,i_tab_act); -- insertion des actes dans une table
  COMMIT;
  -----------------------------------------------------------------------------------
  -------------------------------CREATION DU DOSSIER SANTE---------------------------
  -----------------------------------------------------------------------------------
  --IF  loc_nature_dossier IS NOT NULL THEN      -- on creer le dossier uniquement si la transcodification de la nature du dossier est ok.
  PK_CTRL_TP.P_INS_DOSSIER_SANTE( P_ref         => to_char(loc_rappel.reference ),
                                  P_numindiv    => i_numIndiv,
                                  P_PS          => NULL,
                                  P_numassu     => i_numAdherent,
                                  P_numporte    => i_numporte,
                                  P_natdoss     => i_natureDossier,
                                  P_typedoss    => i_typeDossier,
                                  P_num_dossier_porte => to_char(loc_rappel.reference),--loc_numdossierPorte, --> av voir si c est le bon numéro
                                  O_num_dossier => loc_num_dossier);

    IF loc_num_dossier = 0 THEN
      RAISE exc_dossier_non_cree;
    ELSE
        -- CLI le 22/03/2018 création des pièces en fonction du type de dossier
     /* IF   i_mutuelleExist = 1 THEN
         loc_nature_dossier := 98; --Si bouton radio oui sur ce bénéf dispose d'une 1ère mutuelle = Devis autre mutuelle
      ELSIF loc_nature_dossier IS NULL THEN
         loc_nature_dossier := 99; --Autres devis
      END IF;*/
      FOR r_piece in c_pieces_to_create(i_natureDossier) LOOP      -- pour chaque pièce a creer on insere un lien ged sur chaque document
      INSERT INTO PIECES (  CONTEXTE,
                            ENTITE ,
                            NUMFOR ,
                            NUMBENE,
                            NUMINDIV_DEST ,
                            IDREPARTITION,
                            NOPIECE,
                            BLOC,
                            DELAI,
                            PERIOD ,
                            NBREL,
                            DATEENREG )
                  VALUES(  20,
                           loc_num_dossier,
                           0,
                           i_numindiv,
                           i_numAdherent,
                           0,
                           to_number(r_piece.val_int),
                           'N',
                           0,
                           0,
                           NULL,
                          sysdate
                        )
      RETURNING idpiece INTO l_id_piece;
      INSERT_LIEN_GED(i_documents, 20, loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil, l_id_piece);
      DELETE_LIEN_GED( i_etendue=>30, i_clef=> loc_rappel.idrappel);
        END LOOP;

      UPDATE RAPPEL
      SET ENTITE = loc_num_dossier
      WHERE IDRAPPEL = loc_rappel.IDRAPPEL;

       -- VERIFICATION DE LA COUVERTURE DES ACTES

     BEGIN
     -- verification qu'un contrat existe sur la porte Extranet (25 chez gerep)
     --correctif 14042020 ABO - contrôle par rapport au 1er sinistre au lieu de sysdate pour les radié.
        SELECT distinct 1
        INTO loc_porte_exist
        FROM adhesion, contrat, porte_contrat
        WHERE contrat.NUMGAR_REF = adhesion.NUMGAR
          AND porte_contrat.NUMGAR = contrat.NUMGAR_REF
          AND porte_contrat.numporte=i_numporte
          AND adhesion.NUMINDIV= i_numIndiv
          AND i_tab_act(1).datsin between adhesion.DATAPLI and nvl(adhesion.datper, i_tab_act(1).datsin);

      EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE exc_porte_not_exist;
      END;

      -- verification que tout les actes du tableau sont connu du système
      SELECT count(*)
      INTO loc_acte_inconnu
      FROM  table (i_tab_act) acts
      WHERE acts.codefrais  NOT IN (SELECT codfrais FROM natfrais);

      IF loc_acte_inconnu > 0 THEN
        RAISE exc_acte_inconnu;
      END IF;


     -- verifie que il n'y a pas de doublon d'acte dans le flux
      BEGIN
        SELECT 1
          INTO loc_doublon_dans_flux
          FROm DUAL
          WHERE EXISTS (
              SELECT DISTINCT 1
              FROM table (i_tab_act) acts
              GROUP BY acts.codefrais, acts.datsin
              HAVING COUNT(*) > 1
              )
        ;
        IF loc_doublon_dans_flux =1 THEN
          RAISE exc_doublon_dans_flux;
        END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      END;
  -----------------------------------------------------------------------------------
  -----------------------------CREATION DES ACTES A REMBOURSER-----------------------
  -----------------------------------------------------------------------------------
      i:=1;
      WHILE i <= i_tab_act.COUNT LOOP
        BEGIN
          loc_date_pivot  := GREATEST(trunc(e2d('01/01/2018'),'YEAR'), i_tab_act(i).datsin);   -- mail de corrine du 24 mai 2018
                --  vérifie que l'acte est bien couvert pour l'inndividu
                SELECT count(*)
                  INTO l_etat_sntr
                  FROM natfrais
                      INNER JOIN couverture ON
                            couverture.numindiv = i_numindiv
                        AND couverture.datapli != nvl(couverture.datper,couverture.datapli+1)
                        AND loc_date_pivot   BETWEEN couverture.datapli and  nvl(couverture.datper,loc_date_pivot)
                        AND pk_histo_contrat.f_sel_etat (couverture.numgar,loc_date_pivot)=1
                      INNER JOIN calcul  ON
                         calcul.datapli != nvl(calcul.datper,calcul.datapli+1)
                        AND loc_date_pivot BETWEEN calcul.datapli AND nvl(calcul.datper,loc_date_pivot)
                        AND calcul.numfor = pk_qttc.f_sel_numfor(couverture.numgar,couverture.numfor)
                        AND  natfrais.codfrais = calcul.codfrais
                     INNER JOIN defrub ON
                          DEFRUB.CODFRAIS = CALCUL.rubrique
                          AND    defrub.datapli != nvl(defrub.datper,defrub.datapli+1)
                          AND loc_date_pivot  BETWEEN  defrub.datapli AND nvl(defrub.datper,loc_date_pivot)
                          AND defrub.numfor = calcul.numfor
                          --AND natfrais.rubrique=defrub.codfrais
                      WHERE
                          natfrais.type = 2
                      AND calcul.RUBRIQUE IN (SELECT libelle FROM libelle WHERE mnemo = decode(i_typeFrais, 1,'EAFRBE',null) AND code >=0)   -- rubriques dynmaique selon le type de remboursement
                      AND  F_GET_TRANSCO('EA','FREXCLU',i_tab_act(i).codefrais) IS NULL  --acte non exclu
                      AND natfrais.codfrais = i_tab_act(i).codefrais
                    GROUP BY calcul.codfrais, natfrais.libelle,calcul.rubrique ;  -- même group by que sur le flux de consult


                IF l_etat_sntr = 0 THEN
                 --RAISE exc_couverture_not_exist;
                  l_etat_sntr:=3;          -- on bloque le sinistre si il n'est pas considéré comme couvert par les verifications
                  loc_tab_act(i).commentaire := 'Le sinistre n''est pas couvert';
                ELSE
                  l_etat_sntr:=1;
                  loc_un_acte_est_courvert :=1;
                END IF;
            -- verifier la présence de doublon
              SELECT  count(*)
                INTO loc_is_doublon
                FROM SINISTRE_SANTE ss,dossier_sante ds
               WHERE
                  ss.NUM_DOSSIER = ds.NUM_DOSSIER
                 AND F_ETAT_DOSSIER_SANTE(ds.NUM_DOSSIER)<>1
                 AND ss.NUMINDIV=i_numindiv
                 AND ss.CODFRAIS=i_tab_act(i).codefrais
                 AND ss.DATSIN=i_tab_act(i).datsin;

              IF   nvl(loc_is_doublon,0) >0 THEN
                loc_tab_act(i).commentaire := 'Prestation en doublon';
                RAISE   exc_doublon_detected;
              END IF;


            -- insertion du sinistre si il est couvert  et pas en déjà géré alors il est inséré
               PK_CTRL_TP.P_INS_SNTR_SANTE(P_num_dossier => loc_num_dossier,
                                           P_numligne    => i,
                                           P_numindiv    => i_numindiv,
                                           P_codfrais    => i_tab_act(i).codefrais ,
                                           P_mtfrais     => NVL(i_tab_act(i).mtfrais,0),
                                           P_etat        => l_etat_sntr ,-- a calculer
                                           P_taux        => i_tab_act(i).taux, --NVL(loc_Tab_Acte(i).mtro,0)/NVL(loc_Tab_Acte(i).mtro_sup,0)
                                           P_baseremb    => i_tab_act(i).baseremb,
                                           P_mtremb      => i_tab_act(i).mtremb,--NVL(loc_Tab_Acte(i).mtro,0)+NVL(i_tab_act(i).mtro_sup,0), -- Montant RO + le(s) supplément(s) RO,
                                           P_datsin      => i_tab_act(i).datsin,
                                           P_coeff       => i_tab_act(i).coeff,
                                           P_quantite    => i_tab_act(i).nbacte,
                                           p_autre_rb    => i_tab_act(i).ar
                                          );


        EXCEPTION
          WHEN exc_doublon_detected THEN
            loc_doublon_detected  :=1;

          WHEN OTHERS THEN NULL;

        END;
         i:=i+1;
      END LOOP;

       IF loc_doublon_detected =1 THEN -- si un doublon est detecter on ne calcul pas le dossier santé
         raise exc_doublon_detected;
       END IF;

       -----------------------------------------------------------------------------------
       -----------------------------LANCEMENT DU CALCUL DES PRESTATION--------------------
       -----------------------------------------------------------------------------------
       PK_CALCUL_DOSSIER.P_CALCUL_DOSSIER_SANTE( P_num_dossier => loc_num_dossier,
                                                 P_type        => 'devis',
                                                 P_tot_prest   => -1, -- on passe -1 car pas de corrélation entre le devis et la PEC
                                                 O_erreur      => erreur_dossier,
                                                 O_msg_erreur  => msg_dossier);


    ---------------- MISE A JOUR DES INFORMATIONS DE RETOUR---------------------
      i:=1;
      WHILE i <= i_tab_act.COUNT LOOP
        BEGIN
          SELECT sum(s.MTREEL)
          INTO loc_tab_act(i).mtprest
          FROM SNTR_DOSSIER sd,
               SINISTRE s
          WHERE sd.NUM_DOSSIER = loc_num_dossier
          AND s.numsin = sd.NUMSIN_SNTR
          AND sd.NUMLIGNE =  i;

         IF loc_tab_act(i).mtprest =0 OR loc_tab_act(i).mtprest IS NULL THEN
            IF loc_tab_act(i).commentaire IS NULL THEN  loc_tab_act(i).commentaire := 'Plafond de remboursement atteint';       END IF;
         END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          loc_tab_act(i).mtprest:= null;
        END;
        i:=i+1;
      END LOOP;
    END IF;
    COMMIT;

    IF erreur_dossier  in (5,9,10) THEN
        RAISE exc_prestation_null;
    END IF;

   IF nvl(loc_rappel.code_err,0) <> 0 then
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
   END IF;

  PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN new EXTR_R_ADD_DOS_CALC(PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numAdherent,i_idDemande_ext, l_code_demande),
                                 loc_tab_act);

  EXCEPTION
   WHEN exc_doublon_dans_flux  THEN
      loc_rappel.code_err := 2333;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 4);
      RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(i_numAdherent,i_numindiv,i_idDemande_ext,l_code_demande,pk_trace.F_AFF_mess_err(2333,1))
                                    ,null);
   WHEN exc_acte_inconnu  THEN
      loc_rappel.code_err := 2332;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 4);
      RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(i_numAdherent,i_numindiv,i_idDemande_ext,l_code_demande,pk_trace.F_AFF_mess_err(2332,1))
                                    ,null);
    WHEN exc_dossier_non_cree  THEN
      loc_rappel.code_err := 2225;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 4);
      RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(i_numAdherent,i_numindiv,i_idDemande_ext,l_code_demande,pk_trace.F_AFF_mess_err(2184,1))
                                    ,null);
    WHEN exc_porte_not_exist THEN
      loc_rappel.code_err := 2215;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 4);
      P_FERMER_DOSSIER_SANTE(loc_num_dossier,loc_rappel.code_err);
      RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(i_numAdherent,i_numindiv,i_idDemande_ext,l_code_demande,pk_trace.F_AFF_mess_err(2215,1))
                                    ,null);
    WHEN exc_doublon_detected THEN
      loc_rappel.code_err := 2328;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 4);
      P_FERMER_DOSSIER_SANTE(loc_num_dossier,loc_rappel.code_err);
      RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(i_numAdherent,i_numindiv,i_idDemande_ext,l_code_demande,pk_trace.F_AFF_mess_err(2328,1))
                                    ,null);
    WHEN exc_prestation_null THEN
      loc_rappel.code_err := 2331;
      P_FERMER_DOSSIER_SANTE(loc_num_dossier,loc_rappel.code_err);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 4);
      IF loc_un_acte_est_courvert = 1 THEN -- plafond
      RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(i_numAdherent,i_numindiv,i_idDemande_ext,l_code_demande,pk_trace.F_AFF_mess_err(2331,1))
                                    ,loc_tab_act);
      ELSE   -- acte non couvert
       RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(i_numAdherent,i_numindiv,i_idDemande_ext,l_code_demande,pk_trace.F_AFF_mess_err(2327,1))
                                ,null);
      END IF;
    WHEN exc_couverture_not_exist THEN
      loc_rappel.code_err := 2327;
      P_FERMER_DOSSIER_SANTE(loc_num_dossier,loc_rappel.code_err);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 4);
      RETURN new EXTR_R_ADD_DOS_CALC(pk_ws_web_maj_back.GET_RESP_KO(i_numAdherent,i_numindiv,i_idDemande_ext,l_code_demande,pk_trace.F_AFF_mess_err(2327,1))
                                    ,null);
  END ADD_DOS_CALC ;  -- reponse générique plus une réponse spécifique


/*******************************************************************************/


FUNCTION MAJ_INFO_PERSO(i_numporte  IN NUMBER,
                        i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                        i_numAdherent   IN NUMBER,
                        i_numIndiv      IN NUMBER,
                        i_idDemande_ext IN NUMBER,
                        i_nom           IN INDIVIDU.nom%TYPE,
                        i_nomNais       IN INDIVIDU.nomjf%TYPE,
                        i_prenom        IN INDIVIDU.prenom%TYPE,
                        i_dateEffet     IN DATE,
                        i_dateNaissance IN DATE,
                        i_rangNaissance IN NUMBER,
                        i_regimeSS      IN VARCHAR2,
                        i_caisse        IN VARCHAR2,
                        i_centre        IN VARCHAR2,
                        i_infosocialetomodif IN NUMBER,
                        i_documents       IN EXT_TAB_DOCUMENT
                        )
    RETURN GENERIQUE_WS_RESP
    IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande    NUMBER;
  l_info_exist     NUMBER := 0;
  i number :=1 ;
  l_statement  VARCHAR2(1000);
  l_separateur VARCHAR2(1);

  l_err_numss  NUMBER(9);

  CURSOR C_indv (p_numindiv IN NUMBER) is
    Select i.numindiv
    From individu i, individu a
    where i.matorg = a.matorg
    and a.numindiv = p_numindiv;

  CURSOR C_adhe (p_numindiv IN Number)  IS
  Select adhesion.idadhesion,
              adhesion.numgar,
              porte_contrat.numporte,
              adhesion.numfor,
              adhesion.datper                                               -- Ajout le 20100212 M00003055
       from   adhesion,
              porte_contrat, porte_param
       where  f_numgar_ref(adhesion.numgar) = porte_contrat.numgar
       and    adhesion.numindiv = p_numindiv
       and    porte_contrat.numporte != 1
       and    nvl (adhesion.datper, sysdate) >= sysdate
       and    SYSDATE between adhesion.datapli and nvl (adhesion.datper,SYSDATE)
       and    adhesion.etat =1
       and    porte_contrat.numporte = porte_param.numporte
       and    nat_porte in (3,5) --ABO ajout du filtre pour ne pas déclancher sur les autres portes
       order by nvl(adhesion.datper, sysdate);
BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;
  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.entite := i_numindiv;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 3 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.DATEEFFET  := i_dateEffet;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.numbene     := i_numIndiv;
  loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande exterieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                              'Nom : '                            || i_nom ||';'|| CHR(13)||CHR(10)||
                              'Prénom : '                         || i_prenom ||';'|| CHR(13)||CHR(10)||
                              'Date d''effet : '                  || d2e(i_dateEffet) ||';'|| CHR(13)||CHR(10)||
                              'Date de naissance : '              || d2e(i_dateNaissance) ||';'|| CHR(13)||CHR(10)||
                              'Rang de naissance : '               || i_rangNaissance ||';'|| CHR(13)||CHR(10)||
                              'Regime SS : '                       || i_regimeSS ||';'|| CHR(13)||CHR(10)||
                              'Caisse : '                         || i_caisse ||';'||CHR(13)||CHR(10)||
                              'Centre : '                         || i_centre ||';'||CHR(13)||CHR(10)||
                              'Numéro SS concerné : '             ||i_infosocialetomodif ||';'||CHR(13)||CHR(10)||
                              'Documents : ';

  WHILE i <= i_documents.COUNT LOOP
    loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
    i:=i+1;
  END LOOP;
  i:=1;


  --loc_rappel.RESPONSABLE := 1234; --TODO Comment determiner le respondable?

  INSERT INTO rappel VALUES loc_rappel;
  INSERT_LIEN_GED(i_documents, 30,loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil,loc_rappel.idrappel);
  COMMIT;


  IF LENGTH(i_nom)  > 30 OR LENGTH(i_prenom)  > 30 THEN  --- champs trop grands
    loc_rappel.etat :=4;
    loc_rappel.code_err:= 0;
  ELSIF (i_regimess IS NOT NULL OR i_caisse IS NOT NULL) AND l_err_numss>0  THEN  -- verification de l'existance du couple régime Caisse.
    loc_rappel.etat :=4;
    loc_rappel.code_err:= l_err_numss;
  ELSIF ((i_regimeSS IS NOT NULL OR i_caisse IS NOT NULL /*OR RANG de naissance*/ ) AND NOT (i_documents is not null AND i_documents.count > 0  ))  THEN   ---  La présence d’un document justificatif est obligatoire en cas de modification du regime / caisse et rang de naissance
        loc_rappel.etat :=4;
    loc_rappel.code_err:= 2207;
    PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_WEB_MAJ.MAJ_INFO_PERSO',
              I_session  => SID,
              I_niv_msg  =>1,
              I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||i_documents.count,
              I_idligne  => 2);
  ELSIF i_nom IS NOT NULL OR i_regimeSS IS NOT NULL OR i_caisse  IS NOT NULL OR i_rangNaissance IS NOT NULL THEN
    -- toute modification en dehors de la date de naissance ou du prénom nécessite un traitement manuel

    loc_rappel.etat :=1;
  END IF ;

  SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err,loc_rappel.etat);
  IF loc_rappel.etat =4  THEN
    RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  ELSIF  loc_rappel.etat =1 THEN
    PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
    RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));
  END IF;
  --TODO gérer le nom de naissance et le centre
  l_separateur :=',';
/*  IF i_nom IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' nom = '''||UPPER(i_nom)||'''';
  END IF;*/
  IF i_prenom IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' prenom = '''||UPPER(i_prenom)||'''';
  END IF;
 IF i_dateNaissance IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' datnais = e2d('''||d2e(i_dateNaissance)||'''), datnais_regime ='''||to_char(i_dateNaissance,'ddmmyy')||'''';
  END IF;
 /*  IF i_rangNaissance IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' rang = '''||i_rangNaissance||'''';
  END IF;
  IF i_regimeSS IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' regime = '''||i_regimeSS||'''';
  END IF;
  IF i_caisse IS NOT NULL THEN
   l_statement := l_statement || l_separateur ||' caisse = '''||i_caisse||'''';
  END IF;*/
 /*   PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_WEB_MAJ.MAJ_INFO_PERSO',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(l_statement,2),
              I_idligne  => 2); */
  EXECUTE IMMEDIATE 'UPDATE INDIVIDU SET '||substr(l_statement,2)|| ' WHERE NUMINDIV = '|| i_numindiv;

  --  Génère une nouvelle carte de tiers payant pour le bénéficiaire si le nom, prénom, date ou rang de naissance sont modifiés


  IF  loc_rappel.etat =3 THEN

  FOR R_numindiv IN  C_indv(i_numindiv) LOOP
    FOR R_adhe  IN   C_adhe(R_numindiv.numindiv)LOOP
        pk_porte.P_INS_demande_tp (
                I_numporte => R_adhe.numporte,
                I_idadhesion => R_adhe.idadhesion,
                I_numgar     => R_adhe.numgar,
                I_numindiv   => R_numindiv.numindiv,
                I_debut      => SYSDATE,--a valider par GEREP
                I_fin        => R_adhe.datper,
                I_type       => 16,
                I_numfor     => R_adhe.numfor
              );
    END LOOP;
  END LOOP;


  END IF;
  PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
 RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));
EXCEPTION
 WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'PK_WEB_MAJ.MAJ_INFO_PERSO',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
      I_idligne  => 2);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
    RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
END MAJ_INFO_PERSO;


    /********************************************************/

FUNCTION MAJ_CIRCUIT_INFO(i_numporte  IN NUMBER,
                          i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                          i_numAdherent   IN NUMBER,
                          i_numIndiv      IN NUMBER,
                          i_idDemande_ext IN NUMBER,
                          i_typeCircuit   IN NUMBER,
                          i_ouverture     IN NUMBER
                        )
RETURN GENERIQUE_WS_RESP
IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande    NUMBER;
  l_info_exist     NUMBER :=0;
  l_is_interlocuteur number:=0;
BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;
  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.entite := i_numindiv;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 3 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.numbene     := i_numIndiv;
  loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande exterieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Type de circuit : '               || i_typeCircuit ||';(28: décompte, 50: TPE, 51: Newsletter)'|| CHR(13)||CHR(10)||
                             'Ouverture : '                     || i_ouverture ||';(1:papier, 2: dématérialisé)';

  --loc_rappel.RESPONSABLE := 1234; --TODO Comment determiner le respondable?

  INSERT INTO rappel VALUES loc_rappel;
  COMMIT;

  IF i_typeCircuit NOT IN(28,50,51,52,53)  OR i_ouverture NOT IN (1,2) THEN      -- verification des données
      loc_rappel.etat:=4;
      loc_rappel.code_err:=2210;
  END IF;

  SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
  IF  loc_rappel.etat=4 THEN
    RETURN GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  ELSIF loc_rappel.etat=1 THEN
    BEGIN
      SELECT COUNT(1)
      INTO l_is_interlocuteur
      FROM INTERLOCUTEUR
      where interlocuteur =  i_numAdherent;
    END;

    IF F_IS_HORS_BIA(i_numAdherent) = 1  or l_is_interlocuteur > 0 THEN
      PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
    END IF;
   RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,null,i_idDemande_ext, l_code_demande);
  END IF;

 /* BEGIN
     SELECT DISTINCT 1 INTO l_info_exist
     FROM COURRIER_INFO  c
     WHERE  c.TYPE_CRRR = i_typeCircuit
      AND   c.NUMINDIV  = i_numIndiv;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_info_exist:=0;
  END;

  IF l_info_exist = 1 THEN    -- mettre a jour le paramétrage de l'individu si la ligne existe déjà dans la table
   UPDATE COURRIER_INFO c SET c.MOYEN_INFO = i_ouverture
    WHERE  c.TYPE_CRRR = i_typeCircuit
      AND   c.NUMINDIV  = i_numIndiv;
  ELSE -- sinon creer la ligne
    INSERT INTO COURRIER_INFO (numindiv, TYPE_CRRR,MOYEN_INFO)
    VALUES (i_numIndiv, i_typeCircuit,i_ouverture);
  END IF;   */

  MERGE INTO COURRIER_INFO c
    using dual  on
        (c.TYPE_CRRR = i_typeCircuit
        AND   c.NUMINDIV  = i_numIndiv)
    WHEN MATCHED THEN
      UPDATE SET MOYEN_INFO = i_ouverture
    WHEN NOT MATCHED THEN
      INSERT  (numindiv, TYPE_CRRR,MOYEN_INFO)
      VALUES (i_numIndiv, i_typeCircuit,i_ouverture);



  COMMIT;
   IF  i_typeCircuit not in (52, 53) THEN
    PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  END IF;
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, get_code_demande(i_id_type,i_numporte));
EXCEPTION
   WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'PK_WEB_MAJ.MAJ_CIRCUIT_INFO',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
        I_idligne  => 2);
        SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
        RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));

END;


/******************************************************************************************DMNDE*************************************************************************************************/
/******************************************************************************************DMNDE*************************************************************************************************/
/******************************************************************************************DMNDE*************************************************************************************************/
/* Insére une demande de prise en charge hospitaliére*/
/*Si le tiers n'est pas identifié, la PEC se creer avec un Tiers 'fantôme' défini*/
FUNCTION DMNDE_PEC_HOSPI (i_numporte  IN NUMBER,
                          i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                          i_numAdherent   IN NUMBER,
                          i_numIndiv      IN NUMBER,
                          i_idDemande_ext IN NUMBER,
                          i_natHospi      IN NUMBER,
                          i_nomEtHospi    IN VARCHAR2,
                          i_NNI           IN VARCHAR2,
                          i_codPos        IN VARCHAR2,
                          i_dateHospi     IN DATE,
                          i_ville         IN VARCHAR2,
                          i_tel           IN VARCHAR2, -- telephone
                          i_fax           IN VARCHAR2,
                          i_adresse       IN VARCHAR2,
                          i_email         IN VARCHAR2)
RETURN  GENERIQUE_WS_RESP
IS
  /*variable de verif*/
  loc_etat    Number;
  L_numgar    Number;
  L_numfor       Number;
  L_edatapli     Number;
  L_idadhesion   Number;
  L_numadhe   INDIVIDU.NUMINDIV%TYPE;

  l_tomany_rows_nni NUMBER :=0;
  /* fin variable de verif*/
  l_num_indiv_tiers Tiers.numindiv%TYPE :=324947;
  --const_num_tier_fantome tiers.numindiv%TYPE := 303179; -- TODO A CHANGER avec un vrai numéro de tiers fantome
  --const_num_tier_fantome tiers.numindiv%TYPE := 319968  --GEREPT   ce numero sera ecrassé par la prochaine recette.
  const_num_tier_fantome tiers.numindiv%TYPE := 324947 ; --  GEREPP

  loc_prch  PRCH%ROWTYPE;
  l_message_erreur mess_erreur.lib_msg%TYPE;
  --l_numsec tiers.numsec%TYPE;

  loc_rappel RAPPEL%ROWTYPE;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_type_demande NUMBER := 1;
  l_context_rappel NUMBER;
  l_code_demande NUMBER;
  l_numsec prmt.numsec%TYPE;
  loc_test NUMBER(1) :=0;
  loc_libnature   VARCHAR2(100);
BEGIN
          PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_WEB_MAJ.DMNDE_PEC_HOSPI',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  =>'idrappel=['||loc_rappel.idrappel||']'||'AND id_type= '||i_id_type,
              I_idligne  => 2);
   l_code_demande := get_code_demande(i_id_type,i_numporte);
-- verification de la validité des champs

-- fin verification de la validité des champs


-- creation de l'événement dans la table rappel
-- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
   WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.numbene     := i_numIndiv;
  select decode(i_natHospi,1,'Médicale',2,'Chirurgicale','Inconnu') INTO loc_libnature FROM DUAL;
  loc_rappel.commentaire :=   'Adhérent : '                           || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                              'Individu : '                           || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                              'Demande extérieure : '                 || i_idDemande_ext ||';'|| CHR(13)||CHR(10) ||
                              'Nature de l''hospitalisation : '       || i_natHospi      ||'-'||loc_libnature||';'|| CHR(13)||CHR(10) ||
                              'Nom de l''établissement hospitalier : '|| i_NomEtHospi    ||';'|| CHR(13)||CHR(10) ||
                              'Code NNI : '                           || i_NNI           ||';'|| CHR(13)||CHR(10) ||
                              'Date de l''hospitalisation : '         || d2e(i_dateHospi)||';'|| CHR(13)||CHR(10) ||
                              'Ville : '                              || i_ville         ||';'|| CHR(13)||CHR(10) ||
                              'Téléphone : '                          || i_tel           ||';'|| CHR(13)||CHR(10) ||
                              'Fax : '                                || i_fax           ||';'|| CHR(13)||CHR(10) ||
                              'Adresse : '                            || i_adresse       ||';'|| CHR(13)||CHR(10) ||
                              'Code postal : '                        || i_codpos        ||';'|| CHR(13)||CHR(10) ||
                              'Email: '                               || i_email         ||';'    ;
  --loc_rappel.RESPONSABLE := 1234; --TODO Comment determiner le respondable?
  loc_rappel.entite := 0;
  INSERT INTO rappel VALUES loc_rappel;
  COMMIT;
    --loc_rappel.origine := la porte 25 --TODO
--  fin création de l'événement dans la table rappel
  --  ON determine le numéro du tiers en fonction  de l'instance,
  select max(numindiv), max(numindiv)
    into const_num_tier_fantome, l_num_indiv_tiers
    from tiers
    where tiers.REFCIE = 'PRESTA FANTOME EXTRANET';

   ----------------Verification de la couveture d'un assuré--------------
      --TODO code présent dans le trigger TEST_CRVT et INFO_CVRT pour récupérer le numgar et numfor du l'écran PC04, rapport au blocage de piéce   1926 ou 269
       INFO_CVRT_PRCH( i_numindiv =>  i_numIndiv,
                      numgar=> L_numgar,
                      numfor=> L_numfor,
                      edatapli=> L_edatapli,
                      idadhesion=> L_idadhesion,
                      i_datehospi => i_datehospi);
        BEGIN
          PK_trace.P_INS_journal_adm (I_nom_traitement => 'PK_WEB_MAJ.DMNDE_PEC_HOSPI',
                                      I_session  => SID,
                                      I_niv_msg  => 3,
                                      I_msg_adm  =>'idrappel=['||loc_rappel.idrappel||']'||'AND aprés L_adhesion = '||L_idadhesion,
                                      I_idligne  => 2);
          SELECT numadhe INTO L_numadhe
             FROM adhe_cntrt
             WHERE idadhesion = L_idadhesion;
          EXCEPTION
            WHEN no_data_found THEN  -- Cet assuré n'est pas couvert à cette date ou uniquement en surcomplémentaire
              SET_RAPPEL_ERREUR (loc_rappel.idrappel, 172, 4);
              RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(172,1));
        END;

        IF pk_histo_contrat.f_sel_etat(L_numgar,i_datehospi)!= 1 THEN  -- Le contrat n'est pas en vigueur à cette date
          SET_RAPPEL_ERREUR (loc_rappel.idrappel, 269, 4);
          RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(269,1));
        ELSIF F_piece_blocage(a_idrepartition=>0,a_numbene=> L_numadhe,a_contexte =>4) = 1 THEN
          SET_RAPPEL_ERREUR (loc_rappel.idrappel, 1926, 4);
          RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(1926,1));
        ELSIF F_piece_blocage(a_idrepartition=>0, a_numbene=> i_numIndiv, a_contexte =>12) = 1 THEN --ABO 15/05/2012 M0003144 relance piece adhesion affilié
          SET_RAPPEL_ERREUR (loc_rappel.idrappel, 1926, 4);
          RETURN GET_RESP_KO(i_numAdherent, i_numIndiv, i_idDemande_ext, l_code_demande, pk_trace.F_AFF_mess_err(1926,1));
        ELSE
            l_message_erreur := ca01_xit(  L_numfor, to_char(i_datehospi,'j'), L_edatapli, i_numindiv, L_idadhesion, 'totale');
            IF l_message_erreur<>'1' THEN
            SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
             PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_WEB_MAJ.DMNDE_PEC_HOSPI',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'XIT'||substr(l_message_erreur,1,132),
              I_idligne  => 2);
            RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
            END IF;
        END IF;


        -------------Fin verification couvreture assuré.

    --RECHERCHE DU TIERS en fonction du numéro nni
    IF i_NNI IS NOT NULL THEN
    BEGIN
       SELECT numindiv into l_num_indiv_tiers
        FROM tiers
        WHERE NUMDPT || NUMACTV || NUMINSER || NUMCLE = i_NNI;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  l_num_indiv_tiers:=null;
            WHEN TOO_MANY_ROWS THEN
               l_tomany_rows_nni :=1;
        END;
    END IF;

  IF l_num_indiv_tiers IS NULL OR l_tomany_rows_nni =1 THEN      -- si on a pas trouvé avec le NNI, on cherche avec le nom et le code postale
    BEGIN
         SELECT numindiv into l_num_indiv_tiers
            FROM tiers
            WHERE codpos = i_codpos
            AND nom LIKE '%'||i_nomEtHospi||'%'
            OR    prenom LIKE '%'||i_nomEtHospi||'%';

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'PK_WEB_MAJ.DMNDE_PEC_HOSPI',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'no_data_found',
        I_idligne  => 2);
                  l_num_indiv_tiers:=null;
            WHEN TOO_MANY_ROWS THEN
              PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'PK_WEB_MAJ.DMNDE_PEC_HOSPI',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'TOO_MANY_ROWS',
        I_idligne  => 2);
               l_tomany_rows_nni :=1;
        END;
    END IF;

    IF l_num_indiv_tiers IS NULL OR l_tomany_rows_nni = 1 THEN      -- si toutjours pas de tiers alors on prend le numéro du tiers fantôme
        l_num_indiv_tiers := const_num_tier_fantome;
          PK_trace.P_INS_journal_adm ( I_nom_traitement => 'PK_WEB_MAJ.DMNDE_PEC_HOSPI',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'l_num_indiv_tiers := const_num_tier_fantome;',
        I_idligne  => 2);
    END IF;
          PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'PK_WEB_MAJ.DMNDE_PEC_HOSPI',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'idrappel=['||loc_rappel.idrappel||']'||'numtiers = '||l_num_indiv_tiers,
        I_idligne  => 2);
   ----------------Verification d'un fournisseur paramétré---------------
   BEGIN
   select prmt.numsec
      into l_numsec
      from prmt;
          Exception
            When OTHERS then
            SET_RAPPEL_ERREUR (loc_rappel.idrappel, 612, 1);  -- erreur interne, la demande est traitée manuellement.
            PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
            RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande);
            --RETURN GET_RESP_KO(numAdherent,numIndiv,idDemande_ext, 1,pk_trace.F_AFF_mess_err(612,1)); --Pas de secteur d'activité défini au niveau du paramétrage général
      End;

      Begin
        select 1
        Into loc_test
        from dual
        Where Exists
        (Select 1 from actv
        where numtiers=l_num_indiv_tiers
        and numsec = l_numsec
        );
          Exception
          When no_data_found then
            SET_RAPPEL_ERREUR (loc_rappel.idrappel, 571, 4);
            RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande, pk_trace.F_AFF_mess_err(571,1)); --Ce fournisseur n'est pas habilité sur la famille "Hospitalisation"
        End;
        SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
        IF  loc_rappel.etat=4 THEN
          RETURN GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
        END IF;


        ----- INSERTION DE LA PRISE EN CHARGE -------
        SELECT numpc.nextval
        INTO loc_prch.numpc
        FROM dual;

        loc_prch.NUMINDIV := i_numIndiv ;
        loc_prch.NUMASSU  := i_numAdherent;
        loc_prch.NUMTIERS := l_num_indiv_tiers;
        loc_prch.DATEHOSPI:= i_dateHospi;
        loc_prch.TYPEDEST := 1; -- Voir STD
        loc_prch.DATECREAT:=sysdate;
        loc_prch.numfor := L_numfor;
        --loc_prch.NUMENTREE :=  ; --TODO A valoriser?
        loc_prch.NUMGAR  := L_numgar ;

        INSERT INTO PRCH VALUES loc_prch;

        UPDATE  RAPPEL
        SET     entite = loc_prch.numpc
        WHERE   idrappel = loc_rappel.IDRAPPEL;
        COMMIT;

        ----- FIN INSERTION DE LA PRISE EN CHARGE

   PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande);
EXCEPTION
  WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'PK_WEB_MAJ.DMNDE_PEC_HOSPI',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
      I_idligne  => 2);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
      RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
END DMNDE_PEC_HOSPI;
/******************************************************************************/



FUNCTION RAD_BENE ( i_numporte  IN NUMBER,
                      i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                      i_numAdherent     IN NUMBER,
                      i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                      i_idDemande_ext    IN NUMBER,
                      i_motif           IN NUMBER,
                      i_dateeffet       IN DATE,
                      documents         IN EXT_TAB_DOCUMENT
                      )
  RETURN GENERIQUE_WS_RESP IS
    loc_rappel RAPPEL%ROWTYPE;
    l_context_rappel  NUMBER;
    loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
    l_code_demande    NUMBER;
    l_info_exist     NUMBER :=0;
    i number := 1;
    l_is_ok_to_rad number :=0;
    l_lib_motif  varchar(50);
  BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  SELECT  max(idadhesion) INTO  loc_rappel.entite -- l'entité améne sur la derniére adhésion de l'adhérent.
    FROM adhesion
    WHERE NUMINDIV = i_numAdherent;

  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.DATEEFFET  := i_dateEffet;
  loc_rappel.numassu     := i_numAdherent;
  loc_rappel.numbene     := i_numIndiv;
  select decode( i_motif,1,'Enfant majeur',2,'Divorce',3,'Dissolution de pacs',4,'Séparation',5,'Décès',6,'Autre mutuelle','Motif indeterminé' ) into l_lib_motif from dual;

  loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande extérieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Motif : '                        || i_motif ||'; ('||l_lib_motif||')'|| CHR(13)||CHR(10)||
                             'Date d''effet :'                 || d2e(i_dateeffet) ||';'||CHR(13)||CHR(10)||
                             'Documents : ';
  WHILE i <= documents.COUNT LOOP
    loc_rappel.commentaire := loc_rappel.commentaire||'('||  documents(i).IDDOC ||', '|| documents(i).NOMDOC||'), ';
    i:=i+1;
  END LOOP;
  i:=1;

  --loc_rappel.RESPONSABLE := 1234; --TODO Comment determiner le respondable?
  --loc_rappel.entite := 0;
  INSERT INTO rappel VALUES loc_rappel;
  INSERT_LIEN_GED(documents, 30,loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil,loc_rappel.idrappel);
  COMMIT;

  --controle si le beneficiaire n'est pas deja radié
    BEGIN
      SELECT distinct 1 into l_is_ok_to_rad
      FROM adhesion
      WHERE numindiv = i_numindiv
      --AND rang = 1  -- on ne prend pas le surcomps
      AND DATPER IS NULL;
     EXCEPTION WHEN NO_DATA_FOUND THEN
      loc_rappel.code_err := 2238;
      loc_rappel.etat := 4;
    END;
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
  IF  loc_rappel.etat=4 THEN
    RETURN GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  END IF;

  PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,null,i_idDemande_ext, l_code_demande);

EXCEPTION
 WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'PK_WEB_MAJ.RAD_BENE',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
    I_idligne  => 2);
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
  RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));

END RAD_BENE;
  /*******************************************************************************/



/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  ADD_DOS_CALC                                              */
/* Type         :  Public                                                    */
/* Description  :  Fonction permettant d'enregitrer une demande de rebmoursement*/
/*                 : avec calcul immediat du resultat                           */
/* Auteur       :  CLI/JBO                                                   */
/* Date         :  23/05/2018                                                */
/* Commentaire  :  Projet P201804007                                         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

FUNCTION DEPOT_PIECE (    i_numporte  IN NUMBER,
                          i_id_type IN TYPE_FLUX.ID_TYPE%TYPE,
                          i_numAdherent     IN NUMBER,
                          i_numIndiv        IN INDIVIDU.NUMINDIV%TYPE,
                          i_idDemande_ext   IN NUMBER,
                          i_typePiece       IN NUMBER,
                          i_contexte        IN NUMBER,
                          i_entite          IN NUMBER,
                          i_id_piece        IN NUMBER,
                          datedebut         IN DATE,
                          datefin           IN DATE,
                          i_documents       IN EXT_TAB_DOCUMENT
  )
  RETURN GENERIQUE_WS_RESP IS
  loc_rappel RAPPEL%ROWTYPE;
  l_context_rappel  NUMBER;
  loc_numutil    UTILISATEURS.NUMUTIL%TYPE;
  l_code_demande NUMBER;
  l_info_exist   NUMBER :=0;
  loc_piece      PIECES%ROWTYPE;
  loc_lib        VARCHAR2(100);
  loc_lib1       VARCHAR2(100);
  i              NUMBER :=1;
  loc_interloc   interlocuteur.interlocuteur%TYPE;--M0006649

  CURSOR C_adhesion(p_numindiv IN NUMBER) IS
    SELECT ad.idadhesion, a.numadhe FROM adhesion ad, formule f ,contrat c, adhe_cntrt a
    WHERE ad.numindiv = p_numindiv
    AND f.numfor =   pk_qttc.f_sel_numfor(ad.NUMGAR, ad.NUMFOR)
    AND c.numgar = ad.numgar
    AND a.idadhesion = ad.idadhesion
    AND sysdate BETWEEN ad.datapli AND add_months(NVL(ad.datper, sysdate),9)  --  TODO Les pièces doivent pouvoir être créée 9 mois aprés
    ORDER BY ad.rang, c.gest_prest , f.typgar,add_months(NVL(ad.datper, sysdate),9)desc,ad.datapli;

BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel si null alors adhésion
  SELECT nvl(sens,decode(i_contexte, 4,13, 12,13, 20,27, 19,19/*27*/,15,16,17,16, 13)) SENS INTO l_context_rappel
  FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
   SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;

  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       := l_code_demande;
  loc_rappel.reference := i_idDemande_ext;
  loc_rappel.creation := sysdate;
  loc_rappel.createur := loc_numutil;
  loc_rappel.etat     := 1;

  if l_context_rappel =16 then  --RKO 24/03/2020 contexte dossier sinistre prevoyance
    loc_rappel.origine  := 30; --prevoyance
    -- Valorise le gestionnaire responsable du contrat prévoyance --PBO M0006543
    -- i_entite <=> numsim pour le contexte 16
    BEGIN
      SELECT contrat.numutil INTO loc_rappel.responsable
      FROM adhe_cntrt, contrat
        WHERE adhe_cntrt.idadhesion = f_idadhesion_prev(i_entite) -- remonte l'adhésion prévoyance via le numéro de sinistre
        AND adhe_cntrt.numgar = contrat.numgar;
    EXCEPTION
      WHEN OTHERS THEN
        loc_rappel.responsable := NULL;
        PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'PK_WEB_MAJ.DEPOT_PIECE',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'i_entite=['||i_entite||']'||' gestionnaire responsable du contrat prévoyance non trouve',
          I_idligne  => 2);
    END;
  else
   loc_rappel.origine  := i_numporte;
  end if;
  loc_rappel.numassu  := i_numAdherent;
  loc_rappel.numbene  := i_numIndiv;

  -- valorisation de pièce pré exitante dan Arthus (pièce demandée)
  IF i_typePiece = 0 THEN
    loc_lib1:= 'Valorisation de pièce ';
    BEGIN
        select f_lble('JUSTIF_'||i_contexte, nopiece)  INTO loc_lib from pieces where idpiece=i_id_piece /* where numindiv = i_numIndiv*/;       -- EXTRANET EVo3 CLi 05/04/2018
    END;
  -- Dépôt spontané de pièce
  ELSIF i_typePiece>0 THEN
    loc_lib1:= 'Dépôt spontané ';
    CASE f_get_transco('EA','PJUSTIF', i_typePiece,2)
      WHEN 'POLE_EMP' THEN
        loc_lib1:=loc_lib1 || 'pôle emploi';
        loc_lib := 'pôle emploi';
      WHEN 'POLE_EMP1' THEN
        loc_lib1:=loc_lib1 || 'pôle emploi';
        loc_lib :=   'pôle emploi';
      WHEN 'SCOLA_N' THEN
        loc_lib1:=loc_lib1 || 'de certificat de scolarité';
        loc_lib :='Certificat de scolarité';
      WHEN  'DCPT_IJ_SS' THEN    --EA PREV LOT3
        loc_lib1:=loc_lib1 || 'décompte des IJ de la SS';
        loc_lib := 'décompte des IJ de la SS';
      WHEN 'SAL_MITPS' THEN
        loc_lib1:=loc_lib1 || 'attestation de salaires mi-temps';
        loc_lib := 'attestation de salaire mi-temps';
      WHEN 'MAINT_SAL' THEN
        loc_lib1:=loc_lib1 || 'attestation de maintien salaire à ';
        loc_lib :='attestation de maintien de salaire à ';

      WHEN 'INVAL_SS' THEN    --EA PREV lot4
        loc_lib1:=loc_lib1 || 'notification SS d''invalidité ';
        loc_lib :='notification SS d''invalidité ';
      WHEN 'REQUAL_SS' THEN
        loc_lib1:=loc_lib1 || 'notification SS de requalification de l''arret ';
        loc_lib :='notification SS de requalification de l''arret';
      WHEN 'RECHUTE' THEN
        loc_lib1:=loc_lib1 || 'certificat de rechute ';
        loc_lib :='certificat de rechute ';
      WHEN 'ACT_DECES' THEN
        loc_lib1:=loc_lib1 || 'acte de décès ';
        loc_lib :='acte de décès ';
      WHEN 'RUPT_CONT' THEN
        loc_lib1:=loc_lib1 || 'certificat de travail de sortie des effectifs ';
        loc_lib :='certificat de travail de sortie des effectifs ';
      WHEN 'CORRES_SOC' THEN
        loc_lib1:=loc_lib1 || 'correspondance société ';
        loc_lib :='correspondance société ';
      WHEN 'FIN_INDEMN' THEN
        loc_lib1:=loc_lib1 || 'attestation fin indemnisation IJSS';
        loc_lib :='attestation fin indemnisation IJSS ';
      ELSE NULL;
    END CASE;
  END IF;

  loc_rappel.commentaire :=  'Adhérent : '                     || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || i_numIndiv      ||';'|| CHR(13)||CHR(10) ||
                             'Demande extérieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Type de pièce :'                 || i_typePiece ||'; ('||loc_lib1|| ')'|| CHR(13)||CHR(10)||
                             'Libelle de pièce : #LIBELLE;'      || CHR(13)||CHR(10)||
                             'Entité : '                       || i_entite ||';'|| CHR(13)||CHR(10)||
                             'Contexte : '                     || i_contexte ||';(4 et 12 :adhésion , 19 : télétransmission, 20 : dossier)'|| CHR(13)||CHR(10)||
                             'Id de la pièce :'                || i_id_piece ||';'|| CHR(13)||CHR(10)||
                             'Date de début de période : '     || d2e(nvl(datedebut,sysdate)) ||';'|| CHR(13)||CHR(10)||
                             'Date de fin de période : '       || d2e(nvl(datefin,sysdate)) ||';'|| CHR(13)||CHR(10)||
                             'Documents : ';
  WHILE i <= i_documents.COUNT LOOP
    loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
    i:=i+1;
  END LOOP;
  i:=1;
  loc_rappel.commentaire := loc_rappel.commentaire ||';';
  loc_rappel.entite := NVL(i_entite,0);  --valorisaton, on reprend l'entite, sinon ce sera le numéro d'adhésion de l'adhérent

  INSERT INTO rappel VALUES loc_rappel;

  IF  loc_rappel.contexte=16 THEN
    INSERT_LIEN_GED(i_documents, 30, loc_rappel.idrappel, NVL(i_numindiv,i_numAdherent),30, loc_numutil, loc_rappel.idrappel);
  ELSE
    INSERT_LIEN_GED(i_documents, 30, loc_rappel.idrappel, NVL(i_numindiv,i_numAdherent),i_numporte, loc_numutil, loc_rappel.idrappel);
  END IF;
  --contrôles de cohérence des données transmises
  IF i_typePiece IS NULL THEN
    loc_rappel.code_err:=2208;-- -- Le dépôt de pièce comporte une erreur
    loc_rappel.etat:=4;
  ELSIF i_typePiece = 0 AND (i_id_piece IS NULL OR i_entite IS NULL OR i_contexte IS NULL )THEN
    loc_rappel.code_err:=2208;-- -- Le dépôt de pièce comporte une erreur
    loc_rappel.etat:=4;
  ELSIF i_documents IS NULL OR i_documents.count < 1 THEN
      loc_rappel.code_err := 2214;
      loc_rappel.etat     := 4;
  ELSIF i_typePiece =0 AND i_id_piece IS NOT NULL THEN
    BEGIN
      SELECT daterecep INTO  loc_piece.daterecep
      FROM PIECES
      WHERE idpiece = i_id_piece;

      IF loc_piece.daterecep IS NOT NULL THEN
        loc_rappel.code_err:=2209;-- La pièce demandée a déjà été réceptionnée
        loc_rappel.etat:=4;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        loc_rappel.code_err:=2208;-- Le dépôt de pièce comporte une erreur
        loc_rappel.etat:=4;
     END;
  END IF;

  SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
  IF  loc_rappel.etat=4 THEN
    RETURN GET_RESP_KO(i_numAdherent,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  END IF;

  IF i_typePiece = 0 THEN--valorisation d'une pièce
    INSERT_LIEN_GED( i_documents, nvl(i_contexte,30), loc_rappel.idrappel, i_numIndiv,i_numporte, loc_numutil, i_id_piece);
    DELETE_LIEN_GED( i_etendue=>30, i_clef=> loc_rappel.idrappel);
      UPDATE RAPPEL
      SET-- ENTITE = R_adhesion.idadhesion,
      COMMENTAIRE = REPLACE(commentaire,'#LIBELLE', loc_lib)
      WHERE IDRAPPEL = loc_rappel.IDRAPPEL;
  ELSIF i_typePiece >0 AND f_get_transco('EA','PJUSTIF', i_typePiece,2) IS NOT NULL AND i_typePiece NOT IN (20,21,22,23,24,25,26,27,28,29) THEN --depot spontané hors decompte IJ de la SS(20), attestation salaire mitemps(21), attestation de maintien salaire(22)
    --deux cas possibles : pole emploi ou certificat de scolarité
    IF i_numAdherent = i_numIndiv THEN
      loc_piece.contexte :=4; --adhérent
    ELSE
      loc_piece.contexte :=12;--affilié
    END IF;


    UPDATE RAPPEL
      SET-- ENTITE = R_adhesion.idadhesion,
      COMMENTAIRE = REPLACE(commentaire,'#LIBELLE', loc_lib)
      WHERE IDRAPPEL = loc_rappel.IDRAPPEL;
    --gerer les dates
    --Recherche de la 1ère adhésion de BASE en cours ou non s'il n'en a pas trouvé
    FOR R_adhesion IN C_adhesion(i_numIndiv) LOOP
      --M5687
      IF loc_piece.contexte=4 AND i_numIndiv<>R_adhesion.numadhe THEN
        loc_piece.contexte:=12;
      END IF;
    CASE f_get_transco('EA','PJUSTIF', i_typePiece,2)
      WHEN 'POLE_EMP' THEN
        loc_piece.nopiece:=to_number(f_get_transco('EA','POLE_EMP', loc_piece.contexte,2));
      WHEN 'POLE_EMP1' THEN     -- i_typePiece doit être égale a 3 pour créer la pièce 4
      loc_piece.nopiece:=4;
      WHEN 'SCOLA_N' THEN
        loc_piece.contexte :=12;--affilié
        IF  instr(pk_libelle.f_lib('JUSTIF_12',to_number(f_get_transco('EA','SCOLA_N', 2,2))),'/'||extract(year from datefin))>0 THEN
          loc_piece.nopiece:=to_number(f_get_transco('EA','SCOLA_N', 2,2));--2017/2018 gérér les dates et passer 2 pour l'année suivante
        ELSE
          loc_piece.nopiece:=to_number(f_get_transco('EA','SCOLA_N', 1,2));--2016/2017 année en cours
        END IF;
      ELSE NULL;
    END CASE;

      --contrôle que le dépot spontané ne concerne pas une valorisation
      BEGIN
        SELECT idpiece INTO loc_piece.idpiece
        FROM PIECES
        WHERE entite = R_adhesion.idadhesion
        AND contexte = loc_piece.contexte
        AND nopiece = loc_piece.nopiece
        AND numbene =NVL(i_numindiv,i_numAdherent)
        AND numindiv_dest= i_numAdherent
        AND idrepartition = 0
        AND daterecep IS NULL;
      EXCEPTION
        WHEN OTHERS THEN loc_piece.idpiece :=NULL;
      END;

      IF loc_piece.idpiece  IS NULL THEN
        INSERT INTO PIECES (
                            CONTEXTE,
                            ENTITE ,
                            NUMFOR ,
                            NUMBENE,
                            NUMINDIV_DEST ,
                            IDREPARTITION,
                            NOPIECE,
                            BLOC,
                            DELAI,
                            PERIOD ,
                            NBREL,
                            DATEENREG )
                  VALUES(  loc_piece.contexte,
                           R_adhesion.idadhesion,
                           0,
                           NVL(i_numindiv,i_numAdherent),
                           i_numAdherent,
                           0,
                           loc_piece.nopiece,--TODO
                           'N',
                           DECODE(loc_piece.contexte, 12, DECODE(loc_piece.nopiece, 19, 0, 30), 4, DECODE(loc_piece.nopiece, 9, 0, 30), 30) ,  -- M0005602
                           decode(loc_piece.nopiece,3,60,0),
                           NULL,
                          sysdate )
        RETURNING idpiece INTO loc_piece.idpiece ;
      END IF;
      INSERT_LIEN_GED(i_documents, loc_piece.contexte, loc_rappel.idrappel, NVL(i_numindiv,i_numAdherent),i_numporte, loc_numutil, loc_piece.idpiece);
      DELETE_LIEN_GED( i_etendue=>30, i_clef=> loc_rappel.idrappel);

      UPDATE RAPPEL
      SET ENTITE = R_adhesion.idadhesion,
      COMMENTAIRE = REPLACE(commentaire,'#LIBELLE', loc_lib)
      WHERE IDRAPPEL = loc_rappel.IDRAPPEL;
      EXIT;

    END LOOP;
  END IF; -- i_typePiece
  IF i_typePiece in (20,21,22,23,24,25,26,27,28,29) THEN
    loc_piece.contexte   := 17;
    DEPOT_SPONT_PREV(i_typePiece,i_numIndiv,i_numAdherent,loc_piece,loc_rappel,30,loc_numutil,loc_lib,i_documents);
  END IF;
  COMMIT;
    --COMMENTER POUR SECURITE SUR GEREPD A decommenter pour livraison client
  IF i_contexte in (15,17) THEN --M0006649
      SELECT interlocuteur into loc_interloc
      FROM  interlocuteur
      WHERE numindiv = i_numAdherent
      AND f_coordonne_contact(interlocuteur,4,1) IS NOT NULL
      AND valide='O'
      AND ope_crrr=9
      AND ROWNUM <= 1;
    PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(/*i_numAdherent*/loc_interloc, l_code_demande, l_context_rappel, loc_rappel.entite,29,2); --création du mail accusé de reception avec template 2 pro
  ELSE
    PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  END IF;
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numAdherent,null,i_idDemande_ext, l_code_demande);
EXCEPTION
 WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'PK_WEB_MAJ.DEPOT_PIECE',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
      I_idligne  => 2);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
    RETURN GET_RESP_KO(i_numAdherent,i_numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));
END DEPOT_PIECE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  DEPOT_SPONT_PREV                                          */
/* Type         :  Public                                                    */
/* Description  :   permet le dépot spontané de pièces                       */
/* Auteur       :  RKO                                                       */
/* Date         :  03/04/2020                                                */
/* Commentaire  :  Projet P201910104                                         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

PROCEDURE DEPOT_SPONT_PREV (p_typePiece   IN NUMBER,
                            p_numIndiv    IN INDIVIDU.NUMINDIV%TYPE,
                            p_numAdherent IN NUMBER,
                            p_piece       IN OUT pieces%ROWTYPE,
                            p_rappel      IN OUT rappel%ROWTYPE,
                            p_numporte    IN NUMBER,
                            p_numutil     IN NUMBER,
                            p_lib         IN VARCHAR2,
                            p_documents   IN EXT_TAB_DOCUMENT)
IS
 CURSOR c_sin is
    SELECT s.iddossier,histo.*,r.idrepartition
   FROM  dossier_sinistre d, sntr_prev s
    left outer join repartition r ON  ( r.nosin = s.nosin AND r.valide='O'),
    histo_sntr_prev histo
    WHERE s.iddossier  =  d.iddossier
    AND d.numindiv = p_numIndiv
    AND s.norisq=4
    AND histo.nosin =s.nosin
    AND histo.nosin = p_rappel.entite
    AND (histo.saisie,histo.debut) = (
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
       )
      GROUP BY h.debut
      )
    AND histo.etat=1 --uniquement les sinistres en cours
    ;
  --loc_piece pieces%ROWTYPE;
BEGIN
--3 cas fonctionnels
-- cas A dépot spontané et pièce non déjà présente => p_typePiece valorisé
-- cas B dépot spontané et pièce  déjà présente donc valorisation de la pièce => p_typePiece valorisé
-- cas C ajout de pièces sur sinistre connu=> p_typePiece non valorisé

  IF p_typePiece IS NOT NULL THEN
    CASE f_get_transco('EA','PJUSTIF', p_typePiece,2)
    WHEN 'DCPT_IJ_SS' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','DCPT_IJ_SS', p_piece.contexte,2));
    WHEN 'SAL_MITPS' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','SAL_MITPS', p_piece.contexte,2));
    WHEN 'MAINT_SAL' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','MAINT_SAL',p_piece.contexte,2));
    WHEN 'INVAL_SS' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','INVAL_SS',p_piece.contexte,2));
    WHEN 'REQUAL_SS' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','REQUAL_SS',p_piece.contexte,2));
    WHEN 'RECHUTE' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','RECHUTE',p_piece.contexte,2));
    WHEN 'ACT_DECES' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','ACT_DECES',p_piece.contexte,2));
    WHEN 'RUPT_CONT' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','RUPT_CONT',p_piece.contexte,2));
    WHEN 'CORRES_SOC' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','CORRES_SOC',p_piece.contexte,2));
    WHEN 'FIN_INDEMN' THEN
      p_piece.nopiece:=to_number(f_get_transco('EA','FIN_INDEMN',p_piece.contexte,2));
    ELSE NULL;
    END CASE;

    FOR rec_sin IN c_sin LOOP
      p_rappel.entite := rec_sin.nosin;
      p_piece.idrepartition := rec_sin.idrepartition; --peut être null
      EXIT; --le sinistre doit existé et être non cloturé
    END LOOP;

    --contrôle que le dépot spontané ne concerne pas une valorisation
    BEGIN
      SELECT p.idpiece INTO p_piece.idpiece
      FROM PIECES p
      WHERE p.entite = p_rappel.entite
      AND p.contexte = p_piece.contexte
      AND p.nopiece = p_piece.nopiece
      AND p.numbene =NVL(p_numindiv,p_numAdherent)
      AND p.numindiv_dest= p_numAdherent
      AND p.daterecep IS NULL;

    EXCEPTION
      WHEN OTHERS THEN p_piece.idpiece :=NULL;
    END;

  END IF;

  IF p_piece.idpiece  IS NULL THEN

    INSERT INTO PIECES (
                        CONTEXTE,
                        ENTITE ,
                        NUMFOR ,
                        NUMBENE,
                        NUMINDIV_DEST ,
                        IDREPARTITION,
                        NOPIECE,
                        BLOC,
                        DELAI,
                        PERIOD ,
                        NBREL,
                        DATEENREG )
              VALUES(  p_piece.contexte,
                       p_rappel.entite,
                       0,
                       NVL(p_numindiv,p_numAdherent),
                       p_numAdherent,
                       NVL(p_piece.idrepartition,0),
                       p_piece.nopiece,
                       'N',
                       DECODE(p_piece.contexte, 12, DECODE(p_piece.nopiece, 19, 0, 30), 4, DECODE(p_piece.nopiece, 9, 0, 30), 30) ,
                       decode(p_piece.nopiece,3,60,0),
                       NULL,
                      sysdate )

    RETURNING idpiece INTO p_piece.idpiece ;
 PK_trace.P_INS_journal_adm (
I_nom_traitement => 'DEPOT_SPONT_PREV',
I_session  => SID,
I_niv_msg  => 3,
I_msg_adm  => 'idpiece = '||p_piece.idpiece,
I_idligne  => 1);
  END IF;
  --tous les cas pièces existantes ou non on accroche les liens GED
  INSERT_LIEN_GED(p_documents, p_piece.contexte, p_rappel.idrappel, NVL(p_numindiv,p_numAdherent),p_numporte, p_numutil, p_piece.idpiece);
  DELETE_LIEN_GED( i_etendue=>30, i_clef=> p_rappel.idrappel);

  UPDATE RAPPEL
  SET ENTITE = p_rappel.entite,
  COMMENTAIRE = REPLACE(p_rappel.commentaire,'#LIBELLE', p_lib)
  WHERE IDRAPPEL = p_rappel.IDRAPPEL;


END DEPOT_SPONT_PREV;

/*****************************************************************/
PROCEDURE P_INS_HISTO_ADHESION(i_idadhesion number, i_datapli DATE , i_etat NUMBER, i_motif NUMBER, i_numutil number)  IS

  loc_HISTO_ADHESION           HISTO_ADHESION%ROWTYPE;
  exc_adhesion_incompatible EXCEPTION;
  exc_histo_adhesion        EXCEPTION;
  BEGIN
  SELECT IDHISTOADHE.NEXTVAL
  INTO   loc_HISTO_ADHESION.IDHISTOADHE
  FROM DUAL;
  loc_HISTO_ADHESION.IDADHESION:=i_idadhesion;
  loc_HISTO_ADHESION.DEBUT:=i_datapli;
  loc_HISTO_ADHESION.DATSAI:=sysdate;
  loc_HISTO_ADHESION.ETAT := i_etat;
  loc_HISTO_ADHESION.MOTIF:= i_motif;
  loc_HISTO_ADHESION.NUMUTIL:= i_numutil;

  IF PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_HISTO_ADHESION) THEN
    commit;
  ELSE
    RAISE exc_histo_adhesion;
  END IF;

END  P_INS_HISTO_ADHESION;

  /******************************************************************************/

 FUNCTION VALID_SUBCRIBE_RH(  i_numporte       IN NUMBER,
                               i_id_type        IN TYPE_FLUX.ID_TYPE%TYPE,
                               i_numcli           IN NUMBER,
                               i_idDemande_ext    IN NUMBER,
                               infos            IN EXTR_QUALIF_SUBRIBE
                        )
  RETURN GENERIQUE_WS_RESP
  IS

    loc_rappel                RAPPEL%ROWTYPE;
    l_context_rappel          NUMBER;
    loc_numutil               UTILISATEURS.NUMUTIL%TYPE;
    l_code_demande            NUMBER;
    loc_idadhesion            NUMBER;
    loc_IDHISTOADHE           NUMBER;
    l_info_exist              NUMBER :=0;
    i                         NUMBER :=1;
    l_lib_motif               VARCHAR(50);
    loc_HISTO_ADHESION        HISTO_ADHESION%ROWTYPE;
    loc_datapli               DATE;
    exc_adhesion_incompatible EXCEPTION;
    exc_histo_adhesion        EXCEPTION;

    adhesion_ok_to_valid   number;   -- permet de savoir si on et passé une fois dans la boucle pour l'adhesion principal
    --références a la demande de souscription optionnelle
    loc_idrappel_option rappel.idrappel%type;
    loc_idadhesion_optionnelle  rappel.idrappel%type;


    CURSOR c_adhesion_to_valide (i_idrappel rappel.idrappel%TYPE) is
    -- Simplification du curseur dans le cadre de la M0007171 validation des options obligatoires lors de la validation de l'option de base
      --optimisation + creation d'index
      select distinct id_adhesion idadhesion,  rappel_souscript.DATEEFFET datapli
      from rappel_souscript, adhe_cntrt ac , rappel r
      where rappel_souscript.idrappel=r.idrappel
      and r.type in (20,26,27)
      and r.entite=infos.idadhesion
      and r.numbene=infos.numindiv
      AND ac.idadhesion = rappel_souscript.id_adhesion
      AND F_ETAT_ADHE(ac.idadhesion , greatest (ac.date_adhe,sysdate) ) = 0 --instance
      AND F_ETAT_ADHE(ac.idadhesion , greatest (ac.date_adhe,sysdate) , 2 ) in (58,60)
         ;



  BEGIN

    l_code_demande := get_code_demande(i_id_type,i_numporte);

    -- creation de l'événement dans la table rappel
    -- Récuperation du  code rappel
    SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
    BEGIN
      SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
    EXCEPTION
      WHEN OTHERS THEN loc_numutil:=f_numutil;
    END;

    SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
    BEGIN
      l_lib_motif := f_lble('REJET_BIA',infos.motif );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    loc_rappel.entite := infos.idadhesion;
    loc_rappel.contexte    := l_context_rappel;
    loc_rappel.type        :=  l_code_demande;
    loc_rappel. reference  := i_idDemande_ext;
    loc_rappel.creation    := sysdate;
    loc_rappel.createur    := loc_numutil;
    loc_rappel.etat        := 3 ;
    loc_rappel.origine     := i_numporte;
    loc_rappel.DATEEFFET   := sysdate;
    loc_rappel.numassu     := infos.NUMINTERLOCUTEUR;
    loc_rappel.numcli      := i_numcli ;
    loc_rappel.numbene     := infos.numIndiv;

    loc_rappel.commentaire :=  'Société : '                      || i_numcli   ||';'|| CHR(13)||CHR(10) ||
                               'Interlocuteur : '                || infos.NUMINTERLOCUTEUR      ||';'|| CHR(13)||CHR(10) ||
                               'Individu : '                     || loc_rappel.numbene       ||';'|| CHR(13)||CHR(10) ||
                               'Idadhesion : '                   || infos.idadhesion       ||';'|| CHR(13)||CHR(10) ||
                               'Demande extérieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                               'Motif : '                        || infos.motif ||'; ('||l_lib_motif||')'
                               ;
                               --'Date d''effet :'                 || d2e(i_dateeffet) ||';'||CHR(13)||CHR(10)||
    INSERT INTO rappel VALUES loc_rappel;

    -- l'adhésion doit -être ne instance avec motif de préaffiliation BIA (58)

    FOR rec_adhe_to_valid in c_adhesion_to_valide (loc_rappel.IDRAPPEL) LOOP
      loc_datapli:=rec_adhe_to_valid.datapli;

       UPDATE HISTO_ADHESION
       SET debut = loc_datapli
       WHERE idadhesion = rec_adhe_to_valid.idadhesion
       AND debut <= loc_datapli;
      --TODO trapper erreur du pk_ctrl_affil
       P_INS_HISTO_ADHESION(i_idadhesion =>rec_adhe_to_valid.idadhesion,
                            i_datapli =>loc_datapli ,
                            i_etat => 0,
                            i_motif =>59,
                            i_numutil => loc_numutil) ;

        adhesion_ok_to_valid :=1;
    END LOOP;

    If adhesion_ok_to_valid is null then
      raise     exc_adhesion_incompatible;
    END IF;

    BEGIN
      -- validation de la souscription optionnel si elle existe
     SELECT idrappel,
            to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) idadhesion_option
     INTO
            loc_idrappel_option,
            loc_idadhesion_optionnelle
               FROM rappel
     WHERE type = 27    -- adhesion optionnel
     AND ETAT = 3   -- traité
     AND to_number(F_GET_VALUE_IN_TABLE('Idadhesion_base', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) = infos.idadhesion -- la souscription optionnelle doit etre relative a celle de base
     AND numbene =infos.numIndiv -- la souscription optionnel doit concerné le même adhérent principal, cela évite les souscis lié a l'idadhésion qui est encore en max()+1...
    ;
     PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'VALID_SUBCRIBE_RH',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'idrap_opt:'||loc_idrappel_option||' adh_opt'|| loc_idadhesion_optionnelle,
          I_idligne  => 2);

     P_INS_HISTO_ADHESION(i_idadhesion =>loc_idadhesion_optionnelle,
                        i_datapli => loc_datapli,
                        i_etat => 0,
                        i_motif =>59,
                        i_numutil => loc_numutil) ;

    EXCEPTION
        WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'VALID_SUBCRIBE_RH',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'Pas d''adhesion optionnelle trouveée '||sqlerrm,
          I_idligne  => 2);
    END;
  -- FIN de validation des souscription optionnelles



  UPDATE RAPPEL SET COMMENTAIRE = 'Mise à jour : validé par Responsable le '||d2e(sysdate)||';'||chr(10)||chr(13)||COMMENTAIRE,
  etat = 3
  WHERE
  (idrappel IN (loc_idrappel_option)
    AND ETAT = 3
    AND TYPE = 27);

     -- repasse l'état en nouveau de la souscription de base
 UPDATE RAPPEL SET etat = 1
  WHERE type = 26
  AND to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) = infos.idadhesion
  AND numbene = infos.numindiv
  AND ETAT = 2 ;


  COMMIT;
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numcli,null,i_idDemande_ext, l_code_demande);

  EXCEPTION
    WHEN exc_adhesion_incompatible THEN
      PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'VALID_SUBCRIBE_RH',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'exc_adhesion_incompatible  pas d''adhesion trouvée comptable pour id '||infos.idadhesion|| 'et individu '||infos.numindiv,
        I_idligne  => 2);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2351, 4);
      RETURN GET_RESP_KO(i_numcli,infos.numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2351,1)); --TODO L'adhésion n'est pas dans un état compatble avec votre demande
    WHEN exc_histo_adhesion THEN
      PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'VALID_SUBCRIBE_RH',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'exc_histo_adhesion impossible d inserer '||infos.idadhesion|| 'et individu '||infos.numindiv,
        I_idligne  => 2);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2351, 4);
      RETURN GET_RESP_KO(i_numcli,infos.numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2351,1)); --TODO L'adhésion n'est pas dans un état compatble avec votre demande
  END VALID_SUBCRIBE_RH;
/****************************************************************************/


  FUNCTION REJECT_SUBCRIBE_RH(  i_numporte       IN NUMBER,
                                i_id_type        IN TYPE_FLUX.ID_TYPE%TYPE,
                                i_numcli           IN NUMBER,
                                i_idDemande_ext    IN NUMBER,
                                infos            IN EXTR_QUALIF_SUBRIBE
                        )
  RETURN GENERIQUE_WS_RESP
   IS

    loc_rappel RAPPEL%ROWTYPE;
    l_context_rappel  NUMBER;
    loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
    l_code_demande    NUMBER;
    l_info_exist     NUMBER :=0;
    i number := 1;
    l_is_ok_to_rad number :=0;
    l_lib_motif  varchar(50);
    loc_idadhesion NUMBER;
    exc_adhesion_incompatible EXCEPTION;

    --références a la demande de souscription optionnelle
    loc_idrappel_option rappel.idrappel%type;
    loc_idadhesion_optionnelle  rappel.idrappel%type;

  CURSOR c_adhesion_to_reject is
  -- A supprimer quelques temps aprés la mise en production, le temps que toute les adhésions soient validées
         WITH adhe_initial As(
      SELECT DISTINCT IDADHESION, datapli, numgar        -- on prend l'adhesion intitiale
      FROM  ADHESION
      WHERE F_ETAT_ADHE(idadhesion , sysdate )  = 0 --instance
      AND   F_ETAT_ADHE(idadhesion , sysdate, 2 ) in (58) -- motif préaff
      AND   NUMINDIV = infos.numindiv
      AND   IDADHESION = infos.idadhesion)

      SELECT   --INTO  loc_idadhesion  , loc_datapli
       distinct adhe_initial.IDADHESION, adhe_initial.datapli
       from adhe_initial

       UNION    -- On valide les dépendances cotisantes en même temps
       SELECT adhe_cntrt.IDADHESION, datapli --, numfor
         from adhesion, adhe_cntrt
         where adhe_cntrt.numadhe = infos.numindiv
         and adhesion.idadhesion = adhe_cntrt.idadhesion
         and  F_ETAT_ADHE(adhesion.idadhesion , sysdate )  = 0 --instance
         AND   F_ETAT_ADHE(adhesion.idadhesion , sysdate, 2 ) in (58,60)
         and   adhesion.numfor in (
          select numenvers from dependance
          where   role = 5 and numde in (
            select numfor from adhesion
            where idadhesion  in (
              select IDADHESION from  adhe_initial))
         )
         UNION

      select distinct id_adhesion idadhesion,  DATEEFFET datapli
        from rappel_souscript
        where idrappel in (
        select idrappel from rappel where numbene = infos.numindiv
        and rappel.entite = infos.idadhesion
        and type in (20,26,27)) ;


  BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  BEGIN
    l_lib_motif := f_lble('REJET_BIA',infos.motif );
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  loc_rappel.entite := infos.idadhesion;

  loc_rappel.contexte   := l_context_rappel;
  loc_rappel.type       :=  l_code_demande;
  loc_rappel. reference := i_idDemande_ext;
  loc_rappel.creation   := sysdate;
  loc_rappel.createur   := loc_numutil;
  loc_rappel.etat       := 3 ;
  loc_rappel.origine    := i_numporte;
  loc_rappel.DATEEFFET  := sysdate;
  loc_rappel.numassu    := infos.NUMINTERLOCUTEUR;
  loc_rappel.numcli     := i_numcli ;
  loc_rappel.numbene    := infos.numIndiv;

  loc_rappel.commentaire :=  'Société : '                     || i_numcli   ||';'|| CHR(13)||CHR(10) ||
                             'Interlocuteur : '                || infos.NUMINTERLOCUTEUR      ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || loc_rappel.numbene       ||';'|| CHR(13)||CHR(10) ||
                             'Idadhesion : '                     || infos.idadhesion       ||';'|| CHR(13)||CHR(10) ||
                             'Demande extérieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Motif : '                        || infos.motif ||'; ('||l_lib_motif||')'
                             ;
                             --'Date d''effet :'                 || d2e(i_dateeffet) ||';'||CHR(13)||CHR(10)||
  INSERT INTO rappel VALUES loc_rappel;
 -- RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numcli,null,i_idDemande_ext, l_code_demande);
  -- Suppression de l'adhesion
  -- l'adhésion doit -être ne instance avec motif de préaffiliation BIA (58)

  FOR rec_adhe_to_reject in c_adhesion_to_reject LOOP

    delete adhe_cntrt
    where idadhesion = rec_adhe_to_reject.idadhesion;

    delete adhesion
    where idadhesion = rec_adhe_to_reject.idadhesion;
    COMMIT;

  END LOOP;
  BEGIN
    -- Suppression de la souscription optionnel
   SELECT idrappel,
          to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) idadhesion_option
   INTO
          loc_idrappel_option,
          loc_idadhesion_optionnelle
             FROM rappel
   WHERE type = 27    -- adhesion optionnel   BIA  (l'option iris c'est 20)
   AND ETAT = 3   -- a valider
   AND to_number(F_GET_VALUE_IN_TABLE('Idadhesion_base', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) = infos.idadhesion -- la souscription optionnelle doit etre relative a celle de base
   AND numbene =infos.numIndiv -- la souscription optionnel doit concerné le même adhérent principal, cela évite les souscis lié a l'idadhésion qui est encore en max()+1...
  ;

  delete adhe_cntrt
  where idadhesion = loc_idadhesion_optionnelle;
  delete adhesion
  where idadhesion = loc_idadhesion_optionnelle;

  COMMIT;
  EXCEPTION
      WHEN OTHERS THEN NULL;
  END;

  UPDATE RAPPEL SET COMMENTAIRE = 'Mise à jour : Rejetté par Responsable le '||d2e(sysdate)||';'||chr(10)||chr(13)||COMMENTAIRE,
  etat = 5
  WHERE
  (idrappel IN (loc_idrappel_option)
    AND ETAT = 3
    AND TYPE = 27)
  OR (
      type = 26
      AND to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) = infos.idadhesion
      AND numbene = infos.numindiv
      AND ETAT = 2
      );

  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numcli,null,i_idDemande_ext, l_code_demande);


  EXCEPTION WHEN exc_adhesion_incompatible THEN
      PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'REJECT_SUBCRIBE_RH',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'exc_adhesion_incompatible  pas d''adhesion trouvée comptable pour id '||infos.idadhesion|| 'et individu '||infos.numindiv,
        I_idligne  => 2);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2351, 4);
      RETURN GET_RESP_KO(i_numcli,infos.numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2351,1)); --TODO L'adhésion n'est pas dans un état compatble avec votre demande
  END REJECT_SUBCRIBE_RH;

 /******************************************************************************/
  FUNCTION MAJ_SUBSCRIBE_RH(   i_numporte       IN NUMBER,
                               i_id_type        IN TYPE_FLUX.ID_TYPE%TYPE,
                               i_numcli           IN NUMBER,
                               i_idDemande_ext    IN NUMBER,
                               i_dateeffet        IN DATE,
                               infos            IN EXTR_QUALIF_SUBRIBE
                         )
  RETURN GENERIQUE_WS_RESP
    IS
    loc_rappel RAPPEL%ROWTYPE;
    l_context_rappel  NUMBER;
    loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
    l_code_demande    NUMBER;
    l_info_exist     NUMBER :=0;
    i number := 1;
    l_is_ok_to_rad number :=0;
    l_lib_motif  varchar(50);
    loc_idadhesion NUMBER;
    exc_adhesion_incompatible EXCEPTION;
    exc_histo_adhesion EXCEPTION;
    loc_HISTO_ADHESION  HISTO_ADHESION%ROWTYPE;
    loc_IDHISTOADHE NUMBER;
    loc_DATAPLI DATE;
    --références a la demande de souscription optionnelle
    loc_idrappel_option rappel.idrappel%type;
    loc_idadhesion_optionnelle  rappel.idrappel%type;


     CURSOR c_adhesion_to_valide is
      -- A supprimer quelques temps aprés la mise en production, le temps que toute les adhésions soient validées
         WITH adhe_initial As(
      SELECT DISTINCT IDADHESION, datapli, numgar        -- on prend l'adhesion intitiale
      FROM  ADHESION
      WHERE F_ETAT_ADHE(idadhesion , sysdate )  = 0 --instance
      AND   F_ETAT_ADHE(idadhesion , sysdate, 2 ) in (58) -- motif préaff
      AND   NUMINDIV = infos.numindiv
      AND   IDADHESION = infos.idadhesion)

      SELECT   --INTO  loc_idadhesion  , loc_datapli
       distinct adhe_initial.IDADHESION, adhe_initial.datapli
       from adhe_initial

       UNION    -- On valide les dépendances cotisantes en même temps
       SELECT adhe_cntrt.IDADHESION, datapli --, numfor
         from adhesion, adhe_cntrt
         where adhe_cntrt.numadhe = infos.numindiv
         and adhesion.idadhesion = adhe_cntrt.idadhesion
         and  F_ETAT_ADHE(adhesion.idadhesion , sysdate )  = 0 --instance
         AND   F_ETAT_ADHE(adhesion.idadhesion , sysdate, 2 ) in (58,60)
         and   adhesion.numfor in (
          select numenvers from dependance
          where   role = 5 and numde in (
            select numfor from adhesion
            where idadhesion  in (
              select IDADHESION from  adhe_initial))
         )
         UNION
      select distinct id_adhesion idadhesion,  DATEEFFET datapli
        from rappel_souscript
        where idrappel in (
        select idrappel from rappel where numbene = infos.numindiv
        and rappel.entite = infos.idadhesion
        and type in (20,26,27)) ;




  BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte);
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;

  BEGIN
    l_lib_motif := f_lble('REJET_BIA',infos.motif );
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  loc_rappel.entite := infos.idadhesion; -- l'entité améne sur la derniére adhésion de l'adhérent.

  loc_rappel.contexte    := l_context_rappel;
  loc_rappel.type        := l_code_demande;
  loc_rappel. reference  := i_idDemande_ext;
  loc_rappel.creation    := sysdate;
  loc_rappel.createur    := loc_numutil;
  loc_rappel.etat        := 3 ;
  loc_rappel.origine     := i_numporte;
  loc_rappel.DATEEFFET   := sysdate;
  loc_rappel.numassu     := infos.NUMINTERLOCUTEUR;
  loc_rappel.numcli      := i_numcli ;
  loc_rappel.numbene     := infos.numIndiv;

  loc_rappel.commentaire :=  'Société : '                      || i_numcli   ||';'|| CHR(13)||CHR(10) ||
                             'Interlocuteur : '                || infos.NUMINTERLOCUTEUR      ||';'|| CHR(13)||CHR(10) ||
                             'Individu : '                     || loc_rappel.numbene       ||';'|| CHR(13)||CHR(10) ||
                             'Idadhesion : '                   || infos.idadhesion       ||';'|| CHR(13)||CHR(10) ||
                             'Demande extérieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Motif : '                        || infos.motif ||'; ('||l_lib_motif||')'|| CHR(13)||CHR(10)||
                             'Date d''effet :'                 || d2e(i_dateeffet) ||';'
                             ;

  INSERT INTO rappel VALUES loc_rappel;
  -- Suppression de l'adhesion
  -- l'adhésion doit -être ne instance avec motif de préaffiliation BIA (58)

 /* BEGIN
    SELECT DISTINCT IDADHESION, DATAPLI
    INTO  loc_idadhesion , loc_DATAPLI
    FROM  ADHESION
    WHERE F_ETAT_ADHE(idadhesion , sysdate )  = 0 --instance
    AND   F_ETAT_ADHE(idadhesion , sysdate, 2 ) = 58 -- motif préaff
    AND   NUMINDIV = infos.numindiv   -- évite d'avoir des effet de bord a cause du max(idadhesion)
    AND   IDADHESION = infos.idadhesion
    ;
  EXCEPTION WHEN OTHERS
  THEN RAISE exc_adhesion_incompatible;
  END;  */

 FOR rec_adhe_to_valid in c_adhesion_to_valide LOOP
  loc_DATAPLI:=rec_adhe_to_valid.datapli;

  UPDATE adhesion set datapli = i_dateeffet where idadhesion = rec_adhe_to_valid.idadhesion;
  UPDATE adhe_cntrt set DATE_ADHE = i_dateeffet ,dsous = i_dateeffet where idadhesion = rec_adhe_to_valid.idadhesion;
  -- insertion d'une ligne dans HISTO_ADHESION avec la nouvelle date d'effet
  IF  i_dateeffet <  loc_DATAPLI       THEN
    UPDATE HISTO_ADHESION SET DEBUT =  i_dateeffet where idadhesion = rec_adhe_to_valid.idadhesion;
  END IF;
  P_INS_HISTO_ADHESION( i_idadhesion =>rec_adhe_to_valid.idadhesion,
                        i_datapli => i_dateeffet ,
                        i_etat => 0,
                        i_motif =>59,
                        i_numutil => loc_numutil
                      );

  END LOOP;
  BEGIN

  -- validation de la souscription optionnel
   SELECT idrappel,
          to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) idadhesion_option
   INTO
          loc_idrappel_option,
          loc_idadhesion_optionnelle
   FROM rappel
   WHERE type = 27    -- adhesion optionnel
   AND ETAT = 3   -- a valider
   AND to_number(F_GET_VALUE_IN_TABLE('Idadhesion_base', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) = infos.idadhesion -- la souscription optionnelle doit etre relative a celle de base
   AND numbene =infos.numIndiv ;-- la souscription optionnel doit concerné le même adhérent principal, cela évite les souscis lié a l'idadhésion qui est encore en max()+1...


  IF loc_idadhesion_optionnelle IS NOT NULL THEN
    UPDATE adhesion set datapli = i_dateeffet where idadhesion = loc_idadhesion_optionnelle;
    UPDATE adhe_cntrt set DATE_ADHE = i_dateeffet where idadhesion = loc_idadhesion_optionnelle;
    IF  i_dateeffet <  loc_DATAPLI       THEN
      UPDATE HISTO_ADHESION SET DEBUT =  i_dateeffet where idadhesion = loc_idadhesion_optionnelle;
    END IF;
     P_INS_HISTO_ADHESION(i_idadhesion =>loc_idadhesion_optionnelle,
                          i_datapli => i_dateeffet ,
                          i_etat => 0,
                          i_motif =>59,
                          i_numutil => loc_numutil) ;
  END IF;
  EXCEPTION
      WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'MAJ_SUBSCRIBE_RH',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'Pas d''adhesion optionnelle trouveée '||sqlerrm,
        I_idligne  => 2);
  END;

  --maj de l'option
  IF loc_idrappel_option IS NOT NULL THEN
    UPDATE RAPPEL SET
      COMMENTAIRE = 'Mise à jour : Modifié par Responsable le '||d2e(sysdate)||';'||chr(10)||chr(13)||COMMENTAIRE
    WHERE idrappel IN (loc_idrappel_option)
      AND ETAT = 3   -- traité on y touche plus
      AND TYPE = 27;
  END IF;

  --MAJ rappel de base
  UPDATE RAPPEL SET
    COMMENTAIRE = 'Mise à jour : Modifié par Responsable le '||d2e(sysdate)||';'||chr(10)||chr(13)||COMMENTAIRE,
    etat = 1
  WHERE type = 26
  AND to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) = infos.idadhesion
  AND numbene = infos.numindiv
  --AND ETAT = 2 -- passage en etat nouveau pour f_valide_subscribe
  ;

  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numcli,null,i_idDemande_ext, l_code_demande);

  EXCEPTION
    WHEN exc_adhesion_incompatible THEN
      PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'MAJ_SUBSCRIBE_RH',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'exc_adhesion_incompatible  pas d''adhesion trouvée comptable pour id '||infos.idadhesion|| 'et individu '||infos.numindiv,
        I_idligne  => 2);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2350, 4);
      RETURN GET_RESP_KO(i_numcli,infos.numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2350,1)); --TODO L'adhésion n'est pas dans un état compatble avec votre demande
    WHEN exc_histo_adhesion THEN
      PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'MAJ_SUBSCRIBE_RH',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'exc_histo_adhesion impossible d inserer '||infos.idadhesion|| 'et individu '||infos.numindiv,
        I_idligne  => 2);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2351, 4);
      RETURN GET_RESP_KO(i_numcli,infos.numIndiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2351,1)); --TODO L'adhésion n'est pas dans un état compatble avec votre demande
   END MAJ_SUBSCRIBE_RH;

 /***************************************************************************************************************************/

  /*** Procédure permettant de sauvegarder dans une table toutes les informations des actes passés en paramétre via le service ADD_DOS_CALC ******/
PROCEDURE P_SAVE_TAB_ACT( i_rappel  IN rappel%rowtype
                          ,i_tab_act IN EXTR_TAB_ACTS_CALC
   )
   IS
   l_acte_rappel ACTE_RAPPEL%ROWTYPE;
   i NUMBER := 1;
   BEGIN
       WHILE i <= i_tab_act.count LOOP
          l_acte_rappel.idrappel    := i_rappel.idrappel    ;
          l_acte_rappel.CodeFrais   :=i_tab_act(i).CodeFrais;
          l_acte_rappel.Datsin      :=i_tab_act(i).Datsin   ;
          l_acte_rappel.pdsqls      :=i_tab_act(i).pdsqls   ;
          l_acte_rappel.CAS         :=i_tab_act(i).CAS      ;
          l_acte_rappel.Spe         :=i_tab_act(i).Spe      ;
          l_acte_rappel.RefActe     :=i_tab_act(i).RefActe  ;
          l_acte_rappel.Coeff       :=i_tab_act(i).Coeff    ;
          l_acte_rappel.nbacte      :=i_tab_act(i).nbacte   ;
          l_acte_rappel.mtfrais     :=i_tab_act(i).mtfrais  ;
          l_acte_rappel.Taux        :=i_tab_act(i).Taux     ;
          l_acte_rappel.baseRemb    :=i_tab_act(i).baseRemb ;
          l_acte_rappel.mtremb      :=i_tab_act(i).mtremb   ;
          l_acte_rappel.ar          :=i_tab_act(i).ar       ;

       INSERT INTO ACTE_RAPPEL values  l_acte_rappel;
       i:=i+1;
    END LOOP;


     END ;
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  SUBSCRIBE                                                 */
/* Type         :  Public                                                    */
/* Description  :  Fonction de récupération des données du commentaire suite */
/*                 à une demande de souscription en ligne                    */
/* Auteur       :  CLI/JBO                                                   */
/* Date         :  15/09/2017                                                */
/* Commentaire  :  Projet P201709001_EA_Adhesion_Ind_GEREP                   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
  FUNCTION SUBSCRIBE (  i_numporte        IN NUMBER,
                        i_id_type         IN TYPE_FLUX.ID_TYPE%TYPE,
                        i_numAdherent     IN NUMBER,
                        i_idDemande_ext   IN NUMBER,
                        i_TABPROSPECT     IN EXTR_TAB_BENE_PROSPECT,
                        i_dateeffet       IN DATE ,
                        I_MODE_PAIE       IN NUMBER,
                        i_PRIX_TOT        IN NUMBER,
                        i_NATURE          IN NUMBER, --1 option, 2 base
                        i_Idadhesion_base IN NUMBER,
                        i_documents       IN EXT_TAB_DOCUMENT
  )
  RETURN EXTR_R_SUBCRIBE IS
    loc_rappel                    RAPPEL%ROWTYPE;
    l_context_rappel              NUMBER;
    loc_numutil                   UTILISATEURS.NUMUTIL%TYPE;
    l_code_demande                NUMBER ;
    i                             NUMBER;
    J                             NUMBER;
    K                             NUMBER;
    l_info_souscription           VARCHAR2(1000);
    L_liste_contrat               VARCHAR2(1000) := '';
    l_liste_garantie              VARCHAR2(500) :='';
    separateur_garantie           VARCHAR2(1) := '';
    loc_type_adr                  INDIVIDU.TYPADR%TYPE;
    loc_l_NATURE                VARCHAR2(50);
    loc_result_instanciation    NUMBER;
    loc_idadhesion              NUMBER;
    loc_rappel_sous rappel_souscript%rowtype;
    loc_numcli number;
    loc_choix VARCHAR2(5);
    loc_isnb NUMBER;
 BEGIN

    l_code_demande := get_code_demande(i_id_type,i_numporte);
    -- creation de l'événement dans la table rappel
    SELECT sens INTO l_context_rappel
      FROM libelle
     WHERE mnemo ='TYPERAPPEL'
       AND CODE = l_code_demande;
    BEGIN
     SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
    EXCEPTION
      WHEN OTHERS THEN loc_numutil:=f_numutil;
    END;
    SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
    loc_rappel.contexte   :=  0;-- on met le contexte personne car si l'instanciation de l'adhésion pose problème on sera toujours sur l'individu en question(la clef change lorsque l'adhésion est créée)
    -- l_context_rappel;
    loc_rappel.type       := l_code_demande;
    loc_rappel.reference := i_idDemande_ext;
    loc_rappel.creation := sysdate;
    loc_rappel.createur := loc_numutil;
    loc_rappel.etat     := 1;
    loc_rappel.origine  := i_numporte;
    loc_rappel.numassu  := i_numAdherent;
    loc_rappel.numbene  := i_numAdherent;
    loc_rappel.entite := i_numAdherent;
    loc_rappel.dateeffet := i_dateeffet;
    BEGIN
      SELECT NUMCLI INTO loc_numcli
      FROM CONTRAT_ref
      WHERE NUMGAR = to_number(i_TABPROSPECT(1).TAB_CONTRACTS(1).NUMGAR) ;
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
    SELECT decode(i_NATURE,1,'Optionnelle',2,'De base',3,'Optionnelle depuis pré-aff') INTO  loc_l_NATURE FROM DUAL;


    loc_rappel.commentaire :=  'Adhérent : '                        || i_numAdherent   ||';'|| CHR(13)||CHR(10) ||
                               'Demande extérieure : '              || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                               'Société : '                         || f_nom(loc_numcli) ||';'|| CHR(13)||CHR(10)||
                               'Date d''effet : '                   || d2e(i_dateeffet) ||';'|| CHR(13)||CHR(10)||
                               'Type de souscription : '            || i_NATURE ||';'|| CHR(13)||CHR(10)||
                               'Libellé du type de Souscription : ' || loc_l_NATURE ||';'|| CHR(13)||CHR(10)||
                               'Mode de paiement :'                 ||I_MODE_PAIE||';'|| CHR(13)||CHR(10)||
                             --'L Mode de paiement :'               ||f_lble('MOPM',I_MODE_PAIE)||';'|| CHR(13)||CHR(10)||
                               'Prix total :'                       ||i_PRIX_TOT||';'|| CHR(13)||CHR(10)||
                               'Idadhesion_base :'                  ||i_Idadhesion_base||';'|| CHR(13)||CHR(10)||
                               'Documents : ';
    IF i_documents IS NOT NULL THEN
      WHILE i <= i_documents.COUNT LOOP
        loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
        i:=i+1;
      END LOOP;
    END IF;
    loc_rappel.commentaire := loc_rappel.commentaire||';';
    i:=1;

    FOR I in 1..i_TABPROSPECT.COUNT LOOP        -- POUR chaque BENEFICAIRE
      l_info_souscription :=  CHR(13)||CHR(10)||'Souscription_'||I||' : ';
      L_liste_contrat :='';

      FOR J IN 1 .. i_TABPROSPECT(I).TAB_CONTRACTS.COUNT LOOP -- pour chaque contrat
        separateur_garantie :='';
        l_liste_garantie :='';
        FOR K IN 1..i_TABPROSPECT(I).TAB_CONTRACTS(J).TAB_GRNT.COUNT LOOP -- Pour chaque Options
          l_liste_garantie := l_liste_garantie ||separateur_garantie||  i_TABPROSPECT(I).TAB_CONTRACTS(J).TAB_GRNT(K).NUMFOR;
          separateur_garantie :=' ';
          loc_rappel_sous.idrappel  := loc_rappel.idrappel;
          loc_rappel_sous.numgar    :=to_number(i_TABPROSPECT(I).TAB_CONTRACTS(J).NUMGAR);
          loc_rappel_sous.numfor    := to_number(i_TABPROSPECT(I).TAB_CONTRACTS(J).TAB_GRNT(K).NUMFOR);
          loc_rappel_sous.numindiv  :=to_number(i_TABPROSPECT(I).NUMINDIV);
          loc_rappel_sous.mdpmt     := I_MODE_PAIE;
          loc_rappel_sous. typassu  := i_TABPROSPECT(I).TYPBENE ;
          loc_rappel_sous. provenance  := 1 ; -- demande initiale, a instancié en premier
          loc_choix := i_TABPROSPECT(I).TAB_CONTRACTS(J).TAB_GRNT(K).CHOIX_GAR;

          loc_isnb:=0;
          --le champs choix_gar peut contenir soit OBL... ou un nombre
          BEGIN
            SELECT  1 INTO loc_isnb  FROM    dual  WHERE REGEXP_LIKE (loc_choix,'^-?\d+(\.\d+)?$');
            IF NVL(loc_isnb,0) =1 THEN loc_rappel_sous.rang  := to_number(loc_choix);
            ELSE loc_rappel_sous.rang:=1;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN loc_rappel_sous.rang:=1;
          END;
          loc_rappel_sous.type_souscription :=  i_NATURE;
          loc_rappel_sous.dateeffet := i_dateeffet;
          INSERT INTO rappel_souscript
          VALUES loc_rappel_sous;
        END LOOP;
        L_liste_contrat := L_liste_contrat || CHR(13)||CHR(10)||
                          'CONTRAT_'||J||' : '||  i_TABPROSPECT(I).TAB_CONTRACTS(J).NUMGAR||';'|| CHR(13)||CHR(10)||
                          'Offre_'||J||' : '||  i_TABPROSPECT(I).TAB_CONTRACTS(J).TAB_GRNT(1).OFFRE||';'|| CHR(13)||CHR(10)||
                          'GARANTIES_'||J||' : ('||  l_liste_garantie||');';

      END LOOP;
      l_info_souscription := l_info_souscription||CHR(13)||CHR(10)||'['||'NUMBENE_'||I||' : '||i_TABPROSPECT(I).NUMINDIV||';'|| CHR(13)||CHR(10)||
                            'TYPBENE_'||I||' : '|| i_TABPROSPECT(I).TYPBENE||';'||
                                  L_liste_contrat||'];';
      loc_rappel.commentaire := loc_rappel.commentaire ||  l_info_souscription;

    END lOOP;




    -- Ajout des garanties dependantes dans rappel souscript
        P_insert_grnt_dependante(loc_rappel.idrappel,
                                          i_numAdherent );


    INSERT INTO rappel VALUES loc_rappel;
    INSERT_LIEN_GED(i_documents, 30, loc_rappel.idrappel, i_numAdherent,i_numporte, loc_numutil, loc_rappel.idrappel);
    commit;

   -- fin de création du commentaire

    If   i_dateeffet < add_months(sysdate,-3)  THEN
       SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2355, 4);
      RETURN new EXTR_R_SUBCRIBE(GET_RESP_KO(i_numAdherent,i_numAdherent,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2355,1)),
                                  null) ;

    END IF;
    -- BIA creation de l'adhésion en instance
    loc_result_instanciation := F_INSTANCIE_SUBSCRIBE_dev(loc_rappel.idrappel , loc_rappel.origine);

    IF loc_result_instanciation not in (0, 2261)  THEN
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_result_instanciation, 4);
      RETURN new EXTR_R_SUBCRIBE(GET_RESP_KO(i_numAdherent,i_numAdherent,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_result_instanciation,1)),
                                  null) ;
    END IF;

   --on ne génére pas d'AR pour l'option sur portail pré-aff
   IF loc_rappel_sous.type_souscription <> 3 THEN
       IF loc_rappel_sous.type_souscription  =2 then  -- on n'evnoi pas d'accusé de reception autre que la reception du bia de base
         DELETE envoi_mail
         where 1=1 -- idtexte = 29       -- on prend aussi les mails auto générés par trigger (les idtexte sont différents de 29)
         and numindiv_dest =  i_numAdherent
         and etat = 0
         and datemis is null
         and trunc(date_creation) =trunc(sysdate);
       PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite,33); -- création du mail accusé de reception specifique BASE
      ELSE  -- sinon on est en souscrption d'option classique via lespace assuré(1)
      PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numAdherent, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
       END IF;

   END IF;

   SELECT   to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire)))
   INTO  loc_idadhesion
   FROM rappel
   WHERE loc_rappel.idrappel = idrappel;

   IF  l_code_demande in  (26) then   -- si on arrive ici c'est que tout c'est bien passé, on passe  BIA en attente, car validation RH a venir
        SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 2);
   elsif l_code_demande = 20 THEN
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 1); -- sinon on les passe en nouveau pour les options IRIS
    ELSE
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 3); -- sinon on les passe en traité
   END IF;

    RETURN new EXTR_R_SUBCRIBE(GET_RESP_OK(i_numAdherent,i_numAdherent,i_idDemande_ext, l_code_demande),loc_idadhesion);
  EXCEPTION
   WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'PK_WEB_MAJ.SUBSCRIBE',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
        I_idligne  => 2);
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
      RETURN new EXTR_R_SUBCRIBE(GET_RESP_KO(i_numAdherent,i_numAdherent,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1)),
                                null);
  END SUBSCRIBE;


  -- Procédure permettant d'inserer dans rappel souscript les garanties a instancier dans le contexte PEPS
PROCEDURE P_insert_grnt_dependante(i_idrappel rappel.idrappel%type,
                                            i_numadhe individu.numindiv%type )IS
  CURSOR c_adhesion_rappel(p_id_rappel NUMBER, p_numadhe number) is
  select datas.* from (
              -- cas de l'appel de cotisation niveau affilié, chaque adhésion couvrante a sa propre cotisante (par tête)
       SELECT  rappel_souscript.idrappel,
              gar_cntrt.numgar,
              gar_cntrt.numfor,
              rappel_souscript.numindiv,
              rappel_souscript.typassu,
              null, --idadhesion
              rappel_souscript.mdpmt,--mdpmt,
              rappel_souscript.type_souscription,
              rappel_souscript.dateeffet,
              rappel_souscript.rang
      FROM   rappel_souscript, gar_cntrt, contrat
        WHERE idrappel = p_id_rappel
        AND gar_cntrt.numgar = contrat.numgar
        AND TYPE_CALC = 3   --
        AND gar_cntrt.numfor in (select numenvers from dependance where numde = rappel_souscript.numfor and role = 5)

    UNION  -- cas de l'appel niveau adhérent, la cotisante es porté uniquement par l'adhérent principale

      SELECT distinct  rappel_souscript.idrappel,
              gar_cntrt.numgar,
              gar_cntrt.numfor,
              p_numadhe, --rappel_souscript.numindiv, -- on met l'adhérent en bénéficiaire de l'adhesion cotisante
              0,--rappel_souscript.typassu,
              null, --idadhesion
              rappel_souscript.mdpmt,--mdpmt,
              rappel_souscript.type_souscription,
              rappel_souscript.dateeffet,
               1 --rappel_souscript.rang
      FROM   rappel_souscript, gar_cntrt, contrat
        WHERE idrappel = p_id_rappel
        AND gar_cntrt.numgar = contrat.numgar
        AND TYPE_CALC <>3   --
        AND gar_cntrt.numfor in (select numenvers from dependance where numde = rappel_souscript.numfor and role = 5)


      UNION -- on prends aussi les options du protfeuille 7  "option obligatoire"
             SELECT  rappel_souscript.idrappel,
              gar_cntrt.numgar,
              gar_cntrt.numfor,
              rappel_souscript.numindiv,
              rappel_souscript.typassu,
              null, --idadhesion
              rappel_souscript.mdpmt,--mdpmt,
              rappel_souscript.type_souscription,
              rappel_souscript.dateeffet,
              rappel_souscript.rang
      FROM   rappel_souscript, gar_cntrt, contrat
        WHERE idrappel = p_id_rappel
        AND gar_cntrt.numgar = contrat.numgar
        AND gar_cntrt.numfor in (select numenvers from dependance where numde = rappel_souscript.numfor and role = 4) -- depedance entre le numfor de base et son option
        AND  contrat.numgar in (SELECT numgar FROM TABLE(PK_WS_WEB_BACK.F_GET_CONTRATS_DEPENDANTS(rappel_souscript.numgar,rappel_souscript.dateeffet)) )
        and contrat.PORTEFEUILLE  in (7) -- (on prend les options du portefeuille obligatoire)  BIA

    )
  datas
    ORDER BY
            CASE WHEN numindiv = p_numadhe  THEN 1 ELSE 2 END asc,
            NUMGAR DESC,
            NUMFOR,
            NUMINDIV,
            TYPASSU ASC
        ;
  loc_rappel_sous rappel_souscript%rowtype;
  BEGIN
        -- parcours des garanties dépendantes pour les ajouter dans rappel_souscript

        for r_garantie in c_adhesion_rappel(i_idrappel , i_numadhe ) loop
         loc_rappel_sous.idrappel  := i_idrappel;
          loc_rappel_sous.numgar    := r_garantie.numgar;
          loc_rappel_sous.numfor    := r_garantie.numfor;
          loc_rappel_sous.numindiv  := r_garantie.NUMINDIV;
          loc_rappel_sous.mdpmt     := r_garantie.mdpmt;
          loc_rappel_sous.typassu  := r_garantie.TYPassu ;
          loc_rappel_sous. provenance  := 2 ; -- dépendance a instancier en second lieu
          loc_rappel_sous.rang:=r_garantie.rang;
          loc_rappel_sous.type_souscription :=  r_garantie.type_souscription;
          loc_rappel_sous.dateeffet := r_garantie.dateeffet;
          insert into rappel_souscript
          values   loc_rappel_sous ;
        end loop;

  END P_insert_grnt_dependante;

/***********************************************************************************UTIL************************************************************************************/
/***********************************************************************************UTIL************************************************************************************/
/***********************************************************************************UTIL************************************************************************************/

  FUNCTION GET_RESP_OK(  numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                        numindiv      IN INDIVIDU.NUMINDIV%TYPE,
                        idDemande_ext IN NUMBER,
                        typeDemande   IN NUMBER,
                        message       IN VARCHAR2 DEFAULT NULL)
  RETURN GENERIQUE_WS_RESP
  IS
   wsResponse GENERIQUE_WS_RESP;
    BEGIN
      wsResponse := new GENERIQUE_WS_RESP( numAdherent    => numAdherent,
                                           numIndiv       => numindiv,
                                           dateDemande    => sysdate,
                                           typeDemande    => typeDemande,
                                           libelleDemande => f_lble(a_mnemo => 'WEB_MAJ', a_code=> typeDemande),
                                           codeReponse     => 0 ,
                                           messageErreur  => message,
                                           idDemande_ext  => idDemande_ext);
    RETURN wsResponse;
  END GET_RESP_OK;



    /********************************************************/


  FUNCTION GET_RESP_KO(  numAdherent   IN INDIVIDU.NUMINDIV%TYPE,
                        numindiv      IN INDIVIDU.NUMINDIV%TYPE,
                        idDemande_ext IN NUMBER,
                        typeDemande   IN NUMBER,
                        mess_erreur   IN VARCHAR2)
  RETURN GENERIQUE_WS_RESP
  IS
   wsResponse GENERIQUE_WS_RESP;
  BEGIN
    PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'PK_WEB_MAJ.GET_RESP_KO',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'typeDemande ='||typeDemande||' REP KO '||SQLERRM,
      I_idligne  => 2);
    wsResponse := new GENERIQUE_WS_RESP( numAdherent    => numAdherent,
                                         numIndiv       => numindiv,
                                         dateDemande    => sysdate,
                                         typeDemande    => typeDemande,
                                         libelleDemande => f_lble(a_mnemo => 'WEB_MAJ', a_code=> typeDemande),
                                         codeReponse     => 1 ,
                                         messageErreur  => mess_erreur,
                                         idDemande_ext  => idDemande_ext);
    RETURN wsResponse;
  END GET_RESP_KO;



    /********************************************************/
/**
 * Permet de postionner une date d'annulation sur les pièces concernant un rappel
 **/
PROCEDURE P_ANNUL_PIECES(i_idrappel IN NUMBER,  o_erreur OUT NUMBER)
AS
 loc_rappel rappel%rowtype ;
BEGIN

    SELECT * INTO loc_rappel
    FROM RAPPEL
    WHERE idrappel = i_idrappel;

    UPDATE  pieces SET datannul = sysdate
        WHERE idpiece IN   (
          SELECT clef  FROM lien_ged
          WHERE ref_ext =i_idrappel
          AND src = loc_rappel.origine
          AND etat =3  -- au moins un lien_ged doit être invalidé pour positioner une date d'annulation sur la pièce
          AND lien_ged.ETENDUE<>30 -- on ne touche pas au contexte 30 des demandes
          )
          AND daterecep IS NULL
          AND datannul IS NULL;  -- on n'écrase pas pas de date d'annulation

     EXCEPTION WHEN NO_DATA_FOUND THEN
          o_erreur:=44; -- variable donnée inconnue
END P_ANNUL_PIECES;

/**
 * Permet de postionner une date de reception sur les pièces concernant un rappel dont un lien ged est valide
 **/

PROCEDURE P_RECEPT_PIECES(i_idrappel IN NUMBER,  o_erreur OUT NUMBER)
AS
 loc_rappel rappel%rowtype ;
BEGIN
    SELECT * INTO loc_rappel
    FROM RAPPEL
    WHERE idrappel = i_idrappel;

    UPDATE  pieces SET daterecep = sysdate
        WHERE idpiece IN   (
          SELECT clef  FROM lien_ged
          WHERE ref_ext =i_idrappel
          AND src = loc_rappel.origine
          AND etat = 2  -- au moins un lien_ged doit être validé pour positioner une date de reception sur la pièce
          AND lien_ged.ETENDUE<>30 -- on ne touche pas au contexte 30 des demandes
          )
          AND daterecep IS NULL   -- on ne fait rien si la pièce est déjà receptionnée
          AND datannul IS NULL;  -- on n'écrase pas pas de date d'annulation

     EXCEPTION WHEN NO_DATA_FOUND THEN
          o_erreur:=44; -- variable donnée inconnue
END P_RECEPT_PIECES;


   /********************************************************/
FUNCTION RESPONSE_TO_XML(response GENERIQUE_WS_RESP)
RETURN XMLTYPE
IS
  xml_file XMLTYPE;
BEGIN

  SELECT XMLROOT( XMLELEMENT ("reponse",XMLELEMENT( "numIndiv",response.numIndiv),XMLELEMENT( "idDemande_ext",response.idDemande_ext) ,
  XMLELEMENT( "typeDemande",response.typeDemande),XMLELEMENT( "libelleDemande",response.libelleDemande),XMLELEMENT( "codeReponse",response.codeReponse),XMLELEMENT( "messageErreur",response.messageErreur),XMLELEMENT( "dateDemande",response.dateDemande)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
  INTO xml_file
  FROM dual;

  return xml_file;
END RESPONSE_TO_XML;

    /********************************************************/
PROCEDURE INFO_CVRT_PRCH( i_numindiv IN NUMBER,
                          numgar out number,
                          numfor out number,
                          edatapli out number,
                          idadhesion out number,
                          i_datehospi IN DATE
                    )
IS
  loc_numfor adhesion.NUMFOR%TYPE;
  loc_numgar adhesion.NUMGAR%TYPE;
  loc_idadhesion adhesion.IDADHESION%TYPE;
  loc_edatapli number;

 -- tri par typgar : base /option
 -- rang 2 exclu : pas de pec hospi pour les assurés en surcomplémentaires
  CURSOR C_cvrt IS
  SELECT couverture.numgar,
         couverture.numfor,
         to_char(couverture.datapli,'j') edatapli,
         couverture.idadhesion
  FROM couverture, formule f
  WHERE couverture.NUMINDIV = i_numindiv
  AND f.numfor =   pk_qttc.f_sel_numfor(couverture.NUMGAR, couverture.NUMFOR)
  AND COUVERTURE.NUMFOR in
         (SELECT CALCUL.NUMFOR FROM CALCUL,DEFRUB
           WHERE CALCUL.NUMFOR = COUVERTURE.NUMFOR
             AND DEFRUB.NUMFOR = COUVERTURE.NUMFOR
             AND i_datehospi BETWEEN DEFRUB.DATAPLI
                                 AND nvl(DEFRUB.DATPER,i_datehospi)
             AND i_datehospi BETWEEN CALCUL.DATAPLI
                                 AND nvl(CALCUL.DATPER,i_datehospi)
             AND DEFRUB.DATAPLI !=
                 nvl(DEFRUB.DATPER,DEFRUB.DATAPLI+1)
             AND CALCUL.DATAPLI !=
                 nvl(CALCUL.DATPER,CALCUL.DATAPLI+1))
  AND COUVERTURE.DATAPLI <= i_datehospi
  AND nvl(COUVERTURE.DATPER,i_datehospi) >= i_datehospi
  AND couverture.rang = 1
  ORDER BY f.typgar,couverture.datapli;

BEGIN

  --ABO 15/02/2016 M5050 : en cas de double couverture par même garantie surco conjoint
  --on ne prend que la 1ère occurence du  curseur.
  --l'édition suit ce choix de contrat pour le modèle de courrier et cette garantie
  BEGIN
    FOR R_c_cvrt IN c_cvrt LOOP
      numgar:=R_c_cvrt.numgar;
      numfor:=R_c_cvrt.numfor;
      edatapli:=R_c_cvrt.edatapli;
      idadhesion:=R_c_cvrt.idadhesion;
      EXIT;
    END LOOP;
  END;

-- Message('Numgar : '||to_char(loc_numgar));
END INFO_CVRT_PRCH;


FUNCTION GET_CODE_DEMANDE( i_id_type IN TYPE_FLUX.ID_TYPE%TYPE, i_numporte NUMBER DEFAULT 25)
RETURN NUMBER
IS
  o_code_demande type_flux.CODE_SERVICE%TYPE;
BEGIN
   BEGIN
    SELECT CODE_SERVICE
      INTO o_CODE_DEMANDE
      FROM TYPE_FLUX
      WHERE ID_TYPE = i_id_type
      AND num_porte =to_char(i_numporte);
    EXCEPTION
      WHEN OTHERS THEN
         o_code_demande:=0;
    END;
     RETURN    o_code_demande;
END GET_CODE_DEMANDE;


  /****************************************/

/******* RÉCUPERATION DE l'adhérent Parent */
FUNCTION GET_FIRST_NOT_CHILD( i_beneficiaires  IN EXTR_TAB_BENEFICIAIRE, i_numassu NUMBER, i_numindiv NUMBER)
  RETURN NUMBER  IS
  i NUMBER :=1;
  l_numindiv NUMBER;

  CURSOR c_parents IS
  SELECT NUMINDIV FROM ADHE_CNTRT_MEMBRE
  WHERE NUMINDIV IN (SELECT numindiv FROM TABLE (i_beneficiaires))
  AND TYPADR NOT IN (0,2)-- on ne prend pas l'assuré pincipale ni les enfants
  AND IDADHESION IN(
    SELECT MIN(a1.IDADHESION)
    FROM adhe_cntrt a1 ,ADHE_CNTRT_MEMBRE a2
    WHERE a1.idadhesion = a2.idadhesion
    AND a1.numadhe = i_numassu
    AND (sysdate between a1.date_adhe and nvl (a1.date_fin_adhe, sysdate) OR a1.date_adhe > SYSDATE)
    AND a2.NUMINDIV = i_numassu
    AND a2.TYPADR =0
    )--  adhésion pour laqquelle l'assuré est l'assuré principale
    ORDER BY TYPADR ASC
  ;
  rec_parent c_parents%ROWTYPE;

  BEGIN
    IF i_numassu = i_numindiv THEN   -- l'assuré est automatiquement le porteur du rib si numindiv = numassu.
      RETURN i_numassu;
    ELSIF i_numindiv=0 THEN l_numindiv:=NULL;
    END IF;

    OPEN c_parents;
    FETCH C_parents INTO Rec_parent;

    IF C_parents%NOTFOUND THEN
      CLOSE c_parents;
      RETURN nvl(l_numindiv,i_beneficiaires(1).numindiv);      -- si le numero d'individu est null on prend le premier de la liste pour qu'il soit le proteur du rib
    ELSE
      CLOSE c_parents;
      RETURN Rec_parent.numindiv;
    END IF;
    RETURN nvl(l_numindiv,i_beneficiaires(1).numindiv);  -- si il n'y a que des enfants on retourne null, un nvl doit e^tre fait au retour de la fonction pour prendre le numindiv par defaut

  EXCEPTION
    WHEN OTHERS THEN RETURN nvl(l_numindiv,i_beneficiaires(1).numindiv);
END GET_FIRST_NOT_CHILD;


  /************************************************************************/
PROCEDURE SET_RAPPEL_ERREUR( i_idrappel IN RAPPEL.idrappel%TYPE, i_code_err  IN RAPPEL.code_err%TYPE, i_etat IN RAPPEL.etat%TYPE)
IS
BEGIN
UPDATE RAPPEL
  SET ETAT = i_etat,
  CODE_ERR = i_code_err ,
  modificateur = decode(F_numutil, 8, null, f_numutil),
  maj = decode(F_numutil, 8, null, sysdate)    --RKO M0005772
  WHERE idrappel = i_idrappel;
COMMIT;
END SET_RAPPEL_ERREUR;

/***********************************************************************/
FUNCTION F_FORMAT ( P_Chaine   IN   VARCHAR2)
  RETURN  VARCHAR2
  IS
  BEGIN

    RETURN UPPER(TRIM(TRANSLATE(P_Chaine,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ-''','AAEEEEIIaaaaeeeeiiouuUUO ')));

  EXCEPTION
    WHEN OTHERS THEN
      RETURN P_Chaine;
  END F_FORMAT;

/***********************************************************************************************************/
/**** Procéudre qui cree  les lien GED d'une demande, Prend en entré un tableau de document ****************/
/***********************************************************************************************************/
PROCEDURE INSERT_LIEN_GED( i_documents  IN EXT_TAB_DOCUMENT, i_etendue IN NUMBER, i_iddemande IN NUMBER, i_numindiv IN NUMBER, i_numporte IN NUMBER, i_numutil IN NUMBER, i_numclef IN NUMBER)
IS
i number := 1;
l_lien_ged LIEN_GED%ROWTYPE;
BEGIN
  IF i_documents.COUNT>0 AND (i_documents(i_documents.COUNT).IDDOC IS NOT NULL OR i_documents(i_documents.COUNT).NOMDOC IS NOT NULL) THEN
    i:=1;
    WHILE i <= i_documents.COUNT LOOP
      l_lien_ged :=null;
      SELECT SEQ_LIEN_GED.nextval
      INTO  l_lien_ged.id_lien FROM DUAL;
      l_lien_ged.ETENDUE     :=i_etendue;
      l_lien_ged.CLEF        :=i_numclef; -- clef (id de la pièce)  ou de la demande
      l_lien_ged.IDDOC       :=i_documents(i).IDDOC;
      l_lien_ged.NOMDOC      :=i_documents(i).NOMDOC;
      l_lien_ged.REF_EXT     :=i_iddemande;
      l_lien_ged.NUMINDIV    :=i_numindiv;
      l_lien_ged.SRC         := i_numporte;
      l_lien_ged.DATECREA    := sysdate ;
      l_lien_ged.USERCREA    := i_numutil;
      l_lien_ged.ETAT        := 1; --a valider
      l_lien_ged.DATE_VALID  := null;
      l_lien_ged.DATE_INVALID:= null;
PK_trace.P_INS_journal_adm (
I_nom_traitement => 'INSERT_LIEN_GED',
I_session  => SID,
I_niv_msg  => 3,
I_msg_adm  => 'dans insert lien_ged i='||i||' etendue '||l_lien_ged.ETENDUE||' clef '||l_lien_ged.CLEF||' iddoc '||l_lien_ged.IDDOC
              ||'nomdoc'||l_lien_ged.NOMDOC||'ref_ext'||l_lien_ged.REF_EXT||'numporte'||l_lien_ged.SRC,
I_idligne  => i);
      insert into lien_ged values l_lien_ged ;
      i:=i+1;
    END LOOP;
  END IF;
END;
/*******************************************************************************/
/*** Supprimes les lien Ged celon une etendu et une clef ***********************/
/*** Utile quand on doit rattaché les lien a autre chose que le rappel initial**/
/*******************************************************************************/
PROCEDURE DELETE_LIEN_GED( i_etendue IN NUMBER, i_clef IN NUMBER)
IS
BEGIN
    DELETE LIEN_GED l
    WHERE   l.ETENDUE =  i_etendue
    AND     l.clef = i_clef;
END DELETE_LIEN_GED;

 /* Fonction servant a verifier si le rib que l'on essaye de remplacer est anterieur a celui qui l'on créé*/
 FUNCTION IS_RIB_AFTER_CURRENT (i_id_rib IN rib.idrib%type, i_dateeffet IN  DATE ) RETURN NUMBER
 IS
 loc_code_erreur rappel.code_err%type;
 BEGIN
    SELECT distinct 2196
      INTO  loc_code_erreur
      FROM  RIB r
      WHERE r.IDRIB = i_id_rib
        AND r.debut > i_dateEffet;
   return loc_code_erreur;
  EXCEPTION
      WHEN OTHERS THEN  -- si on a rien trouvé on continu
            return 0;
 END IS_RIB_AFTER_CURRENT;

 /*****************************************************************************/
 FUNCTION IS_RIB_DIFFERENT (i_id_rib IN rib.idrib%type,
                            i_BIC IN RIB.BIC%TYPE,
                            i_BBAN IN rib.bban%type,
                            i_clerib  IN rib.CLERIB%TYPE)
 RETURN NUMBER
 IS
  loc_code_erreur rappel.code_err%type;
  BEGIN
    SELECT distinct 2197
      INTO  loc_code_erreur
      FROM  RIB r
      WHERE r.IDRIB = i_id_rib
        AND nvl(r.bban,1) = nvl(i_bban,1)
        AND nvl(r.clerib,1) = nvl(i_clerib,1)
        AND nvl(r.bic,1) = nvl(i_bic,1)  ;
    return loc_code_erreur;

  EXCEPTION
      WHEN OTHERS THEN  -- si on a rien trouvé on continu
            return 0;
 END IS_RIB_DIFFERENT;


 /************************ UTIL_ADD_BENE***************************************/
 FUNCTION IS_BENE_DOUBLON (i_numAdherent      IN NUMBER,
                           i_nom              IN VARCHAR2,
                           i_prenom           IN VARCHAR2,
                           i_datenaiss        IN DATE,
                           i_numss IN varchar2 DEFAULT NULL)
  RETURN NUMBER
  IS
  l_beneficiaire_existant INDIVIDU.NUmINDIV%TYPE;
  BEGIN
      SELECT numindiv
      INTO l_beneficiaire_existant
      FROM INDIVIDU
      WHERE (UPPER(NOM)   = UPPER(i_nom) OR  matorg||cless = nvl(i_numss,matorg||cless) )
        AND UPPER(PRENOM) = UPPER(i_prenom)
        AND TRUNC(DATNAIS)  = TRUNC(i_datenaiss)
        AND NUMASSU <> i_numAdherent;
  RETURN 2198;
  EXCEPTION
  WHEN TOO_MANY_ROWS  THEN
        RETURN 2198;
  WHEN OTHERS THEN  -- si on a rien trouvé on continu
        RETURN 0;
  END IS_BENE_DOUBLON;

/******************************************************************************/
/*VERIFIE que le bénéficiaire n'est pas déjà existant  sur le groupe familliale */
 FUNCTION IS_BENE_DOUBLON_GROUPE ( i_numAdherent      IN NUMBER,
                                   i_nom              IN VARCHAR2,
                                   i_prenom           IN VARCHAR2,
                                   i_datenaiss        IN DATE,
                                   i_numss            IN VARCHAR2 DEFAULT NULL)
  RETURN NUMBER
  IS
  l_beneficiaire_existant INDIVIDU.NUmINDIV%TYPE;
  BEGIN
      SELECT numindiv INTO l_beneficiaire_existant
        FROM INDIVIDU
        WHERE  (UPPER(NOM)   = UPPER(i_nom) OR  matorg||cless = nvl(i_numss,matorg||cless) )
          AND UPPER(PRENOM) = UPPER(i_prenom)
          AND TRUNC(DATNAIS)  = TRUNC(i_datenaiss)
          AND NUMASSU = i_numAdherent;
  RETURN 2201;
  EXCEPTION
    WHEN TOO_MANY_ROWS  THEN
        RETURN 2198;
  WHEN OTHERS THEN  -- si on a rien trouvé on continu
        RETURN 0;
  END IS_BENE_DOUBLON_GROUPE;

  /* Controle du numero de secu */
FUNCTION IS_NUMSS_OK ( i_numss1 IN individu.matorg%TYPE, i_cless1 IN individu.cless%TYPE, i_numss2  IN individu.matorg2%TYPE, i_cless2 IN  individu.cless2%TYPE)
RETURN NUMBER
IS
  Dummy   number;
  Num_SS  varchar2(40);
  Num_SS2 varchar2(40);
BEGIN
  IF LENGTH (i_numss1) > 15 THEN
      RETURN 2200;
  END IF;

  IF i_numss1 IS NOT NULL THEN
    Num_SS := Replace(i_numss1, '2A', '19');
    Num_SS := Replace(Num_SS, '2B', '18');
    Dummy := mod( (to_number(Num_SS) + to_number(i_cless1)), 97);
    IF Dummy <>0 THEN
      return 2199;
    END IF;
  END IF;
  IF i_numss2 IS NOT NULL THEN
    IF LENGTH (i_numss2) > 15 THEN
      RETURN 2200;
    END IF;
    Num_SS2 := Replace(i_numss2, '2A', '19');
    Num_SS2 := Replace(Num_SS2, '2B', '18');
    Dummy:= mod( (to_number(Num_SS2) + to_number(i_cless2)), 97) ;
    IF Dummy <>0 THEN
      return 2199;
    END IF;
  END IF;

  RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 2199;
End;


FUNCTION IS_REGIME_CAISSE_OK ( i_regime1 IN individu.regime%TYPE, i_caisse1 IN individu.caisse%TYPE, i_regime2 IN individu.regime2%TYPE, i_caisse2 IN individu.caisse2%TYPE)
RETURN NUMBER
IS
dummy number;
BEGIN

/****** verification des regimes 1 et 2 ***************/
  BEGIN
    Select distinct 1
    Into   dummy
    From   libelle
    Where  mnemo = 'REGIME'
    and    to_char(code,'00' ) = to_char(i_regime1,'00' );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 2203;
  END;

  IF i_regime2 IS NOT NULL THEN
    BEGIN
      Select distinct 1
      Into   dummy
      From   libelle
      Where  mnemo = 'REGIME'
      and    to_char(code,'00') = nvl(to_char(i_regime2,'00' ),code) ;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return 2204;
    END;
 END IF;

 BEGIN
    SELECT DISTINCT 1
      into dummy
      from trpnt
     where to_char(caisse,'000' )= to_char(i_caisse1,'000' )
      and to_char(regime,'00' )= to_char(i_regime1,'00')
      and type_tiers=1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return 2205;
  END;

  IF i_caisse2 IS NOT NULL THEN
    BEGIN
      SELECT DISTINCT 1
        into dummy
        from trpnt
        where to_char(caisse,'000' )= to_char(i_caisse2,'000' )
        and to_char(regime,'00' )= to_char(i_regime2,'00')
        and type_tiers=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return 2206;
    END;
  END IF;


 RETURN 0;
 EXCEPTION WHEN OTHERS THEN
    RETURN 2184; -- un probléme est survenu.


END IS_REGIME_CAISSE_OK;



/*****************************************UTIL_MAJ_INFO_PERSO*****************************************************/
 PROCEDURE VERIF_MAJ_INFO_PERSO(i_numAdherent   IN NUMBER,
                              i_numIndiv      IN NUMBER,
                              i_idDemande_ext IN NUMBER,
                              i_nom           IN INDIVIDU.nom%TYPE,
                              i_nomNais       IN INDIVIDU.nomjf%TYPE,
                              i_prenom        IN INDIVIDU.prenom%TYPE,
                              i_dateEffet     IN DATE,
                              i_dateNaissance IN DATE,
                              i_rangNaissance IN NUMBER,
                              i_regimeSS      IN VARCHAR2,
                              i_caisse        IN VARCHAR2,
                              i_centre        IN VARCHAR2,
                              i_documents     IN EXT_TAB_DOCUMENT,
                              o_etat          OUT NUMBER,
                              o_code_erreur   OUT NUMBER
                              )
IS BEGIN
    IF i_regimess IS NOT NULL THEN
    o_code_erreur :=   IS_REGIME_CAISSE_OK (i_regimess, i_caisse, null, null) ;
  END IF;

  IF LENGTH(i_nom)  > 30 OR LENGTH(i_prenom)  > 30 THEN  --- champs trop grands
    o_etat:=4;
    o_code_erreur:= 0;
  ELSIF (i_regimess IS NOT NULL OR i_caisse IS NOT NULL) AND o_code_erreur>0  THEN  -- verification de l'existance du couple régime Caisse.
    o_etat :=4;
   o_code_erreur:= o_code_erreur;
  ELSIF (i_regimeSS IS NOT NULL OR i_caisse IS NOT NULL /*OR RANG de naissance*/  AND NOT (i_documents is not null AND i_documents.count > 1  ))  THEN   ---  La présence d’un document justificatif est obligatoire en cas de modification du regime / caisse et rang de naissance
    o_etat:=4;
    o_code_erreur:= 2207;
  ELSIF i_nom IS NOT NULL OR i_regimeSS IS NOT NULL OR i_caisse  IS NOT NULL OR i_rangNaissance IS NOT NULL THEN
    -- toute modification en dehors de la date de naissance ou du prénom nécessite un traitement manuel
   o_etat :=1;
  END IF ;


END VERIF_MAJ_INFO_PERSO;

FUNCTION F_COMPARE_SOUSCRIPTIONS ( tab_benes_sous EXTR_TAB_BENE_PROSPECT, tab_benes_consult EXTR_TAB_BENE_PROSPECT, offre NUMBER)
RETURN NUMBER
IS
  benes_temp EXTR_BENE_PROSPECT;
  contrat_temp EXTR_CONTRACT_TO_SIGN_UP;
  tableau_epure EXTR_TAB_BENE_PROSPECT;
  grnt_temp EXTR_GRNT_TO_SIGN_UP ;
  temp_transfert EXTR_TAB_BENE_PROSPECT; -- pour switcher le controle
  I NUMBER;  J NUMBER; K NUMBER;
  t_grnt_cons EXTR_TAB_GRNT_TO_SIGN_UP;
  t_contrat_cons EXTR_TAB_CONTRACT_TO_SIGN_UP ;
  l_numfor_cons number;
--nb_max number;
  nb_adherent_cons NUMBER :=0;
  nb_adherent_sous NUMBER :=0;
  num_for  number;
  num_gar  number;
  l_offre number:= offre;
BEGIN


   --  chaque bénéficiaire doit avoir avoir au noumfor dont il prétent


 /* les options passées doivent être iso flux*/
-- temp_transfert:= benes_sous;
 --benes_sous := benes_base;


  FOR rec_flux IN  (SELECT numindiv,TAB_CONTRACTS FROM table(tab_benes_sous))LOOP
    FOR rec_cntrt IN  (SELECT numgar , TAB_GRNT FROM table(rec_flux.TAB_CONTRACTS))LOOP
       FOR rec_grnt IN  (SELECT numfor FROM table(rec_cntrt.TAB_GRNT))LOOP
            BEGIN
              SELECT TAB_CONTRACTS into t_contrat_cons
              FROM   table (tab_benes_consult)
              Where numindiv =rec_flux.numindiv; -- recupération du tableau de contrat de l'individu
              BEGIN
                SELECT TAB_GRNT INTO T_GRNT_CONS
                FROM TABLE (t_contrat_cons)
                WHERE numgar = rec_cntrt.numgar; -- récupération du tableau de garantie du numgar demandé
                BEGIN
                  SELECT numfor into l_numfor_cons from table(T_GRNT_CONS)
                  WHERE numfor = rec_grnt.numfor; -- verfication que le numfor pour l'individu est bien dans le flux de consultation
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    RETURN 2265;-- la garantie n'est pas souscriptible selon le flux de consultation
                END;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  RETURN 2266;-- le contrat n'est pas souscriptible selon le flux de consultation
              END;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  RETURN 2267;-- le bénéficiaire n'est pas présent dans le flux  de consultation
            END;

       END lOOP;
      END LOOP;
    END LOOP;

  IF OFFRE > 0 THEN

  FOR rec_flux IN  (SELECT numindiv,TAB_CONTRACTS FROM table(tab_benes_consult))LOOP
    FOR rec_cntrt IN  (SELECT numgar , TAB_GRNT FROM table(rec_flux.TAB_CONTRACTS))LOOP
       FOR rec_grnt IN  (SELECT numfor,offre FROM table(rec_cntrt.TAB_GRNT) g where g.offre = l_OFFRE)LOOP
          nb_adherent_cons := nb_adherent_cons+1;
       END LOOP;
    END LOOP;
  END LOOP;
      /*SELECT COUNT(DISTINCT NUMINDIV)
      INTO nb_adherent_cons
      FROM TABLE (tab_benes_consult);*/
      SELECT COUNT(DISTINCT NUMINDIV)
      INTO nb_adherent_sous
      FROM TABLE (tab_benes_sous);
      IF nb_adherent_sous < nb_adherent_cons THEN
        RETURN 2271;
      END IF;
  END IF;



return 0;


EXCEPTION WHEN OTHERS THEN RETURN 2272;


END F_COMPARE_SOUSCRIPTIONS;


/*****************************************************************************************/

FUNCTION F_GET_SOUSCRIPTION_EPURE (tab_bene EXTR_TAB_BENE_PROSPECT, NUM_GAR NUMBER, OFFRE NUMBER) return EXTR_TAB_BENE_PROSPECT

IS

  /*         control cohérence            */
  loc_bene_prospects EXTR_TAB_BENE_PROSPECT;
  loc_contrats EXTR_TAB_CONTRACT_TO_SIGN_UP ;
  loc_grnts EXTR_TAB_GRNT_TO_SIGN_UP;

  loc_flux_consultation EXTR_PROSPECT ;
  loc_flux_consult    EXTR_TAB_BENE_PROSPECT ;
  contrat_temp EXTR_CONTRACT_TO_SIGN_UP;
  tableau_epure EXTR_TAB_BENE_PROSPECT;
  grnt_temp EXTR_GRNT_TO_SIGN_UP ;


BEGIN
tableau_epure := new EXTR_TAB_BENE_PROSPECT(null);
-- on recupére tout les individus qui sont conernés par l'offre
  FOR I IN  1..tab_bene.count LOOP
      -- on récupére le contrat corresspondant
      contrat_temp :=   PK_WS_WEB_BACK.F_GET_EXTR_CONTRACT( num_gar,  tab_bene(i).tab_contracts) ;
      IF contrat_temp is not null then
        grnt_temp := PK_WS_WEB_BACK.F_GET_EXTR_GRNT(offre, contrat_temp.tab_GRNT );
        IF grnt_temp IS NOT NULL THEN
        IF tableau_epure(1) is not null then tableau_epure.extend(1); END IF;
          loc_grnts := new EXTR_TAB_GRNT_TO_SIGN_UP(null);
          loc_grnts(1) := new EXTR_GRNT_TO_SIGN_UP(grnt_temp.numfor,null,null,null,null,null,null,null,null,null,null,null,null,null,null,offre );
          loc_contrats := new EXTR_TAB_CONTRACT_TO_SIGN_UP(null);
          loc_contrats(1) := new  EXTR_CONTRACT_TO_SIGN_UP(num_gar,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,loc_grnts,null,null,null);
          tableau_epure(tableau_epure.count):= new  EXTR_BENE_PROSPECT( tab_bene(i).numindiv,
                                                                        null,
                                                                        null,
                                                                        null,
                                                                        null,
                                                                        null,
                                                                        tab_bene(i).TYPBENE,
                                                                        loc_contrats  );
         END IF;
      END IF;
  END LOOP;

return tableau_epure;
END F_GET_SOUSCRIPTION_EPURE;


 /****************************************************INTEGRATION FONCTIONNELLE **************************************************/
FUNCTION F_VALIDE_DEPOT_PIECE(i_idrappel number ,i_numporte number) RETURN NUMBER IS
 loc_rappel  rappel%rowtype;
 l_is_presta_calc NUMBER :=0;
 loc_rappel_bien_etre rappel%rowtype;
 loc_liq_dossier  number :=0;
BEGIN

  SELECT * into loc_rappel from rappel WHERE idrappel = i_idrappel;
 /*  si il s'agit d'un rappel de contexte dossier santé alors on applique les verifications */
     IF loc_rappel.contexte = 27 THEN
       BEGIN
         SELECT DISTINCT  1
         INTO l_is_presta_calc
         FROM  SINISTRE_SANTE
         WHERE NUM_DOSSIER =  loc_rappel.entite
         AND SITUATION = 2; --calculée
        -- si le rappel d'origine est un rebmoursement bien être alors on liquide le dossier
        BEGIN
          SELECT * into loc_rappel_bien_etre
          FROM rappel
          WHERE type = 21
          AND ENTITE  = loc_rappel.entite
          and numassu = loc_rappel.numassu
          and idrappel <> loc_rappel.idrappel -- évite de liquider deux fois le même dossier car la procédure valide deopt pièece est appeler par valide_add_doss_calc a la fin
          ;
          P_LIQ_DOSSIER(  i_num_dossier =>    loc_rappel_bien_etre.entite,
                          o_new_dossier =>loc_liq_dossier )  ;

          IF loc_liq_dossier = 0 then return 2218;END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
                WHEN OTHERS THEN NULL;
        END;
        EXCEPTION
          WHEN OTHERS THEN RETURN 2223;
       END;

     END IF;

  /*Fonction permettant de valider les documents recu par la ged*/
  UPDATE  pieces SET daterecep = sysdate
  WHERE idpiece IN   (
    SELECT clef  FROM lien_ged
    WHERE ref_ext =i_idrappel
    AND src = i_numporte
    AND lien_ged.ETENDUE<>30 -- on ne touche pas au contexte 30 des demandes
    )
    AND daterecep IS NULL;

  COMMIT;
  RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN RETURN 2218;

END F_VALIDE_DEPOT_PIECE;

/******************************************************************************************************************/
FUNCTION F_VALIDE_DEVIS(i_idrappel number ,i_numporte number) RETURN NUMBER
IS
  loc_rappel  rappel%rowtype;
  l_is_edited number := 0;
  l_is_presta_calc number := 0;
BEGIN
  select * into loc_rappel from rappel
  where idrappel = i_idrappel;

  /*  VERIFIER LA PR2ZSENCE D'UNE EDITION DU DEVIS
  BEGIN
     SELECT DISTINCT 1 INTO  l_is_edited
     FROM FILE_EDITION f, PARAM_DMNDE p
     WHERE f.numdmnde = p.numdmnde
     AND EDITID = 'GS30B04'
     AND valdeb1 = loc_rappel.entite;
   EXCEPTION
      WHEN OTHERS THEN
      RETURN 2222; -- aucune édition trouvée pour ce dossier.
   END; */

 -- VERIFIER LA PRESENCE D'UNE PRESTATION CALCULEE.
  BEGIN
   SELECT DISTINCT  1
   INTO l_is_presta_calc
   FROM  SINISTRE_SANTE
   WHERE NUM_DOSSIER =  loc_rappel.entite
   AND SITUATION = 2; --calculée

  EXCEPTION
   WHEN OTHERS THEN  RETURN 2223;
  END;

  RETURN F_VALIDE_DEPOT_PIECE(i_idrappel,i_numporte);

END F_VALIDE_DEVIS;

/******************************************************************************************************************/
FUNCTION F_VALIDE_REMB(i_idrappel number ,i_numporte number) RETURN NUMBER
IS
  loc_rappel  rappel%rowtype;
  l_is_edited number := 0;
  l_is_presta_calc number := 0;
BEGIN
  select * into loc_rappel from rappel
  where idrappel = i_idrappel;

    /*  VERIFIER LA PR2ZSENCE D'UNE EDITION DU DEVIS
    BEGIN
       SELECT DISTINCT 1 INTO  l_is_edited
       FROM FILE_EDITION f, PARAM_DMNDE p
       WHERE f.numdmnde = p.numdmnde
       AND EDITID = 'GS30B04'
       AND valdeb1 = loc_rappel.entite;
     EXCEPTION
        WHEN OTHERS THEN
        RETURN 2222; -- aucune édition trouvée pour ce dossier.
     END; */

   -- VERIFIER LA PRESENCE D4UNE PRESTATION CALCULEE.
  BEGIN
   SELECT DISTINCT  1
   INTO l_is_presta_calc
   FROM  SINISTRE_SANTE
   WHERE NUM_DOSSIER =  loc_rappel.entite
   AND SITUATION = 2; --calculée

  EXCEPTION
    WHEN OTHERS THEN  RETURN 2223;
  END;

  RETURN F_VALIDE_DEPOT_PIECE(i_idrappel,i_numporte);


END F_VALIDE_REMB;



/******************************************************************************************************************/
FUNCTION F_VALIDE_ADD_DOSS_CALC(i_idrappel number ,i_numporte number) RETURN NUMBER
IS
  loc_rappel  rappel%rowtype;
  l_is_edited number := 0;
  l_is_presta_calc number := 0;
  loc_dossier_sante dossier_sante%rowtype;
  loc_new_num_dossier dossier_sante.num_dossier%type;
  loc_dossier_deja_liquide number :=0;
BEGIN
  --Récuperation du rappel
  select * into loc_rappel from rappel
  where idrappel = i_idrappel;
  -- Récupération du dossier
   select * into loc_dossier_sante
    from dossier_sante
    where TYPE_DOSS = 4
    and NAT_DOSS = 8 -- bien-etre
    and NUM_DOSSIER = loc_rappel.entite
    and REF_DOSSIER = loc_rappel.REFERENCE;

   -- VERIFIER LA PRESENCE D'UNE PRESTATION CALCULEE.
  BEGIN
   SELECT DISTINCT  1
   INTO l_is_presta_calc
   FROM  SINISTRE_SANTE
   WHERE NUM_DOSSIER =  loc_rappel.entite
   AND SITUATION = 2; --calculée
  EXCEPTION
    WHEN OTHERS THEN  RETURN 2223;
  END;

  -- Verifier que le dossier n'a pas déjà été liquidé manuellement
   SELECT count(*) INTO loc_dossier_deja_liquide
   FROM DOSSIER_SANTE
   WHERE  REF_DOSSIER =  loc_dossier_sante.REF_DOSSIER
   AND TYPE_DOSS = 1
   AND NUMINDIV = loc_dossier_sante.NUMINDIV;

   IF loc_dossier_deja_liquide = 0 THEN  -- si le dossier n'a pas encore été liquidé on le liquide
    -- Liquider le dossier santé si tout va bien.
    P_LIQ_DOSSIER(  i_num_dossier =>    loc_dossier_sante.num_dossier,
                    o_new_dossier =>loc_new_num_dossier )  ;

    IF loc_new_num_dossier = 0  THEN
        return 2225 ;  -- la creéation du dossier a échouer veuillez le saisir manuellement
    ELSIF  loc_new_num_dossier = -1 THEN
        return 2225 ;
    END IF;
  END IF;
  -- sinon on valider les pièces du dossier
  RETURN F_VALIDE_DEPOT_PIECE(i_idrappel,i_numporte);


END F_VALIDE_ADD_DOSS_CALC;

/******************************************************************************************************************/
FUNCTION F_VALIDE_RADIATION(i_idrappel number ,i_numporte number) RETURN NUMBER
IS
  loc_rappel  rappel%rowtype;
  l_a_au_moins_1_couverture NUMBER :=0;
  l_couverture_posterieure NUMBER := 0;
  l_adhe_croisees NUMBER:=0;
  V_IDHISTORAPPEL number(9);
  varchar_adhesion_croisee VARCHAR2(500) :='';
  l_liste_adhesion_fermee VARCHAR2(500) := 'Validation de la demande, Liste des adhésions fermées:';

 CURSOR c_adhesions (l_numassu NUMBER, l_numbene NUMBER, l_effet DATE) IS
   SELECT acm.idadhecntrtmb, acm.numindiv, acm.idadhesion
    FROM ADHE_CNTRT_MEMBRE acm
    WHERE
    acm.idadhesion in ( -- adhesion de l'assuré  principale uniquement
                       select idadhesion
                       from adhe_cntrt adh
                       where adh.numadhe = l_numassu
                         AND (l_effet BETWEEN date_adhe AND nvl (date_fin_adhe, l_effet))
                      )
    AND acm.idadhesion in (
                          select IDADHESION
                          from adhesion
                          where numindiv =acm.numindiv
                          and adhesion.DATPER is null
            )
    AND NUMINDIV  =l_numbene
    AND NUMINDIV <> l_numassu; --on peut pas radier l'adhérent
 r_adhesions c_adhesions%rowtype;
BEGIN
  SELECT * INTO loc_rappel FROM rappel
  WHERE idrappel = i_idrappel;
   /*F_VALIDE_DEPOT_PIECE(i_idrappel,i_numporte);*/
  /*Règles de gestion CLOSE_BENE:
    ?  Le bénéficiaire doit avoir au moins une couverture ouverte sur l’adhésion de l’adhérent
    ?  La date de radiation doit être supérieure à la date du jour
    ?  Radiation impossible
 */

  --Le bénéficiaire doit avoir au moins une couverture ouverte sur l’adhésion de l’adhérent
  BEGIN
  SELECT DISTINCT 1  INTO l_a_au_moins_1_couverture/*acm.idadhecntrtmb, acm.numindiv, acm.idadhesion */
    FROM ADHE_CNTRT_MEMBRE acm
    WHERE
      acm.idadhesion IN ( -- adhesion de l'assuré  principale uniquement
                         SELECT idadhesion
                         FROM adhe_cntrt adh
                         WHERE adh.numadhe = loc_rappel.numassu
                           AND (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate) OR date_adhe > nvl(loc_rappel.dateeffet,sysdate) )
                        )
      AND acm.idadhesion IN (
                            SELECT IDADHESION
                            FROM adhesion
                            WHERE numindiv =acm.numindiv
                            AND nvl(adhesion.DATPER,loc_rappel.dateeffet)>=loc_rappel.dateeffet
              )
      AND NUMINDIV  = loc_rappel.numbene;

  EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN 2227;
  END;

   --Radiation impossible si au moins une garantie commence postérieurement à la date de radiation
   BEGIN
    SELECT DISTINCT 2226 INTO l_couverture_posterieure /*acm.idadhecntrtmb, acm.numindiv, acm.idadhesion */
    FROM ADHE_CNTRT_MEMBRE acm
    WHERE acm.idadhesion in ( -- adhesion de l'assuré  principale uniquement
                             SELECT idadhesion
                             FROM adhe_cntrt adh
                             WHERE adh.numadhe = loc_rappel.numassu
                               AND (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate) OR date_adhe > nvl(loc_rappel.dateeffet,sysdate) )
                        )
      AND acm.idadhesion IN (
                              SELECT IDADHESION   FROM adhesion  WHERE numindiv =acm.numindiv  and nvl(adhesion.DATAPLI,loc_rappel.dateeffet)>=loc_rappel.dateeffet
              )
      AND NUMINDIV  = loc_rappel.numbene;
    RETURN   l_couverture_posterieure;
  EXCEPTION
   WHEN OTHERS THEN
   NULL;
  END;

  IF loc_rappel.dateeffet < add_months(sysdate ,-1) THEN
    RETURN 2228;  -- la date d'effet souhaitée est trop ancienne
  END IF;


 -- RADIATION DU Bénéficiaire
  FOR r_adhesions IN  c_adhesions(loc_rappel.numassu,loc_rappel.numbene,NVL(loc_rappel.dateeffet,sysdate)) LOOP
    UPDATE ADHESION
     SET DATPER = loc_rappel.dateeffet
     WHERE IDADHESION = r_adhesions.idadhesion
     AND numindiv = r_adhesions.numindiv
     AND DATPER IS NULL;

    l_liste_adhesion_fermee := l_liste_adhesion_fermee ||chr(10)||chr(13)||r_adhesions.idadhesion ||','    ;

    -- Annulation des pièces concernant l'adhesion et le bénéficiaire
    UPDATE PIECES
     SET DATANNUL = sysdate
     WHERE ENTITE = r_adhesions.idadhesion
      AND numbene = r_adhesions.numindiv
      AND DATERECEP IS NULL  ;

  END LOOP;

  -- verification des adhésions croissées
  BEGIN
    SELECT DISTINCT 1 INTO l_adhe_croisees FROM adhe_cntrt_membre a1, adhe_cntrt a2
      WHERE a1.numindiv = loc_rappel.numbene
      AND a2.NUMADHE <> loc_rappel.numassu
      AND a1.IDADHESION = a2.idadhesion;
    varchar_adhesion_croisee :='ATTENTION !!! PRÉSENCE D''ADHÉSIONS CROISÉES SUR CE BÉNÉFICIAIRE';
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  -- Historisation de la liste des adhésion
  --SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
  SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
  INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
							IDHISTORAPPEL,
							CONTEXTE,
							ENTITE,
							TYPE,
							REFERENCE,
							REVISION,
							CREATION,
							CREATEUR,
							MAJ,
							MODIFICATEUR,
							ETAT,
							RESPONSABLE,
							COMMENTAIRE)
		VALUES (loc_rappel.IDRAPPEL,
                                  V_IDHISTORAPPEL,
                                  loc_rappel.CONTEXTE,
                                  loc_rappel.ENTITE,
                                  loc_rappel.TYPE,
                                  loc_rappel.REFERENCE,
                                  loc_rappel.REVISION,
                                  loc_rappel.CREATION,
                                  loc_rappel.CREATEUR,
                                  sysdate,
                                  F_numutil,
                                  6,
                                  loc_rappel.RESPONSABLE,
                                  l_liste_adhesion_fermee ||chr(10)||chr(13)||varchar_adhesion_croisee);
   SET_RAPPEL_ERREUR(  loc_rappel.IDRAPPEL,  loc_rappel.code_err, 6);
  COMMIT;




  return 0;
END F_VALIDE_RADIATION;

/******************************************************************************************************************/
FUNCTION F_VALIDE_ADD_NUMSS(i_idrappel number ,i_numporte number) RETURN NUMBER
IS
  loc_rappel  rappel%rowtype;
  l_is_edited number := 0;
  l_is_presta_calc number := 0;
  l_type_demande_ss number :=0;
  l_ss_ajoute  varchar2(50);
  l_cle_ajoute  varchar2(3);
  l_caisse_ajoute individu.caisse%type;
  l_regime_ajoute individu.regime%type;
  l_centre_ajoute individu.GUICHETORG%type;

  l_caisse individu.caisse%type;      -- dans le cas ou une caisse est passée en paramétre de l'appel ws
  l_regime individu.regime%type;      -- dans le cas ou un  régime est passée en paramétre de l'appel ws
  l_centre individu.GUICHETORG%type;  -- dans le cas ou un  centre est passée en paramétre de l'appel ws
  num_indiv_rattachement  individu.numindiv%type;
  l_num_to_modif NUMBER(1);
  V_IDHISTORAPPEL  rappel.idrappel%type;
  l_liste_adhesion_fermee VARCHAR2(500);
  l_date_effet DATE;
  l_err_numss NUMBER(5);
  l_individu individu%rowtype;
  IS_AYANT_DROIT NUMBER(1);
  appel_carte_tp number(1) :=0;
  dummy number;
  l_numassu individu.numindiv%type;

  CURSOR C_indv (p_numindiv IN NUMBER) is
  SELECT i.numindiv
  FROM individu i, individu a
  WHERE i.matorg = a.matorg
  AND a.numindiv = p_numindiv;

  CURSOR C_adhe (p_numindiv IN Number)  IS
  SELECT adhesion.idadhesion,
              adhesion.numgar,
              porte_contrat.numporte,
              adhesion.numfor,
              adhesion.datper                                               -- Ajout le 20100212 M00003055
       FROM   adhesion,
              porte_contrat, porte_param
       WHERE  f_numgar_ref(adhesion.numgar) = porte_contrat.numgar
       AND    adhesion.numindiv = p_numindiv
       AND    porte_contrat.numporte != 1
       AND    nvl (adhesion.datper, sysdate) >= sysdate
       AND    SYSDATE between adhesion.datapli AND nvl (adhesion.datper,SYSDATE)
       AND    adhesion.etat =1
       AND    porte_contrat.numporte = porte_param.numporte
       AND    nat_porte in (3,5) --ABO ajout du filtre pour ne pas déclancher sur les autres portes
       order by nvl(adhesion.datper, sysdate);

  CURSOR c_adhesions ( l_numbene NUMBER) IS
   SELECT acm.idadhecntrtmb, acm.numindiv, acm.idadhesion
    FROM ADHE_CNTRT_MEMBRE acm, individu i
    WHERE
    acm.idadhesion in ( -- adhesion de l'assuré  principale uniquement
                       select idadhesion
                       from adhe_cntrt adh
                       where adh.numadhe in( select numindiv from individu i2 where i2.matorg like(i.matorg||'%') OR i2.matorg like(i.matorg2||'%') )
                         AND (sysdate BETWEEN date_adhe AND nvl (date_fin_adhe, sysdate))
                      )
    AND acm.idadhesion in (
                          select IDADHESION
                          from adhesion
                          where numindiv =acm.numindiv
                          and adhesion.DATPER is null
            )
    AND acm.NUMINDIV  =l_numbene
    AND acm.numindiv = i.numindiv;

  CURSOR c_garanties ( i_idadhesion number, i_numindiv number) is
    select * from adhesion
    where numindiv = i_numindiv
    and idadhesion = i_idadhesion
    and datper is  null;

   CURSOR c_individu_rattachement (p_numbene number  , p_numassu number ) is  --RKO M0005757
      SELECT numindiv --, CAISSE, REGIME, GUICHETORG --RKO M0005757 on prend l'ouvreur de droit qui a le même numss que l'individu que l'on dénoémise
      -- into   num_indiv_rattachement --, l_caisse_ajoute, l_regime_ajoute, l_centre_ajoute
      FROM INDIVIDU
      WHERE MATORG in (
                select matorg from individu where numindiv = p_numbene
                union all
                select matorg2 from individu where numindiv = p_numbene)
      AND natur = 1   -- ouvreur de droit
      and f_numassu(numindiv) = p_numassu;
BEGIN

/** RECUPERATION DES INFORMATIONS UTILES*/
  select * into loc_rappel
  FROM rappel
  WHERE idrappel = i_idrappel;

  dummy := F_valide_depot_piece(loc_rappel.idrappel,i_numporte);    -- EVO3 Validation des lien ged CLI le 12/04/2018

  SELECT * INTO l_individu
  FROM INDIVIDU
  WHERE NUMINDIV = LOC_RAPPEL.numbene;

  l_type_demande_ss := SUBSTR(F_GET_VALUE_IN_TABLE('Type de demande', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)),1,1) ;
  l_date_effet := nvl(e2d(F_GET_VALUE_IN_TABLE('Date d''effet', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire))), loc_rappel.dateeffet);
  l_num_to_modif:= F_GET_VALUE_IN_TABLE('Numéro SS concerné', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_ss_ajoute   := F_GET_VALUE_IN_TABLE('NumSS', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_caisse      := F_GET_VALUE_IN_TABLE('Caisse', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_centre      := F_GET_VALUE_IN_TABLE('Centre', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_regime      := F_GET_VALUE_IN_TABLE('Regime', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_cle_ajoute  := substr(l_ss_ajoute,14,2);
  l_ss_ajoute   := substr(l_ss_ajoute,1,13);


  IF l_num_to_modif NOT IN (1,2) and l_type_demande_ss in (1,2)THEN  -- blocage de l'intégration automatique tant que IPSO n'a pas valoriser num_to_modif
      return 2241;
   END IF;
    -- permet de savoir si un appel carte tp doit être réalisé
  SELECT COUNT(*)
  INTO appel_carte_tp
  FROM individu
  WHERE numindiv = loc_rappel.numbene
  AND ((decode (l_num_to_modif , 1, nvl(matorg,'0'), nvl(matorg2,'0')) <> l_ss_ajoute
         and l_ss_ajoute is not null)
        OR l_type_demande_ss in (3,4)); -- pas d'appel si on ne change pas  le numss ;


-- valorisation de la caisse, regime, centre en prenant le departement comme code caisse + 1  Si le type de demande =4
  If l_type_demande_ss = 4 and i_numporte = 27 THEN
     BEGIN
        SELECT NVL(l_caisse,substr(codpos,0,2)||'1')
        INTO l_caisse
        FROM pers_adresse
        WHERE idadresse = pk_personne.f_idadresse(loc_rappel.numassu);
      EXCEPTION WHEN OTHERS THEN null;
      END;
      l_regime := nvl(l_regime,'01');
     -- l_centre := nvl(l_centre,'000');
  -- Fin de valorisation de la caisse, regime, centre en prenant le departement comme code caisse + 1

  else
    IF   l_regime = '01' AND  l_caisse = '909' THEN  --  si le régime ='01' et la caisse ='909' alors on force le centre à '000'
      l_centre := '000';
     ELSIF l_regime ='01' AND  l_caisse <> '909'THEN --  si le régime ='01' et caisse est différente de '909' alors centre est valorisé à vide
      l_centre := null;
     END IF;
  END IF;


  IF l_regime IS NOT NULL AND l_regime != 50 THEN   ---RKO M0005757
    l_err_numss :=   IS_REGIME_CAISSE_OK (l_regime, l_caisse, null, null) ;
    IF l_err_numss > 0 THEN
    RETURN l_err_numss;
    END IF;
  END IF;



/** FIN DES RECUPERATIONS DES INFORMATIONS UTILES*/

  IF   l_type_demande_ss = 1 THEN --- AJOUT DU NUMSS
    IF  l_num_to_modif = 1 THEN       -- TODO ce cas n'est pas geré
      NULL;
    ELSIF  l_num_to_modif = 2 THEN      -- ajout d'un dexième numSS
        BEGIN -- on récupére l'individu qui a le même numéro de sécurité sociale
          SELECT numindiv, CAISSE, REGIME, GUICHETORG into   num_indiv_rattachement, l_caisse_ajoute, l_regime_ajoute, l_centre_ajoute
          FROM INDIVIDU
          WHERE MATORG = l_ss_ajoute
          AND natur = 1   -- ouvreur de droit
          AND f_numassu(numindiv) = loc_rappel.numassu; -- on prends uniquement les individus ouvreurs de droit

          IF num_indiv_rattachement = loc_rappel.numbene THEN
            RETURN 2234; -- l'individu posséde déjà ce nuémro de sécurité sociale
          END IF;
        EXCEPTION
          WHEN TOO_MANY_ROWS THEN
            return 2229;
          WHEN OTHERS THEN
            return 2230;
        END;
         UPDATE INDIVIDU
        SET MATORG2 = l_ss_ajoute,
            cless2  = l_cle_ajoute,
            regime2 = l_regime_ajoute ,
            caisse2 =  nvl(l_caisse_ajoute,caisse2),
            GUICHETORG2 = l_centre_ajoute
        WHERE NUMINDIV = loc_rappel.numbene;

     -- demande de carte tp pour les individu dependant du porteur de
     IF appel_carte_tp  = 1 THEN
      FOR R_adhe  IN   C_adhe(num_indiv_rattachement)LOOP
            pk_porte.P_INS_demande_tp (
                    I_numporte => R_adhe.numporte,
                    I_idadhesion => R_adhe.idadhesion,
                    I_numgar     => R_adhe.numgar,
                    I_numindiv   => num_indiv_rattachement,
                    I_debut      => SYSDATE,--a valider par GEREP
                    I_fin        => R_adhe.datper,
                    I_type       => 16,
                    I_numfor     => R_adhe.numfor
                  );
                EXIT; --on insert juste pour une adhesion
        END LOOP;
    END IF;

        UPDATE NOEMIE
        --M0005567 SET   numassu = f_numassu(l_individu.numindiv)
        SET   numassu =num_indiv_rattachement
        WHERE matorg =  l_ss_ajoute
        AND TRUNC(CREATION )= TRUNC(SYSDATE)
        and numremise = 0 -- M0005567
        ;

         -- historisation de l'action effectué
        --SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
       SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
       INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
								IDHISTORAPPEL,
								CONTEXTE,
								ENTITE,
								TYPE,
								REFERENCE,
								REVISION,
								CREATION,
								CREATEUR,
								MAJ,
								MODIFICATEUR,
								ETAT,
								RESPONSABLE,
								COMMENTAIRE)
				VALUES ( loc_rappel.IDRAPPEL,
                                        V_IDHISTORAPPEL,
                                        loc_rappel.CONTEXTE,
                                        loc_rappel.ENTITE,
                                        loc_rappel.TYPE,
                                        loc_rappel.REFERENCE,
                                        loc_rappel.REVISION,
                                        loc_rappel.CREATION,
                                        loc_rappel.CREATEUR,
                                        sysdate,
                                        F_numutil,
                                          6,
                                        loc_rappel.RESPONSABLE,
                                        'Modification du numéro ss sur la base de l''individu n°'||num_indiv_rattachement||', '||pk_personne.f_nom(num_indiv_rattachement)
                                        ||chr(10)||chr(13)||'NUMSS = '||l_individu.matorg
                                        ||chr(10)||chr(13)||'REGIME = '||l_individu.REGIME
                                        ||chr(10)||chr(13)||'CAISSE = '||l_individu.caisse
                                        ||chr(10)||chr(13)||'CENTRE = '||l_individu.guichetorg
                                        ||chr(10)||chr(13)||'NUMSS2 = '||l_individu.matorg2
                                        ||chr(10)||chr(13)||'REGIME2 = '||l_individu.REGIME2
                                        ||chr(10)||chr(13)||'CAISSE2 = '||l_individu.caisse2
                                        ||chr(10)||chr(13)||'CENTRE2 = '||l_individu.guichetorg2);
        SET_RAPPEL_ERREUR(  loc_rappel.IDRAPPEL,  loc_rappel.code_err, 3);
        COMMIT;
        RETURN 0;

    END IF;



  ELSIF l_type_demande_ss = 2 THEN     --  modification Du numéro SS
    IF  l_num_to_modif = 1 THEN       --  1er NUMÉRO CONCERNÉ
    -- est ce un ayant doit?      nature !=1
      IF l_individu.natur = 2 THEN  -- oui => il devient ouvreur de droit + supprimer son deuxieme numss

         UPDATE individu
         SET   NATUR = 1
              , MATORG = l_ss_ajoute
              , cless  = l_cle_ajoute
              , regime = l_regime
              , caisse =  l_caisse
              , GUICHETORG= l_centre
              , MATORG2 = null
              , cless2  = null
              , regime2 = null
              , caisse2 =  null
              , GUICHETORG2 = null
        WHERE numindiv = l_individu.numindiv;

        -- demande de carte tp pour les individu dependant du porteur de
        IF appel_carte_tp  = 1 THEN
          FOR R_adhe  IN   C_adhe(l_individu.numindiv)LOOP
                pk_porte.P_INS_demande_tp (
                        I_numporte => R_adhe.numporte,
                        I_idadhesion => R_adhe.idadhesion,
                        I_numgar     => R_adhe.numgar,
                        I_numindiv   => l_individu.numindiv,
                        I_debut      => SYSDATE,--a valider par GEREP
                        I_fin        => R_adhe.datper,
                        I_type       => 16,
                        I_numfor     => R_adhe.numfor
                      );
                    EXIT; --on insert juste pour une adhesion
            END LOOP;
        END IF;

        UPDATE NOEMIE
        --M0005567 SET   numassu = f_numassu(l_individu.numindiv)
        SET   numassu = l_individu.numindiv
        WHERE matorg =  l_ss_ajoute
        AND TRUNC(CREATION )= TRUNC(SYSDATE)
        and numremise = 0 -- M0005567
        ;


       -- SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
       SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
       INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
								IDHISTORAPPEL,
								CONTEXTE,
								ENTITE,
								TYPE,
								REFERENCE,
								REVISION,
								CREATION,
								CREATEUR,
								MAJ,
								MODIFICATEUR,
								ETAT,
								RESPONSABLE,
								COMMENTAIRE)
					VALUES ( loc_rappel.IDRAPPEL,
                                        V_IDHISTORAPPEL,
                                        loc_rappel.CONTEXTE,
                                        loc_rappel.ENTITE,
                                        loc_rappel.TYPE,
                                        loc_rappel.REFERENCE,
                                        loc_rappel.REVISION,
                                        loc_rappel.CREATION,
                                        loc_rappel.CREATEUR,
                                        sysdate,
                                        F_numutil,
                                          6,
                                        loc_rappel.RESPONSABLE,
                                        'Ayant droit changé en ouvreur de droit'||l_individu.numindiv
                                        ||chr(10)||chr(13)||'NUMSS = '||l_individu.matorg
                                        ||chr(10)||chr(13)||'REGIME = '||l_individu.REGIME
                                        ||chr(10)||chr(13)||'CAISSE = '||l_individu.caisse
                                        ||chr(10)||chr(13)||'CENTRE = '||l_individu.guichetorg
                                        ||chr(10)||chr(13)||'NUMSS2 = '||l_individu.matorg2
                                        ||chr(10)||chr(13)||'REGIME2 = '||l_individu.REGIME2
                                        ||chr(10)||chr(13)||'CAISSE2 = '||l_individu.caisse2
                                        ||chr(10)||chr(13)||'CENTRE2 = '||l_individu.guichetorg2);
      SET_RAPPEL_ERREUR(  loc_rappel.IDRAPPEL,  loc_rappel.code_err, 3);


      ELSE -- non => l'ouvreur modification du numéro de sécurité sociale et copie des modifications sur ces ayants droits.    (where nature =2)
          l_numassu := f_numassu(l_individu.numindiv);
        UPDATE INDIVIDU   -- modification des ayant droit qui avaient le même premier numero de sécurité sociale
        SET     MATORG = l_ss_ajoute
              , cless  = l_cle_ajoute
              , regime = l_regime
              , caisse =  nvl(l_caisse,caisse)
              , GUICHETORG= l_centre
        WHERE  MATORG = l_individu.matorg
        AND numassu = l_numassu
        AND NATUR = 2;
        --
        UPDATE INDIVIDU  -- modification des ayant droit qui avaient le même deuxième numero de sécurité sociale
        SET     MATORG2 = l_ss_ajoute
              , cless2  = l_cle_ajoute
              , regime2 = l_regime
              , caisse2 =  nvl(l_caisse,caisse2)
              , GUICHETORG2= l_centre
        WHERE  MATORG2 = l_individu.matorg
        AND numassu =  l_numassu
        AND NATUR = 2;
        --
        UPDATE individu     -- modification de  l'ouvreur de droit s'il est conjoint et qu'il était sur le même ss il faut conserver cet upd séparémment
        SET     MATORG = l_ss_ajoute
              , cless  = l_cle_ajoute
              , regime = l_regime
              , caisse =  l_caisse
              , GUICHETORG= l_centre
        WHERE numindiv = l_individu.numindiv
        AND numassu = l_numassu;

        IF appel_carte_tp  =1 THEN
          FOR R_adhe  IN   C_adhe(l_individu.numindiv)LOOP
                pk_porte.P_INS_demande_tp (
                        I_numporte => R_adhe.numporte,
                        I_idadhesion => R_adhe.idadhesion,
                        I_numgar     => R_adhe.numgar,
                        I_numindiv   => l_individu.numindiv,
                        I_debut      => SYSDATE,--a valider par GEREP
                        I_fin        => R_adhe.datper,
                        I_type       => 16,
                        I_numfor     => R_adhe.numfor
                      );
                    EXIT; --on insert juste pour une adhesion
            END LOOP;
        END IF;

        UPDATE NOEMIE
        --M0005567 SET   numassu = f_numassu(l_individu.numindiv)
        SET   numassu =l_individu.numindiv
        WHERE matorg =  l_ss_ajoute
        AND TRUNC(CREATION )= TRUNC(SYSDATE)
        and numremise = 0 -- M0005567
        ;

      --SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
      SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
       INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
								IDHISTORAPPEL,
								CONTEXTE,
								ENTITE,
								TYPE,
								REFERENCE,
								REVISION,
								CREATION,
								CREATEUR,
								MAJ,
								MODIFICATEUR,
								ETAT,
								RESPONSABLE,
								COMMENTAIRE)
				VALUES ( loc_rappel.IDRAPPEL,
                                        V_IDHISTORAPPEL,
                                        loc_rappel.CONTEXTE,
                                        loc_rappel.ENTITE,
                                        loc_rappel.TYPE,
                                        loc_rappel.REFERENCE,
                                        loc_rappel.REVISION,
                                        loc_rappel.CREATION,
                                        loc_rappel.CREATEUR,
                                        sysdate,
                                        F_numutil,
                                          6,
                                        loc_rappel.RESPONSABLE,
                                        'Modification du numéro de sécurité sociale et copie des modifications sur ses ayants droit. '||l_individu.numindiv
                                        ||chr(10)||chr(13)||'NUMSS = '||l_individu.matorg
                                        ||chr(10)||chr(13)||'REGIME = '||l_individu.REGIME
                                        ||chr(10)||chr(13)||'CAISSE = '||l_individu.caisse
                                        ||chr(10)||chr(13)||'CENTRE = '||l_individu.guichetorg
                                        ||chr(10)||chr(13)||'NUMSS2 = '||l_individu.matorg2
                                        ||chr(10)||chr(13)||'REGIME2 = '||l_individu.REGIME2
                                        ||chr(10)||chr(13)||'CAISSE2 = '||l_individu.caisse2
                                        ||chr(10)||chr(13)||'CENTRE2 = '||l_individu.guichetorg2);
      SET_RAPPEL_ERREUR(  loc_rappel.IDRAPPEL,  loc_rappel.code_err, 3);
      END IF;

    ELSIF  l_num_to_modif = 2 THEN   --  DEUXIEME NUMÉRO CONCERNÉ
    -- est ce un ayant doit?      nature !=1
      IF l_individu.natur = 2 THEN        -- oui => modification de son nummss2
         BEGIN -- on récupére l'individu qui a le même numéro de sécurité sociale
          SELECT numindiv, CAISSE, REGIME, GUICHETORG into   num_indiv_rattachement, l_caisse_ajoute, l_regime_ajoute, l_centre_ajoute
          FROM INDIVIDU
          WHERE MATORG = l_ss_ajoute
          AND natur = 1   -- ouvreur de droit
          AND f_numassu(numindiv) = loc_rappel.numassu; -- on prends uniquement les individus ouvreurs de droit

        EXCEPTION
          WHEN TOO_MANY_ROWS THEN
            return 2229;
          WHEN OTHERS THEN
            return 2230;
        END;

        UPDATE INDIVIDU  -- modification des ayants droit qui avaient le même deuxième numero de sécurité sociale
        SET     MATORG2 = l_ss_ajoute
              , cless2  = l_cle_ajoute
              , regime2 = l_regime_ajoute
              , caisse2 =  nvl(l_caisse_ajoute,caisse2)
              , GUICHETORG2= l_centre_ajoute
        WHERE  numindiv = l_individu.numindiv
        AND NATUR = 2;
        IF appel_carte_tp  = 1 THEN
             -- demande de carte tp pour les individu dependant du porteur de
          FOR R_adhe  IN   C_adhe(num_indiv_rattachement)LOOP
                pk_porte.P_INS_demande_tp (
                        I_numporte => R_adhe.numporte,
                        I_idadhesion => R_adhe.idadhesion,
                        I_numgar     => R_adhe.numgar,
                        I_numindiv   => num_indiv_rattachement,
                        I_debut      => SYSDATE,--a valider par GEREP
                        I_fin        => R_adhe.datper,
                        I_type       => 16,
                        I_numfor     => R_adhe.numfor
                      );
                    EXIT; --on insert juste pour une adhesion
            END LOOP;
          END IF;

        UPDATE NOEMIE
       --M0005567 SET   numassu = f_numassu(num_indiv_rattachement)
        SET   numassu = num_indiv_rattachement
        WHERE matorg =  l_ss_ajoute
        AND TRUNC(CREATION )= TRUNC(SYSDATE)
        and numremise = 0 -- M0005567
        ;

        -- SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
        SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
         INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
									IDHISTORAPPEL,
									CONTEXTE,
									ENTITE,
									TYPE,
									REFERENCE,
									REVISION,
									CREATION,
									CREATEUR,
									MAJ,
									MODIFICATEUR,
									ETAT,
									RESPONSABLE,
									COMMENTAIRE)
					VALUES (  loc_rappel.IDRAPPEL,
                                            V_IDHISTORAPPEL,
                                            loc_rappel.CONTEXTE,
                                            loc_rappel.ENTITE,
                                            loc_rappel.TYPE,
                                            loc_rappel.REFERENCE,
                                            loc_rappel.REVISION,
                                            loc_rappel.CREATION,
                                            loc_rappel.CREATEUR,
                                            sysdate,
                                            F_numutil,
                                            6,
                                            loc_rappel.RESPONSABLE,
                                          'Modification du second numéro ss de l''individu '|| l_individu.numindiv
                                          ||chr(10)||chr(13)||'NUMSS = '||l_individu.matorg
                                          ||chr(10)||chr(13)||'REGIME = '||l_individu.REGIME
                                          ||chr(10)||chr(13)||'CAISSE = '||l_individu.caisse
                                          ||chr(10)||chr(13)||'CENTRE = '||l_individu.guichetorg
                                          ||chr(10)||chr(13)||'NUMSS2 = '||l_individu.matorg2
                                          ||chr(10)||chr(13)||'REGIME2 = '||l_individu.REGIME2
                                          ||chr(10)||chr(13)||'CAISSE2 = '||l_individu.caisse2
                                          ||chr(10)||chr(13)||'CENTRE2 = '||l_individu.guichetorg2);
        SET_RAPPEL_ERREUR(  loc_rappel.IDRAPPEL,  loc_rappel.code_err, 3);

      ELSE  -- non => Pas possible, on ne peut pas enregistrer un seconds numéross sur un ouvreur de droit)
          return 2239;
      END IF;
    END IF;


  ELSIF l_type_demande_ss = 3   THEN   -- dénoémisation

    FOR r_adhesions IN  c_adhesions(loc_rappel.numbene) LOOP
       FOR r_garantie IN c_garanties(r_adhesions.idadhesion,r_adhesions.numindiv) LOOP
          UPDATE ADHESION
        SET DATPER = l_date_effet
        WHERE IDADHESION = r_adhesions.idadhesion
        AND numindiv = r_adhesions.numindiv
        AND idcouverture = r_garantie.idcouverture;

        r_garantie.idcouverture := null;
        r_garantie.rang := 2;
        r_garantie.datapli := l_date_effet+1;

         INSERT INTO ADHESION VALUES r_garantie;

         l_liste_adhesion_fermee := l_liste_adhesion_fermee ||chr(10)||chr(13)||r_adhesions.idadhesion ||','    ;
      END LOOP;


       UPDATE INDIVIDU
      SET regime = 50,             --RKO M0005757
      caisse = '000' ,
      regime2 = decode(nvl(regime2,'-1'),'-1',null,50),
      caisse2 = decode (regime2, 50, '000', null)
      WHERE numindiv = loc_rappel.numbene;

      COMMIT;

    END LOOP;

     for indiv_rattachement in c_individu_rattachement(loc_rappel.numbene , loc_rappel.numassu ) loop   --RKO M0005757
     IF appel_carte_tp  = 1 THEN      --RKO M0005757
           -- demande de carte tp pour les individu dependant du porteur de
        FOR R_adhe  IN   C_adhe(indiv_rattachement.numindiv)LOOP
              pk_porte.P_INS_demande_tp (
                      I_numporte => R_adhe.numporte,
                      I_idadhesion => R_adhe.idadhesion,
                      I_numgar     => R_adhe.numgar,
                      I_numindiv   => indiv_rattachement.numindiv,
                      I_debut      => SYSDATE,--a valider par GEREP
                      I_fin        => R_adhe.datper,
                      I_type       => 16,
                      I_numfor     => R_adhe.numfor
                    );
                  EXIT; --on insert juste pour une adhesion
          END LOOP;
        END IF;
        end loop;
    -- historisation de l'action effectué
    --SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
    SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
    INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
							IDHISTORAPPEL,
							CONTEXTE,
							ENTITE,
							TYPE,
							REFERENCE,
							REVISION,
							CREATION,
							CREATEUR,
							MAJ,
							MODIFICATEUR,
							ETAT,
							RESPONSABLE,
							COMMENTAIRE)
			VALUES ( loc_rappel.IDRAPPEL,
                                    V_IDHISTORAPPEL,
                                    loc_rappel.CONTEXTE,
                                    loc_rappel.ENTITE,
                                    loc_rappel.TYPE,
                                    loc_rappel.REFERENCE,
                                    loc_rappel.REVISION,
                                    loc_rappel.CREATION,
                                    loc_rappel.CREATEUR,
                                    sysdate,
                                    F_numutil,
                                    loc_rappel.ETAT,
                                    loc_rappel.RESPONSABLE,
                                    'Dénoémisation du bénéficiaire'||chr(10)||chr(13)||'Liste des adhésions dont les garanties ont été fermées:'||l_liste_adhesion_fermee);
     SET_RAPPEL_ERREUR(  loc_rappel.IDRAPPEL,  loc_rappel.code_err, 3);

   ELSIF l_type_demande_ss = 4   THEN   -- dénoémisation
       SELECT numindiv --, CAISSE, REGIME, GUICHETORG --RKO M0005757 on prend l'ouvreur de droit qui a le même numss que l'individu que l'on dénoémise
          into   num_indiv_rattachement --, l_caisse_ajoute, l_regime_ajoute, l_centre_ajoute
          FROM INDIVIDU
          WHERE MATORG in (select matorg from individu where numindiv = loc_rappel.numbene)
          AND natur = 1   -- ouvreur de droit
          and f_numassu(numindiv) = loc_rappel.numassu
        ;
          UPDATE INDIVIDU  -- modification des ayants droit qui avaient le même deuxième numero de sécurité sociale
          SET
                regime = l_regime
              , caisse =  l_caisse
              , GUICHETORG = l_centre
          WHERE  numindiv = l_individu.numindiv;

        IF appel_carte_tp  = 1 THEN
             -- demande de carte tp pour les individu dependant du porteur de
          FOR R_adhe  IN   C_adhe(num_indiv_rattachement)LOOP
                pk_porte.P_INS_demande_tp (
                        I_numporte => R_adhe.numporte,
                        I_idadhesion => R_adhe.idadhesion,
                        I_numgar     => R_adhe.numgar,
                        I_numindiv   => num_indiv_rattachement,
                        I_debut      => SYSDATE,--a valider par GEREP
                        I_fin        => R_adhe.datper,
                        I_type       => 16,
                        I_numfor     => R_adhe.numfor
                      );
                    EXIT; --on insert juste pour une adhesion
            END LOOP;
          END IF;
  END IF;
  RETURN 0;

END F_VALIDE_ADD_NUMSS;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_VALIDE_ADD_RIB                                          */
/* Type         :  Public                                                    */
/* Description  :  Fonction de validation d un RIB a travers une demande de  */
/*                 nouveau RIB                                               */
/* Auteur       :  JBO                                                       */
/* Date         :  07/11/2017                                                */
/* Commentaire  :  Projet P201709001_EA_Adhesion_Ind_GEREP                   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_VALIDE_ADD_RIB (i_idrappel RAPPEL.IDRAPPEL%TYPE , i_numporte PORTE_CONTRAT.NUMPORTE%TYPE)
RETURN NUMBER
IS

  loc_rappel       RAPPEL%ROWTYPE;
  loc_individu     INDIVIDU%ROWTYPE;
  loc_rib_old      RIB%ROWTYPE;
  loc_rib_new      RIB%ROWTYPE;
  loc_idrib_old    RIB.IDRIB%TYPE;
  loc_numutil      UTILISATEURS.NUMUTIL%TYPE;
  loc_Code_Retour  NUMBER := 0;

  l_context_rappel  NUMBER;
  l_code_demande    NUMBER;
  loc_numutil   UTILISATEURS.NUMUTIL%TYPE;
  l_nature      RIB.nature%TYPE;
  l_codbque     RIB.codbque%TYPE;
  l_guichet     RIB.guichet%TYPE;
  l_compte      RIB.compte%TYPE;
  l_clerib      RIB.clerib%TYPE;
  l_codpays     RIB.codpays%TYPE :=1;
  loc_code_erreur loc_rappel.code_err%TYPE;
  Code_Retour   NUMBER;
  i             NUMBER  := 1;
  l_bic         RIB.bic%TYPE;
  l_id_rib        RIB.IDRIB%type;
  exc_info_com           EXCEPTION;
  exc_rib_decaismt       EXCEPTION;
  exc_mandat_non_valide  EXCEPTION;

BEGIN
  /****************************************************************************/
  /****************** RECUPERATION DES INFORMATIONS UTILES ********************/
  /****************************************************************************/
  BEGIN
    SELECT *
      INTO loc_rappel
      FROM RAPPEL
     WHERE idrappel = i_idrappel;

     -- récupération des information du rib présentent dans le commentaire du rappel
    loc_rib_new.numindiv      := F_GET_VALUE_IN_TABLE('Adhérent', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
    loc_rib_new.Bic           := F_GET_VALUE_IN_TABLE('Bic', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
    loc_rib_new.Bban          := F_GET_VALUE_IN_TABLE('Bban', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
    loc_rib_new.clef_iban     := F_GET_VALUE_IN_TABLE('Clef iban', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
    loc_rib_new.type          := F_GET_VALUE_IN_TABLE('Type de Rib', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
    loc_rib_new.domiciliation := F_GET_VALUE_IN_TABLE('Domiciliation', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
    loc_rib_new.intitule      := F_GET_VALUE_IN_TABLE('Nom titulaire', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
    loc_rib_new.debut         := NVL(NVL(e2d(F_GET_VALUE_IN_TABLE('Date d''effet', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire))), loc_rappel.dateeffet),SYSDATE);
    loc_rib_new.debut:=TRUNC(loc_rib_new.debut);
    loc_rib_new.idrib         := idrib.nextval;
    loc_rib_new.codope        :=0;
    loc_rib_new.numgar        :=0;
    loc_rib_new.modpmt        :=2;
    loc_rib_new.nature        :=2;
    loc_rib_new.devise_compte :=pk_devise.devise_ref;
    loc_rib_new.devise_ope    :=pk_devise.devise_ref;
    loc_rib_new.creation      := TRUNC(SYSDATE);
    loc_rib_new.codpays       := 1;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE exc_info_com;
  END;

  BEGIN
    SELECT numutil INTO loc_rib_new.NUMUTIL_CREATION FROM PORTE_PARAM WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN
      loc_rib_new.NUMUTIL_CREATION:=f_numutil;
  END;

  -- si le rib est de type décaissement on ne permet pas la validation manuel
  IF loc_rib_new.type = 1 THEN
    RAISE exc_rib_decaismt;
  END IF;

  /****************************************************************************/
  /************** FIN RECUPERATION DES INFORMATIONS UTILES ********************/
  /****************************************************************************/

  /****************************************************************************/
  /****************** MAJ/INSERTION DU NOUVEAU RIB ****************************/
  /****************************************************************************/

  -- récupération du rib en cours.
  SELECT F_BENE_RIB (loc_rib_new.numindiv, 0, 0, loc_rib_new.type,NULL,loc_rib_new.debut)
    INTO loc_idrib_old
    FROM DUAL;

   PK_virement.P_sel_rib (  I_codpays    =>   loc_rib_new.codpays,
                          I_clef_iban  =>     loc_rib_new.clef_iban,
                          I_bban      =>      loc_rib_new.Bban ,
                          O_codbque    =>    l_codbque,
                          O_guichet    =>    l_guichet,
                          O_compte    =>    l_compte,
                          O_clerib    =>    l_clerib,
                          O_retour    =>  Code_Retour);

    IF IS_RIB_DIFFERENT(loc_idrib_old,loc_rib_new.Bic, loc_rib_new.Bban , null/* l_clerib*/  ) = 2197 THEN
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2197, 4);
      return  2197;
    END IF;
  /*  -- CLI 5557 deplacé aprés la création du nouveau rib
  -- Amendement du mandat SEPA
   PK_sepa.p_generer_amendement ( iv_idrib      =>  loc_idrib_old ,
                                  iv_clef_iban  =>  loc_rib_new.clef_IBAN,
                                  iv_bban       =>  loc_rib_new.BBAN,
                                  iv_BIC        =>  loc_rib_new.BIC,
                                  iv_idrib_new  =>  null,
                                  ov_retour      =>  loc_Code_Retour
                                  );

    IF loc_Code_Retour > 0 THEN

      IF loc_Code_Retour = 2083 THEN -- idrib lié à mandat dans remise non validée
          RAISE exc_mandat_non_valide;
      END IF;
    END IF;
   COMMIT;

  */
  --historisation et fermeture du rib en cours
  UPDATE RIB
     SET FIN = nvl(loc_rib_new.debut-1,SYSDATE)
   WHERE RIB.IDRIB = loc_idrib_old ;
  COMMIT;
  -- Insertion du nouveau rib
   INSERT INTO rib VALUES loc_rib_new;
   COMMIT;
     -- Amendement du mandat SEPA
   PK_sepa.p_generer_amendement ( iv_idrib      =>  loc_idrib_old ,
                                  iv_clef_iban  =>  loc_rib_new.clef_IBAN,
                                  iv_bban       =>  loc_rib_new.BBAN,
                                  iv_BIC        =>  loc_rib_new.BIC,
                                  iv_idrib_new  =>  loc_rib_new.idrib ,     -- allimenté depuis la mantis 5557 le 23/03/2018
                                  ov_retour      =>  loc_Code_Retour
                                  );

    IF loc_Code_Retour > 0 THEN

      IF loc_Code_Retour = 2083 THEN -- idrib lié à mandat dans remise non validée
          RAISE exc_mandat_non_valide;
      END IF;
    END IF;
   COMMIT;

  /****************************************************************************/
  /************** FIN INSERTION DU NOUVEAU RIB ********************************/
  /****************************************************************************/
  RETURN 0;

EXCEPTION
  WHEN exc_info_com THEN
   --Impossible de récupérer les infos du commentaire de la demande:'||sqlerrm
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 318, 4);     -- 2251
    ROLLBACK;
    RETURN -1;
  WHEN exc_rib_decaismt THEN
  --Impossible de valider manuellement un rib de type décaissement:'||sqlerrm
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 318, 4);       -- 2252
    ROLLBACK;
    RETURN -1;
  WHEN exc_mandat_non_valide THEN
   --idrib lié à mandat dans remise non validée:'||sqlerrm
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2083, 4);       -- 2083
    ROLLBACK;
    RETURN -1;
  WHEN OTHERS THEN
   -- F_VALIDE_ADD_RIB KO, sqlerrm: '||sqlerrm
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 318, 4);
    ROLLBACK;
    RETURN -1;
END F_VALIDE_ADD_RIB;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_VALIDE_SUBSCRIBE                                        */
/* Type         :  Public                                                    */
/* Description  :  Fonction de validation d une souscription a travers la    */
/*                 corbeille ST03                                            */
/* Auteur       :  CLI                                                       */
/* Date         :  14/11/2017                                                */
/* Commentaire  :  Projet P201709001_EA_Adhesion_Ind_GEREP                   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/



FUNCTION F_VALIDE_SUBSCRIBE(i_idrappel RAPPEL.IDRAPPEL%TYPE , i_numporte PORTE_CONTRAT.NUMPORTE%TYPE) RETURN NUMBER
IS
  loc_rappel rappel%rowtype;
  loc_id_adhesion      NUMBER;
  loc_id_adhesion_OPT      NUMBER;
  loc_etat_courant     NUMBER;
  loc_motif_courant    NUMBER;
  loc_histo_adhesion histo_adhesion%rowtype;
  loc_numindiv         NUMBER;
  loc_ano              NUMBER;
  V_IDHISTORAPPEL  NUMBER;
  loc_type_sous    NUMBER;
  loc_idrappel_option rappel.idrappel%type;
  l_niveau_trace param_batch.param5%type;
  loc_numgar number;

 loc_NAT_CALC contrat.NAT_CALC%type;
 loc_TYPEQUIT contrat.TYPEQUIT%type;

 CURSOR c_individu_carteTP( l_idadhesion  number, l_debut DATE) IS
 Select adhesion.idadhesion,adhesion.numindiv,adhesion.numgar,
              porte_contrat.numporte,
              adhesion.numfor,
              adhesion.datper                                               -- Ajout le 20100212 M00003055
       from   adhesion,
              porte_contrat, porte_param,individu i
       where  f_numgar_ref(adhesion.numgar) = porte_contrat.numgar
       and    porte_contrat.numporte != 1
       and    nvl (adhesion.datper, sysdate) >= sysdate
       and    l_debut between adhesion.datapli and nvl (adhesion.datper, l_debut)
       and    adhesion.etat =1
       and    adhesion.idadhesion=l_idadhesion
       and    porte_contrat.numporte = porte_param.numporte
       and    porte_param.nat_porte in (3,5) --ABO ajout du filtre pour ne pas déclancher sur les autres portes
       AND    porte_param.type_circuit<>3
       AND    i.numindiv= adhesion.numindiv
       AND    i.natur=1; --on ne prend que les ouvreurs de droits

 CURSOR c_individu_noemie( l_idadhesion  number) IS
 SELECT DISTINCT i.NUMINDIV
 FROM ADHESION a ,individu i , porte_contrat p
 WHERE a.idadhesion = l_idadhesion
 AND a.numindiv = i.numindiv
 AND f_numgar_ref(a.numgar) = p.numgar
 AND p.numporte =1
 AND (i.regime <> 50 OR i.regime2<>50)
 AND a.rang=1;

  CURSOR R_RAPPELS_DEPENDANTS (i_idrappel NUMBER, i_numbene NUMBER, i_id_adhesion NUMBER )IS
   SELECT * FROM RAPPEL
      WHERE TYPE IN (20,26,25,26,27,23)
      AND  i_idrappel <> idrappel
      AND  i_numbene = numbene
      AND  i_id_adhesion in( to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) ,
                              to_number(F_GET_VALUE_IN_TABLE('Idadhesion_base', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))))  -- pour les souscription optionnelles
       ;


     -- on passe la DAtad
  CURSOR c_adhesion_to_valide(i_numindiv NUMBER, i_idadhesion NUMBER) IS     -- on prend aussi les adhésions depéndantes de l'adhésion de base a valider
    WITH adhe_initial   As
      (SELECT DISTINCT a.IDADHESION, a.datapli, a.numgar
      FROM  ADHESION a,  ADHE_CNTRT ac
      WHERE F_ETAT_ADHE(a.idadhesion , greatest (ac.date_adhe,sysdate) )  = 0 --instance
      AND   F_ETAT_ADHE(a.idadhesion , greatest (ac.date_adhe,sysdate) , 2 ) in (59,60) -- motif préaff
      AND   ac.numadhe = i_numindiv
      AND   a.IDADHESION = i_idadhesion
      AND   a.idadhesion = ac.idadhesion)
      SELECT  adhe_initial.IDADHESION, adhe_initial.datapli
       from adhe_initial
      UNION
      /*SELECT a.IDADHESION , a.datapli
       from adhesion a,  ADHE_CNTRT ac
       where ac.numadhe = i_numindiv
         AND   F_ETAT_ADHE(a.idadhesion , greatest (ac.date_adhe,sysdate)  )  = 0 --instance
         AND   F_ETAT_ADHE(a.idadhesion , greatest (ac.date_adhe,sysdate) , 2 ) in (59,60)
         AND   a.idadhesion = ac.idadhesion
         AND   a.numfor in (select numenvers from dependance where numde IN (select numfor from adhesion where idadhesion=i_idadhesion) and role = 5)--M6708 24112020
         -- adhesion resultant d'une dépendance auto instanciée
      */  --RKO M0007171 validation des options obligatoires lors de la validation de l'option de base
      select distinct id_adhesion idadhesion, DATEEFFET datapli
      from rappel_souscript ,adhe_cntrt ac
      WHERE rappel_souscript.idrappel =i_idrappel
      AND ac.idadhesion = rappel_souscript.id_adhesion
      AND F_ETAT_ADHE(ac.idadhesion , greatest (ac.date_adhe,sysdate) ) = 0 --instance
      AND F_ETAT_ADHE(ac.idadhesion , greatest (ac.date_adhe,sysdate) , 2 ) in (59,60)
    ;

    CURSOR c_adhe_rac (i_adhesion NUMBER, i_datapli DATE) IS
         SELECT numgar , numindiv,  numfor,  i_datapli  datapli
        from adhesion where idadhesion =   i_adhesion
        and i_datapli between datapli and nvl(datper, datapli);

 loc_ADHE_CNTRT adhe_cntrt%rowtype;
 exc_cotisation exception;
 exc_echeance exception;

 loc_reste_a_charge NUMBER; -- permet de savoir si il existe un reste a charge a prendre en compte.
 nb_numgar_resil_ok  NUMBER;
 nb_numgar_deja_resil  NUMBER;


 BEGIN

    SELECT *
      INTO loc_rappel
      FROM RAPPEL
     WHERE rappel.idrappel = i_idrappel ;

   /* TODO: code a supprimer quelques temps aprés la mise en production*/
     IF loc_rappel.commentaire NOT like '%Idadhesion%'THEN
       loc_ano:= F_INSTANCIE_SUBSCRIBE_DEV(i_idrappel,i_numporte);  -- pour faire la liaison apres livraison en prod on instancie les adhésions qui n(ont pas été instanciée automatiqiement
     END IF;

     -- on met a jours le commentaire pour récuperer l'adhésion
    SELECT *
      INTO loc_rappel
      FROM RAPPEL
     WHERE rappel.idrappel = i_idrappel;
     /** FIN du TODO*/

    loc_id_adhesion   := to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)));

    BEGIN
    --Contrôle sur la résiliation du contrat à la date d’effet de l’adhésion
      select count(distinct ac.numgar) into nb_numgar_deja_resil
      from adhe_cntrt ac, rappel r, histo_contrat hc
      where r.entite=ac.idadhesion
      and pk_histo_contrat.f_sel_etat(ac.numgar,r.dateeffet)=3 --contrat resilié à la date d'adhesion
      and hc.numgar=ac.numgar
      and r.idrappel= i_idrappel
      and ac.idadhesion= loc_id_adhesion
      ;
      IF nb_numgar_deja_resil >0 then
       --return message blocant pour afficher en sel_mess avec raise Form_trigger_failure
        return 2410;
      ELSE
      --Si le contrat n’est pas résilié à la date d’effet de l’adhesion, on verifie son état sur les 60jours suivants par rapport à la date du jour
        select count(distinct ac.numgar) into nb_numgar_resil_ok
        from adhe_cntrt ac, histo_contrat hc, rappel r
        where r.entite=ac.idadhesion
        and hc.numgar=ac.numgar
        and pk_histo_contrat.f_sel_etat(ac.numgar,sysdate+60)=3 --contrat resilié sous 60jours par rapport à la date du jour
        and ac.idadhesion= loc_id_adhesion
        and r.idrappel=i_idrappel;

        IF nb_numgar_resil_ok >0 THEN
         return 2409;
        ELSE
        	null;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_VALIDE_SUBSCRIBE',
                                   I_session  => SID,
                                   I_niv_msg  => 3,
                                   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'F_VALIDE_SUBSCRIBE ano nb_numgar_resil_ok/nb_numgar_deja_resil: '||sqlerrm,
                                   I_idligne  => 2);
    END;
    For r_adhesion_to_valide IN c_adhesion_to_valide(loc_rappel.numassu, loc_id_adhesion) LOOP

     loc_type_sous := to_number(F_GET_VALUE_IN_TABLE('Type de souscription', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)));

     loc_etat_courant :=  F_ETAT_ADHE( r_adhesion_to_valide.idadhesion,
                                       greatest(sysdate,r_adhesion_to_valide.datapli),-- on passe les datpali pour être sur que l'état est bon
                                       1);

     loc_motif_courant := F_ETAT_ADHE ( r_adhesion_to_valide.idadhesion,
                                        greatest(sysdate,r_adhesion_to_valide.datapli),
                                        2);


     IF  loc_etat_courant = 0 and  loc_motif_courant IN (59,60) THEN    -- on ne valide que les options ou les souscription de base deja validée par le RH
          loc_histo_adhesion.idadhesion := r_adhesion_to_valide.idadhesion;
          loc_histo_adhesion.datsai := sysdate;
          loc_histo_adhesion.etat :=  1;
          loc_histo_adhesion.motif := 57;
          loc_histo_adhesion.numutil := f_numutil;

          SELECT DISTINCT DATAPLI, numgar
          INTO loc_histo_adhesion.debut , loc_numgar
          FROM ADHESION
          where idadhesion = r_adhesion_to_valide.idadhesion ;

          IF PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_histo_adhesion) THEN

            UPDATE ADHESION
            SET etat = 1, motif = 57
            WHERE idadhesion = loc_id_adhesion;

            SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 6);

           --parcours de tous les bénéficiaires et création si contrat ouvert
            FOR r_individu IN  c_individu_noemie(r_adhesion_to_valide.idadhesion) LOOP
              ins_noemie (1, r_individu.numindiv, r_adhesion_to_valide.idadhesion, loc_numgar, loc_histo_adhesion.debut, null, 'C', 1);
            END LOOP;
            --création de la carte de TPE pour tous les membres si contrat ouvert
            FOR r_individu_C IN c_individu_carteTP (r_adhesion_to_valide.idadhesion,loc_histo_adhesion.debut) LOOP
              pk_porte.P_INS_demande_tp (
                      I_numporte => r_individu_C.numporte,
                      I_idadhesion => r_individu_C.idadhesion,
                      I_numgar     => r_individu_C.numgar,
                      I_numindiv   => r_individu_C.numindiv,
                      I_debut      => loc_histo_adhesion.debut,--a valider par GEREP
                      I_fin        => r_individu_C.datper,
                      I_type       => 16,
                      I_numfor     => r_individu_C.numfor
                    );
            END LOOP;
              Commit; -- obliatoire pour pouvoir appler le caclulateur
            --****************************************************************************
            --****************** LANCEMENT DU CALCUL DE COTISATIONS **********************
            --****************************************************************************
            Begin

              SELECT c.NAT_CALC, c.TYPEQUIT
                INTO  loc_NAT_CALC, loc_TYPEQUIT
                FROM CONTRAT c, adhe_cntrt a
               WHERE c.NUMGAR=a.NUMGAR
               AND c.numgar = a.numgar
               AND a.idadhesion =r_adhesion_to_valide.idadhesion ;

              IF NVL(loc_NAT_CALC,0) = 2 AND NVL(loc_TYPEQUIT,0) = 2  THEN   -- niveau d'appel et de calucl adhérent
                select PARAM5
                  into l_niveau_trace
                  from param_batch
                  where numbatch = 'QG02T';
                select *
                  into loc_ADHE_CNTRT
                  from adhe_cntrt
                  where idadhesion = r_adhesion_to_valide.idadhesion;

                P_LANCE_CALCUL_COTIS( 'QG02T',
                                      l_niveau_trace,
                                      loc_ADHE_CNTRT,
                                      r_adhesion_to_valide.datapli ,
                                      loc_ano);
                IF loc_ano=2288 THEN
                   RAISE exc_cotisation;
                ELSIF loc_ano>0 THEN
                   RAISE exc_echeance;
                END IF;
              END IF;
            EXCEPTION
              WHEN exc_cotisation THEN
              --exc_cotisation KO, sqlerrm: '||sqlerrm);
              SET_RAPPEL_ERREUR (loc_rappel.idrappel, 235, 1);        -- Incohérence dans le calcul de l'échéance ...
              ROLLBACK;
              RETURN 235;
              WHEN exc_echeance THEN
              --exc_cotisation KO, sqlerrm: '||sqlerrm);
              SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2288, 1);        -- L''échéance de cotisation n''est pas créé
              ROLLBACK;
              RETURN 2288;
            END ;

           -- -Une alerte est remontée au gestionnaire permettant d’identifier l’existence de sinistre payé avec un reste à charge assuré sur la période
            -- d’adhésion à l’option. : Si on rajoute une option le calcul de sinistre déjà payé avec un RAC devra être annulé et recalculé en
            -- prenant en compte la nouvelle garantie option
            IF loc_type_sous in (1,3) THEN
            FOR r_adhe_rac in  c_adhe_rac (r_adhesion_to_valide.idadhesion, r_adhesion_to_valide.datapli) LOOP
                IF F_EXIST_RAC(r_adhe_rac.numgar, r_adhe_rac.numindiv, r_adhe_rac.numfor, r_adhe_rac.datapli)  > 0 THEN
                 -- SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2261, 1);
                  loc_reste_a_charge :=  2261;
                  EXIT;
              END IF;
            END LOOP;
          END IF;


        -- la validation d'une base valide aussi l'option dépendante
        IF  loc_type_sous = 2    THEN -- si on viens de valider une base
          BEGIN
            SELECT idrappel, to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), rappel.commentaire)))
            INTO loc_idrappel_option , loc_id_adhesion_OPT
            FROM rappel
            WHERE numbene = loc_rappel.numbene
            AND type = 27
            AND ETAT = 3
            AND idrappel <> loc_rappel.idrappel
            AND to_number(F_GET_VALUE_IN_TABLE('Idadhesion_base', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) = r_adhesion_to_valide.idadhesion
            AND  F_ETAT_ADHE( to_number(F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), rappel.commentaire))),
                                       sysdate,
                                       1 )  = 0  -- on prend l'adhésion optionnel en instance
            --AND to_number(F_GET_VALUE_IN_TABLE('Type de souscription', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) IN (1,3)
            ;

              loc_histo_adhesion.idadhesion := loc_id_adhesion_OPT;
              loc_histo_adhesion.datsai := sysdate;
              loc_histo_adhesion.etat :=  1;
              loc_histo_adhesion.motif := 57;
              loc_histo_adhesion.numutil := f_numutil;

          SELECT DISTINCT DATE_ADHE, numgar
              INTO loc_histo_adhesion.debut , loc_numgar
              FROM ADHE_CNTRT
              where idadhesion = loc_id_adhesion_OPT ;

              IF PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_histo_adhesion) THEN

                UPDATE ADHESION
                SET etat = 1, motif = 1
                WHERE idadhesion = loc_id_adhesion_OPT;

                SET_RAPPEL_ERREUR (loc_idrappel_option, null, 6);
        Commit;  -- commit olbigaztoire pour appeler correctement le calculateur
         --****************************************************************************
         --****************** LANCEMENT DU CALCUL DE COTISATIONS  pour l'option********
         --****************************************************************************

      Begin
              SELECT c.NAT_CALC, c.TYPEQUIT
                INTO  loc_NAT_CALC, loc_TYPEQUIT
                FROM CONTRAT c
               WHERE c.NUMGAR= loc_numgar;

              IF NVL(loc_NAT_CALC,0) = 2 AND NVL(loc_TYPEQUIT,0) = 2  THEN   -- niveau d'appel et de calucl adhérent
                select PARAM5
                  into l_niveau_trace
                  from param_batch
                  where numbatch = 'QG02T';
                select *
                  into loc_ADHE_CNTRT
                  from adhe_cntrt
                  where idadhesion = loc_id_adhesion_OPT;

                  P_LANCE_CALCUL_COTIS( 'QG02T',
                                        l_niveau_trace,
                                        loc_ADHE_CNTRT,
                                        loc_histo_adhesion.debut ,
                                        loc_ano);
                IF loc_ano=2288 THEN
                   RAISE exc_cotisation;
                ELSIF loc_ano>0 THEN
                   RAISE exc_echeance;
                END IF;
              END IF;
            EXCEPTION
              WHEN exc_cotisation THEN
              --exc_cotisation KO, sqlerrm: '||sqlerrm);
              SET_RAPPEL_ERREUR (loc_rappel.idrappel, 235, 1);        -- Incohérence dans le calcul de l'échéance ...
              ROLLBACK;
              RETURN 235;
              WHEN exc_echeance THEN
              --exc_cotisation KO, sqlerrm: '||sqlerrm);
              SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2288, 1);        -- L''échéance de cotisation n''est pas créé
              ROLLBACK;
              RETURN 2288;
            END ;

  -- -Une alerte est remontée au gestionnaire permettant d’identifier l’existence de sinistre payé avec un reste à charge assuré sur la période
  -- d’adhésion à l’option. : Si on rajoute une option le calcul de sinistre déjà payé avec un RAC devra être annulé et recalculé en
  -- prenant en compte la nouvelle garantie option
      FOR r_adhe_rac in  c_adhe_rac (loc_id_adhesion_OPT, loc_histo_adhesion.debut) LOOP
          IF F_EXIST_RAC(r_adhe_rac.numgar, r_adhe_rac.numindiv, r_adhe_rac.numfor, r_adhe_rac.datapli)  > 0 THEN
           -- SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2261, 1);
            loc_reste_a_charge :=  2261;
            EXIT;
        END IF;
      END LOOP;
            END IF;--F_INSERT_HISTO_ADHESION loc_id_adhesion_OPT

          EXCEPTION WHEN NO_DATA_FOUND THEN
              NULL;
          END ;--select loc_id_adhesion_OPT
         END IF;--loc_type_sous=2
       ELSE
          -- probleme a l'insertion de l'historique
          return 2349; -- etat de l'adhésion incompatible avec l'action demandée
       END IF;--PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_histo_adhesion)
     END IF;--loc_etat_courant = 0 and  loc_motif_courant IN (59,60)
     END LOOP;


     SET_RAPPEL_ERREUR(  loc_rappel.IDRAPPEL,  null , 6);
    --SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
    SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
          INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
									IDHISTORAPPEL,
									CONTEXTE,
									ENTITE,
									TYPE,
									REFERENCE,
									REVISION,
									CREATION,
									CREATEUR,
									MAJ,
									MODIFICATEUR,
									ETAT,
									RESPONSABLE,
									COMMENTAIRE)
				VALUES (loc_rappel.idrappel,
                                      V_IDHISTORAPPEL,
                                      loc_rappel.CONTEXTE,
                                      loc_rappel.ENTITE,
                                      loc_rappel.TYPE,
                                      loc_rappel.REFERENCE,
                                      loc_rappel.REVISION,
                                      loc_rappel.CREATION,
                                      loc_rappel.CREATEUR,
                                      sysdate,
                                      F_numutil,
                                      6,
                                      loc_rappel.RESPONSABLE,
                                     'Validation de la demande'||loc_rappel.IDRAPPEL);

    -- il faut valider les demandes connexes (l'appel de cette procédure peut venir d'une demande RH ou d'une demande de souscription)
    FOR c_rappel in r_rappels_dependants(loc_rappel.IDRAPPEL , loc_rappel.numbene , loc_id_adhesion ) LOOP
        -- Historisation de la liste des adhésion
      --SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
      SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
     PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_VALIDE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 3,   I_msg_adm  =>   'idrappel=['||loc_rappel.idrappel||']'||'Validation de la demande automatiquement via la validation de la demande '||loc_rappel.IDRAPPEL||', référence externe : '||loc_rappel.REFERENCE,  I_idligne  => 2);

      INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
								IDHISTORAPPEL,
								CONTEXTE,
								ENTITE,
								TYPE,
								REFERENCE,
								REVISION,
								CREATION,
								CREATEUR,
								MAJ,
								MODIFICATEUR,
								ETAT,
								RESPONSABLE,
								COMMENTAIRE)
			VALUES (c_rappel.IDRAPPEL,
                                      V_IDHISTORAPPEL,
                                      c_rappel.CONTEXTE,
                                      c_rappel.ENTITE,
                                      c_rappel.TYPE,
                                      c_rappel.REFERENCE,
                                      c_rappel.REVISION,
                                      c_rappel.CREATION,
                                      c_rappel.CREATEUR,
                                      sysdate,
                                      F_numutil,
                                      6,
                                      c_rappel.RESPONSABLE,
                                     'Validation de la demande automatiquement via la validation de la demande '||loc_rappel.IDRAPPEL||', référence externe : '||loc_rappel.REFERENCE);
       SET_RAPPEL_ERREUR(  c_rappel.IDRAPPEL,  null , 6);
     END LOOP update_rappel_dependant;
     Commit;


     IF loc_reste_a_charge  = 2261 THEN
      return loc_reste_a_charge;
     ELSE
      return 0;
     END IF ;
END F_VALIDE_SUBSCRIBE;

FUNCTION F_INSTANCIE_SUBSCRIBE_DEV(i_idrappel RAPPEL.IDRAPPEL%TYPE , i_numporte PORTE_CONTRAT.NUMPORTE%TYPE)
RETURN NUMBER
IS

  loc_rappel                 RAPPEL%ROWTYPE;
  loc_TAB_T_SOUSCRIPTION     T_SOUSCRIPTION;
  loc_TAB_T_BENE             TAB_bene;
  loc_new_idadhesion         ADHESION.IDADHESION%TYPE:=NULL;
  loc_first_adhesion_cree    ADHESION.IDADHESION%TYPE:=NULL;
  loc_numfor                 ADHESION.NUMFOR%TYPE:=NULL;
  loc_ADHE_CNTRT             ADHE_CNTRT%ROWTYPE;
  loc_HISTO_ADHESION         HISTO_ADHESION%ROWTYPE;
  loc_ADHE_CNTRT_MEMBRE      ADHE_CNTRT_MEMBRE%ROWTYPE;
  loc_ADHESION               ADHESION%ROWTYPE;
  loc_AFFIL_TRACE            AFFIL_TRACE%ROWTYPE;
  loc_verif_numfor           ADHESION.NUMFOR%TYPE;
  loc_numfor_exist           NUMBER;
  i                          NUMBER:=0;
  j                          NUMBER:=0;
  T_indiv                    TAB_indiv;
  T_bene                     TAB_bene;
  loc_flag_new_adhe_cntrt    NUMBER:=0;
  loc_reste_a_charge          NUMBER:=0;
  loc_numcli                  NUMBER;
  /*         control cohérence            */

  loc_flux_consultation EXTR_PROSPECT ;
  loc_flux_consult    EXTR_TAB_BENE_PROSPECT ;


  loc_ano                    NUMBER:=NULL;
  loc_motif_adhe             NUMBER:=1;
  exc_info_com               EXCEPTION;
  exc_nat_calc               EXCEPTION;
  exc_adhecntrt              EXCEPTION;
  exc_adhecntrt_sepa         EXCEPTION;
  exc_histo_adhesion         EXCEPTION;
  exc_adhe_membre            EXCEPTION;
  exc_adhesion               EXCEPTION;
  exc_adhesion_exist         EXCEPTION;
  exc_garantie               EXCEPTION;
  exc_garantie_base          EXCEPTION;
  exc_garantie_opt           EXCEPTION;
  exc_numgar_multi           EXCEPTION;
  exc_numfor_multi           EXCEPTION;
  exc_numfor_exist           EXCEPTION;
  exc_nb_bene_dif            EXCEPTION;
  exc_doc_not_exist          EXCEPTION;
  exc_cotisation             EXCEPTION;
  exc_echeance               EXCEPTION;
  exc_demande_doublon        EXCEPTION;
  exc_contrat_not_in_flux    EXCEPTION;

  dummy                       NUMBER;
  l_niveau_trace     PARAM_BATCH.PARAM5%type;
  loc_type_sous            NUMBER;
  loc_type_gar              number;
  loc_rappel_souscript rappel_souscript%rowtype;

  CURSOR c_adhesion_rappel(p_id_rappel NUMBER, p_numadhe number) is
    SELECT rappel_souscript.idrappel,
    rappel_souscript.numgar,
    rappel_souscript.numfor,
    rappel_souscript.numindiv,
    rappel_souscript.typassu,
    rappel_souscript.id_adhesion,
    rappel_souscript.mdpmt,
    rappel_souscript.type_souscription,
    rappel_souscript.dateeffet,
    rappel_souscript.rang,
    rappel_souscript.provenance,
    rappel_souscript.rowid
      FROM rappel_souscript
      WHERE idrappel = p_id_rappel
    ORDER BY provenance asc,
            CASE WHEN numindiv = p_numadhe  THEN 1 ELSE 2 END asc,
            NUMGAR DESC,
            NUMFOR,
            NUMINDIV,
            TYPASSU ASC
    FOR UPDATE
        ;
  r_adhesion_rappel   c_adhesion_rappel%rowtype;

BEGIN
  --****************************************************************************
  --****************** RECUPERATION DES INFORMATIONS UTILES ********************
  --****************************************************************************

    SELECT *
      INTO loc_rappel
      FROM RAPPEL
     WHERE idrappel = i_idrappel;

    OPEN  c_adhesion_rappel(i_idrappel, loc_rappel.numassu ) ;
    FETCH c_adhesion_rappel into r_adhesion_rappel  ;     -- On ne orend que la première ligne
    loc_TAB_T_SOUSCRIPTION.NUMADHERENT:= loc_rappel.numbene;
    loc_TAB_T_SOUSCRIPTION.NUMINDIV   := loc_TAB_T_SOUSCRIPTION.NUMADHERENT;
    loc_TAB_T_SOUSCRIPTION.DATEEFFET  := r_adhesion_rappel.dateeffet;
    loc_TAB_T_SOUSCRIPTION.MODE_PAIE  := r_adhesion_rappel.mdpmt;
    loc_TAB_T_SOUSCRIPTION.TYPBENE    := r_adhesion_rappel.typassu;
    loc_TAB_T_SOUSCRIPTION.NUMGAR     := r_adhesion_rappel.numgar;

    SELECT numcli
    INTO loc_numcli
    FROM contrat
    WHERE numgar =   loc_TAB_T_SOUSCRIPTION.NUMGAR ;
    loc_type_sous  :=r_adhesion_rappel.type_souscription;
    IF loc_TAB_T_SOUSCRIPTION.MODE_PAIE = 4 AND  F_EXIST_DOCUMENT(i_idrappel)=0 THEN
      RAISE exc_doc_not_exist;
    END IF;

    CLOSE c_adhesion_rappel;


    IF loc_type_sous =3 THEN  -- si on est en souscription BIA, la date d'effet est la même que la l'adhesion de base
     BEGIN
      SELECT    min(DATE_ADHE)
      INTO      loc_TAB_T_SOUSCRIPTION.DATEEFFET
      FROM      ADHE_CNTRT
      WHERE     idadhesion = to_number(F_GET_VALUE_IN_TABLE('Idadhesion_base', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire))) ;
     EXCEPTION WHEN OTHERS THEN
        loc_TAB_T_SOUSCRIPTION.DATEEFFET := sysdate;
     END;
    END IF;

    IF loc_type_sous in(1,3) THEN -- option ou option via la pré-aff
        loc_type_gar := 2;
    ELSE
        loc_type_gar := 1;
    END IF;
         PK_trace.P_INS_journal_adm (  I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',
                                       I_session  => SID,
                                       I_niv_msg  => 1,
                                       I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||' P_NUMADHE     =>'||loc_TAB_T_SOUSCRIPTION.NUMADHERENT||
                                                      ' P_NUMGAR      =>'||loc_TAB_T_SOUSCRIPTION.NUMGAR ||
                                                      ' P_NATURE      =>'||loc_type_sous||  -- type de flux de consultation dynamique
                                                      ' P_DATEEFFET   =>'||null||
                                                      ' P_NUMCLI      =>'||loc_numcli,
                                       I_idligne  => 2);

     IF  loc_type_sous in(1,3) THEN --  si c'est d l'optionnel on ne passe pas le numgar en paramétre
    loc_flux_consultation  := PK_WS_WEB_BACK.F_CONTRACT_TO_SIGN_UP(   P_NUMADHE  =>loc_TAB_T_SOUSCRIPTION.NUMADHERENT,
                                                                      P_NUMGAR  =>    null,
                                                                      P_NATURE  => loc_type_sous,  -- type de flux de consultation dynamique
                                                                      P_DATEEFFET => null,
                                                                      P_NUMCLI=> loc_numcli);
    ELSE   -- on passe le numgar en paramétre pour de la consultation de contrat de base
      loc_flux_consultation  := PK_WS_WEB_BACK.F_CONTRACT_TO_SIGN_UP(   P_NUMADHE  =>loc_TAB_T_SOUSCRIPTION.NUMADHERENT,
                                                                        P_NUMGAR  =>    loc_TAB_T_SOUSCRIPTION.NUMGAR ,
                                                                        P_NATURE  => loc_type_sous,  -- type de flux de consultation dynamique
                                                                        P_DATEEFFET => loc_TAB_T_SOUSCRIPTION.DATEEFFET,--null, --ARTGEREP_343 on verifie la souscriptibilité sur le nouveau contrat base à la date effet
                                                                        P_NUMCLI=> loc_numcli);
    END IF;
    -- verifie que le contrat est bien souscriptible selon le flux de consultation pour cet individu


  -- Fin des vérifications

  FOR r_adhesion_rappel IN c_adhesion_rappel(i_idrappel, loc_rappel.numassu )   LOOP

    BEGIN
          PK_trace.P_INS_journal_adm (  I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',
                                       I_session  => SID,
                                       I_niv_msg  => 1,
                                       I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'tour de boucle',
                                       I_idligne  => 2);
        IF   r_adhesion_rappel.provenance = 1 THEN  --verifie pour chaque adhésion initalement demandé (hors dépendance type PEPS)
          BEGIN                                                 --   si le contrat est souscriptible

            IF loc_flux_consultation IS NOT NULL THEN
            PK_trace.P_INS_journal_adm (  I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',
                                         I_session  => SID,
                                         I_niv_msg  => 1,
                                         I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'loc_flux_consultation IS NOT NULL',
                                         I_idligne  => 2);

             elsif     loc_flux_consultation.TAB_PROSPECT IS NOT NULL      THEN

              PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',
                                           I_session  => SID,
                                           I_niv_msg  => 1,
                                           I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'loc_flux_consultation.TAB_PROSPECT IS NOT NULL',
                                           I_idligne  => 2);
             end if;
            dummy:= null;
            IF loc_flux_consultation IS NOT NULL AND loc_flux_consultation.TAB_PROSPECT IS NOT NULL THEN
              PK_trace.P_INS_journal_adm (  I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',
                                         I_session  => SID,
                                         I_niv_msg  => 1,
                                         I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'on lance le test',
                                         I_idligne  => 2);

              SELECT 1
              INTO dummy
              FROM dual
              WHERE EXISTSNODE(xmltype(loc_flux_consultation),'/EXTR_PROSPECT/TAB_PROSPECT/EXTR_BENE_PROSPECT[./TYPBENE[text()='
                                                              || F_GET_TRANSCO ('EA','TYPASSU',to_char(r_adhesion_rappel.typassu))
                                                              ||']]/TAB_CONTRACTS/EXTR_CONTRACT_TO_SIGN_UP[./NUMGAR[text()='
                                                              ||loc_TAB_T_SOUSCRIPTION.NUMGAR
                                                              ||']]/TAB_GRNT/EXTR_GRNT_TO_SIGN_UP[./NUMFOR[text()='
                                                              ||r_adhesion_rappel.numfor
                                                              ||']]'
                                                              )=1  ;

            ELSE
              RAISE NO_DATA_FOUND;
            END IF;
            dummy:= null;
          EXCEPTION WHEN NO_DATA_FOUND THEN
            dummy:= null;
            RAISE exc_contrat_not_in_flux;
          END;
       END IF; -- fin de verification pour les adhésion initial
      i:=i+1;
      loc_TAB_T_BENE(i).NUMBENE   := r_adhesion_rappel.numindiv;
      loc_TAB_T_BENE(i).TYPBENE   := r_adhesion_rappel.typassu;
      loc_TAB_T_BENE(i).CONTRAT   := r_adhesion_rappel.numgar;
      loc_TAB_T_BENE(i).GARANTIES := r_adhesion_rappel.numfor;
      loc_TAB_T_BENE(i).PROVENANCE := r_adhesion_rappel.PROVENANCE;
      loc_TAB_T_BENE(i).rang := r_adhesion_rappel.rang;

      loc_numfor_exist:=PK_WS_WEB_BACK.IS_ADHESION_EXISTS (loc_TAB_T_BENE(i).GARANTIES , loc_TAB_T_BENE(i).NUMBENE, loc_TAB_T_SOUSCRIPTION.DATEEFFET,loc_type_gar);  --on verifie sur base ou option suivant le type de souscription réalisée
      IF NVL(loc_numfor_exist,0)> 0 THEN
        RAISE exc_numfor_exist;
      END IF;

  -- car on a incrémenté l'indice avant de sortir du LOOP précédent

  EXCEPTION
    WHEN exc_numgar_multi THEN
      RAISE exc_numgar_multi;
    WHEN exc_numfor_multi THEN
      RAISE exc_numfor_multi;
    WHEN exc_demande_doublon THEN
      RAISE exc_demande_doublon;
    WHEN exc_numfor_exist THEN
      RAISE exc_numfor_exist;
    WHEN exc_doc_not_exist THEN
    RAISE exc_doc_not_exist;
    WHEN exc_contrat_not_in_flux THEN
      RAISE exc_contrat_not_in_flux;
    WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',
                                 I_session  => SID,
                                 I_niv_msg  => 3,
                                 I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'F_VALIDE_SUBSCRIBE 1er begin others: sqlerrm: '||sqlerrm,
                                 I_idligne  => 2);
    RAISE exc_info_com;
  END;
  END LOOP;

  BEGIN
    SELECT numutil
    INTO loc_TAB_T_SOUSCRIPTION.numutil
    FROM PORTE_PARAM
    WHERE numporte = i_numporte;
  EXCEPTION
    WHEN OTHERS THEN
      loc_TAB_T_SOUSCRIPTION.numutil :=f_numutil;
  END;
      --  i:=i-1;
  -------------------------------------- CONTROLES A RECEPTION DU FLUX  ----------------------------
  -- Si le mode de prélèvement est 4 (papier), le flux doit contenir au moins une pièce justificative


  -----------------------------------FIN CONTROLES A RECEPTION DU FLUX  ----------------------------

  --****************************************************************************
  --************** FIN RECUPERATION DES INFORMATIONS UTILES ********************
  --****************************************************************************


  --****************************************************************************
  --****************** MAJ/INSERTION DE LA SOUSCRIPTION ************************
  --****************************************************************************



  SELECT c.NAT_CALC, c.TYPEQUIT
    INTO  loc_TAB_T_SOUSCRIPTION.NAT_CALC, loc_TAB_T_SOUSCRIPTION.TYPEQUIT
    FROM CONTRAT c
   WHERE c.NUMGAR=loc_TAB_T_SOUSCRIPTION.NUMGAR;

 -- 1) Créer une adhésion au contrat  à la date d’effet demandée sous le motif « 1- nouvelle affaire » Avec le

  -- vérification si une adhésion en vigueur est déjà existante pour cet assuré
  -- Si l adhesion est existante elle doit avoir obligatoirement une garantie de base valide
  -- On récupère dans un tableau les membres de l adhésion au contrat si elle est existante
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 3,   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'Find_adhesion ',  I_idligne  => 2);

  j:=0;

  FOR r_adhesion_rappel  IN c_adhesion_rappel(i_idrappel, loc_rappel.numassu ) LOOP

  select * into  loc_rappel_souscript
  from rappel_souscript
  where rappel_souscript.rowid = r_adhesion_rappel.rowid ;

   -- on mets a jours le contrat de la souscription au cas ou on ai plusieur numgar, cela oblige le traitement a creer une nouvelle adhesion
    loc_TAB_T_SOUSCRIPTION.NUMGAR := loc_rappel_souscript.numgar;
    loc_TAB_T_SOUSCRIPTION.numfor := loc_rappel_souscript.numfor;
    loc_TAB_T_SOUSCRIPTION.dateeffet := loc_rappel_souscript.dateeffet;
    loc_numfor:=loc_TAB_T_SOUSCRIPTION.numfor;
    loc_flag_new_adhe_cntrt:=0;

    IF loc_type_sous in(1,3) THEN  -- Si l'option est portée par la base, on renvoie l'adhésion de base.
         loc_TAB_T_SOUSCRIPTION.IDADHESION:= F_FIND_ADHESION(loc_rappel.numbene,loc_numfor); -- un adhésion exist-elle dejà sur le contrat en question
           PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 3,   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'  loc_TAB_T_SOUSCRIPTION.IDADHESION = '||  loc_TAB_T_SOUSCRIPTION.IDADHESION,  I_idligne  => 2);
     ELSE
        loc_TAB_T_SOUSCRIPTION.IDADHESION :=0;
         loc_numfor := 0;
         loc_ano :=1;
         BEGIN  -- on récupère l'adhésion en vigeur du contrat

           SELECT nvl(max(idadhesion),0)
            INTO loc_TAB_T_SOUSCRIPTION.IDADHESION
            FROM AdHE_CNTRT
            WHERE NUMADHE =  loc_rappel.numbene
            and f_etat_adhe(idadhesion, sysdate ) <> 3
            AND  NUMGAR  =  loc_rappel_souscript.numgar;



            PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'Find_adhesion ok  ='||loc_new_idadhesion,  I_idligne  => 2);
          EXCEPTION WHEN OTHERS THEN
            loc_flag_new_adhe_cntrt:=1;
            loc_TAB_T_SOUSCRIPTION.IDADHESION :=0;
            PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'Find_adhesion non trouvé on met 0',  I_idligne  => 2);

         END;
    END IF;
    -- si on ne récupère pas d'adhésion existante alors il faudra en instancier une nouvelle
    loc_new_idadhesion :=  loc_TAB_T_SOUSCRIPTION.IDADHESION;
    IF nvl(loc_new_idadhesion,0) = 0 THEN
      loc_flag_new_adhe_cntrt:=1;
    END IF;

    IF loc_type_sous in(1,3) THEN  --souscription à l'option (09/07/2018 BIA)
      -- Vérification que la garantie de base de l'adhesion à laquelle on souhaite ajouter une garantie  est bien paramétrée
      loc_verif_numfor:=F_VERIF_NUMFOR(loc_rappel_souscript.numfor, --loc_numfor,
                                      loc_ano);


      IF NVL(loc_verif_numfor,0)> 0 THEN
        RAISE exc_garantie_base;
      END IF;
    END IF;


  -- Faire une boucle
  -- Vérification que l'adhérent et ses membres n a pas déjà souscript à la garantie optionnelle de la demande



   IF loc_flag_new_adhe_cntrt = 1 THEN
    ---------------------------------------------------------------------------------
    ---********************** CREATION ADHE_CNTRT************************************
    ---------------------- Commun a base et option-----------------------------------
    P_INIT_ADHE_CNTRT( loc_TAB_T_SOUSCRIPTION
                     , loc_ADHE_CNTRT
                     , loc_ano);

    loc_new_idadhesion:=loc_ADHE_CNTRT.IDADHESION;

    IF loc_ano=1 THEN
      RAISE exc_adhecntrt;
    ELSIF loc_ano = 2096 THEN
      RAISE  exc_adhecntrt_sepa; --Le mode de règlement de ce contrat se fait par prélèvement et l'adhérent n'a pas de coordonnées SEPA valides
    END IF;
   --   PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'loc_ADHE_CNTRT.dateeffet =' ||loc_ADHE_CNTRT.dateeffet,  I_idligne  => 2);

    IF PK_CTRL_AFFIL.F_INSERT_ADHE_CNTRT(loc_ADHE_CNTRT) THEN
      loc_ano:=0;
    ELSE
      RAISE exc_adhecntrt;
    END IF;


    ---------------------------------------------------------------------------------
    -- ********************** CREATION HISTO_ADHESION********************************
    ---------------------------------------------------------------------------------
    SELECT decode(loc_type_sous, 1,60,     -- optionnel motif = Option en attente de validation interne
                                 2,58,     -- base = Pré-affiliation bIA
                                 3,58,     -- optionnel venant de BIA
                                 1)       -- sinon nouvelle affaire
    INTO loc_motif_adhe
    FROM dual;
      --création de l'état en instance
     P_INIT_HISTO_ADHESION( loc_TAB_T_SOUSCRIPTION
                         , loc_HISTO_ADHESION
                         , loc_new_idadhesion
                         , 0
                         , loc_motif_adhe
                         , loc_ano);
      IF loc_ano<> 0 THEN
        RAISE exc_histo_adhesion;
      END IF;
      IF PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_HISTO_ADHESION) THEN
        loc_ano:=0;
      ELSE
        RAISE exc_histo_adhesion;
      END IF;
  END IF;

  loc_first_adhesion_cree := nvl(loc_first_adhesion_cree,loc_new_idadhesion);

    ---------------------------------------------------------------------------------
    -- ********************** CREATION ADHE_CNTRT_MEMBRE*****************************
    --  Il s'agit d'un merge donc on le creer au besoin
    ---------------------------------------------------------------------------------
      P_INIT_ADHE_CNTRT_MEMBRE_DEV( loc_rappel_souscript
                                  , loc_new_idadhesion
                                  , loc_ano);
      IF loc_ano<>0 THEN
        RAISE exc_adhe_membre;
      END IF;



    IF loc_type_sous in (1,3) THEN  --souscription à l'option (09/07/2018 BIA)
  -- Vérification que la garantie passée dans la demande est bien du même type(base ou option)
  -- si au préalable une adhésion est trouvée avec une garantie
  -- Boucle sur les bénéficiaires
      loc_verif_numfor:=F_VERIF_NUMFOR(loc_rappel_souscript.numfor, loc_ano);
      --loc_verif_numfor: '|| loc_verif_numfor

      IF loc_verif_numfor > 0 THEN
        RAISE exc_garantie_opt;
      END IF;
    ELSE
    loc_verif_numfor:=0;
    END IF;

    IF loc_verif_numfor =0 THEN
      ---------------------------------------------------------------------------------
      -- ********************** CREATION ADHESION *************************************
      ---------------------------------------------------------------------------------

      P_INIT_ADHESION( loc_TAB_T_SOUSCRIPTION
                     , loc_rappel_souscript
                     , loc_new_idadhesion
                     , loc_numfor   -- garantie de base
                     , loc_ADHESION
                     , loc_ano);

        IF loc_ano<>0 THEN
          RAISE exc_adhesion;
      END IF;
       IF PK_CTRL_AFFIL.F_INSERT_ADHESION(loc_ADHESION) THEN
        loc_ano:=0;
           update rappel_souscript
            set  ID_ADHESION= loc_new_idadhesion
            where rappel_souscript.rowid = r_adhesion_rappel.rowid;
      ELSE

      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'exc_adhesion P_INIT_ADHESION KO: '||sqlerrm,  I_idligne  => 2);

         RAISE exc_adhesion;
      END IF;
    ELSE
      RAISE exc_garantie;    -- 1030
    END IF;
  END LOOP r_adhesion_rappel;


  --****************************************************************************
  --************** FIN MAJ/INSERTION DE LA SOUSCRIPTION ************************
  --****************************************************************************
  -- mise a jour du rappel pour qu'il pointe vers l'adhsesion
  UPDATE rappel set commentaire = commentaire||chr(10)||chr(13)|| 'Idadhesion : '|| loc_first_adhesion_cree ||';'
  , entite =loc_first_adhesion_cree
  , contexte = 13   -- on lui remet le contexte 13 adhesion
  where idrappel = loc_rappel.idrappel;


  COMMIT;



  --***************************************************************************
  --****************** FIN LANCEMENT DU CALCUL DE COTISATIONS *****************
  --***************************************************************************
  If loc_reste_a_charge> 0 THEN -- renvoi le message du reste a charge 2261
    RETURN loc_reste_a_charge ;
  END IF;
   RETURN 0;

EXCEPTION
  WHEN exc_contrat_not_in_flux THEN
    --Ce contrat n''est pas souscriptible selon les régles établies');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2352, 1);
    ROLLBACK;
    RETURN 2352;
  WHEN exc_nat_calc THEN
    --Souscription impossible : Contrat option mal paramétré');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2275, 1);
    ROLLBACK;
    RETURN 2275;
  WHEN exc_demande_doublon THEN
    --Doublon de demande detectée');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2283, 1);
    ROLLBACK;
    RETURN 2283;
  WHEN exc_numgar_multi THEN
    --Souscription impossible car plusieurs contrats sont contenus dans la demande ');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2253, 1);
    ROLLBACK;
    RETURN 2253;
  WHEN exc_numfor_multi THEN
    --Souscription impossible car plusieurs garanties sont contenues dans la demande ');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2254, 1);
    ROLLBACK;
    RETURN 2254;
  WHEN exc_numfor_exist THEN
    --Une adhésion existe déjà pour l''un de ces membres');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2285, 1);
    ROLLBACK;
    RETURN 2285;
  WHEN exc_adhesion_exist THEN
    --Adhésion déjà existante pour cette garantie ');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2262, 1);
    ROLLBACK;
    RETURN 2262;
  WHEN exc_nb_bene_dif THEN
   --Nombre de bénéficiaires différents entre la demande et le SI');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2254, 1);
    ROLLBACK;
    RETURN 2259;
  WHEN exc_doc_not_exist THEN
    --Si le mode de prélèvement est 4 (papier), le flux doit contenir au moins une pièce justificative');
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2260, 1);
    ROLLBACK;
    RETURN 2260;
  WHEN exc_adhecntrt THEN
    --exc_adhecntrt KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2281, 1);        -- Création impossible de l'' adhésion au contrat
    ROLLBACK;
    RETURN 2281;
  WHEN exc_adhecntrt_sepa THEN
    --exc_adhecntrt_sepa KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2096, 1);  --Le mode de règlement de ce contrat se fait par prélèvement et l'adhérent n'a pas de coordonnées SEPA valides
    ROLLBACK;
    RETURN 2096;
  WHEN exc_histo_adhesion THEN
   --exc_histo_adhesion KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2279, 1);        -- Création impossible de la situation de l'' adhésion
    ROLLBACK;
    RETURN 2279;
  WHEN exc_adhe_membre THEN
    --exc_adhe_membre KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2280, 1);        -- Création impossible des membres de l'' adhésion
    ROLLBACK;
    RETURN 2280;
  WHEN exc_adhesion THEN
    --exc_adhesion KO, sqlerrm: '||sqlerrm);
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'exc_adhesion KO: '||sqlerrm,  I_idligne  => 2);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2284, 1);        -- Impossible de créer les couvertures de l adhésion
    ROLLBACK;
    RETURN 2284;
  WHEN exc_garantie THEN
    --exc_garantie KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 1030, 1);        -- Cette garantie n'est pas valide
    ROLLBACK;
    RETURN 1030;
  WHEN exc_garantie_base THEN
    --exc_garantie_base KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2277, 1);        -- Cette garantie de base n''est pas valide
    ROLLBACK;
    RETURN 2277;
  WHEN exc_garantie_opt THEN
   --exc_garantie_opt KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2278, 1);        -- Cette garantie optionelle n''est pas valide
    ROLLBACK;
    RETURN 2278;
  WHEN exc_cotisation THEN
    --exc_cotisation KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 235, 1);        -- Incohérence dans le calcul de l'échéance ...
    ROLLBACK;
    RETURN 235;
  WHEN exc_echeance THEN
    --exc_cotisation KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2288, 1);        -- L''échéance de cotisation n''est pas créé
    ROLLBACK;
    RETURN 2288;
  WHEN OTHERS THEN
    --F_INSTANCIE_SUBSCRIBE KO, sqlerrm: '||sqlerrm);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2255, 1);        -- Validation et intégration de la souscription impossible
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_INSTANCIE_SUBSCRIBE',   I_session  => SID, I_niv_msg  => 3,   I_msg_adm  =>  'idrappel=['||loc_rappel.idrappel||']'||'dernier when others sqlerrm: '||sqlerrm,  I_idligne  => 2);
    ROLLBACK;
    RETURN 2255;
    return  0;
END F_INSTANCIE_SUBSCRIBE_DEV;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_VALIDE_ADD_BENE                                         */
/* Type         :  Public                                                    */
/* Description  :  A la validation de l'ajout d'un bénéficiaire on verifie  */
/*              : qu'une adhésion a bien été crée sur l'individu.            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_VALIDE_ADD_BENE(i_idrappel number , i_numporte number) RETURN NUMBER
IS
  loc_beneficiaire individu%rowtype;
  loc_rappel rappel%rowtype;
  loc_nopiece number := null;
  loc_piece pieces%rowtype;
  loc_idadhesion number;
BEGIN
  SELECT * INTO loc_rappel from rappel
  WHERE  idrappel =  i_idrappel;

  SELECT *   INTO loc_beneficiaire FROM individu
  WHERE numindiv = loc_rappel.numbene ;

/* verifier si une adhésion est existante pour l'individu en question*/
 BEGIN
  SELECT max(idadhesion)
  INTO loc_idadhesion
    FROM adhesion
    WHERE numindiv = loc_beneficiaire.numindiv
      AND sysdate BETWEEN datapli AND nvl(datper,sysdate);
  IF loc_idadhesion IS NULL THEN
    RETURN 2308;
  END IF;
 EXCEPTION  WHEN NO_DATA_FOUND THEN
  RETURN 2308;
 END;
  -- creation des pièces sur l'individu nouvellement créée
  IF loc_beneficiaire.typadr = 2 THEN
    --Enfant mineur	12 – ayant droit	23 =>2
    --Enfant majeur	12 – ayant droit	26 =>2
    IF f_age(loc_beneficiaire.datnais) > 18 THEN
      loc_nopiece := to_number(f_get_transco('EA','SCOLA_N', 2,2));
    ELSE
      loc_nopiece := 23;
    END IF;
  ELSIF loc_beneficiaire.typadr = 1 THEN
    --Conjoint	12 – ayant droit	23 =>1
    loc_nopiece := 23;
  ELSIF loc_beneficiaire.typadr in (3,7) THEN
    --Concubin	12 – ayant droit	20  =>3
    --Pacsé	12 – ayant droit	20      =>7
    loc_nopiece := 20;
  END IF;

  INSERT INTO PIECES (
                          CONTEXTE,
                          ENTITE ,
                          NUMFOR ,
                          NUMBENE,
                          NUMINDIV_DEST ,
                          IDREPARTITION,
                          NOPIECE,
                          BLOC,
                          DELAI,
                          PERIOD ,
                          NBREL,
                          DATEENREG,
                          DATERECEP )
                VALUES(  12,--loc_piece.contexte, -- contexte Personne
                         loc_idadhesion,--loc_beneficiaire.numindiv,--R_adhesion.idadhesion,
                         0,
                         NVL(loc_rappel.numbene,loc_rappel.numassu),
                         loc_rappel.numassu,--numAdherent,
                         0,
                         loc_nopiece,--loc_piece.nopiece,--TODO
                         'N',
                         30,
                         0 ,--decode(loc_piece.nopiece,3,60,0),
                         NULL,
                        sysdate,
                        sysdate ) -- pièce receptionnée
      RETURNING idpiece INTO loc_piece.idpiece ;
  -- mise a jour des lien_ged existant pour les faire pointer sur
     UPDATE LIEN_GED l
     SET l.etendue = 12,
         l.clef = loc_piece.idpiece
        WHERE   l.ETENDUE =  30
        AND     l.clef = loc_rappel.idrappel;
        COMMIT;
    -- null;

  RETURN 0;
END F_VALIDE_ADD_BENE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_ADHESION                                           */
/* Type         :  Public                                                    */
/* Description  :  Fonction de gestion l'affiliation                         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_ADHESION( p_numadherent  IN   number
                        , P_numfor              IN  ADHESION.NUMFOR%TYPE
                     --   , P_nat_calc            OUT  CONTRAT.NAT_CALC%TYPE
                        )
RETURN ADHE_CNTRT.IDADHESION%TYPE
IS
  loc_idadhesion      AFFIL_PORTE.IDADHESION%TYPE;
  loc_numfor          ADHESION.NUMFOR%TYPE;
  loc_numfor_base_ok  ADHESION.NUMFOR%TYPE;
  loc_numfor_opt_ok   ADHESION.NUMFOR%TYPE;

  CURSOR C_adhesion
      IS
   SELECT ad.idadhesion , ad.numfor ,ad.NUMGAR
     FROM adhesion ad, formule f ,contrat c   , adhe_cntrt adh
    WHERE
      f.numfor =   pk_qttc.f_sel_numfor(ad.NUMGAR, P_numfor)
      AND c.numgar = ad.numgar
      AND adh.idadhesion = ad.idadhesion
      AND adh.numadhe = p_numadherent
      AND nvl(ad.datper, sysdate ) < sysdate+1
   ORDER BY  ad.rang, c.gest_prest , f.typgar,ad.datapli  ;

BEGIN

  SELECT DISTINCT ad.idadhesion
  INTO  loc_idadhesion
   FROM  adhesion ad , adhe_cntrt adc
   WHERE ad.numgar in (select numgar from GAR_CNTRT gc where numfor = p_numfor)-- on récupère le contrat qui correspond a la garantie a souscrire
   AND adc.numadhe =  p_numadherent -- on chope l'adhésion de l'adhérent principale uniquement (on s'en moque de l'individu)
   AND ad.idadhesion = adc.idadhesion
   AND ad.datper is null;
  RETURN loc_idadhesion;

EXCEPTION
  WHEN OTHERS THEN
   --Erreur : F_FIND_ADHESION impossible:, sqlerrm: '||sqlerrm);
  --  P_ano:=803;     -- -- Adhésion inexistante !!!
    RETURN 0;
END F_FIND_ADHESION;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_VERIF_NUMFOR                                            */
/* Type         :  Public                                                    */
/* Description  :  Fonction de gestion des couvertures                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_VERIF_NUMFOR( P_NUMFOR           IN   ADHESION.NUMFOR%TYPE
                       , P_ano              OUT  NUMBER)
RETURN NUMBER
IS
  loc_numfor     ADHESION.NUMFOR%TYPE;

BEGIN
 --F_VERIF_NUMFOR, P_NUMFOR: '|| P_NUMFOR);
 -- Vérification que la garantie optionnelle de l'adhesion à laquelle on souhaite ajouter est bien paramétrée
 SELECT DISTINCT NVL(MAX(f.NUMFOR),0)
   INTO loc_numfor
   FROM FORMULE f
  WHERE f.FIN IS NULL
    AND f.TYPGAR IN(1,2) -- optionnelle      doit être valide
    AND f.NUMFOR = P_NUMFOR
    AND f.VALIDE = 'O'
    AND f.FIN IS NULL;

  --F_VERIF_NUMFOR: '|| loc_numfor);
  IF loc_numfor= 0 THEN
    P_ano:=1030;       -- Cette garantie n'est pas valide
    RETURN 1030;
  END IF;

  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    --'Erreur : F_VERIF_NUMFOR impossible:, sqlerrm: '||sqlerrm);
    P_ano:=1030;     -- -- Cette garantie n'est pas valide
    RETURN 1030;
END F_VERIF_NUMFOR;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_EXIST_DOCUMENT                                          */
/* Type         :  Public                                                    */
/* Description  :  Vérification de l'existence de documents dans 1 demande   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_EXIST_DOCUMENT( P_CLEF           IN   LIEN_GED.CLEF%TYPE)
RETURN NUMBER
IS
  loc_clef     LIEN_GED.CLEF%TYPE;

BEGIN
    --'F_EXIST_DOCUMENT, P_CLEF: '|| P_CLEF);

 -- Vérification que la garantie optionnelle de l'adhesion à laquelle on souhaite ajouter est bien paramétrée
 SELECT DISTINCT NVL(MAX(l.CLEF),0)
   INTO loc_clef
   FROM LIEN_GED l
  WHERE l.clef = P_CLEF;

  RETURN loc_clef;

EXCEPTION
  WHEN OTHERS THEN
  --'Erreur : F_EXIST_DOCUMENT impossible:, sqlerrm: '||sqlerrm);
    RETURN 0;
END F_EXIST_DOCUMENT;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_EXIST_RAC                                               */
/* Type         :  Public                                                    */
/* Description  :  Vérification de l'existence d'un RAC pour un assuré et un */
/*                 contrat à une date donnée                                 */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_EXIST_RAC(P_NUMGAR         IN     SINISTRE.NUMGAR%TYPE
                   , P_NUMINDIV       IN     SINISTRE.NUMINDIV%TYPE
                   , P_NUMFOR         IN     SINISTRE.NUMFOR%TYPE
                   , P_DATEEFFET      IN     SINISTRE.DATSIN%TYPE)
RETURN NUMBER
IS
   loc_RAC         NUMBER:=0;
BEGIN

  SELECT NVL(SUM(MTFRAIS),0)- NVL(SUM(MTREEL),0) - NVL(SUM(MTREMB),0) -NVL(SUM(AUTRB),0) RAC
    INTO loc_RAC
    FROM SINISTRE
   WHERE
   -- NUMFOR=P_NUMFOR AND
     numindiv = P_NUMINDIV
   --  AND numgar=P_NUMGAR
   -- AND IDADHESION=202125
   -- AND F_ETAT_ADHE(idadhesion,P_DATEEFFET) = 1
     AND datsin >= P_DATEEFFET
      ;
   RETURN loc_RAC;
EXCEPTION
  WHEN OTHERS THEN
 --Erreur : F_EXIST_RAC impossible:, sqlerrm: '||sqlerrm);
    RETURN 0;
END F_EXIST_RAC;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_NAT_CALC_TYPEQUIT                                  */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_NAT_CALC_TYPEQUIT(P_NUMGAR         IN     CONTRAT.NUMGAR%TYPE,
                                  P_NAT_CALC       OUT    CONTRAT.NAT_CALC%TYPE,
                                  P_TYPEQUIT       OUT    CONTRAT.TYPEQUIT%TYPE)
RETURN NUMBER
IS
   loc_nat_calc         CONTRAT.NAT_CALC%TYPE:=0;
   loc_typequit         CONTRAT.TYPEQUIT%TYPE:=0;
BEGIN


  SELECT DISTINCT c.NAT_CALC, c.TYPEQUIT
    INTO loc_nat_calc, loc_typequit
    FROM CONTRAT c
   WHERE c.NUMGAR=P_NUMGAR;


   RETURN 1;

EXCEPTION
  WHEN OTHERS THEN
  --'F_FIND_NAT_CALC_TYPEQUIT:, sqlerrm: '||sqlerrm);
    RETURN 0;
END F_FIND_NAT_CALC_TYPEQUIT;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_ADHE_CNTRT                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet ADHE_CNTRT          */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_ADHE_CNTRT( P_TAB_T_SOUSCRIPTION  IN   T_SOUSCRIPTION
                           , P_ADHE_CNTRT          OUT  ADHE_CNTRT%ROWTYPE
                           , P_ano                 OUT  NUMBER)
IS
  ID_ADHE ADHE_CNTRT.IDADHESION%TYPE:=NULL;
  loc_refcie CONTRAT_REF.REFCIE%TYPE:=NULL;

BEGIN

  P_ano:=0;
  SELECT DISTINCT c.REFCIE, c.FRACT,c.MREGL,decode(c.TYPEQUIT,2,P_TAB_T_SOUSCRIPTION.NUMADHERENT, c.NUMQUERABLE),c.delai, decode(c.TYPE_ECHE,1,P_TAB_T_SOUSCRIPTION.DATEEFFET,c.ECHE_ANNIV)
    INTO loc_refcie, P_ADHE_CNTRT.FRACT, P_ADHE_CNTRT.MREGL,  P_ADHE_CNTRT.NUMQUERABLE, P_ADHE_CNTRT.DELAI, P_ADHE_CNTRT.ECHE_ANNIV
    FROM CONTRAT_REF c
   WHERE c.NUMGAR=P_TAB_T_SOUSCRIPTION.NUMGAR
       ;

  IF P_ADHE_CNTRT.MREGL = 2 AND f_ctrl_querable(P_TAB_T_SOUSCRIPTION.NUMADHERENT,greatest(P_TAB_T_SOUSCRIPTION.DATEEFFET,sysdate)) = 0 THEN
       PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_MAIL_INTERLOCUTEUR',
                                    I_session  => SID,
                                    I_niv_msg  => 1,
                                    I_msg_adm  =>P_TAB_T_SOUSCRIPTION.NUMADHERENT   ,
                                    I_idligne  => 4);
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_MAIL_INTERLOCUTEUR',
                                    I_session  => SID,
                                    I_niv_msg  => 1,
                                    I_msg_adm  =>P_TAB_T_SOUSCRIPTION.DATEEFFET  ,
                                    I_idligne  => 4);

    P_ano:= 2096;  -- Le mode de règlement de ce contrat se fait par prélèvement et l'adhérent n'a pas de coordonnées SEPA valides. Veuillez modifier ses coord. bancaires.
  END IF ;


  -- SELECT NVL(MAX(idadhesion),0)+1 INTO ID_ADHE FROM adhe_cntrt; -- harmonisation des idadhesion par sequence
  ID_ADHE := pk_adhesion.f_idadhesion;

  P_ADHE_CNTRT.IDADHESION:=ID_ADHE;
  P_ADHE_CNTRT.REF_EXT:=substr(TO_CHAR(P_ADHE_CNTRT.IDADHESION)||' / '||loc_refcie,0,30);   -- hotfix M0006338
  P_ADHE_CNTRT.NUMGAR:=P_TAB_T_SOUSCRIPTION.NUMGAR;
  P_ADHE_CNTRT.NUMADHE:=P_TAB_T_SOUSCRIPTION.NUMADHERENT;
  P_ADHE_CNTRT.DATE_ADHE:=P_TAB_T_SOUSCRIPTION.DATEEFFET;
  P_ADHE_CNTRT.DSOUS:=P_TAB_T_SOUSCRIPTION.DATEEFFET;
  P_ADHE_CNTRT.MEME_GAR:='N';
  P_ADHE_CNTRT.NUMUTIL:=P_TAB_T_SOUSCRIPTION.NUMUTIL;
 -- P_ADHE_CNTRT.motif:=P_TAB_T_SOUSCRIPTION.motif;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
 --Erreur : Initialisation de l adhesion impossible:: '||sqlerrm);
END P_INIT_ADHE_CNTRT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_HISTO_ADHESION                                     */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet HISTO_ADHESION      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_HISTO_ADHESION( P_TAB_T_SOUSCRIPTION  IN  T_SOUSCRIPTION
                               , P_HISTO_ADHESION      OUT HISTO_ADHESION%ROWTYPE
                               , P_new_idadhesion      IN  HISTO_ADHESION.IDADHESION%TYPE
                               , P_etat                IN  NUMBER
                               , p_mofif               IN  NUMBER
                               , P_ano                 OUT NUMBER)
IS
  loc_IDHISTOADHE HISTO_ADHESION.IDHISTOADHE%TYPE:=NULL;
BEGIN

  P_ano:=0;
  SELECT IDHISTOADHE.NEXTVAL INTO loc_IDHISTOADHE FROM DUAL;
  P_HISTO_ADHESION.IDHISTOADHE:=loc_IDHISTOADHE;
  P_HISTO_ADHESION.IDADHESION:=P_new_idadhesion;
/*  IF P_etat = 0 THEN
    P_HISTO_ADHESION.DEBUT:=TRUNC(sysdate);
  ELSE */
    P_HISTO_ADHESION.DEBUT:=P_TAB_T_SOUSCRIPTION.DATEEFFET;
  --END IF;
  P_HISTO_ADHESION.DATSAI:=SYSDATE;
  P_HISTO_ADHESION.ETAT:=P_etat;
  P_HISTO_ADHESION.MOTIF:= nvl(p_mofif,1);       -- « 1- nouvelle affaire »
  P_HISTO_ADHESION.NUMUTIL:=P_TAB_T_SOUSCRIPTION.NUMUTIL;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
 --Erreur : Initialisation de l histo adhesion impossible: '||sqlerrm);
END P_INIT_HISTO_ADHESION;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_ADHE_CNTRT_MEMBRE                                  */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet ADHE_CNTRT_MEMBRE   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_ADHE_CNTRT_MEMBRE( P_TAB_T_SOUSCRIPTION     IN      T_SOUSCRIPTION
                                  , P_TAB_T_BENE             IN      TAB_bene
                                  , P_new_idadhesion         IN      HISTO_ADHESION.IDADHESION%TYPE
                                  , P_ADHE_CNTRT_MEMBRE         OUT  ADHE_CNTRT_MEMBRE%ROWTYPE
                                  , P_ano                       OUT  NUMBER)
IS
  loc_IDADHECNTRTMB          ADHE_CNTRT_MEMBRE.IDADHECNTRTMB%TYPE:=NULL;
  loc_ADHE_CNTRT_MEMBRE      ADHE_CNTRT_MEMBRE%ROWTYPE;
  loc_idadhesion             ADHESION.IDADHESION%TYPE;
  j                          NUMBER:=0;

  CURSOR C_membres(P_idadhesion   IN   ADHESION.IDADHESION%TYPE)
      IS
  SELECT DISTINCT NVL(MAX(acm.IDADHESION),0) , acm.NUMINDIV, acm.TYPADR, acm.NUMBENE
    FROM ADHE_CNTRT_MEMBRE acm
       , ADHE_CNTRT ac
       , CONTRAT c
       , ADHESION a
   WHERE acm.IDADHESION=ac.IDADHESION
     AND ac.IDADHESION = P_idadhesion
     AND c.NUMGAR=ac.NUMGAR
     AND F_ETAT_ADHE(acm.IDADHESION,SYSDATE) IN (1)
     -- Rajouter sur une garantie
     AND ac.DATE_FIN_ADHE IS NULL
     AND a.IDADHESION=ac.IDADHESION
     AND acm.numindiv not in (select a1.numindiv from  ADHE_CNTRT_MEMBRE a1 where a1.idadhesion = P_new_idadhesion and a1.numindiv=acm.numindiv)
  GROUP BY  acm.NUMINDIV, acm.TYPADR, acm.NUMBENE
     ;




BEGIN

--on entre dans la procédure: '||P_TAB_T_SOUSCRIPTION.idadhesion);
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_INIT_ADHE_CNTRT_MEMBRE',   I_session  => 0, I_niv_msg  => 1,   I_msg_adm  => 'P_INIT_ADHE_CNTRT_MEMBRE: '||P_TAB_T_SOUSCRIPTION.idadhesion,                                   I_idligne  => 2);

  IF P_TAB_T_SOUSCRIPTION.idadhesion > 0 THEN
    -- Si on rattache les membres d un contrat existant à un autre
    FOR rec_membre  IN  c_membres(P_TAB_T_SOUSCRIPTION.idadhesion)  LOOP
      loc_ADHE_CNTRT_MEMBRE:=NULL;
      P_ano:=0;
      SELECT IDADHECNTRTMB.NEXTVAL INTO loc_IDADHECNTRTMB FROM DUAL;
      loc_ADHE_CNTRT_MEMBRE.IDADHECNTRTMB:=loc_IDADHECNTRTMB;
      loc_ADHE_CNTRT_MEMBRE.IDADHESION:=P_new_idadhesion;
      loc_ADHE_CNTRT_MEMBRE.NUMINDIV:=rec_membre.NUMINDIV;
      loc_ADHE_CNTRT_MEMBRE.TYPADR:=rec_membre.TYPADR;

      IF PK_CTRL_AFFIL.F_INSERT_ADHE_CNTRT_MEMBRE(loc_ADHE_CNTRT_MEMBRE) THEN
        P_ano:=0;
      ELSE
        P_ano:=1;
      END IF;
     PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_INIT_ADHE_CNTRT_MEMBRE', I_session  => 0, I_niv_msg  => 1,   I_msg_adm  =>  'P_INIT_ADHE_CNTRT_MEMBRE: '||P_TAB_T_SOUSCRIPTION.idadhesion, I_idligne  => 2);
    END LOOP;

  -- Si c est le rattachement de nouveaux membre suite à la création d'une nouvelle souscription
  ELSE
    j:=0;
    FOR j  IN 1 .. P_TAB_T_BENE.COUNT LOOP
      P_ano:=0;
      SELECT IDADHECNTRTMB.NEXTVAL INTO loc_IDADHECNTRTMB FROM DUAL;
      loc_ADHE_CNTRT_MEMBRE.IDADHECNTRTMB:=loc_IDADHECNTRTMB;
      loc_ADHE_CNTRT_MEMBRE.IDADHESION:=P_new_idadhesion;
      loc_ADHE_CNTRT_MEMBRE.NUMINDIV:=P_TAB_T_BENE(j).NUMBENE;
      loc_ADHE_CNTRT_MEMBRE.TYPADR:=P_TAB_T_BENE(j).TYPBENE;

      IF PK_CTRL_AFFIL.F_INSERT_ADHE_CNTRT_MEMBRE(loc_ADHE_CNTRT_MEMBRE) THEN
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_INIT_ADHE_CNTRT_MEMBRE', I_session  => 0, I_niv_msg  => 1,   I_msg_adm  =>  'insertion ok pour '||P_TAB_T_BENE(j).NUMBENE ||', P_new_idadhesion ' ||P_new_idadhesion ||', TYPBENE' ||P_TAB_T_BENE(j).TYPBENE, I_idligne  => 2);

        P_ano:=0;
      ELSE
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_INIT_ADHE_CNTRT_MEMBRE', I_session  => 0, I_niv_msg  => 1,   I_msg_adm  =>  'Ca pete sur '||P_TAB_T_BENE(j).NUMBENE ||', P_new_idadhesion ' ||P_new_idadhesion ||', TYPBENE' ||P_TAB_T_BENE(j).TYPBENE||', Count' ||  P_TAB_T_BENE.COUNT, I_idligne  => 2);

        P_ano:=1;
      END IF;

    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_INIT_ADHE_CNTRT_MEMBRE', I_session  => 0, I_niv_msg  => 1,   I_msg_adm  =>  'Erreur : Initialisation de ADHE_CNTRT_MEMBRE impossible:: '||sqlerrm, I_idligne  => 2);

  --Erreur : Initialisation de ADHE_CNTRT_MEMBRE impossible:: '||sqlerrm);
END P_INIT_ADHE_CNTRT_MEMBRE;

/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_ADHE_CNTRT_MEMBRE                                  */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet ADHE_CNTRT_MEMBRE   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_ADHE_CNTRT_MEMBRE_DEV( P_souscript                IN      rappel_souscript%rowtype
                                      , P_new_idadhesion      IN      HISTO_ADHESION.IDADHESION%TYPE
                                      , P_ano                       OUT  NUMBER)
IS
  loc_IDADHECNTRTMB          ADHE_CNTRT_MEMBRE.IDADHECNTRTMB%TYPE:=NULL;
  loc_ADHE_CNTRT_MEMBRE      ADHE_CNTRT_MEMBRE%ROWTYPE;
  loc_idadhesion             ADHESION.IDADHESION%TYPE;
  j                          NUMBER:=0;

BEGIN

SELECT IDADHECNTRTMB.NEXTVAL INTO loc_IDADHECNTRTMB FROM DUAL;

MERGE INTO ADHE_CNTRT_MEMBRE adhe
  USING (
    SELECT 1 FROM dual
           ) vv

    ON(  adhe.IDADHESION  = P_new_idadhesion
         AND adhe.NUMINDIV    = P_souscript.numindiv
         AND adhe.TYPADR      = P_souscript.TYPassu
        -- AND adhe.NUMBENE     = P_BENE.numbene
         )
  WHEN NOT MATCHED THEN
    INSERT (IDADHESION,NUMINDIV,TYPADR,NUMBENE,IDADHECNTRTMB)
     VALUES(P_new_idadhesion,
            P_souscript.numindiv,
            P_souscript.TYPassu,
            null,
            loc_IDADHECNTRTMB )
    ;


END P_INIT_ADHE_CNTRT_MEMBRE_DEV;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_ADHESION                                           */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet ADHESION            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_ADHESION( P_TAB_T_SOUSCRIPTION     IN           T_SOUSCRIPTION
                         , P_souscript                 IN           rappel_souscript%rowtype
                         , P_idadhesion             IN           ADHESION.IDADHESION%TYPE
                         , P_numfor_base            IN           ADHESION.NUMFOR%TYPE
                         , P_ADHESION                    OUT     ADHESION%ROWTYPE
                         , P_ano                         OUT     NUMBER)
IS
  loc_IDCOUVERTURE ADHESION.IDCOUVERTURE%TYPE:=NULL;
  loc_rang         ADHESION.RANG%TYPE:=NULL;
  loc_idadhesion  ADHESION.IDADHESION%TYPE:=NULL;
BEGIN
  /*
  -- Recherche d'une adhésion de base croisée avec un rang 1 sur la 1ere adhésion et un rang 2 sur la 2ème
  -- Si une occurence est trouvée alors on mets un rang à 1 sur la nouvelle garantie ajoutée
  SELECT DISTINCT NVL(MAX(a2.rang ),0)
    INTO loc_rang
    FROM adhesion  a1
      , adhesion  a2
  WHERE a1.numfor=a2.numfor
    AND a1.rang=1
    AND a2.rang=2
    AND a1.numgar=a2.numgar
    AND a1.IDADHESION<>a2.IDADHESION
    AND a1.numindiv = a2.numindiv
    AND sysdate BETWEEN a1.datapli AND NVL(a1.datper, sysdate)
    AND sysdate BETWEEN a2.datapli AND NVL(a2.datper, sysdate)
    AND a1.numindiv = P_TAB_T_BENE(i).NUMBENE
    AND a1.numgar= P_TAB_T_BENE(i).CONTRAT
    ORDER BY    A1.IDADHESION DESC,  A2.IDADHESION DESC
     ;
   IF loc_rang > 0 THEN
      loc_rang:=1;
   ELSE*/

   IF P_numfor_base <> 0 THEN   -- Si on est dans le cas d'uen adhésion optionnel BIA 02/07/2018
    --on recherche si le bénéficiaire pour la garantie est couvert aussi en rang 1 sur une autre adhésion "croisée"
    SELECT COUNT(rang)
      INTO loc_rang
      FROM ADHESION
     WHERE numfor=P_numfor_base
       AND P_souscript.NUMINDIV=NUMINDIV
       AND idadhesion <> P_TAB_T_SOUSCRIPTION.idadhesion
       AND rang =1
       AND P_TAB_T_SOUSCRIPTION.DATEEFFET BETWEEN datapli AND NVL(datper, P_TAB_T_SOUSCRIPTION.DATEEFFET);

    --Si une occurence est trouvée alors on mets un rang à 1 sur la nouvelle garantie ajoutée
    IF loc_rang = 1 THEN
       P_ADHESION.RANG := 1;
    ELSE --sinon on prend le rang de l'adhésion de base
      SELECT MAX (rang)
      INTO P_ADHESION.RANG
      FROM ADHESION
      WHERE numfor= P_numfor_base --P_T_BENE.GARANTIES
        AND P_souscript.NUMINDIV=NUMINDIV
        AND idadhesion =P_TAB_T_SOUSCRIPTION.idadhesion
        AND P_TAB_T_SOUSCRIPTION.DATEEFFET BETWEEN datapli AND NVL(datper, P_TAB_T_SOUSCRIPTION.DATEEFFET);
    END IF;
  ELSE
      P_ADHESION.RANG :=P_souscript.rang;     -- Sinon on est dans le cas d'une adhésion de base
  END IF;
     P_ADHESION.RANG := nvl(P_ADHESION.RANG,1);
    SELECT type
      INTO P_ADHESION.TYPFOR
      FROM gar_cntrt
     WHERE numfor=P_souscript.numfor ;

   --END IF;
  /* DBMS_OUTPUT.PUT_LINE('P_TAB_T_BENE(i).CONTRAT: '||P_TAB_T_BENE(i).CONTRAT);
   DBMS_OUTPUT.PUT_LINE('P_TAB_T_BENE(i).NUMBENE: '||P_TAB_T_BENE(i).NUMBENE);
   DBMS_OUTPUT.PUT_LINE('P_TAB_T_BENE(i).GARANTIES: '||P_TAB_T_BENE(i).GARANTIES);
   DBMS_OUTPUT.PUT_LINE('loc_rang: '||loc_rang);
   DBMS_OUTPUT.PUT_LINE('P_numfor: '||P_numfor_base);
   DBMS_OUTPUT.PUT_LINE('P_idadhesion: '||P_idadhesion);
   DBMS_OUTPUT.PUT_LINE('P_TAB_T_SOUSCRIPTION.DATEEFFET: '||d2e(P_TAB_T_SOUSCRIPTION.DATEEFFET));*/
  P_ano:=0;

  IF  NVL(P_idadhesion,0) = 0 THEN
    loc_idadhesion:=P_TAB_T_SOUSCRIPTION.idadhesion;
  ELSE
   loc_idadhesion:= P_idadhesion;
  END IF;
  SELECT IDCOUVERTURE.NEXTVAL INTO loc_IDCOUVERTURE FROM DUAL;
    P_ADHESION.IDCOUVERTURE:=loc_IDCOUVERTURE;
  P_ADHESION.IDADHESION:=loc_idadhesion;
  P_ADHESION.NUMGAR:=P_souscript.numgar;
  P_ADHESION.NUMINDIV:=P_souscript.numindiv;
  P_ADHESION.NUMFOR:=P_souscript.numfor;--TODO multi garantie non gérées !!
  P_ADHESION.DATAPLI:=P_TAB_T_SOUSCRIPTION.DATEEFFET;
  P_ADHESION.DATPER:=NULL;
  --P_ADHESION.RANG:=loc_rang;
  P_ADHESION.ETAT:=1;
  P_ADHESION.FLAG_REGIME:='C';

  P_ADHESION.NUMORG:=1;
  P_ADHESION.DIS_CARENCE:='O';
  P_ADHESION.DIS_FRANCHISE:='O';
  P_ADHESION.NUMUTIL := P_TAB_T_SOUSCRIPTION.NUMUTIL; --F_NUMUTIL;    -- harmonistation des numutils entre hist_oadhesion et adhesion
  P_ADHESION.CREATION:=SYSDATE;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_INIT_ADHESION',   I_session  => SID, I_niv_msg  => 1,  I_msg_adm  => 'Erreur : Initialisation de la couverture impossible: '||sqlerrm,                                   I_idligne  => 2);
END P_INIT_ADHESION;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_LANCE_CALCUL_COTIS                                      */
/* Type         :  Public                                                    */
/* Description  :  Lancement du calcul des cotisations par adhésion          */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_LANCE_CALCUL_COTIS ( P_traitement    IN  VARCHAR2,
                                 P_log           IN  VARCHAR2     DEFAULT 'notest',
                                 P_ADHE_CNTRT    IN  ADHE_CNTRT%ROWTYPE,
                                 P_DateEffet     IN  DATE,
                                 P_ano           OUT NUMBER
                                 )
IS
--
  loc_result               VARCHAR2(100);
  loc_lib_param            VARCHAR2(250);
  loc_nom_fichier_log      VARCHAR2(30);
  loc_ano                  NUMBER:=0;
  loc_numedit              FILE_EDITION.NUMEDIT%TYPE:=NULL;
  loc_numquit              QTTC_GLOBAL.NUMQUIT%TYPE:=NULL;
--
BEGIN

  P_VERIF_COMPTANT(P_ADHE_CNTRT,P_DateEffet,loc_ano, loc_numedit);
  IF loc_ano > 0 THEN
    P_ano:=loc_ano;
  ELSE
    --
    -- Debut du traitement
    --
    loc_nom_fichier_log := 'qg01_proc_log.txt';
    --
    -- Lancement de QG01_proc
    --
    loc_result :='';
    loc_result := QG01_proc(loc_numedit, P_log);
    --
    -- Gestion du message de sortie
    --
    loc_lib_param  := loc_result;
    --
    IF ( loc_lib_param <> '1' ) THEN


      IF ( loc_lib_param = 'anomalie_calcul' ) THEN
        SELECT lib_msg
          INTO loc_lib_param
          FROM mess_erreur
         WHERE code_msg = 1819;
      END IF;
      --

    END IF;
  --
  END IF;


  BEGIN
    SELECT MAX(q.numquit)
      INTO loc_numquit
      FROM QTTC_GLOBAL q
     WHERE q.idadhesion = P_ADHE_CNTRT.idadhesion -- 272120
       AND q.numindiv = P_ADHE_CNTRT.numadhe -- 345651
       AND q.numgar = P_ADHE_CNTRT.numgar --9041
       AND q.COMPTANT = 'C'
       AND P_DateEffet BETWEEN q.debut AND NVL(q.fin, P_DateEffet)   --  AND e2d('01/01/2018') BETWEEN q.debut AND NVL(q.fin, e2d('01/01/2018'))
     ;

     IF NVL(loc_numquit,0) > 0 THEN
       INSERT INTO emission
                 (codope,
                  numfact,
                  numrelance,
                  datemis,
                  type_doc)
          SELECT 4,
                 loc_numquit,
                 0,
                 TRUNC(SYSDATE),
                 1
            FROM DUAL
          WHERE NOT EXISTS (
                      SELECT 1
                        FROM emission
                       WHERE codope = 4
                         and numfact = loc_numquit
                         and numrelance = 0
                         and type_doc = 1);
     END IF;


  EXCEPTION
    WHEN OTHERS THEN
      P_ano:=2288;
  END;




   -- mettre a jour la date de de règlement FACTURE.ECHEANCE
  /* IF TO_CHAR(P_DateEffet,'DD') > 15 THEN
     UPDATE FACTURE SET ECHEANCE = e2d('15/'||TO_CHAR(P_DateEffet,'MM/YYYY'))
      WHERE TRUNC(datfact) = TRUNC(sysdate)
        AND TRUNC(echeance)=TRUNC(P_DateEffet);
   END IF;*/


EXCEPTION
  WHEN OTHERS THEN
    P_ano:=1;
END P_LANCE_CALCUL_COTIS;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_VERIF_COMPTANT                                          */
/* Type         :  Public                                                    */
/* Description  :  Lancement du calcul des cotisations par adhésion          */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_VERIF_COMPTANT(P_ADHE_CNTRT   IN  ADHE_CNTRT%ROWTYPE,
                           P_DateEffet    IN      DATE,
                           P_ano          OUT     NUMBER,
                           P_numedit      OUT     FILE_EDITION.NUMEDIT%TYPE)
IS

   PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR c_param_dmnde(P_numdmnde    IN   PARAM_DMNDE.NUMDMNDE%TYPE)
      IS
  SELECT * FROM param_dmnde
   WHERE numdmnde = P_numdmnde;

  r_param_dmnde           c_param_dmnde%ROWTYPE;
  loc_numdmnde            VARCHAR2(25):=NULL;
  loc_numedit             VARCHAR2(25):=NULL;
  loc_numbatch            VARCHAR2(25):=NULL;
--  loc_ADHE_CNTRT          ADHE_CNTRT%ROWTYPE;
--
   loc_fin                DATE;
   loc_debut              DATE;
   loc_anniv              DATE;
   loc_fract              NUMBER;
   loc_delai              NUMBER;
   loc_date_delai         DATE;
   loc_mregl              NUMBER;

   exc_echeance_inval    EXCEPTION;
--
BEGIN
  -- Insertion dans param_dmnde
  SELECT numdmnde.nextval
    INTO loc_numdmnde
    FROM dual;
   -- loc_numdmnde:=numdmnde.nextval;

  INSERT INTO PARAM_DMNDE(numdmnde) VALUES(loc_numdmnde);
  COMMIT;

  -- Récupération des dates de la procédure calc_echeance
 /* BEGIN
    -- loc_ADHE_CNTRT:= P_ADHE_CNTRT;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('loc_ADHE_CNTRT KO,' );
  END;*/


  loc_fract := P_ADHE_CNTRT.fract;
  loc_debut := P_DateEffet;
  loc_fin   := P_DateEffet + 1;
  loc_anniv := P_ADHE_CNTRT.eche_anniv;
  loc_mregl := P_ADHE_CNTRT.mregl;
  --
  FOR r_param_dmnde IN c_param_dmnde(loc_numdmnde) LOOP


    IF ( r_param_dmnde.valdeb1 IS NULL AND loc_debut IS NOT NULL) THEN
      UPDATE param_dmnde
         SET valdeb1 = to_char(loc_debut, 'dd/mm/yyyy')
       WHERE numdmnde = loc_numdmnde;
    END IF;
    --
     IF ( r_param_dmnde.valfin1 IS NULL AND loc_fin IS NOT NULL) THEN
      WHILE (MOD(MONTHS_BETWEEN(loc_fin, loc_anniv), loc_fract) != 0)
      LOOP
        loc_fin := loc_fin + 1;
        IF (loc_fin > ADD_MONTHS(loc_debut, loc_fract)) THEN
          P_ano:=235;
          RAISE exc_echeance_inval;
        END IF;
      END LOOP;
      loc_fin := loc_fin - 1;
      --
      UPDATE param_dmnde
         SET valfin1 = to_char(loc_fin, 'dd/mm/yyyy')
       WHERE numdmnde = loc_numdmnde;


    END IF;
    --
     IF ( r_param_dmnde.valfin10 IS NULL) THEN
      --
       --loc_date_delai := f_eche_regl( loc_mregl, loc_debut, p_adhe_cntrt.delai ); RKO IMPACT SEPA B2B
      loc_date_delai := f_eche_regl( loc_mregl, P_ADHE_CNTRT.numgar, P_ADHE_CNTRT.idadhesion, loc_debut, loc_fin );
      --
      IF (loc_date_delai IS NOT NULL) THEN
        UPDATE param_dmnde
          SET valfin10 = to_char(loc_date_delai, 'dd/mm/yyyy')
        WHERE numdmnde = loc_numdmnde;
      END IF;
      --
    END IF;
    -- si pas de contrat => update avec numgar
    IF ( r_param_dmnde.valdeb7 IS NULL AND P_ADHE_CNTRT.numgar IS NOT NULL) THEN
      UPDATE param_dmnde
         SET valdeb7 = P_ADHE_CNTRT.numgar
       WHERE numdmnde = loc_numdmnde;
    END IF;

    --
    IF ( r_param_dmnde.valdeb6 IS NULL AND P_ADHE_CNTRT.numadhe IS NOT NULL) THEN
      UPDATE param_dmnde
         SET valdeb6 = P_ADHE_CNTRT.numadhe
       WHERE numdmnde = loc_numdmnde;
    END IF;
    --
    IF ( r_param_dmnde.valdeb10 IS NULL AND loc_mregl IS NOT NULL) THEN
      UPDATE param_dmnde
         SET valdeb10 = loc_mregl
       WHERE numdmnde = loc_numdmnde;
    END IF;
    --
    IF ( r_param_dmnde.valdeb9 IS NULL AND P_ADHE_CNTRT.idadhesion IS NOT NULL) THEN
      UPDATE param_dmnde
         SET valdeb9 = P_ADHE_CNTRT.idadhesion
       WHERE numdmnde = loc_numdmnde;
    END IF;
    --
  END LOOP;
--
  -- Insertion dans file_batch
   SELECT numedit.nextval
    INTO loc_numbatch
    FROM dual;


    INSERT INTO FILE_BATCH ( batchid, priorite, seqid, ordre, numbatch
                           , date_demande, date_execute, status, periodique, execute, userid)
      SELECT batchid, priorite, seqid, ordre,loc_numbatch, sysdate, sysdate, 3, 9,4,100
        FROM typ_batch
       WHERE typ_batch.batchid = 'QG02T';

 -- Insertion dans file_edition

  SELECT numedit.nextval
    INTO loc_numedit
    FROM dual;

  INSERT INTO file_edition (
         numedit, numbatch, numdmnde, editid,
         batchid, userid, date_demande, date_execute, nb_ex, status,
         EXECUTE, impid, papid, nb_ligne
         )
  SELECT loc_numedit, loc_numbatch, loc_numdmnde, 'QG01B',
             'QG02T', user, SYSDATE, SYSDATE, 1, 3,
             '*', 'ECRAN', 'A4_LASER', 1
   FROM dual;
   P_numedit:=  loc_numedit;

   COMMIT;
EXCEPTION
  WHEN exc_echeance_inval THEN
    P_ano:=235;
  WHEN OTHERS THEN
  null;
END P_VERIF_COMPTANT;

/*****************************************************************************************************/

FUNCTION F_VALIDE_MAJ_INFO_PERSO(i_idrappel number ,i_numporte number) RETURN NUMBER
IS
  loc_rappel  rappel%rowtype;
  l_is_edited number := 0;
  l_is_presta_calc number := 0;
  l_type_demande_ss number :=0;
  ayant_droit_impact NUMBER := 0; --permet de savoir si des ayant droit sont impacté par une modification de RGIME caisse ou centre
  ayant_droit_impact_commentaire VARCHAR2(500) := NULL;
  V_IDHISTORAPPEL  rappel.idrappel%type;
  l_liste_adhesion_fermee VARCHAR2(500);
  l_Nom individu.nom%type;
  l_Prenom individu.prenom%type;
  l_DATENAISS  date;
  l_rangNaiss  individu.rang%type;
  l_Caisse      individu.caisse%type;
  l_Regime     individu.regime%type;
  l_Centre     individu.GUICHETORG%type;
  l_statement  VARCHAR2(1000);
  l_separateur VARCHAR2(1);

  --sauvegarde
  s_Nom individu.nom%type;
  s_Prenom individu.prenom%type;
  s_DATENAISS  date;
  s_rangNaiss  individu.rang%type;
  s_Caisse      individu.caisse%type;
  s_Regime     individu.regime%type;
  s_Centre     individu.GUICHETORG%type;
  s_statement  VARCHAR2(1000);
  s_separateur VARCHAR2(1);
  l_num_to_modif NUMBER(1);
  l_individu individu%rowtype;
  l_err_numss NUMBER(5);
  l_numassu individu.numindiv%type;
  CURSOR C_indv (p_numindiv IN NUMBER) is
  SELECT i.numindiv
  FROM individu i, individu a
  WHERE i.matorg = a.matorg
  AND a.numindiv = p_numindiv;

  CURSOR C_adhe (p_numindiv IN Number)  IS
  SELECT adhesion.idadhesion,
              adhesion.numgar,
              porte_contrat.numporte,
              adhesion.numfor,
              adhesion.datper                                               -- Ajout le 20100212 M00003055
       FROM   adhesion,
              porte_contrat, porte_param
       WHERE  f_numgar_ref(adhesion.numgar) = porte_contrat.numgar
       AND    adhesion.numindiv = p_numindiv
       AND    porte_contrat.numporte != 1
       AND    nvl (adhesion.datper, sysdate) >= sysdate
       AND    SYSDATE between adhesion.datapli and nvl (adhesion.datper,SYSDATE)
       AND    adhesion.etat =1
       AND    porte_contrat.numporte = porte_param.numporte
       AND    nat_porte in (3,5) --ABO ajout du filtre pour ne pas déclancher sur les autres portes
       order by nvl(adhesion.datper, sysdate);

 CURSOR c_ayant_droit_impact(i_numouvreur IN NUMBER, i_regime IN NUMBER, i_caisse IN NUMBER, i_centre IN NUMBER)
   IS
    SELECT ayantdroit.numindiv FROM individu  ayantdroit, individu ouvreurdroit
    WHERE
        ouvreurdroit.numindiv = i_numouvreur
    AND ayantdroit.matorg = ouvreurdroit.matorg
    AND
    ( i_Centre IS NOT NULL -- contraintes mises dans la requete directement pour dégager les if.
      OR i_Caisse IS NOT NULL
      OR i_Regime IS NOT NULL
      )
      ;
BEGIN
  SELECT * into loc_rappel FROM rappel
  WHERE idrappel = i_idrappel;

  SELECT * into l_individu FROM individu
  WHERE numindiv = loc_rappel.numbene;



  l_Nom := F_GET_VALUE_IN_TABLE('Nom', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)) ;
  l_Prenom := F_GET_VALUE_IN_TABLE('Prénom', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_DATENAISS := e2d(F_GET_VALUE_IN_TABLE('Date de naissance', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)));
  l_rangNaiss := F_GET_VALUE_IN_TABLE('Rang de naissance', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_Regime  := F_GET_VALUE_IN_TABLE('Regime SS', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_Caisse  := F_GET_VALUE_IN_TABLE('Caisse', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_Centre  := F_GET_VALUE_IN_TABLE('Centre', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
  l_num_to_modif:= F_GET_VALUE_IN_TABLE('Numéro SS concerné', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));



  IF l_Regime IS NOT NULL THEN
    l_err_numss :=   IS_REGIME_CAISSE_OK (l_Regime, l_Caisse, null, null) ;

    IF l_err_numss > 0 THEN
           return l_err_numss;
    END IF;
  END IF;


  l_separateur :=',';
  IF l_Nom IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' nom = '''||UPPER(l_Nom)||'''';
  END IF;
  IF l_Prenom IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' prenom = '''||UPPER(l_Prenom)||'''';
  END IF;
  IF l_DATENAISS IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' datnais = e2d('''||d2e(l_DATENAISS)||'''), datnais_regime ='''||to_char(l_DATENAISS,'ddmmyy')||'''';
  END IF;
  IF l_rangNaiss IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' rang = '''||l_rangNaiss||'''';
  END IF;
  /*IF l_Regime IS NOT NULL THEN
   l_statement :=  l_statement || l_separateur ||' regime = '''||l_Regime||'''';
  END IF;
  IF l_Caisse IS NOT NULL THEN
   l_statement := l_statement || l_separateur ||' caisse = '''||l_Caisse||'''';
  END IF;
  IF l_Centre IS NOT NULL THEN
  l_statement := l_statement || l_separateur ||' GUICHETORG = '''||l_Centre||'''';
  END IF;*/
  IF (l_num_to_modif IN (1,2) AND (l_Regime IS NOT NULL OR  l_Caisse IS NOT NULL OR l_Centre IS NOT NULL)) THEN
      IF l_num_to_modif NOT IN(1,2) THEN  -- blocage de l'intégration automatique tant que IPSO n'a pas valoriser num_to_modif
        return 2241;
      END IF;
      IF  l_num_to_modif = 1 THEN       --  1er NUMÉRO CONCERNÉ
      -- est ce un ayant doit?      nature !=1
        IF l_individu.natur = 2 THEN  -- oui => il devient ouvreur de droit + supprimer son deuxieme numss  ???
             return 2240;              -- pas assez d'information pour passage OD.
        ELSE -- non => l'ouvreur modification du numéro de sécurité sociale et copie des modifications sur ces ayants droits.    (where nature =2)
          l_numassu := f_numassu(l_individu.numindiv) ;
          UPDATE INDIVIDU   -- modification des ayant droit qui avaient le même premier numero de sécurité sociale
          SET   --  MATORG = l_ss_ajoute
                --, cless  = l_cle_ajoute
                 regime = l_regime
                , caisse =  nvl(l_caisse,caisse)
                , GUICHETORG= l_centre
          WHERE  MATORG = l_individu.matorg
          AND numassu = l_numassu
          AND NATUR = 2;
          --
          UPDATE INDIVIDU  -- modification des ayant droit qui avaient le même deuxième numero de sécurité sociale
          SET   --  MATORG2 = l_ss
                --, cless2  = l_cle
                  regime2 = l_regime
                , caisse2 =  nvl(l_caisse,caisse2)
                , GUICHETORG2= l_centre
          WHERE  MATORG2 = l_individu.matorg
          AND numassu = l_numassu
          AND NATUR = 2;
          --
          UPDATE individu     -- modification de  l'ouvreur de droit s'il est conjoint et qu'il était sur le même ss il faut conserver cet upd séparémment
          SET    -- MATORG = l_ss_ajoute
               -- , cless  = l_cle_ajoute
                 regime = l_regime
                , caisse =  l_caisse
                , GUICHETORG= l_centre
          WHERE numindiv = l_individu.numindiv;
      END IF;

    ELSIF  l_num_to_modif = 2 THEN   --  DEUXIEME NUMÉRO CONCERNÉ
    -- est ce un ayant doit?      nature !=1
      IF l_individu.natur = 2 THEN        -- oui => modification de son nummss2
        UPDATE INDIVIDU  -- modification des ayants droit qui avaient le même deuxième numero de sécurité sociale
        SET   --  MATORG2 = l_ss_ajoute
             -- , cless2  = l_cle_ajoute
                regime2 = l_regime
              , caisse2 =  nvl(l_caisse,caisse2)
              , GUICHETORG2= l_centre
        WHERE  numindiv = l_individu.numindiv
        AND NATUR = 2;
      ELSE  -- non => Pas possible, on ne peut pas enregistrer un seconds numéross sur un ouvreur de droit)
        return 2239;
      END IF;
    END IF;

  END IF;

 /*PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_WEB_MAJ.MAJ_INFO_PERSO',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(l_statement,2),
              I_idligne  => 2);*/
  SELECT nom, prenom,datnais,rang,regime,caisse,GUICHETORG
  into s_nom,s_prenom, s_datenaiss,s_rangnaiss,s_regime,s_caisse , s_centre
  FROM individu
  WHERE numindiv = loc_rappel.numbene;

 EXECUTE IMMEDIATE 'UPDATE INDIVIDU SET '||substr(l_statement,2)|| ' WHERE NUMINDIV = '|| loc_rappel.numbene;


    /*mantisse 5354 Si le regime la caisse ou le centre sont modifiés alors les ayant-droit se voient applicatquer la même modification*/
    BEGIN
      FOR R_ayant_droit IN c_ayant_droit_impact(loc_rappel.numbene , l_regime, l_caisse, l_centre ) LOOP
         ayant_droit_impact_commentaire := COALESCE(ayant_droit_impact_commentaire,CHR(10)||CHR(13)||'Modification des ayants droit : ') ||CHR(10)||CHR(13)||R_ayant_droit.numindiv;
        UPDATE individu SET
            caisse = COALESCE(l_caisse, caisse),
            regime = COALESCE(l_regime, regime),
            GUICHETORG = COALESCE(l_centre, GUICHETORG)
        WHERE numindiv = R_ayant_droit.numindiv;
      END LOOP;
    END;

  --  Génère une nouvelle carte de tiers payant pour le bénéficiaire si le nom, prénom, date ou rang de naissance sont modifiés
  IF l_Nom IS NOT NULL OR l_Prenom IS NOT NULL OR l_DATENAISS IS NOT NULL OR l_rangNaiss IS NOT NULL THEN
    FOR R_numindiv IN  C_indv(loc_rappel.numbene) LOOP
      FOR R_adhe  IN   C_adhe(R_numindiv.numindiv)LOOP
          pk_porte.P_INS_demande_tp (
                  I_numporte => R_adhe.numporte,
                  I_idadhesion => R_adhe.idadhesion,
                  I_numgar     => R_adhe.numgar,
                  I_numindiv   => R_numindiv.numindiv,
                  I_debut      => SYSDATE,--a valider par GEREP
                  I_fin        => R_adhe.datper,
                  I_type       => 16,
                  I_numfor     => R_adhe.numfor
                );
      END LOOP;
    END LOOP;
  END IF;

  --SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
  SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
  INSERT INTO HISTO_RAPPEL (IDRAPPEL,         ---RKO  M0005772
							IDHISTORAPPEL,
							CONTEXTE,
							ENTITE,
							TYPE,
							REFERENCE,
							REVISION,
							CREATION,
							CREATEUR,
							MAJ,
							MODIFICATEUR,
							ETAT,
							RESPONSABLE,
							COMMENTAIRE)
			VALUES ( loc_rappel.IDRAPPEL,
                                  V_IDHISTORAPPEL,
                                  loc_rappel.CONTEXTE,
                                  loc_rappel.ENTITE,
                                  loc_rappel.TYPE,
                                  loc_rappel.REFERENCE,
                                  loc_rappel.REVISION,
                                  loc_rappel.CREATION,
                                  loc_rappel.CREATEUR,
                                  sysdate,
                                  F_numutil,
                                  6/*loc_rappel.ETAT*/,
                                  loc_rappel.RESPONSABLE,
                                  'Informations de l''individu avant modification :'||chr(10)||chr(13)||'nom: '||s_nom||chr(10)||chr(13)||'prenom: '||s_prenom||chr(10)||chr(13)||'datnaiss: '||s_datenaiss||chr(10)||chr(13)||'rang: '||s_rangnaiss||chr(10)||chr(13)||'regime: '||s_regime||chr(10)||chr(13)||'caisse: '|| s_caisse||chr(10)||chr(13)||'centre: '|| s_centre||ayant_droit_impact_commentaire);
   SET_RAPPEL_ERREUR(  loc_rappel.IDRAPPEL,  loc_rappel.code_err, 6);

  commit;

return 0;
 END F_VALIDE_MAj_INFO_PERSO ;
 /*********************************************************/
FUNCTION F_VALIDE_PEC_HOSPI(i_idrappel number ,i_numporte number) RETURN NUMBER
IS
 loc_rappel rappel%rowtype;
 l_num_indiv_tiers Tiers.numindiv%TYPE ;
 const_num_tier_fantome tiers.numindiv%TYPE;
 l_prise_en_charge PRICHARGE%rowtype;
 l_is_edited NUMBER(1);
BEGIN

  SELECT * into loc_rappel from rappel
  WHERE idrappel = i_idrappel;

  SELECT * into l_prise_en_charge FROM PRCH   -- récupération de l'objet PC a valider
  WHERE numpc= loc_rappel.entite;

  -- récuperation du numéro du tiers FANTOME
  SELECT max(numindiv), max(numindiv)
  into const_num_tier_fantome, l_num_indiv_tiers
  from tiers
  where tiers.REFCIE = 'PRESTA FANTOME EXTRANET';
  -- 1 - PS non fantôme

  IF l_prise_en_charge.numtiers = const_num_tier_fantome THEN
    RETURN 2235; --Le tiers en question n'est pas correct
  END IF;
  --  2 - au moins une édition de pec effectuée

  BEGIN
      SELECT DISTINCT 1  INTO  l_is_edited
      FROM FILE_EDITION f, PARAM_DMNDE p
      WHERE f.BATCHID = 'PC02T'
      AND f.STATUS = 2
      AND f.EXECUTE = '*'
      AND p.valdeb1 = to_char(l_prise_en_charge.numpc)
      AND f.numdmnde = p.numdmnde;
  EXCEPTION  WHEN OTHERS THEN
    RETURN 2236; --Aucune édition n'a été touvée pour cette prise en charge.
  END;
 RETURN 0;

END F_VALIDE_PEC_HOSPI;

/**
 * Fonction qui annule un dossier santé en le fermant, supprimant les sinistres  et les annulant
 */
PROCEDURE P_FERMER_DOSSIER_SANTE(i_num_dossier IN number , o_code_err IN OUT number)
IS
  loc_dossier_liquidation NUMBER ;
BEGIN
  BEGIN
  SELECT 1 INTO loc_dossier_liquidation
  FROM dossier_sante
  WHERE num_dossier =  TO_CHAR(i_num_dossier)
  AND   TYPE_DOSS NOT IN (1); -- on évite d'annuler un dossier de liquidation afin de ne pas supprimer par inadvertance des sinistres décompté 25/06/2016 CLI
  EXCEPTION WHEN OTHERS THEN
    o_code_err :=1;
    RETURN ;
  END;

  DELETE sinistre
    WHERE numsin IN (
        SELECT sd.NUMSIN_SNTR
        FROM SNTR_DOSSIER sd
        WHERE sd.NUM_DOSSIER = TO_CHAR(i_num_dossier)
        );

	DELETE sntr_ref
    WHERE numsin IN (
      SELECT sd.NUMSIN_SNTR
      FROM SNTR_DOSSIER sd
      WHERE sd.NUM_DOSSIER = TO_CHAR(i_num_dossier)
      );

  UPDATE sinistre_sante
  SET situation = 4
  WHERE num_dossier = TO_CHAR(i_num_dossier);

  UPDATE DOSSIER_SANTE
  SET dateferm = sysdate
  WHERE num_dossier =  TO_CHAR(i_num_dossier);

  INSERT INTO HISTO_DOSSIER ( num_dossier, debut, datsai, etat, motif, numutil) values
								(i_num_dossier, sysdate,sysdate,1,0,F_NUMUTIL);
  Commit;
END P_FERMER_DOSSIER_SANTE;


/***************************************************************************************/

PROCEDURE P_INVAL_SOUSCRIPTION (i_idrappel rappel.idrappel%type, o_erreur OUT NUMBER)
IS

  loc_rappel rappel%rowtype;
  exc_adhesion_incompatible EXCEPTION;

  CURSOR c_adhesion(i_idrappel IN rappel.idrappel%type, i_idadhesion IN adhesion.idadhesion%TYPE) IS  --listes les adhesions bases et options qui portent le meme idrappel
    select distinct id_adhesion idadhesion , idrappel
    from rappel_souscript ,adhe_cntrt ac
    WHERE rappel_souscript.idrappel = i_idrappel
    AND ac.idadhesion = rappel_souscript.id_adhesion
    AND F_ETAT_ADHE(ac.idadhesion , greatest (ac.date_adhe,sysdate) ) = 0 --instance
    AND F_ETAT_ADHE(ac.idadhesion , greatest (ac.date_adhe,sysdate) , 2 ) in (59,60)
    UNION
    SELECT distinct entite idadhesion , idrappel
    FROM rappel
    WHERE type in(20,27)
    AND ETAT in(1,3) --on supprime aussi les adhesions options provenant des demandes de soucript. option qui sont à l'état nouveau et traité suite à la validation RH  (flux de validation souscription RH)
    AND to_number(F_GET_VALUE_IN_TABLE('Idadhesion_base', f_get_varchar_splited(';'||chr(10)||chr(13), commentaire))) =i_idadhesion
    AND numbene = loc_rappel.numbene -- la souscription optionnelle doit concernée le même adhérent principal
    ;

BEGIN
  SELECT *
  INTO loc_rappel
  FROM RAPPEL
  WHERE idrappel = i_idrappel;
  -- Type = 20 adhesion optionnelles non obligatoire souscrite depuis l'espace assuré,
  -- Type = 26 BASE espace préaff + opt obligatoire,
  -- Type = 27: option espace Préaff
  -- l'invalidation d'une base invalide également les options obligatoires portées par le rappel de la base et les options dans des rappels distincts
  -- lors de l'invalidation d'une option, on ne touche pas à la base
  IF loc_rappel.contexte = 13 and loc_rappel.entite is not null and loc_rappel.type in(20,26,27) THEN
    BEGIN
      FOR rec_adh IN c_adhesion (i_idrappel, loc_rappel.entite) LOOP
        DELETE adhe_cntrt
        WHERE idadhesion = rec_adh.idadhesion;
        DELETE adhesion
        WHERE idadhesion = rec_adh.idadhesion;
        --on réalise la mise à jour des rappels d’option que lors de l’invalidation d’une base
        IF loc_rappel.type =26 THEN
          UPDATE RAPPEL SET COMMENTAIRE = 'Mise à jour : Rejetté par utilisateur '||f_numutil||' le '||d2e(sysdate)||';'||chr(10)||chr(13)||COMMENTAIRE
                           , etat = 5
          WHERE idrappel =rec_adh.idrappel
          AND ETAT in(1,3) --on met à jour les demandes de soucript option qui sont à l'état nouveau et traité
          AND TYPE IN (20,27);
        END IF;
      END LOOP;
      COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
          PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_INVAL_SOUSCRIPTION',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'Anomalie détectée lors de la suppression des adhesions rappel'||loc_rappel.idrappel,
                                 I_idligne  => 2);
      o_erreur :=-1;
      RETURN;
    END;
  END IF;
  o_erreur :=0;
EXCEPTION
  WHEN OTHERS THEN
    o_erreur :=-1;
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_INVAL_SOUSCRIPTION',
                           I_session  => SID,
                           I_niv_msg  => 1,
                           I_msg_adm  => 'idrappel '||i_idrappel||' '||substr(sqlerrm,1,100),
                           I_idligne  => 2);
    RETURN ;

END P_INVAL_SOUSCRIPTION;


/***********************************************************/

procedure P_CREER_COLLECTION_DOCUSHARE(i_numindiv number,i_societe number)
 is
  req utl_http.req;
  res utl_http.resp;
  url varchar2(4000);-- := --'http://192.168.18.5:8084/api/ws-gestion-adherents/createOrUpdateAdherent';
                       -- 'http://192.168.18.5:8084/ws-gestion-adherents/api/gestion-adherents/createOrUpdateAdherent';
  name varchar2(4000);
  buffer varchar2(4000);

  parametres  varchar2(4000);

  curr_time  number;

begin

    utl_http.set_transfer_timeout(100); -- M0007233
    SELECT DOMAINE_EDITION
    INTO URL
    FROM param_machine
    WHERE id_machine = 'WS_GED';

-- paramétre a passer a la suite de l'url

    select     '?nom='||nom
        ||'&'||'prenom='||prenom
        ||'&'||'numSecu='||matorg
        ||'&'||'societe='||trim(f_nom(i_societe))
        ||'&'||'dateNaissance='||to_char(datnais,'DD/MM/YYYY')
        ||'&'||'idArthus='||i_numindiv
    into PARAMETRES
    FROM INDIVIDU
    WHERE NUMINDIV = i_numindiv;


  curr_time := dbms_utility.get_time;

  req := utl_http.begin_request(utl_url.escape(url=>url||parametres,url_charset => 'UTF-8'), 'POST',' HTTP/1.1');
  res := utl_http.get_response(req);

  begin
    loop
      utl_http.read_line(res, buffer);
      If buffer like '%OK (adherent-%)' then

        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'WS_DOCUSHARE_COLLECTION',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Temps='|| (( dbms_utility.get_time - curr_time ) / 100 )
                                             ||' Collection créee pour individu '||i_numindiv ||' '||buffer,
                               I_idligne  => 2);
         utl_http.end_response(res);
                               return;
      ELSE
         PK_trace.P_INS_journal_adm ( I_nom_traitement => 'WS_DOCUSHARE_COLLECTION',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Temps='|| (( dbms_utility.get_time - curr_time ) / 100 )
                                             ||' KO Réponse pour individu '||i_numindiv ||' '||buffer,
                               I_idligne  => 2);
      END IF;

       end loop;
    utl_http.end_response(res);
  exception
    when utl_http.end_of_body
    then
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'WS_DOCUSHARE_COLLECTION',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Temps='|| (( dbms_utility.get_time - curr_time ) / 100 )
                                             ||' KO Réponse pour individu '||i_numindiv ||' '||SQLERRM,
                               I_idligne  => 2);
      utl_http.end_response(res);
  end;

  EXCEPTION WHEN OTHERS THEN
            BEGIN

                utl_http.end_response(res);
                EXCEPTION WHEN OTHERS THEN NULL;
            END;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'WS_DOCUSHARE_COLLECTION',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Temps='|| (( dbms_utility.get_time - curr_time ) / 100 )
                                             ||' KO Collection non créee pour individu '||i_numindiv ,
                               I_idligne  => 2);

  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'WS_DOCUSHARE_COLLECTION',
   I_session  => SID,
   I_niv_msg  => 1,
   I_msg_adm  => SQLERRM,
   I_idligne  => 2);


end P_creer_collection_docushare;

/************************************/

   FUNCTION  F_CTRL_QUERABLE
              ( iv_numindiv  IN  VARCHAR2,
              i_date IN DATE
              ) RETURN  number
    IS
    count_rib     number := 0  ;
    BEGIN
    select count(1) into count_rib
    from RIB
    where numindiv =  iv_numindiv
    and type = 2 and modpmt = 2 --and nature = 2
    and pk_sepa.f_rib_iban(idrib) = 1
    --and fin is null                                                                              -- MUR : supp le 23/02/2015
    and idrib = pk_treso.f_idrib (iv_numindiv, 2, null, null, i_date, null, pk_devise.devise_ref) -- MUR : ajout le 23/02/2015
    ;

    RETURN  count_rib;

  EXCEPTION
    WHEN OTHERS THEN RETURN  count_rib;
  END f_ctrl_querable;


  /****************************/
  -- retourne 1 si aucune demande de souscription de base
  FUNCTION F_IS_HORS_BIA(i_numassu IN NUMBER) return number
  IS
   l_adhesion_bia number;
  BEGIN
   -- demande de souscription de base
    SELECT count(distinct 1)
    INTO l_adhesion_bia
    FROM  rappel
    WHERE type =  26
    and numassu = i_numassu
    AND trunc(creation) = trunc(sysdate);

    IF l_adhesion_bia = 1 THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;

  END F_IS_HORS_BIA;

  /****************************************************************************/

  FUNCTION ADD_SIN_PREV(i_numporte       IN NUMBER,
                       i_id_type         IN TYPE_FLUX.ID_TYPE%TYPE,
                       i_idDemande_ext   IN NUMBER,
                       i_params          IN EXTR_Q_ADD_SIN_PREV,
                       i_Salaires        IN EXTR_TAB_SALAIRES,
                       i_DocSalaire      IN EXT_TAB_DOCUMENT,
                       i_Documents       IN EXTR_TAB_DOCSINPREV,--EXT_TAB_DOCUMENT,
                       i_Maintien        IN EXTR_TAB_MAINTIEN) RETURN EXTR_TAB_ADD_SIN_PREV
  IS

  loc_tab_add_sin_prev  EXTR_TAB_ADD_SIN_PREV;
  loc_res               GENERIQUE_WS_RESP;
  loc_tab_doc           EXT_TAB_DOCUMENT;

  l_code_demande    NUMBER;
  l_context_rappel  NUMBER;
  loc_numutil       utilisateurs.numutil%TYPE;
  loc_rappel        rappel%ROWTYPE;
  loc_maintien      RAPPEL_SIN_PREV_MAINT%ROWTYPE;
  loc_rap_sin_prev  RAPPEL_SIN_PREV%ROWTYPE;
  loc_salaire       RAPPEL_SIN_PREV_SAL%ROWTYPE;
  i                 NUMBER;
  loc_doublon       NUMBER;
  loc_responsable   NUMBER;   -- gestionnaire responsable du contrat -- PBO M0006543

  exc_param          EXCEPTION;
  exc_ctrl_fonc      EXCEPTION;
  nat_introuv        EXCEPTION;
  exc_crea_nosin     EXCEPTION;
  loc_etat          NUMBER(3);
  loc_cause         NUMBER(3);
  loc_regle         VARCHAR2(250);
  loc_idformule     FRML_PREST.IDFORMULE%TYPE;
  loc_numfor        FRML_PREST.NUMFOR%TYPE;
  loc_maternite     NUMBER;
  loc_hospi         NUMBER;
  loc_nbenf         NUMBER;
  loc_maint         NUMBER;
  loc_prestij       NUMBER;
  is_mensu          NUMBER;
  loc_numdossier    dossier_sinistre.iddossier%TYPE;
  o_numsin          SNTR_PREV.NOSIN%TYPE;
  loc_gest          dossier_sinistre.numutil%TYPE;
  loc_contrat       contrat_ref.numgar%TYPE;
  loc_adhesion      adhesion.idadhesion%TYPE;
  loc_piece         pieces%ROWTYPE;
  loc_lib           VARCHAR2(100);
  loc_survenance    DATE;
  loc_entite        NUMBER;
  loc_interloc      interlocuteur.interlocuteur%TYPE;
  loc_IDCOUVERTURE  adhesion.IDCOUVERTURE%TYPE;
  loc_type_piece    libelle.code%TYPE;
  loc_gar_regl      gar.numfor%TYPE;
  loc_numorgmin     NUMBER(3) ;
  loc_numorg        NUMBER(3) ;
  loc_reg           VARCHAR2(2) ;
  loc_rang          NUMBER(1);
  loc_flag_reg      VARCHAR2(1) ;
  loc_typfor        NUMBER(2);



   CURSOR c_adhesion ( p_numindiv individu.numindiv%type , p_porte porte_contrat.numporte%TYPE, p_date DATE, p_numcli contrat_ref.numcli%TYPE) IS
   SELECT distinct a.idadhesion ,
                    a.numgar,
                    ad.mregl,
                    cr.college ,
                    cr.refcie ,
                    ad.date_adhe,
                    cr.numutil   -- gestionnaire responsable du contrat prévoyance-- PBO M0006543
    FROM adhesion a, adhe_cntrt ad, contrat cr,porte_contrat p
    WHERE a.idadhesion = ad.idadhesion
      AND numindiv = p_numindiv
      AND cr.numgar = a.numgar
      AND p.numgar = cr.numgar
      AND cr.numcli = p_numcli
      AND p.numporte = p_porte
      AND a.datapli <> NVL(a.datper,e2d('01/01/1900'))
      AND p_date BETWEEN a.datapli AND NVL(a.datper,p_date)
      AND a.typfor = 2
      AND NOT EXISTS(SELECT numde FROM dependance
                    WHERE numde=a.numgar AND role =6 AND sysdate BETWEEN datapli AND NVL(datper,sysdate)) --on privilegie le contrat mensu
      ORDER BY ad.date_adhe desc,a.idadhesion desc;

  BEGIN
    loc_tab_add_sin_prev  := new EXTR_TAB_ADD_SIN_PREV(null);
    loc_res               := new GENERIQUE_WS_RESP(null,null,null,null,null,null,null,null) ;
    loc_tab_doc           := NEW    EXT_TAB_DOCUMENT(null);



    l_code_demande := get_code_demande(i_id_type,i_numporte);

    -- creation de la demande dans la table rappel
    -- Récuperation du  code rappel
    SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
    BEGIN
      SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
    EXCEPTION
      WHEN OTHERS THEN loc_numutil:=f_numutil;
    END;

    loc_etat:=NULL;
     --Contrôles des paramètres entrants
    IF i_params.numcli IS NULL OR i_params.numindiv IS NULL OR i_params.survenance IS NULL
      OR i_params.modCtrl IS NULL OR i_params.nature IS NULL THEN
      loc_rappel.code_err:= 2385;--declaration incomplète
      loc_etat := 1;
      loc_rappel.etat:=4;--rejeté
      RAISE exc_param; --reponse KO
    END IF;

    IF NVL(i_params.accident_prive,'N') NOT IN ('O','N') OR NVL(i_params.hospitalisation,'N') NOT IN ('O','N') THEN
      loc_rappel.code_err := 2397;--donnée incohérente
      loc_etat := 1;
      loc_rappel.etat := 4;--rejeté
      RAISE exc_param; --reponse KO
    END IF;


    --contrôles fonctionnels
    --contrôle que la même demande n'a pas déjà été déposée dans la corbeille
    SELECT count(r.idrappel) INTO loc_doublon
    FROM RAPPEL r, RAPPEL_SIN_PREV s
    WHERE r.idrappel = s.idrappel
    AND   s.survenance = i_params.survenance
    AND   s.numindiv = i_params.numindiv
    AND   r.etat <> 4; --non rejeté

    IF loc_doublon >0 THEN
      loc_rappel.code_err:= 2386;
      loc_etat := 2;
      loc_rappel.etat:=4;--rejeté
      RAISE exc_ctrl_fonc;
    END IF;

    --recherche d'un interlocuteur type utilisateur prevoyance sur la société
    IF i_params.interloc IS NULL THEN
      BEGIN
        SELECT interlocuteur into loc_interloc
        FROM  interlocuteur
        WHERE numindiv = i_params.numcli
        AND f_coordonne_contact(interlocuteur,4,1) IS NOT NULL
        AND valide='O'
        AND ope_crrr=9
        AND ROWNUM <= 1;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          loc_rappel.code_err:= 2385;--declaration incomplète
          loc_etat := 1;
          loc_rappel.etat:=4;--rejeté
          RAISE exc_param; --reponse KO
      END;
    END IF;

    BEGIN

      --contrôle que le sinistre n'a pas déjà été créé dans le SI
      SELECT max(s.nosin) nosin INTO loc_doublon
      FROM sntr_prev s, dossier_sinistre d , histo_sntr_prev histo
      WHERE s.iddossier  =  d.iddossier
      AND s.survenance = i_params.survenance
      AND s.norisq = 4
      AND d.numindiv = i_params.numindiv
      AND histo.nosin =s.nosin
      AND (histo.saisie,histo.debut) = (
        SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
        WHERE h.debut<= sysdate  AND h.nosin =s.nosin
        AND h.debut = (
          SELECT MAX(h2.debut) FROM histo_sntr_prev h2
          WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
          AND NOT (h2.etat=1 AND h2.motif=20)
        AND NOT (h.etat=1 AND h.motif=20))
        GROUP BY h.debut
        )
      AND NOT (histo.etat=2 AND histo.motif=10)
      AND histo.etat=1 --uniquement les sinistres en cours
      ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN loc_doublon :=0;
    END;

    IF loc_doublon >0 THEN
      loc_rappel.code_err:= 2387;
      loc_etat := 2;
      loc_rappel.etat:=4;--rejeté
      RAISE exc_ctrl_fonc;
    END IF;

    --Contrôle que l'assuré a une adhésion en cours
    loc_rappel.entite :=0;
    FOR rec_adhesion IN c_adhesion ( i_params.numindiv,i_numporte ,i_params.survenance, i_params.numcli) LOOP
      loc_rappel.entite := rec_adhesion.idadhesion;
      loc_contrat := rec_adhesion.numgar;--recherche du numéro de contrat associé à la société et l’individu
      loc_adhesion := rec_adhesion.idadhesion;
      loc_responsable := rec_adhesion.numutil;  -- gestionnaire responsable du contrat prévoyance -- PBO M0006543
      BEGIN
          --Recherche de la formule de calcul et de la garantie grâce au contrat de l’assuré
          SELECT frml.idformule,frml.numfor INTO loc_idformule, loc_numfor
          FROM gar_cntrt_ref g ,garanties ga ,frml_prest frml
          WHERE frml.numfor = ga.numfor
          AND sysdate between frml.debut AND NVL(frml.fin, sysdate)
          AND frml.valide='O'
          AND g.numfor = ga.numfor
          AND ga.nat_risq = 4
          AND g.numgar = rec_adhesion.numgar
          AND ga.gest_calc = 1
          AND sysdate BETWEEN ga.debut AND NVL(ga.fin,sysdate);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN loc_idformule :=0; loc_numfor:=0;
        END;
     EXIT;
    END LOOP;

    IF loc_rappel.entite  =0 OR loc_numfor = 0 THEN
      loc_rappel.code_err:= 2388;
      loc_etat := 3;
      loc_rappel.etat:=4;--rejeté
      RAISE exc_ctrl_fonc;
    END IF;

    IF trunc(i_params.survenance) > trunc(sysdate) THEN
      loc_rappel.code_err:= 1282;
      loc_etat := 3;
      loc_rappel.etat:=4;--rejeté
      RAISE exc_ctrl_fonc;
    END IF;

    IF trunc(i_params.survenance) < trunc(add_months(sysdate,-24)) THEN --déclaration tardive
      loc_rappel.code_err:= 2399;
    END IF;

    IF i_params.nature IS NOT NULL THEN
      CASE f_get_transco('EA','CAUSINPREV', i_params.nature,2)
        WHEN 'MALADIE' THEN
          loc_cause:=to_number(f_get_transco('EA','MALADIE',NVL(i_params.hospitalisation,'N'),1));
        WHEN 'MAL_PRO' THEN
          loc_cause:=to_number(f_get_transco('EA','MAL_PRO',NVL(i_params.hospitalisation,'N'),1));
        WHEN 'ACC_TRAV' THEN
          loc_cause:=to_number(f_get_transco('EA','ACC_TRAV',NVL(i_params.hospitalisation,'N'),1));
        WHEN 'ACC_TRAJ' THEN
          loc_cause:=to_number(f_get_transco('EA','ACC_TRAJ',NVL(i_params.hospitalisation,'N'),1));
        WHEN 'ACC_PRIV' THEN
          loc_cause:=to_number(f_get_transco('EA','ACC_PRIV',NVL(i_params.hospitalisation,'N'),1));
        ELSE
          loc_rappel.code_err:= 2400;--nature inconnue
          loc_etat := 3;
          loc_rappel.etat:=4;--rejeté
          RAISE nat_introuv;
      END CASE;
    END IF;

    --Selon mode d'appel du WS 1 simulation  2 création
    IF i_params.modCtrl = 2 THEN

      SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;

      loc_rappel.contexte  := l_context_rappel;
      loc_rappel.type      :=  l_code_demande;
      loc_rappel.reference := i_idDemande_ext;
      loc_rappel.creation  := sysdate;
      loc_rappel.createur  := loc_numutil;
      loc_rappel.responsable  := loc_responsable; -- gestionnaire responsable du contrat -- PBO M0006543
      loc_rappel.etat      := 1 ;
      loc_rappel.origine    := i_numporte;
      loc_rappel.DATEEFFET  := sysdate;
      loc_rappel.numassu    := i_params.interloc;--i_params.numindiv;
      loc_rappel.numbene    :=  i_params.numindiv;
      loc_rappel.numcli     := i_params.numcli;
      loc_rappel.commentaire :=   'Survenance : '|| d2e(i_params.Survenance)    ||';'||CHR(13)||CHR(10)||
                              --'Nature : '    || i_params.Nature      ||';'||CHR(13)||CHR(10)||
                              --'Cause : '     || i_params.Cause ||';'||
                              'Cause : '    || loc_cause      ||' '||pk_libelle.F_LIB('CAUS',loc_cause)||';'||CHR(13)||CHR(10)||
                              'Accident : ' ||NVL(i_params.Accident_prive,'N')||';'||CHR(13)||CHR(10)||
                              'Acc tiers : ' ||i_params.Accident_tiers ||';'||CHR(13)||CHR(10)||
                              'Hospitalisation : ' ||NVL(i_params.hospitalisation,'N') ||';'||CHR(13)||CHR(10)||
                              'Reprise mi-temps : ' ||d2e(i_params.Reprise_mitemps)||';'||CHR(13)||CHR(10)||
                              'Fin arrêt : '         ||d2e(i_params.FinArret) ||';'||
                              'Motif : '     ||i_params.MotifFinArret  ||' '||pk_libelle.F_LIB('HISTO_MOTI',i_params.MotifFinArret)||';'||CHR(13)||CHR(10)||
                              'Libelle de pièce : #LIBELLE;'    || CHR(13)||CHR(10)||
                              'Date d''embauche : '||d2e(i_params.embauche)||';'||CHR(13)||CHR(10)||
                              'Rupture du contrat de travail : ' || d2e(i_params.rupture)||';'||CHR(13)||CHR(10)||
                              'Nbre enfants : '||i_params.nbenf||';'||CHR(13)||CHR(10);

      i:=1;
      WHILE i <= i_documents.COUNT LOOP
       loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
       i:=i+1;
      END LOOP;

      i:=1;
      WHILE i <= i_DocSalaire.COUNT LOOP
       loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_DocSalaire(i).IDDOC ||', '|| i_DocSalaire(i).NOMDOC||'), ';
       i:=i+1;
      END LOOP;

      --création du rappel dans la corbeille
      INSERT INTO rappel VALUES loc_rappel;

      --stockage des données du flux dans RAPPEL_SIN_PREV
      loc_rap_sin_prev.IDRAPPEL        := loc_rappel.idrappel;
      loc_rap_sin_prev.NUMCLI          := i_params.numcli;
      loc_rap_sin_prev.INTERLOC        := i_params.interloc;
      loc_rap_sin_prev.NUMINDIV        := i_params.Numindiv;
      loc_rap_sin_prev.MODCTRL         := i_params.modCtrl;
      loc_rap_sin_prev.EMBAUCHE        := i_params.Embauche;
      loc_rap_sin_prev.SURVENANCE      := i_params.Survenance;
      loc_rap_sin_prev.NATURE          := i_params.Nature;
      loc_rap_sin_prev.CAUSE           := i_params.Cause;
      loc_rap_sin_prev.ACCID_PRIVE     := i_params.Accident_prive;
      loc_rap_sin_prev.ACCID_TIERS     := i_params.Accident_tiers;
      loc_rap_sin_prev.HOSPI           := i_params.hospitalisation;
      loc_rap_sin_prev.REPRISE_MITPS   := i_params.Reprise_mitemps;
      loc_rap_sin_prev.FINARRET        := i_params.FinArret;
      loc_rap_sin_prev.MOTIF_FIN_ARRET := i_params.MotifFinArret;
      loc_rap_sin_prev.NB_ENF          := i_params.NBEnf;
      loc_rap_sin_prev.rupture          := i_params.rupture;


      INSERT INTO RAPPEL_SIN_PREV VALUES loc_rap_sin_prev;
      i:=1;
      WHILE i <= i_maintien.count LOOP
          loc_maintien.idrappel := loc_rappel.idrappel    ;
          loc_maintien.debut    := i_maintien(i).debut;
          loc_maintien.fin      := i_maintien(i).fin   ;
          loc_maintien.valeur   :=i_maintien(i).valeur   ;
          loc_maintien.ordre    := i;

          INSERT INTO RAPPEL_SIN_PREV_MAINT values  loc_maintien;
          i:=i+1;
      END LOOP;
      COMMIT ;
      i:=1;

      WHILE i <= i_salaires.count LOOP
          loc_salaire.idrappel      := loc_rappel.idrappel    ;
          loc_salaire.BRUT_FIX      := i_salaires(i).BrutFixe;
          loc_salaire.BRUT_VAR      := i_salaires(i).BrutVar;
          loc_salaire.NET_FIX       := i_salaires(i).NetFixe   ;
          loc_salaire.NET_VAR       :=i_salaires(i).NetVar;
          loc_salaire.COMMENTAIRE   := i_salaires(i).commentaire;

          INSERT INTO RAPPEL_SIN_PREV_SAL values  loc_salaire;
          i:=i+1;
      END LOOP;
      COMMIT ;
      --création des liens GED Corbeille
      --IF i_documents.COUNT>0 THEN-- avant modif de struct
        --INSERT_LIEN_GED(i_documents, 30,loc_rappel.idrappel, i_params.numindiv,i_numporte, loc_numutil,loc_rappel.idrappel);
      --END IF;

      i:=1;
      WHILE i <= i_Documents.count LOOP
        loc_tab_doc(1) :=new EXTR_DOCUMENT(i_Documents(i).iddoc,i_Documents(i).nomdoc,i_Documents(i).typadr);
        loc_tab_doc(1).nomdoc :=i_Documents(i).nomdoc;
        loc_tab_doc(1).iddoc :=i_Documents(i).iddoc;
        INSERT_LIEN_GED(new EXT_TAB_DOCUMENT(loc_tab_doc(1)), 30,loc_rappel.idrappel, i_params.numindiv,i_numporte, loc_numutil,loc_rappel.idrappel);
        loc_tab_doc(1) :=new EXTR_DOCUMENT(null,null,null);
        i:=i+1;
      END LOOP;


      IF i_DocSalaire.COUNT>0 THEN
        INSERT_LIEN_GED(i_DocSalaire, 30,loc_rappel.idrappel, i_params.numindiv,i_numporte, loc_numutil,loc_rappel.idrappel);
      END IF;
      COMMIT;
      -- retour si erreur technique basique détectée
      IF loc_rappel.etat = 4  THEN
        loc_res :=GET_RESP_KO(i_params.numindiv,i_params.numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
        loc_tab_add_sin_prev (1)     := new EXTR_ADD_SIN_PREV(loc_res,NULL,NULL,NULL,loc_rappel.code_err);--EA PREV LOT4 ajout du paramètre codeErreur
        RETURN loc_tab_add_sin_prev;
      END IF;

      --traitement d'intégration

      --vérification si contrat de type mensu
      SELECT count(distinct numde) INTO is_mensu
      FROM dependance
      WHERE (numde=loc_contrat or numenvers = loc_contrat)
      AND role =6 AND sysdate BETWEEN datapli AND NVL(datper,sysdate);

      --Recherche d'un dossier sinistre prévoy existant pour l'année de survenance du flux ou si contrat mensu
      BEGIN

        SELECT tble.loc_doss, tble.numutil INTO loc_numdossier , loc_gest
        FROM(SELECT max(ds.iddossier) loc_doss, ds.numutil numutil
            FROM  dossier_sinistre ds, dependance d
            WHERE ds.numindiv = i_params.numindiv
            AND ((trunc(ds.creation) between E2D('01/01/'||TO_CHAR(i_params.survenance,'YYYY'))--pour l'année de survenance du flux
                                and E2D('31/12/'||TO_CHAR(i_params.survenance,'YYYY')))
                OR (
                    (d.numde=loc_contrat or d.numenvers = loc_contrat)
                    AND d.role =6 AND sysdate BETWEEN d.datapli AND NVL(d.datper,sysdate)
                    )
                )

            GROUP BY iddossier, ds.numutil
            order by ds.iddossier desc
            )  tble
        where ROWNUM <= 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          loc_numdossier :=0;
          loc_gest := NULL;
      END;

      --création du dossier sinistre + sinistre
      P_CREA_SNTR_PREV(is_mensu,loc_rappel,loc_numutil, loc_numdossier, o_numsin);

      IF o_numsin =0 THEN
        RAISE exc_crea_nosin;
      END IF;

      --Historisation du sinistre
      loc_survenance := e2d(F_GET_VALUE_IN_TABLE('Survenance', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)));
      INSERT INTO HISTO_SNTR_PREV (NOSIN,DEBUT,ETAT,MOTIF,NUMUTIL,SAISIE) VALUES (o_numsin, /*i_params.survenance*/loc_survenance ,1 ,31 ,loc_numutil ,sysdate);

      --changement du contexte et clef du rappel pour dossier sinistre prevoy
      loc_rappel.entite := o_numsin;
      loc_rappel.contexte :=16;
      UPDATE RAPPEL SET entite =o_numsin, contexte =16
      WHERE idrappel = loc_rappel.idrappel;
      COMMIT;
      --création de la couverture doit être faite sur la garantie identifiée et pour la date de début d’adhésion identifiée
      INSERT INTO ADHESION (NUMINDIV,
                            NUMGAR,
                            NUMFOR,
                            DATAPLI,
                            DATPER,
                            RANG,
                            ETAT,
                            UC,
                            FLAG_REGIME,
                            REGIME,
                            TYPFOR,
                            NUMORG,
                            DIS_CARENCE,
                            DIS_FRANCHISE,
                            IDADHESION,
                            NUMFOR_CARENCE,
                            NUMUTIL,
                            CREATION,
                            MAJ,
                            MOTIF,
                            IDCOUVERTURE)
            SELECT NUMINDIV,NUMGAR,NUMFOR,DATAPLI,DATPER,RANG,ETAT,
            UC,FLAG_REGIME,REGIME,TYPFOR,NUMORG,DIS_CARENCE,DIS_FRANCHISE,IDADHESION,NUMFOR_CARENCE,NUMUTIL,CREATION,MAJ,MOTIF,IDCOUVERTURE.nextval
            FROM adhesion a
            WHERE idadhesion = loc_adhesion
            AND numindiv = i_params.numindiv
            AND numfor =loc_numfor
            AND NOT EXISTS (select 1 FROM adhesion adh --eviter les doublons TODO ATTENTE RETOUR CLIENT
                            WHERE adh.idadhesion = loc_adhesion
                            AND adh.numindiv = loc_rappel.numbene
                            AND adh.numfor =loc_numfor
                            AND adh.datapli=a.datapli
                            );
           -- RETURNING IDCOUVERTURE INTO loc_IDCOUVERTURE ;
      --couverture sur garantie type 4 Incap de travail M0006702
      BEGIN
        select numfor into loc_gar_regl
        from gar
        where cle=loc_contrat--(select numgar from adhesion where idadhesion=loc_adhesion)
        and nat_risq =4
        and gest_calc=1 --réglées
        and valide='O'
        and fin is null--ouverte
        ;

        BEGIN
            select type into loc_typfor from gar_cntrt where numgar=loc_contrat and numfor= loc_gar_regl;
        EXCEPTION
           WHEN OTHERS THEN loc_typfor :=2;
        END;

        BEGIN
          SELECT FLAG_REGIME into loc_flag_reg  --iso ad01
          FROM FORMULE
          WHERE FORMULE.NUMFOR = loc_gar_regl
          OR FORMULE.NUMFOR = PK_QTTC.F_SEL_numfor(PK_QTTC.F_SEL_numgar(loc_contrat), loc_gar_regl);
        EXCEPTION
           WHEN OTHERS THEN loc_flag_reg :='C';
        END;

        BEGIN
          SELECT REGIME, RANG into loc_reg, loc_rang  --iso ad01
          FROM INDIVIDU
          WHERE NUMINDIV  = i_params.numindiv;
        EXCEPTION
           WHEN OTHERS THEN loc_reg :='01';  loc_rang :=1;
        END;

        BEGIN   --iso ad01
          select min(numorg) into loc_numorgmin from orgns where role = 1;
          select nvl(orgbase,loc_numorgmin)	into   loc_numorg from indvs where  numindiv = i_params.numindiv;
        EXCEPTION
           WHEN OTHERS THEN loc_numorgmin :=null; loc_numorg := 1;
        END;

        INSERT INTO ADHESION (NUMINDIV,
                            NUMGAR,
                            NUMFOR,
                            DATAPLI,
                            DATPER,
                            RANG,
                            ETAT,
                            UC,
                            FLAG_REGIME,
                            REGIME,
                            TYPFOR,
                            NUMORG,
                            DIS_CARENCE,
                            DIS_FRANCHISE,
                            IDADHESION,
                            NUMFOR_CARENCE,
                            NUMUTIL,
                            CREATION,
                            MAJ,
                            MOTIF,
                            IDCOUVERTURE)

           SELECT ac.NUMADHE,ac.NUMGAR,loc_gar_regl,ac.DATE_ADHE,ac.DATE_FIN_ADHE, loc_rang,1,null,loc_flag_reg,to_number(loc_reg),loc_typfor,loc_numorg,'O','O', ac.IDADHESION,null, loc_numutil, sysdate,null,null,IDCOUVERTURE.nextval--,REF_EXT,,,,MEME_GAR,,NUMQUERABLE,FRACT,ECHESUIV,DERECHE,MREGL,DELAI,DSOUS,NUMUTIL,ECHE_ANNIV
            FROM /*adhesion a,*/ adhe_cntrt ac
            where /*a.idadhesion= ac.idadhesion
            and */ac.idadhesion=loc_adhesion
            and  NUMADHE = i_params.numindiv
            AND NOT EXISTS(select 1 FROM adhesion adh --eviter les doublons TODO ATTENTE RETOUR CLIENT
                            WHERE adh.idadhesion = loc_adhesion
                            AND adh.numindiv = loc_rappel.numbene
                            AND adh.numfor =loc_gar_regl
                            AND adh.datapli=ac.DATE_ADHE);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'ADD_SIN_PREV',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'Aucune garantie incap. travail réglée trouvée sur le contrat',
          I_idligne  => 2);
        WHEN TOO_MANY_ROWS THEN
          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'ADD_SIN_PREV',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||'Plusieurs garanties incap. travail réglées trouvées sur le contrat',
          I_idligne  => 2);
      END;

      --creation du correspondant béné uniquement si non existant  --Pas besoin il se cree automatiquement en cochant le beneficaire sur pv36b  vu avec VMO
     /* INSERT INTO CORRESPONDANT (CONTEXTE,
                                  ENTITE,
                                  NUMCORRES,
                                  TYPE_CORRES,
                                  DEFAUT_PJ_ASSU,
                                  DEFAUT_PJ_BENE,
                                  DEFAUT_RGLT_BENE,
                                  CREATION,
                                  CREATEUR,
                                  MODIFICATION,
                                  MODIFICATEUR,
                                  DEFAUT_SNTR,ID_CORRES,
                                  NAT_CORRES,
                                  INTERLOCUTEUR)
                          SELECT 15 ,o_numsin ,/*i_params.numindiv loc_rappel.numbene  ,6 ,'N','N','N',sysdate ,loc_numutil ,sysdate ,loc_numutil ,'N',ID_CORRES.nextval ,4 ,/*i_params.numindivloc_rappel.numbene
                          FROM DUAL  where not exists (
                          select entite from correspondant where contexte = 15
                          AND nat_corres = 4 AND numcorres =loc_rappel.numbene AND entite =o_numsin) ;   */


        INSERT INTO CORRESPONDANT (CONTEXTE,      --M0006706 RKO 17/07/2020
                                  ENTITE,
                                  NUMCORRES,
                                  TYPE_CORRES,
                                  DEFAUT_PJ_ASSU,
                                  DEFAUT_PJ_BENE,
                                  DEFAUT_RGLT_BENE,
                                  CREATION,
                                  CREATEUR,
                                  MODIFICATION,
                                  MODIFICATEUR,
                                  DEFAUT_SNTR,ID_CORRES,
                                  NAT_CORRES,
                                  INTERLOCUTEUR)
                          SELECT 15 ,o_numsin ,/*i_params.numindiv*/loc_rappel.numbene  ,5 ,'N','N','N',sysdate ,loc_numutil ,sysdate ,loc_numutil ,'N',ID_CORRES.nextval ,3 ,null
                          FROM DUAL  where not exists (
                          select entite from correspondant where contexte = 15
                          AND nat_corres = 3 AND numcorres =loc_rappel.numbene AND entite =o_numsin) ;

      --gestion des pièces et documents
      --Tous les liens ged du bloc salaire doivent être lié à une unique pièce n°18 contexte 17
      IF i_DocSalaire.COUNT>0 THEN
        loc_piece.contexte   := 17;
        loc_piece.nopiece    :=18;
        loc_lib :='Copie des bulletins de salaire';
        DEPOT_SPONT_PREV(null,loc_rappel.numbene,loc_rappel.numcli,loc_piece,loc_rappel,30,loc_numutil,loc_lib,i_DocSalaire);
        loc_piece.nopiece :=NULL;
        loc_piece.contexte :=NULL;
        loc_piece.idpiece :=NULL;
      END IF;

      loc_tab_doc:=  NEW    EXT_TAB_DOCUMENT(null);
      i:=1;
      WHILE i <= i_Documents.count LOOP
        loc_entite :=null;
        --on recréé l'objet juste pour passer à la procédure de création de pièces
        loc_tab_doc (1)     := new EXTR_DOCUMENT(i_Documents(i).iddoc,i_Documents(i).nomdoc,null);
        loc_piece.contexte   := 17;
        loc_piece.nopiece      := i_Documents(i).nature;
        IF loc_piece.nopiece =1 THEN
          loc_lib :='Décompte d''indemnité journalière SS';
        ELSIF loc_piece.nopiece =8 THEN
          loc_lib := 'Notification SS d''invalidité';
        ELSIF loc_piece.nopiece=25 THEN
          loc_lib := 'Attestation précisant salaire mi-temps';
        ELSIF loc_piece.nopiece =54 THEN
          loc_lib := 'Copie du contrat de travail';
        ELSIF loc_piece.nopiece =58 THEN
          loc_lib := 'Bulletin d''hospitalisation';
        ELSIF loc_piece.nopiece =19 THEN
          loc_lib := 'Déclaration d''arrêt de travail';
        ELSE NULL;
        END IF;

        IF loc_piece.nopiece IS NOT NULL THEN
           --verif que la pièce justif est connue dans arthus
          BEGIN
            SELECT code INTO loc_type_piece
            FROM libelle
            WHERE mnemo ='JUSTIF_17'
            AND code = loc_piece.nopiece;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN loc_type_piece := null;
          END;
          IF loc_type_piece IS NOT NULL THEN
            DEPOT_SPONT_PREV(null,loc_rappel.numbene,loc_rappel.numcli,loc_piece,loc_rappel,30,loc_numutil,loc_lib,new EXT_TAB_DOCUMENT(loc_tab_doc(1)));
          END IF;

        END IF;

        loc_piece.nopiece :=NULL;
        loc_piece.contexte :=NULL;
        loc_piece.idpiece :=NULL;
        i:=i+1;

      END LOOP;

      --fin intégration

      IF loc_rappel.code_err IS NULL THEN
        IF loc_tab_add_sin_prev(1) IS NOT NULL THEN   loc_tab_add_sin_prev.extend(1);END IF;
      END IF;
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, 1);
      COMMIT;
      --P_MAIL_RECEPTION A DECOMMENTER POUR LIVRAISON CLIENT
      PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(NVL(i_params.interloc, loc_interloc), l_code_demande, l_context_rappel, loc_rappel.entite,29,2); -- création du mail accusé de reception
      loc_res := PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_params.numindiv,i_params.numindiv,1, get_code_demande(i_id_type,i_numporte));
      loc_tab_add_sin_prev (1)     := new EXTR_ADD_SIN_PREV(loc_res,loc_rappel.entite,i_params.MODCTRL,SUBSTR(loc_regle,0,250), loc_rappel.code_err);

    ELSE --mode simulation

      --Recherche Maternité
      SELECT COUNT(idformule) INTO loc_maternite
      FROM frmlvar WHERE (cond like '%CAUSE=8%' OR frml like '%CAUSE=8%')
      AND idformule = loc_idformule;
      IF loc_maternite >0 THEN
        loc_maternite :=1;--trouvé
      ELSE
        loc_maternite :=0;
      END IF;

      --Recherche hospitalisation
      SELECT COUNT(idformule) INTO loc_hospi
      FROM frmlvar WHERE  idformule = loc_idformule
      AND (cond like '%CAUSE=9%' OR frml like '%CAUSE=9%'
      OR cond like '%CAUSE=10%' OR frml like '%CAUSE=10%'
      OR cond like '%CAUSE=11%' OR frml like '%CAUSE=11%'
      OR cond like '%CAUSE=12%' OR frml like '%CAUSE=12%'
      OR cond like '%CAUSE=13%' OR frml like '%CAUSE=13%');
      IF loc_hospi >0 THEN
        loc_hospi :=1;--trouvé
      ELSE
        loc_hospi :=0;
      END IF;

      --Recherche nbenf
      SELECT  COUNT(distinct def.idvariable) INTO loc_nbenf
      FROM frmlvar_detail var , def_variable def
      WHERE var.idformule = loc_idformule
      AND def.idvariable = var.idvariable
      AND nom_variable LIKE 'NBENF%'; --RKO M0006775
      IF loc_nbenf >0 THEN
        loc_nbenf :=1;--trouvé
      ELSE
        loc_nbenf :=0;
      END IF;

      --Recherche maintien
      SELECT  COUNT(distinct def.idvariable) INTO loc_maint
      FROM frmlvar_detail var , def_variable def
      WHERE var.idformule = loc_idformule
      AND def.idvariable = var.idvariable
      AND nom_variable LIKE 'DFINPER1';
      IF loc_maint >0 THEN
        loc_maint :=1;--trouvé
      ELSE
        loc_maint :=0;
      END IF;

      ----Recherche prestIJ (28 ou 29) dans porte contrat pour le contrat de l’assuré
      SELECT COUNT(numgar) INTO loc_prestij
      FROM porte_contrat
      WHERE numporte IN (28,29)
      AND numgar =loc_contrat;
      IF loc_prestij >0 THEN
        loc_prestij :=0;--trouvé
      ELSE
        loc_prestij :=1;
      END IF;


      loc_regle :='nbenf :'||loc_nbenf||',maintien :'||loc_maint||',maternite :'||loc_maternite||',hospi :'||loc_hospi||',PrestIJ :'||loc_prestij||','; --<règle> contiendra : ‘nbenf’ :0,’maintien’ :0,’maternite’ :0,’hospi’ :1,’PrestIJ’ :1,

      loc_res := PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_params.numindiv,i_params.numindiv,1, get_code_demande(i_id_type,i_numporte));
      loc_tab_add_sin_prev (1)     := new EXTR_ADD_SIN_PREV(loc_res,loc_rappel.entite,i_params.MODCTRL,SUBSTR(loc_regle,0,250),loc_rappel.code_err);

    END IF;

    RETURN loc_tab_add_sin_prev;

  EXCEPTION

    WHEN exc_param OR exc_ctrl_fonc OR nat_introuv THEN
      loc_res :=GET_RESP_KO(i_params.numindiv,i_params.numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
      loc_tab_add_sin_prev (1)     := new EXTR_ADD_SIN_PREV(loc_res,NULL,loc_etat,NULL, loc_rappel.code_err);
      RETURN loc_tab_add_sin_prev;
    WHEN exc_crea_nosin THEN
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2185, 4);
      loc_res :=GET_RESP_KO(i_params.numindiv,i_params.numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2185,1));
      loc_tab_add_sin_prev (1)     := new EXTR_ADD_SIN_PREV(loc_res,NULL,NULL,NULL, loc_rappel.code_err);
      RETURN loc_tab_add_sin_prev;
    WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'ADD_SIN_PREV',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
      I_idligne  => 2);
      IF i_params.modCtrl = 2 THEN
        SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
      END IF;
      loc_res :=GET_RESP_KO(i_params.numindiv,i_params.numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2185,1));
      loc_tab_add_sin_prev (1)     := new EXTR_ADD_SIN_PREV(loc_res,NULL,NULL,NULL, loc_rappel.code_err);
      RETURN loc_tab_add_sin_prev;

  END ADD_SIN_PREV;

  /*---------------------------------------------------------------------------*/
  /* PROCEDURE                                                                  */
  /* Nom          :  P_CREA_SNTR_PREV                                          */
  /* Type         :  Public                                                    */
  /* Description  :  creation du dossier sinistre prevoyance
                      ou du sinistre  si dossier prevoy existant               */
  /*                                                                */
  /* Auteur       :  RKO                                                       */
  /* Date         :  18/06/2020                                                */
  /* Commentaire  :  Projet P201910104 Extranet Prévoy GEREP                   */
  /* Retour       :   nosin et numdoss                                                        */
  /*---------------------------------------------------------------------------*/
  PROCEDURE P_CREA_SNTR_PREV (p_mensu IN NUMBER,p_rappel IN RAPPEL%ROWTYPE, p_numutil IN NUMBER, io_numdoss IN OUT DOSSIER_SINISTRE.iddossier%TYPE,o_nosin OUT SNTR_PREV.NOSIN%TYPE )

  IS

    loc_seq           NUMBER;
    loc_cause         NUMBER(3);
    loc_survenance    DATE;
    loc_dossier       dossier_sinistre%ROWTYPE;
    loc_an_survenance NUMBER;
    loc_an_doss       NUMBER;
    loc_code_risq       NUMBER;

  BEGIN

    loc_survenance := e2d(F_GET_VALUE_IN_TABLE('Survenance', f_get_varchar_splited(';'||chr(10)||chr(13), p_rappel.commentaire)));
    loc_cause := to_number(substr(F_GET_VALUE_IN_TABLE('Cause', f_get_varchar_splited(';'||chr(10)||chr(13), p_rappel.commentaire)),1,2));
    loc_an_survenance := to_number(to_char(e2d(F_GET_VALUE_IN_TABLE('Survenance', f_get_varchar_splited(';'||chr(10)||chr(13), p_rappel.commentaire))),'YYYY'));

    BEGIN
      select code into loc_code_risq FROM libelle WHERE mnemo='GESTIP_R' and code > 0 ;    --4 incapacité de travail GEREP

    EXCEPTION
      WHEN OTHERS THEN loc_code_risq :=null;
    END;


    IF p_mensu=0 and io_numdoss=0 THEN--contrat non mensu et pas de dossier existant aucours l'annee de survenance
      --recherche du dossier le plus recent
        SELECT max(dossier_sinistre.iddossier) INTO io_numdoss
        FROM  dossier_sinistre
        WHERE dossier_sinistre.numindiv = p_rappel.numbene ;

      IF io_numdoss IS NULL THEN io_numdoss :=0; END IF;--exception no_data_found ne fonctionne pas sur max
    END IF;

    IF io_numdoss=0 THEN
      --création du dossier
      io_numdoss := f_iddossier(sysdate);
      INSERT INTO DOSSIER_SINISTRE (IDDOSSIER,
                                    REF_EXT,
                                    NUMINDIV,
                                    ANTERIEUR,
                                    DEBUT,
                                    NUMUTIL,
                                    FIN,
                                    CLOTURE,
                                    CREATEUR,
                                    CREATION,
                                    MODIFICATEUR,
                                    MODIFICATION)

                          VALUES (io_numdoss,
                                  'EA_PREV_Noassu_'||p_rappel.numbene,
                                  p_rappel.numbene ,
                                  'N',
                                  sysdate,
                                  p_numutil,
                                  null,
                                  null,
                                  null,
                                  sysdate,
                                  null,
                                  null );

    ELSIF io_numdoss <>0 THEN --
      SELECT * INTO loc_dossier
      FROM dossier_sinistre
      WHERE iddossier=io_numdoss;

      loc_an_doss :=to_number(to_char(loc_dossier.creation, 'YYYY'));
      IF loc_an_doss <> loc_an_survenance AND p_mensu =1 THEN --aucun dossier en cours sur l'année de survenance pour le contrat mensu
      --création du dossier
        io_numdoss := f_iddossier(sysdate);
        INSERT INTO DOSSIER_SINISTRE (IDDOSSIER,
                                      REF_EXT,
                                      NUMINDIV,
                                      ANTERIEUR,
                                      DEBUT,
                                      NUMUTIL,
                                      FIN,
                                      CLOTURE,
                                      CREATEUR,
                                      CREATION,
                                      MODIFICATEUR,
                                      MODIFICATION)

                            VALUES (io_numdoss,
                                    'EA_PREV_Noassu_'||p_rappel.numbene,
                                    p_rappel.numbene ,
                                    'N',
                                    COALESCE(e2d('01/01/'||to_char(loc_an_survenance)),sysdate), -- BCO M0006707
                                    p_numutil,
                                    null,
                                    null,
                                    null,
                                    sysdate,
                                    null,
                                    null );

     -- ELSIF p_mensu =0 OR ( p_mensu=1 AND loc_an_doss = loc_an_survenance) THEN
      END IF;
    END IF;

    SELECT COUNT (nosin+1) INTO loc_seq
    FROM sntr_prev
    WHERE iddossier=io_numdoss;
    o_nosin := io_numdoss|| substr( to_char(loc_seq,'09'), 2, 2 )+1; --incrementation du nosin
    --on rattache le sinistre au dossier
    INSERT INTO SNTR_PREV (NOSIN,
                          IDDOSSIER,
                          SURVENANCE,
                          DECLARATION,
                          NORISQ,
                          CAUSE,
                          IDCORRES,
                          NUMUTIL,
                          NUMCLOT,
                          CREATION,
                          MAJ,
                          FIN,
                          MOTIF,
                          CREATEUR,
                          MODIFICATION,
                          MODIFICATEUR,
                          REF_EXT_1,
                          REF_EXT_2,
                          DC_ASSURE,
                          PRISCHARGE,
                          INFO_COMP1,
                          INFO_COMP2,
                          PRISCALC)

                  VALUES (o_nosin,
                          io_numdoss,
                          loc_survenance,--p_params.survenance,
                          sysdate,
                          loc_code_risq,--4,
                          loc_cause,--p_params.cause,
                          p_rappel.numbene,
                          p_numutil, --TODO suivi par loc_numutil(=user EA PREV) ou loc_gest (=gestionnaire du dossier sinistre)
                          0,
                          sysdate,
                          sysdate,
                          null,
                          null,
                          p_numutil,
                          null,
                          null,
                          'EA_'||p_rappel.reference,--p_idDemande_ext,
                          null,
                          'N',
                          null,
                          null,
                          null,
                          null);




    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'P_CREA_SNTR_PREV',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'nosin=['||o_nosin||'] io_numdoss =['||io_numdoss||'] '||loc_survenance||' '||loc_cause||substr(sqlerrm,1,132),
      I_idligne  => 1);
      o_nosin:=0;
      io_numdoss :=0;
      ROLLBACK;
  END P_CREA_SNTR_PREV;

  /****************************************************************************/
  FUNCTION ADD_EVENT(  i_numporte    IN NUMBER,
                       i_id_type     IN TYPE_FLUX.ID_TYPE%TYPE,
                       i_idDemande_ext   IN NUMBER,
                       i_params  IN EXTR_Q_ADD_EVENT ,
                       i_documents   IN EXT_TAB_DOCUMENT ) RETURN GENERIQUE_WS_RESP
  IS
  loc_res               GENERIQUE_WS_RESP;
  exc_param          EXCEPTION;
  exc_ctrl_fonc      EXCEPTION;

  l_code_demande    NUMBER;
  l_context_rappel  NUMBER;
  loc_numutil    utilisateurs.numutil%TYPE;
  loc_rappel     rappel%ROWTYPE;
  loc_motif      varchar(50);
  loc_lib_nat    varchar(50);
  i              NUMBER;
  loc_doubl      NUMBER;
  loc_chevauch   NUMBER;
  loc_valid      NUMBER;
  nb_sin_ferme  NUMBER;
  loc_code_nat  NUMBER;
  loc_responsable   NUMBER;   -- gestionnaire responsable du contrat -- PBO M0006543

  loc_piece      PIECES%ROWTYPE;
  loc_lib        VARCHAR2(100);
  loc_lib1       VARCHAR2(100);
  date_surv       DATE;

  BEGIN
  loc_res               := new GENERIQUE_WS_RESP(null,null,null,null,null,null,null,null) ;


  l_code_demande := get_code_demande(i_id_type,i_numporte);


  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;


 --Contrôles des paramètres entrants
  BEGIN
   SELECT code INTO loc_code_nat
   FROM libelle
   WHERE mnemo ='NAT_EVENT'
   AND code = i_params.nature;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN loc_code_nat := null;
  END;

  IF i_params.numindiv  IS NULL
  OR i_params.interloc  IS NULL    -- BCO M0006748
  OR i_params.nosin     IS NULL
  OR i_params.nature    IS NULL
  OR i_params.debut     IS NULL
  OR loc_code_nat       IS NULL
  /*loc_nat_trouv = 0 */THEN --RG code nature bien dans la liste des codes natures paramétrés (liste libelle)
    loc_rappel.code_err:= 2397;
    loc_rappel.etat:=4;--rejeté
    RAISE exc_param; --reponse KO

  ELSE
    null;
  END IF;

  IF  i_params.nature =5  AND (i_params.mtijss IS NULL OR i_params.fin IS NULL OR i_params.numcli IS NULL
                                OR (i_documents(i_documents.COUNT).IDDOC IS NULL AND i_documents(i_documents.COUNT).NOMDOC IS NULL)
                              ) THEN
      loc_rappel.code_err:= 2397;
      loc_rappel.etat:=4;--rejeté
      RAISE exc_ctrl_fonc;
  ELSIF loc_code_nat IS NOT NULL THEN --i_params.nature in (SELECT code FROM libelle WHERE mnemo ='NAT_EVENT') THEN   --TODO loc_motif pour nature=5     --RG si nature = clôture (*n) => motif doit être transcodé sinon KO fonctionnel
    CASE f_get_transco('EA','MOTI_ADDEV', i_params.nature,2)
        WHEN '2' THEN
          loc_motif := 'Reprise du travail';
        WHEN '5' THEN
          loc_motif := 'Retraite';
        WHEN '8' THEN
          loc_motif := 'Congé Maternité';
        WHEN  '13' THEN
          loc_motif := 'Fin indemnisation IJSS';
        ELSE NULL;
    END CASE;
  ELSE
    null;
  END IF;
  --vérifier qu’il n’y a pas une autre demande en cours même sin / nature non traitée
  select count(idrappel) into loc_doubl from rappel
  WHERE entite = i_params.nosin
  AND numassu  = i_params.numindiv
  AND to_number(SUBSTR(F_GET_VALUE_IN_TABLE('Nature', f_get_varchar_splited(';'||chr(10)||chr(13), rappel.commentaire)),1,1)) =i_params.nature --recupération du code nature
  --to_number(F_GET_VALUE_IN_TABLE('Nature', f_get_varchar_splited(';'||chr(10)||chr(13), rappel.commentaire))) =i_params.nature
  and etat in(1,2) --nouveau, ou en attente
  ;

  IF loc_doubl >0 THEN
    loc_rappel.code_err:= 2398;
    loc_rappel.etat:=4;--rejeté
    RAISE exc_ctrl_fonc;
  END IF;

 -- remonte le gestionnaire responsable du contrat prévoyance-- PBO M0006543
  IF l_context_rappel = 16 THEN -- dossier sinistre prévoyance uniquement
    SELECT contrat.numutil INTO loc_responsable
    FROM adhe_cntrt, contrat
      WHERE adhe_cntrt.idadhesion = f_idadhesion_prev(i_params.nosin) -- remonte l'adhésion prévoyance via le numéro de sinistre
      AND adhe_cntrt.numgar = contrat.numgar;
  ELSE
    null;
  END IF;

  -- creation de l'événement dans la table rappel
  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;
  loc_rappel.contexte  := l_context_rappel;
  loc_rappel.type      :=  l_code_demande;
  loc_rappel.reference := i_idDemande_ext;
  loc_rappel.creation  := sysdate;
  loc_rappel.createur  := loc_numutil;
  loc_rappel.responsable  := loc_responsable; -- gestionnaire responsable du contrat -- PBO M0006543
  loc_rappel.etat      := 1 ;
  loc_rappel.origine    := i_numporte;
  loc_rappel.DATEEFFET  := sysdate;
  loc_rappel.numassu     := i_params.interloc; --i_params.numindiv; - BCO M0006748
  loc_rappel.numbene     := i_params.numindiv;   --RKO 05/06/2020
  loc_rappel.numcli     := i_params.numcli;
  loc_rappel.entite      := i_params.nosin;
  loc_lib_nat            :=f_lble('NAT_EVENT',i_params.nature );

  loc_rappel.commentaire :=  'Individu : '                     || i_params.numindiv       ||';'|| CHR(13)||CHR(10) ||
                             'Demande extérieure : '           || i_idDemande_ext ||';'|| CHR(13)||CHR(10)||
                             'Date de début : '                 || d2e(i_params.debut) ||';'|| CHR(13)||CHR(10)||
                             'Date de fin : '                  || d2e(i_params.fin) ||';'|| CHR(13)||CHR(10)||
                             'Montant : '                      || i_params.mtijss ||';'|| CHR(13)||CHR(10)||
                             'Nature : '                       || i_params.nature||'-'||loc_lib_nat ||';'|| CHR(13)||CHR(10)||
                             'Libelle de pièce : #LIBELLE;'    || CHR(13)||CHR(10)||
                             'Motif de clôture : '               || loc_motif ||';'|| CHR(13)||CHR(10)
                             ;


  i :=1;
  WHILE i <= i_documents.COUNT LOOP
      loc_rappel.commentaire := loc_rappel.commentaire||'('||  i_documents(i).IDDOC ||', '|| i_documents(i).NOMDOC||'), ';
      i:=i+1;
  END LOOP;

  loc_rappel.commentaire := loc_rappel.commentaire||';';

  --création du rappel dans la corbeille et des liens GED Corbeille
  INSERT INTO rappel VALUES loc_rappel;

  IF i_params.nature <> 5 THEN
    IF i_documents.COUNT>0 THEN
      INSERT_LIEN_GED(i_documents, 30,loc_rappel.idrappel, i_params.numindiv,i_numporte, loc_numutil,loc_rappel.idrappel);
    END IF;
  END IF;
  COMMIT;
  -- retour si erreur technique basique détectée
  IF loc_rappel.etat = 4  THEN
    loc_res :=GET_RESP_KO(i_params.numindiv,i_params.numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
    RETURN loc_res;
  END IF;


  IF loc_rappel.code_err IS NULL THEN

  --Vérifier que le sinistre n'est pas déjà clôturé
    SELECT count(*) into nb_sin_ferme--s.*,histo.*
    FROM sntr_prev s , histo_sntr_prev histo
    WHERE  histo.nosin =s.nosin
    AND histo.nosin = i_params.nosin
    AND (histo.saisie,histo.debut) = (
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
       )
      GROUP BY h.debut
      )
    AND histo.etat=2 -- fermé
    ;
    IF nb_sin_ferme >0 THEN
      loc_rappel.code_err:= 2359;
      loc_rappel.etat:=4;--rejeté
      RAISE exc_ctrl_fonc;
    END IF;
    IF i_params.nature=5 THEN   --continuité
      --Vérifier que la date de debut de l'arrêt n'est pas antérieure à la date de survenance du sinistre
      BEGIN
        SELECT trunc(survenance) INTO date_surv FROM sntr_prev WHERE nosin = i_params.nosin;
      EXCEPTION
        WHEN OTHERS THEN date_surv := null;
      END;

      IF trunc(i_params.debut) < date_surv /*NVL(date_pec_saisie,date_pec_calc)*/ THEN
        loc_rappel.code_err:= 2401;
        loc_rappel.etat:=4;--rejeté
        RAISE exc_ctrl_fonc;
      END IF;
      --Vérifier qu’il n’y a pas de chevauchement avec un arrêt sur le sinistre
      loc_chevauch := PK_PREV_BPIJ.F_DOUBLONS_BPIJ(i_params.numindiv,i_params.debut,i_params.fin);
      IF loc_chevauch >0 THEN --chevauchement avec un arret sur le sinistre
         loc_rappel.code_err:= 2398;
         loc_rappel.etat:=4;--rejeté
         RAISE exc_ctrl_fonc;
      ELSIF f_get_transco('EA','PJUSTIF', 20,2) = 'DCPT_IJ_SS' THEN --continuité du sinistre implique un dépôt spontané de piece décompte IJ de la SS --> i_typepiece 20 pour transco DCPT_IJ_SS
        loc_lib :=' décompte des IJ de la SS';
        loc_lib1:='Dépôt spontané décompte des IJ de la SS';
        loc_piece.contexte   := 17;
        DEPOT_SPONT_PREV(20,i_params.numindiv,i_params.numcli,loc_piece,loc_rappel,30,loc_numutil,loc_lib,i_documents);
      END IF;
    END IF;
  END IF;
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, null, 1);
  COMMIT;
  PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_params.interloc, l_code_demande, l_context_rappel, loc_rappel.entite,29,2); -- création du mail accusé de reception
  loc_res := PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_params.numindiv,i_params.numindiv,1, get_code_demande(i_id_type,i_numporte));
  RETURN loc_res;


  EXCEPTION
    WHEN exc_param THEN
      --SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
      loc_res :=GET_RESP_KO(i_params.numindiv,i_params.numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
      RETURN loc_res;
    WHEN exc_ctrl_fonc THEN
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
      loc_res :=GET_RESP_KO(i_params.numindiv,i_params.numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
      RETURN loc_res;
    WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'ADD_EVENT',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
      I_idligne  => 2);
    SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
    loc_res :=GET_RESP_KO(i_params.numindiv,i_params.numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2185,1));
    RETURN loc_res;

  END ADD_EVENT;
/**************************************************/
FUNCTION F_VALIDE_ADD_SIN_PREV(i_idrappel number ,i_numporte number)
RETURN NUMBER
IS

BEGIN

 RETURN 0;--F_VALIDE_DEPOT_PIECE   (i_idrappel ,i_numporte);

EXCEPTION
    WHEN OTHERS THEN RETURN 2218;
END  F_VALIDE_ADD_SIN_PREV;

/***************************************************/
FUNCTION F_VALIDE_ADD_EVENT(i_idrappel number ,i_numporte number)
RETURN NUMBER

IS

 loc_rappel       rappel%ROWTYPE;
 loc_arret        arret%ROWTYPE;
 loc_chaine       VARCHAR2(50);
 loc_nature       NUMBER;
 loc_code_nat     NUMBER;
 loc_motif        NUMBER;
 loc_date_cloture DATE;
 V_IDHISTORAPPEL rappel.idrappel%TYPE;
 date_pec_saisie DATE;
 date_pec_calc   DATE;

BEGIN
  --RECUPERATION DES INFORMATIONS UTILES
  SELECT * INTO loc_rappel
  FROM rappel
  WHERE idrappel = i_idrappel;

  --recupération du code nature et de la date debut du rappel
  loc_chaine := to_char(F_GET_VALUE_IN_TABLE('Nature', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)));   --1-libelle
  loc_nature := to_number(SUBSTR(loc_chaine,1,1));

  loc_date_cloture := e2d(F_GET_VALUE_IN_TABLE('Date de début', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)));

  BEGIN
   SELECT code INTO loc_code_nat
   FROM libelle
   WHERE mnemo ='NAT_EVENT'
   AND code = loc_nature;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN loc_code_nat := null;
  END;


  loc_motif  := to_number(f_get_transco('EA','MOTI_ADDEV', loc_nature,2));
  IF loc_nature=5 THEN --continuité d'arrêt
    BEGIN
        SELECT trunc(prischarge), trunc(priscalc)
        INTO date_pec_saisie, date_pec_calc
        FROM sntr_prev WHERE nosin = loc_rappel.entite;
    EXCEPTION
      WHEN OTHERS THEN null;
    END;
    IF NVL(date_pec_calc,date_pec_saisie) IS NOT NULL THEN    --M0006668
        IF trunc(e2d(F_GET_VALUE_IN_TABLE('Date de fin', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)))) < NVL(date_pec_calc,date_pec_saisie) THEN
          loc_arret.TYPE := 7;--franchise
        ELSIF trunc(e2d(F_GET_VALUE_IN_TABLE('Date de fin', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)))) >= NVL(date_pec_calc,date_pec_saisie)THEN
          loc_arret.TYPE       := 0 ;  --IJ
        END IF;
    ELSE loc_arret.TYPE := 7; --M0006668
    END IF;
    loc_arret.IDARRET    := PK_PREV_BPIJ.f_next_arret();
    loc_arret.NOSIN      := loc_rappel.entite;
    loc_arret.DEBUT      := e2d(F_GET_VALUE_IN_TABLE('Date de début', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)));
    loc_arret.FIN        := e2d(F_GET_VALUE_IN_TABLE('Date de fin', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire)));
    loc_arret.TRAITE     := 'N';
    loc_arret.PERIODE    := 0 ; --0 :Sur arrêts   ;1: Mensuelle ; 3: Trimestrielle
    loc_arret.CREATION   := SYSDATE;
    loc_arret.MAJ        := SYSDATE;
    loc_arret.NUMUTIL    := f_numutil(); --ce sera le gestionnaire validant la demande
    loc_arret.BASE_REGIME:= F_GET_VALUE_IN_TABLE('Montant', f_get_varchar_splited(';'||chr(10)||chr(13), loc_rappel.commentaire));
    loc_arret.RECEPTION  := TRUNC(loc_rappel.creation);--SYSDATE;--M0006669


    BEGIN
        SELECT DISTINCT 'O'
        INTO loc_arret.CONTINU
        FROM arret a, sntr_prev s, dossier_sinistre d
        WHERE (
            (loc_arret.DEBUT-2, loc_arret.FIN) OVERLAPS (a.DEBUT, a.fin)   -- dans un sens
            OR
            (a.DEBUT-2, a.fin) OVERLAPS (loc_arret.DEBUT, loc_arret.FIN)   -- ou dans l'autre
            )
        AND d.iddossier = s.iddossier
        AND a.nosin     = loc_rappel.entite;
      EXCEPTION
        WHEN OTHERS THEN
          loc_arret.CONTINU := 'N';
      END;

      INSERT INTO arret VALUES loc_arret;
      --loc_rappel.commentaire :=loc_rappel.commentaire||'Idarret : '||loc_arret.IDARRET ;
      /*UPDATE rappel set commentaire = loc_rappel.commentaire WHERE idrappel=i_idrappel;
      COMMIT;*/
      --SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
      SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_VALIDE_ADD_EVENT',   I_session  => SID, I_niv_msg  => 3,   I_msg_adm  =>   'idrappel=['||loc_rappel.idrappel||']'||'Validation de la demande automatiquement via la validation de la demande '||loc_rappel.IDRAPPEL||', référence externe : '||loc_rappel.REFERENCE||' Idarret : '||loc_arret.IDARRET,  I_idligne  => 2);

      INSERT INTO HISTO_RAPPEL (IDRAPPEL,
								IDHISTORAPPEL,
								CONTEXTE,
								ENTITE,
								TYPE,
								REFERENCE,
								REVISION,
								CREATION,
								CREATEUR,
								MAJ,
								MODIFICATEUR,
								ETAT,
								RESPONSABLE,
								COMMENTAIRE)
			VALUES (loc_rappel.IDRAPPEL,
                                      V_IDHISTORAPPEL,
                                      loc_rappel.CONTEXTE,
                                      loc_rappel.ENTITE,
                                      loc_rappel.TYPE,
                                      loc_rappel.REFERENCE,
                                      loc_rappel.REVISION,
                                      loc_rappel.CREATION,
                                      loc_rappel.CREATEUR,
                                      sysdate,
                                      f_numutil,
                                      6,
                                      loc_rappel.RESPONSABLE,
                                     'Validation de la demande automatiquement via la validation de la demande '||loc_rappel.IDRAPPEL||', référence externe : '||loc_rappel.REFERENCE||' Idarret : '||loc_arret.IDARRET);
      COMMIT;

  ELSIF /*loc_nat_trouv =1*/loc_code_nat IS NOT NULL THEN--cloture du sinitre
    INSERT INTO HISTO_SNTR_PREV (NOSIN,DEBUT,ETAT,MOTIF,NUMUTIL,SAISIE)
    VALUES (loc_rappel.entite,trunc(loc_date_cloture),2,loc_motif,f_numutil,trunc(sysdate));

    UPDATE sntr_prev SET fin=trunc(loc_date_cloture), motif=loc_motif WHERE nosin=loc_rappel.entite;
    COMMIT;

  END IF;

 RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_VALIDE_ADD_EVENT',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
      I_idligne  => 2);

    RETURN 2218;
END F_VALIDE_ADD_EVENT;

/******************************************************************************/
FUNCTION RAD_ADHESION ( i_numporte        IN NUMBER,
                        i_id_type         IN TYPE_FLUX.ID_TYPE%TYPE,
                        i_idDemande_ext   IN NUMBER,
                        i_numcli          IN NUMBER,
                        i_numindiv        IN INDIVIDU.NUMINDIV%TYPE,
                        i_typeadhesion    IN VARCHAR2,
                        i_etat            IN NUMBER,
                        i_motif           IN NUMBER,
                        i_debut           IN DATE,
                        i_risque          IN NUMBER) RETURN GENERIQUE_WS_RESP
IS
    exc_param         EXCEPTION;
    exc_ctrl_fonc     EXCEPTION;

    loc_rappel        RAPPEL%ROWTYPE;
    l_context_rappel  NUMBER;
    loc_numutil       UTILISATEURS.NUMUTIL%TYPE;
    l_code_demande    NUMBER;
    l_info_exist      NUMBER :=0;
    i                 NUMBER := 1;
    l_is_ok_to_rad    NUMBER :=0;
    lib_risque        VARCHAR(50);
    loc_motif         NUMBER;
    loc_courrier      NUMBER;
    loc_cotis         NUMBER:=0;

    loc_ano           NUMBER;
    loc_warning       NUMBER;
    loc_action        NUMBER :=0;
    loc_idligne       NUMBER :=0;
    lib_courr         VARCHAR2(45);
    cpt_deja_resil    NUMBER :=0;
	v_prod_motif      libelle_bis.code%TYPE;
	v_numgar          NUMBER;
	v_adhe_vig_exist  NUMBER;

     CURSOR c_adhesion ( p_numindiv individu.numindiv%TYPE , p_numcli contrat.numcli%TYPE, p_risque NUMBER) IS --toutes les adhesions sante et prev en vigueur de l'assuré sur les contrats du numcli concerné
      SELECT distinct a.idadhesion ,
                    null type_mouvement ,
                    null maj,
                    a.numgar,
                    ad.date_adhe datapli,
                    ad.date_fin_adhe datper ,
                    pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe,sysdate),  a_type=>1)   etat_adhe,
                    pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe,sysdate),  a_type=>2) motif_adhe,
                    ad.mregl,
                    cr.college ,
                    cr.refcie ,
                    cr.numprod,
                    ad.date_adhe,
                    a.typfor
      FROM adhesion a, adhe_cntrt ad, contrat cr
      WHERE a.idadhesion = ad.idadhesion
      --AND a.numindiv = ad.numadhe
      AND ad.numadhe = p_numindiv
      AND cr.numgar = a.numgar
      and cr.numcli = p_numcli
      AND typfor = NVL(decode(p_risque,0,null,p_risque),typfor)--risque 0 sante et/ou prev, risque 1 uniquement sante, risque 2 uniquement prev--nvl(decode(p_risque,1,1,2,2,null),typfor)
      AND a.datapli <> NVL(a.datper,e2d('01/01/1900'))
	  AND trunc(a.datapli) <= trunc(i_debut) --On exclut les adhésions qui sont ouvertes après la date de radiation. Possibilité de radier à la date de debut de l'adhesion M0006909 ajout de = sur ce filtre
      AND pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe, add_months(sysdate,-3)),  a_type=>1) = 1 --en vigueur
      ORDER BY a.typfor, ad.date_adhe desc,a.idadhesion desc
      ;
  BEGIN

  l_code_demande := get_code_demande(i_id_type,i_numporte); --porte 27 Espace RH
  -- creation de l'événement dans la table rappel
  -- Récuperation du  code rappel
  SELECT sens INTO l_context_rappel FROM libelle WHERE mnemo ='TYPERAPPEL' AND CODE = l_code_demande;  --13 adhesion
  BEGIN
    SELECT numutil INTO loc_numutil FROM porte_param WHERE numporte =i_numporte;
  EXCEPTION
    WHEN OTHERS THEN loc_numutil:=f_numutil;
  END;

  --Controle des paramètres entrants
  IF i_numcli  IS NULL OR i_numindiv IS NULL OR i_typeadhesion IS NULL OR i_etat IS NULL OR i_motif IS NULL OR i_debut IS NULL OR i_risque IS NULL THEN
    loc_rappel.code_err:= 2385; --demande soumise incomplete
    loc_rappel.etat:=4;--rejeté
    RAISE exc_param; --reponse KO
  END IF;

  /*IF i_etat <>3 OR i_typeadhesion <> 'C' OR i_risque <>0 THEN --PEUT EVOLUER on sait jamais
    loc_rappel.code_err:= 2397; --integration imposs. car une donnée est incoher.
    loc_rappel.etat:=4;--rejeté
    RAISE exc_param; --reponse KO
  END IF;*/
  BEGIN
    SELECT code INTO loc_motif FROM LIBELLE
    WHERE mnemo LIKE 'HISTO_ADHE'
    AND code =i_motif;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      loc_rappel.code_err:= 2402; --Le motif est inconnu
      loc_rappel.etat:=4;--rejeté
      Raise exc_param;
  END;
  FOR rec_adhesion IN c_adhesion (i_numindiv, i_numcli,i_risque) LOOP
    IF i_debut<rec_adhesion.datapli THEN
      loc_rappel.code_err:= 2403; -- date saisie doit être postérieure à la date d''affiliation du salarié
      loc_rappel.etat:=4;--rejeté
      RAISE exc_param; --reponse KO
    END IF;
  END LOOP;


  SELECT IDRAPPEL.NEXTVAL INTO loc_rappel.IDRAPPEL FROM DUAL;

  loc_rappel.contexte    := l_context_rappel;
  loc_rappel.type        :=  l_code_demande;
  loc_rappel. reference  := i_idDemande_ext;
  loc_rappel.creation    := sysdate;
  loc_rappel.maj         := null;
  loc_rappel.createur    := loc_numutil;
  loc_rappel.etat        := 1 ;
  loc_rappel.origine     := i_numporte; --27 espace RH
  loc_rappel.DATEEFFET   := i_debut; --sysdate; M0006901
  loc_rappel.numassu     := i_numindiv;
  loc_rappel.numbene     := i_numindiv;
  loc_rappel.numcli      := i_numcli;

--Les modèles de courriers selon le profil
  FOR rec_adhesion IN c_adhesion(i_numindiv, i_numcli,i_risque) LOOP
	BEGIN
		--recherche du numero de courrier selon le numproduit et le motif de résil.
		SELECT TO_CHAR(LPAD(decode(rec_adhesion.numprod,272,272,0),5,0)||LPAD(i_motif,4,0)) INTO v_prod_motif FROM dual;
		SELECT  sens /*(qui est le numcourrier)*/ INTO loc_courrier FROM libelle_bis WHERE mnemo LIKE 'MOTPRDCOUR' and substr(code,1,9) = v_prod_motif;
	EXCEPTION
		WHEN OTHERS THEN v_prod_motif :=null; loc_courrier :=null;
		PK_trace.P_INS_journal_adm (I_nom_traitement => 'PK_WEB_MAJ.RAD_ADHESION',
									I_session  => SID,
									I_niv_msg  => 3,
									I_msg_adm  => 'Absence de paramétrage produit-motif pour courrier ou cas d''un profil 5. Motif :'||i_motif||' produit '||rec_adhesion.numprod,
									I_idligne  => loc_idligne+1);
	END;
    EXIT;
  END LOOP;

  SELECT decode (i_risque, 0, 'Santé/Prévoyance', 1, 'Santé', 2,'Prévoyance', 'Indéterminé') INTO lib_risque FROM DUAL;
  BEGIN
    SELECT lib_nom INTO lib_courr
    FROM param_texte
    WHERE numrelance= loc_courrier
    AND CODE=4 --adhesion
    AND contexte=99
    AND type_texte=1;
  EXCEPTION
    WHEN OTHERS THEN  lib_courr := 'Indéterminé';
  END;

  loc_rappel.commentaire := 'Etat : '                 ||  pk_libelle.f_lib('ET_ADHE',i_etat) ||';'|| CHR(13)||CHR(10)||
                             'Motif : '                || i_motif ||'-'||pk_libelle.f_lib('HISTO_ADHE',i_motif)||';'|| CHR(13)||CHR(10)||
                             'Début :'                 || d2e(i_debut) ||';'||CHR(13)||CHR(10)||
                             'Risque : '               || lib_risque||';'|| CHR(13)||CHR(10)||
                             'Type adhésion : '        || i_typeadhesion||';' ;

  FOR rec_adhesion IN c_adhesion(i_numindiv, i_numcli,i_risque) LOOP
    loc_rappel.entite := rec_adhesion.idadhesion; --entité alimentée avec la première adhesion santé trouvé, si pas de santé, on prend la prevoyance
	EXIT;
  END LOOP;

  IF loc_rappel.entite IS NULL THEN -- aucune adhésion trouvée
    loc_rappel.code_err := 2404;--L''affiliation du salarié est déjà résiliée
	RAISE exc_ctrl_fonc;
  END IF;

  --exlusion du périmètre de l'envoi des courriers des radiations prévoyance
  select cr.type_contrat into v_numgar -- 1 pour sante et 2 prevoyance
  from contrat_ref cr, adhe_cntrt ad
  where ad.idadhesion=loc_rappel.entite
  and ad.numgar=cr.numgar;


  --Controle sur la présence d'une adhesion santé en vigueur ou en instance avec une date debut postérieur à la date de résiliation sur un autre contrat SANTE
	select count(distinct ad.idadhesion) into v_adhe_vig_exist
	from adhe_cntrt ad, adhesion a, histo_adhesion ha, contrat_ref cr
	where ad.numadhe= i_numindiv --462840
	and ad.idadhesion=a.idadhesion
	and ad.numgar=cr.numgar
	and a.numgar in (select cr.numgar
	from contrat_ref cr where cr.type_contrat = 1 )-- sur contrat santé et pas de filtre sur le souscripteur
	and ha.etat in (0,1)
	AND trunc(a.datapli) <> NVL(a.datper,e2d('01/01/1900'))
	and trunc(a.datapli)>trunc(i_debut)
	and pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe, sysdate),  a_type=>1) in (0,1) --en vigueur ou en instance
	;
   --RG l'état de la demande en fonction de la demat de l'assuré ou si profil 5, ou si radiation sur prévoyance uniquement ou s'il ya une autre adhesion en vig/instance postérieure à la radiation, alors etat=traité car pas de courrier, ni de mail pour ces cas
  IF PK_MAIL.CHECK_DEMAT_INDIV(i_numindiv) = 1 OR loc_courrier IS NULL OR v_numgar =2 OR v_adhe_vig_exist > 0 THEN  -- demat ou profil 5 ou prevoyance ou s'il ya une autre adhesion en vig/instance postérieure à la radiation
    loc_rappel.etat :=3;--traité --> Résiliation + éligible au mail de masse à J+1

  ELSE
    loc_rappel.etat :=1; --la demande doit être traitée manuellement par le gestionnaire
  END IF;

  IF loc_rappel.etat=1 THEN  -- courrier pour les profils 1,2,3 et 4, et pour radiation santé
    loc_rappel.commentaire := loc_rappel.commentaire||CHR(13)||CHR(10)||'Courrier à générer : '||loc_courrier||'-'||lib_courr||';';
  END IF;
  --SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
  INSERT INTO rappel VALUES loc_rappel;
  COMMIT;

  IF  loc_rappel.etat=4 THEN
    RETURN GET_RESP_KO(i_numindiv,null,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
  END IF;
  --RG Si motif 113 la demande est à l'état nouveau
  IF i_motif = 113 THEN
    loc_rappel.etat :=1; --la demande doit être traitée manuellement par le gestionnaire
  END IF;

  IF loc_rappel.etat = 3 OR i_motif <> 113 THEN
  --traitement de radiation-
    IF i_etat = 3 THEN --radiation = résiliation des adhesions de l'assuré principal et la fermeture des couvertures prev. et/ou santé
      loc_action := 1;
    ELSE
      loc_action := 2;--SUSPENSION
    END IF;
    FOR rec_adhesion IN c_adhesion(i_numindiv, i_numcli,i_risque) LOOP

      IF rec_adhesion.datper IS NULL THEN
          P_GEST_RADIA_ADHESION( rec_adhesion.idadhesion
                                , i_numindiv
                                ,i_debut
                                ,i_motif
                                ,i_etat
                                ,loc_numutil
                                , 1
                                , loc_action
                                ,loc_ano
                                ,loc_warning
                                );

         /* IF loc_ano IS NOT NULL THEN --gestion de l'echec de l' annulation des cotisations emises
            PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_GEST_RADIA_ADHESION',
                                              I_session  => SID,
                                              I_niv_msg  => 3,
                                              I_msg_adm  => 'Adhésion '||rec_adhesion.idadhesion||' non radiée, présence de cotisations émises ou prélevées ou encours',
                                              I_idligne  => loc_idligne+1);
            loc_rappel.code_err := 2405;--Une/plusieurs adhésion(s) non radiée(s), présence de cotisations émises ou prélevées ou encours
            loc_rappel.etat := 1;
            SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
          ELSIF loc_warning=122 THEN --cotisation previsionnelles emises non annulées
            PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_GEST_RADIA_ADHESION',
                                              I_session  => SID,
                                              I_niv_msg  => 3,
                                              I_msg_adm  => 'Adhésion '||rec_adhesion.idadhesion||' Echec de l''annulation des cotis. previsionnelles',
                                              I_idligne  => loc_idligne+1);
            loc_rappel.code_err := 2406;
            loc_rappel.etat := 1;
            SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
          END IF;
		  Suite au mail de Corinne   lorsqu’une cotisation est émise/encours, la radiation doit être traitée en automatique,
          car nous ne pouvons pas remboursé de façon anticipée une cotisation, avant le traitement du fichier des impayés.
          Il faut donc forcer l’alerte mais uniquement pour les demandes de radiation dont l’origine est l’EE. */
      ELSE
        cpt_deja_resil := cpt_deja_resil+1;
        PK_trace.P_INS_journal_adm (I_nom_traitement => 'PK_WEB_MAJ.RAD_ADHESION',
                                  I_session  => SID,
                                  I_niv_msg  => 3,
                                  I_msg_adm  => 'idrappel: '||loc_rappel.idrappel||' adhésion déjà resiliée : '||rec_adhesion.idadhesion,
                                  I_idligne  => loc_idligne+1);
      END IF;

    END LOOP;
    IF cpt_deja_resil >0 THEN
      loc_rappel.code_err := 2404;--L''affiliation du salarié est déjà résiliée
      loc_rappel.etat := 4;
      RAISE exc_ctrl_fonc;
    END IF;
  END IF;--fin traitement de radiation
   --Les mails sont générés par pk_mail.p_charge_resil
  --PK_WS_WEB_MAJ_BACK.P_MAIL_RECEPTION(i_numindiv, l_code_demande, l_context_rappel, loc_rappel.entite); -- création du mail accusé de reception
  RETURN PK_WS_WEB_MAJ_BACK.GET_RESP_OK(i_numindiv,null,i_idDemande_ext, l_code_demande);

EXCEPTION
 WHEN exc_param OR exc_ctrl_fonc THEN
      SET_RAPPEL_ERREUR (loc_rappel.idrappel, loc_rappel.code_err, loc_rappel.etat);
      RETURN GET_RESP_KO(i_numindiv,i_numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(loc_rappel.code_err,1));
 WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'PK_WEB_MAJ.RAD_ADHESION',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
    I_idligne  => loc_idligne+1);
  SET_RAPPEL_ERREUR (loc_rappel.idrappel, 2184, 4);
  RETURN GET_RESP_KO(i_numindiv,i_numindiv,i_idDemande_ext, l_code_demande,pk_trace.F_AFF_mess_err(2184,1));

END RAD_ADHESION;

/*----------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GEST_RADIA_ADHESION                                     */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion de la radiation et suspension        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_GEST_RADIA_ADHESION( /*P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                            , P_AFFIL_PORTE_ADH  IN      AFFIL_PORTE_ADH%ROWTYPE,*/
                            p_idadhesion        IN adhesion.idadhesion%TYPE
                            ,p_numindiv             IN individu.numindiv%TYPE
                            ,p_debut                IN DATE
                            ,p_motif            IN   NUMBER
                            , p_etat_adhesion   IN   ADHESION.ETAT%TYPE
                            ,p_numutil          IN NUMBER
                            --, P_flag_newindiv IN      NUMBER
                            , p_ctrlcot         IN   NUMBER
                            ,p_type_action      IN   NUMBER
                            , p_ano             OUT  NUMBER
                            , p_warning         OUT  NUMBER
                            )

IS

  --loc_AFFIL_TRACE         AFFIL_TRACE%ROWTYPE;
  loc_idhistoadhe         HISTO_ADHESION.IDHISTOADHE%TYPE;
  loc_cotis               NUMBER:=0; -- flag de cotisations saisies
  loc_date_adhe           ADHE_CNTRT.DATE_ADHE%TYPE;
  loc_fin_adhe            ADHE_CNTRT.DATE_FIN_ADHE%TYPE;
  loc_numgar              ADHE_CNTRT.NUMGAR%TYPE;
  loc_ligne               NUMBER :=0;

  -- exception
  exc_cotisation          EXCEPTION;
  --exc_cot_emis            EXCEPTION;
  --exc_cot_prelev          EXCEPTION;
  --exc_cot_affec           EXCEPTION;
  --exc_susp_exist          EXCEPTION;
  --exc_resil_exist         EXCEPTION;
  --exc_resil_newindiv      EXCEPTION;
  --exc_susp_newindiv       EXCEPTION;
  exc_resil               EXCEPTION;
  --exc_histo_resil         EXCEPTION;
  exc_suspension          EXCEPTION;

BEGIN

  /*IF F_ETAT_ADHE(P_AFFIL_PORTE_ADH.idadhesion , E2D(P_AFFIL_PORTE.DEBEFF))=P_etat_adhesion
     AND P_AFFIL_PORTE.TYPE_MVT = 3 THEN
      RAISE exc_susp_exist; -- Adhésion déjà suspendu
  ELSIF F_ETAT_ADHE(P_AFFIL_PORTE_ADH.idadhesion , E2D(P_AFFIL_PORTE.FINCON))=P_etat_adhesion
     AND P_AFFIL_PORTE.TYPE_MVT = 5 THEN
      RAISE exc_resil_exist; -- Adhésion déjà résiliée
  END IF;*/

 /* -- 2) Vérification que le salarié n est pas nouveau dans le système suite à l import DSN
  IF P_flag_newindiv = 1 AND P_AFFIL_PORTE_ADH.idadhesion IS NULL THEN
    IF P_AFFIL_PORTE.TYPE_MVT = 3 THEN
      RAISE exc_susp_newindiv; -- Suspension d un nouveau salarié
    ELSIF P_AFFIL_PORTE.TYPE_MVT = 5 THEN
      RAISE exc_resil_newindiv; -- Résiliation d un nouveau salarié
    END IF;
  END IF;*/

  --------------------------------------------------------------------------------
  -- 3) Résiliation de l'adhésion
  --------------------------------------------------------------------------------
  IF p_type_action = 1 THEN--IF P_AFFIL_PORTE.TYPE_MVT IN (5,7,10) THEN

    IF P_ctrlcot =1 THEN
      --CTRLRESCOT
      -- Vérification de la présence de cotisation engagée dans un processus de gestion
      P_VERIF_ANNUL_COTIS_ADH(/*P_AFFIL_PORTE, /*P_AFFIL_PORTE_ADH.idadhesion*/p_idadhesion, p_numindiv, p_debut,loc_cotis);
      --P_INS_journal(3,' P_GEST_RADIA_ADHESION adhesion :'||p_idadhesion||':'||loc_cotis);
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_GEST_RADIA_ADHESION',
                                  I_session  => SID,
                                  I_niv_msg  => 1,
                                  I_msg_adm  => ' P_GEST_RADIA_ADHESION adhesion :'||p_idadhesion||':'||loc_cotis,
                                  I_idligne  => loc_ligne+1);
      /*IF loc_cotis = 1 THEN --RKO M0006910
        RAISE exc_cot_prelev;
      ELSIF loc_cotis = 2 THEN
        RAISE exc_cot_emis;
      ELSIF loc_cotis = 3 THEN
        RAISE exc_cot_affec;
      ELSIF loc_cotis = 5 THEN
        RAISE exc_cotisation;
      END IF;*/
    END IF;

    --************** Résiliation de l'adhésion **************--
    --P_AFFIL_PORTE.MOTIF:= NVL(f_get_transco('DSN', 'HISTO_ADHE',NVL(P_AFFIL_PORTE.MOTIFS,P_AFFIL_PORTE.MOTIFA),1),P_AFFIL_PORTE.MOTIFS);

    BEGIN
      SELECT DATE_ADHE INTO loc_date_adhe FROM ADHE_CNTRT WHERE IDADHESION  = /*P_AFFIL_PORTE_ADH.idadhesion*/p_idadhesion;
    EXCEPTION
       WHEN OTHERS THEN RAISE exc_resil;
    END;

    --loc_fin_adhe:=E2D(NVL(P_AFFIL_PORTE.FINCON,P_AFFIL_PORTE.DEBEFF));
    --ABO 30/06/2017 contrôle si adhésion bien antérieure au mouvement
    IF loc_date_adhe <= /*loc_fin_adhe*/p_debut THEN

      select numgar INTO loc_numgar
      FROM adhe_cntrt
      WHERE idadhesion =p_idadhesion;
      PK_TRANSFERT.p_resilie_adhe( loc_numgar
                                 , p_idadhesion
                                 , p_numindiv
                                 , p_motif
                                 , p_debut
                                 , p_numutil
                                 ,1) ;

      -- Mise à jour du Motif dans AFFIL_PORTE
      /*PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                           , P_ano);
      IF P_ano > 0 THEN
        RAISE exc_resil;
      END IF;*/
      -- recherche de la clef idhistoadhe necessaire a l annulation de la résiliation
      SELECT NVL(MAX(a.idhistoadhe),0)
        INTO loc_idhistoadhe
        FROM HISTO_ADHESION a
       WHERE A.IDADHESION=p_idadhesion--P_AFFIL_PORTE_ADH.idadhesion
         AND TRUNC(a.datsai)=TRUNC(SYSDATE)       -- date d insertion dans histo_adhesion
        AND a.etat=3;

      --si la résiliation s'est bien terminée :
      P_ANNUL_COT_PREVI_ADH(/*P_AFFIL_PORTE, P_AFFIL_PORTE_ADH.*/p_idadhesion,/*loc_fin_adhe*/p_debut,P_ctrlcot, loc_cotis);
      IF loc_cotis = 4 THEN
        P_warning:=122;
      END IF;
    END IF;

  --------------------------------------------------------------------------------
  -- 4) Suspension de l'adhésion
  --------------------------------------------------------------------------------
  ELSIF p_type_action = 2 THEN--ELSIF P_AFFIL_PORTE.TYPE_MVT = 3 THEN

    SELECT IDHISTOADHE.nextval
    INTO loc_idhistoadhe
    FROM DUAL;
    BEGIN
      INSERT INTO HISTO_ADHESION(IDADHESION, DEBUT, DATSAI, ETAT, MOTIF, NUMUTIL,IDHISTOADHE)
        VALUES(/*P_AFFIL_PORTE_ADH.idadhesion*/p_idadhesion, /*E2D(P_AFFIL_PORTE.DEBEFF)*/p_debut,SYSDATE, P_etat_adhesion, /*P_AFFIL_PORTE.MOTIF*/p_motif, /*P_AFFIL_PORTE.USERNAME_FORCAGE*/p_numutil,loc_idhistoadhe);
    EXCEPTION
      WHEN exc_cotisation THEN
        RAISE exc_cotisation;
      WHEN OTHERS THEN
        RAISE exc_suspension;
    END;

  END IF;

EXCEPTION
  /*WHEN exc_cot_prelev THEN
    P_ano:=120; -- Cotisations issues de prélévements
  WHEN exc_cot_emis THEN
    P_ano:=118; -- Cotisations sur l adhésion optionnelle
  WHEN exc_cot_affec THEN
    P_ano:=119; -- Cotisations sur l adhésion optionnelle
  */WHEN exc_cotisation THEN
    P_ano:=75; -- Cotisations en cours à la date de résiliation
  WHEN exc_resil THEN
    P_ano:=35;  -- Impossible de résilier l''adhésion
  WHEN exc_suspension THEN
    P_ano:=73;  -- Impossible de suspendre l''adhésion
  WHEN OTHERS THEN
    --P_INS_journal(3,' Erreur : P_GEST_RADIA_ADHESION impossible:'||SUBSTR(SQLERRM,1,132));
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_GEST_RADIA_ADHESION',
                                  I_session  => SID,
                                  I_niv_msg  => 3,
                                  I_msg_adm  => 'Erreur : P_GEST_RADIA_ADHESION impossible:'||SUBSTR(SQLERRM,1,132),
                                  I_idligne  => loc_ligne+1);
    P_ano:=72;  -- Erreur indéterminée pour la radiation
END P_GEST_RADIA_ADHESION;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_VERIF_ANNUL_COTIS_ADH                                  */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire Annulation des cotisations des adhesions */
/*                 santé et/ou prevoyance                                   */
/* Entree       :  idadhesion,numindiv, date debut de la radiation          */
/* Retour       :  o_cotis, Message d erreur                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_VERIF_ANNUL_COTIS_ADH ( /*I_AFFIL_PORTE       IN       AFFIL_PORTE%ROWTYPE
                                   , */i_idadhesion        IN adhe_cntrt.idadhesion%TYPE
                                   ,i_numindiv             IN individu.numindiv%TYPE
                                   ,i_debut                IN DATE
                                   , o_cotis               OUT   NUMBER)
IS
  --parcourt des cotisations individuelles uniquement --TODO revoir les COMMENTAIRES
  --pour annulation d'un fichier complet en contexte, seul le cas de nouvelle affiliation
  --ayant entrainé une adhésion optionnelle cotisante indiv est concerné
  --on recherche donc dans adhe_cntrt pour un contrôle en masse nouvement 1 et 7 ou unitaire : non radiée
  CURSOR C_AFFIL (/*P_AFFIL_PORTE   AFFIL_PORTE%ROWTYPE,*/ p_idadhesion adhesion.idadhesion%TYPE, p_numindiv individu.numindiv%TYPE) IS
  SELECT DISTINCT adh.IDADHESION, adh.numadhe--, decode(P_AFFIL_PORTE.fincon,NULL,NULL, e2d(P_AFFIL_PORTE.fincon)) date_resil
    FROM adhe_cntrt adh, contrat c
   WHERE adh.numadhe = p_numindiv--P_AFFIL_PORTE.numindiv
     AND adh.numgar = c.numgar
     AND (adh.date_fin_adhe IS NULL /*OR P_AFFIL_PORTE.type_mvt IN (1,7)*/)
     AND adh.IDADHESION=NVL(P_Idadhesion,adh.IDADHESION)
     AND c.typequit<>1;--l'échéancier n'est pas au niveau contrat (on peut avoir de l'option au niveau contrat mais pas concernée car considérée comme collective)


  CURSOR C_COTIS_COMPTANT (/*P_DateResil*/p_debut DATE, p_idadhesion adhesion.idadhesion %TYPE) IS
  SELECT  qg.numquit ,qg.mt_affec_d, qg.comptant, e.datemis,p.numprelev
  FROM QTTC_GLOBAL qg
    left outer join emission e ON (e.numfact=qg.numquit AND e.codope = 4 AND e.numrelance=0)
    left outer join prelevement_detail p ON (p.numfact = qg.numquit AND p.codope = 4 )
   WHERE qg.idadhesion=p_idadhesion
     AND /*P_DateResil*/p_debut < TRUNC(qg.fin)
     AND qg.comptant <>'R'
     AND NOT EXISTS (SELECT 1 FROM facture_annul where facture_annul.numfact =  qg.numquit AND codope =4) --non déjà annulée
     AND qg.type_qttc <> 3; --non prévsionnelle

  exc_affec              EXCEPTION;
  exc_emis               EXCEPTION;
  exc_prelev             EXCEPTION;

  flag1                  NUMBER:=0;
  flag2                  NUMBER:=0;
  loc_ligne              NUMBER:=0;

BEGIN

  -- Parcours de l'ensemble des adhesions concernées par une radiation
  -- uniquement des échéanciers sur adhésions individuelles
  FOR Rec_C_AFFIL IN C_AFFIL (/*I_AFFIL_PORTE,*/i_idadhesion,i_numindiv)LOOP

     --P_INS_journal(3,'Annulation de cotisation, Assuré: '||Rec_C_AFFIL.numadhe ||' adhesion : '||Rec_C_AFFIL.IDADHESION );
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_GEST_RADIA_ADHESION',
                                  I_session  => SID,
                                  I_niv_msg  => 3,
                                  I_msg_adm  => 'Annulation de cotisation, Assuré: '||Rec_C_AFFIL.numadhe ||' adhesion : '||Rec_C_AFFIL.IDADHESION,
                                  I_idligne  => loc_ligne+1);

    FOR R_COTIS_COMPTANT IN C_COTIS_COMPTANT (/*Rec_C_AFFIL_PORTE.date_resil*/i_debut ,i_idadhesion) LOOP
      --si la cotisation est prélevée, on vérifie qu'elle n'est pas prise dans un bordereau
      IF R_COTIS_COMPTANT.numprelev IS NOT NULL THEN
        RAISE exc_prelev;

      --si au moins une cotisation est affectée, on n'annule aucune adhésion
      ELSIF NVL(R_COTIS_COMPTANT.mt_affec_d,0) >0 THEN
        RAISE exc_affec;

      --si au moins une cotisatoin est émise  , on n'annule aucune adhésion
      ELSIF R_COTIS_COMPTANT.datemis IS NOT NULL THEN
       RAISE exc_emis;
      END IF;

    END LOOP;
  END LOOP;
  o_cotis:=0;
EXCEPTION
  WHEN exc_prelev THEN o_cotis:=1;
  WHEN exc_emis THEN   o_cotis:=2;
  WHEN exc_affec THEN  o_cotis:=3;
  WHEN OTHERS THEN
    o_cotis:=5;
     --P_INS_journal(1,' Erreur: Annulation cotisation adhesion:'||SUBSTR(SQLERRM,1,132));
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_VERIF_ANNUL_COTIS_ADH',
                                  I_session  => SID,
                                  I_niv_msg  => 3,
                                  I_msg_adm  => 'Erreur: Annulation cotisation adhesion:'||SUBSTR(SQLERRM,1,132),
                                  I_idligne  => loc_ligne+1);
END P_VERIF_ANNUL_COTIS_ADH;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNUL_COT_PREVI_ADH                                     */
/* Type         :  Public                                                    */
/* Description  :  Annulation des cotisations prévisionnelles lors d'une     */
/* radiation   - processus issu du webservice rad_adhesion                   */
/* Entree       :  P_numremise, numremise                                    */
/* Retour       :  o_erreur, Message d erreur                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_COT_PREVI_ADH ( --I_AFFIL_PORTE AFFIL_PORTE%ROWTYPE,
                           i_idadhesion  IN adhe_cntrt.idadhesion%TYPE--AFFIL_PORTE_ADH.IDADHESION%TYPE
                           , i_debut     IN DATE--I_DateResil
                           , i_ctrtResil IN NUMBER
                           , o_warning   OUT NUMBER) IS
--p_idadhesion,/*loc_fin_adhe*/p_debut,P_ctrlcot, loc_cotis);
  PRAGMA AUTONOMOUS_TRANSACTION;
 --on prend les régularisantes,prévionnelles et les normales
 -- on annule uniquement les cotisations dont la date de début est postérieure à la résiliation
 -- résiliation le 10/05, la quittance de mai doit être régularisée manuellement
  CURSOR C_COTIS_ANN (P_DateResil DATE, P_idadhesion adhesion.idadhesion %TYPE) IS
  SELECT  qg.numquit ,qg.mt_affec_d, qg.comptant, e.datemis,p.numprelev,qg.debut
  FROM QTTC_GLOBAL qg
    left outer join emission e ON (e.numfact=qg.numquit AND e.codope = 4 AND e.numrelance=0)
    left outer join prelevement_detail p ON (p.numfact = qg.numquit AND p.codope = 4 )
   WHERE qg.idadhesion=P_idadhesion
     AND P_DateResil < TRUNC(qg.fin)
     AND qg.comptant <>'R'
     AND NOT EXISTS (SELECT 1 FROM facture_annul where facture_annul.numfact =  qg.numquit AND codope =4) --non déjà annulée
   ORDER BY qg.debut desc
    ;

  loc_AFFIL_TRACE  AFFIL_TRACE%ROWTYPE;

  exc_annul              EXCEPTION;
BEGIN

    o_warning:=0;
    --recherche des cotisations à annuler
    FOR R_COTIS_ANN IN C_COTIS_ANN(/*I_DateResil*/i_debut,I_Idadhesion) LOOP
      BEGIN
      -- si I_ctrtResil =0, on annule que les cotisations non impliquées en trésoreie
      -- si I_ctrtResil = 1 et qu'une cotisation est impliquée en trésorerie ou émise,alors on remonte une anomalie => on annule aucune quittance
      --Dbms_Output.Put_Line(R_COTIS_ANN.numquit||'-'|| R_COTIS_ANN.mt_affec_d ||'-'|| R_COTIS_ANN.numprelev ||'-'||R_COTIS_ANN.datemis );
      IF NVL(R_COTIS_ANN.mt_affec_d,0) >0 THEN
          o_warning:=3;
      ELSIF R_COTIS_ANN.numprelev IS NOT NULL THEN
        o_warning:=1;
      ELSIF R_COTIS_ANN.datemis IS NOT NULL THEN
        o_warning:=2; --on doit pouvoir annuler une cotisation si elle n'a été que émise
      ELSIF  R_COTIS_ANN.debut < /*I_DateResil*/i_debut THEN --on annule pas la cotisation
        o_warning:=4;
      END IF;

      IF o_warning in(1,2,3,4) THEN
        IF I_ctrtResil =1 THEN
            EXIT;
        ELSIF o_warning in(1,3,4)THEN
          CONTINUE;
        END IF;
      END IF;

        INSERT INTO emission (codope, numfact, numrelance, datemis, type_doc)
        SELECT 4,R_COTIS_ANN.numquit, 99, sysdate, 1 FROM dual
        WHERE NOT EXISTS (
        SELECT 1 FROM emission
        WHERE codope = 4
        AND numfact = R_COTIS_ANN.numquit
        AND numrelance = 99
        AND type_doc = 1);

      EXCEPTION
        WHEN OTHERS THEN
          o_warning:=5;
          RAISE exc_annul;
      END;
    END LOOP;

   commit;
   EXCEPTION
    WHEN exc_annul THEN ROLLBACK;--uniqument sur cette procédure
END P_ANNUL_COT_PREVI_ADH;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_VALIDE_RAD_ADHE                                        */
/* Type         :  Public                                                    */
/* Description  :  Validation d'une demande de radiation sur la corbeille    */
/* Entree       :  P_numremise, numremise                                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

FUNCTION F_VALIDE_RAD_ADHE(i_idrappel number,i_numporte number) RETURN NUMBER
IS
  loc_rappel     rappel%ROWTYPE;
  loc_envoi      envoi%ROWTYPE;
  loc_courr_env  NUMBER;
  loc_num_courr  NUMBER;
  loc_idtext     NUMBER;
  V_IDHISTORAPPEL  HISTO_RAPPEL.IDHISTORAPPEL%TYPE;
BEGIN
  --RECUPERATION DES INFORMATIONS UTILES
  SELECT * INTO loc_rappel
  FROM rappel
  WHERE idrappel = i_idrappel;

  loc_num_courr := to_number(SUBSTR(F_GET_VALUE_IN_TABLE('Courrier à générer', f_get_varchar_splited(';'||chr(13)||chr(10), loc_rappel.commentaire)),1,2)) ; --61
  BEGIN
    SELECT idtexte INTO loc_idtext
    FROM param_texte
    WHERE numrelance=loc_num_courr
    AND CODE=4
    AND contexte=99
    AND type_texte=1;
  EXCEPTION
   WHEN no_data_found THEN
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_VALIDE_RAD_ADHE',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'Courrier inexistant dans le paramétrage courrier',
        I_idligne  => 1);

  END;
   --Recherche de courrier de radiation envoyé de moins d’un mois
  SELECT count(numenvoi) INTO loc_courr_env
  FROM envoi
  WHERE envoi.clef = loc_rappel.entite
  AND TRUNC(datemis)>TRUNC(add_months(sysdate,-1))
  AND numindiv_dest = loc_rappel.numbene
  AND idtexte = loc_idtext;

  IF loc_courr_env >0 THEN
    --on met l'état à 'traité'
    SET_RAPPEL_ERREUR(i_idrappel,null,6);
   -- SELECT MAX(IDHISTORAPPEL)+1  INTO V_IDHISTORAPPEL FROM HISTO_RAPPEL;
   SELECT IDHISTORAPPEL.NEXTVAL  INTO V_IDHISTORAPPEL FROM DUAL;--RKO M0006795
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_VALIDE_RAD_ADHE',   I_session  => SID, I_niv_msg  => 3,   I_msg_adm  =>   'idrappel=['||loc_rappel.idrappel||']'||'Validation de la demande automatiquement via la validation de la demande '||loc_rappel.IDRAPPEL||', référence externe : '||loc_rappel.REFERENCE,  I_idligne  => 2);

    INSERT INTO HISTO_RAPPEL (IDRAPPEL,
              IDHISTORAPPEL,
              CONTEXTE,
              ENTITE,
              TYPE,
              REFERENCE,
              REVISION,
              CREATION,
              CREATEUR,
              MAJ,
              MODIFICATEUR,
              ETAT,
              RESPONSABLE,
              COMMENTAIRE)
    VALUES (loc_rappel.IDRAPPEL,
            V_IDHISTORAPPEL,
            loc_rappel.CONTEXTE,
            loc_rappel.ENTITE,
            loc_rappel.TYPE,
            loc_rappel.REFERENCE,
            loc_rappel.REVISION,
            loc_rappel.CREATION,
            loc_rappel.CREATEUR,
            sysdate,
            f_numutil,
            6,
            loc_rappel.RESPONSABLE,
           'Validation de la demande automatiquement via la validation de la demande '||loc_rappel.IDRAPPEL||', référence externe : '||loc_rappel.REFERENCE);
    COMMIT;

  ELSE
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_VALIDE_RAD_ADHE',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => 'courrier manuel non effectué',
        I_idligne  => 1);
    RETURN 2408;

  END IF;
 RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_VALIDE_RAD_ADHE',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'idrappel=['||loc_rappel.idrappel||']'||substr(sqlerrm,1,132),
      I_idligne  => 2);

    RETURN 2218;
END F_VALIDE_RAD_ADHE;



END PK_WS_WEB_MAJ_BACK;
/
