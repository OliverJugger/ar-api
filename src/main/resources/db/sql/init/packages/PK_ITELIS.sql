CREATE OR REPLACE PACKAGE ARTHUS.PK_ITELIS AS
/*============================================================================*/
/* PACKAGE      : PK_ITELIS.sql                                               */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 06/12/2016                                                  */
/* Description  : Gestion des flux XML du tiers payant optique/dentaire et    */
/*                auditif pour ITELIS(Service AXA)                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO : M0005659_Anomalie_de_liquidation_de_PEC + dioptrie    */
/*               Modification de la transco dentaire en obligeant le code CCAM*/
/*============================================================================*/

/*  Type                                      */
TYPE T_ACTE IS RECORD ( numeroActe                     VARCHAR2(19),
                        identiteActeReference          VARCHAR2(19),
                        libelleActe                    VARCHAR2(512),
                        libelleActeLibre               VARCHAR2(512),
                        codeActeSS                     VARCHAR2(10),
                        codeCCAM                       VARCHAR2(7),
                        prixActe                       VARCHAR2(10),
                        prixRemise                     VARCHAR2(10),
                      --  prixRemiseActe                 VARCHAR2(10),
                        prixActeRemise                 VARCHAR2(10),
                        prixVenteDispositif            VARCHAR2(10),
                        montantPrestationSoin          VARCHAR2(10),
                        chargesStructure               VARCHAR2(10),
                        acteBaseSS                     VARCHAR2(10),
                        acteRemboursementSS            VARCHAR2(10),
                        acteRC                         VARCHAR2(10),
                        acteRAC                        VARCHAR2(10),
                        messageInformatif              VARCHAR2(200),
                        messageErreur                  VARCHAR2(512),
                        acteType                       VARCHAR2(24),
                        codfrais                       VARCHAR(10),
                        nature_prest                   VARCHAR2(6),
                        codeReponse                    VARCHAR(10)
                        );
TYPE TAB_T_ACTE IS TABLE OF T_ACTE index by binary_integer;
/*
  ==> acteType  : créer des types pour chacunes des catégories d actes indiqué ci-dessous
Type de l'acte, à choisir parmi :
"MONTURE"
"VERRE"
"SUPPLEMENT VERRE"
"LENTILLE"
"ACTE DENTAIRE"
"AUDIOPROTHESE"
"SUPPLEMENT AUDIOPROTHESE"
"SUPPLEMENT LENTILLE"
*/
TYPE T_MONTURE IS RECORD ( acteType                       VARCHAR2(24),
                           montureType                    VARCHAR2(2)
                       --    marque                         VARCHAR2(50),
                       --    modele                         VARCHAR2(50)
                        );

TYPE TAB_T_MONTURE IS TABLE OF T_MONTURE index by binary_integer;

TYPE T_VERRE IS RECORD ( acteType                       VARCHAR2(24),
                         oeil                           NUMBER(1),
                         sphere                         VARCHAR2(6), -- 50
                         cylindre                       VARCHAR2(6),
                         axe                            VARCHAR2(6),
                         addition                       VARCHAR2(6),
                         prisme                         VARCHAR2(4),
                         pathologie                     VARCHAR2(5),
                         verreType                      VARCHAR2(2),
                         verreIndice                    VARCHAR2(2),
                         verreSurface                   VARCHAR2(2),
                         verreMateriau                  VARCHAR2(2),
                         verreDiametre                  VARCHAR2(2)
                        );

TYPE TAB_T_VERRE IS TABLE OF T_VERRE index by binary_integer;

TYPE T_LENTILLE IS RECORD ( acteType                       VARCHAR2(24),
                            oeil                           NUMBER(1),
                            sphere                         VARCHAR2(6), -- 50
                            cylindre                       VARCHAR2(6),
                            axe                            VARCHAR2(6),
                            addition                       VARCHAR2(6),
                            prisme                         VARCHAR2(4),
                            pathologie                     VARCHAR2(5),
                            lentilleType                   VARCHAR2(2),
                            lentilleFamille                VARCHAR2(2),
                            lentilleJetable                VARCHAR2(5),
                            lentilleDiametre               VARCHAR2(3),
                            lentilleRayon                  VARCHAR2(3),
                            lentilleNombreBoites           VARCHAR2(3),
                            lentilleNombreParBoite         VARCHAR2(3)
                          );

TYPE TAB_T_LENTILLE IS TABLE OF T_LENTILLE index by binary_integer;

TYPE T_DENTAIRE IS RECORD ( acteType                       VARCHAR2(24),
                            dentaireType                   VARCHAR2(2),
                            dentaireFamille                VARCHAR2(1),   -- Balise toujours renseignée à zéro
                            codeRegroupement               VARCHAR2(3),
                            codeCCAM                       VARCHAR2(8),
                            opposable                      VARCHAR2(1),   -- boolean : 0 non opposable, 1 opposable
                            nombreDents                    VARCHAR2(2),
                            numerosDents                   VARCHAR2(255),
                            dentaireMateriauxCCAM          VARCHAR2(255)
                         );

TYPE TAB_T_DENTAIRE IS TABLE OF T_DENTAIRE index by binary_integer;


TYPE T_AUDITIF IS RECORD ( acteType                        VARCHAR2(24),
                           oreille                         VARCHAR2(2),  -- 0 droite, 1 gauche
                           Hz500                           NUMBER(3),
                           Hz1000                          NUMBER(3),
                           Hz2000                          NUMBER(3),
                           Hz4000                          NUMBER(3)
                        );

TYPE TAB_T_AUDITIF IS TABLE OF T_AUDITIF index by binary_integer;

TYPE T_EQUIP IS RECORD (acteType_mont                  VARCHAR2(24),   --RKO WS RAC DEROG
                        montureType                    VARCHAR2(2),
                        --verre
                        acteType_verr                  VARCHAR2(24),
                        oeil                           NUMBER(1),
                        sphere                         VARCHAR2(6),
                        cylindre                       VARCHAR2(6),
                        axe                            VARCHAR2(6),
                        addition                       VARCHAR2(6),
                        prisme                         VARCHAR2(4),
                        pathologie                     VARCHAR2(5),
                        verreType                      VARCHAR2(2),
                        verreIndice                    VARCHAR2(2),
                        verreSurface                   VARCHAR2(2),
                        verreMateriau                  VARCHAR2(2),
                        verreDiametre                  VARCHAR2(2),
                        --supplement
                        acteType_sup_ver               VARCHAR2(24),
                        acteType_sup_mon               VARCHAR2(24),
                        --lentille
                        acteType_lent                  VARCHAR2(24),
                        oeil_lent                      NUMBER(1),
                        sphere_lent                    VARCHAR2(6), -- 50
                        cylindre_lent                  VARCHAR2(6),
                        axe_lent                       VARCHAR2(6),
                        addition_lent                  VARCHAR2(6),
                        prisme_lent                    VARCHAR2(4),
                        pathologie_lent                VARCHAR2(5),
                        lentilleType                   VARCHAR2(2),
                        lentilleFamille                VARCHAR2(2),
                        lentilleJetable                VARCHAR2(5),
                        lentilleDiametre               VARCHAR2(3),
                        lentilleRayon                  VARCHAR2(3),
                        lentilleNombreBoites           VARCHAR2(3),
                        lentilleNombreParBoite         VARCHAR2(3),
                        --dent
                        acteType_dent                  VARCHAR2(24),
                        dentaireType                   VARCHAR2(2),
                        dentaireFamille                VARCHAR2(1),   -- Balise toujours renseignée à zéro
                        codeRegroupement               VARCHAR2(3),
                        codeCCAM                       VARCHAR2(8),
                        opposable                      VARCHAR2(1),   -- boolean : 0 non opposable, 1 opposable
                        nombreDents                    VARCHAR2(2),
                        numerosDents                   VARCHAR2(255),
                        dentaireMateriauxCCAM          VARCHAR2(255) ,
                        --audio
                        acteType_audio                 VARCHAR2(24),
                        oreille                        VARCHAR2(2),  -- 0 droite, 1 gauche
                        Hz500                          NUMBER(3),
                        Hz1000                         NUMBER(3),
                        Hz2000                         NUMBER(3),
                        Hz4000                         NUMBER(3) );

TYPE TAB_T_EQUIP IS TABLE OF T_EQUIP index by binary_integer;

/* Fonction renvoyant laz liste des bénéficiaire d'un Assuré, ou un message d'erreur si cette personne n'existe pas*/
FUNCTION F_BENEFICIAIRE (P_Question IN XMLTYPE) RETURN XMLTYPE;
/* Fonction renvoyant un devis, ou un message d'erreur en cas d'impossibilité de répondre la demande */
FUNCTION F_CALCULRC (P_Question IN XMLTYPE) RETURN XMLTYPE;
/* Function renvoyant une confirmation de prise en charge de l'acte */
FUNCTION F_FACTURATION (P_Question IN XMLTYPE) RETURN XMLTYPE;
/* Function permettant d'annuler une prise en charge existante*/
FUNCTION F_ANNULATION (P_Question IN XMLTYPE) RETURN XMLTYPE;
/* Function permettant d'annuler une prise en charge existante*/
FUNCTION F_MAJPEC ( P_ref_dossier DOSSIER_SANTE.REF_DOSSIER%TYPE) RETURN NUMBER;

FUNCTION appel_ws(p_id_type in type_flux.id_type%type,
                  p_doc_xml in xmltype) return XMLTYPE;

PROCEDURE P_FIND_ASSURE_BY_NOM(
   P_nom            IN      individu.nom%TYPE default null
  ,P_prenom         IN      individu.prenom%TYPE default null
  ,P_datenais       IN      individu.DATNAIS%TYPE
  ,P_numindiv       IN      individu.NUMINDIV%TYPE
  ,P_rang           IN      individu.RANG%TYPE
  ,IO_Tab_indiv     IN  OUT PK_CTRL_TP.TAB_T_Indiv
  ,P_matorg         IN      VARCHAR2
  ,IO_cpt               OUT NUMBER
  ,O_numassu            OUT individu.numassu%TYPE
  ,O_erreur             OUT NUMBER
  );

FUNCTION F_FIND_OPTI( P_numindiv       IN      individu.NUMINDIV%TYPE,
                      P_date           IN      DATE DEFAULT SYSDATE)
RETURN NUMBER;

FUNCTION F_GETXMLBENEFICIAIRE(Tab_Indiv         IN     PK_CTRL_TP.TAB_T_Indiv,
                              loc_cpt           IN     NUMBER,
                              p_xmlns           IN     VARCHAR2,
                              loc_adresse       IN     VARCHAR2,
                              loc_cp            IN     VARCHAR2,
                              loc_ville         IN     VARCHAR2,
                              loc_contrat       IN     VARCHAR2,
                              loc_statut        IN     VARCHAR2,
                              loc_titre         IN     VARCHAR2,
                              loc_regime        IN     VARCHAR2,
                              loc_convention    IN     VARCHAR2,
                              loc_offreBene     IN     VARCHAR2,
                              loc_codeReponse   IN     VARCHAR2,
                              loc_messageErreur IN     VARCHAR2)
RETURN XMLTYPE;

FUNCTION F_GETXML_DETAIL_ACTE_CALCUL( loc_Tab_acte             IN OUT TAB_T_ACTE,
                                      i                        IN     NUMBER,
                                      loc_codeReponse          IN     VARCHAR2,
                                      loc_messageErreur        IN     VARCHAR2,
                                      loc_messageInformatif    IN     VARCHAR2,
                                      loc_statut               IN     VARCHAR2)
RETURN XMLTYPE;

PROCEDURE P_TRANSCO_CODFRAIS_OPTIQUE( P_numfor             ADHESION.NUMFOR%TYPE
                                 --   , P_flag_oeil          NUMBER    DEFAULT NULL
                                    , i                    NUMBER
                                    , P_Tab_acte           TAB_T_ACTE
                                    , P_t_verre            TAB_T_VERRE
                                    , P_t_lentille         TAB_T_LENTILLE
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2
                                    ,P_lpp                 VARCHAR2    --RKO Rac Optique
                                    );

PROCEDURE P_TRANSCO_CODFRAIS_DENTAIRE( P_numfor             ADHESION.NUMFOR%TYPE
                                     , i                    NUMBER
                                     , P_Tab_acte           TAB_T_ACTE
                                     , P_t_dentaire         TAB_T_DENTAIRE
                                     , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                     , O_acte_err_code      OUT VARCHAR2);

PROCEDURE P_TRANSCO_CODFRAIS_AUDITIF( P_numfor             ADHESION.NUMFOR%TYPE
                                    , i                    NUMBER
                                    , P_Tab_acte           TAB_T_ACTE
                                    , P_t_auditif          TAB_T_AUDITIF
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2
                                    , P_lpp                 VARCHAR2    --RKO Rac Audio
                                    );

PROCEDURE P_INSERT_INFOS_VERRES( P_numindiv    IN sinistre_sante.numindiv%TYPE
                               , P_codfrais    IN sinistre_sante.codfrais%TYPE
                               , P_numfor      IN ADHESION.NUMFOR%TYPE
                               , i             IN NUMBER
                          --     , P_Tab_acte    IN TAB_T_ACTE
                               , P_t_verre     IN TAB_T_VERRE
                               , P_num_dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE
                                ) ;

FUNCTION  F_FIND_INFOS_VERRES( P_numindiv    IN sinistre_sante.numindiv%TYPE
                             , P_codfrais    IN sinistre_sante.codfrais%TYPE
                             , P_numfor      IN ADHESION.NUMFOR%TYPE
                             , i             IN NUMBER
                        --     , P_Tab_acte    IN TAB_T_ACTE
                             , P_t_verre     IN TAB_T_VERRE
                             , P_num_dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE
                              )
RETURN NUMBER;

PROCEDURE P_envoi_Mail( P_ObjetMail       IN       VARCHAR2
                      , P_MessMail        IN       VARCHAR2);

PROCEDURE P_DENT (p_dentaire IN T_DENTAIRE,
                  p_domaine      IN NUMBER,
                  o_items        OUT PK_FICHIER.TV_ITEMS,
                  P_IO_TRAV_SAISIE IN OUT TRAV_SAISIE%ROWTYPE);


PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

END PK_ITELIS;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_ITELIS AS
/*============================================================================*/
/* PACKAGE      : PK_ITELIS.sql                                               */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 06/12/2016                                                  */
/* Description  : Gestion des flux XML du tiers payant optique/dentaire et    */
/*                auditif pour ITELIS(Service AXA)                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/


   -- -- Déclaration des variables globales   ----------------------------------
  g_session         journal_adm.id_session%TYPE DEFAULT 1;
  g_nom_traitement  journal_adm.nom_traitement%TYPE:='WS22T';
  g_niv_msg         journal_adm.niv_msg%TYPE;
  g_idligne         journal_adm.idligne%TYPE;
  g_msg_adm         journal_adm.msg_adm%TYPE;

  g_val_opti        NUMBER:=0;
  g_tabCond         PK_PORTE.TAB_Cond;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_BENEFICIAIRE                                            */
/* Type         :  Public                                                    */
/* Description  :  F_BENEFICIAIRE                                            */
/* Entree       :  P_Question IN XMLTYPE                                     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_BENEFICIAIRE (P_Question IN XMLTYPE)
RETURN XMLTYPE
IS

  buf                           VARCHAR2(2000);
  doc                           DBMS_XMLDOM.DOMDocument;
  loc_Reponse                   XMLTYPE;
  loc_Beneficiaire_temp         XMLTYPE;
  retour                        VARCHAR (3000);

  v_deb                         NUMBER;
  v_delai                       NUMBER;
  v_id_flux                     NUMBER:=NULL;
  v_cod_err                     NUMBER:=0;

  g_grpporte                    NUMBER(2) := 22; -- Porte ITELIS

  loc_Tab_Indiv                 PK_CTRL_TP.TAB_T_Indiv ; -- tableau d'individu (patient et assuré principal)
  loc_path_patient              VARCHAR2(100) := 'ns2:BeneficiairesRequest/assure';
  loc_path_bene                 VARCHAR2(100) := 'ns2:beneficiairesResponse/assure';
  loc_path_entete               VARCHAR2(100) := 'ns2:BeneficiairesRequest/enTete';

  loc_nb_individu               NUMBER:=NULL;
  loc_numassu                   individu.numassu%TYPE:=NULL;
  loc_famille_ok                NUMBER:=0;   -- Flag permettant de savoir si c'est un groupe familial ou une liste d homonymes
  loc_erreur                    NUMBER:=0;
  loc_contrat                   VARCHAR2(200):=NULL;
  loc_codeReponse               VARCHAR2(200):=NULL;
  loc_messageErreur             VARCHAR2(200):=NULL;
  loc_ErreurTechnique           VARCHAR2(200):=NULL;
  loc_messageInformatif         VARCHAR2(200):=NULL;
  loc_identifiantDossierAMC     VARCHAR2(50) :=NULL;
  loc_numeroDossierExperteo     VARCHAR2(50) :=NULL;
  loc_dateMessage               VARCHAR2(50) :=NULL;
  loc_nomClient                 VARCHAR2(20) :=NULL;
  loc_statut                    VARCHAR2(10)  :=NULL;
  loc_titre                     VARCHAR2(1)  :=NULL;
  loc_regime                    VARCHAR2(2)  :=NULL;
  loc_convention                VARCHAR2(30) :=NULL;
  loc_offreBene                 VARCHAR2(255):=NULL;


  loc_xmlns                     VARCHAR2(50) := 'xmlns:ns6="http://ws.jalma.com/stdclient"';
  loc_path_courant              VARCHAR2(200):= NULL;

  --adresse
  loc_ligne1  VARCHAR2(50);
  loc_ligne2  VARCHAR2(50);
  loc_ligne3  VARCHAR2(50);
  loc_ligne4  VARCHAR2(50);
  loc_ligne5  VARCHAR2(50);
  loc_adresse VARCHAR2(255);
  loc_cp      VARCHAR2(5); -- pers_adresse.codpos%TYPE;
  loc_ville   pers_adresse.ville%TYPE;
  loc_ss      INDIVIDU.MATORG%TYPE;


  loc_cpt     NUMBER:=0;
  -- exception
  exc_ayantDroit             EXCEPTION;
  exc_erreur_saisi           EXCEPTION;
  exc_assure_inconnu         EXCEPTION;
  exc_assure_ko              EXCEPTION;
  exc_assure_ko1             EXCEPTION;
  exc_tiers_inconnu          EXCEPTION;
  exc_ident_ko               EXCEPTION;
  exc_Refcontrat_ko          EXCEPTION;



  loc_idadhesion     adhe_cntrt.idadhesion%TYPE;
  loc_numgar         contrat_ref.numgar%TYPE;
  loc_isColl         BOOLEAN;
  loc_libelle        produit.libelle%TYPE;
  loc_dateEffet      adhe_cntrt.date_adhe%TYPE;
  loc_dateRes        adhe_cntrt.date_fin_adhe%TYPE;
  loc_numorg         contrat_ref.numorg%TYPE;
  loc_numporte       dossier_sante.numporte%TYPE;
  erreur_contrat     NUMBER :=0;
  loc_found          NUMBER;

  C_lstBene          PK_CTRL_TP.Fetch_adhe_membre%ROWTYPE;
  loc_isCouvert      BOOLEAN;
  loc_isTP           BOOLEAN;


BEGIN

  G_IDLIGNE := 0;
  P_INS_journal(1,v_id_flux|| ' F_BENEFICIAIRE DÉBUT', '');

  DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');

  -- Initialisation XML réponse
  v_deb:=DBMS_UTILITY.GET_TIME;
  pk_xml.new_xml;

  BEGIN
    -- Historisation du flux aller "Demande de prise en charge/ Calcul de reste à charge"
    v_id_flux := pk_ws.insert_flux(p_id_type       => 22,
                                   p_id_flux_tiers => PK_XML.EXTRACT_DATA(P_Question,'ns6:beneficiairesRequest',null,1),
                                   p_doc_xml       => P_Question,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );
    P_INS_journal(1,v_id_flux|| ' g_grpporte:'||g_grpporte, '');
    -- ***************************************************************************
    -- *************** RECUPERATION DES INFOS DE LA QUESTION**********************
    -- ***************************************************************************
    pk_xml.vg_xmlns := ' xmlns:ns2="http://schemas.xmlsoap.org/wsdl/" xmlns="http://ws.jalma.com/stdclient"';
    --assuré principal
    BEGIN
      -- permet de gérer une mauvaise saisie
    --  loc_Tab_Indiv('bene').numindiv := PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/numeroAyantDroit',null,1);
      loc_Tab_Indiv('bene').matorg := PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/numeroSecuriteSociale',null,1);
      loc_Tab_Indiv('bene').cless := PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/cleSecuriteSociale',null,1);
   --   loc_Tab_Indiv('bene').datnais := to_date(TO_CHAR(TO_TIMESTAMP(PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/dateNaissance',null,1), 'YYYY-MM-DD HH24:MI:SS.FF'),'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS');
      loc_Tab_Indiv('bene').nom := PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/nom',null,1);
      loc_Tab_Indiv('bene').prenom := PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/prenom',null,1);
      loc_Tab_Indiv('bene').rang := PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/rang',null,1);
     -- loc_contrat := PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/contrat',null,1);
      loc_identifiantDossierAMC := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/identifiantDossierAMC',null,1);
      loc_numeroDossierExperteo := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/numeroDossierExperteo',null,1);
      loc_dateMessage := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/dateMessage',null,1);
      loc_nomClient := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/nomClient',null,1);
      loc_ErreurTechnique:='false';
      loc_codeReponse:='true';
    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1,v_id_flux|| ' F_BENEFICIAIRE, recup info' || sqlerrm);
        loc_Tab_Indiv('bene').numindiv:=0;
        loc_messageErreur:='Saisie d''une information erronée de l entete ou bénéficiaire';
        loc_ErreurTechnique:='true';
        loc_codeReponse:='false';
        loc_numeroDossierExperteo:=NULL;
        loc_identifiantDossierAMC:=NULL;
        RAISE exc_erreur_saisi ;
    END;

    -- Vérif du format du numéro de l ayant droit  : pas de chaine de caractères
    BEGIN
      -- Ce test sert uniquement à mentionner au client qu'une chaine de caractère est saisie au lieu d un nombre
      loc_Tab_Indiv('bene').numindiv := PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/numeroAyantDroit',null,1);
    EXCEPTION
      WHEN OTHERS THEN
        loc_Tab_Indiv('bene').numindiv:=0;
        loc_messageErreur:='Format de la balise numeroAyantDroit non valide';
        loc_ErreurTechnique:='false';
        loc_codeReponse:='false';
        loc_numeroDossierExperteo:=NULL;
        loc_identifiantDossierAMC:=NULL;
        RAISE exc_ayantDroit;
    END;
    -- Vérif du format de la date de naissance de l ayant droit  : pas des heure 00:00
    BEGIN
      -- Ce test sert uniquement si la date de naissance contient des heure 00:00 ==> cela fait planter le traitement
      loc_Tab_Indiv('bene').datnais := to_date(substr(PK_XML.EXTRACT_DATA(P_Question,loc_path_patient||'/dateNaissance',null,1),0,10), 'YYYY-MM-DD');
    EXCEPTION
      WHEN OTHERS THEN
        loc_Tab_Indiv('bene').datnais:=NULL;
    END;

    P_INS_journal(1,v_id_flux|| ' loc_Tab_Indiv(''bene'').numindiv :'||to_char(loc_Tab_Indiv('bene').numindiv),'');
 /*   P_INS_journal(1,v_id_flux|| ' loc_Tab_Indiv(''bene'').matorg :'||to_char(loc_Tab_Indiv('bene').matorg),'');
    P_INS_journal(1,v_id_flux|| ' loc_Tab_Indiv(''bene'').cless :'||to_char(loc_Tab_Indiv('bene').cless),'');
    P_INS_journal(1,v_id_flux|| ' loc_Tab_Indiv(''bene'').datnais :'||to_char(loc_Tab_Indiv('bene').datnais),'');
    P_INS_journal(1,v_id_flux|| ' loc_Tab_Indiv(''bene'').nom :'||to_char(loc_Tab_Indiv('bene').nom),'');
    P_INS_journal(1,v_id_flux|| ' loc_Tab_Indiv(''bene'').prenom :'||to_char(loc_Tab_Indiv('bene').prenom),'');
    P_INS_journal(1,v_id_flux|| ' loc_Tab_Indiv(''bene'').rang :'||to_char(loc_Tab_Indiv('bene').rang),'');
    P_INS_journal(1,v_id_flux|| ' loc_contrat :'||loc_contrat,'');
    P_INS_journal(1,v_id_flux|| ' loc_identifiantDossierAMC :'||loc_identifiantDossierAMC,'');
    P_INS_journal(1,v_id_flux|| ' loc_numeroDossierExperteo :'||loc_numeroDossierExperteo,'');
    P_INS_journal(1,v_id_flux|| ' loc_dateMessage :'||loc_dateMessage,'');
    P_INS_journal(1,v_id_flux|| ' loc_nomClient :'||loc_nomClient,'');
     */

    -- ***************************************************************************
    -- *************** IDENTIFICATION DES BENEFICIAIRES **************************
    -- ***************************************************************************

    -- Identification de l'assuré figurant sur la carte de TP et du bénéficiaire retourne les identifiants et met à jour le tableau de détail
    P_FIND_ASSURE_BY_NOM( loc_Tab_Indiv('bene').nom
                        , loc_Tab_Indiv('bene').prenom
                        , loc_Tab_Indiv('bene').datnais
                        , loc_Tab_Indiv('bene').numindiv
                        , loc_Tab_Indiv('bene').rang
                        , loc_Tab_Indiv
                        , loc_Tab_Indiv('bene').matorg||loc_Tab_Indiv('bene').cless
                        , loc_nb_individu
                        , loc_numassu
                        , loc_erreur
                        );

    P_INS_journal(1,v_id_flux|| ' loc_numassu :'||loc_numassu,'');
    IF NVL(loc_numassu,0) = 0 THEN
      loc_erreur:=1;
    END IF;
    P_INS_journal(1,v_id_flux|| ' numindiv :'||loc_Tab_Indiv('bene').numindiv,'');
    P_INS_journal(1,v_id_flux|| ' numindiv2 :'||loc_Tab_Indiv(loc_nb_individu).numindiv,'');

    IF loc_erreur = 1 THEN
      loc_messageErreur:='impossible de trouver les bénéficiaires';
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      RAISE exc_assure_inconnu;
    ELSIF loc_erreur = 3 THEN
      loc_Tab_Indiv('bene').numindiv:=loc_Tab_Indiv(loc_nb_individu).numindiv;
    ELSE
      loc_ErreurTechnique:='false';
      loc_codeReponse:='true';
      loc_messageErreur:=NULL;
    END IF;

    -- ***************************************************************************
    -- *************** VERIFICATION DU DROIT AU SERVICE***************************
    -- ***************************************************************************

    PK_CTRL_TP.P_FIND_CONTRAT_BY_ASSU(
          loc_Tab_Indiv('bene').numindiv,
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

    P_INS_journal(1,v_id_flux|| ' erreur_contrat:'||erreur_contrat);
    P_INS_journal(1,v_id_flux|| ' loc_idadhesion:'||loc_idadhesion);
    P_INS_journal(1,v_id_flux|| ' loc_numgar:'||loc_numgar);

    IF erreur_contrat = 1 THEN
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'N°de contrat inconnu ou non couvert à la date des soins';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      RAISE exc_assure_ko;
    ELSIF erreur_contrat = 2 THEN
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'L''assuré ne bénéficie pas du service Itelis ';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      RAISE exc_tiers_inconnu;
    ELSIF erreur_contrat <> 0 THEN
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'Erreur inconnue';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      RAISE exc_assure_ko1;
    END IF;


    -- ***************************************************************************
    -- *************** VERIFICATION DE LA REFERENCE EXTERNE DU CONTRAT************
    -- ***************************************************************************
    -- Saisie d'un numero de contrat erroné
    IF loc_contrat IS NOT NULL THEN
      PK_CTRL_TP.P_FIND_REFCIE (
        loc_contrat,
        loc_numassu,
        g_grpporte,
        loc_idadhesion,
        loc_numassu,
        loc_numgar,
        loc_isColl,
        loc_libelle,
        loc_dateEffet,
        loc_dateRes,
        loc_numorg,
        loc_numporte,
        loc_found
        );

      IF  NVL(loc_found,0)> 0 THEN
        loc_ErreurTechnique:='false';
        loc_codeReponse:='false';
        loc_messageErreur := 'Saisie d''un numero de contrat erroné';
        loc_numeroDossierExperteo:=NULL;
        loc_identifiantDossierAMC:=NULL;
        RAISE exc_Refcontrat_ko;
      END IF;
    END IF;


  EXCEPTION
    WHEN exc_erreur_saisi THEN
      P_INS_journal(1,v_id_flux|| ' Saisie d''un numéro d''adhèrent erronée');
    WHEN exc_ayantDroit THEN
      P_INS_journal(1,v_id_flux|| ' Format de la balise <numeroAyantDroit> ou <dateNaissance> non valide');
    WHEN exc_assure_inconnu THEN
      P_INS_journal(1,v_id_flux|| ' impossible de trouver les bénéficiaires' );
    WHEN exc_assure_ko THEN
      P_INS_journal(1,v_id_flux|| ' N°de contrat inconnu ou non couvert à la date des soins' );
    WHEN exc_assure_ko1 THEN
      P_INS_journal(1,v_id_flux|| ' Erreur inconnue' );
    WHEN exc_tiers_inconnu THEN
      P_INS_journal(1,v_id_flux|| ' Porte non ouverte sur le contrat' );
    WHEN exc_Refcontrat_ko THEN
      P_INS_journal(1,v_id_flux|| ' Saisie d''un numero de contrat erroné' );
    WHEN OTHERS THEN
      P_INS_journal(1,v_id_flux|| ' F_BENEFICIAIRE;' || sqlerrm);
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_messageErreur := 'Erreur technique d''identification';
  END;

  BEGIN
    -- ***************************************************************************
    -- *************** Génération de l entete du XML réponse ***********************
    -- ***************************************************************************

    --loc_Reponse := pk_xml.get_xml('beneficiairesResponse','xmlns:  ="http://ws.jalma.com/stdclient"', false);
    loc_Reponse := XMLTYPE('<ns6:beneficiairesResponse xmlns:ns6="http://ws.jalma.com/stdclient"></ns6:beneficiairesResponse>');
    ------------------------CREATION DE L'ENTETE--------------------
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse,path=>'ns6:beneficiairesResponse',          children=>'ns6:enTete', xmlns=>loc_xmlns );
    loc_path_courant :='ns6:beneficiairesResponse/ns6:enTete';
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:dateMessage', child_val => loc_dateMessage);
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:nomClient', child_val=> loc_nomClient);
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:erreurTechnique', child_val=>loc_ErreurTechnique);
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:codeReponse', child_val=>loc_codeReponse);
    IF TRIM(loc_identifiantDossierAMC) IS NOT NULL THEN
      loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:identifiantDossierAMC', child_val=>loc_identifiantDossierAMC);
    END IF;
    IF TRIM(loc_messageErreur) IS NOT NULL THEN
      loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val=>loc_messageErreur);
    END IF;
    IF TRIM(loc_messageInformatif) IS NOT NULL THEN
      loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageInformatif', child_val=>loc_messageInformatif);
    END IF;
    IF TRIM(loc_numeroDossierExperteo) IS NOT NULL AND loc_numeroDossierExperteo NOT IN ('null') THEN
      loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:numeroDossierExperteo', child_val=>loc_numeroDossierExperteo);
    END IF;
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:versionWSDL', child_val=>'0');
    IF loc_codeReponse = 'false' THEN
      loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse,path=>'ns6:beneficiairesResponse', children=>'ns6:beneficiaires', xmlns=>loc_xmlns);
      RAISE exc_ident_ko;
    END IF;


    -- ***************************************************************************
    -- *************** IDENTIFICATION ADRESSES,REGIME DES BENEFICIAIRES **********
    -- ***************************************************************************
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse,path=>'ns6:beneficiairesResponse', children=>'ns6:beneficiaires', xmlns=>loc_xmlns);
    loc_path_courant :='ns6:beneficiairesResponse/ns6:beneficiaires';
    P_INS_journal(1,v_id_flux|| '  loc_nb_individu:'||loc_nb_individu );
    FOR i IN 1..loc_nb_individu LOOP
    P_INS_journal(1,v_id_flux|| '  loc_nb_individu 2 :'||loc_nb_individu );
      loc_cpt:=loc_cpt+1;
      --SDA réinitialisation des variables loc_messageErreur et loc_codeReponse a null
      loc_messageErreur := null;
      loc_codeReponse := 'true';

      FOR C_lstBene IN  PK_CTRL_TP.Fetch_adhe_membre(loc_idadhesion, loc_Tab_Indiv(loc_cpt).numindiv) LOOP
    P_INS_journal(1,v_id_flux|| '  FOR C_lstBene IN:'||loc_nb_individu );
        -- ***************************************************************************
        -- * Bénéficiaire : Contrôles
        -- ***************************************************************************
        --Contrôle des droits des bénéficaires
        loc_isCouvert := PK_CTRL_TP.F_CTRL_couverture(C_lstBene.numindiv,1,'C',sysdate);
        IF loc_isCouvert = FALSE THEN
          loc_messageErreur:='Pas de remboursement possible : Le patient n''est plus couvert par le contrat';
          loc_codeReponse:='false';
        END IF;
        --Contrôle du rang du bénéficiaire
        loc_isTP := PK_CTRL_TP.F_CTRL_rang(C_lstBene.numindiv,loc_idadhesion,1,'C',sysdate);
        IF loc_isTP = FALSE THEN
          loc_messageErreur:='Ce beneficiaire n''a pas droit au service';
          loc_codeReponse:='false';
        END IF;
        P_INS_journal(1,v_id_flux|| '  C_lstBene.typadr:'||C_lstBene.typadr );

        loc_statut:= F_GET_TRANSCO ('ITELIS','STATUT',C_lstBene.typadr);
        P_INS_journal(1,v_id_flux|| '  loc_statut:'||loc_statut );
        P_INS_journal(1,v_id_flux|| '  C_lstBene.qualite:'||C_lstBene.qualite );
        loc_titre:=C_lstBene.qualite;
        P_INS_journal(1,v_id_flux|| '  loc_titre:'||loc_titre );
        loc_regime:=F_GET_TRANSCO ('ITELIS','REGIME',C_lstBene.regime);
      END LOOP;

      -- recherche de l adresse
      PK_CTRL_TP.P_ADR_FORMAT( loc_Tab_Indiv('bene').numindiv,
                               loc_ligne1,
                               loc_ligne2,
                               loc_ligne3 ,
                               loc_ligne4,
                               loc_ligne5,
                               loc_cp ,
                               loc_ville);
      loc_adresse:=TRIM(loc_ligne1)||'-'||TRIM(loc_ligne2)||'-'||TRIM(loc_ligne3)||'-'||TRIM(loc_ligne4)||'-'||TRIM(loc_ligne5);


      -- Recherche de la mention OPTI de la carte TPE sur le bénéficiaire
      loc_offreBene:= F_FIND_OPTI(loc_Tab_Indiv(loc_cpt).numindiv,SYSDATE);
      IF NVL(loc_offreBene,0) > 0 THEN
        g_val_opti:=loc_offreBene;
      END IF;
      P_INS_journal(1,v_id_flux|| '  loc_offreBene:'||loc_offreBene );
      IF loc_Tab_Indiv(loc_cpt).matorg IS NULL  THEN
        loc_messageErreur:='Information du numéro de sécurité sociale absente';
        loc_codeReponse:='false';
      ELSIF loc_Tab_Indiv(loc_cpt).cless IS NULL THEN
          loc_ss := Replace (loc_Tab_Indiv(loc_cpt).matorg, '2A', '19');
          loc_ss:= Replace(loc_Tab_Indiv(loc_cpt).matorg, '2B', '18');
          loc_Tab_Indiv(loc_cpt).cless := 97- mod( to_number(loc_ss), 97);
      END IF;
    -- ***************************************************************************
    -- * Génération du corps du XML réponse
    -- ***************************************************************************
      loc_Beneficiaire_temp := F_GETXMLBENEFICIAIRE( loc_Tab_Indiv
                                                   , loc_cpt
                                                   , loc_xmlns
                                                   , loc_adresse
                                                   , loc_cp
                                                   , loc_ville
                                                   , loc_contrat
                                                   , loc_statut
                                                   , loc_titre
                                                   , loc_regime
                                                   , loc_convention
                                                   , loc_offreBene
                                                   , loc_codeReponse
                                                   , loc_messageErreur);

      Loc_Reponse := pk_xml.APPENDCHILDXML(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant,  children=>'ns6:beneficiaire', child_val => loc_Beneficiaire_temp);
    END LOOP;
  EXCEPTION
    WHEN exc_ident_ko THEN
      P_INS_journal(1,v_id_flux|| ' exc_ident_ko;');
    WHEN OTHERS THEN
      P_INS_journal(1,v_id_flux|| ' F_BENEFICIAIRE;' || sqlerrm);
  END;

  -- Historisation de la réponse du flux "Demande de prise en charge/ Calcul de reste à charge" (type 6)
  pk_ws.add_xml(p_id_type => 23,
                p_id_flux => v_id_flux,
                p_doc_xml => loc_Reponse,
                p_cod_err => v_cod_err);


  -- MAJ statut du flux OK
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  P_INS_journal(1,v_id_flux|| '  Fin normale de la procédure F_BENEFICIAIRE');
  -- Envoi du XML réponse
  --return null;
  RETURN loc_Reponse;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_INS_journal(1,v_id_flux|| ' F_BENEFICIAIRE;' || sqlerrm);
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
    pk_ws.maj_statut(v_id_flux, 6,sqlerrm,v_delai);   -- statut à 6 si une erreur technique est survenue
    RETURN loc_Reponse;
