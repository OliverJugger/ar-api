CREATE OR REPLACE PACKAGE ARTHUS."PK_TP_GROUPAMA"
AS
/*============================================================================*/
/* PACKAGE      : PK_TP_GROUPAMA.sql                                          */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* Création     : 10/08/2011                                                  */
/* Description  : package gérant les flux xml de groupama pour Gerep contrôle,*/
/*                historisation, génération de la réponse xml                 */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 15/05/2012 / Ajout du cartouche du package            */
/*                Ajout du paramètre false aux procedures pk_xml.get_xml,     */
/*                pk_xml.add_data et pk_xml.merge_data afin de ne pas prendre */
/*                en compte les flux xml au format UTF-8                      */
/* Correction   : ABO 28/10/2014  détection du délai de traitement            */
/* Correction   : ABO 10/08/2016 4706 transodification et 4767 carte TPE      */
/*Evolution    : JBO 07/02/2017 Mise en place de la notion de réseau de soins */
/*              : P201608003_reseau_soin_GEREP + M5232                        */
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
-- Aucun
-- ------------------------------------------------- Fin des types publiques --

   -- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --

   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------

FUNCTION F_CRTL_DROIT (
  P_xml IN XMLTYPE
) RETURN XMLTYPE;

FUNCTION F_DEMANDE_PEC (
  P_xml IN XMLTYPE
)RETURN XMLTYPE;

FUNCTION F_CONFIRM_PEC (
  P_xml IN XMLTYPE
)RETURN XMLTYPE;

FUNCTION F_ANNUL_PEC (
  P_xml IN XMLTYPE
)RETURN XMLTYPE;

FUNCTION F_LIQUID_TP(
 P_num_dossier dossier_sante.num_dossier%TYPE
)RETURN NUMBER;

FUNCTION F_LIQUID_TP_RETOUR( p_id_flux in number,
                            P_XML IN XMLTYPE
) RETURN NUMBER;

Procedure P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_TP_GROUPAMA;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_TP_GROUPAMA"
As
/*============================================================================*/
/* PACKAGE      : PK_TP_GROUPAMA.sql                                          */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* Création     : 10/08/2011                                                  */
/* Description  : package gérant les flux xml de groupama pour Gerep contrôle,*/
/*                historisation, génération de la réponse xml                 */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 15/05/2012 / Ajout du cartouche du package            */
/*                Ajout du paramètre false aux procedures pk_xml.get_xml,     */
/*                pk_xml.add_data et pk_xml.merge_data afin de ne pas prendre */
/*                en compte les flux xml au format UTF-8                      */
/*============================================================================*/

   -- -- PROCEDURES PRIVEES ----------------------------------------------------
--


PROCEDURE P_ENTETE(
  P_bal IN VARCHAR2,
  P_emet IN VARCHAR2,
  P_emet_sup IN VARCHAR2,
  P_dest IN VARCHAR2,
  P_dest_sup IN VARCHAR2,
  P_flux IN VARCHAR2
);
PROCEDURE P_ENTETE_QUEST(
  P_emet IN VARCHAR2,
  P_emet_sup IN VARCHAR2,
  P_dest IN VARCHAR2,
  P_dest_sup IN VARCHAR2,
  P_flux IN VARCHAR2,
  P_code IN VARCHAR2,
  P_gest IN VARCHAR2
);
PROCEDURE P_ENTETE_REP(
  P_emet IN VARCHAR2,
  P_emet_sup IN VARCHAR2,
  P_dest IN VARCHAR2,
  P_dest_sup IN VARCHAR2,
  P_flux IN VARCHAR2,
  P_code IN VARCHAR2
);
PROCEDURE P_ENTETE_REP_ERREUR(
  P_codeRetour IN VARCHAR2,
  P_libErreur IN VARCHAR2
);


-- ------------------------------------------------- Fin des procedures privees --


-- Variables de P_INS_journal
G_nom_traitement  Constant journal_adm.nom_traitement%TYPE default 'WS06T';
G_niv_msg   journal_adm.niv_msg%TYPE;
G_idligne   journal_adm.idligne%TYPE := 0;


-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- ---------------------------------------------- Fin des constantes privees --

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
exc_reference_inconnue EXCEPTION;
exc_contrat_invalide   EXCEPTION;
exc_contrat_resilie    EXCEPTION;
exc_adhe_invalide      EXCEPTION;
exc_adhe_non_couvert   EXCEPTION;
exc_erreur_inconnue    EXCEPTION;
exc_dossier_inconnu    EXCEPTION;
exc_dossier_annule     EXCEPTION;
exc_dossier_facture    EXCEPTION;
exc_adhe_non_tp        EXCEPTION;
exc_erreur_doublon_PS  EXCEPTION;
exc_prestation_null    EXCEPTION;
exc_rc_different       EXCEPTION;


-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
loc_t_etatcntrt varchar2(20);
loc_t_assure  varchar2(20);
loc_t_org varchar2(20);
loc_t_civilite varchar2(20);
loc_t_bene varchar2(20);
loc_grpporte number(2) := 6; -- Porte du groupement SEVEANE
loc_numporte dossier_sante.numporte%type;
-- -------------------------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------

--ABO 02/07/2010 ENTETE
PROCEDURE P_ENTETE(
  P_bal IN VARCHAR2,
  P_emet IN VARCHAR2,
  P_emet_sup IN VARCHAR2,
  P_dest IN VARCHAR2,
  P_dest_sup IN VARCHAR2,
  P_flux IN VARCHAR2
)IS
BEGIN
  pk_xml.add_element(P_bal, 'ent:Emetteur');
  pk_xml.add_data('ent:Emetteur','ent:IdentificationCompagnie',P_emet, false);
  pk_xml.add_data('ent:Emetteur','ent:IdentificationSupplement',P_emet_sup, false);

  pk_xml.add_element(P_bal, 'ent:Destinataire');
  pk_xml.add_data('ent:Destinataire','ent:IdentificationCompagnie',P_dest, false);
  pk_xml.add_data('ent:Destinataire','ent:IdentificationSupplement',P_dest_sup, false);

  pk_xml.add_element(P_bal, 'ent:Flux');
  pk_xml.add_data('ent:Flux','ent:Identifiant',P_flux, false);
  pk_xml.add_data('ent:Flux','ent:Date',To_char(sysdate,'DDMMYYYY'), false);
  pk_xml.add_data('ent:Flux','ent:Heure',To_char(sysdate,'HH24MMSS'), false);
  pk_xml.add_data('ent:Flux','ent:Version','001', false);

END;

--ABO 02/07/2010 Entete de message de question
PROCEDURE P_ENTETE_QUEST(
  P_emet IN VARCHAR2,
  P_emet_sup IN VARCHAR2,
  P_dest IN VARCHAR2,
  P_dest_sup IN VARCHAR2,
  P_flux IN VARCHAR2,
  P_code IN VARCHAR2,
  P_gest IN VARCHAR2
) IS
BEGIN
  pk_xml.add_element('/', 'EnteteQuestion');
  P_entete('EnteteQuestion',P_emet,P_emet_sup,P_dest,P_dest_sup,P_flux);
  pk_xml.add_data('EnteteQuestion','ent:CodeService',P_code, false);
  pk_xml.add_data('EnteteQuestion','ent:Gestionnaire',P_gest, false);
END;

--ABO 02/07/2010 Entete de message de réponse
PROCEDURE P_ENTETE_REP(
  P_emet IN VARCHAR2,
  P_emet_sup IN VARCHAR2,
  P_dest IN VARCHAR2,
  P_dest_sup IN VARCHAR2,
  P_flux IN VARCHAR2,
  P_code IN VARCHAR2
) IS
BEGIN
  pk_xml.add_element('/', 'ent:enteteReponse');
  P_entete('ent:enteteReponse',P_emet,P_emet_sup,P_dest,P_dest_sup,P_flux);
  pk_xml.add_element('ent:enteteReponse','ent:Service');
  pk_xml.add_data('ent:Service','ent:CodeService',P_code, false);
END;

--ABO 02/07 Entete msg réponse - mise à jour des éventuelles erreurs
PROCEDURE P_ENTETE_REP_ERREUR(
  P_codeRetour IN VARCHAR2,
  P_libErreur IN VARCHAR2
)IS
BEGIN
  pk_xml.merge_data('ent:Service','ent:CodeRetour',P_codeRetour, false);
  pk_xml.merge_data('ent:Service','ent:LibelleErreur',SUBSTR(P_libErreur,1,255), false);
END;
-- -- FIN CORPS DES PROCEDURES PRIVEES --------------------------------------
----------------------------------------------------------------------------

-- -- CORPS DES PROCEDURES PUBLIQUES --------------------------------------

--ABO 29/06/2010 GROUPAMA flux retour de contrôle de droits
FUNCTION F_CRTL_DROIT (
P_xml IN XMLTYPE
) RETURN XMLTYPE IS

  V_refContrat VARCHAR2(16);
  loc_numAdhe VARCHAR2(16);
  loc_domaine VARCHAR2(6):='OPT'; --TO DO à initialiser en fonction du paramétrage
  C_lstBene PK_CTRL_TP.Fetch_adhe_membre%ROWTYPE;
  v_xml xmltype;
  V_etatCntrt NUMBER(2);
  v_id_flux flux.id_flux%TYPE;
  v_cod_err number:=0;

  loc_idadhesion  adhe_cntrt.idadhesion%TYPE;
  loc_numAdhePrinc  adhe_cntrt.numadhe%TYPE;
  loc_numgar  contrat_ref.numgar%TYPE;
  loc_isColl  Boolean;
  loc_coll VARCHAR2(2);
  loc_libelle  produit.libelle%TYPE;
  loc_dateEffet  adhe_cntrt.date_adhe%TYPE;--mettre la date au format to_char(loc_dateEffet,'dd/mm/yyyy')
  loc_dateRes  adhe_cntrt.date_fin_adhe%TYPE;
  loc_numorg contrat_ref.numorg%TYPE;
  erreur_adhesion NUMBER :=0;
  erreur_contrat NUMBER :=0;
  erreur_99 BOOLEAN :=FALSE;
  loc_found   NUMBER :=0;

  loc_etatAdhe NUMBER :=0;

  loc_ligne1  VARCHAR2(50);
  loc_ligne2  VARCHAR2(50);
  loc_ligne3  VARCHAR2(50);
  loc_ligne4  VARCHAR2(50);
  loc_ligne5  VARCHAR2(50);
  loc_cp  pers_adresse.codpos%TYPE;
  loc_ville pers_adresse.ville%TYPE;
  loc_tel contact.coordonnee%TYPE;
  loc_regime VARCHAR2(2); -- regime ou sous regime pour les Alsace Moselle

  loc_isCouvert Boolean;
  loc_isTP Boolean;
  loc_couverture VARCHAR2(2);
  loc_reg_spe def_variable.idvariable%TYPE;
  v_deb NUMBER;
	v_delai NUMBER;

