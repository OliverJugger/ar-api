CREATE OR REPLACE PACKAGE ARTHUS.PK_SPSANTE
AS
/*============================================================================*/
/* PACKAGE      : PK_SPSANTE.sql                                              */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 27/05/2011                                                  */
/* Description  : Gestion des flux XML du tiers payant optique SP Sante/Sintia*/
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 15/05/2012 / Ajout du paramètre false aux procedures  */
/*                pk_xml.get_xml,pk_xml.add_data et pk_xml.merge_data afin de */
/*                ne pas prendre en compte les flux xml au format UTF-8       */
/*============================================================================*/
/* Correction   : JBO / 03/09/2012 / Modification du message "Forfait épuisé" */
/*                par "Calcul impossible ou forfait épuisé" pour prendre en   */
/*                compte le blocage sur les relances de piÞces adhÚsions      */
/*============================================================================*/
/* Correction   : JBO / 07/03/2013 / Mantis 4021                              */
/*                Gestion acte MOUN lors d une PEC avec un seul verre+monture */
/*                MOUN : Test sur .nbpresentation <=2  au lieu de : <=1 et <2 */
/*============================================================================*/
/* Correction   : ABO 28/10/2014  détection du délai de traitement            */
/*============================================================================*/
/* Correction   : ABO 15/01/2015  devis numérotation des lignes et produit    */
/*               lentille empechant la création des sinistres                 */
/*============================================================================*/
/* Correction   : ABO 30/08/2016  4767 carte TPE prise en charge partielle    */
/*============================================================================*/
/* Correction   : PHA 13/12/2016  0005159: Annulation de prestation alors que */
/*                                le dossier est en cours de facturation 687  */
/*============================================================================*/
/*Evolution    : JBO 07/02/2017 Mise en place de la notion de réseau de soins */
/*                  : P201608003_reseau_soin_GEREP + M5232                    */
/*============================================================================*/
/* Correction  : JBO 15/12/2017: M5439-M5454: mise en commentaire de la balise*/
/*               <priseEnChargeDetaillee><identifiant> car les PEC KRYS ne l  */
/*               alimente pas toujours ce qui provoque une erreur de structure*/
/*               de flux                                                      */
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
TYPE T_Acte IS RECORD ( codfraisSPS   VARCHAR2(10),            -- Code de l'acte SPSante : VERRE, MONTURE, LENTILLE et BASSE VISION(non utilisé)
                        codfrais      NATFRAIS.CODFRAIS%TYPE,  -- Code de l acte ARTHUS
                        base          NUMBER(11,2),
                        mtro          NUMBER(11,2),            -- <part>
                        taux          NUMBER(11,2),            -- <financement>
                        remise        NUMBER(11,2),            -- <abattement>
                        base_sup      NUMBER(11,2),
                        mtro_sup      NUMBER(11,2),            -- <part>
                        remise_sup    NUMBER(11,2),            -- <abattement>
                        mtfrais       NUMBER(11,2),            -- <depense>
                        mtfrais_sup   NUMBER(11,2),            -- <depense>
                        mtfrais_supRb NUMBER(11,2),
                        mtfrais_reel  NUMBER(11,2),
                        mtprest       NUMBER(11,2),
                        mtrac         NUMBER(11,2),
                        codeErreur    VARCHAR2(3),
                        messErreur    VARCHAR2(500),
                        quantite      NUMBER(2),
                        nbpresentation NUMBER(2),
                        identifiant    NUMBER(2), --identifiant à reprendre dans la réponse
                        numequip       NUMBER(2)
                        );
TYPE TAB_T_Acte IS TABLE OF T_Acte INDEX BY BINARY_INTEGER;

TYPE T_EQUIP_OPT IS RECORD  (CODFRAIS               VARCHAR2 (5),--RKO WS RAC DEROG OPTIQUE
			NATURE                NUMBER(1,0),
			SPHERE_VER_DEB        NUMBER(5,2),
			SPHERE_VER_FIN        NUMBER(5,2),
			CYLINDRE_VER_DEB      NUMBER(4,2),
			CYLINDRE_VER_FIN      NUMBER(4,2),
			ADDITION_VER_DEB      NUMBER(4,2),
			ADDITION_VER_FIN      NUMBER(4,2),
			AMINCI_VER_DEB        NUMBER(5,3),
			AMINCI_VER_FIN        NUMBER(5,3),
			VISION_VER            NUMBER(6),
			MATIERE_VER           NUMBER(6),
			TEINTE_VER            NUMBER(6),
			TYPE_VISION_VER       VARCHAR2(2),
			type_monture          NUMBER (7),
			MATIERE_MONTURE       NUMBER(6),
			SPHERE_LEN_DEB        NUMBER(5,2),
			SPHERE_LEN_FIN        NUMBER(5,2),
			CYLINDRE_LEN_DEB      NUMBER(4,2) ,
			CYLINDRE_LEN_FIN      NUMBER(4,2) ,
			ADDITION_LEN_DEB      NUMBER(4,2),
			ADDITION_LEN_FIN      NUMBER(4,2),
			AMINCI_LEN_DEB        NUMBER(5,3),
			AMINCI_LEN_FIN        NUMBER(5,3),
			VISION_LEN            NUMBER(6),
			TYPE_VISION_LEN       VARCHAR2(2),
			FAMILLE_LEN           NUMBER(1),
			MATIERE_LEN           NUMBER(6),
			CODE_LEN              VARCHAR2(2)
		) ;

TYPE TAB_T_EQUIP IS TABLE OF T_EQUIP_OPT index by binary_integer;


-- ------------------------------------------------- Fin des types publiques --

   -- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --

   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------

FUNCTION creerPEC (
  P_xml IN XMLTYPE
)RETURN XMLTYPE;

FUNCTION annulerPEC (
  P_xml IN XMLTYPE
)RETURN XMLTYPE;

FUNCTION F_DATEHEURE2D(I_StringDateHeure  VARCHAR2)
RETURN DATE;

FUNCTION F_D2DATEHEURE(I_Date  DATE)
RETURN VARCHAR2;

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_SPSANTE;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_SPSANTE"
AS
/*============================================================================*/
/* PACKAGE      : PK_SPSANTE.sql                                              */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 27/05/2011                                                  */
/* Description  : Gestion des flux XML du tiers payant optique SP Sante/Sintia*/
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 15/05/2012 / Ajout du paramètre false aux procedures  */
/*                pk_xml.get_xml,pk_xml.add_data et pk_xml.merge_data afin de */
/*                ne pas prendre en compte les flux xml au format UTF-8       */
/*============================================================================*/
/* Correction   : JBO / 03/09/2012 / Modification du message "Forfait épuisé" */
/*                par "Calcul impossible ou forfait épuisé" pour prendre en   */
/*                compte le blocage sur les relances de piÞces adhÚsions      */
/*============================================================================*/
/* Correction   : JBO / 07/03/2013 / Mantis 4021                              */
/*                Gestion acte MOUN lors d une PEC avec un seul verre+monture */
/*                MOUN : Test sur .nbpresentation <=2  au lieu de : <=1 et <2 */
/*============================================================================*/
/* Correction   : ABO 28/10/2014  détection du délai de traitement            */
/*============================================================================*/
/* Correction   : ABO 30/08/2016  4767 carte TPE prise en charge partielle    */
/*============================================================================*/

   -- -- PROCEDURES PRIVEES ----------------------------------------------------
--
PROCEDURE P_ENTETE_REP(
  p_type IN VARCHAR2,
  P_ident  IN VARCHAR2
);

PROCEDURE P_ENTETE_REP_ERREUR(
  P_codeRetour  IN VARCHAR2,
  P_codeRaison  IN VARCHAR2,
  P_codeJustif  IN VARCHAR2,
  P_Tab_Indiv   IN PK_CTRL_TP.TAB_T_Indiv,
  P_num_dossier IN dossier_sante.num_dossier%TYPE,
  P_AvisPEC     IN VARCHAR2,
  P_refdossExt  IN VARCHAR2,
  P_codeDec     IN VARCHAR2,
  P_libErreur   IN VARCHAR2,
  P_motif       IN VARCHAR2,
  P_flux        IN NUMBER
);

FUNCTION calculDevis(P_loc_Tab_Acte IN OUT TAB_T_Acte
                    , p_niv          IN NUMBER
                    , P_benef        IN NUMBER
                    , P_numindivPS   IN NUMBER
                    , i_derog        IN VARCHAR2 default NULL)
RETURN NUMBER;

FUNCTION gestionAbus( P_patient      IN  individu.numindiv%TYPE
                    , P_assure      IN  individu.numindiv%TYPE
                    , P_rang        IN  NUMBER
                    , P_datenais    IN  DATE
                    , P_equipement  IN  VARCHAR2
                    , P_opticien    IN  individu.numindiv%TYPE
                    , P_NNI         IN  VARCHAR2
                    , P_type        IN  NUMBER)
RETURN NUMBER;
PROCEDURE SupplActe( IO_TabActe     IN OUT  TAB_T_Acte
                   ,p_xml           IN XMLTYPE
                   ,I_niv           IN  NUMBER
                   ,I_path          IN VARCHAR2
                   ,I_type          IN VARCHAR2
                   ,I_nature        IN NUMBER
                   );

PROCEDURE SupplROActe( IO_TabActe    IN OUT  TAB_T_Acte
                    ,I_xml           IN XMLTYPE
                    ,IO_niv          IN OUT  NUMBER
                    ,I_path          IN VARCHAR2
                    ,I_type          IN VARCHAR2
                    ,I_nature        IN NUMBER
                    ,I_numfor        IN NUMBER
                    ,IO_Tab_codfrais IN OUT PK_CTRL_TP.TAB_codfrais
                    ,IO_acte_err_code IN OUT VARCHAR2
                    );
PROCEDURE P_INS_TRAVSAI_OPT (I_cpt        IN NUMBER,
                            I_path_xml    IN VARCHAR2,
                            I_xml         IN XMLTYPE,
                            IO_Tab_Acte   IN OUT TAB_T_Acte,
                            I_tab_equip   IN TAB_T_EQUIP,
                            I_TRAV_SAISIE IN trav_saisie%ROWTYPE
                            );

FUNCTION ConstructPriseEnCharge( P_Tab_Indiv     IN  PK_CTRL_TP.TAB_T_Indiv
                                ,p_xml           IN  XMLTYPE
                                ,I_path_patient  IN  VARCHAR2
                                ,I_path_pec1     IN  VARCHAR2
                                ,I_path_pec2     IN  VARCHAR2
                                ,I_path_xml      IN  VARCHAR2
                                ,KO              IN  BOOLEAN
                                ,P_AvisPEC       OUT VARCHAR2)
RETURN NUMBER;

FUNCTION F_extract_individu( p_xml           IN XMLTYPE
                            ,I_path_patient  IN VARCHAR2
                            ,I_path_pec1     IN VARCHAR2
                            ,I_path_pec2     IN VARCHAR2)