END F_BENEFICIAIRE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_GETXMLBENEFICIAIRE                                      */
/* Type         :  Public                                                    */
/* Description  :  F_GETXMLBENEFICIAIRE                                      */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_GETXMLBENEFICIAIRE(Tab_Indiv         IN     PK_CTRL_TP.TAB_T_Indiv,
                              loc_cpt           IN     NUMBER,
                              p_xmlns           IN     VARCHAR2,
                              loc_adresse       IN     VARCHAR2,
                              loc_cp            IN     VARCHAR2,
                              loc_ville         IN     VARCHAR2,
                              loc_contrat       IN     VARCHAR2,
                              loc_statut        IN     VARCHAR2,
                              loc_titre         IN     VARCHAR2,
                              loc_regime        IN     VARCHAR2,
                              loc_convention    IN     VARCHAR2,
                              loc_offreBene     IN     VARCHAR2,
                              loc_codeReponse   IN     VARCHAR2,
                              loc_messageErreur IN     VARCHAR2)
RETURN XMLTYPE
IS
  loc_retour           XMLTYPE;
  loc_path_courant     VARCHAR2(200);
 /* loc_datenaiss_a      VARCHAR2(4);
  loc_datenaiss_m      VARCHAR2(2);
  loc_datenaiss_j      VARCHAR2(2);
  loc_datenaiss        VARCHAR2(10);*/
  loc_flag_opti        NUMBER:=0;
  loc_val_opti         NUMBER:=0;

BEGIN
   P_INS_journal(1,'DANS F_GETXMLBENEFICIAIRE;' );
  loc_path_courant := 'ns6:beneficiaire';
  -- creation l'itération sur sur bénéficiaire
  loc_retour :=  XMLTYPE('<ns6:beneficiaire xmlns:ns6="http://ws.jalma.com/stdclient"></ns6:beneficiaire>');
  -- reseignement des informations dans l'objet XML beneficiaire
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:numeroSecuriteSociale', child_val => to_char(Tab_Indiv(loc_cpt).matorg));

  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:cleSecuriteSociale', child_val =>TRIM(to_char(Tab_Indiv(loc_cpt).cless,'09')));
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:numeroAyantDroit', child_val=>to_char(Tab_Indiv(loc_cpt).numindiv));
  IF loc_statut IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:statut', child_val=>loc_statut);
  END IF;
  IF loc_titre IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:titre', child_val=>loc_titre);
  END IF;
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:nom', child_val=>to_char(Tab_Indiv(loc_cpt).nom));
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:prenom', child_val=>to_char(Tab_Indiv(loc_cpt).prenom));
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:dateNaissance', child_val=> to_char(Tab_Indiv(loc_cpt).datnais,'YYYY-MM-DD'));
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:rang', child_val=>to_char(Tab_Indiv(loc_cpt).rang));
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:adresse', child_val=>loc_adresse);
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:codePostal', child_val=>to_char(loc_cp));
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:ville', child_val=>to_char(loc_ville));

  IF TRIM(loc_contrat) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:contrat',  child_val=>loc_contrat);
  END IF;
  IF TRIM(loc_convention) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:offreConvention');
  END IF;
  IF NVL(g_val_opti,0) > 0 THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:offreBeneficiaire', child_val=>'OPTI'||g_val_opti); --, child_val=>'0');
  END IF;
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:codeReponse', child_val=>loc_codeReponse);
  IF (loc_messageErreur IS NOT NULL ) THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val=>loc_messageErreur);
  ELSE
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>p_xmlns, path=>loc_path_courant, children=>'ns6:messageInformatif', child_val=>'Assuré trouvé');
  END IF;
   RETURN loc_retour;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'F_GETXMLBENEFICIAIRE;' || sqlerrm);

END F_GETXMLBENEFICIAIRE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_FIND_ASSURE_BY_NOM                                      */
/* Type         :  Privee                                                    */
/* Description  :  Constitution de l'entete de la reponse du flux XML        */
/* Entree       :  P_codeRetour, Code erreur ou non                          */
/*---------------------------------------------------------------------------*/
PROCEDURE P_FIND_ASSURE_BY_NOM(  P_nom            IN      individu.nom%TYPE default null
                                ,P_prenom         IN      individu.prenom%TYPE default null
                                ,P_datenais       IN      individu.DATNAIS%TYPE
                                ,P_numindiv       IN      individu.NUMINDIV%TYPE
                                ,P_rang           IN      individu.RANG%TYPE
                                ,IO_Tab_indiv     IN  OUT PK_CTRL_TP.TAB_T_Indiv
                                ,P_matorg         IN      VARCHAR2
                                ,IO_cpt               OUT NUMBER
                                ,O_numassu            OUT individu.numassu%TYPE
                                ,O_erreur             OUT NUMBER
                                )
IS

   CURSOR C_Assu IS
       /*SELECT ayd.numindiv numass,
            ayd.datnais datass,
            ayd.rang rgass,
            ayd.nom nomass,
            ayd.prenom prenomass,
            ayd.matorg matass,
            ayd.cless cleass,
            ayd.numassu,
            ayd.qualite qualite
       FROM individu ayd
      WHERE ayd.numassu=P_numindiv
      AND ayd.numindiv IN (SELECT numindiv FROM ADHE_CNTRT_MEMBRE)
  ORDER BY ayd.numindiv;*/
  SELECT ayd.numindiv numass,
            ayd.datnais datass,
            ayd.rang rgass,
            ayd.nom nomass,
            ayd.prenom prenomass,
            ayd.matorg matass,
            ayd.cless cleass,
            ayd.numassu,
            ayd.qualite qualite
       FROM individu ayd , individu od
      WHERE od.numindiv=P_numindiv
      AND ayd.numassu = od.numassu
      AND od.matorg IS NOT NULL
      AND ((ayd.matorg = od.matorg AND ayd.matorg IS NOT NULL)
          OR (ayd.matorg2 = od.matorg AND ayd.matorg2 IS NOT NULL))
      AND ayd.numindiv IN (SELECT numindiv FROM ADHE_CNTRT_MEMBRE)
  ORDER BY ayd.numindiv;

   CURSOR C_Assu1(V_NOM IN INDIVIDU.NOM%TYPE,
                 V_PRENOM IN individu.prenom%TYPE
                 ) IS
     SELECT ayd.numindiv numass,
            ayd.datnais datass,
            ayd.rang rgass,
            ayd.nom nomass,
            ayd.prenom prenomass,
            ayd.matorg matass,
            ayd.cless cleass,
            ayd.numassu,
            ayd.qualite qualite
       FROM individu od, individu ayd
      WHERE od.numindiv = NVL(P_numindiv,od.numindiv)
       AND (
             (        ayd.matorg = NVL(substr(P_matorg,0,13),ayd.matorg)
                  AND ayd.cless  = NVL(substr(P_matorg,14),ayd.cless))
           OR
             (       ayd.matorg2 = NVL(substr(P_matorg,0,13),ayd.matorg2)
                 AND ayd.cless2 = NVL(substr(P_matorg,14),ayd.cless2))
           )
       AND (
             (ayd.matorg=od.matorg  AND ayd.cless=od.cless)
             OR
             ( ayd.matorg2=od.matorg AND ayd.cless2=od.cless)
            )
       AND od.natur=1
       AND ayd.nom like UPPER(NVL(TRIM(V_NOM||'%'),ayd.nom))
       AND ayd.prenom like UPPER(NVL(TRIM(V_PRENOM||'%'),ayd.prenom))
       AND ayd.datnais = nvl (e2d(P_datenais) , ayd.datnais )
       AND ayd.numindiv IN (SELECT numindiv FROM ADHE_CNTRT_MEMBRE)
  ORDER BY ayd.numindiv;

   CURSOR C_Assu2(V_NOM IN INDIVIDU.NOM%TYPE,
                  V_PRENOM IN individu.prenom%TYPE
                 ) IS
       SELECT ayd.numindiv numass,
            ayd.datnais datass,
            ayd.rang rgass,
            ayd.nom nomass,
            ayd.prenom prenomass,
            ayd.matorg matass,
            ayd.cless cleass,
            ayd.numassu,
            ayd.qualite qualite
       FROM individu ayd
      WHERE /*ayd.numassu=P_numindiv
       AND*/ ayd.nom like UPPER(TRIM(V_NOM||'%'))
       AND ayd.prenom like UPPER(NVL(TRIM(V_PRENOM||'%'),ayd.prenom))
       AND ayd.datnais = nvl (e2d(P_datenais) , ayd.datnais )
       AND (
             (        ayd.matorg = NVL(substr(P_matorg,0,13),ayd.matorg)
                  AND ayd.cless  = NVL(substr(P_matorg,14),ayd.cless))
           OR
             (       ayd.matorg2 = NVL(substr(P_matorg,0,13),ayd.matorg2)
                 AND ayd.cless2 = NVL(substr(P_matorg,14),ayd.cless2))
           )
       AND ayd.rang = NVL(P_rang,ayd.rang)
       AND ayd.numindiv IN (SELECT numindiv FROM ADHE_CNTRT_MEMBRE)
  ORDER BY ayd.numindiv;

  Rec_C_Assu        C_Assu%ROWTYPE;
  Rec_C_Assu1       C_Assu1%ROWTYPE;
  Rec_C_Assu2       C_Assu2%ROWTYPE;
  cpt_tab           NUMBER;
  cpt               NUMBER;
  V_NOM             individu.nom%TYPE;
  V_PRENOM          individu.prenom%TYPE;
  V_etat            NUMBER:=0;
  loc_found         NUMBER:=0;

BEGIN

  cpt_tab := 0;
  O_erreur:=0;
  IO_Tab_indiv(cpt_tab).numindiv:= 0;

  V_NOM := replace(P_nom,'*','%');
  V_PRENOM := replace(P_prenom,'*','%');


  P_INS_journal(1,'V_NOM:' || V_NOM);
  P_INS_journal(1,'V_PRENOM:' || V_PRENOM);
  P_INS_journal(1,'P_numindiv:' || P_numindiv);
  P_INS_journal(1,'P_datenais:' || P_datenais);

  IF P_numindiv IS NOT NULL THEN

    OPEN C_Assu;
    LOOP
      FETCH C_Assu INTO Rec_C_Assu;
      EXIT WHEN C_Assu%NOTFOUND;
      cpt_tab := cpt_tab + 1;
      IO_Tab_indiv(cpt_tab).numindiv := Rec_C_Assu.numass;
      IO_Tab_indiv(cpt_tab).nom := Rec_C_Assu.nomass;
      IO_Tab_indiv(cpt_tab).prenom := Rec_C_Assu.prenomass;
      IO_Tab_indiv(cpt_tab).datnais := Rec_C_Assu.datass;
      IO_Tab_indiv(cpt_tab).rang := Rec_C_Assu.rgass;
      IO_Tab_indiv(cpt_tab).matorg := Rec_C_Assu.matass;
      IO_Tab_indiv(cpt_tab).cless := Rec_C_Assu.cleass;
      O_numassu:= Rec_C_Assu.numassu;
    END LOOP;
    IF C_Assu%ISOPEN THEN
       CLOSE C_Assu;
    END IF;
  END IF;
  P_INS_journal(1,'IO_Tab_indiv(cpt_tab).numindiv 1 :' || IO_Tab_indiv(cpt_tab).numindiv);
  IF NVL(IO_Tab_indiv(cpt_tab).numindiv,0)=0 THEN

    OPEN C_Assu1(V_NOM,V_PRENOM);
    LOOP
      FETCH C_Assu1 INTO Rec_C_Assu1;
      EXIT WHEN C_Assu1%NOTFOUND;
      cpt_tab := cpt_tab + 1;

      IO_Tab_indiv(cpt_tab).numindiv := Rec_C_Assu1.numass;
      IO_Tab_indiv(cpt_tab).nom := Rec_C_Assu1.nomass;
      IO_Tab_indiv(cpt_tab).prenom := Rec_C_Assu1.prenomass;
      IO_Tab_indiv(cpt_tab).datnais := Rec_C_Assu1.datass;
      IO_Tab_indiv(cpt_tab).rang := Rec_C_Assu1.rgass;
      IO_Tab_indiv(cpt_tab).matorg := Rec_C_Assu1.matass;
      IO_Tab_indiv(cpt_tab).cless := Rec_C_Assu1.cleass;
      O_numassu:= Rec_C_Assu1.numassu;
      P_INS_journal(1,'O_numassu:' || O_numassu);
      O_erreur:=3;     -- mauvais numéro d ayant droit en entrée
    END LOOP;
    IF C_Assu1%ISOPEN THEN
       CLOSE C_Assu1;
    END IF;
  END IF;
  P_INS_journal(1,'IO_Tab_indiv(cpt_tab).numindiv 2 :' || IO_Tab_indiv(cpt_tab).numindiv);
  IF NVL(IO_Tab_indiv(cpt_tab).numindiv,0)=0 THEN

    OPEN C_Assu2(V_NOM,V_PRENOM);
    LOOP
      FETCH C_Assu2 INTO Rec_C_Assu2;
      EXIT WHEN C_Assu2%NOTFOUND;
      cpt_tab := cpt_tab + 1;

      IO_Tab_indiv(cpt_tab).numindiv := Rec_C_Assu2.numass;
      IO_Tab_indiv(cpt_tab).nom := Rec_C_Assu2.nomass;
      IO_Tab_indiv(cpt_tab).prenom := Rec_C_Assu2.prenomass;
      IO_Tab_indiv(cpt_tab).datnais := Rec_C_Assu2.datass;
      IO_Tab_indiv(cpt_tab).rang := Rec_C_Assu2.rgass;
      IO_Tab_indiv(cpt_tab).matorg := Rec_C_Assu2.matass;
      IO_Tab_indiv(cpt_tab).cless := Rec_C_Assu2.cleass;
      O_numassu:= Rec_C_Assu2.numassu;

    END LOOP;
    IF C_Assu2%ISOPEN THEN
       CLOSE C_Assu2;
    END IF;
  END IF;

  IO_cpt := cpt_tab;
  P_INS_journal(1,'P_FIND_ASSURE_BY_NOM OK!');
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'P_FIND_ASSURE_BY_NOM:' || sqlerrm);
    O_erreur:=1;   -- impossible de trouver les bénéficiaires
