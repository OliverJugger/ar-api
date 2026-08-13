CREATE PROCEDURE ARTHUS.P_VALIDE_RAPPEL(i_idrappel IN number,i_type_rappel number, i_numporte IN number default 25, o_etat IN OUT NUMBER, o_code_err IN OUT NUMBER)  AS
l_is_lien_ged_ok number :=0;
BEGIN

IF i_type_rappel = 18 THEN --validation d'un dépot de piéce
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_DEPOT_PIECE(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (8) THEN
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_MAj_INFO_PERSO(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (10) THEN
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_PEC_HOSPI(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (13) THEN
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_ADD_BENE(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (14) THEN
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_ADD_NUMSS(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (15) THEN
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_RADIATION(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (16) THEN
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_DEVIS(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (17) THEN
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_REMB(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (5) THEN     -- validation d un nouveau RIB
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_ADD_RIB(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (20,23,25,26) THEN     -- validation d une souscription option ou base, le gestionnaire peut aussi passé par la demande de validation de la RH pour valider l'adhésion
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_SUBSCRIBE(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (21) THEN     -- validation d un dossier sante bien-être
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_ADD_DOSS_CALC(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;

ELSIF i_type_rappel in (28) THEN     -- validation d'une declaration prestij pour un assuré
  o_code_err := PK_PREV_BPIJ.F_VALIDE_RAPPEL(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
    --RKO EA PREVOYANCE LOT3
ELSIF i_type_rappel in (29) THEN     -- validation d'un ajout de sinistre prévoyance
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_ADD_SIN_PREV(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
ELSIF i_type_rappel in (30) THEN     -- validation d'un ajout d'évènement
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_ADD_EVENT(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
  --FIN RKO EA PREVOYANCE LOT3
ELSIF i_type_rappel in (31) THEN     -- validation d'une demande de radiation IRIS ENTRP RADIATION
  o_code_err := PK_WS_WEB_MAJ_BACK.F_VALIDE_RAD_ADHE(i_idrappel,i_numporte);
  IF o_code_err = 0 THEN
    o_etat := 3;
  END IF;
END IF;

END P_VALIDE_RAPPEL;
/