RETURN PK_CTRL_TP.TAB_T_Indiv ;
FUNCTION ErreurActe(i_code IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION ErreurCalcul(i_code IN NUMBER,i_mtprest IN NUMBER)
RETURN VARCHAR2;

PROCEDURE P_Init_Editique ;

PROCEDURE P_INSERT_INFOS_VERRES( P_numindiv    IN sinistre_sante.numindiv%TYPE
                               , P_codfrais    IN sinistre_sante.codfrais%TYPE
                               , P_numfor      IN ADHESION.NUMFOR%TYPE
                               , i             IN NUMBER
                          --     , P_Tab_acte    IN TAB_T_ACTE
                               , P_t_verre     IN NTFRS_OPTIQUE_T
                               , P_num_dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE
                                ) ;

FUNCTION  F_FIND_INFOS_VERRES( P_numindiv    IN sinistre_sante.numindiv%TYPE
                             , P_codfrais    IN sinistre_sante.codfrais%TYPE
                             , P_numfor      IN ADHESION.NUMFOR%TYPE
                             , i             IN NUMBER
                        --     , P_Tab_acte    IN TAB_T_ACTE
                             , P_t_verre     IN NTFRS_OPTIQUE_T
                             , P_num_dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE
                              )
RETURN NUMBER;

PROCEDURE P_envoi_Mail( P_ObjetMail       IN       VARCHAR2
                      , P_MessMail        IN       VARCHAR2);
-- ------------------------------------------------- Fin des procedures privees --


-- Variables de P_INS_journal
G_nom_traitement  Constant journal_adm.nom_traitement%TYPE default 'WS15T';
G_niv_msg         journal_adm.niv_msg%TYPE;
G_idligne         journal_adm.idligne%TYPE := 0;
g_msg_adm         journal_adm.msg_adm%TYPE;
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- ---------------------------------------------- Fin des constantes privees --

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
exc_reference_inconnue EXCEPTION;
exc_assu_inconnu       EXCEPTION;
exc_contrat_invalide   EXCEPTION;
exc_contrat_resilie    EXCEPTION;
exc_adhe_invalide      EXCEPTION;
exc_TP_ferme           EXCEPTION;
exc_adhe_non_couvert   EXCEPTION;
exc_garantie_inconnue  EXCEPTION;
exc_erreur_inconnue    EXCEPTION;
exc_flux_inconnue      EXCEPTION;
exc_dossier_inconnu    EXCEPTION;
exc_dossier_annule     EXCEPTION;
exc_dossier_facture    EXCEPTION;
exc_dossier_CourFactur EXCEPTION;
exc_adhe_non_tp        EXCEPTION;
exc_PS_inconnue        EXCEPTION;
exc_erreur_doublon_PS  EXCEPTION;
exc_prestation_null    EXCEPTION;
exc_rc_different       EXCEPTION;
exc_info_obligatoire   EXCEPTION;
exc_info_erronnee      EXCEPTION;
exc_produit_entretien  EXCEPTION;
exc_acte_inconnu       EXCEPTION;
exc_double_vision      EXCEPTION;
exc_ordonnance         EXCEPTION;
exc_abus               EXCEPTION;
exc_abus_pec_adhe      EXCEPTION;
exc_abus_fr_reel       EXCEPTION;
nb_limite_lentille     EXCEPTION;


-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------

g_grpporte          NUMBER(2) := 15; -- Porte SPSANTE
g_tabCond        PK_PORTE.TAB_Cond;
--v_type                VARCHAR2(1);


v_personneSuivi       VARCHAR2(1000):=NULL;
v_paragraphe1         VARCHAR2(1000);
v_paragraphe2         VARCHAR2(1000);
v_paragraphe3         VARCHAR2(1000);
v_paragraphe4         VARCHAR2(1000);
v_paragraphe5         VARCHAR2(1000);
v_mess_refus1         VARCHAR2(1000);
v_mess_refus2         VARCHAR2(1000);
v_mess_refus3         VARCHAR2(1000);
v_mess_refus4         VARCHAR2(1000);
v_mess_refus5         VARCHAR2(1000);
v_mess_refus6         VARCHAR2(1000);
v_mess_refus8         VARCHAR2(1000);
v_mess_refus9         VARCHAR2(1000);
v_mess_refus10        VARCHAR2(1000);
v_mess_refus11        VARCHAR2(1000);
v_mess_refus12        VARCHAR2(1000);  --WS RAC DEROG gestion abus
v_mess_refus13        VARCHAR2(1000);
v_lib1                VARCHAR2(1000);
v_lib2                VARCHAR2(1000);
-- -------------------------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ENTETE_REP                                              */
/* Type         :  Privee                                                    */
/* Description  :  Constitution de l'entete de la reponse du flux XML        */
/* Entree       :  P_emet, donnée emise                                      */
/*                 P_emet_sup, donnée emise supplémentaire                   */
/*                 P_dest, donnée Destinataire                               */
/*                 P_dest_sup, donnée Destinataire supplémentaire            */
/*                 P_flux, Flux XML d entrée                                 */
/*                 P_code                                                    */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ENTETE_REP(
  p_type   IN VARCHAR2,
  P_ident  IN VARCHAR2
  ) IS
BEGIN

  pk_xml.add_data('/','identification',P_ident, false);
  pk_xml.add_data('/','date',F_D2DATEHEURE(sysdate), false);
  pk_xml.add_data('/','type',p_type, false);
  -- Suppression de la balise si la reponse est une annulation (OIAMCADV)
  IF TRIM(p_type) IS NULL THEN
    pk_xml.merge_data('/','type','@', false);
  END IF;
  pk_xml.add_data('/','code','', false);
  pk_xml.add_data('/','raison','', false);
  pk_xml.add_data('/','justification','', false);
  -- Suppression de la balise si la reponse est une annulation (OIAMCADV)
  IF TRIM(p_type) IS NULL THEN
    pk_xml.merge_data('/','justification','@', false);
  END IF;
  pk_xml.add_data('/','libelle','', false);
END;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ENTETE_REP_ERREUR                                       */
/* Type         :  Privee                                                    */
/* Description  :  Constitution de l'entete de la reponse du flux XML        */
/*                 avec la mise à jour des éventuelles erreurs               */
/* Entree       :  P_codeRetour, Code erreur ou non                          */
/*                 P_codeRaison, code raison de l erreur                     */
/*                 P_codeJustif, code de la justification                    */
/*                 P_libErreur, libellé de l erreur                          */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ENTETE_REP_ERREUR(
  P_codeRetour  IN VARCHAR2,
  P_codeRaison  IN VARCHAR2,
  P_codeJustif  IN VARCHAR2,
  P_Tab_Indiv   IN PK_CTRL_TP.TAB_T_Indiv,
  P_num_dossier IN dossier_sante.num_dossier%TYPE,
  P_AvisPEC     IN VARCHAR2,
  P_refdossExt  IN VARCHAR2,
  P_codeDec     IN VARCHAR2,
  P_libErreur   IN VARCHAR2,
  P_motif       IN VARCHAR2,
  P_flux        IN NUMBER
)IS
  loc_decision VARCHAR2(2);
BEGIN
  pk_xml.merge_data('/','code',P_codeRetour, false);
  pk_xml.merge_data('/','raison',P_codeRaison, false);
  pk_xml.merge_data('/','libelle',SUBSTR(P_libErreur,1,128), false);
  pk_xml.merge_data('priseEnChargeDetaillee/avisPriseEnCharge','motif',P_motif, false);

  IF P_codeRetour = 2 THEN
    --mise à blanc des balises non requises en cas d'erreur
    pk_xml.merge_data('/','decision','@', false);
    pk_xml.merge_data('/','motif','@', false);

    IF P_codeRaison <>2 THEN --RG CDC
      pk_xml.merge_data('/','justification','@', false);
    ELSE
      pk_xml.merge_data('/','justification',P_codeJustif, false);
    END IF;
   -- pk_xml.merge_data('propositionClient','identifiant', loc_refdossExt); --facultatif = numéro de dossier interne
    pk_xml.merge_data('propositionClient','referenceDossierAMC', P_num_dossier, false); --à mettre à jour si PEC acceptée !
    pk_xml.merge_data('propositionClient','referenceDossierOperateur', P_AvisPEC, false);
  ELSE
    --suppression des balises
    pk_xml.merge_data('/','raison','@', false);
    pk_xml.merge_data('/','justification','@', false);

    --RG le champ motif est renseigné uniquement lorsque le champ decision = 6
    pk_xml.merge_data('/','decision',P_codeDec, false);
    IF P_codeDec <> '6' AND P_codeDec <> '2' THEN
      IF P_flux = 1 THEN
        pk_xml.merge_data('/','motif','@', false);
      END IF;
      pk_xml.merge_data('/','libelle','@', false);
      pk_xml.merge_data('propositionClient','identifiant', P_refdossExt, false); --facultatif = numéro de dossier interne
      pk_xml.merge_data('propositionClient','referenceDossierAMC', P_num_dossier, false); --à mettre à jour si PEC acceptée !
      pk_xml.merge_data('propositionClient','referenceDossierOperateur', P_AvisPEC, false);
    ELSIF P_codeDec = 6 AND P_flux=1 THEN -- uniquement pour une validation de PEC
      --editique
       --TO DO date à l'américaine
      v_paragraphe1:=v_paragraphe1||P_Tab_Indiv('bene').nom||' '
                                  ||P_Tab_Indiv('bene').prenom||' né(e) le '
                                  ||P_Tab_Indiv('bene').datnais||'.';
      --génération

      pk_xml.merge_data('/','partenariat','@', false);
      -- M5439-M5454  : mise en commentaire de cette balise car les PEC KRYS ne l alimente pas toujours ce qui provoque une erreur de structure de flux
     --  pk_xml.merge_data('priseEnChargeDetaillee/avisPriseEnCharge','identifiant','@', false);
      pk_xml.merge_data('priseEnChargeDetaillee/avisPriseEnCharge','conditionDeRemboursement','@', false);
      pk_xml.merge_data('priseEnChargeDetaillee/avisPriseEnCharge','montantPrisEnCharge','@', false);
      pk_xml.merge_data('priseEnChargeDetaillee/avisPriseEnCharge','montantResteACharge','@', false);
      pk_xml.merge_data('priseEnChargeDetaillee/avisPriseEnCharge','montantTotal','@', false);
      pk_xml.add_element('avisPriseEnCharge', 'editionsEFI');
      pk_xml.add_element('editionsEFI', 'edition');
      pk_xml.add_data('edition', 'type',4, false);
      pk_xml.add_data('edition', 'dateRefus',F_D2DATEHEURE(sysdate), false);
      pk_xml.add_data('edition', 'nomPersonneSuivi',P_Tab_Indiv('bene').nom||' '||P_Tab_Indiv('bene').prenom, false);
      pk_xml.add_data('edition', 'titre','TODO_titre', false);
      pk_xml.add_data('edition', 'paragraphe','Madame, Monsieur,', false);
      pk_xml.add_data('edition', 'paragraphe',v_paragraphe1, false);
      pk_xml.add_data('edition', 'paragraphe',v_paragraphe2, false);
      pk_xml.add_data('edition', 'paragraphe',v_paragraphe3, false);
      pk_xml.add_data('edition', 'paragraphe',v_paragraphe4, false);
      pk_xml.add_data('edition', 'signature','Gestion frais de santé GEREP', false);
      pk_xml.add_element('/', 'partenariat');
      pk_xml.add_element('partenariat', 'propositionClient');
      pk_xml.add_data('propositionClient','identifiant', P_refdossExt, false); --facultatif = numéro de dossier interne
      pk_xml.add_data('propositionClient','referenceDossierAMC', 0, false); --refus
      pk_xml.add_data('propositionClient','referenceDossierOperateur', P_AvisPEC, false);
    END IF;
  END IF;
  IF P_flux=2 THEN
    pk_xml.merge_data('/','justification','@', false);
    pk_xml.merge_data('propositionClient','identifiant','@', false);
  ELSE
    --RG le champ effet n'est pas renseigné lorsque decision = 1 2 3
    IF P_codeDec IN('1','2','3') THEN
      pk_xml.merge_data('/','effet','@', false);
    END IF;
  END IF;
END;
-- -- FIN CORPS DES PROCEDURES PRIVEES --------------------------------------
----------------------------------------------------------------------------

-- -- CORPS DES PROCEDURES PUBLIQUES --------------------------------------

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  creerPEC                                                  */
/* Type         :  Public                                                    */
/* Description  :  Demande de prise en charge                                */
/* Entree       :  P_xml, Flux XML                                           */
/* Retour       :  Retourne le flux XML                                      */
/*---------------------------------------------------------------------------*/
FUNCTION creerPEC (
  P_xml IN XMLTYPE
)RETURN XMLTYPE IS

  v_xml               XMLTYPE;
  l_outxmlns          VARCHAR2(10);
  v_id_flux flux.     id_flux%TYPE;
  loc_typeFlux        NUMBER(2);
  V_etatCntrt         NUMBER(2);
  loc_idadhesion      adhe_cntrt.idadhesion%TYPE;
  loc_Tab_Indiv       PK_CTRL_TP.TAB_T_Indiv ; -- tableau d'individu (patient et assuré principal)
  loc_Tab_Acte        TAB_T_Acte;              -- tableau d'acte
  loc_Tab_codfrais    PK_CTRL_TP.TAB_codfrais; -- tableau de transco acte
  loc_numgar          contrat_ref.numgar%TYPE;
  loc_isColl          BOOLEAN;
  loc_libelle         produit.libelle%TYPE;
  loc_dateEffet       adhe_cntrt.date_adhe%TYPE;
  loc_dateRes         adhe_cntrt.date_fin_adhe%TYPE;
  loc_numorg          contrat_ref.numorg%TYPE;
  loc_numporte          dossier_sante.numporte%type;
  loc_num_dossier       dossier_sante.num_dossier%TYPE:=0;
  loc_refdossExt        VARCHAR2(50):='0';
  loc_AvisPEC           VARCHAR2(50):='0';
  erreur_adhesion     NUMBER :=0;
  erreur_contrat      NUMBER :=0;
  erreur_acte         NUMBER:=0;
  erreur_calcul       NUMBER:=0;
  msg_calcul          VARCHAR2(200);
  loc_datsin          DATE;
  loc_found           NUMBER :=0;
  loc_etatAdhe        NUMBER :=0;
  loc_isCouvert       BOOLEAN:=FALSE;
  loc_isTP            BOOLEAN:=FALSE;
  loc_acteCouvert     BOOLEAN :=FALSE;
  loc_numindivPS      individu.numindiv%TYPE;
  loc_typePS          VARCHAR2(50);
  C_lstGar            PK_CTRL_TP.Fetch_garanties_adhe%ROWTYPE;
  loc_refDomaine      transco.val_ext%TYPE;
  msg_dossier         VARCHAR2(200);
  erreur_dossier      NUMBER :=0;
  loc_numdossierPorte dossier_sante.num_dossier_porte%TYPE;
  loc_ordoOpen        NUMBER:=0; -- permet de savoir si le motif de l ordonnance est ouvert au remboursement (MNEMO ORDO_MOTIF, sens=1)
  loc_cumulFrais      NUMBER:=0;
  loc_cumulro         NUMBER:=0;
  loc_cumulremise     NUMBER:=0;
  loc_sens            NUMBER:=NULL;
  loc_ErrAbus         NUMBER:=0; -- variable permettant de controler les abus. 0==> aucun controle encore effectuer

  --données acte de soin
  loc_domaine         VARCHAR2(3):='OPT';
  V_mtprest           NUMBER(11,2):=0;--montant de prestation complémentaire d'un acte
  V_totmtprest        NUMBER(11,2):=0;--montant de total prestation complémentaire d'un acte
  V_totmtFrais        NUMBER(11,2):=0;--montant de total prestation complémentaire d'un act
  V_mtRO              NUMBER(11,2):=0;
  V_mtFrais           NUMBER(11,2):=0;
  v_rac               NUMBER(11,2):=0;
  v_totrac            NUMBER(11,2):=0;
  v_mtdepense         NUMBER(11,2):=0;
  v_ordre             VARCHAR2(3);
  v_codfrais_porte    VARCHAR2(6);
  v_codfrais          NATFRAIS.CODFRAIS%TYPE;
  v_codfrais_cumul    NATFRAIS.CODFRAIS%TYPE;
  v_coeff             NUMBER(3);
  v_type_prest        NUMBER(2);
  loc_action          porte_natfrais.action%TYPE;
  v_DatePresciption   VARCHAR2(50):=NULL;
  i                   NUMBER :=0; -- Compteur des prestations optiques du flux
  t                   NUMBER :=0;
  k                   NUMBER :=0;-- Compteur des prestations optiques après transco
  --cpt                 NUMBER :=0;
  j                   NUMBER :=0;

  loc_nature          VARCHAR2(20);
  v_codfraisSPS       VARCHAR2(20);

  v_cod_err           NUMBER:=0;
  v_acte_err_code     VARCHAR2(2):='00';
  v_acte_err_lib      VARCHAR2(300);
  v_etat              NUMBER:=0;


  loc_path_xml        VARCHAR2(100) :='oiamCREQ/partenariat/propositionClient/';
  loc_path_patient    VARCHAR2(100) :='oiamCREQ/patient/';
  loc_path_pec2       VARCHAR2(100) :='oiamCREQ/priseEnChargeDetaillee[2]/';
  loc_path_pec1       VARCHAR2(100) :='oiamCREQ/priseEnChargeDetaillee[1]/';

  loc_nbrLentilleBoite  NUMBER(3):=0;
  v_nature_ntfrs_detail NUMBER(1);
  v_nature_Retour     VARCHAR2(3);  -- Utilise pour le flux retour dans le detail de la prestation : VER, LUN, LEN
  T_ntfrs_optique     NTFRS_OPTIQUE_T:=NTFRS_OPTIQUE_T(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  T_type_monture      TYPE_MONTURE_T:=TYPE_MONTURE_T(NULL,NULL);
  T_ntfrs_vision      NTFRS_VISION_T:=NTFRS_VISION_T(NULL,NULL,NULL);
  T_ntfrs_typ_vision  NTFRS_TYP_VISION_T:=NTFRS_TYP_VISION_T(NULL,NULL,NULL);
  T_ntfrs_matiere     NTFRS_MATIERE_T:=NTFRS_MATIERE_T(NULL,NULL,NULL);
  T_ntfrs_type_sup    NTFRS_TYPE_SUP_T:=NTFRS_TYPE_SUP_T(NULL,NULL,NULL,NULL,NULL);
  T_renew_lentille    RENEW_LENTILLE_T:=RENEW_LENTILLE_T(NULL,NULL,NULL);

  loc_t_equip                    TAB_T_EQUIP; --RKO WS RAC DEROG


 -- v_qteActeSPS        NUMBER(2):=0;  -- quantité d'acte SPSante
  v_qteActeArthus     NUMBER(2):=0;  -- quantité d'acte SPSante
  v_libelle           VARCHAR2(200):=NULL;      /* 27/04/2021 ARO ARTGEREP-397 Modification adresse mail */
  v_code                VARCHAR2(2):=NULL;
  v_raison              VARCHAR2(1):=NULL;
  v_justification       VARCHAR2(1):=NULL;

  v_motif               VARCHAR2(2):=NULL;
  v_decision_AMC        VARCHAR2(50):=NULL;
  loc_xml xmltype;
  l_out varchar2(110);
  v_deb NUMBER;
  v_delai NUMBER;

  P_TRAV_SAISIE                  TRAV_SAISIE%ROWTYPE;     -- necessaire à l'enregistrement du réseau de soins
  l_sid                          NUMBER(8);


  loc_attente                    NUMBER :=0;     -- afin de mettre en attente des douvle vision ou un changement de dioptrie
  loc_dioptrie                   NUMBER :=0;
  loc_numfor                     NUMBER:=0;

  loc_objet_email  VARCHAR2(100):=NULL;
  loc_mess_email   VARCHAR2(150):=NULL;
  v_loc_oeil       VARCHAR2(2);
  v_oeil_derog     VARCHAR2(2);
  loc_trav         TRAV_SAISIE%ROWTYPE;
  cpt_trav         NUMBER;
  loc_sinistre_verre sinistre_verre%ROWTYPE;
  loc_res_derog      pk_funct.DerogOptique_T;
  cpt_derog          NUMBER :=0;
  l_derog            VARCHAR2(10);
  loc_prixmax_acte   acte.prixmax%TYPE :=0;
  loc_verre_droit    sinistre_verre%ROWTYPE;
  loc_verre_gauche   sinistre_verre%ROWTYPE;
  -- MUR M0006647
  loc_cpt_balise number ;
  loc_num_balise number ;
  v_numequip     number;

BEGIN
  G_IDLIGNE := 0;
  v_libelle:='';
  P_Init_Editique;
  loc_xml:=P_xml.EXTRACT('/');
  l_out := substr(loc_xml.getClobval(),1,110);
  DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');
  P_INS_journal(1,'Début de la procédure CreerPEC');
  -- ***************************************************************************
  -- * Validation XML Question / Création XML Réponse
  -- ***************************************************************************
  -- récupération dynamique du namespace
  l_outxmlns:=pk_xml.GET_XMLNS(P_xml,'/');
  -- Initialisation des namespaces XML
  IF pk_xml.vg_outxmlns IS NOT NULL THEN
    pk_xml.vg_xmlns := 'xmlns:'|| pk_xml.vg_outxmlns||'="http://modele.ws.tpo.cga.com"';
  ELSE
    Pk_Xml.Vg_Xmlns := 'xmlns="http://modele.ws.tpo.cga.com"';

  End If;
  -- Initialisation XML réponse
  v_deb:=DBMS_UTILITY.GET_TIME;
  pk_xml.new_xml;
  BEGIN
    -- Historisation du flux aller "Demande de prise en charge/ Calcul de reste à charge"
    v_id_flux := pk_ws.insert_flux(p_id_type       => 16,
                                   p_id_flux_tiers =>PK_XML.EXTRACT_DATA(P_xml,'oiamCREQ/identification',null,1),
                                   p_doc_xml       => P_xml,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );
    P_INS_journal(2,'Insertion du flux XML ok en base');
    IF v_cod_err <> 0 THEN
       P_INS_journal(2,v_id_flux||' creerPEC INVALID', 'Historisation du flux ko');
       v_libelle:='Historisation du flux OIAMCREQ KO';
       RAISE exc_flux_inconnue;
    END IF;
    P_INS_journal(2,'Historisation du flux XML ok en base');
    -- Validation du flux aller
    IF NOT pk_ws.is_flux_valid(P_xml, 16, v_id_flux) THEN
       P_INS_journal(2,v_id_flux||' creerPEC INVALID', 'Validation du flux aller ko');
       v_libelle:='Validation du flux OIAMCREQ KO';
       RAISE exc_flux_inconnue;
    END IF;

    P_INS_journal(2,v_id_flux||' Validation du flux OIAMCREQ OK');

    -- ***************************************************************************
    -- * Construction du corps de la réponse -> fichier XML à mini
    -- ***************************************************************************
    loc_Tab_Indiv := F_extract_individu(p_xml,loc_path_patient,loc_path_pec1,loc_path_pec2);

    -- Ecriture de l entete de reponse
    loc_typeFlux := ConstructPriseEnCharge( P_Tab_Indiv    => loc_Tab_Indiv
                                          , p_xml          => p_xml
                                          , I_path_patient => loc_path_patient
                                          , I_path_pec1    => loc_path_pec1
                                          , I_path_pec2    => loc_path_pec2
                                          , I_path_xml     => loc_path_xml
                                          , KO             => FALSE
                                          , P_AvisPEC      => loc_AvisPEC);

    P_INS_journal(2,v_id_flux||' loc_Tab_Indiv(''assure'').numindiv:  '|| loc_Tab_Indiv('assure').numindiv
                             ||','||' loc_Tab_Indiv(''bene'').datnais:'|| loc_Tab_Indiv('bene').datnais
                             ||','||' loc_Tab_Indiv(''bene'').rang:   '|| loc_Tab_Indiv('bene').rang);
    -- ***************************************************************************
    -- * Controles
    -- ***************************************************************************
    -- Identification de l'assuré figurant sur la carte de TP et du bénéficiaire retourne les identifiants et met à jour le tableau de détail
    --Si le numéro d'adhérent, la date de naissance et le rang sont corrects, l'AMC doit accorder la PEC -> RG CDC donc on ne vérifie pas le nom et prénom !
    --ajoute le numéro de sécu ? sont-ils en ordre chez GEREP ? a voir....

    PK_CTRL_TP.P_FIND_ASSURE(P_numassu       => loc_Tab_Indiv('assure').numindiv,
                            P_secu          => /*PK_XML.EXTRACT_DATA(p_xml,'oiamCREQ/patient/identite_NIR',1)*/ null,
                            P_datenais      => loc_Tab_Indiv('bene').datnais,
                            P_rang          => loc_Tab_Indiv('bene').rang,
                            IO_tab_indiv    => loc_Tab_Indiv);


    IF loc_Tab_Indiv('assure').numindiv = 0 THEN
      v_libelle:='Echec, assuré inconnu';
      P_INS_journal(2,v_id_flux||' creerPEC err contrat', v_libelle);
      P_INS_journal(2,v_id_flux||' loc_Tab_Indiv(''bene'').nom:'|| loc_Tab_Indiv('bene').nom);
      RAISE exc_assu_inconnu;
    END IF;

    IF loc_Tab_Indiv('bene').numindiv = 0 THEN
      v_libelle:='Echec, patient inconnu';
      P_INS_journal(2,v_id_flux||' creerPEC err contrat', v_libelle);
      RAISE exc_assu_inconnu;
    END IF;

    --Mises à jour correctives des données si l'opérateur de PEC a transmis des erreurs
    pk_xml.merge_data('patient','famille', loc_Tab_Indiv('bene').nom , false);
    pk_xml.merge_data('patient','prenom',  loc_Tab_Indiv('bene').prenom, false);
    pk_xml.merge_data('patient','naissance',F_D2DATEHEURE(loc_Tab_Indiv('bene').datnais), false);
    pk_xml.merge_data('patient','rang',  loc_Tab_Indiv('bene').rang, false);

    -- Contr¶le du contrat
    PK_CTRL_TP.P_FIND_CONTRAT_BY_ASSU(
      loc_Tab_Indiv('assure').numindiv,
      loc_Tab_Indiv('bene').numindiv,
      g_grpporte,
      loc_idadhesion,
      loc_numgar,
      loc_isColl,
      loc_libelle,
      loc_dateEffet,
      loc_dateRes,
      loc_numorg,
      loc_numporte,
      erreur_contrat);

     P_INS_journal(2,v_id_flux||' creerPEC ctrl assu', loc_Tab_Indiv('bene').numindiv||' adhésion :'||loc_idadhesion);
    IF erreur_contrat = 1 THEN
       v_libelle:='Echec, n de contrat inconnu/ n interne inconnu';
       P_INS_journal(2,v_id_flux||' creerPEC err contrat', v_libelle);
       RAISE exc_reference_inconnue;
    ELSIF erreur_contrat = 2 THEN
       RAISE exc_TP_ferme;
    ELSIF erreur_contrat <> 0 THEN
       v_libelle:='Erreur inconnue';
       P_INS_journal(2,v_id_flux||' creerPEC err contrat',v_libelle);
       RAISE exc_contrat_invalide;
    END IF;

    -- Contr¶le Etat du contrat
    V_etatCntrt := PK_CTRL_TP.F_CTRL_CNTRT(loc_numgar,SYSDATE);
    IF V_etatCntrt = 3 THEN
      P_INS_journal(2,v_id_flux||' creerPEC etat contrat', 'Pas de remboursement possible : le contrat est resilie');
      v_libelle:='Pas de remboursement possible : le contrat est résilié';
      RAISE exc_contrat_invalide;
    ELSIF V_etatCntrt <> 1 THEN
      P_INS_journal(2,v_id_flux||' creerPEC etat contrat', 'exc_contrat_invalide');
      v_libelle:='Le contrat est invalide';
      RAISE exc_contrat_invalide;
    END IF;
     P_INS_journal(2,v_id_flux||' creerPEC ctrl cntrt', loc_Tab_Indiv('bene').numindiv||' loc_numgar :'||loc_numgar);
    -- Contr¶le de l'adhésion
    PK_CTRL_TP.P_CTRL_ADHESION (loc_idadhesion,
                                loc_numgar,
                                null,
                                false,
                                loc_etatAdhe,
                                erreur_adhesion);
    IF erreur_adhesion IN (7,8,9) THEN
      P_INS_journal(2,v_id_flux||' creerPEC err adh', 'Pas de remboursement possible : l''adhesion n''est pas en cours');
      v_libelle:='Pas de remboursement possible : l''adhéion n''est pas en cours';
      RAISE exc_adhe_invalide;
    ELSIF erreur_adhesion <> 0 THEN
      P_INS_journal(2,v_id_flux||' creerPEC err adh', 'exc_erreur_inconnue');
      v_libelle:='Erreur inconnue';
      RAISE exc_adhe_invalide;
    END IF;

    -- Contr¶le de couverture du bénéficaire
    loc_isCouvert := PK_CTRL_TP.F_CTRL_couverture(loc_Tab_Indiv('bene').numindiv,1,'C',SYSDATE);--'O ou C...
    IF NOT loc_isCouvert THEN
      P_INS_journal(2,v_id_flux||' creerPEC couvert', 'Pas de remboursement possible : Le patient n''est plus couvert par le contrat');
      v_libelle:='Pas de remboursement possible : Le patient n''est plus couvert par le contrat';
      raise exc_adhe_invalide;
    END IF;


   -- Contr¶le de droit TP du bénéficaire
    loc_isTP := PK_CTRL_TP.F_CTRL_rang(loc_Tab_Indiv('bene').numindiv,loc_idadhesion,1,'C',sysdate);--'O ou C...
    IF NOT loc_isTP THEN
      RAISE exc_TP_ferme;
    END IF;

    -- Controle de l assureur

    /*TO DO revoir cette procédure pour gestion des contacts et gestion du type de PS*/
    PK_CTRL_TP.P_FIND_TIERS(
         P_NNI=> PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'executant/identite_ADELI',null,1),
         P_typePS => '23',
         P_raison=> PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'executant/pPhysique/nom/famille',null,1)
          ||' '|| PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'executant/pPhysique/nom/prenom',null,1),
         P_tel=>PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'executant/pPhysique/telecom/type',null,1),
         P_mail=> PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'executant/pPhysique/telecom/type',null,1),
         O_numindivPS => loc_numindivPS);
    -- Erreur loc_numindivPS null car insertion impossible en base de donnée
    IF loc_numindivPS IS NULL THEN
      P_INS_journal(2,v_id_flux||' creerPEC PS', 'exc_erreur_inconnue');
      v_libelle:='Insertion impossible en base de donnees du practicien';
      RAISE exc_PS_inconnue;
    ELSIF loc_numindivPS =-1 THEN
      P_INS_journal(2,v_id_flux||' Doublon de PS en base');
      v_libelle:='Doublon de PS en base';
      RAISE exc_PS_inconnue;
    END IF;

    -- le nombre de mois de péremption est stocké  par le champ sens de la table libelle, Mnemo HISTO_D1
    loc_sens:=F_SENS_LIBELLE('HISTO_D1', 2);
    SELECT TO_CHAR(SYS_CONTEXT('USERENV', 'SID')) INTO l_sid FROM DUAL;
    -- insertion du réseau de soins si celui-ci est existant sur la porte ainsi que les dents si c est une PEC dentaire
    -- Cette insertion est un pansement pour palier le fait que la dll ne récupère pas la bonne session entre PK_ITELIS et gs19_xit (2 connexions Arthus, donc 2 sid différents)
    P_TRAV_SAISIE.SID:= l_sid;
    BEGIN
      SELECT numutil INTO P_TRAV_SAISIE.USERNAME from porte_param where numporte=loc_numporte;
    EXCEPTION
      WHEN OTHERS THEN
        SELECT F_NUMUTIL INTO P_TRAV_SAISIE.USERNAME FROM DUAL;
    END;
    P_TRAV_SAISIE.NUMSIN:=  NULL;
    P_TRAV_SAISIE.RESEAU:=NVL(F_SENS_LIBELLE('PORTE',loc_numporte),loc_numporte);  -- réseau de soins
    IF loc_typeFlux=2 THEN
      -- Création du dossier_sante
      P_INS_journal(2,' P_INS_DOSSIER_SANTE');
      PK_CTRL_TP.P_INS_DOSSIER_SANTE(
              P_ref         => loc_AvisPEC,
              P_numindiv    => loc_Tab_Indiv('bene').numindiv,
              P_PS          => loc_numindivPS,
              P_numassu     => f_numassu(loc_Tab_Indiv('bene').numindiv,loc_idadhesion), -- loc_Tab_Indiv('assure').numindiv
              P_numporte    => loc_numporte,
              P_natdoss     => 2,  -- Concerne que l optique
              P_typedoss    => 4, --dossier de prise en charge
              P_num_dossier_porte => loc_AvisPEC,--loc_numdossierPorte, --> av voir si c est le bon numéro
              O_num_dossier => loc_num_dossier);

      P_INS_journal(2,v_id_flux||     ' creerPEC Dossier n:'||loc_num_dossier
                               ||','||' creerPEC', 'loc_AvisPEC:'||loc_AvisPEC);

      IF loc_num_dossier = 0 THEN
        RAISE exc_erreur_inconnue; --le numéro de dossier externe existe déjà dans le système
      END IF;
      -- mise à jour de la reférence externe de l'individu
      loc_refDomaine :=F_get_transco('GRP','DOMSP','02');

      PK_CTRL_TP.P_MAJ_REF_EXTERNE(
          P_numindiv    => loc_Tab_Indiv('bene').numindiv,
          P_domaine     => loc_refDomaine,
          P_tiers       => 'GRP',
          P_mnemo       => 'DOMSP');

      -- Historisation du dossier créé en cours
      PK_CTRL_TP.P_INS_HISTO_DOSSIER(
              P_num_dossier => loc_num_dossier,
              P_etat        => 0,
              P_motif       => 0);
      -- Historisation du dossier avec la date de peremption
      PK_CTRL_TP.P_INS_HISTO_DOSSIER(
              P_num_dossier => loc_num_dossier,
              P_etat        => 1,
              P_motif       => 2,
              P_date        => ADD_MONTHS( SYSDATE, loc_sens ));
    END IF;

        -- Contr¶le sur la gestion des abus sur le nombre de demande de devis et/ou prise en charge
    loc_ErrAbus:= gestionAbus(loc_Tab_Indiv('bene').numindiv
                , loc_Tab_Indiv('assure').numindiv
                , loc_Tab_Indiv('bene').rang
                , loc_Tab_Indiv('bene').datnais
                , PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'prestationOptique[1]/identifiant',null,1) --verre ou lentille
                , loc_numindivPS
                , PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'executant/identite_ADELI',null,1)
                , loc_typeFlux);
    IF loc_ErrAbus=5 THEN  --WS RAG DEROG gestion abus pec accordée par adhésion
      raise exc_abus_pec_adhe;
    ELSIF loc_ErrAbus <>0 THEN
      raise exc_abus;
    END IF;

	  P_INS_journal(3,v_id_flux||' avant PK_CTRL_TP.Fetch_garanties_adhe');
		-- Parcours des garanties de l adhérent : si garantie principale non trouvée, on prend la garantie facultatif sinon on sort en erreur
	  OPEN PK_CTRL_TP.Fetch_garanties_adhe(loc_idadhesion, loc_Tab_Indiv('bene').numindiv) ;
      FETCH PK_CTRL_TP.Fetch_garanties_adhe INTO C_lstGar;

      P_INS_journal(3,v_id_flux||' apres PK_CTRL_TP.Fetch_garanties_adhe');
      IF PK_CTRL_TP.Fetch_garanties_adhe%NOTFOUND THEN
        CLOSE  PK_CTRL_TP.Fetch_garanties_adhe;
      P_INS_journal(2,v_id_flux||' RAISE exc_garantie_inconnue');
      RAISE exc_garantie_inconnue;
      END IF;
      P_INS_journal(3,v_id_flux||' C_lstGar.numfor:'||C_lstGar.numfor);
      loc_numfor:=C_lstGar.numfor;
    CLOSE PK_CTRL_TP.Fetch_garanties_adhe;
    -- ***************************************************************************
    -- * Boucle sur les actes
    -- * TRANSCODIFICATION + CTRL COUVERTURE + CTRL DONNEE UTILISATEUR
    -- ***************************************************************************
    i:=0;--compteur fichier xml
    t:=0;--pointeur du parcourt dans le tableau acte
    --cpt :=0;--compteur tableau acte

    LOOP
      P_INS_journal(2,v_id_flux||' Boucle sur les actes');
      i := i +1;
      v_codfraisSPS :=PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'prestationOptique['||i||']/identifiant',null,1);
      IF TRIM(v_codfraisSPS) IS NULL THEN
        EXIT;
      END IF;

      -- Recherche de la garantie prinicpale de l adhesion. Si celle ci n'est pas trouvé, on prend la garantie optionnelle, erreur si aucune trouvée
      -- Boucle sur les garantie
      BEGIN
        IF v_codfraisSPS = 'VERRE' THEN
          v_nature_ntfrs_detail:=1;
          T_ntfrs_optique.sphere_deb :=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/sphere',null,1);
          T_ntfrs_optique.cylindre_deb :=NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/cylindre',null,1),0);
          T_ntfrs_optique.addition_deb :=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/addition',null,1);
          -- Si l indice n est pas renseignée on prend la plage d indice
          T_ntfrs_optique.aminci_deb :=NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/indice',null,1),PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/plageindice',null,1));
          T_ntfrs_optique.teinte :=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/teinte',null,1);
          T_ntfrs_vision.vision:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/vision',null,1);
          T_ntfrs_typ_vision.type_vision:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/type',null,1);
          T_ntfrs_matiere.matiere:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/matiere',null,1);
       --   loc_attente:=loc_attente+1;
          loc_t_equip(i).SPHERE_VER_DEB := PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/sphere',null,1);
          loc_t_equip(i).CYLINDRE_VER_DEB := NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/cylindre',null,1),0);
          loc_t_equip(i).ADDITION_VER_DEB := PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/addition',null,1);
          --loc_t_equip(i).AMINCI_VER_DEB := NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/axeDuCylindre',null,1),0); -- si recupération de la balise axeDuCylindre ici, le flux pete! la recup se fait alors au niveau de loc_sinistre_verre
          loc_t_equip(i).TEINTE_VER := PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/teinte',null,1);
          loc_t_equip(i).VISION_VER := PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/vision',null,1);
          loc_t_equip(i).TYPE_VISION_VER  := PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/type',null,1);
          loc_t_equip(i).MATIERE_VER := PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/verre/matiere',null,1);
        ELSIF v_codfraisSPS = 'MONTURE' THEN
          v_nature_ntfrs_detail:=2;
          T_type_monture.type_monture :=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/monture/type',null,1);
          T_ntfrs_matiere.matiere:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/monture/matiere',null,1);
        --  loc_attente:=loc_attente+1;
          loc_t_equip(i).type_monture := PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/monture/type',null,1);
          loc_t_equip(i).MATIERE_MONTURE  := PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/monture/matiere',null,1);
        ELSIF v_codfraisSPS = 'LENTILLE' THEN
          v_nature_ntfrs_detail:=3;
          T_ntfrs_optique.sphere_deb :=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/sphere',null,1);
          T_ntfrs_optique.cylindre_deb :=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/cylindre',null,1);
          T_ntfrs_optique.addition_deb :=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/ametropie/addition',null,1);
          T_ntfrs_optique.famille:= PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/lentille/famille',null,1);
          T_ntfrs_vision.vision:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/lentille/vision',null,1);
          T_ntfrs_typ_vision.type_vision:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/lentille/type',null,1);
          T_ntfrs_matiere.matiere:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/lentille/matiere',null,1);
          T_renew_lentille.code:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/lentille/renouvellement',null,1);
          loc_nbrLentilleBoite:=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/equipementOptique/lentille/nbrLentilleBoite',null,1);
          IF loc_nbrLentilleBoite > 12 THEN
            raise nb_limite_lentille;
          END IF;
        ELSIF v_codfraisSPS = 'PRODUIT' THEN
          v_libelle:='Les produits d entretien pour lentille ne sont pas couverts.';
         -- raise exc_produit_entretien;
        END IF;--IF loc_Tab_Acte(i).codfrais = 'VERRE' THEN


        loc_Tab_codfrais.delete;
        IF v_codfraisSPS = 'PRODUIT' THEN
          loc_Tab_codfrais('PRDT'):=loc_Tab_codfrais.COUNT;
          v_acte_err_code:='14';
        ELSE

          -- Recherche d'une Transcodification de l'acte + Contr¶le acte autorisé dans SPSante
          PK_CTRL_TP.P_TRANSCO_CODFRAIS_SPSANTE( loc_numfor
                                               , v_nature_ntfrs_detail
                                               , T_ntfrs_optique
                                               , T_type_monture
                                               , T_ntfrs_vision
                                               , T_ntfrs_typ_vision
                                               , T_ntfrs_matiere
                                               , T_renew_lentille
                                               , NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/conditionDeRemboursement/part',null,1),0)
                                               , loc_Tab_codfrais
                                               , v_acte_err_code --cas 99 uniquement non ?
                                               , PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/codeLPP',null,1) --RKO Rac Optique
                                               );

        END IF;

        P_INS_journal(3,v_id_flux||'v_acte_err_code:'||v_acte_err_code
                                 ||','||'apres transco taille tableau acte:'||loc_Tab_codfrais.COUNT);
        --Vérification du codfrais , création d'une nouvelle colonne dans le tableau si le codfrais n'existe pas
        IF loc_Tab_codfrais.COUNT = 0 THEN--pas de transcodication
        --Vérification du codfrais , création d'une nouvelle colonne dans le tableau si le codfrais n'existe pas
          P_INS_journal(2,v_id_flux||'codfrais IS NULL ');
          --cpt := cpt+1;
          t:=t+1;--cpt;
          loc_Tab_Acte(t).codeErreur := '02';
          RAISE exc_acte_inconnu;
        ELSIF loc_Tab_codfrais.COUNT >1 AND t=0 THEN -- plus d'un acte récupéré pour lentille ou verres
          P_INS_journal(2,v_id_flux||'transco mutiple'||loc_Tab_codfrais.COUNT);
          --cpt := cpt+1;
          t:=t+1;--cpt;
          loc_Tab_Acte(t).codeErreur := '05';--à préciser
          RAISE exc_acte_inconnu;
        ELSIF t=0 THEN --cpt=0  THEN
          P_INS_journal(2,v_id_flux||'t=0 ');
          --cpt := cpt+1;
          t:=t+1;--cpt;
          loc_Tab_Acte(t).codfrais := loc_Tab_codfrais.FIRST ;--retourne le 1er index
          loc_Tab_Acte(t).quantite:=0;
          loc_Tab_Acte(t).nbpresentation:=0;
          P_INS_journal(3,v_id_flux||'ELSIF t=0  THEN nbpresentation remis a 0:'||loc_Tab_Acte(t).nbpresentation);
        ELSE
          --v_codfrais <> loc_Tab_Acte(t).codfrais THEN
          P_INS_journal(2,v_id_flux||'ELSE:');

          FOR k IN 1 .. loc_Tab_Acte.COUNT LOOP
            P_INS_journal(3,v_id_flux||'FOR k = :'||k);
            P_INS_journal(3,v_id_flux||'loc_Tab_Acte.COUNT:'||loc_Tab_Acte.COUNT);
            P_INS_journal(3,v_id_flux||'loc_Tab_Acte('||k||').codfrais:'||loc_Tab_Acte(k).codfrais);
            P_INS_journal(3,v_id_flux||'nbpresentation:'|| loc_Tab_Acte(t).nbpresentation||'nature:'||v_nature_ntfrs_detail);

            IF k = loc_Tab_Acte.COUNT THEN
              P_INS_journal(3,v_id_flux||'ELSIF k=loc_Tab_Acte.COUNT:'||k);
              --cpt := cpt+1;
              t:=t+1;--cpt;
              IF loc_Tab_codfrais.COUNT>1 THEN --transo multiple et pas d'acte correspondant dans les transco précédentes
                 IF i>3 THEN
                   loc_Tab_Acte(t).codeErreur := '05';
                   RAISE exc_double_vision;
                 ELSE
                   loc_Tab_Acte(t).codeErreur := '05';
                   RAISE exc_acte_inconnu;
                 END IF;
              ELSE
                  loc_Tab_Acte(t).codfrais := loc_Tab_codfrais.FIRST ;--transco pas multiple
                  loc_Tab_Acte(t).quantite:=0;
                  loc_Tab_Acte(t).nbpresentation:=0;
                  P_INS_journal(3,v_id_flux||'transco pas multiple nbpresentation remis a 0:'||loc_Tab_Acte(t).nbpresentation);
              END IF;
              P_INS_journal(3,v_id_flux||'t :'||t);
            END IF;

          END LOOP;
        END IF;
        P_INS_journal(2,v_id_flux||'loc_Tab_Acte(t).codfrais:'||loc_Tab_Acte(t).codfrais);
        loc_Tab_Acte(t).numequip :=i; --le numéro d'equipement parcouru
        P_INS_journal(1,v_id_flux|| ' numequip:'||loc_Tab_Acte(t).numequip||' acte '||loc_Tab_acte(t).codfrais);
        --Récupération des montants après transcodification
        loc_Tab_Acte(t).mtro := NVL( loc_Tab_Acte(t).mtro,0)+ NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/conditionDeRemboursement/part',null,1),0);
        loc_Tab_Acte(t).base :=  NVL( loc_Tab_Acte(t).base,0)+  NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||i||']/conditionDeRemboursement/base',null,1),0);--à revoir
        loc_Tab_Acte(t).remise := NVL(loc_Tab_Acte(t).remise,0) + NVL(PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'prestationOptique['||i||']/abattements',null,1),0);
        P_INS_journal(1,v_id_flux|| ' rko identifiant:'||NVL(PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'prestationOptique['||i||']/equipement/identifiant',null,1),1)||' acte '||loc_Tab_acte(t).codfrais);
        loc_Tab_Acte(t).identifiant := NVL(PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'prestationOptique['||i||']/equipement/identifiant',null,1),1);
        P_INS_journal(1,v_id_flux|| ' rko loc_Tab_Acte(t).identifiant:'||loc_Tab_Acte(t).identifiant||' acte '||loc_Tab_acte(t).codfrais);
        IF NVL(loc_Tab_Acte(t).mtro,0)=0 THEN
          loc_Tab_Acte(t).taux :=0;
        ELSE
          loc_Tab_Acte(t).taux := round(loc_Tab_Acte(t).mtro / loc_Tab_Acte(t).base,2) *100;
        END IF;
        loc_Tab_Acte(t).mtfrais := NVL(loc_Tab_Acte(t).mtfrais,0) + NVL(PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'prestationOptique['||i||']/depense',null,1),0);
        --RAC DEROG WS gestion des abus depassement de frais réel de prest par rapport au paramétrage
        P_INS_journal(1,v_id_flux|| ' acte '||loc_Tab_acte(t).codfrais||' loc_Tab_Acte(t).mtfrais '||loc_Tab_Acte(t).mtfrais||' depense '||NVL(PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'prestationOptique['||i||']/depense',null,1),0));
        BEGIN
          SELECT prixmax INTO loc_prixmax_acte FROM acte WHERE codfrais = loc_Tab_acte(t).codfrais;
          IF loc_Tab_Acte(t).mtfrais - loc_Tab_Acte(t).remise > loc_prixmax_acte THEN
            RAISE exc_abus_fr_reel;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN P_INS_journal(1,v_id_flux|| ' Pas de prixmax paramétré pour l''acte '||loc_Tab_acte(t).codfrais);
        END;

        loc_Tab_Acte(t).codfraisSPS:=v_codfraisSPS;
        loc_Tab_Acte(t).codeErreur :=v_acte_err_code;
        --Permet de récuperer le paramètre "CUMUL" de la transco,de l acte Arthus. Si le paramètre "CUMUL" est activé,on quantitfie le nombre de prestation pour un meme acte
        IF PK_CTRL_TP.F_CUMUL_ACTE(loc_Tab_Acte(t).codfrais) AND loc_Tab_Acte(t).codfrais<> 'PRDT' THEN
          loc_Tab_Acte(t).quantite :=loc_Tab_Acte(t).quantite+1;
        ELSE
          loc_Tab_Acte(t).quantite:=1;

        END IF;
        loc_Tab_Acte(t).nbpresentation:=loc_Tab_Acte(t).nbpresentation + 1;

        P_INS_journal(2,v_id_flux||'loc_Tab_Acte(t).quantite:'||loc_Tab_Acte(t).quantite
                                 ||','||'loc_Tab_Acte(t).nbpresentation:'|| loc_Tab_Acte(t).nbpresentation);

        IF loc_Tab_Acte(t).codeErreur NOT IN ('00','14') THEN
          RAISE exc_acte_inconnu;
        END IF;

        -- ***************************************************************************
        -- * Actes : Controles
        -- ***************************************************************************
        loc_datsin := sysdate;
        v_DatePresciption:=PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'premed/date',null,1);
        --P_INS_journal(2,v_id_flux||' v_DatePresciption'|| v_DatePresciption);

        -- en optique la date de prescription est obligatoire sauf si le motif est ouvert sur l acte
        IF TRIM(v_DatePresciption) IS NULL THEN
         loc_ordoOpen :=F_SENS_LIBELLE('ORDO_MOTIF',PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'motif',null,1));--ABO 26/12/2011
          IF loc_ordoOpen IS NULL THEN
             loc_Tab_Acte(t).codeErreur := '27';
             RAISE exc_ordonnance;
          END IF;
        END IF;


        IF loc_Tab_Acte(t).codeErreur IN ( '00','14') THEN

         -- P_INS_journal(2,v_id_flux||'loc_Tab_Acte('||t||').codfrais:'||loc_Tab_Acte(t).codfrais);
          -- Contr¶le de couverture de l'acte
          PK_CTRL_TP.P_CTRL_CVRT_ACTE(loc_Tab_Acte(t).codfrais,
                                      loc_Tab_Indiv('bene').numindiv,
                                      loc_datsin,
                                      loc_idadhesion,
                                      loc_acteCouvert,
                                      erreur_acte);
          IF erreur_acte = 5 THEN
            P_INS_journal(2,v_id_flux||' creerPEC acte 09', '');
            loc_Tab_Acte(t).codeErreur := '09'; -- Date sinistre incohérente
          ELSIF erreur_acte <> 0 THEN
            P_INS_journal(2,v_id_flux||' creerPEC 08 erreur_acte'||erreur_acte);
            loc_Tab_Acte(t).codeErreur := '08';  -- Acte non garanti
          END IF;
        END IF;

        -- **********************************************************************************
        -- * Gestion du cumul des suppléments optique
        -- **********************************************************************************
        -- Affectation des variables avant lancement calcul de prestation
        V_mtprest:=0;
        v_rac:=0;
        v_coeff :=1; -- car le coefficient ne s applique que pour du dentaire==> Seveane
        IF NOT loc_acteCouvert THEN
          RAISE exc_acte_inconnu;
        ELSIF loc_acteCouvert AND loc_Tab_Acte(t).codeErreur IN ('00','08','09')  THEN

           P_INS_journal(2,v_id_flux||'loc_Tab_Acte.COUNT'||to_char(loc_Tab_Acte.COUNT));
           P_INS_journal(2,v_id_flux||' Cumul des montants loc_Tab_Acte(t).codfrais'||loc_Tab_Acte(t).codfrais);
           P_INS_journal(2,v_id_flux||' Cumul des montants loc_Tab_Acte(t).codfraisSPS'||loc_Tab_Acte(t).codfraisSPS);
           -- Gestion des suppléments verre
           IF loc_Tab_Acte(t).codfraisSPS = 'VERRE' THEN
             loc_nature :='Verre';
           -- Gestion des suppléments Monture
           ELSIF loc_Tab_Acte(t).codfraisSPS = 'MONTURE' THEN
             loc_nature :='Monture';
           -- Gestion des suppléments Lentille
           ELSIF loc_Tab_Acte(t).codfraisSPS = 'LENTILLE' THEN
             loc_nature :='Lentille';
           ELSIF loc_Tab_Acte(t).codfraisSPS = 'SUPPLEMENT' THEN
             loc_nature :='Supplement';
           END IF;

		   /*loc_Tab_Acte(t).codelpp_supplRO := NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||v_numequip||']/supplementOptique/supplementRO/codeLPP',null,1),0);
		   */

          IF TRIM(loc_nature) IS NOT NULL THEN
            SupplActe( IO_TabActe     => loc_Tab_Acte
                      ,p_xml         => p_xml
                      ,I_niv         => t
                      ,I_path        => loc_path_xml || 'prestationOptique['||i||']/'
                      ,I_type        => loc_nature
                      ,I_nature      => v_nature_ntfrs_detail );

            SupplROActe(IO_TabActe => loc_Tab_Acte
                        ,I_xml           => p_xml
                        ,IO_niv          => t
                        ,I_path          => loc_path_xml || 'prestationOptique['||i||']/'
                        ,I_type          => loc_nature
                        ,I_nature        => v_nature_ntfrs_detail
                        ,I_numfor        => loc_numfor
                        ,IO_Tab_codfrais  => loc_Tab_codfrais
                        ,IO_acte_err_code => v_acte_err_code
                        );
            P_INS_journal(1,v_id_flux|| 'DAns boucle t supplement loc_Tab_Acte(t).identifiant:'||loc_Tab_Acte(t).identifiant||' acte '||loc_Tab_acte(t).codfrais);
            P_INS_journal(1,v_id_flux||'DAns boucle t supplement loc_Tab_Acte(t).codfrais:'||loc_Tab_Acte(t).codfrais);
            P_INS_journal(1,v_id_flux||'DAns boucle t supplement loc_Tab_Acte(t).mtfrais:'||loc_Tab_Acte(t).mtfrais);
            P_INS_journal(1,v_id_flux||'DAns boucle t supplement loc_Tab_Acte(t).mtro:'||loc_Tab_Acte(t).mtro);
            P_INS_journal(1,v_id_flux||'DAns boucle t supplement loc_Tab_Acte(t).remise:'||loc_Tab_Acte(t).remise);
            P_INS_journal(1,v_id_flux||'DAns boucle t supplement loc_Tab_Acte(t).mtro_sup:'||loc_Tab_Acte(t).mtro_sup);
            P_INS_journal(1,v_id_flux||'DAns boucle t supplement loc_Tab_Acte(t).remise_sup:'||loc_Tab_Acte(t).remise_sup);
            P_INS_journal(1,v_id_flux||'DAns boucle t supplement loc_Tab_Acte(t).mtfrais_sup:'||loc_Tab_Acte(t).mtfrais_sup);
          END IF;
        END IF;--IF loc_acteCouvert AND v_acte_err_code = '00' THEN
      END;
    END LOOP;

    -- ***************************************************************************
    -- * Boucle sur le tableau des actes optiques Arthus
    -- * CALCUL DU RAC - CREATION DU DOSSIER DE PEC
    -- ***************************************************************************
   -- mise en place de la dérogation optique RAC WS sur les devis et PEC
    FOR j IN 1 .. loc_t_equip.COUNT LOOP
      --recupération des sinistres verres du flux
      --reinitialisation de l'objet loc_sinistre_verre
      loc_sinistre_verre.oeil := null;
      loc_sinistre_verre.sphere := null ;
      loc_sinistre_verre.cylindre := null;
      loc_sinistre_verre.addition := null;
      loc_sinistre_verre.axe :=  null;
      v_oeil_derog :=PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||j||']/ametropie/oeil',null,1);
      IF v_oeil_derog = '2D' THEN
        loc_sinistre_verre.oeil := 'D';
      ELSIF v_oeil_derog = '2G' THEN
        loc_sinistre_verre.oeil := 'G';
      END IF;
      IF loc_sinistre_verre.oeil IS NOT NULL THEN
        loc_sinistre_verre.sphere := NVL(loc_t_equip(j).SPHERE_VER_DEB,0) ;
        loc_sinistre_verre.cylindre := NVL(loc_t_equip(j).CYLINDRE_VER_DEB,0);
        loc_sinistre_verre.addition := NVL(loc_t_equip(j).ADDITION_VER_DEB,0);
        loc_sinistre_verre.axe := NVL(PK_XML.EXTRACT_DATA(p_xml,loc_path_xml || 'prestationOptique['||j||']/ametropie/axeDuCylindre',null,1),0);
		--RKO M0007213 recuperation de la balise axeDucylindre si elle existe --avec NVL(loc_t_equip(j).AMINCI_VER_DEB,0) ca pète;
      ELSE --RKO M0007214  reinitialisation de l'objet loc_sinistre_verre avec null afin de ne pas deroger avec les caractéristiques 0 sur une monture
        loc_sinistre_verre.sphere := null ;
        loc_sinistre_verre.cylindre := null;
        loc_sinistre_verre.addition := null;
        loc_sinistre_verre.axe :=  null;
      END IF;
      IF  loc_sinistre_verre.oeil = 'D' THEN   --M0007228
        loc_verre_droit := loc_sinistre_verre;
      ELSE
        loc_verre_gauche := loc_sinistre_verre;
      END IF;
      --controle de l'éligibilité de l'équipement à la derog
      loc_res_derog := PK_FUNCT.F_DerogOptique (p_numIndiv    =>loc_Tab_Indiv('bene').numindiv
                                            , p_datSin       => TRUNC(sysdate) --ajout du trunc artgerep_398
                                            , p_codFrais     =>loc_Tab_acte(j).codfrais
                                            , p_verre_droit  =>loc_verre_droit--loc_sinistre_verre
                                            , p_verre_gauche =>loc_verre_gauche--loc_sinistre_verre
                                             ) ;
      IF loc_res_derog.derogOptique ='OUI' THEN cpt_derog :=cpt_derog+1; END IF;
    END LOOP;
    IF cpt_derog>0 THEN l_derog :='OPTI'; ELSE l_derog :=null; END IF;
    P_INS_journal(1,v_id_flux||'derog l_derog:'||l_derog);

    FOR i IN 1 .. loc_Tab_Acte.COUNT LOOP
      --IF loc_Tab_Acte(i).codeErreur IN('00','14') AND TRIM(loc_Tab_Acte(i).codfrais) IS NOT NULL THEN on rentre toujours


      v_qteActeArthus:=v_qteActeArthus+1;
      loc_Tab_Acte(i).mtfrais_reel:= NVL(NVL(loc_Tab_Acte(i).mtfrais,0)
                                        -NVL(loc_Tab_Acte(i).remise,0)
                                        +NVL(loc_Tab_Acte(i).mtfrais_supRb,0)
                                        -NVL(loc_Tab_Acte(i).remise_sup,0),0);
      P_INS_journal(1,v_id_flux||'CALCUL DU RAC mtfrais_reel:'||loc_Tab_Acte(i).mtfrais_reel
                               ||','||'mtfrais_supRb:'||loc_Tab_Acte(i).mtfrais_supRb||'remise'||NVL(loc_Tab_Acte(i).remise,0)||'remise_sup'||NVL(loc_Tab_Acte(i).remise_sup,0));

    IF loc_typeFlux=1 THEN
          P_TRAV_SAISIE.NUMLIG:= i;
          --Saisie des verres dans trav_saisie
          P_INS_journal(1,v_id_flux||'devis avt P_INS_TRAVSAI_OPT i'||i||' loc_Tab_Acte(i).codfrais :'||loc_Tab_Acte(i).codfrais||' numequip '||loc_Tab_Acte(i).numequip);
          P_INS_TRAVSAI_OPT (I_cpt        => i,
                            I_path_xml    => loc_path_xml,
                            I_xml         =>p_xml,
                            IO_Tab_Acte   => loc_Tab_Acte,
                            I_tab_equip   => loc_t_equip,
                            I_TRAV_SAISIE => P_TRAV_SAISIE
                            );
          -- Les frais réels sont égales au montant de la prestation optique moins l abattement sur la prestation optique +
          -- le(s) montant(s) de(s) supplément(s) de la prestation optique moins le(s) abattement(s) de(s) supplément(s) sur la prestation optique
          -- Calcul de remboursement de la prestation
          COMMIT;
          erreur_calcul := calculDevis( loc_Tab_Acte
                                        , i
                                        , loc_Tab_Indiv('bene').numindiv
                                        , loc_numindivPS
                                        , l_derog --paramètre définissant la derogation (ou pas) lors du calcul
                                        );
          loc_Tab_Acte(i).messErreur := loc_Tab_Acte(i).messErreur || ErreurCalcul(erreur_calcul,loc_Tab_Acte(i).mtprest);
          V_totmtprest:=NVL(V_totmtprest,0)+NVL(loc_Tab_Acte(i).mtprest,0);

      ELSE
        P_INS_journal(1,v_id_flux||'avt P_INS_SNTR_SANTE i'||i||' loc_Tab_Acte(i).codfrais :'||loc_Tab_Acte(i).codfrais
                              ||','||'loc_Tab_Acte(i).mtfrais_reel '||loc_Tab_Acte(i).mtfrais_reel);

        P_INS_journal(1,v_id_flux||'avt P_INS_SNTR_SANTE loc_Tab_Acte(i).mtro'||NVL(loc_Tab_Acte(i).mtro,0)||' loc_Tab_Acte(i).mtro_sup :'||NVL(loc_Tab_Acte(i).mtro_sup,0));

        -- M4767 Contrôle de la couverture TPE
    IF pk_porte.F_carte_tp(loc_Tab_Indiv('bene').numindiv, loc_Tab_Acte(i).codfrais, sysdate, 0, NULL,  NULL, g_tabCond ) =0 THEN
      v_etat := 3;--état de la prestation à bloqué
    ELSE
      v_etat := 1;
    END IF;

    PK_CTRL_TP.P_INS_SNTR_SANTE(
             P_num_dossier => loc_num_dossier,
             P_numligne    => i,
             P_numindiv    => loc_Tab_Indiv('bene').numindiv,
             P_codfrais    => loc_Tab_Acte(i).codfrais ,
             P_mtfrais     => NVL(loc_Tab_Acte(i).mtfrais_reel,0),
             P_etat        => v_etat,
             P_taux        => loc_Tab_Acte(i).taux, --NVL(loc_Tab_Acte(i).mtro,0)/NVL(loc_Tab_Acte(i).mtro_sup,0)
             P_baseremb    => loc_Tab_Acte(i).base,
             P_mtremb      => NVL(loc_Tab_Acte(i).mtro,0)+NVL(loc_Tab_Acte(i).mtro_sup,0), -- Montant RO + le(s) supplément(s) RO,
             P_datsin      => loc_datsin,
             P_coeff       => v_coeff,
             P_quantite    => loc_Tab_Acte(i).quantite);
      P_INS_journal(3,v_id_flux||'avant P_INS_HISTO_SNTR_SANTE');
        PK_CTRL_TP.P_INS_HISTO_SNTR_SANTE(
             P_num_dossier => loc_num_dossier,
             P_numligne    => i,
             P_etat        => 1,
             P_motif       => 0);

      END IF; -- IF loc_typeFlux=1 THEN
   -- END IF;--IF v_acte_err_code = '00'
    END LOOP;

    -- Calcul du dossier de PEC
    IF loc_typeFlux=2 THEN
      SELECT TO_CHAR(SYS_CONTEXT('USERENV', 'SID')) INTO l_sid FROM DUAL;
      FOR i IN 1 .. loc_Tab_Acte.COUNT LOOP

        P_TRAV_SAISIE.NUMLIG:= i;
        P_INS_journal(1,v_id_flux||'pec avt P_INS_TRAVSAI_OPT i'||i||' loc_Tab_Acte(i).codfrais :'||loc_Tab_Acte(i).codfrais||' numequip '||loc_Tab_Acte(i).numequip);
        P_INS_TRAVSAI_OPT (I_cpt        => i,
                          I_path_xml    => loc_path_xml,
                          I_xml         =>p_xml,
                          IO_Tab_Acte   => loc_Tab_Acte,
                          I_tab_equip   => loc_t_equip,
                          I_TRAV_SAISIE => P_TRAV_SAISIE
                          );
      END LOOP;
       -- ************* calcul de toutes les prestations du dossier ************* --
       -- calcul prestation par prestation
       -- mise à jour du montant de prestation et de l'état de sinistre_sante
       -- historisation de sinistre_sante
       -- insertion dans sinistre avec sens =-1
       COMMIT;

       PK_CALCUL_DOSSIER.P_CALCUL_DOSSIER_SANTE(P_num_dossier => loc_num_dossier,
                                                P_type        => 'devis',
                                                P_tot_prest   => -1, -- on passe -1 car pas de corrélation entre le devis et la PEC
                                                O_erreur      => erreur_dossier,
                                                O_msg_erreur  => msg_dossier,
                                                p_derog => l_derog --paramètre définissant la derogation (ou pas) lors du calcul
                                                );
       P_INS_journal(3,v_id_flux||'erreur_dossier:'||erreur_dossier
                                ||','||'msg_dossier:'||msg_dossier);

       IF erreur_dossier  in (5,9,10) THEN --Ajout de l'erreur 10 pour la suppression du dossier en cas de montant RC=0 (cf M0007071 RKO 02/02/2021)
         ---- on enregistre pas le dossier si aucune prestation dedans ou ano bloquante de calcul
         PK_CTRL_TP.P_SUP_DOSSIER_SANS_PREST_WS(loc_num_dossier);
         COMMIT;
         RAISE exc_prestation_null;
       END IF;
    -- Pour un devis, on controle que le montant global de la prestation ne soit pas à 0
    ELSIF loc_typeFlux=1 THEN
      IF V_totmtprest=0 THEN
        RAISE exc_prestation_null;
      END IF;
    END IF;

    -- ***************************************************************************
    -- * Actes: CONSTITUTION du XML + calcul du reste a charge par acte Arthus
    -- ***************************************************************************
  --  P_INS_journal(2,v_id_flux||'avant boucle Constitution du XML loc_Tab_Acte.COUNT:'||loc_Tab_Acte.COUNT);
    v_qteActeArthus:=0;
    V_totmtprest:=0;
    FOR i IN 1 .. loc_Tab_Acte.COUNT LOOP
      P_INS_journal(3,v_id_flux||'Dans boucle Constitution du XML loc_Tab_Acte(i).codfrais:'||loc_Tab_Acte(i).codfrais);
      v_qteActeArthus:=v_qteActeArthus+1;
      --P_INS_journal(2,'v_acte_err_code'||v_acte_err_code);
      IF (/*v_acte_err_code IN ('00','14') AND*/ TRIM(loc_Tab_Acte(i).codfrais) IS NOT NULL) THEN

        IF loc_typeFlux=2 THEN--PEC
          SELECT NVL(SUM(MTPREST_REEL),0)
            INTO loc_Tab_Acte(i).mtprest
            FROM SINISTRE_SANTE
           WHERE NUM_DOSSIER=loc_num_dossier
             AND CODFRAIS=loc_Tab_Acte(i).codfrais
             AND numligne = i;
             P_INS_journal(3,v_id_flux||'NVL(SUM(MTPREST_REEL),0)'||loc_Tab_Acte(i).mtprest);
          -- Calcul du reste a charge
         -- loc_Tab_Acte(i).mtrac:=NVL(loc_Tab_Acte(i).mtfrais_reel - (NVL(loc_Tab_Acte(i).mtro,0)+NVL(loc_Tab_Acte(i).mtro_sup,0)) -loc_Tab_Acte(i).mtprest,0);
        END IF;

        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).codeErreur:'||loc_Tab_Acte(i).codeErreur);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).codfrais:'||loc_Tab_Acte(i).codfrais);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).taux:'||loc_Tab_Acte(i).taux);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).base:'||loc_Tab_Acte(i).base);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).mtfrais_reel:'||loc_Tab_Acte(i).mtfrais_reel);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).mtro:'||loc_Tab_Acte(i).mtro);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).mtro_sup:'||loc_Tab_Acte(i).mtro_sup);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).mtfrais:'||loc_Tab_Acte(i).mtfrais);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).remise:'||loc_Tab_Acte(i).remise);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).mtfrais_sup:'||loc_Tab_Acte(i).mtfrais_sup);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).remise_sup:'||loc_Tab_Acte(i).remise_sup);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).mtro_sup:'||loc_Tab_Acte(i).mtro_sup);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).mtprest:'||loc_Tab_Acte(i).mtprest);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).mtrac:'||loc_Tab_Acte(i).mtrac);
        P_INS_journal(3,v_id_flux||'loc_Tab_Acte(i).codfraisSPS:'||loc_Tab_Acte(i).codfraisSPS);

        IF TRIM(loc_Tab_Acte(i).codfrais) IS NULL OR loc_Tab_Acte(i).mtfrais_reel IS NULL OR
           (NVL(loc_Tab_Acte(i).mtro,0)+NVL(loc_Tab_Acte(i).mtro_sup,0)) IS NULL OR loc_Tab_Acte(i).mtprest IS NULL/* OR loc_Tab_Acte(i).mtrac IS NULL*/
        THEN
          v_code:=2;
          v_raison:=2;
          v_justification:=7;
          v_libelle:='Echec indeterminee creer pec ko';
          v_decision_AMC:=6;
      --    P_INS_journal(,v_id_flux||' creerPEC DATA KO');
        ELSE
          IF loc_Tab_Acte(i).codfraisSPS = 'VERRE' THEN
            v_nature_Retour:='VER';
          ELSIF loc_Tab_Acte(i).codfraisSPS = 'MONTURE' THEN
            v_nature_Retour:='LUN';
          ELSIF loc_Tab_Acte(i).codfraisSPS = 'LENTILLE' THEN
            v_nature_Retour:='LEN';
          ELSIF loc_Tab_Acte(i).codfraisSPS = 'PRODUIT' THEN
            v_nature_Retour:='PRT';
          ELSIF loc_Tab_Acte(i).codfraisSPS = 'SUPPLEMENT' THEN
            v_nature_Retour:='SUP';
          END IF;

          P_INS_journal(3,v_id_flux||'Avant CASE loc_Tab_Acte(i).codeErreur:'||loc_Tab_Acte(i).codeErreur);
          --ABO initialisation de la décision
          v_code:=1;
          v_decision_AMC:=4;

          IF v_code=1 AND v_decision_AMC = 4 THEN
            P_INS_journal(3,v_id_flux||'ecriture ligne xml:'||loc_Tab_Acte(i).codfrais);
            v_mtdepense :=NVL(loc_Tab_Acte(i).mtfrais,0)
                            +NVL(loc_Tab_Acte(i).mtfrais_sup,0)
                            +NVL(loc_Tab_Acte(i).mtfrais_supRb,0)
                            -NVL(loc_Tab_Acte(i).remise,0)
                            -NVL(loc_Tab_Acte(i).remise_sup,0);
            loc_Tab_Acte(i).mtrac := v_mtdepense
                                    -NVL(loc_Tab_Acte(i).mtro,0)
                                    -NVL(loc_Tab_Acte(i).mtro_sup,0)
                                    -loc_Tab_Acte(i).mtprest;
            pk_xml.add_data('priseEnChargeDetaillee/avisPriseEnCharge','conditionDeRemboursement',v_qteActeArthus, false);
            pk_xml.add_element('propositionClient', 'prestationOptique');
            pk_xml.add_data('prestationOptique','identifiant', 'DETREMB'||v_qteActeArthus, false);
            pk_xml.add_data('prestationOptique','depense', v_mtdepense, false);
            pk_xml.add_data('prestationOptique','resteACharge', loc_Tab_Acte(i).mtrac, false);
            pk_xml.add_data('prestationOptique','nature', v_nature_Retour, false);
            pk_xml.add_element('prestationOptique', 'detailDePrestation');
            pk_xml.add_data('detailDePrestation', 'identifiant','DETAIL', false);
            pk_xml.add_data('detailDePrestation', 'type', 12, false); -- Forfait global
            pk_xml.add_data('detailDePrestation', 'libelle', loc_Tab_Acte(i).codfrais||'-LPP:', false);
            pk_xml.add_element('prestationOptique', 'conditionDeRemboursement');
            pk_xml.add_data('conditionDeRemboursement', 'identifiant','AMO', false);
            pk_xml.add_data('conditionDeRemboursement', 'avisPriseEnCharge',v_qteActeArthus, false);
            pk_xml.add_data('conditionDeRemboursement', 'financement',loc_Tab_Acte(i).taux, false);
            pk_xml.add_data('conditionDeRemboursement', 'partAMO',NVL(loc_Tab_Acte(i).mtro,0)+NVL(loc_Tab_Acte(i).mtro_sup,0), false);
            pk_xml.add_element('prestationOptique', 'conditionDeRemboursement');
            pk_xml.add_data('conditionDeRemboursement', 'identifiant','AMC', false);
            pk_xml.add_data('conditionDeRemboursement', 'avisPriseEnCharge',v_qteActeArthus, false);
            pk_xml.add_data('conditionDeRemboursement', 'partAMC',NVL(loc_Tab_Acte(i).mtprest,0), false);

           pk_xml.add_element('prestationOptique', 'equipement');
           P_INS_journal(1,v_id_flux|| ' avant add_data loc_Tab_Acte(t).identifiant:'||loc_Tab_Acte(t).identifiant ||' acte '||loc_Tab_acte(t).codfrais);
            pk_xml.add_data('equipement', 'identifiant',loc_Tab_Acte(i).identifiant, false);--> ici est alimenté identifiant de equipement!il provient du flux aller ! or pour les SUPPLRO pas de balise equipement/identifiant!

            V_totmtFrais:=V_totmtFrais+v_mtdepense;
            V_totmtprest:=V_totmtprest+loc_Tab_Acte(i).mtprest;
            v_totrac:=v_totrac+loc_Tab_Acte(i).mtrac;
            COMMIT;
          END IF;

       END IF; --IF TRIM(loc_Tab_Acte(i).codfrais) IS NULL OR loc_Tab_Acte(i).mtfrais_reel IS NULL OR
      END IF;
    END LOOP;

    pk_xml.add_data('priseEnChargeDetaillee/avisPriseEnCharge','expiration',F_D2DATEHEURE(ADD_MONTHS( SYSDATE, loc_sens )), false);
    pk_xml.add_data('priseEnChargeDetaillee/avisPriseEnCharge','montantPrisEnCharge',V_totmtprest, false);
    pk_xml.add_data('priseEnChargeDetaillee/avisPriseEnCharge','montantResteACharge',v_totrac, false);
    pk_xml.merge_data('priseEnChargeDetaillee/avisPriseEnCharge','montantTotal',V_totmtFrais, false);
  IF v_totrac<>0 AND loc_typeFlux = 2 THEN
    v_libelle:=v_libelle||'Remboursement partiel (plafond, carence ou franchise).';
  END IF;

  EXCEPTION
    WHEN exc_assu_inconnu THEN
      v_code:=1; --cas particuler cf CDC
      v_raison:=null;
      v_justification:=null;
      v_decision_AMC := 6; -- dossier refusé
      v_paragraphe2:=v_paragraphe2||v_mess_refus1;
      v_motif:=11; --Autre
    WHEN exc_reference_inconnue THEN
      v_code:=1;
      v_justification:=3;--Erreur d indentification de l assure social ou assure social inconnu
      v_decision_AMC := 6; -- dossier refusé
      v_motif:=4;-- Droit non ouvert
      v_paragraphe2:=v_paragraphe2||v_mess_refus5;
    WHEN exc_contrat_invalide OR exc_garantie_inconnue THEN
      v_libelle:='Ce beneficiaire n''a pas droit au service tiers payant';
      v_code:=1;
      v_motif:=4; -- Droit non ouvert
      v_decision_AMC := 6; -- dossier refusé
      v_paragraphe2:=v_paragraphe2||v_mess_refus5;
    WHEN exc_adhe_invalide THEN
      v_code:=1;
      v_motif:=5; -- Pas de tiers payant
      v_decision_AMC:=6; -- Refuse
      v_paragraphe2:=v_paragraphe2||v_mess_refus5;
    WHEN exc_TP_ferme THEN
      v_libelle:='Ce beneficiaire n''a pas droit au service tiers payant';
      P_INS_journal(2,v_id_flux||' creerPEC err contrat', v_libelle);
      v_code:=1;
      v_motif:=5; -- Pas de tiers payant
      v_decision_AMC:=6; -- Refuse
      v_paragraphe2:=v_paragraphe2||v_mess_refus5;
    WHEN exc_PS_inconnue THEN
      v_code:=2;
      v_raison:=2;--Information manquante ou erronee
      v_justification:=4;-- Erreur d indentification de l opticien ou opticien non reference
    WHEN exc_prestation_null THEN
      v_libelle := v_lib2; --'Calcul impossible ou forfait épuisé';  --M0007243 modification du libellé pour le refus calcul imp. ou forfait epuisé
      P_INS_journal(2,v_id_flux||'creerPEC exc_prestation_null err :', erreur_dossier || ' '||v_libelle);
      v_code:=1;
      v_justification:=null;
      v_decision_AMC := 6; -- dossier refusé
      v_motif:=3; -- forfait épuisé
      --v_paragraphe2:=v_paragraphe2||v_mess_refus11; M0007243 modification du libellé pour le refus calcul imp. ou forfait epuisé
      v_paragraphe2:=v_paragraphe5||v_mess_refus11; --plafond
    WHEN exc_abus_pec_adhe THEN
      --v_libelle := 'Abus de demande de prise en charge ou devis pour la même adhésion';
      v_libelle := v_lib1; --M0007222
      v_code:=1;
      v_justification:=null;
      P_INS_journal(2,v_id_flux||'creerPEC exc_abus_pec_adhe err :', loc_ErrAbus );
      v_decision_AMC := 6; -- dossier refusé
      v_motif:=10; -- Etat incompatible
      v_paragraphe2:=v_paragraphe5||v_mess_refus12;
    WHEN exc_abus THEN
      v_libelle := 'Abus de demande de prise en charge ou devis pour le même bénéficiaire';
      v_code:=1;
      v_justification:=null;
      P_INS_journal(2,v_id_flux||'creerPEC exc_abus err :', loc_ErrAbus );
      v_decision_AMC := 6; -- dossier refusé
      v_motif:=10; -- Etat incompatible
      v_paragraphe2:=v_paragraphe2||v_mess_refus9;
	WHEN exc_abus_fr_reel THEN
	  --v_libelle := 'Abus dépassement de frais réels de prestation';
      v_libelle := v_lib1; --M0007222
      v_code:=1;
      v_justification:=null;
      P_INS_journal(2,v_id_flux||'creerPEC exc_abus_fr_réel ', v_libelle );
      v_decision_AMC := 6; -- dossier refusé
      v_motif:=10; -- Etat incompatible
      v_paragraphe2:=v_paragraphe5||v_mess_refus13;
    WHEN nb_limite_lentille THEN
      v_code:=1;
      v_justification:=null;
      v_decision_AMC := 6; -- dossier refusé
      v_motif:=10; -- Etat incompatible
      v_paragraphe2:=v_paragraphe2||v_mess_refus10;
    WHEN exc_produit_entretien THEN
      v_code:=1;
      v_justification:=null;
      v_decision_AMC := 6; -- dossier refusé
      v_motif:=10; -- Etat incompatible
      v_paragraphe2:=v_paragraphe2||v_mess_refus8;
    WHEN exc_ordonnance THEN
      v_libelle := 'Pas de remboursement possible : le patient ne beneficie pas du "remboursement sans ordonnance"';
      P_INS_journal(2,v_id_flux||'exc_ordonnance :',v_libelle);
      v_code:=1;
      v_justification:=null;
      v_motif:=2; -- Pas d ordonnance
      v_decision_AMC:=6; -- Refuse
      v_paragraphe2:=v_paragraphe2||v_mess_refus3;
    WHEN exc_rc_different THEN
      v_code:=1;
      v_justification:=null;
      v_decision_AMC := 6; -- dossier refusé
      v_paragraphe2:=v_paragraphe2||v_mess_refus4;
    --suppression de l'exception sur le plafond contrat
    WHEN exc_acte_inconnu THEN
      v_libelle := 'Acte non couvert.';
      P_INS_journal(2,v_id_flux||'exc_acte_inconnu :',v_libelle);
      v_code:=1;
      v_motif:=4; -- Droits non ouverts
      v_decision_AMC:=6; -- Refuse
      v_justification:=null;
      v_paragraphe2:=v_paragraphe2||v_libelle;
    WHEN exc_double_vision THEN
      v_libelle := 'Il convient de faire 2 PEC séparées.';
      P_INS_journal(2,v_id_flux||'exc_acte_inconnu :',v_libelle);
      v_code:=1;
      v_motif:=4; -- Droits non ouverts
      v_decision_AMC:=6; -- Refuse
      v_justification:=null;
      v_paragraphe2:=v_paragraphe2||v_libelle;
    WHEN exc_erreur_inconnue THEN
      v_code:=2; -- KO technique
      v_raison:=2;-- erreur d acheminement
      v_justification:=6; -- Information obligatoire manquante dans une ou plusieurs lignes de détails
      v_libelle:='le numéro de dossier externe existe déjà dans le système';
    WHEN exc_flux_inconnue THEN
     P_INS_journal(2,v_id_flux||' exc_flux_inconnue:',v_libelle);
       loc_typeFlux := ConstructPriseEnCharge( P_Tab_Indiv    =>loc_Tab_Indiv
                                              ,p_xml           => p_xml
                                              ,I_path_patient => loc_path_patient
                                              ,I_path_pec1    => loc_path_pec1
                                              ,I_path_pec2    => loc_path_pec2
                                              ,I_path_xml     => loc_path_xml
                                              ,KO             => TRUE
                                             , P_AvisPEC      => loc_AvisPEC);
    WHEN OTHERS  THEN
       P_INS_journal(2,v_id_flux||' creerPEC ECHEC', SQLERRM);
      -- Reconstruction d un flux
      -- Ecriture de l entete de reponse
      --loc_Tab_Indiv := F_extract_individu( p_xml,I_path_patient,I_path_pec1,I_path_pec2);
      loc_typeFlux := ConstructPriseEnCharge( P_Tab_Indiv    =>loc_Tab_Indiv
                                              ,p_xml         =>p_xml
                                              ,I_path_patient => loc_path_patient
                                              ,I_path_pec1    => loc_path_pec1
                                              ,I_path_pec2    => loc_path_pec2
                                              ,I_path_xml     => loc_path_xml
                                              ,KO             => TRUE
                                             , P_AvisPEC      => loc_AvisPEC);

  END;
  ROLLBACK;
  -- ***************************************************************************
  -- * Message aller en erreur: Constitution du XML
  -- ***************************************************************************
  P_ENTETE_REP_ERREUR(P_codeRetour => v_code,
                      P_codeRaison => v_raison,
                      P_codeJustif => v_justification,
                      P_Tab_Indiv  => loc_Tab_Indiv,
                      P_num_dossier => loc_num_dossier,
                      P_AvisPEC     => loc_AvisPEC,
                      P_refdossExt =>  loc_refdossExt,
                      P_libErreur  => v_libelle,
                      P_codeDec    => v_decision_AMC,
                      P_motif      => v_motif,
                      P_flux       => 1);

  -- Suppression des données enregistrées dans travsn (données conservées pour le calcul de plafond/franchise/carence)
  PK_CALCUL_DOSSIER.P_Delete_travsn;
