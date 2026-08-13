CREATE OR REPLACE PACKAGE ARTHUS."PK_IMPORT_AFFIL_DSN"
AS
/*============================================================================*/
/* PACKAGE      : PK_IMPORT_AFFIL_DSN.sql                                     */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : TLE                                                         */
/* Création     : 17/03/2015                                                  */
/* Description  : Package permettant l import d un fichier contenant des      */
/*                fichiers DSN dans Arthus ainsi que l intégration des données*/
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : PHA 06/06/2017 M0005316: Fichier manquant en BDD            */
/*                               mais présent dans DSN_DONE                   */
/*============================================================================*/

PROCEDURE IMPORT_AFFIL_DSN(
      i_Porte      IN AFFIL_PORTE.NUMPORTE%TYPE ,
      i_echange  IN PORTE_ECHANGE.IDECHANGE%TYPE,
      i_fichier    IN VARCHAR2 ,
      i_session    IN JOURNAL_ADM.ID_SESSION%TYPE ,
      i_traitement IN JOURNAL_ADM.NOM_TRAITEMENT%TYPE ,
      i_idligne    IN OUT JOURNAL_ADM.IDLIGNE%TYPE ,
      o_remise    OUT PORTE_REMISE.NUMREMISE%TYPE);



PROCEDURE P_INS_journal(P_niv in NUMBER,
      p_journal IN OUT JOURNAL_ADM%ROWTYPE,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

-- ------------------------------------------------- Fin des procedures publiques --
END PK_IMPORT_AFFIL_DSN;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_IMPORT_AFFIL_DSN
AS
  /*============================================================================*/
  /* PACKAGE      : PK_IMPORT_AFFIL_DSN.sql                                     */
  /* Domaine      : Production                                                  */
  /* Version      : V1.0                                                        */
  /* Auteur       : TLE                                                         */
  /* Création     : 17/03/2015                                                  */
  /* Description  : Package permettant l import d un fichier contenant des      */
  /*                fichiers DSN dans Arthus ainsi que l intégration des données*/
  /*============================================================================*/
  /* Evolution    :                                                             */
  /* Auteur       :                                                             */
  /* Date         :                                                             */
  /* Commentaire  :                                                             */
  /*============================================================================*/
  /* Correction   :                                                             */
  /*============================================================================*/
  -- -- TYPES PRIVEES ------------------------------------------------------
  --
  -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
  --
  -- -- PROCEDURES ET FONCTIONS PRIVEES  -----------------------------------------
  PROCEDURE IMPORT_AFFIL_AF02(
      i_Porte      IN AFFIL_PORTE.NUMPORTE%TYPE ,
      i_fichier    IN UTL_FILE.file_type ,
      i_nomfichier IN AFFIL_FICHIER.FICHIER%TYPE,
      i_echange  IN PORTE_ECHANGE.IDECHANGE%TYPE,
      i_nature     IN NUMBER,
      i_journal    IN OUT JOURNAL_ADM%ROWTYPE ,
      i_remise     IN  PORTE_REMISE%ROWTYPE,
      o_ano        OUT NUMBER);

  PROCEDURE p_ctrlFichierAffil(
      i_repertoire IN VARCHAR2,
      i_fichier    IN OUT VARCHAR2,
      i_format     IN NUMBER,
      o_erreur OUT VARCHAR2);
  PROCEDURE P_ANNUL_REMPLACE( P_AFFIL_FICHIER AFFIL_FICHIER%ROWTYPE ,
                            P_remise porte_remise.numremise%TYPE,
                            i_session     IN       JOURNAL_ADM.ID_SESSION%TYPE,
                            i_traitement  IN       JOURNAL_ADM.NOM_TRAITEMENT%TYPE,
                            i_idligne     IN OUT   JOURNAL_ADM.IDLIGNE%TYPE,
                            i_stop        OUT VARCHAR2);
  -- -- Déclaration des variables globales   ----------------------------------
  g_numutil                   PORTE_PARAM.NUMUTIL%TYPE:=0;
  exc_fin_remise EXCEPTION;
  exc_ins_remise EXCEPTION;
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
/* Nom          :  IMPORT_AFFIL_DSN                                          */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l  import d un fichier contenant des      */
/*                 affiliations dans ainsi que l intégration des données     */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichier , fichier des affiliations  ou DSN              */
/*                 i_Entreprise, contenu dans le nom du fichier              */
/*                 i_Trimestre, contenu dans le nom du fichier               */
/* Retour       :  o_remise, Remise importée                                 */
/*---------------------------------------------------------------------------*/

PROCEDURE IMPORT_AFFIL_DSN(
      i_Porte      IN AFFIL_PORTE.NUMPORTE%TYPE ,
      i_echange    IN PORTE_ECHANGE.IDECHANGE%TYPE,
      i_fichier    IN VARCHAR2 ,
      i_session    IN JOURNAL_ADM.ID_SESSION%TYPE ,
      i_traitement IN JOURNAL_ADM.NOM_TRAITEMENT%TYPE ,
      i_idligne    IN OUT JOURNAL_ADM.IDLIGNE%TYPE ,
      o_remise    OUT PORTE_REMISE.NUMREMISE%TYPE)
IS
  loc_ok           NUMBER:=0;
  Loc_repertoire   TYP_BATCH.REPERTOIRE%TYPE:='IMPORT';
  loc_fichier      VARCHAR2(50);
  loc_numremise    AFFIL_PORTE.NUMREMISE%TYPE:=NULL;
  loc_contratsal   AFFIL_PORTE_ADH.CONTRAT_SAL%TYPE;
  loc_AFFIL_PORTE_CNTRT         AFFIL_PORTE_CNTRT%ROWTYPE;
  loc_AFFIL_PORTE_CNTRT_empty   AFFIL_PORTE_CNTRT%ROWTYPE;
  loc_AFFIL_PORTE               AFFIL_PORTE%ROWTYPE;
  loc_AFFIL_PORTE_empty         AFFIL_PORTE%ROWTYPE;
  loc_AFFIL_PORTE_init          AFFIL_PORTE%ROWTYPE;
  loc_AFFIL_PORTE_ADH           AFFIL_PORTE_ADH%ROWTYPE;
  loc_AFFIL_PORTE_ADH_empty     AFFIL_PORTE_ADH%ROWTYPE;
  loc_AFFIL_PORTE_AYD           AFFIL_PORTE_AYD%ROWTYPE;
  loc_AFFIL_PORTE_AYD_empty     AFFIL_PORTE_AYD%ROWTYPE;

  loc_affil_ano                 AFFIL_ANO%ROWTYPE;


  loc_AFFIL_PORTE_QTTC              AFFIL_PORTE_QTTC%ROWTYPE;
  loc_AFFIL_PORTE_QTTC_empty        AFFIL_PORTE_QTTC%ROWTYPE;
  loc_AFFIL_PORTE_QTTC_INDIV        AFFIL_PORTE_QTTC_INDIV%ROWTYPE;
  loc_AFFIL_PORTE_QTTC_IDV_empty    AFFIL_PORTE_QTTC_INDIV%ROWTYPE;
  loc_AFFIL_PORTE_QTTC_ELT          AFFIL_PORTE_QTTC_ELT%ROWTYPE;
  loc_AFFIL_PORTE_QTTC_ELT_empty    AFFIL_PORTE_QTTC_ELT%ROWTYPE;
  loc_AFFIL_PORTE_ARRET             AFFIL_PORTE_ARRET%ROWTYPE;
  loc_AFFIL_PORTE_ARRET_empty       AFFIL_PORTE_ARRET%ROWTYPE;
  loc_AFFIL_PORTE_PAIEMENT          AFFIL_PORTE_PAIEMENT%ROWTYPE;
  loc_AFFIL_PORTE_PAIEMENT_empty    AFFIL_PORTE_PAIEMENT%ROWTYPE;
--  loc_AFFIL_PORTE_PMT_COMP          AFFIL_PORTE_PAIEMENT_COMPOSANT%ROWTYPE;
--  loc_AFFIL_PORTE_PMT_COMP_empty    AFFIL_PORTE_PAIEMENT_COMPOSANT%ROWTYPE;

  loc_PORTE_REMISE              PORTE_REMISE%ROWTYPE;
  loc_AFFIL_FICHIER             AFFIL_FICHIER%ROWTYPE;
  loc_AFFIL_FICHIER_init        AFFIL_FICHIER%ROWTYPE;
  loc_journal                   JOURNAL_ADM%ROWTYPE;

  TYPE tab_AFFIL_PORTE_AYD      IS TABLE OF AFFIL_PORTE_AYD%ROWTYPE   INDEX BY binary_integer ;
  TYPE tab_AFFIL_PORTE_CNTRT    IS TABLE OF AFFIL_PORTE_CNTRT%ROWTYPE INDEX BY VARCHAR2(50) ;
  TYPE tab_AFFIL_PORTE_ADH      IS TABLE OF AFFIL_PORTE_ADH%ROWTYPE   INDEX BY binary_integer ;
  --Type des Tableaux du LOT2B [Intégration des cotisations]
  TYPE tab_AFFIL_PORTE_QTTC        IS TABLE OF AFFIL_PORTE_QTTC%ROWTYPE       INDEX BY binary_integer;
  TYPE tab_AFFIL_PORTE_QTTC_INDIV  IS TABLE OF AFFIL_PORTE_QTTC_INDIV%ROWTYPE INDEX BY binary_integer;
  TYPE tab_AFFIL_PORTE_QTTC_ELT    IS TABLE OF AFFIL_PORTE_QTTC_ELT%ROWTYPE   INDEX BY binary_integer;
  TYPE tab_AFFIL_PORTE_ARRET       IS TABLE OF AFFIL_PORTE_ARRET%ROWTYPE      INDEX By binary_integer;
  TYPE tab_AFFIL_PORTE_PAIEMENT     IS TABLE OF AFFIL_PORTE_PAIEMENT%ROWTYPE   INDEX By binary_integer;
--  TYPE tab_AFFIL_PORTE_PMT_COMP    IS TABLE OF AFFIL_PORTE_PAIEMENT_COMPOSANT%ROWTYPE   INDEX By binary_integer;

  l_tab_AFFIL_PORTE_AYD      tab_AFFIL_PORTE_AYD;
  l_tab_AFFIL_PORTE_CNTRT    tab_AFFIL_PORTE_CNTRT;
  l_tab_AFFIL_PORTE_ADH      tab_AFFIL_PORTE_ADH;
  --Tableaux du LOT2B [Intégration des cotisations]
  l_tab_AFFIL_PORTE_QTTC     tab_AFFIL_PORTE_QTTC;
  l_tab_AFFIL_PORTE_QTTC_INDIV     tab_AFFIL_PORTE_QTTC_INDIV;
  l_tab_AFFIL_PORTE_QTTC_ELT tab_AFFIL_PORTE_QTTC_ELT;
  l_tab_AFFIL_PORTE_ARRET     tab_AFFIL_PORTE_ARRET;
  l_tab_AFFIL_PORTE_PAIEMENT tab_AFFIL_PORTE_PAIEMENT;
--  l_tab_AFFIL_PORTE_PMT_COMP tab_AFFIL_PORTE_PMT_COMP;

  loc_ano NUMBER:=0;
  loc_erreur VARCHAR2(2000);
  loc_nature NUMBER(3);
  loc_format PORTE_ECHANGE.TYPE_FORMAT%TYPE;
  loc_DSN_OUT NUMBER:=0;

  exc_nature          EXCEPTION;
  exc_devise          EXCEPTION;
  exc_code_fichier    EXCEPTION;
  exc_doublon_fichier EXCEPTION;
  exc_type_envoi      EXCEPTION;
  exc_remise_importe  EXCEPTION;

  Go_fin_fichier NUMBER;
  nb_fichier     NUMBER; --nombre de fichier dans une remise


  --TO DO à enlever g_niv_msg en haut du package

  -- variable utilisation fichier
  h_fichier UTL_FILE.file_type;
  fic_cpt_ligne NUMBER := 0;
  fic_getline   BOOLEAN;

  -- variables import fichier
  s_ligne            VARCHAR2(5000):='';
  v_balise           VARCHAR2(20);
  v_norme            VARCHAR2(2);
  v_bloc             VARCHAR2(2);
  v_bloc_prec        VARCHAR2(2);
  v_rubrique         NUMBER(3);
  v_rubrique_prec    NUMBER(3);
  v_entite           VARCHAR2(3);
  v_code_fichier     VARCHAR2(2);
  v_doublon_fichier porte_remise.NUMREMISE%TYPE:=0;
  v_fichier_annul   porte_remise.NUMREMISE%TYPE;
  v_num_ordre_annul affil_fichier.NUM_ORDRE%TYPE; -- M0006328
  v_stop            VARCHAR2(300);

  cpt_numligne          affil_porte.numligne%TYPE;
  cpt_ayd               NUMBER(9);
  cpt_adh               NUMBER(9);
  cpt_cntrt             NUMBER(9);
  stmt                  VARCHAR2(600);
  cpt_bad_param         NUMBER:=0;--compteur de rejet
  cpt_ano               NUMBER:=0;
  cpt_fic               NUMBER:=0;
  idx_qttc              NUMBER:=0;
  idx_qttc_indiv        NUMBER:=0;
  idx_qttc_elt          NUMBER:=0;
  idx_arret             NUMBER:=0;
  idx_paiement          NUMBER:=0;
  idx_paiement_comp     NUMBER:=0;
  l_erreur              VARCHAR2(100);


  cpt_ligne_fichier NUMBER(9);

  isBase BOOLEAN;
  isCOT  BOOLEAN;


  tab_entite_fichier   PK_CTRL_AFFIL.tab_PORTE_ENTITE;
  tab_entite_affil     PK_CTRL_AFFIL.tab_PORTE_ENTITE;
  tab_entite_adh       PK_CTRL_AFFIL.tab_PORTE_ENTITE;
  tab_entite_ayd       PK_CTRL_AFFIL.tab_PORTE_ENTITE;
  tab_entite_cntrt     PK_CTRL_AFFIL.tab_PORTE_ENTITE;


  tab_entite_qttc       PK_CTRL_AFFIL.tab_PORTE_ENTITE;
  tab_entite_qttc_indiv PK_CTRL_AFFIL.tab_PORTE_ENTITE;
  tab_entite_qttc_elt   PK_CTRL_AFFIL.tab_PORTE_ENTITE;
  tab_entite_arret      PK_CTRL_AFFIL.tab_PORTE_ENTITE;
  tab_entite_paiement   PK_CTRL_AFFIL.tab_PORTE_ENTITE;
--  tab_entite_paiement_composant  PK_CTRL_AFFIL.tab_PORTE_ENTITE;

  -- CONTROLE DES REGELES DE GESTION
  -- Déclaration
  Tab_RG  PK_CTRL_AFFIL.T_RG_TAB;

  CURSOR C_annulFichier (p_remise  porte_remise.numremise%TYPE , p_porte porte_remise.numporte%TYPE)IS
    SELECT distinct af.*  FROM AFFIL_FICHIER af
    WHERE af.NUMREMISE = p_remise
    AND   af.NUMPORTE = p_porte
    AND (af.NUM_ANNUL IS NOT NULL
         OR af.TYPE IN(3,4))
    ORDER BY af.NUM_ORDRE;

  loc_num_ordre_prec      affil_fichier.num_ordre%TYPE;
  loc_ligne           JOURNAL_ADM.IDLIGNE%TYPE;

  v_doublon_remise     affil_fichier.NUMREMISE%TYPE:=0;
  v_doublon_num_ordre  affil_fichier.num_ordre%TYPE:=0;

  BEGIN


    loc_journal.id_session := i_session;
    loc_journal.idligne := i_idligne;
    loc_journal.nom_traitement := i_traitement;
    BEGIN
      SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3), param1
      INTO loc_journal.niv_msg, loc_nature
      FROM PARAM_BATCH
      WHERE NUMBATCH = loc_journal.nom_traitement;
    EXCEPTION
      WHEN OTHERS THEN loc_journal.niv_msg:=3;
    END;

    loc_fichier:=i_fichier;
    P_INS_journal(1, loc_journal, 'DEBUT PK_IMPORT_AFFIL_DSN.IMPORT_AFFIL_DSN le '||TO_CHAR(SYSDATE));
    P_INS_journal(1, loc_journal, 'Nom du fichier '||i_fichier );

    --------------- Récupération de l utilisateur de la porte  ------------------------
    g_numutil:=PK_CTRL_AFFIL.F_FIND_PORTE_NUMUTIL(i_Porte);
    P_INS_journal(3, loc_journal, 'g_numutil '||TO_CHAR(g_numutil));

    --------------------------------------------------------------------------------------------------------------------------------------
    -- Controle de la structure globale du fichier et contrôle d'unicité par rapport au nom du fichier physique
    --------------------------------------------------------------------------------------------------------------------------------------
    BEGIN
      SELECT repertoire INTO Loc_repertoire
      FROM TYP_BATCH
      WHERE BATCHID=i_traitement;
    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1, loc_journal,'Répertoire d''importation non paramétré');
        RAISE exc_fin_remise;
    END ;

    BEGIN
      SELECT type_format into loc_format
      FROM PORTE_ECHANGE e
      WHERE e.idechange = i_echange;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

    p_ctrlFichierAffil (Loc_repertoire, loc_fichier,loc_format, loc_erreur);
    IF loc_erreur IS NOT NULL THEN
      P_INS_journal(1, loc_journal,loc_erreur);
      RAISE exc_fin_remise;
    END IF;


    -- LECTURE DU FICHIER DSN LIGNE A LIGNE ET INSERTION DES DONNEES DANS LES TABLES TEMPORAIRES
    ------------------- Ouverture du fichier ------------------------------------
    h_fichier := UTL_FILE.fopen (Loc_repertoire, loc_fichier, 'R', 32767);
    ---------------- Parcours de chaque ligne du fichier ------------------------
    P_INS_journal(3, loc_journal, 'Ouverture du fichier');
    --nbligne:=0;
    cpt_numligne      :=0;
    cpt_ayd           :=0;
    cpt_cntrt         :=400;--initialisé de manière à permettre la coabitation P2 et P3 sinon insert clef impossible
    cpt_adh           :=0;
    cpt_ano           :=0;
    idx_qttc          :=0;
    idx_qttc_indiv    :=0;
    idx_qttc_elt      :=0;
    idx_arret         :=0;
    idx_paiement      :=0;
    idx_paiement_comp :=0;

    isBase :=FALSE;
    isCOT  :=FALSE;

    cpt_ligne_fichier :=0;
    Go_fin_fichier:=0;
    loc_DSN_OUT := 0;

    -- création de la porte_remise
    -- Initialise PORTE_REMISE de la remise en cours
    SELECT SEQ_AFFIL_PORTE.NEXTVAL
    INTO loc_PORTE_REMISE.numremise
    FROM DUAL;
    P_INS_journal(1, loc_journal,'Importation du fichier dans la remise :'||loc_PORTE_REMISE.numremise);

    loc_PORTE_REMISE.NUMPORTE   := i_Porte;
    loc_PORTE_REMISE.DATEREMISE := SYSDATE;
    loc_PORTE_REMISE.DATEPORTE  := NULL; --stocjée dans affil_fichier.datefic
    loc_PORTE_REMISE.BATCH      := i_traitement;
    loc_PORTE_REMISE.NATURE     := NULL; -- stockée dans affil_fichier
    loc_PORTE_REMISE.REF_EXT    := i_fichier;
    loc_AFFIL_FICHIER_init.NUMREMISE := loc_PORTE_REMISE.NUMREMISE;
    loc_AFFIL_FICHIER_init.NUMPORTE  := loc_PORTE_REMISE.NUMPORTE;
    loc_AFFIL_FICHIER_init.FICHIER   := i_fichier;

    --unicité de porte_remise sur le nom de fichier uniquement
    SELECT max(Numremise) INTO loc_ok
    FROM affil_fichier
    WHERE UPPER(fichier) = UPPER(i_fichier)
    AND numporte = i_porte;

    IF loc_ok > 0 THEN
      RAISE exc_remise_importe;
    END IF;


    /*INSERTION DE PORTE_REMISE 1 remise par fichier physique*/
    IF NOT PK_CTRL_AFFIL.F_INS_PORTE_REMISE(loc_PORTE_REMISE) THEN
      RAISE exc_ins_remise;
    END IF;
    --TO DO controle unicité porte REMISE !!!!

    --initialisaiton de l'objet affil_porte
    loc_AFFIL_PORTE_init.numremise := loc_PORTE_REMISE.numremise;
    loc_AFFIL_PORTE_init.numporte  := i_Porte;
    loc_AFFIL_PORTE_init.datrait   := loc_PORTE_REMISE.DATEREMISE;
    loc_AFFIL_PORTE_init.numligne  := 0;
    loc_AFFIL_PORTE_init.etat      := 2;
    loc_AFFIL_PORTE_init.username_forcage:= g_numutil;



    --chargement des structures des entites
    tab_entite_fichier := PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_FICHIER');
    tab_entite_affil   := PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE');
    tab_entite_adh     := PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE_ADH');
    tab_entite_ayd     := PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE_AYD');
    tab_entite_cntrt   := PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE_CNTRT');

    tab_entite_qttc         :=  PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE_QTTC');
    tab_entite_qttc_indiv   :=  PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE_QTTC_INDIV');
    tab_entite_qttc_elt     :=  PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE_QTTC_ELT');
    tab_entite_arret        :=  PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE_ARRET');
    tab_entite_paiement     :=  PK_CTRL_AFFIL.F_TAB_TYPE_ENTITE(i_echange,i_Porte,'AFFIL_PORTE_PAIEMENT');

    --remplissage du tableau des règles de gestion
    Tab_RG := PK_CTRL_AFFIL.F_GET_REG_AFFIL(i_Porte);



  IF i_traitement='AF02T' THEN
    IMPORT_AFFIL_AF02(
       i_Porte       => i_Porte ,
       i_fichier     => h_fichier,
       i_nomfichier  => i_fichier,
       i_echange     => i_echange,
       i_nature      => loc_nature,
       i_journal     => loc_journal ,
       i_remise      => loc_PORTE_REMISE,
       o_ano         => cpt_ano);
  ELSE
    v_bloc_prec := '00';
    v_rubrique_prec :=1;
    cpt_fic:=1;
    --parcourt du fichier
    WHILE PK_FICHIER.fGetLine(h_fichier,s_ligne) LOOP
      BEGIN
        v_balise := SUBSTR(s_ligne,0,14 );
        v_bloc   := SUBSTR(s_ligne,9,2 );
        v_rubrique := to_number(SUBSTR(s_ligne,12,3 ));
        v_entite := SUBSTR(s_ligne,5,3 );
        cpt_ligne_fichier := cpt_ligne_fichier + 1;

        IF (Go_fin_fichier =0 OR v_bloc ='90' OR v_bloc ='15') AND v_entite='G00'  THEN
          /*****************************************************/
          /************    AFFECTATION TABLEAUX   *************/
          /*****************************************************/
          /* les affectations se font uniquement en arrivant sur le bloc suivant de la norme
          ou sur le même bloc mais avec un numéro de rubrique inférieure*/
          /****     AFFECTATION AYD*********/
          IF Go_fin_fichier =0  AND  v_bloc_prec = '73' AND v_rubrique <= v_rubrique_prec THEN
            cpt_ayd                      := cpt_ayd+1;
            loc_AFFIL_PORTE_AYD.NUMAYD   := cpt_ayd;
            loc_AFFIL_PORTE_AYD.numremise:= loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_AYD.numporte:= loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_AYD.numligne := loc_AFFIL_PORTE.numligne;
            l_tab_AFFIL_PORTE_AYD(loc_AFFIL_PORTE_AYD.numayd):= loc_AFFIL_PORTE_AYD;
          END IF;

          IF Go_fin_fichier =0  AND  /*(v_bloc_prec = '20' or*/ v_bloc_prec= '55'/*)*/ AND v_rubrique <= v_rubrique_prec   THEN     -- CLI le 28/03/2018 suppresion du bloc 20 qui insérait des lignes avec un montant a null
            idx_paiement:=idx_paiement+1;
            loc_AFFIL_PORTE_PAIEMENT.NUMREMISE    :=  loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_PAIEMENT.NUMPORTE     :=   loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_PAIEMENT.IDPAIEMENT := idx_paiement;
            loc_AFFIL_PORTE_PAIEMENT.ENTREPRISE   :=  loc_AFFIL_PORTE_CNTRT.ENTREPRISE;
            loc_AFFIL_PORTE_PAIEMENT.ETABLI    :=  loc_AFFIL_PORTE_CNTRT.ETABLI;
            loc_AFFIL_PORTE_PAIEMENT.NUM_ORDRE :=  loc_AFFIL_PORTE_CNTRT.NUM_ORDRE;
            loc_AFFIL_PORTE_PAIEMENT.ORGN      :=  NVL(loc_AFFIL_PORTE_CNTRT.ORGN, '0');
            l_tab_AFFIL_PORTE_PAIEMENT(idx_paiement):=loc_AFFIL_PORTE_PAIEMENT;
          END IF;


          IF Go_fin_fichier =0  AND v_bloc_prec = '60' AND v_rubrique <= v_rubrique_prec   THEN
            idx_arret:=idx_arret+1;
            loc_AFFIL_PORTE_ARRET.NUMREMISE    :=  loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_ARRET.NUMPORTE     :=  loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_ARRET.NUMLIGNE     :=  loc_AFFIL_PORTE.NUMLIGNE;
            l_tab_AFFIL_PORTE_ARRET(idx_arret):=loc_AFFIL_PORTE_ARRET;
          END IF;

          /****     AFFECTATION QTTC uniquement si la base de cotisation concerne notre domaine*********/
          IF Go_fin_fichier =0 AND  v_bloc_prec = '78' AND v_rubrique <= v_rubrique_prec  AND isBASE THEN
            idx_qttc:=idx_qttc+1;
            loc_AFFIL_PORTE_QTTC.NUM_QTTC   := idx_qttc;
            loc_AFFIL_PORTE_QTTC.NUMREMISE  :=  loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_QTTC.NUMPORTE :=  loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_QTTC.NUMLIGNE :=  loc_AFFIL_PORTE.NUMLIGNE;
            FOR i in 1..l_tab_AFFIL_PORTE_ADH.count loop
              IF l_tab_AFFIL_PORTE_ADH(i).ref_ext_adh = loc_AFFIL_PORTE_QTTC.ref_ext_adh THEN
                loc_AFFIL_PORTE_QTTC.REF_EXT_CNTRT := l_tab_AFFIL_PORTE_ADH(i).REF_EXT_CNTRT;
              END IF;
            END LOOP;
            loc_AFFIL_PORTE_QTTC.STATUT   :=  2;  -- A intégré
            l_tab_AFFIL_PORTE_QTTC(idx_qttc):=loc_AFFIL_PORTE_QTTC;
          END IF;

          IF Go_fin_fichier =0  AND  v_bloc_prec = '79' AND v_rubrique <= v_rubrique_prec  AND isBASE THEN
            idx_qttc_elt:=idx_qttc_elt+1;
            loc_AFFIL_PORTE_QTTC_ELT.NUMREMISE    :=  loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_QTTC_ELT.NUMPORTE     :=  loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_QTTC_ELT.NUMLIGNE     :=  loc_AFFIL_PORTE.NUMLIGNE;
            loc_AFFIL_PORTE_QTTC_ELT.NUM_QTTC     :=  loc_AFFIL_PORTE_QTTC.NUM_QTTC ;
            loc_AFFIL_PORTE_QTTC_ELT.REF_EXT_ADH  :=  loc_AFFIL_PORTE_QTTC.REF_EXT_ADH ;
            loc_AFFIL_PORTE_QTTC_ELT.STATUT       :=  2;  -- A intégré
            l_tab_AFFIL_PORTE_QTTC_ELT(idx_qttc_elt):=loc_AFFIL_PORTE_QTTC_ELT;
          END IF;

          IF Go_fin_fichier =0  AND  v_bloc_prec = '81' AND v_rubrique <= v_rubrique_prec  AND isBASE AND isCOT THEN
            idx_qttc_indiv:=idx_qttc_indiv+1;
            loc_AFFIL_PORTE_QTTC_INDIV.NUM_QTTC  := loc_AFFIL_PORTE_QTTC.NUM_QTTC;
            loc_AFFIL_PORTE_QTTC_INDIV.NUMREMISE := loc_PORTE_REMISE.NUMREMISE;
            loc_AFFIL_PORTE_QTTC_INDIV.NUMPORTE  := loc_PORTE_REMISE.NUMPORTE ;
            loc_AFFIL_PORTE_QTTC_INDIV.NUMLIGNE  := loc_AFFIL_PORTE.NUMLIGNE;
            l_tab_AFFIL_PORTE_QTTC_INDIV(idx_qttc_indiv):=loc_AFFIL_PORTE_QTTC_INDIV;
          END IF;

          -- bloc  précédent 70 et rubrique inf à la rubrique précédente
          --détection d'un rupture entite 70 contrat, on repart sur une rubrique donc nouvelle occurence de l'entité
          IF Go_fin_fichier =0  AND v_bloc_prec = '70'  AND   v_rubrique <= v_rubrique_prec THEN

            --Lors de la phase 1 les contrats sont données au niveau salarié donc info très redondante
            --le tableau sert uniquement à gerer les doublons - clef référence externe de contrat assureur
            --une référence contrat doit être unique par fichier DSN (affil_fichier) - une référence peut donc être partagée par plusieurs établissements
            IF NOT l_tab_AFFIL_PORTE_CNTRT.EXISTS(loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT) THEN
              loc_AFFIL_PORTE_CNTRT.NUMREMISE := loc_PORTE_REMISE.numremise;
              loc_AFFIL_PORTE_CNTRT.NUMPORTE := loc_PORTE_REMISE.numporte;
              loc_AFFIL_PORTE_CNTRT.ENTREPRISE := loc_AFFIL_FICHIER.ENTREPRISE;
              loc_AFFIL_PORTE_CNTRT.ETABLI := loc_AFFIL_FICHIER.ETABLI;
              loc_AFFIL_PORTE_CNTRT.NUM_ORDRE := loc_AFFIL_FICHIER.NUM_ORDRE;
              IF v_norme IN ('01','02') THEN
                cpt_cntrt := cpt_cntrt+1;
                loc_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT := cpt_cntrt; --en phase 1 et 2 pas d'indentifiant technique unique
                --P_INS_journal(1, loc_journal,'Insertion contrat, cpt : '||loc_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT||'ref: '|| loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT);
                IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_CNTRT(loc_AFFIL_PORTE_CNTRT,loc_journal) THEN
                  cpt_ano:=cpt_ano+1;
                END IF;
              END IF;
              l_tab_AFFIL_PORTE_CNTRT(loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT):=loc_AFFIL_PORTE_CNTRT;
            END IF;

            /****  AFFECTATION ADH  *********/
            IF v_norme IN ('01','02') THEN
              --en phase 3 l'identifiant technique est donné dans le flux
              loc_AFFIL_PORTE_ADH.REF_EXT_CNTRT := l_tab_AFFIL_PORTE_CNTRT(loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT).REF_EXT_CNTRT;
            END IF;

            IF loc_AFFIL_PORTE_ADH.NUMAYD IS NULL THEN --1ere occurence
              loc_AFFIL_PORTE_ADH.NUMAYD := 0; --uniquement pour le salarie
            END IF;

            cpt_adh                       := cpt_adh+1;
            loc_AFFIL_PORTE_ADH.NUMADH    := cpt_adh;

            l_tab_AFFIL_PORTE_ADH(cpt_adh):=loc_AFFIL_PORTE_ADH;
            --réinitialisation entre 2 lignes d'adhésions
            loc_contratsal:=loc_AFFIL_PORTE_ADH.CONTRAT_SAL;--entite 40 sauvée
            loc_AFFIL_PORTE_ADH   := loc_AFFIL_PORTE_ADH_empty;
            loc_AFFIL_PORTE_ADH.NUMREMISE := loc_PORTE_REMISE.NUMREMISE;
            loc_AFFIL_PORTE_ADH.NUMPORTE := loc_PORTE_REMISE.NUMPORTE;
            loc_AFFIL_PORTE_ADH.NUMLIGNE  := loc_AFFIL_PORTE.NUMLIGNE;
            loc_AFFIL_PORTE_ADH.CONTRAT_SAL:=loc_contratsal;
          END IF;

          /*****************************************************/
          /************   INSERTION TABLEAUX       *************/
          /*****************************************************/
          -- on insère les données uniquement au salarié suivant (30) ou d'un bloc de fin de fichier (90)
          IF  Go_fin_fichier =0   AND v_bloc_prec <> v_bloc  AND loc_AFFIL_PORTE.NUMLIGNE >0 AND (v_bloc ='30' OR  v_bloc='90') THEN
            IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE(loc_AFFIL_PORTE,loc_journal) THEN
              cpt_ano:=cpt_ano+1;
            END IF;

            --  DBMS_OUTPUT.PUT_LINE( '*****BOUCLE INSERTION DANS AFFIL_PORTE_AYD  :' ||l_tab_AFFIL_PORTE_AYD.count);
            FOR i IN 1..l_tab_AFFIL_PORTE_AYD.count LOOP
              IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_AYD(l_tab_AFFIL_PORTE_AYD(i),loc_journal) THEN
                cpt_ano:=cpt_ano+1;
              END IF;
            END LOOP;

            --DBMS_OUTPUT.PUT_LINE( '*****BOUCLE INSERTION L:'||loc_AFFIL_PORTE.NUMLIGNE  ||' DANS AFFIL_PORTE_ADH  :' ||l_tab_AFFIL_PORTE_ADH.count);
            FOR i IN 1..l_tab_AFFIL_PORTE_ADH.count LOOP
              IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_ADH(l_tab_AFFIL_PORTE_ADH(i),loc_journal) THEN
               cpt_ano:=cpt_ano+1;
              END IF;
            END LOOP;
            --insertion des données du LOT2B [Intégration des cotisations] --ABO???

            --DBMS_OUTPUT.PUT_LINE( '*****BOUCLE INSERTION DANS AFFIL_PORTE_QTTC  :' ||l_tab_AFFIL_PORTE_QTTC.count);
            FOR i IN 1..l_tab_AFFIL_PORTE_QTTC.count LOOP
              IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_QTTC(l_tab_AFFIL_PORTE_QTTC(i),loc_journal) THEN
               cpt_ano:=cpt_ano+1;
              END IF;
            END LOOP;

            -- DBMS_OUTPUT.PUT_LINE( '*****BOUCLE INSERTION DANS AFFIL_PORTE_QTTC_ELT  :' ||l_tab_AFFIL_PORTE_QTTC_ELT.count);
            FOR i IN 1..l_tab_AFFIL_PORTE_QTTC_ELT.count LOOP
              IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_QTTC_ELT(l_tab_AFFIL_PORTE_QTTC_ELT(i),loc_journal) THEN
               cpt_ano:=cpt_ano+1;
              END IF;
            END LOOP;

            -- DBMS_OUTPUT.PUT_LINE( '*****BOUCLE INSERTION DANS AFFIL_PORTE_QTTC_ELT  :' ||l_tab_AFFIL_PORTE_QTTC_INDIV.count);
            FOR i IN 1..l_tab_AFFIL_PORTE_QTTC_INDIV.count LOOP
              IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_QTTC_INDIV(l_tab_AFFIL_PORTE_QTTC_INDIV(i),loc_journal) THEN
               cpt_ano:=cpt_ano+1;
              END IF;
            END LOOP;


            -- DBMS_OUTPUT.PUT_LINE( '*****BOUCLE INSERTION DANS AFFIL_PORTE_ARRET  :' ||l_tab_AFFIL_PORTE_ARRET.count);
            FOR i IN 1..l_tab_AFFIL_PORTE_ARRET.count LOOP
              IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_ARRET(l_tab_AFFIL_PORTE_ARRET(i),loc_journal) THEN
               cpt_ano:=cpt_ano+1;
              END IF;
            END LOOP;

            --DBMS_OUTPUT.PUT_LINE( '*****BOUCLE INSERTION DANS AFFIL_PORTE_PAIEMENT  :' ||l_tab_AFFIL_PORTE_PAIEMENT.count);
            FOR i IN 1..l_tab_AFFIL_PORTE_PAIEMENT.count LOOP
               IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_PAIEMENT(l_tab_AFFIL_PORTE_PAIEMENT(i),loc_journal) THEN
                cpt_ano:=cpt_ano+1;
              END IF;
            END LOOP;

            --initialisaiton des variables et compteurs
            loc_AFFIL_PORTE := loc_AFFIL_PORTE_init;
            cpt_ayd         := 0;
            cpt_adh         := 0;
            idx_qttc_elt    := 0;
            idx_qttc_indiv  := 0;
            idx_qttc        := 0;
            idx_arret        := 0;
            idx_paiement        := 0;
            idx_paiement_comp    := 0;

            isBase:=FALSE;
            isCOT :=FALSE;

            l_tab_AFFIL_PORTE_AYD.delete;
            l_tab_AFFIL_PORTE_ADH.delete;
            l_tab_AFFIL_PORTE_QTTC.delete;
            l_tab_AFFIL_PORTE_QTTC_ELT.delete;
            l_tab_AFFIL_PORTE_QTTC_INDIV.delete;
            l_tab_AFFIL_PORTE_ARRET.delete;
            l_tab_AFFIL_PORTE_PAIEMENT.delete;

            loc_AFFIL_PORTE_AYD:=loc_AFFIL_PORTE_AYD_empty;
            loc_AFFIL_PORTE_ADH:= loc_AFFIL_PORTE_ADH_empty;
            IF v_norme IN('01','02') THEN
              loc_AFFIL_PORTE_CNTRT := loc_AFFIL_PORTE_CNTRT_empty;
            END IF; --nécessaire phase 1 et 2
            loc_AFFIL_PORTE_QTTC        := loc_AFFIL_PORTE_QTTC_empty;
            loc_AFFIL_PORTE_QTTC_ELT    := loc_AFFIL_PORTE_QTTC_ELT_empty;
            loc_AFFIL_PORTE_QTTC_INDIV := loc_AFFIL_PORTE_QTTC_IDV_empty;
            loc_AFFIL_PORTE_ARRET := loc_AFFIL_PORTE_ARRET_empty;
            loc_AFFIL_PORTE_PAIEMENT := loc_AFFIL_PORTE_PAIEMENT_empty;

          END IF;
          /*****************************************************/
          /************   NOUVEAU SALARIE       *************/
          /*****************************************************/
          IF  Go_fin_fichier =0 AND v_bloc_prec <> v_bloc  AND v_bloc ='30' THEN
            cpt_numligne  := cpt_numligne+1;
            loc_AFFIL_PORTE.NUMLIGNE := cpt_numligne;

            --anciennement postionné sur le n°ss mais celui-ci peut être vide
            loc_AFFIL_PORTE_ADH.NUMREMISE := loc_PORTE_REMISE.NUMREMISE;
            loc_AFFIL_PORTE_ADH.NUMPORTE := loc_PORTE_REMISE.NUMPORTE;
            loc_AFFIL_PORTE_ADH.NUMLIGNE  := loc_AFFIL_PORTE.NUMLIGNE;

            loc_AFFIL_PORTE_AYD.numremise:= loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_AYD.numporte:= loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_AYD.numligne := loc_AFFIL_PORTE.numligne;

            loc_AFFIL_PORTE_QTTC.NUMREMISE  :=  loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_QTTC.NUMPORTE :=  loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_QTTC.NUMLIGNE :=  loc_AFFIL_PORTE.NUMLIGNE;

            loc_AFFIL_PORTE_QTTC_INDIV.NUMREMISE := loc_PORTE_REMISE.NUMREMISE;
            loc_AFFIL_PORTE_QTTC_INDIV.NUMPORTE  := loc_PORTE_REMISE.NUMPORTE ;
            loc_AFFIL_PORTE_QTTC_INDIV.NUMLIGNE  := loc_AFFIL_PORTE.NUMLIGNE;

            loc_AFFIL_PORTE_QTTC_ELT.NUMREMISE    :=  loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_QTTC_ELT.NUMPORTE     :=  loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_QTTC_ELT.NUMLIGNE     :=  loc_AFFIL_PORTE.NUMLIGNE;

            loc_AFFIL_PORTE_ARRET.NUMREMISE    :=  loc_PORTE_REMISE.numremise;
            loc_AFFIL_PORTE_ARRET.NUMPORTE     :=  loc_PORTE_REMISE.numporte;
            loc_AFFIL_PORTE_ARRET.NUMLIGNE     :=  loc_AFFIL_PORTE.NUMLIGNE;
          END IF;


          /*********************************************/
          /************     AFFECTATIONS   *************/
          /*********************************************/
          --Pour la phase 1 et 2 on ne traite pas le bloc 15 contrat car répétitive avec entite 70 pour la phase 2 uniquement
          -- on ne bloque pas les doublons de fichiers logiques jusquà la prochaine rubrique 90
          IF NOT(v_norme IN ('01','02') AND substr(v_balise,0,10 ) ='S21.G00.15' )  THEN
            CASE v_balise
              -- Code d'envoi du fichier réel ou de test       01=test 02=reel
              WHEN 'S10.G00.00.005' THEN
                P_INS_journal(3, loc_journal,'debut du fichier DSN n°'|| cpt_fic);
                v_code_fichier := SUBSTR(s_ligne,17,LENGTH(s_ligne)-17);
                --P_INS_journal(3, loc_journal,'RKO CODENVOIDSN : ' || loc_affil_fichier.CODENVOIDSN );
                IF Tab_RG.EXISTS('FIC_MODE') AND  v_code_fichier <> '02' THEN
                  RAISE exc_code_fichier;
                END IF;
                --initialisation
                loc_AFFIL_FICHIER := loc_AFFIL_FICHIER_init;
                --RKO CRM DSN
                loc_affil_fichier.CODENVOIDSN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('CODENVOIDSN'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO CODENVOIDSN : ' || loc_affil_fichier.CODENVOIDSN );   --TODORKO codenvoidsn not insert
                --fin RKO CRM DSN
              WHEN 'S10.G00.00.006' THEN
                --loc_AFFIL_FICHIER := loc_AFFIL_FICHIER_init;  -- RKO CRM DSN
                loc_affil_fichier.NORME :=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NORME'), loc_journal, cpt_ligne_fichier);
              --  P_INS_journal(1, loc_journal,'Norme DSN : ' || loc_affil_fichier.NORME );
                v_norme := substr(loc_affil_fichier.NORME,2,2);
              WHEN 'S10.G00.00.007' THEN
                loc_affil_fichier.PTDEPOT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('PTDEPOT'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO PTDEPOT : ' || loc_affil_fichier.PTDEPOT );
              WHEN 'S10.G00.00.008' THEN
                loc_affil_fichier.TYPENVOIDSN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('TYPENVOIDSN'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO TYPENVOIDSN : ' || loc_affil_fichier.TYPENVOIDSN );
              WHEN 'S10.G00.01.001' THEN
                loc_affil_fichier.SIRENEMETT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('SIRENEMETT'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO SIRETEMETT : ' || loc_affil_fichier.SIRENEMETT );
              WHEN 'S10.G00.01.002' THEN
                loc_affil_fichier.NICEMETT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NICEMETT'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO SIRETEMETT : ' || loc_affil_fichier.SIRENEMETT );
              WHEN 'S10.G00.01.003' THEN
                loc_affil_fichier.NOMEMETT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NOMEMETT'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO NOMEMETT : ' || loc_affil_fichier.NOMEMETT );
              WHEN 'S10.G00.95.001' THEN
                loc_affil_fichier.NOMDECLARANT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NOMDECLARANT'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO NOMDECLARANT : ' || loc_affil_fichier.NOMDECLARANT );
              WHEN 'S10.G00.95.002' THEN
                loc_affil_fichier.PRENOMDECLARANT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('PRENOMDECLARANT'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO PRENOMDECLARANT : ' || loc_affil_fichier.PRENOMDECLARANT );
              WHEN 'S10.G00.95.003' THEN
                loc_affil_fichier.SIRETDECLARANT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('SIRETDECLARANT'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO SIRETDECLARANT : ' || loc_affil_fichier.SIRETDECLARANT );
              WHEN 'S10.G00.95.006' THEN
                loc_affil_fichier.MODEPOT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('MODEPOT'), loc_journal, cpt_ligne_fichier); --permet de controler la taille
                loc_affil_fichier.MODEPOT :=  SUBSTR(s_ligne,17,LENGTH(s_ligne)-17);--Pour recupérer le champs telquel --solution de contournement du UPPER(v_chaine) de F_CTRL_LONGUEUR_VARCHAR
                --P_INS_journal(3, loc_journal,'RKO MODEPOT : ' || loc_affil_fichier.MODEPOT );
              WHEN 'S10.G00.95.008' THEN
                loc_affil_fichier.DATDEPOT := PK_CTRL_AFFIL.F_FORMAT_DATE_HH_MIN_SS(s_ligne,null, tab_entite_fichier('DATDEPOT'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO DATDEPOT : ' || loc_affil_fichier.DATDEPOT );
              WHEN 'S10.G00.95.900' THEN
                loc_affil_fichier.IDENVOI := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('IDENVOI'), loc_journal, cpt_ligne_fichier);
                loc_affil_fichier.IDENVOI :=  SUBSTR(s_ligne,17,LENGTH(s_ligne)-17);--Pour recupérer le champs telquel --solution de contournement du UPPER(v_chaine) de F_CTRL_LONGUEUR_VARCHAR
                --P_INS_journal(3, loc_journal,'RKO IDENVOI : ' || loc_affil_fichier.IDENVOI );
               WHEN 'S20.G00.05.001' THEN
                 -- RECUPERATION DE LA NATURE DU FICHIER DSN
                 -- 01 - DSN Mensuelle
                 -- 02 - Signalement Fin du contrat de travail
                 -- 04 - Signalement Arrêt de travail
                 -- 05 - Signalement Reprise suite à arrêt de travail
                loc_affil_fichier.NATURE := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NATURE'), loc_journal, cpt_ligne_fichier);
              WHEN 'S20.G00.05.002' THEN
                -- S20.G00.05.002 : type de l'envoi : permet de définir s'il s'agit d'un envoi normal,
                --                                    ou d'un envoi contenant uniquement des déclarations mensuelles "néant".
                --01 - déclaration normale
                --02 - déclaration normale néant
                --03 - déclaration annule et remplace intégral
                --04 - déclaration annule
                --05 - annule et remplace néant
                loc_affil_fichier.TYPE :=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('TYPE'), loc_journal, cpt_ligne_fichier);
              WHEN 'S20.G00.05.003' THEN
                loc_AFFIL_FICHIER.FRACTIONDECLA := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('FRACTIONDECLA'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO FRACTIONDECLA '|| loc_AFFIL_FICHIER.FRACTIONDECLA);
              WHEN 'S20.G00.05.004' THEN
                loc_AFFIL_FICHIER.NUM_ORDRE := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NUM_ORDRE'), loc_journal, cpt_ligne_fichier);
                P_INS_journal(3, loc_journal,'NUM_ORDRE initial '|| loc_AFFIL_FICHIER.NUM_ORDRE);
                -- Conservation du numéro d'ordre d'origine pour généré le CRM
                loc_AFFIL_FICHIER.NUM_ORDRE_INI := loc_AFFIL_FICHIER.NUM_ORDRE ;
                --en cas de normale néant ou de annule et remplace néant, on vérifie que la clef num_ordre est bien unique, sinon on l'incrémente
                --permet de gérer les anomalies d'envoi sans num_ordre unique
              WHEN 'S20.G00.05.005' THEN
                loc_affil_fichier.DATEFIC:=PK_CTRL_AFFIL.v2d(SUBSTR(s_ligne,17,LENGTH(s_ligne)-17));
                loc_affil_fichier.DATEMOISDEC:=PK_CTRL_AFFIL.v2d(SUBSTR(s_ligne,17,LENGTH(s_ligne)-17));
              WHEN 'S20.G00.05.006' THEN
                loc_AFFIL_FICHIER.NUM_ANNUL := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NUM_ANNUL'), loc_journal, cpt_ligne_fichier);
              WHEN 'S20.G00.05.007' THEN
                loc_affil_fichier.DATECONSTITUTION:=PK_CTRL_AFFIL.v2d(SUBSTR(s_ligne,17,LENGTH(s_ligne)-17));
                IF loc_affil_fichier.DATEFIC IS NULL THEN
                  loc_affil_fichier.DATEFIC:=PK_CTRL_AFFIL.v2d(SUBSTR(s_ligne,17,LENGTH(s_ligne)-17));
                END IF;
              WHEN 'S20.G00.05.008' THEN
                loc_AFFIL_FICHIER.CHAMDECDSN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('CHAMDECDSN'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO CHAMDECDSN '|| loc_AFFIL_FICHIER.CHAMDECDSN);
              WHEN 'S20.G00.05.009' THEN
                loc_AFFIL_FICHIER.IDMETIERDSN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('IDMETIERDSN'), loc_journal, cpt_ligne_fichier);
                --P_INS_journal(3, loc_journal,'RKO IDMETIERDSN '|| loc_AFFIL_FICHIER.IDMETIERDSN);
              -- LECTURE DE LA DEVISE
              WHEN 'S20.G00.05.010' THEN -- PAS DE DEVISE PRESENTE DANS LE FICHIER EXEMPLE
                loc_AFFIL_FICHIER.DEVISE := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('DEVISE'), loc_journal, cpt_ligne_fichier);
                IF Tab_RG.EXISTS('BLOC_DEV') AND loc_AFFIL_FICHIER.DEVISE <> '01' THEN
                  RAISE exc_devise;
                END IF;
              WHEN 'S20.G00.05.011' THEN
               loc_AFFIL_FICHIER.NATEVENDSN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NATEVENDSN'), loc_journal, cpt_ligne_fichier);
               --P_INS_journal(3, loc_journal,'RKO NATEVENDSN '|| loc_AFFIL_FICHIER.NATEVENDSN);
              WHEN 'S20.G00.07.001' THEN
                loc_AFFIL_FICHIER.NOM_CONTACT :=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('NOM_CONTACT'), loc_journal, cpt_ligne_fichier);
              WHEN 'S20.G00.07.003' THEN
                loc_AFFIL_FICHIER.MAIL_CONTACT :=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('MAIL_CONTACT'), loc_journal, cpt_ligne_fichier);
              WHEN 'S20.G00.96.902' THEN
                loc_affil_fichier.IDDECLARDSN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('IDDECLARDSN'), loc_journal, cpt_ligne_fichier);
               -- P_INS_journal(3, loc_journal,'RKO IDDECLARDSN : ' || loc_affil_fichier.IDDECLARDSN );
              WHEN 'S21.G00.06.001' THEN
                loc_AFFIL_FICHIER.ANNEE      := TO_CHAR(loc_AFFIL_FICHIER.DATEFIC,'YYYY');
                loc_AFFIL_FICHIER.ENTREPRISE := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('ENTREPRISE'), loc_journal, cpt_ligne_fichier);
                P_INS_journal(3, loc_journal,'ENTREPRISE '|| loc_AFFIL_FICHIER.ENTREPRISE);
              WHEN 'S21.G00.11.001' THEN
                loc_AFFIL_FICHIER.ETABLI :=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_fichier('ETABLI'), loc_journal, cpt_ligne_fichier);
                 P_INS_journal(3, loc_journal,'ETABLI '|| loc_AFFIL_FICHIER.ETABLI);
                -- MUR M0005841 : renumérotation systématique des num_ordre
                BEGIN
                  SELECT count(*) -- nvl(max(AFFIL_FICHIER.NUM_ORDRE),0)   -- recherche doublon meme remise , meme numordre -- correction 06/09/2019
                    INTO v_doublon_fichier
                  FROM AFFIL_FICHIER
                  WHERE AFFIL_FICHIER.ENTREPRISE        =  loc_AFFIL_FICHIER.ENTREPRISE
                    AND AFFIL_FICHIER.ETABLI            =  loc_AFFIL_FICHIER.ETABLI
                    --AND AFFIL_FICHIER.DATEFIC           =  loc_AFFIL_FICHIER.datefic M0006328
                    AND AFFIL_FICHIER.NUMPORTE          =  loc_AFFIL_FICHIER.numporte
                    AND AFFIL_FICHIER.NUM_ORDRE         =  loc_AFFIL_FICHIER.NUM_ORDRE
                    AND AFFIL_FICHIER.NUMREMISE         =  loc_AFFIL_FICHIER.NUMREMISE
                    ;
                  P_INS_journal(3, loc_journal,'v_doublon_fichier '|| v_doublon_fichier);
                  IF v_doublon_fichier <> 0 THEN -- renumérotation numordre
                    SELECT nvl(max(AFFIL_FICHIER.NUM_ORDRE),0) + 1
                      INTO loc_AFFIL_FICHIER.NUM_ORDRE
                    FROM AFFIL_FICHIER
                    WHERE AFFIL_FICHIER.ENTREPRISE        =  loc_AFFIL_FICHIER.ENTREPRISE
                      AND AFFIL_FICHIER.ETABLI            =  loc_AFFIL_FICHIER.ETABLI
                      --AND AFFIL_FICHIER.DATEFIC           =  loc_AFFIL_FICHIER.datefic M0006328
                      AND AFFIL_FICHIER.NUMPORTE          =  loc_AFFIL_FICHIER.numporte
                      AND AFFIL_FICHIER.NUMREMISE         =  loc_AFFIL_FICHIER.NUMREMISE
                      ;
                  end if ;
                EXCEPTION
                  when others then null ;
                END ;
                P_INS_journal(3, loc_journal,'NUM_ORDRE integré '|| loc_AFFIL_FICHIER.NUM_ORDRE);

                loc_AFFIL_PORTE_init.entreprise:= loc_AFFIL_FICHIER.entreprise;
                loc_AFFIL_PORTE_init.etabli    := loc_AFFIL_FICHIER.ETABLI;
                loc_AFFIL_PORTE_init.num_ordre := loc_AFFIL_FICHIER.num_ordre;
                --P_INS_journal(1, loc_journal,'11 Insertion société : '||loc_AFFIL_FICHIER.ENTREPRISE||' NIC: '|| loc_AFFIL_FICHIER.ETABLI||' date:'||loc_AFFIL_FICHIER.datefic||' nature:'||loc_affil_fichier.NATURE ||' Type:'||loc_affil_fichier.TYPE);
                --P_INS_journal(1, loc_journal,'AR? société : '||loc_AFFIL_FICHIER.ENTREPRISE||' NIC: '|| loc_AFFIL_FICHIER.ETABLI||' date:'||loc_AFFIL_FICHIER.datefic||' num annul:'||loc_AFFIL_FICHIER.NUM_ANNUL);
                --INSERTION AFFIL_FICHIER PAR DSN MENSUELLE PRESENTE DANS FICHIER PHYSIQUE MEME EN CAS D'ERREUR
                IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_FICHIER(loc_affil_fichier,loc_journal) THEN
                  RAISE exc_ins_remise;
                END IF;
                loc_AFFIL_PORTE_init.etat:=2;--on initialisse l'état d'intégration à 2
                IF Tab_RG.EXISTS('FIC_TYPE') AND  loc_affil_fichier.TYPE not in (1,3,4) THEN
                  --01 - déclaration normale
                  --02 - déclaration normale néant
                  --03 - déclaration annule et remplace intégral
                  --04 - déclaration annule
                  --05 - annule et remplace néant
                  RAISE exc_type_envoi;
                ELSIF Tab_RG.EXISTS('FIC_NAT') AND loc_affil_fichier.NATURE <> 1 THEN
                  IF Tab_RG.EXISTS('FIC_NATSA') AND loc_affil_fichier.NATURE IN(4,5) THEN
                    loc_AFFIL_PORTE_init.etat:=6;
                  ELSIF Tab_RG.EXISTS('FIC_NATSA') AND loc_affil_fichier.NATURE IN(2) THEN
                    loc_AFFIL_PORTE_init.etat:=2;
                    --01 - DSN Mensuelle
                    --02 - Signalement Fin du contrat de travail
                    --04 - Signalement Arrêt de travail
                    --05 - Signalement Reprise suite à arrêt de travail
                  ELSE
                    RAISE exc_nature;
                  END IF;
                END IF;
              loc_AFFIL_PORTE                := loc_AFFIL_PORTE_init;
              /*--------------------------
              --  BLOC CONTRAT - BLOC 15 NON EXISTANT EN PHASE 1 et 2
              ---------------------------*/
              -- Référence de contrat organisme S21.G00.15.001 A30 30 1  REF_ORGN_CNTRT
              WHEN 'S21.G00.15.001'  THEN
                loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT:=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne, loc_AFFIL_PORTE.numligne, tab_entite_cntrt('REF_ORGN_CNTRT'), loc_journal, cpt_ligne_fichier);
              -- Code organisme  S21.G00.15.002 A9 9 1  ORGN
              WHEN 'S21.G00.15.002' THEN
                loc_AFFIL_PORTE_CNTRT.ORGN:=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne, loc_AFFIL_PORTE.numligne, tab_entite_cntrt('ORGN'), loc_journal, cpt_ligne_fichier);
              -- code délégataire S21.G00.15.003 A6 6 1  DELEG
              WHEN 'S21.G00.15.003' THEN
                loc_AFFIL_PORTE_CNTRT.DELEG:=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne, loc_AFFIL_PORTE.numligne, tab_entite_cntrt('DELEG'), loc_journal, cpt_ligne_fichier);
              -- personnel couvert ou non S21.G00.15.004  A2 2 1  PERS_COUV
              WHEN 'S21.G00.15.004' THEN
                loc_AFFIL_PORTE_CNTRT.PERS_COUV:=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne, loc_AFFIL_PORTE.numligne, tab_entite_cntrt('PERS_COUV'), loc_journal, cpt_ligne_fichier);
              --Identififiant technique externe S21.G00.15.005  A3 3 1  REF_EXT_CNTRT
              WHEN 'S21.G00.15.005' THEN
                loc_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT:=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne, loc_AFFIL_PORTE.numligne, tab_entite_cntrt('REF_EXT_CNTRT'), loc_journal, cpt_ligne_fichier);
                loc_AFFIL_PORTE_CNTRT.NUMREMISE := loc_PORTE_REMISE.numremise;
                loc_AFFIL_PORTE_CNTRT.NUMPORTE := loc_PORTE_REMISE.numporte;
                loc_AFFIL_PORTE_CNTRT.ENTREPRISE := loc_AFFIL_FICHIER.ENTREPRISE;
                loc_AFFIL_PORTE_CNTRT.ETABLI := loc_AFFIL_FICHIER.ETABLI;
                loc_AFFIL_PORTE_CNTRT.NUM_ORDRE := loc_AFFIL_FICHIER.NUM_ORDRE;
                -- M0005316
                --contrôle des doublons de fichier uniquement s'il ne s'agit pas d'un fichier d'un fichier mensuel
                --attention aux signalement, RG peut être à revoir !!
                --IF loc_AFFIL_FICHIER.NUM_ANNUL IS NULL AND loc_AFFIL_FICHIER.TYPE <>3 THEN
                IF  loc_AFFIL_FICHIER.TYPE =1 AND  loc_AFFIL_FICHIER.NATURE = 1 THEN
                  -- MUR M0005841  : annulation excep des doublons dans meme remise ou dans remise différente avec prise en compte de l'organisme assureur
                  begin
                    SELECT distinct AFFIL_FICHIER.numremise , AFFIL_FICHIER.num_ordre
                    INTO v_doublon_remise , v_doublon_num_ordre
                    FROM AFFIL_FICHIER
                    inner join AFFIL_PORTE_CNTRT on (     AFFIL_PORTE_CNTRT.NUMREMISE     =  AFFIL_FICHIER.NUMREMISE
                                                      AND AFFIL_PORTE_CNTRT.ENTREPRISE    =  AFFIL_FICHIER.ENTREPRISE
                                                      AND AFFIL_PORTE_CNTRT.ETABLI        =  AFFIL_FICHIER.ETABLI
                                                      AND AFFIL_PORTE_CNTRT.NUM_ORDRE     =  AFFIL_FICHIER.NUM_ORDRE
                                                    )
                    WHERE AFFIL_FICHIER.ENTREPRISE        =  loc_AFFIL_FICHIER.entreprise
                      AND AFFIL_FICHIER.ETABLI            =  loc_AFFIL_FICHIER.ETABLI
                      AND AFFIL_FICHIER.DATEFIC           =  loc_AFFIL_FICHIER.datefic
                      AND AFFIL_FICHIER.NUMPORTE          =  loc_AFFIL_FICHIER.numporte
                      AND AFFIL_FICHIER.NATURE            =  loc_AFFIL_FICHIER.nature
                      and AFFIL_PORTE_CNTRT.orgn          =  loc_AFFIL_PORTE_CNTRT.ORGN
                      AND AFFIL_FICHIER.num_annulante is null
                      --and AFFIL_FICHIER.numremise     !=  loc_AFFIL_FICHIER.numremise
                      and affil_fichier.nature =1
                      and affil_fichier.type in (1,3)  and loc_AFFIL_FICHIER.type in (1,3)
                      -- M0006101 : sinon remise annulée par elle-même
                      and ( AFFIL_FICHIER.numremise != loc_AFFIL_FICHIER.numremise                                                                 -- soit remise différente
                            OR ( AFFIL_FICHIER.numremise = loc_AFFIL_FICHIER.numremise and AFFIL_FICHIER.NUM_ORDRE != loc_AFFIL_FICHIER.NUM_ORDRE) -- soit meme remise mais num_ordre différent
                          )
                    ;
                  exception
                    when others then
                      v_doublon_remise := 0 ;
                      v_doublon_num_ordre := 0 ;
                  end ;
                  --P_INS_journal(1, loc_journal, 'MUR5 trt remise ' || loc_AFFIL_FICHIER.NUMREMISE || ' ' || loc_AFFIL_PORTE_CNTRT.ORGN ||  ' v_doublon_remise  ' || v_doublon_remise || ' v_doublon_num_ordre ' || v_doublon_num_ordre  );
                  IF v_doublon_remise != 0 and v_doublon_num_ordre != 0 then
                    pk_ctrl_affil.P_ANNULATION_AFFILIATION_EXCEP (
                                        P_numremise   => v_doublon_remise
                                      , P_entreprise  => loc_AFFIL_FICHIER.entreprise
                                      , P_etabli      => loc_AFFIL_FICHIER.etabli
                                      , P_num_ordre   => v_doublon_num_ordre
                                      , P_annul       => loc_AFFIL_FICHIER.NUM_ORDRE
                                      , P_numligne    => null
                                      , P_numporte    => 20
                                      , i_session     => 1
                                      , i_traitement  =>'EXCEP'
                                      , i_idligne     => loc_ligne
                                      , o_erreur      => loc_erreur
                                      ); -- maj num_annulante
                  end if ;
                END IF; -- IF  loc_AFFIL_FICHIER.TYPE =1 AND  loc_AFFIL_FICHIER.NATURE = 1 THEN
                --P_INS_journal(1, loc_journal,'15 Insertion contrat, cpt : '||loc_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT||'ref: '|| loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT);
                IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_CNTRT(loc_AFFIL_PORTE_CNTRT,loc_journal) THEN
                  cpt_ano:=cpt_ano+1;
                  P_INS_journal(3, loc_journal,'KO Insertion contrat, cpt : '||loc_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT||'ref: '|| loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT);
                ELSE
                   l_tab_AFFIL_PORTE_CNTRT(loc_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT):=loc_AFFIL_PORTE_CNTRT;
                END IF;
              /*--------------------------
              --  BLOC PAIEMENT - BLOC 20
              ---------------------------*/
              WHEN 'S21.G00.20.010' THEN
                loc_AFFIL_PORTE_PAIEMENT := loc_AFFIL_PORTE_PAIEMENT_empty; -- reinitialisation d'un objet
                loc_AFFIL_PORTE_PAIEMENT.MODE_PAIE := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_paiement('MODE_PAIE'), loc_journal, cpt_ligne_fichier);
              --Date prévisionnelle de paiement, S21.G00.20.011, DATE_PAIE
              WHEN 'S21.G00.20.011' THEN
                loc_AFFIL_PORTE_PAIEMENT.DATE_PAIE :=  E2D(PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,null, tab_entite_paiement('DATE_PAIE'), loc_journal, cpt_ligne_fichier));
              --SIRET de l’établissement payeur, S21.G00.20.012, SIRET_PAIE
              WHEN 'S21.G00.20.012' THEN
                loc_AFFIL_PORTE_PAIEMENT.SIRET_PAIE :=  PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,null, tab_entite_paiement('SIRET_PAIE'), loc_journal, cpt_ligne_fichier);
              /*--------------------------
              --  BLOC SALARIE - BLOC 30
              ---------------------------*/
              WHEN 'S21.G00.30.001' THEN
                loc_AFFIL_PORTE.NUMSSA  :=PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne, loc_AFFIL_PORTE.numligne, tab_entite_affil('NUMSSA'), loc_journal, cpt_ligne_fichier);
              WHEN 'S21.G00.30.002' THEN
                loc_AFFIL_PORTE.NOMNAIS := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne, loc_AFFIL_PORTE.numligne, tab_entite_affil('NOMNAIS'), loc_journal, cpt_ligne_fichier));
              WHEN 'S21.G00.30.003' THEN
                loc_AFFIL_PORTE.NOMSAL := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('NOMSAL'), loc_journal, cpt_ligne_fichier));
              WHEN 'S21.G00.30.004' THEN
                loc_AFFIL_PORTE.PRENOM := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('PRENOM'), loc_journal, cpt_ligne_fichier));
                 --DBMS_OUTPUT.PUT_LINE( '----*Nouveau salarié L:'||loc_AFFIL_PORTE.NUMLIGNE  ||' NOM :' ||loc_AFFIL_PORTE.prenom);
              -- Sexe S21.G00.30.005  2 1  SEXE
              WHEN 'S21.G00.30.005' THEN
                loc_AFFIL_PORTE.SEXE := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('SEXE'), loc_journal, cpt_ligne_fichier);
              -- date de naissance S21.G00.30.006  8 1  DATNAI
              WHEN 'S21.G00.30.006' THEN
                loc_AFFIL_PORTE.DATNAI := PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('DATNAI'), loc_journal, cpt_ligne_fichier);
                -- DBMS_OUTPUT.PUT_LINE('date de naissance : ' || loc_AFFIL_PORTE.DATNAI);
              -- Nombre d'enfant à charge S21.G00.30.021 N2 2 1  NBENFA
              WHEN 'S21.G00.30.021' THEN
                loc_AFFIL_PORTE.NBENFA := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('NBENFA'), loc_journal, cpt_ligne_fichier);
              --Lieu de naissance S21.G00.30.007  30 1  LIEUNAIS
              WHEN 'S21.G00.30.007' THEN
                loc_AFFIL_PORTE.LIEUNAIS := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('LIEUNAIS'), loc_journal, cpt_ligne_fichier));
              --nature, extension, numéro et libellé de la voie S21.G00.30.008  50 1  ADREVOIE
              WHEN 'S21.G00.30.008' THEN
                loc_AFFIL_PORTE.ADREVOIE := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('ADREVOIE'), loc_journal, cpt_ligne_fichier));
              WHEN 'S21.G00.30.016' THEN
                loc_AFFIL_PORTE.COMPLAD := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('COMPLAD'), loc_journal, cpt_ligne_fichier));
              -- code postal ou code distribution à l'étranger "S21.G00.30.009
              WHEN 'S21.G00.30.009' THEN
                loc_AFFIL_PORTE.CODPOS := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('CODPOS'), loc_journal, cpt_ligne_fichier);
              --S21.G00.30.012" A5 5 1  CODPOS
              WHEN 'S21.G00.30.012' THEN
                loc_AFFIL_PORTE.CODPOS := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('CODPOS'), loc_journal, cpt_ligne_fichier);
                --S21.G00.30.010 A50 50 1  VILLE
              WHEN 'S21.G00.30.010' THEN
                loc_AFFIL_PORTE.VILLE := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('VILLE'), loc_journal, cpt_ligne_fichier));
              -- S21.G00.30.011 A2 2 1  PAYS VARCHAR2(2 BYTE)
              WHEN 'S21.G00.30.011' THEN
                loc_AFFIL_PORTE.PAYS := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('PAYS'), loc_journal, cpt_ligne_fichier));
              -- S21.G00.30.018 A100 100 1  MAIL
              WHEN 'S21.G00.30.018' THEN
                loc_AFFIL_PORTE.MAIL := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('MAIL'), loc_journal, cpt_ligne_fichier));
              /*--------------------------
              --  BLOC CONTRAT - BLOC 40
              ---------------------------*/
              WHEN 'S21.G00.40.001' THEN
                loc_AFFIL_PORTE.DEBUTC := PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('DEBUTC'), loc_journal, cpt_ligne_fichier);
              WHEN 'S21.G00.40.003' THEN
                loc_AFFIL_PORTE.CADRNC := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('CADRNC'), loc_journal, cpt_ligne_fichier);
              -- Code convention collective S21.G00.40.017 A4 4 1  CONVCOLL
              WHEN 'S21.G00.40.017' THEN
                loc_AFFIL_PORTE.CONVCOLL := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('CONVCOLL'), loc_journal, cpt_ligne_fichier);
              WHEN 'S21.G00.40.009' THEN
                loc_AFFIL_PORTE_ADH.CONTRAT_SAL:= PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('CONTRAT_SAL'), loc_journal, cpt_ligne_fichier);
               -- Ajout des données sur le portage
              WHEN 'S21.G00.40.007' THEN       -- Accroissement temporaire de l'activité de l’entreprise
                loc_AFFIL_PORTE.ACCROI_TEMP := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('ACCROI_TEMP'), loc_journal, cpt_ligne_fichier);
              WHEN 'S21.G00.55.001' THEN
                --  loc_AFFIL_PORTE_PMT_COMP := loc_AFFIL_PORTE_PMT_COMP_empty; -- reinitialisation d'un objet
                loc_AFFIL_PORTE_PAIEMENT.MT_PAIE :=  PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_paiement('MT_PAIE'), loc_journal, cpt_ligne_fichier);
              --Type de population, S21.G00.55.002, TYPE_POP
              WHEN 'S21.G00.55.002' THEN
                loc_AFFIL_PORTE_PAIEMENT.TYPE_POP :=  PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_paiement('TYPE_POP'), loc_journal, cpt_ligne_fichier);
              --Code d affectation, S21.G00.55.003, REF_ORGN_CNTRT
              WHEN 'S21.G00.55.003' THEN
                loc_AFFIL_PORTE_PAIEMENT.REF_ORGN_CNTRT :=  PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_paiement('REF_ORGN_CNTRT'), loc_journal, cpt_ligne_fichier);
                --Période d affectation, S21.G00.55.004, PERIODE
              WHEN 'S21.G00.55.004' THEN
                loc_AFFIL_PORTE_PAIEMENT.PERIODE :=  PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_paiement('PERIODE'), loc_journal, cpt_ligne_fichier);
              --Date de reprise de travail S21.G00.60.010 N8 8 1 DATE_REPRISE
              WHEN 'S21.G00.60.010' THEN -- bloc correspondant a un Arret cardinalité (0,*)
                loc_AFFIL_PORTE_ARRET := loc_AFFIL_PORTE_ARRET_empty;
                loc_AFFIL_PORTE_ARRET.DATE_REPRISE := E2D(PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_arret('DATE_REPRISE'), loc_journal, cpt_ligne_fichier));
              --Motif reprise de travail S21.G00.60.011 N8 8 1 MOTIF_REPRISE
              WHEN 'S21.G00.60.011' THEN
                loc_AFFIL_PORTE_ARRET.MOTIF_REPRISE := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_arret('MOTIF_REPRISE'), loc_journal, cpt_ligne_fichier);
              /*--------------------------
              --  BLOC fin contrat /suspension - BLOC 62/65
              ---------------------------*/
              --date de fin de contrat S21.G00.62.001  8 1  FINCON
              WHEN 'S21.G00.62.001' THEN
                loc_AFFIL_PORTE.FINCON := PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('FINCON'), loc_journal, cpt_ligne_fichier);
              -- S21.G00.62.002 A2 2 1  MOTIFS
              WHEN 'S21.G00.62.002' THEN
                loc_AFFIL_PORTE.MOTIFS := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('MOTIFS'), loc_journal, cpt_ligne_fichier);
              -- Donnees sur le portage
              WHEN 'S21.G00.62.014' THEN   -- Fin de contrat à durée déterminée
                loc_AFFIL_PORTE.FINCON_DD := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('FINCON_DD'), loc_journal, cpt_ligne_fichier);
              WHEN 'S21.G00.62.016' THEN   -- m5475 Maintien de l’affiliation du salarié au contrat collectif
                loc_AFFIL_PORTE.MAINT_AFFIL := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('MAINT_AFFIL'), loc_journal, cpt_ligne_fichier);
                -- S21.G00.65.001 A2 2 1  MOTIFA
              WHEN 'S21.G00.62.017' THEN -- m5475 Modalité de déclaration de la fin du contrat d’usage
                loc_AFFIL_PORTE.MODE_FIN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('MODE_FIN'), loc_journal, cpt_ligne_fichier);
                -- S21.G00.65.001 A2 2 1  MOTIFA
              WHEN 'S21.G00.65.001' THEN
                loc_AFFIL_PORTE.MOTIFA := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('MOTIFA'), loc_journal, cpt_ligne_fichier);
                -- date de début de suspension  S21.G00.65.002 N8 8 1  DEBEFF
              WHEN 'S21.G00.65.002' THEN
                loc_AFFIL_PORTE.DEBEFF := PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('DEBEFF'), loc_journal, cpt_ligne_fichier);
                -- date de fin de suspension S21.G00.65.003 N8 8 1  FINEFF
              WHEN 'S21.G00.65.003' THEN
                loc_AFFIL_PORTE.FINEFF := PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_affil('FINEFF'), loc_journal, cpt_ligne_fichier);
              /*------------------------------
              --  BLOC CONTRAT - PHASE 1 - 70
              -------------------------------*/
              -- Référence de contrat organisme S21.G00.70.001 A30 30 1  REF_ORGN_CNTRT
              WHEN 'S21.G00.70.001' THEN
                loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_cntrt('REF_ORGN_CNTRT'), loc_journal, cpt_ligne_fichier);
                --  DBMS_OUTPUT.PUT_LINE('REF_ORGN_CNTRT : ' || loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT);
              -- Code organisme  S21.G00.70.002 A9 9 1  ORGN
              WHEN 'S21.G00.70.002' THEN
                loc_AFFIL_PORTE_CNTRT.ORGN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_cntrt('ORGN'), loc_journal, cpt_ligne_fichier);
                -- DBMS_OUTPUT.PUT_LINE('ORGN : ' || loc_AFFIL_PORTE_CNTRT.ORGN);
                -- code délégataire S21.G00.70.003 A6 6 1  DELEG
              WHEN 'S21.G00.70.003' THEN
                loc_AFFIL_PORTE_CNTRT.DELEG := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_cntrt('DELEG'), loc_journal, cpt_ligne_fichier);
                -- DBMS_OUTPUT.PUT_LINE('DELEG : ' || loc_AFFIL_PORTE_CNTRT.DELEG);
              /*--------------------------
              --  BLOC ADHESION - BLOC 70
              ---------------------------*/
              -- Code option S21.G00.70.004 A30 30 1  CODE_OPT
              WHEN 'S21.G00.70.004' THEN
                loc_AFFIL_PORTE_ADH.CODE_OPT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('CODE_OPT'), loc_journal, cpt_ligne_fichier);
              -- Code population S21.G00.70.005 A30 30 1  CODE_POP
              WHEN 'S21.G00.70.005' THEN
                loc_AFFIL_PORTE_ADH.CODE_POP := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('CODE_POP'), loc_journal, cpt_ligne_fichier);
              -- Nombre d'enfant à charge S21.G00.70.007 N2 2 1  NB_ENF_CHARGE
              WHEN 'S21.G00.70.007' THEN
                loc_AFFIL_PORTE_ADH.NB_ENF_CHARGE := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('NB_ENF_CHARGE'), loc_journal, cpt_ligne_fichier);
              -- S21.G00.70.008 N2 2 1  NB_AYD_ADULTE
              WHEN 'S21.G00.70.008' THEN
                loc_AFFIL_PORTE_ADH.NB_AYD_ADULTE := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('NB_AYD_ADULTE'), loc_journal, cpt_ligne_fichier);
              -- S21.G00.70.009 N2 2 1  NB_AYD
              WHEN 'S21.G00.70.009' THEN
                loc_AFFIL_PORTE_ADH.NB_AYD := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('NB_AYD'), loc_journal, cpt_ligne_fichier);
              -- S21.G00.70.010 N2 2 1  NB_AYD_AUTRE
              WHEN 'S21.G00.70.010' THEN
                loc_AFFIL_PORTE_ADH.NB_AYD_AUTRE := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('NB_AYD_AUTRE'), loc_journal, cpt_ligne_fichier);
              -- S21.G00.70.011 N2 2 1  NB_AYD_ENF
              WHEN 'S21.G00.70.011' THEN
                 loc_AFFIL_PORTE_ADH.NB_AYD_ENF := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('NB_AYD_ENF'), loc_journal, cpt_ligne_fichier);
              -- Identififiant technique externe S21.G00.70.012 A3 3 1  REF_EXT_ADH
              WHEN 'S21.G00.70.012' THEN
                loc_AFFIL_PORTE_ADH.REF_EXT_ADH := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('REF_EXT_ADH'), loc_journal, cpt_ligne_fichier);
              -- Identififiant technique externe S21.G00.70.013  A3 3 1  REF_EXT_CNTRT
              WHEN 'S21.G00.70.013' THEN
                loc_AFFIL_PORTE_ADH.REF_EXT_CNTRT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('REF_EXT_CNTRT'), loc_journal, cpt_ligne_fichier);
              WHEN 'S21.G00.70.014' THEN  -- m5475 Date de début de l’affiliation
                loc_AFFIL_PORTE_ADH.DEBUT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('DEBUT'), loc_journal, cpt_ligne_fichier);
              WHEN 'S21.G00.70.015' THEN  -- m5475 Date de début de l’affiliation
                loc_AFFIL_PORTE_ADH.FIN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_adh('FIN'), loc_journal, cpt_ligne_fichier);
              /*--------------------------
              --  BLOC AYANT DROIT - BLOC 73
              ---------------------------*/
              --type d'ayant droit (enfant, adulte, autres S21.G00.73.003 A2 2 1 TYPEAD
              WHEN 'S21.G00.73.003' THEN
                loc_AFFIL_PORTE_AYD        := loc_AFFIL_PORTE_AYD_empty;
                loc_AFFIL_PORTE_AYD.TYPEAD := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_ayd('TYPEAD'), loc_journal, cpt_ligne_fichier);
              --date de naissance S21.G00.73.005 N8 8 1 DATNAIS
              WHEN 'S21.G00.73.005' THEN
                loc_AFFIL_PORTE_AYD.DATNAIS := PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_ayd('DATNAIS'), loc_journal, cpt_ligne_fichier);
              --nom de naissance S21.G00.73.006 A80 80 1 NOM
              WHEN 'S21.G00.73.006' THEN
                loc_AFFIL_PORTE_AYD.NOMUSAGE := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_ayd('NOM'), loc_journal, cpt_ligne_fichier));
              --nss de l'ayant droit S21.G00.73.007 A13 13 1 NUMSSA
              WHEN 'S21.G00.73.007' THEN
                loc_AFFIL_PORTE_AYD.NUMSSA := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_ayd('NUMSSA'), loc_journal, cpt_ligne_fichier);
              --nss de l'ouvreur de droit S21.G00.73.008 A13 13 1 NUMSSOYD
              WHEN 'S21.G00.73.008' THEN
                loc_AFFIL_PORTE_AYD.NUMSSOD := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_ayd('NUMSSOD'), loc_journal, cpt_ligne_fichier);
              --Prénoms S21.G00.73.009 A80 80 1 PRENOM
              WHEN 'S21.G00.73.009' THEN
                loc_AFFIL_PORTE_AYD.PRENOM := (PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_ayd('PRENOM'), loc_journal, cpt_ligne_fichier));
              --Organisme affiliation  S21.G00.73.010 A30 30 1 ORGN
              WHEN 'S21.G00.73.010' THEN
                loc_AFFIL_PORTE_AYD.ORGN := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_ayd('ORGN'), loc_journal, cpt_ligne_fichier);
              --Date de fin de rattachement à l'ouvrant droit S21.G00.73.011 N8 8 1 DATEFINOYD
              WHEN 'S21.G00.73.011' THEN
                loc_AFFIL_PORTE_AYD.DATEFINOD := PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_ayd('DATEFINOD'), loc_journal, cpt_ligne_fichier);
              /*--------------------------
              --  BLOC COTISATIONS - BLOC 78
              ---------------------------*/
              --code de la base assujettie doit être égale à 31
              WHEN 'S21.G00.78.001' THEN
               loc_AFFIL_PORTE_QTTC := loc_AFFIL_PORTE_QTTC_empty;
               IF SUBSTR(s_ligne,17,LENGTH(s_ligne)-17)='31' THEN  isBASE :=TRUE;
               ELSE isBASE :=FALSE;
               END IF;
              --Date de début de période de rattachement S21.G00.78.002 N8 8 1 DEB_BASE
              WHEN 'S21.G00.78.002' THEN
                -- on enregistre le bloc potentielement renseigné auparavant avant de recreer un objet.
                loc_AFFIL_PORTE_QTTC.DEB_BASE :=  E2D(PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_qttc('DEB_BASE'), loc_journal, cpt_ligne_fichier));
              --Date de fin de période de rattachement S21.G00.78.003 N8 8 1 FIN_BASE
              WHEN 'S21.G00.78.003' THEN
                loc_AFFIL_PORTE_QTTC.FIN_BASE := E2D(PK_CTRL_AFFIL.F_CTRL_FORMAT_DATE(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_qttc('FIN_BASE'), loc_journal, cpt_ligne_fichier));
              -- Identififiant technique externe  S21.G00.78.005 REF_EXT_ADH
              WHEN 'S21.G00.78.005' THEN
                loc_AFFIL_PORTE_QTTC.REF_EXT_ADH := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_qttc('REF_EXT_ADH'), loc_journal, cpt_ligne_fichier);
              /*--------------------------
              --  BLOC COTISATIONS - BLOC 79 composant de la base
              ---------------------------*/
              WHEN 'S21.G00.79.001' THEN
                loc_AFFIL_PORTE_QTTC_ELT := loc_AFFIL_PORTE_QTTC_ELT_empty;
                loc_AFFIL_PORTE_QTTC_ELT.TYPE_ELT := PK_CTRL_AFFIL.F_CTRL_LONGUEUR_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_qttc_elt('TYPE_ELT'), loc_journal, cpt_ligne_fichier);
              --Montant de composant de base assujettie S21.G00.79.004 N8 8 1 MT_ELT
              WHEN 'S21.G00.79.004' THEN
                loc_AFFIL_PORTE_QTTC_ELT.MT_ELT := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_qttc_elt('MT_ELT'), loc_journal, cpt_ligne_fichier);
              /*--------------------------
              --  BLOC COTISATIONS individuelle - BLOC 81
              ---------------------------*/
              WHEN 'S21.G00.81.001' THEN
                loc_AFFIL_PORTE_QTTC_INDIV  := loc_AFFIL_PORTE_QTTC_IDV_empty;
                IF SUBSTR(s_ligne,17,LENGTH(s_ligne)-17)='059' THEN  isCOT :=TRUE;
                ELSE isCOT :=FALSE;
                END IF;
              WHEN 'S21.G00.81.004' THEN
                loc_AFFIL_PORTE_QTTC_INDIV.MT_BASE   := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_qttc_indiv('MT_BASE'), loc_journal, cpt_ligne_fichier);
              -- Code cotisation établissement S21.G00.82.002   CODE_COT
              WHEN 'S21.G00.82.002 ' THEN
                loc_AFFIL_PORTE_QTTC.CODE_COT := PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR(s_ligne,loc_AFFIL_PORTE.numligne, tab_entite_qttc('CODE_COT'), loc_journal, cpt_ligne_fichier);
              /*FIN DU FICHIER logique DSN (et non pas du fichier physique)*/
              WHEN 'S90.G00.90.001' THEN
                P_INS_journal(2, loc_journal,'Fin du fichier DSN n°'|| cpt_fic);
                cpt_fic:=cpt_fic+1;
                l_tab_AFFIL_PORTE_CNTRT.delete; --pour la phase 1 et 2 le tableau de références contrat doit être réinit mais pas le compteur
                --cpt_cntrt :=0;
                --réinitialisation des variables
                v_bloc_prec := '00';
                v_rubrique_prec :=1;
                v_doublon_fichier:=0;
                Go_fin_fichier:=0;
                --réinitialisation des objets
                loc_AFFIL_PORTE_ADH   := loc_AFFIL_PORTE_ADH_empty;
                loc_AFFIL_PORTE_CNTRT := loc_AFFIL_PORTE_CNTRT_empty;
                loc_AFFIL_PORTE_AYD   := loc_AFFIL_PORTE_AYD_empty;
                loc_AFFIL_PORTE       := loc_AFFIL_PORTE_empty;
                loc_AFFIL_PORTE_QTTC := loc_AFFIL_PORTE_QTTC_empty;
                loc_AFFIL_PORTE_ARRET := loc_AFFIL_PORTE_ARRET_empty;
                loc_AFFIL_PORTE_PAIEMENT := loc_AFFIL_PORTE_PAIEMENT_empty;
                  --   loc_AFFIL_PORTE_PMT_COMP := loc_AFFIL_PORTE_PMT_COMP_empty;
              ELSE
                NULL;
            END CASE;

          END IF;
        END IF; --Go_fin_fichier

      EXCEPTION
        WHEN exc_ins_remise THEN
          P_INS_journal(1, loc_journal,'Insertion remise fichier impossible, erreur : < '||SQLERRM||' >');
          RAISE exc_fin_remise;
        WHEN exc_code_fichier THEN
          P_INS_journal(2, loc_journal,'Import impossible du fichier n°'||cpt_fic||' de test. Balise S10.G00.00.005, valeur: '||v_code_fichier);
          Go_fin_fichier:=1;
          loc_DSN_OUT:=1;
        WHEN exc_doublon_fichier THEN
          P_INS_journal(1, loc_journal,'Doublon de fichier logique DSN n°'||cpt_fic||', dans remise '||v_doublon_fichier||' société : ' || loc_AFFIL_FICHIER.entreprise||' NIC:'|| loc_AFFIL_FICHIER.ETABLI);
          Go_fin_fichier:=1;
          loc_DSN_OUT:=1;
        WHEN exc_type_envoi THEN
          P_INS_journal(1, loc_journal,'Type d''envoi du fichier  n°'||cpt_fic||' non géré: balise S20.G00.05.002: '||loc_affil_fichier.TYPE);
          Go_fin_fichier:=1;
          loc_DSN_OUT:=1;
        WHEN exc_devise THEN
          P_INS_journal(1, loc_journal,'Devise du fichier incorrecte : différente de 01 pour Euro. Balise S20.G00.05.010');
          Go_fin_fichier:=1;
          loc_DSN_OUT:=1;
        WHEN exc_nature THEN
          P_INS_journal(1, loc_journal,'Nature du fichier  n°'||cpt_fic||' non gérée : Balise S20.G00.05.001: '||loc_affil_fichier.NATURE);
          Go_fin_fichier:=1;
          loc_DSN_OUT:=1;
        WHEN OTHERS THEN
          P_INS_journal(1, loc_journal, 'Lig:'||cpt_ligne_fichier||' Err fic n°'||cpt_fic||'-bloc'||v_bloc|| '-rub'||v_rubrique||'- erreur :'||SQLERRM);
          cpt_ano:=cpt_ano+1;
          RAISE exc_fin_remise;
      END;

      IF v_entite='G00' THEN
        v_bloc_prec := v_bloc;
        v_rubrique_prec := v_rubrique;
      END IF;

    END LOOP;
  END IF;--DSN ou AF02T

  IF UTL_FILE.is_open (h_fichier) THEN
    P_INS_journal(3, loc_journal,'Fermeture du fichier : fin du fichier(*)'); -- M0005453 differenciation trace
    UTL_FILE.fclose (h_fichier);
  END IF;

  l_tab_AFFIL_PORTE_CNTRT.delete;
  cpt_cntrt :=0;
  -- mise à jour de la nature de la remise
  PK_CTRL_AFFIL.P_MAJ_NATURE_PORTE_REMISE(loc_PORTE_REMISE.NUMREMISE,loc_PORTE_REMISE.NUMPORTE);--TODO ajouter critère


  FOR R_annulFichier IN C_annulFichier(loc_PORTE_REMISE.NUMREMISE,loc_PORTE_REMISE.NUMPORTE) LOOP
    --on peut avoir un type AR ou Annule sans num d'annulation TYPE IN(3,4)

    BEGIN
      v_fichier_annul:=NULL;
      v_num_ordre_annul:=NULL ; -- M0006328

      -- recherche remise precedente à annuler
      SELECT distinct af.NUMREMISE , af.num_ordre
      INTO v_fichier_annul , v_num_ordre_annul
      FROM AFFIL_FICHIER af -- MUR M0005841 , AFFIL_PORTE_CNTRT cntrt
      WHERE af.ENTREPRISE=R_annulFichier.entreprise
      AND af.ETABLI = R_annulFichier.ETABLI
      AND af.DATEFIC=R_annulFichier.datefic
      AND af.NUMPORTE =R_annulFichier.numporte
      AND af.NATURE = R_annulFichier.nature
      AND af.TYPE NOT IN (2,5) -- MUR M0005841 pas d'annulation de Néant
      AND af.NUM_ORDRE = NVL(substr(R_annulFichier.NUM_ANNUL,9), af.NUM_ORDRE)
      -- AND af.NUM_ORDRE <> R_annulFichier.NUM_ORDRE -- MUR M0005841
      AND af.NUMREMISE <> R_annulFichier.NUMREMISE
      and num_annulante is null -- MUR M0005841 annulation deja faites au sein d'une meme remise
      AND substr(af.fichier,0,4) = substr(R_annulFichier.fichier,0,4); --on doit rechercher un fichier à annuler du même concentrateur... même assureur peut être compliqué car niveau CNTRT

      P_INS_journal(3, loc_journal, 'v_fichier_annul' || v_fichier_annul || ' - v_num_ordre_annul ' || v_num_ordre_annul );

      --les annulations au sein d'une même remise sont gérées plus haut au travers d'une annulation exceptionnelle
      --P_INS_journal(1, loc_journal,'Présence d''AR pour la société : '||loc_AFFIL_FICHIER.ENTREPRISE||' NIC: '|| loc_AFFIL_FICHIER.ETABLI||' date:'||loc_AFFIL_FICHIER.datefic||' dans la remise:'||v_fichier_annul);


      P_ANNUL_REMPLACE(R_annulFichier, v_fichier_annul, i_session, i_traitement,loc_journal.idligne,v_stop );
      IF v_stop IS NOT NULL THEN --le traitement doit être arreté pour pallier au problème de commit / rollback
        P_INS_journal(1, loc_journal, 'AR impossible, annulation exceptionnelle à réaliser'); -- MUR M0005841 : pour analyse ulterieure
        RAISE exc_fin_remise;
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        v_fichier_annul:=0;--aucun fichier à annuler
      WHEN too_many_rows THEN
        P_INS_journal(1, loc_journal,'Remise :' || R_annulFichier.numremise ||', remplacement fichier impossible pour la société : '||R_annulFichier.ENTREPRISE||' NIC: '|| R_annulFichier.ETABLI||' date:'||R_annulFichier.datefic||' ordre :'||R_annulFichier.NUM_ANNUL);

      -- M0005453 ajout pour toper exception
      when exc_fin_remise then
        P_INS_journal(1, loc_journal,'appel exc_fin_remise Remise :' || R_annulFichier.numremise ) ;
        RAISE exc_fin_remise ;
      when others then P_INS_journal(1, loc_journal,SUBSTR (SQLERRM (SQLCODE), 1, 128 ))  ;
    END;

  END LOOP;

  P_INS_journal(3, loc_journal , 'cpt_ano : ' || cpt_ano ) ; -- M0005453

  IF cpt_ano <>0 THEN
    P_INS_journal(1, loc_journal, 'Importation impossible '||cpt_ano||' anomalies rencontrées');
    ROLLBACK;
    o_remise :=NULL;
  ELSE
    o_remise := loc_PORTE_REMISE.NUMREMISE;
    SELECT count(*)
    INTO nb_fichier
    FROM AFFIL_FICHIER
    WHERE numremise = loc_PORTE_REMISE.NUMREMISE;

    P_INS_journal(3, loc_journal,'nb_fichier :' || to_char(nb_fichier) ) ; -- M0005453
    IF nb_fichier= 0 THEN
      DELETE PORTE_REMISE WHERE NUMREMISE = loc_PORTE_REMISE.NUMREMISE AND NUMPORTE=loc_PORTE_REMISE.NUMPORTE;
    END IF;

    COMMIT;

    IF loc_DSN_OUT = 0 THEN
      P_INS_journal(1, loc_journal, 'Déplacement du fichier :'||loc_fichier||' dans le répertoire des DSN traitées "DONE"');
      UTL_FILE.FCOPY ( 'DSN_IN',
                       loc_fichier,
                       'DSN_DONE',
                       loc_fichier);
    ELSE
      P_INS_journal(1, loc_journal, 'Déplacement du fichier :'||loc_fichier||' dans le répertoire des DSN non-traitées "OUT"');
      UTL_FILE.FCOPY ( 'DSN_IN',
                       loc_fichier,
                       'DSN_OUT',
                       loc_fichier);
    END IF;
    UTL_FILE.FREMOVE ('DSN_IN',loc_fichier);
    loc_DSN_OUT := 0;
  END IF;

  P_INS_journal(3, loc_journal, 'FIN PK_IMPORT_AFFIL_DSN.IMPORT_AFFIL_DSN le '||TO_CHAR(SYSDATE));