BEGIN
  G_IDLIGNE := 0;
  --dbms_output.put_line('F_CRTL_DROIT début');
  P_INS_journal(1,'F_CRTL_DROIT début', '');

  DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');

  -- ***************************************************************************
  -- * Validation XML Question / Création XML Réponse
  -- ***************************************************************************
                                                                                P_INS_journal(3,'F_CRTL_DROIT ', 'INIT');
  -- Initialisation des namespaces XML
  pk_xml.vg_xmlns := 'xmlns="pck/schemas/controleDroits" xmlns:ent="pck/schemas/defaut/message';

  -- Initialisation XML réponse
  v_deb:=DBMS_UTILITY.GET_TIME;
  pk_xml.new_xml;

  -- Constitution de l'entete de la réponse
  P_ENTETE_REP(P_emet     => '00401554',
               P_emet_sup => '',
               P_dest     => PK_XML.EXTRACT_DATA(P_xml,'ent:Emetteur/ent:IdentificationCompagnie'),
               P_dest_sup => PK_XML.EXTRACT_DATA(P_xml,'ent:Emetteur/ent:IdentificationSupplement'),
               P_flux     => PK_XML.EXTRACT_DATA(P_xml,'ent:Flux/ent:Identifiant'),
               P_code     => '10');

  -- Initialisation du code retour
  P_ENTETE_REP_ERREUR('00','');

  BEGIN
                                                                                P_INS_journal(3,'F_CRTL_DROIT ', 'HISTO');
    -- Historisation du flux aller "Contrôle de droits" (type 2)
    v_id_flux := pk_ws.insert_flux(p_id_type       => 2,
                                   p_id_flux_tiers => PK_XML.EXTRACT_DATA(P_xml,'ent:Flux/ent:Identifiant'),
                                   p_doc_xml       => p_xml,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => loc_grpporte );
    IF v_cod_err <> 0 THEN                                                      P_INS_journal(2,v_id_flux||' F_CRTL_DROIT err histo','exc_erreur_inconnue');
       raise exc_erreur_inconnue;
    END IF;

    -- Validation du flux aller
    /*IF NOT pk_ws.is_flux_valid(p_xml, 2, v_id_flux) THEN                        P_INS_journal(2,v_id_flux||' F_CRTL_DROIT valide','exc_erreur_inconnue');
       raise exc_erreur_inconnue;
    END IF;*/

    -- ***************************************************************************
    -- * Contrôles
    -- ***************************************************************************

    -- Extraction flux aller des infos Contrat
    V_refContrat := PK_XML.EXTRACT_DATA(P_xml,'NumContrat');
    loc_numAdhe := PK_XML.EXTRACT_DATA(P_xml,'NumAdhesion');

    -- Contrôle de l'identification de l'adhésion, assureur...
    PK_CTRL_TP.P_FIND_CONTRAT(
      V_refContrat,
      loc_numAdhe,
      loc_grpporte,
      loc_idadhesion,
      loc_numAdhePrinc,
      loc_numgar,
      loc_isColl,
      loc_libelle,
      loc_dateEffet,
      loc_dateRes,
      loc_numorg,
      loc_numporte,
      erreur_contrat);

    IF erreur_contrat = 1 THEN                                                  P_INS_journal(2,v_id_flux||' F_CRTL_DROIT err contrat',' exc_reference_inconnue');
       RAISE exc_reference_inconnue;
    ELSIF erreur_contrat = 2 THEN                                               P_INS_journal(2,v_id_flux||' F_CRTL_DROIT err contrat','exc_adhe_non_tp');
       RAISE exc_adhe_non_tp;
    ELSIF erreur_contrat <> 0 THEN                                              P_INS_journal(2,v_id_flux||' F_CRTL_DROIT err contrat ','exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    END IF;

    -- Contrôle Etat du contrat
    V_etatCntrt := PK_CTRL_TP.F_CTRL_CNTRT(loc_numgar,sysdate);

    IF V_etatCntrt = 3 THEN                                                     P_INS_journal(2,v_id_flux||' F_CRTL_DROIT etat contrat','exc_contrat_resilie');
       RAISE exc_contrat_resilie;
    ELSIF V_etatCntrt <> 1 THEN                                                 P_INS_journal(2,v_id_flux||' F_CRTL_DROIT etat contrat','exc_contrat_invalide');
       RAISE exc_contrat_invalide;
    END IF;
                                                                                P_INS_journal(3,v_id_flux||' F_CRTL_DROIT ', '11');
    -- Contrôle de l'adhésion
    PK_CTRL_TP.P_CTRL_ADHESION (
      loc_idadhesion,
      loc_numgar,
      loc_domaine,
      false,
      loc_etatAdhe,
      erreur_adhesion);

    IF erreur_adhesion IN (7,8,9) THEN                                          P_INS_journal(2,v_id_flux||' F_CRTL_DROIT err adh','exc_adhe_invalide');
       raise exc_adhe_invalide;
    ELSIF erreur_adhesion <> 0 THEN                                             P_INS_journal(2,v_id_flux||' F_CRTL_DROIT err adh','exc_erreur_inconnue');
       raise exc_erreur_inconnue;
    END IF;

    -- ***************************************************************************
    -- * Formatage des données
    -- ***************************************************************************

    -- Nom du contrat
    loc_libelle:=substr(loc_libelle, 1, 30);

    -- Trancodification de l'état
    loc_t_etatcntrt :=F_get_transco('GRP','ET_ADHE',loc_etatAdhe);

    --Transcodification contrat collectif ou non
    IF loc_isColl THEN loc_coll:='02';
    ELSE loc_coll:='01';
    END IF;

    --Adresse de l'assuré principal mis au format
    PK_CTRL_TP.P_ADR_FORMAT(
      loc_numAdhePrinc,
      loc_ligne1,
      loc_ligne2,
      loc_ligne3 ,
      loc_ligne4,
      loc_ligne5,
      loc_cp ,
      loc_ville);

    loc_ligne1:=substr(loc_ligne1, 1, 38);
    loc_ligne2:=substr(loc_ligne2, 1, 38);
    loc_ligne3:=substr(loc_ligne3, 1, 38);
    loc_ligne4:=substr(loc_ligne4, 1, 38);
    loc_ligne5:=substr(loc_ligne5, 1, 38);
    loc_ville:=substr(loc_ville, 1, 32);
    --dbms_output.put_line ('contrat');

    --Téléphone de l'assuré principal mis au format groupama
    loc_tel:=PK_CTRL_TP.F_FIND_CONTACT(loc_numAdhePrinc,1);
    loc_tel := substr(replace(replace(replace(loc_tel,'.'),' '),'/'),1,10);--mise au format

    IF  length(loc_tel)<>10 THEN loc_tel:=null;
    END IF;

    --Transcodification de l'assureur
    loc_t_org :=F_get_transco('GRP','ORGN',loc_numorg);
    --Recherche du regime spe
    loc_reg_spe:= F_Find_var('PER_REGSPE');

    -- ***************************************************************************
    -- * Constitution du XML
    -- ***************************************************************************
                                                                                P_INS_journal(3,v_id_flux||' F_CRTL_DROIT ', 'DEBUT XML');
    -- Contrôle données obligatoires
    IF V_refContrat IS NULL OR loc_numAdhe IS NULL OR loc_libelle IS NULL OR
       loc_ligne1 IS NULL OR loc_cp IS NULL OR loc_ville IS NULL OR
       loc_dateEffet IS NULL OR loc_t_org IS NULL
    THEN                                                                        P_INS_journal(2,v_id_flux||' F_CRTL_DROIT erreur(s)','DATA');
       raise exc_erreur_inconnue;
    END IF;

    pk_xml.add_element('/', 'Contrat');
    pk_xml.add_data('Contrat', 'Numero',V_refContrat, false);
    pk_xml.add_data('Contrat', 'NumAdhesion',loc_numAdhe, false);
    pk_xml.add_data('Contrat', 'Etat',loc_t_etatcntrt, false);
    pk_xml.add_data('Contrat', 'Type',loc_coll, false);
    pk_xml.add_data('Contrat', 'NomContratSouscrit',loc_libelle, false);
    pk_xml.add_element('Contrat', 'AdresseAdherent');
    pk_xml.add_data('AdresseAdherent', 'ent:Ligne1',loc_ligne1, false);
    pk_xml.add_data('AdresseAdherent', 'ent:Ligne2',loc_ligne2, false);
    pk_xml.add_data('AdresseAdherent', 'ent:Ligne3',loc_ligne3, false);
    pk_xml.add_data('AdresseAdherent', 'ent:Ligne4',loc_ligne4, false);
    pk_xml.add_data('AdresseAdherent', 'ent:Ligne5',loc_ligne5, false);
    pk_xml.add_data('AdresseAdherent', 'ent:CodePostal',loc_cp, false);
    pk_xml.add_data('AdresseAdherent', 'ent:Ville',loc_ville, false);
    pk_xml.add_data('AdresseAdherent', 'ent:CodeCommune','', false);--vide car non disponible
    pk_xml.add_data('Contrat', 'Telephone',loc_tel, false);
    pk_xml.add_data('Contrat', 'DateEffet',To_char(loc_dateEffet,'DDMMYYYY'), false);
    pk_xml.add_data('Contrat', 'DateResiliation',to_char(loc_dateRes,'DDMMYYYY'), false);
    pk_xml.add_data('Contrat', 'CodeAssureur',loc_t_org, false);

    --************* Bénéficiaires *************--
    pk_xml.add_element('/', 'Beneficiaires');

    -- ***************************************************************************
    -- * Boucle sur les bénéficiaires
    -- ***************************************************************************
                                                                                P_INS_journal(3,v_id_flux||' F_CRTL_DROIT ', 'DEBUT BENE');
    FOR C_lstBene IN  PK_CTRL_TP.Fetch_adhe_membre(loc_idadhesion) LOOP

      -- ***************************************************************************
      -- * Bénéficiaire : Contrôles
      -- ***************************************************************************

      --Contrôle des droits des bénéficaires
      loc_isCouvert := PK_CTRL_TP.F_CTRL_couverture(C_lstBene.numindiv,1,'C',sysdate);

      --Contrôle du rang du bénéficiaire
      loc_isTP := PK_CTRL_TP.F_CTRL_rang(C_lstBene.numindiv,loc_idadhesion,1,'C',sysdate);

      -- ***************************************************************************
      -- * Bénéficiaire : Formatage des données
      -- ***************************************************************************

      --transcodification civilité
      loc_t_civilite :=F_get_transco('GRP','CODC1', C_lstBene.qualite);

      --trancodification lien de parente
      loc_t_bene :=F_get_transco('GRP','TYAD', C_lstBene.typadr);

      -- Transcodification du regime / sous regime donnée utilisateur 6218
      IF F_VAL_VAR_ALL(C_lstBene.numindiv,loc_reg_spe) ='11' THEN loc_regime := 'A1';
      ELSE loc_regime := trim(to_char(C_lstBene.regime,'00'));
      END IF;
      IF loc_regime ='50' OR loc_regime IS NULL THEN
        loc_regime := '01';
      END IF;

      --Trancodification couverture du bénéficiaire
      IF loc_isCouvert and NOT loc_isTP THEN loc_couverture := '03' ;
      ELSIF loc_isCouvert and erreur_adhesion = 0 THEN loc_couverture := '01' ;
      ELSE loc_couverture:='02';
      END IF;

      -- ***************************************************************************
      -- * Bénéficiaire : Constitution du XML
      -- ***************************************************************************

      -- Contrôle données obligatoires
      IF C_lstBene.numindiv IS NULL OR loc_t_civilite IS NULL OR C_lstBene.nom IS NULL OR
         C_lstBene.prenom IS NULL OR C_lstBene.datnais IS NULL OR
         loc_regime IS NULL OR loc_t_bene IS NULL
      THEN                                                                      P_INS_journal(2,v_id_flux||' F_CRTL_DROIT DATA BENE','exc_erreur_inconnue');
         raise exc_erreur_inconnue;
      END IF;

      pk_xml.add_element('Beneficiaires', 'Beneficiaire');
      pk_xml.add_data('Beneficiaire', 'Identifiant',C_lstBene.numindiv, false);
      pk_xml.add_data('Beneficiaire', 'Civilite',loc_t_civilite, false);
      pk_xml.add_data('Beneficiaire', 'Nom',substr(C_lstBene.nom,1,32), false);
      pk_xml.add_data('Beneficiaire', 'Prenom',substr(C_lstBene.prenom,1,32), false);
      pk_xml.add_data('Beneficiaire', 'DateNaissance',to_char(C_lstBene.datnais,'DDMMYYYY'), false);
      pk_xml.add_data('Beneficiaire', 'RegimeSocial',loc_regime, false);
      pk_xml.add_data('Beneficiaire', 'LienAssure',loc_t_bene, false);
      pk_xml.add_data('Beneficiaire', 'SituationAdministrative',loc_couverture, false);

    END LOOP;
    -- ***************************************************************************
    -- * Fin boucle sur les bénéficiaires
    -- ***************************************************************************

  EXCEPTION
    WHEN exc_reference_inconnue THEN
         P_ENTETE_REP_ERREUR('01','Echec, n de contrat inconnu/ n interne inconnu');
    WHEN exc_contrat_invalide THEN
         P_ENTETE_REP_ERREUR('05','Pas de remboursement possible : le contrat n''est pas en cours');
    WHEN exc_contrat_resilie THEN
         P_ENTETE_REP_ERREUR('06','Pas de remboursement possible : le contrat est resilie');
    WHEN exc_adhe_invalide THEN
         P_ENTETE_REP_ERREUR('08','Pas de remboursement possible : l''adhesion n''est pas en cours');
    WHEN exc_adhe_non_tp THEN
         P_ENTETE_REP_ERREUR('15','Ce beneficiaire n''a pas droit au service');
    WHEN exc_erreur_inconnue THEN
         P_ENTETE_REP_ERREUR('99','Echec indetermine');
         erreur_99:=TRUE;
    WHEN OTHERS THEN
         P_ENTETE_REP_ERREUR('99','Echec indetermine');                         P_INS_journal(2,v_id_flux||' F_CRTL_DROIT ECHEC ', sqlerrm);
         erreur_99:=TRUE;
  END;

  -- ***************************************************************************
  -- * Génération/Validation du XML réponse
  -- ***************************************************************************
  v_xml := pk_xml.get_xml('Reponse','xmlns="pck/schemas/controleDroits" xmlns:ent="pck/schemas/defaut/message"', false);

  -- Historisation de la réponse du flux "Contrôle de droits" (type 3)
  pk_ws.add_xml(p_id_type => 3,
                p_id_flux => v_id_flux,
                p_doc_xml => v_xml,
                p_cod_err => v_cod_err);
                                                                                P_INS_journal(3,v_id_flux||' F_CRTL_DROIT ', '33');
  -- Validation du flux retour
  /*IF NOT pk_ws.is_flux_valid(v_xml, 3, v_id_flux) THEN                          P_INS_journal(3,v_id_flux||' F_CRTL_DROIT ', 'NON VALIDE');
     RETURN v_xml;
  END IF;*/

  -- MAJ statut du flux OK
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  IF erreur_99 THEN
    pk_ws.maj_statut(v_id_flux, 6,null,v_delai);
  ELSE
    pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  END IF;

  P_INS_journal(1,'F_CRTL_DROIT fin');

  -- Envoi du XML réponse
  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN                                                              P_INS_journal(2,v_id_flux||' F_CRTL_DROIT when others FIN', sqlerrm);
       -- Modification du statut : 6 En erreur inconnue
       v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
       pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);
       -- Envoi du XML réponse
       RETURN (v_xml);