P_INS_journal(2,v_id_flux||' après delete_travsn');

  -- ***************************************************************************
  -- * Génération/Validation du XML réponse
  -- ***************************************************************************

  v_xml := pk_xml.get_xml('oiamCRSP','xmlns="http://modele.ws.tpo.cga.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', false);

  -- Historisation de la réponse du flux "Demande de prise en charge/ Calcul de reste à charge" (type 6)
  pk_ws.add_xml(p_id_type => 17,
                p_id_flux => v_id_flux,
                p_doc_xml => v_xml,
                p_cod_err => v_cod_err);
  -- Validation du flux retour
  IF NOT pk_ws.is_flux_valid(v_xml, 17, v_id_flux) THEN
    P_INS_journal(1,v_id_flux||' creerPEC ', 'INVALID RETOUR');
    RETURN v_xml;
  END IF;

  -- MAJ statut du flux OK
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  P_INS_journal(1,v_id_flux||' Fin normale de la procédure CreerPEC');
  -- Envoi du XML réponse
  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
    -- Modification du statut : 6 En erreur inconnue
     v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
     pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);
     P_INS_journal(1,v_id_flux||' creerPEC others', sqlerrm);
     -- Envoi du XML réponse
     RETURN (v_xml);
END creerPEC;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  annulerPEC                                                */
/* Type         :  Public                                                    */
/* Description  :  Annulation de la prise en charge                          */
/* Entree       :  P_xml, Flux XML                                           */
/* Retour       :  Retourne le flux XML                                      */
/*---------------------------------------------------------------------------*/
FUNCTION annulerPEC (
  P_xml IN XMLTYPE
) RETURN XMLTYPE
IS
  v_xml            XMLTYPE;
  loc_numAdhe      dossier_sante.numindiv%TYPE:=NULL;
  loc_motif        NUMBER(3) :=1;
  v_id_flux        flux.id_flux%TYPE;
  v_cod_err        NUMBER:=0;
  l_outxmlns       VARCHAR2(10);
  loc_typeFlux     NUMBER(2);
  loc_fact_pec     dossier_sante.num_fact_pec%TYPE;
  loc_dat_fact_pec dossier_sante.date_fact_pec%TYPE;
  loc_dossier_pec  dossier_sante.num_dossier_pec%TYPE;
  loc_dossier_porte dossier_sante.num_dossier_porte%TYPE;

  loc_num_dossier  dossier_sante.num_dossier%TYPE:=0;
  loc_refdossExt   VARCHAR2(50):='0';
  loc_AvisPEC      VARCHAR2(50):='0';
  loc_path_xml     VARCHAR2(100) :='oiamCDEL/partenariat/propositionClient/';
  loc_path_patient VARCHAR2(100) :='oiamCDEL/patient/';
  loc_path_pec2    VARCHAR2(100) :='oiamCDEL/priseEnChargeDetaillee[2]/';
  loc_path_pec1    VARCHAR2(100) :='oiamCDEL/priseEnChargeDetaillee[1]/';

  v_libelle        VARCHAR2(128):=NULL;
  v_code           VARCHAR2(2):=NULL;
  v_raison         VARCHAR2(1):=NULL;
  v_justification  VARCHAR2(1):=NULL;
  v_motif          VARCHAR2(2):=NULL;
  v_decision_AMC   VARCHAR2(50):=NULL;
  loc_xml xmltype;
  l_out varchar2(110);
  loc_Tab_Indiv PK_CTRL_TP.TAB_T_Indiv;
  v_deb NUMBER;
  v_delai NUMBER;


