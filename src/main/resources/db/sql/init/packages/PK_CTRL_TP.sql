CREATE OR REPLACE PACKAGE ARTHUS.PK_CTRL_TP
AS
/*============================================================================*/
/* PACKAGE      : PK_CTRL_TP.sql                                              */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* Création     : 10/08/2010                                                  */
/* Description  : package de briques fonctionnelless répondant aux besoins de */
/*                flux xml                                                    */
/*============================================================================*/
/* Evolution    : Ajout briques fonctionnelles SPSanté                        */
/* Auteur       : JBO                                                         */
/* Date         : 15/07/2011                                                  */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Evolution    : Gestion du double numéro de sécurité social (P_FIND_ASSURE) */
/* Auteur       : JBO                                                         */
/* Date         : 04/11/2013                                                  */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/* Auteur       : SDA                                                         */
/* Date         : 13/01/2015                                                  */
/* Commentaire  : Mantis 4752 (idahesion dans F_CTRL_rang)                    */
/*============================================================================*/
/* Correction   : ABO 20/03/2015  M4829 base/option dont rubrique acte fermé  */
/*               sur la base                                                  */
/*============================================================================*/
/* Evolution   : JBO 20/07/2015  M4734 Ajout localisation dentaire dans la    */
/*               table SINISTRE_SANTE : Création P_MAJ_SNTR_SANTE_LOCDEN      */
/*============================================================================*/
/* Correction  : PHA 04/09/2015  0004939: SP Santé : réponse anormale du      */
/*               webservice Acte non couvert (teinte non prise en compte)     */
/*============================================================================*/
/* Correction  : PHA 06/01/2016 M0005018 : en comm.: AND a.numadhe = i.numassu*/
/*           Le contrôle sur l'adhérent principal de l'adhésion pour vérifier */
/*           si il est porteur de carte suffit.    P_FIND_CONTRAT_BY_ASSU     */
/*============================================================================*/
/* Correction  : JBO 02/02/2016 M0005047: Refus SP Santé                      */
/*               Dans la procédure P_FIND_CONTRAT_BY_ASSU, vérification dans  */
/*               la table adhesion qu'aucune couverture ne soit fermée        */
/*============================================================================*/
/*Correction  :  PHA 24/03/2016 M0005085: Refus de PEC SP Santé               */
/*               dans P_FIND_CONTRAT_BY_ASSU ajout rang = 1                   */
/*============================================================================*/
/*Correction  :  JBO 04/04/2016 M0005091: PK_CTRL_TP.P_FIND_ASSURE, rajout d  */
/*               un desc dans le tri de la requête afin de récupérer le numéro*/
/*               d'individu le plus grand en cas de doublon                   */
/*============================================================================*/
/* Evolution   : JBO 23/11/2016  P201608003_reseau_soin_GEREP                 */
/*               P_INS_DOSSIER_SANTE :                                        */
/*               NVL(F_SENS_LIBELLE('PORTE',P_numporte),P_numporte);          */
/*============================================================================*/
/* Evolution   : JBO, 14022017, gestion du numutil en fonction du dossier     */
/*               Toutes les procedure d insert ou maj sont impactées(loc_user)*/
/*============================================================================*/
/* Mantis   : SDA, 5288 probleme dans P_FIND_CONTRAT_BY_ASSU sur betwenn      */
/*            datapli et datper                                               */
/*============================================================================*/
/* Mantis   : SDA, 5294 probleme transo flux spsante assure 213167            */
/*============================================================================*/
/* Mantis   : CLI, 5387 ajout des colonnes pdsqls, spe_exe dans les insert    */
/*============================================================================*/
/* Mantis   : PHA 27/02/2018, 5525: Erreur Benef reglement specifique sur     */
/*            adhesion sur Dossier sante Externe  (=>  P_INS_DOSSIER_SANTE)   */
/*============================================================================*/
/* Mantis   : JBO 19/06/2018, M0005652: PK_CTRL_TP.F_CTRL_info_calcul         */
/*            ajout de la jointure : AND defrub.codfrais =calcul.rubrique et  */
/*            mise en commentaire de 4 lignes                                 */
/*============================================================================*/


--
-- Chaine de reconnaissance SCCS
-- %W%   %E%

   -- -- CONSTANTES PUBLIQUE -----------------------------------------------------

  erreur                VARCHAR2(200);
  flag_erreur           BINARY_INTEGER ;
-- -------------------------------------------- Fin des constantes publiques --

   -- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --

   -- -- TYPES PUBLIQUES ---------------------------------------------------------
TYPE T_Indiv IS RECORD (numindiv individu.numindiv%TYPE,
                        nom      individu.nom%TYPE,
                        prenom   individu.prenom%TYPE,
                        datnais  individu.datnais%TYPE,
                        rang     individu.rang%TYPE,
                        matorg   individu.matorg%TYPE,
                        cless    individu.cless%TYPE);

TYPE TAB_T_Indiv IS TABLE OF T_Indiv index by varchar2(10) ;

TYPE TAB_codfrais IS TABLE OF number index by varchar2(10) ;--natfrais.codfrais%TYPE
-- ------------------------------------------------- Fin des types publiques --

   -- -- VARIABLES PUBLIQUES -----------------------------------------------------
CURSOR Fetch_adhe_membre(
  P_idadhesion adhe_cntrt_membre.idadhesion%TYPE,
  P_numindiv   individu.numindiv%TYPE default null
  )
IS
  SELECT i.numindiv,i.qualite, i.nom,i.prenom,i.datnais, i.regime, m.typadr
  FROM  adhe_cntrt_membre m,individu i
  WHERE  m.idadhesion = P_idadhesion
  and m.numindiv = NVL(P_numindiv,i.numindiv)
  and m.numindiv = i.numindiv
 ;

-- Recherche de la garantie santé active rattachée a l adhesion du bénéficiaire du contrat
CURSOR Fetch_garanties_adhe (P_idadhesion adhesion.idadhesion%TYPE,
                             P_numindiv   adhesion.numindiv%TYPE,
                             P_date date default sysdate)
    IS
SELECT f.numfor
  FROM adhesion a
     , frmls f
     , defrub c
 WHERE a.idadhesion = P_idadhesion
   AND a.numindiv = P_numindiv
   AND a.numfor = f.numfor
   AND P_date BETWEEN a.datapli AND nvl(a.datper, P_date)
   AND f.valide = 'O'
   AND c.numfor = a.numfor
   AND c.codfrais like 'H%'
   AND P_date BETWEEN c.datapli AND nvl(c.datper, P_date)
ORDER BY f.typgar,a.datper desc; --ABO 1 obligatoire 2 facultative


-- --------------------------------------------- Fin des variables publiques --

   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------

PROCEDURE P_FIND_CONTRAT (
  P_refContrat IN contrat_ref.refcie%TYPE,
  P_numAdhe IN adhe_cntrt.numadhe%TYPE,
  P_grpporte IN NUMBER,
  O_idadhesion OUT adhe_cntrt.idadhesion%TYPE,
  O_numAdhePrinc OUT adhe_cntrt.numadhe%TYPE,
  O_numgar OUT contrat_ref.numgar%TYPE,
  O_isColl OUT Boolean,
  O_libelle OUT produit.libelle%TYPE,
  O_dateEffet OUT adhe_cntrt.date_adhe%TYPE,
  O_dateRes OUT adhe_cntrt.date_fin_adhe%TYPE,
  O_numorg OUT contrat_ref.numorg%TYPE,
  O_numporte OUT dossier_sante.numporte%TYPE,
  O_found  OUT  NUMBER
  );

PROCEDURE P_FIND_REFCIE (
  P_refContrat IN contrat_ref.refcie%TYPE,
  P_numAdhe IN adhe_cntrt.numadhe%TYPE,
  P_grpporte IN NUMBER,
  O_idadhesion OUT adhe_cntrt.idadhesion%TYPE,
  O_numAdhePrinc OUT adhe_cntrt.numadhe%TYPE,
  O_numgar OUT contrat_ref.numgar%TYPE,
  O_isColl OUT Boolean,
  O_libelle OUT produit.libelle%TYPE,
  O_dateEffet OUT adhe_cntrt.date_adhe%TYPE,
  O_dateRes OUT adhe_cntrt.date_fin_adhe%TYPE,
  O_numorg OUT contrat_ref.numorg%TYPE,
  O_numporte OUT dossier_sante.numporte%TYPE,
  O_found  OUT  NUMBER
  );

PROCEDURE P_FIND_CONTRAT_BY_ASSU (
  P_numPorteurCarte IN adhe_cntrt.numadhe%TYPE,
  P_numAdhe         IN adhe_cntrt.numadhe%TYPE,
  P_grpporte        IN NUMBER,
  O_idadhesion      OUT adhe_cntrt.idadhesion%TYPE,
  O_numgar          OUT contrat_ref.numgar%TYPE,
  O_isColl          OUT BOOLEAN,
  O_libelle         OUT produit.libelle%TYPE,
  O_dateEffet       OUT adhe_cntrt.date_adhe%TYPE,
  O_dateRes         OUT adhe_cntrt.date_fin_adhe%TYPE,
  O_numorg          OUT contrat_ref.numorg%TYPE,
  O_numporte        OUT dossier_sante.numporte%TYPE,
  O_found           OUT NUMBER
);

PROCEDURE P_FIND_ASSURE(
  P_numassu        IN individu.numindiv%TYPE default null,
  P_secu           IN VARCHAR2 default null,
  P_datenais       IN DATE,
  P_rang           IN individu.rang%TYPE default null,
  IO_Tab_indiv     IN OUT TAB_T_Indiv
  )
  ;

FUNCTION F_CUMUL_ACTE(I_codfrais    IN  NATFRAIS.CODFRAIS%TYPE)
RETURN BOOLEAN;

PROCEDURE P_CTRL_ADHESION (
  P_idadhesion IN adhe_cntrt.idadhesion%TYPE,
  P_numgar IN adhe_cntrt.numgar%type,
  P_lstDomaine IN VARCHAR2,
  P_CtrlGar IN BOOLEAN,
  O_etatAdhesion OUT NUMBER,
  O_found  OUT  NUMBER
);

FUNCTION F_CTRL_couverture(
  I_numindiv    IN couverture.numindiv%TYPE,
  I_numtype     IN couverture.numtype%TYPE DEFAULT  1,
  I_flag_regime IN couverture.flag_regime%TYPE DEFAULT 'C',
  I_datsin      IN couverture.datapli%TYPE
  ) RETURN BOOLEAN;

FUNCTION F_CTRL_couverture_NUMFOR(
  I_numindiv    IN couverture.numindiv%TYPE,
  I_numtype     IN couverture.numtype%TYPE DEFAULT  1,
  I_flag_regime IN couverture.flag_regime%TYPE DEFAULT 'C',
  I_datsin      IN couverture.datapli%TYPE
  ) RETURN NUMBER;

FUNCTION F_CTRL_rang(
  I_numindiv    IN couverture.numindiv%TYPE,
  I_idadhesion  IN couverture.idadhesion%TYPE,
  I_numtype     IN couverture.numtype%TYPE DEFAULT  1,
  I_flag_regime IN couverture.flag_regime%TYPE DEFAULT 'C',
  I_datsin      IN couverture.datapli%TYPE
  ) RETURN BOOLEAN;

FUNCTION F_CTRL_CNTRT(
    P_numgar      IN adhe_cntrt.numgar%TYPE,
  P_datsin      IN adhesion.datapli%TYPE
)RETURN NUMBER;

FUNCTION F_CTRL_DOUBLON_PRESTA( P_numindiv   IN  SINISTRE_SANTE.NUMINDIV%TYPE
                              , P_codfrais   IN  SINISTRE_SANTE.CODFRAIS%TYPE
                              , P_datsin     IN  SINISTRE_SANTE.DATSIN%TYPE)
RETURN NUMBER;

FUNCTION F_CTRL_DOUBLON_REMISE( P_ref_ext     IN  PORTE_REMISE.REF_EXT%TYPE
                              , P_dateporte   IN  PORTE_REMISE.DATEPORTE%TYPE)
RETURN NUMBER;

PROCEDURE P_ADR_FORMAT(
  P_numindiv IN individu.numindiv%TYPE,
  O_ligne1 OUT VARCHAR2,
  O_ligne2 OUT VARCHAR2,
  O_ligne3 OUT VARCHAR2,
  O_ligne4 OUT VARCHAR2,
  O_ligne5 OUT VARCHAR2,
  O_cp OUT pers_adresse.codpos%TYPE,
  O_ville OUT pers_adresse.ville%TYPE
  );

FUNCTION F_FIND_CONTACT(
  P_numindiv IN individu.numindiv%TYPE,
  P_nature IN contact.nature%TYPE
) RETURN VARCHAR2;

FUNCTION F_FIND_ASSURE ( P_nom      IN   INDIVIDU.NOM%TYPE DEFAULT NULL
                       , P_prenom   IN   INDIVIDU.PRENOM%TYPE DEFAULT NULL
                       , P_matorg   IN   INDIVIDU.MATORG%TYPE DEFAULT NULL
                       , P_numindiv IN   INDIVIDU.NUMINDIV%TYPE DEFAULT NULL)
RETURN NUMBER;

PROCEDURE P_FIND_TIERS(
  P_NNI IN varchar2,
  P_raison IN varchar2 default null,
  P_typePS IN varchar2 default null,
  P_ad1 In varchar2 default null,
  P_ad2 In varchar2 default null,
  P_ad3 In varchar2 default null,
  P_ad4 In varchar2 default null,
  P_ad5 In varchar2 default null,
  P_cp In varchar2 default null,
  P_ville In varchar2 default null,
  P_tel In varchar2 default null,
  P_mail In varchar2 default null,
  O_numindivPS OUT individu.numindiv%TYPE);
/*
PROCEDURE P_FIND_TIERS2(
  P_NNI        IN VARCHAR2,
  P_nom        IN VARCHAR2 DEFAULT NULL,
  P_Prenom     IN VARCHAR2 DEFAULT NULL,
  P_tel        IN VARCHAR2 DEFAULT NULL,
  P_mail       IN VARCHAR2 DEFAULT NULL,
  O_numindivPS OUT individu.numindiv%TYPE);
*/
PROCEDURE P_NEW_ADRESSE(
  P_numindivPS IN individu.numindiv%TYPE,
  P_ad1 In varchar2 default null,
  P_ad2 In varchar2 default null,
  P_ad3 In varchar2 default null,
  P_ad4 In varchar2 default null,
  P_ad5 In varchar2 default null,
  P_cp In varchar2 default null,
  P_ville In varchar2 default null,
  P_user utilisateurs.numutil%TYPE);

PROCEDURE P_FIND_RIB_PS(
  P_numtiers IN individu.numindiv%TYPE,
  P_intitule IN rib.intitule%TYPE,
  P_banque IN rib.codbque%TYPE,
  P_guichet IN rib.guichet%TYPE,
  P_compte IN rib.compte%TYPE,
  P_clerib IN rib.clerib%TYPE,
  P_bban IN rib.bban%TYPE,
  P_cleban IN rib.clef_iban%TYPE,
  P_bic IN rib.bic%TYPE,
  P_idrib OUT rib.idrib%TYPE);

PROCEDURE P_SEL_natfrais
                  (I_codfrais IN natfrais.rubrique%TYPE,
                   I_type     IN natfrais.type%TYPE DEFAULT 2,
                   O_Trouve       OUT boolean);

PROCEDURE charge_cvrt (
  P_numindiv IN individu.numindiv%TYPE,
  P_codfrais IN natfrais.codfrais%TYPE,
  P_datsin IN date default sysdate,
  O_erreur  OUT  NUMBER
  );

PROCEDURE P_CTRL_etat_cvrt
  (I_mnemo  IN libelle.mnemo%TYPE,
  I_code   IN libelle.code%TYPE,
  I_sens   IN libelle.sens%TYPE DEFAULT 0,
  O_trouve OUT BOOLEAN);

FUNCTION F_CTRL_info_calcul (
  P_numindiv IN couverture.numindiv%TYPE,
  P_codfrais IN calcul.codfrais%TYPE,
  P_datsin   IN calcul.datper%TYPE
  ) RETURN NUMBER;