END F_CRTL_DROIT;


/*ABO 01/07/2010 Demande de prise en charge*/
FUNCTION F_DEMANDE_PEC (
  P_xml IN XMLTYPE
)RETURN XMLTYPE IS

  v_xml xmltype;
  v_id_flux flux.id_flux%TYPE;
  V_etatCntrt NUMBER(2);
  loc_numAdhe VARCHAR2(16);
  loc_idadhesion  adhe_cntrt.idadhesion%TYPE;
  loc_numAdhePrinc  adhe_cntrt.numadhe%TYPE;
  loc_numgar  contrat_ref.numgar%TYPE;
  loc_isColl  Boolean;
  loc_libelle  produit.libelle%TYPE;
  loc_dateEffet  adhe_cntrt.date_adhe%TYPE;
  loc_dateRes  adhe_cntrt.date_fin_adhe%TYPE;
  loc_numorg contrat_ref.numorg%TYPE;
  erreur_adhesion NUMBER :=0;
  erreur_contrat NUMBER :=0;
  erreur_acte NUMBER:=0;
  erreur_calcul NUMBER:=0;
  erreur_99 BOOLEAN :=FALSE;
  msg_calcul VARCHAR2(200);
  loc_datsin DATE;
  loc_found   NUMBER :=0;
  loc_etatAdhe NUMBER :=0;
  loc_isCouvert boolean:=false;
  loc_isTP Boolean:=false;
  loc_acteCouvert boolean :=false;
  V_isAvanceRo boolean :=false;
  loc_numindivPS  individu.numindiv%TYPE;
  loc_typePS VARCHAR2(50);
  loc_domaine VARCHAR2(2);
  V_mtprest NUMBER(11,2):=0;--montant de prestation complémentaire d'un acte
  V_mtRO NUMBER(11,2):=0;
  V_mtFrais NUMBER(11,2):=0;
  v_rac NUMBER(11,2):=0;
  v_ordre VARCHAR2(3);
  v_codfrais VARCHAR2(6);
  v_codfrais_porte VARCHAR2(6);
  v_coeff number(3);
  loc_action porte_natfrais.action%TYPE;
  i NUMBER :=0;
  v_cod_err number:=0;

  v_acte_err_code VARCHAR2(2):='00';
  v_acte_err_lib VARCHAR2(300);
  v_deb NUMBER;
  v_delai NUMBER;

  C_lstGar            PK_CTRL_TP.Fetch_garanties_adhe%ROWTYPE;
  l_tabCond			  PK_PORTE.TAB_Cond;