END P_FIND_ASSURE_BY_NOM;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_OPTI                                               */
/* Type         :  Public                                                    */
/* Description  :  F_FIND_OPTI                                               */
/* Entree       :  P_numindiv, P_date                                        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_OPTI( P_numindiv       IN      individu.NUMINDIV%TYPE,
                      P_date           IN      DATE DEFAULT SYSDATE)
RETURN NUMBER
IS

  loc_OPTI       NUMBER:=0;

BEGIN
  P_INS_journal(1,'F_FIND_OPTI  P_numindiv:'||P_numindiv);
  P_INS_journal(1,'F_FIND_OPTI  P_date:'||to_char(P_date));

  SELECT MAX(F_VAL_VAR_ALL(numfor,F_FIND_VAR('LOGO_OPTI'),P_date))
    INTO loc_OPTI
    FROM adhesion
   WHERE  numindiv = P_numindiv
     AND P_date BETWEEN datapli AND NVL(datper,P_date)
     AND (F_VAL_VAR_ALL(numfor,F_FIND_VAR('LOGO_OPTI'),P_date)) IS NOT NULL;

  P_INS_journal(1,'F_FIND_OPTI OK!, loc_OPTI:'||loc_OPTI);
  RETURN loc_OPTI;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'F_FIND_OPTI:' || sqlerrm);
    RETURN 0;   -- impossible de trouver la notion d OPTI
END F_FIND_OPTI;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_CALCULRC                                                */
/* Type         :  Public                                                    */
/* Description  :  F_CALCULRC                                                */
/* Entree       :  P_Question IN XMLTYPE                                     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CALCULRC (P_Question IN XMLTYPE)
RETURN XMLTYPE
IS
  xmlretour                      XMLTYPE;
  retour                         VARCHAR2(3000);
  loc_xmlns                      VARCHAR2(50);
  loc_path_courant               VARCHAR2(50);
  loc_Reponse                    XMLTYPE;
  loc_detail_acte                XMLTYPE;
  v_cod_err                      NUMBER:=0;
  g_grpporte                     NUMBER(2) := 22;   -- Porte ITELIS
  v_id_flux                      NUMBER:=NULL;
  loc_path_entete                VARCHAR2(100) :='ns2:CalculRCRequest/enTete';
  loc_path_dossier               VARCHAR2(100) :='ns2:CalculRCRequest/dossier';
  loc_path_beneficiaire          VARCHAR2(100) :='ns2:CalculRCRequest/beneficiaire';
  loc_path_practicien            VARCHAR2(100) :='ns2:CalculRCRequest/praticien';
  loc_path_prestation            VARCHAR2(100) :='ns2:CalculRCRequest/prestation';
  loc_path_detailActes           VARCHAR2(100) :='ns2:CalculRCRequest/detailActes';

  v_deb                          NUMBER;
  v_delai                        NUMBER;

  -- entete
  loc_dateMessage                VARCHAR2(50):=NULL;
  loc_nomClient                  VARCHAR2(20):=NULL;
  loc_nomUtilisateur             VARCHAR2(25):=NULL;
  loc_motDePasse                 VARCHAR2(25):=NULL;
  loc_origine                    VARCHAR2(2):=NULL;
  loc_identifiantDossierAMC      VARCHAR2(50) :=NULL;
  loc_numeroDossierExperteo      VARCHAR2(50) :=NULL;
  loc_codeReponse                VARCHAR2(200):=NULL;
  loc_messageErreur              VARCHAR2(200):=NULL;
  loc_messageErreur1             VARCHAR2(200):=NULL;
  loc_ErreurTechnique            VARCHAR2(200):=NULL;
  loc_messageInformatif          VARCHAR2(200):=NULL;
  -- dossier
  loc_domaine                    VARCHAR2(2):=NULL;   -- 0 = Optique, 1 = dentaire, 2 = audioprothèse
  loc_type                       VARCHAR2(1):=NULL;   -- 0 = Devis, 1 = PEC
  loc_statut                     VARCHAR2(10):=NULL;
  loc_nat_dossier                NUMBER(1):=NULL;
  loc_num_dossier                DOSSIER_SANTE.NUM_DOSSIER%TYPE:=0;
  loc_refDomaine                 VARCHAR2(20);
  loc_sens                       NUMBER:=0;
  loc_erreur_dossier             NUMBER:=0;
  loc_msg_dossier                VARCHAR2(200);
  -- beneficiaire
  loc_Tab_Indiv                  PK_CTRL_TP.TAB_T_Indiv ; -- tableau d'individu (patient et assuré principal)
  loc_tauxRemboursement          VARCHAR2(3)  :=NULL;
  -- practicien
  loc_domaine_p                  VARCHAR2(2):=NULL;
  loc_numeroFiness               VARCHAR2(9):=NULL;
  loc_specialite                 VARCHAR2(2):=NULL;
  loc_raisonSociale              VARCHAR2(50):=NULL;
  loc_adresse_p                  VARCHAR2(50):=NULL;
  loc_codePostal_p               VARCHAR2(5):=NULL;
  loc_ville_p                    VARCHAR2(50):=NULL;
  loc_numindivPS                 NUMBER(9):=NULL;


  -- prestation
  loc_nombreActes                VARCHAR2(2):=NULL;
  loc_totalDepense               VARCHAR2(10):=NULL;
  loc_totalRemboursementSS       VARCHAR2(10):=NULL;
  loc_totalRC                    VARCHAR2(10):=NULL;
  loc_totalRAC                   VARCHAR2(10):=NULL;

  loc_montant_dep                SINISTRE_SANTE.MTFRAIS%TYPE:=NULL;
  loc_montant_rc                 SINISTRE_SANTE.MTPREST_REEL%TYPE:=NULL;
  loc_montant_ro                 SINISTRE_SANTE.MTREMB%TYPE:=NULL;
  --reste a charge = MT_FRAIS- RC - RO - AR
  loc_montant_rac                SINISTRE_SANTE.MTFRAIS%TYPE:=NULL;
  loc_montant_autre              SINISTRE_SANTE.AUTRB_DAUTRB%TYPE:=NULL;
  loc_quantite                   SINISTRE_SANTE.QUANTITE%TYPE:=NULL;

  --montant des suppléments verre ou monture
  loc_depense_sup                SINISTRE_SANTE.MTFRAIS%TYPE:=NULL;
  loc_rc_sup                     SINISTRE_SANTE.MTPREST_REEL%TYPE:=NULL;
  loc_ro_sup                     SINISTRE_SANTE.MTREMB%TYPE:=NULL;
  loc_mt_sup                     NUMBER:=0;
  --loc_flag_supplement            BOOLEAN:=FALSE;
  -- detailActes
  loc_codfraisITELIS             VARCHAR2(24);
  loc_Tab_acte                   TAB_T_ACTE;

  -- patient
  loc_numassu                    INDIVIDU.NUMASSU%TYPE:=NULL;
  loc_nb_individu                NUMBER:=NULL;
  loc_erreur                     NUMBER:=0;
  loc_contrat                    VARCHAR2(200):=NULL;
  loc_idadhesion                 ADHE_CNTRT.IDADHESION%TYPE;
  loc_numgar                     CONTRAT_REF.NUMGAR%TYPE;
  loc_isColl                     BOOLEAN;
  loc_libelle                    PRODUIT.LIBELLE%TYPE;
  loc_dateEffet                  ADHE_CNTRT.DATE_ADHE%TYPE;
  loc_dateRes                    ADHE_CNTRT.DATE_FIN_ADHE%TYPE;
  loc_numorg                     CONTRAT_REF.NUMORG%TYPE;
  loc_numporte                   DOSSIER_SANTE.NUMPORTE%TYPE;
  erreur_contrat                 NUMBER :=0;
  loc_found                      NUMBER;
  loc_isCouvert                  BOOLEAN;
  loc_isTP                       BOOLEAN;
  loc_numfor                     ADHESION.NUMFOR%TYPE:=NULL;
  loc_codfrais                   SINISTRE_SANTE.CODFRAIS%TYPE:=NULL;
  loc_acte_err_code              VARCHAR2(2):=NULL;
  loc_acteCouvert                BOOLEAN;
  C_lstGar                       PK_CTRL_TP.Fetch_garanties_adhe%ROWTYPE;
  erreur_acte                    NUMBER;
  loc_mtprest                    NUMBER:=0;
  loc_mtprest_Char               VARCHAR2(10);
  erreur_calcul_devis            NUMBER;
  O_msg_erreur_devis             VARCHAR2(500);

    -- exception
  exc_erreur_saisi               EXCEPTION;
  exc_assure_inconnu             EXCEPTION;
  exc_assure_ko                  EXCEPTION;
  exc_assure_ko1                 EXCEPTION;
  exc_tiers_inconnu              EXCEPTION;
  exc_ident_ko                   EXCEPTION;
  exc_Refcontrat_ko              EXCEPTION;
  exc_adhe_invalide              EXCEPTION;
  exc_acte                       EXCEPTION;
  exc_carte_tp                   EXCEPTION;
  exc_TP_ferme                   EXCEPTION;
  exc_garantie_inconnue          EXCEPTION;
  exc_dossier                    EXCEPTION;
  exc_prestation_ko              EXCEPTION;
  exc_devis_en_attente           EXCEPTION;

  -- compteur
  i                              NUMBER :=0; -- Compteur des prestations optiques du flux
  cpt                            NUMBER :=0;

  loc_cpt                        NUMBER :=0;
  loc_attente                    NUMBER :=0;     -- afin de mettre en attente des douvle vision ou un changement de dioptrie
  loc_dioptrie                   NUMBER :=0;



  -- type
  loc_t_verre                    TAB_T_VERRE;
  loc_t_monture                  TAB_T_MONTURE;
  loc_t_lentille                 TAB_T_LENTILLE;
  loc_t_auditif                  TAB_T_AUDITIF;
  loc_t_dentaire                 TAB_T_DENTAIRE;
  loc_t_equip                    TAB_T_EQUIP; --RKO WS RAC DEROG
  loc_res_derog                  pk_funct.DerogOptique_T;

  -- record
  P_TRAV_SAISIE                  TRAV_SAISIE%ROWTYPE;     -- necessaire à l'enregistrement des localisation dentaires de chaque dents et du réseau de soins
  loc_o_items                    PK_FICHIER.TV_ITEMS;    -- Tableau permettant de récupérer les numéros de dents
  loc_trav                       TRAV_SAISIE%ROWTYPE;
  loc_verre_droit                sinistre_verre%ROWTYPE;
  loc_verre_gauche               sinistre_verre%ROWTYPE;
  l_sid                          NUMBER(8);

  loc_objet_email                VARCHAR2(100):=NULL;
  loc_mess_email                 VARCHAR2(150):=NULL;
  loc_doublon_dent               NUMBER;
  loc_blocage                    NUMBER;

  cpt_trav                      NUMBER;
  k                             NUMBER :=0; --compteur des équipements (verre+monture)
  l_derog                       VARCHAR2(10);

BEGIN
  G_IDLIGNE := 0;
  loc_quantite :=1;
  P_INS_journal(1,v_id_flux|| ' F_CALCULRC DÉBUT', '');
  DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');
  v_deb:=DBMS_UTILITY.GET_TIME;
  loc_xmlns :=' xmlns:ns6="http://ws.jalma.com/stdclient"';
  -- ***************************************************************************
  -- *************** Historisation de la question         **********************
  -- ***************************************************************************
  pk_xml.vg_xmlns := ' xmlns:ns2="http://schemas.xmlsoap.org/wsdl/" xmlns="http://ws.jalma.com/stdclient"';
  v_id_flux := pk_ws.insert_flux(p_id_type       => 24,
                                 p_id_flux_tiers => PK_XML.EXTRACT_DATA(P_Question,'ns2:CalculRCRequest',null,1),
                                 p_doc_xml       => P_Question,
                                 p_cod_err       => v_cod_err,
                                 p_porte         => g_grpporte );
  --récupération du l_sid
  SELECT TO_CHAR(SYS_CONTEXT('USERENV', 'SID')) INTO l_sid FROM DUAL;
  BEGIN
  -- *****************************************************************************
  -- ** RECUPERATION DES INFOS DE L ENTETE, DOSSIER, BENEFICIAIRE DE LA QUESTION**
  -- *****************************************************************************
  -- permet de gérer une mauvaise saisie
  BEGIN
    -- entete
    loc_dateMessage:=PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/dateMessage',null,1);
    loc_nomClient:=PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/nomClient',null,1);
    loc_nomUtilisateur:=PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/nomUtilisateur',null,1);
    loc_motDePasse:=PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/motDePasse',null,1);
    loc_origine:=PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/origine',null,1);
    loc_identifiantDossierAMC:=PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/identifiantDossierAMC',null,1);
    loc_numeroDossierExperteo:=PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/numeroDossierExperteo',null,1);

    -- dossier
    loc_domaine:=PK_XML.EXTRACT_DATA(P_Question,loc_path_dossier||'/domaine',null,1);
    loc_type:=PK_XML.EXTRACT_DATA(P_Question,loc_path_dossier||'/type',null,1);
    loc_statut:=PK_XML.EXTRACT_DATA(P_Question,loc_path_dossier||'/statut',null,1);
    -- beneficiaire
    loc_Tab_Indiv('bene').numindiv := PK_XML.EXTRACT_DATA(P_Question,loc_path_beneficiaire||'/numeroAyantDroit',null,1);
    loc_Tab_Indiv('bene').matorg := PK_XML.EXTRACT_DATA(P_Question,loc_path_beneficiaire||'/numeroSecuriteSociale',null,1);
    loc_Tab_Indiv('bene').cless := PK_XML.EXTRACT_DATA(P_Question,loc_path_beneficiaire||'/cleSecuriteSociale',null,1);
    loc_Tab_Indiv('bene').datnais := to_date(substr(PK_XML.EXTRACT_DATA(P_Question,loc_path_beneficiaire||'/dateNaissance',null,1),0,10), 'YYYY-MM-DD');
    loc_Tab_Indiv('bene').nom := PK_XML.EXTRACT_DATA(P_Question,loc_path_beneficiaire||'/nom',null,1);
    loc_Tab_Indiv('bene').prenom := PK_XML.EXTRACT_DATA(P_Question,loc_path_beneficiaire||'/prenom',null,1);
    loc_tauxRemboursement:= PK_XML.EXTRACT_DATA(P_Question,loc_path_beneficiaire||'/tauxRemboursement',null,1);
    -- practicien
    loc_domaine_p     := PK_XML.EXTRACT_DATA(P_Question,loc_path_practicien||'/domaine',null,1);
    loc_numeroFiness  := PK_XML.EXTRACT_DATA(P_Question,loc_path_practicien||'/numeroFiness',null,1);
    loc_specialite    := PK_XML.EXTRACT_DATA(P_Question,loc_path_practicien||'/specialite',null,1);
    loc_raisonSociale := PK_XML.EXTRACT_DATA(P_Question,loc_path_practicien||'/raisonSociale',null,1);
    loc_adresse_p     := PK_XML.EXTRACT_DATA(P_Question,loc_path_practicien||'/adresse',null,1);
    loc_codePostal_p  := PK_XML.EXTRACT_DATA(P_Question,loc_path_practicien||'/codePostal',null,1);
    loc_ville_p       := PK_XML.EXTRACT_DATA(P_Question,loc_path_practicien||'/ville',null,1);

    -- prestation
    loc_nombreActes := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/nombreActes',null,1);
    loc_totalDepense := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalDepense',null,1);
    loc_totalRemboursementSS := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRemboursementSS',null,1);
    loc_totalRC := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRC',null,1);
    loc_totalRAC := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRAC',null,1);
    --
    loc_ErreurTechnique:='false';
    loc_codeReponse:='true';
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(1,v_id_flux|| ' F_CALCULRC, recup info' || sqlerrm);
      loc_messageErreur:='Saisie d''une information erronée de l entete, dossier, practicien ou de la prestation';
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      RAISE exc_erreur_saisi ;
  END;

  P_INS_journal(3,v_id_flux|| ' loc_attente 1: ' || loc_attente);
  -- *****************************************************************************
  -- ** RECUPERATION DES INFOS DU DETAIL DU OU DES ACTES DE LA QUESTION***********
  -- *****************************************************************************
  -- permet de gérer une mauvaise saisie

  i:=0;--compteur fichier xml
  cpt :=0;--compteur tableau acte

  LOOP
    P_INS_journal(3,v_id_flux|| '  Boucle sur les actes');
    i := i +1;
    loc_codfraisITELIS :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteType',null,1);
    P_INS_journal(3,v_id_flux|| ' 0 loc_codfraisITELIS: ' || loc_codfraisITELIS);
    IF TRIM(loc_codfraisITELIS) IS NULL THEN
      EXIT;
    END IF;

    P_INS_journal(1,v_id_flux|| ' loc_codfraisITELIS: ' || loc_codfraisITELIS);
  --  P_INS_journal(1,v_id_flux|| ' loc_path_detailActes: ' || loc_path_detailActes);

    BEGIN
      -- detailActe
      loc_Tab_acte(i).numeroActe           :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/numeroActe',null,1);
      loc_Tab_acte(i).identiteActeReference:=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/identiteActeReference',null,1);
      loc_Tab_acte(i).libelleActe          :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/libelleActe',null,1);
      loc_Tab_acte(i).libelleActeLibre     :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/libelleActeLibre',null,1);
      loc_Tab_acte(i).codeActeSS           :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/codeActeSS',null,1);
      loc_Tab_acte(i).codeCCAM             :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/codeCCAM',null,1);
      loc_Tab_acte(i).prixActe             :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/prixActe',null,1);
      loc_Tab_acte(i).prixRemise           :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/prixRemise',null,1);
      loc_Tab_acte(i).prixActeRemise       :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/prixActeRemise',null,1);
      loc_Tab_acte(i).prixVenteDispositif  :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/prixVenteDispositif',null,1);
      loc_Tab_acte(i).montantPrestationSoin:=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/montantPrestationSoin',null,1);
      loc_Tab_acte(i).chargesStructure     :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/chargesStructure',null,1);
      loc_Tab_acte(i).acteBaseSS           :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteBaseSS',null,1);
      loc_Tab_acte(i).acteRemboursementSS  :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteRemboursementSS',null,1);
      loc_Tab_acte(i).acteRC               :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteRC',null,1);
      loc_Tab_acte(i).acteRAC              :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteRAC',null,1);
      loc_Tab_acte(i).acteType             :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteType',null,1);

      -- *****************************************************************************
      -- ** *******************MONTURE ***********************************************
      -- *****************************************************************************
      IF loc_Tab_acte(i).acteType = 'MONTURE' THEN
        loc_t_monture(i).montureType          :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/monture/montureType',null,1);
        loc_Tab_acte(i).nature_prest := 'LUN';
        loc_nat_dossier:=2; -- optique
        loc_sens:=F_SENS_LIBELLE('HISTO_D1', 4);   -- recherche du nombre de mois de péremption du dossier
        loc_attente:=loc_attente+1;
        --RAC DEROG WS Recupération de la monture du flux dans le tableau temporaire loc_t_equip
        loc_t_equip(i).acteType_mont :='MONTURE';
        loc_t_equip(i).montureType   :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/monture/montureType',null,1);
      -- *****************************************************************************
      -- ********************** VERRE ************************************************
      -- *****************************************************************************
      ELSIF loc_Tab_acte(i).acteType = 'VERRE' THEN
        loc_t_verre(i).oeil          :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/oeil',null,1);
        loc_t_verre(i).prisme        :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/prisme',null,1);
        loc_t_verre(i).sphere        := /*TO_NUMBER*/(PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/sphere',null,1));
        loc_t_verre(i).cylindre      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/cylindre',null,1);
        loc_t_verre(i).addition      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/addition',null,1);
        loc_t_verre(i).axe           :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/axe',null,1);
        loc_t_verre(i).verreType           :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/equipement/verreType',null,1);
        P_INS_journal(1,v_id_flux|| ' loc_t_verre(i).oeil: ' || loc_t_verre(i).oeil);
        P_INS_journal(1,v_id_flux|| ' loc_t_verre(i).sphere: ' || loc_t_verre(i).sphere);
        P_INS_journal(1,v_id_flux|| ' loc_t_verre(i).cylindre: ' || loc_t_verre(i).cylindre);
        P_INS_journal(1,v_id_flux|| ' loc_t_verre(i).addition: ' || loc_t_verre(i).addition);
        P_INS_journal(1,v_id_flux|| ' loc_t_verre(i).axe: ' || loc_t_verre(i).axe);
        P_INS_journal(1,v_id_flux|| ' loc_t_verre(i).prisme: ' || loc_t_verre(i).prisme);
        P_INS_journal(1,v_id_flux|| ' loc_t_verre(i).verreType: ' || loc_t_verre(i).verreType);
        loc_Tab_acte(i).nature_prest := 'VER';
        loc_nat_dossier:=2; -- optique
        loc_sens:=F_SENS_LIBELLE('HISTO_D1', 4);   -- recherche du nombre de mois de péremption du dossier
        loc_attente:=loc_attente+1;
        --RAC DEROG WS Recupération des verres du flux dans le tableau temporaire loc_t_equip
        loc_t_equip(i).acteType_verr :='VERRE';
        loc_t_equip(i).oeil          :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/oeil',null,1);
        loc_t_equip(i).prisme        :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/prisme',null,1);
        loc_t_equip(i).sphere        := PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes|| '/detailActe['||i||']/verre/correction/sphere',null,1);
        loc_t_equip(i).cylindre      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/cylindre',null,1);
        loc_t_equip(i).addition      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/addition',null,1);
        loc_t_equip(i).axe           :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/correction/axe',null,1);
        loc_t_equip(i).verreType     :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/verre/equipement/verreType',null,1);
      -- *****************************************************************************
      -- ********************** SUPPLEMENT VERRE *************************************
      -- *****************************************************************************
      ELSIF loc_Tab_acte(i).acteType = 'SUPPLEMENT VERRE' THEN
        loc_Tab_acte(i).nature_prest := 'VERSUP';
        loc_t_equip(i).acteType_sup_ver := 'VERSUP';
      -- *****************************************************************************
      -- ********************** SUPPLEMENT MONTURE ***********************************
      -- *****************************************************************************
      ELSIF loc_Tab_acte(i).acteType = 'SUPPLEMENT MONTURE' THEN
        loc_Tab_acte(i).nature_prest := 'LUNSUP';
        loc_t_equip(i).acteType_sup_mon := 'LUNSUP';
      -- *****************************************************************************
      -- ********************** LENTILLE *********************************************
      -- *****************************************************************************
      ELSIF loc_Tab_acte(i).acteType = 'LENTILLE' THEN
        loc_Tab_acte(i).nature_prest := 'LEN';
        loc_t_lentille(i).oeil          :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/oeil',null,1);
        loc_t_lentille(i).sphere        :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/sphere',null,1);
        loc_t_lentille(i).cylindre      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/cylindre',null,1);
        loc_t_lentille(i).addition      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/addition',null,1);
        loc_t_lentille(i).axe           :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/axe',null,1);
        loc_t_lentille(i).prisme        :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/prisme',null,1);
        loc_nat_dossier:=2; -- optique
        loc_sens:=F_SENS_LIBELLE('HISTO_D1', 4);   -- recherche du nombre de mois de péremption du dossier
        --RAC DEROG WS Recupération des lentilles du flux dans le tableau temporaire loc_t_equip
        loc_t_equip(i).acteType_lent :='LENTILLE';
        loc_t_equip(i).oeil_lent     :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/oeil',null,1);
        loc_t_equip(i).sphere_lent   :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/sphere',null,1);
        loc_t_equip(i).cylindre_lent :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/cylindre',null,1);
        loc_t_equip(i).addition_lent :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/addition',null,1);
        loc_t_equip(i).axe_lent      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/axe',null,1);
        loc_t_equip(i).prisme_lent   :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/lentille/correction/prisme',null,1);
      -- *****************************************************************************
      -- ********************** SUPPLEMENT LENTILLE **********************************
      -- *****************************************************************************
      ELSIF loc_Tab_acte(i).acteType = 'SUPPLEMENT LENTILLE' THEN
        loc_Tab_acte(i).nature_prest := 'LENSUP';
      -- *****************************************************************************
      -- ********************** AUDITIF **********************************************
      -- *****************************************************************************
      ELSIF loc_Tab_acte(i).acteType = 'AUDIOPROTHESE' THEN
        loc_Tab_acte(i).nature_prest := 'PAU';
        loc_t_auditif(i).oreille        :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/oreille',null,1);
        loc_t_auditif(i).Hz500          :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/Hz500',null,1);
        loc_t_auditif(i).Hz1000         :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/Hz1000',null,1);
        loc_t_auditif(i).Hz2000         :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/Hz2000',null,1);
        loc_t_auditif(i).Hz4000         :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/Hz4000',null,1);
        loc_nat_dossier:=4; -- auditif
        loc_sens:=F_SENS_LIBELLE('HISTO_D1', 7);   -- recherche du nombre de mois de péremption du dossier
        --RAC DEROG WS Recupération des actes audio du flux dans le tableau temporaire loc_t_equip
        loc_t_equip(i).acteType_audio :='AUDIOPROTHESE';
        loc_t_equip(i).oreille        :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/oreille',null,1);
        loc_t_equip(i).Hz500          :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/Hz500',null,1);
        loc_t_equip(i).Hz1000         :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/Hz1000',null,1);
        loc_t_equip(i).Hz2000         :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/Hz2000',null,1);
        loc_t_equip(i).Hz4000         :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/audioprothese/deficience/Hz4000',null,1);

      -- *****************************************************************************
      -- ********************** SUPPLEMENT AUDITIF ***********************************
      -- *****************************************************************************
      ELSIF loc_Tab_acte(i).acteType = 'SUPPLEMENT AUDIOPROTHESE' THEN
        loc_Tab_acte(i).nature_prest := 'AUDSUP';
      -- *****************************************************************************
      -- ********************** DENTAIRE *********************************************
      -- *****************************************************************************
      ELSIF loc_Tab_acte(i).acteType = 'ACTE DENTAIRE' THEN
        loc_Tab_acte(i).nature_prest := 'DEN';
        loc_t_dentaire(i).dentaireType     :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/dentaireType',null,1);
        loc_t_dentaire(i).dentaireFamille  :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/dentaireFamille',null,1);
        loc_t_dentaire(i).codeRegroupement :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/codeRegroupement',null,1);
        loc_t_dentaire(i).codeCCAM         :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/codeCCAM',null,1);
        loc_t_dentaire(i).nombreDents      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/nombreDents',null,1);
        loc_t_dentaire(i).numerosDents     :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/numerosDents',null,1);
        loc_nat_dossier:=3; -- dentaire
        loc_sens:=F_SENS_LIBELLE('HISTO_D1', 5);
        --RAC DEROG WS Recupération des actes dentaires du flux dans le tableau temporaire loc_t_equip
        loc_t_equip(i).acteType_dent    :='ACTE DENTAIRE';
        loc_t_equip(i).dentaireType     :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/dentaireType',null,1);
        loc_t_equip(i).dentaireFamille  :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/dentaireFamille',null,1);
        loc_t_equip(i).codeRegroupement :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/codeRegroupement',null,1);
        loc_t_equip(i).codeCCAM         :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/codeCCAM',null,1);
        loc_t_equip(i).nombreDents      :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/nombreDents',null,1);
        loc_t_equip(i).numerosDents     :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteDentaire/numerosDents',null,1);
      END IF;
      loc_ErreurTechnique:='false';
      loc_codeReponse:='true';
    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1,v_id_flux|| ' F_CALCULRC, recup info détail acte' || sqlerrm);
        loc_messageErreur1:='Saisie d''un acte erroné';
        loc_Tab_acte(i).messageErreur:='Saisie d''un acte erroné';
        loc_ErreurTechnique:='false';
        loc_codeReponse:='false';
        loc_numeroDossierExperteo:=NULL;
        loc_identifiantDossierAMC:=NULL;
        RAISE exc_erreur_saisi ;
    END;


  END LOOP;

  P_INS_journal(3,v_id_flux|| ' loc_attente 2: ' || loc_attente);


  -- ***************************************************************************
  -- *************** FIN RECUPERATION DES INFOS DE LA QUESTION *****************
  -- ***************************************************************************



  -- ***************************************************************************
  -- ********************** DEBUT CONTROLES INFOS DU PATIENT *******************
  -- ***************************************************************************
  BEGIN
    -- ***************************************************************************
    -- *************** VERIFICATION DU DROIT AU SERVICE***************************
    -- ***************************************************************************
    P_INS_journal(1,v_id_flux|| ' VERIFICATION DU DROIT AU SERVICE');

    P_INS_journal(1,v_id_flux|| ' loc_Tab_Indiv(bene).numindiv:'||loc_Tab_Indiv('bene').numindiv);


    PK_CTRL_TP.P_FIND_CONTRAT_BY_ASSU(
          loc_Tab_Indiv('bene').numindiv,
          loc_Tab_Indiv('bene').numindiv,
          22, --g_grpporte,
          loc_idadhesion,
          loc_numgar,
          loc_isColl,
          loc_libelle,
          loc_dateEffet,
          loc_dateRes,
          loc_numorg,
          loc_numporte,
          erreur_contrat);
    P_INS_journal(1,v_id_flux|| ' VERIFICATION 2 DU DROIT AU SERVICE');
    P_INS_journal(1,v_id_flux|| ' erreur_contrat:'||erreur_contrat);
    P_INS_journal(1,v_id_flux|| ' loc_idadhesion:'||loc_idadhesion);
    P_INS_journal(1,v_id_flux|| ' loc_numgar:'||loc_numgar);

    IF erreur_contrat = 1 THEN
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'N°de contrat inconnu ou non couvert à la date des soins';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      loc_statut:='REFUSE';
      RAISE exc_assure_ko;
    ELSIF erreur_contrat = 2 THEN
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'L''assuré ne bénéficie pas du service Itelis ';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      loc_statut:='REFUSE';
      RAISE exc_tiers_inconnu;
    ELSIF erreur_contrat <> 0 THEN
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'Erreur inconnue';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      loc_statut:='REFUSE';
      RAISE exc_assure_ko1;
    END IF;


    -- ***************************************************************************
    -- *************** VERIFICATION DE LA REFERENCE EXTERNE DU CONTRAT************
    -- ***************************************************************************
    -- Saisie d'un numero de contrat erroné
    IF loc_contrat IS NOT NULL THEN
      loc_numassu:= F_NUMASSU(loc_Tab_Indiv('bene').numindiv,loc_idadhesion);
      PK_CTRL_TP.P_FIND_REFCIE (
        loc_contrat,
        loc_numassu,
        g_grpporte,
        loc_idadhesion,
        loc_numassu,
        loc_numgar,
        loc_isColl,
        loc_libelle,
        loc_dateEffet,
        loc_dateRes,
        loc_numorg,
        loc_numporte,
        loc_found
        );
  --    P_INS_journal(1,v_id_flux|| ' loc_found:'||loc_found);
      IF  NVL(loc_found,0)> 0 THEN
        loc_ErreurTechnique:='false';
        loc_codeReponse:='false';
        loc_messageErreur := 'Saisie d''un numero de contrat erroné';
        loc_numeroDossierExperteo:=NULL;
        loc_identifiantDossierAMC:=NULL;
        loc_statut:='REFUSE';
        RAISE exc_Refcontrat_ko;
      END IF;
    END IF;

    -- Contrôle de la couverture du bénéficaire
    loc_isCouvert := PK_CTRL_TP.F_CTRL_couverture(loc_Tab_Indiv('bene').numindiv,1,'C',sysdate);
    IF NOT loc_isCouvert THEN
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'Pas de remboursement possible : Le patient n''est plus couvert par le contrat';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      loc_statut:='REFUSE';
      raise exc_adhe_invalide;
    END IF;
    --Contrôle du rang du bénéficiaire
    loc_isTP := PK_CTRL_TP.F_CTRL_rang(loc_Tab_Indiv('bene').numindiv,loc_idadhesion,1,'C',sysdate);
    IF NOT loc_isTP THEN
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'Pas de remboursement possible : Le patient n''est plus couvert par le contrat';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      loc_statut:='REFUSE';
      RAISE exc_TP_ferme;
    END IF;

    -- Parcours des garanties de l adhérent : si garantie principale non trouvée, on prend la garantie facultatif sinon on sort en erreur
    OPEN PK_CTRL_TP.Fetch_garanties_adhe(loc_idadhesion, loc_Tab_Indiv('bene').numindiv) ;
    FETCH PK_CTRL_TP.Fetch_garanties_adhe INTO C_lstGar;

    IF PK_CTRL_TP.Fetch_garanties_adhe%NOTFOUND THEN
      CLOSE  PK_CTRL_TP.Fetch_garanties_adhe;
      P_INS_journal(1,v_id_flux|| '  RAISE exc_garantie_inconnue');
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_messageErreur := 'Pas de remboursement possible : Le patient n''est plus couvert par la garantie';
      loc_numeroDossierExperteo:=NULL;
      loc_identifiantDossierAMC:=NULL;
      loc_statut:='REFUSE';
      RAISE exc_garantie_inconnue;
    END IF;

    CLOSE PK_CTRL_TP.Fetch_garanties_adhe;

  EXCEPTION

    WHEN exc_assure_ko THEN
      P_INS_journal(1,v_id_flux|| ' N°de contrat inconnu ou non couvert à la date des soins' );
    WHEN exc_assure_ko1 THEN
      P_INS_journal(1,v_id_flux|| ' ERREUR INCONNUE' );
    WHEN exc_tiers_inconnu THEN
      P_INS_journal(1,v_id_flux|| ' PORTE NON OUVERTE SUR LE CONTRAT' );
    WHEN exc_Refcontrat_ko THEN
      P_INS_journal(1,v_id_flux|| ' Saisie d''un numero de contrat erroné' );
    WHEN exc_adhe_invalide THEN
      P_INS_journal(1,v_id_flux|| ' Pas de remboursement possible : Le patient n''est plus couvert par le contrat' );
    WHEN exc_TP_ferme THEN
      P_INS_journal(1,v_id_flux|| ' Pas de remboursement possible : Le patient n''est plus couvert par le contrat' );
    WHEN exc_garantie_inconnue THEN
      P_INS_journal(1,v_id_flux|| ' Pas de remboursement possible : Le patient n''est plus couvert par la garantie' );
    WHEN OTHERS THEN
      P_INS_journal(1,v_id_flux|| ' F_CALCULRC, controle infos patient(adhesion,contrat,...)' || sqlerrm);
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_messageErreur := 'Erreur technique d''identification';
      loc_statut:='ABANDONNE';
  END;
  -- ***************************************************************************
  -- ********************** FIN CONTROLES INFOS DU PATIENT *********************
  -- ***************************************************************************


  -- ***************************************************************************
  -- ********************** DEBUT CONTROLES INFOS PRACTICIEN *******************
  -- ***************************************************************************
  IF loc_statut NOT IN ('REFUSE','ABANDONNE') THEN
    BEGIN
      IF loc_type = 1 THEN -- PEC

        IF TRIM(loc_raisonSociale) IS NULL THEN
          --nom dans la table individu ne peut-être null;
          loc_raisonSociale := ' ';
        END IF;
        --Recherche et création du professionnel de santé si celui-ci n'existe pas
        PK_CTRL_TP.P_FIND_TIERS(
                P_NNI=> loc_numeroFiness,
                P_typePS => loc_specialite,
                P_raison=> SUBSTR(UPPER(loc_raisonSociale),0,30),
                P_ad1 => null,
                P_ad2 => null,
                P_ad3 => TRIM(loc_adresse_p),
                P_ad4 => null,
                P_ad5 => null,
                P_cp => loc_codePostal_p,
                P_ville => TRIM(loc_ville_p),
                P_tel=>null,
                P_mail=> null,
                O_numindivPS => loc_numindivPS);
        P_INS_journal(1,v_id_flux|| ' FIN ctrl PS, loc_numindivPS:'||to_char(loc_numindivPS));
        P_INS_journal(1,v_id_flux|| ' Experteo:'||loc_numeroDossierExperteo|| ' DossierAMC:'||loc_identifiantDossierAMC);

        PK_CTRL_TP.P_INS_DOSSIER_SANTE( P_ref         => NVL(loc_identifiantDossierAMC,loc_numeroDossierExperteo),
                                        P_numindiv    => loc_Tab_Indiv('bene').numindiv,
                                        P_PS          => loc_numindivPS,
                                        P_numassu     => f_numassu(loc_Tab_Indiv('bene').numindiv,loc_idadhesion),
                                        P_numporte    => g_grpporte,
                                        P_natdoss     => loc_nat_dossier,
                                        P_typedoss    => 4, --dossier de prise en charge
                                        P_num_dossier_porte => loc_numeroDossierExperteo,--loc_numdossierPorte, --> av voir si c est le bon numéro
                                        O_num_dossier => loc_num_dossier);

        P_INS_journal(1,v_id_flux|| ' loc_num_dossier:' || loc_num_dossier);

        IF loc_num_dossier = 0 THEN
          P_INS_journal(1,v_id_flux|| '  RAISE exc_dossier');
          loc_ErreurTechnique:='false';
          loc_codeReponse:='false';
          loc_messageErreur := 'Impossible de créer le dossier de soins santé';
          loc_numeroDossierExperteo:=NULL;
          loc_identifiantDossierAMC:=NULL;
          loc_statut:='REFUSE';
          RAISE exc_dossier;
        END IF;

        -- mise à jour de la reférence externe de l'individu
        loc_refDomaine :=F_get_transco('ITELIS','DOMGEREP',loc_nat_dossier);

        PK_CTRL_TP.P_MAJ_REF_EXTERNE(
            P_numindiv    => loc_Tab_Indiv('bene').numindiv,
            P_domaine     => loc_refDomaine,
            P_tiers       => 'ITELIS',
            P_mnemo       => 'DOMGEREP');

        -- Historisation du dossier créé en cours
        IF NVL(loc_attente,0) < 4 THEN
          PK_CTRL_TP.P_INS_HISTO_DOSSIER(
                  P_num_dossier => loc_num_dossier,
                  P_etat        => 0,
                  P_motif       => 0);

        ELSE
          PK_CTRL_TP.P_INS_HISTO_DOSSIER(
                  P_num_dossier => loc_num_dossier,
                  P_etat        => 0,
                  P_motif       => 8);
        END IF;

      END IF;

    EXCEPTION
      WHEN exc_dossier THEN
          P_INS_journal(1,v_id_flux|| ' Impossible de créer le dossier de soins santé' );
      WHEN OTHERS THEN
        P_INS_journal(1,v_id_flux|| ' F_CALCULRC, controle infos practicien' || sqlerrm);
        loc_ErreurTechnique:='true';
        loc_codeReponse:='false';
        loc_messageErreur := 'Erreur technique d''identification du practicien';
        loc_statut:='ABANDONNE';
    END;
  END IF;
  -- ***************************************************************************
  -- ********************** FIN CONTROLES INFOS PRACTICIEN *********************
  -- ***************************************************************************

  -- ***************************************************************************
  -- ********************** DEBUT CONTROLES INFOS DES ACTES ********************
  -- ***************************************************************************
  loc_numfor:=PK_WS_BACK_SANTECLAIR.F_FORMULE_SOUSCRITE(loc_idadhesion,loc_Tab_Indiv('bene').numindiv);
  P_INS_journal(1,v_id_flux|| ' garantie:'||loc_numfor || ' Domaine:'||loc_domaine );

  --initialisation de l'objet trav_saisie
  P_TRAV_SAISIE.SID:= l_sid;
  BEGIN
    SELECT numutil INTO P_TRAV_SAISIE.USERNAME from porte_param where numporte=g_grpporte;
  EXCEPTION
    WHEN OTHERS THEN
      SELECT F_NUMUTIL INTO P_TRAV_SAISIE.USERNAME FROM DUAL;
  END;
  P_TRAV_SAISIE.NUMSIN:=  NULL;
  P_TRAV_SAISIE.RESEAU:=NVL(F_SENS_LIBELLE('PORTE',g_grpporte),g_grpporte);  -- réseau de soins
  P_INS_journal(3,v_id_flux|| ' DEVIS P_TRAV_SAISIE.RESEAU:' || P_TRAV_SAISIE.RESEAU);
  i:=0;--compteur fichier xml
  cpt :=0;--compteur tableau acte

  LOOP

   -- P_INS_journal(1,v_id_flux|| '  Boucle sur la transco des actes');
    i := i +1;
    P_INS_journal(1,v_id_flux|| ' ***CONTROLE COUV ET TRANSCO ACTE n°' ||i);
    loc_codfraisITELIS :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteType',null,1);
    IF TRIM(loc_codfraisITELIS) IS NULL THEN
      EXIT;
    END IF;

    P_INS_journal(1,v_id_flux|| ' codfraisITELIS: ' || loc_codfraisITELIS|| ' nature_prest: ' || loc_Tab_acte(i).nature_prest);


    BEGIN

      -- ***************************************************************************
      -- ********************** RECHERCHE ET CONTROLES ACTE GEREP OPTIQUE **********
      -- ***************************************************************************
      IF loc_domaine = 0 THEN -- optique (verre ou monture)
        --IF loc_Tab_acte(i).nature_prest NOT IN ('VERSUP','LENSUP') THEN    -- Aucun contrôles si l acte externe est un supplément --TODO