BEGIN
  P_INS_journal(1,' Début de la procédure annulerPEC');
  G_IDLIGNE := 0;
  v_libelle:='';
  P_Init_Editique;
  loc_xml:=P_xml.EXTRACT('/');
  l_out := substr(loc_xml.getClobval(),1,110);
  DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');
  -- ***************************************************************************
  -- * Validation XML Question / Création XML Réponse
  -- ***************************************************************************
  -- récupération dynamique du namespace
  l_outxmlns:=pk_xml.GET_XMLNS(P_xml,'/');
  -- Initialisation des namespaces XML
  IF pk_xml.vg_outxmlns IS NOT NULL THEN
    pk_xml.vg_xmlns := 'xmlns:'|| pk_xml.vg_outxmlns||'="http://modele.ws.tpo.cga.com"';
  ELSE
    Pk_Xml.Vg_Xmlns := 'xmlns="http://modele.ws.tpo.cga.com"';
  End If;

  -- Initialisation XML réponse
  pk_xml.new_xml;
  v_deb:=DBMS_UTILITY.GET_TIME;

  BEGIN
    -- Historisation du flux aller "Demande de prise en charge/ Calcul de reste à charge" (type 5)
    v_id_flux := pk_ws.insert_flux(p_id_type       => 18,
                                   p_id_flux_tiers =>PK_XML.EXTRACT_DATA(P_xml,'oiamCDEL/identification',null,1),
                                   p_doc_xml       => P_xml,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );
    IF v_cod_err <> 0 THEN
       P_INS_journal(2,v_id_flux||' annulerPEC INVALID', 'Historisation du flux ko');
       v_libelle:='Historisation du flux oiamCDEL KO';
       RAISE exc_flux_inconnue;
    END IF;
    P_INS_journal(2,v_id_flux||' Historisation du flux ok');
    -- Validation du flux aller
    IF NOT pk_ws.is_flux_valid(P_xml, 18, v_id_flux) THEN
       P_INS_journal(2,v_id_flux||' annulerPEC INVALID', 'Validation du flux aller ko');
       v_libelle:='Validation du flux oiamCDEL KO';
       RAISE exc_flux_inconnue;
    END IF;
    P_INS_journal(2,v_id_flux||' Validation du flux ok');
    -- Ecriture de l entete de reponse
    P_ENTETE_REP(p_type=> null,
                 p_ident =>PK_XML.EXTRACT_DATA(P_xml,'oiamCDEL/identification',null,1));

    -- ***************************************************************************
    -- * Construction du corps de la réponse -> fichier XML à mini
    -- ***************************************************************************
    pk_xml.add_element('/','origine');
    pk_xml.add_data('origine', 'nomNormeAMC',PK_XML.EXTRACT_DATA(p_xml,'oiamCDEL/origine/nomNormeEmetteur',null,1), false);
    pk_xml.add_data('origine', 'versionNormeAMC',PK_XML.EXTRACT_DATA(p_xml,'oiamCDEL/origine/versionNormeEmetteur',null,1), false);
    loc_num_dossier := PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'referenceDossierAMC',null,1);
    loc_AvisPEC:=PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'referenceDossierOperateur',null,1);
    pk_xml.add_element('/', 'priseEnChargeDetaillee');
    pk_xml.add_data('priseEnChargeDetaillee','type', 2, false);
    pk_xml.add_element('priseEnChargeDetaillee', 'avisPriseEnCharge');
    pk_xml.add_data('avisPriseEnCharge','decision', 1, false);
    pk_xml.add_data('avisPriseEnCharge','motif', 1, false);
    pk_xml.add_data('avisPriseEnCharge','effet',F_D2DATEHEURE(sysdate), false);
    pk_xml.add_element('/', 'partenariat');
    pk_xml.add_element('partenariat', 'propositionClient');
    pk_xml.add_data('propositionClient','referenceDossierAMC', loc_num_dossier, false); --à mettre à jour si PEC acceptée !
    pk_xml.add_data('propositionClient','referenceDossierOperateur', NVL(loc_refdossExt,0), false);
    pk_xml.add_data('propositionClient','referenceDossierOpticien', NVL(loc_refdossExt,0), false);
    pk_xml.add_element('propositionClient', 'structure');
    pk_xml.add_data('structure','identite_SIRET', PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'structure/identite_SIRET',null,1), false);
    pk_xml.add_element('propositionClient', 'executant');
    pk_xml.add_data('executant','identite_ADELI', PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'executant/identite_ADELI',null,1), false);

      --on vérifie que le dossier existe
    IF PK_CTRL_TP.F_FIND_DOSSIER(
      loc_num_dossier,
      loc_numAdhe) THEN

      IF F_ETAT_DOSSIER_SANTE(loc_num_dossier,sysdate,1) = 1 OR -- dossier fermé
          PK_CTRL_TP.F_FIND_SNTR_ANNUL(loc_num_dossier) = 1 THEN -- au moins 1 sinistre_sante annulé
         RAISE exc_dossier_annule;
      ELSIF F_ETAT_DOSSIER_SANTE(loc_num_dossier,sysdate,1) = 0 AND F_ETAT_DOSSIER_SANTE(loc_num_dossier,sysdate,2) IN (6,4) THEN -- dossier en cours de facturation
        /* MUR M0005159 -
        PK_CTRL_TP.P_INFO_DOSSIER(loc_num_dossier, loc_fact_pec, loc_dat_fact_pec, loc_dossier_pec, loc_dossier_porte);
        IF loc_dossier_pec IS NULL THEN
          RAISE exc_dossier_CourFactur;
        END IF;
        */
        RAISE exc_dossier_CourFactur;
      ELSIF PK_CTRL_TP.F_FIND_SNTR_DCPT(loc_num_dossier) = 1 THEN -- au moins 1 sinistre du dossier est décompté
        RAISE exc_dossier_facture;
      END IF;

      -- Annulation du dossier
      PK_CTRL_TP.P_ANNUL_DOSSIER(loc_num_dossier,loc_motif);
      -- mise à jour de la reférence externe de l'individu
      PK_CTRL_TP.P_MAJ_REF_EXTERNE(
            P_numindiv    => loc_numAdhe,
            P_domaine     => '',
            P_num_dossier => loc_num_dossier,
            P_tiers       => 'GRP',
            P_mnemo       => 'DOMSP');
      COMMIT;
      v_decision_AMC:=1; -- Action acceptée
      v_code:=1;
    ELSE
      RAISE exc_dossier_inconnu; -- dossier non trouvé
    END IF;

   EXCEPTION
    WHEN exc_dossier_inconnu THEN
      v_libelle:='Annulation refusee - PEC/DAC introuvable';
      loc_motif:=9; -- PEC inexistante
      v_code:=1;
      v_raison:=2;--'Information manquante ou erronee';
      v_decision_AMC := 2; -- Action refusé
    WHEN exc_dossier_CourFactur THEN
      v_libelle:='Annulation refusee - PEC/DAC en cours de facturation';
      loc_motif:=10; -- Etat incompatible
      v_code:=1;
      v_raison:=2;--'Information manquante ou erronee';
      v_decision_AMC := 2; -- dossier refusé
    WHEN exc_dossier_annule THEN
      v_libelle:='Annulation refusee - PEC/DAC deja annulee';
      loc_motif:=10; -- Etat incompatible
      v_code:=1;
      v_raison:=2;--'Information manquante ou erronee';
      v_decision_AMC := 2; -- dossier refusé
    WHEN exc_dossier_facture THEN
      v_libelle:='Annulation refusee - PEC/DAC deja facturee';
      loc_motif:=7; -- Etat incompatible
      v_code:=1;
      v_raison:=2;--'Information manquante ou erronee';
      v_decision_AMC := 2; -- dossier refusé
    WHEN exc_erreur_inconnue THEN
      v_libelle:='Echec indeterminee';
      v_code:=1;
      v_raison:=2;--'Information manquante ou erronee';
      v_decision_AMC := 2; -- Action refusé
    WHEN exc_flux_inconnue THEN
      -- KO Technique
      -- Reconstruction d un flux
      -- Ecriture de l entete de reponse
      loc_typeFlux:=PK_XML.EXTRACT_DATA(p_xml,'oiamCDEL/type',null,1);
      P_ENTETE_REP(p_type  => loc_typeFlux,
                   p_ident =>PK_XML.EXTRACT_DATA(P_xml,'oiamCDEL/identification',null,1));
      pk_xml.add_element('/','origine');
      pk_xml.add_data('origine', 'nomNormeAMC',PK_XML.EXTRACT_DATA(p_xml,'oiamCDEL/origine/nomNormeEmetteur',null,1), false);
      pk_xml.add_data('origine', 'versionNormeAMC',PK_XML.EXTRACT_DATA(p_xml,'oiamCDEL/origine/versionNormeEmetteur',null,1), false);
      pk_xml.add_element('/', 'priseEnChargeDetaillee');
      -- M5439-M5454  : mise en commentaire de cette balise car les PEC KRYS ne l alimente pas toujours ce qui provoque une erreur de structure de flux
    --  pk_xml.add_data('priseEnChargeDetaillee','identifiant',0, false);
      pk_xml.add_data('priseEnChargeDetaillee','type', 2, false);
      pk_xml.add_element('priseEnChargeDetaillee', 'avisPriseEnCharge');
      pk_xml.add_data('avisPriseEnCharge','effet',F_D2DATEHEURE(sysdate), false);
      pk_xml.add_element('/', 'partenariat');
      pk_xml.add_element('partenariat', 'propositionClient');
      pk_xml.add_data('propositionClient','referenceDossierAMC', loc_num_dossier, false); --à mettre à jour si PEC acceptée !
      pk_xml.add_data('propositionClient','referenceDossierOperateur', NVL(loc_refdossExt,0), false);
      pk_xml.add_data('propositionClient','referenceDossierOpticien', NVL(loc_refdossExt,0), false);
      pk_xml.add_element('propositionClient', 'structure');
      pk_xml.add_data('structure','identite_SIRET', PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'structure/identite_SIRET',null,1), false);
      pk_xml.add_element('propositionClient', 'executant');
      pk_xml.add_data('executant','identite_ADELI', PK_XML.EXTRACT_DATA(P_xml,loc_path_xml || 'executant/identite_ADELI',null,1), false);
      v_code:=2; -- KO technique
      v_raison:=1;-- erreur d acheminement
    WHEN OTHERS THEN
      v_code:=3;
      P_INS_journal(2,v_id_flux||' annulerPEC', 'ECHEC :'||SQLERRM);
  END;

  ROLLBACK;

  -- ***************************************************************************
  -- * Génération/Validation du XML réponse
  -- ***************************************************************************
  P_ENTETE_REP_ERREUR(P_codeRetour => v_code,
                      P_codeRaison => v_raison,
                      P_codeJustif => null,
                      P_Tab_Indiv  =>loc_Tab_Indiv,
                      P_num_dossier => loc_num_dossier,
                      P_AvisPEC     => loc_AvisPEC,
                      P_refdossExt =>  loc_refdossExt,
                      P_libErreur  => v_libelle,
                      P_codeDec    => v_decision_AMC,
                      P_motif      => loc_motif,
                      P_flux       => 2);

  v_xml := pk_xml.get_xml('oiamCADV','xmlns="http://modele.ws.tpo.cga.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', false);

  -- Historisation de la réponse du flux "Annulation de pirse en charge" (type 12)
  pk_ws.add_xml(p_id_type => 19,
                p_id_flux => v_id_flux,
                p_doc_xml => v_xml,
                p_cod_err => v_cod_err);

  -- Validation du flux retour
  IF NOT pk_ws.is_flux_valid(v_xml, 19, v_id_flux) THEN
    P_INS_journal(2,v_id_flux||' annulerPEC non valide', 'retour');
    RETURN v_xml;
  END IF;

  -- MAJ statut du flux OK
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  P_INS_journal(1,v_id_flux||' Fin normale de la procédure annulerPEC');

  -- Envoi du XML réponse
  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
      P_INS_journal(2,v_id_flux||' annulerPEC EXC', sqlerrm);
       -- Modification du statut : 6 Erreur inconnue
       v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
       pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);
       -- Envoi du XML réponse
       RETURN (v_xml);