BEGIN
  G_IDLIGNE := 0;

                                                                                P_INS_journal(1,'F_DEMANDE_PEC DEBUT', '');

  DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');

  -- ***************************************************************************
  -- * Validation XML Question / Création XML Réponse
  -- ***************************************************************************

  -- Initialisation des namespaces XML
  pk_xml.vg_xmlns := 'xmlns="pck/schemas/calculRac" xmlns:ent="pck/schemas/defaut/message';

  -- Initialisation XML réponse
  v_deb:=DBMS_UTILITY.GET_TIME;
  pk_xml.new_xml;

  -- Constitution de l'entete de la réponse
  P_ENTETE_REP(P_emet     => '00401554',
               P_emet_sup => '',
               P_dest     => PK_XML.EXTRACT_DATA(P_xml,'ent:Emetteur/ent:IdentificationCompagnie'),
               P_dest_sup => PK_XML.EXTRACT_DATA(P_xml,'ent:Emetteur/ent:IdentificationSupplement'),
               P_flux     => PK_XML.EXTRACT_DATA(P_xml,'ent:Flux/ent:Identifiant'),
               P_code     => '20');
  P_ENTETE_REP_ERREUR('00','');

  BEGIN

    -- Historisation du flux aller "Demande de prise en charge/ Calcul de reste à charge" (type 5)
    v_id_flux := pk_ws.insert_flux(p_id_type       => 5,
                                   p_id_flux_tiers => PK_XML.EXTRACT_DATA(P_xml,'ent:Flux/ent:Identifiant'),
                                   p_doc_xml       => p_xml,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => loc_grpporte );
    IF v_cod_err <> 0 THEN
       raise exc_erreur_inconnue;
    END IF;

    -- Validation du flux aller
    /*IF NOT pk_ws.is_flux_valid(p_xml, 5, v_id_flux) THEN                        P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC VALID', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    END IF;*/


    -- ***************************************************************************
    -- * Contrôles
    -- ***************************************************************************

    -- Identification de l'adhesion
    loc_numAdhe:=PK_XML.EXTRACT_DATA(P_xml,'Beneficiaire/Identifiant');
    -- Contrôle du contrat
    PK_CTRL_TP.P_FIND_CONTRAT(
      PK_XML.EXTRACT_DATA(P_xml,'Beneficiaire/NumContrat'),
      loc_numAdhe,
      loc_grpporte,
      loc_idadhesion,
      loc_numAdhePrinc,
      loc_numgar,
      loc_isColl,
      loc_libelle,
      loc_dateEffet,
      loc_dateRes,
      loc_numorg,
      loc_numporte,
      erreur_contrat);
    IF erreur_contrat = 1 THEN                                                  P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC err contrat', 'exc_reference_inconnue');
       RAISE exc_reference_inconnue;
    ELSIF erreur_contrat = 2 THEN                                               P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC err contrat', 'exc_adhe_non_tp');
       RAISE exc_adhe_non_tp;
    ELSIF erreur_contrat <> 0 THEN                                              P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC err contrat', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    END IF;

    -- Contrôle Etat du contrat
    V_etatCntrt := PK_CTRL_TP.F_CTRL_CNTRT(loc_numgar,sysdate);
    IF V_etatCntrt = 3 THEN                                                     P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC etat contrat', 'exc_contrat_resilie');
       RAISE exc_contrat_resilie;
    ELSIF V_etatCntrt <> 1 THEN                                                 P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC etat contrat', 'exc_contrat_invalide');
       RAISE exc_contrat_invalide;
    END IF;

    -- Contrôle de l'adhésion
    PK_CTRL_TP.P_CTRL_ADHESION (loc_idadhesion,
                                loc_numgar,
                                null,
                                false,
                                loc_etatAdhe,
                                erreur_adhesion);
    IF erreur_adhesion IN (7,8,9) THEN                                      P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC err adh', 'exc_adhe_invalide');
       RAISE exc_adhe_invalide;
    ELSIF erreur_adhesion <> 0 THEN                                             P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC err adh', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    END IF;

    -- Contrôle de couverture du bénéficaire
    loc_isCouvert := PK_CTRL_TP.F_CTRL_couverture(loc_numAdhe,1,'C',sysdate);--'O ou C...
    IF NOT loc_isCouvert THEN                                                   P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC couvert', 'exc_adhe_non_couvert');
       raise exc_adhe_non_couvert;
    END IF;

	loc_isTP := PK_CTRL_TP.F_CTRL_rang(loc_numAdhe,loc_idadhesion,1,'C',sysdate);--'O ou C...
    IF NOT loc_isTP THEN                                                        P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC isTP', 'exc_adhe_non_tp');
       RAISE exc_adhe_non_tp;
    END IF;

    --************* Recherche/Création du PS *************--
    loc_domaine :=PK_XML.EXTRACT_DATA(P_xml,'Domaine');-- lunettes/optique ou dentaire
    -- trancodification du type de tiers
    loc_typePS :=F_get_transco('GRP','TT',loc_domaine);

    PK_CTRL_TP.P_FIND_TIERS(
          PK_XML.EXTRACT_DATA(P_xml,'Adeli'),
          SUBSTR(UPPER(PK_XML.EXTRACT_DATA(P_xml,'RaisonSociale')),0,30),
          loc_typePS,
          TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne1')),
          TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne2')),
          TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne3')),
          TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne4')),
          TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne5')),
          PK_XML.EXTRACT_DATA(P_xml,'ent:CodePostal'),
          PK_XML.EXTRACT_DATA(P_xml,'ent:Ville'),
          PK_XML.EXTRACT_DATA(P_xml,'Telephone'),
          null,
          loc_numindivPS);
    -- Erreur loc_numindivPS null car insertion impossible en base de donnée
    IF loc_numindivPS IS NULL THEN                                              P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC PS', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    ELSIF loc_numindivPS =-1 THEN
      RAISE exc_erreur_doublon_PS;
    END IF;

    -- ***************************************************************************
    -- * Boucle sur les actes
    -- ***************************************************************************
    LOOP
      i := i +1;
      EXIT WHEN PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:NumOrdre',i) IS NULL;

      -- Initialisation des variables
      erreur_acte :=0;
      v_acte_err_code := '00';
      v_acte_err_lib := NULL;
      v_codfrais := NULL;

      v_codfrais_porte :=PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:NaturePrestation',i);
      loc_datsin := sysdate;

      OPEN PK_CTRL_TP.Fetch_garanties_adhe(loc_idadhesion, loc_numAdhe) ;
      FETCH PK_CTRL_TP.Fetch_garanties_adhe INTO C_lstGar;

      IF PK_CTRL_TP.Fetch_garanties_adhe%NOTFOUND THEN
        CLOSE  PK_CTRL_TP.Fetch_garanties_adhe;
      END IF;

      -- Transcodification de l'acte + Contrôle acte autorisé dans seveane uniquement sur la 1ère garantie de base
      v_codfrais := PK_CTRL_TP.F_TRANSCO_CODFRAIS_GAR(
                          P_codfrais_porte => v_codfrais_porte,
                          P_regime         => 1,
                          P_spec           => '00',
                          P_porte          => loc_numporte,
                          P_numfor         => C_lstGar.numfor,
                          P_datsin         => loc_datsin,
                          P_action         => loc_action);

      CLOSE PK_CTRL_TP.Fetch_garanties_adhe;
      --dbms_output.put_line ('codfrais'||v_codfrais);
      IF v_codfrais IS NULL THEN                                                P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC 03', 'Acte'||to_char(i));
         v_acte_err_code := '03';
         v_acte_err_lib := 'Pas de calcul possible : code acte non gere';
      ELSE
	    -- Contrôle de la carte TP du bénéficaire
       -- P_INS_journal(2,v_id_flux||' Acte:'||v_codfrais||' Adhésion:'||loc_idadhesion, 'Assuré:'||loc_numAdhe);
	   IF pk_porte.F_carte_tp(loc_numAdhe, v_codfrais, sysdate, loc_idadhesion, NULL,  NULL, l_tabCond ) =0 THEN
          loc_action:=2;
       END IF;

	   IF loc_action = 2 THEN
          v_acte_err_code := '03';
          v_acte_err_lib := 'Pas de remboursement possible : droit TP ferme pour cette prestation';
		END IF;
      END IF;

      -- ***************************************************************************
      -- * Actes : Contrôles
      -- ***************************************************************************


      -- en optique la date de prescription est obligatoire
      IF  loc_domaine !='03' AND PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:DatePresciption',i) = '' THEN
         v_acte_err_code := '27';
         v_acte_err_lib := 'Pas de remboursement possible : le patient ne beneficie pas du "remboursement sans ordonnance"';
      END IF;

      IF v_acte_err_code = '00' THEN

          -- Contrôle de couverture
          PK_CTRL_TP.P_CTRL_CVRT_ACTE(
                  v_codfrais,
                  loc_numAdhe,
                  loc_datsin,
                  loc_idadhesion,
                  loc_acteCouvert,
                  erreur_acte);
          IF erreur_acte = 1 THEN                                               P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC acte 03', v_codfrais);
             -- Code acte inconnu
             v_acte_err_code := '03';
             v_acte_err_lib := 'Pas de calcul possible : code acte non gere';
          ELSIF erreur_acte = 5 THEN                                            P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC acte 02', '');
             -- Date sinistre incohérente
             v_acte_err_code := '02';
             v_acte_err_lib := 'Pas de calcul possible, une des donnees est incorrecte';
          ELSIF erreur_acte <> 0 THEN                                           P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC 04', '');
             -- Acte non garanti
             v_acte_err_code := '04';
             v_acte_err_lib := 'Pas de remboursement possible : l''assure n''est pas garanti sous cette prestation';
          END IF;

      END IF;
     -- dbms_output.put_line ('erreur_acte'||erreur_acte);

      -- ***************************************************************************
      -- * Actes: Calculs
      -- ***************************************************************************

      -- Affectation des variables avant lancement calcul de prestation
      V_mtprest:=0;
      v_rac:=0;
      v_ordre := PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:NumOrdre',i);

      V_mtfrais :=PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:MtDepense',i);
      V_mtRO := PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:MtRo',i);

      V_isAvanceRo := NVL(PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:Dentaire/ent:AvanceRo',i)='N',FALSE);
      IF PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:Dentaire/ent:AvanceRo',i)='N' THEN -- l'assuré n'a pas avancé la part RO
         v_mtfrais := v_mtfrais + V_mtRO; --à voir est-ce qu'il faut dans xml retour de nouveau enlevé la part Ro...
      END IF;

      --coefficient uniquement en dentaire
      v_coeff :=1;
      IF PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:Dentaire/ent:CoefficientSs',i) IS NOT NULL THEN -- l'assuré n'a pas avancé la part RO
         v_coeff := PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:Dentaire/ent:CoefficientSs',i); --à voir est-ce qu'il faut dans xml retour de nouveau enlevé la part Ro...
      END IF;
      --si le coefficient dentaire = 0 alors le coeff = 1
      IF v_coeff=0 THEN
         v_coeff:=1;
      END IF;
      IF loc_acteCouvert AND v_acte_err_code = '00' THEN

         -- Calcul de remboursement de la prestation
         PK_CALCUL_DOSSIER.P_CALCUL_RAC(P_codfrais    => v_codfrais,
                                        P_datsin      => TO_CHAR(loc_datsin,'DD/MM/YYYY'),
                                        P_taux        => PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:TauxRembtRo',i),
                                        P_mtremb      => v_mtRO,
                                        P_mtfrais     => v_mtfrais,
                                        P_devise      => PK_CTRL_TP.F_FIND_DEVISE,
                                        P_quantite    => 1,
                                        P_coeff       => v_coeff,
                                        P_numindiv    => loc_numAdhe,
                                        P_numbene     => loc_numindivPS,
                                        P_type_bene   => 1,
                                        P_ordre       => i,
                                        P_type        =>'devis', --insertion dans travsn avec sens=-1
                                        O_mtprest     => V_mtprest,
                                        O_erreur      => erreur_calcul,
                                        O_msg_erreur  => msg_calcul);
                                                                                P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC ', 'erreur_calcul'||erreur_calcul);
         CASE erreur_calcul
          WHEN 0 THEN NULL;
          WHEN 6 THEN
            IF v_mtprest = 0 THEN
              v_acte_err_code := '09';
              v_acte_err_lib := 'Pas de reboursement possible : cette prestation est soumise a un delai de carence';
            ELSE
              v_acte_err_code := '10';
              v_acte_err_lib := 'Attention, il s''agit d''un remboursement partiel, une partie de la garantie pour cette prestation est soumise a un delai de carence';
            END IF;
          WHEN 7 THEN
            IF v_mtprest = 0 THEN
              v_acte_err_code := '11';
              v_acte_err_lib := 'Pas de reboursement possible : le plafond de remboursement pour cette prestation a ete atteint lors d''un precedent remboursement';
            ELSE
              v_acte_err_code := '12';
              v_acte_err_lib := 'Attention, il s''agit d''un remboursement partiel : le plafond de remboursement est atteint';
            END IF;
          WHEN 8 THEN
            v_acte_err_code := '29';
            v_acte_err_lib := 'Remboursement effectue en fonction de la franchise sur une garantie';
          ELSE
            v_mtprest:=0;
            v_acte_err_code := '30';
            v_acte_err_lib := 'Une des donnees est incorrecte ou calcul impossible';
         END CASE;
      END IF;

      V_rac := v_mtfrais -(v_mtRO +v_mtprest);
      IF V_isAvanceRo THEN
        v_mtfrais := v_mtfrais - v_mtRO;
        v_mtRO := 0;
      END IF;

      -- ***************************************************************************
      -- * Actes: Constitution du XML
      -- ***************************************************************************

      IF v_ordre IS NULL OR v_codfrais_porte IS NULL OR v_mtfrais IS NULL OR
         v_mtro IS NULL OR v_mtprest IS NULL OR v_rac IS NULL
      THEN                                                                      P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC DATA', 'Acte'||to_char(i));
         P_ENTETE_REP_ERREUR('99','Echec indetermine');
         erreur_99 :=TRUE;
      ELSE
         pk_xml.add_element('/', 'Acte');
         pk_xml.add_data('Acte', 'NumOrdre',v_ordre, false);
         pk_xml.add_data('Acte', 'NaturePrestation',v_codfrais_porte, false);
         pk_xml.add_data('Acte', 'CodeRetour',v_acte_err_code, false);
         pk_xml.add_data('Acte', 'LibelleRetour',SUBSTR(v_acte_err_lib,1,255), false);
         pk_xml.add_data('Acte', 'MtDepense',to_char(v_mtfrais,'FM99990.00'), false);
         pk_xml.add_data('Acte', 'MtRo',to_char(v_mtro,'FM99990.00'), false);
         pk_xml.add_data('Acte', 'MtRc',to_char(v_mtprest,'FM99990.00'), false);
         pk_xml.add_data('Acte', 'MtRac',to_char(v_rac,'FM99990.00'), false);
      END IF;
    END LOOP;

    --dbms_output.put_line ('Fin acte');
  EXCEPTION
    WHEN exc_reference_inconnue THEN
         P_ENTETE_REP_ERREUR('01','Echec, n° de contrat inconnu/ n° interne inconnu');
    WHEN exc_contrat_invalide THEN
         P_ENTETE_REP_ERREUR('05','Pas de remboursement possible : le contrat n''est pas en cours');
    WHEN exc_contrat_resilie THEN
         P_ENTETE_REP_ERREUR('06','Pas de remboursement possible : le contrat est resilie');
    WHEN exc_adhe_non_couvert THEN
         P_ENTETE_REP_ERREUR('07','Pas de remboursement possible : Le patient n''est plus couvert par le contrat');
     WHEN exc_adhe_invalide THEN
         P_ENTETE_REP_ERREUR('08','Pas de remboursement possible : l''adhesion n''est pas en cours');
    WHEN exc_adhe_non_tp THEN
         P_ENTETE_REP_ERREUR('15','Ce beneficiaire n''a pas droit au service');
    WHEN exc_erreur_doublon_PS THEN
         P_ENTETE_REP_ERREUR('97','Doublon de PS en base');
    WHEN exc_erreur_inconnue THEN
         P_ENTETE_REP_ERREUR('99','Echec indetermine');
         erreur_99 :=TRUE;
    WHEN OTHERS THEN                                                            P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC ECHEC', SQLERRM);
         P_ENTETE_REP_ERREUR('99','Echec indetermine');
         erreur_99 :=TRUE;
  END;

  -- Suppression des données enregistrées dans travsn (données conservées pour le calcul de plafond/franchise/carence)
  PK_CALCUL_DOSSIER.P_Delete_travsn;

  -- ***************************************************************************
  -- * Génération/Validation du XML réponse
  -- ***************************************************************************

   v_xml := pk_xml.get_xml('Reponse','xmlns="pck/schemas/calculRac" xmlns:ent="pck/schemas/defaut/message"', false);

  -- Historisation de la réponse du flux "Demande de prise en charge/ Calcul de reste à charge" (type 6)
  pk_ws.add_xml(p_id_type => 6,
                p_id_flux => v_id_flux,
                p_doc_xml => v_xml,
                p_cod_err => v_cod_err);

  -- Validation du flux retour
  /*IF NOT pk_ws.is_flux_valid(v_xml, 6, v_id_flux) THEN                          P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC ', 'VALID RETOUR');
     RETURN v_xml;
  END IF;*/

  -- MAJ statut du flux OK
  IF erreur_99 THEN
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
    pk_ws.maj_statut(v_id_flux, 6,null,v_delai);
  ELSE
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
    pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  END IF;


                                                                                P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC FIN', '');
  -- Envoi du XML réponse
  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN
       -- Modification du statut : 6 En erreur inconnue
       v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
       pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);                                 P_INS_journal(2,v_id_flux||' F_DEMANDE_PEC others', sqlerrm);
       -- Envoi du XML réponse
       RETURN (v_xml);