p_ins_journal(1, v_id_flux || 'lpp' ||i|| ': '|| loc_Tab_acte(i).codeActeSS);

          -- Trancodification de l acte
          P_TRANSCO_CODFRAIS_OPTIQUE( loc_numfor
                                    , i
                                    , loc_Tab_acte
                                    , loc_t_verre
                                    , loc_t_lentille
                                    , loc_codfrais
                                    , loc_acte_err_code
                                    , PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/codeActeSS',null,1)--RKO Rac Optique
                                    );



          P_INS_journal(1,v_id_flux|| ' =>Acte identifié:'||loc_codfrais );
          loc_Tab_acte(i).codfrais:=loc_codfrais;
          --Controle de couverture de l'acte
          IF loc_Tab_acte(i).codfrais IS NOT NULL THEN
            loc_acteCouvert := FALSE;
            -- Controle de couverture de l'acte
            PK_CTRL_TP.P_CTRL_CVRT_ACTE(loc_Tab_acte(i).codfrais,
                                        loc_Tab_Indiv('bene').numindiv,
                                        SYSDATE,       -- TODO : récupérer la date des soins
                                        loc_idadhesion,
                                        loc_acteCouvert,
                                        erreur_acte);
          ELSE
            loc_acteCouvert := FALSE;
          END IF;

          IF loc_acteCouvert THEN
            P_INS_journal(3,v_id_flux|| '--Acte couvert par la garantie' );
          ELSE
            P_INS_journal(1,v_id_flux|| ' Acte santé non couvert à la date des soins:'||loc_Tab_acte(i).codfrais );
            RAISE exc_acte;
          END IF;

          -- Contrôle de la couverture TPE
          IF pk_porte.F_carte_tp(loc_Tab_Indiv('bene').numindiv, loc_Tab_acte(i).codfrais, trunc(sysdate), 0, NULL,  NULL, g_tabCond ) =0 THEN
            loc_acteCouvert:=FALSE;
          END IF;
          IF loc_acteCouvert THEN
            P_INS_journal(3,v_id_flux|| '--Acte couvert TPE');
          ELSE
            P_INS_journal(1,v_id_flux|| ' Carte tiers payant non ouverte à la date des soins:'||loc_Tab_acte(i).codfrais );
            RAISE exc_carte_tp;
          END IF;

        --ELSE --TODO
         P_INS_journal(3,v_id_flux|| ' Aucun contrôles si l acte externe est un supplément:'||loc_Tab_acte(i).nature_prest );
        --END IF;--TODO
      -- ***************************************************************************
      -- ********************** RECHERCHE ET CONTROLES ACTE GEREP DENTAIRE *********
      -- ***************************************************************************
      ELSIF loc_domaine = 1 THEN -- dentaire
        P_INS_journal(3,v_id_flux|| ' loc_domaine dentaire:'||loc_domaine );
        -- Trancodification de l acte
        P_TRANSCO_CODFRAIS_DENTAIRE( loc_numfor
                                   , i
                                   , loc_Tab_acte
                                   , loc_t_dentaire
                                   , loc_codfrais
                                   , loc_acte_err_code);

        P_INS_journal(1,v_id_flux|| ' loc_codfrais:'||loc_codfrais );
        loc_Tab_acte(i).codfrais:=loc_codfrais;

        --Controle de couverture de l'acte
        IF loc_Tab_acte(i).codfrais IS NOT NULL THEN
          loc_acteCouvert := FALSE;
          -- Controle de couverture de l'acte
          PK_CTRL_TP.P_CTRL_CVRT_ACTE(loc_Tab_acte(i).codfrais,
                                      loc_Tab_Indiv('bene').numindiv,
                                      SYSDATE,       -- TODO : récupérer la date des soins
                                      loc_idadhesion,
                                      loc_acteCouvert,
                                      erreur_acte);
        ELSE
          loc_acteCouvert := FALSE;
        END IF;
        IF loc_acteCouvert THEN
          P_INS_journal(3,v_id_flux|| ' loc_acteCouvert OK:'||loc_Tab_acte(i).codfrais );
        ELSE
          P_INS_journal(1,v_id_flux|| ' Acte santé non couvert à la date des soins:'||loc_Tab_acte(i).codfrais );
          RAISE exc_acte;
        END IF;
        P_INS_journal(3,v_id_flux|| ' loc_Tab_Indiv(''bene'').numindiv :'||loc_Tab_Indiv('bene').numindiv );
        -- Contrôle de la couverture TPE
        IF pk_porte.F_carte_tp(loc_Tab_Indiv('bene').numindiv, loc_Tab_acte(i).codfrais, trunc(sysdate), 0, NULL,  NULL, g_tabCond ) =0 THEN
          loc_acteCouvert:=FALSE;
        END IF;
        IF loc_acteCouvert THEN
          P_INS_journal(3,v_id_flux|| ' loc_acteCouvert OK2:'||loc_Tab_acte(i).codfrais );
        ELSE
          P_INS_journal(1,v_id_flux|| ' Carte tiers payant non ouverte à la date des soins:'||loc_Tab_acte(i).codfrais );
          RAISE exc_carte_tp;
        END IF;
      -- ***************************************************************************
      -- ********************** RECHERCHE ET CONTROLES ACTE GEREP AUDIO ************
      -- ***************************************************************************
      ELSIF loc_domaine = 2 THEN -- audioprothèse
        IF loc_Tab_acte(i).nature_prest <> 'AUDSUP' THEN    -- Aucun contrôles si l acte externe est un supplément
          P_INS_journal(3,v_id_flux|| ' loc_domaine audioprothèse:'||loc_domaine );
          p_ins_journal(1, v_id_flux || 'lpp' ||i|| ': '|| /*loc_Tab_acte(i).codeActeSS*/PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/codeActeSS',null,1)||'loc_numfor'||loc_numfor);-- RKO Rac audio
          -- Trancodification de l acte
          P_TRANSCO_CODFRAIS_AUDITIF( loc_numfor
                                    , i
                                    , loc_Tab_acte
                                    , loc_t_auditif
                                    , loc_codfrais
                                    , loc_acte_err_code
                                    , PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/codeActeSS',null,1) --RKO Rac Audio
                                    );

          P_INS_journal(1,v_id_flux|| ' loc_codfrais:'||loc_codfrais );
          loc_Tab_acte(i).codfrais:=loc_codfrais;
          --Controle de couverture de l'acte
          IF loc_Tab_acte(i).codfrais IS NOT NULL THEN
            loc_acteCouvert := FALSE;
            P_INS_journal(1,v_id_flux|| ' loc_Tab_acte(i).codfrais:'||loc_Tab_acte(i).codfrais||' adhesion '||loc_idadhesion );
            -- Controle de couverture de l'acte
            PK_CTRL_TP.P_CTRL_CVRT_ACTE(loc_Tab_acte(i).codfrais,
                                        loc_Tab_Indiv('bene').numindiv,
                                        SYSDATE,       -- TODO : récupérer la date des soins
                                        loc_idadhesion,
                                        loc_acteCouvert,
                                        erreur_acte);
          ELSE
            loc_acteCouvert := FALSE;
          END IF;
          IF loc_acteCouvert THEN
            P_INS_journal(3,v_id_flux|| ' loc_acteCouvert OK:'||loc_Tab_acte(i).codfrais );
          ELSE
            P_INS_journal(1,v_id_flux|| ' Acte santé non couvert à la date des soins:'||loc_Tab_acte(i).codfrais );
            RAISE exc_acte;
          END IF;

          -- Contrôle de la couverture TPE
          IF pk_porte.F_carte_tp(loc_Tab_Indiv('bene').numindiv, loc_Tab_acte(i).codfrais, trunc(sysdate), 0, NULL,  NULL, g_tabCond ) =0 THEN
            loc_acteCouvert:=FALSE;
          END IF;
          IF loc_acteCouvert THEN
            P_INS_journal(3,v_id_flux|| ' loc_acteCouvert OK2:'||loc_Tab_acte(i).codfrais );
          ELSE
            P_INS_journal(1,v_id_flux|| ' Carte tiers payant non ouverte à la date des soins:'||loc_Tab_acte(i).codfrais );
            RAISE exc_carte_tp;
          END IF;
        ELSE
          P_INS_journal(3,v_id_flux|| ' Aucun contrôles si l acte externe est un supplément:'||loc_Tab_acte(i).nature_prest );
        END IF;
      END IF;
    EXCEPTION
      WHEN exc_acte THEN
        loc_ErreurTechnique:='false';
        loc_codeReponse:='false';
        loc_Tab_acte(i).messageErreur := 'Acte santé non couvert à la date des soins';
        loc_messageErreur1 := 'Acte santé non couvert à la date des soins';
        loc_numeroDossierExperteo:=NULL;
        loc_identifiantDossierAMC:=NULL;
        loc_statut:='REFUSE';
        ROLLBACK;
      WHEN exc_carte_tp THEN
        loc_ErreurTechnique:='false';
        loc_codeReponse:='false';
        loc_Tab_acte(i).messageErreur := 'Carte tiers payant non ouverte à la date des soins';
        loc_messageErreur1 := 'Carte tiers payant non ouverte à la date des soins';
        loc_numeroDossierExperteo:=NULL;
        loc_identifiantDossierAMC:=NULL;
        loc_statut:='REFUSE';
        ROLLBACK;
      WHEN OTHERS THEN
        P_INS_journal(1,v_id_flux|| ' F_CALCULRC, Devis KO' || sqlerrm);
        loc_statut:='ABANDONNE';
        ROLLBACK;
    END;
  END LOOP;
  -- ***************************************************************************
  -- ********************** FIN CONTROLES INFOS DES ACTES **********************
  -- ***************************************************************************

  -- ***************************************************************************
  -- ********************** LANCEMENT DU CALCUL DU DEVIS OU PEC ****************
  -- ***************************************************************************
  IF loc_statut NOT IN ('REFUSE','ABANDONNE') THEN

    BEGIN

      P_INS_journal(3,v_id_flux|| ' DEVIS, loc_type='||loc_type);
      P_INS_journal(3,v_id_flux|| ' DEVIS, loc_attente='||loc_attente);

      IF loc_type = 0 THEN -- Devis
        IF loc_attente >= 4 THEN
          loc_ErreurTechnique:='false';
          loc_codeReponse:='false';
          loc_messageErreur := 'Devis non géré en cas de double vision ou changement de dioptrie';
          loc_numeroDossierExperteo:=NULL;
          loc_identifiantDossierAMC:=NULL;
          loc_statut:='REFUSE';
          RAISE exc_devis_en_attente;
        END IF;

        ------------------------------------------------------------------------------
        ----------------------- CALCUL DU DEVIS --------------------------------------
        ------------------------------------------------------------------------------
        i:=0;
        loc_totalDepense         :=  0;
        loc_totalRC              :=  0;
        loc_totalRAC             :=  0;
        loc_totalRemboursementSS :=  0;

        --mise en place de la dérogation optique RAC WS pour les devis
        k :=0;
        P_INS_journal(1,v_id_flux|| ' rko devis loc_domaine '||loc_domaine/*||' tableau des actes loc_Tab_acte(i) '||loc_Tab_acte(i).codfrais*/);
        l_derog :=null;
        IF loc_domaine = 0 THEN  --optique
          FOR k IN 1 .. loc_t_equip.COUNT LOOP
              IF loc_t_equip(k).acteType_verr IS NOT NULL  OR loc_t_equip(k).acteType_mont IS NOT NULL  --RKO WS RAC DEROG
                  OR loc_t_equip(k).acteType_sup_ver IS NOT NULL OR loc_t_equip(k).acteType_sup_mon IS NOT NULL THEN  -- M0007220 dérogation des supplements
                P_INS_journal(1,v_id_flux|| ' rko dans if loc_t_equip '||loc_t_equip(k).acteType_verr ||loc_t_equip(k).acteType_mont||' acte '||loc_Tab_acte(k).codfrais);
                --Revue de code dans le cadre du ticket ARTGEREP_398  : déplacement de la dérogation hors de la boucle du tableau des actes loc_Tab_acte(i)
                --reinitialisation de l'oeil droit
                --distinction oeil droit et gauche afin de ne pas passer le meme oeil à la F_derogOptique cf M0007228
                --M0007214 et ARTGEREP_398 reinitialisation des object loc_verre_droit et loc_verre_gauche avec null afin de :
                   -- ne pas deroger avec les caractéristiques 0 sur une monture
                   -- de passer uniquement le bon oeil à la fonction de derog
                loc_verre_droit.oeil := null;
                loc_verre_droit.sphere := null ;
                loc_verre_droit.cylindre := null;
                loc_verre_droit.addition := null;
                loc_verre_droit.axe :=  null;
                --reinitialisation de l'oeil gauche
                loc_verre_gauche.oeil := null;
                loc_verre_gauche.sphere := null ;
                loc_verre_gauche.cylindre := null;
                loc_verre_gauche.addition := null;
                loc_verre_gauche.axe :=  null;
              --recupération des sinistres verres du flux
                IF loc_t_equip(k).oeil = 0 THEN --oeil droit
                   --loc_sinistre_verre.oeil := 'D';
                  loc_verre_droit.oeil := 'D';
                  loc_verre_droit.sphere := NVL(loc_t_equip(k).sphere,0)  ;
                  loc_verre_droit.cylindre := NVL(loc_t_equip(k).cylindre,0);
                  loc_verre_droit.addition := NVL(loc_t_equip(k).addition,0);
                  loc_verre_droit.axe :=  NVL(loc_t_equip(k).axe,0);
                ELSIF loc_t_equip(k).oeil = 1 THEN--oeil gauche
                   --loc_sinistre_verre.oeil := 'G';
                   loc_verre_gauche.oeil := 'G';
                   loc_verre_gauche.sphere := NVL(loc_t_equip(k).sphere,0)  ;
                   loc_verre_gauche.cylindre := NVL(loc_t_equip(k).cylindre,0);
                   loc_verre_gauche.addition := NVL(loc_t_equip(k).addition,0);
                   loc_verre_gauche.axe :=  NVL(loc_t_equip(k).axe,0);
                END IF;
              END IF;  --acteType_verr et acteType_mont
              P_INS_journal(1,v_id_flux|| ' rko les verres sphere_dro '||loc_verre_droit.sphere|| ' cyl_dr '||loc_verre_droit.cylindre|| ' add_dr '||loc_verre_droit.addition||' axe_dr '||loc_verre_droit.axe||' codfrais '||loc_Tab_acte(k).codfrais);
              P_INS_journal(1,v_id_flux|| ' rko les verres sphere_gc '||loc_verre_gauche.sphere|| ' cyl_gc '||loc_verre_gauche.cylindre|| ' add_gc '||loc_verre_gauche.addition||' axe_gc '||loc_verre_gauche.axe||' codfrais '||loc_Tab_acte(k).codfrais);
              --P_INS_journal(1,v_id_flux|| ' rko appel de f_derogOptique verre sphere '||loc_sinistre_verre.sphere|| ' cylindre '||loc_sinistre_verre.cylindre|| ' addition '||loc_sinistre_verre.addition||' axe '||loc_sinistre_verre.axe||' codfrais '||loc_Tab_acte(i).codfrais);
              loc_res_derog := PK_FUNCT.F_DerogOptique (p_numIndiv    =>loc_Tab_Indiv('bene').numindiv
                                                      , p_datSin       => TRUNC(sysdate)--Ajout du trunc ARTGEREP_398
                                                      , p_codFrais     =>loc_Tab_acte(k).codfrais
                                                      , p_verre_droit  =>loc_verre_droit --loc_sinistre_verre -- M0007228
                                                      , p_verre_gauche =>loc_verre_gauche --loc_sinistre_verre
                                                       ) ;
              P_INS_journal(1,v_id_flux|| ' rko loc_res_derog.derogOptique '||loc_res_derog.derogOptique ||' information '||loc_res_derog.information||' codfrais '||loc_Tab_acte(k).codfrais);
              --des lors qu'un acte est dérog, les autres sont dérogeables également
              IF loc_res_derog.derogOptique ='OUI' THEN
                l_derog :='OPTI';
                EXIT;-- sortie de boucle dès qu'un acte est dérogé
              END IF;
          END LOOP;
        END IF;--domaine
        P_INS_journal(1,v_id_flux|| ' rko apres f_derog l_derog '||l_derog );
        LOOP
          loc_mtprest:=0;
          erreur_calcul_devis:=0;
          loc_blocage:=NULL;
          P_INS_journal(3,v_id_flux|| '  CALCUL DU DEVIS : Boucle sur les actes');
          i := i +1;
          loc_codfraisITELIS :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteType',null,1);
          IF TRIM(loc_codfraisITELIS) IS NULL THEN
            EXIT;
          END IF;
          IF i=1 AND loc_Tab_acte(i).nature_prest IN ('VERSUP','LENSUP','AUDSUP') THEN
            RAISE exc_prestation_ko;
          END IF;

          P_INS_journal(3,v_id_flux|| ' CALCUL DU DEVIS, loc_codfraisITELIS: ' || loc_codfraisITELIS);


          -- Detection d un supplément
          /*BEGIN --RKO RAC OPTIQUE gestion des Supplements
            loc_ro_sup:=0;
            loc_depense_sup:=0;
            IF  loc_Tab_acte(i+1).nature_prest IN ('VERSUP','LENSUP','AUDSUP') THEN
              loc_ro_sup:=NVL(TO_NUMBER(loc_Tab_acte(i+1).acteRemboursementSS),0);
              loc_depense_sup:= NVL(TO_NUMBER(loc_Tab_acte(i+1).prixActe),0);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              loc_ro_sup:=0;
              loc_depense_sup:=0;
          END;*/

          -- Deduction de la remise si une remise existe sur l'acte
          IF NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0) > 0 THEN
            loc_Tab_acte(i).prixActeRemise:= TO_CHAR(NVL(TO_NUMBER(loc_Tab_acte(i).prixActe),0) - NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0));
          END IF;


          IF loc_domaine = 1 THEN   -- dentaire

            P_DENT (p_dentaire =>loc_t_dentaire(i),
                  p_domaine =>loc_domaine,
                  o_items =>loc_o_items,
                  P_IO_TRAV_SAISIE =>P_TRAV_SAISIE);
             P_INS_journal(1,v_id_flux|| ' acte dentaire '||i|| ' Contrôle doublon sur '||loc_t_dentaire(i).numerosDents);
             loc_doublon_dent := F_CTRL_DOUBLON_DENT( i_numindiv => loc_Tab_Indiv('bene').numindiv,
                                                i_nodent =>loc_t_dentaire(i).numerosDents,
                                                i_date =>ADD_MONTHS(sysdate, -24),
                                                i_codfrais =>loc_Tab_acte(i).codfrais,
                                                i_numsin =>null,
                                                i_numdoss => loc_num_dossier
                                                );
            IF loc_doublon_dent = 1 then
              loc_blocage :=3;
              loc_Tab_acte(i).messageErreur := 'Plafond atteint ou aucun remboursement complémentaire';
              loc_Tab_acte(i).messageInformatif:= 'Soin de même nature déjà effectué sur cette dent sur les 2 dernières années';
              P_INS_journal(1,v_id_flux|| ' acte dentaire '||loc_Tab_acte(i).codfrais|| ' avec blocage DEVIS'||loc_doublon_dent);
            ELSE
              P_INS_journal(1,v_id_flux|| ' acte dentaire '||loc_Tab_acte(i).codfrais|| ' sans blocage DEVIS'||loc_doublon_dent);
            End if;

          END IF;

          -- IF  loc_Tab_acte(i).nature_prest NOT IN ('VERSUP','LENSUP','AUDSUP') THEN    -- Aucun contrôles si l acte externe est un supplément RKO
          --loc_flag_supplement := FALSE;
          -- insertion du réseau de soins si celui-ci est existant sur la porte ainsi que les dents si c est un devis dentaire
          P_TRAV_SAISIE.NUMLIG:= i;
          cpt_trav :=0;
          IF loc_domaine = 0 AND loc_Tab_acte(i).nature_prest = 'VER' THEN -- verre uniquement
              --Saisie des verres dans trav_saisie pour enreg dans sinistre_verre
            loc_trav :=P_TRAV_SAISIE;
           --Saisie de l'oeil Droit /Gauche
            IF loc_t_verre(i).oeil = 0 THEN
                loc_trav.oeil := 'D';
            ELSIF loc_t_verre(i).oeil = 1 THEN
               loc_trav.oeil := 'G';
            END IF;
            loc_trav.sphere :=NVL(loc_t_verre(i).sphere,0);
            loc_trav.cylindre :=NVL(loc_t_verre(i).cylindre,0);
            loc_trav.addition :=NVL(loc_t_verre(i).addition,0);
            loc_trav.axe := NVL(loc_t_verre(i).axe,0);
            --puis insertion
            P_INSERT_TRAV_SAISIE(  loc_trav );
            cpt_trav := cpt_trav +1;
          END IF;

          IF cpt_trav = 0 THEN
              P_INSERT_TRAV_SAISIE(  P_TRAV_SAISIE );
          END IF;
          COMMIT;

          IF loc_blocage =3 THEN
            loc_mtprest:=0;
          ELSIF loc_attente < 4 THEN
             PK_CALCUL_DOSSIER.P_CALCUL_RAC( P_codfrais    => loc_Tab_acte(i).codfrais,
                                            P_datsin      => TO_CHAR(SYSDATE,'DD/MM/YYYY'),
                                            P_taux        => TO_NUMBER(loc_tauxRemboursement),
                                            P_mtremb      => NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS)/100,0) + NVL(loc_ro_sup/100,0),
                                            P_baseremb    => TO_NUMBER(loc_Tab_acte(i).acteBaseSS)/100,
                                            P_mtfrais     => NVL(TO_NUMBER(loc_Tab_acte(i).prixActe)/100,0) - NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise)/100,0) + NVL(loc_depense_sup/100,0),
                                            P_devise      => PK_CTRL_TP.F_FIND_DEVISE,
                                            P_quantite    => loc_quantite,
                                            P_coeff       => 1,
                                            P_numindiv    => loc_Tab_Indiv('bene').numindiv,
                                            P_numbene     => loc_Tab_Indiv('bene').numindiv, -- loc_numassu,
                                            P_type_bene   => 1,
                                            P_ordre       => i,  -- Parametre très important : permet de gérer le cumul des actes pour les plafonds, carence, franchise
                                            P_type        => 'devis',
                                            O_mtprest     => loc_mtprest,
                                            O_erreur      => erreur_calcul_devis,
                                            O_msg_erreur  => O_msg_erreur_devis
                                            , p_derog     => l_derog  -- paramètre définissant la derogation (ou pas) lors du calcul
                                            );



              P_INS_journal(3,v_id_flux|| ' DEVIS erreur_calcul_devis:' || erreur_calcul_devis);
              P_INS_journal(3,v_id_flux|| ' DEVIS O_msg_erreur_devis:' || O_msg_erreur_devis);
              P_INS_journal(3,v_id_flux|| ' loc_mtprest OK:'||TO_CHAR(loc_mtprest) );

            --  loc_mtprest_Char:=REPLACE(TO_CHAR(loc_mtprest),',', '');
              loc_mtprest_Char:=REPLACE(TO_CHAR(loc_mtprest*100),'.', '');

              IF loc_domaine = 1 THEN   -- dentaire
                IF NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS)/100,0) = 0 THEN
                 loc_mtprest_Char:= loc_mtprest_Char * loc_t_dentaire(i).nombreDents;
                END IF;
              END IF;
              P_INS_journal(3,v_id_flux|| ' loc_mtprest_Char OK:'||loc_mtprest_Char );

              loc_Tab_acte(i).acteRC  :=  loc_mtprest_Char;

          END IF;
          ------------------------------------------------------------------------------
          -- --------------Proratisation des montants
          ------------------------------------------------------------------------------
          P_INS_journal(3,v_id_flux|| ' nature:'||loc_Tab_acte(i).nature_prest  );
          --répartition des actes verre et monture
          /*IF loc_Tab_acte(i).nature_prest NOT IN ('VERSUP','LENSUP','AUDSUP') THEN --RKO RAC OPTIQUE gestion des suppléments
            --ACTE avec a des suppléments
            IF NVL(loc_ro_sup,0)>0 OR NVL(loc_depense_sup,0)>0 THEN
              --si le montant de prestation verre+ sup >= FR verre -remise- SS verre
              IF TO_NUMBER(loc_mtprest_Char)>= (TO_NUMBER(loc_Tab_acte(i).prixActe) - NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0)- NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS),0)  ) THEN
                loc_Tab_acte(i).acteRC := TO_NUMBER(loc_Tab_acte(i).prixActe)- NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0)- NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS),0) ;
              ELSE
                P_INS_journal(1,v_id_flux|| ' *** avec supplément de '||loc_depense_sup ||' pour FR acte='||loc_Tab_acte(i).prixActe);
                loc_Tab_acte(i).acteRC := ROUND((TO_NUMBER(loc_Tab_acte(i).prixActe)*loc_mtprest_Char) / (TO_NUMBER(loc_Tab_acte(i).prixActe)+loc_depense_sup));
              END IF;
            --ACTE sans supplément
            ELSE
              loc_Tab_acte(i).acteRC  :=  loc_mtprest_Char;
            END IF;
          ELSE -- répartition des suppléments
            --RC sup = RC verre+ sup - RC verre
            P_INS_journal(3,v_id_flux|| ' nature1:'||loc_Tab_acte(i).nature_prest  );
            P_INS_journal(3,v_id_flux|| ' nature2:'||loc_Tab_acte(i-1).acteRC  );
            loc_Tab_acte(i).acteRC := loc_mtprest_Char-TO_NUMBER( loc_Tab_acte(i-1).acteRC);
          END IF; */

          P_INS_journal(3,v_id_flux|| ' ***RC '||TO_NUMBER(loc_Tab_acte(i).acteRC));
          --RAC = FR - remise - RO - RC
          loc_Tab_acte(i).acteRAC := TO_NUMBER(loc_Tab_acte(i).prixActe)-NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0) - TO_NUMBER(loc_Tab_acte(i).acteRC) - TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS) ;
         /*
          P_INS_journal(1,v_id_flux|| ' loc_Tab_acte(i).acteRemboursementSS:'||loc_Tab_acte(i).acteRemboursementSS);
          P_INS_journal(1,v_id_flux|| ' loc_Tab_acte(i).acteBaseSS:'||loc_Tab_acte(i).acteBaseSS);
          P_INS_journal(1,v_id_flux|| ' loc_Tab_acte(i).prixActe:'||loc_Tab_acte(i).prixActe);
          P_INS_journal(1,v_id_flux|| ' loc_Tab_acte(i).acteRC:'||loc_Tab_acte(i).acteRC);
          P_INS_journal(1,v_id_flux|| ' loc_Tab_acte(i).acteRAC:'||loc_Tab_acte(i).acteRAC);
          P_INS_journal(1,v_id_flux|| ' loc_ro_sup:'||loc_ro_sup);
          P_INS_journal(1,v_id_flux|| ' loc_depense_sup:'||loc_depense_sup);
          P_INS_journal(1,v_id_flux|| ' erreur_calcul_devis:'||erreur_calcul_devis);
          */
          ------------------------------------------------------------------------------
          -- --------------FIN Proratisation des montants
          ------------------------------------------------------------------------------
          IF loc_Tab_acte(i).nature_prest NOT IN ('VERSUP','LENSUP','AUDSUP') THEN
            CASE erreur_calcul_devis
              WHEN 0 THEN
                 loc_Tab_acte(i).messageInformatif := NVL( loc_Tab_acte(i).messageInformatif ,'service OK');
                 loc_statut:='ACCEPTE';
              WHEN 6 THEN
                  IF loc_mtprest = 0 THEN
                    loc_Tab_acte(i).messageInformatif:='Pas de reboursement possible : cette prestation est soumise a un delai de carence';
                    loc_statut:='REFUSE';
                    loc_totalRC:=0;
                    loc_Tab_acte(i).acteRC:=0;
                    loc_messageErreur := 'Pas de reboursement possible : cette prestation est soumise a un delai de carence';
                  ELSE
                    loc_Tab_acte(i).messageInformatif:='Attention, il s''agit d''un remboursement partiel, une partie de la garantie pour cette prestation est soumise a un delai de carence';
                    loc_statut:='ACCEPTE';
                  END IF;
              WHEN 7 THEN
                  IF loc_mtprest = 0 THEN
                    loc_Tab_acte(i).messageInformatif:='Pas de reboursement possible : le plafond de remboursement pour cette prestation a ete atteint lors d''un precedent remboursement';
                    loc_statut:='REFUSE';
                    loc_totalRC:=0;
                    loc_Tab_acte(i).acteRC:=0;
                    loc_messageErreur := 'Plafond atteint ou aucun remboursement complémentaire';
                  ELSE
                    loc_Tab_acte(i).messageInformatif:='Attention, il s''agit d''un remboursement partiel : le plafond de remboursement est atteint';
                    loc_statut:='ACCEPTE';
                  END IF;
               ELSE
                  IF loc_attente < 4 THEN
                    loc_mtprest:=0;
                    loc_Tab_acte(i).messageInformatif:='Une des donnees est incorrecte ou calcul impossible';
                    loc_statut:='REFUSE';
                  ELSE
                    loc_ErreurTechnique:='false';
                    loc_codeReponse:='true';
                    loc_statut:='EN ATTENTE';
                  END IF;
            END CASE;
          END IF;
          P_INS_journal(3,v_id_flux|| ' loc_Tab_acte(i).messageInformatif après DEVIS: '||loc_Tab_acte(i).messageInformatif );
          -- Faire les totaux
          IF NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise)/100,0) = 0 THEN
            loc_totalDepense        :=  TO_CHAR(TO_NUMBER(NVL(loc_totalDepense,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).prixActe,0)));
          ELSE
            loc_totalDepense        :=  TO_CHAR(TO_NUMBER(NVL(loc_totalDepense,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).prixActeRemise,0)));
          END IF;
     --     END IF;  -- IF loc_attente < 4 THEN
          loc_totalRC             :=  TO_CHAR(TO_NUMBER(NVL(loc_totalRC,0)) +  TO_NUMBER(NVL(loc_Tab_acte(i).acteRC,0)));
          loc_totalRAC            :=  TO_CHAR(TO_NUMBER(NVL(loc_totalRAC,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).acteRAC,0)));
          loc_totalRemboursementSS:=  TO_CHAR(TO_NUMBER(NVL(loc_totalRemboursementSS,0)) + NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS),0));
          P_INS_journal(3,v_id_flux|| ' totaux, loc_totalDepense: '||loc_totalDepense );
          P_INS_journal(3,v_id_flux|| ' totaux, loc_totalRAC: '||loc_totalRAC );
          P_INS_journal(3,v_id_flux|| ' totaux, loc_totalRC: '||loc_totalRC );
        END LOOP;

        IF NVL(loc_totalRC,0) = 0 THEN
          IF loc_attente < 4 THEN
          --  loc_messageInformatif:='Plafond atteint ou aucun remboursement complémentaire';
         --   loc_statut:='ACCEPTE';
            loc_ErreurTechnique:='false';
            loc_codeReponse:='false';
            loc_messageErreur := 'Plafond atteint ou aucun remboursement complémentaire';
            loc_numeroDossierExperteo:=NULL;
            loc_identifiantDossierAMC:=NULL;
            loc_statut:='REFUSE';
          ELSE
            loc_ErreurTechnique:='false';
            loc_codeReponse:='true';
            loc_statut:='EN ATTENTE';
          END IF;
        END IF;

      ELSIF loc_type = 1 THEN -- PEC
        ------------------------------------------------------------------------------
        ----------------------- CALCUL DE LA PEC -------------------------------------
        ------------------------------------------------------------------------------
        i:=0;
        loc_totalDepense         :=  0;
        loc_totalRC              :=  0;
        loc_totalRAC             :=  0;
        loc_totalRemboursementSS :=  0;

        --mise en place de la dérogation optique RAC WS pour les PEC
        k :=0;
        P_INS_journal(1,v_id_flux|| ' rko PEC loc_domaine '||loc_domaine/*||' tableau des actes loc_Tab_acte(i) '||loc_Tab_acte(i).codfrais*/);
        l_derog :=null;
        IF loc_domaine = 0 THEN
          FOR k IN 1 .. loc_t_equip.COUNT LOOP
              IF loc_t_equip(k).acteType_verr IS NOT NULL  OR loc_t_equip(k).acteType_mont IS NOT NULL  --RKO WS RAC DEROG
                  OR loc_t_equip(k).acteType_sup_ver IS NOT NULL OR loc_t_equip(k).acteType_sup_mon IS NOT NULL THEN  -- M0007220 dérogation des supplements
                P_INS_journal(1,v_id_flux|| ' rko dans if loc_t_equip '||loc_t_equip(k).acteType_verr ||loc_t_equip(k).acteType_mont||' acte '||loc_Tab_acte(k).codfrais);
                --Revue du code dans le cadre du ticket ARTGEREP_398
                --reinitialisation de l'oeil droit
                --distinction oeil droit et gauche afin de ne pas passer le meme oeil à la F_derogOptique cf M0007228
                --M0007214 et ARTGEREP_398 reinitialisation des object loc_verre_droit et loc_verre_gauche avec null afin de :
                   -- ne pas deroger avec les caractéristiques 0 sur une monture
                   -- de passer uniquement le bon oeil à la fonction de derog dans la boucle du tableau des actes loc_Tab_acte(i)
                loc_verre_droit.oeil := null;
                loc_verre_droit.sphere := null ;
                loc_verre_droit.cylindre := null;
                loc_verre_droit.addition := null;
                loc_verre_droit.axe :=  null;
                --reinitialisation de l'oeil gauche
                loc_verre_gauche.oeil := null;
                loc_verre_gauche.sphere := null ;
                loc_verre_gauche.cylindre := null;
                loc_verre_gauche.addition := null;
                loc_verre_gauche.axe :=  null;
              --recupération des sinistres verres du flux
                IF loc_t_equip(k).oeil = 0 THEN --oeil droit
                   --loc_sinistre_verre.oeil := 'D';
                   loc_verre_droit.oeil := 'D';
                   loc_verre_droit.sphere := NVL(loc_t_equip(k).sphere,0)  ;
                   loc_verre_droit.cylindre := NVL(loc_t_equip(k).cylindre,0);
                   loc_verre_droit.addition := NVL(loc_t_equip(k).addition,0);
                   loc_verre_droit.axe :=  NVL(loc_t_equip(k).axe,0);
                ELSIF loc_t_equip(k).oeil = 1 THEN--oeil gauche
                   --loc_sinistre_verre.oeil := 'G';
                   loc_verre_gauche.oeil := 'G';
                   loc_verre_gauche.sphere := NVL(loc_t_equip(k).sphere,0)  ;
                   loc_verre_gauche.cylindre := NVL(loc_t_equip(k).cylindre,0);
                   loc_verre_gauche.addition := NVL(loc_t_equip(k).addition,0);
                   loc_verre_gauche.axe :=  NVL(loc_t_equip(k).axe,0);
                END IF;
              END IF;  --acteType_verr et acteType_mont
              P_INS_journal(1,v_id_flux|| ' rko les verres sphere_dro '||loc_verre_droit.sphere|| ' cyl_dr '||loc_verre_droit.cylindre|| ' add_dr '||loc_verre_droit.addition||' axe_dr '||loc_verre_droit.axe||' codfrais '||loc_Tab_acte(k).codfrais);
              P_INS_journal(1,v_id_flux|| ' rko les verres sphere_gc '||loc_verre_gauche.sphere|| ' cyl_gc '||loc_verre_gauche.cylindre|| ' add_gc '||loc_verre_gauche.addition||' axe_gc '||loc_verre_gauche.axe||' codfrais '||loc_Tab_acte(k).codfrais);
              --P_INS_journal(1,v_id_flux|| ' rko appel de f_derogOptique verre sphere '||loc_sinistre_verre.sphere|| ' cylindre '||loc_sinistre_verre.cylindre|| ' addition '||loc_sinistre_verre.addition||' axe '||loc_sinistre_verre.axe||' codfrais '||loc_Tab_acte(i).codfrais);
              loc_res_derog := PK_FUNCT.F_DerogOptique (p_numIndiv    =>loc_Tab_Indiv('bene').numindiv
                                                      , p_datSin       => TRUNC(sysdate)--ajout du trunc ARTGEREP_398
                                                      , p_codFrais     =>loc_Tab_acte(k).codfrais
                                                      , p_verre_droit  =>loc_verre_droit --loc_sinistre_verre -- M0007228
                                                      , p_verre_gauche =>loc_verre_gauche --loc_sinistre_verre
                                                       ) ;
              P_INS_journal(1,v_id_flux|| ' rko loc_res_derog.derogOptique '||loc_res_derog.derogOptique ||' information '||loc_res_derog.information||' codfrais '||loc_Tab_acte(k).codfrais);
              --des lors qu'un acte est dérog, les autres sont dérogeables également
              IF loc_res_derog.derogOptique ='OUI' THEN
                l_derog :='OPTI';
                EXIT;-- sortie de boucle dès qu'un acte est dérogé
              END IF;
          END LOOP;
        END IF;--domaine
        P_INS_journal(1,v_id_flux|| ' rko apres f_derog l_derog '||l_derog );
        LOOP
          loc_mtprest:=0;
          loc_erreur_dossier:=0;
          loc_blocage:=NULL;
          P_INS_journal(1,v_id_flux|| '  CALCUL DE LA PEC : Boucle sur les actes');
          i := i +1;
          loc_codfraisITELIS :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteType',null,1);
          IF TRIM(loc_codfraisITELIS) IS NULL THEN
            EXIT;
          END IF;
          IF i=1 AND loc_Tab_acte(i).nature_prest IN ('VERSUP','LENSUP','AUDSUP') THEN
            RAISE exc_prestation_ko;
          END IF;
          P_INS_journal(1,v_id_flux|| ' CALCUL DE LA PEC, loc_codfraisITELIS: ' || loc_codfraisITELIS);

          P_INS_journal(1,v_id_flux|| ' loc_Tab_acte(i).codfrais:'||loc_Tab_acte(i).codfrais );
          P_INS_journal(1,v_id_flux|| ' acteRemboursementSS:'||loc_Tab_acte(i).acteRemboursementSS);
          P_INS_journal(1,v_id_flux|| ' acteBaseSS:'||loc_Tab_acte(i).acteBaseSS);
          P_INS_journal(1,v_id_flux|| ' prixActe:'||loc_Tab_acte(i).prixActe);
          P_INS_journal(1,v_id_flux|| ' loc_tauxRemboursement:'||loc_tauxRemboursement);
          P_INS_journal(1,v_id_flux|| ' numindiv:'||loc_Tab_Indiv('bene').numindiv);
          P_INS_journal(1,v_id_flux|| ' nature:'||loc_Tab_acte(i).nature_prest);

          -- Detection d un supplément
          /*loc_ro_sup:=0; --RKO RAC OPTIQUE gestion des supplements
          loc_depense_sup:=0;
          BEGIN
            IF  loc_Tab_acte(i+1).nature_prest IN ('VERSUP','LENSUP','AUDSUP') THEN
              loc_ro_sup:=NVL(TO_NUMBER(loc_Tab_acte(i+1).acteRemboursementSS),0);
              loc_depense_sup:= NVL(TO_NUMBER(loc_Tab_acte(i+1).prixActe),0);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              loc_ro_sup:=0;
              loc_depense_sup:=0;
          END;*/
          P_INS_journal(1,v_id_flux|| ' nature2:'||loc_Tab_acte(i).nature_prest);
          -- Deduction de la remise si une remise existe sur l'acte
          IF NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0) > 0 THEN
            loc_Tab_acte(i).prixActeRemise:= TO_CHAR(NVL(TO_NUMBER(loc_Tab_acte(i).prixActe),0) - NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0));
          END IF;

          --IF  loc_Tab_acte(i).nature_prest NOT IN ('VERSUP','LENSUP','AUDSUP') THEN   -- Aucun contrôles si l acte externe est un supplément RKO

            IF loc_domaine = 1 THEN

              P_DENT (p_dentaire =>loc_t_dentaire(i),
                  p_domaine =>loc_domaine,
                  o_items =>loc_o_items,
                  P_IO_TRAV_SAISIE =>P_TRAV_SAISIE);
              P_INS_journal(1,v_id_flux|| ' acte dentaire '||i|| ' Contrôle doublon sur '||loc_t_dentaire(i).numerosDents);
              loc_doublon_dent := F_CTRL_DOUBLON_DENT( i_numindiv => loc_Tab_Indiv('bene').numindiv,
                                                i_nodent =>loc_t_dentaire(i).numerosDents,
                                                i_date =>ADD_MONTHS(sysdate, -24),
                                                i_codfrais =>loc_Tab_acte(i).codfrais,
                                                i_numsin =>null,
                                                i_numdoss => loc_num_dossier
                                                );


              IF loc_doublon_dent = 1 then
                 loc_blocage :=3;
                 loc_Tab_acte(i).messageErreur := 'Plafond atteint ou aucun remboursement complémentaire';
                 loc_Tab_acte(i).messageInformatif:= 'Soin de même nature déjà effectué sur cette dent sur les 2 dernières années';
                 P_INS_journal(1,v_id_flux|| ' acte dentaire '||loc_Tab_acte(i).codfrais|| ' avec blocage '||loc_doublon_dent);
              ELSE
               P_INS_journal(1,v_id_flux|| ' acte dentaire '||loc_Tab_acte(i).codfrais|| ' sans blocage '||loc_doublon_dent);
              End if;
            END IF;
               -- Création des prestations
            PK_CTRL_TP.P_INS_SNTR_SANTE(
                        P_num_dossier => loc_num_dossier,
                        P_numligne    => i,
                        P_numindiv    => loc_Tab_Indiv('bene').numindiv,
                        P_codfrais    => loc_Tab_acte(i).codfrais,
                        P_mtfrais     => NVL(TO_NUMBER(loc_Tab_acte(i).prixActe)/100,0)+ NVL(loc_depense_sup/100,0)- NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise)/100,0),
                        P_etat        => 1,
                        P_taux        => TO_NUMBER(loc_tauxRemboursement),
                        P_baseremb    => TO_NUMBER(loc_Tab_acte(i).acteBaseSS)/100,
                        P_mtremb      => NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS)/100,0)  + NVL(loc_ro_sup/100,0),
                        P_datsin      => SYSDATE,
                        P_coeff       => 1, -- loc_Tab_acte(compteur).COEFF_ACTE,
                        P_quantite    => loc_quantite,
                        p_pdsqls      => 1,
                        p_spe_exe     => '01',
                        p_bloc        => NVL(loc_blocage,0)
                        );


            PK_CTRL_TP.P_INS_HISTO_SNTR_SANTE(
                      P_num_dossier => loc_num_dossier,
                      P_numligne    => i,
                      P_etat        => 1,
                      P_motif       => 0);

            IF loc_domaine = 1 THEN  --dentaire
              PK_CTRL_TP.P_MAJ_SNTR_SANTE_LOCDEN(
                          loc_num_dossier
                        , i
                        , loc_o_items(1)
                        , loc_o_items(2)
                        , loc_o_items(3)
                        , loc_o_items(4)
                        , loc_o_items(5)
                        , loc_o_items(6)
                        , loc_o_items(7)
                        , loc_o_items(8)
                        , loc_o_items(9)
                        , loc_o_items(10)
                        , loc_o_items(11)
                        , loc_o_items(12)
                        , loc_o_items(13)
                        , loc_o_items(14)
                        , loc_o_items(15)
                        , loc_o_items(16)
                       );

            END IF;

            P_INS_journal(1,v_id_flux|| '  PEC : Après PK_CTRL_TP.P_INS_SNTR_SANTE:'||loc_num_dossier);

            -- Calcul des actes du dossier santé
            IF loc_num_dossier > 0 THEN

                -- insertion du réseau de soins si celui-ci est existant sur la porte ainsi que les dents si c est une PEC dentaire
                -- Cette insertion est un pansement pour palier le fait que la dll ne récupère pas la bonne session entre PK_ITELIS et gs19_xit (2 connexions Arthus, donc 2 sid différents)
                P_TRAV_SAISIE.NUMLIG:= i;
                cpt_trav :=0;
                IF loc_domaine = 0 AND loc_Tab_acte(i).nature_prest = 'VER'THEN -- optique
                  --Saisie des verres dans trav_saisie pour enreg dans sinistre_verre
                  loc_trav :=P_TRAV_SAISIE;
                --Saisie de l'oeil Droit /Gauche
                IF loc_t_verre(i).oeil = 0 THEN
                   loc_trav.oeil := 'D';
                ELSIF loc_t_verre(i).oeil = 1 THEN
                   loc_trav.oeil := 'G';
                END IF;
                loc_trav.sphere :=NVL(loc_t_verre(i).sphere,0);
                loc_trav.cylindre :=NVL(loc_t_verre(i).cylindre,0);
                loc_trav.addition :=NVL(loc_t_verre(i).addition,0);
                loc_trav.axe := NVL(loc_t_verre(i).axe,0);
                --puis insertion
                P_INSERT_TRAV_SAISIE(  loc_trav );
                cpt_trav := cpt_trav +1;
                END IF;

                IF cpt_trav = 0 THEN
                  P_INSERT_TRAV_SAISIE(  P_TRAV_SAISIE );
                END IF;
                COMMIT;

                -- Recherche des infos précédement insérés lors de la dernière PEC
             --  JBO 10/07/2018 loc_dioptrie:=F_FIND_INFOS_VERRES(loc_Tab_Indiv('bene').numindiv,loc_Tab_acte(i).codfrais,loc_numfor , i /*, loc_Tab_acte*/, loc_t_verre, loc_num_dossier);


                P_INS_journal(1,v_id_flux|| ' ***loc_domaine:  '||loc_domaine);

                P_INS_journal(1,v_id_flux|| ' ***loc_dioptrie 2:  '||loc_dioptrie);
                P_INS_journal(1,v_id_flux|| ' ***loc_attente:  '||loc_attente);

                -- Si les infos sur les verres optique correspondent à un changement de diopterie, alors on met le dossier en attente
         /*  JBO 10/07/2018     IF loc_dioptrie=0 AND loc_domaine = 0 THEN   -- Optique    -- chagement de dioptrie    : JBO : M5659 (ajout de AND loc_domaine = 0)
                  loc_attente:=4;
                  loc_statut:='EN ATTENTE';
                  UPDATE HISTO_DOSSIER SET MOTIF = 8 WHERE NUM_DOSSIER = loc_num_dossier;
                  P_INS_journal(1,v_id_flux|| ' ***SET MOTIF, loc_statut:  '||loc_statut);
                END IF;      */
                P_INS_journal(1,v_id_flux|| ' ***loc_attente 2:  '||loc_attente);
                P_INS_journal(1,v_id_flux|| ' ***loc_statut 2:  '||loc_statut);
                IF loc_attente < 4 /*OR loc_statut<>'EN ATTENTE' */ THEN
                  P_INS_journal(1,v_id_flux|| ' rko avant appel de p_calcul_dossier l_derog '||l_derog||' dossier '||loc_num_dossier );
                  PK_CALCUL_DOSSIER.P_CALCUL_DOSSIER_SANTE(P_num_dossier => loc_num_dossier,
                                                           P_type        => 'devis',
                                                           P_tot_prest   => -1,
                                                           O_erreur      => loc_erreur_dossier,
                                                           O_msg_erreur  => loc_msg_dossier,
                                                           p_derog       => l_derog --paramètre définissant la derogation (ou pas) lors du calcul
                                                           );

                  P_INS_journal(1,v_id_flux|| ' rko apres appel de p_calcul_dossier l_derog '||l_derog||' dossier '||loc_num_dossier );
                  P_INS_journal(1,v_id_flux|| ' loc_erreur_dossier:' || loc_erreur_dossier);
                  P_INS_journal(1,v_id_flux|| ' loc_msg_dossier:' || loc_msg_dossier);

                  IF loc_erreur_dossier IN (5,9) THEN
                    P_INS_journal(1,v_id_flux|| '  RAISE exc_dossier, loc_erreur_dossier = 5,9');
                    loc_ErreurTechnique:='false';
                    loc_codeReponse:='false';
                    loc_Tab_acte(i).messageErreur := 'Aucune prestation du dossier à calculer';
                    loc_numeroDossierExperteo:=NULL;
                    loc_identifiantDossierAMC:=NULL;
                    loc_Tab_acte(i).messageInformatif:='Aucune prestation du dossier à calculer';
                    loc_statut:='REFUSE';
                    loc_messageErreur := 'Plafond atteint ou aucun remboursement complémentaire';
                    loc_totalDepense := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalDepense',null,1);
                    loc_totalRemboursementSS := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRemboursementSS',null,1);
                    loc_totalRC := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRC',null,1);
                    loc_totalRAC := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRAC',null,1);
                    PK_CTRL_TP.P_SUP_DOSSIER_SANS_PREST_WS(loc_num_dossier);
                    COMMIT;
                    EXIT;
                  ELSIF loc_erreur_dossier = 6 THEN      -- Carence
                    loc_Tab_acte(i).messageInformatif:='Cette prestation fait l''objet d''une carence';
                    loc_statut:='ACCEPTE';
                  ELSIF loc_erreur_dossier = 7 THEN     -- Plafond
                    loc_Tab_acte(i).messageInformatif:='Cette prestation fait l''objet d''un plafond partiel ou atteint';
                    loc_statut:='ACCEPTE';
                  ELSIF loc_erreur_dossier = 8 THEN     -- Franchise
                    loc_Tab_acte(i).messageInformatif:='Remboursement effectue en fonction de la franchise sur une garantie';
                    loc_statut:='ACCEPTE';
                  ELSIF loc_erreur_dossier = 10 THEN --le montant total RC = 0
                    P_INS_journal(1,v_id_flux|| '  RAISE exc_dossier, loc_erreur_dossier = 10');
                    loc_Tab_acte(i).messageInformatif:= 'Pas de reboursement possible : le plafond de remboursement pour cette prestation a ete atteint lors d''un precedent remboursement';
                    loc_statut:='ACCEPTE';
                    -- JBO : 11102018 permettre le calcul d une PEC même si on rembourse 0 sur 1 acte
                  /*  loc_statut:='REFUSE';
                    loc_totalRC:=0;
                    loc_messageErreur := 'Plafond atteint ou aucun remboursement complémentaire';
                    loc_Tab_acte(i).messageErreur := 'Plafond atteint ou aucun remboursement complémentaire';
                    loc_ErreurTechnique:='false';
                    loc_codeReponse:='false';
                    loc_numeroDossierExperteo:=NULL;
                    loc_identifiantDossierAMC:=NULL;
                    loc_totalDepense := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalDepense',null,1);
                    loc_totalRemboursementSS := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRemboursementSS',null,1);
                    loc_totalRC := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRC',null,1);
                    loc_totalRAC := PK_XML.EXTRACT_DATA(P_Question,loc_path_prestation||'/totalRAC',null,1);
                    ROLLBACK;
                    EXIT;    */
                  ELSE
                    P_INS_journal(1,v_id_flux|| ' enregistrement des sinistres:'||loc_erreur_dossier);
                    loc_Tab_acte(i).messageInformatif:='Enregistrement des sinistres OK';
                    loc_statut:='ACCEPTE';
                  END IF;
                END IF;
            --END IF;

            IF loc_statut='ACCEPTE' THEN
              -- on récupère les montants pour chaque acte sauf les suppléments
              SELECT NVL(SUM(MTFRAIS),0),NVL(SUM(MTPREST_REEL),0),NVL(SUM(MTREMB),0),NVL(SUM(AUTRB_DAUTRB),0),NVL(SUM(QUANTITE),0)
                INTO loc_montant_dep,/*loc_montant_rc*/loc_mtprest,loc_montant_ro,loc_montant_autre,loc_quantite
                FROM SINISTRE_SANTE
               WHERE NUM_DOSSIER=loc_num_dossier
                 AND CODFRAIS = loc_Tab_acte(i).codfrais
                 AND numligne = i
            ORDER BY numligne ASC;
            END IF;

            --  loc_mtprest_Char:=REPLACE(TO_CHAR(loc_mtprest),',', '');
              loc_mtprest_Char:=REPLACE(TO_CHAR(loc_mtprest*100),'.', '');
              P_INS_journal(3,v_id_flux|| ' loc_mtprest_Char OK:'||loc_mtprest_Char );
              IF loc_domaine = 1 THEN   -- dentaire
                IF NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS)/100,0) = 0 THEN
                 loc_mtprest_Char:= loc_mtprest_Char * loc_t_dentaire(i).nombreDents;
                END IF;
              END IF;
            END IF;

          loc_Tab_acte(i).acteRC  :=  loc_mtprest_Char;
          ------------------------------------------------------------------------------
          -- --------------Proratisation des montants
          ------------------------------------------------------------------------------
          P_INS_journal(1,v_id_flux|| 'roratisation des montants loc_ro_sup:'||loc_ro_sup);
          P_INS_journal(1,v_id_flux|| ' loc_depense_sup:'||loc_depense_sup);
          --répartition des actes verre et monture
          /*IF loc_Tab_acte(i).nature_prest NOT IN ('VERSUP','LENSUP','AUDSUP') THEN RKO
            --ACTE avec a des suppléments
            IF NVL(loc_ro_sup,0)>0 OR NVL(loc_depense_sup,0)>0 THEN
              --si le montant de prestation verre+ sup >= FR verre -remise- SS verre
              IF TO_NUMBER(loc_mtprest_Char)>= (TO_NUMBER(loc_Tab_acte(i).prixActe) - NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0)- NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS),0)  ) THEN
                loc_Tab_acte(i).acteRC := TO_NUMBER(loc_Tab_acte(i).prixActe)- NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0)- NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS),0) ;
              ELSE
                P_INS_journal(1,v_id_flux|| ' *** avec supplément de '||loc_depense_sup ||' pour FR acte='||loc_Tab_acte(i).prixActe);
                loc_Tab_acte(i).acteRC := ROUND((TO_NUMBER(loc_Tab_acte(i).prixActe)*loc_mtprest_Char) / (TO_NUMBER(loc_Tab_acte(i).prixActe)+loc_depense_sup));
              END IF;
            --ACTE sans supplément
            ELSE
              loc_Tab_acte(i).acteRC  :=  loc_mtprest_Char;
            END IF;
          ELSE -- répartition des suppléments
            --RC sup = RC verre+ sup - RC verre
            P_INS_journal(1,v_id_flux|| ' ***RC supplément:'||loc_Tab_acte(i-1).acteRC);
            loc_Tab_acte(i).acteRC := loc_mtprest_Char-TO_NUMBER( loc_Tab_acte(i-1).acteRC);
          END IF;*/
          P_INS_journal(1,v_id_flux|| ' ***RC '||TO_NUMBER(loc_Tab_acte(i).acteRC));
          P_INS_journal(1,v_id_flux|| ' ***loc_statut:  '||loc_statut);
          P_INS_journal(1,v_id_flux|| ' ***loc_attente:  '||loc_attente);
          --RAC = FR - remise - RO - RC
          IF loc_attente<4 THEN      -- todo : voir si on utiliser le IF loc_statut='ACCEPTE' THEN, ligne 2499
            P_INS_journal(1,v_id_flux|| ' ***loc_attente 2:  '||loc_attente);
            loc_Tab_acte(i).acteRAC := TO_NUMBER(loc_Tab_acte(i).prixActe)-NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0) - TO_NUMBER(loc_Tab_acte(i).acteRC) - TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS) ;
          END IF;


          ------------------------------------------------------------------------------
          -- --------------FIN Proratisation des montants
          ------------------------------------------------------------------------------

          P_INS_journal(1,v_id_flux|| 'FIN Proratisation loc_statut:'||loc_statut);
          P_INS_journal(1,v_id_flux|| ' Calcul loc_mtprest:'||loc_mtprest);
          P_INS_journal(1,v_id_flux|| ' Calcul loc_Tab_acte(i).acteRemboursementSS:'||loc_Tab_acte(i).acteRemboursementSS);
          P_INS_journal(1,v_id_flux|| ' Calcul loc_Tab_acte(i).acteBaseSS:'||loc_Tab_acte(i).acteBaseSS);
          P_INS_journal(1,v_id_flux|| ' Calcul loc_Tab_acte(i).prixActe:'||loc_Tab_acte(i).prixActe);
          P_INS_journal(1,v_id_flux|| ' Calcul loc_Tab_acte(i).acteRC:'||loc_Tab_acte(i).acteRC);
          P_INS_journal(1,v_id_flux|| ' Calcul loc_Tab_acte(i).acteRAC:'||loc_Tab_acte(i).acteRAC);
          P_INS_journal(1,v_id_flux|| ' loc_montant_dep:'||loc_montant_dep);
          P_INS_journal(1,v_id_flux|| ' loc_montant_rc:'||loc_montant_rc);
          P_INS_journal(1,v_id_flux|| ' loc_montant_ro:'||loc_montant_ro);
          P_INS_journal(1,v_id_flux|| ' loc_montant_autre:'||loc_montant_autre);
          P_INS_journal(1,v_id_flux|| ' loc_quantite:'||loc_quantite);
          -- Faire les totaux
          IF NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise)/100,0) = 0 THEN
            loc_totalDepense        :=  TO_CHAR(TO_NUMBER(NVL(loc_totalDepense,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).prixActe,0)));
          ELSE
            loc_totalDepense        :=  TO_CHAR(TO_NUMBER(NVL(loc_totalDepense,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).prixActeRemise,0)));
          END IF;
          loc_totalRC             :=  TO_CHAR(TO_NUMBER(NVL(loc_totalRC,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).acteRC,0)));
          loc_totalRAC            :=  TO_CHAR(TO_NUMBER(NVL(loc_totalRAC,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).acteRAC,0)));
          loc_totalRemboursementSS:=  TO_CHAR(TO_NUMBER(NVL(loc_totalRemboursementSS,0)) + NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS),0));
          P_INS_journal(1,v_id_flux|| ' totaux, loc_totalDepense: '||loc_totalDepense );
          P_INS_journal(1,v_id_flux|| ' totaux, loc_totalRAC: '||loc_totalRAC );
          P_INS_journal(1,v_id_flux|| ' totaux, loc_totalRC: '||loc_totalRC );
        END LOOP;
        P_INS_journal(1,v_id_flux|| ' loc_totalRC:'||loc_totalRC);
        P_INS_journal(1,v_id_flux|| ' ***loc_attente 1:  '||loc_attente);
        IF NVL(loc_totalRC,0) = 0 THEN
          IF loc_attente < 4 THEN
          --  loc_messageInformatif:='Plafond atteint ou aucun remboursement complémentaire';
          --  loc_statut:='ACCEPTE';
            loc_ErreurTechnique:='false';
            loc_codeReponse:='false';
            loc_messageErreur := 'Plafond atteint ou aucun remboursement complémentaire';
            loc_numeroDossierExperteo:=NULL;
            loc_identifiantDossierAMC:=NULL;
            loc_statut:='REFUSE';
            P_INS_journal(1,v_id_flux|| ' ***loc_attente <4:  '||loc_attente);
            PK_CTRL_TP.P_SUP_DOSSIER_SANS_PREST_WS(loc_num_dossier);
            COMMIT;
          ELSE
            loc_ErreurTechnique:='false';
            loc_codeReponse:='true';
            loc_statut:='EN ATTENTE';

            loc_objet_email:='ITELIS : Dossier '||loc_num_dossier||' en attente';
            loc_mess_email:='ITELIS : Le dossier '||loc_num_dossier||' est en attente. Veuillez calculer les prestations et notifier ITELIS';
            -- On envoi le mail
           -- P_envoi_Mail(loc_objet_email, loc_mess_email) ;

          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN exc_prestation_ko THEN
        P_INS_journal(1,v_id_flux|| ' Aucune prestation du dossier à calculer ou Montant RC different');
        loc_ErreurTechnique:='false';
        loc_codeReponse:='false';
        loc_messageErreur := 'Aucune prestation du dossier à calculer ou Montant RC different';
        loc_numeroDossierExperteo:=NULL;
        loc_identifiantDossierAMC:=NULL;
        loc_totalDepense        :=  TO_CHAR(TO_NUMBER(NVL(loc_totalDepense,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).prixActeRemise,0)));
        loc_totalRC             :=  TO_CHAR(TO_NUMBER(NVL(loc_totalRC,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).acteRC,0)));
        loc_totalRAC            :=  TO_CHAR(TO_NUMBER(NVL(loc_totalRAC,0)) + TO_NUMBER(NVL(loc_Tab_acte(i).acteRAC,0)));
        loc_totalRemboursementSS:=  TO_CHAR(TO_NUMBER(NVL(loc_totalRemboursementSS,0)) + NVL(TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS),0));

        loc_statut:='REFUSE';
      WHEN exc_devis_en_attente THEN
        P_INS_journal(1,v_id_flux|| ' Devis non géré en cas de double vision ou changement de dioptrie');
      WHEN OTHERS THEN
        P_INS_journal(1,v_id_flux|| ' F_CALCULRC, Devis/PEC KO' || sqlerrm);
        loc_statut:='ABANDONNE';
    END;
  END IF; -- IF loc_statut NOT IN ('REFUSE','ABANDONNE') THEN

  EXCEPTION
    WHEN  exc_erreur_saisi THEN
      P_INS_journal(1,v_id_flux|| ' Saisie d''une information erronée de l entete, dossier, practicien ou de la prestation');
  END;
  -- ***************************************************************************
  -- ********************** FIN LANCEMENT DU CALCUL DU DEVIS OU PEC ************
  -- ***************************************************************************

  loc_Reponse := XMLTYPE('<ns6:calculRCResponse '||loc_xmlns||'></ns6:calculRCResponse>');
  ----------------------------------------------------------------------------
  ------------------------CREATION DE L'ENTETE-------------------------------
  ----------------------------------------------------------------------------
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse,path=>'ns6:calculRCResponse', children=>'ns6:enTete', xmlns=>loc_xmlns );
  loc_path_courant :='ns6:calculRCResponse/ns6:enTete';
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:dateMessage', child_val => loc_dateMessage);
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:nomClient', child_val=> loc_nomClient);
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:erreurTechnique', child_val=>loc_ErreurTechnique);
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:codeReponse', child_val=>loc_codeReponse);
  IF TRIM(loc_identifiantDossierAMC) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:identifiantDossierAMC', child_val=> loc_identifiantDossierAMC ); -- loc_num_dossier);
  END IF;
  IF TRIM(loc_messageErreur) IS NOT NULL OR TRIM(loc_messageErreur1) IS NOT NULL  THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val=>NVL(loc_messageErreur,loc_messageErreur1));
  END IF;
  IF TRIM(loc_messageInformatif) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageInformatif', child_val=>loc_messageInformatif);
  END IF;
  IF TRIM(loc_numeroDossierExperteo) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:numeroDossierExperteo', child_val=> loc_numeroDossierExperteo  ); -- loc_num_dossier);
  END IF;
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:versionWSDL', child_val=>'0');

  IF loc_ErreurTechnique = 'false' THEN
    --creation de la balise dossier
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse,path=>'ns6:calculRCResponse', children=>'ns6:dossier', xmlns=>loc_xmlns );
    loc_path_courant :='ns6:calculRCResponse/ns6:dossier';
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:domaine', child_val => loc_domaine);
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:type', child_val => loc_type);
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:statut', child_val => loc_statut);
     -- loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:datePrescriptionMedicale', child_val => '2016-12-24');
     -- loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:suspect', child_val => '1');
     -- loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:offreConvention', child_val => '1');

    --creation de la balise prestation
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse,path=>'ns6:calculRCResponse', children=>'ns6:prestation', xmlns=>loc_xmlns );
    loc_path_courant :='ns6:calculRCResponse/ns6:prestation';
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:nombreActes', child_val => loc_nombreActes);
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:totalDepense', child_val => REPLACE(loc_totalDepense,'.', ''));
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:totalRemboursementSS', child_val => REPLACE(loc_totalRemboursementSS,'.', ''));
    IF loc_statut IN ('REFUSE', 'ABANDONNE') THEN
      loc_totalRAC:= NVL(TO_NUMBER(loc_totalDepense),0) - NVL(TO_NUMBER(loc_totalRemboursementSS),0);
      loc_totalRC:=0;
    END IF;
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:totalRC', child_val => REPLACE(loc_totalRC,'.', ''));
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:totalRAC', child_val => REPLACE(loc_totalRAC,'.', ''));


    -- creation de la balise englobate de detailAtcteS
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse,path=>'ns6:calculRCResponse', children=>'ns6:detailActes', xmlns=>loc_xmlns );
    loc_path_courant :='ns6:calculRCResponse/ns6:detailActes';

    --- POUR CHAQUE LIGNE DU DETAIL DES ACTES, BOUCLER ET APPELER F_GETXML_DETAIL_ACTE_CALCUL
    i:=0;
    LOOP
      BEGIN
        i:=i+1;
        loc_codfraisITELIS :=PK_XML.EXTRACT_DATA(P_Question,loc_path_detailActes || '/detailActe['||i||']/acteType',null,1);
        IF TRIM(loc_codfraisITELIS) IS NULL THEN
          EXIT;
        END IF;
    /*    P_INS_journal(1,v_id_flux|| ' i: ' || i);
        P_INS_journal(1,v_id_flux|| ' BOUCLE ACTES REPONSE, codfraisITELIS: ' || loc_codfraisITELIS ||' codfrais :'||loc_Tab_acte(i).codfrais);
        P_INS_journal(1,v_id_flux|| ' BOUCLE ACTES REPONSE, codeReponse: '||loc_codeReponse||' messageErreur: ' || loc_messageErreur);
        P_INS_journal(1,v_id_flux|| ' BOUCLE ACTES REPONSE, loc_messageInformatif: ' || loc_messageInformatif);
        P_INS_journal(1,v_id_flux|| ' BOUCLE ACTES REPONSE, prixActeRemise: ' || loc_Tab_acte(i).prixActeRemise);
        P_INS_journal(1,v_id_flux|| ' BOUCLE ACTES REPONSE, prixRemise: ' || loc_Tab_acte(i).prixRemise);   */
        loc_detail_acte := F_GETXML_DETAIL_ACTE_CALCUL( loc_Tab_acte,
                                                        i,
                                                        loc_codeReponse,
                                                        loc_messageErreur,
                                                        loc_messageInformatif,
                                                        loc_statut);

        loc_Reponse := pk_xml.APPENDCHILDXML(doc=>loc_Reponse,path=>loc_path_courant, children=>'ns6:detailActe', xmlns=>loc_xmlns, child_val =>loc_detail_acte  );

      EXCEPTION
        WHEN OTHERS THEN
          P_INS_journal(1,v_id_flux|| ' F_CALCULRC, Devis KO' || sqlerrm);
          loc_statut:='ABANDONNE';
          ROLLBACK;
      END;
    END LOOP;
  END IF; --pas ko technique
  -- Suppression des données enregistrées dans travsn (données conservées pour le calcul de plafond/franchise/carence)
  PK_CALCUL_DOSSIER.P_Delete_travsn(P_sid=>l_sid);
  COMMIT;
  -- ***************************************************************************
  -- ******************** Historisation de la response *************************
  -- ***************************************************************************
  pk_ws.add_xml(p_id_type => 25,
                p_id_flux => v_id_flux,
                p_doc_xml => loc_Reponse,
                p_cod_err => v_cod_err);

   v_delai := DBMS_UTILITY.GET_TIME- v_deb;
   pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  P_INS_journal(1,v_id_flux|| '  Fin normale de la procédure F_CALCULRC');
  RETURN loc_Reponse;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,v_id_flux|| ' F_CALCULRC: ' || sqlerrm);
