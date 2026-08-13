CREATE OR REPLACE package ARTHUS.PK_WS_BACK_SANTECLAIR
as
/*=========================================================================
PAckage      : PK_WS_BACK_SANTECLAIR
Domaine      : webservice
Version      : V1.0
Auteur       : SDA
Création     : 19/05/2014
Description  :
==========================================================================
Evolution    : Optimisation F_RET_SC_CALCUL
Auteur       : JBO
Date         : 30/07/2014
Commentaire  : Ré-indentation du code de F_RET_SC_CALCUL, optimisation du code,
               gestion des erreurs avec des RAISE, optimisation des traces,
               traitement des qualifications clientes
==========================================================================
Correction   : JBO 18/11/2014 : Gestion d'un jumeau dans la recherche du patient
correction   : SDA/JBO Mantis 4711 PK_CTRL_TP.P_FIND_TIERS ajout adresse
correction   : SDA/JBO mantis 4719
correction   : SDA Mantis 4752
               remplacement dans
               F_FORMULE_SOUSCRITE du NUMGAR par loc_patient
               PK_CTRL_TP.F_CTRL_couverture du NUMGAR par loc_patient
               PK_CTRL_TP.F_CTRL_rang du NUMGAR par loc_patient
               PK_CTRL_TP.P_CTRL_CVRT_ACTE du NUMGAR par loc_patient
correction   : SDA Mantis 4772
               remplacement dans
               PK_CTRL_TP.P_CTRL_CVRT_ACTE du NUMGAR par loc_patient
               pour la prtie devis
Correction   : JBO 09/06/2015, Mantis 4870 : Correction sur la gestion des
               suppléments optique + Mise en place du délai de réponse d'une PEC
Evolution    : JBO 21/07/2015, Mantis 4734 : Ajout localisation dentaire sur écran gs14
               ==> Appel de la procédure P_MAJ_SNTR_SANTE_LOCDEN
Correction   : JBO 15/10/2015, Mantis 4970 : Correction sur la gestion des
               PEC auditifs: P_TRANSCO_CODFRAIS_AUDITIF , mise en commenataire --   AND n.auditif=1
Corection    : SDA Mantis 5177+5192+5279
Corection    : SDA Mantis 5294 et 5298
==========================================================================*/

TYPE T_Indiv IS RECORD (numindiv individu.numindiv%TYPE,
                        nom      individu.nom%TYPE,
                        prenom   individu.prenom%TYPE,
                        qualite  individu.qualite%TYPE,
                        datnais  individu.datnais%TYPE,
                        rang     individu.rang%TYPE,
                        matorg   individu.matorg%TYPE,
                        cless    individu.cless%TYPE,
                        idadhesion adhe_cntrt_membre.idadhesion%TYPE,
                        typadr     adhe_cntrt_membre.typadr%TYPE
                        );
TYPE TAB_T_Indiv IS TABLE OF T_Indiv index by binary_integer;


TYPE T_ACTE IS RECORD (
                        TYPE_ENREG         NUMBER(3),
                        DATE_SOINS         VARCHAR2(6),
                        PRIX_ACTE          NUMBER(11,5),
                        BASE_REMB          NUMBER(8,2),
                        TAUX_REMB          NUMBER(3),
                        MONT_REMB          NUMBER(8,2),
                        NATURE_PREST       VARCHAR2(5),
                        QUANT_ACTE         NUMBER(3),
                        COEFF_ACTE         NUMBER(5,2),
                        DENOM_ACTE         NUMBER(3),
                        NB_DENT            NUMBER(2),
                        MONTANT_DEP        NUMBER(8,2),
                        FAMILLE_LENT       VARCHAR2(1),
                        TYPE_RENOU_LENT    VARCHAR2(2),
                        TYPE_LENT          VARCHAR2(1),
                        MONT_PART_COMP     NUMBER(8,2),
                        CODE_LPP           VARCHAR2(7),
                        CODE_CCAM          VARCHAR2(7),
                        LOC_DENT1          VARCHAR2(2),
                        LOC_DENT2          VARCHAR2(2),
                        LOC_DENT3          VARCHAR2(2),
                        LOC_DENT4          VARCHAR2(2),
                        LOC_DENT5          VARCHAR2(2),
                        LOC_DENT6          VARCHAR2(2),
                        LOC_DENT7          VARCHAR2(2),
                        LOC_DENT8          VARCHAR2(2),
                        LOC_DENT9          VARCHAR2(2),
                        LOC_DENT10         VARCHAR2(2),
                        LOC_DENT11         VARCHAR2(2),
                        LOC_DENT12         VARCHAR2(2),
                        LOC_DENT13         VARCHAR2(2),
                        LOC_DENT14         VARCHAR2(2),
                        LOC_DENT15         VARCHAR2(2),
                        LOC_DENT16         VARCHAR2(2),
                        OD_SPHERE          NUMBER(4,2),
                        OD_CYLINDRE        NUMBER(4,2),
                        OD_AXE             NUMBER(3),
                        OD_ADDITION        NUMBER(4,2),
                        OG_SPHERE          NUMBER(4,2),
                        OG_CYLINDRE        NUMBER(4,2),
                        OG_AXE             NUMBER(3),
                        OG_ADDITION        NUMBER(4,2),
                        EQUI_2_OD_SPHERE   NUMBER(4,2),
                        EQUI_2_OD_CYLLIN   NUMBER(4,2),
                        EQUI_2_OD_AXE      NUMBER(3),
                        EQUI_2_OG_SPHERE   NUMBER(4,2),
                        EQUI_2_OG_CYLLIN   NUMBER(4,2),
                        EQUI_2_OG_AXE      NUMBER(3),
                        CASSE              VARCHAR2(1),
                        CESSITE            VARCHAR2(1),
                        NATURE_EQUI_OPT    VARCHAR2(1),
                        ACTE_COUVERT       BOOLEAN,
                        CODFRAIS           VARCHAR2(10)
                        );
TYPE TAB_T_ACTE IS TABLE OF T_ACTE index by binary_integer;


TYPE T_RET_ACTE IS RECORD (
                        NAT_PRESTATION      VARCHAR2(5),
                        FORMULE_SOUS1       VARCHAR2(15),
                        FORMULE_SOUS2       VARCHAR2(15),
                        LIBELLE_RETOUR      VARCHAR2(2),
                        MESS_SUPP           VARCHAR2(50),
                        MT_DEP              VARCHAR2(8),
                        MT_REMB_RO          VARCHAR2(8),
                        MT_PART_COMP        VARCHAR2(8),
                        MT_REMB_RC          VARCHAR2(8),
                        RESTE_A_CHARGE      VARCHAR2(8),
                        QUANTITE_ACTE       VARCHAR2(3),
                        FILLER1             VARCHAR2(3),
                        QUANTITE_COMP_ACTE  VARCHAR2(2),
                        CODE_CCAM           VARCHAR2(7),
                        FILLER2             VARCHAR2(25),
                        TYPE_ENREG          VARCHAR2(3)
                      );
TYPE TAB_T_RET_ACTE IS TABLE OF T_RET_ACTE index by binary_integer;


FUNCTION F_RET_SC_IDENDIFICATION(
  P_FLUX_SC VARCHAR2
) RETURN VARCHAR2;

FUNCTION F_RET_SC_CALCUL(
  P_FLUX_SC VARCHAR2
) RETURN VARCHAR2;

FUNCTION F_DECOUPE(
         P_FLUX VARCHAR2,
         P_DEBUT NUMBER,
         P_LONG NUMBER,
         P_AJOUT NUMBER default 0
) RETURN VARCHAR2;

FUNCTION F_COMPLETE(
         P_CHAINE VARCHAR2,
         P_LONG NUMBER,
         P_REMP VARCHAR2 default '['
) RETURN VARCHAR2;

FUNCTION F_FORMULE_SOUSCRITE(
         P_idadhesion adhesion.idadhesion%TYPE,
         P_numindiv   adhesion.numindiv%TYPE,
         P_date date default sysdate
) RETURN NUMBER;

FUNCTION F_FORMAT_NUMBER(
         P_CHAINE VARCHAR2,
         P_ENTIER NUMBER,
         P_DECIMALE NUMBER
) RETURN NUMBER;

FUNCTION F_FORMAT_VARCHAR(
         P_NUMBER NUMBER,
         P_ENTIER NUMBER,
         P_DECIMALE NUMBER
) RETURN VARCHAR2;

FUNCTION F_FIND_DOSSIER(
  P_ref_dossier IN dossier_sante.ref_dossier%TYPE
)RETURN VARCHAR2;

PROCEDURE P_FIND_ASSURE_BY_NOM(
   P_nom            IN individu.nom%TYPE default null
  ,P_prenom         IN individu.prenom%TYPE default null
  ,P_datenais       IN individu.DATNAIS%TYPE
  ,P_NUMGAR         IN individu.NUMINDIV%TYPE
  ,IO_Tab_indiv     OUT TAB_T_Indiv
  ,IO_cpt           OUT NUMBER
  ,O_numassu        OUT individu.numassu%TYPE
  ,O_famille        OUT NUMBER
  ,O_erreur         OUT NUMBER
  );

FUNCTION F_CODE_TYPE_ACTE(
loc_Tab_acte  TAB_T_ACTE
)
RETURN NUMBER;

FUNCTION F_INSERT_FLUX(
          p_id_type in type_flux.id_type%type,
          p_id_flux_tiers flux.id_flux_tiers%type
) RETURN NUMBER;

PROCEDURE P_TRANSCO_CODFRAIS_OPTIQUE( P_numfor             ADHESION.NUMFOR%TYPE
                                    , P_flag_oeil          NUMBER
                                    , P_acte               T_ACTE
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2
                                    );

PROCEDURE P_TRANSCO_CODFRAIS_DENTAIR( P_numfor             ADHESION.NUMFOR%TYPE
                                    , P_acte               T_ACTE
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2);

PROCEDURE P_TRANSCO_CODFRAIS_AUDITIF( P_numfor             ADHESION.NUMFOR%TYPE
                                    , P_acte               T_ACTE
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2);

PROCEDURE P_INS_journal(
          P_niv in NUMBER,
          p_msg in VARCHAR2,
          p_msg2 in varchar2 := null
);

FUNCTION F_TAB_ACTE_ERREUR(P_Tab_acte  TAB_T_ACTE,
                           P_LIBELLE_RETOUR_ACTE VARCHAR2,
                           P_TRAITEMENT VARCHAR2 default null
) RETURN TAB_T_RET_ACTE;

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_WS_BACK_SANTECLAIR as
/*=========================================================================
PAckage      : PK_WS_BACK_SANTECLAIR
Domaine      : webservice
Version      : V1.0
Auteur       : SDA
Création     : 19/05/2014
Description  :
==========================================================================
Evolution    : Optimisation F_RET_SC_CALCUL
Auteur       : JBO
Date         : 30/07/2014
Commentaire  : Ré-indentation du code de F_RET_SC_CALCUL, optimisation du code,
               gestion des erreurs avec des RAISE, optimisation des traces,
               traitement des qualifications clientes
==========================================================================
Correction   : JBO 18/11/2014 : Gestion d'un jumeau dans la recherche du patient
correction   : SDA/JBO Mantis 4711 PK_CTRL_TP.P_FIND_TIERS ajout adresse
correction   : SDA/JBO mantis 4719
correction   : SDA Mantis 4752
               remplacement dans
               F_FORMULE_SOUSCRITE du NUMGAR par loc_patient
               PK_CTRL_TP.F_CTRL_couverture du NUMGAR par loc_patient
               PK_CTRL_TP.F_CTRL_rang du NUMGAR par loc_patient
               PK_CTRL_TP.P_CTRL_CVRT_ACTE du NUMGAR par loc_patient
correction   : SDA Mantis 4772
               remplacement dans
               PK_CTRL_TP.P_CTRL_CVRT_ACTE du NUMGAR par loc_patient
               pour la prtie devis
Correction   : JBO 09/06/2015, Mantis 4870 : Correction sur la gestion des
               suppléments optique + Mise en place du délai de réponse d'une PEC
Evolution    : JBO 21/07/2015, Mantis 4734 : Ajout localisation dentaire sur écran gs14
               ==> Appel de la procédure P_MAJ_SNTR_SANTE_LOCDEN
Correction   : JBO 15/10/2015, Mantis 4970 : Correction sur la gestion des
               PEC auditifs: P_TRANSCO_CODFRAIS_AUDITIF , mise en commenataire --   AND n.auditif=1
Evolution    : JBO 07/02/2017 Mise en place de la notion de réseau de soins : P201608003_reseau_soin_GEREP + M5232
==========================================================================*/
g_porte number(2) := 16; -- Porte SANTECLAIR

-- Variables de P_INS_journal
G_nom_traitement  Constant journal_adm.nom_traitement%TYPE default 'SANTE_CLAIR';
G_niv_msg         journal_adm.niv_msg%TYPE := 4;
G_idligne         journal_adm.idligne%TYPE := 0;
g_msg_adm         journal_adm.msg_adm%TYPE;
g_tabCond		  PK_PORTE.TAB_Cond;

/**************FUNCTION F_RET_SC_IDENTIFICATION*************************/
FUNCTION F_RET_SC_IDENDIFICATION(
  P_FLUX_SC VARCHAR2
) RETURN VARCHAR2
IS
       REP_F_SC_IDENTIFICATION VARCHAR2(32000);
       NOM_FIC VARCHAR2(200);
       FILEHANDLER UTL_FILE.FILE_TYPE;
       P_RETOUR_FLUX VARCHAR2(4000);
       P_RETOUR_FLUX_ERREUR VARCHAR2(4000);
       msg_error VARCHAR2(200);
       L_FLUX_SC NUMBER;
       cpt NUMBER:=0;
       i NUMBER:=0;


       --variable traitement
       --flux
       v_id_flux NUMBER;
       --info assure contrat
       loc_idadhesion     adhe_cntrt.idadhesion%TYPE;
       loc_etat_adhesion  number default 0;
       loc_tr_etat_adhesion number default 0;
       loc_tr_etat_adhesion2 varchar2(2);
       loc_numgar         contrat_ref.numgar%TYPE;
       loc_isColl         BOOLEAN;
       loc_tr_isColl      number default 0;
       loc_libelle        produit.libelle%TYPE;
       loc_dateEffet      adhe_cntrt.date_adhe%TYPE;
       loc_dateRes        adhe_cntrt.date_fin_adhe%TYPE;
       loc_numorg         contrat_ref.numorg%TYPE;
       loc_numporte       dossier_sante.numporte%TYPE;
       loc_refcie_cntrt   contrat.refcie%TYPE;
       loc_nom_ent_sous   individu.nom%TYPE;
       loc_numassu        individu.numassu%TYPE;
       erreur_contrat     NUMBER :=0;
       --adresse
       loc_ligne1  VARCHAR2(50);
       loc_ligne2  VARCHAR2(50);
       loc_ligne3  VARCHAR2(50);
       loc_ligne4  VARCHAR2(50);
       loc_ligne5  VARCHAR2(50);
       loc_cp  pers_adresse.codpos%TYPE;
       loc_ville pers_adresse.ville%TYPE;
       loc_tel     VARCHAR2(10);
       --individu
       loc_numindiv individu.numindiv%TYPE;
       loc_qualite  individu.qualite%TYPE;
       loc_tr_qualite VARCHAR2(3);
       loc_nom      individu.nom%TYPE;
       loc_prenom   individu.prenom%TYPE;
       loc_datnais  VARCHAR2(8);
       loc_regime   individu.regime%TYPE;
       loc_tr_regime VARCHAR(4);
       loc_nb_regime number;
       loc_typadr   adhe_cntrt_membre.typadr%TYPE;
       loc_tr_typadr   VARCHAR2(2);
       loc_nb_individu NUMBER;
       loc_Tab_Indiv   TAB_T_Indiv;
       loc_assureur    NUMBER;
       loc_tr_assureur VARCHAR(2);
       loc_famille_ok  NUMBER:=0;   -- Flag permettant de savoir si c'est un groupe familial ou une liste d homonymes
       loc_type_retour NUMBER:=0;
       loc_erreur      NUMBER:=0;

       --contrat
       loc_type_contrat contrat.type_contrat%TYPE;
       loc_type_tr_contrat varchar(2);
       formule_sous1 number;

       --entite
       IDENT_COMPAGNIE VARCHAR2(8);
       IDENT_SUPP      VARCHAR2(2);
       NUMGAR          VARCHAR2(16);
       NUMGAR_aff      VARCHAR2(16);
       LOC_NUMGAR_KO   VARCHAR2(16);
       COMP_NUMGAR     VARCHAR2(16);
       NOM             VARCHAR2(32);
       PRENOM          VARCHAR2(32);
       DATE_NAISS      VARCHAR2(8);
       DATE_NAISS2     DATE;
       CODE_POS        VARCHAR2(5);
       TYPE_ECHANGE    VARCHAR2(1);
       loc_test_numgar NUMBER:=0;

       --variable traitement
         --OK
         --1 unique structure 01
         --3 homonyme structure 03
         --KO
         --0,2,4,5,6,7 reponse structure 0X
       TYPE_RETOUR NUMBER(1);

       v_deb NUMBER;
       v_delai NUMBER;