END F_DEMANDE_PEC;


FUNCTION F_CONFIRM_PEC(
  P_xml IN XMLTYPE
)RETURN XMLTYPE IS
  v_xml xmltype;
  V_etatCntrt NUMBER(2);
  loc_numAdhe VARCHAR2(16);
  loc_idadhesion  adhe_cntrt.idadhesion%TYPE;
  loc_numAdhePrinc  adhe_cntrt.numadhe%TYPE;
  loc_numgar  contrat_ref.numgar%TYPE;
  loc_isColl  Boolean;
  loc_coll VARCHAR2(2);
  loc_libelle  produit.libelle%TYPE;
  loc_dateEffet  adhe_cntrt.date_adhe%TYPE;
  loc_dateRes  adhe_cntrt.date_fin_adhe%TYPE;
  loc_numorg contrat_ref.numorg%TYPE;
  loc_etatAdhe NUMBER :=0;
  erreur_adhesion NUMBER :=0;
  erreur_contrat NUMBER :=0;
  erreur_acte NUMBER:=0;
  erreur_dossier NUmber :=0;
  erreur_99 BOOLEAN :=FALSE;
  msg_dossier VARCHAR2(200);
  loc_found   NUMBER :=0;
  loc_datsin DATE;
  loc_isCouvert boolean:=false;
  loc_isTP Boolean:=false;

  loc_acteCouvert boolean :=false;
  loc_numindivPS  individu.numindiv%TYPE;
  loc_typePS VARCHAR2(50);
  loc_domaine VARCHAR2(2);
  loc_idrib rib.idrib%TYPE;
  V_mtprest NUMBER(11,2):=0;--montant de prestation complémentaire d'un acte
  V_mtRO  NUMBER(11,2):=0;
  V_mtFrais NUMBER(11,2):=0;
  v_rac  NUMBER(11,2):=0;
  v_tot_prest_calc NUMBER(15,2):=0;
  v_ordre VARCHAR2(3);
  v_codfrais VARCHAR2(6);
  v_codfrais_porte VARCHAR2(6);
  v_coeff NUMBER(3);
  i NUMBER :=0;
  loc_num_dossier dossier_sante.num_dossier%TYPE;
  loc_numdossierPorte dossier_sante.num_dossier_porte%TYPE;
  loc_action porte_natfrais.action%TYPE;
  v_id_flux flux.id_flux%TYPE;
  v_cod_err number:=0;
  loc_refDomaine transco.val_ext%TYPE;

  erreur_bloquante EXCEPTION;
  v_deb NUMBER;
	v_delai NUMBER;

  C_lstGar            PK_CTRL_TP.Fetch_garanties_adhe%ROWTYPE;
  l_tabCond			  PK_PORTE.TAB_Cond;

  P_TRAV_SAISIE                  TRAV_SAISIE%ROWTYPE;     -- necessaire à l'enregistrement du réseau de soins
  l_sid                          NUMBER(8);