END annulerPEC;

/*---------------------------------------------------------------------------*/
/* FONCTION     :  JBO 20110728                                              */
/* Nom          :  F_DATEHEURE2D                                             */
/* Type         :  Public                                                    */
/* Description  :  Transforme une chaine de caractere DateHeure en Date      */
/*                 Exemple de format attendu : 1961-11-15T00:00:00           */
/* Entree       :  I_StringDateHeure, chaine de caractere DateHeure          */
/* Retour       :  Retourne une date au format DD/MM/YYYYHH24:MI:SS          */
/*---------------------------------------------------------------------------*/
FUNCTION F_DATEHEURE2D(I_StringDateHeure  VARCHAR2)
RETURN DATE IS

  d_date    DATE:=NULL;
  s_annee   VARCHAR2(4):=NULL;
  s_mois    VARCHAR2(2):=NULL;
  s_jour    VARCHAR2(2):=NULL;
  s_heure   VARCHAR2(2):=NULL;
  s_minute  VARCHAR2(2):=NULL;
  s_seconde VARCHAR2(2):=NULL;

BEGIN

  s_annee:=SUBSTR(i_StringDateHeure, 1, 4);
  s_mois:=SUBSTR(i_StringDateHeure, 6, 2);
  s_jour:=SUBSTR(i_StringDateHeure, 9, 2);
  s_heure:=SUBSTR(i_StringDateHeure, 12, 2);
  s_minute:=SUBSTR(i_StringDateHeure, 15, 2);
  s_seconde:=SUBSTR(i_StringDateHeure, 18, 2);

  RETURN TO_DATE(s_jour||'/'||s_mois||'/'||s_annee||' '||s_heure||':'||s_minute||':'||s_seconde, 'DD/MM/YYYY HH24:MI:SS');


