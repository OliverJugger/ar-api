CREATE OR REPLACE PACKAGE ARTHUS.PK_DUPLIQ_GAR AS
/*============================================================================*/
/* PACKAGE      : PK_DUPLIQ_GAR.sql                                           */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 02/10/2013                                                  */
/* Description  : Package permettant la duplication des garanties             */
/*============================================================================*/
/* Evolution    : Ajout de la colonne GARANTIES.GEST_CALC dans les insertions */
/* Auteur       : JBO                                                         */
/* Date         : 02/10/2013                                                  */
/* Commentaire  : Mise en place du module du calcul des prestations prévoyance*/
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/
PROCEDURE p_ins_gar(
    i_numprod     IN NUMBER,
    i_nomgar      IN VARCHAR2,
    i_lib_nogar   IN VARCHAR2,
    i_datapli     IN DATE,
    i_numfor_ref  IN NUMBER,
    i_fran_gar    IN NUMBER,
    i_max_gar     IN NUMBER,
    i_fran_act    IN NUMBER,
    i_max_act     IN NUMBER,
    i_carence_act IN NUMBER,
    I_don_comp    IN NUMBER,
    i_numprod_ref IN NUMBER,
    i_code_pays   IN NUMBER,
    i_session     IN NUMBER,
    i_date        IN DATE,
    i_ins_journal IN BOOLEAN DEFAULT FALSE );

  --
  -- Procedure de duplication des garanties par rapport a une garantie de
  -- reference. Procedure appelee par la forme gg05.inp.
  --
PROCEDURE p_ins_gar2(
    i_numfor      IN gar_cntrt.numfor%TYPE,
    i_code_pays   IN NUMBER,
    i_session     IN NUMBER,
    i_date        IN DATE,
    i_ins_journal IN BOOLEAN DEFAULT FALSE );
  -- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_DUPLIQ_GAR AS
/*============================================================================*/
/* PACKAGE      : PK_DUPLIQ_GAR.sql                                           */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 02/10/2013                                                  */
/* Description  : Package permettant la duplication des garanties             */
/*============================================================================*/
/* Evolution    : Ajout de la colonne GARANTIES.GEST_CALC dans les insertions */
/* Auteur       : JBO                                                         */
/* Date         : 02/10/2013                                                  */
/* Commentaire  : Mise en place du module du calcul des prestations prévoyance*/
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/


  -- Variable concernant la Trace
  G_nom_traitement Journal_adm.nom_traitement%TYPE DEFAULT 'pk_dupliq_gar';
  G_niv_msg Journal_adm.niv_msg%TYPE;
  G_msg_adm Journal_adm.msg_adm%TYPE;
  G_idligne Journal_adm.idligne%TYPE;


PROCEDURE P_nextval_numfor(
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    O_next_numfor OUT NUMBER)
IS
BEGIN
  SELECT numfor.nextval INTO O_next_numfor FROM DUAL;
  --
  IF I_ins_journal THEN
    G_idligne := 1;
    G_msg_adm := 'Nouveau numero Numfor : '||O_next_numfor;
    PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
  END IF;
  --
END;
--

--
FUNCTION F_CTRL_frmls(
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor      IN frmls.numfor%TYPE)
  RETURN BOOLEAN
IS
  CURSOR C_frmls
  IS
    SELECT 'x' FROM frmls WHERE numfor = I_numfor;
  --
  L_test       VARCHAR2(1);
  L_trouve     BOOLEAN;
  L_aff_trouve VARCHAR2(10);
  --
BEGIN
  OPEN C_frmls;
  FETCH C_frmls INTO L_test;
  IF C_frmls%FOUND THEN
    L_trouve     := TRUE;
    L_aff_trouve := 'trouve';
  ELSE
    L_trouve     := FALSE;
    L_aff_trouve := 'Non trouve';
  END IF;
  --
  CLOSE C_frmls;
  --
  IF I_ins_journal THEN
    G_idligne := 2;
    G_msg_adm := 'Ligne '||L_aff_trouve||' dans Frmls a partir du numfor de '|| 'reference '|| I_numfor;
    PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
  END IF;
  RETURN(L_trouve);
END;

--
PROCEDURE P_INS_franfor(
    I_next_numfor IN franfor.numfor%TYPE,
    I_datapli     IN franfor.datapli%TYPE,
    I_datper      IN franfor.datper%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN franfor.numfor%TYPE)
IS
  --