BEGIN
  G_IDLIGNE := 0;

  P_INS_journal(1,'F_CONFIRM_PEC début', '');

  DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');

  -- ***************************************************************************
  -- * Validation XML Question / Création XML Réponse
  -- ***************************************************************************

  -- Initialisation des namespaces XML
  pk_xml.vg_xmlns := 'xmlns="pck/schemas/creationPEC" xmlns:ent="pck/schemas/defaut/message';

  -- Initialisation XML réponse
  v_deb:=DBMS_UTILITY.GET_TIME;
  pk_xml.new_xml;

  -- Constitution de l'entete de la réponse
  P_ENTETE_REP(P_emet     => '00401554',
               P_emet_sup => '',
               P_dest     => PK_XML.EXTRACT_DATA(P_xml,'ent:Emetteur/ent:IdentificationCompagnie'),
               P_dest_sup => PK_XML.EXTRACT_DATA(P_xml,'ent:Emetteur/ent:IdentificationSupplement'),
               P_flux     => PK_XML.EXTRACT_DATA(P_xml,'ent:Flux/ent:Identifiant'),
               P_code     => '30');
  P_ENTETE_REP_ERREUR('00','');

  BEGIN
    -- Historisation du flux aller "Confirmation de la prise en charge" (type 8)
    v_id_flux := pk_ws.insert_flux(p_id_type       => 8,
                                   p_id_flux_tiers => PK_XML.EXTRACT_DATA(P_xml,'ent:Flux/ent:Identifiant'),
                                   p_doc_xml       => p_xml,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => loc_grpporte );
    IF v_cod_err <> 0 THEN                                                      P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC erreur'||v_cod_err, 'exc_erreur_inconnue');
       raise exc_erreur_inconnue;
    END IF;

    -- Validation du flux aller
   /* IF NOT pk_ws.is_flux_valid(p_xml, 8, v_id_flux) THEN                        P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    END IF;*/

    -- ***************************************************************************
    -- * Contrôles
    -- ***************************************************************************

    -- Identification de l'adhesion
    loc_numAdhe:=PK_XML.EXTRACT_DATA(P_xml,'Beneficiaire/Identifiant');
    PK_CTRL_TP.P_FIND_CONTRAT(
            PK_XML.EXTRACT_DATA(P_xml,'Beneficiaire/NumContrat'),
            loc_numAdhe,
            loc_grpporte,
            loc_idadhesion,
            loc_numAdhePrinc,
            loc_numgar,
            loc_isColl,
            loc_libelle,
            loc_dateEffet,
            loc_dateRes,
            loc_numorg,
            loc_numporte,
            erreur_contrat);
    IF erreur_contrat = 1 THEN                                                  P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC err contrat', 'exc_reference_inconnue');
       RAISE exc_reference_inconnue;
    ELSIF erreur_contrat = 2 THEN                                               P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC err contrat', 'exc_adhe_non_tp');
       RAISE exc_adhe_non_tp;
    ELSIF erreur_contrat <> 0 THEN                                              P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC err contrat', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    END IF;

    -- Contrôle Etat du contrat
    V_etatCntrt := PK_CTRL_TP.F_CTRL_CNTRT(loc_numgar,sysdate);
    IF V_etatCntrt = 3 THEN                                                     P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC etat contrat', 'exc_contrat_resilie');
       RAISE exc_contrat_resilie;
    ELSIF V_etatCntrt <> 1 THEN                                                 P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC etat contrat', 'exc_contrat_invalide');
       RAISE exc_contrat_invalide;
    END IF;

    -- Contrôle de l'adhésion
    PK_CTRL_TP.P_CTRL_ADHESION (loc_idadhesion,
                                loc_numgar,
                                loc_domaine,
                                false,
                                loc_etatAdhe,
                                erreur_adhesion);
    IF erreur_adhesion IN (7,8,9) THEN                                      P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC err adh', 'exc_adhe_invalide');
       RAISE exc_adhe_invalide;
    ELSIF erreur_adhesion <> 0 THEN                                             P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC arr adh', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    END IF;

    -- Contrôle de droit du bénéficaire
    loc_isCouvert := PK_CTRL_TP.F_CTRL_couverture(loc_numAdhe,1,'C',sysdate);--'O ou C...
    IF NOT loc_isCouvert THEN                                                   P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC couverture', 'exc_adhe_non_couvert');
       raise exc_adhe_non_couvert;
    END IF;

   -- Contrôle de droit TP du bénéficaire
   loc_isTP := PK_CTRL_TP.F_CTRL_rang(loc_numAdhe,loc_idadhesion,1,'C',sysdate);--'O ou C...
   IF NOT loc_isTP THEN                                                        P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC isTP', 'exc_adhe_non_tp');
      RAISE exc_adhe_non_tp;
   END IF;

   loc_domaine :=PK_XML.EXTRACT_DATA(P_xml,'Domaine');-- lunettes/optique ou dentaire
   -- trancodification du type de tiers
   loc_typePS :=F_get_transco('GRP','TT',loc_domaine);

   -- Recherche/Creéation du PS
   PK_CTRL_TP.P_FIND_TIERS(
        PK_XML.EXTRACT_DATA(P_xml,'Adeli'),
        SUBSTR(UPPER(PK_XML.EXTRACT_DATA(P_xml,'RaisonSociale')),30),
        loc_typePS,
        UPPER(TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne1'))),
        UPPER(TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne2'))),
        UPPER(TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne3'))),
        UPPER(TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne4'))),
        UPPER(TRIM(PK_XML.EXTRACT_DATA(P_xml,'ent:Ligne5'))),
        PK_XML.EXTRACT_DATA(P_xml,'ent:CodePostal'),
        UPPER(PK_XML.EXTRACT_DATA(P_xml,'ent:Ville')),
        PK_XML.EXTRACT_DATA(P_xml,'Telephone'),
        null,
        loc_numindivPS);

    -- Erreur loc_numindivPS null car insertion impossible en base de données
    IF loc_numindivPS IS NULL THEN                                              P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC PS', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    ELSIF loc_numindivPS =-1 THEN
      RAISE exc_erreur_doublon_PS;
    END IF;

    -- Recherche/Création du rib du PS
    -- le rib ou l'iban est renseigné dans le flux
    PK_CTRL_TP.P_FIND_RIB_PS(
          loc_numindivPS,
          PK_XML.EXTRACT_DATA(P_xml,'Intitule'), --soit du rib soit de l'iban...
          PK_XML.EXTRACT_DATA(P_xml,'RIB/NumBanque'),
          PK_XML.EXTRACT_DATA(P_xml,'RIB/NumGuichet'),
          PK_XML.EXTRACT_DATA(P_xml,'RIB/NumCompte'),
          lpad(PK_XML.EXTRACT_DATA(P_xml,'RIB/Cle'),2,'0'),
          PK_XML.EXTRACT_DATA(P_xml,'IBAN/NumCompte'),
          PK_XML.EXTRACT_DATA(P_xml,'IBAN/IbanCodePays')||PK_XML.EXTRACT_DATA(P_xml,'IBAN/CleControle'),
          PK_XML.EXTRACT_DATA(P_xml,'IBAN/Bic'),
          loc_idrib);

    -- Erreur loc_idrib null car insertion impossible en base de donnée
    IF loc_idrib IS NULL THEN                                                   P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC rib ', SQLERRM);
       RAISE exc_erreur_inconnue;
    END IF;

    -- Validation de la création du PS et du RIB associé
    COMMIT;
                                                                                P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC', 'PS ET RIB OK');
    -- Création du dossier_sante
    -- trancodification du domaine optique ou dentaire pour la nature du dossier
    loc_refDomaine :=F_get_transco('GRP','NAT_DOSS',loc_domaine);
    loc_numdossierPorte := PK_XML.EXTRACT_DATA(P_xml,'Dossier/NumDossierAssureur');
    PK_CTRL_TP.P_INS_DOSSIER_SANTE(
            P_ref         => PK_XML.EXTRACT_DATA(P_xml,'Dossier/NumAccordTP'),
            P_numindiv    => loc_numAdhe,
            P_PS          => loc_numindivPS,
            P_numassu     => f_numassu(loc_numAdhe,loc_idadhesion),
            P_numporte    => loc_numporte,
            P_natdoss     => loc_refDomaine,
            P_typedoss    => 4,
            P_num_dossier_porte => loc_numdossierPorte,
            O_num_dossier => loc_num_dossier);                                  P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC', 'Dossier n°:'||loc_num_dossier);
    IF loc_num_dossier = 0 THEN
      RAISE exc_erreur_inconnue; --le numéro de dossier externe existe déjà dans le système
    END IF;
    -- mise à jour de la reférence externe de l'individu
    loc_refDomaine :=F_get_transco('GRP','DOM',loc_domaine);
    PK_CTRL_TP.P_MAJ_REF_EXTERNE(
        P_numindiv    => loc_numAdhe,
        P_domaine     => loc_refDomaine,
        P_tiers       => 'GRP',
        P_mnemo       => 'DOM');

    -- Historisation du dossier
    PK_CTRL_TP.P_INS_HISTO_DOSSIER(
            P_num_dossier => loc_num_dossier,
            P_etat        => 0,
            P_motif       => 0);
    -- Validation de la création du dossier santé
    --COMMIT; -- Validation avant la prise en compte des actes ? TO DO

                                                                                P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC', 'DOSSIER OK');
    -- ***************************************************************************
    -- * Boucle sur les actes
    -- ***************************************************************************

    --dbms_output.put_line ('avant acte');
    LOOP
      i := i +1;
      erreur_acte := 0;
      loc_acteCouvert:=FALSE;
      v_codfrais :=NULL;

      EXIT WHEN PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:NumOrdre',i) IS NULL;
                                                                                P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC', 'DEBUT ACTE');

      v_codfrais_porte :=PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:NaturePrestation',i);

      -- Transcodification de l'acte + Contrôle acte autorisé dans seveane
      --dbms_output.put_line ('codfrais porte :'||v_codfrais_porte);
      loc_datsin := sysdate;

      OPEN PK_CTRL_TP.Fetch_garanties_adhe(loc_idadhesion, loc_numAdhe) ;
      FETCH PK_CTRL_TP.Fetch_garanties_adhe INTO C_lstGar;

      IF PK_CTRL_TP.Fetch_garanties_adhe%NOTFOUND THEN
        CLOSE  PK_CTRL_TP.Fetch_garanties_adhe;
      END IF;

      -- Transcodification de l'acte + Contrôle acte autorisé dans seveane uniquement sur la 1ère garantie de base
      v_codfrais := PK_CTRL_TP.F_TRANSCO_CODFRAIS_GAR(
                          P_codfrais_porte => v_codfrais_porte,
                          P_regime         => 1,
                          P_spec           => '00',
                          P_porte          => loc_numporte,
                          P_numfor         => C_lstGar.numfor,
                          P_datsin         => loc_datsin,
                          P_action         => loc_action);

      CLOSE PK_CTRL_TP.Fetch_garanties_adhe;

      -- ***************************************************************************
      -- * Actes : Contrôles
      -- ***************************************************************************
      IF v_codfrais IS NOT NULL THEN
	    -- Contrôle de la carte TP du bénéficaire
        IF pk_porte.F_carte_tp(loc_numAdhe, v_codfrais, sysdate, 0, NULL,  NULL, l_tabCond ) = 0 THEN
          loc_action:=2;
        END IF;
	    IF loc_action = 2 THEN
          erreur_acte := 3;--'Pas de remboursement possible : droit TP ferme pour cette prestation'
		END IF;
      END IF;

	  --la date de prestation est toujours la date du jour, la date passée dans le flux est celle de la prescription
      IF PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:Domaine',i)!='03' AND PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:DatePresciption',i) = '' THEN
         erreur_acte:=6;
      END IF;

      IF v_codfrais IS NOT NULL AND erreur_acte=0 THEN
          -- Contrôle de couverture
          PK_CTRL_TP.P_CTRL_CVRT_ACTE(
              v_codfrais,
              loc_numAdhe,
              loc_datsin,
              loc_idadhesion,
              loc_acteCouvert,
              erreur_acte);

          -- est-il vraiment nécessaire de vérifier la couverture de l'acte dans la mesure où
          -- si celui-ci n'est pas couvert, son montant mtprest = 0
          -- vérifier qu'il ne passe pas au travers et surtout dans le cas où il n'est pas TP TO DO ???
      END IF;
      --dbms_output.put_line ('erreur_acte'||erreur_acte||v_acte_err_lib);

      -- ***************************************************************************
      -- * Actes: Calculs
      -- ***************************************************************************
      -- Affectation des variables avant lancement calcul de prestation

      V_mtfrais :=PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:MtDepense',i);
      V_mtRO := PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:MtRo',i);

      IF PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:Dentaire/ent:AvanceRo',i)='N' THEN -- l'assuré n'a pas avancé la part RO
         v_mtfrais := v_mtfrais + V_mtRO; --à voir est-ce qu'il faut dans xml retour de nouveau enlever la part Ro...
      END IF;
      --coefficient uniquement en dentaire
      v_coeff :=1;
      IF PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:Dentaire/ent:CoefficientSs',i) IS NOT NULL THEN -- l'assuré n'a pas avancé la part RO
         v_coeff := PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:Dentaire/ent:CoefficientSs',i); --à voir est-ce qu'il faut dans xml retour de nouveau enlevé la part Ro...
      END IF;
       --si le coefficient dentaire = 0 alors le coeff = 1
      IF v_coeff=0 THEN
         v_coeff:=1;
      END IF;

      IF loc_acteCouvert AND erreur_acte=0  THEN
         --dbms_output.put_line ('sinistre_sante');
         -- Insertion dans sinistre_sante de chaque acte/prestation et historisation

         PK_CTRL_TP.P_INS_SNTR_SANTE(
                    P_num_dossier => loc_num_dossier,
                    P_numligne    => i,
                    P_numindiv    => loc_numAdhe,
                    P_codfrais    => v_codfrais ,
                    P_mtfrais     => V_mtfrais,
                    P_etat        => 1, --à calculer
                    P_taux        => PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:TauxRembtRo',i),
                    P_baseremb    => PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:BaseRembtRo',i),
                    P_mtremb      => V_mtRO,
                    P_datsin      => loc_datsin,
                    P_coeff       => v_coeff);

         PK_CTRL_TP.P_INS_HISTO_SNTR_SANTE(
                    P_num_dossier => loc_num_dossier,
                    P_numligne    => i,
                    P_etat        => 1,
                    P_motif       => 0);

          -- on vérifie que le montant confirmé par rapport au montant calculé
          IF PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:mtRc',i) IS NOT NULL THEN
            v_tot_prest_calc := v_tot_prest_calc + PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:mtRc',i);
          END IF;
      END IF;
    END LOOP;

    -- ************* calcul de toutes les prestations du dossier ************* --
    -- calcul prestation par prestation
    -- mise à jour du montant de prestation et de l'état de sinistre_sante
    -- historisation de sinistre_sante
    -- insertion dans sinistre avec sens =-1

    -- insertion du réseau de soins si celui-ci est existant sur la porte ainsi que les dents si c est une PEC dentaire
    -- Cette insertion est un pansement pour palier le fait que la dll ne récupère pas la bonne session entre PK_ITELIS et gs19_xit (2 connexions Arthus, donc 2 sid différents)
    SELECT TO_CHAR(SYS_CONTEXT('USERENV', 'SID')) INTO l_sid FROM DUAL;
    LOOP
      i := i +1;
      EXIT WHEN PK_XML.EXTRACT_DATA(P_xml,'Acte/ent:NumOrdre',i) IS NULL;

      P_TRAV_SAISIE.SID:= l_sid;
      P_TRAV_SAISIE.NUMLIG:= i;
      P_TRAV_SAISIE.USERNAME:= f_numutil;
      P_TRAV_SAISIE.NUMSIN:=  NULL;
      P_TRAV_SAISIE.RESEAU:=NVL(F_SENS_LIBELLE('PORTE',loc_numporte),loc_numporte);  -- réseau de soins

      P_INSERT_TRAV_SAISIE(  P_TRAV_SAISIE );
    END LOOP;

    PK_CALCUL_DOSSIER.P_CALCUL_DOSSIER_SANTE(
            P_num_dossier => loc_num_dossier,
            P_type        => 'devis',
            P_tot_prest   => v_tot_prest_calc,
            O_erreur      => erreur_dossier,
            O_msg_erreur  => msg_dossier);
    --IF erreur_dossier = 5 OR erreur_dossier = 1 THEN
    --   RAISE erreur_bloquante;
    -- TO DO à revoir gestion cas 5 et 1 ???
    IF erreur_dossier = 9   THEN                                                P_INS_journal(2,v_id_flux||'F_CONFIRM_PEC erreur dossier', msg_dossier);
       -- on enregistre pas le dossier si aucune prestation dedans
       RAISE exc_prestation_null;
    ELSIF erreur_dossier =11 THEN
      -- on enregistre pas le dossier car les montants calcules du devis sont different de la confirmation
       RAISE exc_rc_different;
    ELSE
      IF  erreur_dossier = 10   THEN --le montant total RC = 0
         -- Historisation du dossier
        PK_CTRL_TP.P_INS_HISTO_DOSSIER(
                P_num_dossier => loc_num_dossier,
                P_etat        => 0,
                P_motif       => 5);
      END IF;
      COMMIT;
    END IF;




    -- ***************************************************************************
    -- * Constitution du XML
    -- ***************************************************************************

    pk_xml.add_element('/', 'Dossier');
    pk_xml.add_data('Dossier', 'NumDossierAssureur',loc_numdossierPorte, false);
    pk_xml.add_data('Dossier', 'NumDossierDelegataire',loc_num_dossier, false);

  EXCEPTION
    WHEN exc_reference_inconnue THEN
         P_ENTETE_REP_ERREUR('01','Echec, n de contrat inconnu/ n interne inconnu');
    WHEN exc_contrat_invalide THEN
         P_ENTETE_REP_ERREUR('05','Pas de remboursement possible : le contrat n''est pas en cours');
    WHEN exc_contrat_resilie THEN
         P_ENTETE_REP_ERREUR('06','Pas de remboursement possible : le contrat est resilie');
    WHEN exc_adhe_non_couvert THEN
         P_ENTETE_REP_ERREUR('07','Pas de remboursement possible : Le patient n''est plus couvert par le contrat');
     WHEN exc_adhe_invalide THEN
         P_ENTETE_REP_ERREUR('08','Pas de remboursement possible : l''adhesion n''est pas en cours');
    WHEN exc_adhe_non_tp THEN
         P_ENTETE_REP_ERREUR('15','Ce beneficiaire n''a pas droit au service');
    WHEN exc_erreur_doublon_PS THEN
         P_ENTETE_REP_ERREUR('97','Enregistrement impossible : doublon de PS en base');
    WHEN exc_prestation_null THEN
         P_ENTETE_REP_ERREUR('96','Enregistrement impossible : aucune prestation couverte');
    WHEN exc_rc_different THEN
         P_ENTETE_REP_ERREUR('98','Enregistrement impossible : les montants calcules ne sont plus valides.');
    WHEN exc_erreur_inconnue THEN
         P_ENTETE_REP_ERREUR('99','Echec indetermine, erreur inconnue');
         erreur_99 :=TRUE;
    WHEN OTHERS THEN
         P_ENTETE_REP_ERREUR('99','Echec indetermine');
         erreur_99 :=TRUE;
         P_INS_journal(2,v_id_flux||' F_CONFIRM_PEC', 'ECHEC :'||SQLERRM);


  END;

  ROLLBACK;

  -- ***************************************************************************
  -- * Génération/Validation du XML réponse
  -- ***************************************************************************

   v_xml := pk_xml.get_xml('Reponse','xmlns="pck/schemas/creationPEC" xmlns:ent="pck/schemas/defaut/message"', false);

  -- Historisation de la réponse du flux "Demande de prise en charge/ Calcul de reste à charge" (type 9)
  pk_ws.add_xml(p_id_type => 9,
                p_id_flux => v_id_flux,
                p_doc_xml => v_xml,
                p_cod_err => v_cod_err);

  -- Validation du flux retour
 /*IF NOT pk_ws.is_flux_valid(v_xml, 9, v_id_flux) THEN                          P_INS_journal(2,v_id_flux||'F_CONFIRM_PEC exc 17', '');
     RETURN v_xml;
  END IF;*/

  -- MAJ statut du flux OK
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  IF erreur_99 THEN
    pk_ws.maj_statut(v_id_flux, 6,null,v_delai);
  ELSE
    pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  END IF;

  P_INS_journal(1,v_id_flux||'F_CONFIRM_PEC fin', '');

  -- Envoi du XML réponse
  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN                                                              P_INS_journal(2,'F_CONFIRM_PEC when others 2', sqlerrm);
       -- Modification du statut : 6 Erreur inconnue
       v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
       pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);
       -- Envoi du XML réponse
       RETURN (v_xml);
END F_CONFIRM_PEC;




FUNCTION F_ANNUL_PEC (
  P_xml IN XMLTYPE
) RETURN XMLTYPE IS
  v_xml xmltype;
  loc_num_dossier dossier_sante.num_dossier%TYPE;
  loc_numAdhe VARCHAR2(16);
  loc_motif NUMBER(3) :=1;
  erreur_99 BOOLEAN :=FALSE;
  v_id_flux flux.id_flux%TYPE;
  v_cod_err number:=0;
  v_deb NUMBER;
	v_delai NUMBER;
BEGIN
  G_IDLIGNE := 0;

                                                                                P_INS_journal(1,'F_ANNUL_PEC début', '');

  DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');

  -- ***************************************************************************
  -- * Validation XML Question / Création XML Réponse
  -- ***************************************************************************

  -- Initialisation des namespaces XML
  pk_xml.vg_xmlns := 'xmlns="pck/schemas/annulationPEC" xmlns:ent="pck/schemas/defaut/message';

  -- Initialisation XML réponse
  v_deb:=DBMS_UTILITY.GET_TIME;
  pk_xml.new_xml;

  -- Constitution de l'entete de la réponse
  P_ENTETE_REP(P_emet     => '00401554',
               P_emet_sup => '',
               P_dest     => PK_XML.EXTRACT_DATA(P_xml,'ent:Emetteur/ent:IdentificationCompagnie'),
               P_dest_sup => PK_XML.EXTRACT_DATA(P_xml,'ent:Emetteur/ent:IdentificationSupplement'),
               P_flux     => PK_XML.EXTRACT_DATA(P_xml,'ent:Flux/ent:Identifiant'),
               P_code     => '40');
  P_ENTETE_REP_ERREUR('00','');

  BEGIN
    -- Historisation du flux aller "Annulation de la prise en charge" (type 11)
    v_id_flux := pk_ws.insert_flux(p_id_type       => 11,
                                   p_id_flux_tiers => PK_XML.EXTRACT_DATA(P_xml,'ent:Flux/ent:Identifiant'),
                                   p_doc_xml       => p_xml,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => loc_grpporte );
    IF v_cod_err <> 0 THEN
       raise exc_erreur_inconnue;
    END IF;

    -- Validation du flux aller
    /*IF NOT pk_ws.is_flux_valid(p_xml, 11, v_id_flux) THEN                       P_INS_journal(2,v_id_flux||' F_ANNUL_PEC non valide', 'exc_erreur_inconnue');
       RAISE exc_erreur_inconnue;
    END IF;*/

    loc_num_dossier := PK_XML.EXTRACT_DATA(P_xml,'NumDossierDelegataire');
    loc_numAdhe := PK_XML.EXTRACT_DATA(P_xml,'Identifiant');

    --on vérifie que le dossier existe
    IF PK_CTRL_TP.F_FIND_DOSSIER(
      loc_num_dossier,
      loc_numAdhe) THEN

     IF F_ETAT_DOSSIER_SANTE(loc_num_dossier,sysdate,1) = 1 OR -- dossier fermé
         PK_CTRL_TP.F_FIND_SNTR_ANNUL(loc_num_dossier) = 1 THEN -- au moins 1 sinistre_sante annulé
        RAISE exc_dossier_annule;

      ELSIF PK_CTRL_TP.F_FIND_SNTR_DCPT(loc_num_dossier) = 1 THEN -- au moins 1 sinistre du dossier est décompté
        RAISE exc_dossier_facture;
      END IF;

      --recherche du motif de l'annulation si le flux en contient un sinon '1'
      IF PK_XML.EXTRACT_DATA(P_xml,'motifAnnulation') IS NOT NULL THEN
        loc_motif := NVL(F_get_transco('GRP','HISTO_D1',PK_XML.EXTRACT_DATA(P_xml,'motifAnnulation')),1);
      END IF;
      -- Annulation du dossier
      PK_CTRL_TP.P_ANNUL_DOSSIER(loc_num_dossier,loc_motif);
        -- mise à jour de la reférence externe de l'individu

      PK_CTRL_TP.P_MAJ_REF_EXTERNE(
          P_numindiv    => loc_numAdhe,
          P_domaine     => '',
          P_num_dossier => loc_num_dossier,
          P_tiers       => 'GRP',
          P_mnemo       => 'DOM');
      COMMIT;

    ELSE
      RAISE exc_dossier_inconnu; -- dossier non trouvé
    END IF;

   EXCEPTION
    WHEN exc_dossier_inconnu THEN
      P_ENTETE_REP_ERREUR('21','Annulation refusee - PEC/DAC introuvable');
    WHEN exc_dossier_annule THEN
      P_ENTETE_REP_ERREUR('22','Annulation refusee - PEC/DAC deja annulee');
    WHEN exc_dossier_facture THEN
      P_ENTETE_REP_ERREUR('23','Annulation refusee - PEC/DAC deja facturee');
    WHEN exc_erreur_inconnue THEN
      P_ENTETE_REP_ERREUR('99','Echec indetermine');
      erreur_99:=TRUE;
    WHEN OTHERS THEN
      P_ENTETE_REP_ERREUR('99','Echec indetermine');
      erreur_99:=TRUE;
      P_INS_journal(2,v_id_flux||' F_ANNUL_PEC', 'ECHEC :'||SQLERRM);
  END;

  ROLLBACK;

  -- ***************************************************************************
  -- * Génération/Validation du XML réponse
  -- ***************************************************************************

  v_xml := pk_xml.get_xml('Reponse','xmlns="pck/schemas/annulationPEC" xmlns:ent="pck/schemas/defaut/message"', false);

  -- Historisation de la réponse du flux "Annulation de pirse en charge" (type 12)
  pk_ws.add_xml(p_id_type => 12,
                p_id_flux => v_id_flux,
                p_doc_xml => v_xml,
                p_cod_err => v_cod_err);

  -- Validation du flux retour
 /* IF NOT pk_ws.is_flux_valid(v_xml, 12, v_id_flux) THEN                         P_INS_journal(2,v_id_flux||' F_ANNUL_PEC non valide', 'retour');
     RETURN v_xml;
  END IF;*/

  -- MAJ statut du flux OK
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  IF erreur_99 THEN
    pk_ws.maj_statut(v_id_flux, 6,null,v_delai);
  ELSE
    pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  END IF;

  P_INS_journal(1,'F_ANNUL_PEC fin', '');

  -- Envoi du XML réponse
  RETURN v_xml;

EXCEPTION
  WHEN OTHERS THEN                                                              P_INS_journal(2,v_id_flux||' F_ANNUL_PEC EXC', sqlerrm);
       -- Modification du statut : 6 Erreur inconnue
       v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
       pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);
       -- Envoi du XML réponse
       RETURN (v_xml);
END F_ANNUL_PEC;


FUNCTION F_LIQUID_TP(
 P_num_dossier dossier_sante.num_dossier%TYPE
) RETURN NUMBER
IS
  v_xml xmltype;
  v_xml_str CLOB;
  v_pos NUMBER;
  loc_num_dossier dossier_sante.num_dossier%TYPE;
  loc_num_fact_pec  dossier_sante.num_fact_pec%TYPE;
  loc_date_fact_pec  dossier_sante.date_fact_pec%TYPE;
  loc_num_dossier_pec  dossier_sante.num_dossier_pec%TYPE;
  loc_num_dossier_porte dossier_sante.num_dossier_porte%TYPE;

  v_id_flux flux.id_flux%TYPE;
  v_cod_err number:=0;
  v_code_retour VARCHAR2(2);
  v_deb NUMBER;
	v_delai NUMBER;

BEGIN

  BEGIN

    G_IDLIGNE := 0;
                                                                                P_INS_journal(1,'F_LIQUID_TP DOSSIER n:'||P_num_dossier, '');

    DBMS_SESSION.SET_NLS('nls_numeric_characters','''.,''');

    -- ***************************************************************************
    -- * Recherche des informations du dossier
    -- ***************************************************************************
    loc_num_dossier := P_num_dossier;

    PK_CTRL_TP.P_INFO_DOSSIER(
                    P_num_dossier_liq => loc_num_dossier,
                    O_num_fact_pec => loc_num_fact_pec,
                    O_date_fact_pec => loc_date_fact_pec,
                    O_num_dossier_pec => loc_num_dossier_pec,
                    O_num_dossier_porte => loc_num_dossier_porte);

    IF  loc_num_dossier IS NULL THEN                                            P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP exc 1', '');
       RETURN 1; -- Erreur
    END IF;


    -- Création occurence dans table FLUX  "Notification TP aller" (type 14)
    v_id_flux := pk_ws.insert_flux(p_id_type       => 14,
                                   p_id_flux_tiers => NULL,
                                   p_doc_xml       => NULL,
                                   p_cod_err       => v_cod_err,
                                   p_porte         => loc_grpporte );
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP', 'INSERT OK');
    IF v_cod_err <> 0 THEN                                                      P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP exc 2', '');
       RETURN 1; -- Erreur
    END IF;

  EXCEPTION
    WHEN OTHERS THEN                                                            P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP others 1', '');
       RETURN 1; -- Erreur
  END;

  -- à partir d'ici, une occurence existe dans la table FLUX
  -- => toute erreur inconnue entrainera une MAJ du statut du flux
  BEGIN

    -- ***************************************************************************
    -- * Création XML Question
    -- ***************************************************************************
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP ', 'INIT');
    -- Initialisation des namespaces XML
    pk_xml.vg_xmlns := 'xmlns="http://groupama/gan/courtiers/notificationLiquidationTP/retour" xmlns:ent="http://groupama/gan/courtiers/entete"';

    -- Initialisation XML question
    v_deb:=DBMS_UTILITY.GET_TIME;
    pk_xml.new_xml;

    -- Constitution de l'entete de la question
    P_ENTETE_QUEST(P_emet     => '00401554',
                   P_emet_sup => '',
                   P_dest     => '09470006',
                   P_dest_sup => '',
                   P_flux     => v_id_flux,
                   P_code     => '60',
                   P_gest     => '');

    -- ***************************************************************************
    -- * Constitution du corps du XML
    -- ***************************************************************************
    pk_xml.add_element('/', 'Dossier');
    pk_xml.add_data('Dossier', 'NumeroDossierAssureur',loc_num_dossier_porte, false);
    pk_xml.add_data('Dossier', 'NumeroDossierDelegataire',loc_num_dossier_pec, false);
    pk_xml.add_data('Dossier', 'DateReglement',to_char(loc_date_fact_pec,'DDMMYYYY'), false);

    -- ***************************************************************************
    -- * Génération/Validation du XML question
    -- ***************************************************************************

    v_xml := pk_xml.get_xml('Racine','xmlns="http://groupama/gan/courtiers/notificationLiquidationTP/aller" xmlns:ent="http://groupama/gan/courtiers/entete"', false);

    -- Historisation de la question du flux "Annulation TP aller" (type 14)
    pk_ws.add_xml(p_id_type => 14,
                  p_id_flux => v_id_flux,
                  p_doc_xml => v_xml,
                  p_cod_err => v_cod_err);

    IF v_cod_err <> 0 THEN                                                      P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP exc 3', '');
       RETURN 1;
    END IF;

    -- Validation du flux aller
    /*IF NOT pk_ws.is_flux_valid(v_xml, 14, v_id_flux) THEN                       P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP exc 4', '');
       RETURN 1; -- Erreur
    END IF;*/

    -- ***************************************************************************
    -- * Appel Web Service Notification Liquidation (Groupama)
    -- ***************************************************************************
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP', 'APPEL WS');
    v_xml := pk_ws.appel_ws(p_id_type => 14,
                            p_doc_xml => v_xml);

    IF v_xml IS NULL THEN                                                       P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP exc 5', '');
       -- MAJ statut du flux à 6 : Erreur inconnue
       v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
       pk_ws.maj_statut(v_id_flux, 6, 'Erreur lors de l''appel au WebService : '||sqlerrm,v_delai);
       RETURN 1;
    END IF;
    -- ***************************************************************************
    -- * Correction de l'encodification du message retour
    -- ***************************************************************************
    --set define off
    v_xml_str := v_xml.getStringval();
    v_xml_str := replace(v_xml_str,'&lt;','<');
    v_xml_str := replace(v_xml_str,'&gt;','>');
    v_pos     := INSTR(v_xml_str,'<Racine');
    v_xml_str := SUBSTR(v_xml_str,v_pos);
    v_pos     := INSTR(v_xml_str,'</result');
    v_xml_str := SUBSTR(v_xml_str,1,v_pos-1);
    v_xml     := XMLTYPE(v_xml_str);

    -- ***************************************************************************
    -- * Validation XML Réponse
    -- ***************************************************************************
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP 17', 'HISTO RETOUR');
    -- Historisation du flux retour "NotificationLiquidation TP" (type 15)
    pk_ws.add_xml(p_id_type => 15,
                  p_id_flux => v_id_flux,
                  p_doc_xml => v_xml,
                  p_cod_err => v_cod_err);

    -- Validation du flux retour
   /* IF NOT pk_ws.is_flux_valid(v_xml, 15, v_id_flux) THEN                       P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP exc 6', '');
       RETURN 1;
    END IF;*/

    -- MAJ statut du flux OK
     v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
     pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  EXCEPTION
    WHEN OTHERS THEN                                                            P_INS_journal(2,'F_LIQUID_TP others 2', '');
       -- MAJ statut du flux à 6 : Erreur inconnue
       pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);
       RETURN 1;
  END;

  -- à partir d'ici, il ne faut plus MAJ le statut du flux
  BEGIN
    -- ***************************************************************************
    -- * Lecture du XML Réponse
    -- ***************************************************************************
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP', 'LECTURE REP');
    -- Vérification du code retour du flux
    v_code_retour := PK_XML.EXTRACT_DATA(v_xml,'ent:Service/ent:CodeRetour');

    IF v_code_retour <> '01' THEN                                               P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP exc 7', '');
       P_INS_journal(2,'F_LIQUID_TP code retour <> 01', '');
       RETURN 1;
    END IF;

                                                                                P_INS_journal(1,'F_LIQUID_TP FIN', '');

    -- Fin OK
    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN                                                            P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP others 3', '');
         P_INS_journal(2,'F_LIQUID_TP others', sqlerrm);
         RETURN 1;
  END;