BEGIN

       --sauvegarde dans un fichier txt
       --pour la phase de test
     /*  NOM_FIC := 'FLUX_IDENT_' || TO_CHAR(SYSTIMESTAMP,'YYYYDDMMHH24MISSFFFF')  || '.txt';
       FILEHANDLER := UTL_FILE.FOPEN('REP_SANTECLAIR', NOM_FIC, 'W');
       UTL_FILE.PUTF(FILEHANDLER, P_FLUX_SC);
       UTL_FILE.FCLOSE(FILEHANDLER);*/
       --fin sauvegarde

       -- Initialisation XML réponse
       v_deb:=DBMS_UTILITY.GET_TIME;

       L_FLUX_SC := LENGTH(P_FLUX_SC);

       --insertion trace flux aller dans table flux
       v_id_flux := F_INSERT_FLUX(20,'FLUX_IDENT_SC');

       --insertion du flux aller dans table de stockage
       INSERT INTO HISTO_FLUX_WS_SC (ID_FLUX_SC,TYPE_FLUX,DATE_FLUX,FLUX_ALLER,FLUX_RETOUR,LONG_FLUX_IN,LONG_FLUX_OUT)
       VALUES (v_id_flux,1,sysdate,P_FLUX_SC,null,L_FLUX_SC,null);

       --Flux ALLER
       --*******************************************************************--
       --récuperation des entités
         --Identification Compagnie
         IDENT_COMPAGNIE := F_DECOUPE(P_FLUX_SC,0,8);
         --Identifiant supplémentaire
         IDENT_SUPP := F_DECOUPE(P_FLUX_SC,9,2);
         --N° de contrat
         NUMGAR := F_DECOUPE(P_FLUX_SC,11,16);
         BEGIN
           LOC_NUMGAR_KO := NUMGAR;
           loc_test_numgar:=TO_NUMBER(NUMGAR);
           IF LENGTH(NUMGAR)>9 THEN
             P_INS_journal(2,v_id_flux||' Contrat(numindiv) trop long) : ' || NUMGAR);
             NUMGAR_aff:=NUMGAR;
             NUMGAR:='0';
           END IF;
         EXCEPTION
           WHEN OTHERS THEN
             NUMGAR_aff:=NUMGAR;
             NUMGAR:='0';
         END;
         P_INS_journal(2,v_id_flux||' LOC_NUMGAR_KO : ' || LOC_NUMGAR_KO);
         P_INS_journal(2,v_id_flux||' NUMGAR : ' || NUMGAR);
         P_INS_journal(2,v_id_flux||' NUMGAR_aff : ' || NUMGAR_aff);
          --Complément au n° de contrat
         COMP_NUMGAR := F_DECOUPE(P_FLUX_SC,27,16);
         --Nom
         NOM := F_DECOUPE(P_FLUX_SC,43,32);
         NOM := replace(NOM,'*','');
          --Prénom
         PRENOM := F_DECOUPE(P_FLUX_SC,75,32);
         --Date de naissance
         DATE_NAISS := F_DECOUPE(P_FLUX_SC,107,8);
          --Code postal
         CODE_POS := F_DECOUPE(P_FLUX_SC,115,5);
          --Type d’échange I (Identification)
         TYPE_ECHANGE := F_DECOUPE(P_FLUX_SC,164,1);
       --fin récupérations des entités
         P_INS_journal(2,v_id_flux||' avant proc : ' || NUMGAR);
      --   NUMGAR_aff:=NUMGAR;
         P_INS_journal(2,v_id_flux||' DATE_NAISS : ' || DATE_NAISS);
         --traitement par le nom/prenom/date de naissance
         DATE_NAISS2 := e2d(DATE_NAISS);
         P_INS_journal(2,v_id_flux||' avnt P_FIND_ASSURE_BY_NOM : ' );
         P_FIND_ASSURE_BY_NOM(P_nom=>NOM
                             ,P_prenom=>PRENOM
                             ,P_datenais =>e2d(DATE_NAISS2)
                             ,P_NUMGAR => NUMGAR
                             ,IO_Tab_indiv=> loc_Tab_Indiv
                             ,IO_cpt=> loc_nb_individu
                             ,O_numassu => loc_numassu
                             ,O_famille => loc_famille_ok
                             ,O_erreur => loc_erreur
                                 );

         IF NUMGAR = '0' THEN
           loc_nb_individu:=0;
         END IF;

         P_INS_journal(2,v_id_flux||' loc_nb_individu : ' || loc_nb_individu);
         P_INS_journal(2,v_id_flux||' numindiv : ' || NUMGAR);
         P_INS_journal(2,v_id_flux||' loc_numassu : ' || loc_numassu);
         P_INS_journal(2,v_id_flux||'  loc_famille_ok : ' || loc_famille_ok);

         IF loc_nb_individu = 1 AND loc_famille_ok>0 THEN
                  TYPE_RETOUR := 1; -- la recherche est OK
                  NUMGAR := loc_Tab_Indiv(loc_nb_individu).numindiv;
                  loc_type_retour:=1;      ---- JBO 31082015
         /*ELSIF  loc_nb_individu = 0 THEN
                   TYPE_RETOUR := 6; -- échec, une ou plusieurs données inconnues
                  NUMGAR := null;*/
         ELSIF (loc_nb_individu > 1 and loc_nb_individu < 20) and loc_famille_ok=-1 THEN
                  TYPE_RETOUR := 3; -- il existe plusieurs homonymes sur ce contrat
                  NUMGAR := null;
         ELSIF (loc_nb_individu > 1 and loc_nb_individu < 20) and loc_famille_ok>0 THEN
                  loc_type_retour := 3; -- il existe plusieurs homonymes sur ce contrat
                  TYPE_RETOUR := 1; -- il existe plusieurs homonymes sur ce contrat
                  NUMGAR:=loc_numassu;
       /*  ELSIF (loc_nb_individu > 20) and loc_famille_ok=-1  THEN
                  loc_type_retour := 3; -- il existe plusieurs homonymes sur ce contrat
                  TYPE_RETOUR := 1;*/
         ELSIF (loc_nb_individu > 20) and loc_famille_ok>0 THEN
                  TYPE_RETOUR := 4; -- il y a plus de 20 homonymes, affiner la recherche
                --  loc_type_retour := 3; -- il existe plusieurs homonymes sur ce contrat
                  NUMGAR := null;
         ELSIF loc_nb_individu = 0 THEN
                  P_INS_journal(2,'loc_erreur : ' || loc_erreur);
                  loc_type_retour:=0;
                  IF loc_erreur=6 THEN
                    TYPE_RETOUR := 6; -- échec n°de contrat inconnu
                    P_INS_journal(2,v_id_flux||' échec n°de contrat inconnu, numgar : ' || NUMGAR);
                    NUMGAR := null;
                  ELSE
                    TYPE_RETOUR := 2; -- échec n°de contrat inconnu
                    P_INS_journal(2,v_id_flux||' échec n°de contrat inconnu, numgar : ' || NUMGAR);
                    NUMGAR := null;
                  END IF;

         ELSE
                  TYPE_RETOUR := 0; -- échec indéterminé
                  NUMGAR := null;
                  P_INS_journal(2,v_id_flux||' Erreur indéterminée');
                  IF  loc_etat_adhesion in (2,3) THEN
                    --msg_error := 'Le n°contrat/adhesion est résiliée ou suspendue.';
                    msg_error := 'Erreur indéterminée';
                  END IF;
         END IF;
         --END IF;

         --traitemenent de la demande
         --numgar est le numero d'adherent
         IF NUMGAR is not null THEN
             PK_CTRL_TP.P_FIND_CONTRAT_BY_ASSU(
              loc_numassu,
              loc_numassu,
              g_porte,
              loc_idadhesion,
              loc_numgar,
              loc_isColl,
              loc_libelle,
              loc_dateEffet,
              loc_dateRes,
              loc_numorg,
              loc_numporte,
              erreur_contrat);

              P_INS_journal(2,v_id_flux||' erreur_contrat : ' || erreur_contrat);

              IF erreur_contrat = 0 THEN
                  SELECT i.numindiv,i.qualite, i.nom,i.prenom,to_char(i.datnais,'DDMMYYYY'), i.regime, m.typadr
                  INTO loc_numindiv,loc_qualite,loc_nom,loc_prenom,loc_datnais,loc_regime,loc_typadr
                  FROM adhe_cntrt_membre m,individu i
                  WHERE m.idadhesion = loc_idadhesion
                  AND m.numindiv = NUMGAR
                  AND m.numindiv = i.numindiv;

                  loc_tr_regime := F_GET_TRANSCO('SC','REGIME',loc_regime,1);
                  IF length(loc_tr_regime) = 1 THEN
                    loc_tr_regime := '0' || loc_tr_regime;
                  END IF;

                  select type_contrat,numorg,refcie,f_nom(numcli,30) into loc_type_contrat,loc_assureur,loc_refcie_cntrt,loc_nom_ent_sous from contrat where numgar= loc_numgar;

                  loc_tr_assureur := F_GET_TRANSCO('SC','ORGN',to_char(loc_assureur),1);
                  IF length(loc_tr_assureur) = 1 THEN
                    loc_tr_assureur := '0' || loc_tr_assureur;
                  END IF;
                  loc_type_tr_contrat := '0' || loc_type_contrat;

                  PK_CTRL_TP.P_ADR_FORMAT(
                  NUMGAR,
                  loc_ligne1,
                  loc_ligne2,
                  loc_ligne3 ,
                  loc_ligne4,
                  loc_ligne5,
                  loc_cp ,
                  loc_ville);

                  loc_ligne1:=substr(loc_ligne1, 1, 32);
                  loc_ligne2:=substr(loc_ligne2, 1, 32);
                  loc_ligne3:=substr(loc_ligne3, 1, 32);
                  loc_ligne4:=substr(loc_ligne4, 1, 32);
                  loc_ligne5:=substr(loc_ligne5, 1, 32);
                  loc_ville:=substr(loc_ville, 1, 26);

                  formule_sous1 := F_FORMULE_SOUSCRITE(loc_idadhesion,NUMGAR);
              END IF;

              IF erreur_contrat = 2 THEN
                  TYPE_RETOUR := 02;
                  msg_error := 'PORTE SANTE CLAIR NON OUVERTE ADHÉRENT:' || NUMGAR;
                  P_INS_journal(2,v_id_flux||' PORTE SANTE CLAIR NON OUVERTE ADHÉRENT:' || NUMGAR);
              ELSIF erreur_contrat = 1 THEN
                  TYPE_RETOUR := 02;
                  msg_error := 'LE N°ADHERENT N''EXISTE PAS.';
                  P_INS_journal(2,v_id_flux||' LE N°ADHERENT N''EXISTE PAS.');
              ELSE
                  TYPE_RETOUR := 1;
              END IF;

         END IF;
        --Flux RETOUR
        --*******************************************************************--
        --retour de la demande
         --OK reponse unique structure 01
         --ENTETETE 400 octets
             --Identification Compagnie
             P_RETOUR_FLUX := F_COMPLETE(IDENT_COMPAGNIE,8);
             --Identifiant supplémentaire
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(IDENT_SUPP,2);

             P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX;
             P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX_ERREUR || F_COMPLETE('00',2);
             P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX_ERREUR || F_COMPLETE('ERREUR TECHNIQUE',200);
             P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX_ERREUR || F_COMPLETE('',16);
             P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX_ERREUR || F_COMPLETE('',3172);

             --Message retour
             P_INS_journal(2,v_id_flux||' Message retour,TYPE_RETOUR:'||to_char(TYPE_RETOUR));
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('0'||TYPE_RETOUR,2);
        IF TYPE_RETOUR=0 OR TYPE_RETOUR=2  THEN
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(msg_error,200);
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(LOC_NUMGAR_KO,16);
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',3172);
        END IF;
        P_INS_journal(2,v_id_flux||' LOC_NUMGAR_KO:'||LOC_NUMGAR_KO);

        IF TYPE_RETOUR=1 AND loc_type_retour>0  THEN    ---- JBO 31082015 : modif du OR par AND
             --N° de Contrat
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(NVL(NUMGAR_aff,loc_numassu),16);
             --Complément au n° de contrat
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(COMP_NUMGAR,16);
             --Etat Contrat
             P_INS_journal(2,'loc_idadhesion:'||to_char(loc_idadhesion));
             loc_etat_adhesion := f_etat_adhe(loc_idadhesion,sysdate);
             loc_tr_etat_adhesion := loc_etat_adhesion;
             P_INS_journal(2,'loc_etat_adhesion:'||to_char(loc_etat_adhesion));
             IF loc_etat_adhesion = 2 THEN
               msg_error := 'Le n°contrat/adhesion est suspendue.';
               loc_tr_etat_adhesion  := 3;
             END IF;
             IF loc_etat_adhesion = 3 THEN
               msg_error := 'Le n°contrat/adhesion est résiliée.';
               loc_tr_etat_adhesion := 2;
             END IF;
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('0' || loc_tr_etat_adhesion,2);
             --Etat Prime
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',2);
             --codage statistique
             IF loc_isColl THEN
                loc_tr_isColl := 2;
             ELSE
                loc_tr_isColl := 1;
             END IF;


             P_INS_journal(2,v_id_flux||' loc_tr_isColl:'||to_char(loc_tr_isColl));

             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('0' || loc_tr_isColl,2);
             --filler
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',18);
             --Nom du contrat souscrit
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_nom_ent_sous,30);
             --Adresse 1
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ligne1,32);
             --Adresse 2
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ligne4,32);
             --Adresse 3
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ligne2,32);
             --Adresse 4
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ligne3,32);
             --Adresse 5
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ligne5,32);
             --Code Postal
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_cp,5);
             --Ville
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ville,26);
             --Code commune
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',5);
             --N° de téléphone
             loc_tel := substr(trim(replace(f_contact(NUMGAR,1),'.','')),1,10);
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_tel,10);
             --N° (Code) de l’intermédiaire
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',6);
             --Type intermédiaire
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',2);
             --Date d’effet contrat
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',8);
             --Code gestion (vu avec gerep et santeclair)
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('GEREP',10);
             --Code assureur
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_tr_assureur,2);
             --Tout Internet
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',2);
             --Date de résiliation
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',8);
             --Date de l'échéance anniversaire
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',8);
             --Email
             P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',50);
         --ENTETETE 400 octets
         --POSTES 15 * 200 octets
             FOR i in 1..15 LOOP
                 IF TYPE_RETOUR = 1 and i > loc_Tab_Indiv.count-1 THEN
                    loc_qualite          := null;
                    loc_tr_qualite       := null;
                    loc_nom              := null;
                    loc_prenom           := null;
                    loc_type_tr_contrat  := null;
                    loc_datnais          := null;
                    loc_typadr           := null;
                    loc_tr_typadr        := null;
                    loc_etat_adhesion    := null;
                    loc_tr_etat_adhesion := null;
                    loc_tr_etat_adhesion2:= null;
                    loc_regime           := null;
                    loc_tr_regime        := null;
                    formule_sous1        := null;

                 END IF;

                 --Civilité
                 IF loc_qualite is not null THEN
                    IF loc_qualite = 1 THEN
                       loc_tr_qualite := 'M';
                    ELSIF loc_qualite = 2 THEN
                       loc_tr_qualite := 'MME';
                    ELSIF loc_qualite = 3 THEN
                       loc_tr_qualite := 'MLE';
                    ELSE
                       loc_tr_qualite := 'A';
                    END IF;
                 ELSE
                    loc_tr_qualite := null;
                 END IF;
                 IF i > loc_Tab_Indiv.count-1 THEN
                    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_tr_qualite,3);
                    --Nom
                    P_INS_journal(2,'loc_Tab_Indiv(i).nom:'||loc_nom);
                    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_nom,32);
                    --Prénom
                    P_INS_journal(2,'loc_Tab_Indiv(i).prenom:'||loc_prenom);
                    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_prenom,32);
                    --Date Naissance
                    P_INS_journal(2,'loc_Tab_Indiv(i).prenom:'||to_char(loc_datnais,'DDMMYYYY'));
                    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(to_char(loc_datnais,'DDMMYYYY'),8);
                 ELSE
                    --Civilité
                   IF loc_Tab_Indiv(i).qualite is not null THEN
                      IF loc_Tab_Indiv(i).qualite = 1 THEN
                         loc_tr_qualite := 'M';
                      ELSIF loc_Tab_Indiv(i).qualite = 2 THEN
                         loc_tr_qualite := 'MME';
                      ELSIF loc_Tab_Indiv(i).qualite = 3 THEN
                         loc_tr_qualite := 'MLE';
                      ELSE
                         loc_tr_qualite := 'A';
                      END IF;
                   ELSE
                      loc_tr_qualite := null;
                   END IF;
                    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_tr_qualite,3);
                     --Nom
                    P_INS_journal(2,'loc_Tab_Indiv(i).nom:'||loc_Tab_Indiv(i).nom);
                    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_Tab_Indiv(i).nom,32);
                    --Prénom
                    loc_typadr:=loc_Tab_Indiv(i).typadr;
                    --P_INS_journal(2,'loc_typadr:'||to_char(loc_typadr));
                    --P_INS_journal(2,'loc_Tab_Indiv(i).prenom:'||loc_Tab_Indiv(i).prenom);
                    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_Tab_Indiv(i).prenom,32);
                    --Date Naissance
                    --P_INS_journal(2,'loc_Tab_Indiv(i).prenom:'||to_char(loc_Tab_Indiv(i).datnais,'DDMMYYYY'));
                    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(to_char(loc_Tab_Indiv(i).datnais,'DDMMYYYY'),8);
                 END IF;
                 --Type de Garantie
                 --01--sante
                 --02--prevoynce

                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_type_tr_contrat,2);
                 --Régime Social
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_tr_regime,2);
                 --Parenté avec l’assuré principal
                 IF  loc_typadr is not null THEN
                    IF loc_typadr = 0 THEN
                       --Assuré Principal
                       loc_tr_typadr := 'A';
                    ELSIF loc_typadr = 1 THEN
                       --Conjoint
                       loc_tr_typadr := 'C';
                    ELSIF loc_typadr = 2 THEN
                       --Enfant à charge
                       loc_tr_typadr := 'E';
                    ELSIF loc_typadr = 3 THEN
                       --Concubin
                       loc_tr_typadr := 'C';
                    ELSIF loc_typadr = 4 THEN
                       --Ayant-droit à charge
                       loc_tr_typadr := 'AU';
                    ELSIF loc_typadr = 6 THEN
                       --Ouvreur de droit
                       loc_tr_typadr := 'AU';
                    ELSIF loc_typadr = 7 THEN
                       --PACSE
                       loc_tr_typadr := 'C';
                    ELSIF loc_typadr = 8 THEN
                       --Personne ayant acquitté frais d'obsèques
                       loc_tr_typadr := 'AU';
                    ELSIF loc_typadr = 9 THEN
                       --Affilié
                       loc_tr_typadr := 'A';
                    ELSIF loc_typadr = 10 THEN
                       --Enfant bénéficiaire
                       loc_tr_typadr := 'E';
                    ELSIF loc_typadr = 11 THEN
                       --Ascendants
                       loc_tr_typadr := 'AU';
                    ELSIF loc_typadr = 12 THEN
                       --Collatéraux
                       loc_tr_typadr := 'AU';
                    ELSIF loc_typadr = 13 THEN
                       --Neveu, nièce
                       loc_tr_typadr := 'AU';
                    ELSIF loc_typadr = 14 THEN
                       --Autres (Associations ...)
                       loc_tr_typadr := 'AU';
                    ELSIF loc_typadr = 15 THEN
                       --Enfant invalide
                       loc_tr_typadr := 'E';
                    ELSIF loc_typadr = 16 THEN
                       --Enfant primo demandeur d'emploi
                       loc_tr_typadr := 'E';
                    ELSE
                       loc_tr_typadr := 'AU';
                    END IF;
                 END IF;
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_tr_typadr,2);
                 --Situation administrative
                 IF loc_etat_adhesion is not null THEN
                    IF loc_etat_adhesion = 0 THEN
                      loc_tr_etat_adhesion := 3;
                    ELSIF loc_etat_adhesion = 1 THEN
                      loc_tr_etat_adhesion := 1;
                    ELSIF loc_etat_adhesion = 2 THEN
                      loc_tr_etat_adhesion := 2;
                    ELSIF loc_etat_adhesion = 3 THEN
                      loc_tr_etat_adhesion := 2;
                    ELSE
                      loc_tr_etat_adhesion := 2;
                    END IF;
                    loc_tr_etat_adhesion2 := '0' || loc_tr_etat_adhesion;
                 END IF;
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_tr_etat_adhesion2,2);
                 --Formule souscrite 1
                 --pb voir avec marylin
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(formule_sous1,15);
                 --Formule souscrite 2
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',15);
                 --Zone technique utile au calcul
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',50);
                 --Plafond Optique
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',2);
                 --Plafond Dentaire
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',2);
                 --Filler
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',1);
                 --Top G10
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',1);
                 --Date Fin Carence Hospi
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',6);
                 --Date Fin Carence Optique
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',6);
                 --Date Fin Carence Dentaire
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',6);
                 --Formule
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',6);
                 --Formule
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',6);
                 --Filler
                 P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',1);

             END LOOP;
         --FIN POSTES 15 * 200 octets
         END IF;

         P_INS_journal(2,v_id_flux||' TYPE_RETOUR:'||to_char(TYPE_RETOUR));
         P_INS_journal(2,v_id_flux||' loc_idadhesion:'||to_char(loc_idadhesion));

         --OK reponse homonyme structure 03
         IF TYPE_RETOUR=3 THEN
          FOR i IN 1..loc_nb_individu LOOP
              P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_Tab_Indiv(i).nom,32);
              P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_Tab_Indiv(i).prenom,32);
              P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(to_char(loc_Tab_Indiv(i).datnais,'DDMMYYYY'),8);
              P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',16);
              P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_Tab_Indiv(i).numindiv,16);--idadhesion
              P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',16);
          END LOOP;
          --complete selon le nombre d'invidu a 20
          FOR i IN loc_nb_individu+1..20 LOOP
              P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',120);
          END LOOP;
          --filer de 988
          P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',988);
         END IF;

         IF TYPE_RETOUR=4 THEN
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('LA LISTE DES HOMONYMES DÉPASSE LES 20 PERSONNES.',200);
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',16);
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',3172);
         END IF;


         IF TYPE_RETOUR=6 THEN
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',200);
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(Loc_numgar_ko,16);
            P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',3172);
         END IF;

         --KO structure 00,02,04,05,06,07
         IF TYPE_RETOUR<>1 or TYPE_RETOUR<>3 THEN
          cpt := cpt+1;
          PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'PK_WS_BACK_SANTECLAIR',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr('F_RET_SC_IDENDIFICATION : TYPE_RETOUR ' || TYPE_RETOUR,1,132),
            I_idligne  => cpt);
         END IF;

         --remplace des crochets par []
         P_RETOUR_FLUX := replace(P_RETOUR_FLUX,'[',' ');
         P_RETOUR_FLUX := replace(P_RETOUR_FLUX,']',' ');

         --longueur du flux retour
         L_FLUX_SC := LENGTH(P_RETOUR_FLUX);
         --UPDATE flux retour
         UPDATE HISTO_FLUX_WS_SC
         SET FLUX_RETOUR = P_RETOUR_FLUX,
         LONG_FLUX_OUT = L_FLUX_SC
         WHERE ID_FLUX_SC = v_id_flux;

         --REP_F_SC_IDENTIFICATION := 'OK FLUX TRAITEMENT IDENTIFICATION : ' || TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS');
         REP_F_SC_IDENTIFICATION := P_RETOUR_FLUX;

         P_INS_journal(2,v_id_flux||' TYPE_RETOUR: ' || TYPE_RETOUR);


         -- MAJ statut du flux OK
         v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
         IF TYPE_RETOUR=0 THEN
           pk_ws.maj_statut(v_id_flux, 6,null,v_delai);
         ELSE
           pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
         END IF;

         RETURN REP_F_SC_IDENTIFICATION;

     EXCEPTION
       WHEN OTHERS THEN
          ROLLBACK;
          P_INS_journal(2,v_id_flux||' F_RET_SC_IDENDIFICATION;' || sqlerrm);
          v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
          pk_ws.maj_statut(v_id_flux, 6,sqlerrm,v_delai);   -- statut à 6 si une erreur technique est survenue
          P_RETOUR_FLUX_ERREUR := replace(P_RETOUR_FLUX_ERREUR,'[',' ');
          P_RETOUR_FLUX_ERREUR := replace(P_RETOUR_FLUX_ERREUR,']',' ');
          RETURN P_RETOUR_FLUX_ERREUR;
END F_RET_SC_IDENDIFICATION;