PROCEDURE P_CTRL_CVRT_ACTE(
  P_codfrais IN natfrais.rubrique%TYPE,
  P_numindiv IN individu.numindiv%TYPE,
  P_datsin   IN DATE,
  P_idadhesion IN adhe_cntrt.idadhesion%TYPE,
  O_couvert OUT BOOLEAN,
  O_erreur OUT NUMBER
);
FUNCTION F_CREATE_DOSSIER_SANTE ( P_dossier_sante  IN dossier_sante%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INS_DOSSIER_SANTE( P_numbene          IN  dossier_sante.numbene%TYPE
                            , P_numassu          IN  dossier_sante.numassu%TYPE
                            , P_numindiv         IN  dossier_sante.numindiv%TYPE
                            , P_numporte         IN  dossier_sante.numporte%TYPE
                            , P_devise           IN  dossier_sante.devise%TYPE
                            , P_devise_out       IN  dossier_sante.devise_out%TYPE
                            , P_numremise        IN  dossier_sante.numremise_sntrprt%TYPE)
RETURN NUMBER;
PROCEDURE P_INS_DOSSIER_SANTE(
  P_ref IN dossier_sante.ref_dossier%TYPE,
  P_numindiv IN dossier_sante.numindiv%TYPE,
  P_PS IN dossier_sante.numbene%TYPE,
  P_numassu IN dossier_sante.numassu%TYPE,
  P_numporte IN dossier_sante.numporte%TYPE,
  P_natdoss  IN dossier_sante.nat_doss%TYPE,
  P_typedoss  IN dossier_sante.type_doss%TYPE,
  P_num_dossier_porte IN dossier_sante.num_dossier_porte%TYPE,
  O_num_dossier OUT dossier_sante.num_dossier%TYPE
);


PROCEDURE P_INS_HISTO_DOSSIER(
  P_num_dossier IN dossier_sante.num_dossier%TYPE,
  P_etat IN histo_dossier.etat%TYPE,
  P_motif IN histo_dossier.motif%TYPE,
  P_date IN histo_dossier.debut%TYPE DEFAULT SYSDATE
);

PROCEDURE P_INS_HISTO_SNTR_SANTE(
  P_num_dossier IN histo_sinistre_sante.num_dossier%TYPE,
  P_numligne IN histo_sinistre_sante.numligne%TYPE,
  P_etat IN histo_sinistre_sante.etat%TYPE,
  P_motif IN histo_sinistre_sante.motif%TYPE
);

PROCEDURE P_INS_COURR_DEST(
  P_num_dossier IN COURR_DEST.ID%TYPE,
  P_numindiv IN COURR_DEST.NUMINDIV%TYPE
);

FUNCTION F_INS_SNTR_SANTE (
  P_sinistre_sante  IN SINISTRE_SANTE%ROWTYPE)
RETURN BOOLEAN;

PROCEDURE P_INS_SNTR_SANTE(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne IN sinistre_sante.numligne%TYPE,
  P_numindiv IN sinistre_sante.numindiv%TYPE,
  P_codfrais IN sinistre_sante.codfrais%TYPE,
  P_mtfrais IN sinistre_sante.mtfrais%TYPE,
  P_etat IN sinistre_sante.situation%TYPE,
  P_taux IN sinistre_sante.taux%TYPE,
  P_baseremb IN sinistre_sante.baseremb%TYPE,
  P_mtremb IN sinistre_sante.mtremb%TYPE,
  P_datsin IN DATE,
  P_coeff IN sinistre_sante.coeff%TYPE,
  P_quantite IN sinistre_sante.quantite%TYPE DEFAULT 1,
  P_devise IN sinistre_sante.devise_in%TYPE DEFAULT 1,
  P_deviseout IN sinistre_sante.devise_out%TYPE DEFAULT 1,
  P_numutil IN sinistre_sante.numutil%TYPE DEFAULT 0,
  P_numorg IN sinistre_sante.numorg%TYPE DEFAULT NULL,
  P_numfact IN facture.numfact%TYPE DEFAULT NULL,
  P_numsin_sntrprt IN sinistre_sante.numsin_sntrprt%TYPE DEFAULT NULL,
  P_pays IN sinistre_sante.codpays%TYPE DEFAULT 1,
  p_pdsqls  IN SINISTRE_SANTE.pdsqls%TYPE DEFAULT 1,
  p_spe_exe  IN SINISTRE_SANTE.spe_exe%TYPE DEFAULT '01',
  p_autre_rb    IN SINISTRE_SANTE.AUTRB%TYPE DEFAULT 0,
  p_autre_rb_d  IN SINISTRE_SANTE.AUTRB_DAUTRB%TYPE DEFAULT 0,
  P_bloc IN sinistre_sante.blocage%TYPE DEFAULT 0 --RKO RAC OPTIQUE BLOCAGE
);



PROCEDURE P_UPD_SNTR_SANTE(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne IN sinistre_sante.numligne%TYPE,
  P_mtremb IN sinistre_sante.mtremb%TYPE,
  P_mtprest IN sinistre_sante.mtprest%TYPE,
  P_etat IN sinistre_sante.situation%TYPE
);


PROCEDURE P_UPD_SNTR_SANTE_REMB ( P_num_dossier  IN   SINISTRE_SANTE.NUM_DOSSIER%TYPE
                                 ,P_numligne     IN   SINISTRE_SANTE.NUMLIGNE%TYPE
                                 ,P_mtremb       IN   SINISTRE_SANTE.MTREMB%TYPE
                                 ,P_baseremb     IN   SINISTRE_SANTE.BASEREMB%TYPE
                                 ,P_taux         IN   SINISTRE_SANTE.TAUX%TYPE);

FUNCTION F_FIND_DOSSIER_BY_ASSU ( P_Numremise     IN   DOSSIER_SANTE.NUMREMISE_SNTRPRT%TYPE
                                , P_Numindiv      IN   DOSSIER_SANTE.NUMINDIV%TYPE
                                , P_Numassu       IN   DOSSIER_SANTE.NUMASSU%TYPE
                                , P_devise        IN   DOSSIER_SANTE.DEVISE%TYPE
                                , P_deviseOut     IN   DOSSIER_SANTE.DEVISE_OUT%TYPE)
RETURN NUMBER;

FUNCTION F_FIND_NUMDOSSIER ( P_ref_dossier IN dossier_sante.REF_DOSSIER%TYPE )
RETURN dossier_sante.num_dossier%TYPE;

FUNCTION F_FIND_PATIENT( P_numassu         IN  INDIVIDU.NUMINDIV%TYPE DEFAULT NULL
                       , P_matorgassu      IN  INDIVIDU.MATORG%TYPE DEFAULT NULL
                       , P_nom             IN  INDIVIDU.NOM%TYPE DEFAULT NULL
                       , P_prenom          IN  INDIVIDU.PRENOM%TYPE DEFAULT NULL
                       , P_datnais         IN  INDIVIDU.DATNAIS%TYPE DEFAULT NULL
                       , P_numindiv        IN  INDIVIDU.NUMINDIV%TYPE DEFAULT NULL)
RETURN NUMBER;

FUNCTION F_FIND_BENE( P_numindiv        IN  INDIVIDU.NUMINDIV%TYPE)
RETURN NUMBER;

PROCEDURE P_MAJ_SNTR_SANTE_LOCDEN(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne  IN sinistre_sante.numligne%TYPE,
  P_LOCDENT1  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT2  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT3  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT4  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT5  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT6  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT7  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT8  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT9  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT10 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT11 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT12 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT13 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT14 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT15 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT16 IN sinistre_sante.LOCDENT1%TYPE
);


FUNCTION F_FIND_DOSSIER(
  P_num_dossier IN dossier_sante.num_dossier%TYPE,
  P_numindiv IN OUT dossier_sante.numindiv%TYPE
)RETURN BOOLEAN;

FUNCTION F_FIND_REF_DOSSIER(
  P_ref_dossier IN dossier_sante.REF_DOSSIER%TYPE,
  P_numindiv IN OUT dossier_sante.numindiv%TYPE
)RETURN dossier_sante.num_dossier%TYPE;

PROCEDURE P_INFO_DOSSIER(
  P_num_dossier_liq IN OUT dossier_sante.num_dossier%TYPE,
  O_num_fact_pec OUT dossier_sante.num_fact_pec%TYPE,
  O_date_fact_pec OUT dossier_sante.date_fact_pec%TYPE,
  O_num_dossier_pec OUT dossier_sante.num_dossier_pec%TYPE,
  O_num_dossier_porte OUT dossier_sante.num_dossier_porte%TYPE
);

FUNCTION F_FIND_SNTR_DCPT(
   P_num_dossier IN dossier_sante.num_dossier%TYPE
)RETURN NUMBER;

FUNCTION F_FIND_SNTR_ANNUL(
   P_num_dossier IN dossier_sante.num_dossier%TYPE
)RETURN NUMBER;

PROCEDURE P_ANNUL_DOSSIER(
   P_num_dossier IN dossier_sante.num_dossier%TYPE,
   P_motif IN NUMBER default 1
);

PROCEDURE P_MAJ_REF_EXTERNE(
        P_numindiv IN individu.numindiv%TYPE,
        P_domaine  IN VARCHAR2,
        P_num_dossier IN dossier_sante.num_dossier%TYPE default null,
        P_tiers IN VARCHAR2,
        P_mnemo IN VARCHAR2
);

FUNCTION F_FIND_DEVISE RETURN NUMBER;

FUNCTION F_TRANSCO_CODFRAIS(
  P_codfrais_porte IN VARCHAR2,
  P_regime IN NUMBER,
  P_spec IN VARCHAR2,
  P_porte IN NUMBER,
  P_action OUT NUMBER
)
RETURN VARCHAR2;

FUNCTION F_TRANSCO_CODFRAIS_GAR(
        P_codfrais_porte IN VARCHAR2,
        P_regime IN NUMBER,
        P_spec IN VARCHAR2,
        P_porte IN NUMBER,
        P_numfor IN formule.numfor%TYPE,
        P_datsin IN DATE,
        P_action OUT NUMBER)
RETURN VARCHAR2;

PROCEDURE P_TRANSCO_CODFRAIS_SPSANTE(
        P_numfor              IN gar_cntrt.numfor%TYPE,
        P_nature_ntfrs_detail IN NUMBER,
        P_ntfrs_optique       IN NTFRS_OPTIQUE_T,
        P_type_monture        IN TYPE_MONTURE_T,
        P_ntfrs_vision        IN NTFRS_VISION_T,
        P_ntfrs_typ_vision    IN NTFRS_TYP_VISION_T,
        P_ntfrs_matiere       IN NTFRS_MATIERE_T,
        P_renew_lentille      IN RENEW_LENTILLE_T,
        P_MtRO                IN NUMBER,
        O_codfrais           OUT TAB_codfrais,
        O_acte_err_code      OUT VARCHAR2
        , P_lpp              IN  VARCHAR2 --RKO
        );


FUNCTION F_TRANSCO_SUP_SPSANTE( P_codfrais         IN NATFRAIS.CODFRAIS%TYPE,
                                P_ntfrs_type_sup   IN NTFRS_TYPE_SUP_T,
                                P_type             IN NUMBER,
                                P_MtRO             IN NUMBER,
                                P_typ_supRo        IN BOOLEAN)
RETURN BOOLEAN;


PROCEDURE P_SUP_DOSSIER_SANS_PREST(P_numremise          IN  DOSSIER_SANTE.NUMREMISE_SNTRPRT%TYPE
                                 , P_num_dossier        IN  SINISTRE_SANTE.NUM_DOSSIER%TYPE
                                 , P_nb_dossier_sup     OUT NUMBER);
PROCEDURE P_SUP_DOSSIER_SANS_PREST_WS( P_num_dossier        IN  SINISTRE_SANTE.NUM_DOSSIER%TYPE);

PROCEDURE P_CTRL_COUV_BENE ( P_Numassu    IN   SINISTRE_PORTE.NUMASSU%TYPE
                           , P_Numindiv   IN   SINISTRE_PORTE.NUMINDIV%TYPE
                           , P_Datsin     IN   SINISTRE_PORTE.DATSIN%TYPE
                           , P_Numporte   IN   SINISTRE_PORTE.NUMPORTE%TYPE
                           , P_idadhesion OUT  ADHE_CNTRT.IDADHESION%TYPE
                           , P_numgar     OUT  CONTRAT_REF.NUMGAR%TYPE
                           , P_numfor     OUT  SINISTRE_PORTE.NUMFOR%TYPE
                           , P_codano     OUT  NUMBER
                           , P_Porte      OUT  SINISTRE_PORTE.NUMPORTE%TYPE);

PROCEDURE P_CTRL_MODE_PAIEMENT ( P_NumBene    IN   SINISTRE_PORTE.NUMBENE%TYPE
                               , P_Datsin     IN   SINISTRE_PORTE.DATSIN%TYPE
                               , P_Codmon_d   IN   SINISTRE_PORTE.CODMON_D%TYPE
                               , P_dattrait   IN   SINISTRE_PORTE.DATTRAIT%TYPE
                               , P_idrib      OUT  RIB.IDRIB%TYPE
                               , P_deviseOut  OUT  DOSSIER_SANTE.DEVISE_OUT%TYPE
                               , P_codano     OUT  NUMBER);

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

-- ------------------------------------------------- Fin des procedures publiques --
END PK_CTRL_TP;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_CTRL_TP
As

   -- -- PROCEDURES PRIVEES ----------------------------------------------------
--

-- ------------------------------------------------- Fin des procedures privees --
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
glb_devise dossier_sante.devise%TYPE;

-- Variables de P_INS_journal
  g_session         journal_adm.id_session%TYPE DEFAULT 1;
  g_nom_traitement  journal_adm.nom_traitement%TYPE:='ITELIS2';
  g_niv_msg         journal_adm.niv_msg%TYPE;
  g_idligne         journal_adm.idligne%TYPE;
  g_msg_adm         journal_adm.msg_adm%TYPE;
-- -------------------------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
-- -- CORPS DES PROCEDURES PUBLIQUES --------------------------------------

/*ABO 21/06/2010 procedure de recherche de contrat en fonction du numéro d'adhérent et
la référence du contrat - en sortie le n° de l'adhésion, l'assuré principal, contrat collectif ou non, libelle du contrat*/
PROCEDURE P_FIND_CONTRAT (
  P_refContrat IN contrat_ref.refcie%TYPE,
  P_numAdhe IN adhe_cntrt.numadhe%TYPE,
  P_grpporte IN NUMBER,
  O_idadhesion OUT adhe_cntrt.idadhesion%TYPE,
  O_numAdhePrinc OUT adhe_cntrt.numadhe%TYPE,
  O_numgar OUT contrat_ref.numgar%TYPE,
  O_isColl OUT Boolean,
  O_libelle OUT produit.libelle%TYPE,
  O_dateEffet OUT adhe_cntrt.date_adhe%TYPE,
  O_dateRes OUT adhe_cntrt.date_fin_adhe%TYPE,
  O_numorg OUT contrat_ref.numorg%TYPE,
  O_numporte OUT dossier_sante.numporte%TYPE,
  O_found  OUT  NUMBER
  )
  IS

  V_numgar_ref contrat_ref.numgar_ref%TYPE;
  v_racineContrat VARCHAR2(6);
  v_pos NUMBER :=0;

 CURSOR C_adhe_cntrt is
  SELECT distinct 1 as tri, a.idadhesion, c.numgar, c.numgar_ref, a.numadhe,typadr,
  p.libelle, a.date_adhe, a.date_fin_adhe,c.numorg, pc.numporte, l.sens
    FROM contrat c , adhe_cntrt a , adhe_cntrt_membre m,produit p, porte_contrat pc, libelle l
    where c.numgar = a.numgar
    and m.idadhesion = a.idadhesion
    and pc.numgar = c.numgar
    AND a.date_adhe <= sysdate --abo 28/12/2011
    and substr(c.refcie,1,16) = substr(P_refContrat,1,16)
    and m.numindiv = P_numAdhe
    and p.numprod=c.numprod
    and pc.numporte = l.code
    and l.mnemo='PORTE'
   UNION
   SELECT distinct 2 as tri, a.idadhesion, c.numgar, c.numgar_ref, a.numadhe,typadr,
   p.libelle, a.date_adhe, a.date_fin_adhe,c.numorg, pc.numporte,l.sens
    FROM contrat c , adhe_cntrt a , adhe_cntrt_membre m,produit p, porte_contrat pc, libelle l
    where c.numgar = a.numgar
    and m.idadhesion = a.idadhesion
    and pc.numgar = c.numgar
    and substr(c.refcie, INSTR(P_refContrat,'/')+1,6) = v_racineContrat
    and m.numindiv = P_numAdhe
    AND a.date_adhe <= sysdate --abo 28/12/2011
    and p.numprod=c.numprod
    and pc.numporte = l.code
    and l.mnemo='PORTE'
    order by tri, date_adhe desc, date_fin_adhe desc,typadr ;
  -- 20110921
  --  order by tri,typadr, date_adhe desc,date_fin_adhe desc;

  Rec_adhe_cntrt C_adhe_cntrt%ROWTYPE;

  BEGIN

    O_found := 1; -- Erreur : adhésion non identifiée
    v_pos := INSTR(P_refContrat,'/');
    v_racineContrat := substr(P_refContrat,v_pos+1,6);

    FOR Rec_adhe_cntrt  IN C_adhe_cntrt
    LOOP
      IF  Rec_adhe_cntrt.sens = P_grpporte THEN --regroupement des portes Sévéane
         O_idadhesion := Rec_adhe_cntrt.idadhesion;
         O_numgar := Rec_adhe_cntrt.numgar;
         V_numgar_ref  := Rec_adhe_cntrt.numgar_ref;
         O_numAdhePrinc := Rec_adhe_cntrt.numadhe;
         O_libelle := Rec_adhe_cntrt.libelle;
         O_dateEffet := Rec_adhe_cntrt.date_adhe;
         O_dateRes  := Rec_adhe_cntrt.date_fin_adhe;
         O_numorg := Rec_adhe_cntrt.numorg;
         O_isColl := V_numgar_ref=O_numgar;
         O_numporte := Rec_adhe_cntrt.numporte;

      /* IF NVL(Rec_adhe_cntrt.date_fin_adhe, sysdate) >= sysdate
       THEN
          O_found := 0; -- Pas d'erreur
          EXIT;
       ELSE
          O_found := 2;
       END IF;*/
         O_found := 0;
         EXIT;
       ELSE  O_found := 2;
       END IF;
    END LOOP;

   /* EXCEPTION
    When no_data_found THEN O_found := 1; --Erreur : adhésion non identifiée
    When too_many_rows THEN  O_found := 4;  --erreur requete incohérente*/
END P_FIND_CONTRAT;


PROCEDURE P_FIND_REFCIE (
  P_refContrat IN contrat_ref.refcie%TYPE,
  P_numAdhe IN adhe_cntrt.numadhe%TYPE,
  P_grpporte IN NUMBER,
  O_idadhesion OUT adhe_cntrt.idadhesion%TYPE,
  O_numAdhePrinc OUT adhe_cntrt.numadhe%TYPE,
  O_numgar OUT contrat_ref.numgar%TYPE,
  O_isColl OUT Boolean,
  O_libelle OUT produit.libelle%TYPE,
  O_dateEffet OUT adhe_cntrt.date_adhe%TYPE,
  O_dateRes OUT adhe_cntrt.date_fin_adhe%TYPE,
  O_numorg OUT contrat_ref.numorg%TYPE,
  O_numporte OUT dossier_sante.numporte%TYPE,
  O_found  OUT  NUMBER
  )
  IS

  V_numgar_ref contrat_ref.numgar_ref%TYPE;
  v_racineContrat VARCHAR2(6);
  v_pos NUMBER :=0;

 CURSOR C_adhe_cntrt is
  SELECT distinct 1 as tri, a.idadhesion, c.numgar, c.numgar_ref, a.numadhe,typadr,
  p.libelle, a.date_adhe, a.date_fin_adhe,c.numorg, pc.numporte, l.sens
    FROM contrat c , adhe_cntrt a , adhe_cntrt_membre m,produit p, porte_contrat pc, libelle l
    where c.numgar = a.numgar
    and m.idadhesion = a.idadhesion
    and pc.numgar = c.numgar
    AND a.date_adhe <= sysdate --abo 28/12/2011
    and substr(c.refcie,1,16) = substr(P_refContrat,1,16)
    and m.numindiv = P_numAdhe
    and p.numprod=c.numprod
    and pc.numporte = l.code
    and l.mnemo='PORTE'
    order by tri, date_adhe desc, date_fin_adhe desc,typadr ;
  -- 20110921
  --  order by tri,typadr, date_adhe desc,date_fin_adhe desc;

  Rec_adhe_cntrt C_adhe_cntrt%ROWTYPE;

  BEGIN

    O_found := 1; -- Erreur : adhésion non identifiée
    v_pos := INSTR(P_refContrat,'/');
    v_racineContrat := substr(P_refContrat,v_pos+1,6);

    FOR Rec_adhe_cntrt  IN C_adhe_cntrt
    LOOP
      IF  Rec_adhe_cntrt.sens = P_grpporte THEN --regroupement des portes Sévéane
         O_idadhesion := Rec_adhe_cntrt.idadhesion;
         O_numgar := Rec_adhe_cntrt.numgar;
         V_numgar_ref  := Rec_adhe_cntrt.numgar_ref;
         O_numAdhePrinc := Rec_adhe_cntrt.numadhe;
         O_libelle := Rec_adhe_cntrt.libelle;
         O_dateEffet := Rec_adhe_cntrt.date_adhe;
         O_dateRes  := Rec_adhe_cntrt.date_fin_adhe;
         O_numorg := Rec_adhe_cntrt.numorg;
         O_isColl := V_numgar_ref=O_numgar;
         O_numporte := Rec_adhe_cntrt.numporte;

      /* IF NVL(Rec_adhe_cntrt.date_fin_adhe, sysdate) >= sysdate
       THEN
          O_found := 0; -- Pas d'erreur
          EXIT;
       ELSE
          O_found := 2;
       END IF;*/
         O_found := 0;
         EXIT;
       ELSE  O_found := 2;
       END IF;
    END LOOP;

   /* EXCEPTION
    When no_data_found THEN O_found := 1; --Erreur : adhésion non identifiée
    When too_many_rows THEN  O_found := 4;  --erreur requete incohérente*/
END P_FIND_REFCIE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_FIND_CONTRAT_BY_ASSU, JBO 20110726                      */
/* Type         :  Public                                                    */
/* Description  :  procedure de recherche de contrat                         */
/* Retour       :  Retourne le n° de l'adhésion, l'assuré principal, contrat */
/*                 collectif ou non, libelle du contrat                      */
/*---------------------------------------------------------------------------*/
PROCEDURE P_FIND_CONTRAT_BY_ASSU (
  P_numPorteurCarte   IN adhe_cntrt.numadhe%TYPE,
  P_numAdhe           IN adhe_cntrt.numadhe%TYPE,
  P_grpporte          IN NUMBER,
  O_idadhesion        OUT adhe_cntrt.idadhesion%TYPE,
  O_numgar            OUT contrat_ref.numgar%TYPE,
  O_isColl            OUT BOOLEAN,
  O_libelle           OUT produit.libelle%TYPE,
  O_dateEffet         OUT adhe_cntrt.date_adhe%TYPE,
  O_dateRes           OUT adhe_cntrt.date_fin_adhe%TYPE,
  O_numorg            OUT contrat_ref.numorg%TYPE,
  O_numporte          OUT dossier_sante.numporte%TYPE,
  O_found             OUT NUMBER
) IS

 V_numgar_ref contrat_ref.numgar_ref%TYPE;


 CURSOR C_adhesion is
  SELECT distinct 1 as tri
                , a.idadhesion
                , c.numgar
                , c.numgar_ref
                , a.numadhe
                , i.typadr
                , p.libelle
                , a.date_adhe
                , a.date_fin_adhe
                , c.numorg
                , pc.numporte
                , l.sens
    FROM contrat c
       , adhe_cntrt a
       , adhe_cntrt_membre m
       , produit p
       , porte_contrat pc
       , libelle l
       , individu i
    WHERE c.numgar = a.numgar
    AND m.idadhesion = a.idadhesion
    AND pc.numgar = c.numgar_ref
    AND m.numindiv = P_numAdhe
--    AND a.numadhe = i.numassu
    AND i.numindiv = m.numindiv
    AND p.numprod=c.numprod
    AND pc.numporte = l.code
    AND l.mnemo='PORTE'
    AND a.date_adhe <= sysdate --abo 28/12/2011
    AND NVL(a.date_fin_adhe, sysdate) >= sysdate -- PHA 30/12/2011
    -- JBO 02/02/2016
    --SDA 5288 ajout des truncs
    AND a.idadhesion IN ( SELECT idadhesion
                            FROM adhesion
                           WHERE numindiv = P_numAdhe
                             AND rang = 1
                             AND trunc(sysdate) BETWEEN trunc(datapli) AND trunc(NVL(datper,sysdate)))
  UNION
  SELECT distinct 2 as tri
                , a.idadhesion
                , c.numgar
                , c.numgar_ref
                , a.numadhe
                , i.typadr
                , p.libelle
                , a.date_adhe
                , a.date_fin_adhe
                , c.numorg
                , pc.numporte
                , l.sens
    FROM contrat c
       , adhe_cntrt a
       , adhe_cntrt_membre m
       , produit p
       , porte_contrat pc
       , libelle l
       , individu i
   WHERE c.numgar = a.numgar
    AND m.idadhesion = a.idadhesion
    AND pc.numgar = c.numgar_ref
    AND m.numindiv = P_numAdhe
  --  AND a.numadhe = i.numassu
    AND i.numindiv = m.numindiv
    AND p.numprod=c.numprod
    AND pc.numporte = l.code
    AND l.mnemo='PORTE'
    -- JBO 02/02/2016
    --SDA 5288 ajout des truncs
    AND a.idadhesion IN ( SELECT idadhesion
                            FROM adhesion
                           WHERE numindiv = P_numAdhe
                             AND rang = 1
                             AND trunc(sysdate) BETWEEN trunc(datapli) AND trunc(NVL(datper,sysdate)))
  ORDER BY tri,date_adhe asc,date_fin_adhe desc;

  Rec_adhesion C_adhesion%ROWTYPE;


  BEGIN

    O_found := 1; -- Erreur : adhésion non identifiée
     FOR Rec_C_adhesion IN C_adhesion LOOP

      IF (C_adhesion%NOTFOUND) THEN
        O_found:=1;--ABO
      END IF;
        IF Rec_C_adhesion.sens = P_grpporte THEN--regroupement des portes SPSanté
           O_idadhesion := Rec_C_adhesion.idadhesion;
           O_numgar := Rec_C_adhesion.numgar;
           V_numgar_ref  := Rec_C_adhesion.numgar_ref;
           O_libelle := Rec_C_adhesion.libelle;
           O_dateEffet := Rec_C_adhesion.date_adhe;
           O_dateRes  := Rec_C_adhesion.date_fin_adhe;
           O_numorg := Rec_C_adhesion.numorg;
           O_isColl := V_numgar_ref=O_numgar;
           O_numporte := Rec_C_adhesion.numporte;
           O_found := 0;

           EXIT;
        ELSE
          O_found := 2;  -- Retourne 2 si le contrat n est pas ouvert sur la porte concernée
        END IF;
    END LOOP;
   /* EXCEPTION
    When no_data_found THEN O_found := 1; --Erreur : adhésion non identifiée
    When too_many_rows THEN  O_found := 4;  --erreur requete incohérente*/
END P_FIND_CONTRAT_BY_ASSU;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_FIND_ASSURE,                                            */
/* Type         :  Public                                                    */
/* Description  :  procedure de recherche du porteur de carte TP, ayant droit*/
/* Retour       :  Retourne le tableau d'individu :recherche du bénéficiaire */
/* en fonction de la date de naissance, le rang et le numéro de l'assuré     */
/* figurant du la carte TP , on retourne le nom et prénom corrects           */
/*---------------------------------------------------------------------------*/
/*Correction    : ABO 22/08/2012 présence de doublon d'individu renvoyant le */
/*                mauvais n° de bénéficiaire ajout order by                  */
/*---------------------------------------------------------------------------*/
/*Evolution     : JBO 04/11/2013 Gestion du double numéro de sécurité social */
/*                Permettre la recherche avec le matorg2 et cless2           */
/*---------------------------------------------------------------------------*/
/*Correction  :  JBO 04/04/2016 M0005091: PK_CTRL_TP.P_FIND_ASSURE, rajout d */
/*              un desc dans le tri de la requête afin de récupérer le numéro*/
/*               d'individu le plus grand en cas de doublon                  */
/*===========================================================================*/
PROCEDURE P_FIND_ASSURE(
  P_numassu        IN individu.numindiv%TYPE default null,
  P_secu           IN VARCHAR2 default null,
  P_datenais       IN DATE,
  P_rang           IN individu.rang%TYPE default null,
  IO_Tab_indiv     IN OUT TAB_T_Indiv
  )
IS
   loc_numindiv  individu.numindiv%TYPE;
   loc_numassu   individu.numassu%TYPE;

   CURSOR C_Assu IS
     SELECT ayd.numindiv numass,
            ayd.datnais datass,
            ayd.rang rgass,
            ayd.nom nomass,
            ayd.prenom prenomass,
            ayd.matorg matass,
            ayd.cless cleass,
            od.numindiv numprinc,
            od.datnais datprinc,
            od.rang rgprinc,
            od.nom nomprinc ,
            od.prenom prenomprinc,
            od.matorg matprinc,
            od.cless cleprinc
       FROM individu od, individu ayd
      WHERE od.numindiv = NVL(P_numassu,od.numindiv)
       AND (
             (ayd.matorg = NVL(substr(P_secu,0,13),ayd.matorg)   AND ayd.cless  = NVL(substr(P_secu,14),ayd.cless))
           OR
             (ayd.matorg2 = NVL(substr(P_secu,0,13),ayd.matorg2) AND ayd.cless2 = NVL(substr(P_secu,14),ayd.cless2))
           )
       AND ayd.datnais = P_datenais
       AND ayd.rang = NVL(P_rang,ayd.rang)
       AND (
             (ayd.matorg=od.matorg  AND ayd.cless=od.cless)
             OR
             ( ayd.matorg2=od.matorg AND ayd.cless2=od.cless)
            )
       AND od.natur=1
  ORDER BY ayd.numindiv DESC;


  Rec_C_Assu C_Assu%ROWTYPE;
BEGIN
  IO_Tab_indiv('assure').numindiv:= 0;
  IO_Tab_indiv('bene').numindiv :=0;

  OPEN C_Assu;
  FETCH C_Assu INTO Rec_C_Assu;
  IF C_Assu%FOUND THEN
    IO_Tab_indiv('bene').numindiv := Rec_C_Assu.numass;
    IO_Tab_indiv('bene').nom := Rec_C_Assu.nomass;
    IO_Tab_indiv('bene').prenom := Rec_C_Assu.prenomass;
    IO_Tab_indiv('bene').datnais := Rec_C_Assu.datass;
    IO_Tab_indiv('bene').rang := Rec_C_Assu.rgass;
    IO_Tab_indiv('bene').matorg := Rec_C_Assu.matass;
    IO_Tab_indiv('bene').cless := Rec_C_Assu.cleass;

    IO_Tab_indiv('assure').numindiv := Rec_C_Assu.numprinc;
    IO_Tab_indiv('assure').nom := Rec_C_Assu.nomprinc;
    IO_Tab_indiv('assure').prenom := Rec_C_Assu.prenomprinc;
    IO_Tab_indiv('assure').datnais := Rec_C_Assu.datprinc;
    IO_Tab_indiv('assure').rang := Rec_C_Assu.rgprinc;
    IO_Tab_indiv('assure').matorg := Rec_C_Assu.matprinc;
    IO_Tab_indiv('assure').cless := Rec_C_Assu.cleprinc;

  END IF;
  CLOSE C_Assu;

END P_FIND_ASSURE;

/*---------------------------------------------------------------------------*/
/* FONCTION     :  JBO 20110920                                              */
/* Nom          :  F_CUMUL_ACTE                                              */
/* Type         :  Public                                                    */
/* Description  :  Permet de récuperer le paramètre "CUMUL" de la transco,   */
/*                 de l acte Arthus. Si le paramètre "CUMUL" est activé,     */
/*                 on quantitfie le nombre de prestation pour un meme acte   */
/* Entree       :  I_codfrais, Code acte Arthus                              */
/* Retour       :  Retourne TRUE si le parametre "CUMUL" est coché           */
/*---------------------------------------------------------------------------*/
FUNCTION F_CUMUL_ACTE(I_codfrais    IN  NATFRAIS.CODFRAIS%TYPE)
RETURN BOOLEAN IS
  v_cumul  NUMBER:=NULL;
BEGIN

  SELECT DISTINCT CUMUL c
    INTO v_cumul
   FROM NTFRS_DETAIL c
  WHERE c.CODFRAIS=I_codfrais;

  RETURN v_cumul=1;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_CUMUL_ACTE;

/* ABO 21/06/2010 Procédure de contrôle du tiers Payant de l'adhésion à 3 niveaux
- contrat
- garantie
- domaine*/
PROCEDURE P_CTRL_ADHESION (
  P_idadhesion IN adhe_cntrt.idadhesion%TYPE,
  P_numgar IN adhe_cntrt.numgar%type,
  P_lstDomaine IN VARCHAR2,
  P_CtrlGar IN BOOLEAN,
  O_etatAdhesion OUT NUMBER,
  O_found  OUT  NUMBER
)IS
  V_etatAdhesion number(2);
  V_found NUMBER:=0;
  V_idTP param_tiers_payant.idparam_tp%TYPE;
  V_domaine param_demande_tp.domaine%TYPE;
  V_numfor gar_cntrt.numfor%TYPE;
  BEGIN

/* XHUE le 30/07/2010 Mise en commentaire
BEGIN
      --porte du TP ouverte pour ce contrat
      SELECT idparam_tp
      INTO V_idTP
      FROM param_tiers_payant
      WHERE numgar = P_numgar
      ;

      EXCEPTION
      When no_data_found THEN V_found := 1; --Erreur : porte TP non ouverte
      When too_many_rows THEN V_found := 2;--erreur : requete infructueuse

    END;


  IF V_found=0 AND V_idTP != NULL THEN
    --TP du domaine pour ce contrat
    BEGIN --a corriger !!!!!
      SELECT domaine INTO V_domaine
      FROM param_demande_tp
      WHERE idparam_tp = V_idTP
      AND domaine in (P_lstDomaine);

      EXCEPTION
      When no_data_found THEN V_found := 3; --Erreur : TP non autorisé sur le(s) domaine(s)
      When too_many_rows THEN V_found := 4; --erreur : requete infructueuse
    END;
  END IF;

  IF V_found=0 AND P_CtrlGar THEN
    -- TP sur les garanties
    BEGIN
      SELECT numfor INTO V_numfor
      FROM gar_cntrt c
      WHERE c.numgar = P_numgar
      AND numfor NOT IN (
        SELECT numfor FROM v_gc02 g
        WHERE g.numgar= P_numgar);

      V_found := 5; --Erreur : pas de TP sur au moins une des garanties
      EXCEPTION
      When no_data_found THEN V_found :=0; --si aucune donnée trouvée alors toutes les garanties sont valides
      When too_many_rows THEN V_found := 6;
   END;
  END IF;
*/
  IF V_found=0 THEN
    --Contrôle de l'état de l'adhésion
    BEGIN
      O_etatAdhesion :=F_etat_adhe(P_idadhesion,sysdate,1) ;

      IF O_etatAdhesion = 3 THEN V_found := 7;--erreur : adhésion résilée
      ELSIF O_etatAdhesion = 2 THEN V_found := 8;--erreur : adhésion suspendue
      ELSIF O_etatAdhesion = 0 THEN V_found := 9;--erreur : adhésion en instance
      END IF;

    EXCEPTION
      When no_data_found THEN V_found := 10;--erreur : requete infructueuse
      When too_many_rows THEN V_found := 11;
    END;
  END IF;
  O_found:=V_found;
END;


/*ABO 21/06/2010 Contrôle de droit d'un bénéficiaire de forms gs14*/
FUNCTION F_CTRL_couverture(
  I_numindiv    IN couverture.numindiv%TYPE,
  I_numtype     IN couverture.numtype%TYPE DEFAULT  1,
  I_flag_regime IN couverture.flag_regime%TYPE DEFAULT 'C',
  I_datsin      IN couverture.datapli%TYPE
  ) RETURN BOOLEAN
IS
  CURSOR C_couverture is
         SELECT 'X'
         FROM   couverture
         WHERE  numindiv    = I_numindiv
         AND    numtype     = I_numtype
         AND    flag_regime = I_flag_regime
         AND    I_datsin BETWEEN couverture.datapli
         AND    NVL(couverture.datper,I_datsin);

  L_test VARCHAR2(1);

BEGIN
 OPEN C_couverture;
 FETCH C_couverture INTO L_test;
   IF C_couverture%FOUND THEN
      CLOSE C_couverture;
      RETURN(TRUE);
   ELSE
      CLOSE C_couverture;
      RETURN(FALSE);
  END IF;
END;

FUNCTION F_CTRL_couverture_NUMFOR(
  I_numindiv    IN couverture.numindiv%TYPE,
  I_numtype     IN couverture.numtype%TYPE DEFAULT  1,
  I_flag_regime IN couverture.flag_regime%TYPE DEFAULT 'C',
  I_datsin      IN couverture.datapli%TYPE
  ) RETURN NUMBER
IS
  CURSOR C_couverture is
         SELECT couverture.numfor
         FROM   couverture
         WHERE  numindiv    = I_numindiv
         AND    numtype     = I_numtype
         AND    flag_regime = I_flag_regime
         AND    I_datsin BETWEEN couverture.datapli
         AND    NVL(couverture.datper,I_datsin);

  loc_numfor NUMBER:=0;

BEGIN
 OPEN C_couverture;
 FETCH C_couverture INTO loc_numfor;
   IF C_couverture%FOUND THEN
      CLOSE C_couverture;
      RETURN loc_numfor;
   ELSE
      CLOSE C_couverture;
      RETURN loc_numfor;
  END IF;
END;

/*ABO 21/06/2010 Contrôle de droit TP d'un bénéficiaire : on vérifie que le bénéficiaire
a un rang différent de 2 (qu'il n'est pas couvert par une autre mutuelle ) ex : conjoint avec une mutuelle employeur*/
/*SDA 13/11/2015 mantis 4752 ajout dans le cuseur de la variable I_idadhesion deja présent dans l'appel de la fonction */
FUNCTION F_CTRL_rang(
  I_numindiv    IN couverture.numindiv%TYPE,
  I_idadhesion  IN couverture.idadhesion%TYPE,
  I_numtype     IN couverture.numtype%TYPE DEFAULT  1,
  I_flag_regime IN couverture.flag_regime%TYPE DEFAULT 'C',
  I_datsin      IN couverture.datapli%TYPE
  ) RETURN BOOLEAN
IS
  CURSOR C_couverture is
         SELECT 'X'
         FROM   couverture
         WHERE  numindiv    = I_numindiv
         AND    numtype     = I_numtype
         AND    flag_regime = I_flag_regime
         AND    I_datsin BETWEEN couverture.datapli
         AND    NVL(couverture.datper,I_datsin)
         AND    rang=1
         AND    idadhesion = I_idadhesion;

  L_test VARCHAR2(1);

BEGIN
 OPEN C_couverture;
 FETCH C_couverture INTO L_test;
   IF C_couverture%FOUND THEN
      CLOSE C_couverture;
      RETURN(TRUE);
   ELSE
      CLOSE C_couverture;
      RETURN(FALSE);
  END IF;
END;

/*ABO 01/07/2010 Contrôle du contrat gs01*/
FUNCTION F_CTRL_CNTRT(
  P_numgar      IN adhe_cntrt.numgar%TYPE,
  P_datsin      IN adhesion.datapli%TYPE
)RETURN NUMBER IS
BEGIN
  RETURN pk_histo_contrat.f_sel_etat(P_numgar,P_datsin);
END;

/*----------------------------------------------------------------------------*/
/* FONCTION                                                                   */
/* Nom          :  F_CTRL_DOUBLON_PRESTA                                      */
/* Type         :  Public                                                     */
/* Description  :  Permet de controler la precence d un doublon de prestation */
/*                 santé (SINISTRE_SANTE)                                     */
/* Entree       :  P_numindiv                                                 */
/*              :  P_codfrais                                                 */
/*                 P_datsin                                                   */
/* Retour       :  num_dossier                                                */
/*----------------------------------------------------------------------------*/
FUNCTION F_CTRL_DOUBLON_PRESTA( P_numindiv   IN  SINISTRE_SANTE.NUMINDIV%TYPE
                              , P_codfrais   IN  SINISTRE_SANTE.CODFRAIS%TYPE
                              , P_datsin     IN  SINISTRE_SANTE.DATSIN%TYPE)
RETURN NUMBER
IS

  loc_num_dossier  SINISTRE_SANTE.NUM_DOSSIER%TYPE:=NULL;

BEGIN

  BEGIN
    SELECT DISTINCT ss.NUM_DOSSIER
      INTO loc_num_dossier
      FROM SINISTRE_SANTE ss
     WHERE ss.NUMINDIV=P_numindiv
       AND ss.CODFRAIS=P_codfrais
       AND ss.DATSIN=P_datsin;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END;

  RETURN loc_num_dossier;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 1;
END;

/*----------------------------------------------------------------------------*/
/* FONCTION                                                                   */
/* Nom          :  F_CTRL_DOUBLON_REMISE                                      */
/* Type         :  Public                                                     */
/* Description  :  Permet de controler la precence d un doublon de prestation */
/*                 santé (SINISTRE_SANTE)                                     */
/* Entree       :  P_numindiv                                                 */
/*              :  P_codfrais                                                 */
/*                 P_datsin                                                   */
/* Retour       :  num_dossier                                                */
/*----------------------------------------------------------------------------*/
FUNCTION F_CTRL_DOUBLON_REMISE( P_ref_ext     IN  PORTE_REMISE.REF_EXT%TYPE
                              , P_dateporte   IN  PORTE_REMISE.DATEPORTE%TYPE)
RETURN NUMBER
IS

  loc_num_remise  PORTE_REMISE.NUMREMISE%TYPE:=NULL;

BEGIN

  BEGIN
    SELECT DISTINCT pr.NUMREMISE
      INTO loc_num_remise
      FROM PORTE_REMISE pr
     WHERE pr.REF_EXT=P_ref_ext
       AND pr.DATEPORTE=P_dateporte;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END;

  RETURN loc_num_remise;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 1;
END F_CTRL_DOUBLON_REMISE;

/*ABO 21/06/2010 Adresse d'un individu formatée sur 5 lignes, ne gère pas les adr internationales
Attention gérer la longeur des champs en sortie ! */
PROCEDURE P_ADR_FORMAT(
  P_numindiv IN individu.numindiv%TYPE,
  O_ligne1 OUT VARCHAR2,
  O_ligne2 OUT VARCHAR2,
  O_ligne3 OUT VARCHAR2,
  O_ligne4 OUT VARCHAR2,
  O_ligne5 OUT VARCHAR2,
  O_cp OUT pers_adresse.codpos%TYPE,
  O_ville OUT pers_adresse.ville%TYPE
  ) IS

  loc_idadresse pers_adresse.idadresse%TYPE;

  CURSOR c_adresse
      IS
         SELECT a.codtitre,pers_adresse.no_voie, pers_adresse.bis,
                pers_adresse.type_voie, pers_adresse.nom_voie,
                pers_adresse.comp_adresse, pers_adresse.adresse_2,
                DECODE (pers_adresse.codpos,
                        '99999', '',
                        pers_adresse.codpos
                       ) codpos,
                pers_adresse.ville, pers_adresse.flag_cedex,
                pers_adresse.no_cedex, pers_adresse.codpays,
                pers_adresse.TYPE type_adresse, pers_adresse.idadresse ,
                b.libelle libqual,
                d.libelle libelle_titre
           FROM pers_adresse,individu a,lble b, lble d
          WHERE pers_adresse.idadresse = pk_personne.f_idadresse (
                        P_numindiv, 0, sysdate, 'O', 0, -1 )
          AND a.numindiv = P_numindiv + 0
          AND b.mnemo(+)='CODC1'
          AND b.code(+)=a.codcourrier1
          AND d.mnemo(+)='TITRE'
          AND d.code(+)=a.codtitre;
  CURSOR c_adresse_inter IS
      SELECT *
      FROM adr_internationale
      WHERE idadresse = loc_idadresse;
  rec_adresse                  c_adresse%ROWTYPE;
  rec_adresse_inter            c_adresse_inter%ROWTYPE;
BEGIN
  -- désignation : qualité abrégé prénom nom
  O_ligne1 := SUBSTR(pk_personne.f_concatene (O_ligne1,pk_personne.f_nom(P_numindiv,50,1)),1,50);
  FOR rec_adresse IN c_adresse LOOP

    IF (rec_adresse.type_adresse != 3) THEN
      --désignation complémentaire (résidence... ou batiment B)
      IF (rec_adresse.comp_adresse IS NOT NULL) THEN O_ligne2 := rec_adresse.comp_adresse;
      ELSIF (rec_adresse.codtitre IS NOT NULL) THEN O_ligne2 := pk_libelle.f_lib ('TITRE', rec_adresse.codtitre);
      END IF;

      --Rue
      O_ligne4 := pk_personne.f_recompose (rec_adresse.no_voie,
                              rec_adresse.bis,
                              rec_adresse.type_voie,
                              rec_adresse.nom_voie,
                              50
                             );
      --Lieu Dit
      IF rec_adresse.adresse_2 IS NOT NULL THEN O_ligne5 := rec_adresse.adresse_2;
      END IF;

      --Code postal
      O_cp := rec_adresse.codpos;

      -- ville
      O_ville :=  rec_adresse.ville;
      /*
      IF (c_adresse.flag_cedex = 'O') THEN
         IF (INSTR (c_adresse.ville, 'CEDEX') = 0) THEN
          t_adresse (6) :=SUBSTR (pk_personne.f_concatene (t_adresse (i), 'CEDEX'),1,32);
         END IF;

         t_adresse (7) := SUBSTR (pk_personne.f_concatene (t_adresse (i),c_adresse.no_cedex),1,32);
      END IF;*/
    ELSE
       loc_idadresse := rec_adresse.idadresse;
       FOR rec_adresse_inter IN c_adresse_inter LOOP
          O_ligne4 := rec_adresse_inter.adr1;
          O_ligne5 := rec_adresse_inter.adr2 || rec_adresse_inter.adr3;
          O_cp :='00000';
          O_ville := rec_adresse_inter.adr4 || ' ' ||rec_adresse_inter.adr5;
          EXIT WHEN c_adresse_inter%FOUND;
      END lOOP;
    END IF;

    EXIT WHEN c_adresse%FOUND;



  END LOOP;
END;

/*ABO 28/06/2010  recherche un le contact d'un individu en fonction de la nature*/
FUNCTION F_FIND_CONTACT(
  P_numindiv IN individu.numindiv%TYPE,
  P_nature IN contact.nature%TYPE
) RETURN VARCHAR2 IS
  CURSOR C_contact IS
     SELECT coordonnee
     FROM   contact
     WHERE  numindiv = P_numindiv
     AND    nature   = P_nature
     ORDER BY creation DESC;
--
  Rec_C_contact C_contact%ROWTYPE;
BEGIN
  OPEN C_contact;
  FETCH C_contact INTO Rec_C_contact;
  IF C_contact%FOUND THEN
      CLOSE C_contact;
      RETURN Rec_C_contact.coordonnee;
  ELSE
      CLOSE C_contact;
      RETURN NULL;
  END IF;
END;
/*----------------------------------------------------------------------------*/
/* FONCTION                                                                   */
/* Nom          :  F_FIND_ASSURE                                              */
/* Type         :  Public                                                     */
/* Description  :  Permet de faire la recherche du numéro de l assure a partir*/
/*                 du nom, prenom, numéro de sécu et de la date de naissance  */
/* Entree       :  P_nom                                                      */
/*              :  P_prenom                                                   */
/*                 P_matorg                                                   */
/* Retour       :  Numindiv                                                   */
/*----------------------------------------------------------------------------*/
FUNCTION F_FIND_ASSURE ( P_nom      IN   INDIVIDU.NOM%TYPE DEFAULT NULL
                       , P_prenom   IN   INDIVIDU.PRENOM%TYPE DEFAULT NULL
                       , P_matorg   IN   INDIVIDU.MATORG%TYPE DEFAULT NULL
                       , P_numindiv IN   INDIVIDU.NUMINDIV%TYPE DEFAULT NULL)
RETURN NUMBER
IS

  loc_numindiv        INDIVIDU.NUMINDIV%TYPE:=NULL;

BEGIN
  BEGIN
    -- Recherche de l assure a partir de son numéro(utilisé pour le déblocage d une presta pe05)
    SELECT DISTINCT NVL(a.NUMINDIV,0)
      INTO loc_numindiv
      FROM ASSURES a
     WHERE a.NUMINDIV=P_numindiv
     ;
  EXCEPTION
    WHEN OTHERS THEN
    -- Recherche de l assure a partir du numéro de sécu
    BEGIN
      SELECT DISTINCT NVL(a.NUMINDIV,0)
        INTO loc_numindiv
        FROM ASSURES a
       WHERE a.MATORG=NVL(SUBSTR(P_matorg,0,13),a.matorg)
         AND (a.CLESS=NVL(SUBSTR(P_matorg,14),a.cless) OR a.cless IS NULL)
       ;
    EXCEPTION
        -- Recherche de l assu a partir du numéro de sécu, du nom et du prénom
       WHEN OTHERS THEN
        BEGIN
          SELECT DISTINCT NVL(a.NUMINDIV,0)
          INTO loc_numindiv
          FROM ASSURES a
          WHERE a.MATORG=NVL(SUBSTR(P_matorg,0,13),a.matorg)
          AND (a.CLESS=NVL(SUBSTR(P_matorg,14),a.cless) OR a.cless IS NULL)
          AND (UPPER(a.NOM)=UPPER(P_nom)
		       OR UPPER(a.NOMJF)=UPPER(P_nom)) -- M0004004 : ajout recherche sur nom de jeune fille
          AND UPPER(a.PRENOM)=UPPER(P_prenom)
          ;
         RETURN loc_numindiv;
        EXCEPTION
          WHEN OTHERS THEN
            -- Recherche de l assu a partir du numéro de sécu, du nom et du prénom , sans les caracteres speciaux - MUR mantis 4004
            SELECT DISTINCT NVL(a.NUMINDIV,0)
            INTO loc_numindiv
            FROM ASSURES a
            WHERE a.MATORG=NVL(SUBSTR(P_matorg,0,13),a.matorg)
            AND (a.CLESS=NVL(SUBSTR(P_matorg,14),a.cless) OR a.cless IS NULL)
            AND (replace(replace(replace(UPPER(a.NOM),' '),''''),'-') = replace(replace(replace(UPPER(P_nom),' '),''''),'-')
			     OR replace(replace(replace(UPPER(a.NOMJF),' '),''''),'-') = replace(replace(replace(UPPER(P_nom),' '),''''),'-')) -- M0004004 : ajout recherche sur nom de jeune fille
            AND replace(replace(replace(UPPER(a.PRENOM),' '),''''),'-') = replace(replace(replace(UPPER(P_prenom),' '),''''),'-')
            ;
            RETURN loc_numindiv;
        END ;
    END;
  END;

  RETURN loc_numindiv;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_FIND_ASSURE;


/*ABO 22/06/2010 recherche du praticien et s'il n'existe pas création du tiers
Attention numéro national d'identification en caractères*/

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_FIND_TIERS, ABO                                         */
/* Type         :  Public                                                    */
/* Description  :  procedure de recherche du praticien et s'il n'existe pas  */
/*                 création du tiers                                         */
/* Entree       :  P_NNI, numéro ADELI de l opticien                         */
/* Entree       :  P_raison,raison sociale du PS                             */
/* Entree       :  P_typePS, type de PS                                      */
/* Entree       :  P_ad1, adresse 1                                          */
/* Entree       :  P_ad2, adresse 2                                          */
/* Entree       :  P_ad3, adresse 3                                          */
/* Entree       :  P_ad4, adresse 4                                          */
/* Entree       :  P_ad5, adresse 5                                          */
/* Entree       :  P_cp, code postal du PS                                   */
/* Entree       :  P_ville, ville du PS                                      */
/* Entree       :  P_tel, télépone du PS                                     */
/* Retour       :  Retourne le n° du practicien                              */
/*---------------------------------------------------------------------------*/
PROCEDURE P_FIND_TIERS(
  P_NNI IN varchar2,
  P_raison IN varchar2 default null,
  P_typePS IN varchar2 default null,
  P_ad1 In varchar2 default null,
  P_ad2 In varchar2 default null,
  P_ad3 In varchar2 default null,
  P_ad4 In varchar2 default null,
  P_ad5 In varchar2 default null,
  P_cp In varchar2 default null,
  P_ville In varchar2 default null,
  P_tel In varchar2 default null,
  P_mail In varchar2 default null,
  O_numindivPS OUT individu.numindiv%TYPE) IS


  --SDA 5298
  PRAGMA AUTONOMOUS_TRANSACTION;


  loc_numindiv individu.numindiv%TYPE;
  loc_user utilisateurs.numutil%TYPE;
  loc_idadresse pers_adresse.idadresse%TYPE;
  loc_nom individu.nom%TYPE;


   CURSOR c_adresse IS
     SELECT idadresse
     FROM pers_adresse
     WHERE idadresse = pk_personne.f_idadresse (loc_numindiv, 0, sysdate, 'O', 0, -1 )
     AND  NVL(no_voie,-1)  = NVL(pk_personne.f_appel_decompose(substr(trim(P_ad3||' '||P_ad4),1,30),1),-1)
     AND NVL(bis,-1)       = NVL(pk_personne.f_appel_decompose(substr(trim(P_ad3||' '||P_ad4),1,30),2),-1)
     AND NVL(type_voie,-1) = NVL(pk_personne.f_appel_decompose(substr(trim(P_ad3||' '||P_ad4),1,30),3),-1)
     AND NVL(nom_voie,-1)  = NVL(pk_personne.f_appel_decompose(substr(trim(P_ad3||' '||P_ad4),1,30),4),-1)
     AND NVL(adresse_2,-1) = NVL(substr(P_ad5,1,30),-1)
     AND NVL(codpos,-1)    = NVL(P_cp,-1)
     AND NVL(ville,-1)     = NVL(P_ville,-1)
     AND codpays   = 1;

  Rec_c_adresse                  c_adresse%ROWTYPE;

BEGIN
  BEGIN
    SELECT numindiv INTO loc_numindiv
    FROM pers_tiers
    WHERE  numdpt = SUBSTR(P_NNI,1,2)
    AND numactv = SUBSTR(P_NNI,3,1)
    AND numinser = SUBSTR(P_NNI,4,5)
    AND numcle = SUBSTR(P_NNI,9,1);

    EXCEPTION
      When no_data_found THEN O_numindivPS := NULL;
      When too_many_rows THEN O_numindivPS:=-1; RETURN;
  END;
  --si le praticien n'existe pas, création du tiers
  IF loc_numindiv IS NULL THEN
    --dbms_output.put_line('PS inexistant');
    -- création d'une personne morale
    loc_numindiv  := f_numero( 'INDVS' ); -- incrémentation du numéro d'individu


    SELECT F_NUMUTIL INTO loc_user FROM DUAL;


    --insertion d'une personne morale
    INSERT INTO individu (numindiv, nom,qualite, type,codcourrier1, creation,numutil, tel)
      VALUES (loc_numindiv,P_raison,0,2,0,sysdate,loc_user,P_tel);
     -- création du tiers, le type est indéfini
    INSERT INTO pers_tiers (numindiv,numtiers,nomp,type_tiers,numdpt,numactv,numinser,numcle)
      VALUES ( loc_numindiv,loc_numindiv,P_raison,P_typePS,SUBSTR(P_NNI,1,2),SUBSTR(P_NNI,3,1),SUBSTR(P_NNI,4,5),SUBSTR(P_NNI,9,1));
    -- création du contact téléphone ou mail dans la table contact
    IF P_tel IS NOT NULL OR P_mail IS NOT NULL THEN
      INSERT INTO contact (numindiv,nature,type, coordonnee, flag, creation, maj, numutil)
        VALUES ( loc_numindiv, 1, 1, NVL(P_tel, P_mail), 'O', sysdate, sysdate, loc_user);
    END IF;

    IF P_ville IS NOT NULL THEN
      /*pas d'insertion de l'adresse et du contact cf spec décision Gerep 04/2010 mais en évo*/
      --creation de l'adresse si l'individu n'existait pas
      P_NEW_ADRESSE(loc_numindiv,P_ad1,P_ad2,P_ad3,P_ad4,P_ad5,P_cp,P_ville,loc_user);
    END IF;
  ELSIF  P_ville IS NOT NULL THEN
    -- si l'individu existait on compare les adresses enregistrées si non identique on créé la nouvelle

    BEGIN
      SELECT DISTINCT TRIM(nom) INTO loc_nom
        FROM individu
       WHERE numindiv=loc_numindiv;

      EXCEPTION
        When no_data_found THEN
          IF TRIM(P_raison) IS NOT NULL THEN
            UPDATE individu
               SET nom=P_raison
                 , tel=P_tel
             WHERE numindiv=loc_numindiv;
            UPDATE pers_tiers
               SET nomp=P_raison
                 , type_tiers=P_typePS
             WHERE numindiv=loc_numindiv;
          END IF;
        When too_many_rows THEN O_numindivPS:=-1; RETURN;
    END;

  -- On vérifie si le nom dans individu n'est pas null ==> a cause de SPSANTE qui ne fournit pas de raison social ni adresse

    SELECT F_NUMUTIL INTO loc_user FROM DUAL;

    OPEN c_adresse;
    FETCH c_adresse INTO Rec_c_adresse;
    IF c_adresse%NOTFOUND THEN
      P_NEW_ADRESSE(loc_numindiv,P_ad1,P_ad2,P_ad3,P_ad4,P_ad5,P_cp,P_ville,loc_user);
    END IF;
    CLOSE c_adresse;
  END IF;

  O_numindivPS:=loc_numindiv;

  --SDA 5298
  commit;

  EXCEPTION
    when others then  --dbms_output.put_line('erreur création PS'||SQLERRM);
    PK_TP_GROUPAMA.P_INS_journal(2,' FIND ADRESSE error' , SQLERRM);
    CLOSE c_adresse;
END;

/*ABO 20/10/2010 Creation d'une adresse*/
PROCEDURE P_NEW_ADRESSE(
  P_numindivPS IN individu.numindiv%TYPE,
  P_ad1 In varchar2 default null,
  P_ad2 In varchar2 default null,
  P_ad3 In varchar2 default null,
  P_ad4 In varchar2 default null,
  P_ad5 In varchar2 default null,
  P_cp In varchar2 default null,
  P_ville In varchar2 default null,
  P_user utilisateurs.numutil%TYPE) IS

  loc_idadresse pers_adresse.idadresse%TYPE :=0;

BEGIN
    -- mise à jour de l'actuelle adresse par défaut
    loc_idadresse := pk_personne.f_idadresse (P_numindivPS, 0, sysdate, 'O', 0, -1 );
    IF loc_idadresse !=0 THEN
      UPDATE pers_adresse
      SET defaut = 'N'
      WHERE idadresse = loc_idadresse;
      loc_idadresse:=0;
    END IF;

    -- création de la nouvelle adresse par défaut
    SELECT idadresse.nextval INTO loc_idadresse
    FROM DUAL;

    INSERT INTO pers_adresse(idadresse,numindiv,debut,codope,defaut,type,numutil,
                            no_voie,bis,type_voie,
                            nom_voie,adresse_2,
                            codpos,ville,flag_cedex,codpays)
    VALUES(loc_idadresse,P_numindivPS,sysdate,0,'O',1,P_user,
            pk_personne.f_appel_decompose(substr(trim(P_ad3||' '||P_ad4),1,30),1),
            pk_personne.f_appel_decompose(substr(trim(P_ad3||' '||P_ad4),1,30),2),
            pk_personne.f_appel_decompose(substr(trim(P_ad3||' '||P_ad4),1,30),3),
            pk_personne.f_appel_decompose(substr(trim(P_ad3||' '||P_ad4),1,30),4),
            substr(P_ad5,1,30),
            P_cp,P_ville,'N',1);

END;


/* ABO 22/06/2010 Recherche du rib d'un PS sinon création du rib
-- ABO 14/09/2011 : norme SEPA*/
PROCEDURE P_FIND_RIB_PS(
  P_numtiers IN individu.numindiv%TYPE,
  P_intitule IN rib.intitule%TYPE,
  P_banque IN rib.codbque%TYPE,
  P_guichet IN rib.guichet%TYPE,
  P_compte IN rib.compte%TYPE,
  P_clerib IN rib.clerib%TYPE,
  P_bban IN rib.bban%TYPE,
  P_cleban IN rib.clef_iban%TYPE,
  P_bic IN rib.bic%TYPE,
  P_idrib OUT rib.idrib%TYPE)
IS
  v_idrib rib.idrib%TYPE;
  v_bban rib.bban%TYPE;
  v_debut rib.debut%TYPE;
  loc_user utilisateurs.numutil%TYPE;
  loc_bban rib.bban%TYPE;
  loc_clef_iban rib.clef_iban%TYPE;

BEGIN
 IF P_bban IS NULL THEN
  --génération de l'iban
  loc_bban := upper(concat(trim(P_banque), concat(trim(P_guichet),concat(trim(P_compte),trim(P_clerib)))));
  loc_clef_iban := upper(trim(  concat('FR' , 98 - mod(  cast(
  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(
  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(
  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(  Replace(
    upper(concat(P_banque ,concat(P_guichet ,concat(P_compte  ,concat( P_clerib ,'FR00' )))))
    ,'A','10')  ,'B','11')  ,'C','12')  ,'D','13')  ,'E','14')  ,'F','15')  ,'G','16')  ,'H','17')
    ,'I','18')  ,'J','19')  ,'K','20')  ,'L','21')  ,'M','22')  ,'N','23')  ,'O','24')  ,'P','25')
    ,'Q','26')  ,'R','27')  ,'S','28')  ,'T','29')  ,'U','30')  ,'V','31')  ,'W','32')  ,'X','33')
    ,'Y','34')  ,'Z','35') as number) ,97 ))));
  ELSE
    loc_bban:=P_bban;
    loc_clef_iban :=P_cleban;
  END IF;


  SELECT F_NUMUTIL INTO loc_user FROM DUAL;

  --Recherche du dernier RIB
   BEGIN
    SELECT idrib,bban,debut
    INTO v_idrib,v_bban,v_debut
    FROM rib
    WHERE numindiv = P_numtiers
    AND type = 1 --encaissement/décaissement
    AND modpmt = 2 --mode paiement RIB
    AND rownum=1
    order by debut DESC;

   EXCEPTION
   -- When too_many_rows then return; --le rib existe déjà
    When others then v_idrib:=NULL; --aucun rib de trouvé
  END;

  -- aucun RIB ou rib different
  IF v_idrib IS NULL OR NVL(v_bban,0) <> loc_bban THEN
    --dbms_output.put_line('RIB PS inexistant ou different');
    SELECT   idrib.nextval
    INTO  v_idrib
    FROM  Dual;

    --RIB de décaissement(type = 1) en mode prélèvement et nature RIB normalisé
    INSERT INTO rib(idrib,type,numindiv,numgar,codope,modpmt,intitule,debut,
      devise_compte,devise_ope,creation,numutil_creation,nature,
      codbque,guichet,compte,clerib,bban,clef_iban,codpays,bic)
    SELECT   v_idrib,1,P_numtiers,0,0,2,P_intitule,sysdate
      ,pk_devise.devise_ref,pk_devise.devise_ref,sysdate,loc_user,2,
      P_banque,P_guichet,P_compte,P_clerib,loc_bban,loc_clef_iban,1,P_bic
    FROM  dual;

  ELSE
    IF to_char(v_debut,'mm/dd/yyyy') = to_char(sysdate,'mm/dd/yyyy') THEN
    --mise à jour du RIB créé par trigger sur insertion de l'indivdu
    UPDATE RIB SET
       intitule = P_intitule,
       codbque=P_banque,
       guichet=P_guichet,
       compte=P_compte,
       clerib=P_clerib,
       bban=loc_bban,
       clef_iban=loc_clef_iban,
       bic = P_bic,
       numutil_creation =loc_user,
       codpays =1,
       nature = 2,
       modpmt =2
    WHERE idrib = v_idrib;
    END IF;
  END IF;

  P_idrib:=v_idrib;

  EXCEPTION
  when others then null;--dbms_output.put_line('Erreur insertion RIB : '||SQLERRM);
  PK_TP_GROUPAMA.P_INS_journal(2,' F_CONFIRM_PEC RIB error ',SQLERRM);