END F_CALCULRC;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_GETXML_DETAIL_ACTE_CALCUL                               */
/* Type         :  Public                                                    */
/* Description  :  F_GETXML_DETAIL_ACTE_CALCUL                               */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_GETXML_DETAIL_ACTE_CALCUL( loc_Tab_acte             IN OUT TAB_T_ACTE,
                                      i                        IN     NUMBER,
                                      loc_codeReponse          IN     VARCHAR2,
                                      loc_messageErreur        IN     VARCHAR2,
                                      loc_messageInformatif    IN     VARCHAR2,
                                      loc_statut               IN     VARCHAR2)
RETURN XMLTYPE
IS
  loc_retour XMLTYPE;
  loc_xmlns  VARCHAR2(50);
  loc_path_courant VARCHAR2(200);
  loc_reponse     VARCHAR2(50);
BEGIN
  P_INS_journal(1,'1 F_GETXML_DETAIL_ACTE_CALCUL, loc_statut: ' || loc_statut);
  IF loc_statut IN ('REFUSE', 'ABANDONNE') THEN
    loc_Tab_acte(i).acteRC:=0;
    loc_Tab_acte(i).acteRAC:=TO_NUMBER(loc_Tab_acte(i).prixActe)-NVL(TO_NUMBER(loc_Tab_acte(i).prixRemise),0) - TO_NUMBER(loc_Tab_acte(i).acteRC) - TO_NUMBER(loc_Tab_acte(i).acteRemboursementSS) ;
  ELSIF loc_statut IN ('1') THEN
    loc_reponse:='true';
  END IF;

  loc_xmlns := 'xmlns:ns6="http://ws.jalma.com/stdclient"';
  loc_path_courant := 'ns6:detailActe';
  -- creation l'itération sur sur bénéficiaire
  loc_retour :=  XMLTYPE('<ns6:detailActe '||loc_xmlns||'></ns6:detailActe>');

  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:numeroActe', child_val => loc_Tab_acte(i).numeroActe);
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:identiteActeReference', child_val => loc_Tab_acte(i).identiteActeReference);
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:libelleActe', child_val => REPLACE(loc_Tab_acte(i).libelleActe, '&',' ') );
 -- loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:codeActeSS', child_val => 'CCAM');  -- TODO : Acte CCAM
  IF TRIM(loc_Tab_acte(i).prixActe) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:prixActe', child_val => REPLACE(loc_Tab_acte(i).prixActe,'.', ''));
  END IF;
  IF TRIM(loc_Tab_acte(i).prixRemise) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:prixRemise', child_val => REPLACE(loc_Tab_acte(i).prixRemise,'.', ''));
  END IF;
  IF TRIM(loc_Tab_acte(i).prixRemise) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:prixRemise', child_val => REPLACE(loc_Tab_acte(i).prixRemise,'.', ''));
  END IF;
  IF TRIM(loc_Tab_acte(i).prixActeRemise) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:prixActeRemise', child_val => REPLACE(loc_Tab_acte(i).prixActeRemise,'.', ''));
  END IF;
  IF TRIM(loc_Tab_acte(i).acteBaseSS) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:acteBaseSS', child_val => REPLACE(loc_Tab_acte(i).acteBaseSS,'.', ''));
  END IF;
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:acteRemboursementSS', child_val => REPLACE(loc_Tab_acte(i).acteRemboursementSS,'.', ''));
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:acteRC', child_val => REPLACE(loc_Tab_acte(i).acteRC,'.', ''));
  loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:acteRAC', child_val => REPLACE(loc_Tab_acte(i).acteRAC,'.', ''));
  IF TRIM(NVL(loc_codeReponse,loc_reponse)) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:codeReponse', child_val => NVL(loc_codeReponse,loc_reponse));
  END IF;
  IF TRIM (loc_Tab_acte(i).messageErreur) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val => TRIM(loc_Tab_acte(i).messageErreur));
  ELSIF TRIM (loc_messageErreur) IS NOT NULL THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val => TRIM(loc_messageErreur));
  ELSIF loc_codeReponse ='false' THEN
    loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val => TRIM('Calcul impossible'));
  END IF;
  IF loc_statut <> '1' THEN
    IF TRIM (loc_Tab_acte(i).messageInformatif) IS NOT NULL THEN
      loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageInformatif', child_val => TRIM(loc_Tab_acte(i).messageInformatif));
    ELSIF TRIM (loc_messageInformatif) IS NOT NULL THEN
      loc_retour := pk_xml.APPENDCHILD(doc=>loc_retour, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageInformatif', child_val => TRIM(loc_messageInformatif));
    END IF;
  END IF;

  RETURN loc_retour;
END F_GETXML_DETAIL_ACTE_CALCUL;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FACTURATION                                             */
/* Type         :  Public                                                    */
/* Description  :  F_FACTURATION                                             */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FACTURATION (P_Question IN XMLTYPE)
RETURN XMLTYPE
IS
  xmlretour                     XMLTYPE;
  loc_xmlns                     VARCHAR2(50);
  loc_path_courant              VARCHAR2(50);
  loc_Reponse                   XMLTYPE;
  loc_detail_acte               XMLTYPE;
  v_cod_err                     NUMBER:=0;
  g_grpporte                    NUMBER(2) := 22;
  v_id_flux                     NUMBER:=NULL;
  v_deb                         NUMBER;
  v_delai                       NUMBER;

  -- entete
  loc_path_entete               VARCHAR2(100) :='ns2:FacturationRequest/enTete';
  loc_dateMessage               VARCHAR2(50)  :=NULL;
  loc_nomClient                 VARCHAR2(20)  :=NULL;
  loc_nomUtilisateur            VARCHAR2(25)  :=NULL;
  loc_motDePasse                VARCHAR2(25)  :=NULL;
  loc_origine                   VARCHAR2(2)   :=NULL;
  loc_identifiantDossierAMC     VARCHAR2(50)  :=NULL;
  loc_numeroDossierExperteo     VARCHAR2(50)  :=NULL;
  loc_dateDossier               VARCHAR2(50)  :=NULL;
  loc_dateFacture               VARCHAR2(50)  :=NULL;
  loc_numeroFacture             VARCHAR2(20)  :=NULL;
  loc_messageInformatif         VARCHAR2(200) :=NULL;
  -- liquidation (facturation)
  loc_num_dossier               VARCHAR2(50) :=NULL;
  loc_numfact                   SUIVI_FACT_TPE.NUMFACT%TYPE:=NULL;
  loc_datfact                   SUIVI_FACT_TPE.DATFACT%TYPE:=NULL;
  loc_numremise                 SINISTRE_PORTE.NUMREMISE%TYPE:=NULL;
  loc_numdoss_fact              NUMBER:=0;
  -- reponse
  loc_ErreurTechnique           VARCHAR2(200):=NULL;
  loc_codeReponse               VARCHAR2(200):=NULL;
  loc_messageErreur             VARCHAR2(200):=NULL;
  -- exception
  exc_dossier_inconnu           EXCEPTION;
  exc_rej_technique             EXCEPTION;

BEGIN
  G_IDLIGNE := 0;
  P_INS_journal(1,v_id_flux|| ' F_FACTURATION DÉBUT', '');
  v_deb:=DBMS_UTILITY.GET_TIME;

  loc_xmlns :=' xmlns:ns6="http://ws.jalma.com/stdclient"';
    -- ***************************************************************************
    -- *************** Historisation de la question         **********************
    -- ***************************************************************************
  pk_xml.vg_xmlns := ' xmlns:ns2="http://schemas.xmlsoap.org/wsdl/" xmlns="http://ws.jalma.com/stdclient"';
  v_id_flux := pk_ws.insert_flux(p_id_type       => 26,
                                   p_id_flux_tiers => PK_XML.EXTRACT_DATA(P_Question,'ns2:FacturationRequest',null,1),
                                   p_doc_xml       => P_Question,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => g_grpporte );

  -- ***************************************************************************
  -- *************** RECUPERATION DES INFOS DE LA QUESTION**********************
  -- ***************************************************************************
  loc_dateMessage := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/dateMessage',null,1);
  loc_nomClient             := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/nomClient',null,1);
  loc_nomUtilisateur        := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/nomUtilisateur',null,1);
  loc_motDePasse            := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/motDePasse',null,1);
  loc_origine               := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/origine',null,1);
  loc_numeroDossierExperteo := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/numeroDossierExperteo',null,1);
  loc_dateDossier           := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/dateDossier',null,1);
  loc_dateFacture           := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/dateFacture',null,1);
  loc_numeroFacture         := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/numeroFacture',null,1);


  -- ***************************************************************************
  -- *************** FIN RECUPERATION DES INFOS DE LA QUESTION *****************
  -- ***************************************************************************


  -- ***************************************************************************
  -- *************** DEBUT FACTURATION DU DOSSIER *******************************
  -- ***************************************************************************

  BEGIN
  --  loc_num_dossier:= PK_CALCUL_DOSSIER.F_LIQ_DOSSIER(loc_numeroDossierExperteo,loc_numremise,loc_numfact,loc_datfact);
    loc_datfact:=to_date(TO_CHAR(TO_TIMESTAMP(PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/dateFacture',null,1), 'YYYY-MM-DD HH24:MI:SS.FF'),'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS');

   -- Verification que le dossier n est pas déja facturé
   BEGIN
      SELECT distinct 1 into loc_numdoss_fact
      FROM dossier_sante
      WHERE ref_dossier = trim(loc_numeroDossierExperteo)
      AND type_doss = 1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    IF  loc_numdoss_fact > 0 THEN
     RAISE exc_rej_technique;
    END IF;
    loc_num_dossier:= PK_CALCUL_DOSSIER.F_LIQ_DOSSIER(loc_numeroDossierExperteo,loc_numremise,loc_numeroFacture,loc_datfact);

    -- Mise à jour des facturés envoyé
    PK_CTRL_TP.P_INS_HISTO_DOSSIER(loc_num_dossier,0,7);      -- motif 7 Dossier facturé et envoyé
    P_INS_journal(1,v_id_flux|| ' loc_num_dossier :'||loc_num_dossier);
    IF loc_num_dossier = 0 THEN
      P_INS_journal(1,v_id_flux|| ' RAISE exc_dossier_inconnu : '||loc_num_dossier);
      RAISE exc_dossier_inconnu;
    ELSIF loc_num_dossier =-1 THEN
      P_INS_journal(1,v_id_flux|| ' RAISE exc_rej_technique : '||loc_num_dossier);
      RAISE exc_rej_technique;
    END IF;

    loc_ErreurTechnique:='false';   -- Action acceptée
    loc_codeReponse:='true';

  EXCEPTION
    WHEN exc_dossier_inconnu THEN
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_messageErreur := 'Liquidation refusee - Facture introuvable';
      ROLLBACK;
    WHEN exc_rej_technique THEN
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_messageErreur := 'Liquidation refusee - PEC deja facturee';
      ROLLBACK;
    WHEN OTHERS THEN
      P_INS_journal(1,v_id_flux|| ' F_FACTURATION, ano: ' || sqlerrm);
      loc_messageErreur:='Erreur indéterminée lors de la liquidation du dossier';
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
    --  loc_numeroDossierExperteo:=loc_num_dossier;
      ROLLBACK;
  END;

  -- ***************************************************************************
  -- *************** FIN FACTURATION DU DOSSIER ********************************
  -- ***************************************************************************


  -- ***************************************************************************
  -- ******************** CONSTRUCTION DE LA REPONSE****************************
  -- ***************************************************************************
  P_INS_journal(1,v_id_flux|| ' CONSTRUCTION DE LA REPONSE');
  loc_xmlns := 'xmlns:ns6="http://ws.jalma.com/stdclient"';
  loc_path_courant := 'ns6:facturationResponse';
  -- creation l'itération sur sur bénéficiaire
  loc_Reponse :=  XMLTYPE('<ns6:facturationResponse '||loc_xmlns||'></ns6:facturationResponse>');
  loc_path_courant := 'ns6:facturationResponse';
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:enTete');
  loc_path_courant := 'ns6:facturationResponse/ns6:enTete';
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:dateMessage', child_val => loc_dateMessage);
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:nomClient', child_val => loc_nomClient);
  IF TRIM(loc_erreurTechnique) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:erreurTechnique', child_val => loc_erreurTechnique);
  END IF;
  IF TRIM(loc_codeReponse) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:codeReponse', child_val => loc_codeReponse);
  END IF;
  IF TRIM(loc_messageErreur) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val => loc_messageErreur);
  END IF;
  IF TRIM(loc_messageInformatif) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageInformatif', child_val => loc_messageInformatif);
  END IF;
  IF TRIM(loc_numeroDossierExperteo) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:numeroDossierExperteo', child_val => loc_numeroDossierExperteo);
  END IF;
  IF TRIM(loc_identifiantDossierAMC) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:identifiantDossierAMC', child_val => loc_identifiantDossierAMC);
  END IF;
--  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:versionWSDL', child_val => '1');
  -- ***************************************************************************
  -- ******************* FIN DE CONSTRUCTION DE LA REPONSE *********************
  -- ***************************************************************************
  P_INS_journal(1,v_id_flux|| ' FIN RECUPERATION DES INFOS DE LA REPONSE FACTURATION');
  pk_ws.add_xml(p_id_type => 27,
            p_id_flux => v_id_flux,
            p_doc_xml => loc_Reponse,
            p_cod_err => v_cod_err);

  v_delai := DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);


  P_INS_journal(1,v_id_flux|| '  Fin normale de la procédure F_FACTURATION');
  COMMIT;
  RETURN loc_Reponse;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,v_id_flux|| ' F_FACTURATION: ' || sqlerrm);
    ROLLBACK;
END F_FACTURATION;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_ANNULATION                                              */
/* Type         :  Public                                                    */
/* Description  :  F_ANNULATION                                              */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_ANNULATION (P_Question IN XMLTYPE)
RETURN XMLTYPE
IS
  xmlretour                     XMLTYPE;
  loc_xmlns                     VARCHAR2(50);
  loc_path_courant              VARCHAR2(100);
  loc_Reponse                   XMLTYPE;
  loc_detail_acte               XMLTYPE;
  v_cod_err                     NUMBER:=0;
  g_grpporte                    NUMBER(2) := 22;
  v_id_flux                     NUMBER:=NULL;
  v_deb                         NUMBER;
  v_delai                       NUMBER;
  -- entete
  loc_path_entete               VARCHAR2(100):='ns2:AnnulationRequest/enTete';
  loc_dateMessage               VARCHAR2(50) :=NULL;
  loc_nomClient                 VARCHAR2(20) :=NULL;
  loc_nomUtilisateur            VARCHAR2(25) :=NULL;
  loc_motDePasse                VARCHAR2(25) :=NULL;
  loc_origine                   VARCHAR2(2)  :=NULL;
  loc_identifiantDossierAMC     VARCHAR2(50) :=NULL;
  loc_numeroDossierExperteo     VARCHAR2(50) :=NULL;
  loc_dateDossier               VARCHAR2(50) :=NULL;
  loc_messageInformatif         VARCHAR2(200):=NULL;
  -- dossier
  loc_num_dossier               VARCHAR2(50) :=NULL;
  loc_numAdhe                   DOSSIER_SANTE.NUMINDIV%TYPE:=NULL;
  loc_fact_pec                  DOSSIER_SANTE.NUM_FACT_PEC%TYPE:=NULL;
  loc_dat_fact_pec              DOSSIER_SANTE.DATE_FACT_PEC%TYPE:=NULL;
  loc_dossier_pec               DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE:=NULL;
  loc_dossier_porte             DOSSIER_SANTE.NUM_DOSSIER_PORTE%TYPE:=NULL;
  loc_motif                     NUMBER(3) :=1;
  -- reponse
  loc_ErreurTechnique           VARCHAR2(200):=NULL;
  loc_codeReponse               VARCHAR2(200):=NULL;
  loc_messageErreur             VARCHAR2(200):=NULL;
  -- exception
  exc_dossier_inconnu           EXCEPTION;
  exc_dossier_annule            EXCEPTION;
  exc_dossier_CourFactur        EXCEPTION;
  exc_dossier_facture           EXCEPTION;

BEGIN
  G_IDLIGNE := 0;
  P_INS_journal(1,v_id_flux|| ' F_ANNULATION DÉBUT', '');
  v_deb:=DBMS_UTILITY.GET_TIME;

  loc_xmlns := ' xmlns:ns6="http://ws.jalma.com/stdclient"';

    -- ***************************************************************************
    -- *************** Historisation de la question         **********************
    -- ***************************************************************************
  pk_xml.vg_xmlns := ' xmlns:ns2="http://schemas.xmlsoap.org/wsdl/" xmlns="http://ws.jalma.com/stdclient"';
  v_id_flux := pk_ws.insert_flux(p_id_type         => 28,
                                 p_id_flux_tiers   => PK_XML.EXTRACT_DATA(P_Question,'ns2:AnnulationRequest',null,1),
                                 p_doc_xml         => P_Question,
                                 p_cod_err         => v_cod_err,
                                 p_porte           => g_grpporte );

  P_INS_journal(1,v_id_flux|| ' Recupération des données');
  -- ***************************************************************************
  -- *************** RECUPERATION DES INFOS DE LA QUESTION**********************
  -- ***************************************************************************
  loc_dateMessage           := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/dateMessage',null,1);
  loc_nomClient             := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/nomClient',null,1);
  loc_nomUtilisateur        := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/nomUtilisateur',null,1);
  loc_motDePasse            := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/motDePasse',null,1);
  loc_origine               := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/origine',null,1);
  loc_numeroDossierExperteo := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/numeroDossierExperteo',null,1);
  loc_dateDossier           := PK_XML.EXTRACT_DATA(P_Question,loc_path_entete||'/dateDossier',null,1);

  -- ***************************************************************************
  -- *************** FIN RECUPERATION DES INFOS DE LA QUESTION *****************
  -- ***************************************************************************

  -- ***************************************************************************
  -- *************** DEBUT ANNULATION DU DOSSIER *******************************
  -- ***************************************************************************
  BEGIN
    --on vérifie que le dossier existe
    loc_num_dossier:=PK_CTRL_TP.F_FIND_REF_DOSSIER(TRIM(loc_numeroDossierExperteo),loc_numAdhe) ;
    IF NVL(loc_num_dossier,0) > 0 THEN

      IF F_ETAT_DOSSIER_SANTE(loc_num_dossier,SYSDATE,1) = 1 OR -- dossier fermé
        PK_CTRL_TP.F_FIND_SNTR_ANNUL(loc_num_dossier) = 1 THEN -- au moins 1 sinistre_sante annulé
        P_INS_journal(1,v_id_flux|| ' RAISE exc_dossier_annule loc_num_dossier : '||loc_num_dossier);
        RAISE exc_dossier_annule;
      ELSIF F_ETAT_DOSSIER_SANTE(loc_num_dossier,SYSDATE,1) = 0 AND F_ETAT_DOSSIER_SANTE(loc_num_dossier,SYSDATE,2) IN (6,4) THEN -- dossier en cours de facturation
        PK_CTRL_TP.P_INFO_DOSSIER(loc_num_dossier, loc_fact_pec, loc_dat_fact_pec, loc_dossier_pec, loc_dossier_porte);
        IF loc_dossier_pec IS NULL THEN
          P_INS_journal(1,v_id_flux|| ' RAISE exc_dossier_CourFactur loc_num_dossier : '||loc_num_dossier);
          RAISE exc_dossier_CourFactur;
        END IF;
      ELSIF PK_CTRL_TP.F_FIND_SNTR_DCPT(loc_num_dossier) = 1 THEN -- au moins 1 sinistre du dossier est décompté
        P_INS_journal(1,v_id_flux|| ' RAISE exc_dossier_facture loc_num_dossier : '||loc_num_dossier);
        RAISE exc_dossier_facture;
      END IF;
      IF F_ETAT_DOSSIER_SANTE(loc_num_dossier,SYSDATE,2) = 8 THEN -- en attente
        loc_motif:=8;
      END IF;
      P_INS_journal(1,v_id_flux|| '  loc_num_dossier : '||loc_num_dossier||', loc_motif : ' ||loc_motif);
      -- Annulation du dossier
      PK_CTRL_TP.P_ANNUL_DOSSIER(loc_num_dossier,loc_motif);
      -- mise à jour de la reférence externe de l'individu
      PK_CTRL_TP.P_MAJ_REF_EXTERNE(
            P_numindiv    => loc_numAdhe,
            P_domaine     => '',
            P_num_dossier => loc_num_dossier,
            P_tiers       => 'ITELIS',
            P_mnemo       => 'DOMGEREP');
      COMMIT;
      loc_ErreurTechnique:='false';   -- Action acceptée
      loc_codeReponse:='true';
    ELSE
      P_INS_journal(1,v_id_flux|| ' RAISE exc_dossier_inconnu loc_numeroDossierExperteo : '||loc_numeroDossierExperteo);
      RAISE exc_dossier_inconnu; -- dossier non trouvé
    END IF;

  P_INS_journal(1,v_id_flux|| ' annulation OK, dossier : '||loc_numeroDossierExperteo);

  EXCEPTION
    WHEN exc_dossier_inconnu THEN
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_messageErreur := 'Annulation refusee - PEC/DAC introuvable';
      loc_numeroDossierExperteo:=loc_num_dossier;
    WHEN exc_dossier_annule THEN
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_messageErreur := 'Annulation refusee - PEC/DAC deja annulee';
      loc_numeroDossierExperteo:=loc_num_dossier;
    WHEN exc_dossier_CourFactur THEN
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_messageErreur := 'Annulation refusee - PEC/DAC en cours de facturation';
      loc_numeroDossierExperteo:=loc_num_dossier;
    WHEN exc_dossier_facture THEN
      loc_ErreurTechnique:='true';
      loc_codeReponse:='false';
      loc_messageErreur := 'Annulation refusee - PEC/DAC deja facturee';
      loc_numeroDossierExperteo:=loc_num_dossier;
    WHEN OTHERS THEN
      P_INS_journal(1,v_id_flux|| ' F_ANNULATION, ano: ' || sqlerrm);
      loc_messageErreur:='Erreur indéterminée lors de l annulation du dossier';
      loc_ErreurTechnique:='false';
      loc_codeReponse:='false';
      loc_numeroDossierExperteo:=loc_num_dossier;
  END;

  -- ***************************************************************************
  -- *************** FIN ANNULATION DU DOSSIER *********************************
  -- ***************************************************************************

  -- ***************************************************************************
  -- ******************** CONSTRUCTION DE LA REPONSE****************************
  -- ***************************************************************************
  loc_xmlns := 'xmlns:ns6="http://ws.jalma.com/stdclient"';
  loc_path_courant := 'ns6:annulationResponse';
  -- creation l'itération sur sur bénéficiaire
  loc_Reponse :=  XMLTYPE('<ns6:annulationResponse '||loc_xmlns||'></ns6:annulationResponse>');
  loc_path_courant := 'ns6:annulationResponse';
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:enTete');
  loc_path_courant := 'ns6:annulationResponse/ns6:enTete';
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:dateMessage', child_val => loc_dateMessage);
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:nomClient', child_val => loc_nomClient);
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:erreurTechnique', child_val => loc_erreurTechnique);
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:codeReponse', child_val => loc_codeReponse);
  IF TRIM(loc_messageErreur) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val => loc_messageErreur);
  END IF;
  IF TRIM(loc_messageInformatif) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageInformatif', child_val => loc_messageInformatif);
  END IF;
  IF TRIM(loc_numeroDossierExperteo) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:numeroDossierExperteo', child_val => loc_numeroDossierExperteo);
  END IF;
  IF TRIM(loc_identifiantDossierAMC) IS NOT NULL THEN
    loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:identifiantDossierAMC', child_val => loc_identifiantDossierAMC);
  END IF;
  loc_Reponse := pk_xml.APPENDCHILD(doc=>loc_Reponse, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:versionWSDL', child_val => '1');
  -- ***************************************************************************
  -- ******************* FIN DE CONSTRUCTION DE LA REPONSE *********************
  -- ***************************************************************************
  pk_ws.add_xml(p_id_type => 29,
                p_id_flux => v_id_flux,
                p_doc_xml => loc_Reponse,
                p_cod_err => v_cod_err);

  v_delai := DBMS_UTILITY.GET_TIME- v_deb;
  pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  P_INS_journal(1,v_id_flux|| '  Fin normale de la procédure F_ANNULATION');
  RETURN loc_Reponse;
EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,v_id_flux|| ' F_ANNULATION: ' || sqlerrm);
END F_ANNULATION;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_MAJPEC                                                  */
/* Type         :  Public                                                    */
/* Description  :  F_MAJPEC                                                  */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_MAJPEC ( P_ref_dossier DOSSIER_SANTE.REF_DOSSIER%TYPE)
RETURN NUMBER
IS
  xmlretour                     XMLTYPE;
  loc_xmlns                     VARCHAR2(50);
  loc_path_courant              VARCHAR2(100);
  loc_Question                  XMLTYPE;
  loc_Question_Format           XMLTYPE;
  loc_Reponse                   XMLTYPE;
  loc_detail_acte               XMLTYPE;
  v_cod_err                     NUMBER:=0;
  g_grpporte                    NUMBER(2) := 22;
  v_id_flux                     NUMBER:=NULL;
  v_deb                         NUMBER;
  v_delai                       NUMBER;
  i                             NUMBER;
  -- entete
  loc_path_entete               VARCHAR2(100):='ns6:majPecRequest/enTete';
  loc_path_entete_rep           VARCHAR2(100):='ns8:majPecResponse/enTete';
  loc_dateMessage               VARCHAR2(50) :=NULL;
  loc_nomClient                 VARCHAR2(20) :=NULL;
  loc_nomUtilisateur            VARCHAR2(25) :=NULL;
  loc_motDePasse                VARCHAR2(25) :=NULL;
  loc_numeroDossierExperteo     VARCHAR2(50) :=NULL;
  loc_messageInformatif         VARCHAR2(200):=NULL;
  -- dossier
  loc_domaine                    VARCHAR2(2):=NULL;   -- 0 = Optique, 1 = dentaire, 2 = audioprothèse
  loc_type                       VARCHAR2(1):=NULL;   -- 0 = Devis, 1 = PEC
  loc_statut                     VARCHAR2(10):=NULL;
  loc_num_dossier                DOSSIER_SANTE.NUM_DOSSIER%TYPE:=0;
  -- prestation
  loc_nombreActes                VARCHAR2(2):=NULL;
  loc_totalDepense               VARCHAR2(10):=NULL;
  loc_totalRemboursementSS       VARCHAR2(10):=NULL;
  loc_totalRC                    VARCHAR2(10):=NULL;
  loc_totalRAC                   VARCHAR2(10):=NULL;
  -- acte
  loc_Tab_acte                   TAB_T_ACTE;
  -- reponse
  loc_ErreurTechnique           VARCHAR2(200):=NULL;
  loc_codeReponse               VARCHAR2(200):=NULL;
  loc_messageErreur             VARCHAR2(200):=NULL;
  -- exception
  exc_dossier_inconnu           EXCEPTION;

  loc_doc_xml1    CLOB;
  soap_respond   varchar2(30000);