/**************FUNCTION F_RET_SC_CALCUL*************************/
FUNCTION F_RET_SC_CALCUL(
  P_FLUX_SC VARCHAR2
) RETURN VARCHAR2
IS
  REP_F_SC_CALCUL VARCHAR2(32000);
  NOM_FIC VARCHAR2(200);
  FILEHANDLER UTL_FILE.FILE_TYPE;
  L_FLUX_SC NUMBER;
  P_TEMP_FLUX VARCHAR2(7400);
  P_RETOUR_FLUX VARCHAR2(7400);
  P_RETOUR_FLUX_ERREUR VARCHAR2(7400);
  msg_error VARCHAR2(200);
  cpt NUMBER:=0;
  cpt_acte NUMBER := 0;
  cpt_acte2 NUMBER := 0;

  --variable traitement
  --flux
  v_id_flux                                      NUMBER;

  --entite
  --aller
  IDENT_COMPAGNIE                                VARCHAR2(8);
  IDENT_SUPP                                     VARCHAR2(2);
  NUMGAR                                         VARCHAR2(16);
  DATENAIS                                       VARCHAR2(8);
  TYPE_MONNAIE                                   VARCHAR2(1);
  TYPE_ECAHNGE                                   VARCHAR2(1);
  CODE_TYPE_DOSSIER                              VARCHAR2(1);
  CODE_ACTION                                    VARCHAR2(1);
  DATE_FIN_VAL                                   VARCHAR2(8);
  NUM_PEC                                        VARCHAR2(16);
  MODE_TEST                                      VARCHAR2(1);
  loc_Tab_acte                                   TAB_T_ACTE;

  TIERS_ADELI                                    NUMBER(9);
  TIERS_SPECIALITE                               VARCHAR2(2);
  TIERS_RAISON                                   VARCHAR2(32);
  TIERS_NOM                                      VARCHAR2(25);
  TIERS_ADRESSE                                  VARCHAR2(32);
  TIERS_CODEPOSTAL                               VARCHAR2(5);
  TIERS_VILLE                                    VARCHAR2(27);
  TIERS_TEL                                      VARCHAR2(10);
  --retour
  LIBELLE_RETOUR                                 VARCHAR2(2) default '01';
  LIBELLE_RETOUR_ACTE                            VARCHAR2(2) default '01';
  MESSAGE_SUPP                                   VARCHAR2(50) default null;
  loc_ret_Tab_acte                               TAB_T_RET_ACTE ;
  TRAITEMENT                                     varchar2(100);
  V_NUM_DOSSIER                                  DOSSIER_SANTE.NUM_DOSSIER%TYPE;
  loc_fact_pec                                   dossier_sante.num_fact_pec%TYPE;
  loc_dat_fact_pec                               dossier_sante.date_fact_pec%TYPE;
  loc_dossier_pec                                dossier_sante.num_dossier_pec%TYPE;
  loc_dossier_porte                              dossier_sante.num_dossier_porte%TYPE;
  --info assure contrat
  loc_idadhesion                                 adhe_cntrt.idadhesion%TYPE;
  loc_etat_adhesion                              number default 0;
  loc_tr_etat_adhesion                           number default 0;
  loc_tr_etat_adhesion2                          varchar2(2);
  loc_numgar                                     contrat_ref.numgar%TYPE;
  loc_isColl                                     BOOLEAN;
  loc_tr_isColl                                  number default 0;
  loc_libelle                                    produit.libelle%TYPE;
  loc_dateEffet                                  adhe_cntrt.date_adhe%TYPE;
  loc_dateRes                                    adhe_cntrt.date_fin_adhe%TYPE;
  loc_numorg                                     contrat_ref.numorg%TYPE;
  loc_numporte                                   dossier_sante.numporte%TYPE;
  loc_refcie_cntrt                               contrat.refcie%TYPE;
  erreur_contrat                                 NUMBER :=0;
  --infos adhesions
  loc_etatAdhe                                   NUMBER :=0;
  erreur_adhesion                                NUMBER :=0;
  formule_sous1                                  adhesion.numfor%TYPE;
  --couverture
  loc_isCouvert                                  BOOLEAN:=FALSE;
  --crtl tp
  loc_isTP                                       BOOLEAN:=FALSE;
  --tiers
  v_code_specialite                              NUMBER(2);
  loc_numindivPS                                 individu.numindiv%TYPE;
  loc_patient                                   individu.numindiv%TYPE;

  V_etatCntrt                                    NUMBER(2);
  v_nat_dossier                                  NUMBER(1);
  loc_num_dossier                                dossier_sante.num_dossier%TYPE:=0;
  loc_refDomaine                                 VARCHAR2(20);

  msg_dossier                                    VARCHAR2(200);
  erreur_dossier                                 NUMBER :=0;

  --montant de la depense
  MONTANT_DEP                                    sinistre_sante.MTFRAIS%TYPE;
  MONTANT_RC                                     sinistre_sante.MTPREST_REEL%TYPE;
  MONTANT_RO                                     sinistre_sante.MTREMB%TYPE;
  --reste a charge = MT_FRAIS- RC - RO - AR
  MONTANT_RAC                                    NUMBER(8,2);
  QUANTITE                                       sinistre_sante.quantite%TYPE;
  MONTANT_AUTRE                                  sinistre_sante.AUTRB_DAUTRB%TYPE;

  erreur_calcul_devis                            NUMBER;
  O_msg_erreur_devis                             VARCHAR2(500);

 -- trans_O_codfrais                               SINISTRE_SANTE.codfrais%TYPE;
  trans_O_acte_err_code                          VARCHAR2(2);

  l_sid                                          NUMBER(8);
  loc_mtfrais_reel                               NUMBER:=0;
  loc_mtprest                                    NUMBER:=0;
  loc_mtprest_sup                                NUMBER:=0;

  loc_acteCouvert                                BOOLEAN;
  erreur_acte                                    NUMBER;
  loc_flag_oeil                                  NUMBER:=0;
  loc_flag_ctrl_assu                             NUMBER:=0;

  -- Declaration des exceptions
  exc_assure_ko                                  EXCEPTION;
  exc_contrat_suspendu                           EXCEPTION;
  exc_contrat_resilie                            EXCEPTION;
  exc_assure_ctrl_cvt                            EXCEPTION;
  exc_tiers_inconnu                              EXCEPTION;
  exc_assure_ctrl_tp                             EXCEPTION;
  exc_assure_ctrl_tp1                            EXCEPTION;


  --montant des suppléments verre ou monture
  loc_depense_sup                                sinistre_sante.MTFRAIS%TYPE;
  loc_rc_sup                                     sinistre_sante.MTPREST_REEL%TYPE;
  loc_ro_sup                                     sinistre_sante.MTREMB%TYPE;

  loc_cpt                                        NUMBER:=0;
  loc_quantite                                   NUMBER:=0;
  loc_sens                                       NUMBER:=NULL;
  loc_motif                                      NUMBER:=NULL;
  loc_tot_prest                                  NUMBER:=0;

  loc_prenom                                     individu.prenom%TYPE;

  v_deb NUMBER;
  v_delai NUMBER;

  P_TRAV_SAISIE   TRAV_SAISIE%ROWTYPE;
  loc_trav        TRAV_SAISIE%ROWTYPE;
  cpt_trav        NUMBER;
  loc_o_items     PK_FICHIER.TV_ITEMS;    -- Tableau permettant de récupérer les numéros de dents
  loc_list_dent   VARCHAR2(100);
  loc_blocage     NUMBER;
  l_top_derog     VARCHAR2(1);
  l_derog         VARCHAR2(10);
  loc_nat_acte    NUMBER;