END;


/* ABO 23/06/2010 Procédure de contrôle acte
mnemo des type d'acte : ACT-REGIME NGAP = 2 */
PROCEDURE P_SEL_natfrais(
  I_codfrais IN natfrais.rubrique%TYPE,
  I_type     IN natfrais.type%TYPE DEFAULT 2,
  O_Trouve   OUT boolean)
IS
--
  CURSOR C_natfrais IS
     SELECT rubrique
     FROM   natfrais
     WHERE  codfrais = I_codfrais
     AND    type     = I_type;
--
  Rec_C_natfrais C_natfrais%ROWTYPE;
--
BEGIN
  OPEN C_natfrais;
  FETCH C_natfrais INTO Rec_C_natfrais;
  IF C_natfrais%FOUND THEN
      O_Trouve := TRUE;
  ELSE
      O_Trouve := FALSE;
  END IF;
  CLOSE C_natfrais;
END;


/*ABO 23/06/2010 gs01 Charge la couverture de l'acte*/
PROCEDURE charge_cvrt (
  P_numindiv IN individu.numindiv%TYPE,
  P_codfrais IN natfrais.codfrais%TYPE,
  P_datsin IN date default sysdate,
  O_erreur  OUT  NUMBER
  )
  IS

  loc_numfor      number default 0;
  Cursor fetch_cvrt is
          SELECT  v_cvrt.idadhesion,
                  v_cvrt.numgar,
                  v_cvrt.numfor,
                  v_cvrt.datper,
                  v_cvrt.numorg,
                  v_cvrt.etat,
                  v_cvrt.motif,
                  v_cvrt.rang
          FROM    v_cvrt
          WHERE   v_cvrt.numindiv = P_numindiv
          AND     v_cvrt.typfor = 1
          AND     P_datsin BETWEEN v_cvrt.datapli AND nvl(v_cvrt.datper, P_datsin)
          ORDER BY  rang
          ;
  loc_cvrt    fetch_cvrt%ROWTYPE;
  L_trouve boolean;