EXCEPTION
  WHEN OTHERS THEN

    RETURN null;
END F_DATEHEURE2D;

/*---------------------------------------------------------------------------*/
/* FONCTION     :  JBO 20110728                                              */
/* Nom          :  F_D2DATEHEURE                                             */
/* Type         :  Public                                                    */
/* Description  :  Transforme une Date en  chaine de caractere DateHeure     */
/*                 Exemple de format renvoyé : 1961-11-15T00:00:00           */
/* Entree       :  I_Date, date                                              */
/* Retour       :  Retourne une date au format YYYY-MM-DDTHH24:MI:SS         */
/*---------------------------------------------------------------------------*/
FUNCTION F_D2DATEHEURE(I_Date  DATE)
RETURN VARCHAR2 IS
  s_chaineDate VARCHAR2(21):=NULL;
BEGIN

  s_chaineDate :=TO_CHAR( I_Date, 'DD/MM/YYYY HH24:MI:SS' );

  IF TRIM(s_chaineDate) IS NULL THEN
    RETURN NULL;
  ELSE
    RETURN SUBSTR( TO_CHAR( I_Date, 'DD/MM/YYYY HH24:MI:SS' ), 7, 4)
                  ||'-'||SUBSTR(TO_CHAR( I_Date, 'DD/MM/YYYY HH24:MI:SS' ), 4, 2)
                  ||'-'||SUBSTR(TO_CHAR( I_Date, 'DD/MM/YYYY HH24:MI:SS' ), 1, 2)
                  ||'T'||SUBSTR(TO_CHAR( I_Date, 'DD/MM/YYYY HH24:MI:SS' ), 12, 3)
                  ||SUBSTR(TO_CHAR( I_Date, 'DD/MM/YYYY HH24:MI:SS' ), 15, 3)
                  ||SUBSTR(TO_CHAR( I_Date, 'DD/MM/YYYY HH24:MI:SS' ), 18, 2);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END F_D2DATEHEURE;

-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  calculDevis                                               */
/* Type         :  Privee                                                    */
/* Description  :  Calcul des montants d un devis de PEC                     */
/* Entree       :  P_loc_Tab_Acte                                            */
/* Retour       :  Retourne P_loc_Tab_Acte                                   */
/*---------------------------------------------------------------------------*/
FUNCTION calculDevis(P_loc_Tab_Acte IN OUT TAB_T_Acte
                    , p_niv          IN NUMBER
                    , P_benef        IN NUMBER
                    , P_numindivPS   IN NUMBER
                    , i_derog        IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER IS

  erreur_calcul       NUMBER:=0;
  msg_calcul          VARCHAR2(200);
  v_etat              NUMBER:=0;
  P_TRAV_SAISIE       TRAV_SAISIE%ROWTYPE;     -- necessaire à l'enregistrement du réseau de soins
  l_sid               NUMBER(8);

BEGIN

   -- Les frais réels sont égales au montant de la prestation optique moins l abattement sur la prestation optique +
   -- le(s) montant(s) de(s) supplément(s) de la prestation optique moins le(s) abattement(s) de(s) supplément(s) sur la prestation optique
   -- Calcul de remboursement de la prestation
   P_loc_Tab_Acte(p_niv).messErreur:='';
   P_loc_Tab_Acte(p_niv).mtprest:=0;
    --M4767 Contrôle de la couverture TPE
  IF pk_porte.F_carte_tp(P_benef, P_loc_Tab_Acte(p_niv).codfrais, sysdate, 0, NULL,  NULL, g_tabCond ) =0 THEN
    v_etat := 3;--état de la prestation à bloqué
  ELSE v_etat := 1;
  END IF;
   --gestion des actes à exclure du calcul
   IF  P_loc_Tab_Acte(p_niv).codeErreur NOT IN ('08','09') and v_etat=1 THEN
     --
     -- insertion du réseau de soins si celui-ci est existant sur la porte SPSANTE
     --récupération du l_sid
     SELECT TO_CHAR(SYS_CONTEXT('USERENV', 'SID')) INTO l_sid FROM DUAL;
     P_TRAV_SAISIE.SID:= l_sid;
     P_TRAV_SAISIE.NUMLIG:= p_niv;
     --P_TRAV_SAISIE.USERNAME:= f_numutil;--RKO
     BEGIN
          SELECT numutil INTO P_TRAV_SAISIE.USERNAME from porte_param where numporte=g_grpporte;
     EXCEPTION
       WHEN OTHERS THEN
         SELECT F_NUMUTIL INTO P_TRAV_SAISIE.USERNAME FROM DUAL;
     END;
     P_TRAV_SAISIE.NUMSIN:=  NULL;
     P_TRAV_SAISIE.RESEAU:=NVL(F_SENS_LIBELLE('PORTE',g_grpporte),g_grpporte);  -- réseau de soins
     --P_INSERT_TRAV_SAISIE(  P_TRAV_SAISIE );
     -- fin insertion réseau de soins
     --
    PK_CALCUL_DOSSIER.P_CALCUL_RAC(P_codfrais    => P_loc_Tab_Acte(p_niv).codfrais,
                                  P_datsin      => TO_CHAR(SYSDATE,'DD/MM/YYYY'),
                                  P_taux        => P_loc_Tab_Acte(p_niv).taux, -- NVL(P_loc_Tab_Acte(i).mtro,0)/NVL(P_loc_Tab_Acte(i).mtro_sup,0)
                                  P_mtremb      => NVL(P_loc_Tab_Acte(p_niv).mtro,0)+NVL(P_loc_Tab_Acte(p_niv).mtro_sup,0), -- Montant RO + le(s) supplément(s) RO
                                  P_mtfrais     => P_loc_Tab_Acte(p_niv).mtfrais_reel,
                                  P_devise      => PK_CTRL_TP.F_FIND_DEVISE,
                                  P_quantite    => P_loc_Tab_Acte(p_niv).quantite,
                                  P_coeff       => 1,
                                  P_numindiv    => P_benef,
                                  P_numbene     => P_numindivPS,
                                  P_type_bene   => 1,
                                  P_ordre       => P_niv,-- i,  ==> a voir pour plusieurs verres ou prestations optiques
                                  P_type        =>'devis', --insertion dans travsn avec sens=-1
                                  O_mtprest     => P_loc_Tab_Acte(p_niv).mtprest,
                                  O_erreur      => erreur_calcul,
                                  O_msg_erreur  => P_loc_Tab_Acte(p_niv).messErreur,
                                  p_derog       => i_derog);
                                  /*
    P_INS_journal(2,'Dans devis P_loc_Tab_Acte(i).codfrais:'||P_loc_Tab_Acte(p_niv).codfrais);
    P_INS_journal(2,'Dans devis P_loc_Tab_Acte(i).mtprest:'||P_loc_Tab_Acte(p_niv).mtprest);
    P_INS_journal(2,'Dans devis P_loc_Tab_Acte(i).quantite:'||P_loc_Tab_Acte(p_niv).quantite);
    P_INS_journal(2,'P_loc_Tab_Acte(i).mtfrais_reel:'||P_loc_Tab_Acte(p_niv).mtfrais_reel);
    P_INS_journal(2,'P_loc_Tab_Acte(i).mtro:'||P_loc_Tab_Acte(p_niv).mtro);
    P_INS_journal(2,'Dans devis P_loc_Tab_Acte(i).codeErreur:'||P_loc_Tab_Acte(p_niv).codeErreur);
    P_INS_journal(2,'Dans devis erreur_calcul:'||erreur_calcul);
*/
  ELSE
    P_loc_Tab_Acte(p_niv).mtprest:=0;
  END IF;

   RETURN erreur_calcul;

END calculDevis;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                 */
/* Nom          :  gestionAbus                                               */
/* Type         :  Privee                                                    */
/* Description  :  Contr¶le sur la gestion des abus sur le nombre de demande */
/*                 de devis et/ou prise en charge                            */
/* Entree       :  P_patient                                                 */
/*                 P_datenais                                                */
/*                 P_rang                                                    */
/*                 P_equipement                                              */
/*                 P_opticien                                                */
/*                 P_type                                                    */
/* Retour       :  erreur abus 0 si pas d'erreur                             */
/*---------------------------------------------------------------------------*/
FUNCTION gestionAbus( P_patient      IN  individu.numindiv%TYPE
                     , P_assure      IN  individu.numindiv%TYPE
                     , P_rang        IN  NUMBER
                     , P_datenais    IN  DATE
                     , P_equipement  IN  VARCHAR2
                     , P_opticien    IN  individu.numindiv%TYPE
                     , P_NNI         IN  VARCHAR2
                     , P_type        IN  NUMBER)
RETURN NUMBER IS

  cptPECAn       NUMBER:=0; -- comptabilise le nombre de PEC annulée sur un mois.
  cptDevis       NUMBER:=0; -- comptabilise le nombre de devis sur un mois.
  cptPEC         NUMBER:=0; -- comptabilise le nombre de PEC sans annulation non liquidée
  loc_presta NUMBER:=NULL;  -- 1 VERRE, 2 MONTURE, 3 LENTILLE
  cptPEC_accord_adh NUMBER :=0; --comptabilise le nombre de PEC accordées de moins d'un mois pour les membres de l'adhesion de base du benef

BEGIN

  -- Récupération du type de prestation (VERRE, MONTURE, LENTILLE)
  IF P_equipement = 'VERRE' THEN
    loc_presta:=1;
  ELSIF P_equipement = 'MONTURE' THEN
      loc_presta:=2;
  ELSIF P_equipement = 'LENTILLE' THEN
      loc_presta:=3;
  END IF;

  -------------------- ABUS PEC AVEC ANNULATION---------------------------------
    -- Calcul du nombre de PEC annulée sur un mois.
    --ABO cas flouté : OPTC car dans flux on sait s'il s'agit d'un verre ou d'une lentille mais pas dans le dossier
    SELECT COUNT(distinct ds.NUM_DOSSIER)
      INTO cptPECAn
      FROM SINISTRE_SANTE ss
         , DOSSIER_SANTE ds
      --   , INDIVIDU i
         , NTFRS_DETAIL nd
     WHERE ds.NUM_DOSSIER=ss.NUM_DOSSIER
       AND ds.TYPE_DOSS=4  -- Concerne que les PEC
  --    AND i.NUMINDIV = ds.NUMINDIV
       AND F_ETAT_DOSSIER_SANTE(ds.NUM_DOSSIER,SYSDATE,1) = 1 -- Annulé
       AND TRUNC(ds.DATEFERM)>= ADD_MONTHS(SYSDATE,-1)
       AND ds.NUMPORTE=15
       AND ss.numligne =1 --ABO on prend préférentiellement lentille/verre
       AND ss.CODFRAIS = nd.CODFRAIS
       AND ((nd.VERRE = 1 AND loc_presta=1) OR (nd.MONTURE = 1 AND loc_presta=2) OR (nd.LENTILLE = 1 AND loc_presta=3))
       AND ds.NUMINDIV=P_patient
     --  AND i.rang=P_rang
     -- AND i.DATNAIS=P_datenais
       AND ds.numprescrip=P_opticien ;
      dbms_output.put_line('cptPECAn'||cptPECAn);

  -------------------- ABUS DEVIS-----------------------------------------------
    -- Calcul du nombre de devis sur un mois.
    SELECT COUNT(f.id_flux)
      INTO cptDevis
      FROM xml_04_06 x, flux f
     WHERE x.id_flux = f.id_flux
      AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:type','xmlns:mod="http://modele.ws.tpo.cga.com"') = '1'
      AND NVL(EXTRACTVALUE(doc_xml2,'oiamCRSP/priseEnChargeDetaillee[1]/avisPriseEnCharge[1]/decision','xmlns="http://modele.ws.tpo.cga.com"'),'6') = '4'
      AND f.statut=0
      AND TRUNC(f.dat_maj)>= ADD_MONTHS(SYSDATE,-2)
      AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:executant/mod:identite_ADELI',
                                'xmlns:mod="http://modele.ws.tpo.cga.com"') = P_NNI
      AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:priseEnChargeDetaillee[2]/mod:assure/mod:abstract_Identite',
                                'xmlns:mod="http://modele.ws.tpo.cga.com"') = to_char(P_assure)
      AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:patient/mod:pPhysique/mod:rang',
                                'xmlns:mod="http://modele.ws.tpo.cga.com"') = to_char(P_rang)
      AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:patient/mod:pPhysique/mod:naissance',
                                'xmlns:mod="http://modele.ws.tpo.cga.com"') = F_D2DATEHEURE(P_datenais)
      AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:identifiant',
                                'xmlns:mod="http://modele.ws.tpo.cga.com"') =P_equipement ;--ABO on prend uniquement le 1er acte