BEGIN
  --sauvegarde dans un fichier txt
  --pour la phase de test
  --NOM_FIC := 'FLUX_CAL_' || TO_CHAR(SYSTIMESTAMP,'YYYYDDMMHH24MISSFFFF') || '.txt';
  --FILEHANDLER := UTL_FILE.FOPEN('REP_SANTECLAIR', NOM_FIC, 'W');
  --UTL_FILE.PUTF(FILEHANDLER, substr(P_TEMP_FLUX,1,3400));
  --UTL_FILE.PUTF(FILEHANDLER, P_TEMP_FLUX);
  --UTL_FILE.FCLOSE(FILEHANDLER);
  P_INS_journal(2,'DEBUT du traitement du service CALCUL SANTECLAIR');

   -- Initialisation XML réponse
  v_deb:=DBMS_UTILITY.GET_TIME;

  L_FLUX_SC := LENGTH(P_FLUX_SC);
  P_INS_journal(2,'Historisation du flux de calcul');
  --insertion flux aller dabs table de stockage
  --insertion trace flux aller dans table flux
  v_id_flux := F_INSERT_FLUX(21,'FLUX_CALC_SC');

  INSERT INTO HISTO_FLUX_WS_SC (ID_FLUX_SC,TYPE_FLUX,DATE_FLUX,FLUX_ALLER,FLUX_RETOUR,LONG_FLUX_IN,LONG_FLUX_OUT)
  VALUES (v_id_flux,2,sysdate,P_FLUX_SC,null,L_FLUX_SC,null);

  --récupération du l_sid
  select to_char(sys_context('userenv', 'sid')) into l_sid from dual;

  P_INS_journal(2,v_id_flux||' Récupération des informations du flux aller');
  --FLUX ALLER
  --********************************************************--
  --Identification Compagnie
  IDENT_COMPAGNIE := F_DECOUPE(P_FLUX_SC,0,8);
  --Identifiant supplémentaire
  IDENT_SUPP := F_DECOUPE(P_FLUX_SC,9,2);
  --N° de contrat/adherent
  NUMGAR := F_DECOUPE(P_FLUX_SC,11,26);
  --Date de naissance du patient
  DATENAIS := F_DECOUPE(P_FLUX_SC,43,8);
  -- Prénom du patient
  loc_prenom := F_DECOUPE(P_FLUX_SC,51,32);
  --Type de monnaie
  TYPE_MONNAIE := F_DECOUPE(P_FLUX_SC,163,1);
  --Type d’échange
  TYPE_ECAHNGE := F_DECOUPE(P_FLUX_SC,164,1);
  P_INS_journal(2,'TYPE_ECAHNGE:' || TYPE_ECAHNGE);
  --Code Type de dossier
  CODE_TYPE_DOSSIER := F_DECOUPE(P_FLUX_SC,165,1);
  P_INS_journal(2,'CODE_TYPE_DOSSIER:' || CODE_TYPE_DOSSIER);
  --Code action
  CODE_ACTION := F_DECOUPE(P_FLUX_SC,166,1);
  P_INS_journal(2,'CODE_ACTION:' || CODE_ACTION);
  --Date de fin de validité
  DATE_FIN_VAL := F_DECOUPE(P_FLUX_SC,167,8);
  --N° de PEC
  NUM_PEC := F_DECOUPE(P_FLUX_SC,175,16);
  --Mode Test (T ou R)
  MODE_TEST := F_DECOUPE(P_FLUX_SC,211,1);
  P_INS_journal(2,'MODE_TEST:' || MODE_TEST);
  --RKO WS RAC DEROG RECUPERATION DU TOP DEROGATOIRE
  l_top_derog := F_DECOUPE(P_FLUX_SC,272,1);
  P_INS_journal(1,'l_top_derog:' || l_top_derog);

  --tableau des actes
  cpt_acte := 0;

  --recuperation tableau des actes 32*200
  FOR compteur IN 1 .. 32 LOOP
    loc_Tab_acte(compteur).TYPE_ENREG   := F_DECOUPE(P_FLUX_SC,281,3,cpt_acte);
    loc_Tab_acte(compteur).DATE_SOINS   := F_DECOUPE(P_FLUX_SC,300,6,cpt_acte);
    loc_Tab_acte(compteur).PRIX_ACTE    := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,312,11,cpt_acte),6,5);
    loc_Tab_acte(compteur).BASE_REMB    := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,323,8,cpt_acte),6,2);
    loc_Tab_acte(compteur).TAUX_REMB    := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,331,3,cpt_acte),3,0);
    loc_Tab_acte(compteur).MONT_REMB    := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,334,8,cpt_acte),6,2);
    loc_Tab_acte(compteur).NATURE_PREST := F_DECOUPE(P_FLUX_SC,343,5,cpt_acte);
    loc_Tab_acte(compteur).QUANT_ACTE   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,348,3,cpt_acte),3,0);
    loc_Tab_acte(compteur).COEFF_ACTE   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,351,5,cpt_acte),3,2);
    loc_Tab_acte(compteur).DENOM_ACTE   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,356,3,cpt_acte),3,0);
    loc_Tab_acte(compteur).MONTANT_DEP  := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,359,8,cpt_acte),6,2);
    loc_Tab_acte(compteur).NB_DENT      := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,372,2,cpt_acte),3,0);
    loc_Tab_acte(compteur).FAMILLE_LENT := F_DECOUPE(P_FLUX_SC,379,1,cpt_acte);
    loc_Tab_acte(compteur).TYPE_RENOU_LENT := F_DECOUPE(P_FLUX_SC,380,2,cpt_acte);
    loc_Tab_acte(compteur).TYPE_LENT     := F_DECOUPE(P_FLUX_SC,382,1,cpt_acte);
    loc_Tab_acte(compteur).MONT_PART_COMP := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,391,8,cpt_acte),6,2);
    IF TRIM(loc_Tab_acte(compteur).NATURE_PREST) IS NOT NULL THEN
      P_INS_journal(2,'loc_Tab_acte(compteur).NATURE_PREST:' || compteur || ':' || loc_Tab_acte(compteur).NATURE_PREST );
      P_INS_journal(2,'loc_Tab_acte(compteur).PRIX_ACTE:' || compteur || ':' || loc_Tab_acte(compteur).PRIX_ACTE );
      P_INS_journal(2,'loc_Tab_acte(compteur).BASE_REMB:' || compteur || ':' || loc_Tab_acte(compteur).BASE_REMB );
      P_INS_journal(2,'loc_Tab_acte(compteur).TAUX_REMB:' || compteur || ':' || loc_Tab_acte(compteur).TAUX_REMB );
      P_INS_journal(2,'loc_Tab_acte(compteur).MONT_REMB:' || compteur || ':' || loc_Tab_acte(compteur).MONT_REMB );
      P_INS_journal(2,'loc_Tab_acte(compteur).QUANT_ACTE:' || compteur || ':' || loc_Tab_acte(compteur).QUANT_ACTE );
      P_INS_journal(2,'loc_Tab_acte(compteur).COEFF_ACTE:' || compteur || ':' || loc_Tab_acte(compteur).COEFF_ACTE );
      P_INS_journal(2,'loc_Tab_acte(compteur).DENOM_ACTE:' || compteur || ':' || loc_Tab_acte(compteur).DENOM_ACTE );
      P_INS_journal(2,'loc_Tab_acte(compteur).NB_DENT:' || compteur || ':' || loc_Tab_acte(compteur).NB_DENT );
      P_INS_journal(2,'loc_Tab_acte(compteur).MONTANT_DEP:' || compteur || ':' || loc_Tab_acte(compteur).MONTANT_DEP );
      P_INS_journal(2,'loc_Tab_acte(compteur).MONT_PART_COMP:' || compteur || ':' || loc_Tab_acte(compteur).MONT_PART_COMP );
    END IF;
    loc_Tab_acte(compteur).CODE_LPP      := F_DECOUPE(P_FLUX_SC,399,7,cpt_acte);
    loc_Tab_acte(compteur).CODE_CCAM     := F_DECOUPE(P_FLUX_SC,406,7,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT1     := F_DECOUPE(P_FLUX_SC,413,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT2     := F_DECOUPE(P_FLUX_SC,415,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT3     := F_DECOUPE(P_FLUX_SC,417,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT4     := F_DECOUPE(P_FLUX_SC,419,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT5     := F_DECOUPE(P_FLUX_SC,421,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT6     := F_DECOUPE(P_FLUX_SC,423,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT7     := F_DECOUPE(P_FLUX_SC,425,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT8     := F_DECOUPE(P_FLUX_SC,427,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT9     := F_DECOUPE(P_FLUX_SC,429,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT10    := F_DECOUPE(P_FLUX_SC,431,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT11    := F_DECOUPE(P_FLUX_SC,433,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT12    := F_DECOUPE(P_FLUX_SC,435,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT13    := F_DECOUPE(P_FLUX_SC,437,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT14    := F_DECOUPE(P_FLUX_SC,439,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT15    := F_DECOUPE(P_FLUX_SC,441,2,cpt_acte);
    loc_Tab_acte(compteur).LOC_DENT16    := F_DECOUPE(P_FLUX_SC,443,2,cpt_acte);
    --les informations sur les yeux de l'aussre sont ajouté au tableau des actes
    --sur le premier acte seulement.
    /* IF compteur = 1 THEN*/
    loc_Tab_acte(compteur).OD_SPHERE     := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,212,5),3,2);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,212,5,cpt_acte),3,2);      --NUMBER(4,2),
    loc_Tab_acte(compteur).OD_CYLINDRE   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,217,5),3,2); -- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,217,5,cpt_acte),3,2);      --NUMBER(4,2),
    --P_INS_journal(2,' sphere 2:' || MODE_TEST);
    loc_Tab_acte(compteur).OD_AXE        := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,222,3),3,0);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,222,3,cpt_acte),3,0);      --NUMBER(3),
    --  P_INS_journal(2,' sphere 3:' || MODE_TEST);
    loc_Tab_acte(compteur).OD_ADDITION   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,225,4),2,2);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,225,4,cpt_acte),2,2);      --NUMBER(4,2),
    --  P_INS_journal(2,' sphere 4:' || MODE_TEST);
    loc_Tab_acte(compteur).OG_SPHERE     := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,229,5),3,2); --  F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,229,5,cpt_acte),3,2);          --NUMBER(4,2),
    --   P_INS_journal(2,' sphere 5:' || MODE_TEST);
    loc_Tab_acte(compteur).OG_CYLINDRE   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,234,5),3,2); -- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,234,5,cpt_acte),3,2);          --NUMBER(4,2),
    --   P_INS_journal(2,' sphere 6:' || MODE_TEST);
    loc_Tab_acte(compteur).OG_AXE        := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,239,3),3,0); -- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,239,3,cpt_acte),3,0);          --NUMBER(3),
    loc_Tab_acte(compteur).OG_ADDITION   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,242,4),2,2);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,242,4,cpt_acte),2,2);          --NUMBER(4,2),
    loc_Tab_acte(compteur).EQUI_2_OD_SPHERE   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,246,5),3,2);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,246,5,cpt_acte),3,2);     --NUMBER(4,2),
    loc_Tab_acte(compteur).EQUI_2_OD_CYLLIN   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,251,5),3,2);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,251,5,cpt_acte),3,2);     --NUMBER(4,2),
    loc_Tab_acte(compteur).EQUI_2_OD_AXE      := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,256,3),3,0);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,256,3,cpt_acte),3,0);     --NUMBER(3),
    loc_Tab_acte(compteur).EQUI_2_OG_SPHERE   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,259,5),3,2);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,259,5,cpt_acte),3,2);     --NUMBER(4,2),
    loc_Tab_acte(compteur).EQUI_2_OG_CYLLIN   := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,264,5),3,2);-- F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,264,5,cpt_acte),3,2);     --NUMBER(4,2),
    loc_Tab_acte(compteur).EQUI_2_OG_AXE      := F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,269,3),3,0);--  F_FORMAT_NUMBER(F_DECOUPE(P_FLUX_SC,269,3,cpt_acte),3,0);     --NUMBER(3),
    loc_Tab_acte(compteur).CASSE              := F_DECOUPE(P_FLUX_SC,272,1);  -- F_DECOUPE(P_FLUX_SC,272,1,cpt_acte);                          --VARCHAR2(1),
    loc_Tab_acte(compteur).CESSITE            := F_DECOUPE(P_FLUX_SC,273,1); -- F_DECOUPE(P_FLUX_SC,273,1,cpt_acte);                          --VARCHAR2(1),
    loc_Tab_acte(compteur).NATURE_EQUI_OPT    := F_DECOUPE(P_FLUX_SC,274,1); -- F_DECOUPE(P_FLUX_SC,274,1,cpt_acte);                         --VARCHAR2(1)
    --     P_INS_journal(2,'apres sphere:' || MODE_TEST);
    /*    ELSE
    loc_Tab_acte(compteur).OD_SPHERE     :=  null;
    loc_Tab_acte(compteur).OD_CYLINDRE   :=  null;
    loc_Tab_acte(compteur).OD_AXE        :=  null;
    loc_Tab_acte(compteur).OD_ADDITION   :=  null;
    loc_Tab_acte(compteur).OG_SPHERE     :=  null;
    loc_Tab_acte(compteur).OG_CYLINDRE   :=  null;
    loc_Tab_acte(compteur).OG_AXE        :=  null;
    loc_Tab_acte(compteur).OG_ADDITION   :=  null;
    loc_Tab_acte(compteur).EQUI_2_OD_SPHERE   :=  null;
    loc_Tab_acte(compteur).EQUI_2_OD_CYLLIN   :=  null;
    loc_Tab_acte(compteur).EQUI_2_OD_AXE      :=  null;
    loc_Tab_acte(compteur).EQUI_2_OG_SPHERE   :=  null;
    loc_Tab_acte(compteur).EQUI_2_OG_CYLLIN   :=  null;
    loc_Tab_acte(compteur).EQUI_2_OG_AXE      :=  null;
    loc_Tab_acte(compteur).CASSE              :=  null;
    loc_Tab_acte(compteur).CESSITE            :=  null;
    loc_Tab_acte(compteur).NATURE_EQUI_OPT    :=  null;
    END IF;*/
    cpt_acte := cpt_acte + 200;
  END LOOP;
  --fin recuperation des actes
  TIERS_ADELI := F_DECOUPE(P_FLUX_SC,6681,9);
  TIERS_SPECIALITE := F_DECOUPE(P_FLUX_SC,6690,2);
  TIERS_RAISON := TRIM(F_DECOUPE(P_FLUX_SC,6692,32));
  TIERS_NOM := TRIM(F_DECOUPE(P_FLUX_SC,6727,25));
  IF TIERS_RAISON is null THEN
   TIERS_RAISON := TIERS_NOM;
  END IF;
  --P_INS_journal(2,' TIERS_RAISON: ' || TIERS_RAISON);
  --P_INS_journal(2,' TIERS_NOM: ' || TIERS_NOM);
  TIERS_ADRESSE := F_DECOUPE(P_FLUX_SC,6767,32);
  --P_INS_journal(2,' TIERS_ADRESSE: ' || TIERS_ADRESSE);
  TIERS_CODEPOSTAL := F_DECOUPE(P_FLUX_SC,6863,5);
  TIERS_VILLE := F_DECOUPE(P_FLUX_SC,6868,27);
  TIERS_TEL := F_DECOUPE(P_FLUX_SC,6895,10);

  -- FIN FLUX ALLER
  --********************************************************--

  -- selection de l ayant droit selectionné par le PS
    BEGIN

      select numindiv INTO loc_patient
      from individu
      where numassu=NUMGAR
      and trunc(datnais)=e2d(DATENAIS)
      AND prenom = nvl(trim(loc_prenom),prenom);-- JBO 18/11/2014 : Gestion d'un jumeau

    EXCEPTION
      WHEN OTHERS THEN
        LIBELLE_RETOUR := '15'; -- ce bénéficiaire n a pas droit au service
    END;


  P_INS_journal(2,v_id_flux||' CODE_TYPE_DOSSIER: ' || CODE_TYPE_DOSSIER);

  --TRAITEMENT
  --********************************************************--
  --DEVIS
  IF CODE_TYPE_DOSSIER = 'D' THEN
    TRAITEMENT := 'D';
  --PRISE EN CHARGE
  ELSIF CODE_TYPE_DOSSIER = 'P' THEN
    --CALCUL
    IF CODE_ACTION='C' THEN
      IF MODE_TEST = 'T' THEN
        TRAITEMENT := 'PCT';
        --LIBELLE_RETOUR := '00';
        --MESSAGE_SUPP := 'TRAITEMENT NON PRÉVU P(PEC) C(CALCUL) T(TEST)';
      ELSE
        TRAITEMENT := 'PCR';
      END IF;
    --ANNULATION
    ELSIF CODE_ACTION='A' THEN
      IF MODE_TEST = 'T' THEN
        LIBELLE_RETOUR := '00';
        MESSAGE_SUPP := 'TRAITEMENT NON PRÉVU P(PEC) A(ANNULATION) T(TEST)';
      ELSE
        TRAITEMENT := 'PAR';
      END IF;
    --PLAFOND
    ELSIF CODE_ACTION='P' THEN
      IF MODE_TEST = 'T' THEN
        LIBELLE_RETOUR := '00';
        MESSAGE_SUPP := 'TRAITEMENT NON PRÉVU P(PEC) P(PLAFONT) T(TEST)';
      ELSE
        TRAITEMENT := 'PPR';
        LIBELLE_RETOUR := '00';
        MESSAGE_SUPP := 'TRAITEMENT NON PRÉVU P(PEC) P(PLAFONT) R(RÉEL)';
      END IF;
    END IF;
  --EVALUATION DU RBST RC
  ELSIF CODE_TYPE_DOSSIER = 'E' THEN
    TRAITEMENT := 'PPT';
    LIBELLE_RETOUR := '00';
    MESSAGE_SUPP := 'TRAITEMENT EVALUATION DU RBST RC NON PRÉVU';
  END IF;

  --on trouve le type de flux en ragardant le premier acte du tableau des actes
  v_nat_dossier := F_CODE_TYPE_ACTE(loc_Tab_acte);
  -- Determination du nombre de mois de la validité de la PEC en fonction de la nature du dossier
  IF v_nat_dossier = 2 THEN --optique
     v_code_specialite := 23;
     loc_sens:=F_SENS_LIBELLE('HISTO_D1', 4);
     loc_motif:=4;
  ELSIF v_nat_dossier =3 THEN  -- dentaire
     v_code_specialite := 28;
     loc_sens:=F_SENS_LIBELLE('HISTO_D1', 5);
     loc_motif:=5;
  ELSIF v_nat_dossier = 4 THEN --auditif
     v_code_specialite := 22;
     loc_sens:=F_SENS_LIBELLE('HISTO_D1', 7);
     loc_motif:=7;
  ELSIF v_nat_dossier =5 THEN -- /orthodontie
     v_code_specialite := 28;
     loc_sens:=F_SENS_LIBELLE('HISTO_D1', 6);
     loc_motif:=6;
  END IF;
  P_INS_journal(2,v_id_flux|| ' v_nat_dossier <' || v_nat_dossier||'>, nombre de mois de validité de PEC<' || loc_sens||'>');

  P_INS_journal(2,v_id_flux||' TRAITEMENT :' || TRAITEMENT);

  --**************************************************************************
  ----------------------- DEBUT ANNULATION -----------------------------------
  ----------------------- DEBUT ANNULATION -----------------------------------
  ----------------------- DEBUT ANNULATION -----------------------------------
  ----------------------- DEBUT ANNULATION -----------------------------------
  --**************************************************************************
  IF TRAITEMENT = 'PAR' THEN
     --traitement de l'annulation du dossier sante avec cle PEC sante clair

     --on trouve la numero de dossier(de PEC liquidé ou pas) arthus avec la cle  PEC sante clair NUM_PEC
     V_NUM_DOSSIER := 0;
     V_NUM_DOSSIER := F_FIND_DOSSIER(NUM_PEC);

     P_INS_journal(2,v_id_flux||' V_NUM_DOSSIER:' || V_NUM_DOSSIER);
     IF V_NUM_DOSSIER = 0 THEN
       LIBELLE_RETOUR := '21';
     ELSE
       --on teste si le dossier_sante n'est pas fermé
       -- au moins 1 sinistre_sante annulé
       IF F_ETAT_DOSSIER_SANTE(V_NUM_DOSSIER,sysdate,1) = 1  OR PK_CTRL_TP.F_FIND_SNTR_ANNUL(V_NUM_DOSSIER) = 1 THEN
          LIBELLE_RETOUR := '29';
       -- dossier en cours de facturation ou dejà liquidé
       ELSIF F_ETAT_DOSSIER_SANTE(V_NUM_DOSSIER,sysdate,1) = 0 AND F_ETAT_DOSSIER_SANTE(V_NUM_DOSSIER,sysdate,2) IN (6,4) THEN
        -- PK_CTRL_TP.P_INFO_DOSSIER(V_NUM_DOSSIER, loc_fact_pec, loc_dat_fact_pec, loc_dossier_pec, loc_dossier_porte);
        -- IF loc_dossier_pec IS NULL THEN
           LIBELLE_RETOUR := '23';
       --  END IF;
       -- au moins 1 sinistre du dossier est décompté
       ELSIF PK_CTRL_TP.F_FIND_SNTR_DCPT(V_NUM_DOSSIER) = 1 THEN
         LIBELLE_RETOUR := '23';
       END IF;
     END IF;
     P_INS_journal(2,v_id_flux||' LIBELLE_RETOUR:' || LIBELLE_RETOUR);
     -- Annulation du dossier
     IF LIBELLE_RETOUR = '01' THEN
        PK_CTRL_TP.P_ANNUL_DOSSIER(V_NUM_DOSSIER,1);
        P_INS_journal(2,v_id_flux||' PK_CTRL_TP.P_ANNUL_DOSSIER OK:' );
        --mise à jour de la reférence externe de l'individu
        --Mantis 4719 SDA/JBO  patient et non assure principal
        --recuperation du numassu par le numero de dossier dans dossier sante
        select numindiv into loc_patient from DOSSIER_SANTE where NUM_DOSSIER = V_NUM_DOSSIER;

        PK_CTRL_TP.P_MAJ_REF_EXTERNE(
           P_numindiv    => loc_patient,
           P_domaine     => '',
           P_num_dossier => V_NUM_DOSSIER,
           P_tiers       => 'SC',
           P_mnemo       => 'DOMGEREP');

        P_INS_journal(2,v_id_flux||' PK_CTRL_TP.P_MAJ_REF_EXTERNE OK:' );
     END IF;
     loc_ret_Tab_acte := F_TAB_ACTE_ERREUR(loc_Tab_acte,null,TRAITEMENT);
  END IF;
  --**************************************************************************
  ----------------------- FIN ANNULATION -------------------------------------
  ----------------------- FIN ANNULATION -------------------------------------
  ----------------------- FIN ANNULATION -------------------------------------
  ----------------------- FIN ANNULATION -------------------------------------
  --**************************************************************************

  BEGIN

  --**************************************************************************
  ----------------------- CONTROLES DROITS ASSURE ----------------------------
  ----------------------- CONTROLES DROITS ASSURE ----------------------------
  ----------------------- CONTROLES DROITS ASSURE ----------------------------
  ----------------------- CONTROLES DROITS ASSURE ----------------------------
  --**************************************************************************
    IF TRAITEMENT = 'PCR' OR  TRAITEMENT = 'D'  OR TRAITEMENT = 'PCT' THEN
      P_INS_journal(2,v_id_flux||' TRAITEMENT PCR:' || TRAITEMENT || ',LIBELLE_RETOUR:' || LIBELLE_RETOUR);
      --traitement de la prise en charge Mode réel
      --création d'un dossier sante si n'existe pas avec cle PEC sante clair
      --controle assure/contrat/adehesion
      --P_INS_journal(2,v_id_flux||' numero individu:'||to_char(NUMGAR));
      PK_CTRL_TP.P_FIND_CONTRAT_BY_ASSU(
          NUMGAR,
          NUMGAR,
          g_porte,
          loc_idadhesion,
          loc_numgar,
          loc_isColl,
          loc_libelle,
          loc_dateEffet,
          loc_dateRes,
          loc_numorg,
          loc_numporte,
          erreur_contrat);
      P_INS_journal(2,'erreur_contrat:'||erreur_contrat);

      IF erreur_contrat = 1 THEN
         LIBELLE_RETOUR := '00';
         MESSAGE_SUPP := 'ECHEC, N DE CONTRAT INCONNU/ N INTERNE INCONNU';
         raise exc_assure_ko;
      ELSIF erreur_contrat = 2 THEN
         LIBELLE_RETOUR := '17';
         MESSAGE_SUPP := 'PORTE NON OUVERTE SUR LE CONTRAT';
         raise exc_tiers_inconnu;
      ELSIF erreur_contrat <> 0 THEN
         LIBELLE_RETOUR := '00';
         MESSAGE_SUPP := 'ERREUR INCONNUE';
         raise exc_assure_ko;
      END IF;
      -------------------------------------------------------------------------
      --controle contrat
      -------------------------------------------------------------------------
      IF erreur_contrat = 0 THEN
        P_INS_journal(2,v_id_flux||' Controle contrat:'||to_char(loc_numgar));
        V_etatCntrt := PK_CTRL_TP.F_CTRL_CNTRT(loc_numgar,SYSDATE);
        IF V_etatCntrt = 3 THEN
          LIBELLE_RETOUR := '06';
          MESSAGE_SUPP := 'ERREUR INCONNUE';
          raise exc_contrat_resilie;
        ELSIF V_etatCntrt <> 1 THEN
          LIBELLE_RETOUR := '05';
          raise exc_contrat_suspendu;
        END IF;
        P_INS_journal(2,v_id_flux||' Etat contrat:'||to_char(V_etatCntrt));
      END IF;
      -------------------------------------------------------------------------
      --controle adhesion
      -------------------------------------------------------------------------
      IF LIBELLE_RETOUR = '01' THEN
        P_INS_journal(2,v_id_flux||' controle adhesion:'||to_char(loc_idadhesion));
         PK_CTRL_TP.P_CTRL_ADHESION (loc_idadhesion,
                            loc_numgar,
                            null,
                            false,
                            loc_etatAdhe,
                            erreur_adhesion);
         IF erreur_adhesion IN (7,8,9) THEN
           LIBELLE_RETOUR := '06';
           raise exc_contrat_resilie;
         ELSIF erreur_adhesion <> 0 THEN
           LIBELLE_RETOUR := '05';
           raise exc_contrat_suspendu;
         END IF;
        P_INS_journal(2,v_id_flux||' etat adhesion:'||to_char(loc_etatAdhe));
      END IF;
      -------------------------------------------------------------------------
      --ctrl_couverture
      -------------------------------------------------------------------------
      IF LIBELLE_RETOUR = '01' THEN
        --SDA Mantis 4752
        --loc_isCouvert := PK_CTRL_TP.F_CTRL_couverture(NUMGAR,1,'C',SYSDATE);
        loc_isCouvert := PK_CTRL_TP.F_CTRL_couverture(loc_patient,1,'C',SYSDATE);
        IF NOT loc_isCouvert THEN
          LIBELLE_RETOUR := '07';
          raise exc_assure_ctrl_cvt;
        END IF;
        P_INS_journal(2,v_id_flux||' ctrl_couverture OK');
      END IF;
      -------------------------------------------------------------------------
      -- Ctrl de droit TP du bénéficaire
      -------------------------------------------------------------------------
      IF LIBELLE_RETOUR = '01' THEN
        --SDA Mantis 4752
        --loc_isTP := PK_CTRL_TP.F_CTRL_rang(NUMGAR,loc_idadhesion,1,'C',sysdate);
        loc_isTP := PK_CTRL_TP.F_CTRL_rang(loc_patient,loc_idadhesion,1,'C',sysdate);

        IF NOT loc_isTP THEN
          LIBELLE_RETOUR := '15';
          raise exc_assure_ctrl_tp;
        END IF;
        P_INS_journal(2,v_id_flux||' Ctrl de droit TP du bénéficaire OK');
      END IF;

    END IF;


  EXCEPTION
    WHEN exc_assure_ko THEN
      loc_ret_Tab_acte := F_TAB_ACTE_ERREUR(loc_Tab_acte,'00',TRAITEMENT); -- 00 retour indeterminee
      P_INS_journal(2,v_id_flux||' 00 retour indeterminee');
      loc_flag_ctrl_assu:=1; --  permettant de ne pas faire le devis ou la PEC
    WHEN exc_contrat_suspendu THEN
      loc_ret_Tab_acte := F_TAB_ACTE_ERREUR(loc_Tab_acte,'04',TRAITEMENT); -- 04 pour les actes : pas de remboursement possible
      P_INS_journal(2,v_id_flux||' 04 pour les actes : pas de remboursement possible, contrat/adhesion suspendu ');
      loc_flag_ctrl_assu:=1; --  permettant de ne pas faire le devis ou la PEC
    WHEN exc_contrat_resilie THEN
      loc_ret_Tab_acte := F_TAB_ACTE_ERREUR(loc_Tab_acte,'04',TRAITEMENT); -- 04 pour les actes : pas de remboursement possible
      P_INS_journal(2,v_id_flux||' 04 pour les actes : pas de remboursement possible, contrat/adhesion resilie ');
      loc_flag_ctrl_assu:=1; --  permettant de ne pas faire le devis ou la PEC
    WHEN exc_assure_ctrl_cvt THEN
      loc_ret_Tab_acte := F_TAB_ACTE_ERREUR(loc_Tab_acte,'04',TRAITEMENT); -- 04 pour les actes : pas de remboursement possible
      P_INS_journal(2,v_id_flux||' 04 pour les actes : pas de remboursement possible, le patient n est pas couvert ');
      loc_flag_ctrl_assu:=1; --  permettant de ne pas faire le devis ou la PEC
    WHEN exc_tiers_inconnu THEN
      loc_ret_Tab_acte := F_TAB_ACTE_ERREUR(loc_Tab_acte,'04',TRAITEMENT); -- 04 pour les actes : pas de remboursement possible
      P_INS_journal(2,v_id_flux||' 04 pour les actes : pas de remboursement possible, contrat/adhesion resilie ');
      loc_flag_ctrl_assu:=1; --  permettant de ne pas faire le devis ou la PEC
    WHEN exc_assure_ctrl_tp THEN
      loc_ret_Tab_acte := F_TAB_ACTE_ERREUR(loc_Tab_acte,'04',TRAITEMENT); -- 04 pour les actes : pas de remboursement possible
      P_INS_journal(2,v_id_flux||' 04 pour les actes : pas de remboursement possible, pas de droit au TP');
      loc_flag_ctrl_assu:=1; --  permettant de ne pas faire le devis ou la PEC
  END;
  --**************************************************************************
  ----------------------- FIN CONTROLES DROITS ASSURE ------------------------
  ----------------------- FIN CONTROLES DROITS ASSURE ------------------------
  ----------------------- FIN CONTROLES DROITS ASSURE ------------------------
  ----------------------- FIN CONTROLES DROITS ASSURE ------------------------
  --**************************************************************************

  IF loc_flag_ctrl_assu = 0 THEN -- controle de droits de l assure OK


    BEGIN
      --**************************************************************************
      ----------------------- DEBUT PEC ------------------------------------------
      ----------------------- DEBUT PEC ------------------------------------------
      ----------------------- DEBUT PEC ------------------------------------------
      ----------------------- DEBUT PEC ------------------------------------------
      --**************************************************************************
      --initialisation de l'objet
      P_TRAV_SAISIE.SID:= l_sid;
      BEGIN
        SELECT numutil INTO P_TRAV_SAISIE.USERNAME from porte_param where numporte=g_porte;
      EXCEPTION
       WHEN OTHERS THEN
       SELECT F_NUMUTIL INTO P_TRAV_SAISIE.USERNAME FROM DUAL;
      END;
      P_TRAV_SAISIE.RESEAU:=NVL(F_SENS_LIBELLE('PORTE',g_porte),g_porte);  -- réseau de soins
      IF TRAITEMENT = 'PCR' THEN
        P_INS_journal(2,v_id_flux||' Traitement de la PEC');
        --ctrl PS
        IF LIBELLE_RETOUR = '01' THEN

          -- selection de l ayant droit selectionné par le PS
          --SDA Mantis 4752 remonte plus haut
          /*BEGIN

            select numindiv INTO loc_patient
            from individu
            where numassu=NUMGAR
            and trunc(datnais)=e2d(DATENAIS)
            AND prenom = nvl(trim(loc_prenom),prenom);-- JBO 18/11/2014 : Gestion d'un jumeau

          EXCEPTION
            WHEN OTHERS THEN
              LIBELLE_RETOUR := '15'; -- ce bénéficiaire n a pas droit au service
          END;*/

          IF TIERS_RAISON is null THEN
           --nom dans la table individu ne peut-être null;
           TIERS_RAISON := ' ';
          END IF;
          --MAntis 4711 SDA/JBO ajout adresse
          PK_CTRL_TP.P_FIND_TIERS(
                  P_NNI=> TIERS_ADELI,
                  P_typePS => v_code_specialite,
                  P_raison=> SUBSTR(UPPER(TIERS_RAISON),0,30),
                  P_ad1 => null,
                  P_ad2 => null,
                  P_ad3 => TRIM(TIERS_ADRESSE),
                  P_ad4 => null,
                  P_ad5 => null,
                  P_cp => TIERS_CODEPOSTAL,
                  P_ville => TRIM(TIERS_VILLE),
                  P_tel=>TIERS_TEL,
                  P_mail=> null,
                  O_numindivPS => loc_numindivPS);
          P_INS_journal(2,v_id_flux||' FIN ctrl PS, loc_numindivPS:'||to_char(loc_numindivPS));
        ELSE
          LIBELLE_RETOUR :=LIBELLE_RETOUR ; -- Afin de gérer le else non gérér auparavant
        END IF;
        --creation dossier sante
        IF LIBELLE_RETOUR = '01' THEN
          P_INS_journal(2,'DEB creation dossier sante');
          PK_CTRL_TP.P_INS_DOSSIER_SANTE( P_ref         => NUM_PEC,
                                          P_numindiv    => loc_patient,
                                          P_PS          => loc_numindivPS,
                                          P_numassu     => f_numassu(NUMGAR,loc_idadhesion),
                                          P_numporte    => g_porte,
                                          P_natdoss     => v_nat_dossier,
                                          P_typedoss    => 4, --dossier de prise en charge
                                          P_num_dossier_porte => NUM_PEC,--loc_numdossierPorte, --> av voir si c est le bon numéro
                                          O_num_dossier => loc_num_dossier);

          P_INS_journal(2,v_id_flux||' loc_num_dossier:' || loc_num_dossier);

          IF loc_num_dossier = 0 THEN
             LIBELLE_RETOUR := '20';
             loc_ret_Tab_acte := F_TAB_ACTE_ERREUR(loc_Tab_acte,'28');
          ELSE
             LIBELLE_RETOUR := '01';
          END IF;

          -- mise à jour de la reférence externe de l'individu
          loc_refDomaine :=F_get_transco('SC','DOMGEREP',v_nat_dossier);

          IF LIBELLE_RETOUR = '01' THEN
             --loc_patient mantis 4719
             --Mantis 4719 SDA/JBO  patient et non assure principal
             PK_CTRL_TP.P_MAJ_REF_EXTERNE(
                  P_numindiv    => loc_patient,
                  P_domaine     => loc_refDomaine,
                  P_tiers       => 'SC',
                  P_mnemo       => 'DOMGEREP');


              -- Historisation du dossier créé en cours
             PK_CTRL_TP.P_INS_HISTO_DOSSIER(
                      P_num_dossier => loc_num_dossier,
                      P_etat        => 0,
                      P_motif       => 0
                      );

             -- Historisation du dossier avec la date de peremption
             PK_CTRL_TP.P_INS_HISTO_DOSSIER(
                      P_num_dossier => loc_num_dossier,
                      P_etat        => 1,
                      P_motif       => loc_motif, -- MNEMO HISTO_D1
                      P_date        => ADD_MONTHS( SYSDATE, loc_sens ));

          END IF;
          P_INS_journal(2,v_id_flux||' FIN creation dossier sante');

          IF LIBELLE_RETOUR = '01' THEN

            --calcut des actes
            loc_flag_oeil:=0;
            P_INS_journal(2,v_id_flux||' Gestion des sinistre_sante');
            FOR compteur IN 1 .. 32 LOOP
              IF loc_Tab_acte(compteur).NATURE_PREST is not null THEN
                P_INS_journal(2,'NATURE_PREST' || loc_Tab_acte(compteur).NATURE_PREST);
                --transcodification de l'acte
                loc_Tab_acte(compteur).codfrais := null;
                loc_blocage:=NULL;

                formule_sous1 := F_FORMULE_SOUSCRITE(loc_idadhesion,loc_patient);
                P_INS_journal(2,v_id_flux||' formule_sous1:' || formule_sous1);
                /*loc_temp_Tab_acte :=loc_tab_empty;
                loc_temp_Tab_acte(1):= loc_Tab_acte(compteur);*/
                IF TRIM(loc_Tab_acte(compteur).NATURE_PREST) IS NOT NULL THEN
                  IF v_nat_dossier = 2 THEN
                    -- A noter les caractéristiques verres sont portées par le 1er verre uniquement
                    IF NVL(loc_Tab_acte(compteur).OD_SPHERE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur).OD_CYLINDRE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur).OD_AXE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur).OD_ADDITION,0) <> 0
                    THEN
                      --IF TRIM(loc_Tab_acte(compteur).NATURE_PREST) NOT IN ('VSU','MSU') THEN -- permet d exclure les suplléments RKO RAC OPTIQUE gestion supplements
                        loc_flag_oeil:=loc_flag_oeil+1; -- permet de savoir si on a traité l oeil droit
                       --END IF;
                    END IF;

                    P_TRANSCO_CODFRAIS_OPTIQUE(
                                    P_numfor            => formule_sous1
                                  , P_flag_oeil         => loc_flag_oeil
                                  , P_acte              => loc_Tab_acte(compteur)
                                  , O_codfrais          =>loc_Tab_acte(compteur).codfrais
                                  , O_acte_err_code     =>trans_O_acte_err_code
                                  );

                  ELSIF v_nat_dossier in (3,5) THEN
                    P_TRANSCO_CODFRAIS_DENTAIR(
                                   P_numfor              => formule_sous1
                                  , P_acte              => loc_Tab_acte(compteur)
                                  , O_codfrais          => loc_Tab_acte(compteur).codfrais
                                  , O_acte_err_code     => trans_O_acte_err_code);
                    -- Permet de passer la bonne quantite si plusieurs dents pour ces 2 actes non remboursables
                    IF loc_Tab_acte(compteur).codfrais IN('IMPF','PDRC') THEN
                      IF loc_Tab_acte(compteur).NB_DENT>0 THEN
                        loc_Tab_acte(compteur).QUANT_ACTE:=loc_Tab_acte(compteur).NB_DENT;
                        P_INS_journal(2,v_id_flux||' Acte IMPF ou PDRC, quantite: ' || loc_Tab_acte(compteur).QUANT_ACTE );
                      END IF;
                    END IF;
                  ELSIF v_nat_dossier = 4 THEN
                     P_TRANSCO_CODFRAIS_AUDITIF(
                                    P_numfor             => formule_sous1
                                  , P_acte              => loc_Tab_acte(compteur)
                                  , O_codfrais          => loc_Tab_acte(compteur).codfrais
                                  , O_acte_err_code     => trans_O_acte_err_code);
                  END IF;
                END IF;
                P_INS_journal(1,v_id_flux||' Acte transcodé:' || loc_Tab_acte(compteur).codfrais  ||' erreur :' || trans_O_acte_err_code );
                IF TRIM(trans_O_acte_err_code) = '02' THEN -- Transco multiple
                  loc_Tab_acte(compteur).codfrais:=NULL;
                END IF;
                loc_acteCouvert := FALSE;
                IF loc_Tab_acte(compteur).codfrais is not null THEN
                  ---- Controle de couverture de l'acte

                  PK_CTRL_TP.P_CTRL_CVRT_ACTE(loc_Tab_acte(compteur).codfrais,
                                              loc_patient,
                                              to_date(loc_Tab_acte(compteur).DATE_SOINS,'DDMMYY'),
                                              loc_idadhesion,
                                              loc_acteCouvert,
                                              erreur_acte);
                END IF;

                --M4767 Contrôle de la couverture TPE
                IF pk_porte.F_carte_tp(loc_patient, loc_Tab_acte(compteur).codfrais, to_date(loc_Tab_acte(compteur).DATE_SOINS,'DDMMYY'), 0, NULL,  NULL, g_tabCond ) =0 THEN
                  loc_acteCouvert:=FALSE;
                END IF;
                loc_Tab_acte(compteur).ACTE_COUVERT :=loc_acteCouvert;
                IF loc_Tab_acte(compteur).codfrais is not null AND loc_Tab_acte(compteur).NATURE_PREST <> 'PDL' AND  loc_Tab_acte(compteur).ACTE_COUVERT THEN

                  P_INS_journal(2,v_id_flux||' Insertion dans sinistre_sante pour l acte:' || loc_Tab_acte(compteur).codfrais );


                  -- Detection des suppléments  --RKO RAC OPTIQUE gestion supplements
                  /*loc_depense_sup:=0;
                  loc_ro_sup:=0;
                  IF loc_Tab_acte(compteur+2).NATURE_PREST IN ('VSU','MSU') THEN
                    loc_depense_sup:=loc_Tab_acte(compteur+2).MONTANT_DEP;
                    loc_ro_sup:=loc_Tab_acte(compteur+2).MONT_REMB;
                    P_INS_journal(2,v_id_flux||' loc_depense_sup:' || to_char(loc_depense_sup));
                    P_INS_journal(2,v_id_flux||' loc_ro_sup:' || to_char(loc_ro_sup));
                  END IF;*/

                  --IF loc_Tab_acte(compteur).NATURE_PREST NOT IN ('VSU','MSU') THEN --RKO RAC OPTIQUE gestion supplements

                  /** Detection Doublon Dentaire PEC***/
                    IF v_nat_dossier = 3 THEN  --dentaire

    P_INS_journal(1,v_id_flux|| ' acte dentaire Contrôle doublon sur '||loc_Tab_acte(compteur).codfrais);

                       loc_list_dent :=  loc_Tab_acte(compteur).LOC_DENT1 ||','
                                || loc_Tab_acte(compteur).LOC_DENT2 ||','
                                ||loc_Tab_acte(compteur).LOC_DENT3 ||','
                                || loc_Tab_acte(compteur).LOC_DENT4 ||','
                                || loc_Tab_acte(compteur).LOC_DENT5 ||','
                                || loc_Tab_acte(compteur).LOC_DENT6 ||','
                                || loc_Tab_acte(compteur).LOC_DENT7 ||','
                                || loc_Tab_acte(compteur).LOC_DENT8 ||','
                                || loc_Tab_acte(compteur).LOC_DENT9 ||','
                                || loc_Tab_acte(compteur).LOC_DENT10 ||','
                                || loc_Tab_acte(compteur).LOC_DENT11 ||','
                                || loc_Tab_acte(compteur).LOC_DENT12 ||','
                                || loc_Tab_acte(compteur).LOC_DENT13 ||','
                                || loc_Tab_acte(compteur).LOC_DENT14 ||','
                                || loc_Tab_acte(compteur).LOC_DENT15 ||','
                                || loc_Tab_acte(compteur).LOC_DENT16 ;


                       IF F_CTRL_DOUBLON_DENT( i_numindiv => loc_patient,
                                                      i_nodent =>loc_list_dent,
                                                      i_date =>ADD_MONTHS(sysdate, -24),
                                                      i_codfrais =>loc_Tab_acte(compteur).codfrais,
                                                      i_numsin =>null,
                                                      i_numdoss => loc_num_dossier
                                                      ) =1 THEN
                          loc_blocage :=3;
                          P_INS_journal(1,v_id_flux|| '  PEC '||loc_Tab_acte(compteur).codfrais|| '  blocage doublon dentaire '||loc_list_dent);
                       END IF;
                    END IF;
                  /***FIN detection doublon dentaire PEC***/
					PK_CTRL_TP.P_INS_SNTR_SANTE(
                    P_num_dossier => loc_num_dossier,
                    P_numligne    => compteur,
                    P_numindiv    => loc_patient,
                    P_codfrais    => loc_Tab_acte(compteur).codfrais,
                    P_mtfrais     => NVL(loc_Tab_acte(compteur).MONTANT_DEP,0)+ NVL(loc_depense_sup,0),
                    P_etat        => 1,
                    P_taux        => loc_Tab_acte(compteur).TAUX_REMB,
                    P_baseremb    => loc_Tab_acte(compteur).BASE_REMB,
                    P_mtremb      => NVL(loc_Tab_acte(compteur).MONT_REMB,0)+NVL(loc_ro_sup,0),
                    P_datsin      => to_date(loc_Tab_acte(compteur).DATE_SOINS,'DDMMYY'),
                    P_coeff       => 1, -- loc_Tab_acte(compteur).COEFF_ACTE,
                    P_quantite    => loc_Tab_acte(compteur).QUANT_ACTE,
                    p_bloc        => NVL(loc_blocage,0)   --RKO blocage pour doublon dentaire
                    );

                    -- M4734 : Mise à jour de la localisation dentaire si c est une PEC dentaire ou orthodentie
                    IF v_nat_dossier IN (3,5) THEN
                      PK_CTRL_TP.P_MAJ_SNTR_SANTE_LOCDEN(
                                  loc_num_dossier
                                , compteur
                                , loc_Tab_acte(compteur).LOC_DENT1
                                , loc_Tab_acte(compteur).LOC_DENT2
                                , loc_Tab_acte(compteur).LOC_DENT3
                                , loc_Tab_acte(compteur).LOC_DENT4
                                , loc_Tab_acte(compteur).LOC_DENT5
                                , loc_Tab_acte(compteur).LOC_DENT6
                                , loc_Tab_acte(compteur).LOC_DENT7
                                , loc_Tab_acte(compteur).LOC_DENT8
                                , loc_Tab_acte(compteur).LOC_DENT9
                                , loc_Tab_acte(compteur).LOC_DENT10
                                , loc_Tab_acte(compteur).LOC_DENT11
                                , loc_Tab_acte(compteur).LOC_DENT12
                                , loc_Tab_acte(compteur).LOC_DENT13
                                , loc_Tab_acte(compteur).LOC_DENT14
                                , loc_Tab_acte(compteur).LOC_DENT15
                                , loc_Tab_acte(compteur).LOC_DENT16
                                                     );
                    END IF;

                    P_INS_journal(2,v_id_flux||' Insertion dans histo_sinistre_sante pour l acte:' || loc_Tab_acte(compteur).codfrais );

                    PK_CTRL_TP.P_INS_HISTO_SNTR_SANTE(
                      P_num_dossier => loc_num_dossier,
                      P_numligne    => compteur,
                      P_etat        => 1,
                      P_motif       => 0);
                  --  END IF;  RKO RAC OPTIQUE gestion supplements

                    P_TRAV_SAISIE.NUMLIG:= compteur;

                    P_TRAV_SAISIE.NUMSIN:=  NULL;
                    P_TRAV_SAISIE.LOCDENT1:= loc_Tab_acte(compteur).LOC_DENT1;
                    P_TRAV_SAISIE.LOCDENT2:= loc_Tab_acte(compteur).LOC_DENT2;
                    P_TRAV_SAISIE.LOCDENT3:= loc_Tab_acte(compteur).LOC_DENT3;
                    P_TRAV_SAISIE.LOCDENT4:= loc_Tab_acte(compteur).LOC_DENT4;
                    P_TRAV_SAISIE.LOCDENT5:= loc_Tab_acte(compteur).LOC_DENT5;
                    P_TRAV_SAISIE.LOCDENT6:= loc_Tab_acte(compteur).LOC_DENT6;
                    P_TRAV_SAISIE.LOCDENT7:= loc_Tab_acte(compteur).LOC_DENT7;
                    P_TRAV_SAISIE.LOCDENT8:= loc_Tab_acte(compteur).LOC_DENT8;
                    P_TRAV_SAISIE.LOCDENT9:= loc_Tab_acte(compteur).LOC_DENT9;
                    P_TRAV_SAISIE.LOCDENT10:= loc_Tab_acte(compteur).LOC_DENT10;
                    P_TRAV_SAISIE.LOCDENT11:= loc_Tab_acte(compteur).LOC_DENT11;
                    P_TRAV_SAISIE.LOCDENT12:= loc_Tab_acte(compteur).LOC_DENT12;
                    P_TRAV_SAISIE.LOCDENT13:= loc_Tab_acte(compteur).LOC_DENT13;
                    P_TRAV_SAISIE.LOCDENT14:= loc_Tab_acte(compteur).LOC_DENT14;
                    P_TRAV_SAISIE.LOCDENT15:= loc_Tab_acte(compteur).LOC_DENT15;
                    P_TRAV_SAISIE.LOCDENT16:= loc_Tab_acte(compteur).LOC_DENT16;

                    cpt_trav :=0;
                    BEGIN
                        select nature into loc_nat_acte from ntfrs_optique where codfrais=loc_Tab_acte(compteur).codfrais; --ntfrs_optique.nature=1 pour les verres, 2 pour les montures et 3 pour lentilles
                    EXCEPTION --ARTGEREP_407 nvl(nature,0) ne gere pas le cas où il nya aucune ligne
                        WHEN OTHERS THEN loc_nat_acte :=0;
                    END;

                    IF v_nat_dossier = 2 AND loc_nat_acte=1 THEN -- optique et acte verre -- RKO 24/03/2021 Suppression du filtre loc_Tab_acte(compteur).NATURE_PREST = 'VER' car avant SC vehiculait VER pour les actes verres mais maintenant il véhicule VU, VM,V0,etc...
                        --Saisie des verres dans trav_saisie pour enreg dans sinistre_verre

                        loc_trav := P_TRAV_SAISIE;
                        --Saisie de l'oeil Droit
                        IF (NVL(loc_Tab_acte(compteur).OD_SPHERE,0) <> 0
                          OR NVL(loc_Tab_acte(compteur).OD_CYLINDRE,0) <> 0
                          OR NVL(loc_Tab_acte(compteur).OD_AXE,0) <> 0
                          OR NVL(loc_Tab_acte(compteur).OD_ADDITION,0) <> 0) AND loc_flag_oeil=1 THEN

                                loc_trav.oeil := 'D';
                                loc_trav.sphere := NVL(loc_Tab_acte(compteur).OD_SPHERE,0);
                                loc_trav.cylindre := NVL(loc_Tab_acte(compteur).OD_CYLINDRE,0);
                                loc_trav.addition:= NVL(loc_Tab_acte(compteur).OD_ADDITION,0);
                                loc_trav.axe := NVL(loc_Tab_acte(compteur).OD_AXE,0);
                                --puis insertion
                                P_INSERT_TRAV_SAISIE(  loc_trav );
                                cpt_trav := cpt_trav +1;

                           --Saisie de l'oeil Gauche
                        ELSIF NVL(loc_Tab_acte(compteur).OG_SPHERE,0) <> 0
                          OR NVL(loc_Tab_acte(compteur).OG_CYLINDRE,0) <> 0
                          OR NVL(loc_Tab_acte(compteur).OG_AXE,0) <> 0
                          OR NVL(loc_Tab_acte(compteur).OG_ADDITION,0) <> 0 THEN

                                loc_trav := P_TRAV_SAISIE;
                                loc_trav.oeil := 'G';
                                loc_trav.sphere := NVL(loc_Tab_acte(compteur).OG_SPHERE,0);
                                loc_trav.cylindre := NVL(loc_Tab_acte(compteur).OG_CYLINDRE,0);
                                loc_trav.addition := NVL(loc_Tab_acte(compteur).OG_ADDITION,0);
                                Loc_trav.axe := NVL(loc_Tab_acte(compteur).OG_AXE,0);
                                --puis insertion
                                P_INSERT_TRAV_SAISIE(  loc_trav );
                                cpt_trav := cpt_trav +1;
                        END IF;
                    END IF;

                    IF cpt_trav=0 THEN
                      P_INSERT_TRAV_SAISIE(  P_TRAV_SAISIE );
                    END IF;
                END IF;
                P_INS_journal(2,v_id_flux||' Fin des sinistre_sante');
              END IF;
            END LOOP;
          END IF;


          P_INS_journal(2,v_id_flux||' Calcul du dossier:' || to_char(loc_num_dossier));


      IF loc_num_dossier > 0 THEN

            COMMIT;
            ----mise en place de la dérogation optique RAC WS sur les PEC
            IF v_nat_dossier = 2 AND l_top_derog in ('D','M','N','C') THEN -- optique et derogation sur le flux
              l_derog := 'OPTI';
            ELSE  l_derog := null;
            END IF;
            P_INS_journal(1,v_id_flux||' l_derog '||l_derog);
            PK_CALCUL_DOSSIER.P_CALCUL_DOSSIER_SANTE(P_num_dossier => loc_num_dossier,
                                                     P_type        => 'devis',
                                                     P_tot_prest   => -1,
                                                     O_erreur      => erreur_dossier,
                                                     O_msg_erreur  => msg_dossier,
                                                     p_derog       => l_derog --paramètre définissant la derogation (ou pas) lors du calcul
                                                     );
            P_INS_journal(2,v_id_flux||' erreur_dossier:' || erreur_dossier);
            P_INS_journal(2,v_id_flux||' msg_dossier:' || msg_dossier);
            IF erreur_dossier =9 THEN
                 LIBELLE_RETOUR_ACTE := '02';
                 rollback;
            ELSIF erreur_dossier = 10 THEN --le montant total RC = 0
               -- Historisation du dossier
              P_INS_journal(2,v_id_flux||' Historisation du dossier pour cause d erreur:'||erreur_dossier);
            /*  PK_CTRL_TP.P_INS_HISTO_DOSSIER(
                    P_num_dossier => loc_num_dossier,
                    P_etat        => 0,
                    P_motif       => 5);*/
              LIBELLE_RETOUR_ACTE := '11'; -- 02
            ELSE
              LIBELLE_RETOUR_ACTE := '01';
            END IF;
            loc_flag_oeil:=0;
            FOR compteur IN 1 .. 32 LOOP
              BEGIN
                --M6650 réinitialisation du code retour acte
                IF LIBELLE_RETOUR_ACTE NOT IN ('02','11')THEN
                  LIBELLE_RETOUR_ACTE := '01';
                END IF;
                loc_blocage:=NULL;
                IF loc_Tab_acte(compteur).codfrais is not null AND loc_Tab_acte(compteur).NATURE_PREST <> 'PDL' AND loc_Tab_acte(compteur).ACTE_COUVERT THEN
                  P_INS_journal(2,v_id_flux||'*****Acte montant:' || loc_Tab_acte(compteur).codfrais );
                  -- on récupère les montants pour chaque acte
                  SELECT NVL(SUM(MTFRAIS),0),NVL(SUM(MTPREST_REEL),0),NVL(SUM(MTREMB),0),NVL(SUM(AUTRB_DAUTRB),0),NVL(SUM(QUANTITE),0), NVL(blocage,0)
                  INTO MONTANT_DEP,MONTANT_RC,MONTANT_RO,MONTANT_AUTRE,QUANTITE, loc_blocage
                  FROM SINISTRE_SANTE
                  WHERE NUM_DOSSIER=loc_num_dossier
                  AND CODFRAIS = loc_Tab_acte(compteur).codfrais
                  AND numligne = compteur
                  GROUP BY blocage
                  ORDER BY numligne ASC;

                  MONTANT_RAC :=MONTANT_DEP - MONTANT_RC - MONTANT_RO ; --RKO et CGR M0006469
                  loc_tot_prest:=loc_tot_prest+MONTANT_RC;
                  IF NVL(MONTANT_RC,0)=0 THEN
                    LIBELLE_RETOUR_ACTE:='04';
                  --M6650 code retour pour montant partiel
                  ELSIF MONTANT_RAC<>0 AND NVL(MONTANT_RC,0)<>0 THEN
                   LIBELLE_RETOUR_ACTE:='12'; --rbt partiel
                  END IF;
                  P_INS_journal(2,v_id_flux||' Dossier:' || loc_num_dossier||' compteur:' || compteur);
                  P_INS_journal(2,v_id_flux||' loc_Tab_acte(compteur).MONTANT_DEP:' || loc_Tab_acte(compteur).MONTANT_DEP);
                  P_INS_journal(2,v_id_flux||' loc_Tab_acte(compteur).MONT_REMB:' || loc_Tab_acte(compteur).MONT_REMB);
                  P_INS_journal(2,v_id_flux||' MONTANT_DEP total:' || MONTANT_DEP||' MONTANT_RO:' || MONTANT_RO);
                  P_INS_journal(2,v_id_flux||' MONTANT_RC total:' || MONTANT_RC||' MONTANT_RAC total:' || MONTANT_RAC);
                  P_INS_journal(2,v_id_flux||' MONTANT_AUTRE :' || MONTANT_AUTRE||' QUANTITE:' || QUANTITE);


                  loc_ret_Tab_acte(compteur).MT_REMB_RC          := MONTANT_RC;
                  loc_ret_Tab_acte(compteur).RESTE_A_CHARGE      := MONTANT_RAC;
                  loc_ret_Tab_acte(compteur).QUANTITE_ACTE       := QUANTITE;

                ELSE
                  IF loc_Tab_acte(compteur).NATURE_PREST is null THEN
                     LIBELLE_RETOUR_ACTE := null;
                  ELSIF loc_Tab_acte(compteur).NATURE_PREST = 'PDL' THEN
                      LIBELLE_RETOUR_ACTE := '04'; -- '03' Santé Clair ne veut pas du code 03
                  ELSIF NOT loc_Tab_acte(compteur).ACTE_COUVERT  THEN
                      LIBELLE_RETOUR_ACTE := '04';
                  END IF;

                  loc_ret_Tab_acte(compteur).MT_REMB_RC          := null;
                  loc_ret_Tab_acte(compteur).RESTE_A_CHARGE      := loc_Tab_acte(compteur).MONTANT_DEP-loc_Tab_acte(compteur).MONT_REMB;
                  loc_ret_Tab_acte(compteur).QUANTITE_ACTE       := null;

                END IF;

                loc_ret_Tab_acte(compteur).NAT_PRESTATION      := loc_Tab_acte(compteur).NATURE_PREST;
                loc_ret_Tab_acte(compteur).FORMULE_SOUS1       := null;
                loc_ret_Tab_acte(compteur).FORMULE_SOUS2       := null;
                loc_ret_Tab_acte(compteur).MESS_SUPP           := null;
                loc_ret_Tab_acte(compteur).MT_DEP              := loc_Tab_acte(compteur).MONTANT_DEP;
                loc_ret_Tab_acte(compteur).MT_REMB_RO          := loc_Tab_acte(compteur).MONT_REMB; --MONTANT_RO;
                loc_ret_Tab_acte(compteur).MT_PART_COMP        := null;
                loc_ret_Tab_acte(compteur).CODE_CCAM           := loc_Tab_acte(compteur).CODE_CCAM;
                loc_ret_Tab_acte(compteur).FILLER1             := null;
                loc_ret_Tab_acte(compteur).QUANTITE_COMP_ACTE  := null;
                loc_ret_Tab_acte(compteur).FILLER2             := null;
                loc_ret_Tab_acte(compteur).TYPE_ENREG          := loc_Tab_acte(compteur).TYPE_ENREG;
                IF NVL(loc_blocage,0) = 3 THEN
                   LIBELLE_RETOUR_ACTE:='00';
                   loc_ret_Tab_acte(compteur).MESS_SUPP           := 'Soin de même nature déjà effectué sur cette dent';
                END IF;
                loc_ret_Tab_acte(compteur).LIBELLE_RETOUR      := LIBELLE_RETOUR_ACTE;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  P_INS_journal(2,v_id_flux||' no_data_found  compteur:' || compteur);
                WHEN OTHERS THEN
                  P_INS_journal(2,v_id_flux||' others:   compteur:' || compteur);
              END;
            END LOOP;
          END IF;
        ELSE
          LIBELLE_RETOUR :=LIBELLE_RETOUR ; -- Afin de gérer le else non gérér auparavant
        END IF;
      END IF;
      --**************************************************************************
      ----------------------- FIN PEC --------------------------------------------
      ----------------------- FIN PEC --------------------------------------------
      ----------------------- FIN PEC --------------------------------------------
      ----------------------- FIN PEC --------------------------------------------
      --**************************************************************************

      --**************************************************************************
      ----------------------- DEVIS ----------------------------------------------
      ----------------------- DEVIS ----------------------------------------------
      ----------------------- DEVIS ----------------------------------------------
      ----------------------- DEVIS ----------------------------------------------
      --**************************************************************************
      P_INS_journal(2,'DEBUT DEVIS' );
      loc_flag_oeil:=0;
      IF TRAITEMENT = 'D'  OR TRAITEMENT = 'PCT' THEN

        -- selection de l ayant droit selectionné par le PS
        BEGIN

          select numindiv INTO loc_patient
            from individu
           where numassu=NUMGAR
             and trunc(datnais)=e2d(DATENAIS)
             AND prenom = nvl(trim(loc_prenom),prenom); -- JBO 18/11/2014 : Gestion d'un jumeau

        EXCEPTION
          WHEN OTHERS THEN
            LIBELLE_RETOUR := '15'; -- ce bénéficiaire n a pas droit au service
        END;
        P_INS_journal(2,v_id_flux||' loc_patient:'||to_char(loc_patient) );
        P_INS_journal(2,v_id_flux||' DATENAIS:'||to_char(DATENAIS) );

        FOR compteur3 IN 1..32 LOOP
          loc_Tab_acte(compteur3).codfrais := null;
          loc_blocage:=NULL;

          --SDA Mantis 4752
          --formule_sous1 := F_FORMULE_SOUSCRITE(loc_idadhesion,NUMGAR);
          formule_sous1 := F_FORMULE_SOUSCRITE(loc_idadhesion,loc_patient);


          IF TRIM(loc_Tab_acte(compteur3).NATURE_PREST) IS NOT NULL THEN
            P_INS_journal(2,v_id_flux||' Formule_sous1(numfor):' || formule_sous1 ||' NATURE_PREST:'||loc_Tab_acte(compteur3).NATURE_PREST);
            IF v_nat_dossier = 2 THEN
              IF NVL(loc_Tab_acte(compteur3).OD_SPHERE,0) <> 0
                OR NVL(loc_Tab_acte(compteur3).OD_CYLINDRE,0) <> 0
                OR NVL(loc_Tab_acte(compteur3).OD_AXE,0) <> 0
                OR NVL(loc_Tab_acte(compteur3).OD_ADDITION,0) <> 0
                THEN
                  --IF TRIM(loc_Tab_acte(compteur3).NATURE_PREST) NOT IN ('VSU','MSU') THEN -- permet d exclure les suplléments
                    loc_flag_oeil:=loc_flag_oeil+1; -- permet de savoir si on a traité l oeil droit
                  --END IF;--RKO RAC OPTIQUE gestion supplements
              END IF;
              P_TRANSCO_CODFRAIS_OPTIQUE(
                              P_numfor            => formule_sous1
                            , P_flag_oeil         => loc_flag_oeil
                            , P_acte             => loc_Tab_acte(compteur3)
                            , O_codfrais          => loc_Tab_acte(compteur3).codfrais
                            , O_acte_err_code     => trans_O_acte_err_code
                            );
             ELSIF v_nat_dossier in (3,5) THEN
               P_TRANSCO_CODFRAIS_DENTAIR(
                              P_numfor              => formule_sous1
                            , P_acte               => loc_Tab_acte(compteur3)
                            , O_codfrais          => loc_Tab_acte(compteur3).codfrais
                            , O_acte_err_code     => trans_O_acte_err_code);
               -- Permet de passer la bonne quantite si plusieurs dents pour ces 2 actes non remboursables
               P_INS_journal(2,v_id_flux||' Acte quantite: ' || loc_Tab_acte(compteur3).QUANT_ACTE || 'nb_dent :'||loc_Tab_acte(compteur3).NB_DENT);
               IF loc_Tab_acte(compteur3).codfrais IN('IMPF','PDRC') THEN
                 IF loc_Tab_acte(compteur3).NB_DENT>0 THEN
                   loc_Tab_acte(compteur3).QUANT_ACTE:=loc_Tab_acte(compteur3).NB_DENT;
                   P_INS_journal(2,v_id_flux||' Acte IMPF ou PDRC, quantite: ' || loc_Tab_acte(compteur3).QUANT_ACTE );
                 END IF;
               END IF;
             ELSIF v_nat_dossier = 4 THEN
               P_TRANSCO_CODFRAIS_AUDITIF(
                              P_numfor             => formule_sous1
                            , P_acte              => loc_Tab_acte(compteur3)
                            , O_codfrais          => loc_Tab_acte(compteur3).codfrais
                            , O_acte_err_code     => trans_O_acte_err_code);
             END IF;

            P_INS_journal(2,v_id_flux||' DEVIS v_nat_dossier:' || v_nat_dossier||' acte transco:' || loc_Tab_acte(compteur3).codfrais ||' err :' || trans_O_acte_err_code);

            IF TRIM(trans_O_acte_err_code) = '02' THEN -- Transco multiple
              loc_Tab_acte(compteur3).codfrais:=NULL;
            END IF;

            IF loc_Tab_acte(compteur3).codfrais is not null THEN
              -- Controle de couverture de l'acte
              -- SDA mantis 4772
              PK_CTRL_TP.P_CTRL_CVRT_ACTE(loc_Tab_acte(compteur3).codfrais,
                                          loc_patient,
                                          to_date(loc_Tab_acte(compteur3).DATE_SOINS,'DDMMYY'),
                                          loc_idadhesion,
                                          loc_acteCouvert,
                                          erreur_acte);
            END IF;

            --M4767 Contrôle de la couverture TPE
            IF pk_porte.F_carte_tp(loc_patient, loc_Tab_acte(compteur3).codfrais, to_date(loc_Tab_acte(compteur3).DATE_SOINS,'DDMMYY'), 0, NULL,  NULL, g_tabCond ) =0 THEN
              loc_acteCouvert:=FALSE;
            END IF;

            loc_Tab_acte(compteur3).ACTE_COUVERT :=loc_acteCouvert;
          END IF;

          IF loc_Tab_acte(compteur3).NATURE_PREST is not null AND loc_Tab_acte(compteur3).codfrais is not null AND loc_Tab_acte(compteur3).ACTE_COUVERT THEN
            IF loc_Tab_acte(compteur3).NATURE_PREST = 'PDL' THEN
              loc_mtprest:=0; -- pas de remboursement pour les produits d entretien lentilles
              MONTANT_RC:=0;
              LIBELLE_RETOUR_ACTE := '01';
              MONTANT_RAC:=loc_Tab_acte(compteur3).MONTANT_DEP- loc_Tab_acte(compteur3).MONT_REMB;

           --RKO RAC OPTIQUE gestion supplements ELSE

            ELSE
             --  Detection des suppléments
              loc_depense_sup:=0;
              loc_ro_sup:=0;

            --Detection doublon dentaire Devis
               IF v_nat_dossier = 3 THEN  --dentaire

                   P_INS_journal(1,v_id_flux|| ' acte dentaire Contrôle doublon sur '||loc_Tab_acte(compteur3).codfrais);

                    loc_list_dent :=  loc_Tab_acte(compteur3).LOC_DENT1 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT2 ||','
                                ||loc_Tab_acte(compteur3).LOC_DENT3 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT4 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT5 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT6 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT7 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT8 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT9 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT10 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT11 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT12 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT13 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT14 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT15 ||','
                                || loc_Tab_acte(compteur3).LOC_DENT16 ;


                    IF F_CTRL_DOUBLON_DENT( i_numindiv => loc_patient,
                                                      i_nodent =>loc_list_dent,
                                                      i_date =>ADD_MONTHS(sysdate, -24),
                                                      i_codfrais =>loc_Tab_acte(compteur3).codfrais,
                                                      i_numsin =>null,
                                                      i_numdoss => loc_num_dossier
                                                      ) =1 THEN
                       loc_blocage :=3;
                       P_INS_journal(1,v_id_flux|| '  DEVIS '||loc_Tab_acte(compteur3).codfrais|| '  blocage doublon dentaire '||loc_list_dent);
                    END IF;
                  END IF;
               --FIN detection doublon dentaire devis

                -- JBO : dents du sourire
                P_TRAV_SAISIE.NUMLIG:= compteur3;

                P_TRAV_SAISIE.NUMSIN:=  NULL;
                P_TRAV_SAISIE.LOCDENT1:= loc_Tab_acte(compteur3).LOC_DENT1;
                P_TRAV_SAISIE.LOCDENT2:= loc_Tab_acte(compteur3).LOC_DENT2;
                P_TRAV_SAISIE.LOCDENT3:= loc_Tab_acte(compteur3).LOC_DENT3;
                P_TRAV_SAISIE.LOCDENT4:= loc_Tab_acte(compteur3).LOC_DENT4;
                P_TRAV_SAISIE.LOCDENT5:= loc_Tab_acte(compteur3).LOC_DENT5;
                P_TRAV_SAISIE.LOCDENT6:= loc_Tab_acte(compteur3).LOC_DENT6;
                P_TRAV_SAISIE.LOCDENT7:= loc_Tab_acte(compteur3).LOC_DENT7;
                P_TRAV_SAISIE.LOCDENT8:= loc_Tab_acte(compteur3).LOC_DENT8;
                P_TRAV_SAISIE.LOCDENT9:= loc_Tab_acte(compteur3).LOC_DENT9;
                P_TRAV_SAISIE.LOCDENT10:= loc_Tab_acte(compteur3).LOC_DENT10;
                P_TRAV_SAISIE.LOCDENT11:= loc_Tab_acte(compteur3).LOC_DENT11;
                P_TRAV_SAISIE.LOCDENT12:= loc_Tab_acte(compteur3).LOC_DENT12;
                P_TRAV_SAISIE.LOCDENT13:= loc_Tab_acte(compteur3).LOC_DENT13;
                P_TRAV_SAISIE.LOCDENT14:= loc_Tab_acte(compteur3).LOC_DENT14;
                P_TRAV_SAISIE.LOCDENT15:= loc_Tab_acte(compteur3).LOC_DENT15;
                P_TRAV_SAISIE.LOCDENT16:= loc_Tab_acte(compteur3).LOC_DENT16;


                cpt_trav :=0;
                BEGIN
                  select nature into loc_nat_acte from ntfrs_optique where codfrais=loc_Tab_acte(compteur3).codfrais; --ntfrs_optique.nature=1 pour les verres, 2 pour les montures et 3 pour lentilles
                EXCEPTION --ARTGEREP_407 nvl(nature,0) ne gere pas le cas où il nya aucune ligne
                  WHEN OTHERS THEN loc_nat_acte :=0;
                END;
                IF v_nat_dossier = 2 AND loc_nat_acte=1 THEN -- optique et acte verre  --RKO 24/03/2021 Suppression du filtre loc_Tab_acte(compteur3).NATURE_PREST = 'VER' car avant SC vehiculait VER pour les actes verres mais maintenant il véhicule VU, VM,V0,etc... donc la condition sur les caractéristiques verres suffisent pour determiner qu'il s'agit d'acte verre
                    --Saisie des verres dans trav_saisie pour enreg dans sinistre_verre

                    loc_trav := P_TRAV_SAISIE;
                    --Saisie de l'oeil Droit
                    IF (NVL(loc_Tab_acte(compteur3).OD_SPHERE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur3).OD_CYLINDRE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur3).OD_AXE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur3).OD_ADDITION,0) <> 0) AND loc_flag_oeil=1  THEN
                      loc_trav.oeil := 'D';
                      loc_trav.sphere := NVL(loc_Tab_acte(compteur3).OD_SPHERE,0);
                      loc_trav.cylindre := NVL(loc_Tab_acte(compteur3).OD_CYLINDRE,0);
                      loc_trav.addition:= NVL(loc_Tab_acte(compteur3).OD_ADDITION,0);
                      loc_trav.axe := NVL(loc_Tab_acte(compteur3).OD_AXE,0);
                      --puis insertion
                      P_INSERT_TRAV_SAISIE(  loc_trav );
                      cpt_trav := cpt_trav +1;

                       --Saisie de l'oeil Gauche
                    ELSIF NVL(loc_Tab_acte(compteur3).OG_SPHERE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur3).OG_CYLINDRE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur3).OG_AXE,0) <> 0
                      OR NVL(loc_Tab_acte(compteur3).OG_ADDITION,0) <> 0 AND loc_flag_oeil> 1 THEN
                      loc_trav := P_TRAV_SAISIE;
                      loc_trav.oeil := 'G';
                      loc_trav.sphere := NVL(loc_Tab_acte(compteur3).OG_SPHERE,0);
                      loc_trav.cylindre := NVL(loc_Tab_acte(compteur3).OG_CYLINDRE,0);
                      loc_trav.addition := NVL(loc_Tab_acte(compteur3).OG_ADDITION,0);
                      Loc_trav.axe := NVL(loc_Tab_acte(compteur3).OG_AXE,0);
                      --puis insertion
                      P_INSERT_TRAV_SAISIE(  loc_trav );
                      cpt_trav := cpt_trav +1;
                    END IF;
                END IF;

                IF cpt_trav=0 THEN
                  P_INSERT_TRAV_SAISIE(  P_TRAV_SAISIE );
                END IF;

                IF loc_blocage =3 THEN
                  loc_mtprest:=0;
                  P_INS_journal(1,v_id_flux|| ' Forçage montant prest car doublon dent: '||loc_mtprest);
                ELSE
                 --mise en place de la dérogation optique RAC WS sur les devis
                  IF v_nat_dossier = 2 AND l_top_derog in ('D','M','N','C') THEN
                    l_derog := 'OPTI';
                  ELSE  l_derog := null;
                  END IF;
                  P_INS_journal(1,v_id_flux||' l_derog '||l_derog);
                  PK_CALCUL_DOSSIER.P_CALCUL_RAC( P_codfrais    => loc_Tab_acte(compteur3).codfrais,
                                                P_datsin      => TO_CHAR(SYSDATE,'DD/MM/YYYY'),
                                                P_taux        => loc_Tab_acte(compteur3).TAUX_REMB,
                                                P_mtremb      => loc_Tab_acte(compteur3).MONT_REMB +NVL(loc_ro_sup,0) ,
                                                P_mtfrais     => loc_Tab_acte(compteur3).MONTANT_DEP + NVL(loc_depense_sup,0),
                                                P_devise      => PK_CTRL_TP.F_FIND_DEVISE,
                                                P_quantite    => loc_Tab_acte(compteur3).QUANT_ACTE,
                                                P_coeff       => 1,
                                                P_numindiv    => loc_patient,
                                                P_numbene     => NUMGAR,
                                                P_type_bene   => 1,
                                                P_ordre       => compteur3,  -- Parametre très important : permet de gérer le cumul des actes pour les plafonds, carence, franchise
                                                P_type        =>'devis',
                                                O_mtprest     => loc_mtprest, --MONTANT_DEP, -- V_mtprest
                                                O_erreur      => erreur_calcul_devis,
                                                O_msg_erreur  => O_msg_erreur_devis,
                                                p_derog       => l_derog   --paramètre définissant la derogation (ou pas) lors du calcul
                                                 );

                  P_INS_journal(1,v_id_flux|| ' montant prestation n°' ||compteur3|| ' = '||loc_mtprest);
                END IF;

               P_INS_journal(2,v_id_flux||' DEVIS erreur_calcul_devis:' || erreur_calcul_devis);
               P_INS_journal(2,v_id_flux||' DEVIS O_msg_erreur_devis:' || O_msg_erreur_devis);


               MONTANT_RAC :=loc_Tab_acte(compteur3).MONTANT_DEP - loc_mtprest - loc_Tab_acte(compteur3).MONT_REMB ;
               MONTANT_RC := loc_mtprest;
               P_INS_journal(2,v_id_flux||' DEVIS MONTANT_RC:'              || to_char(MONTANT_RC));

              CASE erreur_calcul_devis
                WHEN 0 THEN LIBELLE_RETOUR_ACTE := '01'; -- service OK
                WHEN 6 THEN
                  IF loc_mtprest = 0 THEN
                    LIBELLE_RETOUR_ACTE := '09';--Pas de reboursement possible : cette prestation est soumise a un delai de carence';
                  ELSE
                    LIBELLE_RETOUR_ACTE := '10';--'Attention, il s''agit d''un remboursement partiel, une partie de la garantie pour cette prestation est soumise a un delai de carence';
                  END IF;
                WHEN 7 THEN
                  IF loc_mtprest = 0 THEN
                    LIBELLE_RETOUR_ACTE  := '11';--'Pas de reboursement possible : le plafond de remboursement pour cette prestation a ete atteint lors d''un precedent remboursement';
                  ELSE
                    LIBELLE_RETOUR_ACTE := '12';--'Attention, il s''agit d''un remboursement partiel : le plafond de remboursement est atteint';
                  END IF;
              /*  WHEN 8 THEN
                  v_acte_err_code := '29';
                  v_acte_err_lib := 'Remboursement effectue en fonction de la franchise sur une garantie';*/
                ELSE
                  loc_mtprest:=0;
                  MONTANT_RAC:=0;
                  MONTANT_RC:=0;
                  LIBELLE_RETOUR_ACTE := '30';--'Une des donnees est incorrecte ou calcul impossible';
              END CASE;
            END IF;

            loc_tot_prest:=loc_tot_prest+loc_mtprest;
            IF NVL(loc_mtprest,0)=0 THEN
              LIBELLE_RETOUR_ACTE:='04';
            --M6650 code retour pour montant partiel
            ELSIF MONTANT_RAC<>0 AND NVL(MONTANT_RC,0)<>0 THEN
              LIBELLE_RETOUR_ACTE:='12'; --rbt partiel
            END IF;

            loc_ret_Tab_acte(compteur3).NAT_PRESTATION      := loc_Tab_acte(compteur3).NATURE_PREST;
            loc_ret_Tab_acte(compteur3).FORMULE_SOUS1       := null;
            loc_ret_Tab_acte(compteur3).FORMULE_SOUS2       := null;
            loc_ret_Tab_acte(compteur3).MESS_SUPP           := null;
            --loc_ret_Tab_acte(compteur3).MT_DEP              := MONTANT_DEP;
            loc_ret_Tab_acte(compteur3).MT_DEP              := loc_Tab_acte(compteur3).MONTANT_DEP;
            loc_ret_Tab_acte(compteur3).MT_REMB_RO          := loc_Tab_acte(compteur3).MONT_REMB;--MONTANT_RO;
            loc_ret_Tab_acte(compteur3).MT_PART_COMP        := null;--null;
            loc_ret_Tab_acte(compteur3).MT_REMB_RC          := MONTANT_RC;
            loc_ret_Tab_acte(compteur3).RESTE_A_CHARGE      := MONTANT_RAC;
            loc_ret_Tab_acte(compteur3).QUANTITE_ACTE       := loc_Tab_acte(compteur3).QUANT_ACTE; --QUANTITE;
            loc_ret_Tab_acte(compteur3).FILLER1             := null;
            loc_ret_Tab_acte(compteur3).QUANTITE_COMP_ACTE  := null;
            loc_ret_Tab_acte(compteur3).CODE_CCAM           := loc_Tab_acte(compteur3).CODE_CCAM;
            loc_ret_Tab_acte(compteur3).FILLER2             := null;
            loc_ret_Tab_acte(compteur3).TYPE_ENREG          := loc_Tab_acte(compteur3).TYPE_ENREG;

             IF loc_blocage = 3 THEN
               LIBELLE_RETOUR_ACTE:='00';
               loc_ret_Tab_acte(compteur3).MESS_SUPP           := 'Soin de même nature déjà effectué sur cette dent';
             END IF;

             loc_ret_Tab_acte(compteur3).LIBELLE_RETOUR      := LIBELLE_RETOUR_ACTE;
          ELSE
            --coda acte  pas vide mais resultat transco null
            --03 pas de calcul possible : code acte inconnu
            IF loc_Tab_acte(compteur3).NATURE_PREST is null THEN
                     --SDA mantis 5177+5192 corrige
                     LIBELLE_RETOUR_ACTE := null;
            ELSIF TRIM(loc_Tab_acte(compteur3).NATURE_PREST) IS NOT NULL AND loc_Tab_acte(compteur3).codfrais is null THEN
                LIBELLE_RETOUR_ACTE := '04'; -- '03' Santé Clair ne veut pas du code 03
            ELSIF NOT loc_acteCouvert THEN
                LIBELLE_RETOUR_ACTE := '04';
            ELSE
                LIBELLE_RETOUR_ACTE := null;
            END IF;
            loc_ret_Tab_acte(compteur3).NAT_PRESTATION      := loc_Tab_acte(compteur3).NATURE_PREST;
            loc_ret_Tab_acte(compteur3).FORMULE_SOUS1       := null;
            loc_ret_Tab_acte(compteur3).FORMULE_SOUS2       := null;
            loc_ret_Tab_acte(compteur3).LIBELLE_RETOUR      := LIBELLE_RETOUR_ACTE;
            loc_ret_Tab_acte(compteur3).MESS_SUPP           := null;
            loc_ret_Tab_acte(compteur3).MT_DEP              := loc_Tab_acte(compteur3).MONTANT_DEP;
            loc_ret_Tab_acte(compteur3).MT_REMB_RO          := loc_Tab_acte(compteur3).MONT_REMB;
            loc_ret_Tab_acte(compteur3).MT_PART_COMP        := null;
            loc_ret_Tab_acte(compteur3).MT_REMB_RC          := null;
            loc_ret_Tab_acte(compteur3).RESTE_A_CHARGE      := loc_Tab_acte(compteur3).MONTANT_DEP-loc_Tab_acte(compteur3).MONT_REMB;
            loc_ret_Tab_acte(compteur3).QUANTITE_ACTE       := null;
            loc_ret_Tab_acte(compteur3).FILLER1             := null;
            loc_ret_Tab_acte(compteur3).QUANTITE_COMP_ACTE  := null;
            loc_ret_Tab_acte(compteur3).CODE_CCAM           := null;
            loc_ret_Tab_acte(compteur3).FILLER2             := null;
            loc_ret_Tab_acte(compteur3).TYPE_ENREG          := null;

          END IF;

        END LOOP;
      END IF;
      P_INS_journal(2,v_id_flux||' FIN DEVIS:');
    --**************************************************************************
    ----------------------- FIN DEVIS ------------------------------------------
    ----------------------- FIN DEVIS ------------------------------------------
    ----------------------- FIN DEVIS ------------------------------------------
    ----------------------- FIN DEVIS ------------------------------------------
    --**************************************************************************
    EXCEPTION
      WHEN exc_assure_ctrl_tp1 THEN
        P_INS_journal(2,v_id_flux||' exc_assure_ctrl_tp1 2'); -- exception dejà gérer mais permet de ne pas faire de devis ou PEC
    END;

  ELSE
    P_INS_journal(2,v_id_flux||' Controles de droits de l assure KO');
  END IF;



  --**************************************************************************
  ----------------------- FLUX RETOUR ----------------------------------------
  ----------------------- FLUX RETOUR ----------------------------------------
  ----------------------- FLUX RETOUR ----------------------------------------
  ----------------------- FLUX RETOUR ----------------------------------------
  --**************************************************************************
  --Identification Compagnie
  P_RETOUR_FLUX := F_COMPLETE(IDENT_COMPAGNIE,8);
  --Identifiant supplémentaire
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(IDENT_SUPP,2);

  P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX;
  P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX_ERREUR || F_COMPLETE('00',2);
  P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX_ERREUR || F_COMPLETE('ERREUR TECHNIQUE',200);
  P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX_ERREUR || F_COMPLETE('',16);
  P_RETOUR_FLUX_ERREUR := P_RETOUR_FLUX_ERREUR || F_COMPLETE('',3172);

  --N° de contrat
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(NUMGAR,16);
  --Complément au n° de contrat
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',16);
  --Date de naissance du patient
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(DATENAIS,8);
  --Prénom du patient
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(UPPER(LTRIM(SUBSTR(F_NOM(loc_patient),INSTR(F_NOM(loc_patient),' ')))),32);
  --Type de monnaie
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(TYPE_MONNAIE,1);
  --Libellé retour
   --00 retour indéterminé
   --01 service OK
   --05 pas de remboursement possible : le contrat n'est pas en cours (en attente de régularisation, ou en impayé, ou suspendu)
   --06 pas de remboursement possible : le contrat est résilié
   --07 pas de remboursement possible : le patient n'est plus couvert par le contrat
   --13 anomalie dans le traitement, une intervention Compagnie est nécessaire: prévenir le correspondant Compagnie
   --15 Ce bénéficiaire n’a pas droit au service
   --17 Le bénéficiaire appartient à une société exclue du service
   --19 PEC acceptée mais existence d’une autre prise en charge en cours
   --20 PEC refusée – Existence d’une autre prise en charge en cours
   --21 Annulation refusée – PEC introuvable
   --22 Annulation refusée – PEC déjà annulée
   --23 Annulation refusée – PEC déjà facturée.
   --24 Forçage refusé.
   --29 Annulation refusée – PEC déjà clôturée.
   --31 Pas de remboursement possible : le patient doit passer par sa 1ere mutuelle.
  IF TRAITEMENT <> 'PAR' THEN --
    IF loc_tot_prest = 0 THEN
      LIBELLE_RETOUR:='04';
    END IF;

  END IF;

  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(LIBELLE_RETOUR,2);
  --Message supplémentaire
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',200);
  --Zone code caisse
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',3);
  --Numero de décompte
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',20);
  --Date de fin de validité de la PEC