BEGIN
  O_erreur := 0;

  FOR loc_cvrt IN fetch_cvrt LOOP
  --  message('Recherche codfrais sur garantie :
  -- '||to_char(loc_cvrt.numfor));
    BEGIN
      SELECT  numfor
      INTO    loc_numfor
      FROM    calcul
      WHERE   calcul.numfor = pk_qttc.F_sel_Numfor(loc_cvrt.numgar,loc_cvrt.numfor)
      and     calcul.codfrais = P_codfrais
      and     P_datsin between calcul.datapli
                       and     nvl(calcul.datper, P_datsin)
      and     calcul.datapli != nvl(calcul.datper, calcul.datapli + 1)
      ;
      EXCEPTION
      WHEN No_data_found THEN loc_numfor:= 0;
      WHEN Too_Many_Rows THEN loc_numfor:= 0;   /*La couverture de l'assuré est invalide : @ ... 676*/
    END;
    IF loc_numfor != 0 THEN
  --     message('Adhésion : '||to_char(loc_cvrt.idadhesion));
      /* :sntr.numfor := loc_cvrt.numfor;
       :sntr.numgar := loc_cvrt.numgar;
       :sntr.idadhesion := loc_cvrt.idadhesion;
       :sntr.etat := loc_cvrt.etat;
       :sntr.numorg := loc_cvrt.numorg;
       :sntr.rang := loc_cvrt.rang;
       :sntr.datper := loc_cvrt.datper;
       :sntr.motif := loc_cvrt.motif;*/

        /*P_CTRL_etat_cvrt
            (I_mnemo  => 'ETIN',
             I_code   => :sntr.etat,
             O_trouve => L_trouve,
             O_tab_libelle => L_tab_libelle);
       --
       IF L_trouve THEN
          L_Traitement_encours := 'P_CTRL_etat_cvrt - ET_CVRT - '||:sntr.motif;*/

        /*vérification de la situation de la garantie en passant par son motif de fermeture*/
        P_CTRL_etat_cvrt
                (I_mnemo  => 'ET_CVRT',
                 I_code   => loc_cvrt.motif,
                 O_trouve => L_trouve);
        IF L_trouve THEN O_erreur:=4; /*La couverture de l'assuré est invalide : @ ... 676*/
        END IF;
        EXIT; -- acte couvert par au moins une garantie
      END IF;

  END LOOP;

  IF (loc_numfor = 0) THEN O_erreur := 5; /* l'assuré n'est pas couvert à cette date 265*/
  END IF;
END;

/* gs01 ABO 24/06/2010 Vérifie qu'un code existe dans la table libelle en fonction du mnemo */
PROCEDURE P_CTRL_etat_cvrt(
  I_mnemo  IN libelle.mnemo%TYPE,
  I_code   IN libelle.code%TYPE,
  I_sens   IN libelle.sens%TYPE DEFAULT 0,
  O_trouve OUT BOOLEAN)
IS
--
  CURSOR C_etat_cvrt
  IS
     SELECT  lib.libelle
     FROM    libelle lib
     WHERE   lib.mnemo  = I_mnemo
     AND     lib.code   = I_code
     AND     NVL(lib.sens,0)  <> I_sens;
--
  Rec_C_etat_cvrt C_etat_cvrt%ROWTYPE;
--
BEGIN
  OPEN C_etat_cvrt;
  --
    FETCH C_etat_cvrt INTO Rec_C_etat_cvrt;
    IF C_etat_cvrt%FOUND THEN
        O_trouve := TRUE;
    ELSE
        O_trouve := FALSE;
    END IF;
  --
  CLOSE C_etat_cvrt;

END;
/*   P_exec_prescription; --forclusion de l'organisme

   P_exec_carte_tp; --
   */


/*23/06/2010 gs01 contrôle de couverture d'un bénéficiaire par une garantie d'un acte*/
FUNCTION F_CTRL_info_calcul (
  P_numindiv IN couverture.numindiv%TYPE,
  P_codfrais IN calcul.codfrais%TYPE,
  P_datsin   IN calcul.datper%TYPE
  ) RETURN NUMBER
IS
--
  CURSOR C_couverture IS
     SELECT numgar
     FROM   couverture
     WHERE  numindiv = P_numindiv
     AND EXISTS
          (SELECT 'X'
           FROM   calcul, defrub
           WHERE  calcul .numfor  = pk_qttc.f_sel_numfor(couverture.numgar,couverture.numfor)
           AND    defrub.numfor   = pk_qttc.f_sel_numfor(couverture.numgar,couverture.numfor)
           AND    calcul.codfrais = P_codfrais
           AND    defrub.codfrais =calcul.rubrique     -- M0005652 : ajout de la jointure et mise en commentaire des 4 lignes
      /*   AND    defrub.codfrais IN
                          /*(SELECT  rubrique
                           FROM    natfrais
                           WHERE   codfrais =  'LENJ'
                          )*/
           AND P_datsin BETWEEN defrub.datapli
                        AND NVL(defrub.datper,P_datsin)
           AND P_datsin BETWEEN calcul.datapli
                        AND  NVL(calcul.datper,P_datsin)
           AND defrub.datapli <>
                          NVL(defrub.datper,defrub.datapli+1)
           AND calcul.datapli <>
                          NVL(calcul.datper,calcul.datapli+1)
          )
  AND  datapli <= P_datsin
  AND  NVL(datper,P_datsin) >= P_datsin;

  --
  Rec_C_couverture C_couverture%ROWTYPE;
  L_etat           NUMBER;
  L_code_msg       NUMBER := 0;
  --
BEGIN
 OPEN C_couverture;
 FETCH C_couverture INTO Rec_C_couverture;
 IF C_couverture%NOTFOUND THEN  L_code_msg := 1;/* l'assuré n'est pas couvert à cette date 265*/
 ELSE
      LOOP
         L_etat := pk_histo_contrat.F_sel_etat
                          (I_numgar => Rec_C_couverture.numgar,
                           I_debut  => P_datsin);
         IF L_etat = 1 THEN
            L_code_msg := 0;
            EXIT;
         ELSE
           FETCH C_couverture INTO Rec_C_couverture;
           IF C_couverture%NOTFOUND THEN
              L_code_msg := 1;/*Aucun contrat valide à cette date*/
              EXIT;
           END IF;
         END IF;
      END LOOP;
 END IF;
 CLOSE C_couverture;
 RETURN (L_code_msg);
END;
/*ABO 25/06/2010 controle de couverture d'un acte*/
PROCEDURE P_CTRL_CVRT_ACTE(
  P_codfrais IN natfrais.rubrique%TYPE,
  P_numindiv IN individu.numindiv%TYPE,
  P_datsin   IN DATE,
  P_idadhesion IN adhe_cntrt.idadhesion%TYPE,
  O_couvert OUT BOOLEAN,
  O_erreur OUT NUMBER
)
IS
  loc_tp NUMBER :=0;
  loc_erreur NUMBER:=0;
BEGIN
  O_erreur := 0;
  O_couvert := FALSE;

  /*acte connu ?*/
  P_SEL_natfrais (P_codfrais,2,O_couvert);
  IF NOT O_couvert THEN
     O_erreur := 1; /*acte inconnu*/
     RETURN;
  END IF;

   /*date du sinistre cohérente ?*/
  IF trunc(P_datsin) > trunc(sysdate) THEN
     O_couvert := FALSE;
     O_erreur := 5; /*la date de l'acte ne peut être postérieure à la date du jour*/
     RETURN;
  END IF;

  /*acte TP ?*/
  -- XHUE mise en commentaire
  --loc_tp := pk_porte.F_carte_tp(P_numindiv,P_codfrais,P_datsin,P_idadhesion,NULL);
  --IF loc_tp = 0 THEN
  --   O_couvert := FALSE;
  --   O_erreur := 2; /*acte non TP ou acte non défini dans le domaine*/
  --   RETURN;
  --END IF;

  /* Acte couvert par au moins une garantie ?*/
  charge_cvrt (P_numindiv,P_codfrais, P_datsin,loc_erreur);
  IF loc_erreur <> 0 THEN
     O_erreur := 3;
     O_couvert := FALSE;
     RETURN;
  END IF;

  /*contrôle de couverture de l'acte par une garantie*/
  loc_erreur:= F_CTRL_info_calcul (P_numindiv,P_codfrais, P_datsin);
  IF loc_erreur <> 0 THEN
     O_couvert := FALSE;
     O_erreur := 4;
     RETURN;
  END IF;
  O_couvert := TRUE;
END;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_SINISTRE_PORTE                                      */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans SINISTRE_PORTE                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CREATE_DOSSIER_SANTE ( P_dossier_sante  IN DOSSIER_SANTE%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO DOSSIER_SANTE VALUES P_dossier_sante;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,' F_CREATE_DOSSIER_SANTE 3 P_dossier_sante.num_dossier:'||P_dossier_sante.num_dossier);
    RETURN FALSE;
END F_CREATE_DOSSIER_SANTE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_DOSSIER_SANTE                                       */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans SINISTRE_PORTE                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_DOSSIER_SANTE( P_numbene          IN  dossier_sante.numbene%TYPE
                            , P_numassu          IN  dossier_sante.numassu%TYPE
                            , P_numindiv         IN  dossier_sante.numindiv%TYPE
                            , P_numporte         IN  dossier_sante.numporte%TYPE
                            , P_devise           IN  dossier_sante.devise%TYPE
                            , P_devise_out       IN  dossier_sante.devise_out%TYPE
                            , P_numremise        IN  dossier_sante.numremise_sntrprt%TYPE)
RETURN NUMBER
IS

  loc_dossier_sante        DOSSIER_SANTE%ROWTYPE;
  loc_ret_dossier_sante    BOOLEAN:= FALSE;
  loc_user                 utilisateurs.numutil%TYPE;

BEGIN

  BEGIN
    SELECT numutil INTO loc_user from porte_param where numporte=P_numporte;
  EXCEPTION
    WHEN OTHERS THEN
      SELECT F_NUMUTIL INTO loc_user FROM DUAL;
  END;


  loc_dossier_sante.numbene:=P_numbene;
  loc_dossier_sante.numassu:=P_numassu;
  loc_dossier_sante.numporte:=P_numporte;
  loc_dossier_sante.numindiv:=P_numindiv;
  loc_dossier_sante.num_dossier:=PK_CALCUL_DOSSIER.F_NUM_DOSSIER(sysdate);
  loc_dossier_sante.ref_dossier:=loc_dossier_sante.num_dossier;
  loc_dossier_sante.typbene:=1;
  loc_dossier_sante.devise:=P_devise;
  loc_dossier_sante.devise_out:=P_devise_out;
  loc_dossier_sante.creation:=SYSDATE;
  loc_dossier_sante.dateouv:=SYSDATE;
  loc_dossier_sante.date_recept:=SYSDATE;
  loc_dossier_sante.numutil:=loc_user;
  loc_dossier_sante.nat_doss:=1;
  loc_dossier_sante.type_doss:=1;
  loc_dossier_sante.numprescrip:=NULL;
  loc_dossier_sante.pec:=0;
  loc_dossier_sante.num_dossier_porte:=loc_dossier_sante.num_dossier;
  loc_dossier_sante.numremise_sntrprt:=P_numremise;
  loc_dossier_sante.idadresse:=NULL;
  loc_dossier_sante.idrib:=NULL;
  loc_dossier_sante.maj:=NULL;
  loc_dossier_sante.numtiers:=NULL;
  loc_dossier_sante.num_dossier_pec:=NULL;
  loc_dossier_sante.num_fact_pec:=NULL;
  loc_dossier_sante.date_fact_pec:=NULL;
  loc_dossier_sante.num_entree_pec:=NULL;
  loc_dossier_sante.reseau:=NULL;

  loc_ret_dossier_sante:=F_CREATE_DOSSIER_SANTE(loc_dossier_sante);

  IF loc_ret_dossier_sante THEN
    RETURN loc_dossier_sante.num_dossier;
  ELSE
    RETURN 0;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_INS_DOSSIER_SANTE;


/*ABO 28/06/2010 insertion dossier_sante attention à la porte*/
PROCEDURE P_INS_DOSSIER_SANTE(
  P_ref IN dossier_sante.ref_dossier%TYPE,
  P_numindiv IN dossier_sante.numindiv%TYPE,
  P_PS IN dossier_sante.numbene%TYPE,
  P_numassu IN dossier_sante.numassu%TYPE,
  P_numporte IN dossier_sante.numporte%TYPE,
  P_natdoss  IN dossier_sante.nat_doss%TYPE,
  P_typedoss  IN dossier_sante.type_doss%TYPE,
  P_num_dossier_porte IN dossier_sante.num_dossier_porte%TYPE,
  O_num_dossier OUT dossier_sante.num_dossier%TYPE
)
IS
  loc_user       utilisateurs.numutil%TYPE;
  loc_nb_dossier NUMBER:=0;
  loc_typbene    dossier_sante.typbene%TYPE;
  loc_bene       dossier_sante.numbene%TYPE;
  loc_dossier_sante        DOSSIER_SANTE%ROWTYPE;
  loc_ret_dossier_sante    BOOLEAN:= FALSE;

  -- PHA 27/02/2018 5525: Erreur Beneficiaire de reglement specifique sur adhesion sur Dossier sante Externe
  CURSOR C_Find_Bene
  IS
    SELECT NVL(adhe_cntrt_membre.numbene, P_numassu)
      FROM adhe_cntrt , adhe_cntrt_membre , contrat
      WHERE adhe_cntrt_membre.idadhesion = adhe_cntrt.idadhesion
        AND adhe_cntrt_membre.numindiv   = P_numindiv
        AND contrat.numgar               = adhe_cntrt.numgar
        AND contrat.type_contrat         = 1
    ORDER BY NVL(date_fin_adhe, SYSDATE + 3000) DESC, date_adhe DESC;

BEGIN


  G_IDLIGNE := 0;

  -- P_INS_journal(1,' P_INS_DOSSIER_SANTE P_INS_DOSSIER_SANTE P_PS:'||P_PS);
  -- P_INS_journal(1,' P_INS_DOSSIER_SANTE P_INS_DOSSIER_SANTE P_numindiv:'||P_numindiv);
  --contrôle de doublon de PEC
  SELECT count(num_dossier) INTO loc_nb_dossier
  FROM DOSSIER_SANTE
  WHERE num_dossier_porte = P_num_dossier_porte
  AND numporte = P_numporte;
  IF loc_nb_dossier > 0 THEN
    O_num_dossier:=0;
    RETURN;
  END IF;

  BEGIN
    SELECT numutil INTO loc_user from porte_param where numporte=P_numporte;
  EXCEPTION
    WHEN OTHERS THEN
      SELECT F_NUMUTIL INTO loc_user FROM DUAL; --user xml spécifique
  END;
  SELECT PK_CALCUL_DOSSIER.F_NUM_DOSSIER(sysdate) into O_num_dossier FROM DUAL;

 -- P_INS_journal(1,' P_INS_DOSSIER_SANTE P_INS_DOSSIER_SANTE loc_user:'||loc_user);
  glb_devise:=F_FIND_DEVISE;

  --récupération du paramétrage de la porte
  BEGIN
    SELECT typbene,NVL(numbene, P_PS)
    INTO loc_typbene,loc_bene
    FROM porte_param
    WHERE numporte = P_numporte;
  EXCEPTION
    WHEN OTHERS THEN
      loc_bene :=P_PS;
      loc_typbene := 4;
  END;

  -- Cas benef = assuré : Récupération du benef de règlement si renseigné sinon assuré principal
  IF loc_typbene = 1 THEN
    BEGIN
      OPEN C_Find_Bene;
      FETCH C_Find_Bene INTO loc_bene;

     IF (C_Find_Bene%NOTFOUND) THEN
       loc_bene:=P_numassu;
     END IF;

     CLOSE C_Find_Bene;

    EXCEPTION WHEN OTHERS THEN
      loc_bene:=P_numassu;
      CLOSE C_Find_Bene;
    END;
  END IF;

 -- P_INS_journal(1,' P_INS_DOSSIER_SANTE P_INS_DOSSIER_SANTE avant loc_dossier:'||O_num_dossier);

  loc_dossier_sante.numbene:=loc_bene;
  loc_dossier_sante.numassu:=P_numassu;
  loc_dossier_sante.numporte:=P_numporte;
  loc_dossier_sante.numindiv:=P_numindiv;
  loc_dossier_sante.num_dossier:=O_num_dossier;
  loc_dossier_sante.ref_dossier:=P_ref;
  loc_dossier_sante.typbene:=loc_typbene;
  loc_dossier_sante.devise:=glb_devise;
  loc_dossier_sante.devise_out:=glb_devise;
  loc_dossier_sante.creation:=SYSDATE;
  loc_dossier_sante.dateouv:=SYSDATE;
  loc_dossier_sante.date_recept:=SYSDATE;
  loc_dossier_sante.numutil:=loc_user;
  loc_dossier_sante.nat_doss:=P_natdoss;
  loc_dossier_sante.type_doss:=P_typedoss;
  loc_dossier_sante.numprescrip:=P_PS;
  loc_dossier_sante.pec:=0;
  loc_dossier_sante.num_dossier_porte:=P_num_dossier_porte;
  loc_dossier_sante.numremise_sntrprt:=NULL;
  loc_dossier_sante.idadresse:=0;
  loc_dossier_sante.idrib:=0;
  loc_dossier_sante.maj:=NULL;
  loc_dossier_sante.numtiers:=NULL;
  loc_dossier_sante.num_dossier_pec:=NULL;
  loc_dossier_sante.num_fact_pec:=NULL;
  loc_dossier_sante.date_fact_pec:=NULL;
  loc_dossier_sante.num_entree_pec:=NULL;
  loc_dossier_sante.reseau:=NVL(F_SENS_LIBELLE('PORTE',P_numporte),P_numporte);  -- réseau de soins

  loc_ret_dossier_sante:=F_CREATE_DOSSIER_SANTE(loc_dossier_sante);


EXCEPTION
  WHEN OTHERS THEN
     O_num_dossier:=0;
     P_INS_journal(1,' WHEN OTHERS THEN P_INS_DOSSIER_SANTE' );
END P_INS_DOSSIER_SANTE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_HISTO_DOSSIER                                       */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans HISTO_DOSSIER                   */
/* Retour       :                                                            */
/* evolution    : JBO, 14022017, gestion du numutil en fonction du dossier   */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_HISTO_DOSSIER(
  P_num_dossier IN dossier_sante.num_dossier%TYPE,
  P_etat IN histo_dossier.etat%TYPE,
  P_motif IN histo_dossier.motif%TYPE,
  P_date IN histo_dossier.debut%TYPE DEFAULT SYSDATE
)IS

  loc_user     DOSSIER_SANTE.NUMUTIL%TYPE:=NULL;

BEGIN


  BEGIN
    SELECT numutil INTO loc_user from dossier_sante where num_dossier=P_num_dossier;    -- recupére le numutil du dossier créé en amont
  EXCEPTION
    WHEN OTHERS THEN
      SELECT F_NUMUTIL INTO loc_user FROM DUAL;
  END;


  --dbms_output.put_line('P_INS_HISTO_DOSSIER :'||P_num_dossier ||SQLERRM);
  INSERT INTO HISTO_DOSSIER (num_dossier,debut,datsai,etat,motif,numutil)
  SELECT P_num_dossier,P_date,SYSDATE,P_etat,P_motif,loc_user  FROM DUAL;

END P_INS_HISTO_DOSSIER;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_SNTR_SANTE                                          */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans SINISTRE_SANTE                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_SNTR_SANTE ( P_sinistre_sante  IN SINISTRE_SANTE%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO SINISTRE_SANTE VALUES P_sinistre_sante;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_INS_SNTR_SANTE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_SNTR_SANTE                                          */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans SINISTRE_SANTE                  */
/* Retour       :                                                            */
/* evolution    : JBO, 14022017, gestion du numutil en fonction du dossier   */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_SNTR_SANTE(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne IN sinistre_sante.numligne%TYPE,
  P_numindiv IN sinistre_sante.numindiv%TYPE,
  P_codfrais IN sinistre_sante.codfrais%TYPE,
  P_mtfrais IN sinistre_sante.mtfrais%TYPE,
  P_etat IN sinistre_sante.situation%TYPE,
  P_taux IN sinistre_sante.taux%TYPE,
  P_baseremb IN sinistre_sante.baseremb%TYPE,
  P_mtremb IN sinistre_sante.mtremb%TYPE,
  P_datsin IN DATE,
  P_coeff IN sinistre_sante.coeff%TYPE,
  P_quantite IN sinistre_sante.quantite%TYPE DEFAULT 1,
  P_devise IN sinistre_sante.devise_in%TYPE DEFAULT 1,
  P_deviseout IN sinistre_sante.devise_out%TYPE DEFAULT 1,
  P_numutil IN sinistre_sante.numutil%TYPE DEFAULT 0,
  P_numorg IN sinistre_sante.numorg%TYPE DEFAULT NULL,
  P_numfact IN facture.numfact%TYPE DEFAULT NULL,
  P_numsin_sntrprt IN sinistre_sante.numsin_sntrprt%TYPE DEFAULT NULL,
  P_pays        IN SINISTRE_SANTE.codpays%TYPE DEFAULT 1,
  p_pdsqls      IN SINISTRE_SANTE.pdsqls%TYPE DEFAULT 1,
  p_spe_exe     IN SINISTRE_SANTE.spe_exe%TYPE DEFAULT '01' ,
  p_autre_rb    IN SINISTRE_SANTE.AUTRB%TYPE DEFAULT 0,
  p_autre_rb_d  IN SINISTRE_SANTE.AUTRB_DAUTRB%TYPE DEFAULT 0,
  P_bloc IN sinistre_sante.blocage%TYPE DEFAULT 0 --RKO RAC OPTIQUE BLOCAGE
)
IS
  loc_user     DOSSIER_SANTE.NUMUTIL%TYPE:=NULL;

BEGIN

  BEGIN
    SELECT numutil INTO loc_user from dossier_sante where num_dossier=P_num_dossier;    -- recupére le numutil du dossier créé en amont
  EXCEPTION
    WHEN OTHERS THEN
      SELECT F_NUMUTIL INTO loc_user FROM DUAL;
  END;

  glb_devise:=F_FIND_DEVISE;

  INSERT INTO SINISTRE_SANTE( num_dossier,
                              numligne,
                              numindiv,
                              datsin,
                              codpays,
                              codfrais,
                              quantite,
                              coeff,
                              devise_in,
                              devise_out,
                              devise_autrb,
                              mtfrais_in,
                              mtfrais,
                              situation,
                              taux,
                              baseremb,
                              mtremb,
                              creation,
                              numutil,
                              blocage,
                              exclusion,
                              numsin_sntrprt,
                              reference,
                              pdsqls,
                              spe_exe,
                              autrb,
                              autrb_dautrb)
        VALUES ( P_num_dossier,
                 P_numligne,
                 P_numindiv,
                 P_datsin,
                 1,
                 P_codfrais,
                 P_quantite,
                 P_coeff,
                 glb_devise,
                 glb_devise,
                 glb_devise,
                 P_mtfrais,
                 P_mtfrais,
                 P_etat,
                 P_taux,
                 P_baseremb,
                 P_mtremb,
                 sysdate,
                 loc_user,
                 P_bloc , --0, RKO RAC OPTIQUE BLOCAGE
                 0,
                 P_numsin_sntrprt,
                 F_REFEXT_FACTURE(P_numfact,12),
                 p_pdsqls,
                 p_spe_exe,
                 p_autre_rb,
                 p_autre_rb_d);

END P_INS_SNTR_SANTE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_UPD_SNTR_SANTE                                          */
/* Type         :  Public                                                    */
/* Description  :  fonction de mise a jour dans SINISTRE_SANTE               */
/* Retour       :                                                            */
/* evolution    : JBO, 14022017, gestion du numutil en fonction du dossier   */
/*---------------------------------------------------------------------------*/
PROCEDURE P_UPD_SNTR_SANTE(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne IN sinistre_sante.numligne%TYPE,
  P_mtremb IN sinistre_sante.mtremb%TYPE,
  P_mtprest IN sinistre_sante.mtprest%TYPE,
  P_etat IN sinistre_sante.situation%TYPE
)IS
  loc_user     DOSSIER_SANTE.NUMUTIL%TYPE:=NULL;

BEGIN

  BEGIN
    SELECT numutil INTO loc_user from dossier_sante where num_dossier=P_num_dossier;    -- recupére le numutil du dossier créé en amont
  EXCEPTION
    WHEN OTHERS THEN
      SELECT F_NUMUTIL INTO loc_user FROM DUAL;
  END;

  UPDATE SINISTRE_SANTE SET
    mtremb = P_mtremb,
    mtprest= P_mtprest,
    situation= P_etat,
    maj= sysdate  ,
    numutil_modif = loc_user
  WHERE num_dossier = P_num_dossier
  AND numligne = P_numligne;
END;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_UPD_SNTR_SANTE_REMB                                     */
/* Type         :  Public                                                    */
/* Description  :  Permet de mettre a jour le montant rembourser             */
/* Entree       :  P_num_dossier                                             */
/*---------------------------------------------------------------------------*/
PROCEDURE P_UPD_SNTR_SANTE_REMB ( P_num_dossier  IN   SINISTRE_SANTE.NUM_DOSSIER%TYPE
                                 ,P_numligne     IN   SINISTRE_SANTE.NUMLIGNE%TYPE
                                 ,P_mtremb       IN   SINISTRE_SANTE.MTREMB%TYPE
                                 ,P_baseremb     IN   SINISTRE_SANTE.BASEREMB%TYPE
                                 ,P_taux         IN   SINISTRE_SANTE.TAUX%TYPE)
IS
BEGIN

  UPDATE SINISTRE_SANTE ss
    SET ss.MTREMB=ss.MTREMB + P_mtremb,
        ss.BASEREMB=ss.BASEREMB + P_baseremb
  WHERE ss.NUM_DOSSIER=P_num_dossier
    AND ss.NUMLIGNE=P_numligne;

END P_UPD_SNTR_SANTE_REMB;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_HISTO_SNTR_SANTE                                    */
/* Type         :  Public                                                    */
/* Description  :  insertion des localisations dentaires dans SINISTRE_SANTE */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_SNTR_SANTE_LOCDEN(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne  IN sinistre_sante.numligne%TYPE,
  P_LOCDENT1  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT2  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT3  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT4  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT5  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT6  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT7  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT8  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT9  IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT10 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT11 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT12 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT13 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT14 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT15 IN sinistre_sante.LOCDENT1%TYPE,
  P_LOCDENT16 IN sinistre_sante.LOCDENT1%TYPE
)
IS
  loc_user     DOSSIER_SANTE.NUMUTIL%TYPE:=NULL;

BEGIN

  BEGIN
    SELECT numutil INTO loc_user from dossier_sante where num_dossier=P_num_dossier;    -- recupére le numutil du dossier créé en amont
  EXCEPTION
    WHEN OTHERS THEN
      SELECT F_NUMUTIL INTO loc_user FROM DUAL;
  END;



  UPDATE SINISTRE_SANTE SET
          LOCDENT1 = DECODE (P_LOCDENT1,0,null,P_LOCDENT1)
        , LOCDENT2 = DECODE (P_LOCDENT2,0,null,P_LOCDENT2)
        , LOCDENT3 = DECODE (P_LOCDENT3,0,null,P_LOCDENT3)
        , LOCDENT4 = DECODE (P_LOCDENT4,0,null,P_LOCDENT4)
        , LOCDENT5 = DECODE (P_LOCDENT5,0,null,P_LOCDENT5)
        , LOCDENT6 = DECODE (P_LOCDENT6,0,null,P_LOCDENT6)
        , LOCDENT7 = DECODE (P_LOCDENT7,0,null,P_LOCDENT7)
        , LOCDENT8 = DECODE (P_LOCDENT8,0,null,P_LOCDENT8)
        , LOCDENT9 = DECODE (P_LOCDENT9,0,null,P_LOCDENT9)
        , LOCDENT10= DECODE (P_LOCDENT10,0,null,P_LOCDENT10)
        , LOCDENT11= DECODE (P_LOCDENT11,0,null,P_LOCDENT11)
        , LOCDENT12= DECODE (P_LOCDENT12,0,null,P_LOCDENT12)
        , LOCDENT13= DECODE (P_LOCDENT13,0,null,P_LOCDENT13)
        , LOCDENT14= DECODE (P_LOCDENT14,0,null,P_LOCDENT14)
        , LOCDENT15= DECODE (P_LOCDENT15,0,null,P_LOCDENT15)
        , LOCDENT16= DECODE (P_LOCDENT16,0,null,P_LOCDENT16)
        , numutil_modif = loc_user
  WHERE num_dossier = P_num_dossier
    AND numligne = P_numligne;


END P_MAJ_SNTR_SANTE_LOCDEN;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_HISTO_SNTR_SANTE                                    */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans HISTO_SINISTRE_SANTE            */
/* Retour       :                                                            */
/* evolution    : JBO, 14022017, gestion du numutil en fonction du dossier   */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_HISTO_SNTR_SANTE(
  P_num_dossier IN histo_sinistre_sante.num_dossier%TYPE,
  P_numligne IN histo_sinistre_sante.numligne%TYPE,
  P_etat IN histo_sinistre_sante.etat%TYPE,
  P_motif IN histo_sinistre_sante.motif%TYPE
)
IS
  loc_user     DOSSIER_SANTE.NUMUTIL%TYPE:=NULL;

BEGIN

  BEGIN
    SELECT numutil INTO loc_user from dossier_sante where num_dossier=P_num_dossier;    -- recupére le numutil du dossier créé en amont
  EXCEPTION
    WHEN OTHERS THEN
      SELECT F_NUMUTIL INTO loc_user FROM DUAL;
  END;



  INSERT INTO HISTO_SINISTRE_SANTE (histo_sntr_sante,num_dossier,numligne,etat,motif,datetat,numutil)
  SELECT HISTO_SNTR_SANTE.nextval,P_num_dossier,P_numligne,P_etat,P_motif,sysdate,loc_user  FROM DUAL;

  UPDATE SINISTRE_SANTE
  SET situation = P_etat
  WHERE num_dossier = P_num_dossier
  AND numligne = P_numligne;


END P_INS_HISTO_SNTR_SANTE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_DOSSIER_BY_ASSU                                    */
/* Type         :  Public                                                    */
/* Description  :  Recherche si un dossier est déjà existant en fonction du  */
/*                 du bénéficiaire et de la devise                           */
/* Entree       :  P_numremise, P_Numbene, P_Numassu, P_devise, P_deviseOut  */
/* Retour       :  loc_numdossier                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_DOSSIER_BY_ASSU ( P_Numremise     IN   DOSSIER_SANTE.NUMREMISE_SNTRPRT%TYPE
                                , P_Numindiv      IN   DOSSIER_SANTE.NUMINDIV%TYPE
                                , P_Numassu       IN   DOSSIER_SANTE.NUMASSU%TYPE
                                , P_devise        IN   DOSSIER_SANTE.DEVISE%TYPE
                                , P_deviseOut     IN   DOSSIER_SANTE.DEVISE_OUT%TYPE)
RETURN NUMBER
IS

  loc_numdossier        DOSSIER_SANTE.NUM_DOSSIER%TYPE;

BEGIN

  SELECT NVL(ds.num_dossier, 0)
    INTO loc_numdossier
    FROM DOSSIER_SANTE ds
   WHERE ds.numindiv            = NVL(P_Numindiv, ds.numbene)
    -- AND ds.numassu            = NVL(P_Numassu, ds.numassu)
     AND ds.numremise_sntrprt  = P_Numremise
     --AND ds.devise             = NVL(P_devise, ds.devise)
     AND ds.devise_out         = NVL(P_deviseOut, ds.devise_out)
   ;

  RETURN loc_numdossier;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    RETURN -1;
END F_FIND_DOSSIER_BY_ASSU;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_NUMDOSSIER                                         */
/* Type         :  Public                                                    */
/* Description  :  Recherche du dossier de PEC à partir de la reférence      */
/*                 externe du dossier                                        */
/* Entree       :  P_ref_dossier                                             */
/* Retour       :  loc_numdossier                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_NUMDOSSIER ( P_ref_dossier IN dossier_sante.REF_DOSSIER%TYPE )
RETURN dossier_sante.num_dossier%TYPE
IS

  loc_numdossier        DOSSIER_SANTE.NUM_DOSSIER%TYPE;

BEGIN

  SELECT NVL(ds.num_dossier, 0)
    INTO loc_numdossier
    FROM DOSSIER_SANTE ds
   WHERE ds.REF_DOSSIER = NVL(P_ref_dossier, ds.REF_DOSSIER)
     AND ds.TYPE_DOSS    = 4 -- Prise en charge
   ;

  RETURN loc_numdossier;


EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_FIND_NUMDOSSIER;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_PATIENT                                           */
/* Type         :  Public                                                    */
/* Description  :  Controle du numéro de bénéficiaire a partir du numéro de  */
/*                 l assure et des informations du bénéficaire               */
/* Entree       :  P_numindiv                                                */
/*                 P_matorgassu                                              */
/*                 P_nom                                                     */
/*                 P_prenom                                                  */
/*                 P_datnais                                                 */
/* Retour       :  Numindiv                                                  */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_PATIENT( P_numassu         IN  INDIVIDU.NUMINDIV%TYPE DEFAULT NULL
                       , P_matorgassu      IN  INDIVIDU.MATORG%TYPE DEFAULT NULL
                       , P_nom             IN  INDIVIDU.NOM%TYPE DEFAULT NULL
                       , P_prenom          IN  INDIVIDU.PRENOM%TYPE DEFAULT NULL
                       , P_datnais         IN  INDIVIDU.DATNAIS%TYPE DEFAULT NULL
                       , P_numindiv        IN  INDIVIDU.NUMINDIV%TYPE DEFAULT NULL)
RETURN NUMBER
IS

  loc_numindiv        INDIVIDU.NUMINDIV%TYPE:=NULL;

BEGIN


  BEGIN
    SELECT NVL(i.numindiv,0)
      INTO loc_numindiv
      FROM individu i
     WHERE i.numindiv=P_numindiv
       AND i.numassu=P_numassu
       ;
     RETURN loc_numindiv;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        -- Recherche du bénéficiaire a partir du numéro de sécu de l assuré principal, du nom et du prénom
        SELECT NVL(ayd.numindiv,0)
          INTO loc_numindiv
          FROM individu od, individu ayd
         WHERE od.numindiv = NVL(P_numassu,od.numindiv)
           AND od.matorg = NVL(SUBSTR(P_matorgassu,0,13),od.matorg)
           AND (od.cless = NVL(SUBSTR(P_matorgassu,14),od.cless) OR od.cless IS NULL)
           AND ayd.numassu= od.numassu
           AND ayd.datnais=P_datnais
           ;
      EXCEPTION
          -- Recherche du bénéficiaire jumeau a partir du numéro de sécu de l assuré principal, du nom, du prénom et de la date de naissance
        WHEN OTHERS THEN
          SELECT NVL(ayd.numindiv,0)
            INTO loc_numindiv
            FROM individu od, individu ayd
           WHERE od.numindiv = NVL(P_numassu,od.numindiv)
             AND od.matorg = NVL(SUBSTR(P_matorgassu,0,13),od.matorg)
             AND (od.cless = NVL(SUBSTR(P_matorgassu,14),od.cless) OR od.cless IS NULL)
             --AND od.nom=P_nom
             AND ayd.numassu= od.numassu
             AND ayd.prenom=P_prenom
             AND ayd.datnais=P_datnais
             ;
          RETURN loc_numindiv;
      END;
  END;
  RETURN loc_numindiv;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_FIND_PATIENT;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_BENE                                               */
/* Type         :  Public                                                    */
/* Description  :  Controle du numéro de bénéficiaire a partir du numéro de  */
/*                 l assure et des informations du bénéficaire               */
/* Entree       :  P_numindiv                                                */
/* Retour       :  Numbene                                                   */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_BENE( P_numindiv        IN  INDIVIDU.NUMINDIV%TYPE)
RETURN NUMBER
IS

  loc_numbene        ADHE_CNTRT_MEMBRE.NUMBENE%TYPE:=NULL;

BEGIN

  SELECT DISTINCT ADHE_CNTRT_MEMBRE.NUMBENE
    INTO loc_numbene
    FROM ADHE_CNTRT_MEMBRE, ADHESION
   WHERE ((ADHESION.NUMINDIV = ADHE_CNTRT_MEMBRE.NUMINDIV)
     AND (ADHESION.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION)
     AND (P_numindiv = ADHESION.NUMINDIV));

  RETURN loc_numbene;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END F_FIND_BENE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_COURR_DEST                                          */
/* Type         :  Public                                                    */
/* Description  :  Permet d insérer le destinataire du courrier suite a la   */
/*                 création d un dossier santé                               */
/* Entree       :  P_num_dossier                                             */
/*                 P_numindiv                                                */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_COURR_DEST(P_num_dossier IN COURR_DEST.ID%TYPE,
                           P_numindiv    IN COURR_DEST.NUMINDIV%TYPE
)
IS
BEGIN

  INSERT INTO COURR_DEST(ID, CODE, TYPE, NUMINDIV, NATURE, VALIDE)
       VALUES (P_num_dossier, 28, 15, P_numindiv, 1, 1);

END P_INS_COURR_DEST;



/*ABO 18/07/2010 Fonction qui retourne vrai si le dossier existe*/
FUNCTION F_FIND_DOSSIER(
  P_num_dossier IN dossier_sante.num_dossier%TYPE,
  P_numindiv IN OUT dossier_sante.numindiv%TYPE
)RETURN BOOLEAN IS
  V_num  dossier_sante.num_dossier%TYPE;
BEGIN
  SELECT num_dossier, numindiv INTO V_num, P_numindiv
  FROM dossier_sante
  WHERE numindiv = NVL(P_numindiv,numindiv)
  AND num_dossier = P_num_dossier;

  RETURN TRUE;

  EXCEPTION
    WHEN no_data_found THEN RETURN FALSE;

END F_FIND_DOSSIER;

FUNCTION F_FIND_REF_DOSSIER(
  P_ref_dossier IN dossier_sante.REF_DOSSIER%TYPE,
  P_numindiv IN OUT dossier_sante.numindiv%TYPE
)RETURN dossier_sante.num_dossier%TYPE
 IS
  V_num  dossier_sante.num_dossier%TYPE;
BEGIN
  SELECT num_dossier, numindiv INTO V_num, P_numindiv
  FROM dossier_sante
  WHERE numindiv = NVL(P_numindiv,numindiv)
  AND REF_DOSSIER = P_ref_dossier;

  RETURN V_num;

  EXCEPTION
    WHEN no_data_found THEN RETURN 0;

END F_FIND_REF_DOSSIER;


/*ABO 18/07/2010 Fonction qui retourne les infos du dossier*/
PROCEDURE P_INFO_DOSSIER(
  P_num_dossier_liq IN OUT dossier_sante.num_dossier%TYPE,
  O_num_fact_pec OUT dossier_sante.num_fact_pec%TYPE,
  O_date_fact_pec OUT dossier_sante.date_fact_pec%TYPE,
  O_num_dossier_pec OUT dossier_sante.num_dossier_pec%TYPE,
  O_num_dossier_porte OUT dossier_sante.num_dossier_porte%TYPE
) IS
  V_num  dossier_sante.num_dossier%TYPE;
BEGIN
  SELECT num_fact_pec ,creation,num_dossier_pec,num_dossier_porte
  INTO O_num_fact_pec,O_date_fact_pec,O_num_dossier_pec,O_num_dossier_porte
  FROM dossier_sante
  WHERE num_dossier = P_num_dossier_liq;

  EXCEPTION
    WHEN no_data_found THEN P_num_dossier_liq:= NULL;

END P_INFO_DOSSIER;

/*20/08/2010 Fonction vérifiant si au moins un sinsitre est décompté*/
FUNCTION F_FIND_SNTR_DCPT(
   P_num_dossier IN dossier_sante.num_dossier%TYPE
)RETURN NUMBER IS

  CURSOR C_sntr IS
    SELECT s.numsin
    FROM SINISTRE s , SNTR_DOSSIER d
    WHERE d.num_dossier = P_num_dossier
    AND d.numsin_sntr  = s.numsin
    AND s.numdec <>0;

  Rec_C_sntr C_sntr%ROWTYPE;

BEGIN
    OPEN C_sntr;
    FETCH C_sntr into Rec_C_sntr;
    IF C_sntr%FOUND THEN
      CLOSE C_sntr;
      RETURN 1;
    ELSE
      CLOSE C_sntr;
      RETURN 0;
    END IF;
END F_FIND_SNTR_DCPT;

/*20/08/2010 Fonction vérifiant si au moins un sinsitre_sante est annulé*/
FUNCTION F_FIND_SNTR_ANNUL(
   P_num_dossier IN dossier_sante.num_dossier%TYPE
)RETURN NUMBER IS

  CURSOR C_sntr_sante IS
    SELECT numligne
    FROM SINISTRE_SANTE
    WHERE num_dossier = P_num_dossier
    AND F_ETAT_SINISTRE_SANTE(num_dossier,numligne,sysdate,1)=4;

  Rec_C_sntr_sante C_sntr_sante%ROWTYPE;

BEGIN
    OPEN C_sntr_sante;
    FETCH C_sntr_sante into Rec_C_sntr_sante;
    IF C_sntr_sante%FOUND THEN
      CLOSE C_sntr_sante;
      RETURN 1;
    ELSE
      CLOSE C_sntr_sante;
      RETURN 0;
    END IF;
END F_FIND_SNTR_ANNUL;


/*23/08/2010 Pocedure d'annulation d'un dossier*/
PROCEDURE P_ANNUL_DOSSIER(
   P_num_dossier IN dossier_sante.num_dossier%TYPE,
   P_motif IN NUMBER default 1
) IS

  CURSOR C_sntr_sante IS
    SELECT numligne
    FROM SINISTRE_SANTE
    WHERE num_dossier = P_num_dossier;

  Rec_C_sntr_sante C_sntr_sante%ROWTYPE;

  CURSOR C_sntr_sinistre IS
    SELECT numsin_sntr
    FROM SNTR_DOSSIER
    WHERE num_dossier = P_num_dossier;

  Rec_C_sntr_sinistre C_sntr_sinistre%ROWTYPE;

BEGIN
    -- suppression des détails d une pec (optique:sphere, addition,aminci...)
    DELETE PEC_DETAILS WHERE NUMDOSSIER=P_num_dossier;
    --susppression des sinitres
    FOR  Rec_C_sntr_sinistre in C_sntr_sinistre LOOP
     DELETE FROM sinistre
     WHERE numsin = Rec_C_sntr_sinistre.numsin_sntr;
    END LOOP;

    --suppresion des sntr_dossier
    DELETE FROM SNTR_DOSSIER
    WHERE num_dossier = P_num_dossier;

    --annulation des sinitre_sante
    FOR  Rec_C_sntr_sante in C_sntr_sante LOOP
     P_INS_HISTO_SNTR_SANTE(P_num_dossier,Rec_C_sntr_sante.numligne,4,1); --HISTO_DL4 sans motif
    END LOOP;

    --fermeture du dossier
   P_INS_HISTO_DOSSIER(P_num_dossier,1,NVL(P_motif,1)); --HISTO_D1 fermé sans recours

   --mise a jour de la date de fermeture du dossier
   UPDATE DOSSIER_SANTE
   SET DATEFERM = sysdate
   WHERE num_dossier = P_num_dossier;

END P_ANNUL_DOSSIER;

/*ABO 15//11/2010 Procédure mettant à jour la ref_externe de l'individu concerné par le dossier*/
PROCEDURE P_MAJ_REF_EXTERNE(
        P_numindiv IN individu.numindiv%TYPE,
        P_domaine  IN VARCHAR2,
        P_num_dossier IN dossier_sante.num_dossier%TYPE default null,
        P_tiers IN VARCHAR2,
        P_mnemo IN VARCHAR2) IS
  loc_natdoss dossier_sante.nat_doss%TYPE;
  loc_domaine transco.val_ext%TYPE;
  loc_ref transco.val_ext%TYPE;
BEGIN
  IF P_num_dossier IS NOT NULL THEN
    BEGIN
      --lors d'annulation on enlève l'information sur la nature du dossier de la référence
      -- recherche du type de dossier
      SELECT nat_doss INTO loc_natdoss
      FROM DOSSIER_SANTE d
      WHERE d.num_dossier = P_num_dossier;

      -- nature du dossier optique ou dentaire ?
      loc_domaine :=F_get_transco(P_tiers,'NAT_DOSS',loc_natdoss,2);

      -- transco ajouté dans refcie de l'individu à la création du dossier
      loc_ref := F_get_transco(P_tiers,P_mnemo,loc_domaine,1);

      UPDATE INDIVIDU SET refcie = regexp_replace(refcie,'\'||loc_ref,'',1,1)
      WHERE numindiv = P_numindiv;

      EXCEPTION
        WHEN OTHERS THEN NULL; --declenché si la taille dépasse les 30 caractères
    END;
  ELSE
    BEGIN
      --on ajoute une info sur la nature du dossier dans la référence externe
      UPDATE individu SET refcie = refcie || P_domaine
      WHERE numindiv = P_numindiv;
    EXCEPTION
      WHEN OTHERS THEN NULL; -- cas où on depasse les 30 caractères max
    END;


  END IF;
END P_MAJ_REF_EXTERNE;


/*ABO 18/07/2010 Fonction de recherche de la devise paramétrée par défaut*/
FUNCTION F_FIND_DEVISE RETURN NUMBER IS
  loc_devise number;
BEGIN
 SELECT dfdev INTO loc_devise FROM parametres;
 RETURN loc_devise;
 EXCEPTION
  WHEN no_data_found THEN RETURN NULL;
END F_FIND_DEVISE;


/*ABO 20/07/2010 fonction de transcodification d'un code acte externe en code acte Arthus*/
-- fonction provenant de TRG_BF_INS_SINSITRE_PORTE, elle ne prend pas en compte les spécialités médicales
FUNCTION F_TRANSCO_CODFRAIS(
        P_codfrais_porte IN VARCHAR2,
        P_regime IN NUMBER,
        P_spec IN VARCHAR2,
        P_porte IN NUMBER,
        P_action OUT NUMBER)
RETURN VARCHAR2
IS

  loc_secteur NUMBER(2);
  loc_zone NUMBER(2);
  loc_codfrais porte_natfrais.codfrais%TYPE := NULL;

BEGIN

  loc_secteur := 1;
  loc_zone := 0;

  SELECT nvl(decode(loc_secteur, 2, codfrais_porte_nc, codfrais), codfrais), action
  INTO  loc_codfrais, P_action
  FROM  PORTE_NATFRAIS p
  WHERE numporte = P_porte
  AND   codfrais_porte = P_codfrais_porte
  AND   regime = NVL(P_regime, 1)
  AND  (code_spec = P_spec OR
        (code_spec  = '00'
         AND P_spec  <> '00'
         AND NOT EXISTS (SELECT 1
                         FROM porte_natfrais
                         WHERE numporte = P_porte
                         AND   codfrais_porte = P_codfrais_porte
                         AND   regime = NVL(P_regime, 1)
                         AND   code_spec = P_spec)
        )
       )
  AND   code_zone IN (loc_zone, 0)
  AND   EXISTS (SELECT 1
                FROM natfrais n
                WHERE n.codfrais = DECODE(loc_secteur, 2, p.codfrais_porte_nc, p.codfrais))
  -- Ajouter critères sur les montants ??? TO DO
  ;
  RETURN loc_codfrais;

EXCEPTION
  WHEN OTHERS THEN
       return NULL;
END F_TRANSCO_CODFRAIS;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_TRANSCO_CODFRAIS_GAR                                    */
/* Type         :  Public                                                    */
/* Description  :  procedure de transcodification d'un code acte externe en  */
/*                 code acte Arthus  sans détail acte                        */
/* Retour       :  Retourne les code acte                                    */


/*---------------------------------------------------------------------------*/
-- fonction provenant de TRG_BF_INS_SINSITRE_PORTE, elle ne prend pas en compte les spécialités médicales
FUNCTION F_TRANSCO_CODFRAIS_GAR(
        P_codfrais_porte IN VARCHAR2,
        P_regime IN NUMBER,
        P_spec IN VARCHAR2,
        P_porte IN NUMBER,
        P_numfor IN formule.numfor%TYPE,
        P_datsin IN DATE,
        P_action OUT NUMBER)
RETURN VARCHAR2
IS

  loc_secteur NUMBER(2);
  loc_zone NUMBER(2);
  loc_codfrais porte_natfrais.codfrais%TYPE := NULL;

BEGIN

  loc_secteur := 1;
  loc_zone := 0;

  SELECT nvl(decode(loc_secteur, 2, p.codfrais_porte_nc, p.codfrais), p.codfrais), action
  INTO  loc_codfrais, P_action
  FROM  PORTE_NATFRAIS p, calcul c
  WHERE numporte = P_porte
  AND   codfrais_porte = P_codfrais_porte
  AND   regime = NVL(P_regime, 1)
  AND   c.codfrais = p.codfrais
  AND   c.numfor =P_numfor
  AND  P_datsin BETWEEN c.datapli and NVL(c.datper,P_datsin)
  AND  (code_spec = P_spec OR
        (code_spec  = '00'
         AND P_spec  <> '00'
         AND NOT EXISTS (SELECT 1
                         FROM porte_natfrais
                         WHERE numporte = P_porte
                         AND   codfrais_porte = P_codfrais_porte
                         AND   regime = NVL(P_regime, 1)
                         AND   code_spec = P_spec)
        )
       )
  AND   code_zone IN (loc_zone, 0)
  AND   EXISTS (SELECT 1
                FROM natfrais n
                WHERE n.codfrais = DECODE(loc_secteur, 2, p.codfrais_porte_nc, p.codfrais))
  -- Ajouter critères sur les montants ??? TO DO
  ;
  RETURN loc_codfrais;

EXCEPTION
  WHEN OTHERS THEN
       return NULL;
END F_TRANSCO_CODFRAIS_GAR;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_SUP_DOSSIER_SANS_PREST                                  */
/* Type         :  Public                                                    */
/* Description  :  Suppression de l'ensemble des informations crées au       */
/*                 préalable si un dossier santé a été créé alors qu'aucunes */
/*                 prestations santé ne sont rattachées au dossier           */
/* Entré        :  Numéro de facture                                         */
/* Retour       :  Retourne le nombre de dossier supprimé                    */
/*---------------------------------------------------------------------------*/
PROCEDURE P_SUP_DOSSIER_SANS_PREST(P_numremise          IN  DOSSIER_SANTE.NUMREMISE_SNTRPRT%TYPE
                                 , P_num_dossier        IN  SINISTRE_SANTE.NUM_DOSSIER%TYPE
                                 , P_nb_dossier_sup     OUT NUMBER)
IS

  CURSOR c_dossier_sans_prest
      IS
  SELECT ds.NUMREMISE_SNTRPRT
       , ds.NUM_DOSSIER
    FROM DOSSIER_SANTE ds
   WHERE ds.NUMREMISE_SNTRPRT=P_numremise
     AND ds.NUM_DOSSIER = NVL(P_num_dossier, ds.NUM_DOSSIER)
     AND ds.NUM_DOSSIER NOT IN (
      SELECT ss.NUM_DOSSIER
      FROM SINISTRE_SANTE ss
      WHERE ss.NUM_DOSSIER=ds.NUM_DOSSIER);

  r_dossier_sans_prest c_dossier_sans_prest%ROWTYPE;

BEGIN
  P_nb_dossier_sup:=0;
  FOR r_dossier_sans_prest IN c_dossier_sans_prest LOOP
     ----------------------------------------------------------------
     -- Suppression des informations et historique du dossier santé
     ----------------------------------------------------------------
    DELETE HISTO_DOSSIER
     WHERE num_dossier = r_dossier_sans_prest.num_dossier;
    DELETE DOSSIER_SANTE
     WHERE num_dossier = r_dossier_sans_prest.num_dossier;
    DELETE POST_IT
     WHERE clef = r_dossier_sans_prest.num_dossier
     AND etendue=23;
    DELETE COURR_DEST
     WHERE ID = r_dossier_sans_prest.num_dossier;
     ----------------------------------------------------------------
     -- Suppression de la reference externe dans SINISTRE_PORTE
     ----------------------------------------------------------------
    UPDATE SINISTRE_PORTE SET REFCIE=NULL
     WHERE REFCIE=r_dossier_sans_prest.num_dossier
       AND NUMREMISE=P_numremise;
     ----------------------------------------------------------------
    P_nb_dossier_sup:=P_nb_dossier_sup+1;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    P_nb_dossier_sup:=-1; -- Erreur indeterminée
END P_SUP_DOSSIER_SANS_PREST;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_SUP_DOSSIER_SANS_PREST_WS                               */
/* Type         :  Public                                                    */
/* Description  :  Suppression de l'ensemble des informations crées au       */
/*                 préalable si un dossier santé a été créé alors qu'aucunes */
/*                 prestations santé n'est payé                              */
/* Entré        :  Numéro de dossier                                         */
/*---------------------------------------------------------------------------*/
PROCEDURE P_SUP_DOSSIER_SANS_PREST_WS( P_num_dossier        IN  SINISTRE_SANTE.NUM_DOSSIER%TYPE)
IS
  P_nb_dossier_sup NUMBER;
BEGIN
  P_nb_dossier_sup:=0;

   ----------------------------------------------------------------
   -- Suppression des informations et historique du dossier santé
   ----------------------------------------------------------------

  DELETE SINISTRE
  WHERE NUMSIN IN (SELECT NUMSIN_SNTR FROM SNTR_DOSSIER WHERE num_dossier = P_num_dossier);
  --TRG réalise toutes les suppressions même sntr_dossier / courrier / histo ...
  DELETE SINISTRE_SANTE
  WHERE num_dossier = P_num_dossier;

  DELETE HISTO_DOSSIER
  WHERE num_dossier = P_num_dossier;

  DELETE DOSSIER_SANTE
  WHERE num_dossier = P_num_dossier;

  DELETE POST_IT
  WHERE clef = P_num_dossier
  AND etendue=23;

  DELETE COURR_DEST
  WHERE ID = P_num_dossier;

EXCEPTION
  WHEN OTHERS THEN
    P_nb_dossier_sup:=-1; -- Erreur indeterminée
END P_SUP_DOSSIER_SANS_PREST_WS;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                  */
/* Nom          :  P _TRANSCO_CODFRAIS_SPSANTE, JBO 201108924                */
/* Type         :  Public                                                    */
/* Description  :  procedure de transcodification d'un code acte externe en  */
/*                 code acte Arthus                                          */
/* Retour       :  Retourne les code acte et le code erreur                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_TRANSCO_CODFRAIS_SPSANTE(
        P_numfor              IN gar_cntrt.numfor%TYPE,
        P_nature_ntfrs_detail IN NUMBER,
        P_ntfrs_optique       IN NTFRS_OPTIQUE_T,
        P_type_monture        IN TYPE_MONTURE_T,
        P_ntfrs_vision        IN NTFRS_VISION_T,
        P_ntfrs_typ_vision    IN NTFRS_TYP_VISION_T,
        P_ntfrs_matiere       IN NTFRS_MATIERE_T,
        P_renew_lentille      IN RENEW_LENTILLE_T,
        P_MtRO                IN NUMBER,
        O_codfrais           OUT TAB_codfrais,
        O_acte_err_code      OUT VARCHAR2
        , P_lpp              IN  VARCHAR2 --RKO
        )
IS

  --loc_codfrais NTFRS_DETAIL.codfrais%TYPE := NULL;
  loc_tab_codfrais TAB_codfrais;

  CURSOR c_optique_v_lpp
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , lpp l
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = P_lpp
      AND l.codfrais=c.codfrais
      AND n.codfrais=c.codfrais
      AND d.codfrais=c.rubrique
      and sysdate between c.datapli and NVL(c.datper,sysdate)
      and sysdate between d.datapli and NVL(d.datper,sysdate)
      AND (n.verre=1 or n.supp_verre=1);

   CURSOR c_optique_l_lpp
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , lpp l
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = P_lpp
     AND l.codfrais=c.codfrais
      AND n.codfrais=c.codfrais
      AND d.codfrais=c.rubrique
      and sysdate between c.datapli and NVL(c.datper,sysdate)
      and sysdate between d.datapli and NVL(d.datper,sysdate)
      AND n.lentille=1;

   CURSOR c_optique_m_lpp
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , lpp l
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = P_lpp
   AND l.codfrais=c.codfrais
      AND n.codfrais=c.codfrais
      AND d.codfrais=c.rubrique
      and sysdate between c.datapli and NVL(c.datper,sysdate)
      and sysdate between d.datapli and NVL(d.datper,sysdate)
      AND (n.monture=1 or n.supp_monture=1);

  CURSOR c_optique_detailv
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_OPTIQUE o
       , NTFRS_VISION v
       , NTFRS_TYP_VISION t
       , NTFRS_MATIERE m
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND n.verre=1
     AND o.codfrais (+) =c.codfrais
     AND ((NVL(p_ntfrs_optique.sphere_deb  ,o.spheren_deb)  BETWEEN NVL(o.spheren_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spheren_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spheren_deb  IS NULL AND o.spheren_fin  IS NULL))
       OR (NVL(p_ntfrs_optique.sphere_deb  ,o.spherep_deb)  BETWEEN NVL(o.spherep_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spherep_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spherep_deb  IS NULL AND o.spherep_fin  IS NULL)))
     AND  (NVL(P_ntfrs_optique.cylindre_deb,o.cylindre_deb) BETWEEN NVL(o.cylindre_deb,P_ntfrs_optique.cylindre_deb) AND NVL(o.cylindre_fin,P_ntfrs_optique.cylindre_deb) OR (o.cylindre_deb IS NULL AND o.cylindre_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.addition_deb,o.addition_deb) BETWEEN NVL(o.addition_deb,P_ntfrs_optique.addition_deb) AND NVL(o.addition_fin,P_ntfrs_optique.addition_deb) OR (o.addition_deb IS NULL AND o.addition_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.aminci_deb  ,o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,P_ntfrs_optique.aminci_deb)   AND NVL(o.aminci_fin  ,P_ntfrs_optique.aminci_deb)   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(o.teinte,-1) = NVL(P_ntfrs_optique.teinte,-1) OR o.teinte IS NULL)
     AND (NVL(o.famille,-1)= NVL(p_ntfrs_optique.famille,-1)OR o.famille IS NULL)
     AND o.codfrais = v.codfrais (+)
     AND o.nature = v.nature (+)
     AND NVL(v.vision,p_ntfrs_vision.vision) = p_ntfrs_vision.vision
     AND o.codfrais = t.codfrais (+)
     AND NVL(t.type_vision,p_ntfrs_typ_vision.type_vision) = p_ntfrs_typ_vision.type_vision
     AND NVL(m.matiere,p_ntfrs_matiere.matiere) = p_ntfrs_matiere.matiere
     AND o.nature = t.nature (+)
     AND o.codfrais = m.codfrais (+)
     AND o.nature = m.nature (+)
  ORDER BY o.codfrais, n.secu;


  CURSOR c_optique_detaill
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_OPTIQUE o
       , NTFRS_VISION v
       , NTFRS_TYP_VISION t
       , NTFRS_MATIERE m
       , RENEW_LENTILLE r
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND d.codfrais = c.rubrique -- a.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND n.lentille=1
     AND o.codfrais (+) =c.codfrais
     AND ((NVL(p_ntfrs_optique.sphere_deb  ,o.spheren_deb)  BETWEEN NVL(o.spheren_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spheren_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spheren_deb  IS NULL AND o.spheren_fin  IS NULL))
       OR (NVL(p_ntfrs_optique.sphere_deb  ,o.spherep_deb)  BETWEEN NVL(o.spherep_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spherep_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spherep_deb  IS NULL AND o.spherep_fin  IS NULL)))
     AND  (NVL(P_ntfrs_optique.cylindre_deb,o.cylindre_deb) BETWEEN NVL(o.cylindre_deb,P_ntfrs_optique.cylindre_deb) AND NVL(o.cylindre_fin,P_ntfrs_optique.cylindre_deb) OR (o.cylindre_deb IS NULL AND o.cylindre_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.addition_deb,o.addition_deb) BETWEEN NVL(o.addition_deb,P_ntfrs_optique.addition_deb) AND NVL(o.addition_fin,P_ntfrs_optique.addition_deb) OR (o.addition_deb IS NULL AND o.addition_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.aminci_deb  ,o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,P_ntfrs_optique.aminci_deb)   AND NVL(o.aminci_fin  ,P_ntfrs_optique.aminci_deb)   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(o.teinte,-1) = NVL(P_ntfrs_optique.teinte,-1) OR o.teinte IS NULL)
     AND (NVL(NVL(o.famille,p_ntfrs_optique.famille),-1) = NVL(p_ntfrs_optique.famille,-1) OR o.famille IS NULL)
     AND o.codfrais = v.codfrais (+)
     AND o.nature = v.nature (+)
     AND NVL(p_ntfrs_vision.vision,-1) = NVL(v.vision,NVL(p_ntfrs_vision.vision,-1))
     AND o.codfrais = t.codfrais (+)
     AND NVL(p_ntfrs_typ_vision.type_vision,-1) = NVL(t.type_vision,NVL(p_ntfrs_typ_vision.type_vision,-1))
     AND NVL(p_ntfrs_matiere.matiere,-1) = NVL(m.matiere,NVL(p_ntfrs_matiere.matiere,-1))
     AND o.nature = t.nature (+)
     AND o.codfrais = m.codfrais (+)
     AND o.nature = m.nature (+)
     AND n.codfrais = r.codfrais (+)
     AND NVL(P_renew_lentille.code,-1) = NVL(r.code,NVL(P_renew_lentille.code,-1))
  ORDER BY o.codfrais, n.secu;



  CURSOR c_monture_acte
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , TYPE_MONTURE t
       , NTFRS_MATIERE m
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND n.codfrais=c.codfrais
     AND d.codfrais = c.rubrique -- a.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.monture=1
     AND n.codfrais=c.codfrais
     AND t.codfrais (+)=c.codfrais
     AND NVL(p_type_monture.type_monture,-1) = NVL(t.type_monture,NVL(p_type_monture.type_monture,-1))
     AND m.codfrais (+)=c.codfrais
     AND NVL(p_ntfrs_matiere.matiere,-1) = NVL(m.matiere,NVL(p_ntfrs_matiere.matiere,-1))
  ORDER BY d.codfrais ;


BEGIN

  O_acte_err_code:='00';
  --ABO 17012020 retrait de la prise en compte du LPP pour les lentilles
  IF P_lpp IS NOT NULL AND TRIM(P_lpp) <>'-'  AND P_nature_ntfrs_detail IN (1,2)  THEN
    IF P_nature_ntfrs_detail =1 THEN
      FOR rec_optique_detailv IN c_optique_v_lpp LOOP
        IF (rec_optique_detailv.secu ='O' AND P_MtRO>0) OR (rec_optique_detailv.secu ='N' AND P_MtRO=0) OR (rec_optique_detailv.secu IS NULL) THEN
          O_codfrais(rec_optique_detailv.codfrais):=O_codfrais.COUNT;
              END IF;
      END LOOP;
    -- On traite la prestation optique LENTILLE
    ELSIF P_nature_ntfrs_detail =3 THEN
      FOR rec_optique_detaill IN c_optique_l_lpp LOOP
        IF (rec_optique_detaill.secu ='O' AND P_MtRO>0) OR (rec_optique_detaill.secu ='N' AND P_MtRO=0) OR (rec_optique_detaill.secu IS NULL) THEN
          o_acte_err_code:='00';
          O_codfrais(rec_optique_detaill.codfrais):=O_codfrais.COUNT;
        END IF;
      END LOOP;
    -- On traite la prestation optique MONTURE
    ELSIF P_nature_ntfrs_detail = 2 THEN
      FOR rec_monture_acte IN c_optique_m_lpp LOOP
        IF (rec_monture_acte.secu ='O' AND P_MtRO>0) OR (rec_monture_acte.secu ='N' AND P_MtRO=0) OR (rec_monture_acte.secu IS NULL) THEN
          O_codfrais(rec_monture_acte.codfrais):=O_codfrais.COUNT;
        END IF;
      END LOOP;
    END IF;
  ELSE
    -- On traite la prestation optique VERRE
    IF P_nature_ntfrs_detail =1 THEN
      FOR rec_optique_detailv IN c_optique_detailv LOOP
        IF (rec_optique_detailv.secu ='O' AND P_MtRO>0) OR (rec_optique_detailv.secu ='N' AND P_MtRO=0) OR (rec_optique_detailv.secu IS NULL) THEN
          O_codfrais(rec_optique_detailv.codfrais):=O_codfrais.COUNT;
        END IF;
      END LOOP;
    -- On traite la prestation optique LENTILLE
    ELSIF P_nature_ntfrs_detail =3 THEN
      FOR rec_optique_detaill IN c_optique_detaill LOOP
        IF (rec_optique_detaill.secu ='O' AND P_MtRO>0) OR (rec_optique_detaill.secu ='N' AND P_MtRO=0) OR (rec_optique_detaill.secu IS NULL) THEN
          o_acte_err_code:='00';
          O_codfrais(rec_optique_detaill.codfrais):=O_codfrais.COUNT;
        END IF;
      END LOOP;
    -- On traite la prestation optique MONTURE
    ELSIF P_nature_ntfrs_detail = 2 THEN
      FOR rec_monture_acte IN c_monture_acte LOOP
        IF (rec_monture_acte.secu ='O' AND P_MtRO>0) OR (rec_monture_acte.secu ='N' AND P_MtRO=0) OR (rec_monture_acte.secu IS NULL) THEN
          O_codfrais(rec_monture_acte.codfrais):=O_codfrais.COUNT;
        END IF;
      END LOOP;
    END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    o_acte_err_code:='99'; -- Erreur indeterminée
END P_TRANSCO_CODFRAIS_SPSANTE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_TRANSCO_SUP_SPSANTE, JBO 20110916                       */
/* Type         :  Public                                                    */
/* Description  :  fonction de transcodification d'un supplément d'un code   */
/*                 acte externe en code acte Arthus                          */
/* Retour       :  Retourne le code de l acte                                */
/*---------------------------------------------------------------------------*/
FUNCTION F_TRANSCO_SUP_SPSANTE( P_codfrais         IN NATFRAIS.CODFRAIS%TYPE,
                                P_ntfrs_type_sup   IN NTFRS_TYPE_SUP_T,
                                P_type             IN NUMBER,
                                P_MtRO             IN NUMBER,
                                P_typ_supRo        IN BOOLEAN)
RETURN BOOLEAN
IS

  CURSOR c_sup
      IS
  SELECT nd.codfrais
    FROM NTFRS_TYPE_SUP n
       , NTFRS_DETAIL nd
   WHERE nd.codfrais=P_codfrais
     AND ((nd.VERRE = 1 AND P_type=1) OR (nd.MONTURE = 1 AND P_type=2) OR (nd.LENTILLE = 1 AND P_type=3))
     AND ND.CODFRAIS= n.codfrais(+)
     AND NVL(P_ntfrs_type_sup.type_sup,-1) = NVL(n.type_sup,NVL(P_ntfrs_type_sup.type_sup,-1))
     AND NVL(n.prisme,-1)= NVL(P_ntfrs_type_sup.prisme,-1)
  ORDER BY n.codfrais ;

  rec_sup c_sup%ROWTYPE;

  CURSOR c_sup_ro
      IS
  SELECT nd.codfrais
       , sp.code_lpp
    FROM SUP_LPP sp
       , NTFRS_DETAIL nd
   WHERE nd.codfrais=P_codfrais
     AND ((nd.VERRE = 1 AND P_type=1) OR (nd.MONTURE = 1 AND P_type=2) OR (nd.LENTILLE = 1 AND P_type=3))
     AND ND.CODFRAIS= sp.codfrais(+)
     AND (NVL(P_ntfrs_type_sup.type_suplpp,-1) = NVL(sp.code_lpp,NVL(P_ntfrs_type_sup.type_suplpp,-1)) OR NVL(sp.code_lpp,0) =0)
  ORDER BY sp.code_lpp asc ;

  rec_sup_ro c_sup_ro%ROWTYPE;

BEGIN
/*
  PK_SPSANTE.P_INS_journal(2,'F_TRANSCO_SUP_SPSANTE P_codfrais:'||P_codfrais);
  PK_SPSANTE.P_INS_journal(2,'F_TRANSCO_SUP_SPSANTE P_type:'||P_type);
  PK_SPSANTE.P_INS_journal(2,'F_TRANSCO_SUP_SPSANTE P_ntfrs_type_sup.prisme:'||P_ntfrs_type_sup.prisme);
  PK_SPSANTE.P_INS_journal(2,'F_TRANSCO_SUP_SPSANTE P_ntfrs_type_sup.type_sup:'||P_ntfrs_type_sup.type_sup);
  PK_SPSANTE.P_INS_journal(2,'F_TRANSCO_SUP_SPSANTE P_MtRO:'||to_char(P_MtRO));
*/
  -- Gestion des supplements non RO prenant en compte le type de supplément et le prisme
  IF P_typ_supRo = FALSE THEN
    --PK_SPSANTE.P_INS_journal(2,'F_TRANSCO_SUP_SPSANTE avant curseur1:'||to_char(P_MtRO));
    FOR rec_sup IN c_sup LOOP
      RETURN TRUE;
    END LOOP;
  ELSE
    --PK_SPSANTE.P_INS_journal(2,'F_TRANSCO_SUP_SPSANTE avant curseur2:'||to_char(P_MtRO));
    -- Gestion des supplements RO prenant en compte les codes LPP
    FOR rec_sup_ro IN c_sup_ro LOOP
      IF rec_sup_ro.code_lpp =0 THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    END LOOP;
  END IF;

  RETURN FALSE;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN FALSE;
WHEN OTHERS THEN
    RETURN FALSE; -- Erreur indeterminée
END F_TRANSCO_SUP_SPSANTE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CTRL_COUV_BENE                                          */
/* Type         :  Public                                                    */
/* Description  :  Procedure permettant le controle de couvertue du          */
/*                 bénéficiaire, létat du contrat, l etat de l adhésion, le  */
/*                 numéro de garantie ainsi que la zone territoriale         */
/* Retour       :  Retourne l idadhesion, le numgar, le numfor, la zone ainsi*/
/*                 que le code d une eventuelle anomalie                     */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CTRL_COUV_BENE ( P_Numassu    IN   SINISTRE_PORTE.NUMASSU%TYPE
                           , P_Numindiv   IN   SINISTRE_PORTE.NUMINDIV%TYPE
                           , P_Datsin     IN   SINISTRE_PORTE.DATSIN%TYPE
                           , P_Numporte   IN   SINISTRE_PORTE.NUMPORTE%TYPE
                           , P_idadhesion OUT  ADHE_CNTRT.IDADHESION%TYPE
                           , P_numgar     OUT  CONTRAT_REF.NUMGAR%TYPE
                           , P_numfor     OUT  SINISTRE_PORTE.NUMFOR%TYPE
                           , P_codano     OUT  NUMBER
                           , P_Porte      OUT  SINISTRE_PORTE.NUMPORTE%TYPE)
IS

  loc_etat_numgar             HISTO_CONTRAT.ETAT%TYPE;
  loc_etatAdhe                HISTO_ADHESION.ETAT%TYPE;
  loc_isColl                  BOOLEAN;
  loc_libelle                 PRODUIT.LIBELLE%TYPE;
  loc_dateEffet               ADHE_CNTRT.DATE_ADHE%TYPE;
  loc_dateRes                 ADHE_CNTRT.DATE_FIN_ADHE%TYPE;
  l_numorg                    PORTE_REMISE.NUMORG%TYPE;
  loc_porte                   NUMBER:=0;
  erreur_contrat              NUMBER :=0;
  erreur_adhesion             NUMBER :=0;
  l_trouve                    BOOLEAN:=FALSE;
  loc_numfor                  SINISTRE_PORTE.NUMFOR%TYPE ;

BEGIN
  P_codano:=0;
  -- Controle du contrat et verification que la porte CFE soit ouverte sur le contrat
  PK_CTRL_TP.P_FIND_CONTRAT_BY_ASSU( P_Numassu
                                   , P_Numindiv
                                   , P_Numporte
                                   , P_idadhesion
                                   , P_numgar
                                   , loc_isColl
                                   , loc_libelle
                                   , loc_dateEffet
                                   , loc_dateRes
                                   , l_numorg
                                   , loc_porte
                                   , erreur_contrat);
  P_Porte:=NVL(loc_porte,P_Numporte);

  IF erreur_contrat = 1 THEN
     P_codano:=43;
  ELSIF erreur_contrat = 2 THEN
     P_codano:=100;
  ELSIF erreur_contrat <> 0 THEN
     P_codano:=63;
  ELSE
    -- Controle de l état du contrat
    loc_etat_numgar:=PK_CTRL_TP.F_CTRL_CNTRT(P_numgar,P_Datsin);
    IF loc_etat_numgar = 3 THEN
      P_codano:=101;
    ELSIF loc_etat_numgar <> 1 THEN
      P_codano:=101;
    ELSE
      -- Controle de l adhésion
      PK_CTRL_TP.P_CTRL_ADHESION (P_idadhesion,
                                  P_numgar,
                                  NULL,
                                 -- P_datsin,
                                  FALSE,
                                  loc_etatAdhe,
                                  erreur_adhesion);
      IF erreur_adhesion IN (7,8,9) THEN
        P_codano:=102;
      ELSIF erreur_adhesion <> 0 THEN
        P_codano:=102;
      ELSE
        -- Controle de couverture du bénéficaire
        P_numfor := PK_CTRL_TP.F_CTRL_couverture_NUMFOR(P_Numindiv,1,'C',P_Datsin);
        IF P_numfor=0 THEN
          P_codano:=46;
        -- MUR  : ajout M0004004 : controle de couverture obligatoire
        ELSE
          loc_numfor := PK_CTRL_TP.F_CTRL_couverture_NUMFOR(P_Numindiv,1,'O',P_Datsin);
          IF loc_numfor = 0 THEN
            P_codano:=125;
          END IF ;
        -- MUR  : fin ajout M0004004
        END IF;
      END IF;
    END IF;
  END IF;
END P_CTRL_COUV_BENE;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CTRL_MODE_PAIEMENT                                      */
/* Type         :  Public                                                    */
/* Description  :  Procedure permettant le controle du mode et le moyen de   */
/*                 paiement du bénéficiaire CFE pour une devise donnée       */
/* Retour       :  Retourne le rib, la devise de remboursement et le codano  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CTRL_MODE_PAIEMENT ( P_NumBene    IN   SINISTRE_PORTE.NUMBENE%TYPE
                               , P_Datsin     IN   SINISTRE_PORTE.DATSIN%TYPE
                               , P_Codmon_d   IN   SINISTRE_PORTE.CODMON_D%TYPE
                               , P_dattrait   IN   SINISTRE_PORTE.DATTRAIT%TYPE
                               , P_idrib      OUT  RIB.IDRIB%TYPE
                               , P_deviseOut  OUT  DOSSIER_SANTE.DEVISE_OUT%TYPE
                               , P_codano     OUT  NUMBER)
IS

BEGIN

 /* -- Recherche du moyen de paiement et de la devise de remboursement
  P_idrib:=PK_CTRL_CFE.F_CTRL_RIB_NUMBENE( P_Codmon_d
                                         , P_NumBene
                                         , P_dattrait);

    -- Rib trouvé
  IF P_idrib > 0 THEN
    -- Recherche de la devise de remboursement
    P_deviseOut:=PK_CTRL_CFE.F_CTRL_DEVISE_REMB(P_idrib);
    IF P_deviseOut = 0 THEN
      P_codano:=115;
    ELSE
      -- Recherche du mode de paiement, si cheque ou cheque manuel alors blocage ==> Lettre cheque? inexistant pour le mnemo MOPM
      IF PK_CTRL_CFE.F_CTRL_RIB_MODPMT(P_idrib) = 1 OR PK_CTRL_CFE.F_CTRL_RIB_MODPMT(P_idrib)=3 THEN
        P_codano:=113;
      ELSE
        -- Recheche du taux de change
        P_codano:=PK_CTRL_CFE.F_VALIDE_DEVISE( P_deviseOut
                                             , P_datsin);

      END IF;
    END IF;
  ELSIF P_idrib < 0 THEN
    -- Plusieurs Rib trouvé mais pas avec la bonne devise
    P_codano:=105;
  ELSE
    -- Aucun Rib trouvé
    P_codano:=104;
  END IF;*/
  null;

END P_CTRL_MODE_PAIEMENT;

-- Insertion dans journal_adm
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
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
        I_session  => SID,
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;
  COMMIT;
END P_INS_journal;

-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------

---------------- Fin des corps des procedures privees --

END PK_CTRL_TP;
/