BEGIN
  G_IDLIGNE := 0;
  P_INS_journal(1,v_id_flux|| ' F_MAJPEC DÉBUT', '');

  P_INS_journal(1,v_id_flux|| ' Recupération des données, P_ref_dossier: '||P_ref_dossier);

  -- Recherche du numéro de dossier
  loc_num_dossier := PK_CTRL_TP.F_FIND_NUMDOSSIER(P_ref_dossier);
  P_INS_journal(1,v_id_flux|| ' Recupération des données, loc_num_dossier: '||loc_num_dossier);
  -- ***************************************************************************
  -- *************** DEBUT RECUPERATION DES INFOS DU DOSSIER *******************
  -- ***************************************************************************
  BEGIN
    SELECT EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:dateMessage', 'xmlns:ns6="http://ws.jalma.com/stdclient"') dateMessage
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:nomClient', 'xmlns:ns6="http://ws.jalma.com/stdclient"') nomClient
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:nomUtilisateur', 'xmlns:ns6="http://ws.jalma.com/stdclient"') nomUtilisateur
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:motDePasse', 'xmlns:ns6="http://ws.jalma.com/stdclient"') motDePasse
     --    , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:erreurTechnique', 'xmlns:ns6="http://ws.jalma.com/stdclient"') erreurTechnique
       --  , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:codeReponse', 'xmlns:ns6="http://ws.jalma.com/stdclient"') codeReponse
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:numeroDossierExperteo', 'xmlns:ns6="http://ws.jalma.com/stdclient"') numeroDossierExperteo
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:domaine', 'xmlns:ns6="http://ws.jalma.com/stdclient"') domaine
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:type', 'xmlns:ns6="http://ws.jalma.com/stdclient"') type
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:statut', 'xmlns:ns6="http://ws.jalma.com/stdclient"') statut
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:messageErreur', 'xmlns:ns6="http://ws.jalma.com/stdclient"') messageErreur
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:messageInformatif', 'xmlns:ns6="http://ws.jalma.com/stdclient"') messageInformatif
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:prestation/ns6:nombreActes', 'xmlns:ns6="http://ws.jalma.com/stdclient"') nombreActes
         , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:prestation/ns6:totalDepense', 'xmlns:ns6="http://ws.jalma.com/stdclient"') totalDepense
     --    , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:prestation/ns6:totalRemboursementSS', 'xmlns:ns6="http://ws.jalma.com/stdclient"') totalRemboursementSS
     --    , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:prestation/ns6:totalRC', 'xmlns:ns6="http://ws.jalma.com/stdclient"') totalRC
     --    , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:prestation/ns6:totalRAC', 'xmlns:ns6="http://ws.jalma.com/stdclient"') totalRAC
      INTO loc_dateMessage
         , loc_nomClient
         , loc_nomUtilisateur
         , loc_motDePasse
     --    , loc_erreurTechnique
      --   , loc_codeReponse
         , loc_numeroDossierExperteo
         , loc_domaine
         , loc_type
         , loc_statut
         , loc_messageErreur
         , loc_messageInformatif
         , loc_nombreActes
         , loc_totalDepense
     --    , loc_totalRemboursementSS
     --    , loc_totalRC
     --    , loc_totalRAC
      FROM XML_04_09_ITELIS x
         , FLUX f
     WHERE x.id_flux = f.id_flux
       AND f.statut=0
       AND f.id_type=24
       AND EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:numeroDossierExperteo', 'xmlns:ns6="http://ws.jalma.com/stdclient"') IS NOT NULL
       AND EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:numeroDossierExperteo', 'xmlns:ns6="http://ws.jalma.com/stdclient"') = TRIM(P_ref_dossier)
       AND EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:type', 'xmlns:ns6="http://ws.jalma.com/stdclient"') = '1'
       AND UPPER(EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:statut', 'xmlns:ns6="http://ws.jalma.com/stdclient"')) = 'EN ATTENTE'
    ORDER BY DAT_MAJ DESC;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1; -- Erreur
  END;
  -- todo -- a enlever
  loc_nomUtilisateur :='ITE_GEREP';
  loc_motDePasse :='pass';
  loc_statut:=1;


  -- ***************************************************************************
  -- *************** FIN RECUPERATION DES INFOS DU DOSSIER *********************
  -- ***************************************************************************

  -- ***************************************************************************
  -- *************** DEBUT RECUPERATION DES INFOS DES ACTES ********************
  -- ***************************************************************************
  FOR i IN 1..loc_nombreActes LOOP
    BEGIN
      -- detailActe
        SELECT EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:detailActes/ns6:detailActe['||i||']/ns6:numeroActe', 'xmlns:ns6="http://ws.jalma.com/stdclient"') numeroActe
             , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:detailActes/ns6:detailActe['||i||']/ns6:identiteActeReference', 'xmlns:ns6="http://ws.jalma.com/stdclient"') identiteActeReference
             , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:detailActes/ns6:detailActe['||i||']/ns6:libelleActe', 'xmlns:ns6="http://ws.jalma.com/stdclient"') libelleActe
             , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:detailActes/ns6:detailActe['||i||']/ns6:acteRemboursementSS', 'xmlns:ns6="http://ws.jalma.com/stdclient"') acteRemboursementSS
             , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:detailActes/ns6:detailActe['||i||']/ns6:acteRC', 'xmlns:ns6="http://ws.jalma.com/stdclient"') acteRC
             , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:detailActes/ns6:detailActe['||i||']/ns6:acteRAC', 'xmlns:ns6="http://ws.jalma.com/stdclient"') acteRAC
             , EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:detailActes/ns6:detailActe['||i||']/ns6:codeReponse', 'xmlns:ns6="http://ws.jalma.com/stdclient"') codeReponse
          INTO loc_Tab_acte(i).numeroActe
             , loc_Tab_acte(i).identiteActeReference
             , loc_Tab_acte(i).libelleActe
             , loc_Tab_acte(i).acteRemboursementSS
             , loc_Tab_acte(i).acteRC
             , loc_Tab_acte(i).acteRAC
             , loc_Tab_acte(i).codeReponse
      FROM XML_04_09_ITELIS x
         , FLUX f
     WHERE x.id_flux = f.id_flux
       AND f.statut=0
       AND f.id_type=24
       AND EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:numeroDossierExperteo', 'xmlns:ns6="http://ws.jalma.com/stdclient"') IS NOT NULL
       AND EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:enTete/ns6:numeroDossierExperteo', 'xmlns:ns6="http://ws.jalma.com/stdclient"') = TRIM(P_ref_dossier)
       AND EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:type', 'xmlns:ns6="http://ws.jalma.com/stdclient"') = '1'
       AND UPPER(EXTRACTVALUE(doc_xml2,'ns6:calculRCResponse/ns6:dossier/ns6:statut', 'xmlns:ns6="http://ws.jalma.com/stdclient"')) = 'EN ATTENTE'
    ORDER BY DAT_MAJ DESC;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 1; -- Erreur
      END;

--    IF NVL(loc_Tab_acte(i).acteRC,0) = 0 THEN

      SELECT (REPLACE(TO_CHAR(MTFRAIS*100),'.', '')-REPLACE(TO_CHAR(MTPREST_REEL*100),'.', '')-REPLACE(TO_CHAR(MTREMB*100),'.', '') ) , REPLACE(TO_CHAR(MTPREST_REEL*100),'.', '')  , REPLACE(TO_CHAR(MTREMB*100),'.', '')
        INTO loc_Tab_acte(i).acteRAC,loc_Tab_acte(i).acteRC,loc_Tab_acte(i).acteRemboursementSS
        FROM SINISTRE_SANTE s
       WHERE s.NUM_DOSSIER=loc_num_dossier
         AND s.NUMLIGNE=i;


      loc_totalRemboursementSS :=  NVL(loc_totalRemboursementSS,0) + NVL(loc_Tab_acte(i).acteRemboursementSS,0);
      loc_totalRC              :=  NVL(loc_totalRC,0) + NVL(loc_Tab_acte(i).acteRC,0);
      loc_totalRAC             :=  NVL(loc_totalRAC,0) + NVL(loc_Tab_acte(i).acteRAC,0);


 --   END IF;
    P_INS_journal(1,v_id_flux|| ' loc_Tab_acte(i).acteRC: '||loc_Tab_acte(i).acteRC);
  END LOOP;
  -- ***************************************************************************
  -- *************** FIN RECUPERATION DES INFOS DES ACTES **********************
  -- ***************************************************************************

  -- ***************************************************************************
  -- ******************** CONSTRUCTION DE LA QUESTION***************************
  -- ***************************************************************************
  -- Initialisation XML question
  v_deb:=DBMS_UTILITY.GET_TIME;
  pk_xml.new_xml;

  loc_xmlns := 'xmlns:ns6="http://ws.jalma.com/stdclient"';
  loc_Question := XMLTYPE('<ns6:majPecRequest '||loc_xmlns||'></ns6:majPecRequest>');
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question,path=>'ns6:majPecRequest', children=>'ns6:enTete',xmlns=>loc_xmlns);
  loc_path_courant :='ns6:majPecRequest/ns6:enTete';
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:dateMessage', child_val => loc_dateMessage);
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:nomClient', child_val=> loc_nomClient);
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:nomUtilisateur', child_val => loc_nomUtilisateur);
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:motDePasse', child_val=> loc_motDePasse);
  IF TRIM(loc_ErreurTechnique) IS NOT NULL THEN
    loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:erreurTechnique', child_val=>loc_ErreurTechnique);
  END IF;
  IF TRIM(loc_codeReponse) IS NOT NULL THEN
    loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:codeReponse', child_val=>loc_codeReponse);
  END IF;
  IF TRIM(loc_messageErreur) IS NOT NULL THEN
    loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageErreur', child_val=> loc_messageErreur);
  END IF;
  IF TRIM(loc_messageInformatif) IS NOT NULL THEN
    loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:messageInformatif', child_val=>loc_messageInformatif);
  END IF;
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:numeroDossierExperteo', child_val=> loc_numeroDossierExperteo  ); -- loc_num_dossier);
  --creation de la balise dossier
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question,path=>'ns6:majPecRequest', children=>'ns6:dossier', xmlns=>loc_xmlns );
  loc_path_courant :='ns6:majPecRequest/ns6:dossier';
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:domaine', child_val => loc_domaine);
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:type', child_val => loc_type);
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:statut', child_val => '1');

  --creation de la balise prestation
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question,path=>'ns6:majPecRequest', children=>'ns6:prestation', xmlns=>loc_xmlns );
  loc_path_courant :='ns6:majPecRequest/ns6:prestation';
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:nombreActes', child_val => loc_nombreActes);
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:totalDepense', child_val => REPLACE(loc_totalDepense,'.', ''));
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:totalRemboursementSS', child_val => REPLACE(loc_totalRemboursementSS,'.', ''));
  IF loc_statut NOT IN ('1') THEN
    RETURN 1;    -- le dossier n est pas en attente
  END IF;
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:totalRC', child_val => REPLACE(loc_totalRC,'.', ''));
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question, xmlns=>loc_xmlns, path=>loc_path_courant, children=>'ns6:totalRAC', child_val => REPLACE(loc_totalRAC,'.', ''));
  -- creation de la balise englobate de detailAtcteS
  loc_Question := pk_xml.APPENDCHILD(doc=>loc_Question,path=>'ns6:majPecRequest', children=>'ns6:detailActes', xmlns=>loc_xmlns );
  loc_path_courant :='ns6:majPecRequest/ns6:detailActes';

  --- POUR CHAQUE LIGNE DU DETAIL DES ACTES, BOUCLER ET APPELER F_GETXML_DETAIL_ACTE_CALCUL
  FOR i IN 1..loc_nombreActes LOOP
    BEGIN
      P_INS_journal(3,v_id_flux|| ' i: ' || i);
      P_INS_journal(3,v_id_flux|| ' BOUCLE ACTES REPONSE, codeReponse: '||loc_codeReponse||' messageErreur: ' || loc_messageErreur);
      P_INS_journal(3,v_id_flux|| ' BOUCLE ACTES REPONSE, loc_messageInformatif: ' || loc_messageInformatif);
      loc_detail_acte := F_GETXML_DETAIL_ACTE_CALCUL( loc_Tab_acte,
                                                      i,
                                                      loc_codeReponse,
                                                      loc_messageErreur,
                                                      loc_messageInformatif,
                                                      loc_statut);

      loc_Question := pk_xml.APPENDCHILDXML(doc=>loc_Question,path=>loc_path_courant, children=>'ns6:detailActe', xmlns=>loc_xmlns, child_val =>loc_detail_acte  );

    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1,v_id_flux|| ' F_CALCULRC, Devis KO' || sqlerrm);
        loc_statut:='ABANDONNE';
    END;
  END LOOP;
  -- ***************************************************************************
  -- ******************* FIN DE CONSTRUCTION DE LA QUESTION ********************
  -- ***************************************************************************

  -- ***************************************************************************
  -- * Appel Web Service MAJPEC
  -- ***************************************************************************
  v_id_flux := pk_ws.insert_flux(p_id_type       => 30,
                                 p_id_flux_tiers => PK_XML.EXTRACT_DATA(loc_Question,'ns6:majPecRequest',null,1),
                                 p_doc_xml       => loc_Question,
                                 p_cod_err       => v_cod_err,
                                 p_porte         => g_grpporte );


  /*****************************************************************************************/
  /*****************************************************************************************/
  /*****************************************************************************************/
  /*****************************************************************************************/
  loc_Reponse := /*pk_ws.*/appel_ws(p_id_type => 30,
                                    p_doc_xml => loc_Question);

  /*****************************************************************************************/
  /*****************************************************************************************/
  /*****************************************************************************************/
  /*****************************************************************************************/
  IF loc_Reponse IS NULL THEN
    P_INS_journal(1,v_id_flux|| ' Erreur lors de l appel au WebService F_MAJPEC,  erreur: '||sqlerrm);
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
    P_INS_journal(1,v_id_flux|| ' Erreur lors de l appel au WebService F_MAJPEC,  v_delai: '||v_delai);
    RETURN 1;
  END IF;

  -- Historisation du flux retour MAJPEC (type 31)
  pk_ws.add_xml(p_id_type => 31,
                p_id_flux => v_id_flux,
                p_doc_xml => loc_Reponse,
                p_cod_err => v_cod_err);

  IF v_cod_err <> 0 THEN
     P_INS_journal(1,v_id_flux|| ' F_MAJPEC, erreur pk_ws.add_xml,p_id_type => 31 ');
     RETURN 1; -- Erreur
  END IF;


  loc_codeReponse := PK_XML.EXTRACT_DATA(loc_Reponse,loc_path_entete_rep||'/codeReponse',null,1);
  IF loc_codeReponse = 'false' THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,v_id_flux|| ' F_MAJPEC: ' || sqlerrm);
    RETURN 1;