--  DATE_FIN_VAL:=TO_CHAR(ADD_MONTHS( SYSDATE, loc_sens ),'DDMMYYYY');
--  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(DATE_FIN_VAL,8);
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',8);
  --FILLER
  P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE('',19);

  --tableau des actes retour 32*170
  FOR compteur2 IN 1 .. 32 LOOP
    --P_INS_journal(2,'tableau retour :' || compteur2 );
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).NAT_PRESTATION,5);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).FORMULE_SOUS1,15);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).FORMULE_SOUS2,15);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).LIBELLE_RETOUR,2);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).MESS_SUPP,50);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(F_FORMAT_VARCHAR(loc_ret_Tab_acte(compteur2).MT_DEP,6,2),8,'N');
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(F_FORMAT_VARCHAR(loc_ret_Tab_acte(compteur2).MT_REMB_RO,6,2),8,'N');
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(F_FORMAT_VARCHAR(loc_ret_Tab_acte(compteur2).MT_PART_COMP,6,2),8,'N');
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(F_FORMAT_VARCHAR(loc_ret_Tab_acte(compteur2).MT_REMB_RC,6,2),8,'N');
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(F_FORMAT_VARCHAR(loc_ret_Tab_acte(compteur2).RESTE_A_CHARGE,6,2),8,'N');
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(F_FORMAT_VARCHAR(loc_ret_Tab_acte(compteur2).QUANTITE_ACTE,3,0),3,'N');
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).FILLER1,3);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).QUANTITE_COMP_ACTE,2);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).CODE_CCAM,7);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).FILLER2,25);
    P_RETOUR_FLUX := P_RETOUR_FLUX || F_COMPLETE(loc_ret_Tab_acte(compteur2).TYPE_ENREG,3);
  END LOOP;

  --**************************************************************************
  ----------------------- FIN FLUX RETOUR ------------------------------------
  ----------------------- FIN FLUX RETOUR ------------------------------------
  ----------------------- FIN FLUX RETOUR ------------------------------------
  ----------------------- FIN FLUX RETOUR ------------------------------------
  --**************************************************************************

  PK_CALCUL_DOSSIER.P_Delete_travsn(P_sid=>l_sid);

  --remplace des crochets par []
  P_RETOUR_FLUX := replace(P_RETOUR_FLUX,'[',' ');


  --longueur du flux retour
  L_FLUX_SC := LENGTH(P_RETOUR_FLUX);
  --UPDATE flux retour
  UPDATE HISTO_FLUX_WS_SC
     SET FLUX_RETOUR = P_RETOUR_FLUX,
         LONG_FLUX_OUT = L_FLUX_SC
   WHERE ID_FLUX_SC = v_id_flux;

  REP_F_SC_CALCUL := P_RETOUR_FLUX;

  -- MAJ statut du flux OK
  v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
  IF TRIM(NVL(LIBELLE_RETOUR,'00'))='00' THEN
    pk_ws.maj_statut(v_id_flux, 6,null,v_delai);
  ELSE
    pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  END IF;

  P_INS_journal(2,v_id_flux||' FIN du traitement du service CALCUL SANTECLAIR');
  RETURN REP_F_SC_CALCUL;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(2,v_id_flux||' F_RET_SC_CALCUL;' || sqlerrm);
    ROLLBACK;
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
    pk_ws.maj_statut(v_id_flux, 6, sqlerrm,v_delai);
    RETURN 'ERREUR TRAITEMENT FLUX CALCUL : ' || TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS');
