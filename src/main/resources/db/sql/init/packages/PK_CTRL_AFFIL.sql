CREATE OR REPLACE PACKAGE ARTHUS."PK_CTRL_AFFIL"
AS
/*============================================================================*/
/* PACKAGE      : PK_CTRL_AFFIL.sql                                           */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 15/05/2013                                                  */
/* Description  : Package permettant l import d un fichier contenant des      */
/*                affiliations dans Arthus ainsi que l intégration des données*/
/*============================================================================*/
/* Evolution    : DSN                                                         */
/* Auteur       : JBO                                                         */
/* Date         : 06/03/2015                                                  */
/* Commentaire  : P201401001_DSN                                              */
/*============================================================================*/
/* Correction   : JBO / 22/09/2014 / Mantis 4436                              */
/*              : Mantis 5417 le 19/10/2017                                   */
/*============================================================================*/
/* Correction   : MUR / 29/11/2017 / Mantis 5437                              */
/*              : correction fonction recherche garantie                      */
/*============================================================================*/
/* Correction   : MUR / 03/01/2018 / Mantis 5469                              */
/*              : correction P_VERIF_ANNUL_COTISATION                         */
/*============================================================================*/
/* Correction   : M0005538: DSN-date d'historique création adhésion, individu */
/*                pers_adresse, histo_phys, val_variable fausse               */
/*============================================================================*/
/* Correction   : MUR / 15/05/2018 / Mantis 5606                              */
/*              : enrichissement affil_trace                                  */
/*============================================================================*/


TYPE T_RG_TAB IS TABLE OF LIBELLE_BIS.LIBELLE%TYPE INDEX BY LIBELLE_BIS.CODE%TYPE;


FUNCTION F_INS_AFFIL_PORTE(P_AFFIL_PORTE      AFFIL_PORTE%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_AFFIL_PORTE_FORCAGE(P_AFFIL_PORTE_FORCAGE   IN OUT   AFFIL_PORTE_FORCAGE%ROWTYPE/*,p_journal IN OUT JOURNAL_ADM%ROWTYPE*/)
RETURN BOOLEAN;

PROCEDURE P_AFFIL_ANO( P_AFFIL_PORTE      AFFIL_PORTE%ROWTYPE
                      ,P_ano              AFFIL_ANO.NUMANO%TYPE
                      , P_etat             AFFIL_ANO.ETATANO%TYPE
                      , P_date             AFFIL_ANO.DATANO%TYPE);
PROCEDURE P_INS_AFFIL_ANO(P_AFFIL_ANO      AFFIL_ANO%ROWTYPE);

PROCEDURE P_DEL_AFFIL_ANO( i_numremise    IN       AFFIL_ANO.NUMREMISE%TYPE
                         , i_numligne     IN       AFFIL_ANO.NUMLIGNE%TYPE
                         , i_numporte     IN       AFFIL_ANO.NUMPORTE%TYPE);
PROCEDURE P_DEL_AFFIL_ANO_ETAT( i_numremise    IN       AFFIL_ANO.NUMREMISE%TYPE
                               , i_numporte     IN       AFFIL_ANO.NUMPORTE%TYPE
                               , i_etat IN AFFIL_PORTE.ETAT%TYPE);

FUNCTION P_CTRL_SOCIETE(  i_numporte     IN       AFFIL_PORTE.NUMPORTE%TYPE
                        , i_numremise    IN       AFFIL_PORTE.NUMREMISE%TYPE
                        , i_nuligne      IN       AFFIL_PORTE.NUMLIGNE%TYPE
                        , i_codadh       IN       AFFIL_PORTE.ENTREPRISE%TYPE
                        , i_Entreprise   IN       AFFIL_PORTE.ENTREPRISE%TYPE)
RETURN NUMBER;

FUNCTION F_FIND_SOCIETE( I_SIREN   IN  AFFIL_PORTE.ENTREPRISE%TYPE
                       , I_ETABLI  IN  AFFIL_PORTE.ETABLI%TYPE
                       , O_Erreur   OUT NUMBER)
RETURN NUMBER;

PROCEDURE P_MAJ_AFFIL_PORTE_ETAT( i_numremise    IN       AFFIL_PORTE.NUMREMISE%TYPE
                                , i_etat         IN       AFFIL_PORTE.ETAT%TYPE
                                , i_numligne     IN       AFFIL_PORTE.NUMLIGNE%TYPE
                                , i_numporte     IN       AFFIL_PORTE.NUMPORTE%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE( P_AFFIL_PORTE    IN       AFFIL_PORTE%ROWTYPE);
-- surcharge
PROCEDURE P_MAJ_AFFIL_PORTE_AYD( P_AFFIL_PORTE_AYD    IN       AFFIL_PORTE_AYD%ROWTYPE);
PROCEDURE P_MAJ_AFFIL_PORTE_AYD( P_AFFIL_PORTE_ADH    IN       AFFIL_PORTE_ADH%ROWTYPE);
-- surcharge

PROCEDURE P_MAJ_AFFIL_FICHIER_NUMCLI( I_AFFIL_FICHIER      IN       AFFIL_FICHIER%ROWTYPE);
PROCEDURE P_MAJ_AFFIL_PORTE_ADH( P_AFFIL_PORTE_ADH    IN       AFFIL_PORTE_ADH%ROWTYPE);
-- surcharge
PROCEDURE P_MAJ_AFFIL_PRT_ADH_INDIV ( P_AFFIL_PORTE_ADH    IN       AFFIL_PORTE_ADH%ROWTYPE);
PROCEDURE P_MAJ_AFFIL_PRT_ADH_INDIV ( P_AFFIL_PORTE_AYD    IN       AFFIL_PORTE_AYD%ROWTYPE);
-- fin surcharge
PROCEDURE P_MAJ_AFFIL_PORTE_ADH_NUMGAR( P_AFFIL_FICHIER       IN  AFFIL_FICHIER%ROWTYPE
                                       , P_REF_EXT_CNTRT     IN  AFFIL_PORTE_CNTRT.REF_EXT_CNTRT%TYPE
                                       , P_CODE_POP          IN  AFFIL_PORTE_ADH.CODE_POP%TYPE
                                       , P_NUMGAR            IN  AFFIL_PORTE_ADH.NUMGAR%TYPE);
PROCEDURE P_MAJ_AFFIL_PORTE_ADH_NUMFOR( P_AFFIL_FICHIER       IN  AFFIL_FICHIER%ROWTYPE
                                       , P_NUMGAR             IN  AFFIL_PORTE_ADH.NUMGAR%TYPE
                                       , P_CODE_OPT          IN  AFFIL_PORTE_ADH.CODE_OPT%TYPE
                                       , P_NUMFOR            IN  AFFIL_PORTE_ADH.REFGARANTIE%TYPE);
PROCEDURE P_MAJ_AFFIL_PORTE_CNTRT( P_AFFIL_PORTE_CNTRT     IN       AFFIL_PORTE_CNTRT%ROWTYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_QTTC( P_NUMLIGNE     IN       AFFIL_PORTE_QTTC.NUMLIGNE%TYPE
                                , P_NUM_QTTC     IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                , P_NUMREMISE    IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                , P_NUMPORTE     IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                , P_NUMQUIT      IN       AFFIL_PORTE_QTTC.NUMQUIT%TYPE
                                );

PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_ELT( P_NUMLIGNE     IN       AFFIL_PORTE_QTTC.NUMLIGNE%TYPE
                                    , P_NUM_QTTC     IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                    , P_NUMREMISE    IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                    , P_NUMPORTE     IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                    , P_ID_VARIABLE  IN       AFFIL_PORTE_QTTC_ELT.ID_VARIABLE%TYPE
                                    );
PROCEDURE P_MAJ_ID_VAR_QTTC_ELT(  P_NUMREMISE    IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                , P_NUMPORTE     IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                , P_ELT          IN       AFFIL_PORTE_QTTC_ELT.TYPE_ELT%TYPE
                                , P_NUMGAR       IN       CONTRAT.NUMGAR%TYPE
                                , P_ID_VARIABLE  IN       AFFIL_PORTE_QTTC_ELT.ID_VARIABLE%TYPE
                                 );
PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_STATUT(  P_NUMLIGNE     IN       AFFIL_PORTE_QTTC.NUMLIGNE%TYPE
                                        , P_NUM_QTTC     IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                        , P_NUMREMISE    IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                        , P_NUMPORTE     IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                        , P_STATUT       IN       AFFIL_PORTE_QTTC.STATUT%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_NUMQUIT( P_NUMREMISE     IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                        , P_NUMPORTE      IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                        , P_NUM_QTTC      IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                        , P_NUMQUIT       IN       AFFIL_PORTE_QTTC.NUMQUIT%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_ELTVAR( P_NUMREMISE     IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                       , P_NUMPORTE      IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                       , P_NUM_QTTC      IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                       , P_ID_VARIABLE   IN       AFFIL_PORTE_QTTC_ELT.ID_VARIABLE%TYPE
                                       , P_VALEUR        IN       AFFIL_PORTE_QTTC_ELT.VALEUR%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_VALEUR( P_NUMREMISE     IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                       , P_NUMPORTE      IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                       , P_NUM_QTTC      IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                       , P_somme_bases   IN       AFFIL_PORTE_QTTC_ELT.VALEUR%TYPE);

/*PROCEDURE P_MAJ_INDIVIDU_NUMASSU( P_AFFIL_PORTE_ADH  IN        AFFIL_PORTE_ADH%ROWTYPE
                                , P_ano                OUT  AFFIL_ANO.NUMANO%TYPE);*/

FUNCTION F_FIND_PARTICIPANT ( P_matorg   IN   AFFIL_PORTE.NUMSSA%TYPE DEFAULT NULL
                            , P_nom      IN   AFFIL_PORTE.NOMSAL%TYPE DEFAULT NULL
                            , P_datnais  IN   AFFIL_PORTE.DATNAI%TYPE DEFAULT NULL
                            , P_numindiv IN   AFFIL_PORTE.NUMINDIV%TYPE DEFAULT NULL)
RETURN NUMBER;

FUNCTION F_FIND_SALARIE ( P_matorg   IN   AFFIL_PORTE.NUMSSA%TYPE DEFAULT NULL
                        , P_nom      IN   AFFIL_PORTE.NOMSAL%TYPE DEFAULT NULL
                        , P_prenom   IN   AFFIL_PORTE.PRENOM%TYPE DEFAULT NULL
                        , P_nomnais  IN   AFFIL_PORTE.NOMNAIS%TYPE DEFAULT NULL
                        , P_datnais  IN   AFFIL_PORTE.DATNAI%TYPE DEFAULT NULL
                        , P_rang     IN   AFFIL_PORTE_AYD.RANG%TYPE DEFAULT 1
                        , O_erreur   OUT  NUMBER)
RETURN NUMBER;

FUNCTION F_FORMAT ( P_Chaine   IN   VARCHAR2)
RETURN  INDIVIDU.NOM%TYPE;

FUNCTION F_FORMAT2 ( P_Chaine   IN   INDIVIDU.NOM%TYPE)
RETURN  INDIVIDU.NOM%TYPE;

FUNCTION F_VERIF_COLONNE ( P_TABLE   IN   USER_TAB_COLUMNS.TABLE_NAME%TYPE
                         , P_COLONNE IN   USER_TAB_COLUMNS.COLUMN_NAME%TYPE)
RETURN  USER_TAB_COLUMNS.DATA_LENGTH%TYPE;

FUNCTION F_FIND_MATORG ( P_numindiv   IN   INDIVIDU.NUMINDIV%TYPE)
RETURN INDIVIDU.MATORG%TYPE;

PROCEDURE P_INIT_AFFIL_PORTE( P_numporte     IN       AFFIL_PORTE.NUMPORTE%TYPE
                            , P_numremise    IN       AFFIL_PORTE.NUMREMISE%TYPE
                            , P_numligne     IN       AFFIL_PORTE.NUMLIGNE%TYPE
                            , P_AFFIL_PORTE  IN OUT   AFFIL_PORTE%ROWTYPE
                            , P_ano             OUT   AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_GestionIndividu( P_AFFIL_PORTE     IN      AFFIL_PORTE%ROWTYPE
                           , P_AFFIL_PORTE_AYD IN      AFFIL_PORTE_AYD%ROWTYPE
                           , P_INDIVIDU        IN OUT  INDIVIDU%ROWTYPE
                           , P_ano                OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_INDIVIDUAYD( P_AFFIL_PORTE         IN      AFFIL_PORTE%ROWTYPE
                            , P_AFFIL_PORTE_AYD     IN      AFFIL_PORTE_AYD%ROWTYPE
                            , P_INDIVIDU            IN OUT  INDIVIDU%ROWTYPE
                            , P_ano                    OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_INDIVIDU( P_AFFIL_PORTE     IN      AFFIL_PORTE%ROWTYPE
                         , P_AFFIL_PORTE_AYD IN      AFFIL_PORTE_AYD%ROWTYPE
                         , P_INDIVIDU        IN OUT  INDIVIDU%ROWTYPE
                         , P_ano                OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_AFFIL_ANO( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                          , P_AFFIL_ANO     IN OUT  AFFIL_ANO%ROWTYPE
                          , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_PORTE_REMISE( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                             , P_PORTE_REMISE  IN OUT  PORTE_REMISE%ROWTYPE
                             , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_NATURE_PORTE_REMISE( P_NUMREMISE   IN PORTE_REMISE.NUMREMISE%TYPE
                                   , P_PORTE       IN PORTE_REMISE.NUMPORTE%TYPE);

PROCEDURE P_Gestion_Pers_histo_phys( P_AFFIL_PORTE           IN      AFFIL_PORTE%ROWTYPE
                                   , P_AFFIL_FICHIER         IN      AFFIL_FICHIER%ROWTYPE
                                   , P_trimestre             IN      NUMBER  DEFAULT NULL
                                   , P_annee                 IN      NUMBER  DEFAULT NULL
                                   , P_INIT_PERS_HISTO_PHYS  IN OUT  PERS_HISTO_PHYS%ROWTYPE
                                   , P_ano                      OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_PERS_HISTO_PHYS( P_AFFIL_PORTE              IN     AFFIL_PORTE%ROWTYPE
                                , P_INIT_PERS_HISTO_PHYS  IN OUT  PERS_HISTO_PHYS%ROWTYPE
                                , P_ano                      OUT  AFFIL_ANO.NUMANO%TYPE);


FUNCTION F_FIND_NUMUTIL_ADRESSE(P_NUMINDIV   IN      AFFIL_PORTE.NUMINDIV%TYPE)
RETURN PERS_ADRESSE.NUMUTIL%TYPE;

PROCEDURE P_Gestion_Pers_adresse( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                                , P_PERS_ADRESSE  IN OUT  PERS_ADRESSE%ROWTYPE
                                , P_dateff        IN      CONTRAT.DATEFF%TYPE
                                , P_RG_ADR_DIFF   IN      BOOLEAN
                                , P_warning          OUT  VARCHAR2
                                , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_PERS_ADRESSE( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                             , P_PERS_ADRESSE  IN OUT  PERS_ADRESSE%ROWTYPE
                             , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_Gestion_Contact( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                           , P_CONTACT       IN OUT  CONTACT%ROWTYPE
                           , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

FUNCTION F_INSERT_CONTACT( P_CONTACT IN CONTACT%ROWTYPE)
RETURN BOOLEAN;

PROCEDURE P_GEST_RIB( P_AFFIL_PORTE      IN          AFFIL_PORTE%ROWTYPE
                    , i_log              IN  OUT     JOURNAL_ADM.MSG_ADM%TYPE
                    , P_ano                  OUT     AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_ctrl_Contrat( P_DATRAIT       IN      AFFIL_PORTE.DATRAIT%TYPE
                        , P_NUMGAR        IN      CONTRAT.NUMGAR%TYPE
                        , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_GestionAffiliation( P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                              , P_AFFIL_PORTE_ADH  IN OUT  AFFIL_PORTE_ADH%ROWTYPE
                              , P_ano              OUT     AFFIL_ANO.NUMANO%TYPE);

/*PROCEDURE P_GestionAffil_Resil( P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                              , P_AFFIL_PORTE_ADH  IN OUT  AFFIL_PORTE_ADH%ROWTYPE
                              , P_ano              OUT     AFFIL_ANO.NUMANO%TYPE);*/

FUNCTION F_CTRL_MEMBRE_HORS_ADHESION( P_IDADHESION IN        AFFIL_PORTE_ADH.IDADHESION%TYPE
                                    , P_NUMINDIV   IN        AFFIL_PORTE.NUMINDIV%TYPE
                                    , P_NUMGAR     IN        AFFIL_PORTE_ADH.NUMGAR%TYPE)
RETURN NUMBER;

PROCEDURE P_GestionRadiation( P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                            , P_AFFIL_PORTE_ADH  IN      AFFIL_PORTE_ADH%ROWTYPE
                            , P_etat_adhesion    IN      ADHESION.ETAT%TYPE
                            , P_flag_newindiv    IN      NUMBER
                            , P_ctrlcot          IN      NUMBER
                            , P_ano                 OUT  AFFIL_ANO.NUMANO%TYPE
                            , P_warning             OUT  NUMBER
                            );

FUNCTION F_FIND_ADHESION( P_AFFIL_PORTE_ADH   IN      AFFIL_PORTE_ADH%ROWTYPE
                        , P_AFFIL_PORTE       IN      AFFIL_PORTE%ROWTYPE
                        , P_AFFIL_FICHIER     IN      AFFIL_FICHIER%ROWTYPE
                        , P_ano               IN OUT  AFFIL_ANO.NUMANO%TYPE)
RETURN AFFIL_PORTE_ADH.IDADHESION%TYPE;

FUNCTION F_FIND_NUMFOR( P_NUMGAR           IN      AFFIL_PORTE_ADH.NUMGAR%TYPE
                      , P_CODE_OPT         IN      AFFIL_PORTE_ADH.CODE_OPT%TYPE
                      , P_AFFIL_FICHIER    IN      AFFIL_FICHIER%ROWTYPE
                      , P_ano              IN OUT  AFFIL_ANO.NUMANO%TYPE)
RETURN ADHESION.NUMFOR%TYPE;
FUNCTION F_COUVERT_GAR( P_AFFIL_PORTE_ADH  IN      AFFIL_PORTE_ADH%ROWTYPE
                      , P_AFFIL_PORTE      IN      AFFIL_PORTE%ROWTYPE
                      , P_AFFIL_FICHIER    IN      AFFIL_FICHIER%ROWTYPE)
RETURN NUMBER;


FUNCTION F_FIND_MVT( P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                   , P_AFFIL_FICHIER    IN      AFFIL_FICHIER%ROWTYPE
                   , P_ano                 OUT  AFFIL_ANO.NUMANO%TYPE)
RETURN AFFIL_PORTE.TYPE_MVT%TYPE;

PROCEDURE P_GestionAdhesion( P_AFFIL_PORTE   IN OUT  AFFIL_PORTE%ROWTYPE
                           , P_mvt           IN OUT  NUMBER
                           , P_dateff        IN       CONTRAT.DATEFF%TYPE
                           , P_flag_integ    IN      NUMBER
                           , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE
                           , P_regul            OUT  AFFIL_ANO.NUMANO%TYPE);

/*
PROCEDURE P_AFFILIATION (  P_AFFIL_PORTE  IN OUT AFFIL_PORTE%ROWTYPE
                         , P_dateff       IN     CONTRAT.DATEFF%TYPE
                         , P_numgarMut    IN     ADHE_CNTRT.NUMGAR%TYPE
                         , P_ADHE_CNTRT   OUT ADHE_CNTRT%ROWTYPE
                         , P_ano          OUT NUMBER
                         );
*/
PROCEDURE P_INIT_ADHE_CNTRT( P_AFFIL_PORTE      IN   AFFIL_PORTE%ROWTYPE
                           , P_numgar           IN   AFFIL_PORTE_ADH.NUMGAR%TYPE
                           , P_dateff           IN   CONTRAT.DATEFF%TYPE
                           , P_ADHE_CNTRT       OUT  ADHE_CNTRT%ROWTYPE
                           , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_HISTO_ADHESION( P_AFFIL_PORTE         IN      AFFIL_PORTE%ROWTYPE
                               , P_AFFIL_PORTE_ADH     IN      AFFIL_PORTE_ADH%ROWTYPE
                               , P_dateff              IN      CONTRAT.DATEFF%TYPE
                               , P_HISTO_ADHESION         OUT  HISTO_ADHESION%ROWTYPE
                               , P_ano                    OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_ADHE_CNTRT_MEMBRE( P_AFFIL_PORTE_ADH     IN       AFFIL_PORTE_ADH%ROWTYPE
                                  , P_ADHE_CNTRT_MEMBRE       OUT  ADHE_CNTRT_MEMBRE%ROWTYPE
                                  , P_ano                     OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INS_ADHE_CNTRT_MEMBRE( P_AFFIL_PORTE_ADH      IN      AFFIL_PORTE_ADH%ROWTYPE
                                 , P_ano                     OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INS_COUVERTURES( P_AFFIL_PORTE_ADH      IN      AFFIL_PORTE_ADH%ROWTYPE
                          ,  P_numutil               IN      UTILISATEURS.NUMUTIL%TYPE
                          ,  P_debut                IN      DATE
                          ,  P_fin                  IN      DATE
                           , P_ano                     OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_INIT_ADHESION( P_AFFIL_PORTE     IN      AFFIL_PORTE%ROWTYPE
                         , P_dateff          IN      CONTRAT.DATEFF%TYPE
                      --   , P_NUMFOR          IN      ADHESION.NUMFOR%TYPE
                        ,  P_AFFIL_PORTE_ADH IN      AFFIL_PORTE_ADH%ROWTYPE
                         , P_ADHESION        IN OUT  ADHESION%ROWTYPE
                         , P_ano                OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_VERIF_ANNUL_COTISATION ( I_AFFIL_PORTE       IN       AFFIL_PORTE%ROWTYPE
                                   , I_Idadhesion        IN       AFFIL_PORTE_ADH.IDADHESION%TYPE
                                   , o_cotis                OUT   NUMBER);
PROCEDURE P_ANNUL_COT_PREV ( I_AFFIL_PORTE              AFFIL_PORTE%ROWTYPE
                           , I_Idadhesion        IN     AFFIL_PORTE_ADH.IDADHESION%TYPE
                           , I_DateResil         IN     DATE
                           , I_ctrtResil         IN     NUMBER
                           , o_warning           OUT    NUMBER);

PROCEDURE P_ANNULATION_AFFILIATION (  P_numremise    IN      AFFIL_PORTE.NUMREMISE%TYPE
                                    , P_entreprise  IN       AFFIL_PORTE.ENTREPRISE%TYPE DEFAULT NULL
                                    , P_etabli      IN       AFFIL_PORTE.ETABLI%TYPE DEFAULT NULL
                                    , P_num_ordre   IN       AFFIL_PORTE.NUM_ORDRE%TYPE DEFAULT NULL
                                    , P_annul       IN       AFFIL_PORTE.NUM_ORDRE%TYPE DEFAULT NULL
                                    , P_numligne     IN      AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                                    , P_numporte     IN      AFFIL_PORTE.NUMPORTE%TYPE
                                    , i_session      IN      JOURNAL_ADM.ID_SESSION%TYPE
                                    , i_traitement   IN      JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                                    , i_idligne      IN OUT  JOURNAL_ADM.IDLIGNE%TYPE
                                    , o_erreur          OUT  VARCHAR2
                                    , p_type        IN NUMBER default 0);

PROCEDURE P_ANNULATION_AFFILIATION_EXCEP (  P_numremise   IN       AFFIL_PORTE.NUMREMISE%TYPE
                                    , P_entreprise  IN       AFFIL_PORTE.ENTREPRISE%TYPE DEFAULT NULL
                                    , P_etabli      IN       AFFIL_PORTE.ETABLI%TYPE DEFAULT NULL
                                    , P_num_ordre   IN       AFFIL_PORTE.NUM_ORDRE%TYPE DEFAULT NULL
                                    , P_annul       IN       AFFIL_PORTE.NUM_ORDRE%TYPE DEFAULT NULL
                                    , P_numligne    IN       AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                                    , P_numporte    IN       AFFIL_PORTE.NUMPORTE%TYPE
                                    , i_session     IN       JOURNAL_ADM.ID_SESSION%TYPE
                                    , i_traitement  IN       JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                                    , i_idligne     IN OUT   JOURNAL_ADM.IDLIGNE%TYPE
                                    , o_erreur         OUT   VARCHAR2);
PROCEDURE P_ANNULATION_COTISATION (  P_numquit         IN    AFFIL_PORTE_QTTC.NUMQUIT%TYPE
                                   , o_erreur          OUT   VARCHAR2);

PROCEDURE P_BLOCAGE_AFFILIATION ( P_numremise       IN    AFFIL_PORTE.NUMREMISE%TYPE
                                , P_numligne        IN    AFFIL_PORTE.NUMLIGNE%TYPE
                                , P_Flagetype       IN    NUMBER
                                , o_erreur          OUT   VARCHAR2);
/*
PROCEDURE P_DEBLOCAGE_AFFILIATION ( P_AFFIL_PORTE   IN OUT     AFFIL_PORTE%ROWTYPE
                                  , O_erreur           OUT     NUMBER
                                  , Po_forcage      IN OUT     NUMBER);
*/
PROCEDURE P_DEBLOC_AFFIL_PORTE( P_AFFIL_PORTE      IN      AFFIL_PORTE%ROWTYPE
                              , P_ano              OUT     AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_NUMINDIV( P_NUMINDIV      IN      AFFIL_PORTE.NUMINDIV%TYPE
                                    , P_NUMREMISE     IN      AFFIL_PORTE.NUMREMISE%TYPE
                                    , P_NUMPORTE      IN      AFFIL_PORTE.NUMPORTE%TYPE
                                    , P_NUMLIGNE      IN      AFFIL_PORTE.NUMLIGNE%TYPE
                                    , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_NUMGAR(  P_NUMGAR        IN      AFFIL_PORTE.NUMGAR%TYPE
                                   , P_NUMCLI        IN      AFFIL_PORTE.NUMCLI%TYPE
                                   , P_NUMINDIV      IN      AFFIL_PORTE.NUMINDIV%TYPE
                                   , P_NUMREMISE     IN      AFFIL_PORTE.NUMREMISE%TYPE
                                   , P_NUMPORTE      IN      AFFIL_PORTE.NUMPORTE%TYPE
                                   , P_NUMLIGNE      IN      AFFIL_PORTE.NUMLIGNE%TYPE
                                   , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_IDADHESION( P_IDADHESION    IN      AFFIL_PORTE.IDADHESION%TYPE
                                      , P_NUMINDIV      IN      AFFIL_PORTE.NUMINDIV%TYPE
                                      , P_NUMREMISE     IN      AFFIL_PORTE.NUMREMISE%TYPE
                                      , P_NUMPORTE      IN      AFFIL_PORTE.NUMPORTE%TYPE
                                      , P_NUMLIGNE      IN      AFFIL_PORTE.NUMLIGNE%TYPE
                                      , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_AFFIL( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                                 , P_NUMREMISE     IN      AFFIL_PORTE.NUMREMISE%TYPE
                                 , P_NUMPORTE      IN      AFFIL_PORTE.NUMPORTE%TYPE
                                 , P_NUMLIGNE      IN      AFFIL_PORTE.NUMLIGNE%TYPE
                                 , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE IN   AFFIL_PORTE%ROWTYPE
                                 , P_ano         OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_INDIVIDU_REFCIE( P_NUMINDIV      IN      INDIVIDU.NUMINDIV%TYPE
                               , P_REFCIE        IN      INDIVIDU.REFCIE%TYPE
                               , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_INDIVIDU_MATORG( P_NUMINDIV      IN      INDIVIDU.NUMINDIV%TYPE
                               , P_NUMSSA        IN      AFFIL_PORTE.NUMSSA%TYPE
                               , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_INDIVIDU_LIEUNAIS( P_NUMINDIV     IN      INDIVIDU.NUMINDIV%TYPE
                                 , P_LIEUNAIS     IN      INDIVIDU.LIEUNAIS%TYPE
                                 , P_ano              OUT AFFIL_ANO.NUMANO%TYPE);

PROCEDURE P_MAJ_INDIVIDU_NOMJF( P_NUMINDIV     IN      INDIVIDU.NUMINDIV%TYPE
                              , P_NOMJF        IN      INDIVIDU.NOMJF%TYPE
                              , P_ano              OUT AFFIL_ANO.NUMANO%TYPE);


PROCEDURE P_Gestion_Val_Variable( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                                , P_trimestre     IN      NUMBER
                                , P_annee         IN      NUMBER
                                , P_regul         IN      NUMBER
                                , P_AFFIL_ANO     IN OUT  AFFIL_ANO%ROWTYPE
                                , P_anoSalaireA      OUT  AFFIL_ANO.NUMANO%TYPE
                                , P_anoSalaireB      OUT  AFFIL_ANO.NUMANO%TYPE
                                , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

FUNCTION F_FIND_VALEUR_VALVAR( P_IDVARIABLE     IN    VAL_VARIABLE.IDVARIABLE%TYPE
                             , P_ETENDUE        IN    VAL_VARIABLE.ETENDUE%TYPE
                             , P_NUMGAR         IN    VAL_VARIABLE.NUMGAR%TYPE
                             , P_CLEF           IN    VAL_VARIABLE.CLEF%TYPE
                             , P_DEBUT          IN    VAL_VARIABLE.DEBUT%TYPE
                             , o_DEBUT         OUT    VAL_VARIABLE.DEBUT%TYPE)
RETURN VAL_VARIABLE.VALEUR%TYPE;

FUNCTION F_FIND_USERCREA_VALVAR( P_IDVARIABLE     IN    VAL_VARIABLE.IDVARIABLE%TYPE
                               , P_ETENDUE        IN    VAL_VARIABLE.ETENDUE%TYPE
                               , P_NUMGAR         IN    VAL_VARIABLE.NUMGAR%TYPE
                               , P_CLEF           IN    VAL_VARIABLE.CLEF%TYPE)
RETURN VAL_VARIABLE.USERCREA%TYPE;

FUNCTION F_FIND_PORTE_NUMUTIL( P_porte          IN    LIBELLE.CODE%TYPE)
RETURN NUMBER;

FUNCTION F_INSERT_ADHE_CNTRT( P_ADHE_CNTRT IN ADHE_CNTRT%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INSERT_HISTO_ADHESION( P_HISTO_ADHESION IN HISTO_ADHESION%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INSERT_ADHE_CNTRT_MEMBRE( P_ADHE_CNTRT_MEMBRE IN ADHE_CNTRT_MEMBRE%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INSERT_ADHESION( P_ADHESION IN ADHESION%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_PORTE_REMISE(P_porte_remise      PORTE_REMISE%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_FIND_NUMGAR( P_CODADH IN     AFFIL_PORTE.ENTREPRISE%TYPE
                      , P_NUMCLI IN OUT CONTRAT.NUMCLI%TYPE
                      , P_dateff    OUT CONTRAT.DATEFF%TYPE)
RETURN CONTRAT.NUMGAR%TYPE;

FUNCTION F_FIND_CONTRAT( P_AFFIL_FICHER       IN  AFFIL_FICHIER%ROWTYPE
                       , P_REF_ORGN_CNTRT     IN  AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT%TYPE
                       , P_CODE_POP           IN  AFFIL_PORTE_ADH.CODE_POP%TYPE)
RETURN CONTRAT.NUMGAR%TYPE;
FUNCTION F_GEST_CONTRAT (P_AFFIL_FICHIER       IN  AFFIL_FICHIER%ROWTYPE
                       , P_REF_EXT_CNTRT     IN  AFFIL_PORTE_CNTRT.REF_EXT_CNTRT%TYPE
                       , P_CODE_POP          IN  AFFIL_PORTE_ADH.CODE_POP%TYPE
                       , P_NUMGAR            IN  OUT AFFIL_PORTE_ADH.NUMGAR%TYPE)RETURN NUMBER ;


FUNCTION F_FIND_NUMGAR_OUVERT( P_NUMADHE  IN  AFFIL_PORTE.NUMINDIV%TYPE
                             , P_TYPE_MVT IN  AFFIL_PORTE.TYPE_MVT%TYPE
                             , P_NUMCLI   IN  NUMBER 
                             , P_NUMGAR   IN  AFFIL_PORTE_ADH.NUMGAR%TYPE
                             , p_DATE     IN DATE
                            , P_numfor   IN  AFFIL_PORTE_ADH.REFGARANTIE%TYPE)
RETURN NUMBER;

FUNCTION F_FIND_CONTRAT_NORU( P_NUMGAR IN  AFFIL_PORTE.NUMGAR%TYPE)
RETURN CONTRAT_REF.NUMPROD%TYPE;

FUNCTION F_CPT_ETAT_REMISE_AFFIL ( a_numporte    IN   NUMBER
                                 , a_numremise   IN   NUMBER
                                 , a_etat        IN   NUMBER)
RETURN NUMBER;

FUNCTION F_INSERT_AFFIL_TRACE( P_AFFIL_TRACE IN AFFIL_TRACE%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_CTRL_RG(I_mnemo IN LIBELLE_BIS.MNEMO%TYPE
                  ,I_RG    IN LIBELLE_BIS.CODE%TYPE)
RETURN NUMBER;

FUNCTION F_GET_REG_AFFIL(I_numporte IN PORTE_PARAM.NUMPORTE%TYPE)
RETURN T_RG_TAB;
FUNCTION    V2D (a_edate    in   Varchar2)
Return Date;

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

--**********************************************************************************

TYPE tab_PORTE_ENTITE         IS  TABLE OF PORTE_ENTITE%ROWTYPE INDEX BY VARCHAR2(50) ;
/*******************************************************************************
FONCTIONS D'INSERTION DES DONNEES DANS LA TABLE AFFIL_FICHIER
***************************************************************************** */
FUNCTION F_INS_AFFIL_FICHIER(P_AFFIL_FICHIER      AFFIL_FICHIER%ROWTYPE ,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;


/*******************************************************************************
FONCTIONS D'INSERTION DES DONNEES DANS LE TABLE AFFIL_PORTE8...
***************************************************************************** */
FUNCTION F_INS_AFFIL_PORTE_ADH(P_AFFIL_PORTE_ADH      AFFIL_PORTE_ADH%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_AFFIL_PORTE_AYD(P_AFFIL_PORTE_AYD      AFFIL_PORTE_AYD%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_AFFIL_PORTE_CNTRT(P_AFFIL_PORTE_CNTRT      AFFIL_PORTE_CNTRT%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_AFFIL_PORTE_QTTC(P_AFFIL_PORTE_QTTC      AFFIL_PORTE_QTTC%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_AFFIL_PORTE_QTTC_ELT(P_AFFIL_PORTE_QTTC_ELT      AFFIL_PORTE_QTTC_ELT%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_AFFIL_PORTE_QTTC_INDIV(P_AFFIL_PORTE_QTTC_INDIV      AFFIL_PORTE_QTTC_INDIV%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_AFFIL_PORTE_PAIEMENT(P_AFFIL_PORTE_PAIEMENT      AFFIL_PORTE_PAIEMENT%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;
 /*
FUNCTION F_INS_AFFIL_PORTE_PMT_COMP(P_AFFIL_PORTE_PAIEMENT_COMP      AFFIL_PORTE_PAIEMENT_COMPOSANT%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;
  */
FUNCTION F_INS_AFFIL_PORTE_ARRET(P_AFFIL_PORTE_ARRET      AFFIL_PORTE_ARRET%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN;


/*******************************************************************************
FONCTIONS DE CONTROLE DU FORMAT DES DONNEES DU FICHIER DSN
***************************************************************************** */
FUNCTION F_CTRL_FORMAT_DATE(i_chaine IN VARCHAR2,
                            i_ligne  IN NUMBER,
                            I_entite    IN PORTE_ENTITE%ROWTYPE,
                            p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                            I_cptligne_fichier IN NUMBER)
RETURN VARCHAR2;

FUNCTION F_FORMAT_DATE_HH_MIN_SS(i_chaine IN VARCHAR2,
                            i_ligne  IN NUMBER,
                            I_entite    IN PORTE_ENTITE%ROWTYPE,
                            p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                            I_cptligne_fichier IN NUMBER)
RETURN DATE;


FUNCTION F_CTRL_NUMBER_VARCHAR( i_chaine IN VARCHAR2,
                                i_ligne  IN NUMBER,
                                I_entite    IN PORTE_ENTITE%ROWTYPE,
                                p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                                I_cptligne_fichier IN NUMBER)
RETURN VARCHAR2;
FUNCTION F_CTRL_NUMBER_VARCHAR_AFF(
      i_chaine IN VARCHAR2,
      i_ligne  IN NUMBER,
      I_entite    IN PORTE_ENTITE%ROWTYPE,
      p_journal IN OUT JOURNAL_ADM%ROWTYPE,
      I_cptligne_fichier IN NUMBER
   )   RETURN VARCHAR2;




FUNCTION F_CTRL_LONGUEUR_VARCHAR(i_chaine IN VARCHAR2,
                                 i_ligne  IN NUMBER,
                                 I_entite IN PORTE_ENTITE%ROWTYPE ,
                                 p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                                 I_cptligne_fichier IN NUMBER)
RETURN VARCHAR2;




FUNCTION F_TAB_TYPE_ENTITE(i_idechange    IN  PORTE_ECHANGE.IDECHANGE%TYPE,i_numporte PORTE_ECHANGE.NUMPORTE%TYPE, i_entite    IN  PORTE_ENTITE.ENTITE%TYPE)
RETURN tab_PORTE_ENTITE;

PROCEDURE P_INS_journal(
      P_niv  IN NUMBER,
      p_journal IN OUT JOURNAL_ADM%ROWTYPE,
      P_msg  IN VARCHAR2,
      p_msg2 IN VARCHAR2 := NULL);

--**********************************************************************************

-- ------------------------------------------------- Fin des procedures publiques --
END PK_CTRL_AFFIL;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_CTRL_AFFIL
As
/*============================================================================*/
/* PACKAGE      : PK_CTRL_AFFIL.sql                                           */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 15/05/2013                                                  */
/* Description  : Package permettant l import d un fichier contenant des      */
/*                affiliations dans Arthus ainsi que l intégration des données*/
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       : JBO                                                         */
/* Date         : 06/03/2015                                                  */
/* Commentaire  : P201401001_DSN                                              */
/*============================================================================*/
/* Correction   : JBO / 22/09/2014 / Mantis 4436                              */
/*============================================================================*/

   -- -- TYPES PRIVEES ------------------------------------------------------

   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--


  exc_entite_en_ano           EXCEPTION;

   -- -- PROCEDURES ET FONCTIONS PRIVEES -----------------------------------------
--

/*
  PROCEDURE P_insert_donnees ( s_entite       IN  PORTE_ENTITE.ENTITE%TYPE
                             , s_T_entite     IN  PORTE_ENTITE.DONNEE%TYPE);

*/

   -- -- Déclaration des variables globales   ----------------------------------
  g_session         journal_adm.id_session%TYPE          DEFAULT 1;
  g_nom_traitement  journal_adm.nom_traitement%TYPE:='JBO_AF04T';
  g_niv_msg         journal_adm.niv_msg%TYPE:=3;
  g_idligne         journal_adm.idligne%TYPE:=1;
  g_msg_adm         journal_adm.msg_adm%TYPE;

  g_fichier                   VARCHAR2 (200);
  g_date                      VARCHAR2 (8);
  g_numporte                  PORTE_PARAM.NUMPORTE%TYPE:=4;
  g_echange                   PORTE_ECHANGE.IDECHANGE%TYPE:=2;
  g_extension                 LIBELLE.LIBELLE%TYPE:=NULL;
  g_nature                    PORTE_PARAM.NAT_PORTE%TYPE:=NULL;


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
/* Nom          :  F_INS_AFFIL_PORTE                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans AFFIL_PORTE                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE(P_AFFIL_PORTE      AFFIL_PORTE%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE )
RETURN BOOLEAN
IS

BEGIN
  INSERT INTO AFFIL_PORTE VALUES P_AFFIL_PORTE;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible salarié n° :' || P_AFFIL_PORTE.numligne ||'-'||P_AFFIL_PORTE.nomsal ||' '||P_AFFIL_PORTE.prenom||', Err : ' || SQLERRM);

    RETURN FALSE;
END F_INS_AFFIL_PORTE;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE_FORCAGE                                 */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans AFFIL_PORTE_FORCAGE            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_FORCAGE(P_AFFIL_PORTE_FORCAGE   IN OUT   AFFIL_PORTE_FORCAGE%ROWTYPE/*,p_journal IN OUT JOURNAL_ADM%ROWTYPE*/)
RETURN BOOLEAN
IS
  loc_numordre   number(3);
BEGIN
  SELECT nvl(max(numordre),0)+1
  INTO loc_numordre
  FROM AFFIL_PORTE_FORCAGE
  WHERE numremise = P_AFFIL_PORTE_FORCAGE.numremise
  AND numligne = P_AFFIL_PORTE_FORCAGE.numligne;

  P_AFFIL_PORTE_FORCAGE.numordre :=loc_numordre;
  P_AFFIL_PORTE_FORCAGE.datfrcg :=NVL(P_AFFIL_PORTE_FORCAGE.datfrcg, sysdate);
  P_AFFIL_PORTE_FORCAGE.numutil :=NVL(P_AFFIL_PORTE_FORCAGE.numutil, f_numutil);
  INSERT INTO AFFIL_PORTE_FORCAGE VALUES P_AFFIL_PORTE_FORCAGE;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3, 'Enregistrement impossible forcage n° :' || P_AFFIL_PORTE_FORCAGE.numligne ||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_FORCAGE;


PROCEDURE P_AFFIL_ANO( P_AFFIL_PORTE      AFFIL_PORTE%ROWTYPE
                      , P_ano              AFFIL_ANO.NUMANO%TYPE
                      , P_etat             AFFIL_ANO.ETATANO%TYPE
                      , P_date             AFFIL_ANO.DATANO%TYPE)
IS
  loc_AFFIL_ANO AFFIL_ANO%ROWTYPE;
BEGIN
          loc_AFFIL_ANO.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;
          loc_AFFIL_ANO.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
          loc_AFFIL_ANO.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;
          loc_AFFIL_ANO.DATANO:=P_date;
          loc_AFFIL_ANO.NUMANO:=P_ano;
          loc_AFFIL_ANO.ETATANO:=P_etat;
          PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);

END P_AFFIL_ANO;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_AFFIL_ANO                                           */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans AFFIL_ANO                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_AFFIL_ANO(P_AFFIL_ANO      AFFIL_ANO%ROWTYPE)
IS

BEGIN
  IF P_AFFIL_ANO.NUMANO IS NOT NULL THEN
    INSERT INTO AFFIL_ANO VALUES P_AFFIL_ANO;
  END IF;
END P_INS_AFFIL_ANO;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_DEL_AFFIL_ANO                                           */
/* Type         :  Public                                                    */
/* Description  :  procedure de suppression dans AFFIL_ANO                   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_DEL_AFFIL_ANO( i_numremise    IN       AFFIL_ANO.NUMREMISE%TYPE
                         , i_numligne     IN       AFFIL_ANO.NUMLIGNE%TYPE
                         , i_numporte     IN       AFFIL_ANO.NUMPORTE%TYPE)
IS

BEGIN
  DELETE FROM AFFIL_ANO WHERE NUMREMISE=i_numremise
                          AND NUMLIGNE=i_numligne
                          AND NUMPORTE=i_numporte;
END P_DEL_AFFIL_ANO;


PROCEDURE P_DEL_AFFIL_ANO_ETAT( i_numremise    IN       AFFIL_ANO.NUMREMISE%TYPE
                               , i_numporte     IN       AFFIL_ANO.NUMPORTE%TYPE
                               , i_etat IN AFFIL_PORTE.ETAT%TYPE)
IS

BEGIN
  DELETE FROM AFFIL_ANO
  WHERE NUMREMISE=i_numremise
  AND NUMPORTE=i_numporte
  AND NUMLIGNE IN (
    SELECT NUMLIGNE FROM AFFIL_PORTE
    WHERE NUMREMISE=i_numremise
    AND NUMPORTE=i_numporte
    AND ETAT = i_etat);

END P_DEL_AFFIL_ANO_ETAT;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_ETAT                                    */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l etat dans AFFIL_ANO         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_ETAT( i_numremise    IN       AFFIL_PORTE.NUMREMISE%TYPE
                                , i_etat         IN       AFFIL_PORTE.ETAT%TYPE
                                , i_numligne     IN       AFFIL_PORTE.NUMLIGNE%TYPE
                                , i_numporte     IN       AFFIL_PORTE.NUMPORTE%TYPE)
IS

BEGIN

  UPDATE AFFIL_PORTE a
     SET a.ETAT=i_etat
   WHERE a.NUMREMISE=i_numremise
     AND a.NUMLIGNE=i_numligne
     AND a.NUMPORTE=i_numporte;

END P_MAJ_AFFIL_PORTE_ETAT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE           */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE( P_AFFIL_PORTE   IN       AFFIL_PORTE%ROWTYPE)
IS

BEGIN

  UPDATE AFFIL_PORTE
     SET ROW =P_AFFIL_PORTE
   WHERE NUMLIGNE = P_AFFIL_PORTE.NUMLIGNE
     AND NUMREMISE = P_AFFIL_PORTE.NUMREMISE
     AND NUMPORTE = P_AFFIL_PORTE.NUMPORTE;

END P_MAJ_AFFIL_PORTE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AFFIL_PORTE_AYD                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_AYD       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_AYD( P_AFFIL_PORTE_AYD    IN       AFFIL_PORTE_AYD%ROWTYPE)

IS

BEGIN

  UPDATE AFFIL_PORTE_AYD
     SET ROW =P_AFFIL_PORTE_AYD
   WHERE NUMLIGNE = P_AFFIL_PORTE_AYD.NUMLIGNE
     AND NUMREMISE = P_AFFIL_PORTE_AYD.NUMREMISE
     AND NUMPORTE = P_AFFIL_PORTE_AYD.NUMPORTE
     AND NUMAYD = P_AFFIL_PORTE_AYD.NUMAYD ;

END P_MAJ_AFFIL_PORTE_AYD;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AFFIL_PORTE_AYD                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de AFFIL_PORTE_AYD.NUMINDIV      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_AYD( P_AFFIL_PORTE_ADH    IN       AFFIL_PORTE_ADH%ROWTYPE)

IS

BEGIN



  UPDATE AFFIL_PORTE_AYD
     SET NUMINDIV = P_AFFIL_PORTE_ADH.NUMINDIV
   WHERE NUMLIGNE = P_AFFIL_PORTE_ADH.NUMLIGNE
     AND NUMREMISE = P_AFFIL_PORTE_ADH.NUMREMISE
     AND NUMPORTE = P_AFFIL_PORTE_ADH.NUMPORTE
     AND NUMAYD = P_AFFIL_PORTE_ADH.NUMAYD ;

END P_MAJ_AFFIL_PORTE_AYD;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_CPAM                                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour des infod CPAM de l individu     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
/*PROCEDURE P_MAJ_CPAM( P_AFFIL_PORTE_AYD    IN OUT AFFIL_PORTE_AYD%ROWTYPE)
IS

BEGIN

  SELECT CAISSE, REGIME, CENTRE
    INTO P_AFFIL_PORTE_AYD.CAISSE, P_AFFIL_PORTE_AYD.REGIME, P_AFFIL_PORTE_AYD.CENTRE
    FROM AFFIL_PORTE_AYD
    WHERE NUMREMISE=P_AFFIL_PORTE_AYD.NUMREMISE
      AND NUMPORTE=P_AFFIL_PORTE_AYD.numporte
      AND NUMLIGNE=P_AFFIL_PORTE_AYD.numligne
      AND NUMAYD = P_AFFIL_PORTE_AYD.NUMAYD;

  UPDATE INDIVIDU
     SET CAISSE      = P_AFFIL_PORTE_AYD.CAISSE
       , REGIME      = P_AFFIL_PORTE_AYD.REGIME
       , GUICHETORG  = P_AFFIL_PORTE_AYD.CENTRE
   WHERE NUMINDIV    = P_AFFIL_PORTE_AYD.NUMINDIV;

END P_MAJ_CPAM;
*/

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_ADH                                     */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_ADH       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_ADH( P_AFFIL_PORTE_ADH     IN       AFFIL_PORTE_ADH%ROWTYPE)
IS
BEGIN
  --mise à jour adh pour le salarié et ses ayants droits
  UPDATE AFFIL_PORTE_ADH
     SET --NUMGAR      = P_AFFIL_PORTE_ADH.NUMGAR
     --  , NUMINDIV    = P_AFFIL_PORTE_ADH.NUMINDIV
        IDADHESION  = P_AFFIL_PORTE_ADH.IDADHESION
   WHERE NUMLIGNE = P_AFFIL_PORTE_ADH.NUMLIGNE
     AND NUMREMISE = P_AFFIL_PORTE_ADH.NUMREMISE
  --   AND NUMINDIV= P_AFFIL_PORTE_ADH.NUMINDIV
     AND NUMADH= P_AFFIL_PORTE_ADH.NUMADH
     AND REF_EXT_CNTRT =P_AFFIL_PORTE_ADH.REF_EXT_CNTRT
     AND NUMPORTE = P_AFFIL_PORTE_ADH.NUMPORTE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_ADH '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_ADH;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PRT_ADH_INDIV                                 */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de AFFIL_PORTE_ADH.NUMINDIV      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PRT_ADH_INDIV ( P_AFFIL_PORTE_ADH    IN       AFFIL_PORTE_ADH%ROWTYPE)
IS

BEGIN

  UPDATE AFFIL_PORTE_ADH
     SET NUMINDIV =P_AFFIL_PORTE_ADH.NUMINDIV
   WHERE NUMLIGNE = P_AFFIL_PORTE_ADH.NUMLIGNE
     AND NUMREMISE = P_AFFIL_PORTE_ADH.NUMREMISE
     AND NUMPORTE = P_AFFIL_PORTE_ADH.NUMPORTE
     AND NUMAYD = P_AFFIL_PORTE_ADH.NUMAYD ;

END P_MAJ_AFFIL_PRT_ADH_INDIV;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PRT_ADH_INDIV                                 */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de AFFIL_PORTE_ADH.NUMINDIV      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PRT_ADH_INDIV ( P_AFFIL_PORTE_AYD    IN       AFFIL_PORTE_AYD%ROWTYPE)
IS

BEGIN

  UPDATE AFFIL_PORTE_ADH
     SET NUMINDIV =P_AFFIL_PORTE_AYD.NUMINDIV
   WHERE NUMLIGNE = P_AFFIL_PORTE_AYD.NUMLIGNE
     AND NUMREMISE = P_AFFIL_PORTE_AYD.NUMREMISE
     AND NUMPORTE = P_AFFIL_PORTE_AYD.NUMPORTE
     AND NUMAYD = P_AFFIL_PORTE_AYD.NUMAYD ;

END P_MAJ_AFFIL_PRT_ADH_INDIV;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_ADH_NUMGAR                              */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour du NUMGAR d'AFFIL_PORTE_ADH      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_ADH_NUMGAR( P_AFFIL_FICHIER       IN  AFFIL_FICHIER%ROWTYPE
                                       , P_REF_EXT_CNTRT     IN  AFFIL_PORTE_CNTRT.REF_EXT_CNTRT%TYPE
                                       , P_CODE_POP          IN  AFFIL_PORTE_ADH.CODE_POP%TYPE
                                       , P_NUMGAR            IN  AFFIL_PORTE_ADH.NUMGAR%TYPE)
IS
BEGIN

  UPDATE AFFIL_PORTE_ADH
     SET NUMGAR      = P_NUMGAR
   WHERE NUMREMISE = P_AFFIL_FICHIER.NUMREMISE
     AND NUMPORTE = P_AFFIL_FICHIER.NUMPORTE
     AND REF_EXT_CNTRT =P_REF_EXT_CNTRT
     AND NVL(CODE_POP,0) = NVL(P_CODE_POP,0)
     AND NUMLIGNE IN (
       SELECT NUMLIGNE FROM AFFIL_PORTE
       WHERE NUMREMISE = P_AFFIL_FICHIER.NUMREMISE
       AND NUMPORTE = P_AFFIL_FICHIER.NUMPORTE
       AND ENTREPRISE = P_AFFIL_FICHIER.ENTREPRISE
       AND ETABLI = P_AFFIL_FICHIER.ETABLI
       AND NUM_ORDRE = P_AFFIL_FICHIER.NUM_ORDRE);


EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_ADH_NUMGAR '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_ADH_NUMGAR;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_ADH_NUMFOR                              */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de REFGARANTIE d'AFFIL_PORTE_ADH */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_ADH_NUMFOR( P_AFFIL_FICHIER       IN  AFFIL_FICHIER%ROWTYPE
                                       , P_NUMGAR             IN  AFFIL_PORTE_ADH.NUMGAR%TYPE
                                       , P_CODE_OPT          IN  AFFIL_PORTE_ADH.CODE_OPT%TYPE
                                       , P_NUMFOR            IN  AFFIL_PORTE_ADH.REFGARANTIE%TYPE)
IS
BEGIN

  UPDATE AFFIL_PORTE_ADH
     SET REFGARANTIE      = P_NUMFOR
   WHERE NUMREMISE = P_AFFIL_FICHIER.NUMREMISE
     AND NUMPORTE = P_AFFIL_FICHIER.NUMPORTE
     AND NUMGAR =P_NUMGAR
     AND NVL(CODE_OPT,0) = NVL(P_CODE_OPT,0)
     AND NUMLIGNE IN (
       SELECT NUMLIGNE FROM AFFIL_PORTE
       WHERE NUMREMISE = P_AFFIL_FICHIER.NUMREMISE
       AND NUMPORTE = P_AFFIL_FICHIER.NUMPORTE
       AND ENTREPRISE = P_AFFIL_FICHIER.ENTREPRISE
       AND ETABLI = P_AFFIL_FICHIER.ETABLI
       AND NUM_ORDRE = P_AFFIL_FICHIER.NUM_ORDRE);


EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_ADH_NUMFOR '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_ADH_NUMFOR;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_CNTRT                                   */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_CNTRT     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_CNTRT( P_AFFIL_PORTE_CNTRT     IN       AFFIL_PORTE_CNTRT%ROWTYPE)
IS
BEGIN

  UPDATE AFFIL_PORTE_CNTRT
     SET REF_ORGN_CNTRT  = P_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT
   WHERE NUMPORTE = P_AFFIL_PORTE_CNTRT.NUMPORTE
     AND NUMREMISE = P_AFFIL_PORTE_CNTRT.NUMREMISE
     AND ENTREPRISE = P_AFFIL_PORTE_CNTRT.ENTREPRISE
     AND ETABLI = P_AFFIL_PORTE_CNTRT.ETABLI
     AND REF_EXT_CNTRT =P_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT
     AND NUM_ORDRE = P_AFFIL_PORTE_CNTRT.NUM_ORDRE;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_CNTRT '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_CNTRT;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_QTTC                                    */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_QTTC      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_QTTC( P_NUMLIGNE     IN       AFFIL_PORTE_QTTC.NUMLIGNE%TYPE
                                , P_NUM_QTTC     IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                , P_NUMREMISE    IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                , P_NUMPORTE     IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                , P_NUMQUIT      IN       AFFIL_PORTE_QTTC.NUMQUIT%TYPE
                                )
IS
BEGIN

  UPDATE AFFIL_PORTE_QTTC
     SET NUMQUIT  = P_NUMQUIT
   WHERE NUMPORTE = P_NUMPORTE
     AND NUMREMISE =P_NUMREMISE
     AND NUMLIGNE = P_NUMLIGNE
     AND NUM_QTTC = P_NUM_QTTC
     ;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_QTTC '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_QTTC;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_QTTC_ELT                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_QTTC_ELT  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_ELT( P_NUMLIGNE     IN       AFFIL_PORTE_QTTC.NUMLIGNE%TYPE
                                    , P_NUM_QTTC     IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                    , P_NUMREMISE    IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                    , P_NUMPORTE     IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                    , P_ID_VARIABLE  IN       AFFIL_PORTE_QTTC_ELT.ID_VARIABLE%TYPE
                                    )
IS
BEGIN

  UPDATE AFFIL_PORTE_QTTC_ELT
     SET ID_VARIABLE  = P_ID_VARIABLE
   WHERE NUMPORTE = P_NUMPORTE
     AND NUMREMISE =P_NUMREMISE
     AND NUMLIGNE = P_NUMLIGNE
     AND NUM_QTTC = P_NUM_QTTC
     ;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_QTTC_ELT '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_QTTC_ELT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_ID_VAR_QTTC_ELT                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_QTTC_ELT  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_ID_VAR_QTTC_ELT(  P_NUMREMISE    IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                , P_NUMPORTE     IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                , P_ELT          IN       AFFIL_PORTE_QTTC_ELT.TYPE_ELT%TYPE
                                , P_NUMGAR       IN       CONTRAT.NUMGAR%TYPE
                                , P_ID_VARIABLE  IN       AFFIL_PORTE_QTTC_ELT.ID_VARIABLE%TYPE
                                 )
IS
BEGIN
  --mise à jour massive de tous les elements de toutes les adhésion d'un contrat d'une remise
  UPDATE AFFIL_PORTE_QTTC_ELT
     SET ID_VARIABLE  = P_ID_VARIABLE
   WHERE NUMPORTE = P_NUMPORTE
     AND NUMREMISE = P_NUMREMISE
     AND TYPE_ELT = P_ELT
     AND REF_EXT_ADH IN
     ( SELECT REF_EXT_ADH FROM AFFIL_PORTE_ADH
     WHERE NUMGAR =P_NUMGAR
     AND  NUMPORTE = P_NUMPORTE
     AND NUMREMISE =P_NUMREMISE
     AND REF_EXT_ADH IS NOT NULL
     AND NUMGAR IS NOT NULL)
     ;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_QTTC_ELT '||SUBSTR(SQLERRM,1,132));
END P_MAJ_ID_VAR_QTTC_ELT;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_QTTC_STATUT                             */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_QTTC      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_STATUT(  P_NUMLIGNE     IN       AFFIL_PORTE_QTTC.NUMLIGNE%TYPE
                                        , P_NUM_QTTC     IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                        , P_NUMREMISE    IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                        , P_NUMPORTE     IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                        , P_STATUT       IN       AFFIL_PORTE_QTTC.STATUT%TYPE)
IS
BEGIN

  UPDATE AFFIL_PORTE_QTTC
     SET STATUT  = P_STATUT
   WHERE NUMPORTE = P_NUMPORTE
     AND NUMREMISE =P_NUMREMISE
     AND NUMLIGNE = P_NUMLIGNE
     AND NUM_QTTC = P_NUM_QTTC
     ;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_QTTC_STATUT '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_QTTC_STATUT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_QTTC_NUMQUIT                            */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_QTTC      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_NUMQUIT( P_NUMREMISE     IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                        , P_NUMPORTE      IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                        , P_NUM_QTTC      IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                        , P_NUMQUIT       IN       AFFIL_PORTE_QTTC.NUMQUIT%TYPE)
IS
BEGIN

  UPDATE AFFIL_PORTE_QTTC
     SET NUMQUIT  = null
       , STATUT = 2
   WHERE NUMQUIT = P_NUMQUIT
     AND NUMPORTE = P_NUMPORTE
     AND NUMREMISE =P_NUMREMISE
     AND NUM_QTTC = P_NUM_QTTC
     ;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_QTTC_NUMQUIT '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_QTTC_NUMQUIT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_QTTC_ELTVAR                             */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_QTTC      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_ELTVAR( P_NUMREMISE     IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                       , P_NUMPORTE      IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                       , P_NUM_QTTC      IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                       , P_ID_VARIABLE   IN       AFFIL_PORTE_QTTC_ELT.ID_VARIABLE%TYPE
                                       , P_VALEUR        IN       AFFIL_PORTE_QTTC_ELT.VALEUR%TYPE)
IS
BEGIN

  UPDATE AFFIL_PORTE_QTTC_ELT
     SET ID_VARIABLE  = NULL
       , VALEUR = NULL
   WHERE ID_VARIABLE = P_ID_VARIABLE
     AND NUMPORTE = P_NUMPORTE
     AND NUMREMISE =P_NUMREMISE
     AND NUM_QTTC = P_NUM_QTTC
     ;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_QTTC_ELTVAR '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_QTTC_ELTVAR;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_QTTC_VALEUR                             */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_QTTC_ELT  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_QTTC_VALEUR( P_NUMREMISE     IN       AFFIL_PORTE_QTTC.NUMREMISE%TYPE
                                       , P_NUMPORTE      IN       AFFIL_PORTE_QTTC.NUMPORTE%TYPE
                                       , P_NUM_QTTC      IN       AFFIL_PORTE_QTTC.NUM_QTTC%TYPE
                                       , P_somme_bases   IN       AFFIL_PORTE_QTTC_ELT.VALEUR%TYPE)
IS
BEGIN

  UPDATE AFFIL_PORTE_QTTC_ELT
     SET VALEUR  = P_somme_bases
   WHERE NUM_QTTC = P_NUM_QTTC
     AND NUMREMISE = P_NUMREMISE
     AND NUMPORTE = P_NUMPORTE
     ;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3 ,'P_MAJ_AFFIL_PORTE_QTTC_VALEUR '||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_QTTC_VALEUR;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_INDIVIDU_NUMASSU                                    */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet du INDIVIDU.NUMASSU   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
/*PROCEDURE P_MAJ_INDIVIDU_NUMASSU( P_AFFIL_PORTE_ADH  IN        AFFIL_PORTE_ADH%ROWTYPE
                                , P_ano                OUT  AFFIL_ANO.NUMANO%TYPE)
IS
  loc_numassu        INDIVIDU.NUMASSU%TYPE:=NULL;
BEGIN
  P_ano:=0;



  UPDATE INDIVIDU
     SET NUMASSU  = P_AFFIL_PORTE_ADH.NUMINDIV
   WHERE NUMINDIV IN   (
                         SELECT adh.NUMINDIV
                          FROM AFFIL_PORTE_ADH adh
                          WHERE adh.NUMPORTE=P_AFFIL_PORTE_ADH.NUMPORTE
                            AND adh.NUMREMISE=P_AFFIL_PORTE_ADH.NUMREMISE
                            AND adh.NUMLIGNE=P_AFFIL_PORTE_ADH.NUMLIGNE
                            AND adh.NUMAYD<>0
                        )
     ;
EXCEPTION
  WHEN OTHERS THEN
    P_ano:=0;
    P_INS_journal(3 ,'P_MAJ_INDIVIDU_NUMASSU '||SUBSTR(SQLERRM,1,132));
END P_MAJ_INDIVIDU_NUMASSU;
*/
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE_QTTC                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans AFFIL_PORTE_QTTC                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_QTTC(P_AFFIL_PORTE_QTTC      AFFIL_PORTE_QTTC%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE )
RETURN BOOLEAN
IS
BEGIN
  INSERT INTO AFFIL_PORTE_QTTC VALUES P_AFFIL_PORTE_QTTC;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible cotisation ,remise :' || P_AFFIL_PORTE_QTTC.numremise ||' ,ligne:'||P_AFFIL_PORTE_QTTC.numligne ||', porte:'||P_AFFIL_PORTE_QTTC.numporte||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_QTTC;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE_QTTC-ELT                                */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans AFFIL_PORTE_QTTC               */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_QTTC_ELT(P_AFFIL_PORTE_QTTC_ELT      AFFIL_PORTE_QTTC_ELT%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE )
RETURN BOOLEAN
IS
BEGIN
  INSERT INTO AFFIL_PORTE_QTTC_ELT VALUES P_AFFIL_PORTE_QTTC_ELT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible cotisation element ,remise :' || P_AFFIL_PORTE_QTTC_ELT.numremise ||' ,ligne:'||P_AFFIL_PORTE_QTTC_ELT.numligne ||', porte:'||P_AFFIL_PORTE_QTTC_ELT.numporte||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_QTTC_ELT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE_QTTC_INDIV                                */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans AFFIL_PORTE_QTTC               */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_QTTC_INDIV(P_AFFIL_PORTE_QTTC_INDIV     AFFIL_PORTE_QTTC_INDIV%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE )
RETURN BOOLEAN
IS
BEGIN
  INSERT INTO AFFIL_PORTE_QTTC_INDIV VALUES P_AFFIL_PORTE_QTTC_INDIV;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible cotisation individuelle ,remise :' || P_AFFIL_PORTE_QTTC_INDIV.numremise ||' ,ligne:'||P_AFFIL_PORTE_QTTC_INDIV.numligne ||', porte:'||P_AFFIL_PORTE_QTTC_INDIV.numporte||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_QTTC_INDIV;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE_ARRET                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans F_INS_AFFIL_PORTE_ARRET                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_ARRET(P_AFFIL_PORTE_ARRET     AFFIL_PORTE_ARRET%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE )
RETURN BOOLEAN
IS

BEGIN
  INSERT INTO AFFIL_PORTE_ARRET VALUES P_AFFIL_PORTE_ARRET;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible arret n° :' || P_AFFIL_PORTE_ARRET.numremise ||'-'||P_AFFIL_PORTE_ARRET.numligne ||' '||P_AFFIL_PORTE_ARRET.numporte||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_ARRET;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE_PAIEMENT                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans AFFIL_PORTE                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_PAIEMENT(P_AFFIL_PORTE_PAIEMENT   AFFIL_PORTE_PAIEMENT %ROWTYPE, p_journal IN OUT JOURNAL_ADM%ROWTYPE )
RETURN BOOLEAN
IS
v_idpaiement NUMBER;

BEGIN
  INSERT INTO AFFIL_PORTE_PAIEMENT  VALUES P_AFFIL_PORTE_PAIEMENT ;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enreg. impossible Paiement remise:' || P_AFFIL_PORTE_PAIEMENT .numremise ||', porte:'||P_AFFIL_PORTE_PAIEMENT .numporte ||' Entreprise:'||P_AFFIL_PORTE_PAIEMENT.ENTREPRISE
||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_PAIEMENT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE_PAIEMENT_COMPOSANT                      */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans AFFIL_PORTE                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
/*FUNCTION F_INS_AFFIL_PORTE_PMT_COMP(P_AFFIL_PORTE_PAIEMENT_COMP   AFFIL_PORTE_PAIEMENT_COMPOSANT%ROWTYPE, p_journal IN OUT JOURNAL_ADM%ROWTYPE )
RETURN BOOLEAN
IS

BEGIN
  INSERT INTO AFFIL_PORTE_PAIEMENT_COMPOSANT  VALUES P_AFFIL_PORTE_PAIEMENT_COMP ;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible Paiement remise:' || P_AFFIL_PORTE_PAIEMENT_COMP.idpaiement ||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_PMT_COMP;
*/


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  P_CTRL_SOCIETE                                            */
/* Type         :  Public                                                    */
/* Description  :  procedure de controle de la societe d affiliation         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION P_CTRL_SOCIETE(  i_numporte     IN       AFFIL_PORTE.NUMPORTE%TYPE
                        , i_numremise    IN       AFFIL_PORTE.NUMREMISE%TYPE
                        , i_nuligne      IN       AFFIL_PORTE.NUMLIGNE%TYPE
                        , i_codadh       IN       AFFIL_PORTE.ENTREPRISE%TYPE
                        , i_Entreprise   IN       AFFIL_PORTE.ENTREPRISE%TYPE)
RETURN NUMBER
IS

BEGIN

  IF TRIM(i_codadh)<> TRIM(i_Entreprise) THEN
    RETURN 1; -- Numéro de société incohérent
  ELSE
    RETURN 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1 ,'P_CTRL_SOCIETE '||SUBSTR(SQLERRM,1,132));
    RETURN 1;
END P_CTRL_SOCIETE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_SOCIETE                                            */
/* Type         :  Public                                                    */
/* Description  :  procedure d'identification de la societe d affiliation    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_SOCIETE( I_SIREN  IN  AFFIL_PORTE.ENTREPRISE%TYPE
                       , I_ETABLI  IN  AFFIL_PORTE.ETABLI%TYPE
                       , O_Erreur   OUT NUMBER)
RETURN NUMBER
IS

  loc_numindiv PERS_MORALE.NUMINDIV%TYPE:=0;

BEGIN

  BEGIN
    --Recherche de la société avec uniquement le SIREN
    SELECT DISTINCT numindiv  INTO loc_numindiv
    FROM pers_morale
    WHERE SUBSTR(siret, 1, 9) = I_SIREN;
  EXCEPTION
    /*WHEN NO_DATA_FOUND THEN
      BEGIN
        SELECT DISTINCT numindiv
          INTO loc_numindiv
           FROM pers_morale WHERE siret=I_SIREN||I_ETABLI;
      EXCEPTION

        WHEN OTHERS THEN
          RETURN NULL;
      END;*/
    WHEN TOO_MANY_ROWS THEN
      --Recherche de la société avec SIRET
      BEGIN
          SELECT DISTINCT numindiv INTO loc_numindiv
          FROM pers_morale WHERE siret=I_SIREN||I_ETABLI;
      EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        O_Erreur:=1; --doublon de société pour même SIRET
        RETURN NULL;
      WHEN OTHERS THEN
        O_Erreur:=86; --Société pour SIREN ou SIRET introuvable
        RETURN NULL;
      END;
    WHEN OTHERS THEN
      O_Erreur:=86; --Société pour SIREN ou SIRET introuvable
      RETURN NULL;

  END;

 RETURN loc_numindiv;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1 ,'F_FIND_SOCIETE '||SUBSTR(SQLERRM,1,132));
    RETURN NULL;
END F_FIND_SOCIETE;

/*----------------------------------------------------------------------------*/
/* FONCTION                                                                   */
/* Nom          :  F_FIND_PARTICIPANT                                         */
/* Type         :  Public                                                     */
/* Description  :  Permet de faire la recherche du numéro de l individu a     */
/*                 partir du nom, numéro de sécu et de la date de naissance   */
/* Entree       :  P_matorg                                                   */
/*                 P_nom                                                      */
/*                 P_datnais                                                  */
/* Retour       :  Numindiv si trouvé, 0 si aucun particpant trouvé, 2 si     */
/*                 anomalie de doublons de particpant(code 2 de AFFIL_ANO)    */
/*----------------------------------------------------------------------------*/
FUNCTION F_FIND_PARTICIPANT ( P_matorg   IN   AFFIL_PORTE.NUMSSA%TYPE DEFAULT NULL
                            , P_nom      IN   AFFIL_PORTE.NOMSAL%TYPE DEFAULT NULL
                            , P_datnais  IN   AFFIL_PORTE.DATNAI%TYPE DEFAULT NULL
                            , P_numindiv IN   AFFIL_PORTE.NUMINDIV%TYPE DEFAULT NULL)
RETURN NUMBER
IS

  loc_numindiv        INDIVIDU.NUMINDIV%TYPE:=NULL;
  loc_ano_matorg      AFFIL_ANO.NUMANO%TYPE:=NULL;
  exc_secu_social     EXCEPTION;

BEGIN

  -- Controle de la conformité du Numero de securité social
  /*IF SUBSTR(P_matorg,11,3)='999' OR TRIM(P_matorg) IS NULL THEN
    loc_ano_matorg:=40;
  ELS*/IF ((SUBSTR(P_matorg,1,1) NOT IN ('1','2')) OR (TRIM(P_matorg) IS NULL)) THEN
    loc_ano_matorg:=40;
  ELSE
    loc_ano_matorg:=0;
  END IF;

  IF NVL(P_numindiv,0) > 0 THEN  -- Deblocage d une affiliation
    BEGIN
      SELECT DISTINCT NVL(a.NUMINDIV,0)
        INTO loc_numindiv
        FROM INDIVIDU a
       WHERE a.NUMINDIV=P_numindiv
         AND a.numassu=P_numindiv;
      RETURN loc_numindiv;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN -2;
    END;
  ELSE
    -- Recherche de l assure
    BEGIN

      -- Identification du participant avec un numéro de sécurité sociale
      IF loc_ano_matorg<>40 THEN

        SELECT DISTINCT NVL(a.NUMINDIV,0)
            INTO loc_numindiv
            FROM INDIVIDU a
           WHERE a.MATORG=NVL(SUBSTR(P_matorg,0,13),a.matorg)
             AND (a.CLESS=NVL(SUBSTR(P_matorg,14),a.cless) OR a.cless IS NULL)
           ;
      ELSE
      -- Identification du participant avec un numéro de sécurité sociale temporaire
        SELECT DISTINCT NVL(a.NUMINDIV,0)
          INTO loc_numindiv
          FROM INDIVIDU a
         WHERE UPPER(a.NOM)=UPPER(P_nom)
           AND a.DATNAIS=E2D(P_datnais)
         ;
      END IF;

    EXCEPTION
      -- Recherche de l assu a partir du numéro de sécu, de la date naissance
      WHEN TOO_MANY_ROWS THEN
        BEGIN
          IF loc_ano_matorg<>40 THEN
            SELECT DISTINCT NVL(a.NUMINDIV,0)
              INTO loc_numindiv
              FROM INDIVIDU a
             WHERE a.MATORG=NVL(SUBSTR(P_matorg,0,13),a.matorg)
               AND (a.CLESS=NVL(SUBSTR(P_matorg,14),a.cless) OR a.cless IS NULL)
               AND a.DATNAIS=E2D(P_datnais)
             ;
          ELSE
            RETURN -1;-- Anomalie doublon de participant temporaire
          END IF;
        EXCEPTION
          WHEN TOO_MANY_ROWS THEN
            RETURN -1; -- Anomalie doublon de participant
        END;
      WHEN NO_DATA_FOUND THEN
        BEGIN
          IF loc_ano_matorg<>40 THEN
            SELECT DISTINCT NVL(a.NUMINDIV,0)
              INTO loc_numindiv
              FROM INDIVIDU a
             WHERE UPPER(a.NOM)=UPPER(P_nom)
               AND a.DATNAIS=E2D(P_datnais)
             ;
          ELSE
            RETURN 0; -- Ok pour la création d'un nouvel individu sans numéro de sécurité social
          END IF;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             RETURN 0; -- Ok pour la création d'un nouvel individu
           WHEN TOO_MANY_ROWS THEN
             RETURN -1; -- Anomalie doublon de participant
         END;
    END;
  END IF;
  RETURN loc_numindiv;

EXCEPTION
  WHEN exc_secu_social THEN
    RETURN -3;
  WHEN OTHERS THEN
    RETURN -4;
END F_FIND_PARTICIPANT;

/*----------------------------------------------------------------------------*/
/* FONCTION                                                                   */
/* Nom          :  F_FIND_SALARIE                                             */
/* Type         :  Public                                                     */
/* Description  :  Permet de faire la recherche du numéro de l individu a     */
/*                 partir du nom, numéro de sécu et de la date de naissance   */
/* Entree       :  P_matorg                                                   */
/*                 P_nom                                                      */
/*                 P_datnais                                                  */
/* Retour       :  Numindiv si trouvé,  null sinon                            */
/*               O_erreur 1 si aucun particpant trouvé, 2 si doublon          */
/*                3 ano technique, 4 si date de naissance différente  0 sinon */
/*----------------------------------------------------------------------------*/
FUNCTION F_FIND_SALARIE ( P_matorg   IN   AFFIL_PORTE.NUMSSA%TYPE DEFAULT NULL
                        , P_nom      IN   AFFIL_PORTE.NOMSAL%TYPE DEFAULT NULL
                        , P_prenom   IN   AFFIL_PORTE.PRENOM%TYPE DEFAULT NULL
                        , P_nomnais  IN   AFFIL_PORTE.NOMNAIS%TYPE DEFAULT NULL
                        , P_datnais  IN   AFFIL_PORTE.DATNAI%TYPE DEFAULT NULL
                        , P_rang     IN   AFFIL_PORTE_AYD.RANG%TYPE DEFAULT 1
                        , O_erreur   OUT  NUMBER)
RETURN NUMBER
IS

  loc_numindiv        INDIVIDU.NUMINDIV%TYPE:=NULL;
  loc_matorg          AFFIL_PORTE.NUMSSA%TYPE;
  loc_nom             AFFIL_PORTE.NOMSAL%TYPE;
  loc_prenom          AFFIL_PORTE.PRENOM%TYPE ;
  loc_nomnais         AFFIL_PORTE.NOMNAIS%TYPE;
  loc_datnais         DATE ;

  loc_ano_matorg      AFFIL_ANO.NUMANO%TYPE:=NULL;

BEGIN
  O_erreur:=0;
  loc_matorg := SUBSTR(P_matorg,0,13) ;
  loc_nom :=F_FORMAT(P_nom);
  loc_prenom :=F_FORMAT(P_prenom);
  loc_nomnais:=F_FORMAT(P_nomnais);
  loc_datnais:= E2D(P_datnais);
  -- Recherche de l assure uniquement à partir du N°SS et la date de naissance
  BEGIN
    SELECT a.NUMINDIV
      INTO loc_numindiv
      FROM INDIVIDU a
     WHERE (a.MATORG=loc_matorg OR a.MATORG2=loc_matorg) AND loc_matorg IS NOT NULL
       AND a.DATNAIS=NVL(loc_datnais,a.DATNAIS)
       AND a.NATUR=1
       AND a.rang=P_rang
       AND a.MATORG IS NOT NULL
         ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Recherche de l assuré a partir du nom, prénom et date de naissance
      BEGIN
        SELECT a.NUMINDIV
          INTO loc_numindiv
          FROM INDIVIDU a
         WHERE F_FORMAT(a.NOM)=  NVL(loc_nom,F_FORMAT(a.NOM))
           AND F_FORMAT(a.PRENOM)=  NVL(loc_Prenom,F_FORMAT(a.PRENOM))
           AND a.DATNAIS=NVL(loc_datnais,a.DATNAIS)
           AND a.rang=P_rang
           AND a.MATORG IS NOT NULL
            AND (a.MATORG=NVL(loc_matorg,a.MATORG) OR a.MATORG2=NVL(loc_matorg,a.MATORG2));
      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          -- Recherche de l assuré a partir du nom de jeune fille(nomnais), prénom et date de naissance
          BEGIN
            SELECT a.NUMINDIV
              INTO loc_numindiv
              FROM INDIVIDU a
             WHERE F_FORMAT(a.NOMJF)=  NVL(loc_nomnais,F_FORMAT(a.NOMJF))
               AND F_FORMAT(a.PRENOM)=  NVL(loc_prenom,F_FORMAT(a.PRENOM))
               AND a.DATNAIS=NVL(loc_datnais,a.DATNAIS)
               AND a.rang=P_rang
               AND a.MATORG IS NOT NULL
               AND (a.MATORG=NVL(loc_matorg,a.MATORG) OR a.MATORG2=NVL(loc_matorg,a.MATORG2));

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                -- Vérification que la date de naissance est identique entre le SI et le fichier
                SELECT a.NUMINDIV
                  INTO loc_numindiv
                  FROM INDIVIDU a
                 WHERE (F_FORMAT(a.NOM)=  NVL(loc_nom,F_FORMAT(a.NOM)) OR F_FORMAT(a.NOMJF)=  NVL(loc_nomnais,F_FORMAT(a.NOMJF)))
                   AND F_FORMAT(a.PRENOM)=  NVL(loc_prenom,F_FORMAT(a.PRENOM))
                   AND a.DATNAIS<>loc_datnais
                   AND (a.MATORG=loc_matorg OR a.MATORG2=loc_matorg )
                   AND loc_matorg IS NOT NULL
                   AND a.rang=P_rang
                   ;

                   O_erreur:=4; -- La date de naissance est différente entre le SI et le fichier

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  BEGIN

                    SELECT a.NUMINDIV
                      INTO loc_numindiv
                      FROM INDIVIDU a
                     WHERE (F_FORMAT(a.NOM)=  NVL(loc_nom,F_FORMAT(a.NOM)) OR F_FORMAT(a.NOMJF)=  NVL(loc_nomnais,F_FORMAT(a.NOMJF)))
                       AND F_FORMAT(a.PRENOM)=  NVL(loc_prenom,F_FORMAT(a.PRENOM))
                       AND a.DATNAIS=loc_datnais
                       AND NVL(a.MATORG,0)<>NVL(loc_matorg,0)
                       AND a.rang=P_rang ;

                       O_erreur:=5;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       BEGIN

                           -- 5633
                           SELECT MAX(a.NUMINDIV)
                             INTO loc_numindiv
                             FROM INDIVIDU a
                            WHERE F_FORMAT(a.NOM)=  NVL(loc_nom,F_FORMAT(a.NOM))
                              AND F_FORMAT(a.PRENOM)=  NVL(loc_prenom,F_FORMAT(a.PRENOM))
                              AND a.DATNAIS=NVL(loc_datnais,a.DATNAIS)
                              AND a.rang=P_rang
                              AND a.MATORG IS  NULL
                               ;
                         IF TRIM(TO_CHAR(loc_numindiv)) IS NOT NULL THEN
                             O_erreur:=6;    -- Assuré existant dans le SI sans n°SS
                           ELSE
                              O_erreur:=1; -- Inconnu du SI
                           END IF;
                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                         O_erreur:=1; -- Inconnu du SI
                     END;
                  END;
                WHEN OTHERS THEN  O_erreur:=2;   -- Doublon de salarié
              END;
            WHEN OTHERS THEN  O_erreur:=2;   -- Doublon de salarié
          END;
        WHEN OTHERS THEN  O_erreur:=2;   -- Doublon de salarié
      END;
    WHEN TOO_MANY_ROWS THEN
      -- Recherche de l assuré a partir du N°SS, nom, prénom et date de naissance
      BEGIN
        SELECT a.NUMINDIV
          INTO loc_numindiv
          FROM INDIVIDU a
         WHERE (a.MATORG=NVL(loc_matorg,a.matorg) OR a.MATORG2=NVL(loc_matorg,a.MATORG2))
           AND F_FORMAT(a.NOM)=  NVL(loc_nom,F_FORMAT(a.NOM))
           AND F_FORMAT(a.PRENOM)=  NVL(loc_prenom,F_FORMAT(a.PRENOM))
           AND a.DATNAIS=NVL(loc_datnais,a.DATNAIS)
           AND a.rang=P_rang
           AND a.MATORG IS NOT NULL
           AND (a.MATORG=loc_matorg OR a.MATORG2=loc_matorg) AND loc_matorg IS NOT NULL
           ;
       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           -- Recherche de l assuré a partir du nom de jeune fille(nomnais), prénom et date de naissance
           BEGIN
             SELECT a.NUMINDIV
               INTO loc_numindiv
               FROM INDIVIDU a
              WHERE (a.MATORG=NVL(loc_matorg,a.MATORG) OR a.MATORG2=NVL(loc_matorg,a.MATORG2))
                AND F_FORMAT(a.NOM)=  NVL(loc_nom,F_FORMAT(a.NOM))
                AND F_FORMAT(a.NOMJF)=NVL(loc_nomnais,F_FORMAT(a.NOMJF))
                AND F_FORMAT(a.PRENOM)=NVL(loc_prenom,F_FORMAT(a.PRENOM))
                AND a.DATNAIS=NVL(loc_datnais,a.DATNAIS)
                AND a.rang=P_rang
                AND a.MATORG IS NOT NULL
                AND (a.MATORG=loc_matorg OR a.MATORG2=loc_matorg) AND loc_matorg IS NOT NULL
                ;
           EXCEPTION
            WHEN TOO_MANY_ROWS THEN
              O_erreur:= 2;        -- Doublon de salarié
             WHEN OTHERS THEN
               O_erreur:= 1;        -- INDIVIDU INCONNU DU RC
           END;
       END;
  END;

  -- MUR M0005561 : ne plus remonter le numindiv trouvé si anomalie
  IF O_erreur != 0 then
      RETURN NULL;
  END IF;

  RETURN loc_numindiv;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(3,' Erreur : F_FIND_SALARIE impossible:'||SUBSTR(SQLERRM,1,132));
    O_erreur:=3;-- Assuré inconnu du SI
    RETURN NULL;
END F_FIND_SALARIE;

/*----------------------------------------------------------------------------*/
/* FUNCTION                                                                   */
/* Nom          :  F_FORMAT                                                   */
/* Type         :  Public                                                     */
/* Description  :                                                             */
/* Entree       :  Chaine de caractères                                       */
/* Retour       :Retourne la chaine de caractères formatée pour les selections*/
/*----------------------------------------------------------------------------*/
FUNCTION F_FORMAT ( P_Chaine   IN   VARCHAR2)
RETURN  INDIVIDU.NOM%TYPE
IS
BEGIN

  RETURN REPLACE(TRANSLATE(UPPER(P_Chaine),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÇÔ-''','AAEEEEIIaaaaeeeeiiouuUUCO '),' ','');

EXCEPTION
  WHEN OTHERS THEN
    RETURN P_Chaine;
END F_FORMAT;

/*----------------------------------------------------------------------------*/
/* FUNCTION                                                                   */
/* Nom          :  F_FORMAT2                                                  */
/* Type         :  Public                                                     */
/* Description  :                                                             */
/* Entree       :  Chaine de caractères                                       */
/* Retour       :Retourne la chaine de caractères formatée pour les insertions*/
/*----------------------------------------------------------------------------*/
FUNCTION F_FORMAT2 ( P_Chaine   IN   INDIVIDU.NOM%TYPE)
RETURN  INDIVIDU.NOM%TYPE
IS
BEGIN
  RETURN TRIM(TRANSLATE(P_Chaine,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÇÔ''','AAEEEEIIaaaaeeeeiiouuUUCO'));
EXCEPTION
  WHEN OTHERS THEN
    RETURN P_Chaine;
END F_FORMAT2;

/*----------------------------------------------------------------------------*/
/* FUNCTION                                                                   */
/* Nom          :  F_VERIF_COLONNE                                            */
/* Type         :  Public                                                     */
/* Description  :                                                             */
/* Entree       :  Nom de la table + nom de la colonne de la table            */
/* Retour       :  Retourne la longueur de la colonne                         */
/*----------------------------------------------------------------------------*/
FUNCTION F_VERIF_COLONNE ( P_TABLE   IN   USER_TAB_COLUMNS.TABLE_NAME%TYPE
                         , P_COLONNE IN   USER_TAB_COLUMNS.COLUMN_NAME%TYPE)
RETURN  USER_TAB_COLUMNS.DATA_LENGTH%TYPE
IS

  loc_data_length        USER_TAB_COLUMNS.DATA_LENGTH%TYPE:=NULL;

BEGIN

  SELECT DISTINCT DATA_LENGTH
    INTO loc_data_length
    FROM USER_TAB_COLUMNS
   WHERE TABLE_NAME=P_TABLE
     AND COLUMN_NAME =P_COLONNE
   ORDER BY DATA_LENGTH;

   RETURN loc_data_length;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_VERIF_COLONNE;

/*----------------------------------------------------------------------------*/
/* FONCTION                                                                   */
/* Nom          :  F_FIND_MATORG                                             */
/* Type         :  Public                                                     */
/* Description  :                                                             */
/* Entree       :  P_matorg                                                   */
/* Retour       :  Numindiv si trouvé, 0 si aucun particpant trouvé, 2 si     */
/*----------------------------------------------------------------------------*/
FUNCTION F_FIND_MATORG ( P_numindiv   IN   INDIVIDU.NUMINDIV%TYPE)
RETURN INDIVIDU.MATORG%TYPE
IS

  loc_matorg        INDIVIDU.MATORG%TYPE:=NULL;
  -- Recherche du N°SS
BEGIN

  SELECT (NVL(a.MATORG,a.MATORG2))
    INTO loc_matorg
    FROM INDIVIDU a
   WHERE NUMINDIV= P_numindiv
       ;
   RETURN loc_matorg;

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;
END F_FIND_MATORG;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_AFFIL_PORTE                                        */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet AFFIL_PORTE         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_AFFIL_PORTE( P_numporte     IN       AFFIL_PORTE.NUMPORTE%TYPE
                            , P_numremise    IN       AFFIL_PORTE.NUMREMISE%TYPE
                            , P_numligne     IN       AFFIL_PORTE.NUMLIGNE%TYPE
                            , P_AFFIL_PORTE  IN OUT   AFFIL_PORTE%ROWTYPE
                            , P_ano             OUT   AFFIL_ANO.NUMANO%TYPE)
IS

  CURSOR C_AFFIL_PORTE IS
    SELECT *
     FROM AFFIL_PORTE
    WHERE AFFIL_PORTE.NUMREMISE=P_numremise
      AND AFFIL_PORTE.NUMPORTE=P_numporte
      AND AFFIL_PORTE.NUMLIGNE=P_numligne
    ORDER BY NUMLIGNE ASC;

  Rec_C_AFFIL_PORTE       C_AFFIL_PORTE%ROWTYPE;

BEGIN
  P_ano:=0;

  FOR Rec_C_AFFIL_PORTE IN C_AFFIL_PORTE LOOP
    P_AFFIL_PORTE:=Rec_C_AFFIL_PORTE;
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de l affiliation impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_AFFIL_PORTE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GestionIndividu                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion d un objet INDIVIDU(init.+création)  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestionIndividu( P_AFFIL_PORTE     IN      AFFIL_PORTE%ROWTYPE
                           , P_AFFIL_PORTE_AYD IN      AFFIL_PORTE_AYD%ROWTYPE
                           , P_INDIVIDU        IN OUT  INDIVIDU%ROWTYPE
                           , P_ano                OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  loc_AFFIL_TRACE       AFFIL_TRACE%ROWTYPE;
  o_erreur VARCHAR2(1000);
  loc_couv NUMBER;
  exc_exit EXCEPTION;

BEGIN
  P_ano:=0;
  loc_couv:=0;
  --BIA en ligne : la création d’un adhérent ne doit être effectuée que si au moins un contrat et sa garantie sont identifiés.
  SELECT COUNT(numadh) INTO loc_couv
  FROM AFFIL_PORTE_ADH
  WHERE NUMREMISE = P_AFFIL_PORTE.NUMREMISE
  AND NUMPORTE = P_AFFIL_PORTE.NUMPORTE
  AND NUMLIGNE = P_AFFIL_PORTE.NUMLIGNE
  AND NUMAYD = 0
  AND NUMGAR IS NOT NULL
  AND REFGARANTIE IS NOT NULL;

  IF loc_couv =0 THEN
    RAISE exc_exit; -- on sort
  END IF;

  PK_CTRL_AFFIL.P_init_IndividuAyd( P_AFFIL_PORTE
                                    , P_AFFIL_PORTE_AYD
                                    , P_INDIVIDU
                                    , P_ano);


  IF P_ano=0 THEN
    IF PK_PERSONNE.F_INSERT_INDIVIDU(P_INDIVIDU,o_erreur) THEN
      P_ano:=0;
       -- Insertion dans AFFIL_TRACE
      loc_AFFIL_TRACE.ETENDUE:=4;--Assuré principal
      loc_AFFIL_TRACE.CLEF:=P_INDIVIDU.NUMINDIV;--Numéro d individu
      loc_AFFIL_TRACE.ACTION:='I';--insertion
      loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
      loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
      loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_TRACE.OBJET:='INDIVIDU';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='NUMINDIV';--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        P_ano:=1;
      END IF;
    ELSE
       IF o_erreur IS NOT NULL THEN
        P_INS_journal(3,o_erreur);
       END IF;
       P_ano:=2;
    END IF;
  ELSE
    P_ano:=3;
  END IF;

EXCEPTION
  WHEN exc_exit THEN NULL;
  WHEN OTHERS THEN
  P_ano:=4;
  P_INS_journal(3,' Erreur : Gestion de l individu impossible:'||SUBSTR(SQLERRM,1,132));
END P_GestionIndividu;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_INDIVIDUAYD                                        */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet INDIVIDU            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_INDIVIDUAYD( P_AFFIL_PORTE         IN      AFFIL_PORTE%ROWTYPE
                            , P_AFFIL_PORTE_AYD     IN      AFFIL_PORTE_AYD%ROWTYPE
                            , P_INDIVIDU            IN OUT  INDIVIDU%ROWTYPE
                            , P_ano                    OUT  AFFIL_ANO.NUMANO%TYPE)
IS
  L_ss            AFFIL_PORTE.NUMSSA%TYPE:=NULL;

  loc_nb NUMBER;
BEGIN

 -- P_INS_journal(3,' P_AFFIL_PORTE_AYD.NUMSSA:'||P_AFFIL_PORTE_AYD.NUMSSA);
  P_ano:=0;
  loc_nb:=0;

  P_INDIVIDU.NUMINDIV:=F_NUMERO('INDVS');
  P_INDIVIDU.TYPE:=1;
  --initialisation spécifique aux ayants droits
  IF  NVL(P_AFFIL_PORTE_AYD.NUMAYD,0) > 0 THEN
    P_INDIVIDU.NOM:=UPPER(TRIM(P_AFFIL_PORTE_AYD.NOMUSAGE));
   -- P_INDIVIDU.QUALITE:=NVL(SUBSTR(P_AFFIL_PORTE_AYD.NUMSSA,1,1),1);

    P_INDIVIDU.SEXE:=NVL(P_AFFIL_PORTE_AYD.SEXE,SUBSTR(P_AFFIL_PORTE_AYD.NUMSSA,1,1));
    P_INDIVIDU.PRENOM:=UPPER(TRIM(P_AFFIL_PORTE_AYD.PRENOM));
    P_INDIVIDU.DATNAIS:=E2D(P_AFFIL_PORTE_AYD.DATNAIS);
    P_INDIVIDU.DATNAIS_REGIME:=to_char(E2D(P_AFFIL_PORTE_AYD.DATNAIS),'ddmmyy');
    P_INDIVIDU.LIEUNAIS:=UPPER(TRIM(P_AFFIL_PORTE_AYD.LIEUNAIS));
    --GESTION du n°SS
    IF SUBSTR(P_AFFIL_PORTE_AYD.NUMSSA,11,3)='999' OR  TRIM(P_AFFIL_PORTE_AYD.NUMSSA)  IS NULL THEN
      P_INDIVIDU.N_INSEE:=NULL;
      P_INDIVIDU.MATORG:=NULL;
    ELSE
      P_INDIVIDU.N_INSEE:=P_AFFIL_PORTE_AYD.NUMSSA;
      P_INDIVIDU.MATORG:=P_AFFIL_PORTE_AYD.NUMSSA;
    END IF;
    -- on détermine la clef SS
    L_ss := Replace (P_AFFIL_PORTE_AYD.NUMSSA, '2A', '19');
    L_ss:= Replace(P_AFFIL_PORTE_AYD.NUMSSA, '2B', '18');
    P_INDIVIDU.CLESS := NVL(P_AFFIL_PORTE_AYD.NUMCLE,97- mod( to_number(L_ss), 97));
    P_INDIVIDU.TYPASSU:=2;
    P_INDIVIDU.NUMASSU:=P_AFFIL_PORTE.numindiv;
  --initialisation spécifique au salarié
  ELSE
    P_INDIVIDU.NOM:=UPPER(TRIM(NVL(P_AFFIL_PORTE.NOMSAL,P_AFFIL_PORTE.NOMNAIS)));
    P_INDIVIDU.NOMJF:=UPPER(TRIM(P_AFFIL_PORTE.NOMNAIS));
    P_INDIVIDU.SEXE:=NVL(P_AFFIL_PORTE.SEXE,SUBSTR(P_AFFIL_PORTE.NUMSSA,1,1));

    P_INDIVIDU.PRENOM:=UPPER(TRIM(P_AFFIL_PORTE.PRENOM));
    P_INDIVIDU.DATNAIS:=E2D(P_AFFIL_PORTE.DATNAI);
    P_INDIVIDU.DATNAIS_REGIME:=to_char(E2D(P_AFFIL_PORTE.DATNAI),'ddmmyy');
    P_INDIVIDU.LIEUNAIS:=UPPER(TRIM(P_AFFIL_PORTE.LIEUNAIS));
    P_INDIVIDU.NATUR:=1;
    P_INDIVIDU.REFCIE:=TO_CHAR(P_AFFIL_PORTE.MATRIC);
    --GESTION du n°SS
    IF SUBSTR(P_AFFIL_PORTE.NUMSSA,11,3)='999' OR  TRIM(P_AFFIL_PORTE.NUMSSA)  IS NULL THEN
      P_INDIVIDU.N_INSEE:=NULL;
      P_INDIVIDU.MATORG:=NULL;
    ELSE
      P_INDIVIDU.N_INSEE:=P_AFFIL_PORTE.NUMSSA;
      P_INDIVIDU.MATORG:=P_AFFIL_PORTE.NUMSSA;
    END IF;
    -- on détermine la clef SS
    L_ss := Replace (P_AFFIL_PORTE.NUMSSA, '2A', '19');
    L_ss:= Replace(L_ss, '2B', '18');
    P_INDIVIDU.CLESS := NVL(P_AFFIL_PORTE.NUMCLE,97- mod( to_number(L_ss), 97));
    P_INDIVIDU.TYPASSU:=1;
    P_INDIVIDU.NUMASSU:=P_INDIVIDU.numindiv;
  END IF;



  P_INDIVIDU.ORGBASE:=1;
  P_INDIVIDU.QUALITE:=P_INDIVIDU.SEXE;
  P_INDIVIDU.CODCOURRIER1:=P_INDIVIDU.SEXE;
  P_INDIVIDU.CODCOURRIER2:=P_INDIVIDU.SEXE;
  P_INDIVIDU.RANG:= NVL(P_AFFIL_PORTE_AYD.rang,1);
  P_INDIVIDU.TYPADR:= NVL(to_number(P_AFFIL_PORTE_AYD.TYPEAD),0);
  P_INDIVIDU.REGIME := P_AFFIL_PORTE_AYD.REGIME;
  P_INDIVIDU.GUICHETORG := P_AFFIL_PORTE_AYD.CENTRE;
  P_INDIVIDU.CAISSE := P_AFFIL_PORTE_AYD.CAISSE;

  --conjoint ou enfant avec même n° ss que le salarié
  IF  P_AFFIL_PORTE_AYD.typead >=1 AND P_AFFIL_PORTE_AYD.NUMSSA = P_AFFIL_PORTE.NUMSSA THEN
    P_INDIVIDU.NATUR:=2;
  --conjoint avec  n° ss <>n°ss salarié
  ELSIF  P_AFFIL_PORTE_AYD.typead in (1,3,7) AND P_AFFIL_PORTE_AYD.NUMSSA <> P_AFFIL_PORTE.NUMSSA THEN
     P_INDIVIDU.NATUR:=1;
  --enfant avec n° ss <> n° ss salarié
  ELSIF  P_AFFIL_PORTE_AYD.NUMSSA <> P_AFFIL_PORTE.NUMSSA THEN
     SELECT  count(numssa) INTO loc_nb
     FROM affil_porte_ayd
     WHERE numremise=P_AFFIL_PORTE.NUMREMISE
      AND numligne=P_AFFIL_PORTE.NUMLIGNE
      AND numporte=P_AFFIL_PORTE.NUMPORTE
      AND numssa = P_AFFIL_PORTE_AYD.numssa
      AND  typead in (0,1,3,7);--salarié et conjoint

      IF loc_nb = 0 THEN P_INDIVIDU.NATUR:=1;
      ELSE P_INDIVIDU.NATUR:=2;
      END IF;
  END IF;

  P_INDIVIDU.NUMUTIL:=P_AFFIL_PORTE.USERNAME_FORCAGE;
  P_INDIVIDU.CREATION:= SYSDATE; -- P_AFFIL_PORTE.DATRAIT;
 -- P_INDIVIDU.MAJ:=P_INDIVIDU.CREATION;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de l individu  impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_INDIVIDUAYD;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_INDIVIDU                                           */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet INDIVIDU            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_INDIVIDU( P_AFFIL_PORTE     IN      AFFIL_PORTE%ROWTYPE
                         , P_AFFIL_PORTE_AYD IN      AFFIL_PORTE_AYD%ROWTYPE
                         , P_INDIVIDU        IN OUT  INDIVIDU%ROWTYPE
                         , P_ano                OUT  AFFIL_ANO.NUMANO%TYPE)
IS
  L_ss    AFFIL_PORTE.NUMSSA%TYPE:=NULL;
BEGIN
  P_ano:=0;
  P_INDIVIDU.NUMINDIV:=F_NUMERO('INDVS');
  P_INDIVIDU.TYPE:=1;
  P_INDIVIDU.NOM:=(UPPER(TRIM(P_AFFIL_PORTE.NOMSAL)));
  P_INDIVIDU.NOMJF:=(UPPER(TRIM(P_AFFIL_PORTE.NOMNAIS)));
  P_INDIVIDU.QUALITE:=NVL(SUBSTR(P_AFFIL_PORTE.NUMSSA,1,1),1);
  P_INDIVIDU.CODCOURRIER1:=NVL(SUBSTR(P_AFFIL_PORTE.NUMSSA,1,1),1);
  P_INDIVIDU.CODCOURRIER2:=NVL(SUBSTR(P_AFFIL_PORTE.NUMSSA,1,1),1);
  P_INDIVIDU.NUMASSU:=P_INDIVIDU.NUMINDIV;
  P_INDIVIDU.TYPASSU:=1;
  P_INDIVIDU.RANG:=1;
  P_INDIVIDU.ORGBASE:=1;
  P_INDIVIDU.TYPADR:=0;
  P_INDIVIDU.NATUR:=1;
  IF SUBSTR(P_AFFIL_PORTE.NUMSSA,11,3)='999' OR  TRIM(P_AFFIL_PORTE.NUMSSA)  IS NULL THEN
    P_INDIVIDU.N_INSEE:=NULL;
    P_INDIVIDU.MATORG:=NULL;
  ELSE
    P_INDIVIDU.N_INSEE:=P_AFFIL_PORTE.NUMSSA;
    P_INDIVIDU.MATORG:=P_AFFIL_PORTE.NUMSSA;
  END IF;
  -- on détermine la clef SS
  L_ss := Replace ( P_AFFIL_PORTE.NUMSSA, '2A', '19');
  L_ss := Replace ( L_ss, '2B', '18');
 -- P_INDIVIDU.CLESS := 97- mod( to_number(L_ss), 97);

  P_INDIVIDU.CLESS := NVL(P_AFFIL_PORTE.NUMCLE,97- mod( to_number(L_ss), 97));
  P_INDIVIDU.PRENOM:=UPPER(TRIM(P_AFFIL_PORTE.PRENOM));
  P_INDIVIDU.DATNAIS:=E2D(P_AFFIL_PORTE.DATNAI);
  P_INDIVIDU.LIEUNAIS:=UPPER(TRIM(P_AFFIL_PORTE.LIEUNAIS));
  P_INDIVIDU.SEXE:=NVL(P_AFFIL_PORTE.SEXE,SUBSTR(P_AFFIL_PORTE.NUMSSA,1,1));
  P_INDIVIDU.REGIME := P_AFFIL_PORTE_AYD.REGIME;
  P_INDIVIDU.GUICHETORG := P_AFFIL_PORTE_AYD.CENTRE;
  P_INDIVIDU.CAISSE := P_AFFIL_PORTE_AYD.CAISSE;

  P_INDIVIDU.NUMUTIL:=P_AFFIL_PORTE.USERNAME_FORCAGE;
  P_INDIVIDU.CREATION:=SYSDATE; --P_AFFIL_PORTE.DATRAIT;
  P_INDIVIDU.MAJ:=P_INDIVIDU.CREATION;
  P_INDIVIDU.REFCIE:=TO_CHAR(P_AFFIL_PORTE.MATRIC);

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de l individu impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_INDIVIDU;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_AFFIL_ANO                                          */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet AFFIL_ANO           */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_AFFIL_ANO( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                          , P_AFFIL_ANO     IN OUT  AFFIL_ANO%ROWTYPE
                          , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  P_AFFIL_ANO.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;
  P_AFFIL_ANO.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
  P_AFFIL_ANO.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;
  P_AFFIL_ANO.DATANO:=SYSDATE; --P_AFFIL_PORTE.DATRAIT;
  P_AFFIL_ANO.NUMANO:=NULL;
  P_AFFIL_ANO.ETATANO:=NULL;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de AFFIL_ANO impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_AFFIL_ANO;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_PORTE_REMISE                                       */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet PORTE_REMISE        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_PORTE_REMISE( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                             , P_PORTE_REMISE  IN OUT  PORTE_REMISE%ROWTYPE
                             , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  P_PORTE_REMISE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;
  P_PORTE_REMISE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
  P_PORTE_REMISE.DATEREMISE:=P_AFFIL_PORTE.DATRAIT;
  P_PORTE_REMISE.BATCH:= NULL;
  P_PORTE_REMISE.DATEPORTE:= SYSDATE; -- TODO : a déterminer  loc_dateff
  P_PORTE_REMISE.NATURE:= NULL;
  P_PORTE_REMISE.REF_EXT:= NULL;
  P_PORTE_REMISE.NUMORG:=  NULL;
  P_PORTE_REMISE.REF_INT:= NULL;
  P_PORTE_REMISE.MONTANT :=   NULL;
  P_PORTE_REMISE.NORME:=  NULL;
  P_PORTE_REMISE.DESTINATAIRE:=  NULL;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de PORTE_REMISE impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_PORTE_REMISE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_NATURE_PORTE_REMISE                                 */
/* Type         :  Public                                                    */
/* Description  :  procedure de maj de la nature en fonction d'affil_fichier */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_NATURE_PORTE_REMISE( P_NUMREMISE   IN PORTE_REMISE.NUMREMISE%TYPE
                                   , P_PORTE       IN PORTE_REMISE.NUMPORTE%TYPE)
IS
 l_nature porte_remise.nature%TYPE;
BEGIN
  BEGIN
    SELECT DISTINCT NATURE INTO l_nature
    FROM AFFIL_FICHIER
    WHERE numremise = P_NUMREMISE
    AND numporte =P_PORTE;

  EXCEPTION
    WHEN OTHERS THEN l_nature :=NULL;
  END;
    --seule la nature sur porte_remise est transcodée, la nature par fichier est bien celle transmise
  IF l_nature IS NOT NULL THEN
   -- UPDATE PORTE_REMISE SET NATURE=F_GET_TRANSCO('DSN','FIC_IMP',TRIM(to_char(l_nature,'00')),2)
   UPDATE PORTE_REMISE SET NATURE=NVL(F_GET_TRANSCO('DSN','FIC_IMP',TRIM(to_char(l_nature,'00')),2),l_nature)
    WHERE NUMREMISE =P_NUMREMISE
      AND NUMPORTE =P_PORTE ;
  END IF;

END P_MAJ_NATURE_PORTE_REMISE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Gestion_Pers_histo_phys                                 */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion d un objet PERS_HISTO_PHYS           */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_Gestion_Pers_histo_phys( P_AFFIL_PORTE           IN      AFFIL_PORTE%ROWTYPE
                                   , P_AFFIL_FICHIER         IN      AFFIL_FICHIER%ROWTYPE
                                   , P_trimestre             IN      NUMBER  DEFAULT NULL
                                   , P_annee                 IN      NUMBER  DEFAULT NULL
                                   , P_INIT_PERS_HISTO_PHYS  IN OUT  PERS_HISTO_PHYS%ROWTYPE
                                   , P_ano                      OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  loc_numindiv          PERS_HISTO_PHYS.NUMINDIV%TYPE:=NULL;
  loc_AFFIL_TRACE       AFFIL_TRACE%ROWTYPE;
  loc_dateSitu          DATE;
  loc_annee             VARCHAR2(4):=NULL;
  exc_info_null         EXCEPTION;

BEGIN
  P_ano:=0;
  P_INIT_PERS_HISTO_PHYS.DEBUT:=greatest(P_AFFIL_FICHIER.datefic,E2D(P_AFFIL_PORTE.DEBUTC));
  P_INIT_PERS_HISTO_PHYS.CREATION:=SYSDATE;
  P_INIT_PERS_HISTO_PHYS.SITU_FAM:=NVL(F_get_transco('AFFIL','SITFAM',P_AFFIL_PORTE.SITFAM,2), P_AFFIL_PORTE.SITFAM);
 -- P_INIT_PERS_HISTO_PHYS.SITU_PROF:=F_get_transco('AFFIL','CADRNC',P_AFFIL_PORTE.CADRNC,2);
  P_INIT_PERS_HISTO_PHYS.SITU_PROF:=NVL(F_get_transco('DSN','SITU_PROF',P_AFFIL_PORTE.CADRNC,1),P_AFFIL_PORTE.CADRNC);
  P_INIT_PERS_HISTO_PHYS.CSP_1:=NVL(F_get_transco('AFFIL','CATEGP',P_AFFIL_PORTE.CATEGP,2),P_AFFIL_PORTE.CATEGP);
  IF P_INIT_PERS_HISTO_PHYS.SITU_FAM IS NULL AND P_INIT_PERS_HISTO_PHYS.SITU_PROF IS NULL AND  P_INIT_PERS_HISTO_PHYS.CSP_1 IS NULL THEN
    RAISE exc_info_null;
  END IF;

  -- Recherche de la personne dans PERS_HISTO_PHYS avec les critères d historisation
  SELECT NVL(MAX(p.NUMINDIV),0)
    INTO loc_numindiv
    FROM PERS_HISTO_PHYS p
    WHERE p.NUMINDIV =P_AFFIL_PORTE.NUMINDIV
      AND (p.SITU_FAM =NVL(P_INIT_PERS_HISTO_PHYS.SITU_FAM,p.SITU_FAM) OR p.SITU_FAM IS NULL)
      AND (p.SITU_PROF=NVL(P_INIT_PERS_HISTO_PHYS.SITU_PROF,p.SITU_PROF) OR p.SITU_PROF IS NULL)
      AND (p.CSP_1=NVL(P_INIT_PERS_HISTO_PHYS.CSP_1,p.CSP_1)  OR p.CSP_1 IS NULL);

  -- Création de PERS_HISTO_PHYS
  IF loc_numindiv = 0 THEN
    PK_CTRL_AFFIL.P_INIT_PERS_HISTO_PHYS( P_AFFIL_PORTE
                                        , P_INIT_PERS_HISTO_PHYS
                                        , P_ano);
    IF P_ano=0 THEN
      IF PK_PERSONNE.F_INSERT_PERS_HISTO_PHYS(P_INIT_PERS_HISTO_PHYS) THEN
         -- Insertion dans AFFIL_TRACE
        loc_AFFIL_TRACE.ETENDUE:=4;--Assuré principal
        loc_AFFIL_TRACE.CLEF:=P_INIT_PERS_HISTO_PHYS.IDPERSHISTPHYS;
        loc_AFFIL_TRACE.ACTION:='I';--insertion
        loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
        loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
        loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
        loc_AFFIL_TRACE.OBJET:='PERS_HISTO_PHYS';--Table impactée
        loc_AFFIL_TRACE.COLONNE:='IDPERSHISTPHYS';--Colonne impactée
        IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          P_ano:=1;
        END IF;
      ELSE
         P_ano:=1;
      END IF;
    ELSE
      P_ano:=1;
    END IF;
  END IF;


EXCEPTION
  WHEN exc_info_null THEN
  P_ano:=1;
  dbms_output.put_line( 'P_Gestion_Pers_histo_phys P_ano  WHEN exc_info_null THEN :'||to_char(P_ano));
  P_INS_journal(3,' exc_info_null : Gestion de pers_histo_phys impossible:'||SUBSTR(SQLERRM,1,132));
  WHEN OTHERS THEN
  P_ano:=1;
  dbms_output.put_line( 'P_Gestion_Pers_histo_phys P_ano  WHEN OTHERS THEN :'||to_char(P_ano));
  P_INS_journal(3,' Erreur : Gestion de pers_histo_phys impossible:'||SUBSTR(SQLERRM,1,132));
END P_Gestion_Pers_histo_phys;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_PERS_HISTO_PHYS                                    */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation objet P_INIT_PERS_HISTO_PHYS   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_PERS_HISTO_PHYS( P_AFFIL_PORTE              IN     AFFIL_PORTE%ROWTYPE
                                , P_INIT_PERS_HISTO_PHYS  IN OUT  PERS_HISTO_PHYS%ROWTYPE
                                , P_ano                      OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  ID_HISTPHYS PERS_HISTO_PHYS.IDPERSHISTPHYS%TYPE:=NULL;

BEGIN



  SELECT IDPERSHISTPHYS.NEXTVAL INTO ID_HISTPHYS FROM DUAL;
  P_ano:=0;
  P_INIT_PERS_HISTO_PHYS.IDPERSHISTPHYS:=ID_HISTPHYS;
  P_INIT_PERS_HISTO_PHYS.NUMINDIV:=P_AFFIL_PORTE.NUMINDIV;
  P_INIT_PERS_HISTO_PHYS.DEBUT:=NVL(P_INIT_PERS_HISTO_PHYS.DEBUT,SYSDATE);
  P_INIT_PERS_HISTO_PHYS.NUMUTIL:=P_AFFIL_PORTE.USERNAME_FORCAGE;
  P_INIT_PERS_HISTO_PHYS.CREATION:=SYSDATE; -- P_INIT_PERS_HISTO_PHYS.CREATION;
 -- P_INIT_PERS_HISTO_PHYS.MAJ:=P_INIT_PERS_HISTO_PHYS.CREATION;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de pers_histo_phys impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_PERS_HISTO_PHYS;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FIND_NUMUTIL_ADRESSE                                    */
/* Type         :  Public                                                    */
/* Description  :  fonction de recherche du numutil de PERS_ADRESSE          */
/* Retour       :  loc_numutil                                               */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_NUMUTIL_ADRESSE(P_NUMINDIV   IN      AFFIL_PORTE.NUMINDIV%TYPE)
RETURN PERS_ADRESSE.NUMUTIL%TYPE
IS
  loc_numutil PERS_ADRESSE.NUMUTIL%TYPE:=0;
BEGIN

  SELECT p.NUMUTIL
    INTO loc_numutil
    FROM PERS_ADRESSE p
   WHERE p.NUMINDIV=P_NUMINDIV
     AND p.IDADRESSE=PK_PERSONNE.F_IDADRESSE(P_NUMINDIV)
     ;

  RETURN loc_numutil;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0 ;
  WHEN OTHERS THEN
    RETURN -1 ;
END F_FIND_NUMUTIL_ADRESSE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Gestion_Pers_adresse                                    */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion d un objet PERS_ADRESSE              */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_Gestion_Pers_adresse( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                                , P_PERS_ADRESSE  IN OUT  PERS_ADRESSE%ROWTYPE
                                , P_dateff        IN      CONTRAT.DATEFF%TYPE
                                , P_RG_ADR_DIFF   IN      BOOLEAN
                                , P_warning          OUT  VARCHAR2
                                , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  loc_numindiv            PERS_ADRESSE.NUMINDIV%TYPE:=NULL;
  loc_numutil             PERS_ADRESSE.NUMUTIL%TYPE:=NULL;
  loc_AFFIL_TRACE         AFFIL_TRACE%ROWTYPE;
  loc_idadresse_encours   PERS_ADRESSE.IDADRESSE%TYPE:=NULL;
  loc_warning             AFFIL_ANO.NUMANO%TYPE:=0;
  exc_adresse             EXCEPTION;
  exc_warning             EXCEPTION;
  loc_adr_encours_debut   DATE;

BEGIN
  P_ano:=0;
  P_warning:=NULL;
  --recherche de l'adresse en cours du salarié
  loc_idadresse_encours:= PK_PERSONNE.F_IDADRESSE(P_AFFIL_PORTE.NUMINDIV);

  -- Vérification que la dernière adresse saisi valide n'est pas issue d une saisie manulle
  -- ou si l adresse n existe pas
  /* IF F_FIND_NUMUTIL_ADRESSE(P_AFFIL_PORTE.NUMINDIV) IN (P_AFFIL_PORTE.USERNAME_FORCAGE,F_NUMUTIL)
  OR loc_idadresse_encours= 0  THEN*/

  -- Initialisation des éléments connu afin de faire la recherche d un changement ou création d adresse
  P_PERS_ADRESSE.NUMUTIL:=P_AFFIL_PORTE.USERNAME_FORCAGE;
  P_PERS_ADRESSE.DEBUT:=greatest(E2D(P_AFFIL_PORTE.DEBUTC),P_dateff);
  P_PERS_ADRESSE.MAJ:=SYSDATE; -- P_AFFIL_PORTE.DATRAIT;
  P_PERS_ADRESSE.NO_VOIE:= PK_PERSONNE.F_DECOMPOSE(P_AFFIL_PORTE.ADREVOIE,1);
  P_PERS_ADRESSE.NOM_VOIE:=UPPER(SUBSTR(PK_PERSONNE.F_DECOMPOSE(P_AFFIL_PORTE.ADREVOIE,4),1,30));
  P_PERS_ADRESSE.TYPE_VOIE := UPPER(PK_PERSONNE.F_DECOMPOSE( P_AFFIL_PORTE.ADREVOIE, 3));
  P_PERS_ADRESSE.BIS := PK_PERSONNE.F_DECOMPOSE( P_AFFIL_PORTE.ADREVOIE, 2);
  P_PERS_ADRESSE.ADRESSE_2:=UPPER(SUBSTR(P_AFFIL_PORTE.COMPLAD,1,30));
  --P_PERS_ADRESSE.COMP_ADRESSE:=SUBSTR(P_AFFIL_PORTE.ADREVOIE,1,30);
  P_PERS_ADRESSE.CODPOS:=P_AFFIL_PORTE.CODPOS;
  P_PERS_ADRESSE.VILLE:=UPPER(P_AFFIL_PORTE.VILLE);

  -- comparaison de l'adresse externe avec celle en cours
  SELECT NVL(MAX(NUMINDIV),0)
    INTO loc_numindiv
    FROM PERS_ADRESSE p
   WHERE p.NUMINDIV=P_AFFIL_PORTE.NUMINDIV
     AND p.NO_VOIE=NVL(P_PERS_ADRESSE.NO_VOIE,p.NO_VOIE)
     AND F_FORMAT(p.NOM_VOIE)=NVL(F_FORMAT(P_PERS_ADRESSE.NOM_VOIE),F_FORMAT(p.NOM_VOIE))
    -- AND p.NUMUTIL=P_AFFIL_PORTE.USERNAME_FORCAGE -- adresse créée par le système
     --AND p.COMP_ADRESSE=NVL(P_PERS_ADRESSE.COMP_ADRESSE,p.COMP_ADRESSE)
     AND p.CODPOS=NVL(P_PERS_ADRESSE.CODPOS,p.CODPOS)
     AND F_FORMAT(p.VILLE)=NVL(F_FORMAT(P_PERS_ADRESSE.VILLE),F_FORMAT(p.VILLE))
     AND p.IDADRESSE=loc_idadresse_encours -- récupère la dernière adresse saisie
     ;

  loc_adr_encours_debut := SYSDATE;
  IF loc_idadresse_encours <> 0 THEN
  SELECT DEBUT
    INTO loc_adr_encours_debut
    FROM PERS_ADRESSE
   WHERE IDADRESSE=loc_idadresse_encours -- récupère la dernière adresse saisie
    ;
  END IF;
  -- pas de création d'adresse si l'adresse en cours est postérieure au fichier DSN
  -- SDA 5376 ajout du OR
  IF loc_adr_encours_debut < P_PERS_ADRESSE.DEBUT OR loc_idadresse_encours = 0 THEN

    IF loc_numindiv = 0 THEN

      PK_CTRL_AFFIL.P_INIT_PERS_ADRESSE( P_AFFIL_PORTE
                                       , P_PERS_ADRESSE
                                       , P_ano);

      IF P_ano<>0 THEN
        P_ano:=1;
        RAISE exc_adresse;
      END IF;

      IF loc_idadresse_encours <> 0 THEN

          IF P_RG_ADR_DIFF THEN    -- Règle de gestion de la DSN
            -- Affinage beaucoup moins large de la recherche d adresse car beaucoup d erreurs de saisie
            -- sont possible entre le SI et le fichiers DSN/affiliation
            SELECT NVL(MAX(NUMINDIV),0)
              INTO loc_numindiv
              FROM PERS_ADRESSE p
             WHERE p.NUMINDIV=P_AFFIL_PORTE.NUMINDIV
               AND p.CODPOS=NVL(P_PERS_ADRESSE.CODPOS,p.CODPOS)
               AND F_FORMAT(p.VILLE)=NVL(F_FORMAT(P_PERS_ADRESSE.VILLE),F_FORMAT(p.VILLE))
               AND p.IDADRESSE=loc_idadresse_encours  ;
            IF loc_numindiv > 0 THEN
              RAISE exc_warning;  --on sort
            END IF;
          END IF;

          -- Fermeture de l adresse actuelle, Création de PERS_ADRESSE
          -- Avant d insérer une nouvelle adresse, on enlève l adresse par défaul de la précédente
          UPDATE PERS_ADRESSE SET DEFAUT='N'
          WHERE DEFAUT='O'
          AND IDADRESSE=loc_idadresse_encours;
          -- Insertion dans AFFIL_TRACE
          loc_AFFIL_TRACE.ETENDUE:=26;--Adresse
          loc_AFFIL_TRACE.CLEF:=loc_idadresse_encours;
          loc_AFFIL_TRACE.CLEF2:='O';
          loc_AFFIL_TRACE.ACTION:='U';--mise a jour
          loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
          loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
          loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
          loc_AFFIL_TRACE.OBJET:='PERS_ADRESSE';--Table impactée
          loc_AFFIL_TRACE.COLONNE:='IDADRESSE';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE2:='DEFAUT';--Colonne impactée
          IF NOT PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
            P_ano:=2;
            RAISE exc_adresse;
          END IF;

      END IF;

      -- Insertion de la nouvelle adresse
      IF NOT PK_PERSONNE.F_INSERT_PERS_ADRESSE(P_PERS_ADRESSE) THEN
        P_ano:=4;
        RAISE exc_adresse;
      END IF;
      -- Insertion dans AFFIL_TRACE
      loc_AFFIL_TRACE.ETENDUE:=26;--Adresse
      loc_AFFIL_TRACE.CLEF:=PK_PERSONNE.F_IDADRESSE(P_AFFIL_PORTE.NUMINDIV);
      loc_AFFIL_TRACE.ACTION:='I';--insertion
      loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
      loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
      loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_TRACE.OBJET:='PERS_ADRESSE';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='IDADRESSE';--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE)=FALSE THEN
        P_ano:=5;
        RAISE exc_adresse;
      END IF;
    END IF;
  END IF;

EXCEPTION
  WHEN exc_adresse THEN
   NULL;
  WHEN exc_warning THEN
     P_ano:=0;
     P_warning:='Adresse existante mais une des informations de l adresse est différentes du SI';
  WHEN OTHERS THEN
  P_ano:=7;
  P_INS_journal(3,' Erreur pour assuré :'||P_AFFIL_PORTE.NUMINDIV||', gestion de l adresse impossible:'||SQLERRM);
END P_Gestion_Pers_adresse;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_PERS_ADRESSE                                       */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet PERS_ADRESSE        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_PERS_ADRESSE( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                             , P_PERS_ADRESSE  IN OUT  PERS_ADRESSE%ROWTYPE
                             , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  P_PERS_ADRESSE.IDADRESSE:=NULL;--IDADRESSE.NEXTVAL;
  P_PERS_ADRESSE.NUMINDIV:=P_AFFIL_PORTE.NUMINDIV;
  P_PERS_ADRESSE.TYPE:=1;
  P_PERS_ADRESSE.CODOPE:=0;
  P_PERS_ADRESSE.NUMGAR:=0;
  P_PERS_ADRESSE.DEFAUT:='O';
  P_PERS_ADRESSE.NUMUTIL:=P_AFFIL_PORTE.USERNAME_FORCAGE;   -- P_PERS_ADRESSE.NUMUTIL;
  P_PERS_ADRESSE.TYPE_VOIE:=P_PERS_ADRESSE.TYPE_VOIE;
  P_PERS_ADRESSE.FLAG_CEDEX:='N';
  P_PERS_ADRESSE.NO_CEDEX:=NULL;
  P_PERS_ADRESSE.CODPAYS:=PK_DEVISE.PAYS_REF;
  P_PERS_ADRESSE.NPAI:='N';


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de l adresse impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_PERS_ADRESSE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Gestion_Contact                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure de controle du contrat de l affiliation         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_Gestion_Contact( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                           , P_CONTACT       IN OUT  CONTACT%ROWTYPE
                           , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  loc_AFFIL_TRACE    AFFIL_TRACE%ROWTYPE;
  loc_idcontact      CONTACT.IDCONTACT%TYPE;
  loc_coordonne      CONTACT.COORDONNEE%TYPE;
 -- loc_numutil_ant    CONTACT.NUMUTIL%TYPE;

BEGIN
  --Vérification de la présence de la coordonnée par défaut
  SELECT NVL(MAX(-1),0)
    INTO P_ano
    FROM CONTACT c
   WHERE UPPER(c.COORDONNEE)=UPPER(P_CONTACT.COORDONNEE)
     AND c.numindiv=P_CONTACT.NUMINDIV
     AND c.nature = P_CONTACT.NATURE
     AND c.type =  P_CONTACT.TYPE
     AND c.flag='O';

  --si la coordonnée n'est pas présente on sauvegarde les valeurs des anciennes coordonnées
  IF P_ano = 0 THEN
    BEGIN
      SELECT MAX(c.IDCONTACT) , TRIM(c.COORDONNEE)
        INTO loc_idcontact, loc_coordonne
        FROM CONTACT c
       WHERE c.numindiv= P_CONTACT.NUMINDIV
         AND c.nature = P_CONTACT.NATURE
         AND c.type =  P_CONTACT.TYPE
         AND c.flag='O'
        GROUP BY c.COORDONNEE;
    EXCEPTION
      WHEN OTHERS THEN loc_idcontact :=0;
    END;
    --aucune coordonnée existante, alors on créé le contact
    IF loc_idcontact = 0 THEN

      SELECT ARTHUS.IDCONTACT.NEXTVAL INTO loc_idcontact FROM DUAL;
      P_CONTACT.IDCONTACT:=loc_idcontact;
      IF PK_CTRL_AFFIL.F_INSERT_CONTACT(P_CONTACT) THEN
        -- Insertion dans AFFIL_TRACE
        P_ano:=0;
        loc_AFFIL_TRACE.ETENDUE:=4;--Individu
        loc_AFFIL_TRACE.CLEF:=loc_idcontact;
        loc_AFFIL_TRACE.CLEF3:=loc_idcontact;
        loc_AFFIL_TRACE.ACTION:='I';--insertion
        loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
        loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
        loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
        loc_AFFIL_TRACE.OBJET:='CONTACT';--Table impactée
        loc_AFFIL_TRACE.COLONNE:='IDCONTACT';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE3:='COORDONNEE';--Colonne impactée
        IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          P_ano:=1;
        END IF;
      ELSE
        P_ano:=1;
      END IF;
    --sinon mise à jour de la coordonnée
    ELSE

      UPDATE CONTACT SET COORDONNEE=LOWER(P_CONTACT.COORDONNEE)  , NUMUTIL= P_CONTACT.NUMUTIL
       WHERE numindiv=P_CONTACT.NUMINDIV
       AND idcontact  =loc_idcontact;

      loc_AFFIL_TRACE.ETENDUE:=4;--Individu
      loc_AFFIL_TRACE.CLEF:=loc_idcontact;
      loc_AFFIL_TRACE.CLEF3:=loc_coordonne;
      loc_AFFIL_TRACE.ACTION:='U';--MAJ
      loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
      loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
      loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_TRACE.OBJET:='CONTACT';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='IDCONTACT';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE3:='COORDONNEE';--Colonne impactée
  --    loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_numutil_ant,'DD/MM/YYYY');
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        P_ano:=1;
      END IF;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur :Gestion Contact impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=1;
END P_Gestion_Contact;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_INSERT_CONTACT                                          */
/* Type         :  Public                                                    */
/* Description  :  fonction de insertion dans CONTACT                        */
/* Retour       :  TRUE=>OK, FALSE=>KO                                       */
/*---------------------------------------------------------------------------*/
FUNCTION F_INSERT_CONTACT( P_CONTACT IN CONTACT%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO CONTACT VALUES P_CONTACT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1 ,'P_CONTACT WHEN OTHERS THEN'||SUBSTR(SQLERRM,1,132));
    RETURN FALSE;
END F_INSERT_CONTACT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GEST_RIB                                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de création du rib de l affiliation             */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_GEST_RIB( P_AFFIL_PORTE      IN          AFFIL_PORTE%ROWTYPE
                    , i_log              IN  OUT     JOURNAL_ADM.MSG_ADM%TYPE
                    , P_ano                  OUT     AFFIL_ANO.NUMANO%TYPE)
IS

  loc_AFFIL_PORTE_RIB   AFFIL_PORTE_RIB%ROWTYPE;
  --loc_AFFIL_TRACE       AFFIL_TRACE%ROWTYPE;
  exc_rib               EXCEPTION;

BEGIN

  P_ano:=0;

  BEGIN
    SELECT *
      INTO loc_AFFIL_PORTE_RIB
      FROM AFFIL_PORTE_RIB  r
     WHERE r.NUMREMISE=P_AFFIL_PORTE.NUMREMISE
       AND r.NUMPORTE=P_AFFIL_PORTE.NUMPORTE
       AND r.NUMLIGNE=P_AFFIL_PORTE.NUMLIGNE
       AND r.NUMAYD=0
       AND r.MODE_PAIE =1;
  EXCEPTION
   WHEN OTHERS THEN
     RETURN; --aucun rib à intégrer
  END;

  BEGIN
    IF  loc_AFFIL_PORTE_RIB.IDRIB IS NULL THEN
      UPDATE RIB SET
         intitule = NVL(loc_AFFIL_PORTE_RIB.titulaire,intitule),
         domiciliation = loc_AFFIL_PORTE_RIB.domiciliation,
         codbque=null,
         guichet=null,
         compte=null,
         clerib=null,
         bban=substr(loc_AFFIL_PORTE_RIB.IBAN,5),
         clef_iban=substr(loc_AFFIL_PORTE_RIB.IBAN,0,4),
         bic = loc_AFFIL_PORTE_RIB.BIC,
         numutil_creation =F_NUMUTIL,
         codpays =1,
         nature = 2,
         modpmt =2
      WHERE numindiv = P_AFFIL_PORTE.NUMINDIV
        AND loc_AFFIL_PORTE_RIB.IBAN IS NOT NULL
        AND substr(loc_AFFIL_PORTE_RIB.IBAN,5)<>NVL(BBAN,0);

      UPDATE AFFIL_PORTE_RIB  r
         SET IDRIB = F_BENE_RIB(P_AFFIL_PORTE.NUMINDIV,0,NULL,1,NULL,sysdate+1) , NUMINDIV = P_AFFIL_PORTE.NUMINDIV
       WHERE r.NUMREMISE=P_AFFIL_PORTE.NUMREMISE
         AND r.NUMPORTE=P_AFFIL_PORTE.NUMPORTE
         AND r.NUMLIGNE=P_AFFIL_PORTE.NUMLIGNE
         AND r.NUMAYD=0
         AND r.MODE_PAIE =1;
   END IF;


  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(3,  i_log||' Création rib impossible 1:'||SUBSTR(SQLERRM,1,132));
      RAISE exc_rib;
  END;


EXCEPTION
  WHEN exc_rib THEN
  P_INS_journal(3, i_log||' Création rib impossible 2 :'||SUBSTR(SQLERRM,1,132));
  P_ano:=2;
  WHEN OTHERS THEN
  P_INS_journal(3, i_log||' Erreur : Création rib KO impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=1;
END P_GEST_RIB;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ctrl_Contrat                                            */
/* Type         :  Public                                                    */
/* Description  :  procedure de controle du contrat de l affiliation         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ctrl_Contrat( P_DATRAIT       IN      AFFIL_PORTE.DATRAIT%TYPE
                        , P_NUMGAR        IN      CONTRAT.NUMGAR%TYPE
                        , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN

  -- Le contrat doit être en vigueur à la date d effet de l affiliation
  SELECT 0
    INTO P_ano
    FROM DUAL
   WHERE PK_HISTO_CONTRAT.F_SEL_DATE_DEBUT(P_NUMGAR) <= TRUNC(P_DATRAIT,'q')
     AND PK_HISTO_CONTRAT.F_SEL_ETAT(P_NUMGAR) = 1;


EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur : Controle du contrat impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=1;
END P_ctrl_Contrat;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GestionAffiliation                                      */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion l affiliation                        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestionAffiliation( P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                              , P_AFFIL_PORTE_ADH  IN OUT  AFFIL_PORTE_ADH%ROWTYPE
                              , P_ano              OUT     AFFIL_ANO.NUMANO%TYPE)
IS

  loc_numfor            ADHESION.NUMFOR%TYPE:=NULL;
  loc_ADHE_CNTRT        ADHE_CNTRT%ROWTYPE;
  loc_AFFIL_ANO         AFFIL_ANO%ROWTYPE;
  loc_HISTO_ADHESION    HISTO_ADHESION%ROWTYPE;
  loc_ADHE_CNTRT_MEMBRE ADHE_CNTRT_MEMBRE%ROWTYPE;
  loc_ADHESION          ADHESION%ROWTYPE;
  loc_AFFIL_TRACE       AFFIL_TRACE%ROWTYPE;
  loc_idhistoadhe       HISTO_ADHESION.IDHISTOADHE%TYPE;
  exc_adhecntrt         EXCEPTION;
  exc_histo_adhesion    EXCEPTION;
  exc_adhe_membre       EXCEPTION;
  exc_adhesion          EXCEPTION;

BEGIN

  P_INS_journal(3,' Début P_GestionAffiliation, P_AFFIL_PORTE_ADH.NUMGAR: '||P_AFFIL_PORTE_ADH.NUMGAR);

  P_AFFIL_PORTE.IDADHESION:=NULL;
--  IF P_AFFIL_PORTE.NUMGAR IS NULL THEN
  --  P_AFFIL_PORTE.NUMGAR:=P_AFFIL_PORTE_ADH.NUMGAR;
--  END IF;
  ---------------------------------------------------------------------------------
  -- ********************** CREATION ADHE_CNTRT************************************
  ---------------------------------------------------------------------------------

  PK_CTRL_AFFIL.P_INIT_ADHE_CNTRT( P_AFFIL_PORTE
                                 , P_AFFIL_PORTE_ADH.NUMGAR
                                 , e2d(P_AFFIL_PORTE.DEBUTC) -- P_dateff
                                 , loc_ADHE_CNTRT
                                 , P_ano);

 -- P_AFFIL_PORTE.IDADHESION:=loc_ADHE_CNTRT.IDADHESION;
  P_AFFIL_PORTE_ADH.IDADHESION:=loc_ADHE_CNTRT.IDADHESION;
  P_INS_journal(3,' P_GestionAffiliation, P_AFFIL_PORTE_ADH.IDADHESION: '||P_AFFIL_PORTE_ADH.IDADHESION);
  IF P_ano<>0 THEN
    RAISE exc_adhecntrt;
  END IF;
  IF PK_CTRL_AFFIL.F_INSERT_ADHE_CNTRT(loc_ADHE_CNTRT) THEN
     -- Insertion dans AFFIL_TRACE
    loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
    loc_AFFIL_TRACE.CLEF:=loc_ADHE_CNTRT.IDADHESION;
    loc_AFFIL_TRACE.ACTION:='I';--insertion
    loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
    loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
    loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
    loc_AFFIL_TRACE.OBJET:='ADHE_CNTRT';--Table impactée
    loc_AFFIL_TRACE.COLONNE:='IDADHESION';--Colonne impactée
    IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
      P_ano:=0;
    ELSE
      RAISE exc_adhecntrt;
    END IF;
  ELSE
    RAISE exc_adhecntrt;
  END IF;

  ---------------------------------------------------------------------------------
  -- ********************** CREATION HISTO_ADHESION********************************
  ---------------------------------------------------------------------------------
  IF e2d(P_AFFIL_PORTE.DEBUTC) > sysdate THEN      -- M0006008 : gestion adhesion dans le futur => mise en instance
  PK_CTRL_AFFIL.P_INIT_HISTO_ADHESION( P_AFFIL_PORTE
                                     , P_AFFIL_PORTE_ADH
                                     , e2d(P_AFFIL_PORTE.DEBUTC) -- P_dateff
                                     , loc_HISTO_ADHESION
                                     , P_ano);
    loc_HISTO_ADHESION.etat :=0; --création en instance
    loc_HISTO_ADHESION.debut := trunc(sysdate);
    IF PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_HISTO_ADHESION) THEN
      P_ano:=0;
    ELSE
      RAISE exc_histo_adhesion;
    END IF;
  END IF;

  --mise en vigueur
  PK_CTRL_AFFIL.P_INIT_HISTO_ADHESION( P_AFFIL_PORTE
                                     , P_AFFIL_PORTE_ADH
                                     , e2d(P_AFFIL_PORTE.DEBUTC) -- P_dateff
                                     , loc_HISTO_ADHESION
                                     , P_ano);
  P_INS_journal(3,' P_GestionAffiliation, P_INIT_HISTO_ADHESION: '||P_AFFIL_PORTE_ADH.IDADHESION);
  IF P_ano<> 0 THEN
    RAISE exc_histo_adhesion;
  END IF;
  IF PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_HISTO_ADHESION) THEN
    P_ano:=0;
  ELSE
    RAISE exc_histo_adhesion;
  END IF;

  ---------------------------------------------------------------------------------
  -- ********************** CREATION ADHE_CNTRT_MEMBRE*****************************
  ---------------------------------------------------------------------------------
  PK_CTRL_AFFIL.P_INIT_ADHE_CNTRT_MEMBRE( P_AFFIL_PORTE_ADH
                                        , loc_ADHE_CNTRT_MEMBRE
                                        , P_ano);
  P_INS_journal(3,' P_GestionAffiliation, P_INIT_ADHE_CNTRT_MEMBRE: '||P_AFFIL_PORTE_ADH.IDADHESION);
  IF P_ano<>0 THEN
    RAISE exc_adhe_membre;
  END IF;

  IF PK_CTRL_AFFIL.F_INSERT_ADHE_CNTRT_MEMBRE(loc_ADHE_CNTRT_MEMBRE) THEN
    P_ano:=0;
  ELSE
    RAISE exc_adhe_membre;
  END IF;
  P_INS_journal(3,' FIN P_GestionAffiliation');


EXCEPTION
  WHEN exc_adhecntrt THEN
    P_ano:=-4;
  WHEN exc_histo_adhesion THEN
    P_ano:=-6;
  WHEN exc_adhe_membre THEN
    P_ano:=-9;
  WHEN exc_adhesion THEN
    P_ano:=-12;
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur : P_GestionAffiliation impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=-14;
END P_GestionAffiliation;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GestionAffil_Resil                                      */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion l affiliation puis résiliation       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
/*PROCEDURE P_GestionAffil_Resil( P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                              , P_AFFIL_PORTE_ADH  IN OUT  AFFIL_PORTE_ADH%ROWTYPE
                              , P_ano              OUT     AFFIL_ANO.NUMANO%TYPE)
IS

  loc_numfor            ADHESION.NUMFOR%TYPE:=NULL;
  loc_ADHE_CNTRT        ADHE_CNTRT%ROWTYPE;
  loc_AFFIL_ANO         AFFIL_ANO%ROWTYPE;
  loc_HISTO_ADHESION    HISTO_ADHESION%ROWTYPE;
  loc_AFFIL_TRACE       AFFIL_TRACE%ROWTYPE;
  loc_idhistoadhe       HISTO_ADHESION.IDHISTOADHE%TYPE;
  exc_adhecntrt         EXCEPTION;
  exc_histo_adhesion    EXCEPTION;
  exc_resil             EXCEPTION;


BEGIN

  ---------------------------------------------------------------------------------
  -- ********************** AFFILIATION********************************************
  ---------------------------------------------------------------------------------

  P_AFFIL_PORTE.IDADHESION:=NULL;
--  IF P_AFFIL_PORTE.NUMGAR IS NULL THEN
    P_AFFIL_PORTE.NUMGAR:=P_AFFIL_PORTE_ADH.NUMGAR;
--  END IF;
  ---------------------------------------------------------------------------------
  -- ********************** CREATION ADHE_CNTRT************************************
  ---------------------------------------------------------------------------------

  PK_CTRL_AFFIL.P_INIT_ADHE_CNTRT( P_AFFIL_PORTE
                                 , P_AFFIL_PORTE_ADH.NUMGAR
                                 , e2d(P_AFFIL_PORTE.DEBUTC) -- P_dateff
                                 , loc_ADHE_CNTRT
                                 , P_ano);

 -- P_AFFIL_PORTE.IDADHESION:=loc_ADHE_CNTRT.IDADHESION;
  P_AFFIL_PORTE_ADH.IDADHESION:=loc_ADHE_CNTRT.IDADHESION;

  IF P_ano<>0 THEN
    RAISE exc_adhecntrt;
  END IF;
  IF PK_CTRL_AFFIL.F_INSERT_ADHE_CNTRT(loc_ADHE_CNTRT) THEN
     -- Insertion dans AFFIL_TRACE
    loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
    loc_AFFIL_TRACE.CLEF:=loc_ADHE_CNTRT.IDADHESION;
    loc_AFFIL_TRACE.ACTION:='I';--insertion
    loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
    loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
    loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
    loc_AFFIL_TRACE.OBJET:='ADHE_CNTRT';--Table impactée
    loc_AFFIL_TRACE.COLONNE:='IDADHESION';--Colonne impactée
    IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
      P_ano:=0;
    ELSE
      RAISE exc_adhecntrt;
    END IF;
  ELSE
    RAISE exc_adhecntrt;
  END IF;

  ---------------------------------------------------------------------------------
  -- ********************** CREATION HISTO_ADHESION********************************
  ---------------------------------------------------------------------------------
  PK_CTRL_AFFIL.P_INIT_HISTO_ADHESION( P_AFFIL_PORTE
                                     , P_AFFIL_PORTE_ADH
                                     , e2d(P_AFFIL_PORTE.DEBUTC) -- P_dateff
                                     , loc_HISTO_ADHESION
                                     , P_ano);
  IF P_ano<> 0 THEN
    RAISE exc_histo_adhesion;
  END IF;
  IF PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_HISTO_ADHESION) THEN
    P_ano:=0;
  ELSE
    RAISE exc_histo_adhesion;
  END IF;

  ---------------------------------------------------------------------------------
  -- ********************** RESILIATION********************************************
  ---------------------------------------------------------------------------------


    --************** Résiliation de l'adhésion **************--
    P_AFFIL_PORTE.MOTIF:= NVL(f_get_transco('DSN', 'HISTO_ADHE',NVL(P_AFFIL_PORTE.MOTIFS,P_AFFIL_PORTE.MOTIFA),1),P_AFFIL_PORTE.MOTIFS);
    PK_TRANSFERT.p_resilie_adhe( P_AFFIL_PORTE_ADH.NUMGAR
                               , P_AFFIL_PORTE_ADH.IDADHESION
                               , P_AFFIL_PORTE.NUMINDIV
                               , P_AFFIL_PORTE.MOTIF
                               , E2D(P_AFFIL_PORTE.FINCON)+1);

    -- Mise à jour du Motif dans AFFIL_PORTE
    PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                         , P_ano);
    IF P_ano > 0 THEN
      RAISE exc_resil;
    END IF;

    -- recherche de la clef idhistoadhe necessaire a l annulation de la résiliation
    SELECT NVL(MAX(a.idhistoadhe),0)
      INTO loc_idhistoadhe
      FROM HISTO_ADHESION a
     WHERE A.IDADHESION=P_AFFIL_PORTE_ADH.IDADHESION
       AND TRUNC(a.datsai)=TRUNC(SYSDATE)       -- date d insertion dans histo_adhesion
      AND a.etat=3;

    IF P_ano > 0 THEN
      RAISE exc_resil;
    END IF;
    -- Gestion de l historisation des actions effectuées sur ma résiliation de l adhésion
    loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
    loc_AFFIL_TRACE.CLEF:=loc_idhistoadhe;
    loc_AFFIL_TRACE.ACTION:='I';--insertion
    loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
    loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
    loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
    loc_AFFIL_TRACE.OBJET:='HISTO_ADHESION';--Table impactée
    loc_AFFIL_TRACE.COLONNE:='IDHISTOADHE';--Colonne impactée
    IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
      P_ano:=0;
    ELSE
      RAISE exc_resil;
    END IF;
    loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE_ADH.IDADHESION;
    loc_AFFIL_TRACE.ACTION:='U';--Mise a jour Update
    loc_AFFIL_TRACE.OBJET:='ADHESION';--Table impactée
    loc_AFFIL_TRACE.COLONNE:='DATPER';--Colonne impactée
    IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
      P_ano:=0;
    ELSE
      RAISE exc_resil;
    END IF;

    loc_AFFIL_TRACE.COLONNE:='MOTIF';--Colonne impactée
    IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
      P_ano:=0;
    ELSE
      RAISE exc_resil;
    END IF;

    loc_AFFIL_TRACE.OBJET:='ADHE_CNTRT';--Table impactée
    loc_AFFIL_TRACE.COLONNE:='DATE_FIN_ADHE';--Colonne impactée
    IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
      P_ano:=0;
    ELSE
      RAISE exc_resil;
    END IF;



EXCEPTION
  WHEN exc_adhecntrt THEN
    P_ano:=-4;
  WHEN exc_histo_adhesion THEN
    P_ano:=-6;
  WHEN exc_resil THEN
    P_ano:=-6;
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur : P_GestionAffil_Resil impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=-14;
END P_GestionAffil_Resil;
*/
/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_MEMBRE_HORS_ADHESION                               */
/* Type         :  Public                                                    */
/* Description  :  fonction qui controle si un membre d une famille n est pas /
/*                 couvert par une autre adhesion                            */
/* Retour       :  numgar=>OK, 0=>KO                                         */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_MEMBRE_HORS_ADHESION( P_IDADHESION IN        AFFIL_PORTE_ADH.IDADHESION%TYPE
                                    , P_NUMINDIV   IN        AFFIL_PORTE.NUMINDIV%TYPE
                                    , P_NUMGAR     IN        AFFIL_PORTE_ADH.NUMGAR%TYPE)
RETURN NUMBER
IS

  loc_warning     NUMBER:=0;
  loc_idadhesion  NUMBER:=0;


  CURSOR c_membre IS
  SELECT a.NUMINDIV,cn.numgar
    FROM ADHE_CNTRT_MEMBRE a ,ADHE_CNTRT ad,contrat cn
   WHERE a.IDADHESION=P_IDADHESION
   AND ad.IDADHESION=a.IDADHESION
   AND ad.NUMGAR = cn.NUMGAR
   AND cn.typequit =1
    -- AND a.NUMINDIV<>P_NUMINDIV assuré adhérent y compris
   ;

  rec_membre    c_membre%ROWTYPE;

BEGIN
  --on parcourt les membres des adhésions de bases uniquement pour savoir s'ils ont une option ou une surco
  FOR rec_membre  IN  c_membre LOOP
  --  controle si un membre de la famille n est pas couvert par une autre adhesion
    BEGIN
      SELECT count(a.idadhesion)
        INTO loc_warning
        FROM ADHE_CNTRT a
           , CONTRAT c
       WHERE a.numadhe=rec_membre.NUMINDIV
         AND F_ETAT_ADHE(a.idadhesion,SYSDATE)=1
         AND a.IDADHESION<>P_IDADHESION
         AND a.date_fin_adhe IS  NULL
         AND c.NUMGAR=a.NUMGAR
         AND c.NUMGAR <> rec_membre.numgar
         AND c.TYPEQUIT<>1        -- Niveau d'appel des cotisations ne doit pas se faire au niveau contrat(libelle.mnemo='TYPQ')
         AND c.numgar not in (
          SELECT numde FROM DEPENDANCE WHERE role = 2 AND numenvers=rec_membre.numgar) --contrat option non lié à une base
         ;
      IF loc_warning > 0 THEN
        loc_warning:=loc_warning+1;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        loc_warning:=0;
      WHEN OTHERS THEN
        loc_warning:=0;
    END;

  END LOOP;

  RETURN loc_warning;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_CTRL_MEMBRE_HORS_ADHESION;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GestionRadiation                                        */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion de la radiation et suspension        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestionRadiation( P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                            , P_AFFIL_PORTE_ADH  IN      AFFIL_PORTE_ADH%ROWTYPE
                            , P_etat_adhesion    IN      ADHESION.ETAT%TYPE
                            , P_flag_newindiv    IN      NUMBER
                            , P_ctrlcot          IN      NUMBER
                            , P_ano                 OUT  AFFIL_ANO.NUMANO%TYPE
                            , P_warning             OUT  NUMBER
                            )

IS

  loc_AFFIL_TRACE         AFFIL_TRACE%ROWTYPE;
  loc_idhistoadhe         HISTO_ADHESION.IDHISTOADHE%TYPE;
  loc_cotis               NUMBER:=0; -- flag de cotisations saisies
  loc_date_adhe           ADHE_CNTRT.DATE_ADHE%TYPE;
  loc_fin_adhe            ADHE_CNTRT.DATE_FIN_ADHE%TYPE;

  -- exception
  exc_cotisation          EXCEPTION;
  exc_cot_emis            EXCEPTION;
  exc_cot_prelev          EXCEPTION;
  exc_cot_affec           EXCEPTION;
  exc_susp_exist          EXCEPTION;
  exc_resil_exist         EXCEPTION;
  exc_resil_newindiv      EXCEPTION;
  exc_susp_newindiv       EXCEPTION;
  exc_resil               EXCEPTION;
  exc_histo_resil         EXCEPTION;
  exc_suspension          EXCEPTION;

BEGIN

  IF F_ETAT_ADHE(P_AFFIL_PORTE_ADH.idadhesion , E2D(P_AFFIL_PORTE.DEBEFF))=P_etat_adhesion
     AND P_AFFIL_PORTE.TYPE_MVT = 3 THEN
      RAISE exc_susp_exist; -- Adhésion déjà suspendu
  ELSIF F_ETAT_ADHE(P_AFFIL_PORTE_ADH.idadhesion , E2D(P_AFFIL_PORTE.FINCON))=P_etat_adhesion
     AND P_AFFIL_PORTE.TYPE_MVT = 5 THEN
      RAISE exc_resil_exist; -- Adhésion déjà résiliée
  END IF;

  -- 2) Vérification que le salarié n est pas nouveau dans le système suite à l import DSN
  IF P_flag_newindiv = 1 AND P_AFFIL_PORTE_ADH.idadhesion IS NULL THEN
    IF P_AFFIL_PORTE.TYPE_MVT = 3 THEN
      RAISE exc_susp_newindiv; -- Suspension d un nouveau salarié
    ELSIF P_AFFIL_PORTE.TYPE_MVT = 5 THEN
      RAISE exc_resil_newindiv; -- Résiliation d un nouveau salarié
    END IF;
  END IF;

  --------------------------------------------------------------------------------
  -- 3) Résiliation de l'adhésion
  --------------------------------------------------------------------------------
  IF P_AFFIL_PORTE.TYPE_MVT IN (5,7,10) THEN

    IF P_ctrlcot =1 THEN
      --CTRLRESCOT
      -- Vérification de la présence de cotisation engagée dans un processus de gestion
      P_VERIF_ANNUL_COTISATION(P_AFFIL_PORTE, P_AFFIL_PORTE_ADH.idadhesion, loc_cotis);
      P_INS_journal(3,' P_GestionRadiation adhesion :'||P_AFFIL_PORTE_ADH.idadhesion||':'||loc_cotis);
      IF loc_cotis = 1 THEN
        RAISE exc_cot_prelev;
      ELSIF loc_cotis = 2 THEN
        RAISE exc_cot_emis;
      ELSIF loc_cotis = 3 THEN
        RAISE exc_cot_affec;
      ELSIF loc_cotis = 5 THEN
        RAISE exc_cotisation;
      END IF;
    END IF;

    --************** Résiliation de l'adhésion **************--
    P_AFFIL_PORTE.MOTIF:= NVL(f_get_transco('DSN', 'HISTO_ADHE',NVL(P_AFFIL_PORTE.MOTIFS,P_AFFIL_PORTE.MOTIFA),1),P_AFFIL_PORTE.MOTIFS);

    BEGIN
      SELECT DATE_ADHE INTO loc_date_adhe FROM ADHE_CNTRT WHERE IDADHESION  = P_AFFIL_PORTE_ADH.idadhesion;
    EXCEPTION
       WHEN OTHERS THEN RAISE exc_resil;
    END;

    loc_fin_adhe:=E2D(NVL(P_AFFIL_PORTE.FINCON,P_AFFIL_PORTE.DEBEFF));
    --ABO 30/06/2017 contrôle si adhésion bien antérieure au mouvement
    IF loc_date_adhe <= loc_fin_adhe THEN

      PK_TRANSFERT.p_resilie_adhe( P_AFFIL_PORTE_ADH.NUMGAR
                                 , P_AFFIL_PORTE_ADH.idadhesion
                                 , P_AFFIL_PORTE.NUMINDIV
                                 , P_AFFIL_PORTE.MOTIF
                                 , loc_fin_adhe --le pk_transfert fait un -1, debeff pour gérer le mouvement 10
                                 , P_AFFIL_PORTE.USERNAME_FORCAGE) ; -- MUR M0005418

      -- Mise à jour du Motif dans AFFIL_PORTE
      PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                           , P_ano);
      IF P_ano > 0 THEN
        RAISE exc_resil;
      END IF;
      -- recherche de la clef idhistoadhe necessaire a l annulation de la résiliation
      SELECT NVL(MAX(a.idhistoadhe),0)
        INTO loc_idhistoadhe
        FROM HISTO_ADHESION a
       WHERE A.IDADHESION=P_AFFIL_PORTE_ADH.idadhesion
         AND TRUNC(a.datsai)=TRUNC(SYSDATE)       -- date d insertion dans histo_adhesion
        AND a.etat=3;

      IF P_ano > 0 THEN
        RAISE exc_resil;
      END IF;
      -- Gestion de l historisation des actions effectuées sur ma résiliation de l adhésion
      loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
      loc_AFFIL_TRACE.CLEF:=loc_idhistoadhe;
      loc_AFFIL_TRACE.ACTION:='I';--insertion
      loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
      loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
      loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_TRACE.OBJET:='HISTO_ADHESION';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='IDHISTOADHE';--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        RAISE exc_resil;
      END IF;
      loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE_ADH.idadhesion;
      loc_AFFIL_TRACE.CLEF2:= to_char(loc_fin_adhe,'dd/mm/yyyy'); --MUR M0005606
      loc_AFFIL_TRACE.ACTION:='U';--Mise a jour Update
      loc_AFFIL_TRACE.OBJET:='ADHESION';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='DATPER';--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        RAISE exc_resil;
      END IF;

      loc_AFFIL_TRACE.COLONNE:='MOTIF';--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        RAISE exc_resil;
      END IF;

      loc_AFFIL_TRACE.OBJET:='ADHE_CNTRT';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='DATE_FIN_ADHE';--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        RAISE exc_resil;
      END IF;

      --si la résiliation s'est bien terminée :
      P_ANNUL_COT_PREV(P_AFFIL_PORTE, P_AFFIL_PORTE_ADH.idadhesion,loc_fin_adhe,P_ctrlcot, loc_cotis);
      IF loc_cotis = 4 THEN
        P_warning:=122;
      END IF;
  END IF;

  --------------------------------------------------------------------------------
  -- 4) Suspension de l'adhésion
  --------------------------------------------------------------------------------
  ELSIF P_AFFIL_PORTE.TYPE_MVT = 3 THEN

    SELECT IDHISTOADHE.nextval
    INTO loc_idhistoadhe
    FROM DUAL;
    BEGIN
      INSERT INTO HISTO_ADHESION(IDADHESION, DEBUT, DATSAI, ETAT, MOTIF, NUMUTIL,IDHISTOADHE)
        VALUES(P_AFFIL_PORTE_ADH.idadhesion, E2D(P_AFFIL_PORTE.DEBEFF),SYSDATE, P_etat_adhesion, P_AFFIL_PORTE.MOTIF, P_AFFIL_PORTE.USERNAME_FORCAGE ,loc_idhistoadhe);
    EXCEPTION
      WHEN exc_cotisation THEN
        RAISE exc_cotisation;
      WHEN OTHERS THEN
        RAISE exc_suspension;
    END;

    -- Gestion de l historisation des actions effectuées sur ma résiliation de l adhésion
    loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
    loc_AFFIL_TRACE.CLEF:=loc_idhistoadhe;
    loc_AFFIL_TRACE.ACTION:='I';--insertion
    loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
    loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
    loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
    loc_AFFIL_TRACE.OBJET:='HISTO_ADHESION';--Table impactée
    loc_AFFIL_TRACE.COLONNE:='IDHISTOADHE';--Colonne impactée
    IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
      P_ano:=0;
    ELSE
      RAISE exc_suspension;
    END IF;

  END IF;

EXCEPTION
  WHEN exc_cot_prelev THEN
    P_ano:=120; -- Cotisations issues de prélévements
  WHEN exc_cot_emis THEN
    P_ano:=118; -- Cotisations sur l adhésion optionnelle
  WHEN exc_cot_affec THEN
    P_ano:=119; -- Cotisations sur l adhésion optionnelle
  WHEN exc_cotisation THEN
    P_ano:=75; -- Cotisations en cours à la date de résiliation
  WHEN exc_resil_exist THEN
    P_ano:= 0 ; -- 68; -- Adhésion déjà résiliée
  WHEN exc_susp_exist THEN
    P_ano:=69; -- Adhésion déjà suspendue
  WHEN exc_resil_newindiv THEN
    P_ano:=70; -- Résiliation d un nouveau salarié
  WHEN exc_susp_newindiv THEN
    P_ano:=71; -- Suspension d un nouveau salarié
  WHEN exc_resil THEN
    P_ano:=35;  -- Impossible de résilier l''adhésion
  WHEN exc_suspension THEN
    P_ano:=73;  -- Impossible de suspendre l''adhésion
  WHEN OTHERS THEN
    P_INS_journal(3,' Erreur : P_GestionRadiation impossible:'||SUBSTR(SQLERRM,1,132));
    P_ano:=72;  -- Erreur indéterminée pour la radiation
END P_GestionRadiation;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_ADHESION                                           */
/* Type         :  Public                                                    */
/* Description  :  Fonction de gestion l affiliation                         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_ADHESION( P_AFFIL_PORTE_ADH   IN      AFFIL_PORTE_ADH%ROWTYPE
                        , P_AFFIL_PORTE       IN      AFFIL_PORTE%ROWTYPE
                        , P_AFFIL_FICHIER     IN      AFFIL_FICHIER%ROWTYPE
                        , P_ano               IN OUT  AFFIL_ANO.NUMANO%TYPE)
RETURN AFFIL_PORTE_ADH.IDADHESION%TYPE
IS
  loc_idadhesion    AFFIL_PORTE.IDADHESION%TYPE;
  loc_date_adhe     ADHE_CNTRT.DATE_ADHE%TYPE;
 -- loc_dateMax       ADHE_CNTRT.DATE_ADHE%TYPE;

BEGIN


  --ABO 30/06/2017 ajout du contrôle de date_adhe pour palier la fonction f_etat_adhe
  SELECT DISTINCT NVL(MAX(ac.IDADHESION),0)-- , ac.DATE_ADHE
    INTO loc_idadhesion--, loc_date_adhe
    FROM-- ADHE_CNTRT_MEMBRE acm
        ADHE_CNTRT ac
       , CONTRAT c
   WHERE ac.NUMADHE=P_AFFIL_PORTE_ADH.NUMINDIV
     AND ac.NUMGAR=P_AFFIL_PORTE_ADH.NUMGAR
     AND c.NUMGAR=ac.NUMGAR
     AND F_ETAT_ADHE(ac.IDADHESION,GREATEST(P_AFFIL_FICHIER.DATEFIC,e2d(P_AFFIL_PORTE.DEBUTC))) IN (0,1)
     AND ac.DATE_ADHE < add_months(P_AFFIL_FICHIER.DATEFIC,2);   -- MUR M0006008 élargir le périmètre à deux mois au lieu d'un seul

 -- P_INS_journal(3,'  F_FIND_ADHESION loc_idadhesion 0 :'||to_char(loc_idadhesion));

  IF loc_idadhesion= 0  THEN
    SELECT DISTINCT NVL(MAX(ac.IDADHESION),0)-- , ac.DATE_ADHE
      INTO loc_idadhesion--, loc_date_adhe
      FROM --ADHE_CNTRT_MEMBRE acm
          ADHE_CNTRT ac
         , CONTRAT c
     WHERE ac.NUMADHE=P_AFFIL_PORTE_ADH.NUMINDIV
       AND ac.NUMGAR=P_AFFIL_PORTE_ADH.NUMGAR
       AND c.NUMGAR=ac.NUMGAR
       AND F_ETAT_ADHE(ac.IDADHESION,e2d(P_AFFIL_PORTE.FINCON)-1)=3
       AND ac.DATE_ADHE < add_months(P_AFFIL_FICHIER.DATEFIC,2);   -- MUR M0006008  élargir le périmètre à deux mois au lieu d'un seul
  END IF;


  IF loc_idadhesion> 0  THEN
    SELECT DISTINCT MAX(ac.DATE_ADHE)  INTO loc_date_adhe FROM ADHE_CNTRT ac WHERE  ac.IDADHESION = loc_idadhesion;
  ELSE loc_idadhesion :=NULL;
  END IF;

  IF loc_idadhesion IS NULL THEN
    P_ano:=15;       -- Adhésion non trouvée
  ELSIF E2D(P_AFFIL_PORTE.DEBUTC) > loc_date_adhe THEN
    P_ano:=67;       -- Date d entrée postèrieure à l''affiliation
  END IF;

  RETURN loc_idadhesion;

EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur : F_FIND_ADHESION impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=8;     -- Adhésion non traitée ou trouvée
  RETURN NULL;
END F_FIND_ADHESION;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_NUMFOR                                             */
/* Type         :  Public                                                    */
/* Description  :  Fonction de gestion l affiliation                         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_NUMFOR( P_NUMGAR           IN      AFFIL_PORTE_ADH.NUMGAR%TYPE
                      , P_CODE_OPT         IN      AFFIL_PORTE_ADH.CODE_OPT%TYPE
                      , P_AFFIL_FICHIER    IN      AFFIL_FICHIER%ROWTYPE
                      , P_ano              IN OUT  AFFIL_ANO.NUMANO%TYPE)
RETURN ADHESION.NUMFOR%TYPE
IS
  loc_numfor    ADHESION.NUMFOR%TYPE:=0;
  loc_couv      NUMBER:=0;
BEGIN
  loc_numfor:=NULL;
  IF P_ano =0 THEN

    BEGIN

    IF P_CODE_OPT IS NOT NULL THEN
      SELECT MIN(gar.NUMFOR)  INTO loc_numfor
      FROM GAR_PARAM_DETAIL g, CONTRAT c, v_GAR_CNTRT gar
      WHERE (g.CODE_OPTION = P_CODE_OPT OR g.LIB_OPTION = P_CODE_OPT)
      AND P_CODE_OPT IS NOT NULL
       AND c.numgar = P_NUMGAR
       AND c.numgar = gar.numgar
       AND gar.numfor = g.numfor
       AND P_AFFIL_FICHIER.datefic BETWEEN gar.debut AND NVL(gar.fin,P_AFFIL_FICHIER.datefic);

      --si le code option est vide, il n'est pas présent dans gar_param_detail.
      --Il doit donc être rechercher en fonction des garanties porteuses de tarification de cotisation en cours
    ELSIF P_CODE_OPT IS NULL THEN
        SELECT MIN(gar.NUMFOR)  INTO loc_numfor
        FROM  CONTRAT c, v_GAR_CNTRT gar, frml_prime_simple cot
        WHERE P_CODE_OPT IS  NULL
         AND c.numgar = P_NUMGAR
         AND c.numgar = gar.numgar
         AND gar.numfor = cot.numfor
         AND P_AFFIL_FICHIER.datefic BETWEEN gar.debut AND NVL(gar.fin,P_AFFIL_FICHIER.datefic)
         AND P_AFFIL_FICHIER.datefic BETWEEN cot.debut AND NVL(cot.fin,P_AFFIL_FICHIER.datefic)
         -- M0005437
         --AND (NOT EXISTS (select numfor FROM GAR_PARAM_DETAIL WHERE numfor =  gar.numfor)
         --  OR EXISTS (select numfor FROM GAR_PARAM_DETAIL WHERE numfor =  gar.numfor AND code_option IS NULL));
         AND (NOT EXISTS (select g.numfor FROM GAR_PARAM_DETAIL g WHERE g.numfor = gar.numfor AND (g.seq = cot.seq OR NVl(g.seq,0) =0) )
              OR EXISTS (select numfor FROM GAR_PARAM_DETAIL WHERE numfor =  gar.numfor AND code_option IS NULL AND (seq = cot.seq OR NVl(seq,0) =0)));

    END IF;

  --  P_INS_journal(3,'  F_FIND_NUMFOR loc_numfor:'||to_char(loc_numfor));

    IF NVL(loc_numfor,0) = 0 THEN
      P_ano:=63;   -- Garantie non trouvée
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_ano:=63; -- Garantie non trouvée
      WHEN TOO_MANY_ROWS THEN
        P_ano:=64; -- Doublon de garantie
    END;
  END IF;

 -- P_INS_journal(3,'  F_FIND_NUMFOR loc_numfor 2 :'||to_char(loc_numfor));
  IF NVL(loc_numfor,0) = 0 AND P_ano <>0 THEN
    INSERT INTO AFFIL_ANO (numremise, numporte, numligne,numano,datano,etatano)
    SELECT p.numremise, p.numporte ,p.numligne,P_ano,sysdate,3
    FROM affil_porte_adh adh, affil_porte p
    WHERE p.numremise = P_AFFIL_FICHIER.numremise
    AND p.numporte = P_AFFIL_FICHIER.numporte
    AND p.numremise = adh.numremise
    AND p.numporte = adh.numporte
    AND p.numligne = adh.numligne
    AND adh.numayd = 0
    AND p.etabli = P_AFFIL_FICHIER.etabli
    AND p.entreprise = P_AFFIL_FICHIER.entreprise
    AND p.num_ordre = P_AFFIL_FICHIER.num_ordre
    AND adh.numgar =P_NUMGAR
    AND NVL(adh.code_opt,0) = NVl(P_CODE_OPT,0)
    AND NOT EXISTS (
      SELECT numano FROM  AFFIL_ANO
      WHERE numremise = P_AFFIL_FICHIER.numremise
      AND numporte = P_AFFIL_FICHIER.numporte
      AND numligne = adh.numligne
      AND numano = P_ano);
  END IF;
  RETURN loc_numfor;
EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur : Recherche de la garantie impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=65;  -- Recherche indéterminéé de la garantie
  RETURN NULL;
END F_FIND_NUMFOR;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_COUVERT_GAR                                             */
/* Type         :  Public                                                    */
/* Description  :  Fonction de gestion l affiliation                         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_COUVERT_GAR( P_AFFIL_PORTE_ADH  IN      AFFIL_PORTE_ADH%ROWTYPE
                      , P_AFFIL_PORTE      IN      AFFIL_PORTE%ROWTYPE
                      , P_AFFIL_FICHIER    IN      AFFIL_FICHIER%ROWTYPE)
RETURN NUMBER
IS
  loc_numfor    ADHESION.NUMFOR%TYPE:=0;
BEGIN
  -- Contrôle de couverture du salarié pour la garantie trouvée en fonction de l'adhésion, individu et du contrat
  -- Se fait uniquement sur une continuité d adhésion
  IF P_AFFIL_PORTE.TYPE_MVT=2 AND P_AFFIL_PORTE_ADH.REFGARANTIE IS NOT NULL THEN
    SELECT DISTINCT NVL(MAX( a.numfor),0)
      INTO loc_numfor
      FROM ADHESION a
     WHERE a.NUMINDIV = P_AFFIL_PORTE.NUMINDIV
       AND P_AFFIL_FICHIER.datefic BETWEEN a.datapli AND nvl(a.datper, P_AFFIL_FICHIER.datefic)
       AND a.NUMFOR = P_AFFIL_PORTE_ADH.REFGARANTIE
       AND a.NUMGAR = P_AFFIL_PORTE_ADH.NUMGAR
       AND a.IDADHESION = P_AFFIL_PORTE_ADH.IDADHESION;
    IF loc_numfor = 0 THEN
      RETURN 66; -- Salarié non couvert par la garantie trouvée
    ELSE
      RETURN 0;
    END IF;
  END IF;

  RETURN loc_numfor;

EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur : F_COUVERT_GAR impossible:'||SUBSTR(SQLERRM,1,132));
  --P_ano:=65;  --TODO
  RETURN 0;
END F_COUVERT_GAR;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_MVT                                                */
/* Type         :  Public                                                    */
/* Description  :  Fonction de gestion l affiliation                         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_MVT( P_AFFIL_PORTE      IN OUT  AFFIL_PORTE%ROWTYPE
                   , P_AFFIL_FICHIER    IN      AFFIL_FICHIER%ROWTYPE
                   , P_ano                 OUT  AFFIL_ANO.NUMANO%TYPE)
RETURN AFFIL_PORTE.TYPE_MVT%TYPE
IS
  Loc_MVT                 AFFIL_PORTE.TYPE_MVT%TYPE;
  Loc_MVT_init            AFFIL_PORTE.TYPE_MVT%TYPE;
  loc_numgar              AFFIL_PORTE_ADH.NUMGAR%TYPE;

BEGIN
--  P_INS_journal(3,' F_FIND_MVT');
  Loc_MVT:=NULL;
  P_ano:=0;

  -- DEBUTC   ==>  date d affiliation
  -- DEBEFF   ==> date debut de suspension
  -- FINCON   ==> date de radiation

  ---------------------------------------------------------------------------------
  -- **********************CONTROLES INCOHERENCES MOUVEMENT ***********************
  ---------------------------------------------------------------------------------
  IF TRIM(P_AFFIL_PORTE.DEBUTC) IS NULL THEN
    P_ano := 74;  -- Date de debut d''adhésion non renseignée
  ELSIF (TRIM(P_AFFIL_PORTE.MOTIFA) IS NULL  AND TRIM(P_AFFIL_PORTE.DEBEFF) IS NOT NULL)
    OR (TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL  AND TRIM(P_AFFIL_PORTE.MOTIFS) IS NULL) THEN
    P_ano := 45;  -- Motif de résiliation manquant
  ELSIF E2D(P_AFFIL_PORTE.FINCON) <=E2D(P_AFFIL_PORTE.DEBUTC) THEN
    P_ano:=77;
  END IF;



  ---------------------------------------------------------------------------------
  -- ********************** TYPE MOUVEMENT ****************************************
  ---------------------------------------------------------------------------------
  IF P_ano =0 THEN
    -- Affiliation
    IF TRIM(P_AFFIL_PORTE.DEBUTC) IS NOT NULL THEN
      IF E2D(P_AFFIL_PORTE.DEBUTC) >= P_AFFIL_FICHIER.DATEFIC THEN
        Loc_MVT :=1; --affiliation
        Loc_MVT_init:=1;
      ELSE
        Loc_MVT :=2; -- continuite affiliation
        Loc_MVT_init:=2;
      END IF;
    END IF;
    -- Portage
    IF Loc_MVT=5 THEN
      IF  ((TRIM(P_AFFIL_PORTE.ACCROI_TEMP) = '02'
      AND TRIM(P_AFFIL_PORTE.FINCON_DD) = '11'
      AND TRIM(P_AFFIL_PORTE.MOTIFS) = '031'
      AND TRIM(P_AFFIL_PORTE.MAINT_AFFIL) = '01')
      OR P_AFFIL_PORTE.MOTIFS ='999') --motif propre au saisonnier
      THEN
        Loc_MVT :=11; -- Affiliation en portage
        P_ano:=-1;
      END IF;
    END IF;

    -- suspension

    IF TRIM(P_AFFIL_PORTE.DEBEFF) IS NOT NULL THEN
      IF E2D(P_AFFIL_PORTE.DEBEFF) >= P_AFFIL_FICHIER.DATEFIC AND Loc_MVT_init = 1 THEN
        Loc_MVT :=8; --affiliation puis suspension
      ELSIF E2D(P_AFFIL_PORTE.DEBEFF) >= P_AFFIL_FICHIER.DATEFIC AND  E2D(P_AFFIL_PORTE.FINEFF) < ADD_MONTHS (P_AFFIL_FICHIER.DATEFIC,1) THEN
       Loc_MVT:=9;--si le début et la fin de suspension sont sur le mois du fichier : Suspension non intégréee
      ELSIF E2D(P_AFFIL_PORTE.DEBEFF) >= P_AFFIL_FICHIER.DATEFIC AND Loc_MVT_init =2 THEN
        Loc_MVT :=3; --suspension
      ELSE
        Loc_MVT :=4; -- continuite suspension
      END IF;
    END IF;

    /*RG spé 02/05/2007
    112 – invalidité catégorie 1
    114 – invalidité catégorie 2
    116 – invalidité catégorie 3
    200 – COP (congés payés) – absence sans motif
    507 – chômage intempéries
    602 – chômage sans rupture de contrat
    647 – réduction temps d’emploi*/

    -- résiliation
    IF TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL THEN

      IF E2D(P_AFFIL_PORTE.FINCON) >=ADD_MONTHS(P_AFFIL_FICHIER.DATEFIC,1) THEN
        Loc_MVT:=Loc_MVT_init; --fincon > fin du mois
      ELSIF E2D(P_AFFIL_PORTE.FINCON) >= P_AFFIL_FICHIER.DATEFIC AND Loc_MVT_init = 1  THEN
        Loc_MVT :=7; --affiliation puis radiation

      ELSIF E2D(P_AFFIL_PORTE.FINCON) >= P_AFFIL_FICHIER.DATEFIC AND Loc_MVT_init = 2  THEN
        Loc_MVT :=5; --radiation
      ELSE
        Loc_MVT :=6; -- continuite radiation
      END IF;
    END IF;

    IF Loc_MVT=3 AND  P_AFFIL_PORTE.MOTIFS NOT IN (112 ,114,116 ,200,507,602 ,647 ) THEN
      Loc_MVT:=10;--Suspension traitée en radiation
    END IF;

  END IF;

  IF Loc_MVT IS NULL AND P_ano =0 THEN
    P_ano:=77;
  END IF;

  RETURN Loc_MVT;

EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur : F_FIND_MVT impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=77;
  RETURN NULL;
END F_FIND_MVT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GestionAdhesion                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion de l adhesion lié à l affiliation    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestionAdhesion( P_AFFIL_PORTE   IN OUT  AFFIL_PORTE%ROWTYPE
                           , P_mvt           IN OUT  NUMBER
                           , P_dateff        IN      CONTRAT.DATEFF%TYPE
                           , P_flag_integ    IN      NUMBER
                           , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE
                           , P_regul            OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  loc_ADHE_CNTRT        ADHE_CNTRT%ROWTYPE;
  loc_AFFIL_ANO         AFFIL_ANO%ROWTYPE;
  loc_HISTO_ADHESION    HISTO_ADHESION%ROWTYPE;
  loc_ADHE_CNTRT_MEMBRE ADHE_CNTRT_MEMBRE%ROWTYPE;
  loc_ADHESION          ADHESION%ROWTYPE;
  loc_AFFIL_TRACE       AFFIL_TRACE%ROWTYPE;
  loc_idhistoadhe       HISTO_ADHESION.IDHISTOADHE%TYPE;
  loc_sens              LIBELLE.SENS%TYPE:=NULL;
  --loc_date              AFFIL_PORTE.DEBEFF%TYPE;
  --loc_motif             ADHESION.MOTIF%TYPE;
  loc_numgarMut         ADHE_CNTRT.NUMGAR%TYPE:=NULL; -- Contrat différent de celui de la société gérée (Mutation))
  loc_idadhesionMut     ADHE_CNTRT.IDADHESION%TYPE:=NULL; -- Contrat différent de celui de la société gérée (Mutation))
  loc_salTA             NUMBER(11,2);
  loc_salTB             NUMBER(11,2);

  loc_flag_debloc       NUMBER:=0;
  loc_flag_resil        NUMBER:=0;
  loc_flag_adhe         NUMBER:=0;

  exc_resil             EXCEPTION;
  exc_motif_plein       EXCEPTION;
  exc_motif_vide        EXCEPTION;
  exc_motif_inconnu     EXCEPTION;
  exc_mutation          EXCEPTION;
  exc_deja_resil        EXCEPTION;
  exc_affil_salTA       EXCEPTION;


BEGIN

  P_ano:=0;
  loc_flag_debloc:=0;
  loc_salTA :=0;
  loc_salTB :=0;
  P_regul:=0;

  ---------------------------------------------------------------------------------
  -- ********************** DEBLOCAGE********************************************
  ---------------------------------------------------------------------------------
  IF NVL(P_AFFIL_PORTE.IDADHESION,0)>0 AND P_flag_integ=0 THEN -- Concerne un déblocage de l adhesion d une affiliation
    BEGIN
      loc_flag_debloc:=1;
      SELECT a.idadhesion
        INTO P_AFFIL_PORTE.IDADHESION
        FROM ADHE_CNTRT a
       WHERE a.numgar=P_AFFIL_PORTE.NUMGAR
         AND a.numadhe=P_AFFIL_PORTE.NUMINDIV
         AND F_ETAT_ADHE(a.idadhesion, P_AFFIL_PORTE.DATRAIT)=1
         AND a.date_fin_adhe IS NULL
       --  AND F_FIND_CONTRAT_RU(P_AFFIL_PORTE.NUMGAR)> 0
         AND a.IDADHESION=P_AFFIL_PORTE.IDADHESION;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          -- Recherche d une adhésion résiliée
          SELECT MAX(a.idadhesion)
            INTO P_AFFIL_PORTE.IDADHESION
            FROM ADHE_CNTRT a
           WHERE a.numgar=P_AFFIL_PORTE.NUMGAR
             AND a.numadhe=P_AFFIL_PORTE.NUMINDIV
          --   AND F_FIND_CONTRAT_RU(P_AFFIL_PORTE.NUMGAR)> 0
             AND F_ETAT_ADHE(a.idadhesion, P_AFFIL_PORTE.DATRAIT)=3
             AND a.IDADHESION=P_AFFIL_PORTE.IDADHESION;
        EXCEPTION
          WHEN OTHERS THEN
            P_ano:=-18;
        END;
    END;
  ELSE


    ---------------------------------------------------------------------------------
    -- ********************** RECHERCHE**********************************************
    ---------------------------------------------------------------------------------
    BEGIN
      -- Recherche de l adhésion en fonction du contrat et du numéro d adhérent
      SELECT a.idadhesion
        INTO P_AFFIL_PORTE.IDADHESION
        FROM ADHE_CNTRT a
       WHERE a.numgar=P_AFFIL_PORTE.NUMGAR
         AND a.numadhe=P_AFFIL_PORTE.NUMINDIV
         AND F_ETAT_ADHE(a.idadhesion, P_AFFIL_PORTE.DATRAIT)=1
         AND a.date_fin_adhe IS NULL;

      IF ((TRIM(P_AFFIL_PORTE.MOTIFA) IS NULL AND TRIM(P_AFFIL_PORTE.DEBEFF) IS NULL)
      AND (TRIM(P_AFFIL_PORTE.MOTIFS) IS NULL AND TRIM(P_AFFIL_PORTE.FINCON) IS NULL)) THEN
        P_mvt:=3; --continuité adhésion
      END IF;

    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        P_ano:=-20; --doublons d'adhésion sur le contrat RU
      WHEN NO_DATA_FOUND THEN
        BEGIN
          -- Recherche d une adhésion RU résiliée sur le contrat
          SELECT a.idadhesion
            INTO P_AFFIL_PORTE.IDADHESION
            FROM ADHE_CNTRT a
           WHERE a.numgar=P_AFFIL_PORTE.NUMGAR
             AND a.numadhe=P_AFFIL_PORTE.NUMINDIV
             AND F_ETAT_ADHE(a.idadhesion, P_AFFIL_PORTE.DATRAIT)=3;
          IF --(
             NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.')),0) > 1500
          --OR NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),0) >1500)
          THEN
            IF (TRIM(P_AFFIL_PORTE.MOTIFA) IS NULL AND TRIM(P_AFFIL_PORTE.DEBEFF) IS NULL) THEN
              P_mvt:=0;
              P_regul:=2;
            ELSE
              IF (TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL AND TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL) THEN
                P_mvt := 4;
                PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,46,7,P_AFFIL_PORTE.DATRAIT);--Continuité d'' Adhésion RU déjà résiliée
                P_regul:=1; --P_regul
              END IF;
            END IF;
          ELSE
            IF (TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL AND TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL) THEN
              P_mvt := 4;
              PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,46,7,P_AFFIL_PORTE.DATRAIT);--Continuité d'' Adhésion RU déjà résiliée
              P_regul:=1; --P_regul
            ELSIF (TRIM(P_AFFIL_PORTE.MOTIFA) IS NOT NULL AND TRIM(P_AFFIL_PORTE.DEBEFF) IS NOT NULL) THEN
              P_mvt := 4;
              PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,46,7,P_AFFIL_PORTE.DATRAIT);--Continuité d'' Adhésion RU déjà résiliée
              P_regul:=3; --P_regul
            END IF;
          END IF;
         -- END IF;
        EXCEPTION
          WHEN TOO_MANY_ROWS THEN
            -- Recherche de la dernière adhésion résiliée
            SELECT MAX(a.idadhesion)
              INTO P_AFFIL_PORTE.IDADHESION
              FROM ADHE_CNTRT a
             WHERE a.numgar=P_AFFIL_PORTE.NUMGAR
               AND a.numadhe=P_AFFIL_PORTE.NUMINDIV
               AND F_ETAT_ADHE(a.idadhesion, P_AFFIL_PORTE.DATRAIT)=3;
            IF --(
               NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.')),0) > 1500
            --OR NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),0) >1500)
            THEN
              IF (TRIM(P_AFFIL_PORTE.MOTIFA) IS NULL AND TRIM(P_AFFIL_PORTE.DEBEFF) IS NULL) THEN
                P_mvt:=0;
                P_regul:=2;
              ELSE
                IF (TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL AND TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL) THEN
                  P_mvt := 4;
                  PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,46,7,P_AFFIL_PORTE.DATRAIT);--Continuité d'' Adhésion RU déjà résiliée
                  P_regul:=1; --P_regul
                END IF;
              END IF;
            ELSE
              IF (TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL AND TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL) THEN
                P_mvt := 4;
                PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,46,7,P_AFFIL_PORTE.DATRAIT);--Continuité d'' Adhésion RU déjà résiliée
                P_regul:=1; --P_regul
              ELSIF (TRIM(P_AFFIL_PORTE.MOTIFA) IS NOT NULL AND TRIM(P_AFFIL_PORTE.DEBEFF) IS NOT NULL) THEN
                P_mvt := 4;
                PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,46,7,P_AFFIL_PORTE.DATRAIT);--Continuité d'' Adhésion RU déjà résiliée
                P_regul:=3; --P_regul
              END IF;
            END IF;
            loc_flag_resil:=1;
          WHEN NO_DATA_FOUND THEN
            loc_flag_resil:=-1;
        END;
    END;
  END IF;

  --gestion des salaires
  loc_salTA := NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.')),0);
  loc_salTB := NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),0);
/*
P_INS_journal(3,' P_GestionAdhesion P_mvt 2:'||to_char(P_mvt));
P_INS_journal(3,' P_GestionAdhesion NUMINDIV:'||to_char(P_AFFIL_PORTE.NUMINDIV));
P_INS_journal(3,' P_GestionAdhesion P_regul 2:'||to_char(P_regul));
P_INS_journal(3,' Avant P_AFFIL_PORTE.NUMGAR:'||to_char(P_AFFIL_PORTE.NUMGAR));
P_INS_journal(3,' Avant P_AFFIL_PORTE.IDADHESION:'||to_char(P_AFFIL_PORTE.IDADHESION));
P_INS_journal(3,' Avant P_AFFIL_PORTE.NUMINDIV:'||to_char(P_AFFIL_PORTE.NUMINDIV));
*/
    ---------------------------------------------------------------------------------
    -- ********************** Mouvement **********************************************
    ---------------------------------------------------------------------------------
  CASE P_mvt

    WHEN 0 THEN
    ---------------------------------------------------------------------------------
    -- ********************** AFFILIATION ET MUTATION********************************
    ---------------------------------------------------------------------------------

      -- Recherche d une adhesion portant sur un autre contrat
      BEGIN
        SELECT NVL(MAX(a.idadhesion),0), NVL(MAX(a.numgar),0)
          INTO loc_idadhesionMut, loc_numgarMut
          FROM ADHE_CNTRT a
         WHERE a.numgar<>P_AFFIL_PORTE.NUMGAR
           AND a.numadhe=P_AFFIL_PORTE.NUMINDIV
           AND F_ETAT_ADHE(a.idadhesion, P_AFFIL_PORTE.DATRAIT)=1
           AND a.date_fin_adhe IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE exc_mutation;
      END;
      IF P_regul=2 THEN
        IF loc_idadhesionMut>0 THEN
          P_AFFIL_PORTE.IDADHESION:=loc_idadhesionMut;
          PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,53,7,P_AFFIL_PORTE.DATRAIT);
        ELSE
          -- Résiliation déjà effectuée dans la période
          -- Mise à jour uniquement du motif dans affil_porte
          IF TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL AND TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL THEN
            IF P_AFFIL_PORTE.MOTIF IS NULL THEN -- en cas de déblocage
                BEGIN
                  SELECT l.code, l.sens
                    INTO P_AFFIL_PORTE.MOTIF, loc_sens
                    FROM LIBELLE l
                   WHERE TRIM(TRANSLATE(UPPER(P_AFFIL_PORTE.MOTIFS),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))=TRIM(TRANSLATE(UPPER(l.libelle),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))
                     AND l.MNEMO = 'HISTO_ADHE';
                EXCEPTION
                  WHEN OTHERS THEN
                    RAISE exc_motif_inconnu;
                END;
                -- Mise à jour du Motif dans AFFIL_PORTE
                PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                                     , P_ano);
            END IF;
            PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,54,7,P_AFFIL_PORTE.DATRAIT);
            P_regul:=4;
            RAISE exc_deja_resil;
          END IF;
        END IF;
      END IF;

      -- Si on traite une nouvelle affiliation avec un salaire à 0 on bloque
      IF NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.')),0)=0 THEN
        RAISE exc_affil_salTA;
      END IF;
    --nouvelle affiliation
  --  P_AFFILIATION(P_AFFIL_PORTE, P_dateff, loc_numgarMut,loc_adhe_cntrt,P_ano);
    WHEN 1 THEN

      ---------------------------------------------------------------------------------
      -- ********************** RADIATION -********************************************
      ---------------------------------------------------------------------------------
      -- Si une adhésion est trouvé, on gère l affiliation qui correspond à une résiliation
      --contrôle de cohérence des données
      IF TRIM(P_AFFIL_PORTE.DEBEFF) IS NOT NULL
        AND TRIM(P_AFFIL_PORTE.MOTIFA) IS NOT NULL
        AND TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL
        AND TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL THEN
          P_INS_journal(3,' Anomalie de donnée du fichier, tous les motifs et dates sont saisies');
          RAISE exc_motif_plein;
      ELSIF TRIM(P_AFFIL_PORTE.DEBEFF) IS NULL
        AND TRIM(P_AFFIL_PORTE.MOTIFA) IS NULL
        AND TRIM(P_AFFIL_PORTE.FINCON) IS NULL
        AND TRIM(P_AFFIL_PORTE.MOTIFS) IS NULL THEN
          P_INS_journal(3,' Anomalie de donnée du fichier, tous les motifs et dates sont vides pour une résiliation');
          RAISE exc_motif_vide;
      END IF;
      IF TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL AND TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL THEN
        IF P_AFFIL_PORTE.MOTIF IS NULL THEN -- en cas de déblocage
          BEGIN
            SELECT l.code, l.sens
              INTO P_AFFIL_PORTE.MOTIF, loc_sens
              FROM LIBELLE l
             WHERE TRIM(TRANSLATE(UPPER(P_AFFIL_PORTE.MOTIFS),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))=TRIM(TRANSLATE(UPPER(l.libelle),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))
               AND l.MNEMO = 'HISTO_ADHE';
          EXCEPTION
            WHEN OTHERS THEN
              RAISE exc_motif_inconnu;
          END;
        END IF;
      ELSE

        P_AFFIL_PORTE.MOTIF:=NULL;
        RAISE exc_motif_vide; --on sort car on ne peut résilier dans motif
      END IF;

      --************** Résiliation de l'adhésion **************--
      BEGIN
        /*
        P_INS_journal(3,' Avant p_resilie_adhe P_AFFIL_PORTE.MOTIF:'||to_char(P_AFFIL_PORTE.MOTIF));
        P_INS_journal(3,' Avant p_resilie_adhe P_AFFIL_PORTE.NUMGAR:'||to_char(P_AFFIL_PORTE.NUMGAR));
        P_INS_journal(3,' Avant p_resilie_adhe P_AFFIL_PORTE.IDADHESION:'||to_char(P_AFFIL_PORTE.IDADHESION));
        P_INS_journal(3,' Avant p_resilie_adhe P_AFFIL_PORTE.NUMINDIV:'||to_char(P_AFFIL_PORTE.NUMINDIV));
        P_INS_journal(3,' Avant p_resilie_adhe P_AFFIL_PORTE.FINCON:'||to_char(P_AFFIL_PORTE.FINCON));
        */
        PK_TRANSFERT.p_resilie_adhe( P_AFFIL_PORTE.NUMGAR
                                   , P_AFFIL_PORTE.IDADHESION
                                   , P_AFFIL_PORTE.NUMINDIV
                                   , P_AFFIL_PORTE.MOTIF
                                   , E2D(P_AFFIL_PORTE.FINCON)
                                   , P_AFFIL_PORTE.USERNAME_FORCAGE); -- MUR M0005418

        -- Mise à jour du Motif dans AFFIL_PORTE
        PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                             , P_ano);

        -- recherche de la clef idhistoadhe necessaire a l annulation de la résiliation
        SELECT MAX(a.idhistoadhe)
          INTO loc_idhistoadhe
          FROM HISTO_ADHESION a
         WHERE A.IDADHESION=P_AFFIL_PORTE.IDADHESION
           AND TRUNC(a.datsai)=TRUNC(P_AFFIL_PORTE.DATRAIT)
         ;

        IF P_ano > 0 THEN
          RAISE exc_resil;
        END IF;
        -- Gestion de l historisation des actions effectuées sur ma résiliation de l adhésion
        loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
        loc_AFFIL_TRACE.CLEF:=loc_idhistoadhe;
        loc_AFFIL_TRACE.ACTION:='I';--insertion
        loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
        loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
        loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
        loc_AFFIL_TRACE.OBJET:='HISTO_ADHESION';--Table impactée
        loc_AFFIL_TRACE.COLONNE:='IDHISTOADHE';--Colonne impactée
        IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          RAISE exc_resil;
        END IF;
        loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
        loc_AFFIL_TRACE.ACTION:='U';--Mise a jour Update
        loc_AFFIL_TRACE.OBJET:='ADHESION';--Table impactée
        loc_AFFIL_TRACE.COLONNE:='DATPER';--Colonne impactée
        IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          RAISE exc_resil;
        END IF;

        loc_AFFIL_TRACE.COLONNE:='MOTIF';--Colonne impactée
        IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          RAISE exc_resil;
        END IF;

        loc_AFFIL_TRACE.OBJET:='ADHE_CNTRT';--Table impactée
        loc_AFFIL_TRACE.COLONNE:='DATE_FIN_ADHE';--Colonne impactée
                IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          RAISE exc_resil;
        END IF;
      EXCEPTION
        WHEN exc_resil THEN
          P_ano:=-16;
        WHEN OTHERS THEN


          P_ano:=-17;

      END;

    WHEN 2 THEN
      ---------------------------------------------------------------------------------
      -- ********************** ABSENCE ***********************************************
      ---------------------------------------------------------------------------------
       IF TRIM(P_AFFIL_PORTE.DEBEFF) IS NOT NULL AND TRIM(P_AFFIL_PORTE.MOTIFA) IS NOT NULL THEN
         IF P_AFFIL_PORTE.MOTIF IS NULL THEN -- en cas de déblocage
           BEGIN
             SELECT l.code, l.sens
               INTO P_AFFIL_PORTE.MOTIF, loc_sens
               FROM LIBELLE l
              WHERE TRIM(TRANSLATE(UPPER(P_AFFIL_PORTE.MOTIFA),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))=TRIM(TRANSLATE(UPPER(l.libelle),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))
                AND l.MNEMO = 'HISTO_ADHE';
           EXCEPTION
             WHEN OTHERS THEN
               RAISE exc_motif_inconnu;
           END;
           -- Mise à jour du Motif dans AFFIL_PORTE
           PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                                , P_ano);
         END IF;

       ELSE
         P_AFFIL_PORTE.MOTIF:=NULL;
         RAISE exc_motif_vide; --on sort car on ne peut résilier sans motif
       END IF;
      /*
       -- une régularisation de salaire est communiquée post absence
       IF loc_salTA >0   OR loc_salTB >0 THEN
       --  IF TRIM(P_AFFIL_PORTE.DEBEFF)  THEN
       --  END IF;
         P_regul:=1;
         --absence avec une régularisation(état 3 bloqué) car non intégrable  à gérer en exception avec un message particulier
         PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,37,3,P_AFFIL_PORTE.DATRAIT);--17102013
        -- RAISE exc_resil; --17102013
       END IF;*/
       IF loc_sens = 4 THEN -- On résilie toutes les absences hormis les motifs INVALIDITE
           --************** Résiliation de l'adhésion **************--
         BEGIN
           PK_TRANSFERT.p_resilie_adhe( P_AFFIL_PORTE.NUMGAR
                                      , P_AFFIL_PORTE.IDADHESION
                                      , P_AFFIL_PORTE.NUMINDIV
                                      , P_AFFIL_PORTE.MOTIF
                                      , E2D(P_AFFIL_PORTE.DEBEFF)
                                      , P_AFFIL_PORTE.USERNAME_FORCAGE) ; -- MUR M0005418

           -- Mise à jour du Motif dans AFFIL_PORTE
           PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                                , P_ano);
           -- recherche de la clef idhistoadhe necessaire a l annulation de la résiliation
           SELECT MAX(a.idhistoadhe)
             INTO loc_idhistoadhe
             FROM HISTO_ADHESION a
            WHERE A.IDADHESION=P_AFFIL_PORTE.IDADHESION
              AND TRUNC(a.datsai)=TRUNC(P_AFFIL_PORTE.DATRAIT)
            ;
           IF P_ano > 0 THEN
              RAISE exc_resil;
           END IF;
           -- Gestion de l historisation des actions effectuées sur ma résiliation de l adhésion
           loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
           loc_AFFIL_TRACE.CLEF:=loc_idhistoadhe;
           loc_AFFIL_TRACE.ACTION:='I';--insertion
           loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
           loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
           loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
           loc_AFFIL_TRACE.OBJET:='HISTO_ADHESION';--Table impactée
           loc_AFFIL_TRACE.COLONNE:='IDHISTOADHE';--Colonne impactée
           IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
             P_ano:=0;
           ELSE
             RAISE exc_resil;
           END IF;
           loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
           loc_AFFIL_TRACE.ACTION:='U';--Mise a jour Update
           loc_AFFIL_TRACE.OBJET:='ADHESION';--Table impactée
           loc_AFFIL_TRACE.COLONNE:='DATPER';--Colonne impactée
           IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
             P_ano:=0;
           ELSE
             RAISE exc_resil;
           END IF;

           loc_AFFIL_TRACE.COLONNE:='MOTIF';--Colonne impactée
           IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
             P_ano:=0;
           ELSE
             RAISE exc_resil;
           END IF;

           loc_AFFIL_TRACE.OBJET:='ADHE_CNTRT';--Table impactée
           loc_AFFIL_TRACE.COLONNE:='DATE_FIN_ADHE';--Colonne impactée
           IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
             P_ano:=0;
           ELSE
             RAISE exc_resil;
           END IF;
         EXCEPTION
           WHEN exc_resil THEN
             P_ano:=-16;
           WHEN OTHERS THEN
             P_ano:=-17;
         END;
       ELSE
         BEGIN
           -- Pour le motif d invalidité, on insere la données compléméntaire MOT_ABS, afin d'avertir
           -- l'utilisateur que l'adhésion correspond a une adhésion issue d'une absence
           INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                             VALUES(134,0,P_AFFIL_PORTE.NUMINDIV,'O',E2D(P_AFFIL_PORTE.DEBEFF),E2D(P_AFFIL_PORTE.FINEFF),'O',SUBSTR(P_AFFIL_PORTE.MOTIFA,1,15),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);
           loc_AFFIL_TRACE.ETENDUE:=0;--Individu
           loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.NUMINDIV;
           loc_AFFIL_TRACE.CLEF2:=TO_CHAR(E2D(P_AFFIL_PORTE.DEBEFF),'DD/MM/YYYY');
           loc_AFFIL_TRACE.CLEF3:=NULL;
           loc_AFFIL_TRACE.CLEF4:=134;
           loc_AFFIL_TRACE.ACTION:='I';--insertion
           loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
           loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
           loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
           loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
           loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
           loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
           loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
           loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée

           IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
             P_ano:=0;
           ELSE
             RAISE exc_resil;
           END IF;
         EXCEPTION
           WHEN exc_resil THEN
             P_ano:=-16;
           WHEN OTHERS THEN
             P_ano:=-17;
         END;

       END IF;

    WHEN 3 THEN
      ---------------------------------------------------------------------------------
      -- ********************** CONTINUITÉ ********************************************
      ---------------------------------------------------------------------------------
      NULL;
    WHEN 4 THEN
      ---------------------------------------------------------------------------------
      -- ********************** RADIATION DEJA RESILIEE********************************
      ---------------------------------------------------------------------------------
      -- résiliation d'une adhésion déjà résiliée
      IF TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL AND TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL THEN
        IF P_AFFIL_PORTE.MOTIF IS NULL THEN -- en cas de déblocage
          BEGIN
            SELECT l.code, l.sens
              INTO P_AFFIL_PORTE.MOTIF, loc_sens
              FROM LIBELLE l
             WHERE TRIM(TRANSLATE(UPPER(P_AFFIL_PORTE.MOTIFS),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))=TRIM(TRANSLATE(UPPER(l.libelle),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))
               AND l.MNEMO = 'HISTO_ADHE';
          EXCEPTION
            WHEN OTHERS THEN
              RAISE exc_motif_inconnu;
          END;
        END IF;
      ELSIF TRIM(P_AFFIL_PORTE.DEBEFF) IS NOT NULL AND TRIM(P_AFFIL_PORTE.MOTIFA) IS NOT NULL THEN
        IF P_AFFIL_PORTE.MOTIF IS NULL THEN -- en cas de déblocage
          BEGIN
            SELECT l.code, l.sens
              INTO P_AFFIL_PORTE.MOTIF, loc_sens
              FROM LIBELLE l
             WHERE TRIM(TRANSLATE(UPPER(P_AFFIL_PORTE.MOTIFA),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))=TRIM(TRANSLATE(UPPER(l.libelle),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'))
               AND l.MNEMO = 'HISTO_ADHE';
          EXCEPTION
            WHEN OTHERS THEN
              RAISE exc_motif_inconnu;
          END;
           -- Mise à jour du Motif dans AFFIL_PORTE
           PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                                , P_ano);
        END IF;
        --P_AFFIL_PORTE.MOTIF:=F_get_transco('AFFIL','MOTIFS',P_AFFIL_PORTE.MOTIFS,2);
      ELSE
        P_AFFIL_PORTE.MOTIF:=NULL;
        RAISE exc_motif_vide; --on sort car on ne peut résilier dans motif
      END IF;
      -- Mise à jour du Motif dans AFFIL_PORTE
      PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE
                                           , P_ano);
      -- une régularisation de salaire est communiquée post résiliation
      IF loc_salTA >0   OR loc_salTB >0 THEN
        PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,37,3,P_AFFIL_PORTE.DATRAIT);
        P_regul:=1;
      ELSE
        IF loc_salTA >0   and loc_salTB >0 THEN
          P_ano:=1;
        END IF;
      END IF;

    ELSE NULL;
    END CASE;

EXCEPTION
  WHEN exc_mutation THEN
    P_ano:=-21;
  WHEN exc_motif_plein THEN
    P_ano:=-15;
  WHEN exc_motif_vide THEN
    P_ano:=-19;
  WHEN exc_motif_inconnu THEN
    P_ano:=-22;
  WHEN exc_deja_resil THEN
    P_ano:=23;
  WHEN exc_affil_salTA THEN
    P_ano:=-23;
  WHEN OTHERS THEN
  P_INS_journal(3,' Erreur : Gestion de l adhesion impossible:'||SUBSTR(SQLERRM,1,132));
  P_ano:=-14;
END P_GestionAdhesion;



/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_ADHE_CNTRT                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet ADHE_CNTRT          */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_ADHE_CNTRT( P_AFFIL_PORTE      IN   AFFIL_PORTE%ROWTYPE
                           , P_numgar           IN   AFFIL_PORTE_ADH.NUMGAR%TYPE
                           , P_dateff           IN   CONTRAT.DATEFF%TYPE
                           , P_ADHE_CNTRT       OUT  ADHE_CNTRT%ROWTYPE
                           , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  loc_refcie CONTRAT_REF.REFCIE%TYPE:=NULL;
BEGIN
  --querable conditionné en fonction du niveau d'appel de cotisation, ainsi contrat indiv, querable adhérent
  --eche_anniv RG ad01 glissant ou non
  SELECT DISTINCT c.REFCIE, c.FRACT,c.MREGL,decode(c.TYPEQUIT,2,P_AFFIL_PORTE.NUMINDIV, c.NUMQUERABLE),c.delai, decode(c.TYPE_ECHE,1,P_dateff,c.ECHE_ANNIV)
    INTO loc_refcie, P_ADHE_CNTRT.FRACT, P_ADHE_CNTRT.MREGL,  P_ADHE_CNTRT.NUMQUERABLE, P_ADHE_CNTRT.delai, P_ADHE_CNTRT.ECHE_ANNIV
    FROM CONTRAT_REF c
   WHERE c.NUMGAR=P_numgar;
  P_ano:=0;

  P_ADHE_CNTRT.IDADHESION:=pk_adhesion.f_idadhesion;-- Harmonisation des idadehsion BIA CLI 27/08/2018
  P_ADHE_CNTRT.REF_EXT:=SUBSTR(TO_CHAR(P_ADHE_CNTRT.IDADHESION)||' / '||loc_refcie,1,30);
  P_ADHE_CNTRT.NUMGAR:=P_numgar;
  P_ADHE_CNTRT.NUMADHE:=P_AFFIL_PORTE.NUMINDIV;
  P_ADHE_CNTRT.DATE_ADHE:=P_dateff;
  P_ADHE_CNTRT.DSOUS:=P_dateff;
  P_ADHE_CNTRT.MEME_GAR:='N';
  P_ADHE_CNTRT.NUMUTIL:=P_AFFIL_PORTE.USERNAME_FORCAGE;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de l adhesion impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_ADHE_CNTRT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_HISTO_ADHESION                                     */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet HISTO_ADHESION      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_HISTO_ADHESION( P_AFFIL_PORTE         IN      AFFIL_PORTE%ROWTYPE
                               , P_AFFIL_PORTE_ADH     IN      AFFIL_PORTE_ADH%ROWTYPE
                               , P_dateff              IN      CONTRAT.DATEFF%TYPE
                               , P_HISTO_ADHESION         OUT  HISTO_ADHESION%ROWTYPE
                               , P_ano                    OUT  AFFIL_ANO.NUMANO%TYPE)
IS
  loc_IDHISTOADHE HISTO_ADHESION.IDHISTOADHE%TYPE:=NULL;
BEGIN

  P_ano:=0;
  SELECT IDHISTOADHE.NEXTVAL INTO loc_IDHISTOADHE FROM DUAL;
  P_HISTO_ADHESION.IDHISTOADHE:=loc_IDHISTOADHE;
  P_HISTO_ADHESION.IDADHESION:=P_AFFIL_PORTE_ADH.IDADHESION;
  P_HISTO_ADHESION.DEBUT:=P_dateff;
  P_HISTO_ADHESION.DATSAI:= SYSDATE; -- P_AFFIL_PORTE.DATRAIT;
  P_HISTO_ADHESION.ETAT:=1;
  P_HISTO_ADHESION.MOTIF:=1;
  P_HISTO_ADHESION.NUMUTIL:=P_AFFIL_PORTE.USERNAME_FORCAGE;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de l histo adhesion impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_HISTO_ADHESION;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_ADHE_CNTRT_MEMBRE                                   */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion d un objet ADHE_CNTRT_MEMBRE        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_ADHE_CNTRT_MEMBRE( P_AFFIL_PORTE_ADH      IN      AFFIL_PORTE_ADH%ROWTYPE
                                 , P_ano                     OUT  AFFIL_ANO.NUMANO%TYPE)
IS
  loc_ADHE_CNTRT_MEMBRE     ADHE_CNTRT_MEMBRE%ROWTYPE:=NULL;
  loc_ADHESION              ADHESION%ROWTYPE;
  loc_AFFIL_TRACE           AFFIL_TRACE%ROWTYPE;
  exc_adhe_membre           EXCEPTION;
  exc_adhesion              EXCEPTION;
BEGIN


  /*
  P_INS_journal(3,' ADHE_CNTRT_MEMBRE NUMREMISE:'||P_AFFIL_PORTE_ADH.NUMREMISE);
  P_INS_journal(3,' ADHE_CNTRT_MEMBRE NUMPORTE:'||P_AFFIL_PORTE_ADH.NUMPORTE);
  P_INS_journal(3,' ADHE_CNTRT_MEMBRE NUMLIGNE:'||P_AFFIL_PORTE_ADH.NUMLIGNE);
  P_INS_journal(3,' ADHE_CNTRT_MEMBRE NUMADH:'||P_AFFIL_PORTE_ADH.NUMADH);
  P_INS_journal(3,' ADHE_CNTRT_MEMBRE IDADHESION:'||P_AFFIL_PORTE_ADH.IDADHESION);
  P_INS_journal(3,' ADHE_CNTRT_MEMBRE numindiv:'||P_AFFIL_PORTE_ADH.numindiv);
  */
  INSERT INTO ADHE_CNTRT_MEMBRE(IDADHECNTRTMB,IDADHESION, numindiv,typadr)
  SELECT IDADHECNTRTMB.nextval, adh.idadhesion,adh.numindiv, ayd.typead -- adh.typead  TODO : ==> affil_porte_numayd et non numadh
    FROM affil_porte_adh adh, affil_porte_ayd ayd
  WHERE adh.numremise =  P_AFFIL_PORTE_ADH.NUMREMISE
    AND adh.numporte =   P_AFFIL_PORTE_ADH.NUMPORTE
    AND adh.numligne =   P_AFFIL_PORTE_ADH.NUMLIGNE
    AND adh.numadh =     P_AFFIL_PORTE_ADH.NUMADH
    AND adh.numayd >0
    AND idadhesion = P_AFFIL_PORTE_ADH.IDADHESION
    AND adh.numremise = ayd.numremise
    AND adh.numporte = ayd.numporte
    AND adh.numligne = ayd.numligne
    AND adh.numayd = ayd.numayd
    AND NOT EXISTS(SELECT idadhesion
                     FROM adhe_cntrt_membre
                    WHERE idadhesion = P_AFFIL_PORTE_ADH.IDADHESION
                      AND numindiv =   adh.numindiv      );


EXCEPTION
  WHEN exc_adhe_membre THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Insertion de ADHE_CNTRT_MEMBRE impossible:'||SUBSTR(SQLERRM,1,132));
  WHEN exc_adhesion THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Insertion de ADHESION impossible:'||SUBSTR(SQLERRM,1,132));
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Insertion de ADHE_CNTRT_MEMBRE impossible:'||SUBSTR(SQLERRM,1,132));
END P_INS_ADHE_CNTRT_MEMBRE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_COUVERTURES                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion d un objet ADHESION                 */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_COUVERTURES( P_AFFIL_PORTE_ADH      IN      AFFIL_PORTE_ADH%ROWTYPE
                          ,  P_numutil               IN      UTILISATEURS.NUMUTIL%TYPE
                          ,  P_debut                IN      DATE
                          ,  P_fin                  IN      DATE
                           , P_ano                     OUT  AFFIL_ANO.NUMANO%TYPE)

IS
loc_test number :=0;
BEGIN

  INSERT INTO ADHESION( NUMINDIV,NUMGAR,NUMFOR,DATAPLI,DATPER,RANG,ETAT,UC,FLAG_REGIME,
                        REGIME,TYPFOR,NUMORG,DIS_CARENCE,DIS_FRANCHISE,IDADHESION,
                        NUMFOR_CARENCE,NUMUTIL,CREATION,MAJ,MOTIF,IDCOUVERTURE
                        )
  SELECT   adh.numindiv ,adh.NUMGAR,adh.REFGARANTIE,NVL(P_debut,sysdate),P_fin,NVL(adh.rang,1),1,NULL,'C',
         1,g.type,1,'O','O',adh.IDADHESION,
         NULL,P_numutil,SYSDATE, NULL, NULL, IDCOUVERTURE.NEXTVAL
   FROM affil_porte_adh adh, gar_cntrt g
  WHERE numremise =  P_AFFIL_PORTE_ADH.NUMREMISE
    AND numporte =   P_AFFIL_PORTE_ADH.NUMPORTE
    AND numligne =   P_AFFIL_PORTE_ADH.NUMLIGNE
    AND numadh =     P_AFFIL_PORTE_ADH.NUMADH
   -- AND numayd >0
    AND idadhesion = P_AFFIL_PORTE_ADH.IDADHESION
    AND g.numfor  = adh.refgarantie
    AND NOT EXISTS(SELECT idadhesion
                     FROM adhesion
                    WHERE NUMINDIV =   adh.NUMINDIV
                      and idadhesion = P_AFFIL_PORTE_ADH.IDADHESION
                      and numfor = P_AFFIL_PORTE_ADH.REFGARANTIE);



    --historisation des traces pour annulation
    INSERT INTO AFFIL_TRACE(ETENDUE,CLEF,ACTION, NUMREMISE, NUMLIGNE,NUMPORTE,OBJET,COLONNE)
    SELECT 13,ad.idcouverture,'I',P_AFFIL_PORTE_ADH.NUMREMISE,P_AFFIL_PORTE_ADH.NUMLIGNE, P_AFFIL_PORTE_ADH.NUMPORTE,
            'ADHESION','IDCOUVERTURE'
    FROM affil_porte_adh adh, adhesion ad
    WHERE adh.numremise =  P_AFFIL_PORTE_ADH.NUMREMISE
    AND adh.numporte =   P_AFFIL_PORTE_ADH.NUMPORTE
    AND adh.numligne =   P_AFFIL_PORTE_ADH.NUMLIGNE
    AND adh.numadh =     P_AFFIL_PORTE_ADH.NUMADH
    AND adh.idadhesion = P_AFFIL_PORTE_ADH.IDADHESION
    AND adh.idadhesion = ad.idadhesion
    AND adh.numindiv = ad.numindiv
    AND ad.numfor = adh.refgarantie
    AND ad.NUMUTIL = P_numutil
    AND ad.creation > sysdate-1;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=-12;
  P_INS_journal(3,' Erreur : Insertion de P_INS_COUVERTURES impossible:'||SUBSTR(SQLERRM,1,132));
END P_INS_COUVERTURES;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_ADHE_CNTRT_MEMBRE                                  */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet ADHE_CNTRT_MEMBRE   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_ADHE_CNTRT_MEMBRE( P_AFFIL_PORTE_ADH     IN      AFFIL_PORTE_ADH%ROWTYPE
                                  , P_ADHE_CNTRT_MEMBRE       OUT  ADHE_CNTRT_MEMBRE%ROWTYPE
                                  , P_ano                     OUT  AFFIL_ANO.NUMANO%TYPE)
IS
  loc_IDADHECNTRTMB ADHE_CNTRT_MEMBRE.IDADHECNTRTMB%TYPE:=NULL;
BEGIN

  P_ano:=0;
  SELECT IDADHECNTRTMB.NEXTVAL INTO loc_IDADHECNTRTMB FROM DUAL;
  P_ADHE_CNTRT_MEMBRE.IDADHECNTRTMB:=loc_IDADHECNTRTMB;
  P_ADHE_CNTRT_MEMBRE.IDADHESION:=P_AFFIL_PORTE_ADH.IDADHESION;
  P_ADHE_CNTRT_MEMBRE.NUMINDIV:=P_AFFIL_PORTE_ADH.NUMINDIV;
  P_ADHE_CNTRT_MEMBRE.TYPADR:=P_AFFIL_PORTE_ADH.NUMAYD;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de ADHE_CNTRT_MEMBRE impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_ADHE_CNTRT_MEMBRE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INIT_ADHESION                                           */
/* Type         :  Public                                                    */
/* Description  :  procedure d initialisation d un objet ADHESION            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INIT_ADHESION( P_AFFIL_PORTE     IN      AFFIL_PORTE%ROWTYPE
                         , P_dateff          IN      CONTRAT.DATEFF%TYPE
                      --   , P_NUMFOR          IN      ADHESION.NUMFOR%TYPE
                        ,  P_AFFIL_PORTE_ADH IN      AFFIL_PORTE_ADH%ROWTYPE
                         , P_ADHESION        IN OUT  ADHESION%ROWTYPE
                         , P_ano                OUT  AFFIL_ANO.NUMANO%TYPE)
IS
  loc_IDCOUVERTURE ADHESION.IDCOUVERTURE%TYPE:=NULL;
BEGIN

  P_ano:=0;
  SELECT IDCOUVERTURE.NEXTVAL INTO loc_IDCOUVERTURE FROM DUAL;
  P_ADHESION.IDCOUVERTURE:=loc_IDCOUVERTURE;
  P_ADHESION.IDADHESION:=P_AFFIL_PORTE_ADH.IDADHESION;
  P_ADHESION.NUMGAR:=P_AFFIL_PORTE_ADH.NUMGAR;
  IF P_AFFIL_PORTE_ADH.NUMAYD =  0 THEN
    P_ADHESION.NUMINDIV:=P_AFFIL_PORTE_ADH.NUMINDIV;
  END IF;
  P_ADHESION.NUMFOR:=P_AFFIL_PORTE_ADH.REFGARANTIE;
  P_ADHESION.DATAPLI:=P_dateff;
  P_ADHESION.DATPER:=e2d(P_AFFIL_PORTE.FINCON);--pour les affiliations résiliation
  P_ADHESION.RANG:=1;
  P_ADHESION.ETAT:=1;
  P_ADHESION.FLAG_REGIME:='C';
  P_ADHESION.TYPFOR:=2;
  P_ADHESION.NUMORG:=1;
  P_ADHESION.DIS_CARENCE:='O';
  P_ADHESION.DIS_FRANCHISE:='O';


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Initialisation de la couverture impossible:'||SUBSTR(SQLERRM,1,132));
END P_INIT_ADHESION;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_NUMINDIV                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour du numindiv dans AFFIL_PORTE     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_NUMINDIV( P_NUMINDIV      IN      AFFIL_PORTE.NUMINDIV%TYPE
                                    , P_NUMREMISE     IN      AFFIL_PORTE.NUMREMISE%TYPE
                                    , P_NUMPORTE      IN      AFFIL_PORTE.NUMPORTE%TYPE
                                    , P_NUMLIGNE      IN      AFFIL_PORTE.NUMLIGNE%TYPE
                                    , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  -- Mise à jour de AFFIL_PORTE.NUMINDIV
  UPDATE AFFIL_PORTE
     SET NUMINDIV=P_NUMINDIV
   WHERE NUMREMISE=P_NUMREMISE
     AND NUMPORTE=P_NUMPORTE
     AND NUMLIGNE=P_NUMLIGNE;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible de AFFIL_PORTE.NUMINDIV:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_NUMINDIV;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_FICHIER_NUMCLI                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l objet AFFIL_PORTE_ADH       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_FICHIER_NUMCLI( I_AFFIL_FICHIER      IN       AFFIL_FICHIER%ROWTYPE)
IS
BEGIN

  UPDATE AFFIL_FICHIER
     SET AFFIL_FICHIER.NUMCLI=I_AFFIL_FICHIER.NUMCLI
   WHERE AFFIL_FICHIER.NUMREMISE=I_AFFIL_FICHIER.NUMREMISE
   AND AFFIL_FICHIER.ENTREPRISE = I_AFFIL_FICHIER.ENTREPRISE
   AND AFFIL_FICHIER.ETABLI = I_AFFIL_FICHIER.ETABLI
   AND AFFIL_FICHIER.NUM_ORDRE = I_AFFIL_FICHIER.NUM_ORDRE
   AND AFFIL_FICHIER.NUMPORTE = I_AFFIL_FICHIER.NUMPORTE;

END P_MAJ_AFFIL_FICHIER_NUMCLI;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_CONTRAT                                 */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour du numindiv dans AFFIL_PORTE     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_NUMGAR(  P_NUMGAR        IN      AFFIL_PORTE.NUMGAR%TYPE
                                   , P_NUMCLI        IN      AFFIL_PORTE.NUMCLI%TYPE
                                   , P_NUMINDIV      IN      AFFIL_PORTE.NUMINDIV%TYPE
                                   , P_NUMREMISE     IN      AFFIL_PORTE.NUMREMISE%TYPE
                                   , P_NUMPORTE      IN      AFFIL_PORTE.NUMPORTE%TYPE
                                   , P_NUMLIGNE      IN      AFFIL_PORTE.NUMLIGNE%TYPE
                                   , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  -- Mise à jour de AFFIL_PORTE.NUMGAR
  UPDATE AFFIL_PORTE
     SET NUMGAR=P_NUMGAR
       , NUMCLI=P_NUMCLI
   WHERE NUMREMISE=P_NUMREMISE
     AND NUMPORTE=P_NUMPORTE
     AND NUMLIGNE=P_NUMLIGNE
     AND NUMINDIV=P_NUMINDIV;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible du NUMGAR:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_NUMGAR;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_IDADHESION                              */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de l adhesion dans AFFIL_PORTE   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_IDADHESION( P_IDADHESION    IN      AFFIL_PORTE.IDADHESION%TYPE
                                      , P_NUMINDIV      IN      AFFIL_PORTE.NUMINDIV%TYPE
                                      , P_NUMREMISE     IN      AFFIL_PORTE.NUMREMISE%TYPE
                                      , P_NUMPORTE      IN      AFFIL_PORTE.NUMPORTE%TYPE
                                      , P_NUMLIGNE      IN      AFFIL_PORTE.NUMLIGNE%TYPE
                                      , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS
  v_nbrows  NUMBER:=0;
BEGIN
  P_ano:=0;
  -- Mise à jour de AFFIL_PORTE.IDADHESION
  UPDATE AFFIL_PORTE
     SET IDADHESION=P_IDADHESION
   WHERE NUMREMISE=P_NUMREMISE
     AND NUMPORTE=P_NUMPORTE
     AND NUMLIGNE=P_NUMLIGNE
     AND NUMINDIV=P_NUMINDIV;

  v_nbrows := SQL%ROWCOUNT;
  IF v_nbrows=0 OR TRIM(P_IDADHESION) IS NULL THEN
    P_ano:=1;
  ELSE
    P_ano:=0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible de IDADHESION:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_IDADHESION;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_AFFIL                                   */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour des données dans AFFIL_PORTE     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_AFFIL( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                                 , P_NUMREMISE     IN      AFFIL_PORTE.NUMREMISE%TYPE
                                 , P_NUMPORTE      IN      AFFIL_PORTE.NUMPORTE%TYPE
                                 , P_NUMLIGNE      IN      AFFIL_PORTE.NUMLIGNE%TYPE
                                 , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  -- Mise à jour de AFFIL_PORTE
  UPDATE AFFIL_PORTE
     SET  NUMINDIV=P_AFFIL_PORTE.NUMINDIV
     --  , IDADHESION=P_AFFIL_PORTE.IDADHESION
     --  , NUMGAR=P_AFFIL_PORTE.NUMGAR
       , NUMCLI=P_AFFIL_PORTE.NUMCLI
       , MOTIF=P_AFFIL_PORTE.MOTIF
   WHERE NUMREMISE=P_NUMREMISE
     AND NUMPORTE=P_NUMPORTE
     AND NUMLIGNE=P_NUMLIGNE;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible de IDADHESION:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_AFFIL;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_AFFIL_PORTE_MOTIF                                   */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour du motif de résiliation dans     */
/*                 AFFIL_PORTE.                                              */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_AFFIL_PORTE_MOTIF( P_AFFIL_PORTE IN   AFFIL_PORTE%ROWTYPE
                                 , P_ano         OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  -- Mise à jour de AFFIL_PORTE.MOTIF
  UPDATE AFFIL_PORTE
     SET MOTIF=P_AFFIL_PORTE.MOTIF
   WHERE NUMREMISE=P_AFFIL_PORTE.NUMREMISE
     AND NUMPORTE=P_AFFIL_PORTE.NUMPORTE
     AND NUMLIGNE=P_AFFIL_PORTE.NUMLIGNE;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible de MOTIF de AFFIL_PORTE:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_AFFIL_PORTE_MOTIF;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_INDIVIDU_REFCIE                                     */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de la refcie dans INDIVIDU       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_INDIVIDU_REFCIE( P_NUMINDIV      IN      INDIVIDU.NUMINDIV%TYPE
                               , P_REFCIE        IN      INDIVIDU.REFCIE%TYPE
                               , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  -- Mise à jour de la référence externe de l individu
  UPDATE INDIVIDU
     SET REFCIE=P_REFCIE
   WHERE NUMINDIV=P_NUMINDIV;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible de la référence externe dans INDIVIDU:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_INDIVIDU_REFCIE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_INDIVIDU_MATORG                                     */
/* Type         :  Public                                                    */
/* Description  :  procedure de Mise à jour du numéro de sécu a blanc si il  */
/*                 se termine par 999 pour l individu trouvé                 */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_INDIVIDU_MATORG( P_NUMINDIV      IN      INDIVIDU.NUMINDIV%TYPE
                               , P_NUMSSA        IN      AFFIL_PORTE.NUMSSA%TYPE
                               , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  --Mise à jour du numéro de sécu a blanc si il se termine par 999 pour l individu trouvé
  UPDATE INDIVIDU
     SET MATORG=NULL, CLESS=NULL, N_INSEE=NULL
   WHERE NUMINDIV=P_NUMINDIV
     AND MATORG=P_NUMSSA;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible du numéro de sécu a blanc dans INDIVIDU:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_INDIVIDU_MATORG;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_INDIVIDU_LIEUNAIS                                   */
/* Type         :  Public                                                    */
/* Description  :  procedure de Mise à jour du lieu de naissance             */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_INDIVIDU_LIEUNAIS( P_NUMINDIV     IN      INDIVIDU.NUMINDIV%TYPE
                                 , P_LIEUNAIS     IN      INDIVIDU.LIEUNAIS%TYPE
                                 , P_ano              OUT AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  --Mise à jour du numéro de sécu a blanc si il se termine par 999 pour l individu trouvé
  UPDATE INDIVIDU
     SET LIEUNAIS=P_LIEUNAIS
   WHERE NUMINDIV=P_NUMINDIV;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible du lieu de naissance dans INDIVIDU:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_INDIVIDU_LIEUNAIS;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_INDIVIDU_NOMJF                                      */
/* Type         :  Public                                                    */
/* Description  :  procedure de Mise à jour du lieu de naissance             */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_INDIVIDU_NOMJF( P_NUMINDIV     IN      INDIVIDU.NUMINDIV%TYPE
                              , P_NOMJF        IN      INDIVIDU.NOMJF%TYPE
                              , P_ano              OUT AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  --Mise à jour du numéro de sécu a blanc si il se termine par 999 pour l individu trouvé
  UPDATE INDIVIDU
     SET NOMJF=P_NOMJF
   WHERE NUMINDIV=P_NUMINDIV;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible du nom de jeune fille dans INDIVIDU:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_INDIVIDU_NOMJF;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Gestion_Val_Variable                                    */
/* Type         :  Public                                                    */
/* Description  :  Gestion des données complémentaires de l affiliation      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_Gestion_Val_Variable( P_AFFIL_PORTE   IN      AFFIL_PORTE%ROWTYPE
                                , P_trimestre     IN      NUMBER
                                , P_annee         IN      NUMBER
                                , P_regul         IN      NUMBER
                                , P_AFFIL_ANO     IN OUT  AFFIL_ANO%ROWTYPE
                                , P_anoSalaireA      OUT  AFFIL_ANO.NUMANO%TYPE
                                , P_anoSalaireB      OUT  AFFIL_ANO.NUMANO%TYPE
                                , P_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  loc_val_SALATA        AFFIL_PORTE.SALATA%TYPE:=NULL;
  loc_val_SALATB        AFFIL_PORTE.SALATB%TYPE:=NULL;
  loc_val_NBENFA        AFFIL_PORTE.NBENFA%TYPE:=NULL;
  loc_val_MATRIC        AFFIL_PORTE.MATRIC%TYPE:=NULL;
  loc_val_ETABLI        AFFIL_PORTE.ETABLI%TYPE:=NULL;
  loc_datedSAL          DATE;
  loc_dateTrait         DATE;
  loc_datefSALRes       DATE;
  loc_datedSAL2         DATE;
  loc_annee             VARCHAR2(4):=NULL;
  loc_AFFIL_TRACE       AFFIL_TRACE%ROWTYPE;
  flag_resil            NUMBER:=0;
  flag_regul            NUMBER:=0;
  v_nbrows              NUMBER:=0;
  i_regul               NUMBER:=0;
  flag                  NUMBER:=NULL;
  flag_regulOK          NUMBER:=0;

  integ_sala            EXCEPTION;
  integ_salb            EXCEPTION;
  integ_nb_enf          EXCEPTION;
  integ_etabli          EXCEPTION;

BEGIN


/*---------------------------------------------------------------------------*/
/* Règle de gestion de l intégration des salaires TA et TB                   */
/* Tables impactées : VAL_VARIABLE, CLEF=IDADHESION, IDVARIABLE=45 TA, 46 TB */
/* 1) Vérification que la période à traiter n'existe pas sinon erreur        */
/* 2) Vérification qu'il existe une période pour le trimestre antérieur      */
/* 3) Si c'est une affiliation et que la période n'existe pas alors création */
/* 4) Si c'est une résiliation qui a lieu dans le cours du trimestre que l on*/
/* traite, alors on insére une période avec une datefin=date résiliation     */
/* 5) Si c'est une résiliation qui a eu lieu le trimestre précédent avec des */
/* salaires supérieur à 0, alors il s'agit d'un régularisation               */
/*---------------------------------------------------------------------------*/



--P_INS_journal(3,' P_AFFIL_PORTE.NUMLIGNE 1:'||to_char(P_AFFIL_PORTE.NUMLIGNE));

  P_anoSalaireA:=0;
  P_anoSalaireB:=0;
  flag_resil:=0;
  v_nbrows:=0;

/*
P_INS_journal(3,' P_AFFIL_PORTE.NUMLIGNE P_annee:'||to_char(P_annee));
P_INS_journal(3,' P_AFFIL_PORTE.NUMLIGNE loc_annee:'||loc_annee);
P_INS_journal(3,' P_AFFIL_PORTE.NUMLIGNE P_trimestre:'||to_char(P_trimestre));
*/
  -- On détermine la date de début de trimestre à partir du trimestre du fichier saisi
  loc_annee:=TO_CHAR(P_annee);
  IF P_trimestre=1 THEN
    loc_datedSAL:=TO_DATE('01/01/'||loc_annee,'DD/MM/YYYY');
  ELSIF P_trimestre=2 THEN
    loc_datedSAL:=TO_DATE('01/04/'||loc_annee,'DD/MM/YYYY');
  ELSIF P_trimestre=3 THEN
    loc_datedSAL:=TO_DATE('01/07/'||loc_annee,'DD/MM/YYYY');
  ELSIF P_trimestre=4 THEN
    loc_datedSAL:=TO_DATE('01/10/'||loc_annee,'DD/MM/YYYY');
  END IF;
  loc_dateTrait:=loc_datedSAL;
--P_INS_journal(3,' P_AFFIL_PORTE.NUMLIGNE 2:'||to_char(P_AFFIL_PORTE.NUMLIGNE));
  ------------------------------------------------------------------------------
  -- Récupération des dates d affectation du salaires en cas d une résiliation
  ------------------------------------------------------------------------------
  IF P_AFFIL_PORTE.MOTIF IS NOT NULL THEN
    BEGIN
     /* SELECT a.date_fin_adhe
        INTO loc_datefSALRes
        FROM ADHE_CNTRT a
       WHERE a.IDADHESION=P_AFFIL_PORTE.IDADHESION
         AND a.NUMGAR=P_AFFIL_PORTE.NUMGAR;*/

      IF ( loc_datedSAL >= NVL(E2D(TRIM(P_AFFIL_PORTE.DEBEFF)),loc_datedSAL)
       AND loc_datedSAL >= NVL(E2D(TRIM(P_AFFIL_PORTE.FINCON)),loc_datedSAL) ) THEN
       IF TRIM(P_AFFIL_PORTE.FINCON) IS NOT NULL THEN
         loc_datedSAL:=TRUNC(e2d(TRIM(P_AFFIL_PORTE.FINCON)),'Q');
         loc_datefSALRes:=e2d(TRIM(P_AFFIL_PORTE.FINCON));
       ELSE
         loc_datefSALRes:=ADD_MONTHS(TRUNC(loc_datedSAL,'q'),+3)-1;
       END IF;
      ELSE
        IF TRIM(P_AFFIL_PORTE.DEBEFF) IS NOT NULL AND TRIM(P_AFFIL_PORTE.MOTIFA) IS NOT NULL THEN
          loc_datefSALRes:=E2D(TRIM(P_AFFIL_PORTE.DEBEFF));
        ELSE
          loc_datefSALRes:=E2D(TRIM(P_AFFIL_PORTE.FINCON));
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        loc_datefSALRes:=ADD_MONTHS(TRUNC(loc_datedSAL,'q'),+3)-1;
    END;
  END IF;

  IF loc_datefSALRes IS NOT NULL THEN
    loc_datedSAL:=TRUNC(loc_datefSALRes,'q');
    flag_resil:=1;
  ELSE
    loc_datefSALRes:=ADD_MONTHS(TRUNC(loc_datedSAL,'q'),+3)-1;
  END IF;


  ------------------------------------------------------------------------------
  -- Gestion du salaire tranche A : Donnée utilisateur TA
  ------------------------------------------------------------------------------
  IF NVL(TO_DATE(P_AFFIL_PORTE.DEBUTC,'DD/MM/YYYY'),SYSDATE) > loc_datedSAL THEN
    loc_datedSAL:=NVL(TO_DATE(P_AFFIL_PORTE.DEBUTC,'DD/MM/YYYY'),loc_datedSAL);
  END IF;
  BEGIN

/*
P_INS_journal(3,' numligne:'||to_char(P_AFFIL_PORTE.numligne));
P_INS_journal(3,' adhesion:'||to_char(P_AFFIL_PORTE.IDADHESION));
P_INS_journal(3,' numindiv:'||to_char(P_AFFIL_PORTE.NUMINDIV));
P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
P_INS_journal(3,' loc_val_SALATA:'||to_char(loc_val_SALATA));
P_INS_journal(3,' P_AFFIL_PORTE.SALATA:'||P_AFFIL_PORTE.SALATA);
P_INS_journal(3,' P_regul:'||to_char(P_regul));
P_INS_journal(3,' flag_regul:'||to_char(flag_regul));
P_INS_journal(3,' flag_resil:'||to_char(flag_resil));
*/
    loc_val_SALATA:=PK_CTRL_AFFIL.F_FIND_VALEUR_VALVAR(45,13,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.IDADHESION,loc_datedSAL,loc_datedSAL2);

--P_INS_journal(3,' loc_val_SALATA 2:'||to_char(loc_val_SALATA));

    IF P_regul in(1,3) AND flag_resil=1 THEN -- Si c est une régularisation post résiliation
      IF loc_val_SALATA=-1 OR NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.')),0)=0 THEN -- Un salaire doit etre trouvé pour la période antèrieur (trimestre en cours - 1 ) sinon on bloque
        flag_regul:=1;
      END IF;
    END IF;

--P_INS_journal(3,' flag_regul2:'||to_char(flag_regul));

    IF (loc_val_SALATA > 0 AND flag_resil=0)/* OR(loc_val_SALATA = 0 AND flag_resil=1)*/ THEN
      /*
      P_INS_journal(3,' RAISE 1:');
      P_INS_journal(3,' numligne:'||to_char(P_AFFIL_PORTE.numligne));
      P_INS_journal(3,' adhesion:'||to_char(P_AFFIL_PORTE.IDADHESION));
      P_INS_journal(3,' numindiv:'||to_char(P_AFFIL_PORTE.NUMINDIV));
      P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
      P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
       P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
      */
      RAISE integ_sala;
    END IF;

    IF flag_resil=0 THEN
      loc_val_SALATA:=PK_CTRL_AFFIL.F_FIND_VALEUR_VALVAR(45,13,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.IDADHESION,loc_datedSAL-1,loc_datedSAL2);
      IF P_regul in(1,3) THEN -- Si c est une régularisation post résiliation
        IF loc_val_SALATA=-1 OR NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.')),0)=0 THEN -- Un salaire doit etre trouvé pour la période antèrieur (trimestre en cours - 1 ) sinon on bloque
          flag_regul:=1;
        END IF;
      END IF;
    END IF;
--P_INS_journal(3,' flag_regul3:'||to_char(flag_regul));
    IF flag_regul<>1 THEN -- pas de regul sur un salaire à 0

      IF loc_val_SALATA<>P_AFFIL_PORTE.SALATA THEN

        -- avertissement si salaire = 0
        IF NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.')),0)=0 THEN
          P_anoSalaireA:=30;
          PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,30,7,P_AFFIL_PORTE.DATRAIT);
        --  P_INS_journal(3,' INSERT 1 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
          INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                            VALUES(45,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_CHAR(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.'))),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);
          loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
          loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
          loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
          loc_AFFIL_TRACE.CLEF3:=NULL;
          loc_AFFIL_TRACE.CLEF4:=45;
          loc_AFFIL_TRACE.CLEF5:=NULL;
          loc_AFFIL_TRACE.ACTION:='I';--insertion
          loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
          loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
          loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
          loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
          loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
          loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
          IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
            P_ano:=0;
          ELSE
            P_ano:=39;
          END IF;
         -- IF (/*P_AFFIL_PORTE.MOTIFA IS NOT NULL OR*/ P_AFFIL_PORTE.MOTIFS IS NULL) THEN -- continuité d affiliation
/*
            v_nbrows:=0;
            UPDATE VAL_VARIABLE v SET v.FIN=loc_datefSALRes
             WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
               AND v.IDVARIABLE=45
               AND v.ETENDUE=13
               AND v.clef=P_AFFIL_PORTE.IDADHESION;
            v_nbrows := SQL%ROWCOUNT;
            IF v_nbrows=0 THEN
              P_INS_journal(3,' RAISE integ_sala;');
              RAISE integ_sala;
            ELSE
              -- Insertion dans AFFIL_TRACE
              loc_AFFIL_TRACE.ETENDUE:=13;
              loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
              loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
              loc_AFFIL_TRACE.CLEF3:=loc_val_SALATA;
              loc_AFFIL_TRACE.CLEF4:=45;
              loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
              loc_AFFIL_TRACE.ACTION:='U';--mise a jour
              loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
              loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
              loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
              loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
              loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
              IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                P_ano:=0;
              ELSE
                P_ano:=39;
              END IF;
            END IF;*/
          --END IF;
        ELSE

          -- Création du nouveau salaire si il était inexistant
          IF (loc_val_SALATA = -1 OR loc_val_SALATA<>P_AFFIL_PORTE.SALATA) AND loc_dateTrait <= loc_datedSAL THEN

          --  P_INS_journal(3,' INSERT 2 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
        --  IF loc_val_SALATA<>P_AFFIL_PORTE.SALATA THEN
          --  P_INS_journal(3,' INSERT INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
            INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                              VALUES(45,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_CHAR(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.'))),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);
            loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
            loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
            loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
            loc_AFFIL_TRACE.CLEF3:=NULL;
            loc_AFFIL_TRACE.CLEF4:=45;
            loc_AFFIL_TRACE.CLEF5:=NULL;
            loc_AFFIL_TRACE.ACTION:='I';--insertion
            loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
            loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
            loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
            loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
            loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
            loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
            IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
              P_ano:=0;
            ELSE
              P_ano:=39;
            END IF;
          ELSE
            v_nbrows:=0;
            -- Mise à jour du salaire
            IF flag_resil=1 THEN
              IF P_regul=1 THEN --JBO
                IF TRIM(P_AFFIL_PORTE.MOTIFA) IS NOT NULL THEN
                  IF E2D(TRIM(P_AFFIL_PORTE.DEBEFF)) > TRUNC(loc_datedSAL-1) THEN
                    flag:=1; -- insert d'une période
                  ELSE
                    flag:=0; -- regul de la période antérieur
                  END IF;
                END IF;
                IF TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL THEN
                  IF E2D(TRIM(P_AFFIL_PORTE.FINCON)) > TRUNC(loc_datedSAL-1) THEN
                    flag:=1; -- insert d'une période
                  ELSE
                    flag:=0; -- regul de la période antérieur
                  END IF;
                END IF;
                /*
                P_INS_journal(3,' JBO 1 flag:'||to_char(flag));
                P_INS_journal(3,' JBO 1 P_AFFIL_PORTE.MOTIFA:'||P_AFFIL_PORTE.MOTIFA);
                P_INS_journal(3,' JBO 1 P_AFFIL_PORTE.MOTIFS:'||P_AFFIL_PORTE.MOTIFS);
                P_INS_journal(3,' JBO 1 loc_datedSAL:'||to_char(loc_datedSAL,'dd/mm/yyyy'));
                P_INS_journal(3,' JBO 1 loc_datefSALRes:'||to_char(loc_datefSALRes,'dd/mm/yyyy'));*/
               /* IF flag = 1 THEN
                  INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                                    VALUES(45,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_CHAR(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.'))),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT);
                  loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
                  loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
                  loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
                  loc_AFFIL_TRACE.CLEF3:=NULL;
                  loc_AFFIL_TRACE.CLEF4:=45;
                  loc_AFFIL_TRACE.CLEF5:=NULL;
                  loc_AFFIL_TRACE.ACTION:='I';--insertion
                  loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
                  loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
                  loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
                  loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
                  loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
                  flag_regulOK:=1;
                  IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                    P_ano:=0;
                  ELSE
                    P_ano:=39;
                  END IF;
                ELSE*/
                --  P_INS_journal(3,' UPDATE 1 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
                  UPDATE VAL_VARIABLE v SET v.VALEUR =v.VALEUR + TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.'))
                   --WHERE TRUNC(v.DEBUT)=TRUNC(loc_datedSAL)
                   WHERE TRUNC(v.FIN)=TRUNC(loc_datefSALRes)
                     AND v.IDVARIABLE=45
                     AND v.ETENDUE=13
                     AND v.clef=P_AFFIL_PORTE.IDADHESION;
                  v_nbrows := SQL%ROWCOUNT;
                  -- Insertion dans AFFIL_TRACE
                  loc_AFFIL_TRACE.ETENDUE:=13;
                  loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
                  loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
                  loc_AFFIL_TRACE.CLEF3:=loc_val_SALATA;
                  loc_AFFIL_TRACE.CLEF4:=45;
                  loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datefSALRes,'DD/MM/YYYY');
                  loc_AFFIL_TRACE.ACTION:='U';--mise a jour
                  loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
                  loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
                  loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
                  loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
                  loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
                  IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                    P_ano:=0;
                  ELSE
                    P_ano:=39;
                  END IF;
                  IF v_nbrows=0 THEN
                    /*
                    P_INS_journal(3,' RAISE 3:');
                    P_INS_journal(3,' numligne:'||to_char(P_AFFIL_PORTE.numligne));
                    P_INS_journal(3,' adhesion:'||to_char(P_AFFIL_PORTE.IDADHESION));
                    P_INS_journal(3,' numindiv:'||to_char(P_AFFIL_PORTE.NUMINDIV));
                    P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
                    P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
                    P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
                    */
                    RAISE integ_sala;
                  END IF;
                --END IF;
              ELSE

            --  P_INS_journal(3,' JBO 3 P_regul:'||to_char(P_regul));
            --    P_INS_journal(3,' INSERT INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
              --  P_INS_journal(3,' INSERT 3 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
                INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                                  VALUES(45,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_CHAR(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.'))),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);
                loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
                loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
                loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
                loc_AFFIL_TRACE.CLEF3:=NULL;
                loc_AFFIL_TRACE.CLEF4:=45;
                loc_AFFIL_TRACE.CLEF5:=NULL;
                loc_AFFIL_TRACE.ACTION:='I';--insertion
                loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
                loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
                loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
                loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
                loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
                loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
                loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
                loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
                IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                  P_ano:=0;
                ELSE
                  P_ano:=39;
                END IF;
              END IF;
            ELSE
            --  P_INS_journal(3,' UPDATE 2 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
              v_nbrows:=0;
              UPDATE VAL_VARIABLE v SET v.VALEUR = TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.'))
                                      , v.FIN=loc_datefSALRes
               WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
                 AND v.IDVARIABLE=45
                 AND v.ETENDUE=13
                 AND v.clef=P_AFFIL_PORTE.IDADHESION;
              v_nbrows := SQL%ROWCOUNT;
              -- Insertion dans AFFIL_TRACE
              loc_AFFIL_TRACE.ETENDUE:=13;
              loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
              loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
              loc_AFFIL_TRACE.CLEF3:=loc_val_SALATA;
              loc_AFFIL_TRACE.CLEF4:=45;
              loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
              loc_AFFIL_TRACE.ACTION:='U';--mise a jour
              loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
              loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
              loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
              loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
              loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
              IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                P_ano:=0;
              ELSE
                P_ano:=39;
              END IF;
              IF v_nbrows=0 THEN
                /*
                P_INS_journal(3,' RAISE 3:');
                P_INS_journal(3,' numligne:'||to_char(P_AFFIL_PORTE.numligne));
                P_INS_journal(3,' adhesion:'||to_char(P_AFFIL_PORTE.IDADHESION));
                P_INS_journal(3,' numindiv:'||to_char(P_AFFIL_PORTE.NUMINDIV));
                P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
                P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
                P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
                */
                RAISE integ_sala;
            END IF;
            END IF;

          END IF;
        END IF;
      ELSE
        IF NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.')),0)=0 THEN
          P_anoSalaireA:=30;
          PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,30,7,P_AFFIL_PORTE.DATRAIT);
        END IF;



     --   P_INS_journal(3,' INSERT 3 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
        INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                          VALUES(45,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_CHAR(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATA,' ',''),',','.'))),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);
        loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
        loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
        loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
        loc_AFFIL_TRACE.CLEF3:=NULL;
        loc_AFFIL_TRACE.CLEF4:=45;
        loc_AFFIL_TRACE.CLEF5:=NULL;
        loc_AFFIL_TRACE.ACTION:='I';--insertion
        loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
        loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
        loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
        loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
        loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
        loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
        IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          P_ano:=39;
        END IF;



/*
        v_nbrows:=0;
        P_INS_journal(3,' UPDATE 3 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
        UPDATE VAL_VARIABLE v SET v.FIN=loc_datefSALRes
         WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)--(SELECT MAX (TRUNC(v1.FIN)) FROM VAL_VARIABLE v1 WHERE v1.clef=v.clef AND v1.IDVARIABLE=45 AND v1.ETENDUE=13)
           AND v.IDVARIABLE=45
           AND v.ETENDUE=13
           AND v.clef=P_AFFIL_PORTE.IDADHESION;
        v_nbrows := SQL%ROWCOUNT;
        -- Insertion dans AFFIL_TRACE
        loc_AFFIL_TRACE.ETENDUE:=13;
        loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
        loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
        loc_AFFIL_TRACE.CLEF3:=loc_val_SALATA;
        loc_AFFIL_TRACE.CLEF4:=45;
        loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
        loc_AFFIL_TRACE.ACTION:='U';--mise a jour
        loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
        loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
        loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
        loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
        loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
        IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          P_ano:=39;
        END IF;
        IF v_nbrows=0 THEN
          P_INS_journal(3,' RAISE 2:');
          P_INS_journal(3,' numligne:'||to_char(P_AFFIL_PORTE.numligne));
          P_INS_journal(3,' adhesion:'||to_char(P_AFFIL_PORTE.IDADHESION));
          P_INS_journal(3,' numindiv:'||to_char(P_AFFIL_PORTE.NUMINDIV));
          P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
          P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
          P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
          RAISE integ_sala;
        END IF;*/
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      /*
      P_INS_journal(3,' RAISE 4:');
      P_INS_journal(3,' numligne:'||to_char(P_AFFIL_PORTE.numligne));
      P_INS_journal(3,' adhesion:'||to_char(P_AFFIL_PORTE.IDADHESION));
      P_INS_journal(3,' numindiv:'||to_char(P_AFFIL_PORTE.NUMINDIV));
      P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
      P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
      P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
      */
      RAISE integ_sala;
  END;

  ------------------------------------------------------------------------------
  -- Gestion du salaire tranche B : Donnée utilisateur TB
  ------------------------------------------------------------------------------
  BEGIN
    flag_regul:=0;

    loc_val_SALATB:=PK_CTRL_AFFIL.F_FIND_VALEUR_VALVAR(46,13,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.IDADHESION,loc_datedSAL,loc_datedSAL2);
 -- P_INS_journal(3,' TB loc_val_SALATB:'||loc_val_SALATB);
    IF P_regul in(1,3) and flag_resil=1 THEN -- Si c est une régularisation post résiliation
      IF loc_val_SALATB=-1 OR NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),0)=0 THEN -- Un salaire doit etre trouvé pour la période antèrieur (trimestre en cours - 1 ) sinon on bloque
        IF flag_regulOK = 1 THEN
          flag_regul:=0;
        ELSE
          flag_regul:=1;
        END IF;
      END IF;
    END IF;

  --P_INS_journal(3,' TB apres 1  F_FIND_VALEUR_VALVAR loc_val_SALATB:'||loc_val_SALATB);
   IF (loc_val_SALATB > 0 AND flag_resil=0) THEN
   -- IF loc_val_SALATB > 0 THEN
      RAISE integ_salb;
    END IF;

    IF flag_resil=0 THEN
      loc_val_SALATB:=PK_CTRL_AFFIL.F_FIND_VALEUR_VALVAR(46,13,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.IDADHESION,loc_datedSAL-1,loc_datedSAL2);

 -- P_INS_journal(3,' TB loc_val_SALATB2:'||loc_val_SALATB);

    --P_INS_journal(3,' TB apres 2 F_FIND_VALEUR_VALVAR loc_val_SALATB:'||loc_val_SALATB);
      IF P_regul in(1,3) and flag_resil=0 THEN -- Si c est une régularisation post résiliation
        IF loc_val_SALATB=-1 OR NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),0)=0 THEN -- Un salaire doit etre trouvé pour la période antèrieur (trimestre en cours - 1 ) sinon on bloque
          IF flag_regulOK = 1 THEN
            flag_regul:=0;
          ELSE
            flag_regul:=1;
          END IF;
        END IF;
      END IF;
    END IF;
/*
  P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
  P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
  P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
  P_INS_journal(3,' TB  P_AFFIL_PORTE.SALATB:'||P_AFFIL_PORTE.SALATB);
  P_INS_journal(3,' TB  loc_val_SALATB:'||loc_val_SALATB);
  P_INS_journal(3,' TB flag_regulOK:'||flag_regulOK);
  P_INS_journal(3,' TB P_regul:'||P_regul);
  P_INS_journal(3,' TB flag_regul:'||flag_regul);
  P_INS_journal(3,' TB flag_resil:'||flag_resil);
*/

    IF flag_regul<>1 THEN

      IF loc_val_SALATB<>P_AFFIL_PORTE.SALATB AND loc_dateTrait <= loc_datedSAL  THEN
        -- Création du nouveau salaire si il était inexistant
        --IF loc_val_SALATB = -1  THEN
        IF loc_val_SALATB<>P_AFFIL_PORTE.SALATB AND loc_dateTrait <= loc_datedSAL THEN



          IF flag_resil = 0 THEN
           -- P_INS_journal(3,' TB INSERT 1 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
            INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                              VALUES(46,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);


            loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
            loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
            loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
            loc_AFFIL_TRACE.CLEF3:=NULL;
            loc_AFFIL_TRACE.CLEF4:=46;
            loc_AFFIL_TRACE.CLEF5:=NULL;
            loc_AFFIL_TRACE.ACTION:='I';--insertion
            loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
            loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
            loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
            loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
            loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
            loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
            IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
              P_ano:=0;
            ELSE
              P_ano:=39;
            END IF;
          ELSE
            --IF TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')) <> 0 THEN
              IF P_regul=1 THEN --JBO
                IF TRIM(P_AFFIL_PORTE.MOTIFA) IS NOT NULL THEN
              --    P_INS_journal(3,' TB JBO 1 P_AFFIL_PORTE.DEBEFF:'||P_AFFIL_PORTE.DEBEFF);
                  IF E2D(TRIM(P_AFFIL_PORTE.DEBEFF)) > TRUNC(loc_datedSAL-1) THEN
                    flag:=1; -- insert d'une période
                  ELSE
                    flag:=0; -- regul de la période antérieur
                  END IF;
                END IF;
                IF TRIM(P_AFFIL_PORTE.MOTIFS) IS NOT NULL THEN
               --   P_INS_journal(3,' TB JBO 1 P_AFFIL_PORTE.FINCON:'||P_AFFIL_PORTE.FINCON);
                  IF E2D(TRIM(P_AFFIL_PORTE.FINCON)) > TRUNC(loc_datedSAL-1) THEN
                    flag:=1; -- insert d'une période
                  ELSE
                    flag:=0; -- regul de la période antérieur
                  END IF;
                END IF;
/*
                P_INS_journal(3,'TB JBO 1 flag:'||to_char(flag));
                P_INS_journal(3,'TB JBO 1 P_AFFIL_PORTE.MOTIFA:'||P_AFFIL_PORTE.MOTIFA);
                P_INS_journal(3,'TB JBO 1 P_AFFIL_PORTE.MOTIFS:'||P_AFFIL_PORTE.MOTIFS);
                P_INS_journal(3,'TB JBO 1 loc_datedSAL:'||to_char(loc_datedSAL,'dd/mm/yyyy'));
                P_INS_journal(3,'TB JBO 1 loc_datefSALRes:'||to_char(loc_datefSALRes,'dd/mm/yyyy'));
*/
                IF flag=1 THEN
                --  P_INS_journal(3,' TB INSERT 2 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
                  INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                                    VALUES(46,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);


                  loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
                  loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
                  loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
                  loc_AFFIL_TRACE.CLEF3:=NULL;
                  loc_AFFIL_TRACE.CLEF4:=46;
                  loc_AFFIL_TRACE.CLEF5:=NULL;
                  loc_AFFIL_TRACE.ACTION:='I';--insertion
                  loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
                  loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
                  loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
                  loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
                  loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
                  IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                    P_ano:=0;
                  ELSE
                    P_ano:=39;
                  END IF;

                ELSE
                --  P_INS_journal(3,' TB UPDATE 1 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
                  UPDATE VAL_VARIABLE v SET v.VALEUR =v.VALEUR + TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),v.FIN= loc_datedSAL-1 --loc_datefSALRes
                   --WHERE TRUNC(v.DEBUT)=TRUNC(loc_datedSAL)
                   WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
                     AND v.IDVARIABLE=46
                     AND v.ETENDUE=13
                     AND v.clef=P_AFFIL_PORTE.IDADHESION;
                  v_nbrows := SQL%ROWCOUNT;
                  IF v_nbrows=0 THEN
                    P_INS_journal(3,' TB apres mise a jour RAISE integ_salb:'||flag_resil);
                    RAISE integ_salb;
                  END IF;

                  -- Insertion dans AFFIL_TRACE
                  loc_AFFIL_TRACE.ETENDUE:=13;
                  loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
                  loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
                  loc_AFFIL_TRACE.CLEF3:=loc_val_SALATB;
                  loc_AFFIL_TRACE.CLEF4:=46;
                  loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
                  loc_AFFIL_TRACE.ACTION:='U';--mise a jour
                  loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
                  loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
                  loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
                  loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
                  loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
                  loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
                  IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                    P_ano:=0;
                  ELSE
                    P_ano:=39;
                  END IF;

                END IF;

              ELSE
              --  P_INS_journal(3,' TB INSERT 3 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
                INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                                  VALUES(46,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);


                loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
                loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
                loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
                loc_AFFIL_TRACE.CLEF3:=NULL;
                loc_AFFIL_TRACE.CLEF4:=46;
                loc_AFFIL_TRACE.CLEF5:=NULL;
                loc_AFFIL_TRACE.ACTION:='I';--insertion
                loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
                loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
                loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
                loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
                loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
                loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
                loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
                loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
                IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                  P_ano:=0;
                ELSE
                  P_ano:=39;
                END IF;
              END IF;
          /*  ELSE

              UPDATE VAL_VARIABLE v SET v.FIN=loc_datefSALRes
               --WHERE TRUNC(v.DEBUT)=TRUNC(loc_datedSAL)
               WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
                 AND v.IDVARIABLE=46
                 AND v.ETENDUE=13
                 AND v.clef=P_AFFIL_PORTE.IDADHESION;
              v_nbrows := SQL%ROWCOUNT;
              IF v_nbrows=0 THEN
                P_INS_journal(3,' TB apres mise a jour RAISE integ_salb:'||flag_resil);
                RAISE integ_salb;
              END IF;

              -- Insertion dans AFFIL_TRACE
              loc_AFFIL_TRACE.ETENDUE:=13;
              loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
              loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
              loc_AFFIL_TRACE.CLEF3:=loc_val_SALATB;
              loc_AFFIL_TRACE.CLEF4:=46;
              loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
              loc_AFFIL_TRACE.ACTION:='U';--mise a jour
              loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
              loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
              loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
              loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
              loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
              loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
              IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
                P_ano:=0;
              ELSE
                P_ano:=39;
              END IF;

            END IF;*/
          END IF;
        ELSE
        /*  IF NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),0)=0 THEN
            RAISE integ_salb;
          END IF;*/
          v_nbrows:=0;
          -- Mise à jour du salaire
/*
  P_INS_journal(3,' TB UPDATE 2  P_regul:'||P_regul);
  P_INS_journal(3,' TB UPDATE 2  F_FIND_VALEUR_VALVAR loc_val_SALATB:'||loc_val_SALATB);
  P_INS_journal(3,' TB UPDATE 2  flag_resil:'||flag_resil);*/
          IF flag_resil=1 THEN
            IF NVL(TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),0)<>0 THEN -- régularisation de salaire
           --   P_INS_journal(3,' TB UPDATE 2 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
              UPDATE VAL_VARIABLE v SET v.VALEUR =v.VALEUR + TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.'))
               --WHERE TRUNC(v.DEBUT)=TRUNC(loc_datedSAL)
               WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
                 AND v.IDVARIABLE=46
                 AND v.ETENDUE=13
                 AND v.clef=P_AFFIL_PORTE.IDADHESION;
              v_nbrows := SQL%ROWCOUNT;
            END IF;

          ELSE
            v_nbrows:=0;
          --  P_INS_journal(3,' TB UPDATE 3 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
            UPDATE VAL_VARIABLE v SET v.VALEUR = TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.'))
                                    , v.FIN=loc_datefSALRes
             WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
               AND v.IDVARIABLE=46
               AND v.ETENDUE=13
               AND v.clef=P_AFFIL_PORTE.IDADHESION;
            v_nbrows := SQL%ROWCOUNT;
          END IF;
          IF v_nbrows=0 THEN
            RAISE integ_salb;
          END IF;

          -- Insertion dans AFFIL_TRACE
          loc_AFFIL_TRACE.ETENDUE:=13;
          loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
          loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
          loc_AFFIL_TRACE.CLEF3:=loc_val_SALATB;
          loc_AFFIL_TRACE.CLEF4:=46;
          loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
          loc_AFFIL_TRACE.ACTION:='U';--mise a jour
          loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
          loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
          loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
          loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
          loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
          IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
            P_ano:=0;
          ELSE
            P_ano:=39;
          END IF;
        END IF;
      ELSE

 -- P_INS_journal(3,' TB UPDATE 3   F_FIND_VALEUR_VALVAR loc_val_SALATB:'||loc_val_SALATB);

      --  IF (/*P_AFFIL_PORTE.MOTIFA IS NOT NULL OR*/ P_AFFIL_PORTE.MOTIFS IS NULL) THEN -- continuité d affiliation
         IF P_Regul=0 THEN
          --  P_INS_journal(3,' TB INSERT 4 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATB));
           INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                            VALUES(46,13,P_AFFIL_PORTE.IDADHESION,'O',loc_datedSAL,loc_datefSALRes,'O',TO_NUMBER(REPLACE(REPLACE(P_AFFIL_PORTE.SALATB,' ',''),',','.')),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);


          loc_AFFIL_TRACE.ETENDUE:=13;--Adhesion
          loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
          loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
          loc_AFFIL_TRACE.CLEF3:=NULL;
          loc_AFFIL_TRACE.CLEF4:=46;
          loc_AFFIL_TRACE.CLEF5:=NULL;
          loc_AFFIL_TRACE.ACTION:='I';--insertion
          loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
          loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
          loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
          loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
          loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
          loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
          loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
          IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
            P_ano:=0;
          ELSE
            P_ano:=39;
          END IF;

/*
            v_nbrows:=0;
            P_INS_journal(3,' TB UPDATE 4 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATB));
            UPDATE VAL_VARIABLE v SET v.FIN=loc_datefSALRes
             WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
               AND v.IDVARIABLE=46
               AND v.ETENDUE=13
               AND v.clef=P_AFFIL_PORTE.IDADHESION;
            v_nbrows := SQL%ROWCOUNT;
            IF v_nbrows=0 THEN
              RAISE integ_salb;
            END IF;
            -- Insertion dans AFFIL_TRACE
            loc_AFFIL_TRACE.ETENDUE:=13;
            loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
            loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
            loc_AFFIL_TRACE.CLEF3:=loc_val_SALATB;
            loc_AFFIL_TRACE.CLEF4:=46;
            loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
            loc_AFFIL_TRACE.ACTION:='U';--mise a jour
            loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
            loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
            loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
            loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
            loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
            IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
              P_ano:=0;
            ELSE
              P_ano:=39;
            END IF;*/
         ELSE
          --  P_INS_journal(3,' TB UPDATE 5 INTO VAL_VARIABL:'||to_char(P_AFFIL_PORTE.SALATA));
            v_nbrows:=0;
            UPDATE VAL_VARIABLE v SET v.FIN=loc_datedSAL-1
             WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
               AND v.IDVARIABLE=46
               AND v.ETENDUE=13
               AND v.clef=P_AFFIL_PORTE.IDADHESION;
            v_nbrows := SQL%ROWCOUNT;
            IF v_nbrows=0 THEN
              RAISE integ_salb;
            END IF;
            -- Insertion dans AFFIL_TRACE
            loc_AFFIL_TRACE.ETENDUE:=13;
            loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.IDADHESION;
            loc_AFFIL_TRACE.CLEF2:=NVL(TO_CHAR(loc_datedSAL2,'DD/MM/YYYY'),TO_CHAR(ADD_MONTHS(TRUNC(loc_datedSAL,'q'),-3),'DD/MM/YYYY'));
            loc_AFFIL_TRACE.CLEF3:=loc_val_SALATB;
            loc_AFFIL_TRACE.CLEF4:=46;
            loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
            loc_AFFIL_TRACE.ACTION:='U';--mise a jour
            loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
            loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
            loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
            loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
            loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
            loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
            IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
              P_ano:=0;
            ELSE
              P_ano:=39;
            END IF;
         END IF;

        --END IF;
      END IF;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      RAISE integ_salb;
  END;

  ------------------------------------------------------------------------------
  -- Gestion des régularisations de salaire
  ------------------------------------------------------------------------------


  ------------------------------------------------------------------------------
  -- Gestion du nombre d enfant pour un participant : Donnée utilisateur NB_ENF_PAR
  ------------------------------------------------------------------------------
  BEGIN
/*
P_INS_journal(3,' P_AFFIL_PORTE.NBENFA:'||P_AFFIL_PORTE.NBENFA);
P_INS_journal(3,' numligne:'||to_char(P_AFFIL_PORTE.numligne));
P_INS_journal(3,' adhesion:'||to_char(P_AFFIL_PORTE.IDADHESION));
P_INS_journal(3,' numindiv:'||to_char(P_AFFIL_PORTE.NUMINDIV));
P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
*/
    loc_val_NBENFA:=PK_CTRL_AFFIL.F_FIND_VALEUR_VALVAR(81,0,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.NUMINDIV,loc_datedSAL,loc_datedSAL2);
--P_INS_journal(3,' apres 1 F_FIND_VALEUR_VALVAR:'||to_char(loc_val_NBENFA));
    IF (loc_val_NBENFA > 0 AND flag_resil=0) THEN
      RAISE integ_nb_enf;
    END IF;
    loc_val_NBENFA:=PK_CTRL_AFFIL.F_FIND_VALEUR_VALVAR(81,0,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.NUMINDIV,loc_datedSAL-1,loc_datedSAL2);
--P_INS_journal(3,' apres 2 F_FIND_VALEUR_VALVAR:'||to_char(loc_val_NBENFA));
    IF loc_val_NBENFA<>P_AFFIL_PORTE.NBENFA THEN

      -- Vérification que le dernier nombre d enfant saisie ne provient pas d une saisie manuel via l application
      IF ( F_FIND_USERCREA_VALVAR(81,0,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.NUMINDIV) IN(P_AFFIL_PORTE.USERNAME_FORCAGE,9)
        OR F_FIND_USERCREA_VALVAR(81,0,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.NUMINDIV) = 0) THEN

        INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                          VALUES(81,0,P_AFFIL_PORTE.NUMINDIV,'O',loc_datedSAL,loc_datefSALRes,'O',P_AFFIL_PORTE.NBENFA,NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);

        loc_AFFIL_TRACE.ETENDUE:=0;--Individu
        loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.NUMINDIV;
        loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
        loc_AFFIL_TRACE.CLEF3:=P_AFFIL_PORTE.NBENFA;
        loc_AFFIL_TRACE.CLEF4:=81;
        loc_AFFIL_TRACE.CLEF5:=NULL;
        loc_AFFIL_TRACE.ACTION:='I';--insertion
        loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
        loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
        loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
        loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
        loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
        loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE5:=NULL;--Colonne impactée
        IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
          P_ano:=0;
        ELSE
          P_ano:=39;
        END IF;
      END IF;
      --P_INS_journal(3,' Insert ok:'||to_char(loc_val_ETABLI));
    ELSE
      v_nbrows:=0;
       UPDATE VAL_VARIABLE v SET v.FIN=loc_datefSALRes
        WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
          AND v.IDVARIABLE=81
          AND v.ETENDUE=0
          AND v.clef=P_AFFIL_PORTE.NUMINDIV;
      v_nbrows := SQL%ROWCOUNT;
      IF v_nbrows=0 THEN
        RAISE integ_nb_enf;
      END IF;
      -- Insertion dans AFFIL_TRACE
      loc_AFFIL_TRACE.ETENDUE:=0;
      loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.NUMINDIV;
      loc_AFFIL_TRACE.CLEF2:=NULL;
      loc_AFFIL_TRACE.CLEF3:=P_AFFIL_PORTE.NBENFA;
      loc_AFFIL_TRACE.CLEF4:=81;
      loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
      loc_AFFIL_TRACE.ACTION:='U';--mise a jour
      loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
      loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
      loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        P_ano:=39;
      END IF;

--P_INS_journal(3,' UPDATE ok:'||to_char(loc_val_NBENFA));
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(3,' integ_nb_enf:'||to_char(P_AFFIL_PORTE.NUMINDIV));
      P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
      P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
      RAISE integ_nb_enf;
  END;

  ------------------------------------------------------------------------------
  -- Gestion de l etablissement du participant : Donnée utilisateur ETABLI_PAR
  ------------------------------------------------------------------------------
  BEGIN
  /*
P_INS_journal(3,' P_AFFIL_PORTE.ETABLI:'||SUBSTR(P_AFFIL_PORTE.ETABLI,0,15));
P_INS_journal(3,' numligne:'||to_char(P_AFFIL_PORTE.numligne));
P_INS_journal(3,' adhesion:'||to_char(P_AFFIL_PORTE.IDADHESION));
P_INS_journal(3,' numindiv:'||to_char(P_AFFIL_PORTE.NUMINDIV));
P_INS_journal(3,' loc_datefSALRes:'||to_char(loc_datefSALRes));
P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));*/
    loc_val_ETABLI:=PK_CTRL_AFFIL.F_FIND_VALEUR_VALVAR(131,0,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.NUMINDIV,loc_datedSAL,loc_datedSAL2);

    IF (loc_val_ETABLI > 0 AND flag_resil=0) THEN
      RAISE integ_etabli;
    END IF;
    loc_val_ETABLI:=PK_CTRL_AFFIL.F_FIND_VALEUR_VALVAR(131,0,P_AFFIL_PORTE.NUMGAR,P_AFFIL_PORTE.NUMINDIV,loc_datedSAL-1,loc_datedSAL2);

    IF TO_CHAR(loc_val_ETABLI)<>P_AFFIL_PORTE.ETABLI THEN
      INSERT INTO VAL_VARIABLE(IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR,USERCREA,DATECREA,USERMAJ,DATEMAJ)
                        VALUES(131,0,P_AFFIL_PORTE.NUMINDIV,'O',loc_datedSAL,loc_datefSALRes,'O',SUBSTR(P_AFFIL_PORTE.ETABLI,0,15),NULL,P_AFFIL_PORTE.USERNAME_FORCAGE,P_AFFIL_PORTE.DATRAIT,P_AFFIL_PORTE.USERNAME_FORCAGE,/*P_AFFIL_PORTE.DATRAIT*/NULL);
      loc_AFFIL_TRACE.ETENDUE:=0;--Individu
      loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.NUMINDIV;
      loc_AFFIL_TRACE.CLEF2:=TO_CHAR(loc_datedSAL,'DD/MM/YYYY');
      loc_AFFIL_TRACE.CLEF3:=SUBSTR(P_AFFIL_PORTE.ETABLI,0,15);
      loc_AFFIL_TRACE.CLEF4:=131;
      loc_AFFIL_TRACE.CLEF5:=NULL;
      loc_AFFIL_TRACE.ACTION:='I';--insertion
      loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
      loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
      loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE3:=NULL;--Colonne impactée
      loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
        loc_AFFIL_TRACE.COLONNE5:=NULL;--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        P_ano:=39;
      END IF;
    ELSE
      v_nbrows:=0;
      UPDATE VAL_VARIABLE v SET v.FIN=loc_datefSALRes
       WHERE TRUNC(v.FIN)=TRUNC(loc_datedSAL-1)
         AND v.IDVARIABLE=131
         AND v.ETENDUE=0
         AND v.clef=P_AFFIL_PORTE.NUMINDIV;
      v_nbrows := SQL%ROWCOUNT;

      IF v_nbrows=0 THEN
        P_INS_journal(3,' RAISE integ_etabli:'||to_char(P_AFFIL_PORTE.NUMINDIV));
        RAISE integ_etabli;
      END IF;
      -- Insertion dans AFFIL_TRACE
      loc_AFFIL_TRACE.ETENDUE:=0;
      loc_AFFIL_TRACE.CLEF:=P_AFFIL_PORTE.NUMINDIV;
      loc_AFFIL_TRACE.CLEF2:=NULL;
      loc_AFFIL_TRACE.CLEF3:=SUBSTR(P_AFFIL_PORTE.ETABLI,0,15);
      loc_AFFIL_TRACE.CLEF4:=131;
      loc_AFFIL_TRACE.CLEF5:=TO_CHAR(loc_datedSAL-1,'DD/MM/YYYY');
      loc_AFFIL_TRACE.ACTION:='U';--mise a jour
      loc_AFFIL_TRACE.NUMREMISE:=P_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
      loc_AFFIL_TRACE.NUMLIGNE:=P_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
      loc_AFFIL_TRACE.NUMPORTE:=P_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_TRACE.OBJET:='VAL_VARIABLE';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='CLEF';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE2:='DEBUT';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE3:='VALEUR';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE4:='IDVARIABLE';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE5:='FIN';--Colonne impactée
      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN
        P_ano:=0;
      ELSE
        P_ano:=39;
      END IF;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(3,' WHEN OTHERS THEN etabli:'||to_char(P_AFFIL_PORTE.NUMINDIV));
      P_INS_journal(3,' loc_datedSAL:'||to_char(loc_datedSAL));
      P_INS_journal(3,' loc_datedSAL2:'||to_char(loc_datedSAL2));
      RAISE integ_etabli;
  END;

EXCEPTION
  WHEN integ_sala THEN
    P_ano:=1;
  WHEN integ_salb THEN
    P_ano:=2;
  WHEN integ_nb_enf THEN
    P_ano:=0;
  WHEN integ_etabli THEN
    P_ano:=0;
  WHEN OTHERS THEN
    P_INS_journal(3,' Erreur : Gestion des données complémentaires impossible:'||SUBSTR(SQLERRM,1,132));
    PK_CTRL_AFFIL.P_AFFIL_ANO(P_AFFIL_PORTE,9,3,P_AFFIL_PORTE.DATRAIT);
END P_Gestion_Val_Variable;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FIND_VALEUR_VALVAR                                      */
/* Type         :  Public                                                    */
/* Description  :  fonction de recherche de la valeur de VAL_VARIABLE        */
/* Retour       :  loc_valeur, valeur de la donnée utilisateur               */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_VALEUR_VALVAR( P_IDVARIABLE     IN    VAL_VARIABLE.IDVARIABLE%TYPE
                             , P_ETENDUE        IN    VAL_VARIABLE.ETENDUE%TYPE
                             , P_NUMGAR         IN    VAL_VARIABLE.NUMGAR%TYPE
                             , P_CLEF           IN    VAL_VARIABLE.CLEF%TYPE
                             , P_DEBUT          IN    VAL_VARIABLE.DEBUT%TYPE
                             , o_DEBUT         OUT    VAL_VARIABLE.DEBUT%TYPE)
RETURN VAL_VARIABLE.VALEUR%TYPE
IS
  loc_valeur VAL_VARIABLE.VALEUR%TYPE:=NULL;
BEGIN

  SELECT DISTINCT v.VALEUR, v.DEBUT
    INTO loc_valeur, o_DEBUT
    FROM VAL_VARIABLE v
   WHERE v.IDVARIABLE=P_IDVARIABLE
     AND v.ETENDUE=P_ETENDUE
     --AND TRUNC(v.DEBUT) = TRUNC(P_DEBUT)
     AND TRUNC(P_DEBUT) BETWEEN TRUNC(v.DEBUT) AND NVL(TRUNC(v.FIN),v.DEBUT)
     AND v.clef=P_CLEF
    /* AND V.DEBUT = (SELECT MAX(v1.DEBUT)
                      FROM VAL_VARIABLE v1
                     WHERE v1.IDVARIABLE=v.IDVARIABLE
                       AND v1.ETENDUE=v.ETENDUE
                      -- AND v1.NUMGAR=v.NUMGAR
                       AND v1.clef=v.clef
                    )*/
     ;

  RETURN loc_valeur;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    o_DEBUT:=NULL;
    RETURN -1;
  WHEN OTHERS THEN
    o_DEBUT:=NULL;
    RETURN NULL ;
END F_FIND_VALEUR_VALVAR;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FIND_USERCREA_VALVAR                                    */
/* Type         :  Public                                                    */
/* Description  :  fonction de recherche du dernier usercrea de VAL_VARIABLE */
/* Retour       :  loc_numutil, user de création ou maj                      */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_USERCREA_VALVAR( P_IDVARIABLE     IN    VAL_VARIABLE.IDVARIABLE%TYPE
                               , P_ETENDUE        IN    VAL_VARIABLE.ETENDUE%TYPE
                               , P_NUMGAR         IN    VAL_VARIABLE.NUMGAR%TYPE
                               , P_CLEF           IN    VAL_VARIABLE.CLEF%TYPE)
RETURN VAL_VARIABLE.USERCREA%TYPE
IS
  loc_numutil VAL_VARIABLE.USERCREA%TYPE:=NULL;
BEGIN

  SELECT NVL(USERMAJ,USERCREA)
    INTO loc_numutil
    FROM VAL_VARIABLE v
   WHERE v.IDVARIABLE=P_IDVARIABLE
     AND v.ETENDUE=P_ETENDUE
    -- AND v.NUMGAR=P_NUMGAR
     AND v.clef=P_CLEF
     AND V.DEBUT = (SELECT MAX(v1.DEBUT)
                      FROM VAL_VARIABLE v1
                     WHERE v1.IDVARIABLE=v.IDVARIABLE
                       AND v1.ETENDUE=v.ETENDUE
                      -- AND v1.NUMGAR=v.NUMGAR
                       AND v1.clef=v.clef
                    )
     ;

  RETURN loc_numutil;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    RETURN NULL ;
END F_FIND_USERCREA_VALVAR;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_VERIF_ANNUL_COTISATION                                  */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire Annulation des cotisations de l import du */
/*                 fichier des affiliations dans ARTHUS                      */
/* Entree       :  P_numremise, numremise                                    */
/* Retour       :  o_erreur, Message d erreur                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_VERIF_ANNUL_COTISATION ( I_AFFIL_PORTE       IN       AFFIL_PORTE%ROWTYPE
                                   , I_Idadhesion        IN       AFFIL_PORTE_ADH.IDADHESION%TYPE
                                   , o_cotis                OUT   NUMBER)
IS
  --parcourt des cotisations individuelles uniquement
  --pour annulation d'un fichier complet en contexte, seul le cas de nouvelle affiliation
  --ayant entrainé une adhésion optionnelle cotisante indiv est concerné
  --on recherche donc dans adhe_cntrt pour un contrôle en masse nouvement 1 et 7 ou unitaire : non radiée
  CURSOR C_AFFIL_PORTE (P_AFFIL_PORTE   AFFIL_PORTE%ROWTYPE, P_Idadhesion adhesion.idadhesion%TYPE) IS
  SELECT DISTINCT adh.IDADHESION, adh. numadhe, decode(P_AFFIL_PORTE.fincon,NULL,NULL, e2d(P_AFFIL_PORTE.fincon)) date_resil
    FROM adhe_cntrt adh, contrat c
   WHERE adh.numadhe = P_AFFIL_PORTE.numindiv
     AND adh.numgar = c.numgar
     AND (adh.date_fin_adhe IS NULL OR P_AFFIL_PORTE.type_mvt IN (1,7))
     AND adh.IDADHESION=NVL(P_Idadhesion,adh.IDADHESION)
     AND c.typequit<>1;--l'échéancier n'est pas au niveau contrat (on peut avoir de l'option au niveau contrat mais pas concernée car considérée comme collective)


  CURSOR C_COTIS_COMPTANT (P_DateResil DATE, P_idadhesion adhesion.idadhesion %TYPE) IS
  SELECT  qg.numquit ,qg.mt_affec_d, qg.comptant, e.datemis,p.numprelev
  FROM QTTC_GLOBAL qg
    left outer join emission e ON (e.numfact=qg.numquit AND e.codope = 4 AND e.numrelance=0)
    left outer join prelevement_detail p ON (p.numfact = qg.numquit AND p.codope = 4 )
   WHERE qg.idadhesion=P_idadhesion
     AND P_DateResil < TRUNC(qg.fin)
     AND qg.comptant <>'R'
     AND NOT EXISTS (SELECT 1 FROM facture_annul where facture_annul.numfact =  qg.numquit AND codope =4) --non déjà annulée
     AND qg.type_qttc <> 3; --non prévsionnelle

  exc_affec              EXCEPTION;
  exc_emis               EXCEPTION;
  exc_prelev             EXCEPTION;

  flag1                  NUMBER:=0;
  flag2                  NUMBER:=0;

BEGIN

  -- Parcours de l'ensemble des adhesions concernées par une radiation ou une annulation de fichier
  -- uniquement des échéanciers sur adhésions individuelles
  FOR Rec_C_AFFIL_PORTE IN C_AFFIL_PORTE (I_AFFIL_PORTE,I_Idadhesion)LOOP

    flag1:=Rec_C_AFFIL_PORTE.numadhe;
    flag2:=Rec_C_AFFIL_PORTE.IDADHESION;
    P_INS_journal(3,'Annulation de cotisation, Assuré: '||Rec_C_AFFIL_PORTE.numadhe ||' adhesion : '||Rec_C_AFFIL_PORTE.IDADHESION );

    FOR R_COTIS_COMPTANT IN C_COTIS_COMPTANT (Rec_C_AFFIL_PORTE.date_resil ,Rec_C_AFFIL_PORTE.Idadhesion) LOOP
      --si la cotisation est prélevée, on vérifie qu'elle n'est pas prise dans un bordereau
      IF R_COTIS_COMPTANT.numprelev IS NOT NULL THEN
        RAISE exc_prelev;

      --si au moins une cotisation est affectée, on n'annule aucun fichier ou adhésion
      ELSIF NVL(R_COTIS_COMPTANT.mt_affec_d,0) >0 THEN
        RAISE exc_affec;

      --si au moins une cotisatoin est émise  , on n'annule aucun fichier ou adhésion
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
    P_INS_journal(1,' Erreur: Annulation cotisation:'||SUBSTR(SQLERRM,1,132));

END P_VERIF_ANNUL_COTISATION;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNUL_COT_PREV                                          */
/* Type         :  Public                                                    */
/* Description  :  Annulation des cotisations prévisionnelles lors d'une     */
/* radiation   - processus issu de qg01                                      */
/* Entree       :  P_numremise, numremise                                    */
/* Retour       :  o_erreur, Message d erreur                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_COT_PREV ( I_AFFIL_PORTE AFFIL_PORTE%ROWTYPE
                           , I_Idadhesion        IN     AFFIL_PORTE_ADH.IDADHESION%TYPE
                           , I_DateResil         IN     DATE
                           , I_ctrtResil         IN     NUMBER
                           , o_warning           OUT   NUMBER) IS
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

  exc_affec              EXCEPTION;
  exc_emis               EXCEPTION;
  exc_prelev             EXCEPTION;
  exc_annul              EXCEPTION;
BEGIN

    o_warning:=0;
   -- Dbms_Output.Put_Line(I_Idadhesion);
    --recherche des cotisations à annuler
    FOR R_COTIS_ANN IN C_COTIS_ANN(I_DateResil,I_Idadhesion) LOOP
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
      ELSIF  R_COTIS_ANN.debut < I_DateResil THEN --on annule pas la cotisation
        o_warning:=4;
      END IF;

      IF o_warning in(1,2,3,4) THEN
        IF I_ctrtResil =1 THEN
            EXIT;
        ELSIF o_warning in(1,3,4)THEN
          CONTINUE;
        END IF;
      END IF;
      --si au moins une cotisation est régularisée, mais non émise => on peut l'annuler
      loc_AFFIL_TRACE.ETENDUE:=13;
      loc_AFFIL_TRACE.CLEF:=R_COTIS_ANN.numquit;
      loc_AFFIL_TRACE.CLEF2:=to_char(sysdate,'dd/mm/yyyy');
      loc_AFFIL_TRACE.ACTION:='I';
      loc_AFFIL_TRACE.NUMREMISE:=I_AFFIL_PORTE.NUMREMISE;
      loc_AFFIL_TRACE.NUMLIGNE:=I_AFFIL_PORTE.NUMLIGNE;
      loc_AFFIL_TRACE.NUMPORTE:=I_AFFIL_PORTE.NUMPORTE;
      loc_AFFIL_TRACE.OBJET:='EMISSION';--Table impactée
      loc_AFFIL_TRACE.COLONNE:='NUMFACT';--Colonne impactée
      loc_AFFIL_TRACE.COLONNE2:='DATEMIS';--Colonne impactée

      IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE) THEN

        INSERT INTO emission (codope, numfact, numrelance, datemis, type_doc)
        SELECT 4,R_COTIS_ANN.numquit, 99, sysdate, 1 FROM dual
        WHERE NOT EXISTS (
        SELECT 1 FROM emission
        WHERE codope = 4
         AND numfact = R_COTIS_ANN.numquit
         AND numrelance = 99
         AND type_doc = 1);
        --insertion dans facture_annul s'effectue sur trigger

        --pas de maj d'echesuiv car uniquement annulation de prévisionnelle
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          o_warning:=5;
          RAISE exc_annul;
      END;
    END LOOP;

   commit;
   EXCEPTION
    WHEN exc_annul THEN ROLLBACK;--uniqument sur cette procédure
END P_ANNUL_COT_PREV;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNULATION_AFFILIATION                                  */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire Annulation de l import du fichier des     */
/*                 affiliations dans ARTHUS                                  */
/* Entree       :  remise et porte                                           */
/* Retour       :  o_erreur, Message d erreur                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNULATION_AFFILIATION (  P_numremise   IN       AFFIL_PORTE.NUMREMISE%TYPE
                                    , P_entreprise  IN       AFFIL_PORTE.ENTREPRISE%TYPE DEFAULT NULL
                                    , P_etabli      IN       AFFIL_PORTE.ETABLI%TYPE DEFAULT NULL
                                    , P_num_ordre   IN       AFFIL_PORTE.NUM_ORDRE%TYPE DEFAULT NULL
                                    , P_annul       IN       AFFIL_PORTE.NUM_ORDRE%TYPE DEFAULT NULL
                                    , P_numligne    IN       AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                                    , P_numporte    IN       AFFIL_PORTE.NUMPORTE%TYPE
                                    , i_session     IN       JOURNAL_ADM.ID_SESSION%TYPE
                                    , i_traitement  IN       JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                                    , i_idligne     IN OUT   JOURNAL_ADM.IDLIGNE%TYPE
                                    , o_erreur         OUT   VARCHAR2
                                    , p_type        IN NUMBER default 0)
IS

  CURSOR C_AFFIL_TRACE
      IS
  SELECT DISTINCT t.CLEF
                , t.CLEF2
                , t.CLEF3
                , t.CLEF4
                , t.CLEF5
                , t.ACTION
                , t.OBJET
                , t.COLONNE
                , t.COLONNE2
                , t.COLONNE3
                , t.COLONNE4
                , t.COLONNE5
                , a.NUMLIGNE
                , a.NUMREMISE
  FROM AFFIL_TRACE t, AFFIL_PORTE a
  WHERE a.NUMREMISE=P_numremise
  AND a.NUMPORTE=P_numporte
  AND a.NUMLIGNE = NVL(P_numligne, a.NUMLIGNE)
  AND a.NUMLIGNE = t.numligne
  AND a.numremise = t.numremise
  AND a.numporte = t.numporte
  AND a.etabli = NVL(P_etabli,a.etabli)
  AND a.entreprise = NVL(P_entreprise,a.entreprise)
  AND a.num_ordre = NVL(P_num_ordre,a.num_ordre);

  Rec_C_AFFIL_TRACE       C_AFFIL_TRACE%ROWTYPE;
  stmt                    VARCHAR2(5000);
  loc_presta              NUMBER:=0; -- flag de prestations saisies
  loc_cotis               NUMBER:=0; -- flag de cotisations saisies
  cpt_annul               NUMBER;
  loc_warning            NUMBER;

  exc_prestation          EXCEPTION;
  exc_prestation_sante    EXCEPTION;
  exc_cotisation          EXCEPTION;
  exc_annul_incomplete    EXCEPTION;
  exc_fic_annul           EXCEPTION;
  exc_fic_annulante       EXCEPTION;
  exc_famille             EXCEPTION;
  exc_mvt_adhesion        EXCEPTION;
  flag_annul              VARCHAR2(50);
  loc_affil              AFFIL_PORTE%ROWTYPE;

BEGIN
    --p_type = 0 : annulation drastique de la remise => suppression
  --p_type = 1 : annulation unitaire depuis af06 d'une seule ligne
  --p_type = 2 : annulation d'un établissement d'une remise
  --p_type = 3 :

  --différents cas de figure
  --P_annul : num_ordre DSN annulante AR remise DSN annulant une autre remise lors de l'import automatisé - attention peut être vide aussi
     --> annulation de l'intégration avec conservation de la remise et
  --P_numligne : non vide annulation unitaire lors d'un blocage depuis af06
  --P_entreprise :
  --la suppression de l'import technique est possible uniquement en manuel et uniquement pour la totalité d'une remise.


  o_erreur:=NULL;
  G_nom_traitement:=i_traitement;
  G_Session := i_session;
  G_idligne:=i_idligne;
  cpt_annul:=0;


  P_INS_journal(1, 'Traitement d''annulation :'||P_numremise ||' pour la société :'||P_entreprise||'-'||P_etabli||' ordre:'||P_num_ordre ||' par '||P_annul);
  loc_affil.numremise :=P_numremise;
  loc_affil.numporte :=P_numporte;
  loc_affil.numligne :=P_numligne;
  loc_affil.etabli :=P_etabli;
  loc_affil.entreprise :=P_entreprise;
  loc_affil.num_ordre :=P_num_ordre;
  -- Vérification qu aucune cotisation n a été saisi pour un assuré
  P_VERIF_ANNUL_COTISATION(loc_affil, NULL, loc_cotis);
  IF loc_cotis <>0 THEN
    RAISE exc_cotisation;
  END IF;

  --Vérification de la présence de fichier annulant type AR avec existance d'un fichier annule reel
  SELECT COUNT(NUM_ORDRE) INTO cpt_annul
  FROM AFFIL_FICHIER af
  WHERE NUMREMISE = NVL(P_numremise,NUMREMISE)
  AND NUMPORTE =NVL(P_numporte,NUMPORTE)
  AND ENTREPRISE =NVL(P_entreprise,ENTREPRISE)
  AND ETABLI = NVL(P_etabli,ETABLI)
  AND NUM_ORDRE = P_num_ordre --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
  AND ( NUM_ANNUL IS NOT NULL OR TYPE IN( 3,4))
  AND NUM_ORDRE IN (
     SELECT NUM_ORDRE FROM AFFIL_FICHIER annule
     WHERE annule.NUMREMISE = af.NUMREMISE
     AND annule.NUMPORTE = af.NUMPORTE
     AND annule.ENTREPRISE = af.ENTREPRISE
     AND annule.ETABLI = af.ETABLI
     AND annule.NUM_ANNULANTE = af.NUM_ORDRE);

  IF cpt_annul >0 THEN
    RAISE exc_fic_annul;
  END IF;

  /* M0005453 traces pour debug
  P_INS_journal(3, ' avant count : ' || P_numremise || ' - ' || P_numporte || ' - ' || P_entreprise || ' - ' || P_etabli || ' - ' || P_num_ordre || ' - ' || P_annul );
  insert into affil_fichier_debug select affil_fichier.* , P_num_ordre , P_annul   from affil_fichier where numremise = P_numremise and ENTREPRISE= P_entreprise  and etabli = P_etabli  ;
  */

  --Vérification que le fichier à annuler n'a pas déjà été annulé par un AR
  SELECT COUNT(NUM_ORDRE) INTO cpt_annul
  FROM AFFIL_FICHIER
  WHERE NUMREMISE = NVL(P_numremise,NUMREMISE)
  AND NUMPORTE =NVL(P_numporte,NUMPORTE)
  AND ENTREPRISE =NVL(P_entreprise,ENTREPRISE)
  AND ETABLI = NVL(P_etabli,ETABLI)
  AND NUM_ORDRE = P_num_ordre  --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
  AND NUM_ANNULANTE IS NOT NULL;


  IF cpt_annul >0 THEN
    RAISE exc_fic_annulante;
  END IF;

  -- Parcours de l'ensemble des transactions effectuées pour l import d une affiliation
  FOR Rec_C_AFFIL_TRACE IN C_AFFIL_TRACE LOOP
    flag_annul:= Rec_C_AFFIL_TRACE.OBJET||'-'||Rec_C_AFFIL_TRACE.CLEF;

    stmt:=NULL;

    /***********INSERT************/
    IF Rec_C_AFFIL_TRACE.ACTION ='I' THEN -- Suppression des insertions de l'affiliation

      IF Rec_C_AFFIL_TRACE.OBJET = 'INDIVIDU' THEN --nouvel assuré créé par l'import
        -- Vérification qu aucune prestation n a été saisi pour un assuré
        --prestation prévoyance
        SELECT count(iddossier)   INTO loc_presta
        FROM DOSSIER_SINISTRE ds
        WHERE ds.numindiv = Rec_C_AFFIL_TRACE.CLEF;
        IF loc_presta >0 THEN
          RAISE exc_prestation;
        END IF;

        SELECT count(numsin)   INTO loc_presta
        FROM SINISTRE s
        WHERE s.numindiv = Rec_C_AFFIL_TRACE.CLEF;
        IF loc_presta >0 THEN
          RAISE exc_prestation_sante;
        END IF;
        --mouvement TPE ou noemie
        SELECT count(idporte)   INTO loc_presta
        FROM PORTE_ADHESION p
        WHERE p.numindiv = Rec_C_AFFIL_TRACE.CLEF
        AND p.numporte in (1,2);
        IF loc_presta >0 THEN
          RAISE exc_mvt_adhesion;
        END IF;
        -- groupe familial pour les ayants droits
        SELECT count(numindiv)   INTO loc_presta
        FROM INDIVIDU i
        WHERE i.numassu = Rec_C_AFFIL_TRACE.CLEF;
        IF loc_presta >1 THEN
          RAISE exc_famille;
        END IF;

      ELSIF Rec_C_AFFIL_TRACE.OBJET = 'ADHE_CNTRT' THEN
      --avant de supprimer une adhésion on vérifie son implication dans une prestation santé et prévoyance

        SELECT count(numsin)   INTO loc_presta
        FROM SINISTRE s
        WHERE s.idadhesion IN (
          SELECT idadhesion FROM ADHE_CNTRT WHERE idadhesion =  Rec_C_AFFIL_TRACE.CLEF);
        IF loc_presta >0 THEN
          RAISE exc_prestation_sante;
        END IF;
        --prestation prévoyance

        SELECT count(idrepartition)   INTO loc_presta
        FROM REPARTITION r
        WHERE r.idadhesion = Rec_C_AFFIL_TRACE.CLEF;

        IF loc_presta >0 THEN
          RAISE exc_prestation;
        END IF;

      ELSIF Rec_C_AFFIL_TRACE.OBJET = 'ADHESION' THEN
      --avant de supprimer une couverture, on contrôle qu'il n'y pas déjà eu calcul de prestation
      -- on ne prend pas en compte les lignes de couverture ouverte en double (mauellement)
       SELECT count(numsin)   INTO loc_presta
        FROM SINISTRE s
        WHERE (s.idadhesion,s.numfor) IN (
          SELECT idadhesion,numfor FROM ADHESION WHERE idcouverture =  Rec_C_AFFIL_TRACE.CLEF)
        AND NOT EXISTS (
          SELECT adh.idcouverture FROM ADHESION adh
          WHERE adh.idcouverture <>  Rec_C_AFFIL_TRACE.CLEF
          AND s.datsin between adh.datapli AND NVL(adh.datper,s.datsin)
          AND adh.numindiv = s.numindiv
          AND adh.idadhesion =s.idadhesion
          AND adh.numfor = s.numfor
          );
        IF loc_presta >0 THEN
          RAISE exc_prestation_sante;
        END IF;

       --prestation prévoyance
        SELECT count(idrepartition)   INTO loc_presta
        FROM REPARTITION r, adhesion adh
        WHERE r.idadhesion = adh.idadhesion
        AND adh.idcouverture =Rec_C_AFFIL_TRACE.CLEF;

        IF loc_presta >0 THEN
          RAISE exc_prestation;
        END IF;
      END IF;
      /***STRUCTURE DU DELETE****/
      --cas particulier de structure sql pour les cotisations
      IF Rec_C_AFFIL_TRACE.OBJET = 'EMISSION' THEN
         Dbms_Output.Put_Line(flag_annul);
        stmt:='DELETE FROM '||Rec_C_AFFIL_TRACE.OBJET||' WHERE '||Rec_C_AFFIL_TRACE.COLONNE||' = '||Rec_C_AFFIL_TRACE.CLEF
              ||' AND TRUNC('||Rec_C_AFFIL_TRACE.COLONNE2||') = TRUNC(E2D('''||Rec_C_AFFIL_TRACE.CLEF2||''')) AND NUMRELANCE =99';
        Dbms_Output.Put_Line(stmt);
        EXECUTE IMMEDIATE stmt ;
        --insertion sur trigger doit être répercutée
        stmt:='DELETE FROM FACTURE_ANNUL WHERE codope = 4 AND NUMFACT  = '||Rec_C_AFFIL_TRACE.CLEF
              ||' AND TRUNC(DATOPE) = TRUNC(E2D('''||Rec_C_AFFIL_TRACE.CLEF2||'''))';
        EXECUTE IMMEDIATE stmt ;
      --sinon pour tous les autres cas
      ELSE
        stmt:='DELETE FROM '||Rec_C_AFFIL_TRACE.OBJET||' WHERE '||Rec_C_AFFIL_TRACE.COLONNE||' = '||Rec_C_AFFIL_TRACE.CLEF;
        EXECUTE IMMEDIATE stmt ;
      END IF;


    /*  IF Rec_C_AFFIL_TRACE.OBJET = 'VAL_VARIABLE' THEN
        stmt:=stmt||' AND '||Rec_C_AFFIL_TRACE.COLONNE2||' = TO_DATE('''||Rec_C_AFFIL_TRACE.CLEF2||''', ''DD/MM/YYYY'')';
      END IF;*/


    /***********UPDATE************/
    ELSIF Rec_C_AFFIL_TRACE.ACTION ='U' THEN -- Suppression des mises a jour de l'affiliation(ne concerne que les ADHESIONS)

      IF Rec_C_AFFIL_TRACE.OBJET = 'PERS_ADRESSE' THEN
        stmt:='UPDATE '||Rec_C_AFFIL_TRACE.OBJET||' SET '||Rec_C_AFFIL_TRACE.COLONNE2||' = '''||Rec_C_AFFIL_TRACE.CLEF2
                       ||''' WHERE '|| Rec_C_AFFIL_TRACE.COLONNE||' = '||Rec_C_AFFIL_TRACE.CLEF;
      ELSIF Rec_C_AFFIL_TRACE.OBJET = 'VAL_VARIABLE' THEN
        stmt:='UPDATE '||Rec_C_AFFIL_TRACE.OBJET||' SET '||Rec_C_AFFIL_TRACE.COLONNE3||' = '''||Rec_C_AFFIL_TRACE.CLEF3
                                                ||''' , '  ||Rec_C_AFFIL_TRACE.COLONNE5||'= TO_DATE('''||Rec_C_AFFIL_TRACE.CLEF5||''', ''DD/MM/YYYY'')'
                       ||' WHERE '|| Rec_C_AFFIL_TRACE.COLONNE||'  = '||Rec_C_AFFIL_TRACE.CLEF
                       ||'     AND '||Rec_C_AFFIL_TRACE.COLONNE2||'  = NVL(TO_DATE('''||Rec_C_AFFIL_TRACE.CLEF2||''', ''DD/MM/YYYY''),'||Rec_C_AFFIL_TRACE.COLONNE2||')'
                       ||'     AND '||Rec_C_AFFIL_TRACE.COLONNE4||' = '||Rec_C_AFFIL_TRACE.CLEF4;
      -- MUR M0005606
      ELSIF Rec_C_AFFIL_TRACE.OBJET IN( 'ADHESION') THEN
        stmt:='UPDATE '||Rec_C_AFFIL_TRACE.OBJET||' SET '||Rec_C_AFFIL_TRACE.COLONNE||'= NULL WHERE IDADHESION='||Rec_C_AFFIL_TRACE.CLEF ||
               ' AND DATPER=e2d('''||Rec_C_AFFIL_TRACE.CLEF2||''')' ;

        --P_INS_journal(1, 'MUR debug stmt :' || stmt );

      ELSIF Rec_C_AFFIL_TRACE.OBJET  = 'ADHE_CNTRT' THEN -- MUR M0005606 IN( 'ADHESION' , 'ADHE_CNTRT') THEN
        stmt:='UPDATE '||Rec_C_AFFIL_TRACE.OBJET||' SET '||Rec_C_AFFIL_TRACE.COLONNE||'= NULL WHERE IDADHESION='||Rec_C_AFFIL_TRACE.CLEF;


      ELSIF Rec_C_AFFIL_TRACE.OBJET = 'INDIVIDU' AND Rec_C_AFFIL_TRACE.COLONNE IN ('LIEUNAIS','NOMJF') THEN
        stmt:='UPDATE '||Rec_C_AFFIL_TRACE.OBJET||' SET '||Rec_C_AFFIL_TRACE.COLONNE||' = NULL WHERE NUMINDIV = '||Rec_C_AFFIL_TRACE.CLEF;

      ELSE RAISE exc_annul_incomplete;
      END IF;

      EXECUTE IMMEDIATE stmt ;

    END IF;
  END LOOP;

  IF p_type =0 THEN
   --SUPPRESION DES DONNÉES DE PHASE 3
     -------------------- Suppression dans AFFIL_PORTE_ARRET -----------------------
    DELETE AFFIL_PORTE_ARRET
    WHERE numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_PORTE_PAIEMENT -----------------------
    DELETE AFFIL_PORTE_PAIEMENT
    WHERE numremise = P_numremise
    AND numporte = P_numporte;
        -------------------- Suppression dans AFFIL_FICHIER -----------------------
    DELETE AFFIL_PORTE_QTTC_ELT
    WHERE numremise = P_numremise
    AND numporte = P_numporte;
         -------------------- Suppression dans AFFIL_FICHIER -----------------------
    DELETE AFFIL_PORTE_QTTC_INDIV
    WHERE numremise = P_numremise
    AND numporte = P_numporte;
        -------------------- Suppression dans AFFIL_FICHIER -----------------------
    DELETE AFFIL_PORTE_QTTC
    WHERE numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_PORTE_AYD -------------------------
    DELETE AFFIL_PORTE_AYD
    WHERE  numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_PORTE_ADH -------------------------
    DELETE AFFIL_PORTE_ADH
    WHERE  numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_PORTE_RIB -------------------------
    DELETE AFFIL_PORTE_RIB
    WHERE  numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_PORTE_CNTRT -------------------------
    DELETE AFFIL_PORTE_CNTRT
    WHERE  numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_PORTE_FORCAGE -------------------------
    DELETE AFFIL_PORTE_FORCAGE
    WHERE  numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_TRACE -------------------------
    DELETE AFFIL_TRACE
    WHERE  numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_ANO ---------------------------
    DELETE AFFIL_ANO
    WHERE numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans AFFIL_PORTE -------------------------
    DELETE AFFIL_PORTE
    WHERE  numremise = P_numremise
    AND numporte=P_numporte;
      -------------------- Suppression dans AFFIL_FICHIER -----------------------
    DELETE AFFIL_FICHIER
    WHERE numremise = P_numremise
    AND numporte = P_numporte;
    -------------------- Suppression dans PORTE_REMISE -------------------------
    DELETE PORTE_REMISE
    WHERE  numremise = P_numremise
    AND numporte = P_numporte;


  ELSIF p_type >0 THEN
    --Annulation intégration fonctionnelle
    -- remise à blanc des clefs

    -- todo :  AFFIL_PORTE_ARRET une fois intégration fonctionnelle réalisée

    UPDATE AFFIL_PORTE_QTTC_ELT  SET statut =decode(P_annul,NULL,2,0), valeur = null, id_variable = null
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = P_num_ordre --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
          )));

    UPDATE AFFIL_PORTE_QTTC  SET statut  =decode(P_annul,NULL,2,0), numquit = null
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = P_num_ordre --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
          )));

    UPDATE AFFIL_PORTE_ADH  SET numindiv = null, numgar = null, refgarantie = null, idadhesion = null
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = P_num_ordre --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
          )));

    UPDATE AFFIL_PORTE_AYD  SET numindiv = null
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = P_num_ordre --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
          )));

    UPDATE AFFIL_PORTE_RIB  SET numindiv = null , idrib = null
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND (NUMLIGNE = P_numligne AND P_numligne IS NOT NULL
        OR NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = P_num_ordre --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
          ));

    --état ligne salarié en fonction de l'annulation manuelle ou suite à la réception d'un fichier DSN annule et remplace
    UPDATE AFFIL_PORTE  SET NUMINDIV = NULL , NUMGAR = NULL , IDADHESION = NULL   , TYPE_MVT = NULL, ETAT =decode(P_annul,NULL,2,4)
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND num_ordre = P_num_ordre
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = P_num_ordre --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
          )));

    IF P_annul IS NOT NULL THEN --uniquement pour les AR
      UPDATE AFFIL_FICHIER SET NUM_ANNULANTE =  P_annul
      WHERE numremise = P_numremise
      AND numporte = P_numporte
      AND etabli =P_etabli
      AND entreprise = P_entreprise
      AND num_ordre = P_num_ordre --M0005453 fichier à annuler déterminé dans P_ANNUL_REMPLACE
      AND datefic IN (
        SELECT datefic FROM AFFIL_FICHIER
        WHERE numremise >= P_numremise
        AND numporte = P_numporte
        AND etabli =P_etabli
        AND entreprise = P_entreprise
        AND num_ordre = P_annul);

      P_INS_journal(1, 'Annulation de ' ||SQL%ROWCOUNT||' fichier :'||P_num_ordre ||' de la remise '||P_numremise||' pour la société :'||P_entreprise||'-'||P_etabli|| ' a été effectuée par '||P_annul);
    ELSE
      P_INS_journal(1, 'Annulation du fichier :'||P_num_ordre ||' de la remise '||P_numremise||' pour la société :'||P_entreprise||'-'||P_etabli|| ' a été effectuée sans n°annulant');
    END IF;

    -------------------- Suppression dans AFFIL_TRACE -------------------------
    DELETE AFFIL_TRACE
    WHERE  numremise = P_numremise
      AND NUMPORTE = P_numporte
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = NVL(P_num_ordre,num_ordre))));

  END IF;
  i_idligne:=G_idligne;
  --COMMIT; réalisé dans la fonction appelante
EXCEPTION
  WHEN exc_cotisation THEN
    O_erreur:='Existence de cotisations : annulation impossible';
    P_INS_journal(1,'Existence de cotisations : annulation impossible');
    ROLLBACK;
  WHEN exc_fic_annul THEN
    O_erreur:='Existence de '|| cpt_annul||' fichier(s) annulant d''autre(s) fichier(s) : annulation impossible';
    P_INS_journal(1,'Existence de '|| cpt_annul||' fichier(s) annulant d''autre(s) fichier(s) : annulation impossible');
    ROLLBACK;
  WHEN exc_fic_annulante THEN
    O_erreur:='Existence de '|| cpt_annul||' fichier(s) annulé(s) par d''autre(s) fichier(s) : annulation impossible';
    P_INS_journal(1,'Existence de '|| cpt_annul||' fichier(s) annulés par d''autre(s) fichier(s) : annulation impossible');
    ROLLBACK;
  WHEN exc_prestation THEN
    O_erreur:='Existence de prestations prévoyance : annulation impossible de l''intégration <'||flag_annul;
    P_INS_journal(1,'Existence de prestations prévoyance : annulation impossible de l''assuré<'||flag_annul);
    ROLLBACK;
  WHEN exc_prestation_sante THEN
    O_erreur:='Existence de prestations santé : annulation impossibe de l''intégration <'||flag_annul;
    P_INS_journal(1,'Existence de prestations santé : annulation impossibe de l''assuré<'||flag_annul);
    ROLLBACK;
  WHEN exc_mvt_adhesion THEN
    O_erreur:='Existence mouvement Noémie ou TPE : annulation impossibe de l''intégration <'||flag_annul;
    P_INS_journal(1,'Existence de prestations santé : annulation impossibe de l''assuré<'||flag_annul);
    ROLLBACK;
  WHEN exc_famille THEN
    O_erreur:='Existence d''ayant droit : annulation impossibe de l''intégration <'||flag_annul;
    P_INS_journal(1,'Existence de prestations santé : annulation impossibe de l''assuré<'||flag_annul);
    ROLLBACK;
  WHEN exc_annul_incomplete THEN
    O_erreur:='Annulation non possible : process incomplet pour l''intégration <'||flag_annul;
    P_INS_journal(1,'Annulation non possible : process incomplet pour<'||flag_annul);
    ROLLBACK;
  WHEN OTHERS THEN
    O_erreur:='Erreur: Annulation impossible:'||SQLERRM;
    P_INS_journal(1,'Erreur: Annulation impossible:'||SQLERRM);
    P_INS_journal(1,'Erreur: stmt -'||stmt);
    ROLLBACK;
END P_ANNULATION_AFFILIATION;

--remise à 0 de l'identification d'une intégration ou annulation de doublon intégré par script avec numannul valorisé
--affil_trace reste en historique, les données ne sont pas supprimées
PROCEDURE P_ANNULATION_AFFILIATION_EXCEP (  P_numremise   IN       AFFIL_PORTE.NUMREMISE%TYPE
                                    , P_entreprise  IN       AFFIL_PORTE.ENTREPRISE%TYPE DEFAULT NULL
                                    , P_etabli      IN       AFFIL_PORTE.ETABLI%TYPE DEFAULT NULL
                                    , P_num_ordre   IN       AFFIL_PORTE.NUM_ORDRE%TYPE DEFAULT NULL
                                    , P_annul       IN       AFFIL_PORTE.NUM_ORDRE%TYPE DEFAULT NULL
                                    , P_numligne    IN       AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                                    , P_numporte    IN       AFFIL_PORTE.NUMPORTE%TYPE
                                    , i_session     IN       JOURNAL_ADM.ID_SESSION%TYPE
                                    , i_traitement  IN       JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                                    , i_idligne     IN OUT   JOURNAL_ADM.IDLIGNE%TYPE
                                    , o_erreur         OUT   VARCHAR2)
IS





  loc_presta              NUMBER:=0; -- flag de prestations saisies
  loc_cotis               NUMBER:=0; -- flag de cotisations saisies
  cpt_annul               NUMBER;
  loc_warning             NUMBER;

  exc_prestation          EXCEPTION;
  exc_prestation_sante    EXCEPTION;
  exc_cotisation          EXCEPTION;
  exc_annul_incomplete    EXCEPTION;
  exc_fic_annul           EXCEPTION;
  exc_fic_annulante       EXCEPTION;
  flag_annul              NUMBER;
  loc_affil              AFFIL_PORTE%ROWTYPE;

BEGIN
  o_erreur:=NULL;
  G_nom_traitement:=i_traitement;
  G_Session := i_session;
  G_idligne:=i_idligne;
  cpt_annul:=0;


  P_INS_journal(1, 'Traitement d''annulation EXCEP :'||P_numremise ||' pour la société :'||P_entreprise||'-'||P_etabli||' ordre:'||P_num_ordre);
  loc_affil.numremise :=P_numremise;
  loc_affil.numporte :=P_numporte;
  loc_affil.numligne :=P_numligne;
  loc_affil.etabli :=P_etabli;
  loc_affil.entreprise :=P_entreprise;
  loc_affil.num_ordre :=P_num_ordre;
  -- Vérification qu aucune cotisation n a été saisi pour un assuré
  P_VERIF_ANNUL_COTISATION(loc_affil, NULL, loc_cotis);
  IF loc_cotis = 1 THEN
    RAISE exc_cotisation;
  END IF;

  --Vérification de la présence de fichier annulant type AR avec existance d'un fichier annule reel
  SELECT COUNT(NUM_ORDRE) INTO cpt_annul
  FROM AFFIL_FICHIER af
  WHERE NUMREMISE = NVL(P_numremise,NUMREMISE)
  AND NUMPORTE =NVL(P_numporte,NUMPORTE)
  AND ENTREPRISE =NVL(P_entreprise,ENTREPRISE)
  AND ETABLI = NVL(P_etabli,ETABLI)
  AND NUM_ORDRE = NVL(P_num_ordre,NUM_ORDRE)
  AND ( NUM_ANNUL IS NOT NULL OR TYPE IN( 3,4))
  AND NUM_ORDRE IN (
     SELECT NUM_ORDRE FROM AFFIL_FICHIER annule
     WHERE annule.NUMREMISE = af.NUMREMISE
     AND annule.NUMPORTE = af.NUMREMISE
     AND annule.ENTREPRISE = af.NUMREMISE
     AND annule.ETABLI = af.NUMREMISE
     AND annule.NUM_ANNULANTE = af.NUM_ORDRE);

  IF cpt_annul >0 THEN
    RAISE exc_fic_annul;
  END IF;


  --Vérification que le fichier n'a pas déjà été annulé par un AR
  SELECT COUNT(NUM_ORDRE) INTO cpt_annul
  FROM AFFIL_FICHIER
  WHERE NUMREMISE = NVL(P_numremise,NUMREMISE)
  AND NUMPORTE =NVL(P_numporte,NUMPORTE)
  AND ENTREPRISE =NVL(P_entreprise,ENTREPRISE)
  AND ETABLI = NVL(P_etabli,ETABLI)
  AND NUM_ORDRE = NVL(P_num_ordre,NUM_ORDRE)
  AND NUM_ANNULANTE IS  NULL;

  IF cpt_annul<>1 THEN
    RAISE exc_fic_annulante;
  END IF;



    -- todo :  AFFIL_PORTE_ARRET une fois intégration fonctionnelle réalisée

    UPDATE AFFIL_PORTE_QTTC_ELT  SET statut = null, valeur = null, id_variable = null
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = NVL(P_num_ordre,num_ordre))));

    UPDATE AFFIL_PORTE_QTTC  SET statut = 2, numquit = null
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = NVL(P_num_ordre,num_ordre))));

    --état ligne salarié en fonction de l'annulation manuelle ou suite à la réception d'un fichier DSN annule et remplace
    UPDATE AFFIL_PORTE  SET  ETAT =decode(P_annul,NULL,2,4)
    WHERE NUMREMISE=P_numremise
      AND NUMPORTE = P_numporte
      AND ((NUMLIGNE = P_numligne AND P_numligne IS NOT NULL)
        OR( P_numligne IS  NULL AND NUMLIGNE IN (
          SELECT numligne FROM AFFIL_PORTE
          WHERE numremise = P_numremise  AND numporte = P_numporte
          AND etabli = NVL(P_etabli,etabli) AND entreprise = NVL(P_entreprise,entreprise)
          AND num_ordre = NVL(P_num_ordre,num_ordre))));

    IF P_annul IS NOT NULL THEN
      UPDATE AFFIL_FICHIER SET NUM_ANNULANTE =  P_annul
      WHERE numremise = P_numremise
      AND numporte = P_numporte
      AND etabli = NVL(P_etabli,etabli)
      AND entreprise = NVL(P_entreprise,entreprise)
      AND num_ordre = NVL(P_num_ordre,num_ordre);

      P_INS_journal(1, 'Annulation du fichier :'||P_annul ||' pour la société :'||P_entreprise||'-'||P_etabli|| ' a été effectuée.');
      Dbms_Output.Put_Line( 'Annulation du fichier :'||P_annul ||' pour la société :'||P_entreprise||'-'||P_etabli|| ' a été effectuée.');
    END IF;


  i_idligne:=G_idligne;
  -- COMMIT; MUR M0006328 ne plus importer une partie seulement du fichier  
EXCEPTION
  WHEN exc_cotisation THEN
    O_erreur:='Existence de cotisations : annulation impossible';
    P_INS_journal(1,'Existence de cotisations : annulation impossible');
    ROLLBACK;
  WHEN exc_fic_annul THEN
    O_erreur:='Existence de '|| cpt_annul||' fichier(s) annulant d''autre(s) fichier(s) : annulation impossible';
    P_INS_journal(1,'Existence de '|| cpt_annul||' fichier(s) annulant d''autre(s) fichier(s) : annulation impossible');
    ROLLBACK;
  WHEN exc_fic_annulante THEN
    O_erreur:='Existence de '|| cpt_annul||' fichier(s) annulé(s) par d''autre(s) fichier(s) : annulation impossible';
    P_INS_journal(1,'Existence de '|| cpt_annul||' fichier(s) annulés par d''autre(s) fichier(s) : annulation impossible');
    ROLLBACK;
  WHEN exc_prestation THEN
    O_erreur:='Existence de prestations prévoyance : annulation impossible de l''assuré<'||flag_annul;
    P_INS_journal(1,'Existence de prestations prévoyance : annulation impossible de l''assuré<'||flag_annul);
    ROLLBACK;
  WHEN exc_prestation_sante THEN
    O_erreur:='Existence de prestations santé : annulation impossibe de l''assuré<'||flag_annul;
    P_INS_journal(1,'Existence de prestations santé : annulation impossibe de l''assuré<'||flag_annul);
    ROLLBACK;
  WHEN exc_annul_incomplete THEN
    O_erreur:='Annulation non possible : process incomplet pour <'||flag_annul;
    P_INS_journal(1,'Annulation non possible : process incomplet pour<'||flag_annul);
    ROLLBACK;
  WHEN OTHERS THEN
    O_erreur:='Erreur: Annulation impossible:'||SQLERRM;
    P_INS_journal(1,'Erreur: Annulation impossible:'||SQLERRM);
    ROLLBACK;
END P_ANNULATION_AFFILIATION_EXCEP;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNULATION_COTISATION                                   */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire Annulation de l import fonctionnelle des  */
/*                 cotisations                                               */
/* Entree       :  remise et porte                                           */
/* Retour       :  o_erreur, Message d erreur                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNULATION_COTISATION (  P_numquit         IN    AFFIL_PORTE_QTTC.NUMQUIT%TYPE
                                   , o_erreur          OUT   VARCHAR2)
IS
  -- Recherche de l idvariable a annuler pour une quittance
  CURSOR C_annul_cotis
      IS
    SELECT DISTINCT NVL(MAX(aq.id_variable),0) id_variable, aq.numremise, aq.numporte , ap.NUM_QTTC , aq.valeur
      FROM AFFIL_PORTE_QTTC_ELT aq
         , AFFIL_PORTE_QTTC ap
     WHERE aq.NUM_QTTC=ap.NUM_QTTC
       AND ap.NUMQUIT=P_numquit
     GROUP BY  aq.numremise, aq.numporte, ap.NUM_QTTC , aq.valeur;


BEGIN


  FOR  rec_annul_cotis      IN    C_annul_cotis   LOOP

    -- remise à blanc du numéro de quittance
    P_MAJ_AFFIL_PORTE_QTTC_NUMQUIT( rec_annul_cotis.numremise
                                  , rec_annul_cotis.numporte
                                  , rec_annul_cotis.num_qttc
                                  , P_numquit
                                  ) ;


    -- remise à blanc de l idvariable
    P_MAJ_AFFIL_PORTE_QTTC_ELTVAR( rec_annul_cotis.numremise
                                 , rec_annul_cotis.numporte
                                 , rec_annul_cotis.num_qttc
                                 , rec_annul_cotis.id_variable
                                 , rec_annul_cotis.valeur
                                  ) ;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    O_erreur:='Erreur: Annulation impossible:'||SUBSTR(SQLERRM,1,132);
    P_INS_journal(3,' Erreur: Annulation impossible:'||SUBSTR(SQLERRM,1,132));
END P_ANNULATION_COTISATION;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_BLOCAGE_AFFILIATION                                     */
/* Type         :  Public                                                    */
/* Description  :  Permet de bloquer une affiliation. Cette action a pour    */
/*                 objectif de mettre l état à 3 et de supprimer les insert  */
/*                 ou mise à jour effectuée sur affiliations dans ARTHUS lors*/
/*                 de l import                                               */
/* Entree       :  P_numremise, numremise                                    */
/*              :  P_numligne, P_numligne                                    */
/* Retour       :  o_erreur, Message d erreur                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_BLOCAGE_AFFILIATION ( P_numremise       IN    AFFIL_PORTE.NUMREMISE%TYPE
                                , P_numligne        IN    AFFIL_PORTE.NUMLIGNE%TYPE
                                , P_Flagetype       IN    NUMBER
                                , o_erreur          OUT   VARCHAR2)
IS
  CURSOR C_AFFIL_TRACE
      IS
  SELECT DISTINCT a.CLEF
                , a.ACTION
                , a.OBJET
                , a.COLONNE
                , a.COLONNE2
                , a.CLEF2
                , a.COLONNE3
                , a.CLEF3
                , a.COLONNE4
                , a.CLEF4
                , a.COLONNE5
                , a.CLEF5
   FROM AFFIL_TRACE a
  WHERE a.NUMREMISE=P_numremise
    AND a.NUMLIGNE=P_numligne;

  Rec_C_AFFIL_TRACE       C_AFFIL_TRACE%ROWTYPE;
  stmt                    VARCHAR2(600);
  loc_AFFIL_ANO           AFFIL_ANO%ROWTYPE;
  loc_presta              NUMBER:=0; -- flag de prestations saisies
  loc_cotis               NUMBER:=0; -- flag de cotisations saisies

  exc_prestation          EXCEPTION;
  exc_prestation_sante    EXCEPTION;
  exc_cotisation          EXCEPTION;
  exc_annul_incomplete    EXCEPTION;

BEGIN
  o_erreur:=0;


  -- Parcours de l'ensemble des transactions effectuées pour l import d une affiliation
  FOR Rec_C_AFFIL_TRACE IN C_AFFIL_TRACE LOOP
    stmt:=NULL;

    /***********INSERT************/
    IF Rec_C_AFFIL_TRACE.ACTION ='I' THEN -- Suppression des insertions de l'affiliation

      IF Rec_C_AFFIL_TRACE.OBJET = 'INDIVIDU' THEN --nouvel assuré créé par l'import
        -- Vérification qu aucune prestation n a été saisi pour un assuré
        SELECT count(iddossier)   INTO loc_presta
        FROM DOSSIER_SINISTRE ds
        WHERE ds.numindiv = Rec_C_AFFIL_TRACE.CLEF;
        IF loc_presta >0 THEN
          RAISE exc_prestation;
        END IF;

        SELECT count(numsin)   INTO loc_presta
        FROM SINISTRE s
        WHERE s.numindiv = Rec_C_AFFIL_TRACE.CLEF;
        IF loc_presta >0 THEN
          RAISE exc_prestation_sante;
        END IF;

      END IF;

      stmt:='DELETE FROM '||Rec_C_AFFIL_TRACE.OBJET||' WHERE '||Rec_C_AFFIL_TRACE.COLONNE||' = '||Rec_C_AFFIL_TRACE.CLEF;
      IF Rec_C_AFFIL_TRACE.OBJET = 'VAL_VARIABLE' THEN
        stmt:=stmt||' AND '||Rec_C_AFFIL_TRACE.COLONNE2||' = TO_DATE('''||Rec_C_AFFIL_TRACE.CLEF2||''', ''DD/MM/YYYY'')';
      END IF;

      EXECUTE IMMEDIATE stmt ;

    /***********UPDATE************/
    ELSIF Rec_C_AFFIL_TRACE.ACTION ='U' THEN -- Suppression des mises a jour de l'affiliation(ne concerne que les ADHESIONS)

      IF Rec_C_AFFIL_TRACE.OBJET = 'PERS_ADRESSE' THEN
        stmt:='UPDATE '||Rec_C_AFFIL_TRACE.OBJET||' SET '||Rec_C_AFFIL_TRACE.COLONNE2||' = '''||Rec_C_AFFIL_TRACE.CLEF2
                       ||''' WHERE '|| Rec_C_AFFIL_TRACE.COLONNE||' = '||Rec_C_AFFIL_TRACE.CLEF;
      ELSIF Rec_C_AFFIL_TRACE.OBJET = 'VAL_VARIABLE' THEN
        stmt:='UPDATE '||Rec_C_AFFIL_TRACE.OBJET||' SET '||Rec_C_AFFIL_TRACE.COLONNE3||' = '''||Rec_C_AFFIL_TRACE.CLEF3
                                                ||''' , '  ||Rec_C_AFFIL_TRACE.COLONNE5||'= TO_DATE('''||Rec_C_AFFIL_TRACE.CLEF5||''', ''DD/MM/YYYY'')'
                       ||' WHERE '|| Rec_C_AFFIL_TRACE.COLONNE||'  = '||Rec_C_AFFIL_TRACE.CLEF
                       ||'     AND '||Rec_C_AFFIL_TRACE.COLONNE2||'  = NVL(TO_DATE('''||Rec_C_AFFIL_TRACE.CLEF2||''', ''DD/MM/YYYY''),'||Rec_C_AFFIL_TRACE.COLONNE2||')'
                       ||'     AND '||Rec_C_AFFIL_TRACE.COLONNE4||' = '||Rec_C_AFFIL_TRACE.CLEF4;
      ELSIF Rec_C_AFFIL_TRACE.OBJET IN( 'ADHESION' , 'ADHE_CNTRT') THEN
        stmt:='UPDATE '||Rec_C_AFFIL_TRACE.OBJET||' SET '||Rec_C_AFFIL_TRACE.COLONNE||'= NULL WHERE IDADHESION='||Rec_C_AFFIL_TRACE.CLEF;
      ELSE RAISE exc_annul_incomplete;
      END IF;

      EXECUTE IMMEDIATE stmt ;

    END IF;

  END LOOP;

  -- Insertion de l ano 10 Prestation bloquee manuellement.
  SELECT numporte INTO loc_AFFIL_ANO.NUMPORTE
  FROM PORTE_REMISE WHERE NUMREMISE = P_numremise;

  loc_AFFIL_ANO.NUMANO:=10;
  loc_AFFIL_ANO.NUMREMISE:=P_numremise;
  loc_AFFIL_ANO.NUMLIGNE:=P_numligne;
  loc_AFFIL_ANO.DATANO:=SYSDATE;
  loc_AFFIL_ANO.ETATANO:=3;

  --ABO 29/05/2015 remise à blanc au blocage des objets
  PK_CTRL_AFFIL.P_DEL_AFFIL_ANO(P_numremise,P_numligne,loc_AFFIL_ANO.NUMPORTE);
  PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);


  DELETE FROM AFFIL_TRACE a
  WHERE a.NUMREMISE=P_numremise
    AND a.NUMLIGNE=P_numligne;

  COMMIT;



EXCEPTION
  WHEN exc_cotisation THEN
    O_erreur:='Existence de cotisations : annulation impossible';
    ROLLBACK;
  WHEN exc_prestation THEN
    O_erreur:= 'Existence de prestations prévoyance : annulation impossible';
    ROLLBACK;
  WHEN exc_prestation_sante THEN
    O_erreur:='Existence de prestations santé : annulation impossibe';
    ROLLBACK;
  WHEN exc_annul_incomplete THEN
    O_erreur:='Annulation non possible : process incomplet';
    ROLLBACK;
  WHEN OTHERS THEN
    O_erreur:='Blocage impossible:'||SUBSTR(SQLERRM,1,132);
    ROLLBACK;

END P_BLOCAGE_AFFILIATION;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_DEBLOCAGE_AFFILIATION                                   */
/* Type         :  Public                                                    */
/* Description  :  Permet de débloquer une affiliation. Cette action a pour  */
/*                 objectif de mettre l état à 3 et de supprimer les insert  */
/*                 ou mise à jour effectuée sur affiliations dans ARTHUS lors*/
/*                 de l import                                               */
/* Entree       :  P_numremise, numremise                                    */
/*              :  P_numligne, P_numligne                                    */
/* Retour       :  o_erreur, Message d erreur                                */
/*---------------------------------------------------------------------------*/
/*
PROCEDURE P_DEBLOCAGE_AFFILIATION ( P_AFFIL_PORTE   IN OUT     AFFIL_PORTE%ROWTYPE
                                  , O_erreur           OUT     NUMBER
                                  , Po_forcage      IN OUT     NUMBER)
IS
  loc_ok                NUMBER:=0;
  loc_AFFIL_PORTE       AFFIL_PORTE%ROWTYPE;
  loc_ano_affiporte     AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_erreur_ctrl       VARCHAR2(150):=NULL;
  loc_ano               AFFIL_ANO.NUMANO%TYPE:=0;
BEGIN
  O_erreur:=0;
  ---------------------------------------------------------------------------------
  --PURGE DES ANO DE L AFFILIATION DE LA REMISE
  ---------------------------------------------------------------------------------
  PK_CTRL_AFFIL.P_DEL_AFFIL_ANO( P_AFFIL_PORTE.numremise
                               , P_AFFIL_PORTE.numligne
                               , P_AFFIL_PORTE.numporte);

  P_AFFIL_PORTE.ETAT:=2;
  P_AFFIL_PORTE.USERNAME_FORCAGE:=F_NUMUTIL;
  ---------------------------------------------------------------------------------------------------------
  -- INITIALISATION DE L'OBJET P_AFFIL_PORTE AVEC LES INFORMATIONS DÉBLOQUÉES
  ---------------------------------------------------------------------------------------------------------
  PK_CTRL_AFFIL.P_DEBLOC_AFFIL_PORTE( P_AFFIL_PORTE
                                    , loc_ano_affiporte);
  IF loc_ano_affiporte>0 THEN
    O_erreur:=1;
  ELSE
    O_erreur:=0;
  END IF;


  IF O_erreur=0 THEN
    ---------------------------------------------------------------------------------------------------------
    -- CONTROLES DES DONNÉES DÉBLOQUÉES AFIN DE POUVOIR LES INTÉGRÉES AU MOMENT VOULUES
    ---------------------------------------------------------------------------------------------------------
      loc_ok:=PK_IMPORT_AFFIL.f_ctrlAFFIL_PORTE( P_AFFIL_PORTE.numporte
                                               , P_AFFIL_PORTE.numremise
                                               , P_AFFIL_PORTE.ENTREPRISE
                                               , P_AFFIL_PORTE.numligne
                                               , null
                                               , loc_ano
                                               , loc_erreur_ctrl);
    IF loc_ano>0 THEN
      O_erreur:=1;
      COMMIT;
    ELSE
      COMMIT;
      O_erreur:=0;
    END IF;
  ELSE
    ROLLBACK;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    O_erreur:=1;
    ROLLBACK;
    P_INS_journal(3,' Erreur: Déblocage impossible:'||SUBSTR(SQLERRM,1,132));
END P_DEBLOCAGE_AFFILIATION;
*/
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_DEBLOC_AFFIL_PORTE                                      */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour des données de l'interface       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_DEBLOC_AFFIL_PORTE( P_AFFIL_PORTE      IN      AFFIL_PORTE%ROWTYPE
                              , P_ano              OUT     AFFIL_ANO.NUMANO%TYPE)
IS

BEGIN
  P_ano:=0;
  -- Mise à jour de AFFIL_PORTE
  UPDATE AFFIL_PORTE
     SET NUMINDIV=P_AFFIL_PORTE.NUMINDIV
       , NUMCLI=P_AFFIL_PORTE.NUMCLI
       , ETAT=P_AFFIL_PORTE.ETAT
       , USERNAME_FORCAGE=P_AFFIL_PORTE.USERNAME_FORCAGE
       , IDADHESION=P_AFFIL_PORTE.IDADHESION
     --  , DEBUTA=P_AFFIL_PORTE.DEBUTA
     --  , FINA=P_AFFIL_PORTE.FINA
       , MOTIF=P_AFFIL_PORTE.MOTIF
   WHERE NUMREMISE=P_AFFIL_PORTE.NUMREMISE
     AND NUMPORTE=P_AFFIL_PORTE.NUMPORTE
     AND NUMLIGNE=P_AFFIL_PORTE.NUMLIGNE;


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(3,' Erreur : Mise a jour impossible de AFFIL_PORTE.NUMINDIV:'||SUBSTR(SQLERRM,1,132));
END P_DEBLOC_AFFIL_PORTE;

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
/* FUNCTION                                                                  */
/* Nom          :  F_INSERT_ADHE_CNTRT                                       */
/* Type         :  Public                                                    */
/* Description  :  fonction de insertion dans ADHE_CNTRT                     */
/* Retour       :  TRUE=>OK, FALSE=>KO                                       */
/*---------------------------------------------------------------------------*/
FUNCTION F_INSERT_ADHE_CNTRT( P_ADHE_CNTRT IN ADHE_CNTRT%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO ADHE_CNTRT VALUES P_ADHE_CNTRT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,' P_INIT_ADHE_CNTRT , P_ADHE_CNTRT.IDADHESION <'||P_ADHE_CNTRT.IDADHESION||'>');
  P_INS_journal(1 ,'WHEN OTHERS THEN'||SUBSTR(SQLERRM,1,132));
    RETURN FALSE;
END F_INSERT_ADHE_CNTRT;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_INSERT_HISTO_ADHESION                                   */
/* Type         :  Public                                                    */
/* Description  :  fonction de insertion dans HISTO_ADHESION                 */
/* Retour       :  TRUE=>OK, FALSE=>KO                                       */
/*---------------------------------------------------------------------------*/
FUNCTION F_INSERT_HISTO_ADHESION( P_HISTO_ADHESION IN HISTO_ADHESION%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN
  IF P_HISTO_ADHESION.IDADHESION IS NULL THEN
    RETURN FALSE;
  END IF;

  INSERT INTO HISTO_ADHESION VALUES P_HISTO_ADHESION;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_INSERT_HISTO_ADHESION;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_INSERT_ADHE_CNTRT_MEMBRE                                */
/* Type         :  Public                                                    */
/* Description  :  fonction de insertion dans HISTO_ADHESION                 */
/* Retour       :  TRUE=>OK, FALSE=>KO                                       */
/*---------------------------------------------------------------------------*/
FUNCTION F_INSERT_ADHE_CNTRT_MEMBRE( P_ADHE_CNTRT_MEMBRE IN ADHE_CNTRT_MEMBRE%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO ADHE_CNTRT_MEMBRE VALUES P_ADHE_CNTRT_MEMBRE;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_INSERT_ADHE_CNTRT_MEMBRE;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_INSERT_ADHESION                                         */
/* Type         :  Public                                                    */
/* Description  :  fonction de insertion dans ADHESION                       */
/* Retour       :  TRUE=>OK, FALSE=>KO                                       */
/*---------------------------------------------------------------------------*/
FUNCTION F_INSERT_ADHESION( P_ADHESION IN ADHESION%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN
  /*
  P_INS_journal(1,' F_INSERT_ADHESION IDADHESION :'||P_ADHESION.IDADHESION);
  P_INS_journal(1,' F_INSERT_ADHESION NUMINDIV :'||P_ADHESION.NUMINDIV);
  P_INS_journal(1,' F_INSERT_ADHESION NUMGAR :'||P_ADHESION.NUMGAR);
  P_INS_journal(1,' F_INSERT_ADHESION NUMFOR :'||P_ADHESION.NUMFOR);
  P_INS_journal(1,' F_INSERT_ADHESION IDCOUVERTURE :'||P_ADHESION.IDCOUVERTURE);
  P_INS_journal(1,' F_INSERT_ADHESION RANG :'||P_ADHESION.RANG);
  P_INS_journal(1,' F_INSERT_ADHESION ETAT :'||P_ADHESION.ETAT);
  P_INS_journal(1,' F_INSERT_ADHESION FLAG_REGIME :'||P_ADHESION.FLAG_REGIME);
  P_INS_journal(1,' F_INSERT_ADHESION TYPFOR :'||P_ADHESION.TYPFOR);
  P_INS_journal(1,' F_INSERT_ADHESION NUMORG :'||P_ADHESION.NUMORG);
  P_INS_journal(1,' F_INSERT_ADHESION DIS_CARENCE :'||P_ADHESION.DIS_CARENCE);
  P_INS_journal(1,' F_INSERT_ADHESION DIS_FRANCHISE :'||P_ADHESION.DIS_FRANCHISE);
  */
  INSERT INTO ADHESION VALUES P_ADHESION;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_INSERT_ADHESION;

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

BEGIN
  INSERT INTO PORTE_REMISE VALUES P_porte_remise;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_INS_PORTE_REMISE;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FIND_NUMGAR                                             */
/* Type         :  Public                                                    */
/* Description  :  fonction de recherche du contrat à partir du code adhérent*/
/* Retour       :  numgar=>OK, 0=>KO                                         */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_NUMGAR( P_CODADH IN     AFFIL_PORTE.ENTREPRISE%TYPE
                      , P_NUMCLI IN OUT CONTRAT.NUMCLI%TYPE
                      , P_dateff    OUT CONTRAT.DATEFF%TYPE)
RETURN CONTRAT.NUMGAR%TYPE
IS

  loc_numgar     ADHE_CNTRT.NUMGAR%TYPE:=0;

BEGIN


 -- IF NVL(P_NUMCLI,0) = 0 THEN
    BEGIN
      SELECT DISTINCT c.numgar, c.numcli, c.dateff
        INTO loc_numgar, P_NUMCLI, P_dateff
        FROM CONTRAT c
       WHERE c.numcli IN (SELECT i.numindiv FROM individu i WHERE i.refcie=P_CODADH AND i.type=2)
         AND c.numcli= NVL(P_NUMCLI,c.numcli)
         AND c.numprod=1; --produit régime unique
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN -4;
      WHEN OTHERS THEN
        RETURN -1;
    END;
 /* ELSE
    BEGIN
      SELECT DISTINCT c.numgar, c.numcli
        INTO loc_numgar, P_NUMCLI
        FROM CONTRAT c
       WHERE c.numcli IN (SELECT i.numindiv FROM individu i WHERE i.refcie=P_CODADH AND i.type=2)
         AND c.numcli=P_NUMCLI
         AND F_FIND_CONTRAT_RU(c.numgar)> 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN -4;
      WHEN OTHERS THEN
        RETURN -2;
    END;
  END IF;*/

  RETURN NVL(loc_numgar,0);

EXCEPTION
  WHEN OTHERS THEN
    RETURN -3;
END F_FIND_NUMGAR;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FIND_CONTRAT                                            */
/* Type         :  Public                                                    */
/* Description  :  fonction de recherche du contrat                          */
/* Retour       :  numgar=>OK, 0=>KO                                         */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_CONTRAT( P_AFFIL_FICHER       IN  AFFIL_FICHIER%ROWTYPE
                       , P_REF_ORGN_CNTRT     IN  AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT%TYPE
                       , P_CODE_POP           IN  AFFIL_PORTE_ADH.CODE_POP%TYPE)
RETURN CONTRAT.NUMGAR%TYPE
IS

  loc_numgar     CONTRAT.NUMGAR%TYPE:=0;
  loc_numgar2    CONTRAT.NUMGAR%TYPE:=0;


BEGIN
  --référence de contrat identique
  SELECT DISTINCT c.numgar
    INTO loc_numgar
    FROM CONTRAT_REF c , porte_contrat p
   WHERE PK_HISTO_CONTRAT.F_SEL_ETAT(c.numgar, P_AFFIL_FICHER.datefic)=1 -- contrat en vigueur
     AND ( UPPER(TRIM(c.COLLEGE))= UPPER(TRIM(P_CODE_POP))
       OR f_get_transco('DSN', 'COLLEGE',P_CODE_POP,2)= UPPER(TRIM(c.COLLEGE)) )
     AND UPPER(TRIM(c.REFCIE)) = UPPER(TRIM(P_REF_ORGN_CNTRT))
     AND c.NUMCLI=P_AFFIL_FICHER.NUMCLI
     AND p.numgar = c.numgar
     AND p.numporte =P_AFFIL_FICHER.numporte;

  RETURN loc_numgar;

EXCEPTION
  WHEN TOO_MANY_ROWS THEN  -- Doublons de contrat trouvés
    RETURN -1;
  WHEN NO_DATA_FOUND THEN  -- Aucun contrat trouvé

    BEGIN
      SELECT DISTINCT c.numgar
        INTO loc_numgar
        FROM CONTRAT_REF c , porte_contrat p
       WHERE PK_HISTO_CONTRAT.F_SEL_ETAT(c.numgar, P_AFFIL_FICHER.datefic)=1 -- contrat en vigueur
         AND ( UPPER(TRIM(c.COLLEGE))= UPPER(TRIM(P_CODE_POP))
           OR f_get_transco('DSN', 'COLLEGE',P_CODE_POP,2)= UPPER(TRIM(c.COLLEGE)) )
         AND UPPER(TRIM(c.REFCIE)) LIKE UPPER(TRIM('%'||P_REF_ORGN_CNTRT||'%'))
         AND c.NUMCLI=P_AFFIL_FICHER.NUMCLI
         AND p.numgar = c.numgar
         AND p.numporte =P_AFFIL_FICHER.numporte;
         RETURN loc_numgar;
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN  -- Doublons de contrat trouvés
         RETURN -1;
       WHEN NO_DATA_FOUND THEN
         -- on controle que l'on trouve bien la référence contrat sur d'autre code population
         BEGIN
           SELECT DISTINCT c.numgar
             INTO loc_numgar2
             FROM CONTRAT_REF c , porte_contrat p
           WHERE PK_HISTO_CONTRAT.F_SEL_ETAT(c.numgar, P_AFFIL_FICHER.datefic)=1 -- contrat en vigueur
             AND ( UPPER(TRIM(c.REFCIE)) LIKE UPPER(TRIM('%'||P_REF_ORGN_CNTRT||'%'))
                  OR  TRIM(P_CODE_POP) IS NULL )
             AND c.NUMCLI=P_AFFIL_FICHER.NUMCLI
             AND p.numgar = c.numgar
             AND p.numporte =P_AFFIL_FICHER.numporte;
           RETURN -2;  -- Code population erronée
         EXCEPTION
           WHEN TOO_MANY_ROWS THEN 
             RETURN -2; -- Code population erronée
           WHEN NO_DATA_FOUND THEN
             --cas particulier des contrats nécessitants un traitement manuel
             BEGIN
               SELECT DISTINCT c.numgar
               INTO loc_numgar2
               FROM CONTRAT_REF c , porte_contrat p
               WHERE PK_HISTO_CONTRAT.F_SEL_ETAT(c.numgar, P_AFFIL_FICHER.datefic)=1 -- contrat en vigueur
               AND UPPER(TRIM(replace(c.REFCIE,'|',''))) LIKE UPPER(TRIM('%'||P_REF_ORGN_CNTRT||'%'))
               AND c.NUMCLI=P_AFFIL_FICHER.NUMCLI
               AND p.numgar = c.numgar
               AND p.numporte =P_AFFIL_FICHER.numporte;         

               RETURN -3;--125
             EXCEPTION
             WHEN TOO_MANY_ROWS THEN -- PBO M00006963
               RETURN -3;-- 125
             WHEN NO_DATA_FOUND THEN
               RETURN 0;  --Numéro de contrat introuvable
             END;
           WHEN OTHERS THEN         -- Erreur indéteminée
             RETURN NULL;
         END;
       WHEN OTHERS THEN         -- Erreur indéteminée
         RETURN NULL;
    END;
  WHEN OTHERS THEN         -- Erreur indéteminée
    RETURN NULL;
END F_FIND_CONTRAT;

FUNCTION F_GEST_CONTRAT (P_AFFIL_FICHIER       IN  AFFIL_FICHIER%ROWTYPE
                       , P_REF_EXT_CNTRT     IN  AFFIL_PORTE_CNTRT.REF_EXT_CNTRT%TYPE
                       , P_CODE_POP          IN  AFFIL_PORTE_ADH.CODE_POP%TYPE
                       , P_NUMGAR            IN OUT  AFFIL_PORTE_ADH.NUMGAR%TYPE) RETURN NUMBER IS
  loc_ano NUMBER;
BEGIN
  loc_ano:=0;
  --Traitement des erreurs d'identification contrat
  IF TRIM(P_NUMGAR) IS NULL THEN
    loc_ano:=62;  -- Erreur indéterminée sur la recherche contrat
  ELSIF  TRIM(P_NUMGAR)=0 THEN
    loc_ano:=6;   -- Numéro de contrat introuvable
    P_NUMGAR:=NULL;
  ELSIF  TRIM(P_NUMGAR)=-1 THEN
    loc_ano:=61;  -- Numéro de contrat trouvé en doublons
    P_NUMGAR:=NULL;
  ELSIF  TRIM(P_NUMGAR)=-2 THEN
    loc_ano := 124;  -- Code population erroné
    P_NUMGAR:=NULL;
  ELSIF  TRIM(P_NUMGAR)=-3 THEN
    loc_ano := 125;  -- contrat à traiter manuellement
    P_NUMGAR:=NULL;

  END IF;

  --Déclenchement des anomalies contrats
  IF P_NUMGAR IS NULL THEN

    INSERT INTO AFFIL_ANO (numremise, numporte, numligne,numano,datano,etatano)
    SELECT p.numremise, p.numporte ,p.numligne,loc_ano,sysdate,3
    FROM affil_porte_adh adh, affil_porte p
    WHERE p.numremise = P_AFFIL_FICHIER.numremise
    AND p.numporte = P_AFFIL_FICHIER.numporte
    AND p.numremise = adh.numremise
    AND p.numporte = adh.numporte
    AND p.numligne = adh.numligne
    AND adh.numayd = 0
    AND p.etabli = P_AFFIL_FICHIER.etabli
    AND p.entreprise = P_AFFIL_FICHIER.entreprise
    AND p.num_ordre = P_AFFIL_FICHIER.num_ordre
    AND adh.numgar IS NULL
    AND adh.ref_ext_cntrt =P_REF_EXT_CNTRT
    AND NVL(adh.code_pop,0) = NVl(P_CODE_POP,0)
    AND NOT EXISTS (
      SELECT numano FROM  AFFIL_ANO
      WHERE numremise = P_AFFIL_FICHIER.numremise
      AND numporte = P_AFFIL_FICHIER.numporte
      AND numligne = adh.numligne
      AND numano = loc_ano);

  END IF;
  RETURN   loc_ano;
END F_GEST_CONTRAT;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FIND_NUMGAR_OUVERT                                       */
/* Type         :  Public                                                    */
/* Description  :  fonction de recherche du contrat hors régime obligatoire  */
/* Retour       :  numgar=>OK, 0=>KO                                         */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_NUMGAR_OUVERT( P_NUMADHE  IN  AFFIL_PORTE.NUMINDIV%TYPE
                             , P_TYPE_MVT IN  AFFIL_PORTE.TYPE_MVT%TYPE
                             , P_NUMCLI   IN  NUMBER
                             , P_NUMGAR   IN  AFFIL_PORTE_ADH.NUMGAR%TYPE
                             , p_DATE     IN DATE
                             , P_NUMFOR   IN  AFFIL_PORTE_ADH.REFGARANTIE%TYPE)
RETURN NUMBER
IS

  loc_deja_ouvert     NUMBER:=0;
  loc_typgar          FORMULE.TYPGAR%TYPE;

BEGIN


  IF P_TYPE_MVT = 1 THEN

    BEGIN
        -- contrôle sur les multiples garanties (unique contrat) doit s’appliquer pour les garanties de base et optionnelle       
      SELECT DISTINCT 109 -- code rejet affiliation externe (mnemo AFFILANO)
        INTO loc_deja_ouvert
      FROM 
      (-- garantie soins de santé base
        SELECT 1
        FROM ADHE_CNTRT a , CONTRAT c ,adhesion adh, formule f, formule f2
      WHERE a.NUMADHE = P_NUMADHE
        AND a.numgar= c.numgar
        --06/10/2021 suite au retour de Catherine, suppression du filtre sur le client
        AND c.TYPEQUIT=1   --échéancier contrat
        AND c.numgar <>   P_NUMGAR
        AND adh.idadhesion = a.idadhesion
        AND adh.numindiv = a.numadhe
        AND p_DATE BETWEEN adh.datapli AND NVL(adh.datper, p_DATE)
        AND (adh.datper IS NULL OR adh.datper <> adh.datapli) --06/10/2021 suite au retour de Catherine, exclusion des garanties ouvertes et fermées le même jour 
        AND adh.typfor = 1 -- garantie soins de santé
        AND adh.rang = 1
        AND f.numfor =   pk_qttc.f_sel_numfor(adh.NUMGAR, adh.NUMFOR)
        AND f2.numfor =  pk_qttc.f_sel_numfor(P_NUMGAR, P_NUMFOR) --06/10/2021 suite au retour de Catherine, filtre sur les contrats OPTION OBLIGATOIRE
        AND f.typgar = 1 --BASE uniquement
        AND f2.typgar = 1 --BASE uniquement
      -- union Garantie prévoyance
      UNION
      SELECT 1
        FROM ADHE_CNTRT a , CONTRAT c ,adhesion adh, garanties g
      WHERE a.NUMADHE = P_NUMADHE
        AND a.numgar= c.numgar
        --06/10/2021 suite au retour de Catherine, suppression du filtre sur le client
        AND c.TYPEQUIT=1   --échéancier contrat
        AND c.numgar <>   P_NUMGAR
        AND adh.idadhesion = a.idadhesion
        AND adh.numindiv = a.numadhe
        AND p_DATE BETWEEN adh.datapli AND NVL(adh.datper, p_DATE)
        AND (adh.datper IS NULL OR adh.datper <> adh.datapli) --06/10/2021 suite au retour de Catherine,exclusion des garanties ouvertes et fermées le même jour 
        AND adh.typfor = 2 -- Garantie prévoyance
        AND g.numfor =  pk_qttc.f_sel_numfor(P_NUMGAR, P_NUMFOR)
      )
      ;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       loc_deja_ouvert := 0;
     WHEN OTHERS THEN
       P_INS_journal(3 ,'F_FIND_NUMGAR_OUVERT 1 '||SUBSTR(SQLERRM,1,132));
       loc_deja_ouvert := 0;

    END;

    IF loc_deja_ouvert <> 0 THEN
      RETURN loc_deja_ouvert;
    END IF;

    -- Contrôle s'il existe:
            -- une adhésion type santé sur le contrat
            -- pour un mm adhérent principal
            -- garantie de mm type sur un mm contrat
    BEGIN
      SELECT DISTINCT 126 -- code rejet Type de garantie déjà présent sur le contrat (mnemo AFFILANO)
        INTO loc_deja_ouvert
      FROM adhesion adh
             INNER JOIN formule f  ON f.numfor = adh.numfor
             INNER JOIN formule f2 ON f2.numfor = P_NUMFOR
      WHERE 1 = 1
        AND f.typgar     = f2.typgar  -- type garantie identique (2 bases ou 2 options)
        AND adh.numindiv = P_NUMADHE
        AND adh.numgar   = P_NUMGAR
        AND adh.typfor   = 1          -- santé
        AND adh.numfor  <> P_NUMFOR   -- nouvelle garantie
        AND p_DATE BETWEEN adh.datapli AND NVL(adh.datper, p_DATE) -- couverture valide
        AND (adh.datper IS NULL OR adh.datper <> adh.datapli); -- exclusion des adhésions ouvertes puis fermées le même jour
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        loc_deja_ouvert := 0;
      WHEN OTHERS THEN
        P_INS_journal(3 ,'F_FIND_NUMGAR_OUVERT 2 '||SUBSTR(SQLERRM,1,132));
        loc_deja_ouvert := 0;
    END;

    IF loc_deja_ouvert <> 0 THEN
      RETURN loc_deja_ouvert;
    END IF;

  END IF; -- Fin si P_TYPE_MVT = 1

  RETURN loc_deja_ouvert;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_FIND_NUMGAR_OUVERT;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FIND_CONTRAT_NORU                                       */
/* Type         :  Public                                                    */
/* Description  :  fonction de recherche du contrat hors régime obligatoire  */
/* Retour       :  numgar=>OK, 0=>KO                                         */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_CONTRAT_NORU( P_NUMGAR IN  AFFIL_PORTE.NUMGAR%TYPE)
RETURN CONTRAT_REF.NUMPROD%TYPE
IS

  loc_numprod     CONTRAT_REF.NUMPROD%TYPE:=0;

BEGIN


  SELECT DISTINCT c.numprod
    INTO loc_numprod
    FROM CONTRAT_REF c
   WHERE c.numgar=P_NUMGAR
     AND c.numprod<>1; -- produit hors régime obligatoire

  RETURN loc_numprod;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_FIND_CONTRAT_NORU;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CPT_ETAT_REMISE_AFFIL                                   */
/* Type         :  Privee                                                    */
/* Description  :  Controle l etat d une affiliation                         */
/* Entree       :  a_numporte                                                */
/*                 a_numremise,                                              */
/*                 a_etat     ,                                              */
/* Retour       :  loc_nombre                                                */
/*---------------------------------------------------------------------------*/
FUNCTION F_CPT_ETAT_REMISE_AFFIL ( a_numporte    IN   NUMBER
                                 , a_numremise   IN   NUMBER
                                 , a_etat        IN   NUMBER)
RETURN NUMBER
AS
   loc_nombre   NUMBER;
BEGIN
   BEGIN
      SELECT COUNT (*)
        INTO loc_nombre
        FROM AFFIL_PORTE
       WHERE AFFIL_PORTE.numporte = a_numporte
         AND AFFIL_PORTE.numremise = a_numremise
         AND AFFIL_PORTE.etat = a_etat;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_nombre := 0;
   END;

   RETURN loc_nombre;
END F_CPT_ETAT_REMISE_AFFIL;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_INSERT_AFFIL_TRACE                                      */
/* Type         :  Public                                                    */
/* Description  :  fonction de insertion dans AFFIL_TRACE                    */
/* Retour       :  TRUE=>OK, FALSE=>KO                                       */
/*---------------------------------------------------------------------------*/
FUNCTION F_INSERT_AFFIL_TRACE( P_AFFIL_TRACE IN AFFIL_TRACE%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO AFFIL_TRACE VALUES P_AFFIL_TRACE;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_INSERT_AFFIL_TRACE;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_RG                                                 */
/* Type         :  Public                                                    */
/* Description  :  fonction de insertion dans AFFIL_TRACE                    */
/* Retour       :  TRUE=>OK, FALSE=>KO                                       */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_RG(I_mnemo IN LIBELLE_BIS.MNEMO%TYPE
                  ,I_RG    IN LIBELLE_BIS.CODE%TYPE)
RETURN NUMBER
IS
BEGIN

  null;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_CTRL_RG;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_GET_REG_AFFIL                                           */
/* Type         :  Public                                                    */
/* Description  :  fonction de recheche des règles de gestion de la DSN      */
/* Retour       :  Tableau contenant les règles de gestion de la DSN         */
/*---------------------------------------------------------------------------*/
FUNCTION F_GET_REG_AFFIL(I_numporte IN PORTE_PARAM.NUMPORTE%TYPE)
RETURN T_RG_TAB
IS

  loc_Tab_RG  PK_CTRL_AFFIL.T_RG_TAB;

  CURSOR C_RG_AFFIL(I_numporte IN PORTE_PARAM.NUMPORTE%TYPE)
      IS
  SELECT l.CODE, l.LIBELLE
    FROM LIBELLE_BIS l
   WHERE l.MNEMO = 'RG_AFFIL'||TO_CHAR(I_numporte)
     AND l.CODE <> '-2';

BEGIN

  FOR R_RG_AFFIL IN C_RG_AFFIL(I_numporte) LOOP
   -- dbms_output.put_line( '(R_RG_AFFIL.CODE :'||R_RG_AFFIL.CODE);
    loc_Tab_RG(R_RG_AFFIL.CODE):=R_RG_AFFIL.LIBELLE;

  END LOOP;

  RETURN loc_Tab_RG;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line( '(error.CODE :'||sqlerrm);
    RETURN loc_Tab_RG;
END F_GET_REG_AFFIL;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  V2D                                                       */
/* Type         :                                                            */
/* Description  :                                                            */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION V2D (a_edate    in   VARCHAR2)
RETURN DATE
IS

BEGIN
  RETURN( TO_DATE(a_edate, 'ddmmyyyy') );
END V2D;

--**********************************************************************************************************************************************


/*******************************************************************************
FONCTIONS D'INSERTION DES DONNEES DANS LA TABLE AFFIL_FICHIER
***************************************************************************** */
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                 */
/* Nom          :  F_INS_AFFIL_FICHIER                                         */
/* Type         :  Public                                                    */
/* Description  :  fonction d'insertion dans AFFIL_FICHIER                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_FICHIER(P_AFFIL_FICHIER      AFFIL_FICHIER%ROWTYPE ,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN

/* INSERT INTO AFFIL_FICHIER VALUES P_AFFIL_FICHIER ; */

P_INS_journal(3, p_journal,'RKO avant insert CODENVOIDSN:' || P_AFFIL_FICHIER.CODENVOIDSN ||'-'||P_AFFIL_FICHIER.CODENVOIDSN );

  INSERT INTO AFFIL_FICHIER
                          (
                           FICHIER,
                           ENTREPRISE,
                           TRIMESTRE,
                           ANNEE,
                           NUMREMISE,
                           MOIS,
                           DEVISE,
                           ETABLI,
                           NUMCLI,
                           NUMPORTE,
                           DATEFIC,
                           NATURE,
                           NORME,
                           TYPE,
                           NUM_ORDRE,
                           NUM_ANNUL,
                           NUM_ANNULANTE,
                           NOM_CONTACT,
                           MAIL_CONTACT ,
                           IDENVOI,-- RKO DSN_CRM lot1
                           MODEPOT,
                           DATDEPOT,
                           NOMDECLARANT,
                           PRENOMDECLARANT,
                           SIRETDECLARANT,
                           IDDECLARDSN,
                           SIRENEMETT,
                           NICEMETT,
                           NOMEMETT,
                           TYPENVOIDSN,
                           CODENVOIDSN,
                           FRACTIONDECLA,
                           PTDEPOT,
                           IDMETIERDSN,
                           CHAMDECDSN,
                           NATEVENDSN,  
                           DATEMOISDEC,
                           DATECONSTITUTION,
                           NUM_ORDRE_INI
                           -- fin RKO DSN_CRM lot1

                          ) SELECT P_AFFIL_FICHIER.FICHIER,
                                   P_AFFIL_FICHIER.ENTREPRISE,
                                   P_AFFIL_FICHIER.TRIMESTRE,
                                   P_AFFIL_FICHIER.ANNEE,
                                   P_AFFIL_FICHIER.NUMREMISE,
                                   P_AFFIL_FICHIER.MOIS,
                                   P_AFFIL_FICHIER.DEVISE,
                                   P_AFFIL_FICHIER.ETABLI,
                                   P_AFFIL_FICHIER.NUMCLI,
                                   P_AFFIL_FICHIER.NUMPORTE,
                                   P_AFFIL_FICHIER.DATEFIC,
                                   P_AFFIL_FICHIER.NATURE,
                                   P_AFFIL_FICHIER.NORME,
                                   P_AFFIL_FICHIER.TYPE,
                                   P_AFFIL_FICHIER.NUM_ORDRE,
                                   P_AFFIL_FICHIER.NUM_ANNUL,
                                   P_AFFIL_FICHIER.NUM_ANNULANTE,
                                   P_AFFIL_FICHIER.NOM_CONTACT,
                                   P_AFFIL_FICHIER.MAIL_CONTACT,
                                   P_AFFIL_FICHIER.IDENVOI,
                                   P_AFFIL_FICHIER.MODEPOT,
                                   P_AFFIL_FICHIER.DATDEPOT,
                                   P_AFFIL_FICHIER.NOMDECLARANT,
                                   P_AFFIL_FICHIER.PRENOMDECLARANT,
                                   P_AFFIL_FICHIER.SIRETDECLARANT,
                                   P_AFFIL_FICHIER.IDDECLARDSN,
                                   P_AFFIL_FICHIER.SIRENEMETT,
                                   P_AFFIL_FICHIER.NICEMETT,
                                   P_AFFIL_FICHIER.NOMEMETT,
                                   P_AFFIL_FICHIER.TYPENVOIDSN,
                                   P_AFFIL_FICHIER.CODENVOIDSN,
                                   P_AFFIL_FICHIER.FRACTIONDECLA,
                                   P_AFFIL_FICHIER.PTDEPOT,
                                   P_AFFIL_FICHIER.IDMETIERDSN,
                                   P_AFFIL_FICHIER.CHAMDECDSN,
                                   P_AFFIL_FICHIER.NATEVENDSN,
                                   P_AFFIL_FICHIER.DATEMOISDEC, 
                                   P_AFFIL_FICHIER.DATECONSTITUTION,
                                   P_AFFIL_FICHIER.NUM_ORDRE_INI
                            FROM   DUAL
             WHERE NOT EXISTS( SELECT 1 FROM AFFIL_FICHIER a
                                       WHERE NVL(a.FICHIER,'-1')      = NVL(P_AFFIL_FICHIER.FICHIER,'-1')
                                         AND NVL(a.ENTREPRISE,'-1')   = NVL(P_AFFIL_FICHIER.ENTREPRISE,'-1')
                                         AND NVL(a.TRIMESTRE,'-1')    = NVL(P_AFFIL_FICHIER.TRIMESTRE,'-1')
                                         AND NVL(a.ANNEE,'-1')        = NVL(P_AFFIL_FICHIER.ANNEE,'-1')
                                         AND NVL(a.NUMREMISE,-1)      = NVL(P_AFFIL_FICHIER.NUMREMISE,-1)
                                         AND NVL(a.MOIS,'-1')         = NVL(P_AFFIL_FICHIER.MOIS,'-1')
                                         AND NVL(a.DEVISE,'-1')       = NVL(P_AFFIL_FICHIER.DEVISE,'-1')
                                         AND NVL(a.ETABLI,'-1')       = NVL(P_AFFIL_FICHIER.ETABLI,'-1')
                                         AND NVL(a.NUMCLI,-1)         = NVL(P_AFFIL_FICHIER.NUMCLI,-1)
                                         AND NVL(a.NUMPORTE,-1)       = NVL(P_AFFIL_FICHIER.NUMPORTE,-1)
                                         AND NVL(a.DATEFIC,SYSDATE+1) = NVL(P_AFFIL_FICHIER.DATEFIC,SYSDATE+1)
                                         AND NVL(a.NATURE,-1)         = NVL(P_AFFIL_FICHIER.NATURE,-1)
                                         AND NVL(a.NORME,'-1')        = NVL(P_AFFIL_FICHIER.NORME,'-1')
                                         AND NVL(a.TYPE,-1)           = NVL(P_AFFIL_FICHIER.TYPE,-1)
                                         AND NVL(a.NUM_ORDRE,-1)      = NVL(P_AFFIL_FICHIER.NUM_ORDRE,-1)
                                         AND NVL(a.NUM_ANNUL,'-1')    = NVL(P_AFFIL_FICHIER.NUM_ANNUL,'-1')
                                         AND NVL(a.NUM_ANNULANTE,-1)  = NVL(P_AFFIL_FICHIER.NUM_ANNULANTE,-1)
                             );


  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible fichier n° :' || P_AFFIL_FICHIER.entreprise ||'-'||P_AFFIL_FICHIER.etabli ||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_FICHIER;



/*******************************************************************************
FONCTIONS D'INSERTION DES DONNEES DANS LE TABLE AFFIL_PORTE8...
***************************************************************************** */

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE                                         */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans AFFIL_PORTE                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_2(P_AFFIL_PORTE      AFFIL_PORTE%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN
  INSERT INTO AFFIL_PORTE VALUES P_AFFIL_PORTE;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_INS_AFFIL_PORTE_2;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_AFFIL_PORTE_ADH                                     */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans AFFIL_PORTE_ADH                 */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_ADH(P_AFFIL_PORTE_ADH      AFFIL_PORTE_ADH%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN
  INSERT INTO AFFIL_PORTE_ADH VALUES P_AFFIL_PORTE_ADH;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
   P_INS_journal(1, p_journal,'Enregistrement impossible adhésion sal n° :' || P_AFFIL_PORTE_ADH.numligne ||'-'||P_AFFIL_PORTE_ADH.ref_ext_cntrt ||', Err : ' || SQLERRM);
   RETURN FALSE;
END F_INS_AFFIL_PORTE_ADH;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_AFFIL_PORTE_AYD                                     */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans AFFIL_PORTE_AYD                 */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_AYD(P_AFFIL_PORTE_AYD      AFFIL_PORTE_AYD%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN
  INSERT INTO AFFIL_PORTE_AYD VALUES P_AFFIL_PORTE_AYD;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible ayd sal n° :' || P_AFFIL_PORTE_AYD.numligne ||'- ayd n°'||P_AFFIL_PORTE_AYD.numayd ||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_AYD;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                 */
/* Nom          :  F_INS_AFFIL_PORTE_CNTRT                                         */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans AFFIL_PORTE_CNTRT                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_AFFIL_PORTE_CNTRT(P_AFFIL_PORTE_CNTRT      AFFIL_PORTE_CNTRT%ROWTYPE,p_journal IN OUT JOURNAL_ADM%ROWTYPE)
RETURN BOOLEAN
IS

BEGIN
  INSERT INTO AFFIL_PORTE_CNTRT VALUES P_AFFIL_PORTE_CNTRT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1, p_journal,'Enregistrement impossible contrat  :' || P_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT||' | '|| P_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT ||'- sté n°'||P_AFFIL_PORTE_CNTRT.ENTREPRISE||'-'||P_AFFIL_PORTE_CNTRT.ETABLI ||', Err : ' || SQLERRM);
    RETURN FALSE;
END F_INS_AFFIL_PORTE_CNTRT;


/*******************************************************************************
FONCTIONS DE CONTROLE DU FORMAT DES DONNEES DU FICHIER DSN
***************************************************************************** */

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_NUMBER_VARCHAR                                     */
/* Type         :  Public                                                    */
/* Description  :  Fonction qui verifie si chaine est un nombre  et retourne */
/*                 un varchar spécifique à la DSN                            */
/*                                                                           */
/* Retour       :   0 si erreur ; va                                         */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_NUMBER_VARCHAR(
      i_chaine IN VARCHAR2, -- ex = i_chaine = S21.G00.06.001,'999100019'
      i_ligne  IN NUMBER,
      I_entite    IN PORTE_ENTITE%ROWTYPE,
      p_journal IN OUT JOURNAL_ADM%ROWTYPE,
      I_cptligne_fichier IN NUMBER
   )
   RETURN VARCHAR2
IS
   v_chaine VARCHAR2(500);
   nb       NUMBER;
   erreur VARCHAR2(50);
BEGIN

   v_chaine := SUBSTR(i_chaine,17,LENGTH(i_chaine)-17); -- EX : 999100019
   -- On essaie de caster la chaine. Si on peut, on renvoie un to_char de la chaine.
   --                                Sinon, on part en exception et on renvoie 0
   nb := to_number(v_chaine);
   RETURN TO_CHAR(v_chaine);

EXCEPTION
  WHEN OTHERS THEN
     IF i_ligne IS NULL THEN
      erreur:='';
     ELSE erreur:='salarié n°'||(NVL(i_ligne,0)+1);
     END IF;
     P_INS_journal(1,
                   p_journal,
                   'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur,'||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine
                   );

    RETURN TO_CHAR(0);
END F_CTRL_NUMBER_VARCHAR;
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
     ELSE erreur:='Ligne salarié n°'||(NVL(i_ligne,0)+1);
     END IF;
     P_INS_journal(1,p_journal,
                   'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur,'||erreur ||' Donnee : ' || I_entite.donnee || ' chaine : ' || v_chaine);

    RETURN TO_CHAR(0);
END F_CTRL_NUMBER_VARCHAR_AFF;


/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_FORMAT_DATE                                        */
/* Type         :  Public                                                    */
/* Description  :  formate une chaine en DATE                                */
/*                 en entrée une chaine de format DDMMYYYY                   */
/* Retour       :  une chaine si le format est correct sinon null            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_FORMAT_DATE(i_chaine IN VARCHAR2,
                            i_ligne  IN NUMBER,
                            I_entite    IN PORTE_ENTITE%ROWTYPE,
                            p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                            I_cptligne_fichier IN NUMBER)
RETURN VARCHAR2
IS
   excep_invalid_format EXCEPTION;
   v_test               VARCHAR2(20);
   v_chaine             VARCHAR2(500);
   erreur VARCHAR2(50);
BEGIN

   v_chaine := SUBSTR(i_chaine,17,LENGTH(i_chaine)-17); -- EX : 01092013

  IF i_ligne IS NULL THEN
      erreur:='';
   ELSE erreur:='salarié n°'||(NVL(i_ligne,0)+1);
   END IF;
   -- VERIFICATION QUE LA CHAINE FAIT BIEN 8 SINON LE TO_DATE AJOUTE UN O
   IF LENGTH(v_chaine) <> I_entite.taille THEN
      RAISE excep_invalid_format;
   END IF;

   BEGIN
      -- CONVERSION DE LA CHAINE DE CARACTERE EXTRAITE EN DATE
      SELECT d2e(TO_DATE(v_chaine,'DDMMYYYY'))
      INTO v_test
      FROM DUAL
      WHERE REGEXP_LIKE (v_chaine,'^[0-9]'); -- ex : vtest = 01/09/2013 00:00:00
   EXCEPTION
   WHEN OTHERS THEN
     P_INS_journal(1, p_journal,  'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur, '||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine );
     RETURN NULL;
   END;
   RETURN v_test; -- CONVERTI UNE CHAINE DE CARACTERE EN DATE AU FORMAT DD/MM/YYYY
EXCEPTION
  WHEN excep_invalid_format THEN
     P_INS_journal(1, p_journal, 'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' format en erreur,'||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine);
     RETURN NULL;
  WHEN OTHERS THEN
     P_INS_journal(1, p_journal, 'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur, '||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine ||'-' || SQLERRM);
     RETURN NULL;
END F_CTRL_FORMAT_DATE;


/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FORMAT_DATE_HH_MIN_SS                                   */
/* Type         :  Public                                                    */
/* Description  :  formate une chaine en DATE                                */
/*                 en entrée une chaine de format YYYYMMDDHHMINSS            */
/* Retour       :  une DATE si le format est correct sinon null            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FORMAT_DATE_HH_MIN_SS(i_chaine IN VARCHAR2,
                            i_ligne  IN NUMBER,
                            I_entite    IN PORTE_ENTITE%ROWTYPE,
                            p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                            I_cptligne_fichier IN NUMBER)
RETURN DATE
IS
   excep_invalid_format EXCEPTION;
   v_test               DATE;
   v_chaine             VARCHAR2(500);
   erreur VARCHAR2(50);
BEGIN

   v_chaine := SUBSTR(i_chaine,17,LENGTH(i_chaine)-17); -- EX : 20201707200115

  IF i_ligne IS NULL THEN
      erreur:='';
   ELSE erreur:='salarié n°'||(NVL(i_ligne,0)+1);
   END IF;
   -- VERIFICATION QUE LA CHAINE FAIT BIEN 14 
   IF LENGTH(v_chaine) <> I_entite.taille THEN
      RAISE excep_invalid_format;
   END IF;

   BEGIN
      -- CONVERSION DE LA CHAINE DE CARACTERE EXTRAITE EN DATE 
      SELECT to_date(v_chaine,'YYYYMMDDHH24MISS') 
      INTO v_test
      FROM DUAL
      WHERE REGEXP_LIKE (v_chaine,'^[0-9]'); -- ex : vtest = 17/07/20 20:01:15
   EXCEPTION
   WHEN OTHERS THEN
     P_INS_journal(1, p_journal,  'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur, '||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine );
     RETURN NULL;
   END;
   RETURN v_test;
EXCEPTION
  WHEN excep_invalid_format THEN
     P_INS_journal(1, p_journal, 'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' format en erreur,'||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine);
     RETURN NULL;
  WHEN OTHERS THEN
     P_INS_journal(1, p_journal, 'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur, '||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine ||'-' || SQLERRM);
     RETURN NULL;
END F_FORMAT_DATE_HH_MIN_SS;



/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_LONGUEUR_VARCHAR                                   */
/* Type         :  Public                                                    */
/* Description  :  Fonction qui verifie la longueur d'une chaine de caractère*/
/*                                                                           */
/* Retour       :   0 si erreur ; va                                         */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_LONGUEUR_VARCHAR(
      i_chaine           IN VARCHAR2, -- ex = i_chaine = S10.G00.01.009,'Service du Personnel'
      i_ligne            IN NUMBER,
      I_entite           IN PORTE_ENTITE%ROWTYPE,
      p_journal          IN OUT JOURNAL_ADM%ROWTYPE,
      I_cptligne_fichier IN NUMBER)
   RETURN VARCHAR2
IS
   v_chaine             VARCHAR2(500);
   excep_invalid_format EXCEPTION;
   erreur VARCHAR2(50);
BEGIN
   v_chaine            := F_FORMAT2(SUBSTR(i_chaine,17,LENGTH(i_chaine)-17)); -- EX : 'Service du Personnel'
   IF i_ligne IS NULL THEN
      erreur:='';
   ELSE erreur:='salarié n°'||(NVL(i_ligne,0));
   END IF;

   IF LENGTH(v_chaine) <= I_entite.taille THEN
      IF I_entite.donnee like '%MAIL%' THEN
        RETURN v_chaine;
      ELSE
        RETURN UPPER(v_chaine);
      END IF;
   ELSE
      RAISE excep_invalid_format;
   END IF;

EXCEPTION
WHEN excep_invalid_format THEN
   P_INS_journal(1, p_journal, 'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' format en erreur, '||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine);
   RETURN NULL;
WHEN OTHERS THEN
   P_INS_journal(1, p_journal, 'Lig:'||I_cptligne_fichier ||'-'||I_entite.nom ||' en erreur, '||erreur ||' Balise : ' || I_entite.balise || ' chaine : ' || v_chaine||SQLERRM);
   RETURN NULL;
END F_CTRL_LONGUEUR_VARCHAR;



/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_TAB_TYPE_ENTITE                                        */
/* Type         :  Public                                                    */
/* Description  :  renvoie un tableau de porte_entite                        */
/*---------------------------------------------------------------------------*/
FUNCTION F_TAB_TYPE_ENTITE(i_idechange    IN  PORTE_ECHANGE.IDECHANGE%TYPE,i_numporte PORTE_ECHANGE.NUMPORTE%TYPE, i_entite    IN  PORTE_ENTITE.ENTITE%TYPE)
RETURN tab_PORTE_ENTITE IS

  CURSOR C_entite(p_echange PORTE_ENTITE.IDECHANGE%TYPE,p_numporte PORTE_ECHANGE.NUMPORTE%TYPE, p_entite PORTE_ENTITE.ENTITE%TYPE) IS
  SELECT e.*
  FROM PORTE_ENTITE e, PORTE_ECHANGE c
  WHERE c.idechange = p_echange
  AND c.idechange =e.idechange
  AND e.entite = p_entite
  AND c.numporte = p_numporte;

  l_tab_entite tab_PORTE_ENTITE;

BEGIN
  FOR R_entite IN C_entite(i_idechange,i_numporte,i_entite) LOOP
    l_tab_entite( R_entite.donnee):= R_entite;
  END LOOP;
RETURN l_tab_entite;
END F_TAB_TYPE_ENTITE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Privee                                                    */
/* Description  :  Insertion dans journal_adm                                */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(
      P_niv  IN NUMBER,
      p_journal IN OUT JOURNAL_ADM%ROWTYPE,
      P_msg  IN VARCHAR2,
      p_msg2 IN VARCHAR2 := NULL)
IS
BEGIN

   IF p_journal.niv_msg >= P_niv THEN
      p_journal.idligne := p_journal.idligne +1;
      PK_trace.P_INS_journal_adm ( I_nom_traitement => p_journal.nom_traitement, I_session => p_journal.id_session, I_niv_msg => P_niv, I_msg_adm => SUBSTR(P_msg||' '||P_msg2,1,132), I_idligne => p_journal.idligne);
   END IF;
END P_INS_journal;
--***********************************************************************************************************************************************




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
  G_niv_msg:=3;
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

END PK_CTRL_AFFIL;
/
