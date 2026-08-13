CREATE OR REPLACE PACKAGE ARTHUS."PK_WS_WEB_BACK"
  as
  /*=========================================================================
  PAckage      : PK_WS_WEB_BACK
  Domaine      : INTERFACE WEB - webservice
  Version      : V1.0
  Auteur       : SDA
  Création     : 17/04/2012
  Description  :
  ==========================================================================
  Evolution    :
  Auteur       :
  Date         :
  Commentaire  :
  ==========================================================================
  Correction   : SDA M4916 07/08/2015
                 PHA M5331 19/06/2017 Contrôle adhérent bien couvert à la date des soins
                 PHA M5333 21/06/2017 Extranet : ne remonter que les cartes annees en cours et annee plus un
                 ABO 04/07/2017 sécurisation des notifications pour ne pas afficher les mouvements du jour
                 CLI 27/07/2017 M5353 affichage des devis validés uniquement
                 ABO 23/08/2017 M5350 affichage des décompte même si sinistre payé sur adhésion résiliée(tant que l'adhérent est couvert sur autre contrat)
                 JBO 06/11/2017 P201709001_EA_Adhesion_Ind_GEREP : Ajout de la RUM pour l'affichage des échéanciers des cotisations en ligne(chapitre 2.8.1 de la PC)

 ============================================================*/

  /***********************************************************/
  FUNCTION F_COMPANY_LIST_BY_REP(
    P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_SOCIETE;
  /***********************************************************/
   FUNCTION F_GET_CONTRATS_BIA ( P_NUMCLI NUMBER, p_PORTE NUMBER, P_NUMGAR NUMBER )
  RETURN EXTR_TAB_CONTRAT ;

  /**********************************************************/
  FUNCTION F_CONTRACT_LIST_BY_COMP(
    P_NUMINDIV EXTR_TAB_NUMINDIV,
    P_NUMGAR   CONTRAT.NUMGAR%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
    ,P_FLAG     NUMBER DEFAULT 0 --RKO M0006874
  ) RETURN EXTR_TAB_CONTRAT;

  /**********************************************************/
  FUNCTION F_CONTRACT_LIST_BY_COMP_PREV(
    P_NUMINDIV EXTR_TAB_NUMINDIV,
    P_NUMGAR   CONTRAT.NUMGAR%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_CONTRAT;

  /***********************************************************/
  FUNCTION F_CONTRACT_TO_SIGN_UP(
    P_NUMADHE   INDIVIDU.NUMINDIV%type,
    P_NUMGAR    CONTRAT.NUMGAR%TYPE,
    P_NATURE     VARCHAR2,
    P_DATEEFFET   DATE,
    P_NUMCLI       NUMBER
  ) RETURN EXTR_PROSPECT;
  /***********************************************************/

  FUNCTION F_SEARCH_AFFILIATES(
    P_NUMINDIV EXTR_TAB_NUMINDIV,
    P_NUMGAR EXTR_TAB_NUMGAR,
    P_NOM INDIVIDU.NOM%TYPE,
    P_PRENOM INDIVIDU.PRENOM%TYPE,
    P_NUMSS  INDIVIDU.MATORG%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_AFFILIE;

  /***********************************************************/
  FUNCTION F_GET_AFF(
    P_NUMASSUP INDIVIDU.NUMINDIV%TYPE,
    P_NUMADHE  INDIVIDU.NUMINDIV%TYPE,
    P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE DEFAULT NULL,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_AFFILIE_DETAIL;
  /***********************************************************/
  FUNCTION F_VERIFY_USER_ACCOUNT (
    P_NOM INDIVIDU.NOM%TYPE,
    P_PRENOM INDIVIDU.PRENOM%TYPE,
    P_DATE INDIVIDU.DATNAIS%TYPE,
    P_MAIL CONTACT.COORDONNEE%TYPE,
    P_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  )
  RETURN EXTR_TAB_REP_ACTION;
  /***********************************************************/
  FUNCTION F_EDIT_COMPANY  (
    P_NUMINDIV  INDIVIDU.NUMINDIV%TYPE,
    P_NOM       INDIVIDU.NOM%TYPE,
    P_TELEPHONE CONTACT.COORDONNEE%TYPE,
    P_TELECOPIE CONTACT.COORDONNEE%TYPE,
    P_EMAIL     CONTACT.COORDONNEE%TYPE,
    P_NUMSIRET  PERS_MORALE.SIRET%TYPE,
    P_CODEAPE   PERS_MORALE.APE%TYPE
  )
  RETURN EXTR_TAB_REP_ACTION;
  /***********************************************************/
  FUNCTION F_AJOUT_DETAIL_ACTION(
     TYPE          VARCHAR2,   --AUTO or MANUEL
     MESSAGE       VARCHAR2,   --MESSAGE DE LA REP
     CLEF          NUMBER,     --clef de retour
     ORIGINE       VARCHAR2,   --ARTHUS
     SUCCES        NUMBER,     --1 OK 0 KO
     NOMWS         VARCHAR2,   --NOM DU WEB SEVICE
     TB_DETAIL     EXTR_TAB_DETAIL_ACTION
  )
  RETURN EXTR_TAB_DETAIL_ACTION;
  /***********************************************************/
  FUNCTION F_COOR_BANQUE (
    P_NUMINDIV  INDIVIDU.NUMINDIV%TYPE
  ) RETURN EXTR_TAB_RIB;
  /***********************************************************/
  FUNCTION F_COTISATION (
    P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
    P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE,
    P_TYPE_QUERABLE NUMBER,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_COTISATION;
  /***********************************************************/
  /*********** FONCTION DE MUTUALISATION A VENIR ************/
  /*FUNCTION F_GET_GARANTIES (
         P_NUMFOR ADHESION.NUMFOR%TYPE,
         P_DATAPLI ADHESION.DATAPLI%TYPE,
         P_DATPER ADHESION.DATPER%TYPE,
         P_OBLIGATOIRE  GAR_CNTRT.OBLIGATOIRE%TYPE,
         P_FLAG_REGIME ADHESION.FLAG_REGIME%TYPE
       ) RETURN EXTR_TAB_GARANTIE;*/
  /***********************************************************/
  FUNCTION F_DECOMPTE (
    P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
    P_ANNEE    NUMBER,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_DECOMPTE;

  FUNCTION F_DECOMPTE_V7 (
    P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
    P_ANNEE    NUMBER,
    P_DEBUT    DATE,
    P_FIN      DATE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_DECOMPTE;

  FUNCTION F_PIECE ( I_NUMINDIV INDIVIDU.NUMINDIV%TYPE, I_PARAMS IN EXTR_Q_PIECE) RETURN EXTR_TAB_PIECE ;

  FUNCTION F_CARTETPE ( I_NUMINDIV INDIVIDU.NUMINDIV%TYPE) RETURN EXTR_TAB_CARTE_TPE ;
  /***********************************************************/
  FUNCTION F_ADRESSE_BY_NUMINDIV(
           P_NUMINDIV INDIVIDU.NUMINDIV%TYPE
  )RETURN EXTR_ADRESSE_TR;
  /***********************************************************/
  PROCEDURE f_adresse (
        a_idadresse     in Number,
        --a_indice     in Number,
        a_numindiv     in Number    Default 0,
        a_force     in Number    Default 0,
        a_codope        in Number       Default 0,
        adresse1 OUT VARCHAR2,
        adresse2 OUT VARCHAR2,
        adresse3 OUT VARCHAR2,
        codpos   OUT VARCHAR2,
        ville    OUT VARCHAR2,
        pays    OUT NUMBER
  );
  /***********************************************************/
  Function F_COM_DECOMPTE(
           i_NUMDEC IN COURRIER.NUMDEC%TYPE,
           i_CODFRAIS IN COURRIER.CODFRAIS%TYPE,
           i_NUMSIN  IN COURRIER.NUMSIN%TYPE
  )
  RETURN COURRIER.TEXT%TYPE;
  /***********************************************************/

  Function F_EMETTEUR(
           i_numorg in PARPORTE.NUMORG%TYPE

  ) RETURN PARPORTE.NUMEMETTEUR%TYPE;
  /***********************************************************/
  FUNCTION F_GET_CIRCUITS_INFO(I_NUMINDIV INDIVIDU.NUMINDIV%TYPE)
  RETURN  EXTR_TAB_CIRCUIT_INFO;
  /***********************************************************/
  FUNCTION F_GET_PRCH(I_NUMASSU INDIVIDU.NUMINDIV%TYPE, I_DATE_DEBUT DATE, I_DATE_FIN DATE)
  RETURN  EXTR_TAB_PRCH;

  /***********************************************************/
  FUNCTION F_GET_DEVIS(I_NUMASSU INDIVIDU.NUMINDIV%TYPE, I_DATE_DEBUT DATE, I_DATE_FIN DATE)
  RETURN  EXTR_TAB_DEVIS_SANTE;

 /*************************************************/
  FUNCTION F_GET_SERVICES(I_NUMGAR contrat_ref.numgar%TYPE)
  RETURN  EXTR_TAB_SERVICE;

   /*************************************************/
  FUNCTION F_GET_DEMANDES(I_NUMINDIV INDIVIDU.numindiv%TYPE,
                          i_idrappel rappel.idrappel%type,
                          i_debut date ,
                          i_fin date ,
                          i_numBene rappel.numbene%type,
                          i_etat rappel.etat%type  )
  RETURN  EXTR_TAB_DEMANDE;

 /*************************************************/
  FUNCTION F_GET_ACTS_INSURED(I_NUMBENE INDIVIDU.numindiv%TYPE,
                              i_NUMGAR   CONTRAT.NUMGAR%TYPE,
                              i_datsin DATE ,
                              i_type NUMBER)
  RETURN  EXTR_TAB_ACTS_INSURED;
  /*************************************************/
  FUNCTION F_LIST_EMPLOYEE_dev(I_params EXTR_Q_LIST_EMPLOYEE)
  RETURN EXTR_R_LIST_EMPLOYEE  ;
/*************************************************/
  FUNCTION F_GET_IDENTIFIANT_RH(i_email VARCHAR2)
  RETURN NUMBER ;

  /***********************UTIL *************************************/
  /***********************************************************/
  PROCEDURE P_INFO_QUERABLE(
    I_NUMQUERABLE           IN CONTRAT_REF.NUMQUERABLE%TYPE,
    O_CIV_NUMQUERABLE       OUT LIBELLE.LIBELLE%TYPE,
    O_NOM_NUMQUERABLE       OUT INDIVIDU.NOM%TYPE,
    O_PRENOM_NUMQUERABLE    OUT INDIVIDU.PRENOM%TYPE
  );

  /***********************************************************/
  FUNCTION f_statut_noemie(I_NUMINDIV INDIVIDU.NUMINDIV%TYPE, I_IDPORTE PORTE_ADHESION.IDPORTE%TYPE)  RETURN VARCHAR2;
  /***********************************************************/
  FUNCTION F_RESEAU(i_numsin SINISTRE.NUMSIN%TYPE) RETURN VARCHAR2 ;
  /***********************************************************/
  FUNCTION F_TOT_SIN_PAYE(i_numassu INDIVIDU.NUMINDIV%TYPE,
                          i_numdecaimst DECAISMT.NUMDECAISMT%TYPE,
                          i_mtdecais DECAISMT.MONTANT%TYPE,
                          i_mtdcpt AFFECTATION.MONTANT%TYPE,
                          i_modpmt DECAISMT.MODPMT%TYPE,
                          i_typbene DECOMPTE.TYPBENE%TYPE) RETURN NUMBER;
  /***********************************************************/
  FUNCTION f_libgar ( I_numfor IN gar_cntrt.numfor%Type )RETURN VARCHAR2 ;
  /***********************************************************/
  FUNCTION F_DROIT_GAR(i_typadr adhe_cntrt_membre.typadr%TYPE,i_obli_bene formule.obli_bene%TYPE, p_numfor_base formule.numfor%TYPE, p_numfor_opt formule.numfor%TYPE, p_nombre_ayant_droit NUMBER) RETURN VARCHAR2;
  FUNCTION F_FIND_MT_COT (i_numfor formule.numfor%TYPE, i_base frml_prime_simple.base%TYPE, i_taux NUMBER , i_date IN DATE, i_typadr NUMBER, i_ayd individu.numindiv%TYPE ,i_adhesion adhesion.idadhesion%TYPE) RETURN NUMBER;
  FUNCTION IS_ADHESION_EXISTS(i_NUMFOR adhesion.numfor%type, i_numbene adhesion.numindiv%type, i_date DATE, i_type NUMBER default 1, p_numadhe number default null, p_obli_bene VARCHAR2 default null) RETURN NUMBER;
  --suppression ancienne F_GET_DATE_EFFET car historiquement jamais utilisé (changement de SFD projet en qualification client
  FUNCTION F_GET_DATE_EFFET(i_numgar_base number, i_numindiv number, i_idadhesion_base number, i_nature_souscript number ) return date  ;

  FUNCTION F_GET_CONTRATS_DEPENDANTS ( p_numgar NUMBER, p_date DATE, p_type NUMBER default 2 ) RETURN EXTR_TAB_CONTRAT;

  FUNCTION F_GET_EXTR_BENE_PROSPECT( l_numindiv individu.numindiv%type,  l_tab_bene EXTR_TAB_BENE_PROSPECT) RETURN EXTR_BENE_PROSPECT;
  FUNCTION F_GET_EXTR_CONTRACT( l_numgar ADHESION.NUMGAR%type,  l_tab_contracts EXTR_TAB_CONTRACT_TO_SIGN_UP) RETURN EXTR_CONTRACT_TO_SIGN_UP;
  FUNCTION F_GET_EXTR_GRNT( l_numoffre ADHESION.NUMFOR%type,  l_tab_GRNT EXTR_TAB_GRNT_TO_SIGN_UP) RETURN EXTR_GRNT_TO_SIGN_UP;
  FUNCTION F_FORMAT ( P_Chaine   IN   VARCHAR2) RETURN  VARCHAR2;
  FUNCTION F_CONSUlT_SOUSBASE(  P_NUMADHE   INDIVIDU.NUMINDIV%type,
                                P_NUMGAR    CONTRAT.NUMGAR%TYPE,
                                P_DATEEFFET  DATE,
                                P_NUMCLI     number)
  RETURN EXTR_PROSPECT;

  FUNCTION        F_ETAT_ADHE_WS (
         a_idadhesion   IN NUMBER,
         a_date      IN DATE,
         a_type in number default 1)RETURN NUMBER;


  /*****************************************************************************/
  FUNCTION F_WS_LIST_EVENT(i_numindiv INDIVIDU.NUMINDIV%TYPE, i_nosin SNTR_PREV.NOSIN%TYPE)
  RETURN EXTR_TAB_LIST_EVENT ;
  /*****************************************************************************/
  FUNCTION F_WS_LIST_PREV(i_params EXTR_Q_LIST_PREV)
  RETURN EXTR_TAB_LIST_PREV;
  /****************************************************************************/
  FUNCTION F_WS_LIST_PREV_INFO(i_params EXTR_Q_PREV_INFO)
  RETURN EXTR_TAB_LIST_PREV_INFO;
  /****************************************************************************/
  FUNCTION F_get_note_frml_prest(p_numfor repartition.numfor%TYPE ) RETURN VARCHAR2;
  /****************************************************************************/
  FUNCTION F_get_note_frml_reval(p_numfor repartition.numfor%TYPE ) RETURN VARCHAR2;
  /****************************************************************************/
  FUNCTION F_etat_sntr_prev ( p_etat histo_sntr_prev.etat%TYPE, p_idrepartition repartition.idrepartition%TYPE, p_nosin SNTR_PREV.NOSIN%TYPE, p_sens libelle.sens%TYPE)
  RETURN NUMBER;
  /****************************************************************************/
  FUNCTION F_GET_ANCIENNETE (p_numindiv NUMBER) RETURN DATE ;
  /****************************************************************************/
  FUNCTION F_WS_LIST_DCPT_PREV(i_params EXTR_Q_DCPT_PREV)
  RETURN EXTR_TAB_LIST_DCPT_PREV ;

  /****************************************************************************/
 FUNCTION F_WS_BOARD_COUNTER(i_numindiv individu.numindiv%TYPE,
                            i_type     EXTR_Q_BC)
  RETURN EXTR_BOARD_COUNTER ;
   /****************************************************************************/
  FUNCTION F_BOARDCOUNTER_CPT1(I_CLE IN ARTHUS_CACHE.CLE%TYPE)
  RETURN NUMBER;
    /****************************************************************************/
  FUNCTION F_BOARDCOUNTER_CPT2(I_CLE IN ARTHUS_CACHE.CLE%TYPE)
  RETURN NUMBER;
    /****************************************************************************/
  FUNCTION F_BOARDCOUNTER_CPT3(I_CLE IN ARTHUS_CACHE.CLE%TYPE)
  RETURN NUMBER;
    /****************************************************************************/
  FUNCTION F_BOARDCOUNTER_CPT4(I_CLE IN ARTHUS_CACHE.CLE%TYPE)
  RETURN NUMBER;
  /*****************************************************************************/
  FUNCTION F_list_employ_niv_6  (i_numindiv individu.numindiv%type,
                                i_nom individu.nom%type,
                                i_prenom individu.prenom%type,
                                i_matorg individu.matorg%type,
                                i_datnais individu.datnais%type,
                                i_numcli individu.numindiv%type,
                                i_numgar contrat.numgar%type,
                                i_college contrat.college%type
                                )  RETURN  EXTR_R_LIST_EMPLOYEE;

   FUNCTION F_list_employ_niv_7  (i_numindiv individu.numindiv%type,
                                i_nom individu.nom%type,
                                i_prenom individu.prenom%type,
                                i_matorg individu.matorg%type,
                                i_datnais individu.datnais%type,
                                i_numcli individu.numindiv%type,
                                i_numgar contrat.numgar%type,
                                i_college contrat.college%type
                                )  RETURN  EXTR_R_LIST_EMPLOYEE;
  END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_WS_WEB_BACK" as

  /****privées***/
  FUNCTION F_LIB_TRPNT (i_type TRPNT.TYPE_TIERS%TYPE,
                        i_regime TRPNT.REGIME%TYPE,
                        i_caisse TRPNT.CAISSE%TYPE,
                        i_centre TRPNT.CENTRE%TYPE) RETURN TRPNT.NOM%TYPE;
  /***********************************************************/
  FUNCTION F_COMPANY_LIST_BY_REP(
    P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  )
  RETURN EXTR_TAB_SOCIETE IS

    CURSOR C_SEL_SOCIETE_INTERLOCUTEUR(V_NUMINDIV IN INDIVIDU.NUMINDIV%TYPE)  IS
      SELECT NUMINDIV ,'INTERLOC' typ_param FROM INTERLOCUTEUR
      WHERE INTERLOCUTEUR = V_NUMINDIV
      AND VALIDE = 'O'
      UNION
      SELECT NUMCLI NUMINDIV ,'SOCIETE' typ_param FROM CONTRAT WHERE NUMCLI = V_NUMINDIV;

    CURSOR C_SEL_SOCIETE(V_NUMINDIV IN INDIVIDU.NUMINDIV%TYPE) IS
      SELECT INDIVIDU.QUALITE,
      F_LBLE('QLTE',INDIVIDU.QUALITE) as LIB_QUALITE,
      INDIVIDU.NUMINDIV,
      INDIVIDU.NOM,
      PERS_MORALE.ABREGE,
      PERS_MORALE.APE,
      PERS_MORALE.SIRET,
      F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,4,1) as mail,
      F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,1,1) as telephone,
      F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,3,1) as telecopie
      FROM INDIVIDU,PERS_MORALE
      WHERE INDIVIDU.NUMINDIV = V_NUMINDIV
      AND INDIVIDU.NUMINDIV = PERS_MORALE.NUMINDIV
      ;


    CURSOR C_SEL_INTERLOCUTEUR(V_NUMINDIV IN INDIVIDU.NUMINDIV%TYPE, P_NUMINDIV IN INTERLOCUTEUR.INTERLOCUTEUR%TYPE) IS
      SELECT  MIN(IDINTERLOCUTEUR) IDINTERLOCUTEUR,
      INTERLOCUTEUR,
      INDIVIDU.QUALITE,
      F_LBLE('QLTE',INDIVIDU.QUALITE) as LIB_QUALITE,
      INDIVIDU.NOM,
      INDIVIDU.PRENOM,
      NULL OPE_CRRR,--INTERLOCUTEUR.OPE_CRRR,
      NULL LIB_SERVICE,--F_LBLE('OPE_CRRR',INTERLOCUTEUR.OPE_CRRR) as LIB_SERVICE,
      NULL VALIDE,-- INTERLOCUTEUR.VALIDE,
      F_COORDONNE_CONTACT(interlocuteur,4,1) as mail,
      F_COORDONNE_CONTACT(interlocuteur,1,1) as telephone,
      F_COORDONNE_CONTACT(interlocuteur,3,1) as telecopie,
      NULL FONCTION,--INTERLOCUTEUR.FONCTION,
      NULL LIB_FONCTION,-- F_LBLE('FONCTION',INTERLOCUTEUR.FONCTION) as LIB_FONCTION,
      MAX(INTERLOCUTEUR.DEFAUT) DEFAUT,
      MIN(INTERLOCUTEUR.DEBUT ) DEBUT,
      MAX(INTERLOCUTEUR.FIN) FIN
      FROM INTERLOCUTEUR, INDIVIDU
      WHERE INTERLOCUTEUR.numindiv = V_NUMINDIV
      AND INTERLOCUTEUR.INTERLOCUTEUR = INDIVIDU.NUMINDIV
      AND TRUNC(SYSDATE) BETWEEN NVL(DEBUT,TRUNC(SYSDATE)) AND NVL(FIN,TRUNC(SYSDATE))
      AND INTERLOCUTEUR.VALIDE='O'
      AND INTERLOCUTEUR.INTERLOCUTEUR = NVL(P_NUMINDIV ,INTERLOCUTEUR.INTERLOCUTEUR)
      GROUP BY
        INTERLOCUTEUR,
        INDIVIDU.QUALITE,
        INDIVIDU.NOM,
        INDIVIDU.PRENOM,
        F_COORDONNE_CONTACT(interlocuteur,4,1) ,
        F_COORDONNE_CONTACT(interlocuteur,1,1) ,
        F_COORDONNE_CONTACT(interlocuteur,3,1)
      UNION
      SELECT NUMCLI,numcli,
      INDIVIDU.QUALITE,
      F_LBLE('QLTE',INDIVIDU.QUALITE) as LIB_QUALITE,
      f_nom(numcli),
      NULL,
      0,
      F_LBLE('OPE_CRRR',0) as LIB_SERVICE,
      'O',
      F_COORDONNE_CONTACT(numcli,4,1) as mail,
      F_COORDONNE_CONTACT(numcli,1,1) as telephone,
      F_COORDONNE_CONTACT(numcli,3,1) as telecopie,
      NULL as FONCTION,
      NULL as LIB_FONCTION,
      'O',
      NULL,
      NULL
      FROM CONTRAT ,INDIVIDU
      WHERE CONTRAT.NUMCLI = INDIVIDU.NUMINDIV
      AND  CONTRAT.NUMCLI = V_NUMINDIV
      AND P_NUMINDIV IS NULL
      ORDER BY 7,15 DESC;


    V_SEL_SOCIETE_INTERLOCUTEUR C_SEL_SOCIETE_INTERLOCUTEUR%ROWTYPE;
    V_SEL_SOCIETE C_SEL_SOCIETE%ROWTYPE;
    V_SEL_INTERLOCUTEUR C_SEL_INTERLOCUTEUR%ROWTYPE;

    TB_SOCIETE EXTR_TAB_SOCIETE;
    TB_SERVICES  EXTR_TAB_INTERLOC_SERV; --RKO EA PREV
    TB_INTERLOCUTEUR EXTR_TAB_INTERLOCUTEUR;
    CPT NUMBER := 0;
    CPT_2 NUMBER := 0;
    idligne NUMBER := 0;

     T_ADRESSE   VARCHAR2(200);
     T_ADRESSE_2 VARCHAR2(200);
     T_ADRESSE_3 VARCHAR2(200);
     T_CODPOS    VARCHAR2(40);
     T_VILLE     VARCHAR2(30);
     T_PAYS      NUMBER(3);
     T_LIB_PAYS  VARCHAR2(45);
     loc_nomste VARCHAR2(60);
     loc_serv_prev   NUMBER;
     loc_serv_affil  NUMBER;
     loc_interloc  INDIVIDU.numindiv%TYPE;

  BEGIN
    TB_SOCIETE := new EXTR_TAB_SOCIETE(null);

    CPT := 1;
    PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_COMPANY_LIST_BY_REP',
      I_session  => SID,
      I_niv_msg  => 1,
      I_msg_adm  => 'P_numindiv = '||P_NUMINDIV,
      I_idligne  => 5);


    FOR V_SEL_SOCIETE_INTERLOCUTEUR IN C_SEL_SOCIETE_INTERLOCUTEUR(P_NUMINDIV) LOOP

      /*****c_sel_societe*****/


      --permet de savoir si le paramètre passé en appel est une société ou un interlocuteur
      IF V_SEL_SOCIETE_INTERLOCUTEUR.typ_param='SOCIETE' THEN loc_interloc := NULL;
      ELSE loc_interloc:=P_NUMINDIV;
      END IF;
      --parcours des sociétés de l'interlocuteur
      FOR V_SEL_SOCIETE IN C_SEL_SOCIETE(V_SEL_SOCIETE_INTERLOCUTEUR.NUMINDIV) LOOP
        TB_INTERLOCUTEUR := new EXTR_TAB_INTERLOCUTEUR(null);
        CPT_2 := 1;
        /******* c_sel_interlocuteur**************/
        --EA PREV     lorsque le paramètre entrant est un interlocuteur, le flux ne remonte que cet interlocuteur dans le tableau dédié
        FOR V_SEL_INTERLOCUTEUR IN C_SEL_INTERLOCUTEUR(V_SEL_SOCIETE.NUMINDIV, loc_interloc) LOOP

          IF (CPT_2 > 1) THEN
           TB_INTERLOCUTEUR.EXTEND(1);
          END IF;

          --compte les contrats prev qui porte la porte 30 pour profil PREV
          --contrat en vigueur
          --ou resilié depuis moins de 3 mois
          SELECT COUNT(c.numgar) INTO loc_serv_prev
          FROM contrat c, porte_contrat pc
          WHERE c.numcli = V_SEL_SOCIETE.NUMINDIV
          AND c.numgar = pc.numgar
          AND pc.numporte = 30
          AND (pk_histo_contrat.f_sel_etat(c.NUMGAR, sysdate) =1
          OR ( pk_histo_contrat.f_sel_etat(c.NUMGAR, sysdate) =3
          AND pk_histo_contrat.f_sel_debut_etat(c.numgar, 3, sysdate)>= add_months(sysdate,-3)))
          AND EXISTS (
            SELECT numindiv FROM interlocuteur
            WHERE numindiv = c.numcli
            AND interlocuteur =V_SEL_INTERLOCUTEUR.INTERLOCUTEUR
            AND valide='O'
            AND OPE_CRRR=9)
          ;
          --compte les contrats ouverts au BIA profil affil
          SELECT COUNT(numgar) INTO loc_serv_affil
          FROM contrat c
          WHERE c.numcli = V_SEL_SOCIETE.NUMINDIV
          AND c.numgar IN (SELECT numgar FROM TABLE(pk_ws_web_back.F_Get_CONTRATs_BIA(c.numcli,25,c.numgar)))
          AND EXISTS (
            SELECT numindiv FROM interlocuteur
            WHERE numindiv = c.numcli
            AND interlocuteur = V_SEL_INTERLOCUTEUR.INTERLOCUTEUR
            AND valide='O'
            AND OPE_CRRR=8)
          ;

          TB_SERVICES := new EXTR_TAB_INTERLOC_SERV(null);


          --rechercher pour la société les services => tous les interlocuteurs d'une même société ont les mêmes services
          --les services sont portés par les contrats de la société contrat.numcli =sté
          --PREV : elle doit avoir au moins un contrat en vigueur ou résilié de moins de 3 mois avec la porte 30
          --f_sel_etat = 1 ou  3 mais sel_etat_debut


          IF loc_serv_affil >0 THEN
            IF TB_SERVICES(1) IS NOT NULL THEN TB_SERVICES.extend(1); END IF;
            TB_SERVICES(TB_SERVICES.count) := EXTR_INTERLOC_SERV('AFFIL');
          END IF;
          IF loc_serv_prev > 0 THEN
             IF TB_SERVICES(1) IS NOT NULL THEN TB_SERVICES.extend(1); END IF;
            TB_SERVICES(TB_SERVICES.count) := EXTR_INTERLOC_SERV('PREV');
          END IF;

          TB_INTERLOCUTEUR(CPT_2) := EXTR_INTERLOCUTEUR_TR( V_SEL_INTERLOCUTEUR.IDINTERLOCUTEUR,
                                                            V_SEL_INTERLOCUTEUR.INTERLOCUTEUR,
                                                            V_SEL_INTERLOCUTEUR.QUALITE,
                                                            V_SEL_INTERLOCUTEUR.LIB_QUALITE,
                                                            substr(V_SEL_INTERLOCUTEUR.NOM,0,30),
                                                            V_SEL_INTERLOCUTEUR.PRENOM,
                                                            V_SEL_INTERLOCUTEUR.OPE_CRRR,
                                                            V_SEL_INTERLOCUTEUR.LIB_SERVICE,
                                                            V_SEL_INTERLOCUTEUR.VALIDE,
                                                            V_SEL_INTERLOCUTEUR.DEFAUT,
                                                            V_SEL_INTERLOCUTEUR.DEBUT,
                                                            V_SEL_INTERLOCUTEUR.FIN,
                                                            V_SEL_INTERLOCUTEUR.FONCTION,
                                                            V_SEL_INTERLOCUTEUR.LIB_FONCTION,
                                                            V_SEL_INTERLOCUTEUR.mail,
                                                            V_SEL_INTERLOCUTEUR.telephone,
                                                            V_SEL_INTERLOCUTEUR.telecopie
                                                            ,TB_SERVICES
                                                            );
          CPT_2 := CPT_2 + 1;
        END LOOP;

        /******* fin c_sel_interlocuteur**************/

        IF (CPT > 1) THEN
          TB_SOCIETE.EXTEND(1);
        END IF;

        T_ADRESSE := '';
        T_ADRESSE_2 := '';
        T_ADRESSE_3 := '';
        T_CODPOS  := '';
        T_VILLE   := '';
        T_PAYS    := 0;
        T_LIB_PAYS := '';
      --ABO 23/09 correction récupération adresse
        pk_ws_web_back.f_adresse ( PK_PERSONNE.F_IDADRESSE(V_SEL_SOCIETE.NUMINDIV),V_SEL_SOCIETE.NUMINDIV,0,30,T_ADRESSE,
                                   T_ADRESSE_2,T_ADRESSE_3,T_CODPOS,T_VILLE,T_PAYS);


        T_ADRESSE_2:= TRIM(T_ADRESSE_2||' '||T_ADRESSE_3);
        T_LIB_PAYS := F_PAYS(T_PAYS);
        IF length(V_SEL_SOCIETE.NOM)>30 THEN  loc_nomste:= V_SEL_SOCIETE.ABREGE;
        ELSE loc_nomste :=V_SEL_SOCIETE.NOM;
        END IF;


        TB_SOCIETE(CPT) := EXTR_SOCIETE_TR( V_SEL_SOCIETE.QUALITE,
                                            V_SEL_SOCIETE.LIB_QUALITE,
                                            V_SEL_SOCIETE.NUMINDIV,
                                            loc_nomste,
                                            T_ADRESSE,
                                            T_ADRESSE_2,
                                            T_ADRESSE_3,
                                            '',
                                            T_CODPOS,
                                            T_VILLE ,
                                            T_PAYS,
                                            T_LIB_PAYS,
                                             V_SEL_SOCIETE.mail,
                                             V_SEL_SOCIETE.telephone,
                                             V_SEL_SOCIETE.telecopie,
                                             V_SEL_SOCIETE.SIRET,
                                             V_SEL_SOCIETE.APE,
                                             TB_INTERLOCUTEUR
                                             );

          CPT := CPT + 1;
        END LOOP;

          /*****c_sel_societe*****/

    END LOOP;

    RETURN TB_SOCIETE;

 /* EXCEPTION
      /* WHEN OTHERS THEN
          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_COMPANY_LIST_BY_REP',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(sqlerrm,1,132),
          I_idligne  => 2);  */

         -- RETURN TB_SOCIETE;

  END F_COMPANY_LIST_BY_REP;
  /******************************************************************************/

  -- Function donnant la liste des contrat BIA ouvert selon le numéro de société et le numéro de porte (25 Extranet, ou 26 BIA)
  FUNCTION F_GET_CONTRATS_BIA ( P_NUMCLI NUMBER, p_PORTE NUMBER, P_NUMGAR NUMBER )
  RETURN EXTR_TAB_CONTRAT
  IS

   --ARTGEREP-340 retrait du filtre sur les contrats groupes ouverts
   Cursor c_cntrt is
    WITH porte_EA as (select f_porte_ea numporte from dual) -- renvoie le numéro de la porte extranet
     , EXCLU_BIA as (select F_FIND_VAR('EXCLU_BIA') valeur from dual) -- renvoi l'identifiant de la variable EXCLU_BIA une seule fois
     , BIAEXCLU as (select F_FIND_VAR('BIAEXCLU') valeur from dual) -- Renvoi l'identifiant de la variable BIAEXCLU une saule fois
     SELECT contrats.numgar FROM ( -- on recupére tout les numéro de contrats
       SELECT DISTINCT CONTRAT_REF.NUMGAR, CONTRAT_REF.NUMCLI,CONTRAT_REF.datsous
            FROM CONTRAT_REF, PORTE_CONTRAT
            WHERE CONTRAT_REF.NUMCLI = NVL(P_NUMCLI,CONTRAT_REF.NUMCLI)
            AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
            AND CONTRAT_REF.NUMGAR= NVL(P_NUMGAR,CONTRAT_REF.NUMGAR)
            AND
            ( PORTE_CONTRAT.NUMPORTE = P_PORTE   -- soit on est sur la porte extranet             BIA 06/08/2018
            OR                                      -- soit on est sur une autre porte et on applique  les regles suivantes
             ( PORTE_CONTRAT.NUMPORTE  in(select numporte from porte_EA) -- on prend quand même les contrat ouvert sur la porte extranet
               AND CONTRAT_REF.type_contrat = 1 -- contrat Santé
               AND (CONTRAT_REF.typgar <> 2 OR CONTRAT_REF.portefeuille IN (14,13)) -- exclusion des groupes ouverts
                  ) -- contrat groupe
            )
         UNION
            --adhesion collective
            SELECT CONTRAT_REF.NUMGAR, CONTRAT_REF.NUMCLI ,CONTRAT_REF.datsous
            FROM ADHE_COLLECTIVE,CONTRAT_REF, PORTE_CONTRAT
            WHERE ADHE_COLLECTIVE.numgar_ref = CONTRAT_REF.NUMGAR
              AND ADHE_COLLECTIVE.NUMCLI = NVL(P_NUMCLI,ADHE_COLLECTIVE.NUMCLI)
              AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
              AND CONTRAT_REF.NUMGAR= NVL(P_NUMGAR,CONTRAT_REF.NUMGAR)
              AND
              ( PORTE_CONTRAT.NUMPORTE = P_PORTE   -- soit on est sur la porte extranet             BIA 06/08/2018
              OR                                      -- soit on est sur une autre porte et on applique  les regles suivantes
               (
                 PORTE_CONTRAT.NUMPORTE in(select numporte from porte_EA)  -- on prend quand même les contrat ouvert sur la porte extranet
                 AND CONTRAT_REF.type_contrat = 1 -- contrat Santé
                 AND (CONTRAT_REF.typgar <> 2 OR CONTRAT_REF.portefeuille IN (14,13)) -- exclusion des groupes ouverts
                )
              )
         UNION
            --contrat à adhésion individuelle
            SELECT DISTINCT cr.NUMGAR,  cr.NUMCLI, cr.datsous
            FROM adhe_cntrt ac, contrat_ref cr,PORTE_CONTRAT p
            WHERE (ac.numadhe = P_NUMCLI   OR ac.numquerable =  P_NUMCLI  )
              AND NVL(ac.date_fin_adhe, sysdate) > add_months(sysdate,-24)
              AND CR.NUMGAR = NVL(P_NUMGAR,CR.NUMGAR)
              AND cr.numgar = ac.numgar
              AND  p.NUMGAR  = cr.NUMGAR
              AND cr.typequit <> 1
           AND
            ( P.NUMPORTE = P_PORTE  -- soit on est sur la porte extranet             BIA 06/08/2018
            OR                                     -- soit on est sur une autre porte et on applique  les regles suivantes
             (  P.NUMPORTE in(select numporte from porte_EA)  -- on prend quand même les contrat ouvert sur la porte extranet
                  AND cr.type_contrat = 1 -- contrat Santé
                 -- AND cr.typgar <> 2 -- exclusion des groupes ouverts

               )
              )
      )
          CONTRATS -- puis on applique les verification d'exclusion et de vigeur
             WHERE 1=1
             AND  exists (select 1 from EXCLU_BIA where F_VAL_VAR_ALL(contrats.numgar ,EXCLU_BIA.valeur,sysdate) is null)
             AND  exists (select 1 from BIAEXCLU where F_VAL_VAR_ALL(contrats.numgar ,BIAEXCLU.valeur,sysdate) is null)
             AND pk_histo_contrat.f_sel_etat(contrats.numgar, greatest(contrats.datsous,sysdate ) ) = 1
           ;



   o_retour EXTR_TAB_CONTRAT ;
   l_contrat EXTR_CONTRAT_TR;
  BEGIN
    o_retour := new EXTR_TAB_CONTRAT(null);
    FOR REC_GAR IN C_CNTRT LOOP
      l_contrat := new  EXTR_CONTRAT_TR ( /*NUMGAR          */REC_GAR.numgar, --CONTRAT_REF.NUMGAR%TYPE,
                                          /*NUMGAR_REF      */ null, --si adhesion collective renseigne
                                          /*CNTREF_REFCIE   */ null, -- Si adhesion_collective -> référence du contrat juridique (contrat_ref)
                                          /*REFCIE          */ null, --CONTRAT_REF.REFCIE%TYPE si adhesion_collective -> adhesion_collective.refcie
                                          /*ASSUREUR        */ null, --CONTRAT_REF.NUMORG
                                          /*EMETTEUR        */ null, --numero Emetteur de l'assureur
                                          /*NATURE          */ null, --CONTRAT_REF.TYPE_CONTRAT
                                          /*ETAT            */ null, -- PK_HISTO_CONTRAT.F_SEL_ETAT
                                          /*COLLEGE         */ null, --adhe_collective.college or contrat_ref.college
                                          /*DATEFFE         */ null, --adhe_collective.dateffe or contrat_ref.dat_effet
                                          /*DATE_RESIL      */ null, --Date de résiliation (si présente)
                                          /*SOCIETE         */ Null, --
                                          /*LIB_SOCIETE     */ null, -- INDIVIDU.NOM
                                          /*SIRET           */ null,
                                          /*LIB_DEVISE      */ null,
                                          /*COUVERTCFE      */ null,   --couvert CFE O ou N
                                          /*FRACT           */ null,    --contrat_ref
                                          /*QUERABLE_NUM    */ null,      --numero du querable
                                          /*QUERABLE_CIV    */ null,    --civilité querable
                                          /*QUERABLE_NOM    */ null,    --nom querable
                                          /*QUERABLE_PRENOM */ null,    --prenom ou raison sociale
                                          /*QUERABLE_ADRESSE*/ null, --adresse du querable
                                          /*CNTRT_BASE      */ null, --numéro de contrat de base auquel il est lié identique si base
                                          /*TAB_GARANTIE    */ null,
                                          /*TAB_PORTE       */ null, --tableau des portes / réseaux ouverts sur le contrat
                                          /*GEST_COTIS      */ null,
                                          /*GEST_PREST      */ null,
                                          /*MDP*/              null
                                        );

   IF o_retour(1) is not null THEN o_retour.extend; END IF;
     o_retour(o_retour.count) := l_contrat;
 END LOOP;
   return o_retour;
END F_GET_CONTRATS_BIA ;
  /******************************************************************************/

  FUNCTION F_CONTRACT_LIST_BY_COMP(
    P_NUMINDIV EXTR_TAB_NUMINDIV,
    P_NUMGAR   CONTRAT.NUMGAR%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
    ,P_FLAG     NUMBER DEFAULT 0
  )
  RETURN EXTR_TAB_CONTRAT IS

  CURSOR C_SEL_CONTRAT(V_NUMINDIV IN INDIVIDU.NUMINDIV%TYPE, V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE, V_NUMGAR CONTRAT.NUMGAR%TYPE) IS
      WITH contrats_BIA as (select numgar from TABLE(F_Get_CONTRATs_BIA(V_NUMINDIV,V_NUMPORTE,V_NUMGAR)))

      SELECT  NUMGAR,
     NUMGAR_REF,
     LIB_SOCIETE,
     CNTREF_REFCIE, -- contrat juridique = contrat
     REFCIE,
     pk_libelle.f_lib('ORGN',ASSUREUR) assureur,
     F_EMETTEUR(EMETTEUR) EMETTEUR,
     F_LBLE('TYP_CONT',NATURE) NATURE,
     F_LBLE('ET_CONT',PK_HISTO_CONTRAT.F_SEL_ETAT(NUMGAR_REF,greatest(sysdate,PK_HISTO_CONTRAT.F_SEL_date_effet(NUMGAR)))) ETAT
     ,COLLEGE
	 --F_LBLE('COLLEGE',COLLEGE) college,
     ,COLLEGE||'|'||F_LBLE('COLLEGE',COLLEGE) lib_college  --RKO M0006840
     ,PORTEFEUILLE --RKO M0006900
     ,PK_HISTO_CONTRAT.F_SEL_date_effet(NUMGAR) DATEFF,
     DATE_RESIL,
     FRACT,
     NUMQUERABLE,
     NUMCLI,
     GEST_PREST,
     GEST_COTIS
     FROM(
      SELECT CONTRAT_REF.NUMGAR,
      CONTRAT_REF.NUMGAR_REF,
      INDIVIDU.NOM as LIB_SOCIETE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat
      CONTRAT_REF.REFCIE,
      NUMORG as ASSUREUR,
      NUMORG as EMETTEUR,
      TYPE_CONTRAT AS NATURE,
      COLLEGE AS COLLEGE,
      CONTRAT_REF.PORTEFEUILLE AS PORTEFEUILLE,
      CONTRAT_REF.FRACT,
      CONTRAT_REF.NUMQUERABLE,
      CONTRAT_REF.NUMCLI,
      CONTRAT_REF.GEST_PREST,
      CONTRAT_REF.GEST_COTIS,
      DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(CONTRAT_REF.NUMGAR))
      ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(CONTRAT_REF.NUMGAR)) DATE_RESIL
      FROM CONTRAT_REF, INDIVIDU
      WHERE INDIVIDU.NUMINDIV = CONTRAT_REF.NUMCLI
      AND CONTRAT_REF.NUMGAR in (select numgar from contrats_BIA)
    UNION
      --adhesion collective
      SELECT ADHE_COLLECTIVE.NUMGAR,
      ADHE_COLLECTIVE.NUMGAR_REF,
      INDIVIDU.NOM as LIB_SOCIETE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat_ref
      ADHE_COLLECTIVE.REFCIE,
      CONTRAT_REF.NUMORG as ASSUREUR,
      NUMORG as EMETTEUR,
      CONTRAT_REF.TYPE_CONTRAT AS NATURE,
      ADHE_COLLECTIVE.COLLEGE AS COLLEGE,
      CONTRAT_REF.PORTEFEUILLE AS PORTEFEUILLE,
      CONTRAT_REF.FRACT,
      ADHE_COLLECTIVE.NUMQUERABLE,
      ADHE_COLLECTIVE.NUMCLI,
      CONTRAT_REF.GEST_PREST,
      CONTRAT_REF.GEST_COTIS,
       DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(ADHE_COLLECTIVE.NUMGAR))
      ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(ADHE_COLLECTIVE.NUMGAR)) DATE_RESIL
      FROM ADHE_COLLECTIVE,CONTRAT_REF, INDIVIDU, PORTE_CONTRAT
      WHERE ADHE_COLLECTIVE.numgar_ref = CONTRAT_REF.NUMGAR
      AND ADHE_COLLECTIVE.NUMCLI = NVL(V_NUMINDIV,ADHE_COLLECTIVE.NUMCLI)
      AND INDIVIDU.NUMINDIV = ADHE_COLLECTIVE.NUMCLI
      AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
      AND CONTRAT_REF.NUMGAR in (select numgar from contrats_BIA)


   UNION
      --contrat à adhésion individuelle
      SELECT DISTINCT
          cr.NUMGAR,
      cr.NUMGAR_REF,
      i.NOM as LIB_SOCIETE,
      cr.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat
      cr.REFCIE as REFCIE,
      cr.NUMORG as ASSUREUR,
      NUMORG as EMETTEUR,
      cr.TYPE_CONTRAT AS NATURE,
      cr.COLLEGE AS COLLEGE,
      cr.PORTEFEUILLE AS PORTEFEUILLE,
      cr.FRACT,
      ac.numquerable,
      ac.numadhe,
      cr.GEST_PREST,
      cr.GEST_COTIS,
       DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(cr.NUMGAR))
      ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(cr.NUMGAR)) DATE_RESIL
      FROM contrat_ref cr, individu i ,adhe_cntrt ac, PORTE_CONTRAT p
      WHERE cr.numgar = ac.numgar
      AND cr.numgar = ac.numgar
      AND (ac.numadhe = i.numindiv  OR ac.numquerable = i.numindiv )
      AND i.numindiv = V_NUMINDIV
      AND cr.typequit <> 1
      AND p.NUMGAR = cr.NUMGAR
      AND  CR.NUMGAR in (select numgar from contrats_BIA)
      AND  NVL(ac.date_fin_adhe, sysdate) > add_months(sysdate,-24)
      ) liste_contrat
    where NVL(DATE_RESIL, sysdate) > add_months(sysdate,-24)
    ORDER BY 12 desc, 11 desc;



   /* version avant globalisation des règle de remonté
    CURSOR C_SEL_CONTRAT(V_NUMINDIV IN INDIVIDU.NUMINDIV%TYPE, V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE, V_NUMGAR CONTRAT.NUMGAR%TYPE) IS
     --contrat collectif
     SELECT  NUMGAR,
     NUMGAR_REF,
     LIB_SOCIETE,
     CNTREF_REFCIE, -- contrat juridique = contrat
     REFCIE,
     ASSUREUR,
     EMETTEUR,
     NATURE,
     ETAT,
     COLLEGE,
     DATEFF,
     DATE_RESIL,
     FRACT,
     NUMQUERABLE,
     NUMCLI,
     GEST_PREST,
     GEST_COTIS
     FROM(
      SELECT CONTRAT_REF.NUMGAR,
      CONTRAT_REF.NUMGAR_REF,
      INDIVIDU.NOM as LIB_SOCIETE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat
      CONTRAT_REF.REFCIE,
      pk_libelle.f_lib('ORGN',NUMORG) as ASSUREUR,
      F_EMETTEUR(NUMORG) as EMETTEUR,
      F_LBLE('TYP_CONT',TYPE_CONTRAT) AS NATURE,
      F_LBLE('ET_CONT',PK_HISTO_CONTRAT.F_SEL_ETAT(CONTRAT_REF.NUMGAR)) as ETAT,
      F_LBLE('COLLEGE',COLLEGE) AS COLLEGE,
      PK_HISTO_CONTRAT.F_SEL_date_effet(CONTRAT_REF.NUMGAR) as DATEFF,
      DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(CONTRAT_REF.NUMGAR))
      ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(CONTRAT_REF.NUMGAR)) as DATE_RESIL,
      CONTRAT_REF.FRACT,
      CONTRAT_REF.NUMQUERABLE,
      CONTRAT_REF.NUMCLI,
      CONTRAT_REF.GEST_PREST,
      CONTRAT_REF.GEST_COTIS
      FROM CONTRAT_REF, INDIVIDU, PORTE_CONTRAT
      WHERE CONTRAT_REF.NUMCLI = NVL(V_NUMINDIV,CONTRAT_REF.NUMCLI)
      AND INDIVIDU.NUMINDIV = CONTRAT_REF.NUMCLI
      AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
      AND CONTRAT_REF.NUMGAR= NVL(V_NUMGAR,CONTRAT_REF.NUMGAR)
      AND
      ( PORTE_CONTRAT.NUMPORTE = V_NUMPORTE   -- soit on est sur la porte extranet             BIA 06/08/2018
      OR                                      -- soit on est sur une autre porte et on applique  les regles suivantes
       ( PORTE_CONTRAT.NUMPORTE = F_PORTE_EA-- on prend quand même les contrat ouvert sur la porte extranet
         --AND CONTRAT_REF.gest_cotis = 1 -- cotisation gérées par gerep

         AND CONTRAT_REF.type_contrat = 1 -- contrat Santé
         AND pk_histo_contrat.f_sel_etat(CONTRAT_REF.numgar, sysdate ) = 1   -- en vigeur
  -- TODO application des contraintes sur les type de contrat
        AND CONTRAT_REF.typgar <> 2 -- exclusion des groupes ouverts
        --AND  cr.gest_cotis  <> 3 -- exclusion des cotisations non gerées
        AND F_VAL_VAR_ALL(CONTRAT_REF.numgar ,F_FIND_VAR('EXCLU_BIA'),sysdate) is null -- contrat non exclu
        AND F_VAL_VAR_ALL(CONTRAT_REF.numcli ,F_FIND_VAR('BIAEXCLU'),sysdate) is null  -- Société non exclu du BIA;
       ) -- contrat groupe
      )

    UNION
      --adhesion collective
      SELECT ADHE_COLLECTIVE.NUMGAR,
      ADHE_COLLECTIVE.NUMGAR_REF,
      INDIVIDU.NOM as LIB_SOCIETE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat_ref
      ADHE_COLLECTIVE.REFCIE,
      pk_libelle.f_lib('ORGN',CONTRAT_REF.NUMORG) as ASSUREUR,
      F_EMETTEUR(NUMORG) as EMETTEUR,
      F_LBLE('TYP_CONT',CONTRAT_REF.TYPE_CONTRAT) AS NATURE,
      F_LBLE('ET_CONT',PK_HISTO_CONTRAT.F_SEL_ETAT(ADHE_COLLECTIVE.NUMGAR)) as ETAT,
      F_LBLE('COLLEGE',ADHE_COLLECTIVE.COLLEGE) AS COLLEGE,
      PK_HISTO_CONTRAT.F_SEL_date_effet(ADHE_COLLECTIVE.NUMGAR) as DATEFF,
      DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(ADHE_COLLECTIVE.NUMGAR))
      ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(ADHE_COLLECTIVE.NUMGAR)) as DATE_RESIL,
      CONTRAT_REF.FRACT,
      ADHE_COLLECTIVE.NUMQUERABLE,
      ADHE_COLLECTIVE.NUMCLI,
      CONTRAT_REF.GEST_PREST,
      CONTRAT_REF.GEST_COTIS
      FROM ADHE_COLLECTIVE,CONTRAT_REF, INDIVIDU, PORTE_CONTRAT
      WHERE ADHE_COLLECTIVE.numgar_ref = CONTRAT_REF.NUMGAR
      AND ADHE_COLLECTIVE.NUMCLI = NVL(V_NUMINDIV,ADHE_COLLECTIVE.NUMCLI)
      AND INDIVIDU.NUMINDIV = ADHE_COLLECTIVE.NUMCLI
      AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
      AND CONTRAT_REF.NUMGAR= NVL(V_NUMGAR,CONTRAT_REF.NUMGAR)
      AND
      ( PORTE_CONTRAT.NUMPORTE = V_NUMPORTE   -- soit on est sur la porte extranet             BIA 06/08/2018
      OR                                      -- soit on est sur une autre porte et on applique  les regles suivantes
       (
         PORTE_CONTRAT.NUMPORTE = F_PORTE_EA -- on prend quand même les contrat ouvert sur la porte extranet
         AND CONTRAT_REF.type_contrat = 1 -- contrat Santé
         AND pk_histo_contrat.f_sel_etat(CONTRAT_REF.numgar, sysdate ) = 1   -- en vigeur
          -- TODO application des contraintes sur les type de contrat
         AND CONTRAT_REF.typgar <> 2 -- exclusion des groupes ouverts
        --AND  cr.gest_cotis  <> 3 -- exclusion des cotisations non gerées
         AND F_VAL_VAR_ALL(CONTRAT_REF.numgar ,F_FIND_VAR('EXCLU_BIA'),sysdate) is null -- contrat non exclu
         AND F_VAL_VAR_ALL(CONTRAT_REF.numcli ,F_FIND_VAR('BIAEXCLU'),sysdate) is null
       )
      )

   UNION
      --contrat à adhésion individuelle
      SELECT DISTINCT
          cr.NUMGAR,
      cr.NUMGAR_REF,
      i.NOM as LIB_SOCIETE,
      cr.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat
      cr.REFCIE as REFCIE,
      pk_libelle.f_lib('ORGN',cr.NUMORG) as ASSUREUR,
      F_EMETTEUR(NUMORG) as EMETTEUR,
      F_LBLE('TYP_CONT',cr.TYPE_CONTRAT) AS NATURE,
      F_LBLE('ET_CONT',PK_HISTO_CONTRAT.F_SEL_ETAT(cr.NUMGAR)) as ETAT,
      F_LBLE('COLLEGE',cr.COLLEGE) AS COLLEGE,
      PK_HISTO_CONTRAT.F_SEL_date_effet(cr.NUMGAR) as DATEFF,
      DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(cr.NUMGAR))
      ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(cr.NUMGAR)) as DATE_RESIL,
      cr.FRACT,
      ac.numquerable,
      ac.numadhe,
      cr.GEST_PREST,
      cr.GEST_COTIS
      FROM contrat_ref cr, individu i ,adhe_cntrt ac, PORTE_CONTRAT p
      WHERE cr.numgar = ac.numgar
      AND cr.numgar = ac.numgar
      AND (ac.numadhe = i.numindiv  OR ac.numquerable = i.numindiv )
      AND i.numindiv = V_NUMINDIV
      AND V_NUMINDIV IS NOT NULL
      AND cr.typequit <> 1
      AND p.NUMGAR = cr.NUMGAR
      AND CR.NUMGAR= NVL(V_NUMGAR,CR.NUMGAR)
      AND  NVL(ac.date_fin_adhe, sysdate) > add_months(sysdate,-24)

     AND
      ( P.NUMPORTE = V_NUMPORTE  -- soit on est sur la porte extranet             BIA 06/08/2018
      OR
                                         -- soit on est sur une autre porte et on applique  les regles suivantes
       (  P.NUMPORTE = F_PORTE_EA -- on prend quand même les contrat ouvert sur la porte extranet
            AND cr.type_contrat = 1 -- contrat Santé
         AND pk_histo_contrat.f_sel_etat(cr.numgar, sysdate ) = 1   -- en vigeur
          -- TODO application des contraintes sur les type de contrat
         AND cr.typgar <> 2 -- exclusion des groupes ouverts
        --AND  cr.gest_cotis  <> 3 -- exclusion des cotisations non gerées
         AND F_VAL_VAR_ALL(cr.numgar ,F_FIND_VAR('EXCLU_BIA'),sysdate) is null -- contrat non exclu
         AND F_VAL_VAR_ALL(cr.numcli ,F_FIND_VAR('BIAEXCLU'),sysdate) is null
         )
      )
      ) liste_contrat
    WHERE NVL(liste_contrat.date_resil, sysdate) > add_months(sysdate,-24)
    ORDER BY 12 desc, 11 desc;

    */

    CURSOR C_SEL_GARANTIES(V_NUMGAR_REF contrat_ref.NUMGAR_REF%TYPE, V_NUMGAR contrat_ref.NUMGAR%TYPE) IS
      SELECT cntrt.NOMGAR,cntrt.LIBELLE,cntrt.NUMFOR,cntrt.DATAPLI,cntrt.DATPER,cntrt.OBLIGATOIRE,f_lble('GARA',f.TYPGAR) TYPGAR
      FROM V_GAR_CONTRAT cntrt left outer join  formule f ON ( f.numfor = cntrt.numfor)
      WHERE cntrt.NUMGAR = V_NUMGAR
      AND cntrt.VALIDE = 'O'
      AND cntrt.type = 1
      UNION
      SELECT cntrt.NOMGAR,cntrt.LIBELLE,cntrt.NUMFOR,cntrt.DATAPLI,cntrt.DATPER,cntrt.OBLIGATOIRE,f_lble('GARA',g.TYPGAR) TYPGAR
      FROM V_GAR_CONTRAT cntrt left outer join  garanties g  ON (g.numfor = cntrt.numfor)
      WHERE cntrt.NUMGAR = V_NUMGAR
      AND cntrt.VALIDE = 'O'
      AND cntrt.type = 2;

    CURSOR C_PORTE ( V_NUMGAR contrat_ref.NUMGAR%TYPE) IS
      SELECT NUMPORTE, pk_libelle.f_lib('PORTE', NUMPORTE)LIB_PORTE FROM
      (SELECT NVL(l.SENS, p.NUMPORTE) NUMPORTE
      FROM PORTE_CONTRAT p, PORTE_PARAM pp ,LIBELLE l
      WHERE p.NUMGAR = V_NUMGAR
      AND pp.NUMPORTE = p.NUMPORTE
      AND pp.TYPE_CIRCUIT=3
      AND l.MNEMO='PORTE'
      AND l.CODE = p.NUMPORTE);

    TB_GARANTIS EXTR_TAB_GARANTIE;
    TB_PORTE EXTR_TAB_PORTE;
    V_NUMGAR_BASE NUMBER;
    V_DEVISE_CONTRAT   MONNAIE.LIBELLE%TYPE;
    V_SIRET            PERS_MORALE.SIRET%TYPE;
    V_DELEG_PREST      NUMBER(3);
    V_DELEG_COT        NUMBER(3);
    V_DELEG            NUMBER(3);
    V_LIB_DELEG        VARCHAR2(60);
    --V_SEL_ADHE_COLLECTIVE C_SEL_ADHE_COLLECTIVE%ROWTYPE;
   -- V_SEL_ADHE_INDIVIDUELLE C_SEL_ADHE_INDIVIDUELLE%ROWTYPE;
    CPT NUMBER := 0;
    CPT_2 NUMBER := 0;
    TB_CONTRAT EXTR_TAB_CONTRAT;
    TB_ADRESSE EXTR_ADRESSE_TR;
    S_CIV_NUMQUERABLE LIBELLE.LIBELLE%TYPE;
    S_NOM_NUMQUERABLE INDIVIDU.NOM%TYPE;
    S_PRENOM_NUMQUERABLE INDIVIDU.PRENOM%TYPE;

    P_TYPE_GARANTIE VARCHAR2(200) default null;
    S_CFE           VARCHAR2(200) default 'N';
    S_TYPE_GARANTIE LIBELLE.LIBELLE%TYPE;
    loc_pivot DATE;




  BEGIN

    TB_CONTRAT := new EXTR_TAB_CONTRAT(null);
    TB_ADRESSE := EXTR_ADRESSE_TR('','','','','','');


    CPT := 1;
    FOR i IN 1..P_NUMINDIV.COUNT() LOOP
      V_DEVISE_CONTRAT := null;
      FOR V_SEL_CONTRAT IN C_SEL_CONTRAT(P_NUMINDIV(i).NUMINDIV,P_NUMPORTE,P_NUMGAR) LOOP
        P_TYPE_GARANTIE := NULL;
        S_TYPE_GARANTIE := NULL;
        IF P_FLAG = 1  AND ( --P_flag=1 on provient du webservice  fContractListByCompRh
                        V_SEL_CONTRAT.COLLEGE IN (7, 8 , 100) -- RKO M0006874 - exclusion des collèges 7.8 et 100 pour le ws fContractListByCompRh
                        OR V_SEL_CONTRAT.PORTEFEUILLE IN (4,5,6,7) )THEN -- M0006900  exclusion des portefeuilles 4,5,6,7 pour le ws fContractListByCompRh
		    CONTINUE;
        END IF;
		TB_GARANTIS := new EXTR_TAB_GARANTIE(null);
        loc_pivot := greatest(V_SEL_CONTRAT.DATEFF,sysdate);
        CPT_2 := 1;
          FOR V_SEL_GARANTIES IN C_SEL_GARANTIES(V_SEL_CONTRAT.NUMGAR_REF,V_SEL_CONTRAT.NUMGAR) LOOP
            IF (CPT_2 > 1) THEN
               TB_GARANTIS.EXTEND(1);
            END IF;

            --Pour chaque garantie, on regarde si elle est porteuse de formule de prestation et cotisation
            V_DELEG_COT:=0;
            SELECT COUNT(numfor) INTO V_DELEG_COT
            FROM FRML_PRIME_SIMPLE
            WHERE NUMFOR = V_SEL_GARANTIES.NUMFOR
            AND loc_pivot BETWEEN DEBUT AND NVL(FIN,loc_pivot);

            V_DELEG_PREST:=0;
            SELECT COUNT(numfor) INTO V_DELEG_PREST
            FROM CALCUL
            WHERE NUMFOR = V_SEL_GARANTIES.NUMFOR
            AND loc_pivot BETWEEN DATAPLI AND NVL(DATPER,loc_pivot);

            IF V_DELEG_COT + V_DELEG_PREST= 0 THEN
              V_DELEG :=0;
              V_LIB_DELEG := 'Sans délégation';
            ELSIF V_DELEG_COT > 0 AND V_DELEG_PREST =0 THEN
              V_DELEG :=1;
              V_LIB_DELEG := 'Délégation de cotisation';
            ELSIF V_DELEG_COT = 0 AND V_DELEG_PREST >0 THEN
              V_DELEG :=2;
              V_LIB_DELEG := 'Délégation de prestation';
            ELSE
              V_DELEG :=3;
              V_LIB_DELEG := 'Délégation de cotisation et prestation';
            END IF;


            TB_GARANTIS(CPT_2) := EXTR_GARANTIE_TR( V_SEL_GARANTIES.NUMFOR,
                                                    V_SEL_GARANTIES.NOMGAR,
                                                    V_SEL_GARANTIES.LIBELLE,
                                                    V_SEL_GARANTIES.DATAPLI,
                                                    V_SEL_GARANTIES.DATPER,
                                                    V_SEL_GARANTIES.OBLIGATOIRE,
                                                    NULL,
                                                    NULL,NULL,NULL, --Informations complémentaires
                                                    V_SEL_GARANTIES.TYPGAR
                                                    ,NULL
                                                    ,V_DELEG
                                                    ,V_LIB_DELEG);--rang S/O

             P_TYPE_GARANTIE := P_TYPE_GARANTIE || TO_CHAR(F_TYPE_GAR(V_SEL_GARANTIES.NUMFOR));
             IF F_ASSUREUR(V_SEL_GARANTIES.NUMFOR) = 103 THEN
                S_CFE := 'O';
             END IF;


             CPT_2 := CPT_2 + 1;
          END LOOP;

          IF (CPT > 1) THEN TB_CONTRAT.EXTEND(1);
          END IF;
          BEGIN
          V_DEVISE_CONTRAT := PK_DEVISE.LIB_SYMBOLE(PK_DEVISE.DEVISE_CT(V_SEL_CONTRAT.NUMGAR_REF));
          EXCEPTION
            WHEN OTHERS THEN
                 V_DEVISE_CONTRAT := 'DEVISE NON TROUVEE';
          END;

          IF INSTR(P_TYPE_GARANTIE,'1') > 0 AND INSTR(P_TYPE_GARANTIE,'2') = 0 THEN
             --que des 1 donc sante
             S_TYPE_GARANTIE := F_LBLE('TYP_CONT',1);
          ELSIF INSTR(P_TYPE_GARANTIE,'1') = 0 AND INSTR(P_TYPE_GARANTIE,'2') > 0 THEN
             --que des 2 donc prevoyance
             S_TYPE_GARANTIE := F_LBLE('TYP_CONT',2);
          ELSIF INSTR(P_TYPE_GARANTIE,'1') > 0 AND INSTR(P_TYPE_GARANTIE,'2') > 0 THEN
             --des 1 et des 2 donc sante et prevoyance
             S_TYPE_GARANTIE := F_LBLE('TYP_CONT',4);
          ELSE
             S_TYPE_GARANTIE := F_LBLE('TYP_CONT',1);
          END IF;

          TB_ADRESSE := F_ADRESSE_BY_NUMINDIV(V_SEL_CONTRAT.NUMQUERABLE);

          P_INFO_QUERABLE(V_SEL_CONTRAT.NUMQUERABLE,S_CIV_NUMQUERABLE,S_NOM_NUMQUERABLE,S_PRENOM_NUMQUERABLE);


          TB_PORTE := new EXTR_TAB_PORTE(null);
          CPT_2 := 1;
          FOR REC_PORTE IN C_PORTE(V_SEL_CONTRAT.NUMGAR_REF) LOOP

            IF (CPT_2 > 1) THEN
              TB_PORTE.EXTEND(1);
            END IF;

            TB_PORTE(CPT_2) := EXTR_PORTE_TR(REC_PORTE.NUMPORTE  ,
                                            REC_PORTE.LIB_PORTE  );

            CPT_2 :=CPT_2+1;
          END LOOP;

          BEGIN    -- recuperation du potentiel siret.
            SELECT SIRET INTO V_SIRET
            FROM PERS_MORALE
            WHERE numindiv = V_SEL_CONTRAT.NUMCLI;
          EXCEPTION
            WHEN OTHERS THEN V_SIRET := null;
          END;

          -- recupération du contrat de base


          BEGIN
          SELECT d.numenvers
          INTO   V_NUMGAR_BASE
          FROM dependance d
              WHERE d.numde = V_SEL_CONTRAT.NUMGAR
              AND d.role = 2
              AND d.type =2  ;

/*
              EXCEPTION WHEN OTHERS
              THEN
                V_NUMGAR_BASE := null;
          END;
*/
           -- M0006304 PBO
          EXCEPTION
            WHEN no_data_found THEN
             V_NUMGAR_BASE := V_SEL_CONTRAT.NUMGAR;
            WHEN too_many_rows THEN
             V_NUMGAR_BASE := NULL; -- null si plus d'une base
            WHEN OTHERS THEN
             V_NUMGAR_BASE := NULL;
          END;

          TB_CONTRAT(CPT) := EXTR_CONTRAT_TR( V_SEL_CONTRAT.NUMGAR,
                                              V_SEL_CONTRAT.NUMGAR_REF,
                                              V_SEL_CONTRAT.CNTREF_REFCIE,
                                              V_SEL_CONTRAT.REFCIE,
                                              V_SEL_CONTRAT.ASSUREUR,
                                              V_SEL_CONTRAT.EMETTEUR,
                                              --V_SEL_CONTRAT.NATURE,
                                              S_TYPE_GARANTIE,
                                              V_SEL_CONTRAT.ETAT,
                                              V_SEL_CONTRAT.lib_college,
                                              V_SEL_CONTRAT.DATEFF,
                                              V_SEL_CONTRAT.DATE_RESIL,
                                              V_SEL_CONTRAT.numcli,
                                              V_SEL_CONTRAT.LIB_SOCIETE,
                                              V_SIRET,
                                              V_DEVISE_CONTRAT,
                                              S_CFE,
                                              V_SEL_CONTRAT.FRACT,
                                              V_SEL_CONTRAT.NUMQUERABLE,
                                              S_CIV_NUMQUERABLE,
                                              S_NOM_NUMQUERABLE,
                                              S_PRENOM_NUMQUERABLE,
                                              TB_ADRESSE,
                                              -- nvl( V_NUMGAR_BASE,V_SEL_CONTRAT.NUMGAR),
                                              V_NUMGAR_BASE,  -- M0006304 PBO--contrat de base lié
                                              TB_GARANTIS,
                                              TB_PORTE,
                                              V_SEL_CONTRAT.GEST_COTIS,
                                              V_SEL_CONTRAT.GEST_PREST,
                                              F_VAL_VAR_ALL( V_SEL_CONTRAT.NUMGAR ,F_FIND_VAR('MDPCNTRT'),sysdate));
          CPT := CPT + 1;
      END LOOP;


    END LOOP;

    RETURN TB_CONTRAT;

    EXCEPTION
           WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_CONTRACT_LIST_BY_COMP',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 5);

              RETURN TB_CONTRAT;

  END F_CONTRACT_LIST_BY_COMP;

  /****************************************************************************/

  FUNCTION F_CONTRACT_LIST_BY_COMP_PREV(   --RKO EA PREV
    P_NUMINDIV EXTR_TAB_NUMINDIV,
    P_NUMGAR   CONTRAT.NUMGAR%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  )
  RETURN EXTR_TAB_CONTRAT IS

  CURSOR C_SEL_CONTRAT(V_NUMINDIV IN INDIVIDU.NUMINDIV%TYPE, V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE, V_NUMGAR CONTRAT.NUMGAR%TYPE) IS
     SELECT  NUMGAR,
     NUMGAR_REF,
     LIB_SOCIETE,
     CNTREF_REFCIE, -- contrat juridique = contrat
     REFCIE,
     pk_libelle.f_lib('ORGN',ASSUREUR) assureur,
     F_EMETTEUR(EMETTEUR) EMETTEUR,
     F_LBLE('TYP_CONT',NATURE) NATURE,
     F_LBLE('ET_CONT',PK_HISTO_CONTRAT.F_SEL_ETAT(NUMGAR_REF,greatest(sysdate,PK_HISTO_CONTRAT.F_SEL_date_effet(NUMGAR)))) ETAT,
      --F_LBLE('COLLEGE',COLLEGE) college,
     COLLEGE||'|'||F_LBLE('COLLEGE',COLLEGE) college, --RKO M0006840
     PK_HISTO_CONTRAT.F_SEL_date_effet(NUMGAR) DATEFF,
     DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(NUMGAR))
      ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(NUMGAR)) DATE_RESIL,
     FRACT,
     NUMQUERABLE,
     NUMCLI,
     GEST_PREST,
     GEST_COTIS
     FROM(
      SELECT CONTRAT_REF.NUMGAR,
      CONTRAT_REF.NUMGAR_REF,
      INDIVIDU.NOM as LIB_SOCIETE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat
      CONTRAT_REF.REFCIE,
      NUMORG as ASSUREUR,
      NUMORG as EMETTEUR,
      TYPE_CONTRAT AS NATURE,
      COLLEGE AS COLLEGE,
      CONTRAT_REF.FRACT,
      CONTRAT_REF.NUMQUERABLE,
      CONTRAT_REF.NUMCLI,
      CONTRAT_REF.GEST_PREST,
      CONTRAT_REF.GEST_COTIS
      FROM CONTRAT_REF, INDIVIDU, PORTE_CONTRAT
      WHERE INDIVIDU.NUMINDIV = CONTRAT_REF.NUMCLI
      AND CONTRAT_REF.NUMCLI =NVL(V_NUMINDIV,CONTRAT_REF.NUMCLI)
      AND CONTRAT_REF.NUMGAR =NVL(V_NUMGAR,CONTRAT_REF.NUMGAR)--RKO 21/07/2020 Modif mail IPSO
      AND CONTRAT_REF.TYPE_CONTRAT =2 --Contrats prévoy uniquement
      AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
      AND  PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
      AND CONTRAT_REF.GEST_PREST = 1   --uniquement pour les contrats gérés dans le cadre de la délégation de gestion
    UNION
      --adhesion collective
      SELECT ADHE_COLLECTIVE.NUMGAR,
      ADHE_COLLECTIVE.NUMGAR_REF,
      INDIVIDU.NOM as LIB_SOCIETE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat_ref
      ADHE_COLLECTIVE.REFCIE,
      CONTRAT_REF.NUMORG as ASSUREUR,
      NUMORG as EMETTEUR,
      CONTRAT_REF.TYPE_CONTRAT AS NATURE,
      ADHE_COLLECTIVE.COLLEGE AS COLLEGE,
      CONTRAT_REF.FRACT,
      ADHE_COLLECTIVE.NUMQUERABLE,
      ADHE_COLLECTIVE.NUMCLI,
      CONTRAT_REF.GEST_PREST,
      CONTRAT_REF.GEST_COTIS
      FROM ADHE_COLLECTIVE,CONTRAT_REF, INDIVIDU, PORTE_CONTRAT
      WHERE ADHE_COLLECTIVE.numgar_ref = CONTRAT_REF.NUMGAR
      AND CONTRAT_REF.NUMGAR =NVL(V_NUMGAR,CONTRAT_REF.NUMGAR)--RKO 21/07/2020 Modif mail IPSO
      AND ADHE_COLLECTIVE.NUMCLI = NVL(V_NUMINDIV,ADHE_COLLECTIVE.NUMCLI)
      AND INDIVIDU.NUMINDIV = ADHE_COLLECTIVE.NUMCLI
      AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
      AND CONTRAT_REF.TYPE_CONTRAT =2 --Contrats prévoy uniquement
      AND  PORTE_CONTRAT.NUMPORTE = V_NUMPORTE -- porte espace prevoyance
      AND CONTRAT_REF.GEST_PREST = 1   --uniquement pour les contrats gérés dans le cadre de la délégation de gestion

   UNION
      --contrat à adhésion individuelle
      SELECT DISTINCT
          cr.NUMGAR,
      cr.NUMGAR_REF,
      i.NOM as LIB_SOCIETE,
      cr.REFCIE as CNTREF_REFCIE, -- contrat juridique = contrat
      cr.REFCIE as REFCIE,
      cr.NUMORG as ASSUREUR,
      NUMORG as EMETTEUR,
      cr.TYPE_CONTRAT AS NATURE,
      cr.COLLEGE AS COLLEGE,
      cr.FRACT,
      ac.numquerable,
      ac.numadhe,
      cr.GEST_PREST,
      cr.GEST_COTIS
      FROM contrat_ref cr, individu i ,adhe_cntrt ac, PORTE_CONTRAT p
      WHERE cr.numgar = ac.numgar
      AND cr.numgar = ac.numgar
      AND cr.NUMGAR =NVL(V_NUMGAR,cr.NUMGAR)--RKO 21/07/2020 Modif mail IPSO
      AND (ac.numadhe = i.numindiv  OR ac.numquerable = i.numindiv )
      AND i.numindiv = V_NUMINDIV
      AND cr.typequit <> 1
      AND p.NUMGAR = cr.NUMGAR
      AND cr.TYPE_CONTRAT = 2 --Contrats prévoy uniquement
      AND p.numporte = V_NUMPORTE   -- porte espace prevoyance
      AND cr.gest_prest = 1   --uniquement pour les contrats gérés dans le cadre de la délégation de gestion
      AND  NVL(ac.date_fin_adhe, sysdate) > add_months(sysdate,-24)
      ) liste_contrat
    WHERE NVL(DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(NUMGAR))
      ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(NUMGAR)), sysdate) > add_months(sysdate,-24)
    ORDER BY 12 desc, 11 desc;


    /*CURSOR C_SEL_GARANTIES(V_NUMGAR_REF contrat_ref.NUMGAR_REF%TYPE, V_NUMGAR contrat_ref.NUMGAR%TYPE) IS
      SELECT cntrt.NOMGAR,cntrt.LIBELLE,cntrt.NUMFOR,cntrt.DATAPLI,cntrt.DATPER,cntrt.OBLIGATOIRE,f_lble('GARA',f.TYPGAR) TYPGAR
      FROM V_GAR_CONTRAT cntrt left outer join  formule f ON ( f.numfor = cntrt.numfor)
      WHERE cntrt.NUMGAR = V_NUMGAR
      AND cntrt.VALIDE = 'O'
      AND cntrt.type = 1
      UNION
      SELECT cntrt.NOMGAR,cntrt.LIBELLE,cntrt.NUMFOR,cntrt.DATAPLI,cntrt.DATPER,cntrt.OBLIGATOIRE,f_lble('GARA',g.TYPGAR) TYPGAR
      FROM V_GAR_CONTRAT cntrt left outer join  garanties g  ON (g.numfor = cntrt.numfor)
      WHERE cntrt.NUMGAR = V_NUMGAR
      AND cntrt.VALIDE = 'O'
      AND cntrt.type = 2;     */--RKO EA PREVOY

   --porte WS ou liée à des prestations prévoyance
    CURSOR C_PORTE ( V_NUMGAR contrat_ref.NUMGAR%TYPE) IS
      SELECT NUMPORTE, pk_libelle.f_lib('PORTE', NUMPORTE)LIB_PORTE FROM
      (SELECT NVL(l.SENS, p.NUMPORTE) NUMPORTE
      FROM PORTE_CONTRAT p, PORTE_PARAM pp ,LIBELLE l
      WHERE p.NUMGAR = V_NUMGAR
      AND pp.NUMPORTE = p.NUMPORTE
      AND (pp.TYPE_CIRCUIT=3 OR pp.nat_porte=7)
      AND l.MNEMO='PORTE'
      AND l.CODE = p.NUMPORTE);

    --TB_GARANTIS EXTR_TAB_GARANTIE;
    TB_PORTE EXTR_TAB_PORTE;
    V_NUMGAR_BASE NUMBER;
    V_DEVISE_CONTRAT   MONNAIE.LIBELLE%TYPE;
    V_SIRET            PERS_MORALE.SIRET%TYPE;
    V_DELEG_PREST      NUMBER(3);
    V_DELEG_COT        NUMBER(3);
    V_DELEG            NUMBER(3);
    V_LIB_DELEG        VARCHAR2(60);
    --V_SEL_ADHE_COLLECTIVE C_SEL_ADHE_COLLECTIVE%ROWTYPE;
   -- V_SEL_ADHE_INDIVIDUELLE C_SEL_ADHE_INDIVIDUELLE%ROWTYPE;
    CPT NUMBER := 0;
    CPT_2 NUMBER := 0;
    TB_CONTRAT EXTR_TAB_CONTRAT;
    TB_ADRESSE EXTR_ADRESSE_TR;
    S_CIV_NUMQUERABLE LIBELLE.LIBELLE%TYPE;
    S_NOM_NUMQUERABLE INDIVIDU.NOM%TYPE;
    S_PRENOM_NUMQUERABLE INDIVIDU.PRENOM%TYPE;

    P_TYPE_GARANTIE VARCHAR2(200) default null;
    S_CFE           VARCHAR2(200) default 'N';
    S_TYPE_GARANTIE LIBELLE.LIBELLE%TYPE;
    loc_pivot DATE;




  BEGIN

    TB_CONTRAT := new EXTR_TAB_CONTRAT(null);
    TB_ADRESSE := EXTR_ADRESSE_TR('','','','','','');


    CPT := 1;
    FOR i IN 1..P_NUMINDIV.COUNT() LOOP
      V_DEVISE_CONTRAT := null;
      FOR V_SEL_CONTRAT IN C_SEL_CONTRAT(P_NUMINDIV(i).NUMINDIV,P_NUMPORTE,P_NUMGAR) LOOP
        P_TYPE_GARANTIE := NULL;
        S_TYPE_GARANTIE := NULL;
       -- TB_GARANTIS := new EXTR_TAB_GARANTIE(null);
        loc_pivot := greatest(V_SEL_CONTRAT.DATEFF,sysdate);
        CPT_2 := 1;
          /*FOR V_SEL_GARANTIES IN C_SEL_GARANTIES(V_SEL_CONTRAT.NUMGAR_REF,V_SEL_CONTRAT.NUMGAR) LOOP
            IF (CPT_2 > 1) THEN
               TB_GARANTIS.EXTEND(1);
            END IF;

            --Pour chaque garantie, on regarde si elle est porteuse de formule de prestation et cotisation
            V_DELEG_COT:=0;
            SELECT COUNT(numfor) INTO V_DELEG_COT
            FROM FRML_PRIME_SIMPLE
            WHERE NUMFOR = V_SEL_GARANTIES.NUMFOR
            AND loc_pivot BETWEEN DEBUT AND NVL(FIN,loc_pivot);

            V_DELEG_PREST:=0;
            SELECT COUNT(numfor) INTO V_DELEG_PREST
            FROM CALCUL
            WHERE NUMFOR = V_SEL_GARANTIES.NUMFOR
            AND loc_pivot BETWEEN DATAPLI AND NVL(DATPER,loc_pivot);

            IF V_DELEG_COT + V_DELEG_PREST= 0 THEN
              V_DELEG :=0;
              V_LIB_DELEG := 'Sans délégation';
            ELSIF V_DELEG_COT > 0 AND V_DELEG_PREST =0 THEN
              V_DELEG :=1;
              V_LIB_DELEG := 'Délégation de cotisation';
            ELSIF V_DELEG_COT = 0 AND V_DELEG_PREST >0 THEN
              V_DELEG :=2;
              V_LIB_DELEG := 'Délégation de prestation';
            ELSE
              V_DELEG :=3;
              V_LIB_DELEG := 'Délégation de cotisation et prestation';
            END IF;


            TB_GARANTIS(CPT_2) := EXTR_GARANTIE_TR( V_SEL_GARANTIES.NUMFOR,
                                                    V_SEL_GARANTIES.NOMGAR,
                                                    V_SEL_GARANTIES.LIBELLE,
                                                    V_SEL_GARANTIES.DATAPLI,
                                                    V_SEL_GARANTIES.DATPER,
                                                    V_SEL_GARANTIES.OBLIGATOIRE,
                                                    NULL,
                                                    NULL,NULL,NULL, --Informations complémentaires
                                                    V_SEL_GARANTIES.TYPGAR
                                                    ,NULL
                                                    ,V_DELEG
                                                    ,V_LIB_DELEG);--rang S/O

             P_TYPE_GARANTIE := P_TYPE_GARANTIE || TO_CHAR(F_TYPE_GAR(V_SEL_GARANTIES.NUMFOR));
             IF F_ASSUREUR(V_SEL_GARANTIES.NUMFOR) = 103 THEN
                S_CFE := 'O';
             END IF;


             CPT_2 := CPT_2 + 1;
          END LOOP; */

          IF (CPT > 1) THEN TB_CONTRAT.EXTEND(1);
          END IF;
          BEGIN
          V_DEVISE_CONTRAT := PK_DEVISE.LIB_SYMBOLE(PK_DEVISE.DEVISE_CT(V_SEL_CONTRAT.NUMGAR_REF));
          EXCEPTION
            WHEN OTHERS THEN
                 V_DEVISE_CONTRAT := 'DEVISE NON TROUVEE';
          END;

        /*  IF INSTR(P_TYPE_GARANTIE,'1') > 0 AND INSTR(P_TYPE_GARANTIE,'2') = 0 THEN
             --que des 1 donc sante
             S_TYPE_GARANTIE := F_LBLE('TYP_CONT',1);
          ELSIF INSTR(P_TYPE_GARANTIE,'1') = 0 AND INSTR(P_TYPE_GARANTIE,'2') > 0 THEN
             --que des 2 donc prevoyance
             S_TYPE_GARANTIE := F_LBLE('TYP_CONT',2);
          ELSIF INSTR(P_TYPE_GARANTIE,'1') > 0 AND INSTR(P_TYPE_GARANTIE,'2') > 0 THEN
             --des 1 et des 2 donc sante et prevoyance
             S_TYPE_GARANTIE := F_LBLE('TYP_CONT',4);
          ELSE
             S_TYPE_GARANTIE := F_LBLE('TYP_CONT',1);
          END IF;*/

          S_TYPE_GARANTIE := F_LBLE('TYP_CONT',2);

          TB_ADRESSE := F_ADRESSE_BY_NUMINDIV(V_SEL_CONTRAT.NUMQUERABLE);

          P_INFO_QUERABLE(V_SEL_CONTRAT.NUMQUERABLE,S_CIV_NUMQUERABLE,S_NOM_NUMQUERABLE,S_PRENOM_NUMQUERABLE);


          TB_PORTE := new EXTR_TAB_PORTE(null);
          CPT_2 := 1;
          FOR REC_PORTE IN C_PORTE(V_SEL_CONTRAT.NUMGAR_REF) LOOP

            IF (CPT_2 > 1) THEN
              TB_PORTE.EXTEND(1);
            END IF;

            TB_PORTE(CPT_2) := EXTR_PORTE_TR(REC_PORTE.NUMPORTE  ,
                                            REC_PORTE.LIB_PORTE  );

            CPT_2 :=CPT_2+1;
          END LOOP;

          BEGIN    -- recuperation du potentiel siret.
            SELECT SIRET INTO V_SIRET
            FROM PERS_MORALE
            WHERE numindiv = V_SEL_CONTRAT.NUMCLI;
          EXCEPTION
            WHEN OTHERS THEN V_SIRET := null;
          END;

          -- recupération du contrat de base


        /*  BEGIN
          SELECT d.numenvers
          INTO   V_NUMGAR_BASE
          FROM dependance d
              WHERE d.numde = V_SEL_CONTRAT.NUMGAR
              AND d.role = 2
              AND d.type =2  ;


              EXCEPTION WHEN OTHERS
              THEN
                V_NUMGAR_BASE := null;
          END;

           -- M0006304 PBO
          EXCEPTION
            WHEN no_data_found THEN
             V_NUMGAR_BASE := V_SEL_CONTRAT.NUMGAR;
            WHEN too_many_rows THEN
             V_NUMGAR_BASE := NULL; -- null si plus d'une base
            WHEN OTHERS THEN
             V_NUMGAR_BASE := NULL;
          END;*/

          TB_CONTRAT(CPT) := EXTR_CONTRAT_TR( V_SEL_CONTRAT.NUMGAR,
                                              V_SEL_CONTRAT.NUMGAR_REF,
                                              V_SEL_CONTRAT.CNTREF_REFCIE,
                                              V_SEL_CONTRAT.REFCIE,
                                              V_SEL_CONTRAT.ASSUREUR,
                                              V_SEL_CONTRAT.EMETTEUR,
                                              --V_SEL_CONTRAT.NATURE,
                                              S_TYPE_GARANTIE,
                                              V_SEL_CONTRAT.ETAT,
                                              V_SEL_CONTRAT.COLLEGE,
                                              V_SEL_CONTRAT.DATEFF,
                                              V_SEL_CONTRAT.DATE_RESIL,
                                              V_SEL_CONTRAT.numcli,
                                              V_SEL_CONTRAT.LIB_SOCIETE,
                                              V_SIRET,
                                              V_DEVISE_CONTRAT,
                                              S_CFE,
                                              V_SEL_CONTRAT.FRACT,
                                              V_SEL_CONTRAT.NUMQUERABLE,
                                              S_CIV_NUMQUERABLE,
                                              S_NOM_NUMQUERABLE,
                                              S_PRENOM_NUMQUERABLE,
                                              TB_ADRESSE,
                                              -- nvl( V_NUMGAR_BASE,V_SEL_CONTRAT.NUMGAR),
                                              NULL,
                                              NULL,--TB_GARANTIS,
                                              TB_PORTE,
                                              V_SEL_CONTRAT.GEST_COTIS,
                                              V_SEL_CONTRAT.GEST_PREST,
                                              F_VAL_VAR_ALL( V_SEL_CONTRAT.NUMGAR ,F_FIND_VAR('MDPCNTRT'),sysdate));
          CPT := CPT + 1;
      END LOOP;


    END LOOP;

    RETURN TB_CONTRAT;

    EXCEPTION
           WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_CONTRACT_LIST_BY_COMP_PREV',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 5);

              RETURN TB_CONTRAT;

  END F_CONTRACT_LIST_BY_COMP_PREV;

/*******************************************************************************/
  FUNCTION F_CONTRACT_TO_SIGN_UP(
    P_NUMADHE   INDIVIDU.NUMINDIV%type,
    P_NUMGAR    CONTRAT.NUMGAR%TYPE,
    P_NATURE     VARCHAR2, -- 1 option espace assuré, 2 base bia, 3 option bia
    P_DATEEFFET   DATE,
    P_NUMCLI      NUMBER
  ) RETURN EXTR_PROSPECT

  IS
    L_GARANTIE_UNITAIRE         EXTR_GRNT_TO_SIGN_UP; -- Contient les information d'une garantie
    L_TAB_GARANTIE              EXTR_TAB_GRNT_TO_SIGN_UP; -- Contient la liste des garanties souscriptibles
    L_CONTRAT                   EXTR_CONTRACT_TO_SIGN_UP; -- Contient les informations d'un contrat et le tableau de ses garanties
    L_TABLEAU_CONTRAT           EXTR_TAB_CONTRACT_TO_SIGN_UP; -- liste les contrats souscriptibles d'un individu
    L_BENE_PROSPECT             EXTR_BENE_PROSPECT; -- Contient le numéro du béneficiaire et la liste de ses contrats souscriptibles.
    L_TABLEAU_BENE_PROSPECT     EXTR_TAB_BENE_PROSPECT;  -- liste des individus avec leur contrats
    L_PROSPECT_FINAL            EXTR_PROSPECT; -- REPONSE FINALE qui contient le numassu et la liste des bénéficiaire et de leur contrat souscriptibles

    I NUMBER;
    J NUMBER;
    K NUMBER;
    loc_date_effet DATE;
    loc_droit VARCHAR2(5);
    TYPE TAB_offre IS TABLE OF NUMBER(5) index by binary_integer ;
    T_offre TAB_offre;
    nb_offre NUMBER(5);
    loc_numfor formule.numfor%TYPE;

    TYPE T_PrixCot IS RECORD (LibCot varchar2(500),
                              Prix NUMBER(11,2)
                              -- Base frml_prime_simple.base%TYPE,
                              --Taux frml_prime_simple.taux%TYPE
                              );

    TYPE TAB_PrixCot IS TABLE OF T_PrixCot index by binary_integer ;
    Tab_Cot TAB_PrixCot;
    Tab_Cot_vide TAB_PrixCot;
    TB_ADRESSE EXTR_ADRESSE_TR;
    S_CIV_NUMQUERABLE LIBELLE.LIBELLE%TYPE;
    S_NOM_NUMQUERABLE INDIVIDU.NOM%TYPE;
    S_PRENOM_NUMQUERABLE INDIVIDU.PRENOM%TYPE;
    l_nombre_ayant_droit NUMBER ; -- nombre de personnes sur une adhésion donnée
    v_limsouspos  NUMBER ;  -- Limite de souscription postérieur d'un contrat
    v_limsousant  NUMBER ;  -- Limite de souscription antérieur d'un contrat
    v_cntrt_elig  NUMBER ;  -- Contrat eligible?

    l_separateur VARCHAR2(3):='';
    loc_taux NUMBER ;
    --recherche des membres de l'adhésion de base de l'adhérent à date
    CURSOR C_ADHE_BASE (p_date DATE, p_numgar NUMBER) IS
    SELECT distinct m.numindiv, a.idadhesion,m.typadr,a.numgar, a.date_adhe,
      i.QUALITE,
      F_LBLE('QLTE',i.QUALITE) as LIB_QUALITE,
      i.NOM,
      i.PRENOM,
      i.MATORG||TRIM(to_char(i.CLESS,'00')) matorg
    FROM adhe_cntrt a, adhe_cntrt_membre m , individu i
    WHERE a.numadhe = P_NUMADHE
    AND a.idadhesion = m.idadhesion
    AND m.numindiv = i.numindiv
    AND a.numgar = nvl(p_numgar,a.numgar)  -- permet de faire la transantion entre le moment ou ISPO ne valide pas le numgar et le moment ou il le valorisera.
    AND EXISTS (
      SELECT idadhesion FROM adhesion ad, formule f
      WHERE f.numfor = ad.numfor
      --AND nvl(p_date,ad.datapli) BETWEEN ad.datapli and NVL(ad.datper,p_date)     -- enlever la date lorque IPSO valorisera le NUMGAR
      AND f.typgar =1 --de base
      AND ad.typfor = 1--santé
      AND ad.idadhesion = a.idadhesion
      and ad.datper is null    -- CLI M5558 ne pas proposer d'adhesion si le beneficiaire est radié
      AND ((nvl(p_date,ad.datapli) BETWEEN ad.datapli and NVL(ad.datper,p_date) )    -- enlever la date lorque IPSO valorisera le NUMGAR
              OR (ad.numgar = a.numgar /*and p_numgar is not null*/) )
      AND m.numindiv=ad.numindiv)
    ORDER BY  a.idadhesion desc,m.typadr asc,m.numindiv asc;
     --TODO filtre pour en avoir une seule ?

    CURSOR C_GAR_BASE(p_date DATE, p_adhesion adhesion.idadhesion%TYPE, p_bene adhesion.numindiv%TYPE) IS
      SELECT ad.NUMFOR
      FROM  adhesion ad, formule f
      WHERE f.numfor = ad.numfor
      AND ad.idadhesion = p_adhesion
      AND (p_date BETWEEN ad.datapli and NVL(ad.datper,p_date) or p_date is null)
      AND f.typgar =1 --de base
      AND ad.typfor = 1--santé
      AND ad.numindiv = p_bene
      ORDER BY ad.rang,ad.datapli;

    --recherche des contrats eligibles liés au contrat de base
    CURSOR C_CNTRT (p_numgar NUMBER, p_date IN DATE) IS
    SELECT  c.numgar,
            c.numprod,
            c.refcie,
            p.siret ,
            i.NOM as LIB_SOCIETE,
            pk_libelle.f_lib('ORGN',c.NUMORG) as ASSUREUR,
            F_EMETTEUR(NUMORG) as EMETTEUR,
            F_LBLE('TYP_CONT',c.TYPE_CONTRAT) AS NATURE,
            F_LBLE('ET_CONT',PK_HISTO_CONTRAT.F_SEL_ETAT(c.NUMGAR)) as ETAT,
            F_LBLE('COLLEGE',c.COLLEGE) AS COLLEGE,
            PK_HISTO_CONTRAT.F_SEL_date_effet(c.NUMGAR) as DATEFF,
            DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(c.NUMGAR))
            ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(c.NUMGAR)) as DATE_RESIL,
            c.FRACT,
            c.DELAI,
            c.NUMQUERABLE,
            c.NUMCLI,
            c.GEST_PREST,
            c.GEST_COTIS,
            decode(c.MREGL,5,1,2,2,1,5,3) MREGL
    FROM contrat c, pers_morale p, individu i
    WHERE c.numcli = p.numindiv
    AND p.numindiv = i.numindiv
    AND c.numgar in (SELECT numgar FROM TABLE(PK_WS_WEB_BACK.F_GET_CONTRATS_DEPENDANTS(p_numgar,p_date)) )
    and c.PORTEFEUILLE  not in (7) -- (on fait sauter les options du portefeuille obligatoire)  BIA
    ORDER BY numgar;
    --TODO daire une fonction ramenant une liste de contrat eligible pour un contrat de base et une autre ramenant le contrat de base d'un contra opt

    --recherche des garanties SANTE eligibles liées au contrat optionnel
    CURSOR C_GAR(p_numgar NUMBER, p_date IN DATE) IS
    SELECT f.* , decode(f.obli_bene,2,1,3,2,15,1,19,1,NULL) nb_bene
    FROM formule f, gar_cntrt g
    WHERE f.numfor = g.numfor
    AND p_date BETWEEN g.datapli and NVL(g.datper,p_date)
    AND g.datapli <> NVL(g.datper, e2d('01/01/1900'))
    AND g.valide='O'
    AND g.type =1--sante
    AND f.typgar =2 --optionnelle
    AND g.numgar = p_numgar
    ;

    CURSOR C_COT(p_numfor formule.numfor%TYPE, p_date IN DATE ) IS
    SELECT f.base,f.taux,f.debut,f.contenu
    FROM frml_prime_simple f
    WHERE f.numfor =p_numfor
    AND p_date BETWEEN f.debut AND NVL(f.fin,p_date)
    ORDER BY f.debut asc
    ;

    CURSOR C_POSTIT(p_base frml_prime_simple.base%TYPE, p_date IN DATE ) IS
    SELECT LISTAGG(texte, ' ')  WITHIN GROUP (ORDER BY p.numligne) texte
    FROM post_it p
    WHERE p.clef = p_base
    AND p.etendue =11
    GROUP BY CLEF
    --ORDER BY p.numligne
    ;
    --TODO comment gérer les formules à plusieurs lignes !!!!!! la merde


    l_info_gar1  varchar2(50);
  BEGIN

    IF P_NATURE not  in (1,3) THEN -- option ou option BIA
      RETURN F_CONSUlT_SOUSBASE(P_NUMADHE, P_NUMGAR,  P_DATEEFFET,P_NUMCLI);      --  appele une fonction spécifique pour les contrats de base
    END IF;


    --Recherche de bénéficiaire
    IF P_NUMGAR IS NULL THEN
      loc_date_effet := trunc(sysdate ,'YEAR');--TODO déterminer la date d'effet

      --dbms_output.put_line('P_NUMGAR is null loc_date_effet = '||loc_date_effet ||'v_limsousant  = '||v_limsousant||'v_limsouspos  = '||v_limsouspos);

    END IF;
    nb_offre:=0;

    L_TABLEAU_BENE_PROSPECT := new EXTR_TAB_BENE_PROSPECT(null);
    FOR REC_ADHE_BASE IN C_ADHE_BASE(loc_date_effet , P_NUMGAR) LOOP

    Tab_Cot := Tab_Cot_vide;

      -- verification des conditions de delais de souscription
      v_limsouspos := F_VAL_VAR_ALL(REC_ADHE_BASE.numgar ,F_FIND_VAR('LIMSOUSPOS'),nvl(loc_date_effet,sysdate));
      v_limsousant := F_VAL_VAR_ALL(REC_ADHE_BASE.numgar ,F_FIND_VAR('LIMSOUSANT'),nvl(loc_date_effet,sysdate));
      v_cntrt_elig := F_VAL_VAR_ALL(REC_ADHE_BASE.numgar ,F_FIND_VAR('CNTRT_ELIG'),nvl(loc_date_effet,sysdate));


       loc_date_effet := F_GET_DATE_EFFET(i_numgar_base => REC_ADHE_BASE.numgar ,
                                          i_numindiv => P_NUMADHE,
                                          i_idadhesion_base =>REC_ADHE_BASE.idadhesion ,
                                          i_nature_souscript => P_NATURE  ) ;
      IF loc_date_effet IS NULL THEN
        RETURN L_PROSPECT_FINAL;
      END IF;
        --dbms_output.put_line(' loc_date_effet = '||loc_date_effet ||' v_limsousant  = '||v_limsousant||' v_limsouspos  = '||v_limsouspos ||'v_cntrt_elig ='||v_cntrt_elig || ' REC_ADHE_BASE.DATE_ADHE='||REC_ADHE_BASE.DATE_ADHE);
       -- END IF;
      --dbms_output.put_line('Prospect :'||REC_ADHE_BASE.prenom);
      L_TABLEAU_CONTRAT :=new EXTR_TAB_CONTRACT_TO_SIGN_UP(null);
      --on recherche la garantie de base souscrite
      --dbms_output.put_line(' loc_date_effet = '||loc_date_effet ||'REC_ADHE_BASE.idadhesion  = '||REC_ADHE_BASE.idadhesion||'REC_ADHE_BASE.numindiv  = '||REC_ADHE_BASE.numindiv);

       --Pour chaque beneficiaire
      -- on recupére le nombre de personne sur l'adhesion
      SELECT count (distinct ad.NUMINDIV)  into  l_nombre_ayant_droit
        FROM  adhesion ad, formule f, adhe_cntrt  adhe
        WHERE f.numfor = ad.numfor
        AND ad.idadhesion = REC_ADHE_BASE.idadhesion
        AND ad.idadhesion = adhe.idadhesion
        AND loc_date_effet BETWEEN ad.datapli and NVL(ad.datper,loc_date_effet)
        AND f.typgar =1 --de base
        AND ad.typfor = 1 --santé
        ;
      FOR REC_GAR_BASE IN C_GAR_BASE(loc_date_effet,REC_ADHE_BASE.idadhesion,REC_ADHE_BASE.numindiv) LOOP
        loc_numfor :=REC_GAR_BASE.numfor;
      END LOOP;

      --On parcourt les contrats liés au contrat de base
      FOR REC_CNTRT IN C_CNTRT(REC_ADHE_BASE.numgar,loc_date_effet) LOOP
        --dbms_output.put_line('***Contrat :'||REC_CNTRT.numgar ||' pour le contrat :'||REC_ADHE_BASE.numgar || ' pour la date_adhe '||REC_ADHE_BASE.date_adhe || ' et un date d''effet ='||loc_date_effet);
        L_TAB_GARANTIE := new EXTR_TAB_GRNT_TO_SIGN_UP(null);

        IF v_limsouspos IS NOT NULL AND v_limsousant IS NOT NULL AND v_cntrt_elig IS NOT NULL THEN
          --dbms_output.put_line('***Contrat :'||REC_CNTRT.numgar ||' on parcourt les garanties eligibles');

        -- on parcourt les garanties eligibles
        FOR REC_GAR IN C_GAR(REC_CNTRT.numgar,loc_date_effet) LOOP
          loc_droit:= F_DROIT_GAR(REC_ADHE_BASE.typadr,REC_GAR.obli_bene,loc_numfor, REC_GAR.numfor, l_nombre_ayant_droit);

--          dbms_output.put_line('for base'||loc_numfor||' option '||REC_GAR.numfor||' loc_droit = '||loc_droit ||'niombre ayant droit = '||l_nombre_ayant_droit ||' typadr = '||REC_ADHE_BASE.typadr);

          IF loc_droit IS NOT NULL AND IS_ADHESION_EXISTS(null,REC_ADHE_BASE.numindiv,loc_date_effet, 2,P_NUMADHE, REC_GAR.obli_bene)=0 THEN   -- controle de doublon
            --gère l'offre uniquement pour les cas autre que type de gar = 1 ou iso base 7

            IF NOT T_offre.EXISTS(REC_GAR.numfor) THEN
              nb_offre:=nb_offre+1;
              IF REC_GAR.obli_bene  IN (1,7,8,9,10,13,16,17,18) THEN
                T_offre(REC_GAR.numfor):=0;
              ELSE
                T_offre(REC_GAR.numfor):=nb_offre;
              END IF;
            END IF;

            --alimentation du tableau de cotisation
            IF NOT Tab_Cot.EXISTS(REC_GAR.numfor) THEN
              Tab_Cot(REC_GAR.numfor).LibCot := NULL;
              Tab_Cot(REC_GAR.numfor).PRIX :=0 ;

              FOR REC_C_COT IN C_COT(REC_GAR.numfor,loc_date_effet) LOOP
                -- Tab_Cot(REC_GAR.numfor).BASE := REC_C_COT.base;--à revoir
                 --Tab_Cot(REC_GAR.numfor).TAUX := REC_C_COT.taux;
                --ABO suite factorisation du taux au produit - valorisation du taux de cotisation
                IF REC_C_COT.TAUX IS NOT NULL THEN
                  loc_taux:=NVL(F_VAL_VAR_ALL ( P_clef =>REC_CNTRT.numgar,
                                      P_idvar => REC_C_COT.taux, P_deb => loc_date_effet),
                                      F_VAL_VAR_ALL ( P_clef =>REC_CNTRT.numprod,
                                      P_idvar => REC_C_COT.taux, P_deb => loc_date_effet));
                  -- si type contenu =1 il s'agit d'un taux, si c'est 2 c'est un montant forfaitaire
                  IF NVL(REC_C_COT.CONTENU,0) = 1 THEN
                    loc_taux := loc_taux/100;
                  END IF;
                ELSE loc_taux:=1;
                END IF;

                FOR REC_C_POSTIT IN C_POSTIT (REC_C_COT.base,loc_date_effet)LOOP
                  IF REC_C_POSTIT.texte IS NOT NULL THEN

                    IF Tab_Cot(REC_GAR.numfor).LibCot IS NULL THEN  l_separateur := ''; ELSE l_separateur := ' + '; END IF;

                    IF    REC_C_COT.taux IS NOT NULL THEN
                      Tab_Cot(REC_GAR.numfor).LibCot := Tab_Cot(REC_GAR.numfor).LibCot ||l_separateur|| replace (TRIM(REC_C_POSTIT.texte),'#MULT',loc_taux);
                    ELSE
                      Tab_Cot(REC_GAR.numfor).LibCot := Tab_Cot(REC_GAR.numfor).LibCot ||' '|| TRIM(REC_C_POSTIT.texte) ;
                    END IF;
                  END IF;
                END LOOP;

              IF Tab_Cot(REC_GAR.numfor).LibCot IS NOT NULL THEN
                Tab_Cot(REC_GAR.numfor).LibCot :=TRIM(Tab_Cot(REC_GAR.numfor).LibCot);
                --dbms_output.put_line('***BASE :'||REC_C_COT.BASE);
              END IF;
              Tab_Cot(REC_GAR.numfor).PRIX := Tab_Cot(REC_GAR.numfor).PRIX +
                              F_FIND_MT_COT(REC_GAR.numfor,  REC_C_COT.BASE, loc_taux,loc_date_effet,REC_ADHE_BASE.typadr,REC_ADHE_BASE.numindiv,REC_ADHE_BASE.idadhesion );

              l_info_gar1 := '';
              IF Tab_Cot(REC_GAR.numfor).PRIX IS not null then
                 --si année de début de tarification cot = année de sous => on affiche l'année de sous
                 --si année de début de tarification cot(2017) < année de sous (2019)  => on affiche l'année de sous-1(2018)
                 IF trunc(REC_C_COT.debut,'YEAR') = trunc(loc_date_effet, 'YEAR') THEN
                   l_info_gar1:= 'Cotisation en vigueur en '|| to_char(trunc(loc_date_effet, 'YEAR'),'YYYY'); --SOUS
                 ELSIF trunc(sysdate,'YEAR') = trunc(loc_date_effet, 'YEAR') THEN
                   l_info_gar1:= 'Cotisation en vigueur en '|| to_char(trunc(loc_date_effet, 'YEAR'),'YYYY');--SOUS - 1
                 ELSE
                   l_info_gar1:= 'Cotisation en vigueur en '|| to_char(trunc(loc_date_effet, 'YEAR')-1,'YYYY');--SOUS - 1
                 END IF;

                 --IF trunc(REC_CNTRT.DATEFF,'YEAR')= trunc(sysdate,'YEAR') AND  trunc(REC_C_COT.debut,'YEAR') = trunc(sysdate,'YEAR')
                  --  select 'Cotisation en vigueur en '|| to_char(trunc(loc_date_effet, 'YEAR'),'YYYY') into  l_info_gar1 from dual ;  -- a vilder
                    -- si le calcul se fait avec des formules ouvertes sur n+1 on donne quand même les cotisation sur l'année N.
              ENd IF;


              END LOOP;
              --dbms_output.put_line(' Prix = '||Tab_Cot(REC_GAR.numfor).PRIX );
              --Tab_Cot(REC_GAR.numfor).PRIX:=NULL;
              Tab_Cot(REC_GAR.numfor).PRIX := Tab_Cot(REC_GAR.numfor).PRIX / REC_GAR.nbunitcalc;

            END IF;

            IF (L_TAB_GARANTIE(1) is not null) THEN L_TAB_GARANTIE.extend; END IF;
            -- NUMFOR,NOM_GARANTIE,LIBELLE,DATE_DEBUT,DATE_FIN  ,
            -- OBLIGATOIRE ,FLAG_REGIME, PRIX_GAR,LIB_PRIX_GAR,
            -- INFO_GAR1, INFO_GAR2 ,INFO_GAR3 ,
            -- DUREE_ENGAGEMENT,CHOIX_GAR, NB_BENE_MAX, OFFRE

            --dbms_output.put_line(' Creation de la garantie '||REC_GAR.numfor||' avec le prix = '||Tab_Cot(REC_GAR.numfor).PRIX ||' A la date'||greatest(REC_GAR.debut,loc_date_effet));

            L_GARANTIE_UNITAIRE := new EXTR_GRNT_TO_SIGN_UP(REC_GAR.numfor,REC_CNTRT.numgar,REC_GAR.libelle,greatest(REC_GAR.debut,loc_date_effet),REC_GAR.fin,
                                    REC_GAR.OBLIGATOIRE,REC_GAR.flag_regime,Tab_Cot(REC_GAR.numfor).PRIX,Tab_Cot(REC_GAR.numfor).LibCot
                                    ,l_info_gar1,NULL,NULL
                                    ,REC_GAR.ENGAGEMENT,loc_droit,REC_GAR.NB_BENE,T_offre(REC_GAR.numfor));

            L_TAB_GARANTIE(L_TAB_GARANTIE.count) := L_GARANTIE_UNITAIRE;
           END IF;
        -- FIN pour chaque Option du contrat
        END LOOP;
        --querable contrat
        TB_ADRESSE := F_ADRESSE_BY_NUMINDIV(REC_CNTRT.NUMQUERABLE);
        P_INFO_QUERABLE(REC_CNTRT.NUMQUERABLE,S_CIV_NUMQUERABLE,S_NOM_NUMQUERABLE,S_PRENOM_NUMQUERABLE);

        --TODO date limite de souscription=> début val_variable avant ---- après

        if not(L_TAB_GARANTIE is null or L_TAB_GARANTIE(1) is null ) then
          L_CONTRAT := new EXTR_CONTRACT_TO_SIGN_UP(REC_CNTRT.numgar,
                                                    REC_CNTRT.numgar,
                                                    REC_CNTRT.refcie,
                                                    REC_CNTRT.refcie,
                                                    REC_CNTRT.ASSUREUR,
                                                    REC_CNTRT.emetteur,
                                                    REC_CNTRT.nature,
                                                    REC_CNTRT.etat,
                                                    REC_CNTRT.college,
                                                    greatest(REC_CNTRT.DATEFF, loc_date_effet),
                                                    REC_CNTRT.DATE_RESIL,
                                                    null,
                                                    REC_CNTRT.numcli,
                                                    REC_CNTRT.LIB_SOCIETE,
                                                    REC_CNTRT.siret,
                                                    'EUR',
                                                    'N',
                                                    REC_CNTRT.fract,
                                                    REC_CNTRT.MREGL,
                                                    REC_CNTRT.delai,REC_CNTRT.NUMQUERABLE,
                                                    S_CIV_NUMQUERABLE,
                                                    S_NOM_NUMQUERABLE,
                                                    S_PRENOM_NUMQUERABLE,
                                                    TB_ADRESSE,REC_ADHE_BASE.numgar,
                                                    L_TAB_GARANTIE,
                                                    null,
                                                    REC_CNTRT.GEST_COTIS,
                                                    REC_CNTRT.GEST_PREST);

          IF L_TABLEAU_CONTRAT(1) is not null THEN L_TABLEAU_CONTRAT.extend; END IF;
          L_TABLEAU_CONTRAT(L_TABLEAU_CONTRAT.count):= L_CONTRAT;
        end if ;
      -- FIN pour chaque Contrats lié au NUMGAR
      END IF;
      END LOOP;

      --EXTR_BENE_PROSPECT (  NUMINDIV  QUALITE LIB_QUALITE   NOM  PRENOM  MATORG  TYPBENE TAB_CONTRACTS)
      L_BENE_PROSPECT := new EXTR_BENE_PROSPECT( REC_ADHE_BASE.numindiv,
                                                 REC_ADHE_BASE.qualite,
                                                 REC_ADHE_BASE.lib_qualite,
                                                 REC_ADHE_BASE.nom,
                                                 REC_ADHE_BASE.prenom,
                                                 REC_ADHE_BASE.matorg,
                                                 TO_NUMBER(F_GET_TRANSCO ('EA','TYPASSU',to_char(REC_ADHE_BASE.typadr))) ,
                                                 L_TABLEAU_CONTRAT);
      IF L_TABLEAU_CONTRAT(1) IS NOT NULL THEN
      IF L_TABLEAU_BENE_PROSPECT(1) IS NOT NULL  THEN L_TABLEAU_BENE_PROSPECT.extend; END IF;

        L_TABLEAU_BENE_PROSPECT(L_TABLEAU_BENE_PROSPECT.count) := L_BENE_PROSPECT;
      END IF;

    END LOOP;
    --dbms_output.put_line('FINAL Nombre de bene = '||L_TABLEAU_BENE_PROSPECT.count);
    L_PROSPECT_FINAL := new  EXTR_PROSPECT(P_NUMADHE,null, L_TABLEAU_BENE_PROSPECT);

    RETURN L_PROSPECT_FINAL;
  EXCEPTION
    WHEN OTHERS THEN
       --dbms_output.put_line('ERREUR = '||SQLERRM);
       PK_trace.P_INS_journal_adm ( I_nom_traitement => 'F_CONTRACT_TO_SIGN_UP',
                                    I_session  => SID,
                                    I_niv_msg  => 3,
                                    I_msg_adm  => P_numadhe ||'-'||P_numgar||'-'||p_nature ||'-'||substr(sqlerrm,1,132),
                                    I_idligne  => 5
                                    );
      RETURN L_PROSPECT_FINAL;
  END F_CONTRACT_TO_SIGN_UP;


/* FONCTION:GET_CONTRATS_DEPENDANTS                                             */
/*                                                                              */
/*Retourne soit les contrats de base soit les contrat optionnel, en fonction de */
/*  p_numgar = numéro du contrat en question                                    */
/*  p_date = date d'effet                                                       */
/*  p_type  = 1 recherche les bases, 2 recherche les options                    */
/*------------------------------------------------------------------------------*/
FUNCTION F_GET_CONTRATS_DEPENDANTS ( p_numgar NUMBER, p_date DATE, p_type NUMBER default 2 ) RETURN EXTR_TAB_CONTRAT
  IS
  CURSOR C_CNTRT IS
    SELECT c.numgar
    FROM contrat c, pers_morale p, individu i
    WHERE c.numcli = p.numindiv
    AND p.numindiv = i.numindiv
    AND numgar IN (
      SELECT p_numgar numgar FROM DUAL
      WHERE EXISTS (
        SELECT f.numfor FROM formule f ,gar_cntrt g
        WHERE f.numfor = g.numfor
        AND g.numgar = p_numgar
        AND g.type =1--sante
        AND f.typgar =p_type --optionnelle ou de base selon le paramétre p_type
        AND p_date BETWEEN g.datapli and NVL(g.datper,p_date)
      )
      UNION
       SELECT decode(p_type ,2,d.numde,d.numenvers) numgar FROM dependance d
      WHERE  p_numgar = decode(p_type ,2,d.numenvers,d.numde) -- parmétre dynamque
      AND d.role = 2
      AND d.type =2)
    ORDER BY numgar;

   o_retour EXTR_TAB_CONTRAT ;
   l_contrat EXTR_CONTRAT_TR;
  BEGIN
    o_retour := new EXTR_TAB_CONTRAT(null);
    FOR REC_GAR IN C_CNTRT LOOP
      l_contrat := new  EXTR_CONTRAT_TR ( /*NUMGAR          */REC_GAR.numgar, --CONTRAT_REF.NUMGAR%TYPE,
                                          /*NUMGAR_REF      */ null, --si adhesion collective renseigne
                                          /*CNTREF_REFCIE   */ null, -- Si adhesion_collective -> référence du contrat juridique (contrat_ref)
                                          /*REFCIE          */ null, --CONTRAT_REF.REFCIE%TYPE si adhesion_collective -> adhesion_collective.refcie
                                          /*ASSUREUR        */ null, --CONTRAT_REF.NUMORG
                                          /*EMETTEUR        */ null, --numero Emetteur de l'assureur
                                          /*NATURE          */ null, --CONTRAT_REF.TYPE_CONTRAT
                                          /*ETAT            */ null, -- PK_HISTO_CONTRAT.F_SEL_ETAT
                                          /*COLLEGE         */ null, --adhe_collective.college or contrat_ref.college
                                          /*DATEFFE         */ null, --adhe_collective.dateffe or contrat_ref.dat_effet
                                          /*DATE_RESIL      */ null, --Date de résiliation (si présente)
                                          /*SOCIETE         */ Null, --
                                          /*LIB_SOCIETE     */ null, -- INDIVIDU.NOM
                                          /*SIRET           */ null,
                                          /*LIB_DEVISE      */ null,
                                          /*COUVERTCFE      */ null,   --couvert CFE O ou N
                                          /*FRACT           */ null,    --contrat_ref
                                          /*QUERABLE_NUM    */ null,      --numero du querable
                                          /*QUERABLE_CIV    */ null,    --civilité querable
                                          /*QUERABLE_NOM    */ null,    --nom querable
                                          /*QUERABLE_PRENOM */ null,    --prenom ou raison sociale
                                          /*QUERABLE_ADRESSE*/ null, --adresse du querable
                                          /*CNTRT_BASE      */ null, --numéro de contrat de base auquel il est lié identique si base
                                          /*TAB_GARANTIE    */ null,
                                          /*TAB_PORTE       */ null, --tableau des portes / réseaux ouverts sur le contrat
                                          /*GEST_COTIS      */ null,
                                          /*GEST_PREST      */ null,
                                          /*MDP*/              null
                                        );

 IF o_retour(1) is not null THEN o_retour.extend; END IF;
   o_retour(o_retour.count) := l_contrat;
 END LOOP;

 return o_retour;

END F_GET_CONTRATS_DEPENDANTS;

   /* FUNCTION F_DROIT_GAR                        */
   /* Paramétre OBLI BENE :                       */
   /* p_nombre_ayant_droit : nombre d'invididu sur l'adhésion*/
  FUNCTION F_DROIT_GAR(i_typadr adhe_cntrt_membre.typadr%TYPE,i_obli_bene formule.obli_bene%TYPE, p_numfor_base formule.numfor%TYPE, p_numfor_opt formule.numfor%TYPE, p_nombre_ayant_droit NUMBER) RETURN VARCHAR2 IS
    loc_numfor  dependance.numde%TYPE;
  BEGIN
    CASE i_obli_bene
    WHEN 1 THEN --0 beneficiaire
      RETURN 'FAC';
    WHEN 2 THEN --0 beneficiaire
      IF i_typadr = 0  THEN --isole => ass princ
        RETURN 'OBL';
      ELSIF i_typadr <> 0 THEN --isole => bene autre => pas de droit
        RETURN NULL;
      END IF;
    WHEN 3 THEN -- Assuré principal obligatoire avec un seul bénéficiaire facultatif
      IF i_typadr = 0  THEN
        RETURN 'OBL';
      ELSE
        RETURN 'FAC';
      END IF;
    WHEN 4 THEN -- famille multi bene
     IF i_typadr = 0  THEN
      IF p_nombre_ayant_droit > 1  or  p_nombre_ayant_droit is null  THEN
        RETURN 'OBL';
      ELSE
        RETURN NULL;
      END IF;
     ELSIF i_typadr <> 0 THEN
        RETURN 'OBL';
     END IF;
    WHEN 5 THEN  -- Assuré principal obligatoire avec un ou plusieurs bénéficiaires facultatifs enfants , exclusion du conjoint
      IF i_typadr in (1,3,7) THEN
        RETURN NULL;
      ELSIF i_typadr = 0 THEN
         RETURN 'OBL';
      ELSE
        RETURN 'FAC';
      END IF;
    WHEN 6 THEN  -- tout beneficiaire obligatoire
      BEGIN
       SELECT d.numde numfor INTO loc_numfor
        FROM dependance d
        WHERE d.numde = p_numfor_base
        AND d.numenvers = p_numfor_opt
        AND d.role = 4
        AND d.type =25;
        --IF i_typadr = 0 THEN  -- l'adhérent peut ou non ouvrir cette garantie
        --  RETURN 'FAC';
        --ELSE
          RETURN 'OBL';      -- les bénéficiaires doivent suivre
        --END IF;
         EXCEPTION
        WHEN OTHERS THEN
          IF p_numfor_opt IS NULL THEN  -- Pour les base on retourne OBL si on ne trouve rien car le numfor opt est forcement null
            RETURN 'OBL';
          ELSE
            RETURN NULL;
           END IF;
         END;
    WHEN 7 THEN --ISO FAC
      BEGIN
        SELECT d.numde numfor INTO loc_numfor
        FROM dependance d
        WHERE d.numde = p_numfor_base
        AND d.numenvers = p_numfor_opt
        AND d.role = 4
        AND d.type =25;
         --dbms_output.put_line('return fac pour '||p_numfor_opt);
        RETURN 'FAC';
      EXCEPTION
        WHEN OTHERS THEN
        IF p_numfor_opt IS NULL THEN            -- Pour les base on retourne OBL si on ne trouve rien car le numfor opt est forcement null
            RETURN 'OBL';
          ELSE
          RETURN NULL;
        END IF;
      END;

      WHEN 8 THEN -- conjoint uniquement
       IF  i_typadr in (1,3,7)  THEN
            return 'FAC';
      ELSE
            RETURN NULL;
       END IF;
      WHEN 9 THEN -- beneficiaire uniquement
        IF  i_typadr <> 0  THEN
            return 'FAC';
          ELSE
            RETURN NULL;
        END IF;
      WHEN 10 THEN -- enfant uniquemement
        IF  i_typadr = 2  THEN
          return 'FAC';
        ELSE
            RETURN NULL;
        END IF;
      WHEN 11 THEN -- Couple Adulte
        IF  i_typadr in (0,1,3,7)  THEN
          RETURN 'OBL';
        ELSE
          RETURN NULL;
        END IF;
     WHEN 12 THEN --  Adulte uniquement
        IF  i_typadr in (0,1,3,7)  THEN
          RETURN 'FAC';
        ELSE
          RETURN NULL;
        END IF;
     WHEN 13 THEN --  Adulte uniquement
        IF i_typadr = 0  THEN --isole => ass princ
          RETURN 'OBL';
        ELSIF i_typadr <> 0 THEN --isole => bene autre => pas de droit
          RETURN NULL;
        END IF;
     WHEN 14 THEN --0 beneficiaire + type ayd
      IF i_typadr = 0  AND (p_nombre_ayant_droit > 1  or  p_nombre_ayant_droit is null)  THEN
        RETURN NULL;
      ELSIF  i_typadr = 0  AND p_nombre_ayant_droit =1 THEN
        RETURN 'OBL';
      ELSE
        RETURN NULL;
      END IF;
    WHEN 15 THEN -- 1 bénéficiaire uniquement
        IF  i_typadr <> 0  THEN
            return 'FAC';
          ELSE
            RETURN NULL;
        END IF;
    WHEN 16 THEN -- conjoint obli
        IF  i_typadr in (1,3,7)   THEN
            return 'OBL';
          ELSE
            RETURN NULL;
        END IF;
    WHEN 17 THEN -- enfant obli
        IF  i_typadr = 2   THEN
            return 'OBL';
          ELSE
            RETURN NULL;
        END IF;
    WHEN 18 THEN -- adulte obli
       IF  i_typadr in (0,1,3,7)   THEN
            return 'OBL';
          ELSE
            RETURN NULL;
        END IF;
   WHEN 19 THEN -- duo OBL
        IF  i_typadr <> 0  THEN
            return 'OBL';
          ELSE
            RETURN NULL;
        END IF;
    ELSE RETURN NULL;
   END CASE;

    exception
    when others then return null;

  END F_DROIT_GAR;



FUNCTION F_GET_DATE_EFFET(i_numgar_base number, i_numindiv number, i_idadhesion_base number, i_nature_souscript number ) return date

-- Souscription option sur EA suite affiliation en ligne base  -- verifier l'existance d'une demande d'affil non refusée avec une adhésion existante
-- Souscription option sur EA annuelle      -- c'est le cas quand on a pas trouvé de demande d'affilation
-- Souscription option sur espace affiliation en ligne  => si ca ne viens pas d'un bia alors on met le 1 er janvier de l'année en cours
-- Souscription de base => date du jour

IS
loc_date_effet DATE;
loc_datsai DATE;
Loc_adhesion_bia  number;
  BEGIN
  IF i_nature_souscript =3 THEN -- si on est sur de l'optionnel venant du BIA, alors on passe directement la date d'effet de  l'adhesion de base
        BEGIN
        --recherche de la date de souscription à l'adhésion de base - contexte option depuis espace affiliation
          SELECT DATE_ADHE
          INTO  loc_date_effet
          FROM   ADHE_CNTRt
          WHERE idadhesion = nvl(i_idadhesion_base, idadhesion)
          AND numadhe = i_numindiv
          and numgar = i_numgar_base
          AND DATE_FIN_ADHE IS  NULL;
          return  loc_date_effet;
        EXCEPTION WHEN OTHERS THEN
          RETURN NULL;
        END;
  ELSIF i_nature_souscript =1 THEN -- souscription optionnel depuis l'EA, peut suivre une préaff ou être une souscription annuel.
       BEGIN
      --recherche de la date de souscription à l'adhésion de base - contexte option depuis espace assuré
      --limitation de la souscritpion en fonction de la date à laquelle la souscription a été effectuée et sa date d'effet
      SELECT ad.DATE_ADHE, TRUNC(h.datsai)
      INTO  loc_date_effet, loc_datsai
      FROM   ADHE_CNTRT ad, histo_adhesion h
      WHERE ad.idadhesion = nvl(i_idadhesion_base, ad.idadhesion)
      AND h.idadhesion = ad.idadhesion
      AND ad.numadhe = i_numindiv
      AND ad.numgar = i_numgar_base
     -- AND ad.DATE_FIN_ADHE IS  NULL; -- meme si elle est résiliée en anticipé cela ne devrait pas bloquer l'option
      AND h.etat =1;

      --Fenêtre de souscription à l’option depuis EA Mini = date du jour  et Maxi = le max entre la date de création et d’effet adh BASE + délai post
      --Concrètement on laisse un délai à l'assuré pour souscrire à l'option, peu importe le canal de création de la base (manuel, DSN, affil massive, Esp. préaff...)
      IF loc_date_effet IS NULL OR loc_datsai IS NULL THEN
        RETURN NULL; --pas d'adhésion de base en vigueur - impossible de souscription à l'option sur EA
      ELSIF SYSDATE <= GREATEST (loc_datsai ,loc_date_effet) +  to_number(F_VAL_VAR_ALL(i_numgar_base ,F_FIND_VAR('LIMSOUSPOS'),sysdate)) THEN
        RETURN  loc_date_effet;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      RETURN NULL;
      --l'adhésion a été résiliée ou est inconnue, pas de base, pas d'option

    END;

   --sinon la souscription dépend du jour de la demande, et n'est permise que X jours avant et après le 01/01
   -- par exemple pour un délai de 30j, si nous sommes le 15/12/2020 ou le 10/01/2021 la date d'effet est toujours le 01/01/2021
   -- si nous sommes le 02/02/2021 => NULL impossible de souscrire
   select    datas.date_effet  INTO loc_date_effet
         from (
            select trunc(sysdate, 'YEAR' )    date_effet
                from dual
                where sysdate
                  between trunc(sysdate, 'YEAR' )- to_number(F_VAL_VAR_ALL(i_numgar_base ,F_FIND_VAR('LIMSOUSANT'),sysdate))
                  AND  trunc(sysdate, 'YEAR' )+ to_number(F_VAL_VAR_ALL(i_numgar_base ,F_FIND_VAR('LIMSOUSPOS'),sysdate))
                  union
            select add_months(trunc(sysdate, 'YEAR' ),12)   date_effet
                from dual
                where sysdate
                  between add_months(trunc(sysdate, 'YEAR' ),12)- to_number(F_VAL_VAR_ALL(i_numgar_base ,F_FIND_VAR('LIMSOUSANT'),sysdate))
                  AND  add_months(trunc(sysdate, 'YEAR' ),12)+ to_number(F_VAL_VAR_ALL(i_numgar_base ,F_FIND_VAR('LIMSOUSPOS'),sysdate))

                  ) datas ;

    RETURN loc_date_effet;


  END IF;

  RETURN sysdate;

  END F_GET_DATE_EFFET;
  -- VERIFIE qu'une adhésion contenant la garantie (numfor) n'est pas ouverte pour un individu et une date donnée.
  -- i_type : 1 = verifie uniquement les adhésions sur les garanties de base
  --          2 = verifie uniquement les adhésion sur les garanties optionnel
  --          null = Ne fait pas la disctintion entre base et option
  FUNCTION IS_ADHESION_EXISTS(i_NUMFOR adhesion.numfor%type, i_numbene adhesion.numindiv%type, i_date DATE, i_type NUMBER default 1, p_numadhe number default null, p_obli_bene VARCHAR2 default null)
  RETURN NUMBER
  IS
    adhesion_existante NUMBER;
    loc_type_gar NUMBER;
  BEGIN


  -- [3 Assuré princ. obli.+ 1 seul bénéf. facultatif]
  -- [ 4Assuré princ. obli.+ plusieurs bénéf. facul]
  -- [ 5 Ass. princ. obli.+1ou > bénéf. facul. enfants]
  -- [6 Tout bénéficiaire obligatoire]
  IF  p_numadhe is not  null AND p_obli_bene IN (2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19) then -- adhérent doit souscrire, le contrôle se fait donc uniquement sur adhérent.

     SELECT COUNT(*)   -- verifie si ma garantie fait partie d'une adhesion pour ce beneficiarire
      INTO adhesion_existante
      FROM ADHESION a,  formule f , adhe_cntrt ac
      WHERE a.idadhesion = ac.idadhesion
      AND ac.numadhe     = p_numadhe
      AND ac.numadhe    = a.numindiv
      AND f.numfor      = a.numfor
      AND f.typgar      = nvl(i_type, f.typgar)
      AND I_DATE BETWEEN a.DATAPLI AND NVL(a.DATPER, I_DATE)
      AND (NVL(engagement,0) > 0 OR NVL(i_type,0)<>2);
      --M6347 on autorise le cumul option fac + option obligatoire dont l'engagement = 0 impact également subscribe base
    RETURN adhesion_existante;
 -- un béné souscrire sans l'adhérent donc le contrôle de doublon se fait sur le béné
 -- contrôle si numfor valorisé (obli_bene null)
  ELSIF NVL(p_obli_bene,0) IN (0,1,7)  THEN
     SELECT COUNT(*)   -- verifie si ma garantie fait partie d'une adhesion pour ce beneficiarire
      INTO adhesion_existante
      FROM ADHESION a, GAR_CNTRT g, formule f
      WHERE a.NUMINDIV  = i_numbene
      AND g.NUMFOR      = nvl(i_NUMFOR,g.numfor)
      AND f.numfor      = a.numfor
      AND f.typgar      = nvl(i_type, f.typgar)
      AND a.numgar      = g.numgar
      AND I_DATE BETWEEN a.DATAPLI AND NVL(a.DATPER, I_DATE);

    RETURN adhesion_existante;
  ELSE RETURN NULL;
  END IF;

  END IS_ADHESION_EXISTS;
  --ajouter le paramétrage contrat sur le nombre d'unité de la règle de calcul de cotisation (frml_prime_simple)pour diviser par 12 par exemple
  FUNCTION F_FIND_MT_COT (i_numfor formule.numfor%TYPE, i_base frml_prime_simple.base%TYPE, i_taux NUMBER , i_date IN DATE, i_typadr NUMBER, i_ayd individu.numindiv%TYPE ,i_adhesion adhesion.idadhesion%TYPE)
  RETURN NUMBER IS
    l_frml_base frmlvar.frml%TYPE;
    l_frml_cond frmlvar.cond%TYPE;
    loc_pmss NUMBER;
    loc_mt NUMBER(11,2) :=0;
    loc_cond NUMBER;

    Cursor c_formules is
    SELECT f.frml,f.cond --INTO l_frml_base,l_frml_cond
      FROM histo_frmlvar h,frmlvar f
      WHERE h.idvariable = i_base
      AND f.idformule = h.idformule;
  BEGIN
    BEGIN
     --dbms_output.put_line('i_numfor'||i_numfor||' i_taux'||i_taux ||' i_base'||i_base);
     FOR r_formule IN c_formules LOOP
      l_frml_cond := r_formule.cond;
      l_frml_base := r_formule.frml;
      IF l_frml_cond IS NOT NULL THEN
        loc_cond:=0;
        l_frml_cond:=replace(l_frml_cond, 'T_AYDR(NAY,DEC)',i_typadr); --(T_AYDR(NAY,DEC)<>2)
        l_frml_cond:=replace(l_frml_cond, 'R_AYDR(NAY,2,DEC)',pk_funct.f_r_aydr(i_adhesion,i_ayd,2,2,i_date)); --((T_AYDR(NAY,DEC)=2)&(R_AYDR(NAY,2,DEC)<3))
        l_frml_cond:=replace(l_frml_cond, '&','AND');
        --dbms_output.put_line( 'condition ='||l_frml_cond);
        execute immediate 'SELECT count(1) FROM DUAL WHERE '||l_frml_cond INTO loc_cond;
      ELSE
        loc_cond :=1;
        --dbms_output.put_line('Condition is null');
      END IF;

      IF loc_cond =1 THEN
          loc_pmss := ind(1,i_date);
          l_frml_base := replace(l_frml_base, 'IND(1,DEC)',loc_pmss); --((0.0045*IND(1,DEC))*12)
          l_frml_base := replace(l_frml_base,'NAY',i_ayd); --TAB(327,AGE_P(NAY,DEC),DEC);
          l_frml_base := replace(l_frml_base,'DEC','e2d('''|| to_char(i_date,'dd/mm/yyyy')||''')'); --TAB(327,AGE_P(NAY,DEC),DEC);
          l_frml_base := replace(l_frml_base,'TAB','PK_FUNCT.F_TAB1');
          --dbms_output.put_line('SELECT ROUND('|| l_frml_base ||',2) FROM DUAL');
          execute immediate 'SELECT ROUND('|| l_frml_base ||',2) FROM DUAL' INTO loc_mt;
          --dbms_output.put_line('resultat loc_mnt ='||loc_mt);
          --dbms_output.put_line('Execption ='||sqlerrm);
      END iF;
    END LOOP;
    END;
         --dbms_output.put_line('fin de boucle loc_mnt ='||loc_mt);
    --la formule de calcul = multiplicante * multiplicateur (par défaut le taux = 1 si sans multiplicateur)
    RETURN loc_mt*i_taux;

    EXCEPTION
      WHEN OTHERS THEN
       --dbms_output.put_line('Execption ='||sqlerrm);
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_FIND_MT_COT',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => 'base'||i_base||'-'||substr(sqlerrm,1,132),
      I_idligne  => 5);
      RETURN NULL;

  END F_FIND_MT_COT;


  FUNCTION F_SEARCH_AFFILIATES(
   P_NUMINDIV EXTR_TAB_NUMINDIV,
   P_NUMGAR EXTR_TAB_NUMGAR,
   P_NOM INDIVIDU.NOM%TYPE,
   P_PRENOM INDIVIDU.PRENOM%TYPE,
   P_NUMSS  INDIVIDU.MATORG%TYPE,
   P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_AFFILIE
  IS
    CURSOR C_SEL_AFFILIE(
         V_NUMINDIV NUMBER,
         V_NUMGAR NUMBER,
         V_NOM INDIVIDU.NOM%TYPE,
         V_PRENOM INDIVIDU.PRENOM%TYPE,
         V_NUMSS  INDIVIDU.MATORG%TYPE,
         V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
     )   IS
     SELECT INDIVIDU.QUALITE,
       F_LBLE('QLTE',INDIVIDU.QUALITE) as LIB_QUALITE,
       INDIVIDU.NUMINDIV,
       INDIVIDU.NOM,
       INDIVIDU.PRENOM,
       INDIVIDU.MATORG,
       ADHE_CNTRT.NUMGAR,
       ADHE_CNTRT.IDADHESION,
       ADHE_CNTRT.NUMADHE,
       ADHE_CNTRT.DATE_ADHE
       FROM  ADHE_CNTRT_MEMBRE,
             ADHE_CNTRT,
             INDIVIDU,
             CONTRAT,
             PORTE_CONTRAT
       WHERE ADHE_CNTRT_MEMBRE.NUMINDIV = INDIVIDU.NUMINDIV
       AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
       AND ((INDIVIDU.MATORG Like '%' || V_NUMSS || '%' AND  V_NUMSS IS NOT NULL)
        OR INDIVIDU.MATORG = NVL(V_NUMSS,INDIVIDU.MATORG) OR INDIVIDU.MATORG IS NULL)
       AND ((INDIVIDU.NOM like '%' || UPPER( V_NOM) || '%' AND  V_NOM IS NOT NULL)
        OR INDIVIDU.NOM = NVL(V_NOM,INDIVIDU.NOM) OR INDIVIDU.NOM IS NULL)
       AND ((INDIVIDU.PRENOM like '%' || UPPER( V_PRENOM ) || '%' AND  V_PRENOM IS NOT NULL)
        OR INDIVIDU.PRENOM = NVL(V_PRENOM,INDIVIDU.PRENOM) OR INDIVIDU.PRENOM IS NULL )
       AND ADHE_CNTRT.NUMGAR = V_NUMGAR
       AND (ADHE_CNTRT.NUMADHE = V_NUMINDIV OR CONTRAT.NUMCLI = V_NUMINDIV)
       AND ADHE_CNTRT_MEMBRE.TYPADR = 0
       AND CONTRAT.NUMGAR = ADHE_CNTRT.NUMGAR
       AND PORTE_CONTRAT.NUMGAR = CONTRAT.NUMGAR_REF
       AND PORTE_CONTRAT.NUMPORTE =V_NUMPORTE
       AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24)
       AND ROWNUM <= 3500;

    CURSOR C_SEL_ADHESION(
          V_IDADHESION ADHESION.IDADHESION%TYPE,
          V_NUMINDIV VARCHAR2
          )IS
      SELECT ADHESION.NUMFOR,
      ADHESION.DATAPLI,ADHESION.DATPER,
      ADHESION.FLAG_REGIME,RANG
      FROM ADHESION
      WHERE ADHESION.IDADHESION = V_IDADHESION
      AND ADHESION.NUMINDIV = V_NUMINDIV;

    CURSOR C_SEL_GARANTIES(V_NUMFOR ADHESION.NUMFOR%TYPE)  IS
      SELECT GAR_CNTRT.NOMGAR,GAR_CNTRT.LIBELLE,GAR_CNTRT.OBLIGATOIRE,f_lble('GARA',g.TYPGAR) TYPGAR
      FROM   GAR_CNTRT  left outer join garanties g ON (g.numfor = GAR_CNTRT.numfor)
      WHERE  GAR_CNTRT.NUMFOR = V_NUMFOR
      AND GAR_CNTRT.type = 2
      UNION
      SELECT GAR_CNTRT.NOMGAR,GAR_CNTRT.LIBELLE,GAR_CNTRT.OBLIGATOIRE,f_lble('GARA',f.TYPGAR) TYPGAR
      FROM   GAR_CNTRT  left outer join formule f ON (f.numfor = GAR_CNTRT.numfor)
      WHERE  GAR_CNTRT.NUMFOR = V_NUMFOR
      AND GAR_CNTRT.type = 1
      UNION
      SELECT GRP_GAR.NOMGRPGAR,GRP_GAR.LIBELLE,GRP_GAR.OBLIGATOIRE,NULL
      FROM   GRP_GAR
      WHERE  GRP_GAR.NUMGRPGAR = V_NUMFOR;

    V_SEL_GARANTIES C_SEL_GARANTIES%ROWTYPE;
    V_SEL_AFFILIE C_SEL_AFFILIE%ROWTYPE;
    V_SEL_ADHESION C_SEL_ADHESION%ROWTYPE;
    V_DELEG_PREST      NUMBER(3);
    V_DELEG_COT        NUMBER(3);
    V_DELEG            NUMBER(3);
    V_LIB_DELEG        VARCHAR2(60);
    CPT NUMBER := 0;
    CPT_2 NUMBER := 0;
    TB_AFFILIE EXTR_TAB_AFFILIE;
    TB_GARANTIS EXTR_TAB_GARANTIE;
    REP_F_SEARCH_AFFILIATES EXTR_TAB_AFFILIE;
    loc_pivot DATE;

  BEGIN

    TB_AFFILIE := new EXTR_TAB_AFFILIE(null);
    CPT := 1;
    FOR j IN 1..P_NUMINDIV.COUNT() LOOP

      FOR i IN 1..P_NUMGAR.COUNT() LOOP

        FOR V_SEL_AFFILIE IN C_SEL_AFFILIE(P_NUMINDIV(j).NUMINDIV,P_NUMGAR(i).NUMGAR,P_NOM,P_PRENOM,P_NUMSS,P_NUMPORTE) LOOP

          TB_GARANTIS := new EXTR_TAB_GARANTIE(null);
          loc_pivot := greatest(V_SEL_AFFILIE.date_adhe,sysdate);
          CPT_2 := 1;
          FOR V_SEL_ADHESION IN C_SEL_ADHESION(V_SEL_AFFILIE.IDADHESION,V_SEL_AFFILIE.NUMINDIV) LOOP

            FOR V_SEL_GARANTIES IN C_SEL_GARANTIES(V_SEL_ADHESION.NUMFOR) LOOP
              IF (CPT_2 > 1) THEN
                 TB_GARANTIS.EXTEND(1);
              END IF;
              --Pour chaque garantie, on regarde si elle est porteuse de formule de prestation et cotisation
              V_DELEG_COT:=0;
              SELECT COUNT(numfor) INTO V_DELEG_COT
              FROM FRML_PRIME_SIMPLE
              WHERE NUMFOR = V_SEL_ADHESION.NUMFOR
              AND loc_pivot BETWEEN DEBUT AND NVL(FIN,loc_pivot);

              V_DELEG_PREST:=0;
              SELECT COUNT(numfor) INTO V_DELEG_PREST
              FROM CALCUL
              WHERE NUMFOR = V_SEL_ADHESION.NUMFOR
              AND loc_pivot BETWEEN DATAPLI AND NVL(DATPER,loc_pivot);

              IF V_DELEG_COT + V_DELEG_PREST= 0 THEN
                V_DELEG :=0;
                V_LIB_DELEG := 'Sans délégation';
              ELSIF V_DELEG_COT > 0 AND V_DELEG_PREST =0 THEN
                V_DELEG :=1;
                V_LIB_DELEG := 'Délégation de cotisation';
              ELSIF V_DELEG_COT = 0 AND V_DELEG_PREST >0 THEN
                V_DELEG :=2;
                V_LIB_DELEG := 'Délégation de prestation';
              ELSE
                V_DELEG :=3;
                V_LIB_DELEG := 'Délégation de cotisation et prestation';
              END IF;

              TB_GARANTIS(CPT_2) := EXTR_GARANTIE_TR( V_SEL_ADHESION.NUMFOR,
                                                      V_SEL_GARANTIES.NOMGAR,
                                                      V_SEL_GARANTIES.LIBELLE,
                                                      V_SEL_ADHESION.DATAPLI,
                                                      V_SEL_ADHESION.DATPER,
                                                      V_SEL_GARANTIES.OBLIGATOIRE,
                                                      V_SEL_ADHESION.FLAG_REGIME,
                                                      NULL,NULL,NULL,--Informations complémentaires
                                                      V_SEL_GARANTIES.TYPGAR,
                                                      V_SEL_ADHESION.RANG,
                                                      V_DELEG,
                                                      V_LIB_DELEG);
               CPT_2 := CPT_2 + 1;
            END LOOP;
          END LOOP;
          IF (CPT > 1) THEN
               TB_AFFILIE.EXTEND(1);
          END IF;
          TB_AFFILIE(CPT) := EXTR_AFFILIE_TR( V_SEL_AFFILIE.QUALITE,
                                              V_SEL_AFFILIE.LIB_QUALITE,
                                              V_SEL_AFFILIE.NUMINDIV,
                                              V_SEL_AFFILIE.NOM,
                                              V_SEL_AFFILIE.PRENOM,
                                              V_SEL_AFFILIE.MATORG,
                                              V_SEL_AFFILIE.NUMGAR,
                                              V_SEL_AFFILIE.IDADHESION,
                                              V_SEL_AFFILIE.NUMADHE,
                                              TB_GARANTIS);
          CPT := CPT + 1;

        END LOOP;
      END LOOP;
    END LOOP;

    REP_F_SEARCH_AFFILIATES := TB_AFFILIE;
    RETURN REP_F_SEARCH_AFFILIATES;

  EXCEPTION
      WHEN OTHERS THEN

          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_SEARCH_AFFILIATES',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr('err:'||sqlerrm,1,132),
          I_idligne  => 2);

          RETURN REP_F_SEARCH_AFFILIATES;
  END F_SEARCH_AFFILIATES;

  /******************************************************************************/

  /******************************************************************************/
  FUNCTION F_GET_AFF(
    P_NUMASSUP INDIVIDU.NUMINDIV%TYPE,
    P_NUMADHE  INDIVIDU.NUMINDIV%TYPE,
    P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
  ) RETURN EXTR_TAB_AFFILIE_DETAIL
  IS

    CURSOR C_SEL_AFFILIE(
           V_NUMASSUP INDIVIDU.NUMINDIV%TYPE,
           V_NUMADHE INDIVIDU.NUMINDIV%TYPE,
           V_IDADHESION ADHE_CNTRT.IDADHESION%TYPE,
           V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
    ) IS
     SELECT INDIVIDU.QUALITE,
      F_LBLE('QLTE',INDIVIDU.QUALITE) as LIB_QUALITE,
      INDIVIDU.NUMINDIV,
      INDIVIDU.NOM,
      INDIVIDU.PRENOM,
      INDIVIDU.MATORG,
      to_char(INDIVIDU.CLESS,'00') CLESS,
      INDIVIDU.MATORG2,
      to_char(INDIVIDU.CLESS2,'00') CLESS2,
      INDIVIDU.DATNAIS,
      ADHE_CNTRT.NUMGAR,
      ADHE_CNTRT.IDADHESION,
      ADHE_CNTRT.NUMADHE,
      NVL(F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,4,2),F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,4,1)) as MAIL,
      NVL(F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,1,2),F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,1,1)) as TELEPHONE,
      ADHE_CNTRT_MEMBRE.TYPADR,
      F_LBLE('TYAD',ADHE_CNTRT_MEMBRE.TYPADR) as LIB_TYPADR,
      /* MUR hotfix 23/12/2019 - supp greatest(ADHE_CNTRT.date_adhe,sysdate) */
      F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,1) AS ETAT,
      F_LBLE('ET_ADHE',F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,1)) as LIB_ETAT,
      F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,2) AS MOTIF,
      F_LBLE('HISTO_ADHE',F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,1)) as LIB_MOTIF,
      ADHE_CNTRT.REF_EXT,
      CONTRAT.REFCIE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE,
      INDIVIDU.RANG,
      INDIVIDU.REGIME,
      decode (INDIVIDU.REGIME, NULL,NULL,pk_libelle.f_lib('REGIME', to_number(INDIVIDU.REGIME)))LIB_REGIME,
      INDIVIDU.REGIME2,
      decode (INDIVIDU.REGIME2, NULL,NULL,pk_libelle.f_lib('REGIME', to_number(INDIVIDU.REGIME2)))LIB_REGIME2,
      INDIVIDU.CAISSE,
      INDIVIDU.CAISSE2,
      INDIVIDU.GUICHETORG CENTRE,
      INDIVIDU.GUICHETORG2 CENTRE2 ,
      decode(ADHE_CNTRT_MEMBRE.TYPADR,0,ADHE_CNTRT_MEMBRE.NUMINDIV,decode(ADHE_CNTRT_MEMBRE.NUMBENE,NULL,ADHE_CNTRT.NUMADHE,ADHE_CNTRT_MEMBRE.NUMBENE)) porteurRIB,
      CONTRAT.NUMCLI,
      contrat.numprod
    FROM ADHE_CNTRT_MEMBRE,
      ADHE_CNTRT,
--      INNER JOIN HISTO_ADHESION ON HISTO_ADHESION.IDADHESION = ADHE_CNTRT.IDADHESION, -- PBO M0006512
      INDIVIDU,
      CONTRAT,
      CONTRAT_REF,
      PORTE_CONTRAT
    WHERE ADHE_CNTRT_MEMBRE.NUMINDIV = INDIVIDU.NUMINDIV
    AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
    AND ADHE_CNTRT.NUMGAR = CONTRAT.NUMGAR
    AND CONTRAT_REF.NUMGAR_REF = CONTRAT.NUMGAR_REF
    AND (ADHE_CNTRT.NUMADHE = NVL(V_NUMADHE,NUMADHE) --adherent souscipteur ind + assuré principal
    AND ADHE_CNTRT.IDADHESION = NVL(V_IDADHESION,ADHE_CNTRT.IDADHESION) --adherent membre ind
    AND ADHE_CNTRT.IDADHESION IN (
      SELECT ADHE_CNTRT_MEMBRE.IDADHESION FROM ADHE_CNTRT_MEMBRE , adhesion
      WHERE V_NUMADHE  = ADHE_CNTRT_MEMBRE.NUMINDIV
      AND ADHE_CNTRT_MEMBRE.TYPADR = 0
      AND adhesion.numindiv =ADHE_CNTRT_MEMBRE.numindiv
      AND adhesion.IDADHESION =ADHE_CNTRT_MEMBRE.IDADHESION
      AND NVL(adhesion.datper,SYSDATE+3000)<>  adhesion.datapli
      AND NVL(adhesion.datper,SYSDATE) >ADD_MONTHS(SYSDATE,-24))
       -- OR V_NUMASSUP IS NULL)
    AND (V_NUMADHE IS NOT NULL OR V_NUMASSUP IS NOT NULL OR V_IDADHESION IS NOT NULL))
    AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
    AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
    AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24)
    AND ((CONTRAT.GEST_PREST = 1 AND CONTRAT.TYPGAR=1)OR  CONTRAT.TYPGAR<>1)
    AND EXISTS (SELECT idadhesion FROM adhesion where adhesion.idadhesion = ADHE_CNTRT.IDADHESION
    AND NVL(adhesion.datper,SYSDATE+3000)<>  adhesion.datapli
    AND NVL(adhesion.datper,SYSDATE) >ADD_MONTHS(SYSDATE,-24)
    AND adhesion.numindiv = ADHE_CNTRT_MEMBRE.numindiv)
   -- Exclusion des Pré-Affilisations en attente validation RH (58), Pré-aff validée par RH (59) PBO M0006512 + correctif M0006867
    AND (NOT EXISTS (SELECT 1 FROM  HISTO_ADHESION
                              WHERE HISTO_ADHESION.IDADHESION = ADHE_CNTRT.IDADHESION
                              AND   HISTO_ADHESION.ETAT = 0
                              AND   HISTO_ADHESION.IDHISTOADHE = F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,GREATEST(SYSDATE,ADHE_CNTRT.date_adhe),5)  -- M0007011 en instance à date ou ds le futur
                              AND   HISTO_ADHESION.MOTIF IN (58,59)))
    UNION
    SELECT INDIVIDU.QUALITE,
      F_LBLE('QLTE',INDIVIDU.QUALITE) as LIB_QUALITE,
      INDIVIDU.NUMINDIV,
      INDIVIDU.NOM,
      INDIVIDU.PRENOM,
      INDIVIDU.MATORG,
      to_char(INDIVIDU.CLESS,'00') CLESS,
      INDIVIDU.MATORG2,
      to_char(INDIVIDU.CLESS2,'00') CLESS2,
      INDIVIDU.DATNAIS,
      ADHE_CNTRT.NUMGAR,
      ADHE_CNTRT.IDADHESION,
      ADHE_CNTRT.NUMADHE,
      NVL(F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,4,2),F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,4,1)) as MAIL,
      NVL(F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,1,2),F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,1,1)) as TELEPHONE,
      ADHE_CNTRT_MEMBRE.TYPADR,
      F_LBLE('TYAD',ADHE_CNTRT_MEMBRE.TYPADR) as LIB_TYPADR,
      /* MUR hotfix 23/12/2019 - supp greatest(ADHE_CNTRT.date_adhe,sysdate) */
      F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,1) AS ETAT,
      F_LBLE('ET_ADHE',F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,1)) as LIB_ETAT,
      F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,2) AS MOTIF,
      F_LBLE('HISTO_ADHE',F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,2)) as LIB_MOTIF,
      ADHE_CNTRT.REF_EXT,
      CONTRAT.REFCIE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE,
      INDIVIDU.RANG,
      INDIVIDU.REGIME,
      decode (INDIVIDU.REGIME, NULL,NULL,pk_libelle.f_lib('REGIME', to_number(INDIVIDU.REGIME)))LIB_REGIME,
      INDIVIDU.REGIME2,
      decode (INDIVIDU.REGIME2, NULL,NULL,pk_libelle.f_lib('REGIME', to_number(INDIVIDU.REGIME2)))LIB_REGIME2,
      INDIVIDU.CAISSE,
      INDIVIDU.CAISSE2 ,
      INDIVIDU.GUICHETORG CENTRE,
      INDIVIDU.GUICHETORG2 CENTRE2,
      decode(ADHE_CNTRT_MEMBRE.TYPADR,0,ADHE_CNTRT_MEMBRE.NUMINDIV,decode(ADHE_CNTRT_MEMBRE.NUMBENE,NULL,ADHE_CNTRT.NUMADHE,ADHE_CNTRT_MEMBRE.NUMBENE)) porteurRIB,
      CONTRAT.NUMCLI,
      CONTRAT.numprod
    FROM ADHE_CNTRT_MEMBRE,
      ADHE_CNTRT,
      INDIVIDU,
      CONTRAT,
      CONTRAT_REF,
      PORTE_CONTRAT
    WHERE ADHE_CNTRT_MEMBRE.NUMINDIV = INDIVIDU.NUMINDIV
    AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
    AND ADHE_CNTRT.NUMGAR = CONTRAT.NUMGAR
    AND CONTRAT_REF.NUMGAR_REF = CONTRAT.NUMGAR_REF
    AND (CONTRAT.NUMCLI = NVL(V_NUMADHE,CONTRAT.NUMCLI)--société souscripteur coll + assuré principal
    AND ADHE_CNTRT.IDADHESION = NVL(V_IDADHESION,ADHE_CNTRT.IDADHESION) --adherent membre ind
    AND ADHE_CNTRT.IDADHESION IN (
      SELECT ADHE_CNTRT_MEMBRE.IDADHESION FROM ADHE_CNTRT_MEMBRE , adhesion
      WHERE V_NUMADHE  = ADHE_CNTRT_MEMBRE.NUMINDIV
      AND ADHE_CNTRT_MEMBRE.TYPADR = 0
      AND adhesion.numindiv =ADHE_CNTRT_MEMBRE.numindiv
      AND adhesion.IDADHESION =ADHE_CNTRT_MEMBRE.IDADHESION
      AND NVL(adhesion.datper,SYSDATE+3000)<>  adhesion.datapli
      AND NVL(adhesion.datper,SYSDATE) >ADD_MONTHS(SYSDATE,-24))
      -- OR V_NUMASSUP IS NULL)
    AND (V_NUMADHE IS NOT NULL OR V_NUMASSUP IS NOT NULL OR V_IDADHESION IS NOT NULL))
    AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
    AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
    AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24)
    AND ((CONTRAT.GEST_PREST = 1 AND CONTRAT.TYPGAR=1)OR  CONTRAT.TYPGAR<>1)
    AND EXISTS (SELECT idadhesion FROM adhesion where adhesion.idadhesion = ADHE_CNTRT.IDADHESION
    AND NVL(adhesion.datper,SYSDATE+3000)<>  adhesion.datapli
    AND NVL(adhesion.datper,SYSDATE) >ADD_MONTHS(SYSDATE,-24)
    AND adhesion.numindiv = ADHE_CNTRT_MEMBRE.numindiv)
   UNION
      SELECT INDIVIDU.QUALITE,
      F_LBLE('QLTE',INDIVIDU.QUALITE) as LIB_QUALITE,
      INDIVIDU.NUMINDIV,
      INDIVIDU.NOM,
      INDIVIDU.PRENOM,
      INDIVIDU.MATORG,
      to_char(INDIVIDU.CLESS,'00') CLESS,
      INDIVIDU.MATORG2,
      to_char(INDIVIDU.CLESS2,'00') CLESS2,
      INDIVIDU.DATNAIS,
      ADHE_CNTRT.NUMGAR,
      ADHE_CNTRT.IDADHESION,
      ADHE_CNTRT.NUMADHE,
      NVL(F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,4,2),F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,4,1)) as MAIL,
      NVL(F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,1,2),F_COORDONNE_CONTACT(INDIVIDU.NUMINDIV,1,1)) as TELEPHONE,
      ADHE_CNTRT_MEMBRE.TYPADR,
      F_LBLE('TYAD',ADHE_CNTRT_MEMBRE.TYPADR) as LIB_TYPADR,
      /* MUR hotfix 23/12/2019 - supp greatest(ADHE_CNTRT.date_adhe,sysdate) */
      F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,1) AS ETAT,
      F_LBLE('ET_ADHE',F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,1)) as LIB_ETAT,
      F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,2) AS MOTIF,
      F_LBLE('HISTO_ADHE',F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,sysdate,1)) as LIB_MOTIF,
      ADHE_CNTRT.REF_EXT,
      CONTRAT.REFCIE,
      CONTRAT_REF.REFCIE as CNTREF_REFCIE,
      INDIVIDU.RANG,
      INDIVIDU.REGIME,
      decode (INDIVIDU.REGIME, NULL,NULL,pk_libelle.f_lib('REGIME', to_number(INDIVIDU.REGIME)))LIB_REGIME,
      INDIVIDU.REGIME2,
      decode (INDIVIDU.REGIME2, NULL,NULL,pk_libelle.f_lib('REGIME', to_number(INDIVIDU.REGIME2)))LIB_REGIME2,
      INDIVIDU.CAISSE,
      INDIVIDU.CAISSE2  ,
      INDIVIDU.GUICHETORG CENTRE,
      INDIVIDU.GUICHETORG2 CENTRE2,
      decode(ADHE_CNTRT_MEMBRE.TYPADR,0,ADHE_CNTRT_MEMBRE.NUMINDIV,decode(ADHE_CNTRT_MEMBRE.NUMBENE,NULL,ADHE_CNTRT.NUMADHE,ADHE_CNTRT_MEMBRE.NUMBENE)) porteurRIB,
      CONTRAT.NUMCLI,
      contrat.numprod -- ajout du numprod dans le flux
    FROM ADHE_CNTRT_MEMBRE,
      ADHE_CNTRT,
--      INNER JOIN HISTO_ADHESION ON HISTO_ADHESION.IDADHESION = ADHE_CNTRT.IDADHESION, -- PBO M0006512
      INDIVIDU,
      CONTRAT,
      CONTRAT_REF,
      PORTE_CONTRAT
    WHERE ADHE_CNTRT_MEMBRE.NUMINDIV = INDIVIDU.NUMINDIV
    AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
    AND ADHE_CNTRT.NUMGAR = CONTRAT.NUMGAR
    AND CONTRAT_REF.NUMGAR_REF = CONTRAT.NUMGAR_REF
    --AND NUMADHE = NVL(V_NUMADHE,NUMADHE)
    AND ADHE_CNTRT.IDADHESION = NVL(V_IDADHESION,ADHE_CNTRT.IDADHESION) --adherent membre ind
    AND ADHE_CNTRT.IDADHESION IN (
      SELECT ADHE_CNTRT_MEMBRE.IDADHESION FROM ADHE_CNTRT_MEMBRE , adhesion
      WHERE V_NUMADHE  = ADHE_CNTRT_MEMBRE.NUMINDIV
      AND ADHE_CNTRT_MEMBRE.TYPADR = 0
      AND adhesion.numindiv =ADHE_CNTRT_MEMBRE.numindiv
      AND adhesion.IDADHESION =ADHE_CNTRT_MEMBRE.IDADHESION
      AND NVL(adhesion.datper,SYSDATE+3000)<>  adhesion.datapli
      AND NVL(adhesion.datper,SYSDATE) >ADD_MONTHS(SYSDATE,-24))
    --  OR V_NUMADHE IS NULL)
    AND (V_NUMADHE IS NOT NULL OR V_NUMASSUP IS NOT NULL OR V_IDADHESION IS NOT NULL)
    AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
    AND PORTE_CONTRAT.NUMGAR = CONTRAT_REF.NUMGAR
    AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24)
    AND ((CONTRAT.GEST_PREST = 1 AND CONTRAT.TYPGAR=1)OR  CONTRAT.TYPGAR<>1)
    AND EXISTS (SELECT idadhesion FROM adhesion where adhesion.idadhesion = ADHE_CNTRT.IDADHESION
    AND NVL(adhesion.datper,SYSDATE+3000)<>  adhesion.datapli
    AND NVL(adhesion.datper,SYSDATE) >ADD_MONTHS(SYSDATE,-24)
    AND adhesion.numindiv = ADHE_CNTRT_MEMBRE.numindiv)
   -- Exclusion des Pré-Affilisations en attente validation RH (58), Pré-aff validée par RH (59) PBO M0006512 + correctif M0006867
    AND (NOT EXISTS (SELECT 1 FROM  HISTO_ADHESION
                              WHERE HISTO_ADHESION.IDADHESION = ADHE_CNTRT.IDADHESION
                              AND   HISTO_ADHESION.ETAT = 0
                              AND   HISTO_ADHESION.IDHISTOADHE = F_ETAT_ADHE_WS(ADHE_CNTRT.IDADHESION,GREATEST(SYSDATE,ADHE_CNTRT.date_adhe),5)  -- M0007011 en instance à date ou ds le futur
                              AND   HISTO_ADHESION.MOTIF IN (58,59)))
    ORDER BY ETAT,10,14;



    CURSOR C_SEL_ADHESION(
      V_IDADHESION ADHESION.IDADHESION%TYPE,
      V_NUMINDIV ADHESION.NUMINDIV%TYPE
    ) IS
      SELECT
      ADHESION.NUMFOR,
      ADHESION.DATAPLI,
      ADHESION.DATPER,
      ADHESION.FLAG_REGIME,
      ADHESION.RANG
      FROM ADHESION--,HISTO_ADHESION
      WHERE ADHESION.IDADHESION = V_IDADHESION
      --AND HISTO_ADHESION.IDADHESION = ADHESION.IDADHESION
      AND ADHESION.NUMINDIV = V_NUMINDIV
      --AND SYSDATE <= ADD_MONTHS(HISTO_ADHESION.DATSAI , 24)
      AND ADHESION.ETAT = 1; --Uniquement les garanties "couvert" (MNEMO ETIN) M4407

    CURSOR C_SEL_ADHERENT( V_NUMINDIV ADHESION.NUMINDIV%TYPE)   IS
     SELECT INDIVIDU.QUALITE,
       F_LBLE('QLTE',INDIVIDU.QUALITE) as LIB_QUALITE,
           INDIVIDU.NUMINDIV,
           INDIVIDU.NOM,
           INDIVIDU.PRENOM
     FROM INDIVIDU
     WHERE INDIVIDU.NUMINDIV = V_NUMINDIV;

    --uniquement les prestations règlées
     CURSOR C_SEL_GARANTIES(V_NUMFOR ADHESION.NUMFOR%TYPE) IS
       SELECT GAR_CNTRT.NOMGAR,GAR_CNTRT.LIBELLE,F_NAT_RISQ(GAR_CNTRT.NUMGAR_REF,GAR_CNTRT.NUMFOR) NAT_RISQ,GAR_CNTRT.OBLIGATOIRE,f_lble('GARA',g.TYPGAR) TYPGAR
       FROM   GAR_CNTRT left outer join garanties g ON (g.numfor = GAR_CNTRT.numfor)
       WHERE  GAR_CNTRT.NUMFOR = V_NUMFOR
       AND GAR_CNTRT.type = 2
       AND GAR_CNTRT.valide = 'O' -- M0007012
       UNION
       SELECT GAR_CNTRT.NOMGAR,GAR_CNTRT.LIBELLE,F_NAT_RISQ(GAR_CNTRT.NUMGAR_REF,GAR_CNTRT.NUMFOR) NAT_RISQ,GAR_CNTRT.OBLIGATOIRE,f_lble('GARA',f.TYPGAR) TYPGAR
       FROM   GAR_CNTRT left outer join formule f ON (f.numfor = GAR_CNTRT.numfor)
       WHERE  GAR_CNTRT.NUMFOR = V_NUMFOR
       AND GAR_CNTRT.type = 1
       AND GAR_CNTRT.valide = 'O' -- M0007012
       UNION
       SELECT GRP_GAR.NOMGRPGAR,GRP_GAR.LIBELLE,F_NAT_RISQ(GRP_GAR.CLEF,GRP_GAR.NUMGRPGAR) NAT_RISQ,OBLIGATOIRE,NULL
       FROM   GRP_GAR
       WHERE  GRP_GAR.NUMGRPGAR = V_NUMFOR;


     V_SEL_GARANTIES C_SEL_GARANTIES%ROWTYPE;
     V_SEL_AFFILIE C_SEL_AFFILIE%ROWTYPE;
     V_DELEG_PREST      NUMBER(3);
     V_DELEG_COT        NUMBER(3);
     V_DELEG            NUMBER(3);
     V_LIB_DELEG        VARCHAR2(60);
     V_SEL_ADHESION C_SEL_ADHESION%ROWTYPE;
     V_SEL_ADHERENT C_SEL_ADHERENT%ROWTYPE;
     CPT       NUMBER := 0;
     CPT_2     NUMBER := 0;
     CPT_3     NUMBER := 0;
     TB_AFFILIE EXTR_TAB_AFFILIE_DETAIL;
     TB_GARANTIS EXTR_TAB_GARANTIE;
     TB_ADHERENT EXTR_TAB_PERSONNE;
     REP_F_GET_AFF EXTR_TAB_AFFILIE_DETAIL;
     T_ADRESSE   VARCHAR2(200);
     T_ADRESSE_2 VARCHAR2(200);
     T_ADRESSE_3 VARCHAR2(200);
     T_CODPOS    VARCHAR2(40);
     T_VILLE     VARCHAR2(30);
     T_PAYS      NUMBER(3);
     T_LIB_PAYS  VARCHAR2(45);
     T_SITU_FAM  NUMBER(3);
     T_LIB_SITU_FAM VARCHAR2(45);
     S_PAYS VARCHAR2(150);
     S_IDPAYS PAYS.CODPAYS%TYPE;
     loc_pivot DATE;

  BEGIN

    TB_AFFILIE := new EXTR_TAB_AFFILIE_DETAIL(null);
    CPT := 1;


    --Recherche du pays d'expatriation concaténation français / anglais
      BEGIN
        SELECT '[fr]'||p.nom ||'[/fr]'||'[en]'||p.nominter ||'[/en]',p.codpays
      INTO S_PAYS,S_IDPAYS
        FROM def_variable d,  pays p
        WHERE d.nom_variable = 'PAYS_EXPAT'
      AND p.codpays = F_VAL_VAR_ALL(P_IDADHESION,d.idvariable, SYSDATE);
        --AND l.mnemo = 'PAYS_EXPAT';

      EXCEPTION
        WHEN OTHERS THEN
         S_PAYS := null;
         S_IDPAYS := null;

      END;


    FOR V_SEL_AFFILIE IN C_SEL_AFFILIE(P_NUMASSUP,P_NUMADHE ,P_IDADHESION,P_NUMPORTE)LOOP

      T_ADRESSE := '';
      T_ADRESSE_2 := '';
      T_ADRESSE_3 := '';
      T_CODPOS  := '';
      T_VILLE   := '';
      T_PAYS    := null;
      T_LIB_PAYS := '';
      T_SITU_FAM := null;
      T_LIB_SITU_FAM := '';

      IF V_SEL_AFFILIE.TYPADR = 0 THEN

        --ABO 23/09 correction récupération adresse
        pk_ws_web_back.f_adresse ( PK_PERSONNE.F_IDADRESSE(V_SEL_AFFILIE.NUMINDIV),V_SEL_AFFILIE.NUMINDIV,0,30,T_ADRESSE,
                                   T_ADRESSE_2,T_ADRESSE_3,T_CODPOS,T_VILLE,T_PAYS);
        --T_ADRESSE_2:= TRIM(T_ADRESSE_2||' '||T_ADRESSE_3);
        T_LIB_PAYS := F_PAYS(T_PAYS);

      --recuperation de la situation familliale
        T_SITU_FAM := PK_PERSONNE.F_SITU_PERS(V_SEL_AFFILIE.NUMINDIV,2);
        IF( NVL(T_SITU_FAM,-2) = -2)THEN
          T_LIB_SITU_FAM := null;
        ELSE
          T_LIB_SITU_FAM := ARTHUS.F_LBLE('SITU_FAM',T_SITU_FAM);
        END IF;

      END IF;


      TB_GARANTIS := new EXTR_TAB_GARANTIE(null);
      CPT_2 := 1;
      FOR V_SEL_ADHESION IN C_SEL_ADHESION(V_SEL_AFFILIE.IDADHESION,V_SEL_AFFILIE.NUMINDIV) LOOP

        FOR V_SEL_GARANTIES IN C_SEL_GARANTIES(V_SEL_ADHESION.NUMFOR)LOOP
          IF (CPT_2 > 1) THEN
             TB_GARANTIS.EXTEND(1);
          END IF;
          loc_pivot := greatest(V_SEL_ADHESION.DATAPLI,sysdate);
          --Pour chaque garantie, on regarde si elle est porteuse de formule de prestation et cotisation
          V_DELEG_COT:=0;
          SELECT COUNT(numfor) INTO V_DELEG_COT
          FROM FRML_PRIME_SIMPLE
          WHERE NUMFOR = V_SEL_ADHESION.NUMFOR
          AND loc_pivot BETWEEN DEBUT AND NVL(FIN,loc_pivot);

          V_DELEG_PREST:=0;
          SELECT COUNT(numfor) INTO V_DELEG_PREST
          FROM CALCUL
          WHERE NUMFOR = V_SEL_ADHESION.NUMFOR
          AND loc_pivot BETWEEN DATAPLI AND NVL(DATPER,loc_pivot);

          IF V_DELEG_COT + V_DELEG_PREST= 0 THEN
            V_DELEG :=0;
            V_LIB_DELEG := 'Sans délégation';
          ELSIF V_DELEG_COT > 0 AND V_DELEG_PREST =0 THEN
            V_DELEG :=1;
            V_LIB_DELEG := 'Délégation de cotisation';
          ELSIF V_DELEG_COT = 0 AND V_DELEG_PREST >0 THEN
            V_DELEG :=2;
            V_LIB_DELEG := 'Délégation de prestation';
          ELSE
            V_DELEG :=3;
            V_LIB_DELEG := 'Délégation de cotisation et prestation';
          END IF;

          TB_GARANTIS(CPT_2) := EXTR_GARANTIE_TR( V_SEL_ADHESION.NUMFOR,
                                                  V_SEL_GARANTIES.NOMGAR,
                                                  V_SEL_GARANTIES.LIBELLE,
                                                  V_SEL_ADHESION.DATAPLI,
                                                  V_SEL_ADHESION.DATPER,
                                                  V_SEL_GARANTIES.OBLIGATOIRE,
                                                  V_SEL_ADHESION.FLAG_REGIME,
                                                  V_SEL_GARANTIES.NAT_RISQ,
                                                  NULL,NULL ,
                                                  V_SEL_GARANTIES.TYPGAR,
                                                  V_SEL_ADHESION.RANG,
                                                  V_DELEG,
                                                  V_LIB_DELEG
                                                  );
          CPT_2 := CPT_2 + 1;
        END LOOP;

      END LOOP;

      IF (CPT > 1) THEN
           TB_AFFILIE.EXTEND(1);
      END IF;
      TB_AFFILIE(CPT) := EXTR_AFFILIE_DETAIL_TR(V_SEL_AFFILIE.QUALITE,
                                                V_SEL_AFFILIE.LIB_QUALITE,
                                                V_SEL_AFFILIE.NUMINDIV,
                                                V_SEL_AFFILIE.NOM,
                                                V_SEL_AFFILIE.PRENOM,
                                                V_SEL_AFFILIE.DATNAIS,
                                                V_SEL_AFFILIE.MATORG || '' || V_SEL_AFFILIE.CLESS,
                                                V_SEL_AFFILIE.MATORG2||'' || V_SEL_AFFILIE.CLESS2,
                                                V_SEL_AFFILIE.NUMGAR,
                                                V_SEL_AFFILIE.IDADHESION,
                                                S_IDPAYS,
                                                S_PAYS,
                                                V_SEL_AFFILIE.NUMADHE,
                                                T_ADRESSE,
                                                T_ADRESSE_2,
                                                T_ADRESSE_3,
                                                '',
                                                T_CODPOS,
                                                T_VILLE,
                                                T_PAYS,
                                                T_LIB_PAYS,
                                                V_SEL_AFFILIE.MAIL,
                                                V_SEL_AFFILIE.TELEPHONE,
                                                V_SEL_AFFILIE.TYPADR,
                                                V_SEL_AFFILIE.LIB_TYPADR,
                                                V_SEL_AFFILIE.ETAT,
                                                V_SEL_AFFILIE.LIB_ETAT,
                                                V_SEL_AFFILIE.MOTIF,
                                                V_SEL_AFFILIE.LIB_MOTIF,
                                                V_SEL_AFFILIE.REF_EXT,
                                                V_SEL_AFFILIE.REFCIE,
                                                V_SEL_AFFILIE.CNTREF_REFCIE,
                                                T_SITU_FAM,
                                                T_LIB_SITU_FAM,
                                                V_SEL_AFFILIE.RANG,
                                                V_SEL_AFFILIE.REGIME,
                                                V_SEL_AFFILIE.REGIME2,
                                                V_SEL_AFFILIE.CAISSE,
                                                V_SEL_AFFILIE.CAISSE2,
                                                V_SEL_AFFILIE.CENTRE,
                                                V_SEL_AFFILIE.CENTRE2,
                                                V_SEL_AFFILIE.LIB_REGIME,
                                                V_SEL_AFFILIE.LIB_REGIME2,
                                                F_LIB_TRPNT(1, V_SEL_AFFILIE.REGIME,V_SEL_AFFILIE.CAISSE,NULL),
                                                F_LIB_TRPNT(1, V_SEL_AFFILIE.REGIME2,V_SEL_AFFILIE.CAISSE2,NULL),
                                                F_LIB_TRPNT(2, V_SEL_AFFILIE.REGIME,V_SEL_AFFILIE.CAISSE,V_SEL_AFFILIE.CENTRE),
                                                F_LIB_TRPNT(2, V_SEL_AFFILIE.REGIME2,V_SEL_AFFILIE.CAISSE2,V_SEL_AFFILIE.CENTRE2),
                                                NULL,NULL,--noemie
                                                V_SEL_AFFILIE.porteurRIB,
                                                '',
                                                '',
                                                '', --Informations complémentaires
                                                TB_GARANTIS,
                                                V_SEL_AFFILIE.numprod -- ajout du numproduit
                                                );
      CPT := CPT + 1;

    END LOOP;



    RETURN TB_AFFILIE;


  EXCEPTION
    WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_GET_AFF',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => substr('err:'||sqlerrm,1,132),
        I_idligne  => 2);
        RETURN TB_AFFILIE;
  END F_GET_AFF;
  /*********************************************************/

  /*********************************************************/
  FUNCTION F_VERIFY_USER_ACCOUNT (
           P_NOM INDIVIDU.NOM%TYPE,
           P_PRENOM INDIVIDU.PRENOM%TYPE,
           P_DATE INDIVIDU.DATNAIS%TYPE,
           P_MAIL CONTACT.COORDONNEE%TYPE,
           P_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE,
           P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE)
  RETURN EXTR_TAB_REP_ACTION
  IS





    --verif numassu
     CURSOR C_VERIF_INDIVIDU_NUMASSU(
          V_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE
          ) IS
     SELECT distinct INDIVIDU.NUMINDIV
     FROM INDIVIDU, ADHE_CNTRT_MEMBRE, CONTRAT, ADHE_CNTRT ,PORTE_CONTRAT
     WHERE INDIVIDU.NUMINDIV = V_NUM_ASSU
     --AND INDIVIDU.NOM = UPPER(NVL(V_NOM,INDIVIDU.NOM))
     --AND INDIVIDU.PRENOM = UPPER(NVL(V_PRENOM,INDIVIDU.PRENOM))
     --AND INDIVIDU.DATNAIS = TO_DATE(V_DATE,'DD/MM/YYYY')
     AND CONTRAT.NUMGAR = ADHE_CNTRT.NUMGAR
     AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
     --AND PORTE_CONTRAT.NUMGAR = CONTRAT.NUMGAR_REF
     --AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
     AND (ADHE_CNTRT_MEMBRE.NUMINDIV = V_NUM_ASSU
       OR ADHE_CNTRT.NUMADHE = V_NUM_ASSU
       OR ADHE_CNTRT.NUMQUERABLE = V_NUM_ASSU    );
     --AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24);

     --verif numassu + nom
     CURSOR C_VERIF_INDIVIDU_NOM(
          V_NOM    INDIVIDU.NOM%TYPE,
          V_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE
          ) IS
     SELECT distinct INDIVIDU.NUMINDIV
     FROM INDIVIDU, ADHE_CNTRT_MEMBRE, CONTRAT, ADHE_CNTRT ,PORTE_CONTRAT
     WHERE INDIVIDU.NUMINDIV = V_NUM_ASSU
     AND INDIVIDU.NOM = UPPER(NVL(TRIM(V_NOM),INDIVIDU.NOM))
     --AND INDIVIDU.PRENOM = UPPER(NVL(V_PRENOM,INDIVIDU.PRENOM))
     --AND INDIVIDU.DATNAIS = TO_DATE(V_DATE,'DD/MM/YYYY')
     AND CONTRAT.NUMGAR = ADHE_CNTRT.NUMGAR
     AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
     --AND PORTE_CONTRAT.NUMGAR = CONTRAT.NUMGAR_REF
     --AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
     AND (ADHE_CNTRT_MEMBRE.NUMINDIV = V_NUM_ASSU
       OR ADHE_CNTRT.NUMADHE = V_NUM_ASSU
       OR ADHE_CNTRT.NUMQUERABLE = V_NUM_ASSU    );
     --AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24);

     --verif numassu + prenom
     CURSOR C_VERIF_INDIVIDU_PRENOM(
          V_PRENOM INDIVIDU.PRENOM%TYPE,
          V_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE
          ) IS
     SELECT distinct INDIVIDU.NUMINDIV
     FROM INDIVIDU, ADHE_CNTRT_MEMBRE, CONTRAT, ADHE_CNTRT ,PORTE_CONTRAT
     WHERE INDIVIDU.NUMINDIV = V_NUM_ASSU
     --AND INDIVIDU.NOM = UPPER(NVL(TRIM(V_NOM),INDIVIDU.NOM))
     AND INDIVIDU.PRENOM = UPPER(NVL(TRIM(V_PRENOM),INDIVIDU.PRENOM))
     --AND INDIVIDU.DATNAIS = TO_DATE(V_DATE,'DD/MM/YYYY')
     AND CONTRAT.NUMGAR = ADHE_CNTRT.NUMGAR
     AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
     --AND PORTE_CONTRAT.NUMGAR = CONTRAT.NUMGAR_REF
     --AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
     AND (ADHE_CNTRT_MEMBRE.NUMINDIV = V_NUM_ASSU
       OR ADHE_CNTRT.NUMADHE = V_NUM_ASSU
       OR ADHE_CNTRT.NUMQUERABLE = V_NUM_ASSU    );
     --AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24);

     --verif numassu + DateNais
     CURSOR C_VERIF_INDIVIDU_DATNAISS(
          V_DATE   INDIVIDU.DATNAIS%TYPE,
          V_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE
          ) IS
     SELECT distinct INDIVIDU.NUMINDIV
     FROM INDIVIDU, ADHE_CNTRT_MEMBRE, CONTRAT, ADHE_CNTRT ,PORTE_CONTRAT
     WHERE INDIVIDU.NUMINDIV = V_NUM_ASSU
     --AND INDIVIDU.NOM = UPPER(NVL(V_NOM,INDIVIDU.NOM))
     --AND INDIVIDU.PRENOM = UPPER(NVL(V_PRENOM,INDIVIDU.PRENOM))
     AND INDIVIDU.DATNAIS = TO_DATE(V_DATE,'DD/MM/YYYY')
     AND CONTRAT.NUMGAR = ADHE_CNTRT.NUMGAR
     AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
     --AND PORTE_CONTRAT.NUMGAR = CONTRAT.NUMGAR_REF
     --AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
     AND (ADHE_CNTRT_MEMBRE.NUMINDIV = V_NUM_ASSU
       OR ADHE_CNTRT.NUMADHE = V_NUM_ASSU
       OR ADHE_CNTRT.NUMQUERABLE = V_NUM_ASSU    );
     --AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24);

     --verif numassu + porte
     CURSOR C_VERIF_INDIVIDU_PORTE(
          V_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE,
          V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE) IS
     SELECT distinct INDIVIDU.NUMINDIV
     FROM INDIVIDU, ADHE_CNTRT_MEMBRE, CONTRAT, ADHE_CNTRT ,PORTE_CONTRAT
     WHERE INDIVIDU.NUMINDIV = V_NUM_ASSU
     --AND INDIVIDU.NOM = UPPER(NVL(V_NOM,INDIVIDU.NOM))
     --AND INDIVIDU.PRENOM = UPPER(NVL(V_PRENOM,INDIVIDU.PRENOM))
     --AND INDIVIDU.DATNAIS = TO_DATE(V_DATE,'DD/MM/YYYY')
     AND CONTRAT.NUMGAR = ADHE_CNTRT.NUMGAR
     AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
     AND PORTE_CONTRAT.NUMGAR = CONTRAT.NUMGAR_REF
     AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
     AND (ADHE_CNTRT_MEMBRE.NUMINDIV = V_NUM_ASSU
       OR ADHE_CNTRT.NUMADHE = V_NUM_ASSU
       OR ADHE_CNTRT.NUMQUERABLE = V_NUM_ASSU    );
     --AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24);

     CURSOR C_VERIF_INDIVIDU_24MOIS(
         V_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE
         ) IS
     SELECT distinct INDIVIDU.NUMINDIV
     FROM INDIVIDU, ADHE_CNTRT_MEMBRE, CONTRAT, ADHE_CNTRT ,PORTE_CONTRAT
     WHERE INDIVIDU.NUMINDIV = V_NUM_ASSU
     --AND INDIVIDU.NOM = UPPER(NVL(TRIM(V_NOM),INDIVIDU.NOM))
     --AND INDIVIDU.PRENOM = UPPER(NVL(TRIM(V_PRENOM),INDIVIDU.PRENOM))
     --AND INDIVIDU.DATNAIS = TO_DATE(V_DATE,'DD/MM/YYYY')
     AND CONTRAT.NUMGAR = ADHE_CNTRT.NUMGAR
     AND ADHE_CNTRT.IDADHESION = ADHE_CNTRT_MEMBRE.IDADHESION
     --AND PORTE_CONTRAT.NUMGAR = CONTRAT.NUMGAR_REF
     --AND PORTE_CONTRAT.NUMPORTE = V_NUMPORTE
     AND (ADHE_CNTRT_MEMBRE.NUMINDIV = V_NUM_ASSU
       OR ADHE_CNTRT.NUMADHE = V_NUM_ASSU
       OR ADHE_CNTRT.NUMQUERABLE = V_NUM_ASSU    )
     AND NVL(ADHE_CNTRT.DATE_FIN_ADHE,SYSDATE) >ADD_MONTHS(SYSDATE,-24);


   V_VERIF_INDIVIDU_24MOIS C_VERIF_INDIVIDU_24MOIS%ROWTYPE;
   V_VERIF_INDIVIDU_NUMASSU C_VERIF_INDIVIDU_NUMASSU%ROWTYPE;
   V_VERIF_INDIVIDU_NOM C_VERIF_INDIVIDU_NOM%ROWTYPE;
   V_VERIF_INDIVIDU_PRENOM C_VERIF_INDIVIDU_PRENOM%ROWTYPE;
   V_VERIF_INDIVIDU_DATNAISS C_VERIF_INDIVIDU_DATNAISS%ROWTYPE;
   V_VERIF_INDIVIDU_PORTE C_VERIF_INDIVIDU_PORTE%ROWTYPE;

   V_SUCCES NUMBER(1) := 0;
   v_SUCCES_NUMINDIV NUMBER(1) := 0;
   v_SUCCES_NOM NUMBER(1) := 0;
   v_SUCCES_PRENOM NUMBER(1) := 0;
   v_SUCCES_DATNAIS NUMBER(1) := 0;
   v_SUCCES_PORTE NUMBER(1) := 0;
   v_SUCCES_24MOIS NUMBER(1) := 0;
   TB_REP EXTR_TAB_REP_ACTION;
   TB_REP_DETAIL EXTR_TAB_DETAIL_ACTION;
   REP_F_VERIFY_USER_ACCOUNT EXTR_TAB_REP_ACTION;
   V_NUMINDIV INDIVIDU.NUMINDIV%TYPE;
   MSG VARCHAR2(500);
   ERROR_VERIF EXCEPTION;


  BEGIN

    TB_REP := new EXTR_TAB_REP_ACTION(null);
    TB_REP_DETAIL := new EXTR_TAB_DETAIL_ACTION(null);
    V_NUMINDIV := 0;
    V_SUCCES := 0;

    --ASSU
    --***************************************************************************
    FOR V_VERIF_INDIVIDU_NUMASSU IN C_VERIF_INDIVIDU_NUMASSU(P_NUM_ASSU) LOOP
        V_NUMINDIV := V_VERIF_INDIVIDU_NUMASSU.NUMINDIV;
        EXIT;
    END LOOP;

    IF V_NUMINDIV > 0 THEN
       v_SUCCES_NUMINDIV := 1;
       MSG := MSG || 'Numéro Assuré OK: ' || P_NUM_ASSU || '<br />';
    ELSE
       v_SUCCES_NUMINDIV := 0;
       MSG := MSG || '<span class="er_ws">Numéro Assuré KO : ' || P_NUM_ASSU || '</span><br />';
    END IF;

    IF v_SUCCES_NUMINDIV = 0 THEN
       RAISE ERROR_VERIF;
    END IF;

    --***************************************************************************
     --ASSU + NOM
     --***************************************************************************
     V_NUMINDIV := 0;
     FOR V_VERIF_INDIVIDU_NOM IN C_VERIF_INDIVIDU_NOM(P_NOM,P_NUM_ASSU) LOOP
        V_NUMINDIV := V_VERIF_INDIVIDU_NOM.NUMINDIV;
        EXIT;
    END LOOP;

    IF V_NUMINDIV > 0 THEN
       v_SUCCES_NOM := 1;
       MSG := MSG ||'NOM OK: ' || P_NOM || '<br />';
    ELSE
       v_SUCCES_NOM := 0;
       MSG := MSG ||'<span class="er_ws">NOM KO : ' || P_NOM || '</span><br />';
    END IF;

    --***************************************************************************
    --ASSU + PRENOM
    --***************************************************************************
     V_NUMINDIV := 0;
     FOR V_VERIF_INDIVIDU_PRENOM IN C_VERIF_INDIVIDU_PRENOM(P_PRENOM,P_NUM_ASSU) LOOP
        V_NUMINDIV := V_VERIF_INDIVIDU_PRENOM.NUMINDIV;
         EXIT;
    END LOOP;

    IF V_NUMINDIV > 0 THEN
       v_SUCCES_PRENOM := 1;
       MSG := MSG ||'PRENOM OK: '|| P_PRENOM || '<br />';
    ELSE
       v_SUCCES_PRENOM := 0;
       MSG := MSG ||'<span class="er_ws">PRENOM KO : '|| P_PRENOM || '</span><br />';
    END IF;

    --***************************************************************************
    --ASSU + DATNAISS
    --***************************************************************************
     V_NUMINDIV := 0;
     FOR V_VERIF_INDIVIDU_DATNAISS IN C_VERIF_INDIVIDU_DATNAISS(P_DATE,P_NUM_ASSU) LOOP
        V_NUMINDIV := V_VERIF_INDIVIDU_DATNAISS.NUMINDIV;
         EXIT;
    END LOOP;

    IF V_NUMINDIV > 0 THEN
       v_SUCCES_DATNAIS := 1;
       MSG := MSG ||'DATE NAISSANCE OK: '|| TO_DATE(P_DATE,'DD/MM/YYYY') || '<br />';

    ELSE
       v_SUCCES_DATNAIS := 0;
       MSG := MSG ||'<span class="er_ws">DATE NAISSANCE KO : '|| TO_DATE(P_DATE,'DD/MM/YYYY') || '</span><br />';

    END IF;

    --***************************************************************************
    --ASSU  + PORTE
    --***************************************************************************
    V_NUMINDIV := 0;
    FOR V_VERIF_INDIVIDU_PORTE IN C_VERIF_INDIVIDU_PORTE(P_NUM_ASSU,P_NUMPORTE) LOOP
       V_NUMINDIV := V_VERIF_INDIVIDU_PORTE.NUMINDIV;
       EXIT;
    END LOOP;

   IF V_NUMINDIV > 0 THEN
       v_SUCCES_PORTE := 1;
       MSG := MSG ||'PORTE OK: '|| P_NUMPORTE || '<br />';
    ELSE
       v_SUCCES_PORTE := 0;
       MSG := MSG ||'<span class="er_ws">PORTE KO : '|| P_NUMPORTE || '</span><br />';
    END IF;


    --***************************************************************************
    --ASSU + 24Mois
    --***************************************************************************
    V_NUMINDIV := 0;
    FOR V_VERIF_INDIVIDU_24MOIS IN C_VERIF_INDIVIDU_24MOIS(P_NUM_ASSU) LOOP
       V_NUMINDIV := V_VERIF_INDIVIDU_24MOIS.NUMINDIV;
       EXIT;
    END LOOP;

   IF V_NUMINDIV > 0 THEN
       v_SUCCES_24MOIS := 1;
       MSG := MSG ||'Adhesion 2 ans OK' || '<br />';
    ELSE
       v_SUCCES_24MOIS := 0;
       MSG := MSG ||'<span class="er_ws">Adhesion ferme plus de 2 ans KO' || '</span><br />';
    END IF;

    IF v_SUCCES_NUMINDIV = 1 AND
       v_SUCCES_NOM=1 AND
       v_SUCCES_PRENOM = 1 AND
       v_SUCCES_DATNAIS = 1 AND
       v_SUCCES_PORTE = 1 AND
       v_SUCCES_24MOIS = 1
    THEN
      V_SUCCES := 1;
      TB_REP_DETAIL := F_AJOUT_DETAIL_ACTION('AUTO',MSG,P_NUM_ASSU,'ARTHUS',V_SUCCES,'VERIFICATION ARTHUS',TB_REP_DETAIL);
      TB_REP(1) := EXTR_TYPE_REP_ACTION_TR( V_SUCCES,TB_REP_DETAIL );
      REP_F_VERIFY_USER_ACCOUNT := TB_REP;
    ELSE
      V_SUCCES := 0;
    END IF;


    IF V_SUCCES = 0 THEN
     RAISE ERROR_VERIF;
    END IF;
    --***************************************************************************

    RETURN REP_F_VERIFY_USER_ACCOUNT;

  EXCEPTION
     WHEN ERROR_VERIF THEN

          TB_REP_DETAIL := F_AJOUT_DETAIL_ACTION('AUTO',substr(MSG,1,250),P_NUM_ASSU,'ARTHUS',V_SUCCES,'VERIFICATION ARTHUS',TB_REP_DETAIL);
          TB_REP(1) := EXTR_TYPE_REP_ACTION_TR( V_SUCCES,TB_REP_DETAIL );
          REP_F_VERIFY_USER_ACCOUNT := TB_REP;

          RETURN REP_F_VERIFY_USER_ACCOUNT;

     WHEN OTHERS THEN
          PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_VERIFY_USER_ACCOUNT',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(sqlerrm,1,132),
          I_idligne  => 2);

          RETURN REP_F_VERIFY_USER_ACCOUNT;

  END F_VERIFY_USER_ACCOUNT;
  /*********************************************************/

  /*********************************************************/
  FUNCTION F_EDIT_COMPANY  (
               P_NUMINDIV  INDIVIDU.NUMINDIV%TYPE,
               P_NOM       INDIVIDU.NOM%TYPE,
               P_TELEPHONE CONTACT.COORDONNEE%TYPE,
               P_TELECOPIE CONTACT.COORDONNEE%TYPE,
               P_EMAIL     CONTACT.COORDONNEE%TYPE,
               P_NUMSIRET  PERS_MORALE.SIRET%TYPE,
               P_CODEAPE   PERS_MORALE.APE%TYPE
      )
      RETURN EXTR_TAB_REP_ACTION  IS
    REP_F_WS_EDIT_COMPANY EXTR_TAB_REP_ACTION;
  BEGIN
    IF P_NUMINDIV IS NOT NULL THEN
       IF P_NUMSIRET IS NOT NULL THEN
         UPDATE PERS_MORALE SET SIRET = P_NUMSIRET WHERE NUMINDIV = P_NUMINDIV;
       END IF;

       IF P_NOM IS NOT NULL THEN
         UPDATE INDIVIDU SET NOM = P_NOM WHERE NUMINDIV = P_NUMINDIV;
       END IF;

       IF P_TELEPHONE IS NOT NULL THEN
         UPDATE CONTACT SET COORDONNEE = P_TELEPHONE WHERE NUMINDIV = P_NUMINDIV AND NATURE = 1;
       END IF;

       IF P_TELECOPIE IS NOT NULL THEN
         UPDATE CONTACT SET COORDONNEE = P_TELECOPIE WHERE NUMINDIV = P_NUMINDIV AND NATURE = 3;
       END IF;

       IF P_EMAIL IS NOT NULL THEN
         UPDATE CONTACT SET COORDONNEE = P_EMAIL WHERE NUMINDIV = P_NUMINDIV AND NATURE = 4;
       END IF;

       IF P_NUMSIRET IS NOT NULL THEN
         UPDATE PERS_MORALE SET SIRET = P_NUMSIRET WHERE NUMINDIV = P_NUMINDIV;
       END IF;

       IF P_CODEAPE IS NOT NULL THEN
         UPDATE PERS_MORALE SET APE = P_CODEAPE WHERE NUMINDIV = P_NUMINDIV;
       END IF;
    END IF;

    REP_F_WS_EDIT_COMPANY := null;

    RETURN REP_F_WS_EDIT_COMPANY;

      EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_WS_EDIT_COMPANY',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);

            RETURN REP_F_WS_EDIT_COMPANY;
  END F_EDIT_COMPANY;

  /*************************************************************/

  /*************************************************************/

  FUNCTION F_AJOUT_DETAIL_ACTION (
     TYPE          VARCHAR2,                  --AUTO or MANUEL
     MESSAGE       VARCHAR2,                  --MESSAGE DE LA REP
     CLEF          NUMBER,                    --clef
     ORIGINE       VARCHAR2,                  --ARTHUS
     SUCCES        NUMBER,                    --1 OK 0 KO
     NOMWS         VARCHAR2,                  --NOM DU WEB SEVICE
     TB_DETAIL     EXTR_TAB_DETAIL_ACTION     --TABLEAU DETAIL
  )
  RETURN EXTR_TAB_DETAIL_ACTION
  IS
    TAB_DETAIL EXTR_TAB_DETAIL_ACTION;
    TAB_RESULT EXTR_TAB_RESULT;
    CPT NUMBER;
  BEGIN
     TAB_RESULT := new EXTR_TAB_RESULT(null);
     TAB_DETAIL := TB_DETAIL;
     CPT := TAB_DETAIL.COUNT;
     IF TAB_DETAIL.COUNT > 1 THEN
        TAB_DETAIL.EXTEND(1);
        CPT := CPT + 1;
     END IF;
     TAB_RESULT(1) := EXTR_TYPE_TAB_RESULT_TR(CLEF);
     TAB_DETAIL(CPT) := EXTR_TYPE_TAB_DETAIL_ACTION_TR( TYPE,
                                                        MESSAGE,
                                                        TAB_RESULT,
                                                        ORIGINE,
                                                        SUCCES,
                                                        NOMWS
                                                      );
      RETURN TAB_DETAIL;

  EXCEPTION
         WHEN OTHERS THEN
              PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_AJOUT_DETAIL_ACTION',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);

          RETURN TAB_DETAIL;
  END F_AJOUT_DETAIL_ACTION;
  /*****************************************************************/

  /*****************************************************************/

  FUNCTION F_COOR_BANQUE (P_NUMINDIV  INDIVIDU.NUMINDIV%TYPE
        ) RETURN EXTR_TAB_RIB IS

    CURSOR C_SEL_RIB(V_NUMINDIV INDIVIDU.NUMINDIV%TYPE )IS
      SELECT IDRIB,NUMINDIV,TYPE,DECODE(TYPE, 1, 'Prestation', 2, 'Cotisation', 'Indéterminé') as LIB_TYPE,
            DEBUT,CODOPE,F_LBLE('OPE',CODOPE) AS LIB_CODOPE,
            MODPMT,DEVISE_COMPTE, PK_DEVISE.LIB_SYMBOLE(DEVISE_COMPTE)  AS LIB_DEVISE_COMPTE,
            INTITULE,DOMICILIATION,CLEF_IBAN,BBAN,
            BIC,CODPAYS,F_PAYS(CODPAYS) AS LIB_PAYS,
            CODBQUE_ETRG,TYP_BQ_ETRG,GUICHET_ETRG,TYP_GUI_ETRG,
            COMPTE_ETRG,CLERIB_ETRG,TYP_CLE_ETRG,
            NATURE,F_LBLE(DECODE(TYPE,1,'MOPM',2,'MREGL','MOPM'),MODPMT) as LIB_NATURE,FIN
      FROM RIB
      WHERE RIB.NUMINDIV = V_NUMINDIV
      AND NVL(RIB.FIN,SYSDATE)>= SYSDATE
      AND TYPE IN (1,2);

    V_SEL_RIB C_SEL_RIB%ROWTYPE;
    REP_F_COOR_BANQUE EXTR_TAB_RIB;
    CPT NUMBER;

    BEGIN

    CPT:=1;
    REP_F_COOR_BANQUE := new EXTR_TAB_RIB(null);
    FOR V_SEL_RIB IN C_SEL_RIB(P_NUMINDIV) LOOP
       IF (CPT > 1) THEN
            REP_F_COOR_BANQUE.EXTEND(1);
       END IF;

       REP_F_COOR_BANQUE(CPT) := EXTR_RIB_TR( V_SEL_RIB.IDRIB, --IDRIB,
                                              V_SEL_RIB.NUMINDIV, --NUMINDIV,
                                              V_SEL_RIB.TYPE, --TYPE,
                                              V_SEL_RIB.LIB_TYPE, --LIB_TYPE
                                              V_SEL_RIB.DEBUT, --DEBUT,
                                              V_SEL_RIB.CODOPE, --CODOPE,
                                              V_SEL_RIB.LIB_CODOPE, --LIB_CODOPE,
                                              V_SEL_RIB.MODPMT, --MODPMT,
                                              V_SEL_RIB.DEVISE_COMPTE, --DEVISE_COMPTE,
                                              V_SEL_RIB.LIB_DEVISE_COMPTE, --LIB_DEVISE_COMPTE,
                                              V_SEL_RIB.INTITULE, --INTITULE,
                                              V_SEL_RIB.DOMICILIATION, --DOMICILIATION,
                                              V_SEL_RIB.CLEF_IBAN, --CLEF_IBAN,
                                              V_SEL_RIB.BBAN, --BBAN,
                                              V_SEL_RIB.BIC, --BIC,
                                              V_SEL_RIB.CODPAYS, --CODPAYS,
                                              V_SEL_RIB.LIB_PAYS, --LIB_PAYS,
                                              V_SEL_RIB.CODBQUE_ETRG, --CODBQUE_ETRG,
                                              V_SEL_RIB.TYP_BQ_ETRG, --TYP_BQ_ETRG,
                                              V_SEL_RIB.GUICHET_ETRG, --GUICHET_ETRG,
                                              V_SEL_RIB.TYP_GUI_ETRG, --TYP_GUI_ETRG,
                                              V_SEL_RIB.COMPTE_ETRG, --COMPTE_ETRG,
                                              V_SEL_RIB.CLERIB_ETRG, --CLERIB_ETRG,
                                              V_SEL_RIB.TYP_CLE_ETRG, --TYP_CLE_ETRG,
                                              V_SEL_RIB.NATURE, --NATURE,
                                              V_SEL_RIB.LIB_NATURE, --LIB_MODPMT,
                                              V_SEL_RIB.FIN  );
       CPT := CPT+1;
    END LOOP;


    RETURN REP_F_COOR_BANQUE;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_COOR_BANQUE',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr('erreur:' || sqlerrm,1,132),
            I_idligne  => 2);

            RETURN REP_F_COOR_BANQUE;
  END F_COOR_BANQUE;
  /******************************************************************/

  /*****************************************************************/
  /*****************************************************************
  **  P_TYPE_QUERABLE 1 adherent
  **  P_TYPE_QUERABLE 2 assure
  ** ARTGEREP-611 ABO affichage des cotisations prévisionnelles en décembre
  /*****************************************************************/

  FUNCTION F_COTISATION (
    P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
    P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE,
    P_TYPE_QUERABLE NUMBER,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE )
    RETURN EXTR_TAB_COTISATION  IS

    --ABO 23/09 Correction, ajout de jointure et correction référence externe contrat / adh coll
    CURSOR C_SEL_QTTC_SOUS(V_NUMINDIV INDIVIDU.NUMINDIV%TYPE , V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE)  IS
      SELECT vqs.NUMQUIT,decode(vqs.EDATEMIS,'Non émis',NULL,e2d(vqs.EDATEMIS)) EDATEMIS,vqs.NUMGAR,
      c.REFCIE as CNTREF_REFCIE,
      vqs.EDEBUT,vqs.EFIN,
      --SDA Mantis 5238
      --DECODE( c.NAT_CALC ,1,null,vqs.MONTANT_D) as MONTANT_D,
      vqs.MONTANT_D as MONTANT_D,
      vqs.MT_REGL_D,vqs.MONNAIE_D,vqs.IDADHESION,
      vqs.NOMSOUSC,c.numorg,c.typgar,c.refcie,
      vqs.MREGL,F_LBLE('MREGL',vqs.MREGL) as LIBMREGL,vqs.ECHEANCE
      FROM V_QTTC_GLOBAL vqs , CONTRAT_REF c , PORTE_CONTRAT p
      WHERE vqs.NUMQUERABLE = V_NUMINDIV
      --AND (vqs.montant_d-vqs.mt_regl_d>=1 OR vqs.mt_regl_d IS NULL)
      AND vqs.montant_d>0
      AND c.numgar = f_numgar_ref(vqs.numgar)
      AND vqs.mt_affec <>'Régularisée'
      AND vqs.mt_affec <>'Annulé'
      AND vqs.EDATEMIS <>'Non émis'
      AND  NVL( vqs.DATEMIS, e2d('01/01/1900') ) > ADD_MONTHS(SYSDATE,-24)
      --AND vqs.mregl <>2  -- non prélevée
      AND p.NUMGAR = c.NUMGAR_REF
      AND p.NUMPORTE = V_NUMPORTE
      AND vqs.MONNAIE_D = nvl(pk_devise.devise_ref,1) --uniquement euro
      AND NOT EXISTS ( --ne pas affichée les régularisée et les impayés résiliation / suspension
        SELECT numquit FROM emission
        WHERE emission.numfact = vqs.NUMQUIT
        AND numrelance >30
        AND type_doc = 1
      )
      ORDER BY 1;
      --cas de tests unitaire   AND numquit in (304,11195)


    CURSOR C_SEL_QTTC_ADHE(
      V_NUMINDIV V_QTTC_ADHE.NUMQUERABLE%TYPE,
      V_IDADHESION V_QTTC_ADHE.IDADHESION%TYPE,
      V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE,
      v_date DATE
      )
      IS
     SELECT qttc_global.numgar,
      qttc_global.numquit,
      qttc_global.numquerable,
      qttc_global.numindiv,
      qttc_global.nat_calc,
      qttc_global.type_qttc,
      qttc_global.debut,
      qttc_global.fin,
      qttc_global.idadhesion,
      facture.mregl,
      facture.echeance,
      grnts.refcie CNTREF_REFCIE,
      grnts.numorg,
      grnts.typgar,
      grnts.numcli,
      querable.nom || ' ' || querable.prenom nomquerable,
      sousc.nom || ' ' || sousc.prenom nomsousc,
      libelle.libelle LIBMREGL,
      facture.montant montant,
      facture.montant_d montant_d,
      qttc_global.mt_net_d,
      qttc_global.mt_affec_d mt_regl_d,
      DECODE (qttc_global.comptant,
              'N', 'Prévisionnelle',
              DECODE (f_datemis (4, qttc_global.numquit, 1, 99),
                      'Non annulé', NVL (TO_CHAR (qttc_global.mt_affec_d,
                                                  '9999999.99'
                                                 ),
                                         'Non réglé'
                                        ),
                      'Annulé'
                     )
             ) mt_affec_d,
     qttc_global.monnaie_d,
     e.datemis edatemis
    --( select max (datemis) from emission where emission.numquit = qttc_global.numquit) edatemis
     FROM libelle,
          indvs querable,
          indvs sousc,
          grnts,
          porte_contrat p,
          qttc_global
          left outer join indvs assu on (  assu.numindiv = qttc_global.numindiv),
          facture
          left outer join emission e ON (e.numfact = facture.numfact and numrelance = 0)

    WHERE libelle.mnemo = 'MREGL'
      AND libelle.code = facture.mregl
      AND facture.codope = 4
      AND facture.numfact = qttc_global.numquit
      AND querable.numindiv = qttc_global.numquerable
      AND sousc.numindiv = grnts.numcli
      AND grnts.numgar = qttc_global.numgar
      AND grnts.numgar = p.numgar
      AND facture.mregl in (1,2)
      AND p.NUMPORTE = V_NUMPORTE
      AND qttc_global.NUMQUERABLE = V_NUMINDIV
      AND qttc_global.IDADHESION = NVL(V_IDADHESION,qttc_global.IDADHESION)
      AND qttc_global.MONNAIE_D = nvl(pk_devise.devise_ref,1) --uniquement euro
      AND qttc_global.comptant <>'R'
      AND (qttc_global.comptant='N' OR NVL( e.DATEMIS, e2d('01/01/1900') ) > ADD_MONTHS(SYSDATE,-24) )--emission de moins de 24 mois ou prévisionnelle
      AND facture.echeance BETWEEN TRUNC(v_date,'YEAR') AND  ADD_MONTHS(TRUNC(v_date,'YEAR'),24)-1--uniquement les quittances à payer sur l'année en cours et l'année suivante
      AND NOT EXISTS ( --ne pas affichée les régularisée et les impayés résiliation / suspension
        SELECT numquit FROM emission
        WHERE emission.numfact = facture.numfact
        AND numrelance >30
        AND type_doc = 1
      )
      ORDER BY qttc_global.idadhesion, qttc_global.debut;

      REP_F_COTISATION EXTR_TAB_COTISATION;
      V_SEL_COTISATION_ADH C_SEL_QTTC_SOUS%ROWTYPE;
      V_SEL_COTISATION_ASS C_SEL_QTTC_ADHE%ROWTYPE;
      SOLDE_D          NUMBER(11,2);
      CPT              NUMBER;
      TB_ADRESSE EXTR_ADRESSE_TR;
      S_CIV_NUMQUERABLE LIBELLE.LIBELLE%TYPE;
      S_NOM_NUMQUERABLE INDIVIDU.NOM%TYPE;
      S_PRENOM_NUMQUERABLE INDIVIDU.PRENOM%TYPE;
      S_MANDAT HISTO_QUERABLE.MANDAT%TYPE; -- RUM
      loc_idadhesion ADHE_CNTRT.idadhesion%TYPE;
      loc_emis NUMBER;

  BEGIN



    REP_F_COTISATION := new EXTR_TAB_COTISATION(null);
    TB_ADRESSE := EXTR_ADRESSE_TR('','','','','','');
    TB_ADRESSE := F_ADRESSE_BY_NUMINDIV(P_NUMINDIV);
    P_INFO_QUERABLE(P_NUMINDIV,S_CIV_NUMQUERABLE,S_NOM_NUMQUERABLE,S_PRENOM_NUMQUERABLE);


    CPT := 1;
    S_MANDAT:=NULL;
    IF P_TYPE_QUERABLE = 1 THEN

      FOR V_SEL_COTISATION_ADH IN C_SEL_QTTC_SOUS(P_NUMINDIV,P_NUMPORTE) LOOP

        IF (CPT > 1) THEN
          REP_F_COTISATION.EXTEND(1);
        END IF;

        SOLDE_D := null;
        IF(V_SEL_COTISATION_ADH.MONTANT_D is not null)THEN
          SOLDE_D := V_SEL_COTISATION_ADH.MONTANT_D - NVL(V_SEL_COTISATION_ADH.MT_REGL_D,0);
        END IF;


        REP_F_COTISATION(CPT) := EXTR_COTISATION_TR(  V_SEL_COTISATION_ADH.NUMQUIT,
                                                      P_NUMINDIV,
                                                      S_CIV_NUMQUERABLE,
                                                      S_NOM_NUMQUERABLE,
                                                      S_PRENOM_NUMQUERABLE,
                                                      TB_ADRESSE,
                                                      V_SEL_COTISATION_ADH.EDATEMIS,
                                                      V_SEL_COTISATION_ADH.NUMGAR,
                                                      V_SEL_COTISATION_ADH.CNTREF_REFCIE,
                                                      e2d(V_SEL_COTISATION_ADH.EDEBUT),
                                                      e2d(V_SEL_COTISATION_ADH.EFIN),
                                                      V_SEL_COTISATION_ADH.MONTANT_D,
                                                      V_SEL_COTISATION_ADH.MT_REGL_D,
                                                      SOLDE_D,
                                                      V_SEL_COTISATION_ADH.MONNAIE_D,
                                                      PK_DEVISE.Symbole(V_SEL_COTISATION_ADH.MONNAIE_D),
                                                      V_SEL_COTISATION_ADH.IDADHESION,
                                                      V_SEL_COTISATION_ADH.NOMSOUSC,
                                                      V_SEL_COTISATION_ADH.MREGL,
                                                      V_SEL_COTISATION_ADH.LIBMREGL,
                                                      V_SEL_COTISATION_ADH.ECHEANCE,
                                                      S_MANDAT --RUM
                                                       );

         CPT := CPT+1;
      END LOOP;

    ELSE
      loc_emis :=0;
      loc_idadhesion :=NULL;
      FOR V_SEL_COTISATION_ASS IN C_SEL_QTTC_ADHE(P_NUMINDIV,P_IDADHESION,P_NUMPORTE, sysdate) LOOP

        IF loc_idadhesion IS NULL OR loc_idadhesion <> V_SEL_COTISATION_ASS.idadhesion THEN
          -- Application de la RG métier
          -- si appel de cotisation N+1 émis alors le flux remonte
          -- décembre année en cours + année suivante
          -- sinon uniquement l'année en cours
          SELECT COUNT(emis.numfact) INTO loc_emis
          FROM emission emis
          INNER JOIN qttc_global qttc ON (emis.numfact = qttc.numquit )
          WHERE  emis.numrelance =0
          AND emis.codope=4
          AND qttc.idadhesion = V_SEL_COTISATION_ASS.idadhesion
          AND qttc.debut >= SAN(sysdate);
          loc_idadhesion := V_SEL_COTISATION_ASS.idadhesion;

        END IF;

        -- décembre année en cours + année suivante
        IF loc_emis = 1
           AND NOT V_SEL_COTISATION_ASS.echeance BETWEEN e2d('01/12/'||TO_CHAR(SYSDATE,'YYYY')) AND ADD_MONTHS(TRUNC(SYSDATE,'YEAR'),24)-1 THEN
          CONTINUE;
        --sinon uniquement l'année en cours
        ELSIF loc_emis = 0
             AND NOT V_SEL_COTISATION_ASS.echeance BETWEEN TRUNC(SYSDATE,'YEAR') AND ADD_MONTHS(TRUNC(SYSDATE,'YEAR'),12)-1 THEN
          CONTINUE;
        END IF;


        IF (CPT > 1) THEN
          REP_F_COTISATION.EXTEND(1);
        END IF;

        SOLDE_D := null;
        IF(V_SEL_COTISATION_ASS.MONTANT_D is not null)THEN
          SOLDE_D := V_SEL_COTISATION_ASS.MONTANT_D - NVL(V_SEL_COTISATION_ASS.MT_REGL_D,0);
        END IF;

        -- Recherche de la RUM(mandat) en fonction du numéro de querable)
        S_MANDAT:=NULL;
        BEGIN

            SELECT HISTO_mandat.mandat   INTO S_MANDAT
            FROM rib
            INNER JOIN HISTO_MANDAT ON  (HISTO_MANDAT.idrib = rib.idrib )
            INNER JOIN HISTO_QUERABLE ON (HISTO_QUERABLE.MANDAT = HISTO_MANDAT.MANDAT
                      AND HISTO_QUERABLE.NUMGAR = V_SEL_COTISATION_ASS.NUMGAR
                      AND HISTO_QUERABLE.IDADHESION = V_SEL_COTISATION_ASS.idadhesion
                      AND HISTO_QUERABLE.NUMQUERABLE = P_NUMINDIV
                      AND HISTO_QUERABLE.ETAT = 1 )
            WHERE rib.idrib =  pk_treso.f_idrib (P_NUMINDIV, 2, 4, V_SEL_COTISATION_ADH.NUMGAR, SYSDATE, V_SEL_COTISATION_ASS.idadhesion, V_SEL_COTISATION_ASS.MONNAIE_D)
            AND rib.modpmt             = 2
            AND f_rib_valide (rib.idrib) IN (1,2)
            AND HISTO_MANDAT.idhistomandat = (SELECT MAX(idhistomandat) FROM HISTO_MANDAT a  WHERE a.mandat = HISTO_MANDAT.MANDAT)
            AND HISTO_MANDAT.statut <> 0;
        EXCEPTION
          WHEN OTHERS THEN
            S_MANDAT:=NULL;
        END;

        REP_F_COTISATION(CPT) := EXTR_COTISATION_TR( V_SEL_COTISATION_ASS.NUMQUIT,
                                                    P_NUMINDIV,
                                                    S_CIV_NUMQUERABLE,
                                                    S_NOM_NUMQUERABLE,
                                                    S_PRENOM_NUMQUERABLE,
                                                    TB_ADRESSE,
                                                    V_SEL_COTISATION_ASS.EDATEMIS,
                                                    V_SEL_COTISATION_ASS.NUMGAR,
                                                    V_SEL_COTISATION_ASS.CNTREF_REFCIE,
                                                    V_SEL_COTISATION_ASS.DEBUT,
                                                    V_SEL_COTISATION_ASS.FIN,
                                                    V_SEL_COTISATION_ASS.MONTANT_D,
                                                    V_SEL_COTISATION_ASS.MT_REGL_D,
                                                    SOLDE_D,
                                                    V_SEL_COTISATION_ASS.MONNAIE_D,
                                                    PK_DEVISE.Symbole(V_SEL_COTISATION_ASS.MONNAIE_D),
                                                    V_SEL_COTISATION_ASS.IDADHESION,
                                                    V_SEL_COTISATION_ASS.NOMQUERABLE,
                                                    V_SEL_COTISATION_ASS.MREGL,
                                                    V_SEL_COTISATION_ASS.LIBMREGL,
                                                    V_SEL_COTISATION_ASS.ECHEANCE,
                                                    S_MANDAT--RUM
                                                    );

        CPT := CPT+1;
      END LOOP;
    END IF;

    RETURN REP_F_COTISATION;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_COTISATION',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);

            RETURN REP_F_COTISATION;
  END F_COTISATION;
  /******************************************************************/

  /******************************************************************/

  FUNCTION F_DECOMPTE (
    P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
    P_ANNEE    NUMBER,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
       ) RETURN EXTR_TAB_DECOMPTE IS

    CURSOR C_SEL_DECOMPTE(V_NUMINDIV INDIVIDU.NUMINDIV%TYPE, V_ANNEE NUMBER, V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE) IS
    SELECT
      s.numdec                                                 Num_decompte,
      MIN(c.numsin )                                           Num_sinistre,
      ''/*f_regime(s.numsin,b.num_dossier,b.numligne)  */      Regime_gar,
      e.NUMASSU                                                Num_adherent,
      acm.NUMINDIV                                             Num_assup,
      assup.prenom||' '||    assup.nom                         Nom_prenom_assup,
      patient.numindiv                                         Num_benef,
      patient.prenom||' '||patient.nom                         Nom_prenom_benef,
      DECAISMT.NUMDEST                                         Num_dest_reglt,
      dest.prenom||' '||    dest.nom                           Nom_prenom_dest_reglt,
      decaismt.datpay                                          Date_reglt,
      f_numbord_decaismt (decaismt.numdecaismt)                Bdx_payt,
      s.codfrais                                               Code_acte,
      ACTE.LIBELLE                                             Lib_acte,
      s.datsin                                                 Date_soins,
      c.dev_in                                                 Dev_soins,
      v.SYMBOLE                                                Lib_dev_soins,
      to_char(c.mtfrais_in,'999999990.90')                      Frais_reels_dev_soins,
      to_char(SUM(c.mtremb_out) ,'999999990.90')                Mt_rbtregime_Dev_rbt,
      c.dev_out                                                Num_dev_rbt,
      u.SYMBOLE                                                Lib_dev_rbt,
      ''                                                       numfor,
      to_char(SUM(c.autrb_out) ,'999999990.90')                 Mt_autre_rbt_dev_reg,
      to_char(SUM(c.mtreel_out)  ,'999999990.90')               Rbt_ct_dev_rbt,
      ''/*F_crrr_acte(s.numdec,s.numsin,0)   */                Renv,
      ''/*s.num_fact   */                                      Num_facture  ,
      to_char(f_dcpt_rembtotal(b.num_dossier,b.numligne) ,'999999990.90')  Rbt_total,
      decaismt.DATEDIT                                         decompte_edition,
      c.MTFRAIS_CT,
      c.MTREEL_CT,
      c.MTREMB_CT,
      c.AUTRB_CT,
      c.dev_ct,
      ct.SYMBOLE                                               LIB_DEV_RBT_CT,
      F_LBLE('QLTE',dest.QUALITE)                              civilite_dest,
      b.numligne --SDA M4916
    FROM
      indvs patient,
      indvs dest,
      indvs assup,
      sinistre_dev c,
    --    sntr d,
      sinistre_sante a,
      sntr_dossier b,
      dossier_sante e,
      libformath,
      ACTE,
      decaismt,
      affectation,
      DECOMPTE,
      Monnaie u,
      Monnaie V,
      Monnaie ct,
      sinistre s,
      adhe_cntrt_membre acm,
      porte_contrat p,
      contrat cntrt
    WHERE   decaismt.codope=1
    AND     patient.numindiv = c.numindiv
    --AND     c.numsin=d.numsin
    AND  a.num_dossier=b.num_dossier
    AND e.num_dossier=a.num_dossier
    AND a.numligne=b.numligne
    AND b.numsin_sntr=c.numsin
    AND s.edtdcpt=1
    --    AND     f_type_couv(s.numsin,b.num_dossier,b.numligne) In(1,2,5)
    AND libformath.nummath=s.nummath
    AND s.codfrais= ACTE.CODFRAIS
    AND c.numdec= decompte.NUMDEC
    AND affectation.numaffec = decompte.numdec
    AND affectation.numdecaismt = decaismt.NUMDECAISMT
    AND Decaismt.numdest = dest.NUMINDIV
    AND u.CODMON = c.dev_out
    AND v.CODMON = c.dev_in
    AND ct.CODMON = c.dev_ct
    AND acm.typadr = 0 -- Assuré principal
    AND s.numsin = c.numsin
    AND s.idadhesion = acm.idadhesion
    AND assup.numindiv = acm.numindiv
    AND acm.numindiv = V_NUMINDIV
    AND s.numgar=cntrt.numgar
    AND p.numgar = cntrt.numgar_ref
    AND p.numporte=V_NUMPORTE
    AND decaismt.datpay BETWEEN e2d('01/01/'||TO_CHAR(V_ANNEE)) AND e2d('31/12/'||TO_CHAR(V_ANNEE))
    AND decaismt.datpay BETWEEN ADD_MONTHS(SYSDATE,-24) AND SYSDATE
    AND f_type_couv(s.numsin,b.num_dossier,b.numligne) In(1,2,5)
    --AND c.mtremb_ct <> 0 --SDA M4916
    AND ROWNUM <= 443
    group by s.numdec    ,
      e.NUMASSU    ,
      acm.NUMINDIV      ,
      assup.prenom, assup.nom      ,
      patient.numindiv     ,
      patient.prenom,patient.nom    ,
      DECAISMT.NUMDEST     ,
      dest.prenom, dest.nom    ,
      decaismt.datpay      ,
      f_numbord_decaismt (decaismt.numdecaismt)      ,
      s.codfrais          ,
      ACTE.LIBELLE     ,
      s.datsin      ,
      c.dev_in   ,
      v.SYMBOLE    ,
      to_char(c.mtfrais_in,'999999990.90')  ,
      c.dev_out                                                ,
      u.SYMBOLE                                                ,
      to_char(f_dcpt_rembtotal(b.num_dossier,b.numligne) ,'999999990.90') ,
      decaismt.DATEDIT,
      c.MTFRAIS_CT,
      c.MTREEL_CT,
      c.MTREMB_CT,
      c.AUTRB_CT,
      c.dev_ct,
      ct.SYMBOLE,
      F_LBLE('QLTE',dest.QUALITE),
      b.numligne --SDA M4916
    ORDER BY  s.numdec desc,Nom_prenom_benef asc, s.datsin desc , MIN(c.numsin) desc;


    V_SEL_DECOMPTE C_SEL_DECOMPTE%ROWTYPE;
    CPT       NUMBER := 0;
    TB_DECOMPTE EXTR_TAB_DECOMPTE;
    V_COM_DECOMPTE VARCHAR2(700);
    TB_ADRESSE EXTR_ADRESSE_TR;

  BEGIN
    TB_ADRESSE := EXTR_ADRESSE_TR('','','','','','');
    TB_DECOMPTE := new EXTR_TAB_DECOMPTE(null);
    CPT := 1;
    FOR CUR_VAR IN C_SEL_DECOMPTE(P_NUMINDIV, P_ANNEE,P_NUMPORTE) LOOP

      IF (CPT > 1) THEN
      TB_DECOMPTE.EXTEND(1);
      END IF;

      V_COM_DECOMPTE := F_COM_DECOMPTE(CUR_VAR.Num_decompte,CUR_VAR.Code_acte,CUR_VAR.Num_sinistre);

      TB_ADRESSE := F_ADRESSE_BY_NUMINDIV(CUR_VAR.Num_dest_reglt);


      TB_DECOMPTE(CPT) := EXTR_DECOMPTE_TR( CUR_VAR.Num_decompte,
                                            CUR_VAR.Num_sinistre,
                                            CUR_VAR.Num_adherent,
                                            CUR_VAR.Num_assup,
                                            CUR_VAR.Nom_prenom_assup,
                                            CUR_VAR.Num_benef,
                                            CUR_VAR.Nom_prenom_benef,
                                            CUR_VAR.Num_dest_reglt,
                                            CUR_VAR.Nom_prenom_dest_reglt,
                                            TB_ADRESSE,
                                            CUR_VAR.Date_reglt,
                                            CUR_VAR.Bdx_payt,
                                            CUR_VAR.Code_acte,
                                            CUR_VAR.Lib_acte,
                                            CUR_VAR.Date_soins,
                                            CUR_VAR.Dev_soins,
                                            CUR_VAR.Lib_dev_soins,
                                            CUR_VAR.Frais_reels_dev_soins,
                                            CUR_VAR.Mt_rbtregime_Dev_rbt,
                                            CUR_VAR.Num_dev_rbt,
                                            CUR_VAR.Lib_dev_rbt,
                                            CUR_VAR.numfor,
                                            CUR_VAR.Mt_autre_rbt_dev_reg,
                                            CUR_VAR.Rbt_ct_dev_rbt,
                                            CUR_VAR.Renv,
                                            CUR_VAR.Num_facture,
                                            CUR_VAR.Regime_gar,
                                            CUR_VAR.Rbt_total,
                                            V_COM_DECOMPTE,
                                            CUR_VAR.decompte_edition,
                                            CUR_VAR.MTFRAIS_CT,
                                            CUR_VAR.MTREEL_CT,
                                            CUR_VAR.MTREMB_CT,
                                            CUR_VAR.AUTRB_CT,
                                            CUR_VAR.dev_ct,
                                            CUR_VAR.LIB_DEV_RBT_CT,
                                            CUR_VAR.civilite_dest,
                                            NULL,
                                            NULL -- reseau
                                            );
      CPT := CPT + 1;

    END LOOP;
    RETURN TB_DECOMPTE;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_DECOMPTE',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);
            RETURN TB_DECOMPTE;
  END F_DECOMPTE;

  FUNCTION F_DECOMPTE_V7 (
    P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
    P_ANNEE    NUMBER,
    P_DEBUT    DATE,
    P_FIN      DATE,
    P_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
       ) RETURN EXTR_TAB_DECOMPTE IS

    CURSOR C_SEL_DECOMPTE(V_NUMINDIV INDIVIDU.NUMINDIV%TYPE, V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE,v_debut date, v_fin date) IS
    SELECT
       s.numdec                                                Num_decompte,
      c.numsin                                                 Num_sinistre,
      ''                                                       Regime_gar,
      ac.numadhe                                               Num_adherent,
      acm.NUMINDIV                                             Num_assup,
      assup.prenom||' '||    assup.nom                         Nom_prenom_assup,
      patient.numindiv                                         Num_benef,
      patient.prenom||' '||patient.nom                         Nom_prenom_benef,
      DECAISMT.NUMDEST                                         Num_dest_reglt,
      decode(DECOMPTE.typbene,1,dest.prenom||' '||dest.nom,'votre professionnel de santé')   Nom_prenom_dest_reglt,
      TRUNC(F_CPTA_DATE_DECAISMT(decaismt.numdecaismt))        Date_reglt,
      f_cpta_lib_reglt (9151, decaismt.numdecaismt, 1)         Bdx_payt,
      s.codfrais                                               Code_acte,
      CONCAT( UPPER( SUBSTR( ACTE.LIBELLE, 1, 1 ) ), LOWER( SUBSTR( ACTE.LIBELLE , 2 ) ) ) Lib_acte,
      s.datsin                                                 Date_soins,
      c.dev_in                                                 Dev_soins,
      v.SYMBOLE                                                Lib_dev_soins,
      to_char(c.mtfrais_in,'999999990.90')                     Frais_reels_dev_soins,
      to_char(c.mtremb_out ,'999999990.90')                    Mt_rbtregime_Dev_rbt,
      c.dev_out                                                Num_dev_rbt,
      u.SYMBOLE                                                Lib_dev_rbt,
      --pk_ws_web_back.f_libgar(PK_QTTC.F_sel_numfor(s.numgar, s.numfor)) garantie,
      Decode (frm.typgar,1,'base',2,'option',null)             garantie,--RKO M0006648 23/07/2020
      to_char(c.autrb_out ,'999999990.90')                     Mt_autre_rbt_dev_reg,
      to_char(c.mtreel_out  ,'999999990.90')                   Rbt_ct_dev_rbt,
      ''                                                       Renv,
      decaismt.numdecaismt                                     Num_facture  ,
      to_char(pk_ws_web_back.F_TOT_SIN_PAYE(s.numassu,decaismt.numdecaismt,  decaismt.montant, affectation.montant,decaismt.modpmt, decompte.typbene) ,'999999990.90')   Rbt_total,
      decaismt.DATEDIT                                         decompte_edition,
      c.MTFRAIS_CT,
      c.MTREEL_CT,
      c.MTREMB_CT,
      c.AUTRB_CT,
      c.dev_ct,
      ct.SYMBOLE                                               LIB_DEV_RBT_CT,
      F_LBLE('QLTE',dest.QUALITE)                              civilite_dest,
      Decode(DECOMPTE.typbene,1,'Assuré',3,'Tiers',4,'Tiers',2,'Opérateur Tiers payant')  TYPBENE,
      pk_ws_web_back.f_reseau(s.numsin)                        reseau
    FROM
      indvs patient,
      indvs dest,
      indvs assup,
      sinistre_dev c,
      libformath,
      ACTE,
      decaismt,
      affectation,
      DECOMPTE,
      Monnaie u,
      Monnaie V,
      Monnaie ct,
      sinistre s,
      adhe_cntrt_membre acm,
      adhe_cntrt ac,
      porte_contrat p,
      contrat cntrt,
      frmls frm
    WHERE   decaismt.codope=1
    AND     patient.numindiv = c.numindiv
    AND s.edtdcpt=1
    AND F_CPTA_DATE_DECAISMT(decaismt.numdecaismt) <= sysdate  --ne pas afficher les lettres chèques non affectées
    AND libformath.nummath=s.nummath
    AND s.codfrais= ACTE.CODFRAIS
    AND s.numfor = frm.numfor
    AND c.numdec= decompte.NUMDEC
    AND affectation.numaffec = decompte.numdec
    AND affectation.numdecaismt = decaismt.NUMDECAISMT
    AND Decaismt.numdest = dest.NUMINDIV
    AND u.CODMON = c.dev_out
    AND v.CODMON = c.dev_in
    AND ct.CODMON = c.dev_ct
   AND acm.typadr = 0 -- Assuré principal de l'adhésion portée par le sinistre - pose problème pour les doubles adh conjoint rang 2 assuré 3236
     -- contrôle adhérent IRIS bien couvert à la date des soins avec accès 9 mois post radiation
    AND EXISTS( SELECT 1 FROM adhesion a WHERE a.idadhesion = acm.idadhesion
                                            AND a.numindiv   = acm.numindiv
                                            AND TRUNC(s.datsin) BETWEEN TRUNC(a.datapli) AND TRUNC(NVL(add_months(a.datper,9), SYSDATE)) -- resilié a moins de 9 mois
                                            -- AND datapli<>nvl(datper,datapli+1) MUR M0005925
                                            )
    AND s.numsin = c.numsin
    AND s.idadhesion = acm.idadhesion
    AND acm.idadhesion = ac.idadhesion
    AND assup.numindiv = acm.numindiv
    AND acm.numindiv = V_NUMINDIV
    AND s.numgar=cntrt.numgar
    AND p.numgar = cntrt.numgar_ref
    AND p.numporte=V_NUMPORTE
    AND trunc(decaismt.datpay) BETWEEN v_DEBUT AND v_FIN
    AND trunc(decaismt.datpay) BETWEEN ADD_MONTHS(SYSDATE,-24) AND SYSDATE
    --AND ROWNUM <= 443
    ORDER BY  Date_reglt desc,Num_decompte desc,Nom_prenom_benef asc, s.datsin desc ,c.numsin desc
    FETCH FIRST 443 ROWS ONLY;

    V_SEL_DECOMPTE C_SEL_DECOMPTE%ROWTYPE;
    CPT       NUMBER := 0;
    TB_DECOMPTE EXTR_TAB_DECOMPTE;
    V_COM_DECOMPTE VARCHAR2(700);
    TB_ADRESSE EXTR_ADRESSE_TR;
    l_DEBUT DATE;
    l_FIN DATE;

  BEGIN
    TB_ADRESSE := EXTR_ADRESSE_TR('','','','','','');
    TB_DECOMPTE := new EXTR_TAB_DECOMPTE(null);
    CPT := 1;
    IF P_ANNEE IS NOT NULL THEN
      l_DEBUT := e2d('01/01/'||TO_CHAR(P_ANNEE));
      l_FIN:= e2d('31/12/'||TO_CHAR(P_ANNEE));
    ELSE
      l_DEBUT := p_DEBUT;
      l_FIN := p_FIN;
    END IF;

    FOR CUR_VAR IN C_SEL_DECOMPTE(P_NUMINDIV,P_NUMPORTE, l_DEBUT,l_FIN) LOOP

      IF (CPT > 1) THEN
      TB_DECOMPTE.EXTEND(1);
      END IF;

      V_COM_DECOMPTE := F_COM_DECOMPTE(CUR_VAR.Num_decompte,CUR_VAR.Code_acte,CUR_VAR.Num_sinistre);

      TB_ADRESSE := F_ADRESSE_BY_NUMINDIV(CUR_VAR.Num_dest_reglt);


      TB_DECOMPTE(CPT) := EXTR_DECOMPTE_TR( CUR_VAR.Num_decompte,
                                            CUR_VAR.Num_sinistre,
                                            CUR_VAR.Num_adherent,
                                            CUR_VAR.Num_assup,
                                            CUR_VAR.Nom_prenom_assup,
                                            CUR_VAR.Num_benef,
                                            CUR_VAR.Nom_prenom_benef,
                                            CUR_VAR.Num_dest_reglt,
                                            CUR_VAR.Nom_prenom_dest_reglt,
                                            TB_ADRESSE,
                                            CUR_VAR.Date_reglt,
                                            CUR_VAR.Bdx_payt,
                                            CUR_VAR.Code_acte,
                                            CUR_VAR.Lib_acte,
                                            CUR_VAR.Date_soins,
                                            CUR_VAR.Dev_soins,
                                            CUR_VAR.Lib_dev_soins,
                                            CUR_VAR.Frais_reels_dev_soins,
                                            CUR_VAR.Mt_rbtregime_Dev_rbt,
                                            CUR_VAR.Num_dev_rbt,
                                            CUR_VAR.Lib_dev_rbt,
                                            CUR_VAR.garantie,
                                            CUR_VAR.Mt_autre_rbt_dev_reg,
                                            CUR_VAR.Rbt_ct_dev_rbt,
                                            CUR_VAR.Renv,
                                            CUR_VAR.Num_facture,
                                            CUR_VAR.Regime_gar,
                                            CUR_VAR.Rbt_total,
                                            V_COM_DECOMPTE,
                                            CUR_VAR.decompte_edition,
                                            CUR_VAR.MTFRAIS_CT,
                                            CUR_VAR.MTREEL_CT,
                                            CUR_VAR.MTREMB_CT,
                                            CUR_VAR.AUTRB_CT,
                                            CUR_VAR.dev_ct,
                                            CUR_VAR.LIB_DEV_RBT_CT,
                                            CUR_VAR.civilite_dest,
                                            CUR_VAR.TYPBENE,
                                            CUR_VAR.reseau
                                            );
      CPT := CPT + 1;

    END LOOP;
    RETURN TB_DECOMPTE;
  EXCEPTION
       WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_DECOMPTE',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);
            RETURN TB_DECOMPTE;
  END F_DECOMPTE_V7;


  FUNCTION F_PIECE ( I_NUMINDIV INDIVIDU.NUMINDIV%TYPE, I_PARAMS IN EXTR_Q_PIECE) RETURN EXTR_TAB_PIECE IS

    CURSOR C_PIECE ( P_NUMINDIV INDIVIDU.NUMINDIV%TYPE, P_ENTITE SNTR_PREV.NOSIN%TYPE, P_CONTEXTE NUMBER) IS
    SELECT P.IDPIECE, P.CONTEXTE, P.ENTITE, P.NUMBENE,P.NOPIECE,P.DELAI, P.PERIOD,P.NBREL,
      P.BLOC, P.DATEENREG,P.DATEAVIS,P.DATERECEP,P.DATEREL,P.NUMINDIV_DEST,
      pk_libelle.f_lib('JUSTIF_'||CONTEXTE,P.NOPIECE) LIB_PIECE,
      pk_libelle.f_lib('CONT_PJ',P.CONTEXTE) LIB_CONTEXTE  ,
      F_NOM(P.NUMINDIV_DEST) NOMDEST,
      F_NOM(P.NUMBENE) NOMBENE,
      COMMENTAIRE COMMENTAIRE,
      NULL ETAT,NULL LIB_ETAT,
      NULL CANAL_DDE,
      decode(P.CONTEXTE, 20,E.numedit, 19,E.numedit,NULL) NUMEDIT,
      NULL idrappel
    FROM PIECES P
    LEFT OUTER JOIN envoi E ON  P.numenvoi = E.numenvoi  -- récuperation du numéro d'édition
    WHERE P.DATANNUL IS NULL --non annulée
    AND CONTEXTE IN (4,12,19,20)
    AND P.NUMINDIV_DEST = P_NUMINDIV
    AND P.ENTITE = NVL(I_PARAMS.ENTITE,P.ENTITE)--RKO EA PREV LOT4 COMPLT
    AND P.CONTEXTE =NVL(I_PARAMS.CONTEXTE,P.CONTEXTE)
    AND P.DATERECEP IS NULL --non déjà réceptionnée
    AND NOT EXISTS( SELECT clef FROM LIEN_GED WHERE clef =p.idpiece AND etat in (1,2) AND etendue= p.contexte)
    AND NVL(P.DATEREL,NVL(P.DATEAVIS,DATEENREG))  > add_months(sysdate,-12) -- datant de moins d'un an
    AND EXISTS (SELECT DISTINCT 1 FROM adhesion ad WHERE  ad.numindiv = p.numbene AND SYSDATE  BETWEEN DATAPLI AND NVL(DATPER, SYSDATE))
    AND p.DATEENREG < trunc(sysdate)
    AND NVL(p.nbrel,0) < 2  -- ne pas tenir compte des pieces pour courrier d’information sur les limites d’âge
    UNION
    SELECT P.IDPIECE, P.CONTEXTE, P.ENTITE, P.NUMBENE,P.NOPIECE,P.DELAI, P.PERIOD,P.NBREL,
      P.BLOC, P.DATEENREG,P.DATEAVIS,P.DATERECEP,P.DATEREL,P.NUMINDIV_DEST,
      pk_libelle.f_lib('JUSTIF_'||CONTEXTE,P.NOPIECE) LIB_PIECE,
      pk_libelle.f_lib('CONT_PJ',P.CONTEXTE) LIB_CONTEXTE  ,
      F_NOM(P.NUMINDIV_DEST) NOMDEST,
      F_NOM(P.NUMBENE) NOMBENE,
      COMMENTAIRE COMMENTAIRE,
      NULL ETAT,NULL LIB_ETAT,
      NULL CANAL_DDE,
      NULL NUMEDIT,
      NULL idrappel
    FROM PIECES P, /*repartition r ,*/ sntr_prev s,histo_sntr_prev histo
    WHERE P.DATANNUL IS NULL --non annulée
    AND P.CONTEXTE IN (15,17)
    --AND P.CONTEXTE =NVL(I_PARAMS.CONTEXTE,P.CONTEXTE)
    AND NVL(I_PARAMS.CONTEXTE,0)=17
    AND NVL(p.nbrel,0) < 3
    AND P.NUMBENE = P_NUMINDIV
    AND P.ENTITE = NVL(I_PARAMS.ENTITE,P.ENTITE)--RKO EA PREV LOT4 COMPLT
    AND NVL(P.DATEREL,NVL(P.DATEAVIS,DATEENREG))  > add_months(sysdate,-12) -- datant de moins d'un an
    AND (P.DATEAVIS IS NOT NULL OR (P.DATEAVIS IS NULL AND P.DATERECEP IS NOT NULL)) -- M0006729
    AND p.DATEENREG < trunc(sysdate)
    AND p.entite = s.nosin
    /*AND r.nosin = s.nosin
    AND r.idrepartition = p.idrepartition OR --RKO ET CGR ==> ABO 10/08 la jointure est problématique car des pièces sont déposées avec repartion non cochée
    AND r.valide='O'*/
    AND s.norisq = 4
    AND histo.nosin =s.nosin
    AND (histo.saisie,histo.debut) = (
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
        )
      GROUP BY h.debut
      )
    AND ((histo.etat=2 AND P.DATERECEP IS NOT NULL) OR histo.etat<>2)--M6766 dossier  fermé remonté si pièce recu
    UNION
    SELECT P.IDPIECE, P.CONTEXTE, P.ENTITE, P.NUMBENE,P.NOPIECE,P.DELAI, P.PERIOD,P.NBREL,
      P.BLOC, P.DATEENREG,P.DATEAVIS,P.DATERECEP,P.DATEREL,P.NUMINDIV_DEST,
      pk_libelle.f_lib('JUSTIF_'||CONTEXTE,P.NOPIECE) LIB_PIECE,
      pk_libelle.f_lib('CONT_PJ',P.CONTEXTE) LIB_CONTEXTE  ,
      F_NOM(P.NUMINDIV_DEST) NOMDEST,
      F_NOM(P.NUMBENE) NOMBENE,
      COMMENTAIRE COMMENTAIRE,
      NULL ETAT,NULL LIB_ETAT,
      NULL CANAL_DDE,
      NULL NUMEDIT,
      NULL idrappel
    FROM PIECES P, /*repartition r ,*/ sntr_prev s,histo_sntr_prev histo
    WHERE P.DATANNUL IS NULL --non annulée
    AND P.CONTEXTE IN (15,17)
    --AND P.CONTEXTE =NVL(I_PARAMS.CONTEXTE,P.CONTEXTE)
    AND NVL(I_PARAMS.CONTEXTE,0)=17
    AND NVL(p.nbrel,0) < 3
    AND P.NUMINDIV_DEST = P_NUMINDIV
    AND P.ENTITE = NVL(I_PARAMS.ENTITE,P.ENTITE)--RKO EA PREV LOT4 COMPLT
    AND P.DATERECEP IS NULL --non déjà réceptionnée
    AND NOT EXISTS( SELECT clef FROM LIEN_GED WHERE clef =p.idpiece AND etat in (1,2) AND etendue= p.contexte)
    AND NVL(P.DATEREL,NVL(P.DATEAVIS,DATEENREG))  > add_months(sysdate,-12) -- datant de moins d'un an
    AND P.DATEAVIS IS NOT NULL
    AND p.DATEENREG < trunc(sysdate)
    AND p.entite = s.nosin
    /*AND r.nosin = s.nosin
    AND r.idrepartition = p.idrepartition --RKO ET CGR
    AND r.valide='O'*/
    AND s.norisq = 4
    AND histo.nosin =s.nosin
    AND (histo.saisie,histo.debut) = (
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
        )
      GROUP BY h.debut
      )
    AND histo.etat<>2 --dossier non fermé
        ;

    CURSOR C_GED (p_idpiece pieces.idpiece%TYPE,p_contexte pieces.contexte%TYPE) IS
      SELECT IDDOC, NOMDOC
      FROM LIEN_GED
      WHERE CLEF = p_idpiece
      AND ETENDUE= p_contexte
      AND etat in (1,2)
      ORDER BY ETAT DESC;

    CPT       NUMBER := 0;
    TAB_PIECE EXTR_TAB_PIECE;
    loc_IDDOC         VARCHAR2(50);
    loc_NOMDOC       VARCHAR2(100);
    v_deb NUMBER;
    loc_fin DATE;
    loc_comm pieces.commentaire%TYPE;

  BEGIN

    TAB_PIECE := new EXTR_TAB_PIECE(null);
    CPT := 1;
    v_deb:=DBMS_UTILITY.GET_TIME;
    FOR REC_PIECE IN C_PIECE(I_NUMINDIV,I_PARAMS.ENTITE, I_PARAMS.CONTEXTE) LOOP

      IF (CPT > 1) THEN
        TAB_PIECE.EXTEND(1);
      END IF;
      --ABO 05/03/2020 Extranet prévoyance
      -- particularité on permet de remonter les pièces réceptionnées et on remonte le document justificatif collecté.

      loc_IDDOC:=NULL;
      loc_NOMDOC:=NULL;
      IF REC_PIECE.CONTEXTE = 17 AND REC_PIECE.NUMBENE = I_NUMINDIV THEN
        FOR R_GED IN C_GED (REC_PIECE.IDPIECE, REC_PIECE.contexte) LOOP
        --on prend la 1ère pièce valide unique contexte prév souscripteur
          loc_IDDOC :=R_GED.IDDOC;
          loc_NOMDOC := R_GED.NOMDOC;
          EXIT;
        END LOOP;
      END IF;
      --sur mesure pour dcpt iJ SS
      loc_comm:=NULL;
      IF REC_PIECE.CONTEXTE = 17 AND REC_PIECE.nopiece = 1 THEN
        SELECT MAX(fin) INTO loc_fin FROM arret WHERE NOSIN = REC_PIECE.ENTITE;
        IF loc_fin IS NOT NULL THEN
          --loc_comm := 'Date de fin de période : '||to_char (loc_fin,'dd/mm/yyyy') ||'.'||REC_PIECE.COMMENTAIRE;
          loc_comm := 'postérieurs au '||to_char (loc_fin,'dd/mm/yyyy') ||'.'||REC_PIECE.COMMENTAIRE; --RKO M0006564
        ELSE
          loc_comm :=REC_PIECE.COMMENTAIRE;
        END IF;
      ELSE loc_comm :=REC_PIECE.COMMENTAIRE;
      END IF;


      TAB_PIECE(CPT) := EXTR_PIECE_TR(REC_PIECE.CONTEXTE  ,
                                      REC_PIECE.LIB_CONTEXTE ,
                                      REC_PIECE.ENTITE   ,
                                      REC_PIECE.NUMBENE ,
                                      REC_PIECE.NOMBENE ,
                                      REC_PIECE.NUMINDIV_DEST ,
                                      REC_PIECE.NOMDEST ,
                                      REC_PIECE.NOPIECE  ,
                                      REC_PIECE.LIB_PIECE   ,
                                      REC_PIECE.DELAI   ,
                                      REC_PIECE.PERIOD   ,
                                      REC_PIECE.NBREL    ,
                                      REC_PIECE.BLOC   ,
                                      REC_PIECE.DATEENREG ,
                                      REC_PIECE.DATEAVIS  ,
                                      REC_PIECE.DATERECEP ,
                                      REC_PIECE.DATEREL,
                                      loc_comm,
                                      REC_PIECE.ETAT,
                                      REC_PIECE.LIB_ETAT,
                                      REC_PIECE.CANAL_DDE,
                                      REC_PIECE.NUMEDIT,
                                      loc_IDDOC,
                                      loc_NOMDOC,
                                      REC_PIECE.IDPIECE,
                                      REC_PIECE.idrappel
                                      );

      CPT :=CPT+1;
    END LOOP;

    RETURN TAB_PIECE;

    EXCEPTION
     WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_PIECE',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);
            RETURN TAB_PIECE;

  END F_PIECE;



  FUNCTION F_CARTETPE ( I_NUMINDIV INDIVIDU.NUMINDIV%TYPE) RETURN EXTR_TAB_CARTE_TPE IS
 CURSOR C_CARTE ( P_NUMINDIV INDIVIDU.NUMINDIV%TYPE) IS
      SELECT P.IDPORTE, R.DATE_TRANS CREATION ,P.NUMINDIV NUMPORTEUR, F_NOM( P.NUMINDIV) NOMPORTEUR
      FROM PORTE_ADHESION P, REMISE_EXTERNE R
      WHERE P.IDADHESION IN (SELECT IDADHESION FROM ADHE_CNTRT WHERE NUMADHE=P_NUMINDIV)
      AND P.NUMPORTE = 2
      AND P.TRANSMIS = 1
      AND R.NUMREMISE = P.NUMREMISE
      AND TO_NUMBER(TO_CHAR(P.DEBUT, 'YYYY')) BETWEEN TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) AND TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'))+1
      AND (P.IDPORTE IN (
        SELECT MAX(IDPORTE)
        FROM PORTE_ADHESION PA
        WHERE PA.NUMINDIV=P.NUMINDIV
        AND PA.IDADHESION =P.IDADHESION--RKO M0007174
        AND NUMPORTE =2
        AND TRANSMIS =1
        AND TO_NUMBER(TO_CHAR(PA.DEBUT, 'YYYY'))=TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')))
        OR P.IDPORTE IN (
        SELECT MAX(IDPORTE)
        FROM PORTE_ADHESION PA
        WHERE PA.NUMINDIV=P.NUMINDIV
        AND PA.IDADHESION =P.IDADHESION--RKO M0007174
        AND NUMPORTE =2
        AND TRANSMIS =1
        AND TO_NUMBER(TO_CHAR(PA.DEBUT, 'YYYY'))=TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'))+1)
        )
     ;

    CURSOR C_BENE_CARTE ( P_IDPORTE PORTE_ADHESION.IDPORTE%TYPE) IS
      SELECT BENE.NUMINDIV NUMBENE, F_NOM( BENE.NUMINDIV) NOMBENE, DEBUT, FIN
      FROM DEMANDE_TP_AD BENE
      WHERE BENE.IDPORTE = P_IDPORTE;


    CPT       NUMBER := 0;
    CPT2      NUMBER := 0;
    TAB_CARTE EXTR_TAB_CARTE_TPE;
    TAB_BENE EXTR_TAB_CARTE_BENE;

  BEGIN

    TAB_CARTE := new EXTR_TAB_CARTE_TPE(null);
    CPT := 1;

    FOR REC_CARTE IN C_CARTE(I_NUMINDIV) LOOP

      --Bénéficiaire par porteur de carte
      TAB_BENE := new EXTR_TAB_CARTE_BENE(null);
      CPT2 := 1;
      FOR REC_BENE_CARTE IN C_BENE_CARTE(REC_CARTE.IDPORTE) LOOP

        IF (CPT2 > 1) THEN
          TAB_BENE.EXTEND(1);
        END IF;

        TAB_BENE(CPT2) := EXTR_CARTE_BENE_TR(REC_BENE_CARTE.NUMBENE,
                                            REC_BENE_CARTE.NOMBENE,
                                            REC_BENE_CARTE.DEBUT,
                                            REC_BENE_CARTE.FIN);
        CPT2 :=CPT2+1;
      END LOOP;

      --Carte de TPE par porteur de carte
      IF (CPT > 1) THEN
        TAB_CARTE.EXTEND(1);
      END IF;

      TAB_CARTE(CPT) := EXTR_CARTE_TR( REC_CARTE.NUMPORTEUR,
                                       REC_CARTE.NOMPORTEUR,
                                       REC_CARTE.CREATION,
                                       TAB_BENE);
      CPT :=CPT+1;


    END LOOP;


    RETURN TAB_CARTE;

    EXCEPTION
     WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_CARTETPE',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);
            RETURN TAB_CARTE;
  END F_CARTETPE;


  /******************************************************************/
  FUNCTION F_ADRESSE_BY_NUMINDIV(
           P_NUMINDIV INDIVIDU.NUMINDIV%TYPE
  )RETURN EXTR_ADRESSE_TR IS
   loc_T_adresse EXTR_ADRESSE_TR;
   loc_idadresse pers_adresse.idadresse%TYPE;
   loc_codpays NUMBER;
  BEGIN

    loc_T_adresse:=new  EXTR_ADRESSE_TR(NULL,NULL,NULL,NULL,NULL,NULL);
    SELECT PK_PERSONNE.F_IDADRESSE(P_NUMINDIV) INTO loc_idadresse FROM DUAL;


    pk_ws_web_back.f_adresse (loc_idadresse,P_NUMINDIV,0,30,loc_T_adresse.adresse1,
                             loc_T_adresse.adresse2,loc_T_adresse.adresse3,loc_T_adresse.codpos,loc_T_adresse.ville,loc_codpays);
    IF loc_codpays IS NOT NULL THEN
      loc_T_adresse.pays:=Upper( pk_libelle.f_lib('PAYS', loc_codpays));
    END IF;

    RETURN loc_T_adresse;
  END F_ADRESSE_BY_NUMINDIV;

  PROCEDURE f_adresse (
        a_idadresse     in Number,
        --a_indice     in Number,
        a_numindiv     in Number    Default 0,
        a_force     in Number    Default 0,
        a_codope        in Number       Default 0,
        adresse1 OUT VARCHAR2,
        adresse2 OUT VARCHAR2,
        adresse3 OUT VARCHAR2,
        codpos   OUT VARCHAR2,
        ville    OUT VARCHAR2,
        pays    OUT NUMBER
  )IS
    i        Binary_integer;
    ville_tmp varchar2(33);

  Cursor Fetch_adresse Is
      Select    individu.codtitre,
          pers_adresse.no_voie,
          pers_adresse.bis,
          pers_adresse.type_voie,
          pers_adresse.nom_voie,
          pers_adresse.comp_adresse,
          pers_adresse.adresse_2,
          Decode(pers_adresse.codpos, '99999', '',
              pers_adresse.codpos)    codpos,
          pers_adresse.ville,
          pers_adresse.flag_cedex,
          pers_adresse.no_cedex,
          pers_adresse.codpays,
          pers_adresse.type    type_adresse,
                  individu.type
      From     pers_adresse,
          individu
      Where    pers_adresse.idadresse = a_idadresse
      and    individu.numindiv = pers_adresse.numindiv + 0;
  --
  c_indiv        Individu%Rowtype;
  --
  CURSOR C_Ope_gest IS
                 Select  ope_gest
                 From    Ope_gest
                 Where   type_crrr = a_codope;
  --
  Rec_C_ope_gest C_ope_gest%Rowtype;
  --
  CURSOR C_interlocuteur(P_ope_gest Number) IS
                 Select interlocuteur
                 From   Interlocuteur
                 Where  numindiv  =  a_numindiv
                  And    valide    =  'O'
                 And    ope_crrr  =  P_ope_gest;
  --
  Rec_C_interlocuteur  C_interlocuteur%Rowtype;
  --
  CURSOR C_individu IS
                   Select type
                   From   Individu
                   Where  numindiv = a_numindiv;

  Rec_c_individu C_individu%Rowtype;
  --
  Cursor C_international IS
      Select    adr1,
          adr2,
          adr3,
          adr4,
          adr5
      From    adr_internationale
      Where    idadresse = a_idadresse;
  Rec_C_international    C_international%RowType;
  --
  c_adresse    Fetch_adresse%Rowtype;
  --
  --  Si il n'existe pas de courrier specifique , on prend
  --  par defaut le type courrier =0 pour rechercher l'interlocuteur
  --
  CST_loc_ope_crr CONSTANT Number(1) DEFAULT 0;
  --
  loc_nom_interlocuteur             Varchar2(32);
  --loc_charge_tableau                BOOLEAN;
    Type Adresse is table of Varchar2(33) index by Binary_integer;
    T_adresse    Adresse;
  --
  Begin


     -- 28/01/2005 David For i In 1 .. 6 Loop
     For i In 1 .. 7 Loop
       t_adresse( i ) := Null;
     End loop;

     i := 1;

      --
      loc_nom_interlocuteur := Null;
      --
      -- Recherche type personne : Morale ou Physique
      OPEN C_individu;
      FETCH C_individu INTO Rec_c_individu;
      CLOSE C_individu;
      --
     /* IF Rec_c_individu.type = 2 THEN  -- Personne Morale
         IF a_codope <> 0 THEN         -- Si codope different de valeur par defaut
            OPEN C_ope_gest;           -- Alors on recherche l'interlocuteur
            FETCH C_ope_gest INTO REC_c_ope_gest;
            IF C_ope_gest%FOUND THEN
               OPEN C_interlocuteur(Rec_c_ope_gest.ope_gest);
               FETCH C_interlocuteur INTO Rec_c_interlocuteur;
               IF  C_interlocuteur%FOUND THEN   -- Si il existe un interlocuteur
                 -- Recherche du nom de l'interlocuteur
                 loc_nom_interlocuteur := f_nom(a_numindiv =>
                            Rec_c_interlocuteur.interlocuteur);
               ELSE                    -- Interlocuteur non trouve avec ope_gest
                 CLOSE C_interlocuteur;
                 -- Recherche du nom de l'interlocuteur avec ope_crr=0
                 OPEN C_interlocuteur(CST_loc_ope_crr);
                 FETCH C_interlocuteur INTO Rec_c_interlocuteur;
                 IF C_interlocuteur%FOUND THEN
                   loc_nom_interlocuteur := f_nom(a_numindiv =>
                          Rec_c_interlocuteur.interlocuteur);
                 END IF;
               END IF;
               CLOSE C_interlocuteur;
            ELSE
               -- Recherche du nom de l'interlocuteur avec ope_crr=0
               OPEN C_interlocuteur(CST_loc_ope_crr);
               FETCH C_interlocuteur INTO Rec_c_interlocuteur;
               IF C_interlocuteur%FOUND THEN
                 loc_nom_interlocuteur := f_nom(a_numindiv =>
                            Rec_c_interlocuteur.interlocuteur);
               END IF;
               CLOSE C_interlocuteur;
            END IF;
            CLOSE C_ope_gest;
         ELSE   -- Codope = 0
            -- Recherche du nom de l'interlocuteur avec ope_crr=0
            OPEN C_interlocuteur(CST_loc_ope_crr);
            FETCH C_interlocuteur INTO Rec_c_interlocuteur;
            IF C_interlocuteur%FOUND THEN
              loc_nom_interlocuteur := f_nom(a_numindiv =>
                          Rec_c_interlocuteur.interlocuteur);
            END IF;
            CLOSE C_interlocuteur;
         END IF;
      END IF;*/
  --
  -- Fin gestion interlocuteur
  -- Gestion des adresses normalisees ou internationales
  --
   For c_adresse in Fetch_adresse Loop
      --
          IF loc_nom_interlocuteur Is Not Null THEN
              t_adresse(i) := loc_nom_interlocuteur;
              i := i+1;
          END IF;
      --
      If ( c_adresse.type_adresse != 3 ) then        -- Normalisee
          If ( c_adresse.comp_adresse is Not Null ) then
              t_adresse(i) := c_adresse.comp_adresse;
              i := i + 1;
          ElsIf ( c_adresse.codtitre is Not Null ) then
              t_adresse(i) :=
              pk_libelle.f_lib('TITRE', c_adresse.codtitre);
              i := i + 1;
          End if;
          --
          t_adresse(i) := Substr(
                      pk_personne.f_recompose(
                          c_adresse.no_voie,
                          c_adresse.bis,
                          c_adresse.type_voie,
                          c_adresse.nom_voie, 32 ),1, 32 );
          i := i + 1;
        --
        -- Modification 06/11/00 pour gérer 5 lignes adresses
        --
        IF C_adresse.adresse_2 Is Not Null THEN
          t_adresse(i) := c_adresse.adresse_2;
          i := i + 1;
        END IF;
              --

     -- t_adresse(i) := f_concatene(c_adresse.codpos, c_adresse.ville);

      codpos:=c_adresse.codpos;
      ville :=c_adresse.ville;

      If ( c_adresse.flag_cedex = 'O' ) then
              If ( Instr(c_adresse.ville, 'CEDEX') = 0 ) then
                 t_adresse(i) :=Substr(f_concatene(t_adresse(i), 'CEDEX'),    1, 32);
              End if;
              t_adresse(i) := Substr(f_concatene(t_adresse(i),  c_adresse.no_cedex), 1, 32);
          End if;
          i := i + 1;
          --
      Else        -- Adresse internationale
          Open C_international;
          Fetch C_international Into Rec_C_international;

          --David 04/02/2005 Contitionner affichage des adresses
      If ( Rec_C_international.adr1 Is Not null ) then
        t_adresse(i) := Substr(Rec_C_international.adr1,1,32);
        i := i + 1;
      End If;

      If ( Rec_C_international.adr2 Is Not null ) then
        t_adresse(i) := Substr(Rec_C_international.adr2,1,32);
        i := i + 1;
      End If;

      If ( Rec_C_international.adr3 Is Not null ) then
          t_adresse(i) := Substr(Rec_C_international.adr3,1,32);
          i := i + 1;
       End If;

      If ( Rec_C_international.adr4 Is Not null) then
        codpos :=Substr(Rec_C_international.adr4,1,32);
      END IF;
      IF( Rec_C_international.adr5 Is Not null  ) then
        ville := Substr(Rec_C_international.adr5,1,32);
      End If;
      /*
      If ( Rec_C_international.adr5 Is Not null ) then
      t_adresse(i) := Substr(Rec_C_international.adr5,1,32);
      i := i + 1;
      End If;
      */
      End If;
      --
      pays :=c_adresse.codpays;

      --
  End Loop;

    adresse1:=Substr( t_adresse(1 ), 1, 32) ;
    adresse2:=Substr( t_adresse(2 ), 1, 32) ;
    adresse3:=Substr( t_adresse(3 ), 1, 32) ;
    ville_tmp := ville;

    --SDA Mantis 5175
    IF (Instr(adresse2, 'CEDEX') > 0) THEN
        ville := Substr(f_concatene(ville_tmp,adresse2), 1, 32);
        Adresse2 := null;
     END IF;
     IF (Instr(adresse3, 'CEDEX') > 0) THEN
       ville := Substr(f_concatene(ville_tmp,adresse3), 1, 32);
       Adresse3 := null;
     END IF;

  EXCEPTION
      WHEN OTHERS THEN
            PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'f_adresse',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => substr(sqlerrm,1,132),
            I_idligne  => 2);

  --Return( Substr( t_adresse(a_indice ), 1, 32) );
  End f_adresse;

  /******************************************************************/
  Function F_COM_DECOMPTE(
           i_NUMDEC IN COURRIER.NUMDEC%TYPE,
           i_CODFRAIS IN COURRIER.CODFRAIS%TYPE,
           i_NUMSIN IN COURRIER.NUMSIN%TYPE
  )
  RETURN COURRIER.TEXT%TYPE
  IS
    V_TEMP_TEXT VARCHAR2(700);

    CURSOR C_CRRR IS

     SELECT TEXT  FROM COURRIER
     WHERE COURRIER.NUMDEC = i_NUMDEC
     AND COURRIER.CODFRAIS = i_CODFRAIS
     AND COURRIER.NUMSIN = i_NUMSIN;
  BEGIN

    FOR R_CRRR IN C_CRRR LOOP
      V_TEMP_TEXT:=V_TEMP_TEXT||'<br/>'||TRIM(R_CRRR.TEXT );
    END LOOP;

     RETURN substr(V_TEMP_TEXT,6);

  EXCEPTION

   WHEN OTHERs THEN
     return NULL;

  END F_COM_DECOMPTE;
  /******************************************************************/
  PROCEDURE P_INFO_QUERABLE(
    I_NUMQUERABLE           IN CONTRAT_REF.NUMQUERABLe%TYPE,
    O_CIV_NUMQUERABLE       OUT LIBELLE.LIBELLE%TYPE,
    O_NOM_NUMQUERABLE       OUT INDIVIDU.NOM%TYPE,
    O_PRENOM_NUMQUERABLE    OUT INDIVIDU.PRENOM%TYPE
  ) IS

      CURSOR C_INFO_QUERABLE(V_NUMINDIV INDIVIDU.NUMINDIV%TYPE) IS
       SELECT F_LBLE('QLTE',INDIVIDU.QUALITE) AS LIB_QUALITE,
              INDIVIDU.NOM,
              INDIVIDU.PRENOM
       INTO O_CIV_NUMQUERABLE,O_NOM_NUMQUERABLE,O_PRENOM_NUMQUERABLE
       FROM INDIVIDU
       WHERE NUMINDIV = V_NUMINDIV;

       V_INFO_QUERABLE C_INFO_QUERABLE%ROWTYPE;

  BEGIN
       FOR V_INFO_QUERABLE IN C_INFO_QUERABLE(I_NUMQUERABLE) LOOP
            O_CIV_NUMQUERABLE := V_INFO_QUERABLE.LIB_QUALITE;
            O_NOM_NUMQUERABLE := V_INFO_QUERABLE.NOM;
            O_PRENOM_NUMQUERABLE := V_INFO_QUERABLE.PRENOM;
       END LOOP;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     O_CIV_NUMQUERABLE := null;
     O_NOM_NUMQUERABLE := null;
     O_PRENOM_NUMQUERABLE := null;
   WHEN OTHERs THEN
     O_CIV_NUMQUERABLE := null;
     O_NOM_NUMQUERABLE := null;
     O_PRENOM_NUMQUERABLE := null;
  END P_INFO_QUERABLE;

  /******************************************************************/
  Function F_EMETTEUR(
           i_numorg in PARPORTE.NUMORG%TYPE

  ) RETURN PARPORTE.NUMEMETTEUR%TYPE
  IS
    v_numemetteur PARPORTE.NUMEMETTEUR%TYPE;
  BEGIN

       SELECT NUMEMETTEUR into v_numemetteur
       FROM PARPORTE
       WHERE NUMORG = i_numorg
       AND OUVERTE = 1;

       RETURN v_numemetteur;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN '0';
   WHEN OTHERs THEN
        RETURN '0';
  END F_EMETTEUR;
  /******************************************************************/
  FUNCTION F_GET_CIRCUITS_INFO(I_NUMINDIV INDIVIDU.NUMINDIV%TYPE)
  RETURN  EXTR_TAB_CIRCUIT_INFO

  IS
  tab_circuits EXTR_TAB_CIRCUIT_INFO;

  CURSOR c_circuits_info is
    SELECT type_crrr, moyen_info
    FROM COURRIER_INFO
    WHERE NUMINDIV = I_NUMINDIV
      AND type_crrr IN (28,50,51,52,53);    -- décompte soins de santé, newsletter et carte TP, compte extranet
  rec_circuit_info  c_circuits_info%ROWTYPE;
  i NUMBER(3):=1;

    BEGIN
    tab_circuits := new EXTR_TAB_CIRCUIT_INFO(null);
      FOR       rec_circuit_info  IN  c_circuits_info LOOP
        IF i > 1 THEN tab_circuits.EXTEND(1); END IF;
        tab_circuits(i):= new EXTR_CIRCUIT_INFO(
                              rec_circuit_info.type_crrr,
                              f_lble('CIRC_TYPE',rec_circuit_info.type_crrr) ,
                              rec_circuit_info.moyen_info,
                              f_lble('CIRC_INFO', rec_circuit_info.moyen_info)
                              );
        i:=i+1;

      END lOOP;

  return tab_circuits;
  END  F_GET_CIRCUITS_INFO;

  /******************************************************************/
  FUNCTION F_GET_PRCH(I_NUMASSU INDIVIDU.NUMINDIV%TYPE, I_DATE_DEBUT DATE, I_DATE_FIN DATE)
  RETURN  EXTR_TAB_PRCH
  IS
  tab_prch EXTR_TAB_PRCH;
  l_prch EXTR_PRCH;
  i NUMBER :=1;
  l_numedit file_edition.numedit%type;
  l_porte number;
  l_ref_pec RAPPEL.REFERENCE%TYPE;

  CURSOR c_prch IS
    SELECT
      p.numpc,
      p.NUMASSU num_adhe,
      assu.NOM nom_adhe,
      assu.prenom prenom_adhe,
      p.numindiv num_indiv,
      indiv.NOM nom_indiv,
      indiv.prenom prenom_indiv,
      p.numtiers num_ps,
      t.NOM nom_ps,
      t.NUMDPT||t.NUMACTV||t.NUMINSER/*||t.NUMCLE*/ NNI,
      p.DATEHOSPI,
      p.DATECREAT,
      null NUMEDIT,
      p.DATEDIT,
      null refpec, --issue de la corbeille
      null porte
    FROM  pricharge p,
          tiers t,
          individu assu,
          individu indiv
    WHERE p.NUMASSU =  I_NUMASSU
      AND p.NUMTIERS= t.NUMINDIV
      AND p.NUMASSU = assu.numindiv
      AND p.NUMINDIV = indiv.NUMINDIV
      AND p.DATEHOSPI > add_months(sysdate,-3)  -- par defaut on prend sur une année glissante
      --AND p.DATEHOSPI > sysdate-5
      AND p.TYPEDEST IN (1, 3)
    --  AND EXISTS(SELECT 1 FROM courrier_info WHERE type_crrr = 28 AND moyen_info = 2 AND courrier_info.numindiv = p.numassu)
      AND p.DATECREAT < trunc(sysdate) --pour j-1
     ORDER BY numpc DESC
     ;
    rec_prch c_prch%ROWTYPE;

  BEGIN
    tab_prch:= new EXTR_TAB_PRCH(null);

    FOR  rec_prch IN c_prch LOOP

        BEGIN --RECUPERATION du POTENTIEL NUMEDIT
              SELECT max(numedit) INTO l_numedit
              FROM envoi e
              WHERE e.NUMINDIV_DEST = rec_prch.num_adhe
              AND e.clef = rec_prch.numpc
              AND (e.invalide IS NULL OR e.invalide <> 'O')
              ;
        EXCEPTION
          WHEN OTHERS THEN
            l_numedit:= null;
        END;


        --TODO RECHERHCHER LA REF DU RAPPEL ET RECHERCHER LA PORTE   (COMMENT FAIRE?)
          BEGIN --RECUPERATION du POTENTIEL NUMEDIT
              SELECT reference , 25
              INTO   l_ref_pec , l_porte
              FROM    rappel
              WHERE contexte = 6
              AND   entite = rec_prch.numpc ;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_ref_pec := null;
        END;



          IF l_numedit IS NOT NULL THEN
          IF i > 1  THEN   -- si le numedit est nul c'est qu'elle ne dois pas etre remontée.
            tab_prch.EXTEND(1);
            END IF;
          tab_prch(i) :=  new EXTR_PRCH( rec_prch.Numpc
                                        ,rec_prch.Num_adhe
                                        ,rec_prch.Nom_adhe
                                        ,rec_prch.Prenom_adhe
                                        ,rec_prch.Num_indiv
                                        ,rec_prch.Nom_indiv
                                        ,rec_prch.Prenom_indiv
                                        ,rec_prch.Num_PS
                                        ,rec_prch.Nom_PS
                                        ,rec_prch.NNI
                                        ,rec_prch.Datehospi
                                        ,rec_prch.Datecreat
                                        ,l_numedit
                                        ,rec_prch.Datedit
                                        ,l_ref_pec
                                        ,l_Porte
                                          );

          i:=i+1;

        END IF;
    END LOOP;


  return tab_prch;
  END F_GET_PRCH;



FUNCTION F_GET_DEVIS(I_NUMASSU INDIVIDU.NUMINDIV%TYPE, I_DATE_DEBUT DATE, I_DATE_FIN DATE)
  RETURN  EXTR_TAB_DEVIS_SANTE
  IS
  tab_devis EXTR_TAB_DEVIS_SANTE;
  l_numedit file_edition.numedit%type;
  l_date_edit DATE;
  l_valide  number(30);
  i NUMBER :=1;
  l_nbedit  number(3) ;
  l_nbdevis  number(3) ;

  CURSOR c_devis IS
    SELECT
           ds.num_dossier                                IDDOSSIER
          ,DECODE (type_doss,5,2,4,3)                    ETENDUE -- devis dossier
          , null                                         REF_DOSSIER -- a renseigner a posteriorie
          ,ds.NAT_DOSS                                   NATURE
          ,f_lble('NAT_DOSS',ds.NAT_DOSS)                LIB_NATURE
          ,ds.RESEAU                                     RESEAU
          ,NVL(f_lble('RESEAU',ds.RESEAU),'Hors réseau') LIB_RESEAU
          ,ds.numindiv                                   NUMINDIV
          ,i.nom                                         NOM_PATIENT
          ,i.prenom                                      PRENOM_PATIENT
          ,ds.numassu                                    NUM_ADHE
          ,assu.nom                                      NOM_ADHE
          ,assu.prenom                                   PRENOM_ADHE
          ,ds.numtiers                                   NUMPS
          ,t.nom                                         NOM_PS
          ,ds.numbene                                    NUMDEST
          ,ds.creation                                   DATE_CREATION
          ,null                                          NUMEDIT  -- a renseigner a posteriori
          ,ds.DATE_FACT_PEC                              DATE_EDIT -- a verifier
          ,null                                          PORTE
    FROM DOSSIER_SANTE ds
      INNER JOIN individu i     ON ds.NUMINDIV = i.NUMINDIV
      INNER JOIN individu assu  ON ds.NUMASSU = assu.NUMINDIV
      LEFT OUTER JOIN tiers t   ON ds.NUMTIERS = t.NUMINDIV -- le ps n'est pas forcement créé
    WHERE ds.NUMASSU = I_NUMASSU --301206
      AND TYPE_DOSS =5 --  devis uniquement (demande MBO 01/06/2017)
      AND ds.creation BETWEEN add_months(sysdate,-3) and sysdate
    --  AND ds.creation > e2d('05/06/2017')
      AND ds.creation < trunc(sysdate) --pour j-1
    --date validation dans envoi
     -- AND EXISTS(SELECT 1 FROM courrier_info WHERE type_crrr = 28 AND moyen_info = 2 AND courrier_info.numindiv = ds.numassu)
      AND EXISTS (SELECT DISTINCT 1 FROM adhesion ad WHERE  ad.numindiv = ds.Numindiv AND SYSDATE  BETWEEN DATAPLI AND NVL(DATPER, SYSDATE))
    UNION
    SELECT DISTINCT
        TO_CHAR(ds.iddevis_sante)                        IDDOSSIER--evite le multiligne a cause de devis_sante_detail
        ,1                                               ETENDUE -- devis simple
        ,null                                            REF_DOSSIER -- a renseigner a posteriorie
        ,null                                            NATURE
        ,null                                            LIB_NATURE
        ,null                                            RESEAU
        ,null                                            LIB_RESEAU
        ,dst.Numindiv                                    NUMINDIV
        ,i.nom                                           NOM_PATIENT
        ,i.prenom                                        PRENOM_PATIENT
        ,ds.numassu                                      NUM_ADHE
        ,assu.nom                                        NOM_ADHE
        ,assu.prenom                                     PRENOM_ADHE
        ,null                                            NUMPS
        ,null                                            NOM_PS
        ,dst.numbene                                     NUMDEST
        ,ds.datsai                                       DATE_CREATION
        ,null                                            NUMEDIT  -- a renseigner a posteriori
        ,null                                            DATE_EDIT
        ,null                                            PORTE
        FROM  DEVIS_SANTE ds, DEVIS_SANTE_DETAIL dst, INDiVIDU i, INDIVIDU assu , ENVOI
        WHERE ds.NUMASSU = I_NUMASSU
          AND ds.NUMASSU = assu.NUMINDIV
          AND dst.numindiv = i.numindiv
          AND ds.IDDEVIS_SANTE = dst.IDDEVIS_SANTE
          AND ds.numenvoi = envoi.numenvoi
          AND NVL(envoi.valide,'N')='O'
          AND ds.datsai BETWEEN add_months(sysdate,-3) and sysdate
         -- AND ds.datsai > e2d('05/06/2017')
          AND ds.datsai < trunc(sysdate) --pour j-1
         -- AND EXISTS(SELECT 1 FROM courrier_info WHERE type_crrr = 28 AND moyen_info = 2 AND courrier_info.numindiv = ds.numassu)
          AND EXISTS (SELECT DISTINCT 1 FROM adhesion ad WHERE  ad.numindiv = dst.Numindiv AND SYSDATE  BETWEEN DATAPLI AND NVL(DATPER, SYSDATE))   -- individu avec au moins une couverture.
    ORDER BY Iddossier DESC;
  rec_devis c_devis%ROWTYPE;

  BEGIN
    tab_devis := new EXTR_TAB_DEVIS_SANTE(null);
    l_nbdevis := 0 ;
    FOR rec_devis IN c_devis LOOP
        l_nbdevis := l_nbdevis + 1 ;
        -- on verifie pour chaque ligne si le devis a été edité.
        BEGIN--Récupération de du numedit

          -- devis dossier => PC07, Prise en Charge PC06,  devis simple = GD13
          SELECT max(f.numedit), max(f.date_execute) , count(*)
            INTO l_numedit, l_date_edit, l_nbedit
            from param_dmnde p ,file_edition f
            WHERE f.numdmnde = To_CHAR(p.numdmnde)
            AND DECODE(rec_devis.etendue, 1, valdeb4, valdeb1) = To_CHAR(rec_devis.IDDOSSIER)   -- les valdeb contenant le numéro de dossier varient entre les éditions
            AND NVL(valdeb3,TO_CHAR(rec_devis.num_adhe)) = TO_CHAR(rec_devis.num_adhe)
            AND editid like DECODE(rec_devis.etendue,1,'GD13%',2,'PC07%',3,'PC06%')
            AND f.execute IS NOT NULL
            AND status = 2    -- status édité uniquement
             ;
          SELECT numedit
             INTO l_valide
             FROM envoi
             WHERE numedit = TO_NUMBER(l_numedit)
             AND valide = 'O';

        EXCEPTION -- si aucun numedit trouvé, on ne rajoute pas le devis dans le flux  de reponse
            WHEN NO_DATA_FOUND THEN
            PK_TRACE.P_INS_journal_adm ( 'F_GET_DEVIS',sid,1,'assure ' || I_NUMASSU || ' nbre devis trouvé ' || l_nbedit || ' WHEN NO_DATA_FOUND THEN' , SYSDATE,5);
            l_numedit:=null;
            --- MUR M0006815
            when others then
            PK_TRACE.P_INS_journal_adm ( 'F_GET_DEVIS',sid,1,'assure ' || I_NUMASSU || ' nbre devis trouvé ' || l_nbedit || ' ' || SUBSTR(SQLERRM (SQLCODE), 1, 115), SYSDATE,5);
            l_numedit:=null;
        END;
                -- TODO recherche la reference RAPPEL
                IF l_numedit IS NOT NULL THEN
                   IF i > 1 THEN tab_devis.EXTEND(1); END IF;
                tab_devis(i) := new EXTR_DEVIS_SANTE( rec_devis.IDDOSSIER
                                                      ,rec_devis.ETENDUE
                                                      ,rec_devis.REF_DOSSIER
                                                      ,rec_devis.NATURE
                                                      ,rec_devis.LIB_NATURE
                                                      ,rec_devis.RESEAU
                                                      ,rec_devis.LIB_RESEAU
                                                      ,rec_devis.NUMINDIV
                                                      ,rec_devis.NOM_PATIENT
                                                      ,rec_devis.PRENOM_PATIENT
                                                      ,rec_devis.NUM_ADHE
                                                      ,rec_devis.NOM_ADHE
                                                      ,rec_devis.PRENOM_ADHE
                                                      ,rec_devis.NUMPS
                                                      ,rec_devis.NOM_PS
                                                      ,rec_devis.NUMDEST
                                                      ,rec_devis.DATE_CREATION
                                                      ,L_NUMEDIT
                                                      ,L_date_edit
                                                      ,rec_devis.PORTE );
                    i:=i+1;
                END IF;
     END LOOP;
     if l_nbdevis = 0 then
       PK_TRACE.P_INS_journal_adm ( 'F_GET_DEVIS',sid,1,'assure ' || I_NUMASSU || ' aucun devis trouvé ' , SYSDATE,5);
      end if ;
       return tab_devis;

  END F_GET_DEVIS;

/*********************Retourne les services ouverts pour un numgar donné, en se basant sur le paramétrage produit*********************************************/
FUNCTION F_GET_SERVICES(i_NUMGAR contrat_ref.numgar%TYPE)
RETURN  EXTR_TAB_SERVICE
IS
  l_service     EXTR_SERVICE;
  l_tab_service EXTR_TAB_SERVICE;
  TextExplicatif    Varchar2(500):= null;
  l_Telephone       Varchar2(60):= null;
  l_site_web        Varchar2(60):= null;
  l_email           Varchar2(60):= null;
  l_numinterlocuteur individu.numindiv%type;
  l_numprod  contrat_ref.numprod%type;
  l_numassureur individu.numindiv%type;
  l_nomassureur individu.nom%type;

  loc_val_var VAL_VARIABLE%ROWTYPE;
  cursor c_services is
  SELECT dv.idvariable, dv.NOM_VARIABLE,lb.libelle, lb2.libelle libelle_contrat
      FROM  def_variable dv
      INNER JOIN LIBELLE_BIS  lb      ON  dv.NOM_VARIABLE = lb.CODE
                                      AND lb.mnemo='SERVICES'
      LEFT OUTER JOIN LIBELLE_BIS lb2 ON  dv.NOM_VARIABLE = lb2.CODE
                                      AND lb2.mnemo='SERVICEC'
     WHERE dv.NOM_VARIABLE IN ('TELECONSUL','ITELIS','EASYSANTE','HOSPIWAY','MESDOCTEUR','ASSISTANCE') --M0007236 ajout du service ASSISTANCE
     ;

  cursor c_services_porte is
  select * from porte_contrat
    where numporte in ( 22)
    and   numgar = i_NUMGAR;


BEGIN
  l_tab_service := new EXTR_TAB_SERVICE(null);
   -- récupération des informations de l'assureur et le produit

  SELECT numprod,pers_organisme.numorg, indvs.nom
    INTO l_numprod, l_numassureur, l_nomassureur
    FROM contrat_ref, pers_organisme, indvs
    WHERE pers_organisme.ROLE = 2 AND indvs.numindiv = pers_organisme.numindiv
    AND contrat_ref.numorg = pers_organisme.numorg
    AND numgar = i_numgar;


  FOR r_service IN c_services LOOP
   l_numinterlocuteur := F_VAL_VAR_ALL(l_numprod,r_service.idvariable,sysdate); -- recupération de l'interlocuteur du service
   BEGIN    -- Si une variable est positonnée au niveau contrat alors on regarde si elle est valorisé
   select * into loc_val_var from val_variable
     WHERE etendue = 2
      AND clef = i_numgar
      AND IDVARIABLE = F_FIND_VAR(r_service.libelle_contrat)
      AND  sysdate between debut and nvl(fin,sysdate)
      AND VALIDE = 'O';
      l_numinterlocuteur:=  loc_val_var.valeur; -- on valorise avec l'id de l'interlocuteur paramétré sur le contrat , si la valeur sur le contrat est vide alors le service est consiédré comme désactivé
   EXCEPTION WHEN NO_DATA_FOUND THEN
    null;
   END;
    IF  l_numinterlocuteur IS NOT NULL   AND l_numinterlocuteur <> 0 THEN
      l_service   :=  null; -- mise a null du service
      l_Telephone := NVL(f_coordonne_contact(l_numinterlocuteur,1,2),f_coordonne_contact(l_numinterlocuteur,1,1)) ;
      l_email     := NVL(f_coordonne_contact(l_numinterlocuteur,4,2),f_coordonne_contact(l_numinterlocuteur,4,1)) ;
      l_site_web  := NVL(f_coordonne_contact(l_numinterlocuteur,5,2),f_coordonne_contact(l_numinterlocuteur,5,1)) ;
      l_service := new EXTR_SERVICE( r_service.idvariable, --IDService       NUMBER(3),
                                     r_service.libelle,    --LibelleService  Varchar2(50),
                                     null,                 --TextExplicatif  Varchar2(500)
                                     l_Telephone,          --Telephone       Varchar2(60),
                                     l_site_web,           --site_web        Varchar2(60),
                                     l_email,               --email           Varchar2(60)
                                     l_numassureur,
                                     l_nomassureur
                                    )  ;
      IF l_tab_service(l_tab_service.count) IS NOT NULL THEN
         l_tab_service.extend(1);
      END IF;
      l_tab_service(l_tab_service.count) :=  l_service;
    END IF;
  END LOOP;

  IF l_tab_service(l_tab_service.count) IS NOT NULL THEN
    -- Gestion d'itelis qui est porté par la porte 22
    FOR r_service_porte IN C_services_porte LOOP
         l_service := new EXTR_SERVICE( r_service_porte.numporte, --IDService       NUMBER(3),
                                       f_lble('PORTE', r_service_porte.numporte),    --LibelleService  Varchar2(50),
                                       null,                 --TextExplicatif  Varchar2(500)
                                       null,          --Telephone       Varchar2(60),
                                       null,           --site_web        Varchar2(60),
                                       null,               --email           Varchar2(60)
                                       l_numassureur,
                                       l_nomassureur
                                      )  ;
        IF l_tab_service(l_tab_service.count) IS NOT NULL THEN
           l_tab_service.extend(1);
        END IF;
        l_tab_service(l_tab_service.count) :=  l_service;
    END LOOP;
  END IF;
  RETURN  l_tab_service;
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN l_tab_service;
END F_GET_SERVICES;
/********************************************************************************************/

FUNCTION F_GET_DEMANDES(I_NUMINDIV INDIVIDU.numindiv%TYPE,
                        i_idrappel rappel.idrappel%type,
                        i_debut date ,
                        i_fin date ,
                        i_numBene rappel.numbene%type,
                        i_etat rappel.etat%type )
  RETURN  EXTR_TAB_DEMANDE
  IS
  l_demande     EXTR_demande;
  loc_document EXTR_DOCUMENT;
  loc_tab_document EXT_TAB_DOCUMENT;
  l_tab_demande EXTR_TAB_DEMANDE;
  loc_val_var VAL_VARIABLE%ROWTYPE;
  loc_etat_trancode varchar2(30);


  CURSOR c_demandes IS
    SELECT *
    FROM RAPPEL r
    WHERE r.NUMASSU = I_numindiv
    AND r.idrappel = nvl(i_idrappel, r.idrappel)
    AND r.CREATION BETWEEN NVL(i_debut,r.CREATION) AND COALESCE(i_fin, i_debut, r.CREATION)
    AND r.NUMBENE = nvl(i_numbene, r.numbene)
    AND r.etat = nvl(i_etat, r.etat)
     --ABO 090420212 - correctif ARTGEREP_388
    AND r.origine = 25  --Filtre pour ne remonter que les demandes issue de l’extranet Assuré
    -- exclure systématiquement les demandes de type 31 "radiation /suspension". (M0006927)
    AND r.type NOT IN (31)
    and r.idrappel NOT IN(
        SELECT nvl(min(r2.idrappel),0)
        from rappel r2
        where r2.type = 11 -- circuit d'information
        and r2.commentaire like '%Type de circuit : 28;%'   -- circuit demat
        and r2.numassu = r.numassu
        UNION
        SELECT nvl(min(r3.idrappel),0)
        from rappel r3
        where r3.type = 11 -- circuit d'information
        and r3.commentaire like '%Type de circuit : 52;%' -- compte iris
        and r3.numassu = r.numassu
    )
    ;
    -- TODO rajouter une contrainte sur la date de valiation, ne pas les envoyer sans j+1

  CURSOR c_documents(i_idrappel rappel.idrappel%type) IS
    SELECT *
    FROM lien_ged
    WHERE REF_EXT = TO_CHAR(i_IDRAPPEL)
    AND IDDOC IS NOT NULL;

BEGIN
  l_tab_demande := new EXTR_TAB_DEMANDE(null);


  FOR r_demande IN c_demandes LOOP -- pour charque demande extranet
    loc_tab_document := new EXT_TAB_DOCUMENT(null);

    FOR r_document IN c_documents(r_demande.idrappel) LOOP  -- récupération des documents en rapport avec la demande
      loc_document := new EXTR_DOCUMENT( r_document.iddoc,-- id docushare
                                        r_document.nomdoc, -- nom du document transmis,
                                        null);
      IF loc_tab_document(loc_tab_document.count) IS NOT NULL THEN
         loc_tab_document.extend(1);
      END IF;
      loc_tab_document(loc_tab_document.count) :=  loc_document;
    END LOOP;
    IF loc_tab_document(loc_tab_document.count) IS NULL THEN
       loc_tab_document:=null;
    END IF;
   -- valorisation de l'état
    IF r_demande.ETAT in (3,5,6,8) and  (trunc(r_demande.creation) = trunc(sysdate)  OR trunc(r_demande.maj) = trunc(sysdate)) THEN  -- les demandes traité du jours sont valorisées en mode en cours de traitement.
        loc_etat_trancode := 'En cours de traitement';
    ELSIF r_demande.ETAT in (3,5,6,8) THEN     -- sinon elle sont traitées
        loc_etat_trancode := 'Traitée';
    ELSIF r_demande.ETAT in (1)  THEN   --les demandes etat nouveau sont en cours de traitement.
        loc_etat_trancode := 'En cours de traitement';
    ELSIF r_demande.ETAT in (2)  THEN
           loc_etat_trancode := 'En attente';
    ELSIF r_demande.ETAT in (4)  THEN
           loc_etat_trancode := 'Rejetté';
    ELSIF r_demande.ETAT in (7)  THEN
           loc_etat_trancode := 'Incomplet';
     ELSE
       loc_etat_trancode := null;
    END IF;
    l_demande := new EXTR_DEMANDE( r_demande.type,
                                   F_GET_TRANSCO ('MAIL','MAILRPL',r_demande.type), -- transcodification partagée avec l'envoi de mail
                                   r_demande.creation,
                                   r_demande.numassu,
                                   r_demande.numbene,
                                   r_demande.etat,
                                   null, -- TODO libelle etat a valoriser par gerep par le suite
                                   loc_tab_document, -- documents en lien avec le rappel
                                    r_demande.idrappel,
                                   new EXTR_TAB_BENEFICIAiRE(new EXTR_BENEFICIAIRE (r_demande.numbene, null ) )
                                  )  ;

      IF l_tab_demande(l_tab_demande.count) IS NOT NULL THEN
         l_tab_demande.extend(1);
      END IF;
      l_tab_demande(l_tab_demande.count) :=  l_demande;
  END LOOP;
  RETURN  l_tab_demande;
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN l_tab_demande;
END F_GET_DEMANDES;


/******************************************************************/

  /*************************************************/
  FUNCTION F_GET_ACTS_INSURED(I_NUMBENE INDIVIDU.numindiv%TYPE,
                              i_NUMGAR   CONTRAT.NUMGAR%TYPE,
                              i_datsin DATE ,
                              i_type NUMBER)
  RETURN  EXTR_TAB_ACTS_INSURED
  IS
  l_tab_act EXTR_TAB_ACTS_INSURED;
  l_act    EXTR_ACT_INSURED;
  loc_date_pivot date := GREATEST(trunc(e2d('01/01/2018'),'YEAR'), i_datsin);   -- mail de corrine du 24 mai 2018
  -- requette possible pour avoir le numfor et les commentaire, mais trop longue a s executer

CURSOR c_acts_insured( loc_date_pivot DATE, i_numbene NUMBER, i_type NUMBER ) is
  /* select natfrais.codfrais,
      natfrais.libelle libfrais,
      natfrais.rubrique famille,
      f_lib('VRUB',natfrais.RUBRIQUE) LIB_FAM,
      1 rang,
      null commentaire
  --LISTAGG(sqrb.def, ', ')  WITHIN GROUP (ORDER BY sqrb.sequence) commentaire
  from natfrais
  INNER JOIN couverture on
        couverture.numindiv = i_numbene
    and couverture.datapli != nvl(couverture.datper,couverture.datapli+1)
    and loc_date_pivot   between couverture.datapli and  nvl(couverture.datper,loc_date_pivot)
    and pk_histo_contrat.f_sel_etat (couverture.numgar,loc_date_pivot)=1
  INNER JOIN calcul  on
     calcul.datapli != nvl(calcul.datper,calcul.datapli+1)
    AND loc_date_pivot between calcul.datapli and nvl(calcul.datper,loc_date_pivot)
    AND calcul.numfor = pk_qttc.f_sel_numfor(couverture.numgar,couverture.numfor)
    AND  natfrais.codfrais = calcul.codfrais
 INNER JOIN defrub on
      DEFRUB.CODFRAIS = CALCUL.rubrique
      and    defrub.datapli != nvl(defrub.datper,defrub.datapli+1)
      and loc_date_pivot  between  defrub.datapli and nvl(defrub.datper,loc_date_pivot)
      and defrub.numfor = calcul.numfor
      and natfrais.rubrique=defrub.codfrais
  --left outer join sqrb  on
  --  sqrb.codfrais = natfrais.codfrais
  --  and sqrb.numfor = couverture.numfor
  where
      natfrais.type = 2
  AND natfrais.RUBRIQUE IN (SELECT libelle FROM libelle WHERE mnemo = decode(i_type, 1,'EAFRBE',null) AND code >=0)   -- rubriques dynmaique selon le type de remboursement
  AND  F_GET_TRANSCO('EA','FREXCLU',natfrais.codfrais) IS NULL  --acte non exclu
  AND couverture.numgar in (select pc.numgar from porte_contrat pc where pc.numgar = couverture.numgar AND numporte = 25  ) -- oui c'est en dur c'est vrai ( a rendre dynamique)
group by natfrais.codfrais, natfrais.libelle,natfrais.rubrique
 ;  */


  select calcul.codfrais,
      natfrais.libelle libfrais,
      calcul.rubrique famille,
      f_lib('VRUB',calcul.RUBRIQUE) LIB_FAM,
     ( select MIN (rang) from couverture c where c.numindiv = i_numbene
      and c.datapli != nvl(c.datper,c.datapli+1)
    and loc_date_pivot   between c.datapli and  nvl(c.datper,loc_date_pivot)
    and pk_histo_contrat.f_sel_etat (c.numgar,loc_date_pivot)=1  ) as rang_adh,
      MIN(couverture.rang) rang_gar,
      null commentaire
  --LISTAGG(sqrb.def, ', ')  WITHIN GROUP (ORDER BY sqrb.sequence) commentaire
  from natfrais
  INNER JOIN couverture on
        couverture.numindiv = i_numbene
    and couverture.datapli != nvl(couverture.datper,couverture.datapli+1)
    and loc_date_pivot   between couverture.datapli and  nvl(couverture.datper,loc_date_pivot)
    and pk_histo_contrat.f_sel_etat (couverture.numgar,loc_date_pivot)=1
  INNER JOIN calcul  on
     calcul.datapli != nvl(calcul.datper,calcul.datapli+1)
    AND loc_date_pivot between calcul.datapli and nvl(calcul.datper,loc_date_pivot)
    AND calcul.numfor = pk_qttc.f_sel_numfor(couverture.numgar,couverture.numfor)
    AND  natfrais.codfrais = calcul.codfrais
 INNER JOIN defrub on
      DEFRUB.CODFRAIS = CALCUL.rubrique
      and    defrub.datapli != nvl(defrub.datper,defrub.datapli+1)
      and loc_date_pivot  between  defrub.datapli and nvl(defrub.datper,loc_date_pivot)
      and defrub.numfor = calcul.numfor
      --and natfrais.rubrique=defrub.codfrais
  /*left outer join sqrb  on
    sqrb.codfrais = natfrais.codfrais
    and sqrb.numfor = couverture.numfor*/
  where
      natfrais.type = 2
  AND calcul.RUBRIQUE IN (SELECT libelle FROM libelle WHERE mnemo = decode(i_type, 1,'EAFRBE',null) AND code >=0)   -- rubriques dynmaique selon le type de remboursement
  AND  F_GET_TRANSCO('EA','FREXCLU',natfrais.codfrais) IS NULL  --acte non exclu
  AND couverture.numgar in (select pc.numgar from porte_contrat pc where pc.numgar = couverture.numgar AND numporte = 25  ) -- oui c'est en dure c'est vrais ( a rendre dynamique)
group by calcul.codfrais, natfrais.libelle, calcul.rubrique
order by 1  ;



  BEGIN
  l_tab_act := new EXTR_TAB_ACTS_INSURED(null);
  FOR R_act_insured in c_acts_insured(loc_date_pivot, i_numbene, i_type ) LOOP
    l_act := new EXTR_ACT_INSURED( R_act_insured.CODFRAIS
                                  ,R_act_insured.LIBFRAIS
                                  ,R_act_insured.FAMILLE
                                  ,R_act_insured.LIB_FAM
                                  ,R_act_insured.COMMENTAIRE
                                  ,least(R_act_insured.rang_adh,  R_act_insured.rang_gar) -- Si une couverture existe en rang 1 alors tout les rangs seront en rang 1
                                    );

    IF l_tab_act(l_tab_act.count) is not null then
      l_tab_act.extend(1);
    END IF;
    l_tab_act(l_tab_act.count) := l_act;
  END LOOP;



  RETURN l_tab_act;

  END F_GET_ACTS_INSURED;

/*******************************************************************************/
 FUNCTION F_LIST_EMPLOYEE_dev(I_params EXTR_Q_LIST_EMPLOYEE)
  RETURN EXTR_R_LIST_EMPLOYEE IS

  -- L’adhésion de base la plus récente ainsi que ses membres sont remontés même si l’adhésion est résiliée
 CURSOR c_adhesion(i_numadhe individu.numindiv%type, i_niveau number, i_numgar number, i_numcli number, i_nbmois number) IS
  --  WITH contrats_BIA as (select numgar from TABLE(F_Get_CONTRATs_BIA(i_numcli,null,i_numgar)))    -- préselection des contrats BIA
    SELECT distinct a.idadhesion ,
                    0 type_mouvement ,
                    null maj,
                    a.numgar,
                    ad.date_adhe datapli,
                    ad.date_fin_adhe datper  ,
                    F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(sysdate,ad.date_adhe) ,   a_type=>1)   etat_adhe,
                    F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(sysdate,ad.date_adhe),  a_type=>2) motif_adhe,
                    ad.mregl,
                    cr.college,
                    null clef
    FROM adhesion a, adhe_cntrt ad, contrat_ref  cr
    WHERE a.idadhesion IN(  SELECT max(idadhesion )
                            FROM  adhesion
                            WHERE numindiv = i_numadhe
                            AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                            AND datapli <> nvl(datper,datapli+1))
      AND a.numgar = cr.numgar
    --  AND a.numgar in (select numgar from contrats_BIA)
      AND a.numgar = nvl(i_numgar, a.numgar)
      AND a.idadhesion = ad.idadhesion
      AND i_NIVEAU  = 5 -- avec du 1 avant
      AND cr.TYPE_CONTRAT = 1
      AND F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date        => greatest(ad.date_adhe,sysdate),     a_type=>1)<>3 --on enlève les radiés pour éviter les doublons avec les mouvements
      AND a.creation       NOT BETWEEN add_months(trunc(sysdate),i_nbmois) and sysdate --doublon
      AND a.maj            NOT BETWEEN add_months(trunc(sysdate),i_nbmois) and sysdate --doublon
      AND NVL(ad.date_fin_adhe,sysdate) >add_months(TRUNC(SYSDATE),i_nbmois)
  UNION
    -- niveau détail 1  -- PBO M0006695
    SELECT distinct a.idadhesion ,
                    0 type_mouvement ,
                    null maj,
                    a.numgar,
                    ad.date_adhe datapli,
                    ad.date_fin_adhe datper  ,
                    F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(sysdate,ad.date_adhe) ,   a_type=>1)   etat_adhe,
                    F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(sysdate,ad.date_adhe),  a_type=>2) motif_adhe,
                    ad.mregl,
                    cr.college,
                    null clef
    FROM adhesion a, adhe_cntrt ad, contrat_ref  cr
    WHERE a.idadhesion IN( SELECT adhesion.idadhesion
                           FROM  adhesion
                           INNER JOIN adhe_cntrt ON adhe_cntrt.idadhesion = adhesion.idadhesion
                           WHERE adhesion.numindiv = i_numadhe
                           AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                           AND datapli <> nvl(datper,datapli+1)
                           order by adhesion.typfor , adhesion.datapli desc  -- tri sur les garanties et les dates d'adhésion
                           FETCH FIRST 1 ROWS ONLY) -- on ne prend alors que la première ligne, CAD l'adhesion la plus récente
     AND a.numgar = cr.numgar
     AND a.numgar = nvl(i_numgar, a.numgar)
     AND a.idadhesion = ad.idadhesion
     AND i_NIVEAU  = 1 -- Niveau detail 1
     AND cr.TYPE_CONTRAT in (1,2) -- 1 = Sante / 2 = Prevoyance
  UNION
  -- mouvements
    SELECT
          DATAS.idadhesion ,
          DATAS.type_mouvement,
          DATAS.MAJ,
          DATAS.numgar,
          DATAS.datapli,
          DATAS.datper,
          F_ETAT_ADHE_WS(a_idadhesion=> DATAS.idadhesion, a_date  => greatest(sysdate,DATAS.date_adhe),     a_type=>1) etat_adhe,
          F_ETAT_ADHE_WS(a_idadhesion=> DATAS.idadhesion, a_date  => greatest(sysdate,DATAS.date_adhe),     a_type=>2) motif_adhe,
          DATAS.mregl,
          cr.college,
          DATAS.clef
    FROM contrat_ref cr, (
        /* SELECT distinct a.idadhesion ,
                     5 type_mouvement,--'ajout béné'
                    trunc(a.creation) MAJ,
                    a.numgar,
                    datapli,datper,
                    ad.mregl,
                    a.numindiv clef,
                    ad.date_adhe
          FROM adhesion a , adhe_cntrt ad, histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE numindiv = i_numadhe
                                  AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND a.numgar = nvl(i_numgar, a.numgar)
            AND ha.idhistoadhe =  F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date        => sysdate,     a_type=>5)
            AND TRUNC(ha.datsai) < TRUNC(a.creation)
            AND trunc(a.creation) BETWEEN add_months(trunc(sysdate),i_nbmois) and trunc(sysdate)
           -- AND a.numgar in (select numgar from contrats_BIA)
            AND a.datper is  null
            AND a.datapli <> nvl(a.datper,datapli+1)
            AND NOT EXISTS(select 1 from adhesion a2
              where a2.numindiv = a.numindiv AND a2.idadhesion = a.IDADHESION
              AND a2.idcouverture<a.idcouverture AND NVL(a2.datper,a.datapli-1)=a.datapli-1)
      UNION*/
      -- radiation
          SELECT distinct a.idadhesion ,
                          /*'Radiation'*/ 2 type_mouvement,
                          trunc( ha.datsai) MAJ,
                          a.numgar,
                          datapli,datper,
                          ad.mregl,
                          a.idadhesion clef,
                          ad.date_adhe
          FROM adhesion a , adhe_cntrt ad, histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                  AND numindiv = i_numadhe
                                  AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND ha.idhistoadhe =  F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date        => sysdate,     a_type=>5)
            AND(( trunc(ha.datsai)         BETWEEN add_months(trunc(sysdate),-3) and trunc(sysdate)
            AND ha.etat = 3 ) OR NVL(ad.date_fin_adhe,sysdate-1) BETWEEN sysdate AND add_months(sysdate,3))
            AND a.datapli <> nvl(a.datper,datapli+1)
            AND a.numgar = nvl(i_numgar, a.numgar)
            AND ad.numadhe = a.numindiv --on reste focaliser sur l'adhérent
          --   AND a.numgar in (select numgar from contrats_BIA)
            AND EXISTS (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND ad.date_fin_adhe between fps.DEBUT and nvl(fps.fin, ad.date_fin_adhe) and fps.VALIDE ='O')
      UNION
      --  ajout ou cloture de couverture avec cod option liee
        SELECT distinct a.idadhesion ,
                          /*'Ajout de couverture'*/ 3  type_mouvement,
                          trunc(a.creation) MAJ ,
                          a.numgar,
                          datapli,datper,
                          ad.mregl,
                          a.idcouverture clef,
                          ad.date_adhe
          FROM adhesion a , adhe_cntrt ad , histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE numindiv = i_numadhe
                                  AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND ha.idhistoadhe =  F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => sysdate, a_type=>5)
            AND trunc(a.creation) BETWEEN add_months(trunc(sysdate),i_nbmois) and trunc(sysdate)
            AND TRUNC(ha.datsai) < TRUNC(a.creation)
            AND ha.etat <> 3
            AND a.numgar = nvl(i_numgar, a.numgar)
            AND datper is null
            AND a.datapli <> nvl(a.datper,datapli+1)
            --AND trunc(a.creation) > trunc(sysdate, 'MONTH')
            AND exists (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND greatest(trunc(sysdate), ad.DATE_ADHE) BETWEEN fps.DEBUT and nvl(fps.fin, greatest(trunc(sysdate), ad.DATE_ADHE)) and fps.VALIDE ='O')
            AND  EXISTS(select 1 from adhesion a2
              where a2.numindiv = a.numindiv AND a2.idadhesion = a.IDADHESION
              AND a2.idcouverture<a.idcouverture
              AND a2.numfor <> a.numfor
              )--si ajout de plusieurs couverture on ne prend que la dernière
      UNION
      -- fermeture de couverture
        SELECT distinct a.idadhesion ,
                          /*'Fermeture de couverture'*/ 4 type_mouvement,
                          trunc(a.maj) MAJ ,
                          a.numgar,
                          datapli,
                          datper,
                          ad.mregl,
                          a.idcouverture clef,
                          ad.date_adhe
          FROM adhesion a , adhe_cntrt ad , histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                  AND numindiv = i_numadhe
                                  AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND ha.idhistoadhe =  F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => a.datper, a_type=>5)
            AND trunc(a.maj)  BETWEEN add_months(trunc(sysdate),i_nbmois) and trunc(sysdate)-- on prend sur le mois
            AND ha.etat <> 3
            AND a.numgar = nvl(i_numgar, a.numgar)
           -- AND a.numgar in (select numgar from contrats_BIA)
            AND a.datper is not null
            AND a.datapli <> nvl(a.datper,datapli+1)
            --AND MAJ > trunc(sysdate, 'MONTH')
            AND EXISTS (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND greatest(trunc(sysdate), ad.DATE_ADHE) BETWEEN fps.DEBUT and nvl(fps.fin, sysdate) and fps.VALIDE ='O')
            AND  EXISTS(select 1 from adhesion a2 where a2.numindiv = a.numindiv and sysdate BETWEEN a2.DATAPLI and NVL(a2.datper,sysdate) and a2.idadhesion = a.IDADHESION AND a2.idcouverture = a.idcouverture AND a2.datper IS  NULL)--il a encore une couverture
      union

        SELECT distinct a.idadhesion ,
                          /*'Nouvelle adhésion'*/ 1 type_mouvement,
                          trunc(a.creation) MAJ ,
                          a.numgar,
                          datapli,
                          datper,
                          ad.mregl,
                          a.idadhesion clef,
                          ad.date_adhe
          FROM adhesion a , adhe_cntrt ad , histo_adhesion ha
          WHERE a.idadhesion IN(  SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                  AND numindiv = i_numadhe
                                  AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                                  AND datapli <> nvl(datper,datapli+1))
            AND a.idadhesion = ad.idadhesion
            AND ha.idhistoadhe =  F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => sysdate, a_type=>5)
            AND trunc(a.creation)       BETWEEN add_months(trunc(sysdate),i_nbmois) and trunc(sysdate)
            AND ha.etat IN (0,1)
            AND a.datper is null
            AND a.datapli <> nvl(a.datper,datapli+1)
            AND a.numgar = nvl(i_numgar, a.numgar)
            AND ad.numadhe = a.numindiv --on reste focaliser sur l'adhérent
          --  AND a.numgar in (select numgar from contrats_BIA)
            --AND trunc(a.creation) > trunc(sysdate, 'MONTH')
            AND TRUNC(ha.datsai) >= TRUNC(a.creation)
            AND ha.numutil <> f_numutil --M6441 ABO 13022020 retirer les affiliations massives
            AND exists (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND greatest(trunc(sysdate), ad.DATE_ADHE)BETWEEN fps.DEBUT and nvl(fps.fin, greatest(trunc(sysdate), ad.DATE_ADHE)) and fps.VALIDE ='O')
            --and not exists(select 1 from adhesion a2 where a2.numindiv = a.numindiv and  sysdate BETWEEN a2.DATAPLI and NVL(a2.datper,sysdate) and a2.idadhesion = a.IDADHESION )-- verifie que le bénéficiaire n'a jamais eu de couverture sur cette adhesion
  --suppression de beneficiaire
 /* union
  SELECT distinct a.idadhesion ,
                    6 type_mouvement,--'Suppresion de beneficiaire'
                    max(trunc(a.maj)) MAJ ,
                    a.numgar,
                    datapli,
                    datper,
                    ad.mregl,
                    a.numindiv clef,
                    ad.date_adhe
    FROM adhesion a , adhe_cntrt ad , histo_adhesion ha
    WHERE a.idadhesion IN(  SELECT idadhesion
                            FROM adhesion
                            WHERE 1=1
                            AND numindiv = i_numadhe
                            AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                            AND datapli <> nvl(datper,datapli+1))
      AND a.idadhesion = ad.idadhesion
      AND ha.idhistoadhe =  F_ETAT_ADHE(a_idadhesion=> a.idadhesion, a_date    => a.datper, a_type=>5)
       AND trunc(ha.datsai)         BETWEEN add_months(trunc(sysdate),-24) and trunc(sysdate) -- on prend sur le mois
      AND ha.etat <> 3
      AND a.datper IS NOT NULL
      AND a.datapli <> nvl(a.datper,datapli+1)
      AND a.numgar = nvl(i_numgar, a.numgar)
    --   AND a.numgar in (select numgar from contrats_BIA)
      --AND trunc(MAJ) > trunc(sysdate, 'MONTH')
      AND exists (select 1 from frml_prime_simple  fps where fps.numfor = a.numfor AND greatest(trunc(sysdate), ad.DATE_ADHE) BETWEEN fps.DEBUT and nvl(fps.fin, greatest(trunc(sysdate), ad.DATE_ADHE)) and fps.VALIDE ='O')
      AND  not EXISTS(select 1 from adhesion a2 where a2.numindiv = a.numindiv and sysdate BETWEEN a2.DATAPLI and NVL(a2.datper,sysdate) and a2.idadhesion = a.IDADHESION )
      GROUP BY a.idadhesion, a.numgar,datapli,datper,ad.mregl,  a.numindiv, ad.date_adhe
      HAVING max(trunc(a.maj))    BETWEEN add_months(trunc(sysdate),i_nbmois) and trunc(sysdate)*/
  )
  DATAS
    WHERE i_NIVEAU in  (3,5)
      AND cr.numgar = datas.numgar
      AND cr.TYPE_CONTRAT = 1
     -- AND ((DATAS.MAJ > add_months(SYSDATE,-3)AND i_NIVEAU=3) OR (DATAS.MAJ > add_months(SYSDATE,-24)AND i_NIVEAU=5) )-- on fait sauter la contrainte sur les 3 mois si niveau = 5
  ;


 CURSOR c_ayants_droit(i_idadhesion adhesion.idadhesion%type, i_numadhe individu.numindiv%type) IS
  SELECT i.*
  FROM adhesion a , individu i
  WHERE a.idadhesion = i_idadhesion
  AND a.numindiv <> i_numadhe
  and i.numindiv = a.numindiv
  ;


 CURSOR c_garanties_niveau_1(i_idadhesion adhesion.idadhesion%type, i_type_mouvement number,i_maj date,i_clef NUMBER) IS
  SELECT distinct f.numfor, f.NOMGAR, f.LIBELLE, a.DATAPLI, a.DATPER, a.FLAG_REGIME, f.OBLIGATOIRE, f.TYPGAR,
    (SELECT count(ma.numindiv) from Adhe_Cntrt_Membre ma ,adhesion aa,adhe_cntrt ada
    WHERE   ma.numindiv = aa.numindiv
    AND ma.idadhesion = a.idadhesion
    AND ma.typadr <>2
    AND ma.idadhesion = aa.idadhesion
    AND ada.idadhesion = aa.idadhesion
    AND aa.numfor = a.numfor
    AND aa.datapli <> nvl(aa.datper,aa.datapli+1)
     AND greatest(ada.date_adhe,greatest(i_maj,sysdate)) BETWEEN aa.datapli AND NVL(aa.datper,greatest(ada.date_adhe,greatest(i_maj,sysdate)))
    ) nb_adulte,
    (SELECT count(me.numindiv) from Adhe_Cntrt_Membre me ,adhesion ae,adhe_cntrt ade
    WHERE   me.numindiv = ae.numindiv
    AND me.idadhesion = a.idadhesion
    AND me.typadr =2
    AND me.idadhesion = ae.idadhesion
    AND ade.idadhesion = ae.idadhesion
    AND ae.numfor = a.numfor
    AND greatest(ade.date_adhe,greatest(i_maj,sysdate)) BETWEEN ae.datapli AND NVL(ae.datper,greatest(ade.date_adhe,greatest(i_maj,sysdate)))
    ) nb_enfant
  FROM adhesion a,  formule f
  WHERE a.idadhesion = i_idadhesion   -- partie concernant le nombre d'adutlte
    AND a.numfor = f.numfor
    --AND decode(i_type_mouvement,5,trunc(i_maj),trunc(a.maj))=trunc(a.maj);--si 5 ajout béné on filtre
    AND a.datapli <> nvl(a.datper,datapli+1)
    AND (
    (i_type_mouvement = 1 AND i_clef = a.idadhesion)
    OR (i_type_mouvement = 2 AND i_clef = a.idadhesion)
    OR (i_type_mouvement = 3 AND i_clef = a.idcouverture)
    OR (i_type_mouvement = 4 AND i_clef = a.idcouverture)
    OR (i_type_mouvement = 5 AND i_clef = a.numindiv)
    OR (i_type_mouvement = 6 AND i_clef = a.numindiv)
    OR i_type_mouvement = 0)
    AND EXISTS (SELECT 1 FROM frml_prime_simple  fps
      WHERE fps.numfor = a.numfor AND greatest(trunc(sysdate), a.datapli)
      BETWEEN fps.DEBUT and nvl(fps.fin, greatest(trunc(sysdate), a.datapli)) and fps.VALIDE ='O')
    ;

  CURSOR c_code_dsn(i_numfor adhesion.numfor%type) IS
    SELECT distinct code_option, lib_option
    FROM GAR_PARAM_DETAIL
    WHERE numfor = i_numfor
    ORDER BY code_option
    ;

  CURSOR c_salarier_niveau(     i_numindiv individu.numindiv%type,
                                i_nom individu.nom%type,
                                i_prenom individu.prenom%type,
                                i_matorg individu.matorg%type,
                                i_numcli individu.numindiv%type,
                                i_niveau_detail NUMBER,
                                i_numgar NUMBER,
                                i_datnais DATE  --RKO M0006027
                                )
    IS

     SELECT DISTINCT individu.* ,  F_LBLE('QLTE',INDIVIDU.QUALITE) lib_qualite, f_coordonne_contact(numindiv,4,1) lemail,  f_coordonne_contact(numindiv,1,1)  ltelephone
     FROM individu
     WHERE numindiv     = nvl(i_numindiv,numindiv)
     AND (EXISTS (select numindiv from adhe_cntrt_membre where numindiv = individu.numindiv AND i_niveau_detail = 1) --membre d'au moins une adhésion
     OR EXISTS (select numadhe from adhe_cntrt where numadhe = individu.numindiv))--adhérent d'au moins une adhésion
     AND datnais = NVL(i_datnais,datnais)
     AND UPPER(nom)    =UPPER(nvl(i_nom, nom))
     AND UPPER(prenom)  =UPPER(nvl(i_prenom, prenom))
     AND (UPPER(matorg||LPAD(to_char(cless),2,'0'))  = UPPER(nvl(i_matorg, matorg||LPAD(to_char(cless),2,'0')))
       OR UPPER(matorg2||LPAD(to_char(cless2),2,'0'))  = UPPER(nvl(i_matorg, matorg2||LPAD(to_char(cless2),2,'0'))))
     AND  i_niveau_detail  not in (3)

   UNION
     SELECT DISTINCT individu.* ,  F_LBLE('QLTE',INDIVIDU.QUALITE) lib_qualite, f_coordonne_contact(individu.numindiv,4,1) lemail,  f_coordonne_contact(individu.numindiv,1,1)  ltelephone
     FROM individu,
          adhesion,
          adhe_cntrt,
          contrat_ref
     WHERE individu.numindiv = nvl(i_numindiv,individu.numindiv)
      AND adhesion.numindiv = individu.numindiv
      AND EXISTS (select numadhe from adhe_cntrt where numadhe = individu.numindiv)
       AND UPPER(nom)    =UPPER(nvl(i_nom, nom))
       AND UPPER(prenom)  =UPPER(nvl(i_prenom, prenom))
       AND UPPER(matorg||LPAD(to_char(cless),2,'0'))  =UPPER(nvl(i_matorg, matorg||LPAD(to_char(cless),2,'0')))
       --AND contrat_ref.NUMGAR in (select numgar from contrats_BIA)
       AND contrat_ref.NUMGAR = adhe_cntrt.NUMGAR
       AND contrat_ref.numgar = nvl(i_numgar, contrat_ref.numgar)
       AND numcli = i_numcli
       AND adhesion.idadhesion = adhe_cntrt.idadhesion
       AND adhe_cntrt.numadhe = adhesion.numindiv
       AND adhesion.datapli <> NVL(adhesion.datper,e2d('01/01/1900'))
       AND   (adhesion.MAJ > add_months(SYSDATE,-12 ))
       AND  i_niveau_detail =3
   UNION
     SELECT DISTINCT individu.*,  F_LBLE('QLTE',INDIVIDU.QUALITE) lib_qualite, f_coordonne_contact(individu.numindiv,4,1) lemail,  f_coordonne_contact(individu.numindiv,1,1)  ltelephone
     FROM individu,
          adhesion,
          adhe_cntrt,
          contrat_ref
     WHERE individu.numindiv = nvl(i_numindiv,individu.numindiv)
      AND adhesion.numindiv = individu.numindiv
       AND EXISTS (select numadhe from adhe_cntrt where numadhe = individu.numindiv)
       AND UPPER(nom)     = UPPER(nvl(i_nom, nom))
       AND UPPER(prenom)  = UPPER(nvl(i_prenom, prenom))
       AND UPPER(matorg||LPAD(to_char(cless),2,'0'))  = UPPER(nvl(i_matorg, matorg||LPAD(to_char(cless),2,'0')))
      -- AND contrat_ref.NUMGAR in (select numgar from contrats_BIA)
       AND contrat_ref.NUMGAR = adhe_cntrt.NUMGAR
       AND contrat_ref.numgar = nvl(i_numgar, contrat_ref.numgar)
       AND numcli             = i_numcli
       AND adhesion.idadhesion = adhe_cntrt.idadhesion
       AND adhe_cntrt.numadhe  = adhesion.numindiv
       AND  i_niveau_detail = 5
       AND adhesion.datapli <> NVL(adhesion.datper,e2d('01/01/1900'))
      ;

   CURSOR c_salarier_niveau_2(  i_numindiv individu.numindiv%type,
                                i_nom individu.nom%type,
                                i_prenom individu.prenom%type,
                                i_matorg individu.matorg%type,
                                i_numcli individu.numindiv%type,
                                i_numgar contrat.numgar%type )
    IS
   -- WITH contrats_BIA as (select numgar from TABLE(F_Get_CONTRATs_BIA(i_numcli,null,i_numgar)))    -- préselction des contrats BIA
     SELECT individu.* ,  F_LBLE('QLTE',INDIVIDU.QUALITE) lib_qualite, f_coordonne_contact(numindiv,4,1) lemail,  f_coordonne_contact(numindiv,1,1)  ltelephone
     FROM individu
     WHERE numindiv     = nvl(i_numindiv,numindiv)
     AND EXISTS (select numadhe from adhe_cntrt where numadhe = individu.numindiv)
    /* AND ((MATORG Like '%' || i_matorg || '%' AND  i_matorg IS NOT NULL)
      OR MATORG = NVL(i_matorg,MATORG) OR MATORG IS NULL)
      AND ((NOM like '%' || UPPER( i_NOM) || '%' AND  i_NOM IS NOT NULL)
      OR NOM = NVL(i_NOM,NOM) OR NOM IS NULL)
      AND ((PRENOM like '%' || UPPER( i_prenom ) || '%' AND  i_prenom IS NOT NULL)
      OR PRENOM = NVL(i_prenom,PRENOM) OR PRENOM IS NULL )
      AND UPPER(matorg||cless)  = UPPER(nvl(i_matorg, matorg||cless)) */
      AND EXISTS( SELECT 1                          -- On ne remonte que les individus si il est dans le périmétre du numcli et du contrat
                  FROM   adhesion a,
                         contrat c,
                         histo_adhesion ha,
                         adhe_cntrt_membre acm
                  WHERE a.idadhesion IN(SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                  AND numindiv = (select numadhe from adhe_cntrt where adhe_cntrt.idadhesion =  adhesion.idadhesion)
                                  AND adhesion.numgar = nvl(i_numgar, adhesion.numgar)
                                  AND datapli <> nvl(datper,datapli+1))
                   AND ha.idhistoadhe =  F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => sysdate, a_type=>5) -- jointure adhesion/histo_adhesion -- PBO M0006296
                   AND a.numgar  = c.numgar
                --    AND c.NUMGAR in (select numgar from contrats_BIA)
                   AND c.numgar   = nvl(i_numgar, c.numgar)    -- au niveau on fait au minimum avec le numcli
                   AND c.numcli   = i_numcli
                   AND ((c.typequit = 1  -- contrat collectif uniquement -- PBO M0006408
                   AND c.portefeuille not in (4,5,6))-- sauf portabilité: BASE ANI, OPTION ANI, BASE + OPTION ANI -- PBO M0006299
                   OR c.portefeuille IN (14,13) )-- contrat individuel mais sur BASE ou OPT PUR INDIV
                   AND a.numindiv = individu.numindiv
                   AND acm.idadhesion = a.idadhesion
                   AND acm.numindiv = a.numindiv
                   AND acm.typadr = 0  -- Assuré Principal uniquement -- PBO M0006294
                   AND (a.datper is NULL  OR add_months(sysdate,-2) < a.datper)
                   AND ha.motif not in (58,59,60) -- on ne remonte pas les Pré-affiliation en attente validation RH (58), Pré-aff validée par RH (59), Affil option EA en attente validation Gerep (60) -- PBO M0006296
               )
  ;

  CURSOR c_adhesion_niveau_2 ( p_numindiv individu.numindiv%type, p_numcli individu.numindiv%type) IS
     -- WITH contrats_BIA as (select numgar from TABLE(F_Get_CONTRATs_BIA(i_numcli,null,i_numgar)))    -- préselction des contrats BIA
      SELECT distinct a.idadhesion ,
                    null type_mouvement ,
                    null maj,
                    a.numgar,
                    null datapli,
                    null datper  ,
                    F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe,sysdate),  a_type=>1)   etat_adhe,
                    F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe,sysdate),  a_type=>2) motif_adhe,
                    ad.mregl,
                    c.college
    FROM adhesion a, adhe_cntrt ad, contrat c, histo_adhesion ha, adhe_cntrt_membre acm
    WHERE a.idadhesion IN(SELECT idadhesion
                                  FROM adhesion
                                  WHERE 1=1
                                  AND numindiv = numadhe
                                  AND adhesion.numgar = a.numgar
                                  AND datapli <> nvl(datper,datapli+1))
      AND ha.idhistoadhe =  F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => sysdate, a_type=>5) -- jointure adhesion/histo_adhesion -- PBO M0006296
      AND a.idadhesion = ad.idadhesion
      AND a.numindiv = p_numindiv
      AND c.numgar = a.numgar
      AND ((c.typequit = 1  -- contrat collectif uniquement -- PBO M0006408
      AND c.portefeuille not in (4,5,6))-- sauf portabilité: BASE ANI, OPTION ANI, BASE + OPTION ANI -- PBO M0006299
      OR c.portefeuille IN (14,13) )-- contrat individuel mais sur BASE ou OPT PUR INDIV
      AND acm.idadhesion = a.idadhesion
      AND acm.numindiv = a.numindiv
      AND acm.typadr = 0  -- Assuré Principal uniquement -- PBO M0006294
      AND a.datapli <> NVL(a.datper,e2d('01/01/1900'))
      AND F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe,sysdate),  a_type=>1) <> 3  -- adhésions non resiliée
      AND ha.motif not in (58,59,60) -- on ne remonte pas les Pré-affiliation en attente validation RH (58), Pré-aff validée par RH (59), Affil option EA en attente validation Gerep (60) -- PBO M0006296
      AND c.numcli = NVL(p_numcli,c.numcli)
      ORDER BY a.idadhesion
      --FETCH FIRST 1 ROWS ONLY  -- on ne récupère que la premiere ligne.
  ;
 CURSOR c_demande_rejet(i_numcli number) IS
   SELECT  F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), souscript_base.commentaire)) idadhesion,
           decode (F_GET_VALUE_IN_TABLE('Mode de paiement', f_get_varchar_splited(';'||chr(10)||chr(13), souscript_base.commentaire)),0,1,mregl) mregl,
           max(souscript_base.idrappel) idrappel_sous,
           demande_rejet.idrappel idrappel_rejet, -- on prend le max pour eviter d'avoir plusieur lignes de rejet qui apparaissement.  et donc plusieurs adhésion
           F_GET_VALUE_IN_TABLE('Motif', f_get_varchar_splited(';'||chr(10)||chr(13), demande_rejet.commentaire))  motif,
           souscript_base.numbene,
           souscript_base.dateeffet,
           demande_rejet.creation,
           cr.college
  FROM rappel demande_rejet,
       rappel souscript_base,
       individu i,
       contrat_ref cr
  WHERE demande_rejet.TYPE = 24 -- rejet de souscription
    AND souscript_base.TYPE = 26
    and  cr.numgar in (select numgar from rappel_souscript rs where rs.idrappel = souscript_base.idrappel )
    AND demande_rejet.entite = souscript_base.entite
    AND souscript_base.numbene = demande_rejet.numbene
    AND demande_rejet.etat not in (4)
    AND demande_rejet.numcli = i_numcli
    AND  souscript_base.numbene = i.numindiv
    AND souscript_base.creation > add_months(sysdate,-3)
  GROUP BY  F_GET_VALUE_IN_TABLE('Idadhesion', f_get_varchar_splited(';'||chr(10)||chr(13), souscript_base.commentaire)),
              decode (F_GET_VALUE_IN_TABLE('Mode de paiement', f_get_varchar_splited(';'||chr(10)||chr(13), souscript_base.commentaire)),0,1,mregl),
            demande_rejet.idrappel,
             F_GET_VALUE_IN_TABLE('Motif', f_get_varchar_splited(';'||chr(10)||chr(13), demande_rejet.commentaire)),
            souscript_base.numbene,
            souscript_base.dateeffet,
            demande_rejet.creation,
            cr.college
;

CURSOR c_garanties_rejetes(i_idrappel NUMBER) IS

  SELECT  f.numfor,
        count(i.numindiv) nb_adulte,
        nvl(enfant.nb_enfant,0) nb_enfant,
        f.NOMGAR,
        a.numgar,
        f.LIBELLE,
        a.DATEEFFET,
        f.OBLIGATOIRE,
        f.TYPGAR,
        cr.college
  FROM  rappel_souscript a,
        contrat_ref cr,
        individu i,
        formule f
   LEFT OUTER JOIN   -- compter le nombre d'enfant
  (SELECT  a1.numfor, count(i1.numindiv) nb_enfant
    FROM  rappel_souscript a1 , individu i1 , formule f1
    WHERE a1.numfor = f1.numfor
      AND i1.numindiv = a1.numindiv
      AND a1.typassu= 2
      AND a1.idrappel = i_idrappel
      GROUP BY a1.numfor) enfant
    ON  enfant.numfor = f.numfor
    WHERE  a.numfor = f.numfor
      AND i.numindiv = a.numindiv
      AND cr.numgar = a.numgar
      AND a.typassu<>2
      AND a.idrappel = i_idrappel
    GROUP BY f.numfor,
             enfant.nb_enfant,
             enfant.numfor ,
             f.NOMGAR,
             a.numgar,
             f.LIBELLE,
             a.DATEEFFET,
             f.OBLIGATOIRE,
             f.TYPGAR,
              cr.college;


   ---- STRUCTURE DE REPONSE
   loc_reponse            EXTR_R_LIST_EMPLOYEE;

   loc_tab_affilie        EXTR_TAB_AFFILIE_EMPLOYEE;
   loc_affilie            EXTR_AFFILIE_EMPLOYEE;

   loc_adresse            EXTR_ADRESSE_TR;

   loc_tab_adhesion       EXTR_TAB_ADHESION_TR;
   loc_adhesion           EXTR_ADHESION_TR;

   loc_tab_ayant_droit    EXTR_TAB_AYANT_DROIT;
   loc_ayant_droit        EXTR_AYANT_DROIT;

   loc_tab_grnts          EXTR_TAB_GRNTS_TR;
   loc_garantie           EXTR_GRNTS_TR;

   loc_tab_code_DSN       EXTR_TAB_DSN_TR;
   loc_code_dsn           EXTR_DSN_TR;
   v_numgar_base number;
   ---- VARIABLES LOCALES
  loc_Nom           VARCHAR2(90)  :=I_params.nom;
  loc_prenom        VARCHAR2(90)  :=I_params.prenom;
  loc_MATORG        VARCHAR2(15)  :=I_params.matorg;-- numéro plus cle ss  13+2
  loc_numindiv      NUMBER(9)     :=I_params.numindiv;
  loc_Niveau_detail NUMBER(1)     :=I_params.niveau_detail;--1 :PRE-AFF, 2 : RECHERCHE, 3 : MVT
  loc_Numcli        NUMBER(9)     :=I_params.numcli;  -- nuémro de la société
  loc_NUMGAR        NUMBER(9)     :=I_params.numgar;
  loc_datnais       DATE          := I_params.datnais;--RKO M0006027
  loc_numgar_rejete  NUMBER;
  loc_nbmois         NUMBER;
  loc_college       NUMBER          := I_params.college;
   -- CURSEUR
   --verification du périmetre iso contract_list_by_comp_rh
   loc_perimetre_BIA EXTR_TAB_CONTRAT;
   l_perimetre_bia_ok number;

  -- MUR M0005954
  loc_ctrl_sante number(9) ;
  V_DELEG_PREST number;
  V_DELEG_COT  number;
  BEGIN
  loc_perimetre_BIA := F_GET_CONTRATS_BIA(loc_Numcli,null,loc_NUMGAR);
  loc_tab_affilie     := new  EXTR_TAB_AFFILIE_EMPLOYEE(null);
  IF loc_Niveau_detail = 6 THEN
    --RKO LOT2 EA PREVOY test sur les paramètres entrants
    IF ((loc_datnais IS NULL AND loc_nom IS NULL AND loc_prenom IS NULL AND loc_MATORG IS NULL AND loc_numindiv IS NULL) OR loc_Numcli IS NULL)
         THEN  RETURN NULL;

    ELSE RETURN F_list_employ_niv_6  (loc_numindiv,
                                  loc_Nom,
                                  loc_prenom,
                                  loc_matorg,
                                  loc_datnais,
                                  loc_numcli,
                                  loc_numgar,
                                  loc_college) ;
    END IF;
  ELSIF loc_Niveau_detail = 7 THEN      --RKO Enrich. IRIS Entrp
    IF ((loc_nom IS NULL AND loc_prenom IS NULL AND loc_datnais IS NULL)
         OR (loc_nom IS NOT NULL AND loc_prenom IS NULL AND loc_datnais IS NULL) --Au moins deux éléments (parmi nom, prenom et datnais) doivent être saisis
         OR (loc_prenom IS NOT NULL AND loc_nom IS NULL AND loc_datnais IS NULL )
         OR (loc_datnais IS NOT NULL AND loc_nom IS NULL AND loc_prenom IS NULL )
         OR loc_Numcli IS NULL
       ) THEN RETURN NULL;

    ELSE RETURN F_list_employ_niv_7 (loc_numindiv,
                                  loc_Nom,
                                  loc_prenom,
                                  loc_matorg,
                                  loc_datnais,
                                  loc_numcli,
                                  loc_numgar,
                                  loc_college) ;
    END IF;
  ELSIF loc_Niveau_detail in (1,3,5) THEN
    -- TEST sur les paramétres
    IF  (loc_Niveau_detail =1 AND loc_MATORG IS NULL AND loc_numindiv IS NULL) OR
        (loc_Niveau_detail = 1 AND loc_MATORG IS NULL AND loc_datnais IS NULL)  OR    --RKO M0006027
        (loc_Niveau_detail =3 AND loc_numcli IS NULL )  OR
        (loc_Niveau_detail =5 AND loc_MATORG IS NULL AND loc_prenom IS NULL AND loc_nom IS NULL )
    THEN
      RETURN NULL;
    END IF;
    -- FIn TEST SUR LES PARAMÉTRES

    IF loc_Niveau_detail =3 THEN loc_nbmois :=-3;
    ELSIF loc_Niveau_detail =5 THEN loc_nbmois :=-24;
    END IF;

    FOR  R_SALARIER IN c_salarier_niveau(loc_numindiv,
                                        loc_nom, loc_prenom,
                                        loc_matorg,
                                        loc_numcli,
                                        loc_Niveau_detail,
                                        loc_NUMGAR,
                                        loc_datnais --RKO M0006027
                                        )
    LOOP
      loc_tab_adhesion    := new   EXTR_TAB_ADHESION_TR(null);
      FOR R_ADHESION  IN c_adhesion(r_salarier.numindiv, loc_Niveau_detail,loc_NUMGAR,loc_numcli,loc_nbmois) LOOP
      -- verification du périmètre du BIA iso contract_list_by_comp_rh
        BEGIN select distinct 1 into l_perimetre_bia_ok from table(loc_perimetre_BIA) where numgar = R_ADHESION.numgar ;EXCEPTION when others then l_perimetre_bia_ok := 0; end;
        IF l_perimetre_bia_ok =1  THEN
            loc_tab_grnts := new EXTR_TAB_GRNTS_TR(null);
            FOR R_GARANTIE IN c_garanties_niveau_1(r_adhesion.idadhesion, R_ADHESION.type_mouvement,NVL(R_ADHESION.maj,sysdate),R_ADHESION.clef) LOOP

              loc_tab_code_DSN := new EXTR_TAB_DSN_TR(null);

              FOR R_CODE_DSN IN c_code_dsn(r_garantie.numfor) LOOP
                loc_code_dsn   := new   EXTR_DSN_TR(CODOPTION=> r_code_dsn.code_option,
                                                    LIBOPTION=> r_code_dsn.lib_option );
                IF loc_tab_code_DSN(1) IS NOT NULL THEN loc_tab_code_DSN.extend(1); END IF;
                loc_tab_code_DSN(loc_tab_code_DSN.count) := loc_code_dsn ;
              END LOOP curseur_code_dsn;
              loc_garantie     := new   EXTR_GRNTS_TR(  NOM_GARANTIE => r_garantie.nomgar,
                                                        LIBELLE      => r_garantie.libelle,
                                                        NUMFOR       => r_garantie.numfor,
                                                        DATE_DEBUT   => r_garantie.datapli,
                                                        DATE_FIN     => r_garantie.datper,
                                                        TYPE_GAR     => r_garantie.typgar,
                                                        FLAG_REGIME  => r_garantie.flag_regime,
                                                        OBLIGATOIRE  => r_garantie.obligatoire,
                                                        NB_ADULTE    => r_garantie.nb_adulte,
                                                        NB_ENFANT    => r_garantie.nb_enfant,
                                                        CODES_DSN    => loc_tab_code_DSN
                                                        );
             IF loc_tab_grnts(1) IS NOT NULL THEN loc_tab_grnts.extend(1); END IF;
             loc_tab_grnts(loc_tab_grnts.count) := loc_garantie;
            END LOOP curseur_garanties;

            loc_tab_ayant_droit := new   EXTR_TAB_AYANT_DROIT(null);
            IF loc_niveau_detail =1 THEN
              FOR r_ayant_droit IN  c_ayants_droit(r_adhesion.idadhesion, loc_numindiv) LOOP
                  loc_ayant_droit     := new   EXTR_AYANT_DROIT(  Nom      => r_ayant_droit.nom,
                                                                  prenom   => r_ayant_droit.prenom,
                                                                  datnais  => r_ayant_droit.datnais,
                                                                  Rang     => r_ayant_droit.rang,
                                                                  matorg   => r_ayant_droit.matorg,
                                                                  regime   => r_ayant_droit.regime,
                                                                  caisse   => r_ayant_droit.caisse,
                                                                  centre   => r_ayant_droit.GUICHETORG,
                                                                  Typadr   => r_ayant_droit.typadr,
                                                                  libTypadr=>  null--F_LBLE('TYAD',r_ayant_droit.typadr)
                                                                  );
                  IF loc_tab_ayant_droit(1) IS NOT NULL THEN loc_tab_ayant_droit.extend(1); END IF;
                   loc_tab_ayant_droit(loc_tab_ayant_droit.count):= loc_ayant_droit;
              END LOOP cursor_ayantdroit;
            END IF ;

          BEGIN
          SELECT d.numenvers
          INTO   V_NUMGAR_BASE
          FROM dependance d
              WHERE d.numde = R_ADHESION.NUMGAR
              AND d.role = 2
              AND d.type =2  ;

              EXCEPTION WHEN OTHERS
              THEN
                V_NUMGAR_BASE := null;
          END;

               loc_adhesion        := new   EXTR_ADHESION_TR( numgar       => R_ADHESION.numgar,
                                                              refCie       => null,--R_ADHESION.refcie,
                                                              college      => R_ADHESION.COLLEGE||'|'||F_LBLE('COLLEGE',R_ADHESION.COLLEGE),
                                                              Cntrt_base   => nvl(V_NUMGAR_BASE,R_ADHESION.numgar) ,
                                                              idadhesion   => R_ADHESION.idadhesion,
                                                              etat         => R_ADHESION.etat_adhe,
                                                              libetat      => f_lble('ET_ADHE',R_ADHESION.etat_adhe),
                                                              motif        => R_ADHESION.motif_adhe,
                                                              libMotif     => f_lble('HISTO_ADHE',R_ADHESION.motif_adhe ),
                                                              dateDebut    => R_ADHESION.datapli,
                                                              dateFin      => R_ADHESION.datper,
                                                              Modpmt       => R_ADHESION.MREGL,
                                                              Libmodpmt    => pk_libelle.f_lib('MREGL', R_ADHESION.MREGL ),
                                                              dateModif    => R_ADHESION.maj,
                                                              typeModif    => R_ADHESION.type_mouvement,
                                                              ayant_droits => loc_tab_ayant_droit,
                                                              garanties    => loc_tab_grnts);

--dbms_output.put_line('adhes '||loc_adhesion.idadhesion||' etat '||loc_adhesion.libetat||'typemodif '|| loc_adhesion.typeModif);

            IF loc_tab_adhesion(1) IS NOT NULL THEN loc_tab_adhesion.extend(1); END IF;
            loc_tab_adhesion(loc_tab_adhesion.count) :=  loc_adhesion ;
         END IF;-- perimetre_BIA
      END LOOP cusror_adhesions;
      -- M0006441 + M0007091 : on bloque les retours employés pour le niveau 3 (sinon risque de timeout)
      IF loc_tab_adhesion(1) IS NOT NULL OR loc_Niveau_detail <> 3 THEN
         loc_affilie         := new  EXTR_AFFILIE_EMPLOYEE(  Numindiv    => R_SALARIER.numindiv,
                                                          Nom         => R_SALARIER.nom,
                                                          Prenom      => R_SALARIER.prenom,
                                                          Matorg      => R_SALARIER.matorg||LPAD(to_char(R_SALARIER.CLEss),2,'0'),
                                                          Datnais     => R_SALARIER.datnais,
                                                          Rang        => R_SALARIER.rang,
                                                          Qualite     => R_SALARIER.qualite,
                                                          Lib_qualite => R_SALARIER.lib_qualite,
                                                          regime      => R_SALARIER.regime,
                                                          caisse      => R_SALARIER.caisse,
                                                          centre      => R_SALARIER.GUICHETORG,
                                                          email       => R_SALARIER.lemail,
                                                          telephone   => R_SALARIER.ltelephone,
                                                          Adresse     => loc_adresse,
                                                          Adhesions   => loc_tab_adhesion );
          IF loc_niveau_detail <> 5 OR loc_tab_adhesion(1) IS NOT NULL THEN
            IF loc_tab_affilie(1) IS NOT NULL THEN loc_tab_affilie.extend(1); END IF;
            loc_tab_affilie(loc_tab_affilie.count) := loc_affilie;
          END IF;
      END IF;
    END LOOP cursor_salarier;


  ELSiF  loc_Niveau_detail = 2 THEN
           -- FIn TEST SUR LES PARAMÉTRES
    IF loc_numcli IS NULL THEN RETURN NULL; END IF;
    loc_tab_affilie     := new  EXTR_TAB_AFFILIE_EMPLOYEE(null);

    FOR R_SALARIER IN c_salarier_niveau_2(loc_numindiv, loc_nom, loc_prenom, loc_matorg, loc_numcli, loc_numgar) LOOP

        loc_tab_adhesion    := new   EXTR_TAB_ADHESION_TR(null);
        -- On récupére la dernière adhésion en vigueur
        FOR r_adhesion in c_adhesion_niveau_2(R_SALARIER.numindiv,loc_numcli) LOOP

          -- MUR M0005954 controle contrat sante
          begin
            select count(*) into loc_ctrl_sante
            from adhesion a
            inner join formule f on (f.numfor = a.numfor)
            where a.idadhesion = r_adhesion.idadhesion
            ;
          exception
            when others then loc_ctrl_sante := 0 ;
          end;
          if loc_ctrl_sante = 0 then continue ; end if ; -- ne continue que si garantie sante



          loc_tab_grnts := new EXTR_TAB_GRNTS_TR(null);


          FOR R_GARANTIE IN c_garanties_niveau_1(r_adhesion.idadhesion, 0,sysdate,NULL) LOOP
           -- PBO M0006158 filtre sur les garanties en cours sur le niveau_detail 2
            IF NVL(R_GARANTIE.datper, sysdate + 1)  <= sysdate AND loc_Niveau_detail = 2 THEN
              CONTINUE;
            END IF;
           V_DELEG_PREST:=null;
           V_DELEG_COT :=null;
          SELECT COUNT(numfor)
          INTO V_DELEG_PREST
          FROM CALCUL
          WHERE NUMFOR = r_garantie.numfor
          AND greatest(trunc(sysdate),r_garantie.datapli) BETWEEN DATAPLI AND NVL(DATPER,greatest(trunc(sysdate),r_garantie.datapli));

          SELECT COUNT(numfor)
          INTO V_DELEG_COT
          FROM FRML_PRIME_SIMPLE
          WHERE NUMFOR =r_garantie.numfor
          AND greatest(trunc(sysdate),r_garantie.datapli) BETWEEN DEBUT AND NVL(FIN,greatest(trunc(sysdate),r_garantie.datapli));

          IF not(V_DELEG_COT + V_DELEG_PREST= 0 OR (V_DELEG_COT > 0 AND V_DELEG_PREST =0 ))THEN

            loc_garantie     := new   EXTR_GRNTS_TR(  NOM_GARANTIE => r_garantie.nomgar,
                                                      LIBELLE      => r_garantie.libelle,
                                                      NUMFOR       => r_garantie.numfor,
                                                      DATE_DEBUT   => r_garantie.datapli,
                                                      DATE_FIN     => r_garantie.datper,
                                                      TYPE_GAR     => r_garantie.typgar,
                                                      FLAG_REGIME  => r_garantie.flag_regime,
                                                      OBLIGATOIRE  => r_garantie.obligatoire,
                                                      NB_ADULTE    => r_garantie.nb_adulte,
                                                      NB_ENFANT    => r_garantie.nb_enfant,
                                                      CODES_DSN    => null
                                                      );
           IF loc_tab_grnts(1) IS NOT NULL THEN loc_tab_grnts.extend(1); END IF;
           loc_tab_grnts(loc_tab_grnts.count) := loc_garantie;
          END IF;
          END LOOP curseur_garanties;


          BEGIN
          SELECT d.numenvers
          INTO   V_NUMGAR_BASE
          FROM dependance d
              WHERE d.numde = R_ADHESION.numgar
              AND d.role = 2
              AND d.type =2
              AND exists (select 1 from ADHE_CNTRT ac where ac.NUMGAR=d.numenvers AND ac.NUMADHE=R_SALARIER.numindiv); -- M0006304 PBO filtre sur le contrat de base de l'adhérent;

              EXCEPTION WHEN OTHERS
              THEN
                V_NUMGAR_BASE := null;
          END;

          /* MUR M0005954
          loc_tab_adhesion    := new   EXTR_TAB_ADHESION_TR(null);
          loc_tab_adhesion(1)  := new   EXTR_ADHESION_TR( numgar       => R_ADHESION.numgar, etc ...
          */
          IF loc_tab_adhesion(1) IS NOT NULL THEN loc_tab_adhesion.extend(1); END IF;
          loc_tab_adhesion(loc_tab_adhesion.count) := new   EXTR_ADHESION_TR(
                                                          numgar       => R_ADHESION.numgar,
                                                          refCie       => null,--R_ADHESION.refcie,
                                                          college      => R_ADHESION.COLLEGE||'|'||F_LBLE('COLLEGE',R_ADHESION.COLLEGE),
                                                          Cntrt_base   => nvl(V_NUMGAR_BASE,R_ADHESION.numgar),
                                                          idadhesion   => R_ADHESION.idadhesion,
                                                          etat         => R_ADHESION.etat_adhe,
                                                          libetat      => f_lble('ET_ADHE',R_ADHESION.etat_adhe),
                                                          motif        => R_ADHESION.motif_adhe,
                                                          libMotif     => f_lble('HISTO_ADHE',R_ADHESION.motif_adhe ),
                                                          dateDebut    => R_ADHESION.datapli,
                                                          dateFin      => R_ADHESION.datper,
                                                          Modpmt       => R_ADHESION.MREGL,
                                                          Libmodpmt    => pk_libelle.f_lib('MREGL', R_ADHESION.MREGL ),
                                                          dateModif    => R_ADHESION.maj,
                                                          typeModif    => R_ADHESION.type_mouvement,
                                                          ayant_droits => null,
                                                          garanties    => loc_tab_grnts
                                            );

        END LOOP;

        loc_affilie         := new  EXTR_AFFILIE_EMPLOYEE(  Numindiv    => R_SALARIER.numindiv,
                                                            Nom         => R_SALARIER.nom,
                                                            Prenom      => R_SALARIER.prenom,
                                                            Matorg      => R_SALARIER.matorg||LPAD(to_char(R_SALARIER.cless),2,'0'),
                                                            Datnais     => R_SALARIER.datnais,
                                                            Rang        => R_SALARIER.rang,
                                                            Qualite     => R_SALARIER.qualite,
                                                            Lib_qualite => R_SALARIER.lib_qualite,
                                                            regime      => R_SALARIER.regime,
                                                            caisse      => R_SALARIER.caisse,
                                                            centre      => R_SALARIER.GUICHETORG,
                                                            email       => R_SALARIER.lemail,
                                                            telephone   => R_SALARIER.ltelephone,
                                                            Adresse     => loc_adresse,
                                                            Adhesions   => loc_tab_adhesion
                                                        );

     IF loc_tab_affilie(1) IS NOT NULL THEN loc_tab_affilie.extend(1); END IF;
        loc_tab_affilie(loc_tab_affilie.count) := loc_affilie;
    END LOOP cursor_salarier;


  ELSiF  loc_Niveau_detail = 4 THEN -- demandes rejetées
    --DBMS_OUTPUT.PUT_LINE('loc_Niveau_detail = 4 '||loc_Numcli);

       FOR r_demande_rejet IN c_demande_rejet(loc_Numcli) LOOP
           --DBMS_OUTPUT.PUT_LINE('curseur rejet demande'||r_demande_rejet.idrappel_sous);
            loc_tab_adhesion    := new   EXTR_TAB_ADHESION_TR(null);
            loc_tab_grnts := new EXTR_TAB_GRNTS_TR(null);
            FOR R_GARANTIE IN c_garanties_rejetes(r_demande_rejet.idrappel_sous) LOOP
              loc_tab_code_DSN := new EXTR_TAB_DSN_TR(null);
              --DBMS_OUTPUT.PUT_LINE('curseur garantie 1'|| r_garantie.numfor);
              FOR R_CODE_DSN IN c_code_dsn(r_garantie.numfor) LOOP
                 --DBMS_OUTPUT.PUT_LINE('curseur dsn '||r_code_dsn.code_option);
                loc_code_dsn   := new   EXTR_DSN_TR(CODOPTION=> r_code_dsn.code_option,
                                                    LIBOPTION=> r_code_dsn.lib_option );
                IF loc_tab_code_DSN(1) IS NOT NULL THEN loc_tab_code_DSN.extend(1); END IF;
                loc_tab_code_DSN(loc_tab_code_DSN.count) := loc_code_dsn ;
              END LOOP curseur_code_dsn;

              --DBMS_OUTPUT.PUT_LINE('curseur garantie 2'|| r_garantie.numfor);
              loc_garantie     := new   EXTR_GRNTS_TR(  NOM_GARANTIE => r_garantie.nomgar,
                                                        LIBELLE      => r_garantie.libelle,
                                                        NUMFOR       =>  r_garantie.numfor,
                                                        DATE_DEBUT   => r_garantie.DATEEFFET,
                                                        DATE_FIN     => null,-- r_garantie.datper,
                                                        TYPE_GAR     =>  r_garantie.typgar,
                                                        FLAG_REGIME  =>  null,-- r_garantie.flag_regime,
                                                        OBLIGATOIRE  =>  r_garantie.obligatoire,
                                                        NB_ADULTE    =>  r_garantie.nb_adulte,
                                                        NB_ENFANT    =>  r_garantie.nb_enfant,
                                                        CODES_DSN    => loc_tab_code_DSN
                                                        );
              loc_numgar_rejete:=r_garantie.numgar;

              IF loc_tab_grnts(1) IS NOT NULL THEN loc_tab_grnts.extend(1); END IF;
              loc_tab_grnts(loc_tab_grnts.count) := loc_garantie;
            END LOOP curseur_garanties;

          --DBMS_OUTPUT.PUT_LINE('création_adhésion');

             BEGIN
          SELECT d.numenvers
          INTO   V_NUMGAR_BASE
          FROM dependance d
              WHERE d.numde = loc_numgar_rejete
              AND d.role = 2
              AND d.type =2  ;

              EXCEPTION WHEN OTHERS
              THEN
                V_NUMGAR_BASE := null;
          END;

          loc_adhesion        := new   EXTR_ADHESION_TR(  numgar       => loc_numgar_rejete,
                                                          refCie       => null,--R_ADHESION.refcie,
                                                          college      =>  r_demande_rejet.COLLEGE||'|'||F_LBLE('COLLEGE',r_demande_rejet.COLLEGE),
                                                          Cntrt_base   => nvl(V_NUMGAR_BASE,loc_numgar_rejete),
                                                          idadhesion   =>  r_demande_rejet.idadhesion,
                                                          etat         =>  0,
                                                          libetat      => 'Rejeté',--f_lble('ET_ADHE',R_ADHESION.etat_adhe),
                                                          motif        =>  r_demande_rejet.motif,-- R_ADHESION.motif_adhe,
                                                          libMotif     => f_lble('REJET_BIA',r_demande_rejet.motif ),--f_lble('HISTO_ADHE',R_ADHESION.motif_adhe ),
                                                          dateDebut    => r_demande_rejet.dateeffet,--R_ADHESION.datapli,
                                                          dateFin      => null,--R_ADHESION.datper,
                                                          Modpmt       => r_demande_rejet.MREGL,
                                                          Libmodpmt    => pk_libelle.f_lib('MREGL', r_demande_rejet.MREGL ),
                                                          dateModif    => r_demande_rejet.creation,-- R_ADHESION.maj,
                                                          typeModif    => null,
                                                          ayant_droits => null,
                                                          garanties    => loc_tab_grnts);
         -- c'est n'est pas une boucle mais le numindiv permet de ne selectionner que l'individu en question pour l'ajouter au tableau des rejets
         FOR R_SALARIER in  c_salarier_niveau(   r_demande_rejet.numbene,null,null,null,null ,loc_Niveau_detail,loc_numgar, NULL)
           LOOP
           --DBMS_OUTPUT.PUT_LINE('curseur salrié'||R_SALARIER.nom);
           loc_affilie         := new  EXTR_AFFILIE_EMPLOYEE( Numindiv    => R_SALARIER.numindiv,
                                                    Nom         => R_SALARIER.nom,
                                                    Prenom      => R_SALARIER.prenom,
                                                    Matorg      => R_SALARIER.matorg||LPAD(to_char(R_SALARIER.cless),2,'0'),
                                                    Datnais     => R_SALARIER.datnais,
                                                    Rang        => R_SALARIER.rang,
                                                    Qualite     => R_SALARIER.qualite,
                                                    Lib_qualite => R_SALARIER.lib_qualite,
                                                    regime      => R_SALARIER.regime,
                                                    caisse      => R_SALARIER.caisse,
                                                    centre      => R_SALARIER.GUICHETORG,
                                                    email       => R_SALARIER.lemail,
                                                    telephone   => R_SALARIER.ltelephone,
                                                    Adresse     => loc_adresse,
                                                    Adhesions   => new EXTR_TAB_ADHESION_TR(loc_adhesion) );
        IF loc_tab_affilie(1) IS NOT NULL THEN loc_tab_affilie.extend(1); END IF;
        loc_tab_affilie(loc_tab_affilie.count) := loc_affilie;
        END LOOP salarier_unique;
       END LOOP c_demande_rejet;
  END IF;

  return   new EXTR_R_LIST_EMPLOYEE(loc_tab_affilie);

  EXCEPTION
    WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_LIST_EMPLOYEE',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => SQLERRM,
        I_idligne  => 2);

  END F_LIST_EMPLOYEE_dev;

 /**  Fonction F_GET_IDENTIFIANT_RH permettant d'identifier un interlocuteur RH en fonction de son adresse email.
  *  valeur remarquables:
  *  -1 => aucune données trouvées
  *  -2 => plusieurs individus trouvés
  *
  **/
FUNCTION F_GET_IDENTIFIANT_RH(i_email VARCHAR2)
  RETURN NUMBER IS
    l_numindiv individu.numindiv%type;
  BEGIN
  -- M0006250 PBO : integre F_COORDONNE_CONTACT qui s'affranchit desormais des caracteres invisibles
  SELECT DISTINCT interlocuteur
  INTO l_numindiv
  FROM interlocuteur
  WHERE OPE_CRRR in(8,9)  -- interlotucteur de type société , interloc Espace prévoyance
  AND VALIDE = 'O'    -- Email par defaut
  AND upper(i_email) = upper(F_COORDONNE_CONTACT(interlocuteur,4,1)) -- Email professionel de l'interlocuteur
  ;


  /*
  SELECT DISTINCT numindiv
  INTO l_numindiv
  FROM contact
  WHERE upper(coordonnee ) = upper(email)
  AND nature = 4 -- adresse email
  AND type = 1
  AND numindiv IN (SELECT interlocuteur
                    FROM interlocuteur
                    WHERE OPE_CRRR = 8  -- interlotucteur de type société
                    AND VALIDE = 'O')
  ;
  */

  return   l_numindiv;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return -1;
     WHEN TOO_MANY_ROWS THEN
     return -2;
     WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_GET_IDENTIFIANT_RH',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => SQLERRM,
        I_idligne  => 1);

        return -1;
  END  F_GET_IDENTIFIANT_RH;


  /*********************/
  FUNCTION F_LIB_TRPNT (i_type TRPNT.TYPE_TIERS%TYPE,
                        i_regime TRPNT.REGIME%TYPE,
                        i_caisse TRPNT.CAISSE%TYPE,
                        i_centre TRPNT.CENTRE%TYPE) RETURN TRPNT.NOM%TYPE
  IS
    loc_nom TRPNT.NOM%TYPE;
  BEGIN

    IF i_type=1 AND i_caisse IS NULL THEN RETURN NULL;
    ELSIF i_type=2 AND i_centre IS NULL THEN RETURN NULL;
    END IF;

    SELECT NOM
    INTO loc_nom
    FROM TRPNT
    WHERE trim(to_char(regime,'00')) = i_regime
    AND (trim(to_char(caisse,'000')) = i_caisse OR i_caisse IS NULL)
    AND (trim(to_char(centre,'000')) = i_centre OR i_centre IS NULL)
    AND type_tiers = i_type;

    RETURN loc_nom;

    EXCEPTION
      WHEN OTHERS THEN RETURN NULL;
  END F_LIB_TRPNT;

  FUNCTION f_statut_noemie(I_NUMINDIV INDIVIDU.NUMINDIV%TYPE, I_IDPORTE PORTE_ADHESION.IDPORTE%TYPE)
      RETURN VARCHAR2
     IS
        loc_date_trans   DATE                  DEFAULT SYSDATE;

        CURSOR fetch_objet (i_date DATE)
        IS
           SELECT      DECODE (rejet_noemie.mouvement,
                               'R', 'Rejet le ',
                               'S', 'Signal° le ',
                               'C', 'Certif° le '
                              )
                    || TO_CHAR (TO_DATE (rejet_noemie.date_rejet, 'ddmmyy'),
                                'dd/mm/yy'
                               )
                    || ' : '
                    || rejet_noemie.libelle statut
               FROM rejet_noemie
              WHERE rejet_noemie.numindiv = i_numindiv
                AND TO_DATE (date_rejet, 'ddmmyy') >= i_date
           ORDER BY rejet_noemie.numremise ;

        loc_objet        fetch_objet%ROWTYPE;
        loc_retour       VARCHAR2 (200)        := 'Non encore acquité ...';
        loc_numremise    BINARY_INTEGER        := 0;
        loc_transmis     BINARY_INTEGER        := 2;
     BEGIN
        IF (i_idporte != 0)
        THEN
           BEGIN
              SELECT numremise, transmis
                INTO loc_numremise, loc_transmis
                FROM porte_adhesion
               WHERE idporte = i_idporte;
           EXCEPTION
              WHEN NO_DATA_FOUND
              THEN
                 NULL;
           END;

           IF (loc_numremise = 0 OR loc_transmis = 2)
           THEN
              RETURN ('Non encore transmis ...');
           ELSE
              BEGIN
                 SELECT date_trans
                   INTO loc_date_trans
                   FROM remise_externe
                  WHERE numremise = loc_numremise;
              EXCEPTION
                 WHEN NO_DATA_FOUND
                 THEN
                    NULL;
              END;
           END IF;
        END IF;

        FOR loc_objet IN fetch_objet (loc_date_trans )
        LOOP
           IF fetch_objet%FOUND
           THEN
              loc_retour := loc_objet.statut;
              EXIT;
           END IF;
        END LOOP;

        RETURN loc_retour;
  END f_statut_noemie;

  FUNCTION F_RESEAU(i_numsin SINISTRE.NUMSIN%TYPE) RETURN VARCHAR2
   IS
   loc_reseau libelle.libelle%TYPE;
  BEGIN
    SELECT pk_libelle.f_lib('RESEAU',ds.reseau)INTO loc_reseau
      FROM sntr_dossier sd, dossier_sante ds
      WHERE sd.numsin_sntr=i_numsin
      AND sd.num_dossier = ds.num_dossier
      AND ds.reseau IS NOT NULL;

    RETURN loc_reseau;
  EXCEPTION
    WHEN OTHERS THEN RETURN NULL;

  END F_RESEAU;
  --Fonction rémontant le total sinistre pour un assuré pour un décaissement
  FUNCTION F_TOT_SIN_PAYE(i_numassu INDIVIDU.NUMINDIV%TYPE,
                          i_numdecaimst DECAISMT.NUMDECAISMT%TYPE,
                          i_mtdecais DECAISMT.MONTANT%TYPE,
                          i_mtdcpt AFFECTATION.MONTANT%TYPE,
                          i_modpmt DECAISMT.MODPMT%TYPE,
                          i_typbene DECOMPTE.TYPBENE%TYPE) RETURN NUMBER
   IS
   loc_mt NUMBER(13,2);
  BEGIN
    IF i_typbene =  1 THEN
     IF i_modpmt = 2 THEN
       SELECT NVL(SUM(r.montant),0) INTO loc_mt
       FROM remise_vire_detail r
       WHERE ( r.numvirement,r.numremise) IN
       (SELECT v.numvirement,v.numremise
       FROM remise_vire_detail v
       WHERE v.numdecaismt = i_numdecaimst);
      ELSE
       loc_mt:=i_mtdecais;
      END IF;
     RETURN loc_mt;

    ELSIF  i_typbene IN (3,4) THEN
      IF i_modpmt = 2 THEN
        --somme des décaissement pour le même bdb de virement et pour le même assuré
       SELECT NVL(SUM(d.montant),0) INTO loc_mt
        FROM decompte dcpt, affectation af, decaismt d, remise_vire_detail vire
        WHERE d.numdecaismt = af.numdecaismt
        AND af.codope=1
        AND dcpt.numdec = af.numaffec
        AND vire.numdecaismt = d.numdecaismt
        AND  vire.numvirement IN (
          SELECT r.numvirement
          FROM remise_vire_detail r
          WHERE r.numdecaismt=i_numdecaimst)
        AND dcpt.numindiv = i_numassu;
        RETURN loc_mt;
      ELSE
        RETURN i_mtdcpt;
      END IF;


    ELSIF i_typbene = 2 THEN
      SELECT SUM(mtreel) INTO loc_mt
      FROM sinistre s, affectation a
      WHERE s.numdec = a.numaffec
      AND a.codope= 1
      AND s.numassu = i_numassu
      AND a.numdecaismt =i_numdecaimst;
      RETURN loc_mt;

    ELSE
      RETURN NULL;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RETURN NULL;

  END F_TOT_SIN_PAYE;

  FUNCTION f_libgar ( I_numfor IN gar_cntrt.numfor%Type )RETURN VARCHAR2 IS
    CURSOR C_gar IS
      Select  libelle  libgar
      From  gar_cntrt
      Where  numfor = I_numfor;
    CURSOR C_grp IS
      Select   grp_gar.libelle  libgar
      From  grp_gar
      Where  grp_gar.numgrpgar = I_numfor;

    L_libgar  Varchar2(80);
  BEGIN
   Open C_gar;
    Fetch C_gar Into L_libgar;
    If ( C_gar%NotFound ) then
      Open C_grp;
      Fetch C_grp Into L_libgar;
      Close C_grp;
    End If;
    Close C_gar;

    Return ( L_libgar );
  END f_libgar;

  /*****************************UTIL***********************************/



FUNCTION F_GET_EXTR_BENE_PROSPECT( l_numindiv individu.numindiv%type,  l_tab_bene EXTR_TAB_BENE_PROSPECT) RETURN EXTR_BENE_PROSPECT
IS
i number;
BEGIN
  --dbms_output.put_line('****************F_GET_EXTR_BENE_PROSPECT*****************'||l_tab_bene.count);
  FOR i IN 1..l_tab_bene.count LOOP
    IF l_tab_bene(i).numindiv = l_numindiv THEN
      --dbms_output.put_line('****************individu trouvé*****************'||l_numindiv);
     RETURN l_tab_bene(i);
    END IF;
  END LOOP;
  RETURN NULL;
    END;

FUNCTION F_GET_EXTR_CONTRACT( l_numgar  ADHESION.NUMGAR%type,  l_tab_contracts EXTR_TAB_CONTRACT_TO_SIGN_UP) RETURN EXTR_CONTRACT_TO_SIGN_UP
IS
i number;
BEGIN
  FOR i in 1..l_tab_contracts.count LOOP
    IF l_tab_contracts(i).numgar = l_numgar THEN
     RETURN l_tab_contracts(i);
    END IF;
  END LOOP;
 RETURN NULL;
END F_GET_EXTR_CONTRACT;

FUNCTION F_GET_EXTR_GRNT( l_numoffre  ADHESION.NUMFOR%type,  l_tab_GRNT EXTR_TAB_GRNT_TO_SIGN_UP) RETURN EXTR_GRNT_TO_SIGN_UP
IS

BEGIN
  --dbms_output.put_line('****************F_GET_EXTR_GRNT*****************l_numoffre ='||l_numoffre);
  FOR i in 1..l_tab_GRNT.count LOOP
    --dbms_output.put_line('****************F_GET_EXTR_GRNT***************** numoffre = '||l_tab_GRNT(i).offre);
    IF l_tab_GRNT(i).offre = l_numoffre THEN
     RETURN l_tab_GRNT(i);
    END IF;
  END LOOP;
 RETURN NULL;
END F_GET_EXTR_GRNT;

--
FUNCTION F_FORMAT ( P_Chaine   IN   VARCHAR2)
  RETURN  VARCHAR2
  IS
  BEGIN

    RETURN UPPER(TRIM(TRANSLATE(P_Chaine,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ-''','AAEEEEIIaaaaeeeeiiouuUUO ')));

  EXCEPTION
    WHEN OTHERS THEN
      RETURN P_Chaine;
  END F_FORMAT;



 -------------------------------------

FUNCTION F_CONSUlT_SOUSBASE(   P_NUMADHE  INDIVIDU.NUMINDIV%type,
                               P_NUMGAR  CONTRAT.NUMGAR%TYPE,
                               P_DATEEFFET   DATE,
                               P_NUMCLI  NUMBER ) RETURN EXTR_PROSPECT
IS


   TYPE TAB_offre IS TABLE OF NUMBER(5) index by binary_integer ;
   T_offre TAB_offre;
   nb_offre NUMBER(5) :=0;

   adhesion_existante number;
   -- Curseur fictif qui permet de boucler sur un adulte un enfant et un conjoint
   CURSOR C_INDIVIDUS(p_numadherent number) IS
     SELECT numindiv, typadr, prenom FROM individu   -- adhérent principal si sont numéro est identifié
     WHERE numindiv = p_numadherent
     AND p_numadherent is not null
     UNION
     SELECT 0 numindiv ,0 typadr, 'adhérent principal'prenom FROM DUAL    -- adhérent principal fictif si le p_numadherent est null
     WHERE p_numadherent IS NULL
     UNION
     SELECT 0 numindiv ,1 typadr, 'conjoint' prenom FROM DUAL  --coinjoint fictif
     UNION
     SELECT 0 numindiv , 2 typadr, 'enfant' prenom FROM DUAL --enfant fictif

     UNION -- On recupére tout les bénéficiaires de la potentielle précédente adhésion fermée
     select numindiv, typadr, prenom                  -- cas de test numindiv 362993 qui a un enfant avec une date de fin différente
     FROM individu
     WHERE p_numadherent is not null
     AND numindiv in (
              SELECT a.numindiv from adhesion a, adhe_cntrt  ac       -- on récupére les adhesions de l'adhérent principal et se bénéficiaires
              WHERE  a.idadhesion = ac.idadhesion
              AND  ac.numadhe = p_numadherent
              and (a.numindiv, a.idadhesion, nvl(a.datper,sysdate) )                 -- en vérifiant pour chaque bénéficiaire que la date de fin de son adhésion correspond a celle de l'assuré principal
                    IN (  SELECT a1.numindiv, ac1.idadhesion, nvl(ac.DATE_FIN_ADHE,sysdate)
                          FROM adhesion a1, adhe_cntrt ac1
                          WHERE ac1.idadhesion = a1.idadhesion
                          AND  ac1.idadhesion IN (
                                  SELECT max(ac3.idadhesion)
                                  FROM adhe_cntrt ac3
                                  where ac3.numadhe =  p_numadherent
                                  )
                        )

              )

   ;


  -- donne tout les contrats de base souscrite par une société
  --ARTGEREP-340 retrait du filtre sur les contrats groupes ouverts
  CURSOR c_contrat_base (i_numcli NUMBER, i_numgar NUMBER)  IS
     WITH EXCLU_BIA as (select F_FIND_VAR('EXCLU_BIA') valeur from dual) -- renvoi l'identifiant de la variable EXCLU_BIA une seule fois
        , BIAEXCLU as (select F_FIND_VAR('BIAEXCLU') valeur from dual) -- Renvoi l'identifiant de la variable BIAEXCLU une saule fois
   SELECT DISTINCT   cr.numgar,
                    cr.refcie,
                    p.siret ,
                    i.NOM as LIB_SOCIETE,
                    pk_libelle.f_lib('ORGN',cr.NUMORG) as ASSUREUR,
                    F_EMETTEUR(NUMORG) as EMETTEUR,
                    F_LBLE('TYP_CONT',cr.TYPE_CONTRAT) AS NATURE,
                    F_LBLE('ET_CONT',PK_HISTO_CONTRAT.F_SEL_ETAT(cr.NUMGAR)) as ETAT,
                    F_LBLE('COLLEGE',cr.COLLEGE) AS COLLEGE,
                    PK_HISTO_CONTRAT.F_SEL_date_effet(cr.NUMGAR) as DATEFF,
                    DECODE(TRUNC(PK_HISTO_CONTRAT.F_SEL_date_resil(cr.NUMGAR))
                    ,TRUNC(sysdate)+1825,null,PK_HISTO_CONTRAT.F_SEL_date_resil(cr.NUMGAR)) as DATE_RESIL,
                    cr.FRACT,
                    cr.DELAI,
                    cr.NUMQUERABLE,
                    cr.NUMCLI,
                    cr.GEST_PREST,
                    cr.GEST_COTIS,
                    decode(cr.MREGL,5,1,2,2,1,5,3) MREGL
  FROM CONTRAT_REF cr ,pers_morale p , individu i
  WHERE
  cr.NUMCLI = i_NUMCLI
  AND numgar= nvl(i_NUMGAR,numgar)
  AND  cr.numcli =  p.numindiv
  AND  p.numindiv = i.numindiv
  AND pk_histo_contrat.f_sel_etat(cr.numgar,  greatest(cr.datsous,sysdate) )=1
  --AND cr.typgar <> 2 -- exclusion des groupes ouverts
  AND nvl(CR.PORTEFEUILLE,0) NOT IN (
                                      9, -- base saisonnier
                                      10,-- option saisonnier
                                      11 -- base plus option saisonnier

                              )
  AND cr.type_contrat = 1 -- contrat Santé
  AND  exists (select 1 from EXCLU_BIA where F_VAL_VAR_ALL(cr.numgar ,EXCLU_BIA.valeur,sysdate) is null)
  AND  exists (select 1 from BIAEXCLU where F_VAL_VAR_ALL(cr.numcli ,BIAEXCLU.valeur,sysdate) is null)
  ;

  -- récuperation des garanties de base d'un contrat base
  CURSOR  c_garantie_base(p_contrat NUMBER ) IS
    select distinct  f.* ,decode(f.obli_bene,2,1,3,2,15,1,19,1,NULL) nb_bene
    from GAR_CNTRT gct, formule f
    WHERE gct.NUMGAR = p_contrat
    AND f.numfor= gct.NUMFOR
    AND gct.valide = 'O'
    AND gct.datapli <> NVL(gct.datper, e2d('01/01/1900'))
    AND f.valide = 'O'
    and f.OBLI_BENE is not null
    AND nvl(f.fin, trunc(sysdate)) >= trunc(sysdate)
    AND f.TYPGAR= 1
    order by f.numfor
    ;


    L_GARANTIE_UNITAIRE         EXTR_GRNT_TO_SIGN_UP; -- Contient les information d'une garantie
    L_TAB_GARANTIE              EXTR_TAB_GRNT_TO_SIGN_UP; -- Contient la liste des garanties souscriptibles
    L_CONTRAT                   EXTR_CONTRACT_TO_SIGN_UP; -- Contient les informations d'un contrat et le tableau de ses garanties
    L_TABLEAU_CONTRAT           EXTR_TAB_CONTRACT_TO_SIGN_UP; -- liste les contrats souscriptibles d'un individu
    L_BENE_PROSPECT             EXTR_BENE_PROSPECT; -- Contient le numéro du béneficiaire et la liste de ses contrats souscriptibles.
    L_TABLEAU_BENE_PROSPECT     EXTR_TAB_BENE_PROSPECT;  -- liste des individus avec leur contrats
    L_PROSPECT_FINAL            EXTR_PROSPECT;

    l_contrat_courant NUMBER;
    l_contrat_prec  NUMBER;
    loc_droit varchar2(5);
    l_nombre_ayant_droit number;
    l_exc_adhesion_existante EXCEPTION;
 BEGIN

  L_TABLEAU_BENE_PROSPECT := new EXTR_TAB_BENE_PROSPECT(null);
  L_TABLEAU_CONTRAT :=new EXTR_TAB_CONTRACT_TO_SIGN_UP(null);
  L_TAB_GARANTIE := new  EXTR_TAB_GRNT_TO_SIGN_UP(null);

  IF P_NUMADHE IS NOT NULL THEN  --RKO M0007092 ARTGEREP_343 amélioration , le contrôle de l'adhés. existante doit etre fait uniquement si l'assuré est renseigné/ car p_numadhe est vide lors de l'appel du flux F_CONTRACT_SIGN_UP
-- verification qu'un individu n'a pas deja une adhésion de base ouverte.
 SELECT COUNT(*)   -- verifie si ma garantie fait partie d'une adhesion pour ce beneficiarire
    INTO adhesion_existante
    FROM ADHESION a, GAR_CNTRT g, formule f
    WHERE a.NUMINDIV  = P_NUMADHE
    AND f.numfor      = a.numfor
    AND f.typgar      = 1    -- garantie de base
    AND a.numgar      = g.numgar
      AND NVL(P_DATEEFFET,sysdate)  BETWEEN a.DATAPLI AND COALESCE(a.DATPER, P_DATEEFFET, sysdate) --RKO M0007092 ARTGEREP_343
      ;
  ELSE
    adhesion_existante :=0;
  END IF;
  IF  adhesion_existante > 0 THEN RAISE l_exc_adhesion_existante; END IF;
  FOR R_INDIVIDU IN C_INDIVIDUS(P_NUMADHE) LOOP   -- individus tous fictifs pour éviter les cas de divorce, enfant décédés etc
    L_TABLEAU_CONTRAT  := new EXTR_TAB_CONTRACT_TO_SIGN_UP(null);
    FOR r_numgar IN c_contrat_base(P_NUMCLI, P_numgar) LOOP  -- récuperation des contrat de base de la société
      L_TAB_GARANTIE := new  EXTR_TAB_GRNT_TO_SIGN_UP(null);
      FOR r_garantie_base  IN c_garantie_base(r_numgar.numgar) LOOP   -- récuperation des garanties du contrat
          loc_droit:= F_DROIT_GAR(R_INDIVIDU.typadr,r_garantie_base.obli_bene,r_garantie_base.numfor, null, l_nombre_ayant_droit); -- on determine le niveau de droit en fonction du typeadr
        IF loc_droit IS NOT NULL THEN   -- controle de doublon
          --gère l'offre uniquement pour les cas autre que type de gar = 1 ou iso base 7
          IF NOT T_offre.EXISTS(r_garantie_base.numfor) THEN
            IF r_garantie_base.obli_bene  IN (1,7,8,9,10,13,16,17,18) THEN    -- les adhesion conjoint/beneficiaire/enfant unique sont aussi facultatif donc sur l'offre Zero
              T_offre(r_garantie_base.numfor):=0;
            ELSE
              nb_offre:=nb_offre+1;
              T_offre(r_garantie_base.numfor):=nb_offre;
            END IF;
          END IF;

          L_GARANTIE_UNITAIRE := new EXTR_GRNT_TO_SIGN_UP(r_garantie_base.numfor,           --NUMFOR
                                                          r_garantie_base.nomgar,           --NOM_GARANTIE
                                                          r_garantie_base.libelle,          --LIBELLE
                                                          r_garantie_base.debut,            --DATE_DEBUT
                                                          r_garantie_base.fin,              --DATE_FIN
                                                          r_garantie_base.obligatoire,      --OBLIGATOIRE
                                                          r_garantie_base.flag_regime,      --FLAG_REGIME
                                                          0,                                --PRIX_GAR
                                                          '',                               --LIB_PRIX_GAR
                                                          NULL,                             --INFO_GAR1
                                                          NULL,                             --INFO_GAR2
                                                          NULL,                             --INFO_GAR3
                                                          nvl(r_garantie_base.ENGAGEMENT,0),       --DUREE_ENGAGEMENT
                                                          loc_droit,                        --CHOIX_GAR
                                                          r_garantie_base.nb_bene,          --NB_BENE_MAX
                                                          T_offre(r_garantie_base.numfor)); --OFFRE

        IF L_TAB_GARANTIE(1) IS NOT NULL THEN
          L_TAB_GARANTIE.extend(1);
        END IF;
        L_TAB_GARANTIE(L_TAB_GARANTIE.count) := L_GARANTIE_UNITAIRE;
      END IF;
      END LOOP GARANTIE;
       IF L_TAB_GARANTIE(1) IS NOT NULL THEN  -- on ne renvoi pas le contrat si aucune garantie n'est souscriptible
         L_CONTRAT := new EXTR_CONTRACT_TO_SIGN_UP(
                                                    r_numgar.numgar,             --NUMGAR           NUMBER(9),
                                                    r_numgar.numgar,             --NUMGAR_REF       NUMBER(9),
                                                    r_numgar.refcie,             --CNTREF_REFCIE    VARCHAR(30),
                                                    r_numgar.refcie,             --REFCIE           VARCHAR2(30),
                                                    r_numgar.assureur,           --ASSUREUR         VARCHAR2(50),
                                                    r_numgar.emetteur,           --EMETTEUR         VARCHAR2(25),
                                                    r_numgar.nature,             --NATURE           VARCHAR2(50),
                                                    r_numgar.etat,               --ETAT             VARCHAR2(45),
                                                    r_numgar.college,            --COLLEGE          VARCHAR2(50),
                                                    sysdate,                     --DATEFFE          DATE,        TODO
                                                    sysdate,                     --DATE_RESIL       DATE,        TODO
                                                    sysdate,                     --DATE_LIMIT_SOUS  DATE,        -
                                                    r_numgar.numcli,             --SOCIETE          NUMBER(9),   -
                                                    r_numgar.LIB_SOCIETE,        --LIB_SOCIETE      VARCHAR2(30),
                                                    r_numgar.siret,              --SIRET            VARCHAR2(15),
                                                    'EUR',                       --LIB_DEVISE       VARCHAR2(45),
                                                    'N',                         --COUVERTCFE       VARCHAR(1),
                                                    r_numgar.fract,              --FRACT            NUMBER(3),
                                                    r_numgar.mregl,              --MODPMT           NUMBER(3),
                                                    r_numgar.delai,             --ECHEANCE         VARCHAR2(20),
                                                    r_numgar.numquerable,        --QUERABLE_NUM     NUMBER(9),
                                                    '',                          --QUERABLE_CIV     VARCHAR(45),
                                                    '',                          --QUERABLE_NOM     VARCHAR(30),
                                                    '',                          --QUERABLE_PRENOM  VARCHAR(30),
                                                    null/*TB_ADRESSE*/,          --QUERABLE_ADRESSE EXTR_ADRESSE_TR,
                                                    r_numgar.numgar,             --CNTRT_BASE       NUMBER(9),
                                                    L_TAB_GARANTIE,              --TAB_GRNT         EXTR_TAB_GRNT_TO_SIGN_UP,
                                                    null,                        --TAB_PORTE        EXTR_TAB_PORTE,
                                                   r_numgar.GEST_COTIS,          --GEST_COTIS       NUMBER(2),
                                                   r_numgar.GEST_PREST           --GEST_PREST       NUMBER(2)
                                                  );
         IF L_TABLEAU_CONTRAT(1) IS NOT NULL THEN
           L_TABLEAU_CONTRAT.extend(1);
         END IF;
         L_TABLEAU_CONTRAT(L_TABLEAU_CONTRAT.count):= L_CONTRAT;
       END IF;
    END LOOP CONTRAT;

    IF nvl(R_INDIVIDU.numindiv,0) = 0 THEN
     SELECT  new EXTR_BENE_PROSPECT( 0,--REC_ADHE_BASE.numindiv,
                                     0,--REC_ADHE_BASE.qualite,
                                     '',--REC_ADHE_BASE.lib_qualite,
                                     'Fictif',--REC_ADHE_BASE.nom,
                                     R_INDIVIDU.prenom,--REC_ADHE_BASE.prenom,
                                     '',--REC_ADHE_BASE.matorg,
                                     R_INDIVIDU.typadr,--i.typadr,--REC_ADHE_BASE.typadr,
                                     L_TABLEAU_CONTRAT)
    INTO L_BENE_PROSPECT FROM dual;
   ELSE
    SELECT  new EXTR_BENE_PROSPECT(  i.numindiv,--REC_ADHE_BASE.numindiv,
                                     i.qualite,--REC_ADHE_BASE.qualite,
                                     F_LBLE('QLTE',i.QUALITE),--REC_ADHE_BASE.lib_qualite,
                                     i.nom,--REC_ADHE_BASE.nom,
                                     i.prenom,--REC_ADHE_BASE.prenom,
                                     i.matorg,--REC_ADHE_BASE.matorg,
                                     TO_NUMBER(F_GET_TRANSCO ('EA','TYPASSU',to_char(i.typadr))),--i.typadr,--REC_ADHE_BASE.typadr, -- on trancode les typ assu pour simplifier les controles
                                     L_TABLEAU_CONTRAT)
    INTO L_BENE_PROSPECT FROM INDIVIDU i
    WHERE NUMINDIV = R_INDIVIDU.numindiv;
    END IF;

      IF L_TABLEAU_BENE_PROSPECT(1) IS NOT NULL THEN
         L_TABLEAU_BENE_PROSPECT.extend(1);
      END IF;
    L_TABLEAU_BENE_PROSPECT(L_TABLEAU_BENE_PROSPECT.count) := L_BENE_PROSPECT;

  END LOOP INDIVIDU;

  L_PROSPECT_FINAL := new  EXTR_PROSPECT(123,null, L_TABLEAU_BENE_PROSPECT);
  return   L_PROSPECT_FINAL;
 EXCEPTION
    WHEN l_exc_adhesion_existante THEN
    RETURN L_PROSPECT_FINAL;
  END F_CONSUlT_SOUSBASE;

FUNCTION        F_ETAT_ADHE_WS (
         a_idadhesion   IN NUMBER,
         a_date      IN DATE,
         a_type in number default 1)

RETURN NUMBER
AS
loc_etat   number default 0;

L_date      Date;
cursor C_histo is
   Select   histo_adhesion.etat,
      histo_adhesion.motif,
      d2j(histo_adhesion.debut)   debut,
      d2j(histo_adhesion.datsai)   datsai,
      idhistoadhe
   From   histo_adhesion
   Where   idadhesion = a_idadhesion
   and   debut <= L_date
   and   etat != 0
   order by
      datsai desc ,
      idhistoadhe desc
 ;
 Cursor C_instance IS
   Select   histo_adhesion.etat,
      histo_adhesion.motif,
      d2j(histo_adhesion.debut)   debut,
      d2j(histo_adhesion.datsai)   datsai,
      idhistoadhe
   From   histo_adhesion
   Where   idadhesion = a_idadhesion
   and   debut <= L_date
   and   Not Exists (
      select   1
      from   histo_adhesion   instance
      where   instance.idadhesion = a_idadhesion
      and   instance.etat != 0
      and debut <L_date
      )
   order by
      datsai desc ,
      idhistoadhe desc
   ;

Cursor C_futur IS
  Select  histo_adhesion.etat,
        histo_adhesion.motif,
        d2j(histo_adhesion.debut) debut,
        d2j(histo_adhesion.datsai)   datsai,
        histo_adhesion.debut date_debut,
        idhistoadhe
    From    histo_adhesion
    Where   idhistoadhe = (select min(idhistoadhe) from histo_adhesion Where idadhesion = a_idadhesion)
  ;
Rec_C_histo   C_histo%Rowtype;
Rec_C_instance   C_instance%Rowtype;
Rec_C_futur C_futur%Rowtype;
BEGIN
loc_etat := 0;
--
Begin
L_date :=a_date;
End;
--
Open C_instance;
fetch C_instance into Rec_C_instance;
If (C_instance%Found) then
   If (a_type=1) Then
      loc_etat := nvl( Rec_C_instance.etat, 0 );
   Elsif (a_type=2) Then
      loc_etat := nvl( Rec_C_instance.motif, 0 );
   Elsif (a_type=3) Then
      loc_etat := nvl( Rec_C_instance.debut, 1 );
   Elsif (a_type=4) Then
      loc_etat := nvl( Rec_C_instance.datsai, 1 );
    Elsif (a_type=5) Then
      loc_etat := Rec_C_instance.idhistoadhe;
   End if;
Else
   Open C_histo;
   Fetch C_histo into Rec_C_histo;
  If (C_histo%Found) then
     --
     If (a_type=1) Then
        loc_etat := nvl( Rec_C_histo.etat, 0 );
     Elsif (a_type=2) Then
        loc_etat := nvl( Rec_C_histo.motif, 0 );
     Elsif (a_type=3) Then
        loc_etat := nvl( Rec_C_histo.debut, 1 );
     Elsif (a_type=4) Then
        loc_etat := nvl( Rec_C_histo.datsai, 1 );
      Elsif (a_type=5) Then
        loc_etat := Rec_C_histo.idhistoadhe;
     End if;
   Else
     Open C_futur;
     Fetch C_futur into Rec_C_futur;
     Close C_futur;
     --cas particulier des adhésions en instance sans état instance, on surcharge
     IF nvl( Rec_C_futur.etat, 0 )=1 AND Rec_C_futur.date_debut > L_date THEN
       If (a_type=1) Then
        loc_etat := 0;
       Elsif (a_type=2) Then
          loc_etat := nvl( Rec_C_futur.motif, 0 );
       Elsif (a_type=3) Then
          loc_etat := d2j(L_date);
       Elsif (a_type=4) Then
          loc_etat := nvl( Rec_C_futur.datsai, 1 );
        Elsif (a_type=5) Then
          loc_etat := Rec_C_futur.idhistoadhe;
       End if;
     ELSE
       If (a_type=1) Then
          loc_etat := nvl( Rec_C_futur.etat, 0 );
       Elsif (a_type=2) Then
          loc_etat := nvl( Rec_C_futur.motif, 0 );
       Elsif (a_type=3) Then
          loc_etat := nvl( Rec_C_futur.debut, 1 );
       Elsif (a_type=4) Then
          loc_etat := nvl( Rec_C_futur.datsai, 1 );
        Elsif (a_type=5) Then
          loc_etat := Rec_C_futur.idhistoadhe;
       End if;
     END IF;
   End if;
   Close C_histo;
End if;
Close C_instance;
--
Return loc_etat;
--
END F_ETAT_ADHE_WS;

/*********************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :  F_WS_LIST_EVENT                                               */
/* Type         :  Public                                                        */
/* Description  :  liste des événements associés à une personne et à un sinistre */
/* paramètres entrants       :  numindiv  Numéro d’individu recherché ,
                                nosin numéro de sinistre                         */
/* Date         :  20/05/2020                                                    */
/* Commentaire  :  Projet P201910104                                             */
/* Retour       :   tableau d'evenemets                                          */
/*********************************************************************************/
FUNCTION F_WS_LIST_EVENT(i_numindiv INDIVIDU.NUMINDIV%TYPE, i_nosin SNTR_PREV.NOSIN%TYPE)
RETURN EXTR_TAB_LIST_EVENT
IS
  CURSOR c_events(p_numindiv NUMBER,p_nosin NUMBER) IS

  --AVEC REGLE : seuls les évènements des sinistres ouverts et clos depuis 6 mois sont remontés dans le flux
  SELECT distinct  r.idrappel,r.etat,r.maj,r.creation,r.entite nosin, r.numassu numindiv
   ,to_number(SUBSTR(F_GET_VALUE_IN_TABLE('Nature', f_get_varchar_splited(';'||chr(10)||chr(13), r.commentaire)),1,1)) nature --recupération du code nature
   ,e2d(F_GET_VALUE_IN_TABLE('Date de début', f_get_varchar_splited(';'||chr(10)||chr(13), r.commentaire))) debut
   ,NULL type_piece
   FROM rappel r, sntr_prev s, histo_sntr_prev histo
   WHERE r.entite= NVL(p_nosin,r.entite)--190010701
   AND r.NUMBENE =NVL(p_numindiv,r.NUMBENE )
   AND r.type=30 --flux add_event
   and r.etat <>2 --demande en attente
   AND s.nosin=NVL(p_nosin,s.nosin)
   AND s.nosin=r.entite
   AND s.nosin =histo.nosin
   AND (histo.saisie,histo.debut) = (--seuls les évènements des sinistres ouverts et clos depuis 6 mois sont remontés dans le flux
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
        AND NOT (h2.etat=1 AND h2.motif=20))
      AND NOT (h.etat=1 AND h.motif=20)
      GROUP BY h.debut
      )
    AND NOT (histo.etat=2 AND histo.motif=10)
    AND NOT (histo.etat=2 AND histo.saisie<add_months(sysdate,-6))

   UNION
    SELECT distinct r.idrappel, r.etat,r.maj,r.creation,r.entite nosin, r.numassu numindiv
    ,to_number(f_get_transco('EA','PJUSTI_EVE',to_number(F_GET_VALUE_IN_TABLE('Type de pièce', f_get_varchar_splited(';'||chr(10)||chr(13), r.commentaire)))))  nature
    ,e2d(F_GET_VALUE_IN_TABLE('Date de début de période', f_get_varchar_splited(';'||chr(10)||chr(13), r.commentaire))) debut
    ,to_number(F_GET_VALUE_IN_TABLE('Type de pièce', f_get_varchar_splited(';'||chr(10)||chr(13), r.commentaire))) type_piece
    FROM rappel r, pieces p, sntr_prev s, histo_sntr_prev histo
    WHERE r.contexte=16
    and r.etat <>2 --demande en attente
    AND p.entite=r.entite
    AND p.entite=NVL(p_nosin,p.entite)
    AND r.numbene=NVL(p_numindiv,r.numbene)
    AND to_number(F_GET_VALUE_IN_TABLE('Type de pièce', f_get_varchar_splited(';'||chr(10)||chr(13), r.commentaire))) in(20,21,22,23,24,25,26,27,28)   --TODO?ou pas? Nature non defini pour code ws 20 DCPT IJ SS  et 22 Maintien salaire
    AND s.nosin=NVL(p_nosin,s.nosin)
    AND s.nosin=r.entite
    AND s.nosin =histo.nosin
    AND (histo.saisie,histo.debut) = (--seuls les évènements des sinistres ouverts et clos depuis 6 mois sont remontés dans le flux
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
        AND NOT (h2.etat=1 AND h2.motif=20))
      AND NOT (h.etat=1 AND h.motif=20)
      GROUP BY h.debut
      )
    AND NOT (histo.etat=2 AND histo.motif=10)
    AND NOT (histo.etat=2 AND histo.saisie<add_months(sysdate,-6))
   ORDER BY nosin,creation ;


--récupérer les liens ged qu'ils soient sur le rappel ou sur le sinistre
  CURSOR c_ged (i_rappel NUMBER) IS
    SELECT iddoc, nomdoc, decode(etat,1,'En attente',2,'Validé','Rejeté') etat
    FROM lien_ged g
    WHERE g.ref_ext =i_rappel;

  loc_tab_list_event  EXTR_TAB_LIST_EVENT;
  loc_tab_event       EXTR_TAB_EVENT;
  loc_tab_doc         EXT_TAB_DOCUMENT;
  loc_nosin           sntr_prev.nosin%TYPE;
  loc_numindiv        individu.numindiv%TYPE;

  loc_etat VARCHAR2(50);

BEGIN
       --initialisation des objets
  loc_tab_list_event := NEW EXTR_TAB_LIST_EVENT (null);
  loc_tab_event      := NEW    EXTR_TAB_EVENT(null);


  loc_nosin:=NULL;
  FOR rec_event IN c_events(i_numindiv,i_nosin) LOOP
    loc_numindiv:=rec_event.numindiv;
    --2 situations possibles,
    --soit l'add_event est en attente de traitement et est motif de cloture => rappel
    --soit l'add_event est traité et à rattacher la cloture ou l'arret et la pièce est positionnée sur le sinistre
    loc_tab_doc        := NEW     EXT_TAB_DOCUMENT(null);

    FOR r_ged IN c_ged(rec_event.idrappel) LOOP
    IF loc_tab_doc(1) IS NOT NULL THEN
       loc_tab_doc.EXTEND(1);
    END IF;
    loc_tab_doc(loc_tab_doc.COUNT) := NEW EXTR_DOCUMENT(r_ged.iddoc,r_ged.nomdoc,null);
    END LOOP;


    IF rec_event.etat in (3,5,6,8) AND trunc(rec_event.maj)=trunc(sysdate) THEN
      loc_etat :='Demande en cours de traitement';
    ELSIF rec_event.etat in (3,5,6,8) AND trunc(rec_event.maj) <> trunc(sysdate) THEN
      loc_etat :='Demande traitée';
    ELSE
      select decode(rec_event.etat,1,'Demande en cours de traitement',/*2,'En attente',*/4,'Rejeté',7,'Un justificatif/information vous a été demandé(e)',null) into loc_etat from dual;   --TODO pour null
    END IF;

    IF i_nosin IS NULL AND NVL(loc_nosin,rec_event.nosin) <> rec_event.nosin THEN  --variation de sinistre
      IF loc_tab_list_event(1) IS NOT NULL THEN
        loc_tab_list_event.EXTEND(1);
      END IF;
      loc_tab_list_event(loc_tab_list_event.COUNT) := NEW EXTR_LIST_EVENT (rec_event.numindiv, loc_nosin,loc_tab_event);
      loc_tab_event      := NEW    EXTR_TAB_EVENT(null);
    END IF;
    loc_nosin := rec_event.nosin;

    IF loc_tab_event(1) IS NOT NULL THEN
      loc_tab_event.EXTEND(1);
    END IF;
    loc_tab_event(loc_tab_event.COUNT) := NEW EXTR_EVENT(rec_event.nature,rec_event.debut,rec_event.creation,loc_etat,loc_tab_doc);

  END LOOP;


  IF loc_tab_list_event(1) IS NOT NULL THEN
    loc_tab_list_event.EXTEND(1);
  END IF;
  loc_tab_list_event(loc_tab_list_event.COUNT) := NEW EXTR_LIST_EVENT (NVL(loc_numindiv,i_numindiv), loc_nosin,loc_tab_event);
  RETURN loc_tab_list_event;
EXCEPTION
   WHEN OTHERS THEN
     PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_WS_LIST_EVENT',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => SQLERRM,
          I_idligne  => 2);
     RETURN  new EXTR_TAB_LIST_EVENT(null);
END F_WS_LIST_EVENT;

  /*********************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :  F_WS_LIST_PREV                                                */
/* Type         :  Public                                                        */
/* Description  :  liste des sinistre associés à une personne                    */
/* paramètres entrants       :  numindiv  Numéro d’individu recherché , son nom, prenom
                                nosin numéro de sinistre
                                numcli,Date Debut ,Date fin ,norisq              */
/* Date         :  20/05/2020                                                    */
/* Commentaire  :  Projet P201910104                                             */
/* Retour       :   tableau de sinistre                                          */
/*********************************************************************************/
  FUNCTION F_WS_LIST_PREV(i_params EXTR_Q_LIST_PREV)
  RETURN EXTR_TAB_LIST_PREV
  IS

  CURSOR C_sntr_prev (p_numporte NUMBER,p_numcli NUMBER,p_numindiv NUMBER,p_nom VARCHAR2,p_prenom VARCHAR2,p_debut DATE,p_fin DATE,p_norisq NUMBER) IS
    SELECT s.nosin,d.numindiv,i.prenom,i.nom,i.datnais,s.survenance,  pk_libelle.f_lib('CAUS',s.cause) cause,
    s.declaration,NVL(s.priscalc,s.prischarge) priscalc, s.norisq,r.idrepartition,
    histo.etat,histo.debut,histo.saisie datsai,  histo.motif,
    pk_libelle.f_lib('HISTO_SITU',histo.etat) lib_etat,lm.libelle lib_motif,lm.sens
    FROM dossier_sinistre d, sntr_prev s, individu i ,repartition r, histo_sntr_prev histo, libelle lm
    WHERE d.iddossier  = s.iddossier
    AND s.nosin = r.nosin
    AND r.valide='O'
    AND s.norisq = NVL(p_norisq,4)
    AND d.numindiv = i.numindiv
    AND lm.mnemo='HISTO_MOTI'
    AND lm.code = histo.motif
    AND s.survenance BETWEEN NVL(p_debut,s.survenance) AND NVL(p_fin,s.survenance)
    AND d.numindiv = NVL(p_numindiv,d.numindiv)
    AND UPPER(nom) =UPPER(nvl(p_nom, nom))
    AND UPPER(prenom)=UPPER(nvl(p_prenom, prenom))
    AND EXISTS (
      SELECT c.numgar FROM contrat c, gar_cntrt g, porte_contrat p
      WHERE g.numgar = c.numgar
      AND g.numfor = r.numfor
      AND c.numcli = NVL(p_numcli,c.numcli)
      AND p.numgar = c.numgar
      AND p.numporte = p_numporte)
    AND histo.nosin =s.nosin
    AND (histo.saisie,histo.debut) = (
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
        AND NOT (h2.etat=1 AND h2.motif=20))
      AND NOT (h.etat=1 AND h.motif=20)
      GROUP BY h.debut
      )
    AND NOT (histo.etat=2 AND histo.motif=10)
    AND NOT (histo.etat=2 AND histo.saisie<add_months(sysdate,-6))
    UNION
    SELECT s.nosin,d.numindiv,i.prenom,i.nom,i.datnais,s.survenance,  pk_libelle.f_lib('CAUS',s.cause) cause,
    s.declaration,NVL(s.priscalc,s.prischarge) priscalc, s.norisq,NULL,
    histo.etat,histo.debut,histo.saisie datsai,  histo.motif,
    pk_libelle.f_lib('HISTO_SITU',histo.etat) lib_etat,lm.libelle lib_motif,lm.sens
    FROM dossier_sinistre d, sntr_prev s, individu i , histo_sntr_prev histo, libelle lm
    WHERE d.iddossier  = s.iddossier
    AND s.norisq = NVL(p_norisq,4)
    AND d.numindiv = i.numindiv
    AND lm.mnemo='HISTO_MOTI'
    AND lm.code = histo.motif
    AND s.survenance BETWEEN NVL(p_debut,s.survenance) AND NVL(p_fin,s.survenance)
    AND d.numindiv = NVL(p_numindiv,d.numindiv)
    AND UPPER(nom) =UPPER(nvl(p_nom, nom))
    AND UPPER(prenom)=UPPER(nvl(p_prenom, prenom))
    AND NOT EXISTS (SELECT r.nosin FROM repartition r WHERE r.nosin = s.nosin AND valide='O')
    AND EXISTS (
    SELECT ad.idadhesion
    FROM adhesion a, adhe_cntrt ad, contrat cr,porte_contrat p
    WHERE a.idadhesion = ad.idadhesion
      AND a.numindiv = i.numindiv
      AND cr.numgar = a.numgar
      AND p.numgar = cr.numgar
      AND cr.numcli = NVL(p_numcli,cr.numcli)
      AND p.numporte = p_numporte
      AND a.datapli <> NVL(a.datper,e2d('01/01/1900'))
      AND s.survenance BETWEEN a.datapli AND NVL(a.datper,s.survenance)
      AND a.typfor = 2
      AND NOT EXISTS(SELECT numde FROM dependance
                    WHERE numde=a.numgar AND role =6 AND sysdate BETWEEN datapli AND NVL(datper,sysdate)))
    AND histo.nosin =s.nosin
    AND (histo.saisie,histo.debut) = (
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
        AND NOT (h2.etat=1 AND h2.motif=20))
      AND NOT (h.etat=1 AND h.motif=20)
      GROUP BY h.debut
      )
    AND NOT (histo.etat=2 AND histo.motif=10)
    AND NOT (histo.etat=2 AND histo.saisie<add_months(sysdate,-6))
    ;


    CURSOR c_pieces(p_nosin sntr_prev.nosin%TYPE)
    IS
    select lg.nomdoc, lg.iddoc, p.nopiece
    FROM pieces p, lien_ged lg
    WHERE p.entite = p_nosin
   AND p.contexte =17
    AND lg.etendue =17
    AND lg.clef=p.idpiece;

  loc_tab_list_prev    EXTR_TAB_LIST_PREV;
  loc_tab_doc          EXTR_TAB_DOCSINPREV;-- EXT_TAB_DOCUMENT;
  loc_histo_etat       EXTR_HISTO_ETAT;


  loc_regl DATE;
  loc_paie DATE;
  loc_etat NUMBER;
  loc_blocage NUMBER;
  loc_nosin   sntr_prev.nosin%TYPE;

BEGIN

  --initialisation des objets
  loc_tab_list_prev := new EXTR_TAB_LIST_PREV(null);
  --loc_tab_doc       := new EXTR_TAB_DOCSINPREV(null);
  loc_histo_etat := new EXTR_HISTO_ETAT(null,null,null,null);

  loc_nosin:=NULL;

  FOR  rec_sntr_prev IN C_sntr_prev (30,i_params.numcli,i_params.numindiv,i_params.nom,i_params.prenom,i_params.debut,i_params.fin,i_params.norisq) LOOP

    --recherche de la dernière de date de paiement
    SELECT MAX(decaismt.datpay) INTO loc_paie
    FROM repartition r, histo_calcul h ,affectation, decaismt
    WHERE r.nosin = rec_sntr_prev.nosin
    AND r.valide='O'
    AND r.idrepartition = h.idrepartition
    AND h.numdec = affectation.numaffec
    AND affectation.codope = 2
    AND decaismt.numdecaismt = affectation.numdecaismt
    AND decaismt.codope =affectation.codope
    AND decaismt.flagpay =1
    AND decaismt.datpay IS NOT NULL
    AND decaismt.REFPMT > 0 ;

    --recherche du dernier jour règlé
    SELECT MAX(fin) INTO loc_regl
    FROM
    (SELECT h.fin
    FROM repartition r, histo_calcul h ,affectation, decaismt
    WHERE r.nosin = rec_sntr_prev.nosin
    AND r.valide='O'
    AND r.idrepartition = h.idrepartition
    AND h.numdec = affectation.numaffec
    AND affectation.codope = 2
    AND decaismt.numdecaismt = affectation.numdecaismt
    AND decaismt.codope =affectation.codope
    AND decaismt.flagpay =1
    AND decaismt.datpay IS NOT NULL
    AND decaismt.REFPMT > 0
    UNION
    SELECT h.fin
    FROM repartition r, histo_calcul h ,affectation,encaismt, compte_client
    WHERE r.nosin = rec_sntr_prev.nosin
    AND r.valide='O'
    AND r.idrepartition = h.idrepartition
    AND h.numdec = affectation.numaffec
    AND affectation.codope = 2
    AND compte_client.numfact  = affectation.numaffec
    AND compte_client.codope   = 2
    AND encaismt.numencaismt = compte_client.numencaismt);

    --valotisation de l'état du sinistre
    loc_etat := F_etat_sntr_prev(rec_sntr_prev.etat,rec_sntr_prev.idrepartition,rec_sntr_prev.nosin,rec_sntr_prev.sens);
    IF i_params.etat IS NOT NULL AND i_params.etat<> loc_etat THEN
      CONTINUE; --filtre sur les états;
    END IF;

    loc_histo_etat := new EXTR_HISTO_ETAT( pk_libelle.f_lib('ETSINPREV',loc_etat),rec_sntr_prev.debut,rec_sntr_prev.datsai,rec_sntr_prev.lib_motif);

   -- loc_tab_doc(loc_tab_doc.count) := new EXTR_DOC_SIN_PREV(rec_sntr_prev.iddoc,rec_sntr_prev.nomdoc,null,rec_sntr_prev.nature);
    --RKO LOT4 CMPLT
    loc_tab_doc        := NEW     EXTR_TAB_DOCSINPREV(null);
    FOR r_piece IN c_pieces(rec_sntr_prev.nosin) LOOP
      IF loc_tab_doc(1) IS NOT NULL THEN
         loc_tab_doc.EXTEND(1);
      END IF;
      loc_tab_doc(loc_tab_doc.COUNT) := NEW EXTR_DOC_SIN_PREV(r_piece.iddoc,r_piece.nomdoc,null,r_piece.nopiece);
    END LOOP;
    --fin RKO LOT4 CMPLT
    --
    IF loc_tab_list_prev(1) IS NOT NULL THEN loc_tab_list_prev.extend(1); END IF;
    loc_tab_list_prev(loc_tab_list_prev.count) := new EXTR_LIST_PREV(rec_sntr_prev.nosin,rec_sntr_prev.numindiv,rec_sntr_prev.nom,rec_sntr_prev.prenom,
                                               rec_sntr_prev.datnais,rec_sntr_prev.survenance,rec_sntr_prev.cause,rec_sntr_prev.declaration,
                                               rec_sntr_prev.priscalc,loc_regl,loc_paie,rec_sntr_prev.norisq,loc_histo_etat,loc_tab_doc);

  END LOOP;
  RETURN loc_tab_list_prev;
EXCEPTION
    WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_WS_LIST_PREV',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => SQLERRM,
          I_idligne  => 2);
    RETURN  new EXTR_TAB_LIST_PREV(null);
END F_WS_LIST_PREV;

  /****************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :  F_WS_LIST_PREV_INFO                                           */
/* Type         :  Public                                                        */
/* Description  :  Listes des informations des sinistres prévoyance :
                - infos du dossier sinistre : n°, survenance, cause,
                   date de déclaration et date de prise en charge assureur,
                   nom et prénom du gestionnaire.
                - infos bénéficiaire sinistre : n°, date embauche, contrat, garantie
                - infos sur l'historique des états du sinistre prévoyance.
                - infos sur les décaissements, décomptes
                    */
/* paramètres entrants       :  numindiv  Numéro d’individu recherché ,
                                numcli numero du souscripteur
                                nosin numéro de sinistre                         */
/* Date         :  09/06/2020                                                    */
/* Commentaire  :  Projet P201910104                                             */
/* Retour       :   EXTR_TAB_LIST_PREV_INFO                                      */
/*********************************************************************************/
  FUNCTION F_WS_LIST_PREV_INFO(i_params EXTR_Q_PREV_INFO)
  RETURN EXTR_TAB_LIST_PREV_INFO
  IS


  CURSOR C_PREV_INFO IS
    SELECT distinct
         dcmt.modpmt
        ,pk_libelle.f_lib('MOPM',dcmt.modpmt) lib_modpmt
        ,dcmt.numdest
        ,dcmt.numdecaismt
        ,TRUNC(F_CPTA_DATE_DECAISMT(dcmt.numdecaismt))        DATPAY
        ,DECODE(dcmt.numdecaismt,NULL,NULL,TO_NUMBER(f_cpta_lib_reglt (9151, dcmt.numdecaismt, 1)))  refpmt
        ,decode(dcmt.modpmt,2,(select SUM(montant) from remise_vire_detail where numvirement= vire.numvirement),af.montant) montant_decaismt
        ,dp.numdec
        ,dp.montant montant_dcpt
        ,ds.iddossier num_dossier
        ,sp.nosin
        ,sp.survenance
        ,sp.declaration
        ,f_nomutil(sp.numutil,2) gestionnaire
        ,pk_libelle.f_lib('CAUS',sp.cause) lib_cause
        ,NVL(NVL(sp.priscalc,sp.prischarge),j.debut)  dat_indemnisat
        ,DECODE(TRIM(sp.info_comp1),NULL,NULL,pk_libelle.f_lib('INF_DS1',sp.info_comp1)) info1 -- M0006722
        ,DECODE(TRIM(sp.info_comp2),NULL,NULL,pk_libelle.f_lib('INF_DS2',sp.info_comp2)) info2 -- M0006722
        ,pk_libelle.f_lib('TYPE_FRAN',gp.type_fran) franchise
        ,r.numfor
        ,r.idrepartition
        --,g.libelle  garantie
        ,hsp.etat
        ,hsp.motif
        ,lm.libelle lib_motif
        ,lm.sens
        ,hsp.debut
        ,pk_libelle.f_lib('HISTO_SITU',hsp.etat) lib_etat
        ,hsp.saisie datsai
        ,i.numindiv
        ,i.nom
        ,i.prenom
        ,i.datnais
        ,i.matorg
        ,ac.numgar
        ,max(adh.datapli) datapli
        ,ar.idarret
        ,pk_libelle.f_lib('TYP_ARRET',ar.type) lib_nature
        ,j.debut DebutPeriode
        ,j.fin FinPeriode
        ,j.fin-j.debut+1 duree
        --,ROUND (SUM (f_total_histo_d (j.idhisto, -2)), 2) mt_arret --faux période ==> montant par idcalcul
        ,ROUND (SUM (f_total_histo_d (h.idcalcul, -2)), 2) mt_arret
        ,ar.base_regime mt_ss
        ,ar.base_autre  mt_autre
        ,ROUND (SUM (f_total_histo_d (j.idhisto, 0)), 2) mtrevalT   --ok
        ,ROUND (SUM (f_total_histo_d (j.idhisto, -3)), 2) mtdeduT    --ok
        ,ROUND (SUM (f_total_histo_d (j.idhisto, -1)), 2) mtprestT --ok = mtbrutT
        ,ROUND (SUM (f_total_histo_d (j.idhisto, -2)), 2) mttotT  --mtnetT --ok
        --les montants jours
        ,ROUND(SUM (f_total_histo_d (j.idhisto, 0))/(j.fin-j.debut+1),2) mtrevalJ --ok
        ,ROUND(SUM (f_total_histo_d (j.idhisto, -3))/(j.fin-j.debut+1),2) mtdeduJ  --ok
        ,ROUND (SUM (f_total_histo_d (j.idhisto, -1))/(j.fin-j.debut+1),2) mtprestJ --ok --mtprestJ =mtbrutJ
        ,ROUND (SUM (f_total_histo_d (j.idhisto, -2))/(j.fin-j.debut+1),2) mttotJ --mtnetJ --Ok
    FROM       dossier_sinistre ds
    INNER JOIN individu             i    ON   i.numindiv       = ds.numindiv
    INNER JOIN sntr_prev            sp   ON   sp.iddossier     = ds.iddossier
    INNER JOIN histo_sntr_prev      hsp  ON   hsp.nosin        = sp.nosin
    INNER JOIN libelle              lm   ON   lm.mnemo         ='HISTO_MOTI'
                                          AND lm.code          = hsp.motif
    INNER JOIN repartition          r    ON   r.nosin          = sp.nosin
                                          AND r.valide         = 'O'
    INNER JOIN adhe_cntrt           ac   ON   ac.idadhesion    = r.idadhesion
    INNER JOIN adhesion             adh  ON   adh.numfor       = r.numfor
                                          AND adh.idadhesion   = r.idadhesion
    INNER JOIN gar_cntrt            gc   ON   gc.numfor        = adh.numfor
                                          AND gc.valide        = 'O'
    INNER JOIN gar_prev             gp   ON   gp.numfor        = adh.numfor
    LEFT OUTER JOIN histo_calcul    h    ON   h.idrepartition  = r.idrepartition
    LEFT OUTER JOIN histo_jours     j    ON   j.idcalcul       = h.idcalcul
    LEFT OUTER JOIN affectation     af   ON   af.numaffec      = h.numdec
                                          AND af.codope        = 2
    LEFT OUTER JOIN decompte_prev   dp   ON   dp.numdec        = af.numaffec
    LEFT OUTER JOIN decaismt        dcmt ON   dcmt.numdecaismt = af.numdecaismt
                                          AND dcmt.codope      = af.codope
                                          AND dcmt.numdest    = NVL(i_params.numcli,dcmt.numdest)
                                          AND TRUNC(F_CPTA_DATE_DECAISMT(dcmt.numdecaismt)) > ADD_MONTHS(SYSDATE,-36)  --règlements des 36 derniers mois
                                          AND dcmt.datpay IS NOT NULL
                                          AND dcmt.MODPMT IN (1,2,7) -- virement et virement manuel   (MOPM)
                                          AND dcmt.REFPMT > 0
                                          AND dcmt.DATPAY IS NOT NULL
                                          AND dcmt.FLAGPAY = 1
    LEFT OUTER JOIN arret           ar  ON ar.nosin = sp.nosin
                                         AND (ar.idarret = h.idcalcul
                                              OR ( h.debut BETWEEN ar.debut AND ar.fin
                                                  AND ar.traite = 'A'
                                                  AND j.montant_d < 0) )
    LEFT OUTER JOIN remise_vire_detail vire ON vire.numdecaismt = dcmt.numdecaismt
    WHERE
        ds.numindiv = NVL(i_params.numindiv,i.numindiv)
    AND sp.nosin    = NVL(i_params.nosin,sp.nosin)
    AND (hsp.saisie,hsp.debut) = (--1ere etap
      SELECT MAX(hsp1.saisie),hsp1.debut FROM histo_sntr_prev hsp1
      WHERE hsp1.debut<= sysdate  AND hsp1.nosin =sp.nosin
      AND hsp1.debut = (
        SELECT MAX(hsp2.debut) FROM histo_sntr_prev hsp2
        WHERE hsp2.debut<= sysdate  AND hsp2.nosin =sp.nosin
        AND NOT (hsp2.etat=1 AND hsp2.motif=20))
      AND NOT (hsp1.etat=1 AND hsp1.motif=20)--motif 20 dossier controle
      GROUP BY hsp1.debut
      )
    AND NOT (hsp.etat=2 AND hsp.motif=10) -- motif 10 erreeur de saisie
    GROUP BY dp.numdec,dcmt.numdest,
    ds.iddossier,sp.nosin,j.debut,j.fin,sp.survenance,sp.declaration,sp.numutil,sp.cause,sp.prischarge,sp.priscalc,sp.info_comp1,sp.info_comp2,gp.type_fran,
    r.numfor,r.idrepartition,hsp.etat,hsp.motif,lm.libelle,lm.sens,hsp.debut,/*ici hps.etat encore*/hsp.saisie,
    i.numindiv,i.nom ,i.prenom,i.datnais,i.matorg,ac.numgar,adh.datapli,
    ar.idarret,ar.type,j.debut,j.fin,ar.base_regime,ar.base_autre,
    dp.montant,dcmt.numdecaismt,af.montant,dcmt.modpmt,j.montant,vire.numvirement
    ORDER BY TRUNC(F_CPTA_DATE_DECAISMT(dcmt.numdecaismt)) desc
            ,f_cpta_lib_reglt (9151, dcmt.numdecaismt, 1)  desc
            ,dp.numdec
            ,sp.nosin  DESC
            ,j.debut
    ;

  /*CURSOR c_idvar(p_nosin NUMBER) IS
    SELECT DISTINCT idvariable
    FROM val_variable WHERE clef =p_nosin--200000802
    --and idvariable in (120,882,1494)
    AND idvariable IN (F_FIND_VAR('DFINPER1'),F_FIND_VAR('DFINPER2'),F_FIND_VAR('DFINPER3'))
  ;*/

  loc_tab_prev_info     EXTR_TAB_LIST_PREV_INFO;
  loc_histo_etat        EXTR_HISTO_ETAT;
  loc_tab_maintien      EXTR_TAB_MAINTIEN;
  loc_tab_dcpt          EXTR_TAB_DCPT_PREV_INFO;
  loc_tab_arret         EXTR_TAB_ARRET;
  loc_tab_period        EXTR_TAB_PERIOD_PREV;
  loc_tab_dcsmt_prev    EXTR_TAB_DECSMNT_PREV ;


  loc_nbenf             NUMBER;
  loc_brut_an           NUMBER;
  loc_net_an            NUMBER;
  loc_franchise         VARCHAR2(1500);
  loc_garantie          VARCHAR2(2000);
  loc_note_frml_prest   VARCHAR2(2000);
  loc_note_frml_reval   VARCHAR2(2000);

  loc_fin_maint_sal     DATE;

  loc_numdecaismt       decaismt.numdecaismt%TYPE;
  loc_numdec            decompte_prev.numdec%TYPE;
  loc_nosin             sntr_prev.nosin%TYPE;
  loc_arret             arret.idarret%TYPE;
  loc_etat              NUMBER;
  loc_regl              DATE;
  loc_blocage           NUMBER;

  BEGIN
    --Initialisation des objets
    loc_tab_prev_info     := new EXTR_TAB_LIST_PREV_INFO(null);
    loc_histo_etat         := new EXTR_HISTO_ETAT(null,null,null,null);
    loc_tab_maintien      := new  EXTR_TAB_MAINTIEN (null);
    loc_tab_dcpt          := new EXTR_TAB_DCPT_PREV_INFO(null);
    loc_tab_arret         := new  EXTR_TAB_ARRET(null);
    loc_tab_period        := new EXTR_TAB_PERIOD_PREV(null);
    loc_tab_dcsmt_prev    := new EXTR_TAB_DECSMNT_PREV(null);

    IF i_params.numindiv IS NULL OR i_params.nosin IS NULL THEN
    --on ne renvoie rien
     RETURN new EXTR_TAB_LIST_PREV_INFO(null);
    END IF;

    loc_numdecaismt :=NULL;
    loc_numdec      :=NULL;
    loc_arret       :=NULL;
    loc_nosin       :=NULL;
    --loc_nomcli      :=NULL;
    /*structure du flux*/
    --sinistre
    --  décaissement
    --    décompte
    --      arret
    --        periode


    FOR R_PREV_INFO IN C_PREV_INFO LOOP
      --cesure sur sinistre
      --dbms_output.put_line('SIN nb :'||loc_tab_prev_info.COUNT ||'-'||R_PREV_INFO.nosin||'-'||loc_nosin);
      IF NVL(loc_nosin,0) <> R_PREV_INFO.nosin OR loc_tab_prev_info(1) IS  NULL THEN
        IF loc_tab_prev_info.COUNT = 1 THEN
          --dbms_output.put_line('INIT SIN nb :'||loc_tab_sin_prev.COUNT ||'-'||r_dcpt_prev.nosin||'-'||loc_nosin);
          loc_histo_etat := new EXTR_HISTO_ETAT(null,null,null,null);
          loc_tab_maintien := new  EXTR_TAB_MAINTIEN (null);
          loc_tab_dcpt := new EXTR_TAB_DCPT_PREV_INFO(null);
          loc_tab_arret :=new EXTR_TAB_ARRET(null);
          loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
          loc_numdecaismt :=NULL;
          loc_numdec      :=NULL;
          loc_arret       :=NULL;
        ELSE
          --dbms_output.put_line('MAJ tab période du SIN '||loc_nosin);
          loc_tab_prev_info(loc_tab_prev_info.COUNT).Decaissement := loc_tab_dcsmt_prev;
        END IF;

        --création sans le sous objet
        IF loc_tab_prev_info(1) IS NOT NULL THEN
          loc_tab_prev_info.extend(1);
        END IF;

        loc_brut_an :=to_number(F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALANNUEL'),sysdate),'999999.99');--TA+TB+TC
        loc_net_an :=to_number(NVL(F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALNETKC'),sysdate),F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALNETKNC'),sysdate)),'999999.99');
        IF loc_net_an IS NULL THEN
          loc_net_an:=to_number(F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALNET12M'),sysdate),'999999.99');
        END IF;
        loc_nbenf:=to_number(F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('NBENFGAR'),sysdate),'999999.99');

        --(*) TA = 23885.3 retour à la ligne TB = 0 retour à la ligne TC = 0 retour à la ligne et saut de page Franchise : Continue contrôlée ;
        IF F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALREFAM'),sysdate) IS NOT NULL THEN
          loc_franchise := '(*) TA = '
                        || TO_CHAR(to_number(F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALREFAM'),sysdate),'999999.99'),'FM999999990.00')
                        ||' euros'
                        ||CHR(13)||CHR(10);
        ELSE
          loc_franchise := '(*) TA = non déterminée'
                        ||CHR(13)||CHR(10);
        END IF;
        IF F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALREFBM'),sysdate) IS NOT NULL THEN -- BCO M0006721
          loc_franchise := loc_franchise
                        ||'TB = '
                        || TO_CHAR(to_number(F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALREFBM'),sysdate),'999999.99'),'FM999999990.00')
                        ||' euros' -- char € xml
                        ||CHR(13)||CHR(10);
        ELSE
          loc_franchise := loc_franchise
                        ||'TB = non déterminée'
                        ||CHR(13)||CHR(10);
        END IF;
        IF F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALREFCM'),sysdate) IS NOT NULL THEN -- BCO M0006721
          loc_franchise := loc_franchise
                        ||'TC = '
                        ||TO_CHAR(to_number(F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('SALREFCM'),sysdate),'999999.99'),'FM999999990.00')
                        ||' euros'
                        ||CHR(13)||CHR(10);
        END IF;
        loc_franchise := loc_franchise
                        ||CHR(13)||CHR(10)
                        ||'Franchise : '||r_prev_info.franchise;


        loc_note_frml_prest  :=F_get_note_frml_prest(r_prev_info.numfor);
        loc_note_frml_reval  :=F_get_note_frml_reval(r_prev_info.numfor);

        loc_garantie := substr(loc_note_frml_prest||loc_note_frml_reval,0,1000);

        --TODO en dernier --> boucle sur la variable dans val_variable et prendre date de fin de maintien ? oui
        ---- val_var =DFINPER1(pr 1er tour du tableau de maint colonne valeur) ou 2 (pour 2ieme tour ainsi de suite)
        --FOR r_idval IN c_idvar (r_prev_info.nosin) LOOP
          IF loc_tab_maintien(1) IS NOT NULL THEN
            loc_tab_maintien.extend(1);
          END IF;

        BEGIN
        IF F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('DFINPER1'),sysdate) IS NOT NULL THEN
          loc_fin_maint_sal :=to_date(F_VAL_VAR_ALL(r_prev_info.nosin,F_FIND_VAR('DFINPER1'),sysdate),'ddmmyyyy');--fin_maintien = valeur de val_variable ok
        END IF;
        EXCEPTION
          WHEN OTHERS THEN loc_fin_maint_sal := NULL;
        END;
          /*BEGIN
          IF F_VAL_VAR_ALL(r_prev_info.nosin,r_idval.idvariable,sysdate) IS NOT NULL THEN
            loc_fin_maint_sal :=to_date(F_VAL_VAR_ALL(r_prev_info.nosin,r_idval.idvariable,sysdate),'ddmmyyyy');--fin_maintien = valeur de val_variable ok
          END IF;
          EXCEPTION
            WHEN OTHERS THEN loc_fin_maint_sal := NULL;
          END;*/

          loc_tab_maintien(loc_tab_maintien.COUNT) := new EXTR_MAINTIEN(null,loc_fin_maint_sal,null);--TODO MAINTIEN (debut, fin et valeur)
       -- END LOOP;--r_idval

        --valotisation de l'état du sinistre
        loc_etat := F_etat_sntr_prev(r_prev_info.etat,r_prev_info.idrepartition,r_prev_info.nosin,r_prev_info.sens);

        loc_histo_etat := new EXTR_HISTO_ETAT(substr(pk_libelle.f_lib('ETSINPREV',loc_etat),0,50),r_prev_info.debut,r_prev_info.datsai,substr(r_prev_info.lib_motif,0,50));

        loc_tab_prev_info(loc_tab_prev_info.COUNT) := new  EXTR_LIST_PREV_INFO(R_PREV_INFO.nosin,R_PREV_INFO.numindiv,F_GET_ANCIENNETE(r_prev_info.numindiv),
                                                                              r_prev_info.datapli,loc_nbenf,substr(r_prev_info.gestionnaire,0,60), r_prev_info.declaration, r_prev_info.survenance,
                                                                              r_prev_info.dat_indemnisat, substr(r_prev_info.lib_cause,0,50),substr(r_prev_info.info1,0,100), substr(r_prev_info.info2,0,100),
                                                                              r_prev_info.numfor, r_prev_info.numgar,loc_histo_etat, loc_brut_an,loc_net_an, loc_tab_maintien,
                                                                              substr(loc_franchise,0,1000),loc_garantie, NULL);
      END IF;
      loc_nosin := R_PREV_INFO.nosin;
      --RG si le décaissement n'est pas payé, on affiche pas les périodes en cours concernées (M0006732)
      IF r_prev_info.DATPAY IS NULL THEN
        CONTINUE;
      END IF;
      --cesure decaissement
      IF NVL(loc_numdecaismt,r_prev_info.refpmt) <> r_prev_info.refpmt OR loc_tab_dcsmt_prev(1) IS NULL THEN
        IF loc_tab_dcsmt_prev(1) IS NULL THEN
          --dbms_output.put_line('INIT DECAIS nb :'||loc_tab_dcsmt_prev.COUNT ||'-'||r_prev_info.numdecaismt||'-'||loc_numdecaismt);
          loc_tab_dcpt := new EXTR_TAB_DCPT_PREV_INFO(null);

        ELSE
         --  dbms_output.put_line('MAJ tab DCPT du decais '||'-'||r_prev_info.numdecaismt||'-'||loc_numdecaismt);
           loc_tab_arret(loc_tab_arret.COUNT).periode := loc_tab_period;
           loc_tab_dcpt(loc_tab_dcpt.COUNT).arret := loc_tab_arret;
           loc_tab_dcsmt_prev(loc_tab_dcsmt_prev.COUNT).decompte := loc_tab_dcpt;
           loc_tab_dcpt := new EXTR_TAB_DCPT_PREV_INFO(null);
           loc_tab_arret :=new EXTR_TAB_ARRET(null);
           loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
           loc_numdec      :=NULL;
           loc_arret       :=NULL;
        END IF;
        --initialisation
        IF loc_tab_dcsmt_prev(1) IS NOT NULL THEN
          loc_tab_dcsmt_prev.extend(1);
        END IF;
       -- dbms_output.put_line('Creation DECAIS nb :'||r_prev_info.numdecaismt||'-'||loc_numdecaismt);
        loc_tab_dcsmt_prev(loc_tab_dcsmt_prev.COUNT)   := new EXTR_DECSMNT_PREV(r_prev_info.refpmt,r_prev_info.numdecaismt,
                                                                                 r_prev_info.montant_decaismt,r_prev_info.lib_modpmt, r_prev_info.datpay,NULL);

      END IF;
      loc_numdecaismt := r_prev_info.refpmt;

      --cesure sur decompte
      IF NVL(loc_numdec,r_prev_info.numdec) <> r_prev_info.numdec OR loc_tab_dcpt(1) IS NULL THEN
        IF  loc_tab_dcpt(1) IS NULL THEN
          --dbms_output.put_line('INIT DCPT nb :'||loc_tab_dcpt.COUNT ||'-'||r_prev_info.numdec||'-'||loc_numdec);
          loc_tab_arret   := new EXTR_TAB_ARRET(null);
          loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
        ELSE
           --dbms_output.put_line('MAJ tab ARR du dcpt '||loc_numdec);
          loc_tab_arret(loc_tab_arret.COUNT).periode := loc_tab_period;
          loc_tab_dcpt(loc_tab_dcpt.COUNT).arret := loc_tab_arret;
          loc_tab_arret :=new EXTR_TAB_ARRET(null);--rko 30/06
          loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);--rko 30/06
        END IF;

        IF loc_tab_dcpt(1) IS NOT NULL THEN
          loc_tab_dcpt.extend(1);
        END IF;
       -- dbms_output.put_line('Creation DCPT nb :'||r_prev_info.numdec||'-'||loc_numdec);
        loc_tab_dcpt(loc_tab_dcpt.COUNT) := new  EXTR_DCPT_PREV_INFO(r_prev_info.numdec,r_prev_info.montant_dcpt,NULL);
        loc_arret       :=NULL;
      END IF;
      loc_numdec := r_prev_info.numdec;


      --cesure sur arret
     -- dbms_output.put_line('ARR nb :'||loc_tab_arret.COUNT ||'-'||loc_tab_arret.idarret||'-'||loc_arret);
      IF NVL(loc_arret,0) <> r_prev_info.idarret OR loc_tab_arret(1) IS  NULL THEN  -- BCO M0006725
        IF loc_tab_arret(1) IS  NULL THEN
         -- dbms_output.put_line('INIT ARR nb :'||loc_tab_arret.COUNT ||'-'||r_prev_info.idarret||'-'||loc_arret);
          loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
        ELSE
         -- dbms_output.put_line('MAJ tab période du ARR '||loc_arret);
          loc_tab_arret(loc_tab_arret.COUNT).periode := loc_tab_period;
          loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);    -- BCO M0006725
        END IF;

        --création sans le sous objet
        IF loc_tab_arret(1) IS NOT NULL THEN
          loc_tab_arret.extend(1);
        END IF;
        loc_tab_arret(loc_tab_arret.COUNT)   := new EXTR_ARRET(substr(r_prev_info.lib_nature,0,45),r_prev_info.DebutPeriode,r_prev_info.FinPeriode,
                                                                    r_prev_info.mt_arret,r_prev_info.mt_ss,r_prev_info.mt_autre,null);

           /* EXTR_ARRET
            Nature  VARCHAR2(45),
   Debut   DATE,
   Fin     DATE,
   MtArret NUMBER(11,2),
   IJSS    NUMBER(11,2),
   AR      NUMBER(11,2) ,
   Periode   EXTR_TAB_PERIOD_PREV
 )
           */
      END IF;
      loc_arret := r_prev_info.idarret;

      IF loc_tab_period(1) IS NOT NULL THEN
        loc_tab_period.extend(1);
      END IF;
      loc_tab_period(loc_tab_period.COUNT) := new  EXTR_PERIOD_PREV (substr(r_prev_info.lib_nature,0,45),r_prev_info.DebutPeriode,r_prev_info.FinPeriode,r_prev_info.duree
                                                                     ,r_prev_info.mtprestJ,r_prev_info.mttotJ,r_prev_info.mtrevalJ,r_prev_info.mtdeduJ,r_prev_info.mtprestT
                                                                     ,r_prev_info.mttotT,r_prev_info.mtrevalT,r_prev_info.mtdeduT);

/*Nature          VARCHAR2(45),
   DebutPeriode    DATE,
   FinPeriode      DATE,
   Nbjour          NUMBER(4),

   MtBrutJ         NUMBER(11,2),
   MtNetJ          NUMBER(11,2),
   MtRevalJ        NUMBER(11,2),
   MtDeduJ         NUMBER(11,2),

   MtBrutT         NUMBER(11,2),
   MtNetT          NUMBER(11,2),
   MtRevalT        NUMBER(11,2),
   MtDeduT         NUMBER(11,2)
 )
*/
    END LOOP;
    IF loc_tab_period(1).nature IS NOT NULL THEN
      loc_tab_arret(loc_tab_arret.COUNT).periode := loc_tab_period;
      loc_tab_dcpt(loc_tab_dcpt.COUNT).arret := loc_tab_arret;
      loc_tab_dcsmt_prev(loc_tab_dcsmt_prev.COUNT).decompte := loc_tab_dcpt;
      loc_tab_prev_info(loc_tab_prev_info.COUNT).Decaissement := loc_tab_dcsmt_prev;
    END IF;
    loc_tab_dcpt := new EXTR_TAB_DCPT_PREV_INFO(null);
    loc_tab_arret :=new EXTR_TAB_arret(null);
    loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
    loc_numdec      :=NULL;
    loc_nosin       :=NULL;


    RETURN loc_tab_prev_info;

   EXCEPTION
   WHEN OTHERS THEN
 -- dbms_output.put_line('Err :'||SQLERRM);
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_WS_LIST_PREV_INFO',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => SQLERRM,
        I_idligne  => 2);
    RETURN  new EXTR_TAB_LIST_PREV_INFO(null);

  END F_WS_LIST_PREV_INFO;

/***************************************************************************/

  FUNCTION F_etat_sntr_prev ( p_etat histo_sntr_prev.etat%TYPE, p_idrepartition repartition.idrepartition%TYPE, p_nosin SNTR_PREV.NOSIN%TYPE, p_sens libelle.sens%TYPE)
  RETURN NUMBER
  IS

    v_regl               DATE;
    v_etat               NUMBER;
    v_blocage            NUMBER;

      /*  Etats des sinistres prévoyance
      -1 - Indemnisé : ouvert - aucune pièce bloquante et avec au moins une indemnisation
      -2 - A l’étude : les dossiers reçus dans la corbeille et non traité par le gestionnaire.
           C’est les sinistres ouverts qui n’ont pas de souscripteur dans le bloc correspondant
           (la coche garantie n’est pas été effectué)
      -3 - Complet : ouvert aucune pièce bloquante et non indemnisé
      -4 - Bloqué : ouvert mais avec au pièces une pièce bloquante non réceptionnée ni annulée
      -5 - Clos : fermé inférieur à 6 mois
      */
  BEGIN

    SELECT MAX(fin) INTO v_regl
    FROM
    (SELECT h.fin
    FROM repartition r, histo_calcul h ,affectation, decaismt
    WHERE r.nosin = p_nosin--rec_sntr_prev.nosin
    AND r.valide='O'
    AND r.idrepartition = h.idrepartition
    AND h.numdec = affectation.numaffec
    AND affectation.codope = 2
    AND decaismt.numdecaismt = affectation.numdecaismt
    AND decaismt.codope =affectation.codope
    AND decaismt.flagpay =1
    AND decaismt.datpay IS NOT NULL
    AND decaismt.REFPMT > 0
    UNION
    SELECT h.fin
    FROM repartition r, histo_calcul h ,affectation,encaismt, compte_client
    WHERE r.nosin = p_nosin--rec_sntr_prev.nosin
    AND r.valide='O'
    AND r.idrepartition = h.idrepartition
    AND h.numdec = affectation.numaffec
    AND affectation.codope = 2
    AND compte_client.numfact  = affectation.numaffec
    AND compte_client.codope   = 2
    AND encaismt.numencaismt = compte_client.numencaismt);

  --valorisation de l'état du sinistre

    IF p_etat = 2 THEN
      v_etat := 5;
    ELSIF p_etat = 1 THEN
      SELECT count(idpiece) INTO v_blocage
        FROM pieces
       WHERE NVL (pieces.bloc, 'N') = 'O'
         AND pieces.daterecep IS NULL
         AND pieces.datannul  IS NULL
         AND pieces.dateavis  IS NOT NULL
         AND pieces.idrepartition = p_idrepartition
         AND pieces.entite = p_nosin
         AND NVL(DATEREL,DATEAVIS) > add_months(sysdate,-12) -- datant de moins d'un an
         AND pieces.contexte      IN (15,17);

      IF v_blocage > 0 THEN v_etat:=4;
      ELSIF v_blocage = 0 AND v_regl IS NOT NULL THEN  v_etat:=1;
      -- p_idrepartition est passée à NULL si :
      --     - Il n'y a pas de répartition
      --     - il n'y a pas de répartition "cochée" (valide = 'O')
      ELSIF v_blocage = 0 AND v_regl IS NULL AND p_sens =30 AND p_idrepartition IS NULL THEN  v_etat := 2;
      ELSE v_etat:=3;
      END IF;
    END IF;
  RETURN v_etat;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN v_regl :=NULL;

  END F_etat_sntr_prev;

  /*********************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :  F_GET_NOTE_FRML_PREST                                         */
/* Type         :  Public                                                        */
/* Description  :  renvoi le texte présent dans le bloc note de la formule de
                    calcul de la garantie pour la prestation de base
        ecran gp09 puis F10--> ecran va05 puis F11 pour afficher le bloc note    */
/* paramètres entrants       :  numéro de garantie                               */
/* Date         :  20/05/2020                                                    */
/* Commentaire  :  Projet P201910104                                             */
/* Retour       :   chaine de caractère                                         */
/*********************************************************************************/
  FUNCTION F_get_note_frml_prest(p_numfor repartition.numfor%TYPE ) RETURN VARCHAR2 IS

    CURSOR c_notes IS
    SELECT texte FROM post_it
    WHERE clef=(select idformule from frml_prest where numfor=p_numfor AND valide='O' AND fin is null AND etendue =14) order by numligne;

    cursor c_val_variab(i_numgar number) IS
    select * from val_variable where clef=i_numgar and fin is null;

    loc_numgar gar_cntrt.numgar%TYPE;
    loc_nom_var VARCHAR2(20);
    loc_result  VARCHAR2(2000) :='';
  BEGIN
   select numgar into loc_numgar
   from gar_cntrt where numfor=p_numfor;

   FOR r_note IN c_notes LOOP
      loc_result := loc_result||r_note.texte||CHR(13)||CHR(10);  --BCO M0006721
   END LOOP;
   FOR r_val_variab IN c_val_variab(loc_numgar) LOOP
    select nom_variable into loc_nom_var
    from def_variable
    where idvariable=r_val_variab.idvariable;

    loc_result := Replace(loc_result,'$'||loc_nom_var||'(2)'||'x',r_val_variab.valeur);
   END LOOP;
  RETURN loc_result;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN loc_result :=NULL;

  END F_get_note_frml_prest;
 /*********************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :  F_GET_NOTE_FRML_REVAL                                         */
/* Type         :  Public                                                        */
/* Description  :  renvoi le texte présent dans le bloc note de la formule de
                    calcul de la garantie pour la revalorisation
            ecran gp09 puis F10 -->ecran va05 puis F11 pour afficher le bloc note */
/* paramètres entrants       :  numéro de garantie                               */
/* Date         :  20/05/2020                                                    */
/* Commentaire  :  Projet P201910104                                             */
/* Retour       :   chaine de caractère                                         */
/*********************************************************************************/

  FUNCTION F_get_note_frml_reval(p_numfor repartition.numfor%TYPE ) RETURN VARCHAR2 IS


    CURSOR c_notes IS
    SELECT texte FROM post_it
    WHERE clef=(select idformule from frml_reval where numfor=p_numfor AND valide='O' AND fin is null AND etendue =14) order by numligne;

    cursor c_val_variab(i_numgar number) IS
    select * from val_variable where clef=i_numgar and fin is null;

    loc_numgar gar_cntrt.numgar%TYPE;
    loc_nom_var VARCHAR2(20);
    loc_result  VARCHAR2(2000) :='';
  BEGIN
    select numgar into loc_numgar
    from gar_cntrt where numfor=p_numfor;

    FOR r_note IN c_notes LOOP
      loc_result := loc_result||r_note.texte||CHR(13)||CHR(10); --BCO M0006721
    END LOOP;

    FOR r_val_variab IN c_val_variab(loc_numgar) LOOP
      select nom_variable into loc_nom_var
      from def_variable
      where idvariable=r_val_variab.idvariable;

      loc_result := Replace(loc_result,'$'||loc_nom_var||'(2)'||'x',r_val_variab.valeur);
    END LOOP;
  RETURN loc_result;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN loc_result :=NULL;

--DBMS_OUTPUT.PUT_LINE('resul'||loc_result);
  END F_get_note_frml_reval;

  /****************************************************************************/

  /* FUNCTION                                                                    */
/* Nom          :  F_GET_ANCIENNETE                                              */
/* Type         :  Public                                                        */
/* Description  :  Permet de recuperer la date d'ancienneté disponible sur PV36B */
/* paramètres entrants       :  numindiv  Numéro d’individu recherché ,
                                nosin numéro de sinistre
                                numcli numero du souscripteur                    */
/* Date         :  09/06/2020                                                    */
/* Commentaire  :  Projet P201910104                                             */
/* Retour       :   Date                                                         */
  /****************************************************************************/

  FUNCTION F_GET_ANCIENNETE (p_numindiv NUMBER) RETURN DATE
    IS

    loc_debut      DATE;
    loc_debut2     DATE;

    loc_anciennete   DATE;

  BEGIN

    -- Recherche de la date d'entrée du salarié dans la société
    BEGIN
      SELECT E2D( MAX(a.debutc))
        INTO loc_debut
        FROM affil_porte a
       WHERE a.numindiv = p_numindiv;
    EXCEPTION
      WHEN OTHERS THEN
        loc_debut:=NULL;
    END;
    --
    -- Recherche de la date de souscription du salarié au contrat prévoyance
    BEGIN
      SELECT MAX(a.date_adhe)
        INTO loc_debut2
        FROM adhe_cntrt a
       WHERE a.numadhe = p_numindiv;
    EXCEPTION
      WHEN OTHERS THEN
        loc_debut2:=NULL;
    END;
    -- déduction de la date d'anciennté de l'assuré
    IF (NVL(loc_debut,loc_debut2)) > (NVL(loc_debut2,loc_debut)) THEN
      loc_anciennete := (NVL(loc_debut2,loc_debut));
    ELSE
      loc_anciennete := (NVL(loc_debut,loc_debut2));
    END IF;

    RETURN loc_anciennete;

     EXCEPTION
      WHEN OTHERS THEN
        loc_anciennete :=NULL;
        PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_GET_ANCIENNETE',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => SQLERRM,
          I_idligne  => 2);
      RETURN  loc_anciennete;

  END F_GET_ANCIENNETE;



  /****************************************************************************/
  /* FUNCTION                                                                    */
/* Nom          :  F_WS_LIST_DCPT_PREV                                           */
/* Type         :  Public                                                        */
/* Description  :  Liste les decomptes des sinistres prévoyances                 */
/* paramètres entrants       :  numéro de la société,  date de debut,
                            date de fin, numéro de sinistre, numéro de l'individu */
/* Date         :  09/06/2020                                                    */
/* Commentaire  :  Projet P201910104                                             */
/* Retour       : tableau de décompte                                            */
  /*****************************************************************************/
   FUNCTION F_WS_LIST_DCPT_PREV(i_params EXTR_Q_DCPT_PREV)
  RETURN EXTR_TAB_LIST_DCPT_PREV
  IS
    loc_tab_period        EXTR_TAB_PERIOD_PREV;
    loc_tab_sin_prev      EXTR_TAB_SIN_PREV;
    loc_tab_dcpt          EXTR_TAB_DCPT_PREV;
    loc_tab_decais_prev   EXTR_TAB_DECAIS_PREV;
    loc_tab_lst_dcpt_prev EXTR_TAB_LIST_DCPT_PREV;

    CURSOR C_DCPT_PREV IS
    SELECT distinct
      decaismt.modpmt
      ,decaismt.numdest
      ,TRUNC(F_CPTA_DATE_DECAISMT(decaismt.numdecaismt))        DATPAY
      ,to_number(f_cpta_lib_reglt (9151, decaismt.numdecaismt, 1))         refpmt
      ,decode(decaismt.modpmt,2,(select SUM(montant) from remise_vire_detail where numvirement= vire.numvirement),affectation.montant) montant_decaismt
      ,decompte_prev.numdec
      ,decompte_prev.montant montant_dcpt--4ieme etape
      ,r.nosin
      ,i.numindiv
      ,i.nom
      ,i.prenom
      ,i.datnais
      ,i.matorg
      ,ac.numgar
      ,c.college
      ,c.Refcie
      ,c.numcli
      ,f_nom(c.numcli) nomcli
      ,pk_libelle.f_lib('TYP_ARRET',ar.type) lib_nature
      --,ar.type as nature
      ,j.debut DebutPeriode
      ,j.fin   FinPeriode
      ,j.fin-j.debut+1 duree
      ,ROUND (SUM (f_total_histo_d (j.idhisto, 0)), 2) mtrevalT
      ,ROUND (SUM (f_total_histo_d (j.idhisto, -3)), 2) mtdeduT
      ,ROUND (SUM (f_total_histo_d (j.idhisto, -1)), 2) mtBrutT
      ,ROUND (SUM (f_total_histo_d (j.idhisto, -2)), 2) mtNetT
      --les montants jours
      ,ROUND(SUM (f_total_histo_d (j.idhisto, 0))/(j.fin-j.debut+1),2) mtrevalJ
      ,ROUND(SUM (f_total_histo_d (j.idhisto, -3))/(j.fin-j.debut+1),2) mtdeduJ
      ,ROUND (SUM (f_total_histo_d (j.idhisto, -1))/(j.fin-j.debut+1),2) mtBrutJ
      ,ROUND (SUM (f_total_histo_d (j.idhisto, -2))/(j.fin-j.debut+1),2) mtNetJ
    FROM  repartition r,histo_calcul h, histo_jours j ,
    decompte_prev, affectation,
    individu i, dossier_sinistre ds, sntr_prev sp,
    adhe_cntrt ac, contrat c, arret ar,
    decaismt
    left outer join remise_vire_detail vire on ( vire.numdecaismt = decaismt.numdecaismt)
    WHERE  r.valide='O'
    AND r.idrepartition = h.idrepartition
    AND h.numdec = affectation.numaffec
    AND h.idcalcul = j.idcalcul
    AND decaismt.codope = 2
    AND decaismt.codope =affectation.codope
    AND decaismt.datpay IS NOT NULL
    AND decaismt.MODPMT IN  (1,2,7) -- virement et virement manuel   (MOPM)
    AND decaismt.REFPMT > 0
    AND decaismt.DATPAY IS NOT NULL
    AND decaismt.FLAGPAY =1
    AND affectation.numaffec = decompte_prev.numdec
    AND affectation.numdecaismt = decaismt.numdecaismt
    AND i.numindiv= ds.numindiv--1ere etap
    AND ds.numindiv= NVL(i_params.numindiv,i.numindiv)
    AND decaismt.numdest= NVL(i_params.numcli,decaismt.numdest)
    AND sp.nosin=NVL(i_params.nosin,sp.nosin)
    /*AND decaismt.DATPAY >= i_params.debut
    AND decaismt.DATPAY > ADD_MONTHS(SYSDATE,-6)  --règlements des 6 derniers mois*/
    AND /* decaismt.DATPAY*/TRUNC(F_CPTA_DATE_DECAISMT(decaismt.numdecaismt)) between greatest(ADD_MONTHS(SYSDATE,-6), i_params.debut) and NVL(i_params.fin,sysdate)
    --AND decaismt.DATPAY > ADD_MONTHS(SYSDATE,-16)--POUR TU
    AND sp.nosin=r.nosin
    AND sp.iddossier=ds.iddossier
    AND ac.numgar=c.numgar--2ieme etape
    AND ac.idadhesion=r.idadhesion
    AND ar.nosin=r.nosin--3ieme etape
    AND (ar.idarret = h.idcalcul OR (h.debut between ar.debut and ar.fin AND ar.traite='A' AND j.montant_d <0))
    GROUP BY decompte_prev.numdec,decaismt.numdest,r.nosin,j.debut ,
      j.fin  ,i.numindiv,i.nom ,i.prenom,i.datnais,i.matorg,ac.numgar,
      c.college,c.Refcie,c.numcli,ar.type,j.debut,j.fin,decompte_prev.montant
      ,decaismt.numdecaismt,affectation.montant,decaismt.modpmt,j.montant
     ,vire.numvirement
    ORDER BY TRUNC(F_CPTA_DATE_DECAISMT(decaismt.numdecaismt)) desc,f_cpta_lib_reglt (9151, decaismt.numdecaismt, 1)desc,decompte_prev.numdec
    ,r.nosin  DESC, j.debut
    ;
    loc_numdecaismt           decaismt.numdecaismt%TYPE;
    loc_numdec                decompte_prev.numdec%TYPE;
    loc_nosin                 sntr_prev.nosin%TYPE;
    loc_nomcli                VARCHAR2(60);
  BEGIN
  --initialisation des objets
    loc_tab_period        := new EXTR_TAB_PERIOD_PREV(null);
    loc_tab_sin_prev      := new EXTR_TAB_SIN_PREV(null);
    loc_tab_dcpt          := new EXTR_TAB_DCPT_PREV(null);
    loc_tab_decais_prev   := new EXTR_TAB_DECAIS_PREV(null);
    loc_tab_lst_dcpt_prev := new EXTR_TAB_LIST_DCPT_PREV(null);


    IF i_params.numcli IS NULL OR i_params.debut IS NULL THEN
      RETURN  new EXTR_TAB_LIST_DCPT_PREV(null);
    END IF;

    loc_numdecaismt :=NULL;
    loc_numdec      :=NULL;
    loc_nosin       :=NULL;
    loc_nomcli      :=NULL;


    FOR R_DCPT_PREV IN C_DCPT_PREV LOOP


      loc_nomcli := r_dcpt_prev.nomcli;

       --cesure sur decaissement
      IF NVL(loc_numdecaismt,r_dcpt_prev.refpmt) <> r_dcpt_prev.refpmt OR loc_tab_decais_prev(1) IS NULL THEN
        IF loc_tab_decais_prev(1) IS NULL THEN
          --dbms_output.put_line('INIT DECAIS nb :'||loc_tab_decais_prev.COUNT ||'-'||r_dcpt_prev.refpmt||'-'||loc_numdecaismt);
          loc_tab_dcpt := new EXTR_TAB_DCPT_PREV(null);

        ELSE
          -- dbms_output.put_line('MAJ tab DCPT du decais '||'-'||r_dcpt_prev.refpmt||'-'||loc_numdecaismt);
           loc_tab_sin_prev(loc_tab_sin_prev.COUNT).periode := loc_tab_period;
           loc_tab_dcpt(loc_tab_dcpt.COUNT).sinistre := loc_tab_sin_prev;
           loc_tab_decais_prev(loc_tab_decais_prev.COUNT).decompte := loc_tab_dcpt;
           loc_tab_dcpt := new EXTR_TAB_DCPT_PREV(null);
           loc_tab_sin_prev :=new EXTR_TAB_SIN_PREV(null);
           loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
           loc_numdec      :=NULL;
           loc_nosin       :=NULL;
        END IF;
        --initialisation
        IF loc_tab_decais_prev(1) IS NOT NULL THEN
          loc_tab_decais_prev.extend(1);
        END IF;
        --dbms_output.put_line('Creation DECAIS nb :'||r_dcpt_prev.refpmt||'-'||loc_numdecaismt);
        loc_tab_decais_prev(loc_tab_decais_prev.COUNT)   := new EXTR_DECAIS_PREV(r_dcpt_prev.refpmt,NULL,
        r_dcpt_prev.montant_decaismt,r_dcpt_prev.modpmt, r_dcpt_prev.datpay,NULL);

/*
Refpmt        NUMBER(10),
      Numdecaismt   NUMBER(10),
      Montant       NUMBER(11,3),
      Modpmt        VARCHAR2(45),
      Datpay        DATE,
      Decompte       EXTR_TAB_DCPT_PREV
*/

        --loc_numdec      :=NULL;
       -- loc_nosin       :=NULL;
      END IF;
      loc_numdecaismt := r_dcpt_prev.refpmt;

      --cesure sur decompte
      IF NVL(loc_numdec,r_dcpt_prev.numdec) <> r_dcpt_prev.numdec OR loc_tab_dcpt(1) IS NULL THEN
        IF  loc_tab_dcpt(1) IS NULL THEN
          --dbms_output.put_line('INIT DCPT nb :'||loc_tab_dcpt.COUNT ||'-'||r_dcpt_prev.numdec||'-'||loc_numdec);
          loc_tab_sin_prev   := new EXTR_TAB_SIN_PREV(null);
          --loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
        ELSE
           --dbms_output.put_line('MAJ tab SIN du dcpt '||loc_numdec);
          loc_tab_sin_prev(loc_tab_sin_prev.COUNT).periode := loc_tab_period;-- rko 25/06
          loc_tab_dcpt(loc_tab_dcpt.COUNT).sinistre := loc_tab_sin_prev;
          loc_tab_sin_prev :=new EXTR_TAB_SIN_PREV(null);--rko 30/06
          loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);--rko 30/06
        END IF;

        IF loc_tab_dcpt(1) IS NOT NULL THEN
          loc_tab_dcpt.extend(1);
        END IF;
        loc_tab_dcpt(loc_tab_dcpt.COUNT) := new  EXTR_DCPT_PREV(r_dcpt_prev.numdec,r_dcpt_prev.montant_dcpt,NULL);
        loc_nosin       :=NULL;
      END IF;
      loc_numdec := r_dcpt_prev.numdec;

      --cesure sur sinistre
     -- dbms_output.put_line('SIN nb :'||loc_tab_sin_prev.COUNT ||'-'||r_dcpt_prev.nosin||'-'||loc_nosin);
      IF NVL(loc_nosin,0) <> r_dcpt_prev.nosin OR loc_tab_sin_prev(1) IS  NULL THEN
        IF loc_tab_sin_prev.COUNT = 1 THEN
          --dbms_output.put_line('INIT SIN nb :'||loc_tab_sin_prev.COUNT ||'-'||r_dcpt_prev.nosin||'-'||loc_nosin);
          loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
        ELSE
          --dbms_output.put_line('MAJ tab période du SIN '||loc_nosin);
          loc_tab_sin_prev(loc_tab_sin_prev.COUNT).periode := loc_tab_period;
        END IF;

        --création sans le sous objet
        IF loc_tab_sin_prev(1) IS NOT NULL THEN
          loc_tab_sin_prev.extend(1);
        END IF;
        loc_tab_sin_prev(loc_tab_sin_prev.COUNT)   := new EXTR_SIN_PREV(r_dcpt_prev.nosin,r_dcpt_prev.numindiv,r_dcpt_prev.nom,
                                                                    r_dcpt_prev.prenom,r_dcpt_prev.datnais,r_dcpt_prev.matorg,r_dcpt_prev.numgar,
                                                                    r_dcpt_prev.college,r_dcpt_prev.refcie,NULL);

      END IF;
      loc_nosin := r_dcpt_prev.nosin;

      IF loc_tab_period(1) IS NOT NULL THEN
        loc_tab_period.extend(1);
      END IF;
      loc_tab_period(loc_tab_period.COUNT)       := new  EXTR_PERIOD_PREV (substr(r_dcpt_prev.lib_nature,0,45),r_dcpt_prev.DebutPeriode,r_dcpt_prev.FinPeriode,
                                                                          r_dcpt_prev.duree,r_dcpt_prev.mtBrutJ,r_dcpt_prev.mtnetJ,r_dcpt_prev.mtrevalJ,r_dcpt_prev.mtdeduJ,r_dcpt_prev.mtBrutT
                                                                          ,r_dcpt_prev.mtnetT,r_dcpt_prev.mtrevalT,r_dcpt_prev.mtdeduT);

    END LOOP;


    IF loc_tab_period(1).nature IS NOT NULL THEN
      loc_tab_sin_prev(loc_tab_sin_prev.COUNT).periode := loc_tab_period;
      loc_tab_dcpt(loc_tab_dcpt.COUNT).sinistre := loc_tab_sin_prev;
      loc_tab_decais_prev(loc_tab_decais_prev.COUNT).decompte := loc_tab_dcpt;
    END IF;
    loc_tab_dcpt := new EXTR_TAB_DCPT_PREV(null);
    loc_tab_sin_prev :=new EXTR_TAB_SIN_PREV(null);
    loc_tab_period := new EXTR_TAB_PERIOD_PREV(null);
    loc_numdec      :=NULL;
    loc_nosin       :=NULL;

   IF loc_tab_lst_dcpt_prev(1) IS NOT NULL THEN
      loc_tab_lst_dcpt_prev.EXTEND(1);
    END IF;
    loc_tab_lst_dcpt_prev(loc_tab_lst_dcpt_prev.COUNT) := new  EXTR_LIST_DCPT_PREV(i_params.numcli,substr(loc_nomcli,0,30),loc_tab_decais_prev);
    RETURN loc_tab_lst_dcpt_prev;
  EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line('ERR nb :'||SQLERRM);
      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'F_WS_LIST_DCPT_PREV',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => SQLERRM,
          I_idligne  => 2);
      RETURN  new EXTR_TAB_LIST_DCPT_PREV(null);
  END F_WS_LIST_DCPT_PREV;


/*******************************************************************************/
 FUNCTION F_LIST_EMPLOYEE_NUMCLI_NIV3(I_params           EXTR_Q_LIST_EMPLOYEE
                                     ,io_idligne  IN OUT JOURNAL_ADM.IDLIGNE%TYPE)
  RETURN EXTR_R_LIST_EMPLOYEE IS

  -- L’adhésion de base la plus récente ainsi que ses membres sont remontés même si l’adhésion est résiliée
 CURSOR c_adhesion(p_numcli number) IS
    -- préselection des contrats BIA
    WITH contrats_bia as (select numgar from TABLE(F_Get_CONTRATs_BIA(p_numcli,null,null)))
  -- mouvements
    SELECT DISTINCT
          DATAS.numadhe,
          DATAS.idadhesion ,
          DATAS.type_mouvement,
          DATAS.MAJ,
          DATAS.numgar,
          DATAS.datapli,
          DATAS.datper,
          F_ETAT_ADHE_WS(a_idadhesion=> DATAS.idadhesion, a_date=> greatest(sysdate,DATAS.date_adhe), a_type=> 1) etat_adhe,
          F_ETAT_ADHE_WS(a_idadhesion=> DATAS.idadhesion, a_date=> greatest(sysdate,DATAS.date_adhe), a_type=> 2) motif_adhe,
          DATAS.mregl,
          cr.college,
          DATAS.clef
    FROM contrat_ref  cr,
         contrats_bia cbia,
       (  -- radiation
          SELECT ac.numadhe,
                 ac.idadhesion ,
                 /*'Radiation'*/ 2 type_mouvement,
                 trunc(ha.datsai) MAJ,
                 ad.numgar,
                 datapli,
                 datper,
                 ac.mregl,
                 ac.idadhesion     clef,
                 ac.date_adhe
          FROM contrat_ref          cr
          INNER JOIN adhe_cntrt     ac ON ac.numgar      = cr.numgar
          INNER JOIN adhesion       ad ON ad.idadhesion  = ac.idadhesion
                                      AND ad.numindiv    = ac.numadhe
          INNER JOIN histo_adhesion ha ON ha.idhistoadhe = F_ETAT_ADHE_WS(a_idadhesion=> ac.idadhesion
                                                                         ,a_date      => sysdate
                                                                         ,a_type      =>5)
          WHERE cr.numcli       = p_numcli
            AND cr.type_contrat = 1
            AND ((ha.datsai BETWEEN ADD_MONTHS(TRUNC(sysdate),-3) AND TRUNC(sysdate +1)
                  AND ha.etat = 3 )
                OR NVL(ac.date_fin_adhe,sysdate-1) BETWEEN sysdate AND add_months(sysdate,3) )-- BCO ???
            AND ad.datapli <> NVL(ad.datper,ad.datapli + 1)
            AND EXISTS (SELECT 1
                        FROM frml_prime_simple fps
                        WHERE fps.numfor = ad.numfor
                          AND ac.date_fin_adhe BETWEEN fps.debut AND NVL(fps.fin, ac.date_fin_adhe)
                          AND fps.valide ='O')
      UNION ALL
        -- ajout ou cloture de couverture avec cod option liee
        SELECT ac.numadhe,
               ac.idadhesion,
               /*'Ajout de couverture'*/ 3  type_mouvement,
               trunc(ad.creation) MAJ,
               ad.numgar,
               ad.datapli,
               ad.datper,
               ac.mregl,
               ad.idcouverture clef,
               ac.date_adhe
          FROM contrat_ref          cr
          INNER JOIN adhe_cntrt     ac ON ac.numgar      = cr.numgar
          INNER JOIN adhesion       ad ON ad.idadhesion  = ac.idadhesion
                               -- BCO a confirmer que ce prédicat n'est pas pertinent ici =>      AND ad.numindiv    = ac.numadhe
          INNER JOIN histo_adhesion ha ON ha.idhistoadhe = F_ETAT_ADHE_WS(a_idadhesion=> ac.idadhesion
                                                                         ,a_date      => sysdate
                                                                         ,a_type      => 5)
          WHERE cr.numcli       = p_numcli
            AND cr.type_contrat = 1
            AND ad.creation BETWEEN ADD_MONTHS(TRUNC(sysdate),-3) AND TRUNC(sysdate+1)
            AND TRUNC(ha.datsai) < TRUNC(ad.creation)
            AND ha.etat          <> 3
            AND ad.datper IS NULL
            AND ad.datapli        <> NVL(ad.datper,ad.datapli+1)
            AND EXISTS (SELECT 1
                        FROM frml_prime_simple fps
                        WHERE fps.numfor = ad.numfor
                        AND GREATEST(TRUNC(sysdate), ac.date_adhe) BETWEEN fps.debut
                                                                       AND NVL(fps.fin, GREATEST(TRUNC(sysdate), ac.date_adhe))
                        and fps.valide = 'O')
            -- si ajout de plusieurs couverture on ne prend que la dernière
            AND  EXISTS (SELECT 1 from adhesion a2
                         WHERE a2.numindiv     = ad.numindiv
                           AND a2.idadhesion   = ad.idadhesion
                           AND a2.idcouverture < ad.idcouverture
                           AND a2.numfor <> ad.numfor)
      UNION ALL
        -- fermeture de couverture
        SELECT ac.numadhe,
               ad.idadhesion,
               /*'Fermeture de couverture'*/ 4 type_mouvement,
               trunc(ad.maj) MAJ ,
               ad.numgar,
               ad.datapli,
               ad.datper,
               ac.mregl,
               ad.idcouverture clef,
               ac.date_adhe

          FROM contrat_ref          cr
          INNER JOIN adhe_cntrt     ac ON ac.numgar      = cr.numgar
          INNER JOIN adhesion       ad ON ad.idadhesion  = ac.idadhesion
          INNER JOIN histo_adhesion ha ON ha.idhistoadhe = F_ETAT_ADHE_WS(a_idadhesion=> ac.idadhesion
                                                                         ,a_date      => ad.datper
                                                                         ,a_type      => 5)
          WHERE cr.numcli       = p_numcli
            AND ad.maj BETWEEN ADD_MONTHS(TRUNC(sysdate),-3) AND TRUNC(sysdate + 1)
            AND ha.etat <> 3
            AND ad.datper IS NOT NULL
            AND ad.datapli <> NVL(ad.datper,ad.datapli + 1)
            AND EXISTS (SELECT 1
                        FROM frml_prime_simple fps
                        WHERE fps.numfor = ad.numfor
                        AND GREATEST(TRUNC(sysdate), ac.date_adhe) BETWEEN fps.debut
                                                                       AND NVL(fps.fin, GREATEST(TRUNC(sysdate), ac.date_adhe))
                        AND fps.valide = 'O')
            --il a encore une couverture
            AND EXISTS (SELECT 1
                        FROM adhesion a2
                        WHERE a2.numindiv   = ad.numindiv
                        AND a2.idadhesion   = ad.idadhesion
                        AND a2.idcouverture = ad.idcouverture
                        AND sysdate BETWEEN a2.datapli and NVL(a2.datper,sysdate)
                        AND a2.datper IS NULL)
      UNION ALL
        SELECT ac.numadhe,
               ad.idadhesion,
               /*'Nouvelle adhésion'*/ 1 type_mouvement,
               TRUNC(ad.creation) MAJ ,
               ad.numgar,
               ad.datapli,
               ad.datper,
               ac.mregl,
               ad.idadhesion clef,
               ac.date_adhe

          FROM contrat_ref          cr
          INNER JOIN adhe_cntrt     ac ON ac.numgar      = cr.numgar
          INNER JOIN adhesion       ad ON ad.idadhesion  = ac.idadhesion
                                      AND ad.numindiv    = ac.numadhe
          INNER JOIN histo_adhesion ha ON ha.idhistoadhe = F_ETAT_ADHE_WS(a_idadhesion=> ac.idadhesion
                                                                         ,a_date      => sysdate
                                                                         ,a_type      => 5)

          WHERE cr.numcli       = p_numcli
            AND ad.creation BETWEEN ADD_MONTHS(TRUNC(sysdate),-3) AND TRUNC(sysdate)
            AND ha.etat IN (0, 1)
            AND ad.datper is null
            AND ad.datapli <> NVL(ad.datper, ad.datapli + 1)
            AND ha.datsai >= TRUNC(ad.creation)
            AND ha.numutil <> f_numutil --M6441 ABO 13022020 retirer les affiliations massives
            AND EXISTS (SELECT 1
                        FROM frml_prime_simple fps
                        WHERE fps.numfor = ad.numfor
                        AND GREATEST(TRUNC(sysdate), ac.date_adhe) BETWEEN fps.debut
                                                                       AND NVL(fps.fin, GREATEST(TRUNC(sysdate), ac.date_adhe))
                        AND fps.valide = 'O')
  )
  DATAS
    WHERE cr.numgar       = datas.numgar
      AND cr.numgar       = cbia.numgar
      AND cr.TYPE_CONTRAT = 1
    ORDER BY
      DATAS.numadhe        ASC,
      DATAS.idadhesion     ASC,
      DATAS.type_mouvement ASC
  ;


  -- CURSOR c_salarier_niveau(     i_numcli individu.numindiv%type )
  --   IS
  --    SELECT DISTINCT individu.* ,  F_LBLE('QLTE',INDIVIDU.QUALITE) lib_qualite, f_coordonne_contact(individu.numindiv,4,1) lemail,  f_coordonne_contact(individu.numindiv,1,1)  ltelephone
  --    FROM individu,
  --         adhesion,
  --         adhe_cntrt,
  --         contrat_ref
  --    WHERE
  --         adhesion.numindiv = individu.numindiv
  --     AND EXISTS (select numadhe from adhe_cntrt where numadhe = individu.numindiv)
  --      AND contrat_ref.NUMGAR = adhe_cntrt.NUMGAR
  --      AND numcli = i_numcli
  --      AND adhesion.idadhesion = adhe_cntrt.idadhesion
  --      AND adhe_cntrt.numadhe = adhesion.numindiv
  --      AND adhesion.datapli <> NVL(adhesion.datper,e2d('01/01/1900'))
  --      AND   (adhesion.MAJ > add_months(SYSDATE,-12 ))
  --     ;

   ---- STRUCTURE DE REPONSE
   loc_reponse            EXTR_R_LIST_EMPLOYEE;

   loc_tab_affilie        EXTR_TAB_AFFILIE_EMPLOYEE;
   loc_affilie            EXTR_AFFILIE_EMPLOYEE;

   --loc_adresse            EXTR_ADRESSE_TR;

   loc_tab_adhesion       EXTR_TAB_ADHESION_TR;
   loc_adhesion           EXTR_ADHESION_TR;

   loc_tab_ayant_droit    EXTR_TAB_AYANT_DROIT;
   loc_ayant_droit        EXTR_AYANT_DROIT;

   loc_tab_grnts          EXTR_TAB_GRNTS_TR;
   loc_garantie           EXTR_GRNTS_TR;

   loc_tab_code_DSN       EXTR_TAB_DSN_TR;
   loc_code_dsn           EXTR_DSN_TR;
   ---- VARIABLES LOCALES
  loc_Niveau_detail NUMBER(1)     := I_params.niveau_detail;--1 :PRE-AFF, 2 : RECHERCHE, 3 : MVT
  loc_Numcli        NUMBER(9)     := I_params.numcli;  -- nuémro de la société
  loc_numadhe_prec  ADHE_CNTRT.NUMADHE%TYPE;
  -- timers
  v_timer_global    NUMBER;

  BEGIN
    v_timer_global := DBMS_UTILITY.GET_TIME;

    io_idligne := io_idligne + 1;
    PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_LIST_EMPLOYEE_NUMCLI_NIV3',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => 'DEBUT Société '|| loc_numcli,
              I_idligne  => io_idligne);

    -- CTRL sur les paramétres
    IF  (loc_Niveau_detail <> 3)
     OR (loc_Niveau_detail = 3 AND loc_numcli IS NULL ) THEN
      io_idligne := io_idligne + 1;
      PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'F_LIST_EMPLOYEE_NUMCLI_NIV3',
                I_session  => SID,
                I_niv_msg  => 1,
                I_msg_adm  => 'Erreur parametre entree loc_numcli='|| loc_numcli || ' loc_Niveau_detail='||  loc_Niveau_detail,
                I_idligne  => io_idligne);
      RETURN NULL;
    END IF;

    -- Init
    loc_tab_affilie     := new EXTR_TAB_AFFILIE_EMPLOYEE(null);
    loc_tab_grnts       := new EXTR_TAB_GRNTS_TR(null);
    loc_tab_ayant_droit := new EXTR_TAB_AYANT_DROIT(null);
    loc_tab_adhesion    := new EXTR_TAB_ADHESION_TR(null);

    loc_numadhe_prec := NULL;
    FOR R_ADHESION IN c_adhesion(loc_numcli) LOOP
      io_idligne := io_idligne + 1;
      PK_trace.P_INS_journal_adm (
                I_nom_traitement => 'F_LIST_EMPLOYEE_NUMCLI_NIV3',
                I_session  => SID,
                I_niv_msg  => 3,
                I_msg_adm  => loc_numcli|| '-Lecture='
                              ||'-' || R_ADHESION.numadhe
                              ||'-' || R_ADHESION.idadhesion
                              ||'-' || R_ADHESION.type_mouvement
                              ||'-' || R_ADHESION.numgar,
                I_idligne  => io_idligne);

      -- si rupture sur numadhe, alors creation du bloc AFFILIE_EMPLOYEE précédent
      -- et réinit des blocs
      IF loc_numadhe_prec IS NOT NULL
       AND loc_numadhe_prec <> R_ADHESION.numadhe THEN
        loc_affilie := new  EXTR_AFFILIE_EMPLOYEE(Numindiv    => loc_numadhe_prec,
                                                  Nom         => NULL,
                                                  Prenom      => NULL,
                                                  Matorg      => NULL,
                                                  Datnais     => NULL,
                                                  Rang        => NULL,
                                                  Qualite     => NULL,
                                                  Lib_qualite => NULL,
                                                  regime      => NULL,
                                                  caisse      => NULL,
                                                  centre      => NULL,
                                                  email       => NULL,
                                                  telephone   => NULL,
                                                  Adresse     => NULL,
                                                  Adhesions   => loc_tab_adhesion );
        -- insertion dans le tableau des affiliés
        IF loc_tab_affilie(1) IS NOT NULL THEN
          loc_tab_affilie.extend(1);
        END IF;
        loc_tab_affilie(loc_tab_affilie.count) := loc_affilie;
        -- réinit du tableau temporaire des adhésions
        loc_tab_adhesion := new EXTR_TAB_ADHESION_TR(null);
      END IF;
      loc_numadhe_prec := R_ADHESION.numadhe;
      loc_adhesion := new EXTR_ADHESION_TR( numgar       => R_ADHESION.numgar,
                                            refCie       => NULL,
                                            college      => NULL,
                                            Cntrt_base   => NULL ,
                                            idadhesion   => R_ADHESION.idadhesion,
                                            etat         => R_ADHESION.etat_adhe,
                                            libetat      => NULL,
                                            motif        => R_ADHESION.motif_adhe,
                                            libMotif     => NULL,
                                            dateDebut    => R_ADHESION.datapli,
                                            dateFin      => R_ADHESION.datper,
                                            Modpmt       => R_ADHESION.mregl,
                                            Libmodpmt    => NULL,
                                            dateModif    => R_ADHESION.maj,
                                            typeModif    => R_ADHESION.type_mouvement,
                                            ayant_droits => loc_tab_ayant_droit,
                                            garanties    => loc_tab_grnts);
      -- ajout de l'adhesion au tableau temporaire des adhésions
      IF loc_tab_adhesion(1) IS NOT NULL THEN
        loc_tab_adhesion.extend(1);
      END IF;
      loc_tab_adhesion(loc_tab_adhesion.count) := loc_adhesion ;
    END LOOP R_ADHESION;

    -- Gestion sortie de boucle : creation du bloc AFFILIE_EMPLOYEE précédent
    IF loc_numadhe_prec IS NOT NULL THEN
      loc_affilie := new  EXTR_AFFILIE_EMPLOYEE(Numindiv    => loc_numadhe_prec,
                                                Nom         => NULL,
                                                Prenom      => NULL,
                                                Matorg      => NULL,
                                                Datnais     => NULL,
                                                Rang        => NULL,
                                                Qualite     => NULL,
                                                Lib_qualite => NULL,
                                                regime      => NULL,
                                                caisse      => NULL,
                                                centre      => NULL,
                                                email       => NULL,
                                                telephone   => NULL,
                                                Adresse     => NULL,
                                                Adhesions   => loc_tab_adhesion );
      -- insertion dans le tableau des affiliés
      IF loc_tab_affilie(1) IS NOT NULL THEN
        loc_tab_affilie.extend(1);
      END IF;
      loc_tab_affilie(loc_tab_affilie.count) := loc_affilie;
    END IF;

    v_timer_global := DBMS_UTILITY.GET_TIME - v_timer_global;
    io_idligne := io_idligne + 1;
    PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_LIST_EMPLOYEE_NUMCLI_NIV3',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => 'FIN Société '|| loc_numcli || ' delai:' ||v_timer_global * 10||' ms',
            I_idligne  => io_idligne);

    RETURN new EXTR_R_LIST_EMPLOYEE(loc_tab_affilie);

  EXCEPTION
    WHEN OTHERS THEN
    io_idligne := io_idligne + 1;
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_LIST_EMPLOYEE_NUMCLI_NIV3',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => SQLERRM,
        I_idligne  => io_idligne);

  END F_LIST_EMPLOYEE_NUMCLI_NIV3;
  /********************************************************************************/
  /* FUNCTION                                                                    */
/* Nom          :  F_WS_BOARD_COUNTER                                            */
/* Type         :  Public                                                        */
/* Description  :  permet de remonter pour un contexte donné (25 espace Assuré,  */
/*                        27 espace RH, 30 espace Prévoyance),                   */
/*                    une liste de compteurs pour un interlocuteur d'une société */
/* paramètres entrants       :  numéro de l'interlocuteur, le type de compteur   */
/* Date         :  09/06/2020                                                    */
/* Commentaire  :  Projet P201910104                                             */
/* Retour       : tableau de compteurs                                           */
  /*******************************************************************************/

  FUNCTION F_WS_BOARD_COUNTER(i_numindiv individu.numindiv%TYPE,
                              i_type     EXTR_Q_BC
                               )
  RETURN EXTR_BOARD_COUNTER
  IS

  loc_tab_ste      EXTR_TAB_SOCIETE_BC;
  loc_tab_cpt      EXTR_TAB_CPT_BC;
  loc_nbdecais     NUMBER;
  loc_nbpiece      NUMBER;
  loc_nbadhe       NUMBER;
  loc_nbadhe_mvt   NUMBER;

  loc_interlo8     NUMBER;

  v_timer_global   NUMBER;
  v_timer_numcli   NUMBER;
  v_timer_cpt1     NUMBER;
  v_timer_cpt2     NUMBER;
  v_timer_cpt3     NUMBER;
  v_timer_cpt4     NUMBER;

  loc_idligne      NUMBER := 0 ;


  CURSOR  C_interloc_ste (p_interloc NUMBER) IS
    SELECT distinct individu.numindiv,individu.nom
    FROM INTERLOCUTEUR,individu
    WHERE INTERLOCUTEUR.valide='O'
    AND interlocuteur = p_interloc
    AND individu.numindiv = interlocuteur.numindiv;


  BEGIN

    v_timer_global := DBMS_UTILITY.GET_TIME;
    loc_idligne := loc_idligne + 1;
    PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_WS_BOARD_COUNTER',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => 'DEBUT Interloc:'|| i_numindiv,
            I_idligne  => loc_idligne);


    loc_tab_ste := new EXTR_TAB_SOCIETE_BC(null);

    /*1-  Nombre de règlements : comptabilisation du nombre de décomptes sur les 3 derniers mois
      2-  Nombre de dossiers en attente de pièces : les critères utilisés pour lister le nombre de dossier en attente de pièces est identique au flux listant les dossiers en attente de pièce
      3-  Nombre d'affiliations en attente de validation
      4-   Nombre d'affiliations modifiées sur les 3 derniers mois  */
    FOR R_interloc_ste IN C_interloc_ste(i_numindiv) LOOP
      v_timer_numcli := DBMS_UTILITY.GET_TIME;
      loc_tab_cpt := new EXTR_TAB_CPT_BC(null);

      v_timer_cpt1 := DBMS_UTILITY.GET_TIME;
      loc_nbdecais := 0;
      loc_nbdecais :=PK_ARTHUS_CACHE.F_GET_CACHED_VALUE('PK_WS_WEB_BACK.F_BOARDCOUNTER_CPT1',to_char(R_interloc_ste.numindiv));

      v_timer_cpt1 := DBMS_UTILITY.GET_TIME - v_timer_cpt1;
      loc_idligne := loc_idligne + 1;
      PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_WS_BOARD_COUNTER',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => 'numcli:'|| R_interloc_ste.numindiv || ' cpt1 delai:' ||v_timer_cpt1 * 10 ||' ms',
              I_idligne  => loc_idligne);


      v_timer_cpt2 := DBMS_UTILITY.GET_TIME;
      loc_nbpiece := 0;
      loc_nbpiece :=PK_ARTHUS_CACHE.F_GET_CACHED_VALUE('PK_WS_WEB_BACK.F_BOARDCOUNTER_CPT2',to_char(R_interloc_ste.numindiv));

      v_timer_cpt2 := DBMS_UTILITY.GET_TIME - v_timer_cpt2;
      loc_idligne := loc_idligne + 1;
      PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_WS_BOARD_COUNTER',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => 'numcli:'|| R_interloc_ste.numindiv || ' cpt2 delai:' ||v_timer_cpt2 * 10 ||' ms',
              I_idligne  => loc_idligne);

      v_timer_cpt3 := DBMS_UTILITY.GET_TIME;
      loc_nbadhe:=0;
      -- on ne calcule le compteur 3 que si l'interlocuteur est de type 8 pour la société, sinon 0
      BEGIN
        SELECT count(*) INTO loc_interlo8
        FROM  interlocuteur i
        WHERE
            i.numindiv      = R_interloc_ste.numindiv
        AND i.interlocuteur = i_numindiv  -- interlocuteur = p_interloc =238453
        AND i.ope_crrr      = 8
        AND i.valide        = 'O' ;
      EXCEPTION
        WHEN OTHERS THEN
          loc_interlo8 := 0 ;
      END;

      IF loc_interlo8 > 0 THEN
        loc_nbadhe :=PK_ARTHUS_CACHE.F_GET_CACHED_VALUE('PK_WS_WEB_BACK.F_BOARDCOUNTER_CPT3',to_char(R_interloc_ste.numindiv));
      END IF;

      v_timer_cpt3 := DBMS_UTILITY.GET_TIME - v_timer_cpt3;
      loc_idligne := loc_idligne + 1;
      PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_WS_BOARD_COUNTER',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => 'numcli:'|| R_interloc_ste.numindiv || ' cpt3 delai:' ||v_timer_cpt3 * 10||' ms',
              I_idligne  => loc_idligne);

      v_timer_cpt4 := DBMS_UTILITY.GET_TIME;
      loc_nbadhe_mvt :=0;
      loc_nbadhe_mvt :=PK_ARTHUS_CACHE.F_GET_CACHED_VALUE('PK_WS_WEB_BACK.F_BOARDCOUNTER_CPT4',to_char(R_interloc_ste.numindiv));
      v_timer_cpt4 := DBMS_UTILITY.GET_TIME - v_timer_cpt4;
      loc_idligne := loc_idligne + 1;
      PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_WS_BOARD_COUNTER',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => 'numcli:'|| R_interloc_ste.numindiv || ' cpt4 delai:' ||v_timer_cpt4 * 10||' ms',
              I_idligne  => loc_idligne);

      loc_tab_cpt(loc_tab_cpt.count) := new EXTR_CPT_BC(1,loc_nbdecais);
      loc_tab_cpt.extend(1);
      loc_tab_cpt(loc_tab_cpt.count) := new EXTR_CPT_BC(2,loc_nbpiece);
      loc_tab_cpt.extend(1);
      loc_tab_cpt(loc_tab_cpt.count) := new EXTR_CPT_BC(3,loc_nbadhe);
      loc_tab_cpt.extend(1);
      loc_tab_cpt(loc_tab_cpt.count) := new EXTR_CPT_BC(4,loc_nbadhe_mvt);


      IF loc_tab_ste(1) IS NOT NULL THEN
        loc_tab_ste.extend(1);
      END IF;
      loc_tab_ste(loc_tab_ste.count) := new EXTR_SOCIETE_BC(R_interloc_ste.numindiv,R_interloc_ste.nom,loc_tab_cpt);

      v_timer_numcli := DBMS_UTILITY.GET_TIME - v_timer_numcli;
      loc_idligne := loc_idligne + 1;
      PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'F_WS_BOARD_COUNTER',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => 'numcli:'|| R_interloc_ste.numindiv || ' delai:' ||v_timer_numcli * 10 ||' ms',
              I_idligne  => loc_idligne);
    END LOOP; -- FinBoucle R_interloc_ste


    v_timer_global := DBMS_UTILITY.GET_TIME - v_timer_global;
    loc_idligne := loc_idligne + 1;
    PK_trace.P_INS_journal_adm (
            I_nom_traitement => 'F_WS_BOARD_COUNTER',
            I_session  => SID,
            I_niv_msg  => 3,
            I_msg_adm  => 'FIN Interloc:'|| i_numindiv|| ' delai:' ||v_timer_global * 10||' ms',
            I_idligne  => loc_idligne);

    RETURN EXTR_BOARD_COUNTER(loc_tab_ste);

  EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_WS_BOARD_COUNTER',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => SQLERRM,
        I_idligne  => loc_idligne);
    RETURN NEW EXTR_BOARD_COUNTER(null);

  END F_WS_BOARD_COUNTER;
/*********************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :   F_BOARDCOUNTER_CPT1(CLE)                                     */
/* Type         :  Public                                                        */
/* Description  :                                                                */
/* paramètres entrants       :  cle                                              */
/* Date         :  22/12/2021                                                    */
/* Commentaire  :  ARTGEREP_348                                                  */
/* Retour       :                                                                */
  /*******************************************************************************/

  FUNCTION F_BOARDCOUNTER_CPT1(I_CLE IN ARTHUS_CACHE.CLE%TYPE)
  RETURN NUMBER
  IS
  l_nbdecais NUMBER :=0;
  BEGIN
  --compteur 1-  Nombre de règlements : comptabilisation du nombre de décomptes sur les 3 derniers mois
  SELECT COUNT(decaismt.numdecaismt) nb_decais
  INTO l_nbdecais
  FROM  decompte_prev,
        affectation,
        decaismt
  WHERE  affectation.codope = 2
  AND decaismt.codope =affectation.codope
  AND affectation.codope = 2
  AND affectation.numaffec = decompte_prev.numdec
  AND affectation.numdecaismt = decaismt.numdecaismt
  AND decaismt.datpay IS NOT NULL
  AND decaismt.modpmt IN  (2,7) -- virement et virement manuel   (MOPM)
  AND decaismt.refpmt > 0
  AND decaismt.datpay IS NOT NULL
  AND decaismt.datpay > ADD_MONTHS(SYSDATE,-3)
  AND decaismt.flagpay = 1
  AND decaismt.numdest = I_CLE; --R_interloc_ste.numindiv ;

  RETURN l_nbdecais;

  EXCEPTION

  WHEN OTHERS THEN l_nbdecais :=0;
    RETURN l_nbdecais;

  END F_BOARDCOUNTER_CPT1;

  /*********************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :   F_BOARDCOUNTER_CPT2(CLE)                                     */
/* Type         :  Public                                                        */
/* Description  :                                                                */
/* paramètres entrants       :  cle                                              */
/* Date         :  22/12/2021                                                    */
/* Commentaire  :  ARTGEREP_348                                                  */
/* Retour       :                                                                */
  /*******************************************************************************/

  FUNCTION F_BOARDCOUNTER_CPT2(I_CLE IN ARTHUS_CACHE.CLE%TYPE)
  RETURN NUMBER
  IS
    l_nbpiece NUMBER :=0;
  BEGIN
    --compteur 2-  Nombre de dossiers en attente de pièces : les critères utilisés pour lister le nombre de dossier en attente de pièces est identique au flux listant les dossiers en attente de pièce
    SELECT COUNT(distinct s.nosin) INTO l_nbpiece
    FROM pieces,sntr_prev s,/*repartition r,*/ histo_sntr_prev histo
    WHERE pieces.daterecep IS NULL
    AND pieces.datannul IS NULL
    AND pieces.dateavis IS NOT NULL
    AND pieces.entite = s.nosin
    AND s.norisq = 4 --voir ajustement avec prestIJ
    AND pieces.numindiv_dest = I_CLE --R_interloc_ste.numindiv
    -- datant de moins d'un an
    AND NVL(pieces.daterel,pieces.dateavis) > add_months(sysdate,-12)
    AND pieces.contexte IN (15,17)
    AND pieces.dateenreg < trunc(sysdate)
    AND NVL(pieces.nbrel,0) < 3
    AND NOT EXISTS( SELECT lg.clef
                    FROM lien_ged lg
                    WHERE lg.clef = pieces.idpiece
                      AND lg.etat in (1,2)
                      AND lg.etendue= pieces.contexte)
    AND histo.nosin =s.nosin
    AND (histo.saisie,histo.debut) = (
      SELECT MAX(h.saisie),h.debut FROM histo_sntr_prev h
      WHERE h.debut<= sysdate  AND h.nosin =s.nosin
      AND h.debut = (
        SELECT MAX(h2.debut) FROM histo_sntr_prev h2
        WHERE h2.debut<= sysdate  AND h2.nosin =s.nosin
        )
      GROUP BY h.debut
      )
    AND histo.etat<>2; --dossier non fermé

  RETURN l_nbpiece;

  EXCEPTION

  WHEN OTHERS THEN l_nbpiece :=0;
    RETURN l_nbpiece;

  END F_BOARDCOUNTER_CPT2;

/*********************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :   F_BOARDCOUNTER_CPT3(CLE)                                     */
/* Type         :  Public                                                        */
/* Description  :                                                                */
/* paramètres entrants       :  cle1 = societe                                   */
/* Date         :  22/12/2021                                                    */
/* Commentaire  :  ARTGEREP_348                                                  */
/* Retour       :                                                                */
  /*******************************************************************************/

  FUNCTION F_BOARDCOUNTER_CPT3(I_CLE IN ARTHUS_CACHE.CLE%TYPE)
  RETURN NUMBER
  IS
  l_nbadhe NUMBER :=0;
  BEGIN
  -- compteur 3 Nombre affiliations en attente de validation pour la société I_CLE
    SELECT COUNT(DISTINCT ac.numadhe) INTO l_nbadhe
    FROM adhe_cntrt ac, contrat c, histo_adhesion ha
    WHERE c.numcli= I_CLE
    AND ac.numgar=c.numgar
    AND ac.idadhesion =ha.idadhesion
    AND ha.idhistoadhe = ( select max(idhistoadhe)
                           from histo_adhesion adh2
                           where adh2.idadhesion = ac.idadhesion and
                           debut <= greatest(ac.date_adhe,sysdate))
    --ABO M6829 : on ôte l'appel à F_ETAT_ADHE_WS car le contexte du motif 58 le permet.
    -- fonctionnellement les états en affiliation par BIA s'enchaine ainsi
    -- etat 0 motif 58 puis etat 0 motif 59 et état 1 motif 57 avec toujours la même date de début.
    --F_ETAT_ADHE_WS(a_idadhesion=> ac.idadhesion, a_date    => greatest(ac.date_adhe,sysdate), a_type=>5)
    AND ha.etat = 0 -- en instance
    AND ha.motif = 58-- Pré-affiliation en attente validation RH
    ;
  RETURN l_nbadhe;

  EXCEPTION

  WHEN OTHERS THEN l_nbadhe :=0;
    RETURN l_nbadhe;

  END F_BOARDCOUNTER_CPT3;

  /*********************************************************************************/
/* FUNCTION                                                                      */
/* Nom          :   F_BOARDCOUNTER_CPT4(CLE)                                     */
/* Type         :  Public                                                        */
/* Description  :                                                                */
/* paramètres entrants       :  cle                                              */
/* Date         :  22/12/2021                                                    */
/* Commentaire  :  ARTGEREP_348                                                  */
/* Retour       :                                                                */
  /*******************************************************************************/

  FUNCTION F_BOARDCOUNTER_CPT4(I_CLE IN ARTHUS_CACHE.CLE%TYPE)
  RETURN NUMBER
  IS
  l_nbadhe_mvt   NUMBER;
  loc_test         EXTR_Q_LIST_EMPLOYEE;
  loc_res          EXTR_R_LIST_EMPLOYEE;
  loc_etat         NUMBER;
  loc_typemvt      NUMBER;

  -- indices
  i_affilie        NUMBER;
  j_adh            NUMBER;

  cpt_aff_valid    NUMBER;
  cpt_affil_radie  NUMBER;
  cpt_affil_modif  NUMBER;
  loc_idligne      NUMBER := 0 ;

  BEGIN
  --compteur 4 Nombre d'affiliations modifiées sur les 3 derniers mois
      l_nbadhe_mvt :=0;

      loc_test := new EXTR_Q_LIST_EMPLOYEE (null,
                                            null,
                                            null,
                                            null,
                                            3,                      -- Niveau_detail
                                            to_number(I_CLE),--R_interloc_ste.numindiv,-- Numcli
                                            null,
                                            null,
                                            null
                                            );
      loc_res := PK_WS_WEB_BACK.F_LIST_EMPLOYEE_NUMCLI_NIV3(loc_test,loc_idligne);

      cpt_aff_valid   := 0;
      cpt_affil_radie := 0;
      cpt_affil_modif := 0;
      i_affilie       := 1;
      WHILE i_affilie <= loc_res.affilie.count LOOP

        IF loc_res.affilie(i_affilie).adhesions IS NOT NULL THEN
          j_adh := 1;


          WHILE j_adh <= loc_res.affilie(i_affilie).adhesions.count LOOP
            loc_etat       := loc_res.affilie(i_affilie).adhesions(j_adh).etat;
            loc_typemvt    := loc_res.affilie(i_affilie).adhesions(j_adh).typemodif;

            IF loc_typemvt = 1 AND loc_etat = 1 THEN
              cpt_aff_valid := cpt_aff_valid + 1;
            ELSIF loc_typemvt = 2 AND loc_etat = 3 THEN
              cpt_affil_radie := cpt_affil_radie + 1;
            ELSIF loc_typemvt not in (1,2) AND loc_etat = 1 THEN
              cpt_affil_modif := cpt_affil_modif + 1;
            END IF;

            j_adh := j_adh + 1;
          END LOOP adh;
        END IF;
        i_affilie := i_affilie + 1;
      END LOOP;

      l_nbadhe_mvt := cpt_aff_valid + cpt_affil_radie + cpt_affil_modif;

  RETURN l_nbadhe_mvt;

  EXCEPTION

  WHEN OTHERS THEN l_nbadhe_mvt :=0;
    RETURN l_nbadhe_mvt;

  END F_BOARDCOUNTER_CPT4;

   /**********************************************************************************/
  /* FUNCTION                                                                       */
  /* Nom          :  F_list_employ_niv_6                                            */
  /* Type         :  Public                                                         */
  /* Description  :  remonte les salariés affiliés sur des contrats prévoyance ouverts
                    sur la porte dédiée (30 espace Prévoyance).  Niveau détail = 6  */
  /* paramètres entrants :  numéro de l'adhérent, son nom, prenom, n°secu,
                          datnais, numéro de la société, numéro de contrat,
                          la catégorie du contrat                                   */
  /* Date         :  09/06/2020                                                     */
  /* Commentaire  :  Projet P201910104                                              */
  /* Retour       : tableau d'affiliés avec adhésions et garanties                  */
  /**********************************************************************************/

 FUNCTION F_list_employ_niv_6  (i_numindiv individu.numindiv%type,
                                i_nom individu.nom%type,
                                i_prenom individu.prenom%type,
                                i_matorg individu.matorg%type,
                                i_datnais individu.datnais%type,
                                i_numcli individu.numindiv%type,
                                i_numgar contrat.numgar%type,
                                i_college contrat.college%type
                                )  RETURN  EXTR_R_LIST_EMPLOYEE
 IS

 CURSOR c_salarier_niveau_6(  p_numindiv individu.numindiv%type,
                                p_nom individu.nom%type,
                                p_prenom individu.prenom%type,
                                p_matorg individu.matorg%type,
                                p_datnais individu.datnais%type,
                                p_numcli individu.numindiv%type,
                                p_numgar contrat.numgar%type ,
                                p_college contrat.college%type,
                                p_porte porte_contrat.numporte%TYPE)
    IS
     SELECT individu.* ,  F_LBLE('QLTE',INDIVIDU.QUALITE) lib_qualite, f_coordonne_contact(numindiv,4,1) lemail,  f_coordonne_contact(numindiv,1,1)  ltelephone
     FROM individu
     WHERE numindiv     = nvl(p_numindiv,numindiv)
     AND datnais = NVL(p_datnais,datnais)
     AND UPPER(nom)    =UPPER(nvl(p_nom, nom))
     AND UPPER(prenom)  =UPPER(nvl(p_prenom, prenom))
     AND (UPPER(matorg)  = UPPER(nvl(substr(p_matorg,0,13), matorg))
       OR UPPER(matorg2)  = UPPER(nvl(substr(p_matorg,0,13), matorg2)))
     AND EXISTS (select numadhe from adhe_cntrt where numadhe = individu.numindiv)
     AND EXISTS( SELECT 1                          -- On ne remonte que les individus si il est dans le périmétre du numcli et du contrat
                  FROM   adhesion a,
                         contrat c,
                         porte_contrat p
                  WHERE a.numgar  = c.numgar
                   AND c.numgar   = NVL(p_numgar, c.numgar)    -- au niveau on fait au minimum avec le numcli
                   AND c.college  = NVL (p_college,c.college)
                   AND c.numcli   = p_numcli
                   AND a.numindiv = individu.numindiv
                   AND (a.datper is NULL  OR add_months(sysdate,-3) < a.datper)
                   AND p.numgar = c.numgar
                   AND p.numporte = p_porte
               )
  ;

  CURSOR c_adhesion_niveau_6 ( p_numindiv individu.numindiv%type , p_porte porte_contrat.numporte%TYPE) IS
      SELECT distinct a.idadhesion ,
                    null type_mouvement ,
                    null maj,
                    a.numgar,
                    ad.date_adhe datapli,
                    ad.date_fin_adhe datper ,
                    F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe,sysdate),  a_type=>1)   etat_adhe,
                    F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe,sysdate),  a_type=>2) motif_adhe,
                    ad.mregl,
                    cr.college ,
                    cr.refcie ,
                    ad.date_adhe
    FROM adhesion a, adhe_cntrt ad, contrat cr,porte_contrat p
    WHERE a.idadhesion = ad.idadhesion
      AND numindiv = p_numindiv
      AND cr.numgar = a.numgar
      AND p.numgar = cr.numgar
      AND p.numporte = p_porte
      AND a.datapli <> NVL(a.datper,e2d('01/01/1900'))
      AND a.typfor = 2
      AND F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe, add_months(sysdate,-3)),  a_type=>1) <> 3  -- adhésions non resiliée
      AND NOT EXISTS(
        SELECT numde FROM dependance
        WHERE numde=cr.numgar AND role =6 AND sysdate BETWEEN datapli AND NVL(datper,sysdate)) --on privilegie le contrat mensu
      ORDER BY ad.date_adhe desc,a.idadhesion desc
      ;

  CURSOR c_garanties_niveau_6(p_idadhesion adhesion.idadhesion%type) IS
  SELECT distinct f.numfor, f.NOMGAR, f.LIBELLE, a.DATAPLI, a.DATPER, NULL FLAG_REGIME, NULL OBLIGATOIRE, NULL TYPGAR
  FROM adhesion a,  garanties f
  WHERE a.idadhesion = p_idadhesion
    AND a.numfor = f.numfor
    AND a.datapli <> nvl(a.datper,datapli+1);

  loc_tab_grnts          EXTR_TAB_GRNTS_TR;
  loc_garantie           EXTR_GRNTS_TR;

  loc_affil            EXTR_AFFILIE_EMPLOYEE;
  loc_adresse           EXTR_ADRESSE_TR;
  loc_tab_affil        EXTR_TAB_AFFILIE_EMPLOYEE;
  loc_tab_adhesion       EXTR_TAB_ADHESION_TR ;

 BEGIN
       loc_tab_adhesion    := new   EXTR_TAB_ADHESION_TR(null);
       loc_tab_affil    := new  EXTR_TAB_AFFILIE_EMPLOYEE(null);
       loc_tab_adhesion    := new   EXTR_TAB_ADHESION_TR(null);

       FOR R_SALARIER IN c_salarier_niveau_6(i_numindiv, i_nom, i_prenom, i_matorg,i_datnais, i_numcli, i_numgar,i_college,30) LOOP
         loc_adresse := F_ADRESSE_BY_NUMINDIV(R_SALARIER.numindiv);
         FOR r_adhesion in c_adhesion_niveau_6(R_SALARIER.numindiv,30) LOOP


            loc_tab_grnts := new EXTR_TAB_GRNTS_TR(null);


            FOR R_GARANTIE IN c_garanties_niveau_6(r_adhesion.idadhesion) LOOP

             /*-- PBO M0006158 filtre sur les garanties en cours sur le niveau_detail 2
              IF NVL(R_GARANTIE.datper, sysdate + 1)  <= sysdate AND loc_Niveau_detail = 2 THEN
                CONTINUE;
              END IF;
             V_DELEG_PREST:=null;
             V_DELEG_COT :=null;
            SELECT COUNT(numfor)
            INTO V_DELEG_PREST
            FROM CALCUL
            WHERE NUMFOR = r_garantie.numfor
            AND greatest(trunc(sysdate),r_garantie.datapli) BETWEEN DATAPLI AND NVL(DATPER,greatest(trunc(sysdate),r_garantie.datapli));

            SELECT COUNT(numfor)
            INTO V_DELEG_COT
            FROM FRML_PRIME_SIMPLE
            WHERE NUMFOR =r_garantie.numfor
            AND greatest(trunc(sysdate),r_garantie.datapli) BETWEEN DEBUT AND NVL(FIN,greatest(trunc(sysdate),r_garantie.datapli));

           IF not(V_DELEG_COT + V_DELEG_PREST= 0 OR (V_DELEG_COT > 0 AND V_DELEG_PREST =0 ))THEN*/

              loc_garantie     := new   EXTR_GRNTS_TR(  NOM_GARANTIE => r_garantie.nomgar,
                                                LIBELLE      => r_garantie.libelle,
                                                NUMFOR       => r_garantie.numfor,
                                                DATE_DEBUT   => r_garantie.datapli,
                                                DATE_FIN     => r_garantie.datper,
                                                TYPE_GAR     => r_garantie.typgar,
                                                FLAG_REGIME  => r_garantie.flag_regime,
                                                OBLIGATOIRE  => r_garantie.obligatoire,
                                                NB_ADULTE    => null,
                                                NB_ENFANT    => null,
                                                CODES_DSN    => null
                                                );
              IF loc_tab_grnts(1) IS NOT NULL THEN loc_tab_grnts.extend(1); END IF;
              loc_tab_grnts(loc_tab_grnts.count) := loc_garantie;
            --END IF;
            END LOOP curseur_garanties;
         /* BEGIN
          SELECT d.numenvers
          INTO   V_NUMGAR_BASE
          FROM dependance d
              WHERE d.numde = R_ADHESION.numgar
              AND d.role = 2
              AND d.type =2
              AND exists (select 1 from ADHE_CNTRT ac where ac.NUMGAR=d.numenvers AND ac.NUMADHE=R_SALARIER.numindiv); -- M0006304 PBO filtre sur le contrat de base de l'adhérent;

              EXCEPTION WHEN OTHERS
              THEN
                V_NUMGAR_BASE := null;
          END;*/

            IF loc_tab_adhesion(1) IS NOT NULL THEN loc_tab_adhesion.extend(1); END IF;
            loc_tab_adhesion(loc_tab_adhesion.count) := new   EXTR_ADHESION_TR(
                                                          numgar       => R_ADHESION.numgar,
                                                          refCie       => R_ADHESION.refcie,
                                                          college      => R_ADHESION.COLLEGE||'|'||F_LBLE('COLLEGE',R_ADHESION.COLLEGE),
                                                          Cntrt_base   => NULL,
                                                          idadhesion   => R_ADHESION.idadhesion,
                                                          etat         => R_ADHESION.etat_adhe,
                                                          libetat      => f_lble('ET_ADHE',R_ADHESION.etat_adhe),
                                                          motif        => R_ADHESION.motif_adhe,
                                                          libMotif     => f_lble('HISTO_ADHE',R_ADHESION.motif_adhe ),
                                                          dateDebut    => R_ADHESION.datapli,
                                                          dateFin      => R_ADHESION.datper,
                                                          Modpmt       => R_ADHESION.MREGL,
                                                          Libmodpmt    => pk_libelle.f_lib('MREGL', R_ADHESION.MREGL ),
                                                          dateModif    => R_ADHESION.maj,
                                                          typeModif    => R_ADHESION.type_mouvement,
                                                          ayant_droits => null,
                                                          garanties    => loc_tab_grnts
                                                       );

            EXIT;--on ne remonte qu'une seule adhésion TODO RG à revoir certainement sur lot 3
           END LOOP;
           --on ne remonte le salarié que s'il a une adhésion prévoyance
           IF loc_tab_adhesion(1) IS NOT NULL THEN
             loc_affil        := new  EXTR_AFFILIE_EMPLOYEE(  Numindiv    => R_SALARIER.numindiv,
                                                                  Nom         => R_SALARIER.nom,
                                                                  Prenom      => R_SALARIER.prenom,
                                                                  Matorg      => R_SALARIER.matorg||LPAD(to_char(R_SALARIER.cless),2,'0'),
                                                                  Datnais     => R_SALARIER.datnais,
                                                                  Rang        => R_SALARIER.rang,
                                                                  Qualite     => R_SALARIER.qualite,
                                                                  Lib_qualite => R_SALARIER.lib_qualite,
                                                                  regime      => R_SALARIER.regime,
                                                                  caisse      => R_SALARIER.caisse,
                                                                  centre      => R_SALARIER.GUICHETORG,
                                                                  email       => R_SALARIER.lemail,
                                                                  telephone   => R_SALARIER.ltelephone,
                                                                  Adresse     => loc_adresse,
                                                                  Adhesions   => loc_tab_adhesion
                                                              );

             IF loc_tab_affil(1) IS NOT NULL THEN loc_tab_affil.extend(1); END IF;
             loc_tab_affil(loc_tab_affil.count) := loc_affil;
           END IF;


        END LOOP cursor_salarier;

   RETURN  new EXTR_R_LIST_EMPLOYEE(loc_tab_affil);
 EXCEPTION
   WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_list_employ_niv_6',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => SQLERRM,
        I_idligne  => 2);
    RETURN  new EXTR_R_LIST_EMPLOYEE(null);

 END  F_list_employ_niv_6;

 /****************************************************************************/
  /* FUNCTION                                                                   */
/* Nom          :  F_list_employ_niv_7                                          */
/* Type         :  Public                                                       */
/* Description  :  remonte les salariés affiliés sur des contrats santé et/ou
                prévoyance ouverts sur la porte dédiée (contexte 27 espace RH).
                Niveau détail = 7                                               */
/* paramètres entrants :  numéro de l'adhérent, son nom, prenom, n°secu,
                          datnais, numéro de la société, numéro de contrat,
                          la catégorie du contrat                               */
/* Date         :  09/06/2020                                                   */
/* Commentaire  :  Projet P202004001 IRIS ENTREPRISE                            */
/* Retour       : tableau d'affiliés avec adhésions et garanties                */
  /*****************************************************************************/
 FUNCTION F_list_employ_niv_7  (i_numindiv individu.numindiv%type,
                                i_nom individu.nom%type,
                                i_prenom individu.prenom%type,
                                i_matorg individu.matorg%type,
                                i_datnais individu.datnais%type,
                                i_numcli individu.numindiv%type,
                                i_numgar contrat.numgar%type,
                                i_college contrat.college%type
                                )  RETURN  EXTR_R_LIST_EMPLOYEE
 IS

 CURSOR c_salarier_niveau_7(  p_numindiv individu.numindiv%type,
                                p_nom individu.nom%type,
                                p_prenom individu.prenom%type,
                                p_matorg individu.matorg%type,
                                p_datnais individu.datnais%type,
                                p_numcli individu.numindiv%type,
                                p_numgar contrat.numgar%type ,
                                p_college contrat.college%type
                               -- ,p_porte porte_contrat.numporte%TYPE
                               )
    IS
     SELECT individu.* ,  F_LBLE('QLTE',INDIVIDU.QUALITE) lib_qualite, f_coordonne_contact(numindiv,4,1) lemail,  f_coordonne_contact(numindiv,1,1)  ltelephone
     FROM individu
     WHERE numindiv     = nvl(p_numindiv,numindiv)
     AND datnais = NVL(p_datnais,datnais)
     AND UPPER(nom)    =UPPER(nvl(p_nom, nom))
     AND UPPER(prenom)  =UPPER(nvl(p_prenom, prenom))
     AND (UPPER(matorg)  = UPPER(nvl(substr(p_matorg,0,13), matorg))
       OR UPPER(matorg2)  = UPPER(nvl(substr(p_matorg,0,13), matorg2)))
     AND EXISTS (select numadhe from adhe_cntrt where numadhe = individu.numindiv)
     AND EXISTS( SELECT 1                          -- On ne remonte que les individus si il est dans le périmétre du numcli et du contrat
                  FROM   adhesion a,
                         contrat c,
                         porte_contrat p
                  WHERE a.numgar  = c.numgar
                   AND c.numgar   = NVL(p_numgar, c.numgar)    -- au niveau on fait au minimum avec le numcli
                   AND c.college  = NVL (p_college,c.college)
                   AND c.numcli   = p_numcli
                   AND a.numindiv = individu.numindiv
                  -- AND (a.datper is NULL  OR add_months(sysdate,-3) < a.datper)   --en vigueur ou résilié il ya moins de 3moins
                   AND NVL(datper,sysdate)>= sysdate   --en vigueur ou résilié dans le futur (date de fin de couverture postérieure à la date du jour)
                   AND p.numgar = c.numgar
                   AND (p.numporte =20 -- porte DSN
                  OR (c.gest_cotis <>1 and c.typgar=1))  --contrat collectifs en cotisations non gérés de type groupe
                 )
  ;

  CURSOR c_adhesion_niveau_7 ( p_numindiv individu.numindiv%type, p_numcli contrat_ref.numcli%TYPE/*, p_porte porte_contrat.numporte%TYPE*/) IS
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
                    cr.numcli ,
                    ad.date_adhe,
                    a.typfor,
                    cr.portefeuille
                    ,a.rang --RKO M0006916	filtre pour les adhesions croisées, on remonte l'adhesion sur l'assuré principal donc rang 1
    FROM adhesion a, adhe_cntrt ad, contrat cr,porte_contrat p
    WHERE a.idadhesion = ad.idadhesion--479639   --479846
    AND numindiv = p_numindiv   --183382--4796--141022
    AND cr.numgar = a.numgar
    AND p.numgar = cr.numgar
    AND cr.numcli = p_numcli
    -- couverture active
    AND sysdate between a.datapli AND NVL(a.datper ,sysdate)
    --and cr.numgar=7634  --7685
    -- AND p.numporte in (25,27,30)
    AND (p.numporte =20 -- porte DSN
     OR (cr.gest_cotis <>1 and cr.typgar=1))  --contrat collectifs en cotisations non gérés de type groupe
    -- Exclusion des cas ouverts et clos le même jour
    AND a.datapli <> NVL(a.datper,e2d('01/01/1900'))
    --AND a.typfor in(1,2)       --SANTE ET PREVOYANCE
    AND pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe, sysdate),  a_type=>1) =1 --en vigueur
    AND NOT EXISTS(
      SELECT numde FROM dependance
      WHERE numde=cr.numgar AND role =6 AND sysdate BETWEEN datapli AND NVL(datper,sysdate)) --on privilegie le contrat mensu
    ORDER BY a.typfor,a.rang, cr.portefeuille, ad.date_adhe desc,a.idadhesion desc
      ;

  CURSOR c_garanties_niveau_7(p_idadhesion adhesion.idadhesion%type) IS
    SELECT distinct gc.numfor, gc.NOMGAR, gc.LIBELLE, a.DATAPLI, a.DATPER, NULL FLAG_REGIME, NULL OBLIGATOIRE, NULL TYPGAR
    FROM adhesion a, gar_cntrt gc
    WHERE a.idadhesion = p_idadhesion
    AND a.numfor = gc.numfor
    AND a.datapli <> nvl(a.datper,a.datapli+1)
    ;

  loc_tab_grnts        EXTR_TAB_GRNTS_TR;
  loc_garantie         EXTR_GRNTS_TR;

  loc_affil            EXTR_AFFILIE_EMPLOYEE;
  loc_adresse          EXTR_ADRESSE_TR;
  loc_tab_affil        EXTR_TAB_AFFILIE_EMPLOYEE;
  loc_tab_adhesion     EXTR_TAB_ADHESION_TR ;

  V_NUMGAR_BASE        NUMBER;

 BEGIN
       loc_tab_adhesion    := new   EXTR_TAB_ADHESION_TR(null);
       loc_tab_affil       := new  EXTR_TAB_AFFILIE_EMPLOYEE(null);
       loc_tab_adhesion    := new   EXTR_TAB_ADHESION_TR(null);

        FOR R_SALARIER IN c_salarier_niveau_7(i_numindiv, i_nom, i_prenom, i_matorg,i_datnais, i_numcli, i_numgar,i_college/*,30*/) LOOP
          loc_adresse := F_ADRESSE_BY_NUMINDIV(R_SALARIER.numindiv);
          FOR r_adhesion in c_adhesion_niveau_7(R_SALARIER.numindiv,i_numcli/*,30*/) LOOP

            loc_tab_grnts := new EXTR_TAB_GRNTS_TR(null);

            FOR R_GARANTIE IN c_garanties_niveau_7(r_adhesion.idadhesion) LOOP
              loc_garantie     := new   EXTR_GRNTS_TR(  NOM_GARANTIE => r_garantie.nomgar,
                                                LIBELLE      => r_garantie.libelle,
                                                NUMFOR       => r_garantie.numfor,
                                                DATE_DEBUT   => r_garantie.datapli,
                                                DATE_FIN     => r_garantie.datper,
                                                TYPE_GAR     => r_garantie.typgar,
                                                FLAG_REGIME  => r_garantie.flag_regime,
                                                OBLIGATOIRE  => r_garantie.obligatoire,
                                                NB_ADULTE    => null,
                                                NB_ENFANT    => null,
                                                CODES_DSN    => null
                                                );
              IF loc_tab_grnts(1) IS NOT NULL THEN loc_tab_grnts.extend(1); END IF;
              loc_tab_grnts(loc_tab_grnts.count) := loc_garantie;
            END LOOP curseur_garanties;

            IF loc_tab_adhesion(1) IS NOT NULL THEN loc_tab_adhesion.extend(1); END IF;

            BEGIN
              SELECT d.numenvers
              INTO   V_NUMGAR_BASE
              FROM dependance d
              WHERE d.numde = R_ADHESION.NUMGAR
              AND d.role = 2
              AND d.type =2  ;

              EXCEPTION
                WHEN OTHERS THEN
                V_NUMGAR_BASE := null;
            END;
            loc_tab_adhesion(loc_tab_adhesion.count) := new   EXTR_ADHESION_TR(
                                                          numgar       => R_ADHESION.numgar,
                                                          refCie       => R_ADHESION.refcie,
                                                          college      => R_ADHESION.COLLEGE||'|'||F_LBLE('COLLEGE',R_ADHESION.COLLEGE),
                                                          Cntrt_base   => NVL(V_NUMGAR_BASE,R_ADHESION.numgar),--NULL,
                                                          idadhesion   => R_ADHESION.idadhesion,
                                                          etat         => R_ADHESION.etat_adhe,
                                                          libetat      => f_lble('ET_ADHE',R_ADHESION.etat_adhe),
                                                          motif        => R_ADHESION.motif_adhe,
                                                          libMotif     => f_lble('HISTO_ADHE',R_ADHESION.motif_adhe ),
                                                          dateDebut    => R_ADHESION.datapli,
                                                          dateFin      => R_ADHESION.datper,
                                                          Modpmt       => R_ADHESION.MREGL,
                                                          Libmodpmt    => pk_libelle.f_lib('MREGL', R_ADHESION.MREGL ),
                                                          dateModif    => R_ADHESION.maj,
                                                          typeModif    => R_ADHESION.type_mouvement,
                                                          ayant_droits => null,
                                                          garanties    => loc_tab_grnts
                                                       );

            EXIT;--on ne remonte qu'une seule adhésion
          END LOOP;
          IF loc_tab_adhesion(1) IS NOT NULL THEN
            loc_affil        := new  EXTR_AFFILIE_EMPLOYEE(  Numindiv    => R_SALARIER.numindiv,
                                                                  Nom         => R_SALARIER.nom,
                                                                  Prenom      => R_SALARIER.prenom,
                                                                  Matorg      => R_SALARIER.matorg||LPAD(to_char(R_SALARIER.cless),2,'0'),
                                                                  Datnais     => R_SALARIER.datnais,
                                                                  Rang        => R_SALARIER.rang,
                                                                  Qualite     => R_SALARIER.qualite,
                                                                  Lib_qualite => R_SALARIER.lib_qualite,
                                                                  regime      => R_SALARIER.regime,
                                                                  caisse      => R_SALARIER.caisse,
                                                                  centre      => R_SALARIER.GUICHETORG,
                                                                  email       => R_SALARIER.lemail,
                                                                  telephone   => R_SALARIER.ltelephone,
                                                                  Adresse     => loc_adresse,
                                                                  Adhesions   => loc_tab_adhesion
                                                              );

            IF loc_tab_affil(1) IS NOT NULL THEN loc_tab_affil.extend(1); END IF;
            loc_tab_affil(loc_tab_affil.count) := loc_affil;
          END IF;


        END LOOP cursor_salarier;

   RETURN  new EXTR_R_LIST_EMPLOYEE(loc_tab_affil);
 EXCEPTION
   WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_list_employ_niv_7',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => SQLERRM,
        I_idligne  => 2);
    RETURN  new EXTR_R_LIST_EMPLOYEE(null);

 END  F_list_employ_niv_7;

END PK_WS_WEB_BACK;
/