END F_RET_SC_CALCUL;

/**************FUNCTION F_RET_SC_CALCUL*************************/
FUNCTION F_DECOUPE(
         P_FLUX VARCHAR2,
         P_DEBUT NUMBER,
         P_LONG NUMBER,
         P_AJOUT NUMBER default 0
) RETURN VARCHAR2
IS
  V_CHAINE VARCHAR2(200);
  P_DEBUT2 NUMBER;
  cpt NUMBER:=0;
BEGIN
/*
P_INS_journal(2,'F_DECOUPE P_FLUX;' || P_FLUX);
P_INS_journal(2,'F_DECOUPE P_DEBUT;' || P_DEBUT);
P_INS_journal(2,'F_DECOUPE P_LONG;' || P_LONG);
P_INS_journal(2,'F_DECOUPE P_AJOUT;' || P_AJOUT);
*/
     P_DEBUT2 := P_DEBUT + P_AJOUT;

--P_INS_journal(2,'F_DECOUPE P_DEBUT2;' || P_DEBUT2);
     V_CHAINE := RTRIM(SUBSTR(P_FLUX,P_DEBUT2,P_LONG));

--P_INS_journal(2,'F_DECOUPE V_CHAINE;' || V_CHAINE);

     RETURN V_CHAINE;

EXCEPTION
       WHEN OTHERS THEN
          P_INS_journal(2,'F_DECOUPE;' || sqlerrm);
          RETURN null;