dbms_output.put_line('cptDevis'||cptDevis);
  -- PEC SANS ANNULATION NON LIQUID+E------------------------------------------
    -- Calcul du nombre de PEC non annulée et non liquidé sur un an.
      SELECT COUNT(distinct ds.NUM_DOSSIER)
      INTO cptPEC
      FROM SINISTRE_SANTE ss
      , DOSSIER_SANTE ds
      -- , INDIVIDU i
      , NTFRS_DETAIL nd
      WHERE ds.NUM_DOSSIER=ss.NUM_DOSSIER
      AND ds.TYPE_DOSS=4  -- Concerne que les PEC
      --  AND i.NUMINDIV = ds.NUMINDIV
      AND F_ETAT_DOSSIER_SANTE(ds.NUM_DOSSIER,SYSDATE,1) <> 1 -- Non Annulé
      AND ds.NUM_DOSSIER_PEC IS NULL -- Non liquidé
      --AND TRUNC(ds.DATEFERM)>= ADD_MONTHS(SYSDATE,-1) ABO le dossier est en cours donc pas fermé...
      AND TRUNC(ds.DATEOUV)>= AN(SYSDATE)
      AND ds.NUMPORTE=15
      AND ss.numligne =1 --ABO on prend préférentiellement lentille/verre
      AND ss.CODFRAIS = nd.CODFRAIS
      AND ((nd.VERRE = 1 AND loc_presta=1) OR (nd.MONTURE = 1 AND loc_presta=2) OR (nd.LENTILLE = 1 AND loc_presta=3))
      AND ds.NUMINDIV=P_patient
      --  AND i.rang=P_rang
      --   AND i.DATNAIS=P_datenais
      AND ds.numprescrip=P_opticien;
dbms_output.put_line('cptPEC'||cptPEC);


-- PEC accordées de moins d'un mois pour les membres de l'adhesion de base du benef------------------------------------------
    -- Calcul du nombre de PEC accordées de moins d'un mois pour les membres de l'adhesion de base du benef
      SELECT COUNT(distinct ds.NUM_DOSSIER)--ds.num_dossier
      INTO cptPEC_accord_adh
      FROM SINISTRE_SANTE ss
      , DOSSIER_SANTE ds
      , NTFRS_DETAIL nd
      WHERE ds.NUM_DOSSIER=ss.NUM_DOSSIER
      AND ds.TYPE_DOSS=4  -- Concerne que les PEC
      AND F_ETAT_DOSSIER_SANTE(ds.NUM_DOSSIER,SYSDATE,1) <> 1 -- Non Annulé
      --AND ds.NUM_DOSSIER_PEC IS NULL -- Non liquidé
      AND TRUNC(ds.DATEOUV)>trunc(add_months(sysdate,-1))  --ouvert il ya moins d'un mois
      AND ds.NUMPORTE=15
      AND ss.CODFRAIS = nd.CODFRAIS
      AND nat_doss=2 --optique
      AND (nd.VERRE = 1  OR nd.MONTURE = 1  OR nd.LENTILLE = 1 ) --RKO M0007230 les dossiers PEC optiques (verre, monture, lentille)
      AND ds.numassu= P_assure
       ;
dbms_output.put_line('cptPEC_accord_adh'||cptPEC_accord_adh);

  -- CONTROLE PEC -------------------------------------------------------------
  IF P_type = 2 THEN
    IF cptPECAn >= NVL(F_SENS_LIBELLE('CPT_ABUS',2),100) THEN
     P_INS_journal(2,'IF cptPECAn >= NVL(F_SENS_LIBELLE)');
     RETURN 2;  -- refus de la prise en charge si le nombre de PEC annulée sur un mois est égale ou superieur a 2
    ELSIF (cptPECAn + cptDevis) >= NVL(F_SENS_LIBELLE('CPT_ABUS',4),100) THEN --cas transformation devis en PEC
     P_INS_journal(2,' ELSIF (cptPECAn + cptDevis) >= NVL');
     RETURN 1;
    ELSIF cptPEC >= NVL(F_SENS_LIBELLE('CPT_ABUS',1),100)  THEN
     P_INS_journal(2,' ELSIF cptPEC > NVL(F_SENS_LIBELLE)');
     RETURN 3;  -- Refus du calcul d'une PEC  si une PEC  est en cours non liquidée (non annulée) sur l'année
    ELSIF cptPEC_accord_adh >= NVL(F_SENS_LIBELLE('CPT_ABUS',5),100) THEN  --Projet RAC DEROG WS gestion abus
     P_INS_journal(1,'IF cptPEC_accord_adh >= NVL(F_SENS_LIBELLE)');
     RETURN 5;
    END IF;

  -- CONTROLE DEVIS ------------------------------------------------------------
  ELSE
   IF (cptPECAn+cptDevis) >= NVL(F_SENS_LIBELLE('CPT_ABUS',3),100) THEN
     P_INS_journal(2,' cptPECAn+cptDevis');
     RETURN 1;
   ELSIF cptPEC >= NVL(F_SENS_LIBELLE('CPT_ABUS',1),100)  THEN
     P_INS_journal(2,' ELSIF cptPEC > NVL(F_SENS_LIBELLE');
     RETURN 3;  -- Refus du calcul d'une PEC  si une PEC  est en cours non liquidée (non annulée) sur l'année
   ELSIF cptPEC_accord_adh >= NVL(F_SENS_LIBELLE('CPT_ABUS',5),100) THEN  --Projet RAC DEROG WS gestion abus
     P_INS_journal(2,'IF cptPEC_accord_adh >= NVL(F_SENS_LIBELLE)');
     RETURN 5;
   END IF;
  END IF;

  RETURN 0;
END gestionAbus;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  SupplActe                                                 */
/* Type         :  Privee                                                    */
/* Description  :  Gestion des supplements optique                           */
/* Entree       :  IO_TabActe                                                */
/*              :  p_xml                                                     */
/*                 I_niv                                                     */
/*                 I_path                                                    */
/*                 I_type                                                    */
/*                 I_nature                                                  */
/* Retour       :  IO_TabActe                                                */
/*---------------------------------------------------------------------------*/
PROCEDURE SupplActe( IO_TabActe     IN OUT  TAB_T_Acte
                    ,p_xml           IN XMLTYPE
                    ,I_niv           IN  NUMBER
                    ,I_path          IN VARCHAR2
                    ,I_type          IN VARCHAR2
                    ,I_nature        IN NUMBER
                   )

IS
  j NUMBER;
  loc_pathT  VARCHAR2(200);
  nb_sup NUMBER:=0;
BEGIN
  j:=0;

  P_INS_journal(1,'RKO debut dans SupplActe');
  LOOP
    j := j+1;
    P_INS_journal(1,'RKO dans SupplActe j'||j);

    loc_pathT := I_path ||'supplementOptique['||j||']/supplement'||I_type||'/';
    P_INS_journal(1,'RKO I_path:'||substr(I_path,1,100));
    P_INS_journal(1,'RKO loc_pathT:'||substr(loc_pathT,1,100));
    --on ne traite que les supplement non RO
    P_INS_journal(1,'RKO param de existsnode:'||I_path ||'supplementOptique['||j||']');
    P_INS_journal(1,'RKO valeur 1er p_xml.existsnode='||p_xml.existsNode(I_path ||'supplementOptique['||j||']','xmlns="http://modele.ws.tpo.cga.com"'));
    IF p_xml.existsNode(I_path ||'supplementOptique['||j||']','xmlns="http://modele.ws.tpo.cga.com"') <>1 THEN -- sil n'existe pas de supplementOptique je sors de la boucle
      P_INS_journal(1,'RKO SupplActe dans if exit');
      EXIT;
    END IF;
    P_INS_journal(1,'RKO valeur 2er p_xml.existsnode= '||p_xml.existsNode(I_path ||'supplementOptique['||j||']/supplement'||I_type/*||'/'*/,'xmlns="http://modele.ws.tpo.cga.com"'));
    IF p_xml.existsNode(I_path ||'supplementOptique['||j||']/supplement'||I_type/*||'/'*/,'xmlns="http://modele.ws.tpo.cga.com"') <> 1 THEN --sil n'existe pas de supplementVerre/monture je passe au supplementOptique suivant
      P_INS_journal(1,'RKO SupplActe dans if continue');
      continue;
    ELSE

      --les supplements non RO sont cumulés dans l'acte porteur
      P_INS_journal(1,'RKO SupplActe : codfrais '||IO_TabActe(I_niv).codfrais);
      IO_TabActe(I_niv).mtro_sup := NVL(IO_TabActe(I_niv).mtro_sup,0) +NVL(PK_XML.EXTRACT_DATA(p_xml,loc_pathT || 'conditionDeRemboursement/part',null,1),0) ;
      IO_TabActe(I_niv).mtfrais_sup := NVL(IO_TabActe(I_niv).mtfrais_sup,0)  + (NVL(PK_XML.EXTRACT_DATA(p_xml,loc_pathT || 'depense',null,1),0));
      IO_TabActe(I_niv).remise_sup := NVL(IO_TabActe(I_niv).remise_sup,0) + (NVL(PK_XML.EXTRACT_DATA(p_xml,loc_pathT || 'abattements',null,1),0));
    END IF;
  END LOOP;

  P_INS_journal(1,'RKO fin SupplActe j'||j||' IO_TabActe(I_niv).mtro_sup '||IO_TabActe(I_niv).mtro_sup||'IO_TabActe(I_niv).mtfrais_sup'||IO_TabActe(I_niv).mtfrais_sup||'IO_TabActe(I_niv).remise_sup'||IO_TabActe(I_niv).remise_sup);

END SupplActe;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  SupplROActe                                               */
/* Type         :  Privee                                                    */
/* Description  :  Gestion des supplements RO                                */
/* Entree       :  IO_TabActe                                                */
/*              :  I_xml                                                     */
/*                 IO_niv                                                    */
/*                 I_path                                                    */
/*                 I_type                                                    */
/*                 I_nature                                                  */
/*                 IO_Tab_codfrais                                           */
/* Retour       :  IO_TabActe, IO_niv,IO_Tab_codfrais                        */
/*---------------------------------------------------------------------------*/
PROCEDURE SupplROActe( IO_TabActe    IN OUT  TAB_T_Acte
                    ,I_xml           IN XMLTYPE
                    ,IO_niv          IN OUT  NUMBER
                    ,I_path          IN VARCHAR2
                    ,I_type          IN VARCHAR2
                    ,I_nature        IN NUMBER
                    ,I_numfor        IN NUMBER
                    ,IO_Tab_codfrais IN OUT PK_CTRL_TP.TAB_codfrais
                    ,IO_acte_err_code IN OUT VARCHAR2
                   )

IS
  j NUMBER;
  loc_T_ntfrs_type_sup NTFRS_TYPE_SUP_T:=NTFRS_TYPE_SUP_T(NULL,NULL,NULL,NULL,NULL);
  loc_pathRO VARCHAR2(200);

BEGIN


  j:=0;
  P_INS_journal(1,'RKO debut dans SupplROActe');
  --Boucle sur les n suppléments d'un équipement optique (verre ou monture ou lentille) qu'ils soient RO ou non RO
  LOOP
    j := j+1;
P_INS_journal(1,'RKO dans SupplROActe j'||j);
    loc_pathRO := I_path ||'supplementOptique['||j||']/supplementRO/';

    P_INS_journal(1,'RKO loc_pathRO '||substr(loc_pathRO,1,100));

    --on ne traite que les suppléments RO
    IF I_xml.existsNode(I_path||'supplementOptique['||j||']','xmlns="http://modele.ws.tpo.cga.com"') <>1 THEN -- sil n'existe pas de supplementOptique je sors de la boucle
      P_INS_journal(1,'RKO supplROActe dans exit');
      EXIT;
    END IF;

    IF I_xml.existsNode(I_path||'supplementOptique['||j||']/supplementRO','xmlns="http://modele.ws.tpo.cga.com"') <> 1 THEN --sil n'existe pas de supplementRO je passe au supplementOptique suivant
      P_INS_journal(1,'RKO supplROActe dans continue');
      continue;
    ELSE --traitement du supplementRO
      P_INS_journal(1,'RKO supplROActe dans traitement supplROacte j'||j);
      IO_niv :=IO_niv+1;
      IO_TabActe(IO_niv).codfraisSPS := 'SUPPLEMENT';
      IO_TabActe(IO_niv).mtro:= NVL(PK_XML.EXTRACT_DATA(I_xml,loc_pathRO || 'conditionDeRemboursement/part',null,1),0);

      P_INS_journal(1,'RKO SupplROActe avt transco numfor: '||I_numfor||' I_nature '||I_nature||'lpp'||PK_XML.EXTRACT_DATA(I_xml,loc_pathRO || 'codeLPP',null,1));
      --transcodification de l'acte supplement RO
      PK_CTRL_TP.P_TRANSCO_CODFRAIS_SPSANTE( P_numfor              => I_numfor,
                                            P_nature_ntfrs_detail => I_nature,
                                            P_ntfrs_optique       => null,
                                            P_type_monture        => null,
                                            P_ntfrs_vision        => null,
                                            P_ntfrs_typ_vision    => null,
                                            P_ntfrs_matiere       => null,
                                            P_renew_lentille      => null,
                                            P_MtRO                => IO_TabActe(IO_niv).mtro,
                                            O_codfrais            => IO_Tab_codfrais,
                                            O_acte_err_code       => IO_acte_err_code,--'00',
                                            P_lpp               => PK_XML.EXTRACT_DATA(I_xml,loc_pathRO || 'codeLPP',null,1)
                                            );
      IO_TabActe(IO_niv).codfrais := IO_Tab_codfrais.FIRST ;
      P_INS_journal(1,'RKO SupplROActe IO_niv: '||IO_niv||' codfrais '||IO_TabActe(IO_niv).codfrais);
      IO_TabActe(IO_niv).taux := NVL(PK_XML.EXTRACT_DATA(I_xml,loc_pathRO || 'conditionDeRemboursement/financement',null,1),0);
      IO_TabActe(IO_niv).base := NVL(PK_XML.EXTRACT_DATA(I_xml,loc_pathRO || 'conditionDeRemboursement/base',null,1),0);
      IO_TabActe(IO_niv).quantite := 1;
      IO_TabActe(IO_niv).mtfrais := NVL(PK_XML.EXTRACT_DATA(I_xml,loc_pathRO || 'depense',null,1),0);
      IO_TabActe(IO_niv).remise := NVL(PK_XML.EXTRACT_DATA(I_xml,loc_pathRO || 'abattements',null,1),0);
      IO_TabActe(IO_niv).identifiant :=NVL(PK_XML.EXTRACT_DATA(I_xml,I_path||'equipement/identifiant',null,1),1);--alimentation de la balise identifiant pour le flux retour, sinon il sera invalid
    END IF;
  END LOOP;

  P_INS_journal(1,'RKO fin SupplROActe j'||j||' mtro '||IO_TabActe(IO_niv).mtro||' IO_TabActe(IO_niv).taux '||IO_TabActe(IO_niv).taux||'IO_TabActe(IO_niv).mtfrais'||IO_TabActe(IO_niv).mtfrais||'IO_TabActe(IO_niv).remise'||IO_TabActe(IO_niv).remise);

END SupplROActe;
/*---------------------------------------------------------------------------*/
/* PROCEDURE     P_INS_TRAVSAI_OPT                                           */
/* Nom          :                                                            */
/* Type         :  Privee                                                    */
/* Description  :  Insertion des verres dans la table trav_saisie            */
/* Entree       :                                                            */
/*              :  I_cpt                                                     */
/*                 P_path_xml                                                */
/*                 IO_Tab_Acte                                               */
/*                 I_tab_equip                                               */
/*                 I_TRAV_SAISIE                                             */
/* Retour       :  IO_TabActe                                                */
/*---------------------------------------------------------------------------*/


Procedure P_INS_TRAVSAI_OPT (I_cpt        IN NUMBER,
                            I_path_xml    IN VARCHAR2,
                            I_xml         IN XMLTYPE,
                            IO_Tab_Acte   IN OUT TAB_T_Acte,
                            I_tab_equip   IN TAB_T_EQUIP,
                            I_TRAV_SAISIE IN trav_saisie%ROWTYPE
                            )
IS
  cpt_trav     number;
  loc_trav     trav_saisie%ROWTYPE;
  loc_numequip NUMBER;
  v_loc_oeil   VARCHAR2(2);
BEGIN
  --P_TRAV_SAISIE.NUMLIG:= i;
  --Saisie des verres dans trav_saisie
  cpt_trav :=0;
  IF IO_Tab_Acte(I_cpt).codfraisSPS = 'VERRE' THEN --v_codfraisSPS = 'VERRE' -- v_nature_ntfrs_detail =1
    loc_trav := I_TRAV_SAISIE;
    loc_numequip := IO_Tab_Acte(I_cpt).numequip;
    v_loc_oeil :=PK_XML.EXTRACT_DATA(I_xml,I_path_xml || 'prestationOptique['||loc_numequip||']/ametropie/oeil',null,1);
    --P_INS_journal(1,'I_tab_equip(I_cpt).numequip:'||IO_Tab_Acte(I_cpt).numequip||' acte I_cpt '||IO_Tab_Acte(I_cpt).codfrais||'v_loc_oeil'||v_loc_oeil);
    IF v_loc_oeil = '2D' THEN --Saisie oeil droit
      loc_trav.oeil := 'D';
      --P_INS_journal(1,'P_INS_TRAVSAI_OPT', 'loc_numequip'||loc_numequip||'spheredrt'||I_tab_equip(loc_numequip).SPHERE_VER_DEB||'cylindrt'||I_tab_equip(loc_numequip).CYLINDRE_VER_DEB);
      loc_trav.sphere := NVL(I_tab_equip(loc_numequip).SPHERE_VER_DEB,0);
      loc_trav.cylindre := NVL(I_tab_equip(loc_numequip).CYLINDRE_VER_DEB,0);
      loc_trav.addition:= NVL(I_tab_equip(loc_numequip).ADDITION_VER_DEB,0);
      loc_trav.axe := NVL(PK_XML.EXTRACT_DATA(I_xml,I_path_xml || 'prestationOptique['||loc_numequip||']/ametropie/axeDuCylindre',null,1),0);--Recuperation de l'axe avec EXTRACT_DATA pour eviter que ca pète
      --puis insertion
      --P_INS_journal(1,'avt insert_travsaisie oeildroit spher: '||loc_trav.sphere||' cylin '||loc_trav.cylindre||' addit '||loc_trav.addition||' axe '||loc_trav.axe);
      P_INSERT_TRAV_SAISIE(  loc_trav );
      cpt_trav := cpt_trav +1;

    ELSIF v_loc_oeil = '2G' THEN  --Saisie oeil droit
      loc_trav.oeil := 'G';
      P_INS_journal(1,'P_INS_TRAVSAI_OPT', 'loc_numequip'||loc_numequip||'spheregauch'||I_tab_equip(loc_numequip).SPHERE_VER_DEB||'cylingauch'||I_tab_equip(loc_numequip).CYLINDRE_VER_DEB);
      loc_trav.sphere := NVL(I_tab_equip(loc_numequip).SPHERE_VER_DEB,0);
      loc_trav.cylindre := NVL(I_tab_equip(loc_numequip).CYLINDRE_VER_DEB,0);
      loc_trav.addition:= NVL(I_tab_equip(loc_numequip).ADDITION_VER_DEB,0);
      loc_trav.axe := NVL(PK_XML.EXTRACT_DATA(I_xml,I_path_xml || 'prestationOptique['||loc_numequip||']/ametropie/axeDuCylindre',null,1),0);--Recuperation de l'axe avec EXTRACT_DATA pour eviter que ca pète
      --puis insertion
      --P_INS_journal(1,'avt insert_travsaisie oeilgauch spher: '||loc_trav.sphere||' cylin '||loc_trav.cylindre||' addit '||loc_trav.addition||' axe '||loc_trav.axe);
      P_INSERT_TRAV_SAISIE(  loc_trav );
      cpt_trav := cpt_trav +1;
    END IF;
  END IF;-- loc_Tab_Acte(i).codfraisSPS = 'verre'
  IF cpt_trav=0 THEN
   -- P_INS_journal(1,'avt insert_travsaisie cpt_trav=0, I_TRAV_SAISIE spher: '||I_TRAV_SAISIE.sphere||' cylin '||I_TRAV_SAISIE.cylindre||' addit '||I_TRAV_SAISIE.addition||' axe '||I_TRAV_SAISIE.axe);
    P_INSERT_TRAV_SAISIE(  I_TRAV_SAISIE );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'P_INS_TRAVSAI_OPT others', sqlerrm);