EXCEPTION
  WHEN exc_remise_importe THEN
    P_INS_journal(1, loc_journal, 'Le fichier physique a déjà été importé sous ce nom de fichier, remise :'||loc_ok);
  WHEN exc_fin_remise THEN
    --P_INS_journal(1, loc_journal, 'debut exc_fin_remise '); --M0005453
    IF UTL_FILE.is_open (h_fichier) THEN
      P_INS_journal(3, loc_journal,'Intégration impossible, fermeture du fichier');
      UTL_FILE.fclose (h_fichier);
    END IF;
    ROLLBACK;
  WHEN DBMS_LOB.operation_failed THEN
    UTL_FILE.fclose (h_fichier);
    P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' non présent dans le répertoire d''import');
  WHEN UTL_FILE.internal_error THEN
    UTL_FILE.fclose (h_fichier);
    P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' UTL_FILE.INTERNAL_ERROR');
  WHEN UTL_FILE.invalid_filehandle THEN
    UTL_FILE.fclose (h_fichier);
    P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' UTL_FILE.INVALID_FILEHANDLE');
  WHEN UTL_FILE.invalid_mode THEN
    UTL_FILE.fclose (h_fichier);
    P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' UTL_FILE.INVALID_MODE');
  WHEN UTL_FILE.invalid_operation THEN
    UTL_FILE.fclose (h_fichier);
    P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' UTL_FILE.INVALID_OPERATION');
  WHEN UTL_FILE.invalid_path THEN
    UTL_FILE.fclose (h_fichier);
    P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' UTL_FILE.INVALID_PATH');
  WHEN UTL_FILE.read_error THEN
    UTL_FILE.fclose (h_fichier);
    P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' UTL_FILE.READ_ERROR');
  WHEN UTL_FILE.write_error THEN
    UTL_FILE.fclose (h_fichier);
    UTL_FILE.fclose (h_fichier);P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' UTL_FILE.WRITE_ERROR');
  WHEN VALUE_ERROR THEN
    UTL_FILE.fclose (h_fichier);
    P_INS_journal(1, loc_journal, 'Ligne ' ||cpt_ligne_fichier|| ' VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128));
    DBMS_OUTPUT.PUT_LINE('s_ligne:' || s_ligne);
  WHEN OTHERS THEN
    P_INS_journal(1, loc_journal, 'Fichier '||i_fichier||' Fermeture du fichier - '||SQLERRM);
    IF UTL_FILE.is_open (h_fichier) THEN
      UTL_FILE.fclose (h_fichier);
    END IF;
    ROLLBACK;
END IMPORT_AFFIL_DSN;

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  IMPORT_AFFIL_AF02                                          */
/* Type         :  Privée                                                    */
/* Description  :  Permet de faire l  import d un fichier contenant des      */
/*                 affiliations dans ainsi que l intégration des données     */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichier , fichier des affiliations                      */
/* Retour       :  o_remise, Remise importée                                 */
/*---------------------------------------------------------------------------*/
PROCEDURE IMPORT_AFFIL_AF02(
      i_Porte      IN AFFIL_PORTE.NUMPORTE%TYPE ,
      i_fichier    IN UTL_FILE.file_type ,
      i_nomfichier IN AFFIL_FICHIER.FICHIER%TYPE,
      i_echange  IN PORTE_ECHANGE.IDECHANGE%TYPE,
      i_nature     IN NUMBER,
      i_journal    IN OUT JOURNAL_ADM%ROWTYPE ,
      i_remise     IN  PORTE_REMISE%ROWTYPE,
      o_ano        OUT NUMBER) IS

  s_ligne            VARCHAR2(5000):='';
  s_rupture          affil_porte_ayd.groupeayd%TYPE;
  s_rupture_cntrt    contrat.refcie%TYPE;
  s_rupture_siret    VARCHAR2(15);
  cpt_ano               NUMBER:=0;
  cpt_fic               NUMBER:=0;

  Go_fin_fichier NUMBER;
  cpt_ligne NUMBER(9);
  cpt_sal   NUMBER(9);
  cpt_cntrt NUMBER(9);
  cpt_siret NUMBER(9);
  cpt_ayd   NUMBER(9);
  cpt_entite  NUMBER(9);
  cpt_bad_entete         NUMBER:=0;--compteur de rejet
  cpt_bad_ligne          NUMBER:=0;--compteur de rejet
  cpt_bad_entite         NUMBER:=0;--compteur de rejet
  cpt_bad_insert         NUMBER:=0;--compteur de rejet
  cpt_bad_param          NUMBER:=0;--compteur de rejet
  cpt_rejet              NUMBER:=0;--Compteur global des rejets
  s_nb_separateur   NUMBER:=0;
  IS_AYD boolean;
  IS_SAL boolean;

  l_T_ligne         pk_import_affil.T_ligne;
  l_T_entite        pk_import_affil.T_ligne;
  l_T_entite_empty  pk_import_affil.T_ligne;
  stmt            VARCHAR2(6000);
  stmt_init       VARCHAR2(600);
  stmt_value      VARCHAR2(600);
  stmt_clef       VARCHAR2(600);
  s_entite        PORTE_ENTITE.ENTITE%TYPE;
  s_donnee        PORTE_ENTITE.DONNEE%TYPE;
  loc_AFFIL_FICHIER             AFFIL_FICHIER%ROWTYPE;
  loc_AFFIL_PORTE_CNTRT         AFFIL_PORTE_CNTRT%ROWTYPE;
 -- s_colonne       PORTE_ENTITE.DONNEE%TYPE;


  exc_bad_separateur EXCEPTION;
  exc_bad_fichier    EXCEPTION;

  CURSOR C_ENTITE (p_echange NUMBER) IS
  SELECT e.*
    FROM PORTE_ENTITE_ORDRE o , PORTE_ENTITE e
   WHERE o.idechange = p_echange
     AND o.idechange = e.idechange
     AND o.entite = e.entite
     AND e.position>=1 --exclu le numligne clef primaire en 0 pour affil porte
    ORDER BY o.ordre,e.contrainte,e.position;

  CURSOR C_ECHANGE (p_echange NUMBER) IS
  SELECT e.TYPE_FORMAT, e.SEPARATEUR, e.LONGUEUR, e.ENTETE,e.APOSTROPHE
    FROM PORTE_ECHANGE e
   WHERE e.idechange = p_echange;

   Rec_C_ECHANGE C_ECHANGE%ROWTYPE;

BEGIN
  cpt_ligne :=0;
  Go_fin_fichier:=0;

  OPEN C_ECHANGE(i_echange);
  FETCH C_ECHANGE INTO Rec_C_ECHANGE;
  CLOSE C_ECHANGE;

  cpt_sal:=0;
  cpt_cntrt :=0;
  cpt_siret :=0;
  cpt_ayd:=0;
  s_rupture:=NULL;
  IS_AYD := FALSE;
  IS_SAL := FALSE;

   --parcourt du fichier
  WHILE PK_FICHIER.fGetLine(i_fichier,s_ligne) LOOP
    BEGIN
      cpt_ligne:=cpt_ligne+1;

      -- Vérification du bon nombre de séparateur pour chaque ligne vis à vis du format attendu
      s_nb_separateur:=(length(s_ligne) - length(replace(s_ligne, ';')));
      IF s_nb_separateur=Rec_C_ECHANGE.longueur-1 THEN
        s_ligne:=s_ligne||';';
      ELSIF s_nb_separateur>Rec_C_ECHANGE.longueur THEN
        RAISE exc_bad_separateur;
      END IF;
      --tableau par ligne du fichier
      l_T_ligne:= pk_import_affil.S2A(s_ligne,Rec_C_ECHANGE.SEPARATEUR);
      -- Parcourt de l objet
      stmt:=NULL;


      -- On exclut l entete et on vérifie le parametrage de celle ci dans la table
      IF Rec_C_ECHANGE.ENTETE != cpt_ligne THEN

        --P_INS_journal(3, i_journal,'l_T_ligne '||l_T_ligne.count);

        --parcourt des entités suivant l'odre paramétré et en tenant compte de l'action
        BEGIN
          s_entite:=NULL;
          cpt_entite:=0;
          --boucle sur les entités et colonne par ordre d'insertion des tables pour une ligne de fichier !
          --initialisé les objets ? numremise, numadh...numporte selon les Entité
          FOR Rec_C_ENTITE IN C_ENTITE(i_echange) LOOP
            BEGIN
              --***GESTION DES RUPTURES VIA LES CONTRAINTES PARAMETREES GROUPE pour les ayd d'un même salarié en position 0
                            --création de l'affil_porte_cntrt sur le 1er salarié uniquement et non dynamique
              IF   Rec_C_ENTITE.entite ='AFFIL_FICHIER' THEN
                IF Rec_C_ENTITE.donnee ='ENTREPRISE' AND NVL(s_rupture_siret,0)  <> TRIM(l_T_ligne(Rec_C_ENTITE.position))  THEN
                  cpt_siret :=cpt_siret+1;
               -- IF cpt_sal = 0 THEN
                  loc_AFFIL_FICHIER.numremise :=i_remise.numremise;
                  loc_AFFIL_FICHIER.numporte := i_Porte;
                  loc_AFFIL_FICHIER.entreprise :=  substr(PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR_AFF(l_T_ligne(Rec_C_ENTITE.position),cpt_sal, Rec_C_ENTITE, i_journal, cpt_ligne),0,9);
                  loc_AFFIL_FICHIER.etabli := substr(PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR_AFF(l_T_ligne(Rec_C_ENTITE.position),cpt_sal, Rec_C_ENTITE, i_journal, cpt_ligne),10,5);
                  loc_AFFIL_FICHIER.nature :=i_nature;--dans param1 ?
                  loc_AFFIL_FICHIER.datefic := sysdate;
                  loc_AFFIL_FICHIER.fichier := i_nomfichier;
                  loc_AFFIL_FICHIER.num_ordre:=1;
                  s_rupture_siret:=PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR_AFF(l_T_ligne(Rec_C_ENTITE.position),cpt_sal, Rec_C_ENTITE, i_journal, cpt_ligne);
                  s_rupture_cntrt :=NULL;
                  IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_FICHIER(loc_affil_fichier,i_journal) THEN
                    RAISE exc_ins_remise;
                  END IF;

                ELSE
                  NULL;--à conserver car on fait rien sinon!!!
                END IF;
              ELSIF   Rec_C_ENTITE.entite ='AFFIL_PORTE_CNTRT' THEN
                IF Rec_C_ENTITE.donnee ='REF_ORGN_CNTRT' AND NVL(s_rupture_cntrt,0)  <> TRIM(l_T_ligne(Rec_C_ENTITE.position))  THEN
                  cpt_cntrt :=cpt_cntrt+1;

             --   IF cpt_sal = 0 THEN
                  loc_AFFIL_PORTE_CNTRT.numremise := loc_AFFIL_FICHIER.numremise;
                  loc_AFFIL_PORTE_CNTRT.numporte := loc_AFFIL_FICHIER.numporte;
                  loc_AFFIL_PORTE_CNTRT.entreprise:= loc_AFFIL_FICHIER.entreprise;
                  loc_AFFIL_PORTE_CNTRT.etabli := loc_AFFIL_FICHIER.etabli;
                  loc_AFFIL_PORTE_CNTRT.REF_EXT_CNTRT :=cpt_cntrt;
                  loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT:= PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR_AFF(l_T_ligne(Rec_C_ENTITE.position),cpt_sal, Rec_C_ENTITE, i_journal, cpt_ligne);
                  loc_AFFIL_PORTE_CNTRT.NUM_ORDRE :=1;
                  s_rupture_cntrt:= loc_AFFIL_PORTE_CNTRT.REF_ORGN_CNTRT;

                  IF NOT PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_CNTRT(loc_AFFIL_PORTE_CNTRT,i_journal) THEN
                    RAISE exc_ins_remise;
                  END IF;
                ELSE
                  NULL;--à conserver car on fait rien sinon!!!
                END IF;

              --dbms_output.put_line(Rec_C_ENTITE.entite||'-'||Rec_C_ENTITE.contrainte ||'-'||l_T_ligne(Rec_C_ENTITE.position));
              ELSIF Rec_C_ENTITE.entite ='AFFIL_PORTE'
                 AND Rec_C_ENTITE.contrainte ='GROUPE'
                 AND (s_rupture IS NULL OR s_rupture <> TRIM(l_T_ligne(Rec_C_ENTITE.position))) THEN
                s_rupture := TRIM(l_T_ligne(Rec_C_ENTITE.position));
                cpt_sal:=cpt_sal+1; --on change de salarié
                cpt_ayd:=0;--on réinitiailisation le compteur des ayd en conséquence
                IS_SAL :=TRUE;
                IS_AYD:=FALSE;
                dbms_output.put_line('SALARIE'||Rec_C_ENTITE.entite||'-'||cpt_sal);

              --on est sur un ayant droit du salarié=> il ne faut donc pas créer d'affil_porte
              ELSIF Rec_C_ENTITE.entite ='AFFIL_PORTE'
                 AND Rec_C_ENTITE.contrainte ='GROUPE'
                 AND s_rupture IS NOT NULL
                 AND s_rupture = TRIM(l_T_ligne(Rec_C_ENTITE.position)) THEN
                 IS_AYD:=TRUE;
                 IS_SAL:=FALSE;

              --traitement conditionné des entités selon le contexte
              ELSIF IS_SAL OR (IS_AYD AND  Rec_C_ENTITE.entite NOT IN ('AFFIL_PORTE','AFFIL_PORTE_RIB') )THEN
                IF s_entite IS NULL OR s_entite<>Rec_C_ENTITE.entite THEN
                    --***RUPTURE SUR LE AYD***--
                    IF Rec_C_ENTITE.entite ='AFFIL_PORTE_AYD' AND Rec_C_ENTITE.contrainte <>l_T_ligne(Rec_C_ENTITE.position) THEN
                      cpt_ayd:=cpt_ayd+1;
                    END IF;

                  --***CREATION DES REQUETES D'INSERTION DANS LES TABLES ENTITES
                  IF s_entite IS NOT NULL THEN
                    l_T_entite(cpt_entite) :=RTRIM(stmt_init,',') || RTRIM(stmt_value,',')||')';
                  END IF;

                  s_entite := Rec_C_ENTITE.entite;
                  s_donnee := Rec_C_ENTITE.donnee;
                  cpt_entite:=cpt_entite+1;
                  stmt_init := 'INSERT INTO '||s_entite||' (';

                  IF Rec_C_ENTITE.entite ='AFFIL_PORTE' THEN
                   stmt_clef := 'NUMREMISE,NUMPORTE,NUMLIGNE,NUM_ORDRE,ETAT,DATRAIT,ENTREPRISE,ETABLI,';
                    stmt_value := ') VALUES ('|| i_remise.numremise ||','|| i_porte ||','|| cpt_sal||',1,2,e2d('''||to_char(sysdate,'dd/mm/yyyy')||'''),'''||loc_AFFIL_FICHIER.entreprise||''','''||loc_AFFIL_FICHIER.etabli ||''',';
                  ELSIF Rec_C_ENTITE.entite ='AFFIL_PORTE_AYD' THEN
                    stmt_clef := 'NUMREMISE,NUMPORTE,NUMLIGNE,NUMAYD,';
                    stmt_value := ') VALUES ('|| i_remise.numremise ||','|| i_porte ||','|| cpt_sal||','|| cpt_ayd||',';
                  ELSIF Rec_C_ENTITE.entite ='AFFIL_PORTE_ADH' THEN
                    stmt_clef := 'NUMREMISE,NUMPORTE,NUMLIGNE,NUMAYD,NUMADH,REF_EXT_CNTRT,';
                    stmt_value := ') VALUES ('|| i_remise.numremise ||','|| i_porte ||','|| cpt_sal||','|| cpt_ayd||',1,'||cpt_cntrt||',';   --on ne devrait avoir qu'une adhésion par contrat
                  ELSIF Rec_C_ENTITE.entite ='AFFIL_PORTE_RIB' THEN
                    stmt_clef := 'NUMREMISE,NUMPORTE,NUMLIGNE,NUMAYD,MODE_PAIE,';--pour le moment on force le mode de paiement
                    stmt_value := ') VALUES ('|| i_remise.numremise ||','|| i_porte ||','|| cpt_sal||','|| cpt_ayd||',1,';
                  ELSE
                    stmt_clef:='';
                    stmt_value:='';
                  END IF;
                  stmt_init:= stmt_init ||stmt_clef;
                END IF ;

                stmt_init := stmt_init ||Rec_C_ENTITE.donnee||',';

                IF l_T_ligne(Rec_C_ENTITE.position)IS NULL THEN
                  stmt_value := stmt_value||'NULL,';
                ELSE
                  --TODO contrôle de la longueur vis à vis de la longueur attendue
                  stmt_value := stmt_value||''''||PK_CTRL_AFFIL.F_CTRL_NUMBER_VARCHAR_AFF(l_T_ligne(Rec_C_ENTITE.position),cpt_sal, Rec_C_ENTITE, i_journal, cpt_ligne) ||''',';
                END IF;
            END IF; --rupture

            EXCEPTION
              WHEN OTHERS THEN
                P_INS_journal(3,i_journal, 'Ligne <'||TO_CHAR(cpt_ligne)||'>  <'||s_entite||'.'||s_donnee||'>'||l_T_ligne(Rec_C_ENTITE.position)||'-'||SQLERRM);
            END;
          END LOOP;
          --une dernière fois à la sortie de boucle !
          l_T_entite(cpt_entite) :=  RTRIM(stmt_init,',') || RTRIM(stmt_value,',')||')' ;

        EXCEPTION
          WHEN OTHERS THEN
         --   P_INS_journal(3, i_journal,'stmt_init <'||stmt_init||'> ');
        --    P_INS_journal(3,i_journal, 'stmt_value <'||stmt_value||'> ');
            P_INS_journal(1,i_journal, 'Ligne <'||TO_CHAR(cpt_ligne)||'>  <'||s_entite||'.'||s_donnee||'> '||SQLERRM);
            cpt_bad_ligne:=cpt_bad_ligne+1;
        END;

        /****INSERTION DE CHAQUE LIGNE****/
        FOR i in 1..l_T_entite.count LOOP
          dbms_output.put_line(l_T_entite(i));
         -- P_INS_journal(3,i_journal, l_T_entite(i));

        BEGIN
          EXECUTE IMMEDIATE trim(l_T_entite(i)) ;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            CASE SQLCODE
              WHEN '-917'   THEN P_INS_journal(1,i_journal,' Ligne <'||TO_CHAR(cpt_ligne)||'> invalide(Problème d''apostrophe)');
              WHEN '-947'   THEN P_INS_journal(1,i_journal,' Ligne <'||TO_CHAR(cpt_ligne)||'> invalide(Nb colonnes insuffisantes)');
              WHEN '-12899' THEN P_INS_journal(1,i_journal,' Ligne <'||TO_CHAR(cpt_ligne)||'> invalide(nb caractères trop long pour la colonne<'||SUBSTR (SQLERRM (SQLCODE), 68, 128)||'>)');
            ELSE
              P_INS_journal(1, i_journal,'Ligne <'||TO_CHAR(cpt_ligne)||'> : Erreur indéterminée :' ||SQLERRM);
            END CASE;
            cpt_bad_insert:=cpt_bad_insert+1;
        END;
        END LOOP;
        --l_T_import(nbligne):=l_T_entite;
        --l_T_import(cpt_ligne):=l_T_entite;--aprioiri on en fait rien
        l_T_entite:=l_T_entite_empty; --réinitialisation
     /* ELSE  TODO à quoi cela sert ???
        IF SUBSTR(s_ligne, 1, LENGTH(s_donnee)) != s_donnee / THEN
          cpt_bad_entete:=cpt_bad_entete+1;
        END IF;*/
      END IF;
      END;
    END LOOP;

    UPDATE AFFIL_FICHIER set datefic =(SELECT MIN(e2d(debutc)) FROM AFFIL_PORTE WHERE numremise =i_remise.numremise and numporte =i_Porte )
    WHERE numremise = i_remise.numremise
    AND numporte = i_Porte;

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

    P_INS_journal(1,i_journal, 'Le nombre de lignes traitées dans le fichier est de <'||cpt_ligne||'>');
    P_INS_journal(1,i_journal, 'Le nombre de salariés <'||cpt_sal||'>');

    IF cpt_rejet>0 THEN
      RAISE exc_bad_fichier;
    ELSE
      P_INS_journal(3,i_journal, 'Fichier des affiliations traité avec succès');
    END IF;

    EXCEPTION
      WHEN exc_ins_remise THEN
        P_INS_journal(1, i_journal,'Insertion remise fichier impossible, erreur : < '||SQLERRM||' >');
        RAISE exc_fin_remise;
    WHEN exc_bad_fichier THEN
      P_INS_journal(3,i_journal, 'Fermeture du fichier suite à erreur');
      --UTL_FILE.fclose (h_fichier);
       P_INS_journal(1, i_journal,'Le nombre total de Lignes invalide est de  <'||TO_CHAR(cpt_bad_insert)||'>');
       RAISE exc_fin_remise;
    WHEN exc_bad_separateur THEN
         P_INS_journal(1, i_journal,'Nombre de colonne identifiée :'||s_nb_separateur||',attentue :'||Rec_C_ECHANGE.longueur||'. Vérifier la structure du fichier');
         RAISE exc_fin_remise;
     WHEN OTHERS THEN
        P_INS_journal(1, i_journal, 'Lig:'||cpt_ligne||'- erreur :'||SQLERRM);
        cpt_ano:=cpt_ano+1;
        RAISE exc_fin_remise;

END IMPORT_AFFIL_AF02;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                  */
/* Nom          :  p_ctrlFichierAffil                                        */
/* Type         :  Privee                                                    */
/* Description  :  Controle du nom de fichier, du répertoire, de la structure*/
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
PROCEDURE p_ctrlFichierAffil
   (
      i_repertoire IN VARCHAR2,
      i_fichier    IN OUT VARCHAR2,
      i_format     IN NUMBER,
      o_erreur OUT VARCHAR2
   )
IS
   h_fichier UTL_FILE.file_type;
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
   IF TRIM(pk_libelle.f_lib('TYPFORMAT',i_format)) IS NULL THEN
      RAISE exc_extension;
   ELSE
     i_fichier:=i_fichier||pk_libelle.f_lib('TYPFORMAT',i_format);
   END IF;
   h_fichier := UTL_FILE.fopen (i_repertoire, i_fichier, 'R', 32767);
   UTL_FILE.fclose (h_fichier);


   --------------- Vérification que le fichier physique n a pas déja été importé ---------------
   SELECT max(numremise)
   INTO l_numremise
   FROM PORTE_REMISE
   WHERE ref_ext = i_fichier;


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

PROCEDURE P_ANNUL_REMPLACE( P_AFFIL_FICHIER AFFIL_FICHIER%ROWTYPE ,
                            P_remise porte_remise.numremise%TYPE,
                            i_session     IN       JOURNAL_ADM.ID_SESSION%TYPE,
                            i_traitement  IN       JOURNAL_ADM.NOM_TRAITEMENT%TYPE,
                            i_idligne     IN OUT   JOURNAL_ADM.IDLIGNE%TYPE,
                            i_stop        OUT VARCHAR2) IS

p_num_ordre AFFIL_PORTE.NUM_ORDRE%TYPE  ;

BEGIN
  IF P_AFFIL_FICHIER.num_annul IS NULL AND P_AFFIL_FICHIER.num_ordre IS NOT NULL THEN
    BEGIN
      --M0005453 : on détermine de suite le fichier à annuler
      SELECT NUM_ORDRE INTO p_num_ordre
      FROM AFFIL_FICHIER
      WHERE NUMREMISE = P_remise
      AND NUMPORTE =P_AFFIL_FICHIER.numporte
      AND ENTREPRISE =P_AFFIL_FICHIER.entreprise
      AND ETABLI = P_AFFIL_FICHIER.etabli
      AND num_ordre < P_AFFIL_FICHIER.num_ordre -- num_ordre du fichier à annuler doit être inférieur au num_ordre du fichier annulant
      AND NUM_ANNULANTE IS  NULL;

    exception
        WHEN OTHERS THEN i_stop := 'Détermination du fichier à annuler impossible ' ;
    END;
  END IF;

  PK_CTRL_AFFIL.P_ANNULATION_AFFILIATION (  P_numremise  => P_remise,
                             P_entreprise => P_AFFIL_FICHIER.entreprise,
                             P_etabli      => P_AFFIL_FICHIER.etabli,
                             P_num_ordre   => NVL(substr(P_AFFIL_FICHIER.num_annul,9), p_num_ordre), -- M0005453
                             P_annul       => P_AFFIL_FICHIER.num_ordre,
                             P_numligne    => NULL, --toutes les lignes du périmètre
                             P_numporte    => P_AFFIL_FICHIER.numporte,
                             i_session     => i_session,
                             i_traitement  => i_traitement,
                             i_idligne     => i_idligne,
                             o_erreur      => i_stop,
                             p_type        => 2);



END P_ANNUL_REMPLACE;


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
END PK_IMPORT_AFFIL_DSN;
/