END F_DECOUPE;

/***************FUNCTION F_COMPLETE***********************************/
FUNCTION F_COMPLETE(
         P_CHAINE VARCHAR2,
         P_LONG NUMBER,
         P_REMP VARCHAR2 default '['
) RETURN VARCHAR2
IS
  V_CHAINE VARCHAR2(4000);
  V_REMP VARCHAR2(1);
  cpt NUMBER:=0;
BEGIN

/*
P_INS_journal(2,' P_CHAINE;' || P_CHAINE);
P_INS_journal(2,' P_REMP;' || P_REMP);
P_INS_journal(2,' P_LONG;' || P_LONG);
*/
     IF P_REMP = 'N'  THEN
        V_REMP := '0';
     ELSE
        V_REMP := '[';
     END IF;
     IF P_CHAINE is null THEN
        V_CHAINE := RPAD(V_REMP,P_LONG,V_REMP);
     ELSE
        V_CHAINE := RPAD(P_CHAINE,P_LONG,V_REMP);
     END IF;

     RETURN V_CHAINE;
EXCEPTION
       WHEN OTHERS THEN
          P_INS_journal(2,'F_COMPLETE;' || sqlerrm);
          RETURN null;
END F_COMPLETE;

/***********************************************************************/
FUNCTION F_FORMULE_SOUSCRITE(
         P_idadhesion adhesion.idadhesion%TYPE,
         P_numindiv   adhesion.numindiv%TYPE,
         P_date date default sysdate

) RETURN NUMBER
IS
  CURSOR c_garanties_adhe (c_idadhesion adhesion.idadhesion%TYPE,
                             c_numindiv   adhesion.numindiv%TYPE,
                             c_date date default sysdate)
    IS
    SELECT f.numfor
      FROM adhesion a
         , frmls f
     WHERE a.idadhesion = c_idadhesion
       AND a.numindiv = c_numindiv
       AND a.numfor = f.numfor
       AND c_date BETWEEN a.datapli AND nvl(a.datper, c_date)
       AND f.valide = 'O'
       AND f.typgar = 1
       AND f.obligatoire = 'O'
    ORDER BY f.typgar,datper desc,f.numfor asc;  --ABO 1 obligatoire 2 facultative

    Rec_adhesion c_garanties_adhe%ROWTYPE;
    cpt number;
    numfor number;

BEGIN
      cpt := 0;
      OPEN c_garanties_adhe(P_idadhesion,P_numindiv);
      LOOP
      FETCH c_garanties_adhe INTO Rec_adhesion;
        EXIT WHEN c_garanties_adhe%NOTFOUND;
             cpt := cpt + 1;
             IF cpt = 1 THEN
                numfor := Rec_adhesion.numfor;
             END IF;
      END LOOP;
      IF c_garanties_adhe%ISOPEN THEN
             CLOSE c_garanties_adhe;
      END IF;

      RETURN numfor;

EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(2,' F_FORMULE_SOUSCRITE;' || sqlerrm);
          IF c_garanties_adhe%ISOPEN THEN
             CLOSE c_garanties_adhe;
          END IF;
          RETURN 0;
END F_FORMULE_SOUSCRITE;


/***********************************************************************/
FUNCTION F_FORMAT_NUMBER(
         P_CHAINE VARCHAR2,
         P_ENTIER NUMBER,
         P_DECIMALE NUMBER
) RETURN NUMBER
IS
  P_NUMBER NUMBER;
  P_TAMPON_ENT VARCHAR2(30);
  P_TAMPON_DEC VARCHAR2(30);
BEGIN
      IF P_CHAINE is not null THEN
        P_TAMPON_ENT := SUBSTR(P_CHAINE,1,P_ENTIER);
        IF P_DECIMALE = 0 THEN
            P_NUMBER := TO_NUMBER(P_TAMPON_ENT);
        ELSE
            P_TAMPON_DEC := SUBSTR(P_CHAINE,P_ENTIER+1,P_DECIMALE);
            P_NUMBER := TO_NUMBER(P_TAMPON_ENT ||'.' || P_TAMPON_DEC);
        END IF;
        RETURN P_NUMBER;
       ELSE
        RETURN 0;
       END IF;

EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(2,'F_FORMAT_NUMBER;' || sqlerrm);
          RETURN 999999;
END F_FORMAT_NUMBER;

/***********************************************************************/
FUNCTION F_FORMAT_VARCHAR(
         P_NUMBER NUMBER,
         P_ENTIER NUMBER,
         P_DECIMALE NUMBER
) RETURN VARCHAR2
IS
  V_ENTIER     NUMBER;
  V_DECIMAL    NUMBER;
BEGIN
     V_ENTIER := TRUNC(P_NUMBER);
     V_DECIMAL := P_NUMBER - V_ENTIER;
     RETURN LPAD(to_char(V_ENTIER),P_ENTIER,'0') || RPAD(replace(to_char(V_DECIMAL),'.',''),P_DECIMALE,'0');
EXCEPTION
    WHEN OTHERS THEN
       P_INS_journal(2,'F_FORMAT_VARCHAR;' || sqlerrm);
       RETURN null;
END F_FORMAT_VARCHAR;


/***********************************************************************/
FUNCTION F_FIND_DOSSIER(
  P_ref_dossier IN dossier_sante.ref_dossier%TYPE

)RETURN VARCHAR2 IS
  V_num  dossier_sante.num_dossier%TYPE;
BEGIN

  V_num := 0;

  -- rechercher du dossier de PEC non liquidé
  SELECT NVL(MAX(num_dossier),0)
    INTO V_num
    FROM dossier_sante
   WHERE ref_dossier = P_ref_dossier
     AND numporte = g_porte
     AND num_dossier_pec is null -- non liquidé
     AND type_doss=4; -- dossier de PEC

    -- recherche du dossier liquidé si dossier de PEC non trouvé
  IF V_num = 0 THEN

    SELECT NVL(MAX(num_dossier_pec),0)
      INTO V_num
      FROM dossier_sante
     WHERE ref_dossier = P_ref_dossier
       AND numporte = g_porte
       AND type_doss=1; -- dossier de liquidation
  END IF;


  RETURN V_num;

  EXCEPTION
    WHEN no_data_found THEN
         P_INS_journal(2,'F_FIND_DOSSIER no data;' || sqlerrm);
         RETURN V_num;
    WHEN OTHERS THEN
         P_INS_journal(2,'F_FIND_DOSSIER;' || sqlerrm);
         RETURN null;
END F_FIND_DOSSIER;


/***********************************************************************/
PROCEDURE P_FIND_ASSURE_BY_NOM(
   P_nom            IN individu.nom%TYPE default null
  ,P_prenom         IN individu.prenom%TYPE default null
  ,P_datenais       IN individu.DATNAIS%TYPE
  ,P_NUMGAR         IN individu.NUMINDIV%TYPE
  ,IO_Tab_indiv     OUT TAB_T_Indiv
  ,IO_cpt           OUT NUMBER
  ,O_numassu        OUT individu.numassu%TYPE
  ,O_famille        OUT NUMBER
  ,O_erreur         OUT NUMBER
  )