END F_MAJPEC;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  appel_ws                                                  */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION appel_ws(p_id_type in type_flux.id_type%type,
                  p_doc_xml in xmltype)
return XMLTYPE
is
  -- Curseur de recherche de l'url et de l'entête SOAP
  cursor cur_type
  is
  select url, soap
  from type_flux
  where id_type = p_id_type;
  r_type       cur_type%rowtype;

  v_doc_xml    clob;
  soap_request clob;
  soap_respond varchar2(30000);
  http_req     utl_http.req;
  http_resp    utl_http.resp;
  resp_xml     XMLType;

BEGIN
  -- Recherche URL et Entête SOAP du Web Service

P_INS_journal(1,'  appel_ws :  ok 1');

  open cur_type;
  fetch cur_type into r_type;
  close cur_type;
P_INS_journal(1,'  appel_ws :  ok 2');
  -- Conversion du document XML en CLOB
  v_doc_xml := p_doc_xml.getStringVal();
P_INS_journal(1,'  appel_ws :  ok 3');


 -- v_doc_xml:=REPLACE(v_doc_xml, 'xmlns:ns6="http://ws.jalma.com/stdclient"','');
  v_doc_xml:=REPLACE(v_doc_xml, 'xmlns:ns6="http://ws.jalma.com/stdclient"','');
  soap_request:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns6="http://ws.jalma.com/">
   <soapenv:Header/>
   <soapenv:Body>'||v_doc_xml||'</soapenv:Body></soapenv:Envelope>';

  /*
  soap_request:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns6="http://ws.jalma.com/">
   <soapenv:Header/>
   <soapenv:Body>
<ns6:majPecRequest>
   <ns6:enTete>
      <ns6:dateMessage>2017-06-06T16:35:39.822+02:00</ns6:dateMessage>
      <ns6:nomClient>ITELIS</ns6:nomClient>
      <ns6:nomUtilisateur>ITE_GEREP</ns6:nomUtilisateur>
      <ns6:motDePasse>pass</ns6:motDePasse>
      <ns6:numeroDossierExperteo>3624257</ns6:numeroDossierExperteo>
   </ns6:enTete>
   <ns6:dossier>
      <ns6:domaine>0</ns6:domaine>
      <ns6:type>1</ns6:type>
      <ns6:statut>1</ns6:statut>
   </ns6:dossier>
   <ns6:prestation>
      <ns6:nombreActes>3</ns6:nombreActes>
      <ns6:totalDepense>15000</ns6:totalDepense>
      <ns6:totalRemboursementSS>610</ns6:totalRemboursementSS>
      <ns6:totalRC>0</ns6:totalRC>
      <ns6:totalRAC>14390</ns6:totalRAC>
   </ns6:prestation>
   <ns6:detailActes>
      <ns6:detailActe>
         <ns6:numeroActe>3774603</ns6:numeroActe>
         <ns6:identiteActeReference>125557</ns6:identiteActeReference>
         <ns6:libelleActe>ESSILOR ADVANS FIT ORMA CZ A PREVENCIA : Verre unifocal dindice 1,5 personnalisÃ© organique (Ã˜60)  combinÃ© ++</ns6:libelleActe>
         <ns6:acteRemboursementSS>220</ns6:acteRemboursementSS>
         <ns6:acteRC>0</ns6:acteRC>
         <ns6:acteRAC>4780</ns6:acteRAC>
         <ns6:codeReponse>true</ns6:codeReponse>
      </ns6:detailActe>
      <ns6:detailActe>
         <ns6:numeroActe>3774604</ns6:numeroActe>
         <ns6:identiteActeReference>125557</ns6:identiteActeReference>
         <ns6:libelleActe>ESSILOR ADVANS FIT ORMA CZ A PREVENCIA : Verre unifocal dindice 1,5 personnalisÃ© organique (Ã˜60)  combinÃ© ++</ns6:libelleActe>
         <ns6:acteRemboursementSS>220</ns6:acteRemboursementSS>
         <ns6:acteRC>0</ns6:acteRC>
         <ns6:acteRAC>4780</ns6:acteRAC>
         <ns6:codeReponse>true</ns6:codeReponse>
      </ns6:detailActe>
      <ns6:detailActe>
         <ns6:numeroActe>3774605</ns6:numeroActe>
         <ns6:identiteActeReference>11893</ns6:identiteActeReference>
         <ns6:libelleActe>ACADEMIC autre</ns6:libelleActe>
         <ns6:acteRemboursementSS>170</ns6:acteRemboursementSS>
         <ns6:acteRC>0</ns6:acteRC>
         <ns6:acteRAC>4830</ns6:acteRAC>
         <ns6:codeReponse>true</ns6:codeReponse>
      </ns6:detailActe>
   </ns6:detailActes>
</ns6:majPecRequest>
</soapenv:Body>
</soapenv:Envelope>';
 */
  -- Création du message SOAP - On insère le document XML au coeur du message SOAP,