END P_INS_TRAVSAI_OPT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :                                                            */
/* Type         :  Privee                                                    */
/* Description  :  Construction de la prise en charge                        */
/* Entree       :                                                            */
/*              :  P_Tab_Indiv                                               */
/*                 p_xml                                                     */
/*                 I_path_patient                                            */
/*                 I_path_pec1                                               */
/*                 I_path_pec2                                               */
/*                 I_path_xml                                                */
/*                 KO                                                        */
/* Retour       :  IO_TabActe                                                */
/*---------------------------------------------------------------------------*/
FUNCTION ConstructPriseEnCharge( P_Tab_Indiv     IN  PK_CTRL_TP.TAB_T_Indiv
                                ,p_xml           IN  XMLTYPE
                                ,I_path_patient  IN  VARCHAR2
                                ,I_path_pec1     IN  VARCHAR2
                                ,I_path_pec2     IN  VARCHAR2
                                ,I_path_xml      IN  VARCHAR2
                                ,KO              IN  BOOLEAN
                                ,P_AvisPEC       OUT VARCHAR2)
RETURN NUMBER
IS
  loc_Tab_Indiv  PK_CTRL_TP.TAB_T_Indiv;
  loc_typeFlux   NUMBER;
  loc_refdossExt VARCHAR2(50):='0';
  loc_AvisPEC      VARCHAR2(50):='0';
BEGIN
  loc_typeFlux:=PK_XML.EXTRACT_DATA(p_xml,'oiamCREQ/type',null,1);
  loc_refdossExt :=PK_XML.EXTRACT_DATA(P_xml,I_path_pec2 || 'identifiant',null,1);
  P_AvisPEC:=PK_XML.EXTRACT_DATA(P_xml,I_path_xml || 'referenceDossierOperateur',null,1);
  --loc_Tab_Indiv := F_extract_individu( p_xml,I_path_patient,I_path_pec1,I_path_pec2);

  P_ENTETE_REP(p_type  => loc_typeFlux,
               p_ident =>PK_XML.EXTRACT_DATA(P_xml,'oiamCREQ/identification',null,1));


  IF KO THEN
    null;  --TODO reset du flux déjà construit
  END IF;


  pk_xml.add_element('/','origine');
  pk_xml.add_data('origine', 'nomNormeAMC',PK_XML.EXTRACT_DATA(p_xml,'oiamCREQ/origine/nomNormeEmetteur',null,1), false);
  pk_xml.add_data('origine', 'versionNormeAMC',PK_XML.EXTRACT_DATA(p_xml,'oiamCREQ/origine/versionNormeEmetteur',null,1), false);
  pk_xml.add_element('/', 'patient');
  pk_xml.add_element('patient', 'pPhysique');
  pk_xml.add_element('pPhysique', 'nom');
  pk_xml.add_data('nom','famille', P_Tab_Indiv('bene').nom , false);
  pk_xml.add_data('nom','prenom',  P_Tab_Indiv('bene').prenom, false);
  pk_xml.add_data('pPhysique','naissance',F_D2DATEHEURE(P_Tab_Indiv('bene').datnais), false);
  pk_xml.add_data('pPhysique','rang',  P_Tab_Indiv('bene').rang, false);
  pk_xml.add_element('/', 'priseEnChargeDetaillee');
  -- M5439-M5454  : mise en commentaire de cette balise car les PEC KRYS ne l alimente pas toujours ce qui provoque une erreur de structure de flux
  -- pk_xml.add_data('priseEnChargeDetaillee','identifiant',loc_refdossExt, false);
  pk_xml.add_data('priseEnChargeDetaillee','type', 2, false);
  pk_xml.add_element('priseEnChargeDetaillee', 'avisPriseEnCharge');
  pk_xml.add_data('avisPriseEnCharge','identifiant', PK_XML.EXTRACT_DATA(P_xml,I_path_xml || 'referenceDossierOperateur',null,1), false);
  pk_xml.add_data('avisPriseEnCharge','decision', 1, false);
  pk_xml.add_data('avisPriseEnCharge','motif', 1, false);
  pk_xml.add_data('avisPriseEnCharge','effet',F_D2DATEHEURE(sysdate), false);
 /* IF NOT KO THEN --pourquoi pas dans KO ?
    pk_xml.add_data('avisPriseEnCharge','identifiant', loc_AvisPEC);
    pk_xml.add_data('avisPriseEnCharge','decision', 1);
  END IF;*/

 -- pk_xml.add_data('priseEnChargeDetaillee/avisPriseEnCharge','montantTotal',0);--TODO mis à 0 OK?

  pk_xml.add_element('priseEnChargeDetaillee', 'assure');
  --IF NOT KO THEN
    pk_xml.add_data('assure','abstract_Identite', P_Tab_Indiv('assure').numindiv , false);--vraiment utile de conditionner ?
 -- END IF;
  /*pk_xml.add_element('assure', 'pPhysique');
  pk_xml.add_element('pPhysique', 'nom');
  pk_xml.add_data('nom','famille', P_Tab_Indiv('assure').nom );
  pk_xml.add_data('nom','prenom',  P_Tab_Indiv('assure').prenom);
  pk_xml.add_data('pPhysique','naissance',F_D2DATEHEURE(P_Tab_Indiv('assure').datnais));
  pk_xml.add_data('pPhysique','rang',  P_Tab_Indiv('assure').rang);*/
  pk_xml.add_element('/', 'partenariat');
  pk_xml.add_element('partenariat', 'propositionClient');
  pk_xml.add_data('propositionClient','identifiant', 0, false);
  pk_xml.add_data('propositionClient','referenceDossierAMC', 0, false);
  pk_xml.add_data('propositionClient','referenceDossierOperateur', loc_refdossExt, false);

  IF KO THEN
    pk_xml.add_element('propositionClient', 'prestationOptique');
    pk_xml.add_data('prestationOptique','depense', 0, false);
    pk_xml.add_data('prestationOptique','nature', 0, false);
  END IF;
 --TO DO à gérer
 /* v_code:=2; -- KO technique
  v_raison:=2;-- erreur d acheminement
  v_justification:=7; -- Information obligatoire manquante dans une ou plusieurs lignes de détails
  v_libelle:='Information erronnée dans une ou plusieurs lignes de détails';*/

  RETURN loc_typeFlux;
END ConstructPriseEnCharge;


FUNCTION F_extract_individu( p_xml           IN XMLTYPE
                            ,I_path_patient  IN VARCHAR2
                            ,I_path_pec1     IN VARCHAR2
                            ,I_path_pec2     IN VARCHAR2)
RETURN PK_CTRL_TP.TAB_T_Indiv IS

loc_Tab_Indiv PK_CTRL_TP.TAB_T_Indiv;
BEGIN

  --assuré principal
  BEGIN
    -- permet de gérer une mauvaise saisie
    loc_Tab_Indiv('assure').numindiv := PK_XML.EXTRACT_DATA(p_xml,I_path_pec2 ||'assure/abstract_Identite',null,1);
  EXCEPTION
    WHEN OTHERS THEN
      loc_Tab_Indiv('assure').numindiv:=0;
  END;

  P_INS_journal(3,'Construction du corps de la réponse abstract_Identite');
  loc_Tab_Indiv('assure').nom := PK_XML.EXTRACT_DATA(p_xml,I_path_pec2 || 'assure/pPhysique/nom/famille',null,1);
  loc_Tab_Indiv('assure').prenom := PK_XML.EXTRACT_DATA(p_xml,I_path_pec2 || 'assure/pPhysique/nom/prenom',null,1);
  loc_Tab_Indiv('assure').datnais :=F_DATEHEURE2D(PK_XML.EXTRACT_DATA(p_xml,I_path_pec2 || 'assure/pPhysique/naissance',null,1));
  loc_Tab_Indiv('assure').rang :=PK_XML.EXTRACT_DATA(p_xml,I_path_pec2 || 'assure/pPhysique/rang',null,1);
  loc_Tab_Indiv('assure').matorg :=substr(PK_XML.EXTRACT_DATA(p_xml,I_path_pec2 || 'assure/identite_NIR',null,1),0,13);
  loc_Tab_Indiv('assure').cless :=substr(PK_XML.EXTRACT_DATA(p_xml,I_path_pec2 || 'assure/identite_NIR',null,1),14);
  P_INS_journal(3,'Construction du corps de la réponse assure');

  --patient bénéfiaire
  loc_Tab_Indiv('bene').nom := PK_XML.EXTRACT_DATA(p_xml,I_path_patient || 'pPhysique/nom/famille',null,1);
  loc_Tab_Indiv('bene').prenom := PK_XML.EXTRACT_DATA(p_xml,I_path_patient || 'pPhysique/nom/prenom',null,1);
  loc_Tab_Indiv('bene').datnais := F_DATEHEURE2D(PK_XML.EXTRACT_DATA(p_xml,I_path_patient || 'pPhysique/naissance',null,1));
  loc_Tab_Indiv('bene').rang :=PK_XML.EXTRACT_DATA(p_xml,I_path_patient || 'pPhysique/rang',null,1);
  loc_Tab_Indiv('bene').matorg :=substr(PK_XML.EXTRACT_DATA(p_xml,I_path_pec1 || 'assure/identite_NIR',null,1),0,13);
  loc_Tab_Indiv('bene').cless :=substr(PK_XML.EXTRACT_DATA(p_xml,I_path_pec1 || 'assure/identite_NIR',null,1),14);
  P_INS_journal(3,'Construction du corps de la réponse benef');

  RETURN loc_Tab_Indiv;

END F_extract_individu;

FUNCTION ErreurActe(i_code IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
  CASE i_code
    WHEN '01' THEN RETURN 'Plusieurs codes actes Arthus trouvées.';
    WHEN '02' THEN RETURN 'Aucune famille d''acte optique valide trouvée pour la garantie.';
    WHEN '03' THEN RETURN 'Plusieurs codes actes AMC trouvés.';
    WHEN '04' THEN RETURN 'Aucun acte optique valide trouvé pour la garantie.';
    WHEN '05' THEN RETURN 'Plusieurs codes actes Arthus trouvés.';
    WHEN '06' THEN RETURN 'Aucun acte optique valide trouvé pour la garantie.';
    WHEN '07' THEN RETURN 'Aucun acte optique valide trouvé pour la garantie.';
    WHEN '08' THEN RETURN 'Acte optique non couvert.';
    WHEN '09' THEN RETURN 'Date du sinistre postérieure à la date attendue.';
    ELSE RETURN 'Erreur Acte optique';
  END CASE;
END ErreurActe;

FUNCTION ErreurCalcul(i_code IN NUMBER,i_mtprest IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
  CASE i_code
    WHEN 0 THEN RETURN'';
    WHEN 6 THEN
      IF i_mtprest=0 THEN  RETURN 'Aucun remboursement d''une prestation (soumise un délai de carence)'; --9
      ELSE RETURN 'Remboursement partiel d''une prestation (soumise un délai de carence)'; --10
      END IF;
    WHEN 7 THEN
      IF i_mtprest = 0 THEN RETURN'Aucun remboursement d''une prestation (plafond atteint)'; --11
      ELSE RETURN 'Remboursement partiel d''une prestation (plafond atteint)'; --12
      END IF;
    WHEN 8  THEN RETURN 'Remboursement d''une prestation soumis à franchise'; --29
    ELSE RETURN 'Remboursement partiel d''une prestation (couverture insuffisante)'; --2

  END CASE;


END ErreurCalcul;

PROCEDURE P_Init_Editique IS
BEGIN
  v_paragraphe1 :='Nous avons bien reçu, via internet, votre demande de tiers payant relatif à un équipement optique pour notre assuré, ';
  v_paragraphe2 :='Cette demande de prise en charge ne peut être accordée pour le motif suivant : ';
  v_paragraphe3 :='Nous sommes bien entendu à votre disposition au 01 45 22 52 53, pour toute précision complémentaire.';
  v_paragraphe4 :='Veuillez recevoir Madame, Monsieur, nos sincères salutations.';
  v_paragraphe5 :='Cette demande de prise en charge ou devis ne peut être accordée pour le motif suivant : ';
  v_mess_refus1 :='L''assuré n''a pu être identifié dans les fichiers de GEREP. Il convient de vérifier son attestation de tiers payant.';
  v_mess_refus2 :='Le bénéficiaire n''a pu être identifié dans les fichiers de GEREP. Il convient de vérifier son attestation de tiers payant.';
  v_mess_refus3 :='L''information concernant l''ordonnance est obligatoire pour calculer la garantie. Il convient de compléter votre demande.';
  v_mess_refus4 :='L''information concernant la prestation ou son montant est erronée et empêche le calcul de la garantie. Il convient de modifier votre demande.';
  v_mess_refus5 :='Le bénéficiaire n''a pu être identifié dans les fichiers de GEREP. Il convient de vérifier son attestation de tiers payant.';
  v_mess_refus6 :='Votre magasin n''a pu être identifié dans nos fichiers. Il convient de vous rapprocher de SP santé à l''adresse email suivant :.';
  v_mess_refus8 :='Les produits d entretien pour lentille ne sont pas couverts. ';
  v_mess_refus9 :='Le nombre de demandes de prise en charge ou de devis est supérieur au nombre autorisé. ';
  v_mess_refus10:='Le nombre de lentilles est limité à 12 par présentation par oeil. ';
  v_mess_refus11:='Calcul impossible ou forfait épuisé.';
  --v_mess_refus12:='Merci d''adresser votre demande accompagnée des justificatifs à ps@gerep.fr';
  v_mess_refus12 :='Abus de demande de prise en charge ou devis pour la même adhésion';  --M0007222
  v_mess_refus13 :='Abus dépassement de frais réels de prestation'; --M0007222
  v_lib1 :='Merci d''adresser votre demande accompagnée des justificatifs à devis@gerep.fr'; --M0007222     /* 27/04/2021 ARO ARTGEREP-397 Modification adresse mail */
  v_lib2 := 'Si votre demande concerne un renouvellement anticipe, '||lower(v_lib1); --M0007243 modification du libellé pour le refus calcul imp. ou forfait epuisé
END;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INSERT_INFOS_VERRES                                     */
/* Type         :  Privee                                                    */
/* Description  :  Insertion des informations sur la diopterie des verres    */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INSERT_INFOS_VERRES( P_numindiv    IN sinistre_sante.numindiv%TYPE
                               , P_codfrais    IN sinistre_sante.codfrais%TYPE
                               , P_numfor      IN ADHESION.NUMFOR%TYPE
                               , i             IN NUMBER
                            --   , P_Tab_acte    IN TAB_T_ACTE
                               , P_t_verre     IN NTFRS_OPTIQUE_T
                               , P_num_dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE
                                )
IS

  loc_cpt   number;

BEGIN

  INSERT INTO PEC_DETAILS(ID_PEC_DETAILS,NUMPORTE,CODFRAIS,NUMDOSSIER, NUMLIGNE, OEIL, NUMINDIV,NUMFOR,DATSIN,SPHERE,CYLINDRE,AXE,ADDITION)
  VALUES(ID_PEC_DETAILS.nextval,16,P_codfrais, P_num_dossier, i, i, P_numindiv,P_numfor,SYSDATE,P_t_verre.SPHERE_DEB,P_t_verre.CYLINDRE_DEB,P_t_verre.AMINCI_DEB,P_t_verre.ADDITION_DEB);


END P_INSERT_INFOS_VERRES;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_INFOS_VERRES                                       */
/* Type         :  Privee                                                    */
/* Description  :  Recherche des informations sur la dioptrie des verres     */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_INFOS_VERRES( P_numindiv     IN sinistre_sante.numindiv%TYPE
                             , P_codfrais    IN sinistre_sante.codfrais%TYPE
                             , P_numfor      IN ADHESION.NUMFOR%TYPE
                             , i             IN NUMBER
                          --   , P_Tab_acte    IN TAB_T_ACTE
                             , P_t_verre     IN NTFRS_OPTIQUE_T
                             , P_num_dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE
                              )
RETURN NUMBER
IS

  loc_cpt   number;

BEGIN

  SELECT MAX(ID_PEC_DETAILS)
    INTO loc_cpt
    FROM PEC_DETAILS
   WHERE NUMINDIV = P_numindiv
     AND (SPHERE   = P_t_verre.SPHERE_DEB     OR SPHERE   IS NULL)
     AND (CYLINDRE = P_t_verre.CYLINDRE_DEB   OR CYLINDRE IS NULL)
     AND (ADDITION = P_t_verre.ADDITION_DEB   OR ADDITION IS NULL)
     AND (AXE      = P_t_verre.AMINCI_DEB     OR AXE   IS NULL)
     AND NUMPORTE IN (22,16) -- ITELIS et SPSANTE
     AND d2j(DATSIN) BETWEEN d2j(SYSDATE-730) AND d2j(SYSDATE)
    -- AND NUMDOSSIER = P_num_dossier
    -- AND NUMLIGNE = i
     AND OEIL = i
     AND EXISTS (SELECT NUMSIN
                   FROM SNTR_DOSSIER sd
                      , SINISTRE s
                  WHERE s.NUMSIN = sd.NUMSIN_SNTR
                    AND PEC_DETAILS.NUMDOSSIER=sd.NUM_DOSSIER
                    AND s.NUMINDIV = P_numindiv);

  RETURN loc_cpt;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;        -- Changement de diopterie
  WHEN OTHERS THEN
    RETURN 1;
END F_FIND_INFOS_VERRES;
/*----------------------------------------------------------------------------*/
/* PROCEDURE                                                                  */
/* Nom          :  P_envoi_Mail                                               */
/* Type         :  Public                                                     */
/* Description  :                                                             */
/* Entree       :  P_envoi_Mail                                               */
/* Retour       :                                                             */
/*----------------------------------------------------------------------------*/
PROCEDURE P_envoi_Mail( P_ObjetMail       IN       VARCHAR2
                      , P_MessMail        IN       VARCHAR2)
IS

  v_From      VARCHAR2(80) := 'j.boishardy@cat-amania.com';
  v_Recipient VARCHAR2(80) := 'j.boishardy@cat-amania.com';
  v_Mail_Host VARCHAR2(30) := 'mail.cat-amania.com';
  v_Mail_Conn utl_smtp.Connection;
  crlf        VARCHAR2(2)  := chr(13)||chr(10);

BEGIN

  v_Mail_Conn := utl_smtp.Open_Connection(v_Mail_Host, 25);
  utl_smtp.Helo(v_Mail_Conn, v_Mail_Host);
  utl_smtp.Mail(v_Mail_Conn, v_From);
  utl_smtp.Rcpt(v_Mail_Conn, v_Recipient);
  utl_smtp.Data(v_Mail_Conn,
               'Date: '   || to_char(sysdate, 'Dy, DD Mon YYYY hh24:mi:ss') || crlf ||
               'From: '   || v_From || crlf ||
               'Subject: '|| P_ObjetMail || crlf ||
               'To: '     || v_Recipient || crlf ||
               crlf ||
               P_MessMail|| crlf ||           -- Message body
               ''        || crlf              -- More message body
                 );
  utl_smtp.Quit(v_mail_conn);

  P_INS_journal(1,'envoi_Mail OK ' );

EXCEPTION
  WHEN utl_smtp.Transient_Error OR utl_smtp.Permanent_Error then
    P_INS_journal(1,'envoi_Mail KO ' );
    raise_application_error(-20000, 'Unable to send mail', TRUE);
END P_envoi_Mail;



-- Insertion dans journal_adm
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
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
        I_session  => SID,
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;
  COMMIT;
END P_INS_journal;
---------------- Fin des corps des procedures privees --
END PK_SPSANTE;
/