BEGIN
  INSERT
  INTO FRANFOR
    (
      numfor,
      datapli,
      datper,
      typfran,
      montant,
      indice,
      datref,
      nbindice,
      taux,
      frequence,
      etendue,
      domaine
    )
  SELECT I_next_numfor,
    greatest(I_datapli,franfor.datapli),
    least(I_datper, franfor.datper),
    typfran,
    montant,
    indice,
    datref,
    nbindice,
    taux,
    frequence,
    etendue,
    domaine
  FROM FRANFOR
  WHERE franfor.numfor                      = I_numfor_ref
  AND greatest(I_datapli, franfor.datapli) <= least(I_datper, NVL(franfor.datper,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 3;
      G_msg_adm := 'Ligne inseree dans franfor : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_maxfor(
    I_next_numfor IN maxfor.numfor%TYPE,
    I_datapli     IN maxfor.datapli%TYPE,
    I_datper      IN maxfor.datper%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN maxfor.numfor%TYPE)
IS
  --
BEGIN
  INSERT
  INTO MAXFOR
    (
      numfor,
      datapli,
      datper,
      montant,
      indice,
      datref,
      nbindice,
      taux,
      etendue,
      domaine,
      nummath,
      nummath_c
    )
  SELECT I_next_numfor,
    greatest(I_datapli,maxfor.datapli),
    least( I_datper, maxfor.datper),
    montant,
    indice,
    datref,
    nbindice,
    taux,
    etendue,
    domaine,
    nummath,
    nummath_c
  FROM MAXFOR
  WHERE maxfor.numfor                       = I_numfor_ref
  AND greatest( I_datapli, maxfor.datapli) <= least( I_datper, NVL(maxfor.datper,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 4;
      G_msg_adm := 'Ligne inseree dans Maxfor : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_dfrb(
    I_next_numfor IN dfrb.numfor%TYPE,
    I_datapli     IN dfrb.datapli%TYPE,
    I_datper      IN dfrb.datper%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN dfrb.numfor%TYPE)
IS
BEGIN
  INSERT INTO DFRB
    ( numfor, codfrais, datapli, datper, type_acte
    )
  SELECT I_next_numfor,
    codfrais,
    greatest(I_datapli, dfrb.datapli),
    least(I_datper,dfrb.datper),
    type_acte
  FROM DFRB
  WHERE numfor                          = I_numfor_ref
  AND greatest(I_datapli,dfrb.datapli) <= least( I_datper, NVL(dfrb.datper,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 5;
      G_msg_adm := 'Ligne inseree dans Dfrb : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_sqrb(
    I_next_numfor IN sqrb.numfor%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN sqrb.numfor%TYPE)
IS
BEGIN
  INSERT INTO SQRB
    ( numfor, codfrais, sequence, def
    )
  SELECT I_next_numfor,
    codfrais,
    sequence,
    def
  FROM sqrb
  WHERE sqrb.numfor = I_numfor_ref;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 6;
      G_msg_adm := 'Ligne inseree dans sqrb : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_franact(
    I_next_numfor IN franact.numfor%TYPE,
    I_datapli     IN franact.datapli%TYPE,
    I_datper      IN franact.datper%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN franact.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO FRANACT
    (
      numfor,
      codfrais,
      datapli,
      datper,
      typfran,
      frequence,
      etendue,
      domaine,
      montant,
      indice,
      datref,
      nbindice,
      taux
    )
  SELECT I_next_numfor,
    codfrais,
    greatest( I_datapli, franact.datapli),
    least( I_datper, franact.datper),
    typfran,
    frequence,
    etendue,
    domaine,
    montant,
    indice,
    datref,
    nbindice,
    taux
  FROM FRANACT
  WHERE FRANACT.NUMFOR                       = I_numfor_ref
  AND greatest( I_datapli, franact.datapli) <= least( I_datper, NVL(franact.datper,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 7;
      G_msg_adm := 'Ligne inseree dans franact : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_maxact(
    I_next_numfor IN maxact.numfor%TYPE,
    I_datapli     IN maxact.datapli%TYPE,
    I_datper      IN maxact.datper%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN maxact.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO MAXACT
    (
      numfor,
      codfrais,
      datapli,
      datper,
      nbactes,
      montant,
      indice,
      datref,
      nbindice,
      taux,
      etendue,
      domaine,
      nummath,
      nummath_c
    )
  SELECT I_next_numfor,
    codfrais,
    greatest( I_datapli, maxact.datapli),
    least( I_datper, maxact.datper),
    nbactes,
    montant,
    indice,
    datref,
    nbindice,
    taux,
    etendue,
    domaine,
    nummath,
    nummath_c
  FROM MAXACT
  WHERE MAXACT.NUMFOR                       = I_numfor_ref
  AND greatest( I_datapli, maxact.datapli) <= least( I_datper, NVL(maxact.datper,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 8;
      G_msg_adm := 'Ligne inseree dans maxact : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_calcul(
    I_next_numfor IN calcul.numfor%TYPE,
    I_datapli     IN calcul.datapli%TYPE,
    I_datper      IN calcul.datper%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN calcul.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO CALCUL
    (
      numfor,
      codfrais,
      datapli,
      datper,
      nummath,
      X,
	  Y,
      type_acte,
      rubrique
    )
  SELECT I_next_numfor,
    calcul.codfrais,
    greatest( I_datapli, calcul.datapli),
    least( I_datper, calcul.datper),
    calcul.nummath,
    X,
	Y,
    type_acte,
    rubrique
  FROM calcul
  WHERE calcul.numfor                       = I_numfor_ref
  AND greatest( I_datapli, calcul.datapli) <= least( I_datper, NVL(calcul.datper,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 9;
      G_msg_adm := 'Ligne inseree dans Calcul: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_crnc(
    I_next_numfor IN crnc.numfor%TYPE,
    I_datapli     IN crnc.datapli%TYPE,
    I_datper      IN crnc.datper%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN crnc.numfor%TYPE)
IS
BEGIN
  INSERT INTO CRNC
    ( numfor, codfrais, datapli, datper, delai, type, nummath
    )
  SELECT I_next_numfor,
    codfrais,
    greatest( I_datapli, crnc.datapli),
    least( I_datper, crnc.datper),
    delai,
    type,
    nummath
  FROM CRNC
  WHERE CRNC.NUMFOR                       = I_numfor_ref
  AND greatest( I_datapli, crnc.datapli) <= least( I_datper, NVL(crnc.datper,I_datper));

  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 10;
      G_msg_adm := 'Ligne inseree dans Crnc: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--
PROCEDURE P_INS_VAR(
    I_next_numfor IN crnc.numfor%TYPE,
    I_datapli     IN crnc.datapli%TYPE,
    I_datper      IN crnc.datper%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN crnc.numfor%TYPE)
IS
BEGIN

  INSERT INTO VAL_VARIABLE
    ( IDVARIABLE, ETENDUE, CLEF, STATIQUE, DEBUT, FIN, VALIDE, VALEUR, NUMGAR)
  SELECT IDVARIABLE,ETENDUE, I_next_numfor,STATIQUE, greatest( I_datapli, VAL_VARIABLE.debut),
    least( I_datper, VAL_VARIABLE.fin),VALIDE,VALEUR,NUMGAR
  FROM VAL_VARIABLE
  WHERE VAL_VARIABLE.CLEF = I_numfor_ref AND ETENDUE =25
  AND greatest( I_datapli, VAL_VARIABLE.DEBUT) <= least( I_datper, NVL(VAL_VARIABLE.FIN,I_datper));

  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 11;
      G_msg_adm := 'Ligne inseree dans val_variable: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END P_INS_VAR;
--
PROCEDURE P_INS_formule(
    I_next_numfor IN formule.numfor%TYPE,
    I_lib_nogar   IN formule.libelle%TYPE,
    I_nomgar      IN Formule.nomgar%TYPE,
    I_valide      IN formule.valide%TYPE,
    I_numprod     IN formule.numprod%TYPE,
    I_datapli     IN formule.debut%TYPE,
    I_datper      IN formule.fin%TYPE,
    I_ins_journal IN BOOLEAN,
    I_date        IN DATE,
    I_session     IN NUMBER,
    I_numfor_ref  IN formule.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO FORMULE
    (
      numfor,
      libelle,
      monnaie,
      nomgar,
      q_medic,
      typgar,
      gar,
      branche,
      code_cmcr,
      compte,
      debut,
      fin,
      valide,
      numprod,
      ct_resp,
      obligatoire,
      flag_regime,
      nat_calc,
      numass,
      MOD_APP,
      ARRONDI_PRORATA,
      UNITCALC,
      NBUNITCALC,
      TYPEUNITCALC,
      IND_EDIT,
      IND_OPTION,
      NUM_ORDRE,
      LIB_EDIT,
      IMG_DGAR,
      CODE_REASS,
      CENTRE_ANALYTIQUE,
      J_GRATUIT,
      NAT_RISQ ,
      OBLI_BENE,
	  ENGAGEMENT
    )
  SELECT I_next_numfor,
    I_lib_nogar,
    f.monnaie,
    I_nomgar,
    f.q_medic,
    f.typgar,
    f.gar,
    f.branche,
    f.code_cmcr,
    NULL,
    greatest( I_datapli, f.debut),
    least( I_datper, f.fin),
    I_valide,
    I_numprod,
    f.ct_resp,
    f.obligatoire,
    f.flag_regime,
    f.nat_calc,
    f.numass,
    f.MOD_APP,
    f.ARRONDI_PRORATA,
    f.UNITCALC,
    f.NBUNITCALC,
    f.TYPEUNITCALC,
    f.IND_EDIT,
    f.IND_OPTION,
    f.NUM_ORDRE,
    f.LIB_EDIT,
    f.IMG_DGAR,
    f.CODE_REASS,
    f.CENTRE_ANALYTIQUE,
    f.J_GRATUIT,
    f.NAT_RISQ,
    f.obli_bene,
	f.ENGAGEMENT
  FROM formule f
  WHERE f.NUMFOR                     = I_numfor_ref
  AND greatest( I_datapli, f.debut) <= least( I_datper, NVL(f.fin,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 11;
      G_msg_adm := 'Ligne inseree dans formule : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_garanties(
    I_nat_gar     IN garanties.nat_gar%TYPE,
    I_etendue     IN garanties.etendue%TYPE,
    I_next_numfor IN garanties.numfor%TYPE,
    I_lib_nogar   IN garanties.libelle%TYPE,
    I_nomgar      IN garanties.nomgar%TYPE,
    I_valide      IN garanties.valide%TYPE,
    I_numprod     IN garanties.cle%TYPE,
    I_datapli     IN garanties.debut%TYPE,
    I_datper      IN garanties.fin%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN garanties.numfor_ref%TYPE)
IS
BEGIN
  INSERT
  INTO GARANTIES
    (
      nat_gar,
      etendue,
      cle,
      numfor,
      nomgar,
      libelle,
      numass,
      nat_risq,
      typgar,
      numforbis,
      numfor_ref,
      code_cmcr,
      code_c4,
      code_reass,
      classe_gar,
      type_dest,
      type_bene,
      debut,
      fin,
      valide,
      obligatoire,
      nat_calc,
      MOD_APP,
      ARRONDI_PRORATA,
      UNITCALC,
      NBUNITCALC,
      TYPEUNITCALC,
      IND_EDIT,
      IND_OPTION,
      NUM_ORDRE,
      LIB_EDIT,
      IMG_DGAR,
      CENTRE_ANALYTIQUE,
      J_GRATUIT,
      TYPE_DEST_DCPT,
      GEST_CALC
    )
  SELECT I_nat_gar,
    I_etendue,
    I_numprod,
    I_next_numfor,
    I_nomgar,
    I_lib_nogar,
    g.numass,
    g.nat_risq,
    g.typgar,
    g.numforbis,
    I_numfor_ref,
    g.code_cmcr,
    g.code_c4,
    g.code_reass,
    g.classe_gar,
    g.type_dest,
    g.type_bene,
    greatest( I_datapli, g.debut),
    least( I_datper, g.fin),
    I_valide,
    g.obligatoire,
    g.nat_calc,
    g.MOD_APP,
    g.ARRONDI_PRORATA,
    g.UNITCALC,
    g.NBUNITCALC,
    g.TYPEUNITCALC,
    g.IND_EDIT,
    g.IND_OPTION,
    g.NUM_ORDRE,
    g.LIB_EDIT,
    g.IMG_DGAR,
    g.CENTRE_ANALYTIQUE,
    g.J_GRATUIT,
    g.TYPE_DEST_DCPT,
    g.GEST_CALC
  FROM garanties g
  WHERE g.numfor = I_numfor_ref;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 12;
      G_msg_adm := 'Ligne inseree dans garanties: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_gar_prev(
    I_next_numfor IN gar_prev.numfor%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN gar_prev.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO gar_prev
    (
      TYPE_CALC,
      TYPE_PERIOD,
      SIN_ANT,
      SIN_POST,
      GAR_FISC,
      TYPE_TERME,
      TYPE_BASE_REF,
      TYPE_FRAN,
      LIMITE_PREST,
      UNIT_DECLA,
      DELAI_DECLA,
      UNIT_FRAN,
      DUREE_FRAN,
      NAT_FRAN,
      UNIT_RECHUTE,
      DELAI_RECHUTE,
      NUMFOR
    )
  SELECT GAR_PREV.TYPE_CALC,
    GAR_PREV.TYPE_PERIOD,
    GAR_PREV.SIN_ANT,
    GAR_PREV.SIN_POST,
    GAR_PREV.GAR_FISC,
    GAR_PREV.TYPE_TERME,
    GAR_PREV.TYPE_BASE_REF,
    GAR_PREV.TYPE_FRAN,
    GAR_PREV.LIMITE_PREST,
    GAR_PREV.UNIT_DECLA,
    GAR_PREV.DELAI_DECLA,
    GAR_PREV.UNIT_FRAN,
    GAR_PREV.DUREE_FRAN,
    GAR_PREV.NAT_FRAN,
    GAR_PREV.UNIT_RECHUTE,
    GAR_PREV.DELAI_RECHUTE,
    i_next_numfor
  FROM GAR_PREV
  WHERE gar_prev.numfor=I_numfor_ref;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 13;
      G_msg_adm := 'Ligne inseree dans Gar_prev: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_bene_gar(
    I_next_numfor IN bene_gar.numfor%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN bene_gar.numfor%TYPE)
IS
BEGIN
  INSERT INTO bene_gar
    (numfor, type_bene
    )
  SELECT I_next_numfor,
    type_bene
  FROM bene_gar
  WHERE bene_gar.numfor=I_numfor_ref;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 14;
      G_msg_adm := 'Ligne inseree dans Bene_gar: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--
--
PROCEDURE P_INS_frml_reval(
    I_next_numfor IN frml_reval.numfor%TYPE,
    I_datapli     IN frml_reval.debut%TYPE,
    I_datper      IN frml_reval.fin%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN frml_reval.numfor%TYPE)
IS
BEGIN
  INSERT INTO FRML_REVAL
    ( numfor, idformule, debut, valide, fin
    )
  SELECT I_next_numfor,
    idformule,
    greatest( I_datapli, frml_reval.debut),
    frml_reval.valide,
    least( I_datper, frml_reval.fin)
  FROM FRML_REVAL
  WHERE numfor                                = I_numfor_ref
  AND greatest( I_datapli, frml_reval.debut) <= least( I_datper, NVL(frml_reval.fin,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 15;
      G_msg_adm := 'Ligne inseree dans frml_reval: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_frml_dedu(
    I_next_numfor IN frml_dedu.numfor%TYPE,
    I_datapli     IN frml_dedu.debut%TYPE,
    I_datper      IN frml_dedu.fin%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN frml_dedu.numfor%TYPE)
IS
BEGIN
  INSERT INTO FRML_DEDU
    ( numfor, typdedu, idformule, debut, valide, fin
    )
  SELECT I_next_numfor,
    typdedu,
    idformule,
    greatest( I_datapli, frml_dedu.debut),
    frml_dedu.valide,
    least( I_datper, frml_dedu.fin)
  FROM FRML_DEDU
  WHERE numfor                               = I_numfor_ref
  AND greatest( I_datapli, frml_dedu.debut) <= least( I_datper, NVL(frml_dedu.fin,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 16;
      G_msg_adm := 'Ligne inseree dans frml_dedu: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--
--
PROCEDURE P_INS_frml_prest(
    I_next_numfor IN frml_prest.numfor%TYPE,
    I_datapli     IN frml_prest.debut%TYPE,
    I_datper      IN frml_prest.fin%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN frml_prest.numfor%TYPE)
IS
BEGIN
  INSERT INTO FRML_PREST
    ( numfor, idformule, debut, valide, fin
    )
  SELECT I_next_numfor,
    idformule,
    greatest( I_datapli, frml_prest.debut),
    frml_prest.valide,
    least( I_datper, frml_prest.fin)
  FROM FRML_PREST
  WHERE numfor                                = I_numfor_ref
  AND greatest( I_datapli, frml_prest.debut) <= least( I_datper, NVL(frml_prest.fin,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 17;
      G_msg_adm := 'Ligne inseree dans frml_prest: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_for_variable(
    I_next_numfor IN for_variable.numfor%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN for_variable.numfor%TYPE)
IS
BEGIN
  INSERT INTO FOR_VARIABLE
    ( numfor, idvariable, etendue
    )
  SELECT I_next_numfor,
    idvariable,
    etendue
  FROM FOR_VARIABLE
  WHERE numfor = I_numfor_ref;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 18;
      G_msg_adm := 'Ligne inseree dans for_variable : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_justif(
    I_next_numfor IN justif.numfor%TYPE,
    I_contexte    IN justif.contexte%TYPE,
    I_numprod     IN justif.entite%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN justif.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO JUSTIF
    (
      contexte,
      entite,
      numfor,
      type_piece,
      nopiece,
      delai,
      period,
      bloc
    )
  SELECT I_contexte,
    I_numprod,
    I_next_numfor,
    type_piece,
    nopiece,
    delai,
    period,
    bloc
  FROM JUSTIF
  WHERE numfor = I_numfor_ref;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 19;
      G_msg_adm := 'Ligne inseree dans justif: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
--  Insertion des pieces globales
PROCEDURE P_INS_justif_global(
    I_numfor      IN justif.numfor%TYPE,
    I_contexte    IN justif.contexte%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numprod     IN justif.entite%TYPE)
IS
BEGIN
  INSERT
  INTO JUSTIF
    (
      contexte,
      entite,
      numfor,
      type_piece,
      nopiece,
      delai,
      period,
      bloc
    )
  SELECT I_contexte,
    I_numprod,
    I_numfor,
    type_piece,
    nopiece,
    delai,
    period,
    bloc
  FROM JUSTIF
  WHERE numfor = I_numfor
  AND contexte = I_contexte
  AND entite   = I_numprod
  AND NOT EXISTS
    (SELECT 1
    FROM justif a
    WHERE a.contexte = I_contexte
    AND a.entite     = I_numprod
    AND a.numfor     = I_numfor
    AND a.type_piece = justif.type_piece
    AND a.nopiece    = justif.nopiece
    );
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 20;
      G_msg_adm := 'Ligne inseree dans justif: Entite(numprod) --> '|| I_numprod;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_libgar(
    I_next_numfor IN libgar.numfor%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN libgar.numfor%TYPE)
IS
BEGIN
  INSERT INTO LIBGAR
    ( numfor, texte, numligne
    )
  SELECT I_next_numfor, texte, numligne FROM LIBGAR WHERE numfor = I_numfor_ref;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 21;
      G_msg_adm := 'Ligne inseree dans Libgar: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_frml_prime(
    I_next_numfor IN frml_prime.numfor%TYPE,
    I_numprod     IN frml_prime.clef%TYPE,
    I_etendue     IN frml_prime.etendue%TYPE,
    I_valide      IN frml_prime.valide%TYPE,
    I_datapli     IN frml_prime.debut%TYPE,
    I_datper      IN frml_prime.fin%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN frml_prime.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO FRML_PRIME
    (
      numfor,
      etendue,
      clef,
      nomgar,
      seq,
      debut,
      fin,
      valide,
      base,
      contenu,
      taux
    )
  SELECT I_next_numfor,
    I_etendue,
    I_numprod,
    frml_prime.nomgar,
    frml_prime.seq,
    greatest( I_datapli, frml_prime.debut),
    least( I_datper, frml_prime.fin),
    I_valide,
    frml_prime.base,
    frml_prime.contenu,
    frml_prime.taux
  FROM FRML_PRIME
  WHERE frml_prime.numfor                     = I_numfor_ref
  AND frml_prime.valide                       = I_valide
  AND greatest( I_datapli, frml_prime.debut) <= least( I_datper, NVL(frml_prime.fin,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 22;
      G_msg_adm := 'Ligne inseree dans frml_prime: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
PROCEDURE P_INS_frml_tfc(
    I_next_numfor IN frml_tfc.numfor%TYPE,
    I_datapli     IN frml_tfc.debut%TYPE,
    I_datper      IN frml_tfc.fin%TYPE,
    I_valide      IN frml_tfc.valide%TYPE,
    I_tfc         IN frml_tfc.tfc%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN frml_tfc.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO FRML_TFC
    (
      numfor,
      tfc,
      type_tfc,
      debut,
      fin,
      idformule,
      seq,
      valide,
      numbene,
      prelev_revers,
      mode_calc
    )
  SELECT I_next_numfor,
    frml_tfc.tfc,
    frml_tfc.type_tfc,
    greatest( I_datapli, frml_tfc.debut),
    least( I_datper, frml_tfc.fin),
    frml_tfc.idformule,
    frml_tfc.seq,
    I_valide,
    frml_tfc.numbene,
    frml_tfc.prelev_revers,
    frml_tfc.mode_calc
  FROM frml_tfc
  WHERE frml_tfc.numfor                     = I_numfor_ref
  AND frml_tfc.valide                       = I_valide
  AND frml_tfc.tfc                         != I_tfc
  AND greatest( I_datapli, frml_tfc.debut) <= least( I_datper, NVL(frml_tfc.fin,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 23;
      G_msg_adm := 'Ligne inseree dans frml_tfc: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
-- Frais niveau contrat
PROCEDURE P_INS_frml_tfc_contrat(
    I_numprod     IN frml_tfc.numfor%TYPE,
    I_datapli     IN frml_tfc.debut%TYPE,
    I_datper      IN frml_tfc.fin%TYPE,
    I_valide      IN frml_tfc.valide%TYPE,
    I_tfc         IN frml_tfc.tfc%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numprod_ref IN frml_tfc.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO FRML_TFC
    (
      numfor,
      tfc,
      type_tfc,
      debut,
      fin,
      idformule,
      seq,
      valide,
      numbene,
      prelev_revers,
      mode_calc
    )
  SELECT I_numprod,
    frml_tfc.tfc,
    frml_tfc.type_tfc,
    greatest( I_datapli, frml_tfc.debut),
    least( I_datper, frml_tfc.fin),
    frml_tfc.idformule,
    frml_tfc.seq,
    I_valide,
    frml_tfc.numbene,
    frml_tfc.prelev_revers,
    frml_tfc.mode_calc
  FROM frml_tfc
  WHERE frml_tfc.numfor                     = I_numprod_ref
  AND frml_tfc.valide                       = I_valide
  AND frml_tfc.tfc                          = I_tfc
  AND greatest( I_datapli, frml_tfc.debut) <= least( I_datper, NVL(frml_tfc.fin,I_datper))
  AND NOT EXISTS
    (SELECT 1
    FROM frml_tfc
    WHERE frml_tfc.tfc  = I_tfc
    AND frml_tfc.numfor = I_numprod
    ) ;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 24;
      G_msg_adm := 'Ligne inseree dans frml_tfc: numprod--> '||I_numprod|| ' Numprod_ref --> '||I_numprod_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
-- Insertion des conditions de couverture
PROCEDURE P_INS_cond_adhesion_gar(
    I_next_numfor IN cond_adhesion_gar.numfor%TYPE,
    I_datapli     IN cond_adhesion_gar.debut%TYPE,
    I_datper      IN cond_adhesion_gar.fin%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numfor_ref  IN cond_adhesion_gar.numfor%TYPE)
IS
BEGIN
  INSERT INTO cond_adhesion_gar
    ( numfor, idformule, debut, valide, fin
    )
  SELECT I_next_numfor,
    idformule,
    greatest( I_datapli, cond_adhesion_gar.debut),
    cond_adhesion_gar.valide,
    least( I_datper, cond_adhesion_gar.fin)
  FROM cond_adhesion_gar
  WHERE cond_adhesion_gar.numfor = I_numfor_ref;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 25;
      G_msg_adm := 'Ligne inseree dans cond_adhesion_gar: Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

--
--   Procedure P_INS_valide_texte
--   Insertion dans valide_texte de l'idtexte du produit lors de la
--   creation d'un contrat.
--   I_type 2 : niveau garantie
--
PROCEDURE P_INS_valide_texte(
    I_contexte valide_texte.contexte%TYPE,
    I_ins_journal IN BOOLEAN,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_numero valide_texte.numero%TYPE)
IS
BEGIN
  INSERT
  INTO valide_texte
    (
      contexte,
      numero,
      idtexte,
      code_langue,
      courr_dest,
      mod_pmt,
      numrelance,
      type_dest
    )
  SELECT I_contexte,
    I_numero,
    idtexte,
    code_langue,
    courr_dest,
    mod_pmt,
    numrelance,
    type_dest
  FROM valide_texte
  WHERE contexte = I_contexte
  AND numero     =
    (SELECT numfor_ref FROM gar_cntrt WHERE numfor = I_numero
    ) ;
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 26;
      G_msg_adm :='Ligne inseree dans valide_texte: Next_numfor(numero)--> '|| I_numero;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;
--

-- Procedure utilisees uniquement par la procedure publique P_INS_gar2
--
PROCEDURE P_SEL_contrat(
    I_numgar IN contrat.numgar%TYPE,
    O_numprod_ref OUT contrat.numprod%TYPE)
IS
  --
  CURSOR C_contrat
  IS
    SELECT numprod FROM contrat WHERE numgar = I_numgar;
  --
  Rec_c_contrat C_contrat%ROWTYPE;
  --
BEGIN
  OPEN C_contrat;
  FETCH C_contrat INTO Rec_c_contrat;
  O_numprod_ref := Rec_c_contrat.numprod;
  CLOSE C_contrat;
END;
--

--
PROCEDURE P_INS_formule2(
    I_next_numfor IN formule.numfor%TYPE,
    I_valide      IN formule.valide%TYPE,
    I_numgar      IN grnts.numgar%TYPE,
    I_datapli     IN formule.debut%TYPE,
    I_datper      IN formule.fin%TYPE,
    I_ins_journal IN BOOLEAN,
    I_date        IN DATE,
    I_session     IN NUMBER,
    I_numfor_ref  IN formule.numfor%TYPE)
IS
BEGIN
  INSERT
  INTO FORMULE
    (
      numfor,
      libelle,
      monnaie,
      nomgar,
      q_medic,
      typgar,
      gar,
      branche,
      code_cmcr,
      compte,
      debut,
      fin,
      valide,
      ct_resp,
      obligatoire,
      flag_regime,
      nat_calc,
      numass,
      MOD_APP,
      ARRONDI_PRORATA,
      UNITCALC,
      NBUNITCALC,
      TYPEUNITCALC,
      IND_EDIT,
      IND_OPTION,
      NUM_ORDRE,
      LIB_EDIT,
      IMG_DGAR,
      CODE_REASS,
      CENTRE_ANALYTIQUE,
      J_GRATUIT,
      NAT_RISQ,
      OBLI_BENE,
	  ENGAGEMENT
    )
  SELECT I_next_numfor,
    formule.libelle,
    formule.monnaie,
    formule.nomgar,
    formule.q_medic,
    formule.typgar,
    formule.gar,
    formule.branche,
    formule.code_cmcr,
    vd_compte.numcpte,
    greatest(I_datapli, formule.debut),
    least(I_datper, formule.fin),
    I_valide,
    formule.ct_resp,
    formule.obligatoire,
    formule.flag_regime,
    formule.nat_calc,
    formule.numass,
    formule.MOD_APP,
    formule.ARRONDI_PRORATA,
    formule.UNITCALC,
    formule.NBUNITCALC,
    formule.TYPEUNITCALC,
    formule.IND_EDIT,
    formule.IND_OPTION,
    formule.NUM_ORDRE,
    formule.LIB_EDIT,
    formule.IMG_DGAR,
    formule.CODE_REASS,
    formule.CENTRE_ANALYTIQUE,
    formule.J_GRATUIT,
    formule.NAT_RISQ,
    formule.obli_bene,
	formule.ENGAGEMENT
  FROM formule,
    vd_compte,
    grnts
  WHERE formule.numfor                     = I_numfor_ref
  AND grnts.numgar                         = I_numgar
  AND vd_compte.numope (+)                 = 1
  AND vd_compte.numsoc (+)                 = grnts.numinterm
  AND greatest( I_datapli, formule.debut) <= least( I_datper, NVL(formule.fin,I_datper));
  IF SQL%FOUND THEN
    IF I_ins_journal THEN
      G_idligne := 11;
      G_msg_adm := 'Ligne inseree dans formule : Next_numfor--> '|| I_next_numfor||' Numfor_ref --> '||I_numfor_ref;
      PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
    END IF;
  END IF;
END;

--
-- ============== Fin des definitions des procedures privees =================
-- ============================================================================
-- CORPS DES PROCEDURES PUBLIQUES
-- Procedure de duplication des garanties par rapport a une garantie de
-- reference. Procedure appelee par la forme gg03.inp
--
-- ARGEREP-601 ABO 30/11/2021 duplication des données complémentaires garanties produit
PROCEDURE P_INS_Gar(
    I_numprod     IN NUMBER,
    I_nomgar      IN VARCHAR2,
    I_lib_nogar   IN VARCHAR2,
    I_datapli     IN DATE,
    I_numfor_ref  IN NUMBER,
    I_fran_gar    IN NUMBER,
    I_max_gar     IN NUMBER,
    I_fran_act    IN NUMBER,
    I_max_act     IN NUMBER,
    I_carence_act IN NUMBER,
    I_don_comp    IN NUMBER,
    I_numprod_ref IN NUMBER,
    I_code_pays   IN NUMBER,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_ins_journal IN BOOLEAN DEFAULT FALSE )
IS
  --
  -- DECLARATION CONSTANTES
  --
  L_CST_valide  CONSTANT VARCHAR2(1) DEFAULT 'O';
  L_CST_nat_gar CONSTANT NUMBER(1) DEFAULT 2;
  L_CST_numfor  CONSTANT NUMBER(1) DEFAULT 0;
  L_CST_tfc     CONSTANT NUMBER(1) DEFAULT 4;
  L_CST_datper  CONSTANT DATE DEFAULT to_date('31/12/3000','DD/MM/YYYY');
  --
  -- DECLARATION VARIABLES
  --
  L_next_numfor NUMBER(10);
  L_contexte    NUMBER(2);
  L_code_msg mess_erreur.code_msg%TYPE;
  L_lib_msg mess_erreur.lib_msg%TYPE;
  --
BEGIN
  --
  G_niv_msg := 1;
  --
  IF I_ins_journal THEN
    G_idligne := 0;
    G_msg_adm :='début de traitement PK_dupliq_gar.P_INS_gar';
    PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
  END IF;
  --
  -- Recherche du nouveau numero de Garantie
  P_nextval_numfor(I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, O_next_numfor => L_next_numfor);
  --
  IF F_CTRL_frmls(I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor => I_numfor_ref) THEN
    --
    IF I_fran_gar = 1 THEN
      P_INS_franfor(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
      --
    END IF;
    --
    IF I_max_gar = 1 THEN
      P_INS_maxfor(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    END IF;
    --
    -- Insert DFRB et SQRB
    P_INS_sqrb(I_next_numfor => L_next_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    --
    P_INS_dfrb(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_date => I_date, I_session => I_session, I_numfor_ref => I_numfor_ref);
    --
    --
    IF I_fran_act = 1 THEN
      P_INS_franact(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    END IF;
    --
    IF I_max_act = 1 THEN
      P_INS_maxact(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    END IF;
    --
    -- Insert CALCUL
    P_INS_calcul(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    --
    IF I_carence_act = 1 THEN
      P_INS_crnc(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
      --
    END IF;
    --INSERT val_variable
    IF I_don_comp = 1 THEN
      P_INS_VAR(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    END IF;

    --
    -- Insert FORMULE
    P_INS_formule(I_next_numfor => L_next_numfor, I_lib_nogar => I_lib_nogar, I_nomgar => I_nomgar, I_valide => L_CST_valide, I_numprod => I_numprod, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    --
  ELSE
    L_contexte := 7;
    P_INS_garanties(I_nat_gar => L_CST_nat_gar, I_etendue => L_contexte, I_next_numfor => L_next_numfor, I_lib_nogar => I_lib_nogar, I_nomgar => I_nomgar, I_valide => L_CST_valide, I_numprod => I_numprod, I_datapli => I_datapli, I_datper => L_CST_datper, I_session => I_session, I_date => I_date, I_ins_journal => I_ins_journal, I_numfor_ref => I_numfor_ref);
    --
    P_INS_gar_prev(I_next_numfor => L_next_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    --
    P_INS_bene_gar(I_next_numfor => L_next_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    --
    P_INS_frml_reval(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_date => I_date, I_session => I_session, I_numfor_ref => I_numfor_ref);
    --
    P_INS_frml_dedu(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    --
    P_INS_frml_prest(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
    --
    P_INS_for_variable(I_next_numfor => L_next_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
  END IF;
  --
  L_contexte := 7;
  P_INS_justif(I_next_numfor => L_next_numfor, I_contexte => L_contexte, I_numprod => I_numprod, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
  --
  P_INS_justif_global(I_numfor => L_CST_numfor, I_contexte => L_contexte, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numprod => I_numprod);
  --
  P_INS_libgar(I_next_numfor => L_next_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
  --
  L_contexte := 6;
  P_INS_frml_prime(I_next_numfor => L_next_numfor, I_numprod => I_numprod, I_etendue => L_contexte, I_valide => L_CST_valide, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
  --
  P_INS_frml_tfc(I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_valide => L_CST_valide, I_tfc => L_CST_tfc, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
  --
  P_INS_frml_tfc_contrat (I_numprod => I_numprod, I_datapli => I_datapli, I_datper => L_CST_datper, I_valide => L_CST_valide, I_tfc => L_CST_tfc, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numprod_ref => I_numprod_ref);
  --
  P_INS_cond_adhesion_gar (I_next_numfor => L_next_numfor, I_datapli => I_datapli, I_datper => L_CST_datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => I_numfor_ref);
  --
  L_contexte := 10;
  P_INS_valide_texte( I_contexte => L_contexte, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numero => L_next_numfor );
  --
  IF I_ins_journal THEN
    G_idligne := 27;
    G_msg_adm :='Fin de traitement Pk_dupliq_gar.P_INS_gar';
    PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  L_code_msg := 20001;
  --
  -- Recherche du message dans la table
  L_lib_msg:= pk_trace.F_aff_mess_err ( I_code_msg => L_code_msg, I_code_pays => I_code_pays, I_liste_param => 'pk_dupliq_gar ');
  --
  -- message de la table + erreur Oracle
  L_lib_msg := L_lib_msg||SUBSTR(sqlerrm(SQLCODE),1,80 -
  LENGTH(L_lib_msg));
  --
  -- Retour du message vers les postes clients(sqlforms)
  RAISE_APPLICATION_ERROR((L_code_msg * -1),L_lib_msg);
END;
--

--
-- Procedure de duplication des garanties par rapport a une garantie de
-- reference. Procedure appelee par la forme gg05.inp.
--
PROCEDURE P_INS_Gar2(
    I_numfor      IN Gar_cntrt.numfor%TYPE,
    I_code_pays   IN NUMBER,
    I_session     IN NUMBER,
    I_date        IN DATE,
    I_ins_journal IN BOOLEAN DEFAULT FALSE )
IS
  -- DECLARATION CONSTANTES
  --
  L_CST_datper  CONSTANT DATE DEFAULT to_date('31/12/3000','DD/MM/YYYY');
  L_CST_nat_gar CONSTANT NUMBER(1) DEFAULT 2;
  L_CST_numfor  CONSTANT NUMBER(1) DEFAULT 0;
  L_CST_valide  CONSTANT VARCHAR2(1) DEFAULT 'O';
  L_CST_tfc     CONSTANT NUMBER(1) DEFAULT 4;
  --
  -- DECLARATION VARIABLES
  --
  L_numprod_ref Contrat.numprod%TYPE;
  L_contexte NUMBER(2);
  L_code_msg mess_erreur.code_msg%TYPE;
  L_lib_msg mess_erreur.lib_msg%TYPE;
  --
  CURSOR C_gar_cntrt
  IS
    SELECT gar_cntrt.numgar,
      gar_cntrt.datapli,
      gar_cntrt.datper,
      gar_cntrt.valide,
      gar_cntrt.numfor_ref,
      gar_cntrt.nomgar,
      gar_cntrt.libelle
    FROM gar_cntrt
    WHERE numfor = I_numfor;
  --
  Rec_c_gar_cntrt C_gar_cntrt%ROWTYPE;
  --
BEGIN
  G_niv_msg := 1;
  --
  IF I_ins_journal THEN
    G_idligne := 0;
    G_msg_adm :='début de traitement PK_dupliq_gar.P_INS_gar2';
    PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
  END IF;
  --
  OPEN C_gar_cntrt;
  FETCH C_gar_cntrt INTO Rec_c_gar_cntrt;
  --
  IF Rec_c_gar_cntrt.datper IS NULL THEN
    Rec_c_gar_cntrt.datper  := L_CST_datper;
  END IF;
  --
  -- Recherche du numprod de reference a partir du numgar de gar_cntrt
  P_SEL_contrat(I_numgar => Rec_c_gar_cntrt.numgar, O_numprod_ref => L_numprod_ref);
  --
  IF F_CTRL_frmls(I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor => Rec_c_gar_cntrt.numfor_ref) THEN
    --
    P_INS_franfor(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_maxfor(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_sqrb(I_next_numfor => I_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_dfrb(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_date => I_date, I_session => I_session, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_franact(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_maxact(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_calcul(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_crnc(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_VAR(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_formule2(I_next_numfor => I_numfor, I_valide => L_CST_valide, I_numgar => Rec_c_gar_cntrt.numgar, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
  ELSE -- mal_prev  2
    L_contexte := 2;
    P_INS_garanties(I_nat_gar => L_CST_nat_gar, I_etendue => L_contexte, I_next_numfor => I_numfor, I_lib_nogar => Rec_c_gar_cntrt.libelle, I_nomgar => Rec_c_gar_cntrt.nomgar, I_valide => Rec_c_gar_cntrt.valide, I_numprod => Rec_c_gar_cntrt.numgar, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_session => I_session, I_date => I_date, I_ins_journal => I_ins_journal, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_gar_prev(I_next_numfor => I_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_bene_gar(I_next_numfor => I_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_frml_reval(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_date => I_date, I_session => I_session, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_frml_dedu(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_date => I_date, I_session => I_session, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_frml_prest(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_date => I_date, I_session => I_session, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
    --
    P_INS_for_variable(I_next_numfor => I_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
  END IF;
  --
  L_contexte := 2;
  P_INS_justif(I_next_numfor => I_numfor, I_contexte => L_contexte, I_numprod => Rec_c_gar_cntrt.numgar, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
  --
  P_INS_justif_global(I_numfor => L_CST_numfor, I_contexte => L_contexte, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numprod => Rec_c_gar_cntrt.numgar);
  --
  P_INS_libgar(I_next_numfor => I_numfor, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
  --
  L_contexte := 1;
  P_INS_frml_prime(I_next_numfor => I_numfor, I_numprod => Rec_c_gar_cntrt.numgar, I_etendue => L_contexte, I_valide => L_CST_valide, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
  --
  P_INS_frml_tfc(I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_valide => L_CST_valide, I_tfc => L_CST_tfc, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
  --
  P_INS_frml_tfc_contrat (I_numprod => Rec_c_gar_cntrt.numgar, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_valide => L_CST_valide, I_tfc => L_CST_tfc, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numprod_ref => L_numprod_ref);
  --
  P_INS_cond_adhesion_gar (I_next_numfor => I_numfor, I_datapli => Rec_c_gar_cntrt.datapli, I_datper => Rec_c_gar_cntrt.datper, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numfor_ref => Rec_c_gar_cntrt.numfor_ref);
  --
  L_contexte := 10;
  P_INS_valide_texte( I_contexte => L_contexte, I_ins_journal => I_ins_journal, I_session => I_session, I_date => I_date, I_numero => I_numfor);
  --
  IF I_ins_journal THEN
    G_idligne := 27;
    G_msg_adm :='Fin de traitement PK_dupliq_gar.P_INS_gar2';
    PK_trace.P_INS_journal_adm (I_nom_traitement => G_nom_traitement, I_session => I_session, I_niv_msg => G_niv_msg, I_msg_adm => G_msg_adm, I_date => I_date, I_idligne => G_idligne);
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
  L_code_msg := 20001;
  --
  -- Recherche du message dans la table
  L_lib_msg:= pk_trace.F_aff_mess_err ( I_code_msg => L_code_msg, I_code_pays => I_code_pays, I_liste_param => 'pk_dupliq_gar ');
  --
  -- message de la table + erreur Oracle
  --L_lib_msg :=     L_lib_msg||Substr(sqlerrm(sqlcode),1,80 -
  --           length(L_lib_msg));
  L_lib_msg := SUBSTR(sqlerrm(SQLCODE),1,300 );
  --
  -- Retour du message vers les postes clients(sqlforms)
  RAISE_APPLICATION_ERROR((L_code_msg * -1),L_lib_msg);
END;
--
--
-- ========================== Fin des corps des procedures publiques===========
END;
/