/*  soap_request:= REPLACE(r_type.soap,'<Racine/>',v_doc_xml);
P_INS_journal(1,'  appel_ws :  ok 4');
  soap_request:=REPLACE(soap_request, 'xmlns:ns6="http://ws.jalma.com/stdclient"','');        */
 -- soap_request:=REPLACE(soap_request, '''','');
  soap_request:=REPLACE(soap_request, '&apos;','');
--  soap_request:=TRIM(TRANSLATE((soap_request),'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO'));
  soap_request:=REPLACE(soap_request, ' >','>');
/*
P_INS_journal(1,substr(soap_request,0,120));
P_INS_journal(1,substr(soap_request,121,139));
P_INS_journal(1,substr(soap_request,140,260));
P_INS_journal(1,substr(soap_request,260,400));
P_INS_journal(1,substr(soap_request,400,540));
P_INS_journal(1,substr(soap_request,540,680));
P_INS_journal(1,substr(soap_request,680,820));
P_INS_journal(1,substr(soap_request,820,940));
P_INS_journal(1,substr(soap_request,940,1060));
P_INS_journal(1,substr(soap_request,1060,1180));
P_INS_journal(1,substr(soap_request,1180,1300));
P_INS_journal(1,substr(soap_request,1300,1420));
P_INS_journal(1,substr(soap_request,1420,1540));
P_INS_journal(1,substr(soap_request,1540,1660));
P_INS_journal(1,substr(soap_request,1660,1780));
P_INS_journal(1,substr(soap_request,1780,1900));
P_INS_journal(1,substr(soap_request,1900,2020));
P_INS_journal(1,substr(soap_request,2020,2140));
P_INS_journal(1,substr(soap_request,2140,2260));
P_INS_journal(1,substr(soap_request,2260,2380));
P_INS_journal(1,substr(soap_request,2380,2500));
P_INS_journal(1,substr(soap_request,2500,2620));
P_INS_journal(1,substr(soap_request,2620,2740));
P_INS_journal(1,substr(soap_request,2740,2860));
P_INS_journal(1,substr(soap_request,2860,2980));
P_INS_journal(1,substr(soap_request,2980,3100));
P_INS_journal(1,substr(soap_request,3100,3220));
P_INS_journal(1,substr(soap_request,3220,3340));
P_INS_journal(1,substr(soap_request,3340,3460));
P_INS_journal(1,substr(soap_request,3460,3580));
P_INS_journal(1,substr(soap_request,3580,3700));
P_INS_journal(1,substr(soap_request,3700,3820));
P_INS_journal(1,substr(soap_request,3820,3940));
P_INS_journal(1,substr(soap_request,3940,4060));
P_INS_journal(1,substr(soap_request,4060,4180));
P_INS_journal(1,substr(soap_request,4180,4300));
P_INS_journal(1,substr(soap_request,4300,4420));
P_INS_journal(1,substr(soap_request,4420,4540));
P_INS_journal(1,substr(soap_request,4540,4660));
P_INS_journal(1,substr(soap_request,4660,4780));
P_INS_journal(1,substr(soap_request,4780,4900));
P_INS_journal(1,substr(soap_request,4900,5020));
P_INS_journal(1,substr(soap_request,5020,5140));
P_INS_journal(1,substr(soap_request,5140,5260));
P_INS_journal(1,substr(soap_request,5260,5380));
P_INS_journal(1,substr(soap_request,5380,5500));
P_INS_journal(1,substr(soap_request,5500,5620));
P_INS_journal(1,substr(soap_request,5620,5740));
P_INS_journal(1,substr(soap_request,5740,5860));
P_INS_journal(1,substr(soap_request,5860,5980));
P_INS_journal(1,substr(soap_request,5980,6100));
P_INS_journal(1,substr(soap_request,6100,6220));

*/
  -- Appel Web Service
  http_req:= utl_http.begin_request(r_type.url, 'POST', 'HTTP/1.1');
  utl_http.set_header(http_req, 'Content-Type', 'text/xml;charset=UTF-8');
  utl_http.set_header(http_req, 'Content-Length', length(soap_request));
  utl_http.set_header(http_req, 'SOAPAction', '');
  utl_http.write_text(http_req, soap_request);
  -- Réception de la réponse du Web Service
  http_resp:= utl_http.get_response(http_req);
  utl_http.read_text(http_resp, soap_respond);
  utl_http.end_response(http_resp);
/*
P_INS_journal(1,substr(soap_respond,120,140));
P_INS_journal(1,substr(soap_respond,140,260));
P_INS_journal(1,substr(soap_respond,260,400));
P_INS_journal(1,substr(soap_respond,400,540));
P_INS_journal(1,substr(soap_respond,540,680));
P_INS_journal(1,substr(soap_respond,680,820));
P_INS_journal(1,substr(soap_respond,820,940));
P_INS_journal(1,substr(soap_respond,940,1060));
P_INS_journal(1,substr(soap_respond,1060,1180));
P_INS_journal(1,substr(soap_respond,1180,1300));
P_INS_journal(1,substr(soap_respond,1300,1420));
P_INS_journal(1,substr(soap_respond,1420,1540));
P_INS_journal(1,substr(soap_respond,1540,1660));
P_INS_journal(1,substr(soap_respond,1660,1780));
P_INS_journal(1,substr(soap_respond,1780,1900));
P_INS_journal(1,substr(soap_respond,1900,2020));
P_INS_journal(1,substr(soap_respond,2020,2140));
P_INS_journal(1,substr(soap_respond,2140,2260));
P_INS_journal(1,substr(soap_respond,2260,2380));
P_INS_journal(1,substr(soap_respond,2380,2500));
P_INS_journal(1,substr(soap_respond,2500,2620));
P_INS_journal(1,substr(soap_respond,2620,2740));
P_INS_journal(1,substr(soap_respond,2740,2860));
P_INS_journal(1,substr(soap_respond,2860,2980));
P_INS_journal(1,substr(soap_respond,2980,3100));
P_INS_journal(1,substr(soap_respond,3100,3220));
P_INS_journal(1,substr(soap_respond,3220,3340));
P_INS_journal(1,substr(soap_respond,3340,3460));
P_INS_journal(1,substr(soap_respond,3460,3580));
P_INS_journal(1,substr(soap_respond,3580,3700));
P_INS_journal(1,substr(soap_respond,3700,3820));
P_INS_journal(1,substr(soap_respond,3820,3940));
P_INS_journal(1,substr(soap_respond,3940,4060));
P_INS_journal(1,substr(soap_respond,4060,4180));
P_INS_journal(1,substr(soap_respond,4180,4300));
P_INS_journal(1,substr(soap_respond,4300,4420));
P_INS_journal(1,substr(soap_respond,4420,4540));
P_INS_journal(1,substr(soap_respond,4540,4660));
P_INS_journal(1,substr(soap_respond,4660,4780));
P_INS_journal(1,substr(soap_respond,4780,4900));
P_INS_journal(1,substr(soap_respond,4900,5020));
P_INS_journal(1,substr(soap_respond,5020,5140));
P_INS_journal(1,substr(soap_respond,5140,5260));
P_INS_journal(1,substr(soap_respond,5260,5380));
P_INS_journal(1,substr(soap_respond,5380,5500));
P_INS_journal(1,substr(soap_respond,5500,5620));
P_INS_journal(1,substr(soap_respond,5620,5740));
P_INS_journal(1,substr(soap_respond,5740,5860));
P_INS_journal(1,substr(soap_respond,5860,5980));
P_INS_journal(1,substr(soap_respond,5980,6100));
P_INS_journal(1,substr(soap_respond,6100,6220));
*/
  -- Conversion de la réponse en document XML
  resp_xml:= XMLType.createXML(soap_respond);

  return(resp_xml);

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'  appel_ws : WHEN OTHERS THEN ok');
    RETURN(NULL);
END appel_ws;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TRANSCO_CODFRAIS_OPTIQUE                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de transcodification d'un code acte externe en  */
/*                 code acte Arthus                                          */
/* Retour       :  Retourne les code acte et le code erreur                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_TRANSCO_CODFRAIS_OPTIQUE( P_numfor             ADHESION.NUMFOR%TYPE
                                 --   , P_flag_oeil          NUMBER    DEFAULT NULL
                                    , i                    NUMBER
                                    , P_Tab_acte           TAB_T_ACTE
                                    , P_t_verre            TAB_T_VERRE
                                    , P_t_lentille         TAB_T_LENTILLE
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2
                                    ,P_lpp                 VARCHAR2    --RKO Rac Optique
                                    )
IS


  compteur     NUMBER:=i;
  loc_vision   NUMBER:=0;
  loc_cpt      NUMBER:=0;

  CURSOR c_monture_acte
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , TYPE_MONTURE t
       , NTFRS_MATIERE m
       , lpp l
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = NVL(P_lpp,l.code_lpp)
     AND l.codfrais=c.codfrais
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.monture=1
     AND n.codfrais=c.codfrais
     AND t.codfrais (+)=c.codfrais
     AND m.codfrais (+)=c.codfrais
  ORDER BY n.codfrais ;

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
      AND c.codfrais = n.codfrais
      AND l.codfrais=c.codfrais
      AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
      AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
      AND n.verre=1;

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
      AND c.codfrais = n.codfrais
      AND l.codfrais=c.codfrais
      AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
      AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
      AND n.lentille=1;


  -- curseur des verres
  CURSOR c_optique_actev(P_vision  IN  NUMBER)
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_OPTIQUE o
       , NTFRS_TYP_VISION v
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND o.codfrais =c.codfrais --suppression de la jointure left
     AND n.verre=1
     AND ((NVL(TO_NUMBER(P_t_verre(compteur).SPHERE),o.spherep_deb)   BETWEEN NVL(o.spherep_deb  ,TO_NUMBER(P_t_verre(compteur).SPHERE))   AND NVL(o.spherep_fin  ,TO_NUMBER(P_t_verre(compteur).SPHERE))   OR (o.spherep_deb   IS NULL AND o.spherep_fin   IS NULL))
       OR  (NVL(TO_NUMBER(P_t_verre(compteur).SPHERE),o.spheren_deb)   BETWEEN NVL(o.spheren_deb  ,TO_NUMBER(P_t_verre(compteur).SPHERE))   AND NVL(o.spheren_fin  ,TO_NUMBER(P_t_verre(compteur).SPHERE))   OR (o.spheren_deb   IS NULL AND o.spheren_fin   IS NULL)))
     AND (NVL(TO_NUMBER(P_t_verre(compteur).CYLINDRE),o.cylindre_deb)   BETWEEN NVL(o.cylindre_deb  ,TO_NUMBER(P_t_verre(compteur).CYLINDRE))   AND NVL(o.cylindre_fin  ,TO_NUMBER(P_t_verre(compteur).CYLINDRE))   OR (o.cylindre_deb   IS NULL AND o.cylindre_fin   IS NULL))
     AND (NVL(TO_NUMBER(P_t_verre(compteur).AXE),o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,TO_NUMBER(P_t_verre(compteur).AXE))   AND NVL(o.aminci_fin  ,TO_NUMBER(P_t_verre(compteur).AXE))   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(TO_NUMBER(P_t_verre(compteur).ADDITION),o.addition_deb)   BETWEEN NVL(o.addition_deb  ,TO_NUMBER(P_t_verre(compteur).ADDITION))   AND NVL(o.addition_fin  ,TO_NUMBER(P_t_verre(compteur).ADDITION))   OR (o.addition_deb   IS NULL AND o.addition_fin   IS NULL))
     AND o.codfrais = v.codfrais (+)
     AND (v.TYPE_VISION = P_vision OR v.TYPE_VISION IS NULL)
   ORDER BY n.codfrais, n.secu;


 CURSOR c_optique_SUPM
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_OPTIQUE o
       , NTFRS_TYP_VISION v
       ,lpp l
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = P_lpp
     AND l.codfrais=c.codfrais
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND o.codfrais (+) =c.codfrais
     AND NVL(n.supp_monture,0)=1
   ORDER BY n.codfrais, n.secu;

 CURSOR c_optique_SUPV IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_OPTIQUE o
       , NTFRS_TYP_VISION v
       ,lpp l
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = P_lpp
     AND l.codfrais=c.codfrais
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND o.codfrais (+) =c.codfrais
     AND NVL(n.supp_verre,0)=1
   ORDER BY n.codfrais, n.secu;

  -- curseur des lentilles
  CURSOR c_optique_actel
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
     --  , NTFRS a
       , NTFRS_OPTIQUE o
    --   , NTFRS_NGAP ng
       , RENEW_LENTILLE r
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND o.codfrais (+) =c.codfrais
     AND n.lentille=1

     AND (NVL(TO_NUMBER(P_t_lentille(compteur).SPHERE),o.spherep_deb)   BETWEEN NVL(o.spherep_deb  ,TO_NUMBER(P_t_lentille(compteur).SPHERE))   AND NVL(o.spherep_fin  ,TO_NUMBER(P_t_lentille(compteur).SPHERE))   OR (o.spherep_deb   IS NULL AND o.spherep_fin   IS NULL))
     AND (NVL(TO_NUMBER(P_t_lentille(compteur).CYLINDRE),o.cylindre_deb)   BETWEEN NVL(o.cylindre_deb  ,TO_NUMBER(P_t_lentille(compteur).CYLINDRE))   AND NVL(o.cylindre_fin  ,TO_NUMBER(P_t_lentille(compteur).CYLINDRE))   OR (o.cylindre_deb   IS NULL AND o.cylindre_fin   IS NULL))
     AND (NVL(TO_NUMBER(P_t_lentille(compteur).AXE),o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,TO_NUMBER(P_t_lentille(compteur).AXE))   AND NVL(o.aminci_fin  ,TO_NUMBER(P_t_lentille(compteur).AXE))   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(TO_NUMBER(P_t_lentille(compteur).ADDITION),o.addition_deb)   BETWEEN NVL(o.addition_deb  ,TO_NUMBER(P_t_lentille(compteur).ADDITION))   AND NVL(o.addition_fin  ,TO_NUMBER(P_t_lentille(compteur).ADDITION))   OR (o.addition_deb   IS NULL AND o.addition_fin   IS NULL))
     AND n.codfrais = r.codfrais (+)
   ORDER BY n.codfrais, n.secu;



BEGIN

  P_INS_journal(1,'Prestation n°'||compteur||' NATURE_PREST:' || P_Tab_acte(compteur).NATURE_PREST);
 -- P_INS_journal(1,'compteur:' || compteur);
 /* P_INS_journal(1,'Optique P_t_verre(compteur).SPHERE:' || P_t_verre(compteur).SPHERE);
  P_INS_journal(1,'Optique P_t_verre(compteur).CYLINDRE:' || P_t_verre(compteur).CYLINDRE);
  P_INS_journal(1,'Optique P_t_verre(compteur).AXE:' || P_t_verre(compteur).AXE);
  P_INS_journal(1,'Optique P_t_verre(compteur).ADDITION:' || P_t_verre(compteur).ADDITION);  */
  P_INS_journal(1,'P_Tab_acte(compteur).acteRemboursementSS:' || P_Tab_acte(compteur).acteRemboursementSS);



  IF TRIM(P_Tab_acte(compteur).NATURE_PREST) = 'LUN' THEN
    FOR rec_monture_acte IN c_monture_acte LOOP
      IF (rec_monture_acte.secu ='O' AND P_Tab_acte(compteur).acteRemboursementSS>0) OR (rec_monture_acte.secu ='N' AND P_Tab_acte(compteur).acteRemboursementSS=0) OR (rec_monture_acte.secu IS NULL) THEN
         O_codfrais:=rec_monture_acte.codfrais;
         loc_cpt:=loc_cpt+1;
         IF loc_cpt>1 THEN -- Transco multiple
           O_acte_err_code:='02';
         --  P_INS_journal(2,'Transco Multiple:' || P_Tab_acte(compteur).NATURE_EQUI_OPT);
         END IF;
      END IF;
    END LOOP;
  ELSIF TRIM(P_Tab_acte(compteur).NATURE_PREST) = 'VER' THEN

    IF P_t_verre(compteur).verreType IN (4,1) THEN -- 4 unifocal , 1 mi-distance
      loc_vision:=1;     -- 1 unifocal Arthus
    ELSE   -- 0 bifocal, 2 progessif, 3 trifocal
      loc_vision:=4;      -- 4 progressif(multifocal)) Arthus
    END IF;

    IF p_lpp IS NOT NULL THEN
      FOR rec_optique_actev IN c_optique_v_lpp LOOP
        P_INS_journal(1,'Code Acte:' || rec_optique_actev.codfrais);
        P_INS_journal(1,'secu:' || rec_optique_actev.secu);
        IF (rec_optique_actev.secu ='O' AND P_Tab_acte(compteur).acteRemboursementSS>0)
           OR (rec_optique_actev.secu ='N' AND P_Tab_acte(compteur).acteRemboursementSS=0) OR (rec_optique_actev.secu IS NULL) THEN
           P_INS_journal(1,'Acte trouvé' || rec_optique_actev.codfrais);
           O_codfrais:=rec_optique_actev.codfrais;
        END IF;
      END LOOP;
    ELSE
      FOR rec_optique_actev IN c_optique_actev(loc_vision) LOOP
        P_INS_journal(1,'Code Acte:' || rec_optique_actev.codfrais);
        P_INS_journal(1,'secu:' || rec_optique_actev.secu);
        IF (rec_optique_actev.secu ='O' AND P_Tab_acte(compteur).acteRemboursementSS>0)
           OR (rec_optique_actev.secu ='N' AND P_Tab_acte(compteur).acteRemboursementSS=0) OR (rec_optique_actev.secu IS NULL) THEN
           P_INS_journal(1,'Acte trouvé' || rec_optique_actev.codfrais);
           O_codfrais:=rec_optique_actev.codfrais;
        END IF;
      END LOOP;
    END IF;
  ELSIF TRIM(P_Tab_acte(compteur).NATURE_PREST) = 'LEN' THEN
    --ABO 17012020 retrait de la prise en compte du LPP pour les lentilles
    /*IF p_lpp IS NOT NULL THEN
      FOR rec_optique_actel IN c_optique_l_lpp LOOP
          P_INS_journal(1,'Optique rec_optique_actel.secu:' || rec_optique_actel.secu);
        IF (rec_optique_actel.secu ='O' AND P_Tab_acte(compteur).acteRemboursementSS>0)
           OR (rec_optique_actel.secu ='N' AND P_Tab_acte(compteur).acteRemboursementSS=0) OR (rec_optique_actel.secu IS NULL) THEN
             O_codfrais:=rec_optique_actel.codfrais;
        END IF;
      END LOOP;
    ELSE*/
      FOR rec_optique_actel IN c_optique_actel LOOP
          P_INS_journal(1,'Optique rec_optique_actel.secu:' || rec_optique_actel.secu);
        IF (rec_optique_actel.secu ='O' AND P_Tab_acte(compteur).acteRemboursementSS>0)
           OR (rec_optique_actel.secu ='N' AND P_Tab_acte(compteur).acteRemboursementSS=0) OR (rec_optique_actel.secu IS NULL) THEN
             O_codfrais:=rec_optique_actel.codfrais;
        END IF;
      END LOOP;
   -- END IF;
    --Gestion des supplements RAC OPTIQUE
  ELSIF TRIM(P_Tab_acte(compteur).NATURE_PREST) = 'VERSUP' THEN
           P_INS_journal(1,'CGR nature prest' || P_Tab_acte(compteur).NATURE_PREST);
     FOR rec_optique_SUPV IN c_optique_SUPV LOOP
        O_codfrais:=rec_optique_SUPV.codfrais;
         P_INS_journal(1,'CGR O_codfrais:' || O_codfrais);
        CONTINUE;
     END LOOP;

  ELSIF TRIM(P_Tab_acte(compteur).NATURE_PREST) = 'LUNSUP' THEN
     FOR rec_optique_SUPM IN c_optique_SUPM LOOP
        O_codfrais:=rec_optique_SUPM.codfrais;
        CONTINUE;
     END LOOP;
    --Fin Gestion des supplements RAC OPTIQUE

  END IF;

EXCEPTION

  WHEN OTHERS THEN
    o_acte_err_code:='99'; -- Erreur indeterminée
END P_TRANSCO_CODFRAIS_OPTIQUE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TRANSCO_CODFRAIS_DENTAIRE                               */
/* Type         :  Public                                                    */
/* Description  :  procedure de transcodification d'un code acte externe en  */
/*                 code acte Arthus                                          */
/* Retour       :  Retourne les code acte et le code erreur                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_TRANSCO_CODFRAIS_DENTAIRE( P_numfor             ADHESION.NUMFOR%TYPE
                                     , i                    NUMBER
                                     , P_Tab_acte           TAB_T_ACTE
                                     , P_t_dentaire         TAB_T_DENTAIRE
                                     , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                     , O_acte_err_code      OUT VARCHAR2)
IS


  compteur     NUMBER:=i;
  loc_vision   NUMBER:=0;
  loc_cpt      NUMBER:=0;
  loc_o_items  PK_FICHIER.TV_ITEMS;    -- Tableau permettant de récupérer les numéros de dents


  CURSOR c_dentaire_acte
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
                  ,ng.CODNGAP
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_NGAP ng
       , NTFRS_DETAIL n
       left outer join  NTFRS_DENTAIRE de ON  de.codfrais =n.codfrais
       left outer join  NTFRS_CCAM cc   ON  n.codfrais  =cc.codfrais
   WHERE n.dentaire =1
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND d.codfrais =c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
      AND ng.codfrais=c.codfrais
    AND ng.CODNGAP=NVL(P_t_dentaire(compteur).codeRegroupement,ng.CODNGAP)
    AND /*OR M0005659*/ cc.codccam =NVL(P_t_dentaire(compteur).codeCCAM,cc.codccam)
  ORDER BY ng.CODNGAP, n.secu;

  rec_dentaire_acte c_dentaire_acte%ROWTYPE;

BEGIN

  P_INS_journal(3,'P_t_dentaire(compteur).codeRegroupement:' || P_t_dentaire(compteur).codeRegroupement);
  -- Convertire la ligne (avec séparateur) en tableau
  --PK_FICHIER.pCreerTableau(P_t_dentaire(compteur).numerosDents,loc_o_items,',');
  P_INS_journal(3,'P_t_dentaire(compteur).numerosDents:' || P_t_dentaire(compteur).numerosDents);
  P_INS_journal(3,'P_t_dentaire(compteur).codeCCAM:' || P_t_dentaire(compteur).codeCCAM);
  P_INS_journal(3,'P_Tab_acte(compteur).acteRemboursementSS:'||P_Tab_acte(compteur).acteRemboursementSS);
  loc_cpt:= P_t_dentaire(compteur).nombreDents;

  IF loc_cpt < 1 THEN
    loc_o_items(1):=0;
  END IF;
  IF loc_cpt < 2 THEN
    loc_o_items(2):=0;
  END IF;
  IF loc_cpt < 3 THEN
    loc_o_items(3):=0;
  END IF;
  IF loc_cpt < 4 THEN
    loc_o_items(4):=0;
  END IF;
  IF loc_cpt < 5 THEN
    loc_o_items(5):=0;
  END IF;
  IF loc_cpt < 6 THEN
    loc_o_items(6):=0;
  END IF;
  IF loc_cpt < 7 THEN
    loc_o_items(7):=0;
  END IF;
  IF loc_cpt < 8 THEN
    loc_o_items(8):=0;
  END IF;
  IF loc_cpt < 9 THEN
    loc_o_items(9):=0;
  END IF;
  IF loc_cpt < 10 THEN
    loc_o_items(10):=0;
  END IF;
  IF loc_cpt < 11 THEN
    loc_o_items(11):=0;
  END IF;
  IF loc_cpt < 12 THEN
    loc_o_items(12):=0;
  END IF;
  IF loc_cpt < 13 THEN
    loc_o_items(13):=0;
  END IF;
  IF loc_cpt < 14 THEN
    loc_o_items(14):=0;
  END IF;
  IF loc_cpt < 15 THEN
    loc_o_items(15):=0;
  END IF;
  IF loc_cpt < 16 THEN
    loc_o_items(16):=0;
  END IF;

  O_acte_err_code:='00';
  -- Verification de la validité de la famille d acte optique sur la garantie
  -- Recherche de la totalité des actes de la famille optique de la garantie dont il existe une possible trancodification
  -- Recherche de l'acte ARTHUS transcodé
  FOR rec_dentaire_acte IN c_dentaire_acte LOOP
  --   P_INS_journal(1,'rec_dentaire_acte:'|| rec_dentaire_acte.codfrais);
    IF (rec_dentaire_acte.secu ='O' AND P_Tab_acte(compteur).acteRemboursementSS>0) OR (rec_dentaire_acte.secu ='N' AND P_Tab_acte(compteur).acteRemboursementSS=0) OR (rec_dentaire_acte.secu IS NULL) THEN
     --   P_INS_journal(1,'rec_dentaire_acte 1 :'|| rec_dentaire_acte.codfrais);
      O_codfrais:=rec_dentaire_acte.codfrais;
      EXIT;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'WHEN OTHERS THEN P_TRANSCO_CODFRAIS_DENTAIRE');
    o_acte_err_code:='99'; -- Erreur indeterminée
END P_TRANSCO_CODFRAIS_DENTAIRE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TRANSCO_CODFRAIS_AUDITIF                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de transcodification d'un code acte externe en  */
/*                 code acte Arthus                                          */
/* Retour       :  Retourne les code acte et le code erreur                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_TRANSCO_CODFRAIS_AUDITIF( P_numfor             ADHESION.NUMFOR%TYPE
                                    , i                    NUMBER
                                    , P_Tab_acte           TAB_T_ACTE
                                    , P_t_auditif          TAB_T_AUDITIF
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2
                                    , P_lpp                 VARCHAR2    --RKO Rac Audio
                                    )
IS

  compteur     NUMBER:=i;
  loc_vision   NUMBER:=0;
  loc_cpt      NUMBER:=0;

 /* CURSOR c_famille_acte
      IS
  SELECT d.codfrais
    FROM DEFRUB d
   WHERE d.codfrais like 'K%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor;

  rec_famille c_famille_acte%ROWTYPE; */

  /*CURSOR c_acte
      IS
  SELECT DISTINCT c.codfrais
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , lpp l
    --   , NTFRS a
   WHERE d.codfrais like 'K%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND l.code_lpp = NVL(P_lpp,l.code_lpp)    --RKO Rac Audio
     AND l.codfrais=c.codfrais
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND c.numfor=d.numfor
   --  AND a.codfrais = c.codfrais
   --  AND d.codfrais =a.rubrique
     AND d.codfrais = c.rubrique
     AND n.codfrais=c.codfrais
 ORDER BY c.codfrais ;

  rec_acte c_acte%ROWTYPE; */

  CURSOR c_auditif_acte
      IS
    /*SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_AUDITIF de
       , NTFRS_NGAP ng
   WHERE d.codfrais like 'K%'  -- On traite uniquement les famille du dentaire
     AND d.numfor=P_numfor --P_numfor
     AND l.codfrais=c.codfrais
     AND c.numfor=d.numfor
     AND d.codfrais =c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.codfrais=c.codfrais
  --   AND n.auditif=1
     AND ng.codfrais=c.codfrais
     AND ng.CODNGAP=NVL(P_Tab_acte(compteur).NATURE_PREST,ng.CODNGAP)
     AND de.codfrais (+) =c.codfrais
   --  AND (de.quantite = NVL(P_Tab_acte(compteur).QUANT_ACTE,de.quantite) or de.quantite is null)
  ORDER BY n.codfrais, n.secu;    */

  --RKO RAC AUDIO
  SELECT  n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_AUDITIF de
      -- , NTFRS_NGAP ng
       , lpp l
   WHERE d.codfrais like 'K%'  --famille audiologie
    AND d.codfrais =c.rubrique
    AND d.numfor= P_numfor --109531
    AND l.code_lpp =  P_lpp --2307926
    AND c.numfor=d.numfor
    AND c.codfrais = n.codfrais
    AND  n.auditif=1 --acte auditif
    AND l.codfrais=c.codfrais
    AND de.codfrais (+) =c.codfrais
   -- AND ng.codfrais=c.codfrais
    -- AND ng.CODNGAP=NVL(/*P_Tab_acte(compteur).NATURE_PREST*/null,ng.CODNGAP)
    AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
    AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
      ;

  rec_auditif_acte c_auditif_acte%ROWTYPE;

BEGIN

  O_acte_err_code:='00';
  -- Verification de la validité de la famille d acte optique sur la garantie
  --FOR rec_famille IN c_famille_acte LOOP
    -- Recherche de la totalité des actes de la famille optique de la garantie dont il existe une possible trancodification
    IF p_lpp IS NOT NULL THEN
        --FOR rec_acte IN c_acte LOOP
          -- Recherche de l'acte ARTHUS transcodé
          FOR rec_auditif_acte IN c_auditif_acte LOOP
            P_INS_journal(1,'Code Acte:' || rec_auditif_acte.codfrais);
            P_INS_journal(1,'secu:' || rec_auditif_acte.secu);
            IF (rec_auditif_acte.secu ='O' AND P_Tab_acte(compteur).acteRemboursementSS>0)
                OR (rec_auditif_acte.secu ='N' AND P_Tab_acte(compteur).acteRemboursementSS=0)
                OR (rec_auditif_acte.secu IS NULL) THEN
                P_INS_journal(1,'Acte trouvé' || rec_auditif_acte.codfrais);
                O_codfrais:=rec_auditif_acte.codfrais;
            END IF;
          END LOOP;
        --END LOOP;
    END IF;
  --END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    o_acte_err_code:='99'; -- Erreur indeterminée
END P_TRANSCO_CODFRAIS_AUDITIF;

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
                               , P_t_verre     IN TAB_T_VERRE
                               , P_num_dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE
                                )
IS

  loc_cpt   number;

BEGIN

  INSERT INTO PEC_DETAILS(ID_PEC_DETAILS,NUMPORTE,CODFRAIS,NUMDOSSIER, NUMLIGNE, OEIL, NUMINDIV,NUMFOR,DATSIN,SPHERE,CYLINDRE,AXE,ADDITION)
  VALUES(ID_PEC_DETAILS.nextval,22,P_codfrais, P_num_dossier, i, P_t_verre(i).OEIL, P_numindiv,P_numfor,SYSDATE,P_t_verre(i).SPHERE,P_t_verre(i).CYLINDRE,P_t_verre(i).AXE,P_t_verre(i).ADDITION);


END P_INSERT_INFOS_VERRES;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FIND_INFOS_VERRES                                       */
/* Type         :  Privee                                                    */
/* Description  :  Recherche des informations sur la dioptrie des verres     */
/* Entree       :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FIND_INFOS_VERRES( P_numindiv    IN sinistre_sante.numindiv%TYPE
                             , P_codfrais    IN sinistre_sante.codfrais%TYPE
                             , P_numfor      IN ADHESION.NUMFOR%TYPE
                             , i             IN NUMBER
                          --   , P_Tab_acte    IN TAB_T_ACTE
                             , P_t_verre     IN TAB_T_VERRE
                             , P_num_dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE
                              )
RETURN NUMBER
IS

  loc_cpt   number;

BEGIN
  P_INS_journal(1,'F_FIND_INFOS_VERRES');

  -- TO_DO a supprimer : permet de ne pas prendre en compte les dossiers optique entre la livraison initial et la mise en attente d un dossier
/*
  BEGIN
    SELECT MAX(num_dossier)
      INTO loc_cpt
      FROM dossier_sante
     WHERE numporte = 22
       AND TYPE_DOSS=4
       AND numindiv = P_numindiv
       AND creation BETWEEN to_date('01/03/2017','dd/mm/yyyy') AND to_date('03/10/2017','dd/mm/yyyy')-1;

     IF loc_cpt IS NULL THEN
       RETURN NULL ;
     END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      P_INS_journal(1,'NO_DATA_FOUND 1 loc_cpt : '|| loc_cpt);
      RETURN NULL;
    WHEN OTHERS THEN
      P_INS_journal(1,'OTHERS 1 loc_cpt : '|| loc_cpt);
      RETURN 1 ;
  END;
*/

  -- On verifie que l assure possède une ligne dans la table PEC_DETAILS
 /*-BEGIN
    SELECT MAX(ID_PEC_DETAILS)
      INTO loc_cpt
      FROM PEC_DETAILS
     WHERE NUMINDIV = P_numindiv;

     IF loc_cpt IS NULL THEN
       RETURN NULL ;
     END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      P_INS_journal(1,'NO_DATA_FOUND 1 loc_cpt : '|| loc_cpt);
      RETURN NULL;
    WHEN OTHERS THEN
      P_INS_journal(1,'OTHERS 1 loc_cpt : '|| loc_cpt);
      RETURN 1 ;
  END;
  */
    loc_cpt:=NULL;
    P_INS_journal(1,'loc_cpt : '|| loc_cpt);
    P_INS_journal(1,'P_numindiv : '|| P_numindiv);
    P_INS_journal(1,'P_t_verre(i).OEIL : '|| P_t_verre(i).OEIL);
    P_INS_journal(1,'P_t_verre(i).SPHERE : '|| to_char(P_t_verre(i).SPHERE));
    P_INS_journal(1,'P_t_verre(i).CYLINDRE : '|| to_char(P_t_verre(i).CYLINDRE));
    P_INS_journal(1,'P_t_verre(i).ADDITION : '|| to_char(P_t_verre(i).ADDITION));
    P_INS_journal(1,'P_t_verre(i).AXE : '|| to_char(P_t_verre(i).AXE));
  -- on vérifie les information des infos du verre sur le dossier précédent
  SELECT MAX(ID_PEC_DETAILS)
    INTO loc_cpt
    FROM PEC_DETAILS
   WHERE NUMINDIV = P_numindiv
     AND (SPHERE   = P_t_verre(i).SPHERE     OR SPHERE   IS NULL)
     AND (CYLINDRE = P_t_verre(i).CYLINDRE   OR CYLINDRE IS NULL)
     AND (ADDITION = P_t_verre(i).ADDITION   OR ADDITION IS NULL)
     AND (AXE      = P_t_verre(i).AXE        OR AXE      IS NULL)
     AND NUMPORTE IN (22) -- ITELIS
     AND d2j(DATSIN) BETWEEN d2j(SYSDATE-730) AND d2j(SYSDATE)
    -- AND NUMDOSSIER = P_num_dossier
    -- AND NUMLIGNE = i
     AND OEIL = P_t_verre(i).oeil
     AND EXISTS (SELECT NUMSIN
                   FROM SNTR_DOSSIER sd
                      , SINISTRE s
                  WHERE s.NUMSIN = sd.NUMSIN_SNTR
                    AND sd.NUM_DOSSIER <> P_num_dossier
                    AND s.NUMINDIV = P_numindiv
                    AND d2j(s.DATSIN) BETWEEN d2j(SYSDATE-730) AND d2j(SYSDATE));


  P_INS_journal(1,'loc_cpt : '|| loc_cpt);
  P_INS_journal(1,'P_num_dossier : '|| P_num_dossier);

  RETURN NVL(loc_cpt,0);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    P_INS_journal(1,'NO_DATA_FOUND 2 loc_cpt : '|| loc_cpt);
    RETURN 0;        -- Changement de diopterie
  WHEN OTHERS THEN
    P_INS_journal(1,'OTHERS 2 loc_cpt : '|| loc_cpt);
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

  v_From      VARCHAR2(80) := 'm.bougard@gerep.fr';
  v_Recipient VARCHAR2(80) := 'm.bougard@gerep.fr';
  v_Mail_Host VARCHAR2(30) := NULL; --'no-reply@gerep.fr'; -- 'mail.gerep.fr';
  v_Mail_Conn utl_smtp.Connection;
  crlf        VARCHAR2(2)  := chr(13)||chr(10);

BEGIN
  BEGIN
    SELECT nom_machine
      INTO v_Mail_Host
      FROM PARAM_MACHINE
     WHERE TRIM(compte_mail) IS NOT NULL;
   EXCEPTION
     WHEN OTHERS THEN
       v_Mail_Host:= 'no-reply@gerep.fr';
   END;

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

/*----------------------------------------------------------------------------*/

PROCEDURE P_DENT (p_dentaire IN T_DENTAIRE,
                  p_domaine      IN NUMBER,
                  o_items        OUT PK_FICHIER.TV_ITEMS,
                  P_IO_TRAV_SAISIE IN OUT TRAV_SAISIE%ROWTYPE)
IS
  loc_cpt     NUMBER:=0;

BEGIN

  -- Convertire la ligne (avec séparateur) en tableau
  PK_FICHIER.pCreerTableau(p_dentaire.numerosDents,o_items,',');
  loc_cpt:= p_dentaire.nombreDents;
  IF loc_cpt < 1 THEN
    P_IO_TRAV_SAISIE.LOCDENT1:=NULL;
    o_items(1):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT1:=o_items(1);
  END IF;
  IF loc_cpt < 2 THEN
    P_IO_TRAV_SAISIE.LOCDENT2:=NULL;
    o_items(2):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT2:=o_items(2);
  END IF;
  IF loc_cpt < 3 THEN
    P_IO_TRAV_SAISIE.LOCDENT3:=NULL;
    o_items(3):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT3:=o_items(3);
  END IF;
  IF loc_cpt < 4 THEN
    P_IO_TRAV_SAISIE.LOCDENT4:=NULL;
    o_items(4):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT4:=o_items(4);
  END IF;
  IF loc_cpt < 5 THEN
    P_IO_TRAV_SAISIE.LOCDENT5:=NULL;
    o_items(5):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT5:=o_items(5);
  END IF;
  IF loc_cpt < 6 THEN
    P_IO_TRAV_SAISIE.LOCDENT6:=NULL;
    o_items(6):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT6:=o_items(6);
  END IF;
  IF loc_cpt < 7 THEN
    P_IO_TRAV_SAISIE.LOCDENT7:=NULL;
    o_items(7):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT7:=o_items(7);
  END IF;
  IF loc_cpt < 8 THEN
    P_IO_TRAV_SAISIE.LOCDENT8:=NULL;
    o_items(8):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT8:=o_items(8);
  END IF;
  IF loc_cpt < 9 THEN
    P_IO_TRAV_SAISIE.LOCDENT9:=NULL;
    o_items(9):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT9:=o_items(9);
  END IF;
  IF loc_cpt < 10 THEN
    P_IO_TRAV_SAISIE.LOCDENT10:=NULL;
    o_items(10):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT10:=o_items(10);
  END IF;
  IF loc_cpt < 11 THEN
    P_IO_TRAV_SAISIE.LOCDENT11:=NULL;
    o_items(11):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT11:=o_items(11);
  END IF;
  IF loc_cpt < 12 THEN
    P_IO_TRAV_SAISIE.LOCDENT12:=NULL;
    o_items(12):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT12:=o_items(12);
  END IF;
  IF loc_cpt < 13 THEN
    P_IO_TRAV_SAISIE.LOCDENT13:=NULL;
    o_items(13):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT13:=o_items(13);
  END IF;
  IF loc_cpt < 14 THEN
    P_IO_TRAV_SAISIE.LOCDENT14:=NULL;
    o_items(14):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT14:=o_items(14);
  END IF;
  IF loc_cpt < 15 THEN
    P_IO_TRAV_SAISIE.LOCDENT15:=NULL;
    o_items(15):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT15:=o_items(15);
  END IF;
  IF loc_cpt < 16 THEN
    P_IO_TRAV_SAISIE.LOCDENT16:=NULL;
    o_items(16):=0;
  ELSE
    P_IO_TRAV_SAISIE.LOCDENT6:=o_items(16);
  END IF;

END P_DENT;

/*-----------------------------------------------------------------------------*/


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
        I_session  => NVL(g_session, sid),
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;

END P_INS_journal;

END PK_ITELIS;
/