END F_LIQUID_TP;





FUNCTION F_LIQUID_TP_RETOUR( p_id_flux in number,
                            P_XML IN XMLTYPE
) RETURN NUMBER
IS
  v_xml xmltype;
  loc_num_dossier dossier_sante.num_dossier%TYPE;
  loc_num_fact_pec  dossier_sante.num_fact_pec%TYPE;
  loc_date_fact_pec  dossier_sante.date_fact_pec%TYPE;
  loc_num_dossier_pec  dossier_sante.num_dossier_pec%TYPE;
  loc_num_dossier_porte dossier_sante.num_dossier_porte%TYPE;

  v_id_flux flux.id_flux%TYPE;
  v_cod_err number:=0;
  v_code_retour VARCHAR2(2);
  v_deb NUMBER;
	v_delai NUMBER;

BEGIN

  BEGIN
    -- ***************************************************************************
    -- * Appel Web Service Notification Liquidation (Groupama)
    -- ***************************************************************************
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP_RETOUR 15', '');
    v_id_flux := p_id_flux;
    v_xml := P_XML;
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP_RETOUR 16', '');
    IF v_xml IS NULL THEN                                                       P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP_RETOUR exc 5', '');
       -- MAJ statut du flux à 6 : Erreur inconnue
       v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
       pk_ws.maj_statut(v_id_flux, 6, 'Erreur lors de l''appel au WebService : '||sqlerrm,v_delai);
       RETURN 1;
    END IF;

    -- ***************************************************************************
    -- * Validation XML Réponse
    -- ***************************************************************************
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP_RETOUR 17', '');
    -- Historisation du flux retour "NotificationLiquidation TP" (type 15)
    pk_ws.add_xml(p_id_type => 15,
                  p_id_flux => v_id_flux,
                  p_doc_xml => v_xml,
                  p_cod_err => v_cod_err);
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP_RETOUR 18', '');
    -- Validation du flux retour
    /*IF NOT pk_ws.is_flux_valid(v_xml, 15, v_id_flux) THEN                                   P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP_RETOUR exc 6', '');
       RETURN 1;
    END IF;*/
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP_RETOUR 19', '');
    -- MAJ statut du flux OK
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
    pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  EXCEPTION
    WHEN OTHERS THEN                                                            P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP_RETOUR others 2', '');
       -- MAJ statut du flux à 6 : Erreur inconnue
       v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
       pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);
       RETURN 1;
  END;

  -- à partir d'ici, il ne faut plus MAJ le statut du flux
  BEGIN
    -- ***************************************************************************
    -- * Lecture du XML Réponse
    -- ***************************************************************************
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP_RETOUR 20', '');
    -- Vérification du code retour du flux
    v_code_retour := PK_XML.EXTRACT_DATA(v_xml,'ent:Service/ent:CodeRetour');
                                                                                P_INS_journal(3,loc_num_dossier ||' F_LIQUID_TP_RETOUR 21', '');
    IF v_code_retour <> '00' THEN                                               P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP_RETOUR exc 7', '');
       P_INS_journal(2,'F_LIQUID_TP code retour <> 00', '');
       RETURN 1;
    END IF;

    P_INS_journal(1,'F_LIQUID_TP fin', '');

    -- Fin OK
    RETURN 0;

  EXCEPTION
    WHEN OTHERS THEN                                                            P_INS_journal(2,loc_num_dossier ||' F_LIQUID_TP_RETOUR others 3', '');
         P_INS_journal(2,'F_LIQUID_TP others', sqlerrm);
         RETURN 1;
  END;
END F_LIQUID_TP_RETOUR;




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
       WHERE NUMBATCH = 'WS06T';
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
        I_msg_adm  => substr(P_msg||' '||P_msg2,0,132),
        I_idligne  => G_idligne);
  END IF;
  COMMIT;
END P_INS_journal;

-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv

-- Insertion dans journal_adm
---------------- Fin des corps des procedures privees --

END PK_TP_GROUPAMA;
/