IS
  -- Curseur C_Assu:
  -- Les zones à prendre en compte par l'organisme pour identifier la bonne famille sont l'association des données suivantes :
  -- Nom
  -- Nom/Prénom
  -- Nom/Date de naissance
  -- Nom/Prénom/Date de naissance

  -- -- Curseur C_Assu1:
  -- Si les zones "Nom", "Prénom", "Date de naissance" ou d'autres valeurs facultatives sont renseignées, l'organisme ne
  --doit pas les prendre en compte. Seule, la valeur du "N° de contrat" doit permettre à l'organisme d'ide ntifier la bonne famille


   CURSOR C_Assu(V_NOM IN INDIVIDU.NOM%TYPE,
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
            ayd.typadr typadrass,
            ayd.qualite qualite
       FROM individu ayd
      WHERE ayd.numassu=P_NUMGAR
    --   AND ayd.nom like UPPER(NVL(TRIM(V_NOM||'%'),ayd.nom))
    --   AND ayd.prenom like UPPER(NVL(TRIM(V_PRENOM||'%'),ayd.prenom))
    --   AND ayd.datnais = nvl (e2d(P_datenais) , ayd.datnais )
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
            ayd.typadr typadrass,
            ayd.qualite qualite
       FROM individu od, individu ayd
      WHERE od.numindiv = NVL(P_NUMGAR,od.numindiv)
       AND (
             (ayd.matorg = NVL(substr(null,0,13),ayd.matorg)   AND ayd.cless  = NVL(substr(null,14),ayd.cless))
           OR
             (ayd.matorg2 = NVL(substr(null,0,13),ayd.matorg2) AND ayd.cless2 = NVL(substr(null,14),ayd.cless2))
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
            ayd.typadr typadrass,
            ayd.qualite qualite
       FROM individu ayd
      WHERE ayd.numassu=P_NUMGAR
       AND ayd.nom like UPPER(TRIM(V_NOM||'%'))
       AND ayd.prenom like UPPER(NVL(TRIM(V_PRENOM||'%'),ayd.prenom))
       AND ayd.datnais = nvl (e2d(P_datenais) , ayd.datnais )
  ORDER BY ayd.numindiv;

  Rec_C_Assu  C_Assu%ROWTYPE;
  Rec_C_Assu1 C_Assu1%ROWTYPE;
  Rec_C_Assu2 C_Assu2%ROWTYPE;
  cpt_tab           NUMBER;
  cpt               NUMBER;
  V_NOM             individu.nom%TYPE;
  V_PRENOM          individu.prenom%TYPE;
  V_etat            NUMBER:=0;
  loc_famille_ok    NUMBER:=0;   -- Flag permettant de savoir si c'est un groupe familial ou une liste d homonymes
  loc_found         NUMBER:=0;

BEGIN

  cpt_tab := 0;
  O_erreur:=0;
  IO_Tab_indiv(cpt_tab).numindiv:= 0;

  V_NOM := replace(P_nom,'*','%');
  V_PRENOM := replace(P_prenom,'*','%');


  P_INS_journal(2,'V_NOM:' || V_NOM);
  P_INS_journal(2,'V_PRENOM:' || V_PRENOM);
  P_INS_journal(2,'P_NUMGAR:' || P_NUMGAR);
  P_INS_journal(2,'P_datenais:' || P_datenais);

  IF P_NUMGAR IS NOT NULL THEN

    OPEN C_Assu(V_NOM,V_PRENOM);
    LOOP
      FETCH C_Assu INTO Rec_C_Assu;
      EXIT WHEN C_Assu%NOTFOUND;
      cpt_tab := cpt_tab + 1;
      P_INS_journal(2,'Rec_C_Assu.numass : ' || Rec_C_Assu.numass);
      IO_Tab_indiv(cpt_tab).numindiv := Rec_C_Assu.numass;
      IO_Tab_indiv(cpt_tab).nom := Rec_C_Assu.nomass;
      IO_Tab_indiv(cpt_tab).prenom := Rec_C_Assu.prenomass;
      IO_Tab_indiv(cpt_tab).qualite := Rec_C_Assu.qualite;
      IO_Tab_indiv(cpt_tab).datnais := Rec_C_Assu.datass;
      IO_Tab_indiv(cpt_tab).rang := Rec_C_Assu.rgass;
      IO_Tab_indiv(cpt_tab).matorg := Rec_C_Assu.matass;
      IO_Tab_indiv(cpt_tab).cless := Rec_C_Assu.cleass;
      IO_Tab_indiv(cpt_tab).typadr := Rec_C_Assu.typadrass;
      O_numassu:= Rec_C_Assu.numassu;
      IF loc_famille_ok =0 THEN
        loc_famille_ok:=Rec_C_Assu.numassu;
        O_famille:=Rec_C_Assu.numassu;
      ELSE
        IF loc_famille_ok<> Rec_C_Assu.numassu THEN
          loc_famille_ok:=-1;
          O_famille:=-1;
        END IF;
      END IF;
    END LOOP;
    IF C_Assu%ISOPEN THEN
       CLOSE C_Assu;
    END IF;
  END IF;

  IF NVL(IO_Tab_indiv(cpt_tab).numindiv,0)=0 THEN

    OPEN C_Assu1(V_NOM,V_PRENOM);
    LOOP
      FETCH C_Assu1 INTO Rec_C_Assu1;
      EXIT WHEN C_Assu1%NOTFOUND;
      cpt_tab := cpt_tab + 1;

      IO_Tab_indiv(cpt_tab).numindiv := Rec_C_Assu1.numass;
      IO_Tab_indiv(cpt_tab).nom := Rec_C_Assu1.nomass;
      IO_Tab_indiv(cpt_tab).prenom := Rec_C_Assu1.prenomass;
      IO_Tab_indiv(cpt_tab).qualite := Rec_C_Assu1.qualite;
      IO_Tab_indiv(cpt_tab).datnais := Rec_C_Assu1.datass;
      IO_Tab_indiv(cpt_tab).rang := Rec_C_Assu1.rgass;
      IO_Tab_indiv(cpt_tab).matorg := Rec_C_Assu1.matass;
      IO_Tab_indiv(cpt_tab).cless := Rec_C_Assu1.cleass;
      IO_Tab_indiv(cpt_tab).typadr := Rec_C_Assu1.typadrass;
      O_numassu:= Rec_C_Assu1.numassu;
      IF loc_famille_ok =0 THEN
        loc_famille_ok:=Rec_C_Assu1.numassu;
        O_famille:=Rec_C_Assu1.numassu;
      ELSE
        IF loc_famille_ok<> Rec_C_Assu1.numassu THEN
          loc_famille_ok:=-1;
          O_famille:=-1;
        END IF;
      END IF;
    END LOOP;
    IF C_Assu1%ISOPEN THEN
       CLOSE C_Assu1;
    END IF;
  END IF;

  IF NVL(IO_Tab_indiv(cpt_tab).numindiv,0)=0 THEN

    OPEN C_Assu2(V_NOM,V_PRENOM);
    LOOP
      FETCH C_Assu2 INTO Rec_C_Assu2;
      EXIT WHEN C_Assu2%NOTFOUND;
      cpt_tab := cpt_tab + 1;

      IO_Tab_indiv(cpt_tab).numindiv := Rec_C_Assu2.numass;
      IO_Tab_indiv(cpt_tab).nom := Rec_C_Assu2.nomass;
      IO_Tab_indiv(cpt_tab).prenom := Rec_C_Assu2.prenomass;
      IO_Tab_indiv(cpt_tab).qualite := Rec_C_Assu2.qualite;
      IO_Tab_indiv(cpt_tab).datnais := Rec_C_Assu2.datass;
      IO_Tab_indiv(cpt_tab).rang := Rec_C_Assu2.rgass;
      IO_Tab_indiv(cpt_tab).matorg := Rec_C_Assu2.matass;
      IO_Tab_indiv(cpt_tab).cless := Rec_C_Assu2.cleass;
      IO_Tab_indiv(cpt_tab).typadr := Rec_C_Assu2.typadrass;
      O_numassu:= Rec_C_Assu2.numassu;
      IF loc_famille_ok =0 THEN
        loc_famille_ok:=Rec_C_Assu2.numassu;
        O_famille:=Rec_C_Assu2.numassu;
      ELSE
        IF loc_famille_ok<> Rec_C_Assu2.numassu THEN
          loc_famille_ok:=-1;
          O_famille:=-1;
        END IF;
      END IF;
    END LOOP;
    IF C_Assu2%ISOPEN THEN
       CLOSE C_Assu2;
    END IF;
  END IF;

  IO_cpt := cpt_tab;
EXCEPTION
    WHEN OTHERS THEN
         P_INS_journal(2,'P_FIND_ASSURE_BY_NOM:' || sqlerrm);
END P_FIND_ASSURE_BY_NOM;


/***********************************************************************/
FUNCTION F_CODE_TYPE_ACTE(
      loc_Tab_acte  TAB_T_ACTE
)
RETURN NUMBER
IS
  V_DOMSC VARCHAR(20);
  V_RETOUR NUMBER(2) default 0;
BEGIN

      --P_INS_journal(2,'DEB F_CODE_TYPE_ACTE');
      --P_INS_journal(2,'loc_Tab_acte(1).NATURE_PREST:'||loc_Tab_acte(1).NATURE_PREST);
      IF loc_Tab_acte.count > 0 THEN
           V_DOMSC := F_GET_TRANSCO('SC','DOMSC',loc_Tab_acte(1).NATURE_PREST,1);
           P_INS_journal(2,'F_CODE_TYPE_ACTE V_DOMSC' || V_DOMSC);
           IF V_DOMSC = '*SCSD' THEN
              V_RETOUR := 3;
           ELSIF V_DOMSC = '*SCSO'  THEN
              V_RETOUR := 2;
            ELSIF V_DOMSC = '*SCSA'  THEN
              V_RETOUR := 4;
            ELSIF V_DOMSC = '*SCSOR'  THEN
              V_RETOUR := 5;
           ELSE
              V_RETOUR := 0;
           END IF;
      END IF;
      --P_INS_journal(2,'FIN F_CODE_TYPE_ACTE');
      RETURN V_RETOUR;

EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(2,'F_CODE_TYPE_ACTE;' || sqlerrm);
          RETURN 0;
END F_CODE_TYPE_ACTE;

/***********************************************************************/
FUNCTION F_INSERT_FLUX(
          p_id_type in type_flux.id_type%type,
          p_id_flux_tiers flux.id_flux_tiers%type
) RETURN NUMBER
IS
   v_id_flux NUMBER;
BEGIN

     insert into flux (id_type, id_flux_tiers, statut, dat_maj)
     values (p_id_type,p_id_flux_tiers,1,sysdate)
     returning id_flux into v_id_flux;
     commit;

     RETURN v_id_flux;

EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(2,'F_INSERT_FLUX;' || sqlerrm);
          RETURN 0;
END F_INSERT_FLUX;

/************************************************************************/
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TRANSCO_CODFRAIS_OPTIQUE                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de transcodification d'un code acte externe en  */
/*                 code acte Arthus                                          */
/* Retour       :  Retourne les code acte et le code erreur                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_TRANSCO_CODFRAIS_OPTIQUE( P_numfor             ADHESION.NUMFOR%TYPE
                                    , P_flag_oeil          NUMBER
                                    , P_acte               T_ACTE
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2
                                    )
IS


  loc_vision   NUMBER:=0;
  loc_cpt      NUMBER:=0;

    CURSOR c_acte
      IS
  SELECT DISTINCT c.codfrais
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND c.numfor=d.numfor
     AND d.codfrais = c.rubrique
     AND n.codfrais=c.codfrais
 ORDER BY c.codfrais ;


 CURSOR c_optique_lpp
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , lpp l
   WHERE d.codfrais like 'H%'
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = P_acte.code_lpp
      AND l.codfrais=c.codfrais
      AND n.codfrais=c.codfrais
      AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
      AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)      ;

  -- curseur des verres
  CURSOR c_optique_actev (p_sphere IN NUMBER,p_cylindre IN NUMBER, P_axe IN NUMBER,P_ADDITION IN NUMBER)
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_OPTIQUE o
       , NTFRS_VISION v
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND o.codfrais =c.codfrais --suppression de la jointure left
     AND ((NVL(p_sphere  ,o.spheren_deb)  BETWEEN NVL(o.spheren_deb ,p_sphere)   AND NVL(o.spheren_fin ,p_sphere)   OR (o.spheren_deb  IS NULL AND o.spheren_fin  IS NULL))
       OR (NVL(p_sphere  ,o.spherep_deb)  BETWEEN NVL(o.spherep_deb ,p_sphere)   AND NVL(o.spherep_fin ,p_sphere)   OR (o.spherep_deb  IS NULL AND o.spherep_fin  IS NULL)))
     AND (NVL(p_cylindre,o.cylindre_deb)   BETWEEN NVL(o.cylindre_deb  ,p_cylindre)   AND NVL(o.cylindre_fin  ,p_cylindre)   OR (o.cylindre_deb   IS NULL AND o.cylindre_fin   IS NULL))
     AND (NVL(P_axe,o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,P_axe)   AND NVL(o.aminci_fin  ,P_axe)   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(P_ADDITION,o.addition_deb)   BETWEEN NVL(o.addition_deb  ,P_ADDITION)   AND NVL(o.addition_fin  ,P_ADDITION)   OR (o.addition_deb   IS NULL AND o.addition_fin   IS NULL))
     AND o.codfrais = v.codfrais (+)
     AND (v.vision = loc_vision OR v.vision IS NULL)
   ORDER BY n.codfrais, n.secu;


  CURSOR c_optique_actel (p_sphere IN NUMBER,p_cylindre IN NUMBER, P_axe IN NUMBER,P_ADDITION IN NUMBER)
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_OPTIQUE o
       , NTFRS_NGAP ng
       , RENEW_LENTILLE r
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND o.codfrais (+) =c.codfrais
     AND ng.codfrais=c.codfrais
     AND ng.CODNGAP=NVL(P_acte.NATURE_PREST,ng.CODNGAP)
     AND ((NVL(p_sphere  ,o.spheren_deb)  BETWEEN NVL(o.spheren_deb ,p_sphere)   AND NVL(o.spheren_fin ,p_sphere)   OR (o.spheren_deb  IS NULL AND o.spheren_fin  IS NULL))
       OR (NVL(p_sphere  ,o.spherep_deb)  BETWEEN NVL(o.spherep_deb ,p_sphere)   AND NVL(o.spherep_fin ,p_sphere)   OR (o.spherep_deb  IS NULL AND o.spherep_fin  IS NULL)))
     AND (NVL(p_cylindre,o.cylindre_deb)   BETWEEN NVL(o.cylindre_deb  ,p_cylindre)   AND NVL(o.cylindre_fin  ,p_cylindre)   OR (o.cylindre_deb   IS NULL AND o.cylindre_fin   IS NULL))
     AND (NVL(P_axe,o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,P_axe)   AND NVL(o.aminci_fin  ,P_axe)   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(P_ADDITION,o.addition_deb)   BETWEEN NVL(o.addition_deb  ,P_ADDITION)   AND NVL(o.addition_fin  ,P_ADDITION)   OR (o.addition_deb   IS NULL AND o.addition_fin   IS NULL))
     AND n.codfrais = r.codfrais (+)
     AND NVL(P_acte.TYPE_RENOU_LENT,r.code) = NVL(r.code,NVL(P_acte.TYPE_RENOU_LENT,r.code))
  ORDER BY n.codfrais, n.secu;


 CURSOR c_supp_monture
      IS
   SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , lpp l
   WHERE d.codfrais like 'H%'
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = P_acte.code_lpp
     AND l.codfrais=c.codfrais
     AND d.codfrais = c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND NVL(n.supp_monture,0)=1
     AND n.codfrais=c.codfrais
  ORDER BY n.codfrais ;

  rec_supp_monture c_supp_monture%ROWTYPE;

  CURSOR c_supp_verre
      IS
   SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , lpp l
   WHERE d.codfrais like 'H%'
    AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND l.code_lpp = P_acte.code_lpp
     AND l.codfrais=c.codfrais
     AND d.codfrais = c.rubrique
    AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND NVL(n.supp_verre,0)=1
     AND n.codfrais=c.codfrais
  ORDER BY n.codfrais ;

  rec_supp_verre c_supp_verre%ROWTYPE;

BEGIN

  O_acte_err_code:='00';

  -- on determine la vision
  IF P_acte.NATURE_EQUI_OPT IN (1,3) THEN
    loc_vision:=1; -- unifocale
    P_INS_journal(2,'Verre NATURE_EQUI_OPT:' || P_acte.NATURE_EQUI_OPT);
  ELSIF P_acte.NATURE_EQUI_OPT IN (2,4) THEN
    loc_vision:=3; -- multifocale
    P_INS_journal(2,'Verre NATURE_EQUI_OPT:' || P_acte.NATURE_EQUI_OPT);
  ELSE
    loc_vision:=NULL;
  END IF;
  P_INS_journal(2,'loc_vision:' || loc_vision);


  IF TRIM(P_acte.NATURE_PREST) = 'MSU' THEN
    FOR rec_supp_monture IN c_supp_monture  LOOP
    O_codfrais:=rec_supp_monture.codfrais;
    END LOOP;


  ELSIF TRIM(P_acte.NATURE_PREST) = 'VSU' THEN
    FOR rec_supp_verre IN c_supp_verre LOOP
     O_codfrais:=rec_supp_verre.codfrais;
    END LOOP;

  --FIN RKO RAC OPTIQUE gestion supplements
  --ABO 17012020 retrait de la prise en compte du LPP pour les lentilles
  ELSE
    IF P_acte.code_lpp IS NOT NULL  AND TRIM(P_acte.NATURE_PREST) NOT IN ('LEN','LEJ','LER')THEN
      -- Recherche de l'acte ARTHUS transcodé
          FOR rec_optique_lpp IN c_optique_lpp LOOP
            IF (rec_optique_lpp.secu ='O' AND P_acte.MONT_REMB>0) OR (rec_optique_lpp.secu ='N' AND P_acte.MONT_REMB=0) OR (rec_optique_lpp.secu IS NULL) THEN
              O_codfrais:=rec_optique_lpp.codfrais;
            END IF;
          END LOOP;

    ELSE --P_acte.code_lpp IS  NULL

      -- Recherche de la totalité des actes de la famille optique de la garantie dont il existe une possible trancodification
      FOR rec_acte IN c_acte LOOP
        -- Recherche de l'acte ARTHUS transcodé pour des verres
        IF TRIM(P_acte.NATURE_PREST) NOT IN ('LEN','LEJ','LER') THEN
          IF P_flag_oeil = 1 THEN
            FOR rec_optique_actev IN c_optique_actev (P_acte.OD_SPHERE,P_acte.OD_CYLINDRE, P_acte.OD_AXE,P_acte.OD_ADDITION )LOOP
              IF (rec_optique_actev.secu ='O' AND P_acte.MONT_REMB>0) OR (rec_optique_actev.secu ='N' AND P_acte.MONT_REMB=0) OR (rec_optique_actev.secu IS NULL) THEN
                O_codfrais:=rec_optique_actev.codfrais;
              END IF;
            END LOOP;
          ELSE
            FOR rec_optique_actev IN c_optique_actev (P_acte.OG_SPHERE,P_acte.OG_CYLINDRE, P_acte.OG_AXE,P_acte.OG_ADDITION )LOOP
              IF (rec_optique_actev.secu ='O' AND P_acte.MONT_REMB>0) OR (rec_optique_actev.secu ='N' AND P_acte.MONT_REMB=0) OR (rec_optique_actev.secu IS NULL) THEN
                O_codfrais:=rec_optique_actev.codfrais;
              END IF;
            END LOOP;
          END IF;
        -- Recherche de l'acte ARTHUS transcodé pour des lentilles
        ELSE
          IF P_flag_oeil = 1 THEN
            FOR rec_optique_actel IN c_optique_actel (P_acte.OD_SPHERE,P_acte.OD_CYLINDRE, P_acte.OD_AXE,P_acte.OD_ADDITION )LOOP
              IF (rec_optique_actel.secu ='O' AND P_acte.MONT_REMB>0) OR (rec_optique_actel.secu ='N' AND P_acte.MONT_REMB=0) OR (rec_optique_actel.secu IS NULL) THEN
                O_codfrais:=rec_optique_actel.codfrais;
              END IF;
            END LOOP;
          ELSE
            FOR rec_optique_actel IN c_optique_actel (P_acte.OG_SPHERE,P_acte.OG_CYLINDRE, P_acte.OG_AXE,P_acte.OG_ADDITION )LOOP
              IF (rec_optique_actel.secu ='O' AND P_acte.MONT_REMB>0) OR (rec_optique_actel.secu ='N' AND P_acte.MONT_REMB=0) OR (rec_optique_actel.secu IS NULL) THEN
                O_codfrais:=rec_optique_actel.codfrais;
              END IF;
            END LOOP;
          END IF;

        END IF;
      END LOOP;
    END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    o_acte_err_code:='99'; -- Erreur indeterminée
END P_TRANSCO_CODFRAIS_OPTIQUE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TRANSCO_CODFRAIS_DENTAIR                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de transcodification d'un code acte externe en  */
/*                 code acte Arthus                                          */
/* Retour       :  Retourne les code acte et le code erreur                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_TRANSCO_CODFRAIS_DENTAIR( P_numfor             ADHESION.NUMFOR%TYPE
                                    , P_acte               T_ACTE
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2)
IS




  CURSOR c_dentaire_acte
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_CCAM cc
       , NTFRS_DENTAIRE de
       , NTFRS_NGAP ng
   WHERE  d.numfor=P_numfor
     AND c.numfor=d.numfor
     AND d.codfrais =c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND n.dentaire=1
     AND cc.codfrais  (+)=c.codfrais
     AND ng.codfrais=c.codfrais
     AND ng.CODNGAP=NVL(P_acte.NATURE_PREST,ng.CODNGAP)
     AND de.codfrais (+) =c.codfrais
     AND (de.quantite = NVL(P_acte.QUANT_ACTE,de.quantite) or de.quantite is null)
     AND (de.coefficient >= NVL(P_acte.COEFF_ACTE,de.coefficient) or de.coefficient is null)
     AND (de.locdent1  = NVL(P_acte.LOC_DENT1,de.locdent1) OR de.locdent1  IS NULL)
     AND (de.locdent2  = NVL(P_acte.LOC_DENT2,de.locdent2) OR de.locdent2  IS NULL)
     AND (de.locdent3  = NVL(P_acte.LOC_DENT3,de.locdent3) OR de.locdent3  IS NULL)
     AND (de.locdent4  = NVL(P_acte.LOC_DENT4,de.locdent4) OR de.locdent4  IS NULL)
     AND (de.locdent5  = NVL(P_acte.LOC_DENT5,de.locdent5) OR de.locdent5  IS NULL)
     AND (de.locdent6  = NVL(P_acte.LOC_DENT6,de.locdent6) OR de.locdent6  IS NULL)
     AND (de.locdent7  = NVL(P_acte.LOC_DENT7,de.locdent7) OR de.locdent7  IS NULL)
     AND (de.locdent8  = NVL(P_acte.LOC_DENT8,de.locdent8) OR de.locdent8  IS NULL)
     AND (de.locdent9  = NVL(P_acte.LOC_DENT9,de.locdent9) OR de.locdent9  IS NULL)
     AND (de.locdent10 = NVL(P_acte.LOC_DENT10,de.locdent10) OR de.locdent10 IS NULL)
     AND (de.locdent11 = NVL(P_acte.LOC_DENT11,de.locdent11) OR de.locdent11 IS NULL)
     AND (de.locdent12 = NVL(P_acte.LOC_DENT12,de.locdent12) OR de.locdent12 IS NULL)
     AND (de.locdent13 = NVL(P_acte.LOC_DENT13,de.locdent13) OR de.locdent13 IS NULL)
     AND (de.locdent14 = NVL(P_acte.LOC_DENT14,de.locdent14) OR de.locdent14 IS NULL)
     AND (de.locdent15 = NVL(P_acte.LOC_DENT15,de.locdent15) OR de.locdent15 IS NULL)
     AND (de.locdent16 = NVL(P_acte.LOC_DENT16,de.locdent16) OR de.locdent16 IS NULL)
  ORDER BY n.codfrais, n.secu;

  rec_dentaire_acte c_dentaire_acte%ROWTYPE;



BEGIN

  O_acte_err_code:='00';
  -- Verification de la validité de la famille d acte optique sur la garantie
  -- Recherche de la totalité des actes de la famille optique de la garantie dont il existe une possible trancodification
  -- Recherche de l'acte ARTHUS transcodé
  FOR rec_dentaire_acte IN c_dentaire_acte LOOP
    IF (rec_dentaire_acte.secu ='O' AND P_acte.MONT_REMB>0) OR (rec_dentaire_acte.secu ='N' AND P_acte.MONT_REMB=0) OR (rec_dentaire_acte.secu IS NULL) THEN
         O_codfrais:=rec_dentaire_acte.codfrais;
    END IF;
  END LOOP;

 -- P_INS_journal(2,'O_codfrais:' || O_codfrais);

EXCEPTION
  WHEN OTHERS THEN
    o_acte_err_code:='99'; -- Erreur indeterminée
END P_TRANSCO_CODFRAIS_DENTAIR;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TRANSCO_CODFRAIS_AUDITIF                                */
/* Type         :  Public                                                    */
/* Description  :  procedure de transcodification d'un code acte externe en  */
/*                 code acte Arthus                                          */
/* Retour       :  Retourne les code acte et le code erreur                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_TRANSCO_CODFRAIS_AUDITIF( P_numfor             ADHESION.NUMFOR%TYPE
                                     , P_acte               T_ACTE
                                    , O_codfrais           OUT SINISTRE_SANTE.codfrais%TYPE
                                    , O_acte_err_code      OUT VARCHAR2)
IS


  /*CURSOR c_famille_acte     --RKO 02122020
      IS
  SELECT d.codfrais
    FROM DEFRUB d
   WHERE d.codfrais like 'K%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor;

  rec_famille c_famille_acte%ROWTYPE;  */

  CURSOR c_acte
      IS
  SELECT DISTINCT c.codfrais
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , lpp l    --RKO RAC AUDIO
--       , NTFRS a
   WHERE d.codfrais like 'K%'  -- famille audiologie
     AND d.numfor=P_numfor
      AND l.code_lpp = P_acte.code_lpp
      AND l.codfrais=c.codfrais
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)   --RKO
     AND c.numfor=d.numfor
--     AND a.codfrais = c.codfrais
     AND d.codfrais = c.rubrique
--     AND d.codfrais =a.rubrique
     AND n.codfrais=c.codfrais
 ORDER BY c.codfrais ;

  rec_acte c_acte%ROWTYPE;


  CURSOR c_auditif_acte
      IS
    SELECT DISTINCT n.codfrais
                  , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       , NTFRS_AUDITIF de
       --, NTFRS_NGAP ng-- RKO RAC AUDIO
       , lpp l --RKO RAC AUDIO
   WHERE d.codfrais like 'K%'  -- On traite uniquement les famille du dentaire
     AND d.numfor=P_numfor --104211--
      AND l.code_lpp =P_acte.code_lpp --in (2369117,2351057)
      AND l.codfrais=c.codfrais
     AND c.numfor=d.numfor
     AND d.codfrais =c.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND SYSDATE BETWEEN d.datapli AND NVL(d.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND n.auditif=1
     --AND ng.codfrais=c.codfrais
     --AND ng.CODNGAP=NVL(P_acte.NATURE_PREST,ng.CODNGAP)
     AND de.codfrais (+) =c.codfrais
     AND (de.quantite = NVL(P_acte.QUANT_ACTE,de.quantite) or de.quantite is null)
  ORDER BY n.codfrais, n.secu;

  rec_auditif_acte c_auditif_acte%ROWTYPE;



BEGIN

  O_acte_err_code:='00';
  -- Verification de la validité de la famille d acte optique sur la garantie
  --FOR rec_famille IN c_famille_acte LOOP   RKO RAC AUDIO
    -- Recherche de la totalité des actes de la famille optique de la garantie dont il existe une possible trancodification
  IF P_acte.code_lpp IS NOT NULL THEN
    FOR rec_acte IN c_acte LOOP
      -- Recherche de l'acte ARTHUS transcodé
      FOR rec_auditif_acte IN c_auditif_acte LOOP
        IF (rec_auditif_acte.secu ='O' AND P_acte.MONT_REMB>0) OR (rec_auditif_acte.secu ='N' AND P_acte.MONT_REMB=0) OR (rec_auditif_acte.secu IS NULL) THEN
          --PK_SPSANTE.P_INS_journal(2,' dans if secu rec_optique_detailv°:'||rec_optique_detailv.codfrais);
             P_INS_journal(1,'Acte trouvé santeclair : ' || rec_auditif_acte.codfrais);
             O_codfrais:=rec_auditif_acte.codfrais;
        END IF;
      END LOOP;
    END LOOP;
  END IF;
 -- END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    o_acte_err_code:='99'; -- Erreur indeterminée
END P_TRANSCO_CODFRAIS_AUDITIF;

/***********************************************************************/
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  --'notest', 1, 'test', 2, 'totale', 3
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


/***********************************************************************/
FUNCTION F_TAB_ACTE_ERREUR(P_Tab_acte  TAB_T_ACTE,
                           P_LIBELLE_RETOUR_ACTE VARCHAR2,
                           P_TRAITEMENT VARCHAR2 default null
) RETURN TAB_T_RET_ACTE
IS
 loc_ret_Tab_acte TAB_T_RET_ACTE;
BEGIN
     FOR compteur IN 1 .. 32 LOOP
        IF P_TRAITEMENT = 'PAR' THEN
          loc_ret_Tab_acte(compteur).NAT_PRESTATION      := null;
          loc_ret_Tab_acte(compteur).FORMULE_SOUS1       := null;
          loc_ret_Tab_acte(compteur).FORMULE_SOUS2       := null;
          loc_ret_Tab_acte(compteur).LIBELLE_RETOUR      := null;
          loc_ret_Tab_acte(compteur).MESS_SUPP           := null;
          loc_ret_Tab_acte(compteur).MT_DEP              := null;
          loc_ret_Tab_acte(compteur).MT_REMB_RO          := null;
          loc_ret_Tab_acte(compteur).MT_PART_COMP        := null;
          loc_ret_Tab_acte(compteur).MT_REMB_RC          := null;
          loc_ret_Tab_acte(compteur).RESTE_A_CHARGE      := null;
          loc_ret_Tab_acte(compteur).QUANTITE_ACTE       := null;
          loc_ret_Tab_acte(compteur).FILLER1             := null;
          loc_ret_Tab_acte(compteur).QUANTITE_COMP_ACTE  := null;
          loc_ret_Tab_acte(compteur).CODE_CCAM           := null;
          loc_ret_Tab_acte(compteur).FILLER2             := null;
          loc_ret_Tab_acte(compteur).TYPE_ENREG          := null;
        ELSE
          loc_ret_Tab_acte(compteur).NAT_PRESTATION      := P_Tab_acte(compteur).NATURE_PREST;
          loc_ret_Tab_acte(compteur).FORMULE_SOUS1       := null;
          loc_ret_Tab_acte(compteur).FORMULE_SOUS2       := null;
          IF P_Tab_acte(compteur).NATURE_PREST is not null THEN
             loc_ret_Tab_acte(compteur).LIBELLE_RETOUR   := P_LIBELLE_RETOUR_ACTE;
          ELSE
             loc_ret_Tab_acte(compteur).LIBELLE_RETOUR   := null;
          END IF;
          loc_ret_Tab_acte(compteur).MESS_SUPP           := null;
          loc_ret_Tab_acte(compteur).MT_DEP              := P_Tab_acte(compteur).MONTANT_DEP;
          loc_ret_Tab_acte(compteur).MT_REMB_RO          := P_Tab_acte(compteur).MONT_REMB;
          loc_ret_Tab_acte(compteur).MT_PART_COMP        := null;
          loc_ret_Tab_acte(compteur).MT_REMB_RC          := null;
          loc_ret_Tab_acte(compteur).RESTE_A_CHARGE      := P_Tab_acte(compteur).MONTANT_DEP-P_Tab_acte(compteur).MONT_REMB;
          loc_ret_Tab_acte(compteur).QUANTITE_ACTE       := null;
          loc_ret_Tab_acte(compteur).FILLER1             := null;
          loc_ret_Tab_acte(compteur).QUANTITE_COMP_ACTE  := null;
          loc_ret_Tab_acte(compteur).CODE_CCAM           := null;
          loc_ret_Tab_acte(compteur).FILLER2             := null;
          loc_ret_Tab_acte(compteur).TYPE_ENREG         := null;
        END IF;

   END LOOP;

   RETURN loc_ret_Tab_acte;
EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(2,'F_TAB_ACTE_ERREUR;' || sqlerrm);
          RETURN loc_ret_Tab_acte;
END F_TAB_ACTE_ERREUR;

END PK_WS_BACK_SANTECLAIR;
/
