CREATE OR REPLACE PACKAGE ARTHUS."PK_WS_WEB_FRONT"
as
/*=========================================================================
PAckage     : PK_WS_WEB_FRONT
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
Correction   :
==========================================================================*/

/***********************************************************/
FUNCTION F_WS_COMPANY_LIST_BY_REP(
  P_NUMINDIV INDIVIDU.NUMINDIV%TYPE
) RETURN EXTR_TAB_SOCIETE;

/***********************************************************/
FUNCTION F_WS_CONTRACT_LIST_BY_COMP(
         P_NUMINDIV EXTR_TAB_NUMINDIV,
         P_NUMGAR   CONTRAT.NUMGAR%TYPE
) RETURN EXTR_TAB_CONTRAT;

/***********************************************************/
FUNCTION F_WS_CONTRACT_LIST_BY_COMP_RH(
         P_NUMINDIV EXTR_TAB_NUMINDIV,
         P_NUMGAR   CONTRAT.NUMGAR%TYPE
) RETURN EXTR_TAB_CONTRAT;
/***********************************************************/

FUNCTION F_CONTRACT_LIST_BY_COMP_PREV(             --RKO EA prev
         P_NUMINDIV EXTR_TAB_NUMINDIV,
         P_NUMGAR   CONTRAT.NUMGAR%TYPE
) RETURN EXTR_TAB_CONTRAT;

/***********************************************************/
FUNCTION F_WS_CONTRACT_TO_SIGN_UP(
  P_NUMADHE   INDIVIDU.NUMINDIV%type,
  P_NUMGAR    CONTRAT.NUMGAR%TYPE,
  P_NATURE     VARCHAR2,
  P_DATEEFFET   DATE,
  P_NUMCLI      NUMBER
) RETURN EXTR_PROSPECT;
/***********************************************************/
FUNCTION F_WS_SEARCH_AFFILIATES(
  P_NUMINDIV EXTR_TAB_NUMINDIV,
  P_NUMGAR EXTR_TAB_NUMGAR,
  P_NOM INDIVIDU.NOM%TYPE,
  P_PRENOM INDIVIDU.PRENOM%TYPE,
  P_NUMSS  INDIVIDU.MATORG%TYPE
) RETURN EXTR_TAB_AFFILIE;
/***********************************************************/
FUNCTION F_WS_GET_AFF(
  P_NUMASSUP INDIVIDU.NUMINDIV%TYPE,
  P_NUMADHE INDIVIDU.NUMINDIV%TYPE,
  P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE
) RETURN EXTR_TAB_AFFILIE_DETAIL;
/***********************************************************/
FUNCTION F_WS_GET_ATTESTATION(
   P_NUMASSUP INDIVIDU.NUMINDIV%TYPE,
   P_NUMADHE INDIVIDU.NUMINDIV%TYPE,
   P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE
) RETURN EXTR_ATTESTATION_TR;

/***********************************************************/
FUNCTION F_WS_VERIFY_USER_ACCOUNT (
             P_NOM INDIVIDU.NOM%TYPE,
             P_PRENOM INDIVIDU.PRENOM%TYPE,
             P_DATE INDIVIDU.DATNAIS%TYPE,
             P_MAIL CONTACT.COORDONNEE%TYPE,
             P_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE
)
RETURN EXTR_TAB_REP_ACTION;
/***********************************************************/
/*FUNCTION F_WS_EDIT_COMPANY  (
             P_NUMINDIV  INDIVIDU.NUMINDIV%TYPE,
             P_NOM       INDIVIDU.NOM%TYPE,
             P_TELEPHONE CONTACT.COORDONNEE%TYPE,
             P_TELECOPIE CONTACT.COORDONNEE%TYPE,
             P_EMAIL     CONTACT.COORDONNEE%TYPE,
             P_NUMSIRET  PERS_MORALE.SIRET%TYPE,
             P_CODEAPE   PERS_MORALE.APE%TYPE
)
RETURN EXTR_TAB_REP_ACTION;*/
/***********************************************************/
FUNCTION F_WS_COOR_BANQUE (
  P_NUMINDIV  INDIVIDU.NUMINDIV%TYPE
) RETURN EXTR_TAB_RIB;
/***********************************************************/
FUNCTION F_WS_COTISATION (
         P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
         P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE,
         P_TYPE_QUERABLE NUMBER
) RETURN EXTR_TAB_COTISATION;
/***********************************************************/
FUNCTION F_WS_DECOMPTE (
  P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
  P_ANNEE    NUMBER,
  P_DEBUT    DATE,
  P_FIN      DATE
) RETURN EXTR_TAB_DECOMPTE;
/***********************************************************/
FUNCTION F_WS_PIECE (
        P_NUMINDIV INDIVIDU.NUMINDIV%TYPE
        ,P_PARAMS IN EXTR_Q_PIECE
) RETURN EXTR_TAB_PIECE;
/***********************************************************/
FUNCTION F_WS_CARTE_TPE (
        P_NUMINDIV INDIVIDU.NUMINDIV%TYPE
) RETURN EXTR_TAB_CARTE_TPE;
/***********************************************************/
FUNCTION F_WS_CIRCUITS_INFO(
          I_NUMINDIV INDIVIDU.NUMINDIV%TYPE
          )
RETURN EXTR_TAB_CIRCUIT_INFO;
/***********************************************************/
FUNCTION F_WS_PEC_HOSPI( I_QUESTION QUESTION_PEC_DEVIS )
RETURN  EXTR_TAB_PRCH;
/***********************************************************/
FUNCTION F_WS_DEVIS( I_QUESTION QUESTION_PEC_DEVIS )
RETURN  EXTR_TAB_DEVIS_SANTE ;
/***********************************************************/
FUNCTION F_WS_GET_SERVICES( I_NUMGAR NUMBER )
  RETURN  EXTR_TAB_SERVICE;
/***********************************************************/
FUNCTION F_WS_GET_DEMANDES( i_numindiv NUMBER,
                            i_params_facult  EXTR_GET_DEMANDE)
  RETURN  EXTR_TAB_DEMANDE;
/***********************************************************/

FUNCTION F_GET_ACTS_INSURED(I_params EXTR_Q_ACT_INSURED)
  RETURN  EXTR_TAB_ACTS_INSURED;
/***********************************************************/
FUNCTION F_WS_LIST_EMPLOYEE(I_params EXTR_Q_LIST_EMPLOYEE)
  RETURN EXTR_R_LIST_EMPLOYEE  ;
/*************************************************/

FUNCTION F_GET_IDENTIFIANT_RH(email VARCHAR2)
RETURN NUMBER ;

/***********************************************************/
FUNCTION F_WS_LIST_EVENT(numindiv INDIVIDU.NUMINDIV%TYPE, nosin SNTR_PREV.NOSIN%TYPE)--(p1 EXTR_LIST_EVENT)
  RETURN EXTR_TAB_LIST_EVENT;

/***********************************************************/
FUNCTION F_WS_LIST_PREV(i_params EXTR_Q_LIST_PREV)
  RETURN EXTR_TAB_LIST_PREV;

/***********************************************************/
FUNCTION F_WS_LIST_PREV_INFO(i_params EXTR_Q_PREV_INFO)
  RETURN EXTR_TAB_LIST_PREV_INFO;

/***************************************************************/
FUNCTION F_WS_LIST_DCPT_PREV(i_params EXTR_Q_DCPT_PREV)
  RETURN EXTR_TAB_LIST_DCPT_PREV;

/*************************************************************/
FUNCTION F_WS_BOARD_COUNTER(numindiv individu.numindiv%TYPE,
                              type     EXTR_Q_BC)
  RETURN EXTR_BOARD_COUNTER ;

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_WS_WEB_FRONT" as
    exc_flux_inconnue exception;
/*********************************************************/
FUNCTION F_WS_COMPANY_LIST_BY_REP(
		 P_NUMINDIV INDIVIDU.NUMINDIV%TYPE
) RETURN EXTR_TAB_SOCIETE
IS
   REP_F_WS_COMPANY_LIST_BY_REP EXTR_TAB_SOCIETE;
	v_id_flux FLUX.id_flux%TYPE;
	v_cod_err NUMBER;
	v_porte NUMBER;
	v_deb NUMBER;
	v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
BEGIN
	SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Indvidu",P_NUMINDIV) ), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 113,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;



	REP_F_WS_COMPANY_LIST_BY_REP := PK_WS_WEB_BACK.F_COMPANY_LIST_BY_REP(P_NUMINDIV,v_porte);
	SELECT XMLROOT( XMLELEMENT( "Societes",REP_F_WS_COMPANY_LIST_BY_REP) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 114,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null, v_delai);

  RETURN REP_F_WS_COMPANY_LIST_BY_REP;

EXCEPTION
   WHEN exc_flux_inconnue THEN RETURN REP_F_WS_COMPANY_LIST_BY_REP;
   WHEN OTHERS THEN
		PK_trace.P_INS_journal_adm (
		I_nom_traitement => 'F_WS_COMPANY_LIST_BY_REP',
		I_session  => SID,
		I_niv_msg  => 3,
		I_msg_adm  => substr(sqlerrm,1,132),
		I_idligne  => 2);
		RETURN REP_F_WS_COMPANY_LIST_BY_REP;
END F_WS_COMPANY_LIST_BY_REP;
/**********************************************************/

/*********************************************************/
FUNCTION F_WS_CONTRACT_LIST_BY_COMP(
         P_NUMINDIV EXTR_TAB_NUMINDIV,
         P_NUMGAR   CONTRAT.NUMGAR%TYPE
) RETURN EXTR_TAB_CONTRAT
IS
  REP_F_WS_CONTRACT_LIST_BY_COMP EXTR_TAB_CONTRAT;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  loc_ref_cntrt CONTRAT.REFCIE%TYPE;


  CURSOR C_CONTRAT (i_numgar contrat.numgar%TYPE) IS
  SELECT	numorg, typgar
	FROM	contrat
  WHERE numgar = i_numgar;

BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Indvidu",P_NUMINDIV),XMLELEMENT( "numgar",P_NUMGAR) ), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 33,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  REP_F_WS_CONTRACT_LIST_BY_COMP := PK_WS_WEB_BACK.F_CONTRACT_LIST_BY_COMP(P_NUMINDIV,P_NUMGAR,v_porte);

	SELECT XMLROOT( XMLELEMENT( "Contrats",REP_F_WS_CONTRACT_LIST_BY_COMP) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 34,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_CONTRACT_LIST_BY_COMP;
EXCEPTION
  WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_WS_CONTRACT_LIST_BY_COMP',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => substr(sqlerrm,1,132),
      I_idligne  => 2);
      RETURN REP_F_WS_CONTRACT_LIST_BY_COMP;
END F_WS_CONTRACT_LIST_BY_COMP;
/**********************************************************/

FUNCTION F_WS_CONTRACT_LIST_BY_COMP_RH(
         P_NUMINDIV EXTR_TAB_NUMINDIV,
         P_NUMGAR   CONTRAT.NUMGAR%TYPE
) RETURN EXTR_TAB_CONTRAT
IS
  REP_F_WS_CONTRACT_LIST_BY_COMP EXTR_TAB_CONTRAT;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  loc_ref_cntrt CONTRAT.REFCIE%TYPE;


  CURSOR C_CONTRAT (i_numgar contrat.numgar%TYPE) IS
  SELECT	numorg, typgar
	FROM	contrat
  WHERE numgar = i_numgar;

BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Indvidu",P_NUMINDIV),XMLELEMENT( "numgar",P_NUMGAR) ), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 115,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  REP_F_WS_CONTRACT_LIST_BY_COMP := PK_WS_WEB_BACK.F_CONTRACT_LIST_BY_COMP(P_NUMINDIV,P_NUMGAR,v_porte,1);-- 1 flag indiquant qu'on provient du ws F_WS_CONTRACT_LIST_BY_COMP_RH RKO M0006874

	SELECT XMLROOT( XMLELEMENT( "Contrats",REP_F_WS_CONTRACT_LIST_BY_COMP) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 116,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_CONTRACT_LIST_BY_COMP;
EXCEPTION
  WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_WS_CONTRACT_LIST_BY_COMP_RH',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => substr(sqlerrm,1,132),
      I_idligne  => 2);
      RETURN REP_F_WS_CONTRACT_LIST_BY_COMP;
END F_WS_CONTRACT_LIST_BY_COMP_RH;

/***********************************************************/
FUNCTION F_WS_CONTRACT_TO_SIGN_UP(
  P_NUMADHE   INDIVIDU.NUMINDIV%type,
  P_NUMGAR    CONTRAT.NUMGAR%TYPE,
  P_NATURE     VARCHAR2,
  P_DATEEFFET   DATE,
  P_NUMCLI      NUMBER
) RETURN EXTR_PROSPECT

IS
  RESPONSE EXTR_PROSPECT;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  loc_ref_cntrt CONTRAT.REFCIE%TYPE;

BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Numadhe",P_NUMADHE),XMLELEMENT( "numgar",P_NUMGAR) ,
          XMLELEMENT( "nature",P_NATURE),XMLELEMENT( "Date_effet",P_DATEEFFET),XMLELEMENT( "numcli",P_NUMCLI)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 87,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  RESPONSE := PK_WS_WEB_BACK.F_CONTRACT_TO_SIGN_UP(P_NUMADHE,P_NUMGAR,P_NATURE,P_DATEEFFET,P_NUMCLI);

	SELECT XMLROOT( XMLELEMENT( "Prospects",RESPONSE) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 88,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN RESPONSE;
EXCEPTION
  WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_WS_CONTRACT_TO_SIGN_UP',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => substr(sqlerrm,1,132),
      I_idligne  => 2);
      RETURN RESPONSE;

 END F_WS_CONTRACT_TO_SIGN_UP;

/*********************************************************/
FUNCTION F_WS_SEARCH_AFFILIATES(
         P_NUMINDIV EXTR_TAB_NUMINDIV,
         P_NUMGAR EXTR_TAB_NUMGAR,
         P_NOM INDIVIDU.NOM%TYPE,
         P_PRENOM INDIVIDU.PRENOM%TYPE,
         P_NUMSS  INDIVIDU.MATORG%TYPE
) RETURN EXTR_TAB_AFFILIE
IS
  REP_F_WS_SEARCH_AFFILIATES EXTR_TAB_AFFILIE;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
BEGIN

	SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Indvidus",P_NUMINDIV),XMLELEMENT( "Contrat",P_NUMGAR) ,
	XMLELEMENT( "Nom",P_NOM),XMLELEMENT( "Prenom",P_PRENOM),XMLELEMENT( "SS",P_NUMSS)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 35,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

    REP_F_WS_SEARCH_AFFILIATES := PK_WS_WEB_BACK.F_SEARCH_AFFILIATES(P_NUMINDIV,P_NUMGAR,TRIM(P_NOM),TRIM(P_PRENOM),TRIM(P_NUMSS),v_porte);


	SELECT XMLROOT( XMLELEMENT( "RechAffilies",REP_F_WS_SEARCH_AFFILIATES) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 36,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_SEARCH_AFFILIATES;
EXCEPTION
   WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_WS_SEARCH_AFFILIATES',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => substr(sqlerrm,1,132),
        I_idligne  => 2);
    RETURN REP_F_WS_SEARCH_AFFILIATES;
END F_WS_SEARCH_AFFILIATES;
/**********************************************************/

/*********************************************************/
FUNCTION F_WS_GET_AFF(
         P_NUMASSUP INDIVIDU.NUMINDIV%TYPE,
         P_NUMADHE INDIVIDU.NUMINDIV%TYPE,
         P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE
) RETURN EXTR_TAB_AFFILIE_DETAIL
IS
 REP_F_WS_GET_AFF EXTR_TAB_AFFILIE_DETAIL;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  loc_ref_cntrt CONTRAT.REFCIE%TYPE;

  CURSOR C_CONTRAT (i_numgar contrat.numgar%TYPE) IS
  SELECT	numorg, typgar
	FROM	contrat
  WHERE numgar = i_numgar;
BEGIN

	SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "AssureP",P_NUMASSUP),XMLELEMENT( "Adherent",P_NUMADHE) ,XMLELEMENT( "Addhesion",P_IDADHESION)),
  VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;


	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 37,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);



	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;


  REP_F_WS_GET_AFF := PK_WS_WEB_BACK.F_GET_AFF(P_NUMASSUP,P_NUMADHE,P_IDADHESION,v_porte);


	SELECT XMLROOT( XMLELEMENT( "Affilies_detail",REP_F_WS_GET_AFF) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 38,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_GET_AFF;
EXCEPTION
   WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'F_WS_GET_AFF',
        I_session  => SID,
        I_niv_msg  => 3,
        I_msg_adm  => substr(sqlerrm,1,132),
        I_idligne  => 2);
    RETURN REP_F_WS_GET_AFF;
END F_WS_GET_AFF;
/*********************************************************/

/*********************************************************/
FUNCTION F_WS_GET_ATTESTATION(
   P_NUMASSUP INDIVIDU.NUMINDIV%TYPE,
   P_NUMADHE INDIVIDU.NUMINDIV%TYPE,
   P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE
) RETURN EXTR_ATTESTATION_TR
IS


	v_id_flux FLUX.id_flux%TYPE;
	v_cod_err NUMBER;
	v_porte NUMBER;
	v_deb NUMBER;
	v_delai NUMBER;

  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;



BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "AssureP",P_NUMASSUP),XMLELEMENT( "Adherent",P_NUMADHE) ,
	XMLELEMENT( "Addhesion",P_IDADHESION)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

  v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 39,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;


	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 40,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
  RETURN NULL;

EXCEPTION
 WHEN OTHERS THEN

      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_WS_GET_ATTESTATION',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => substr(sqlerrm,1,132),
      I_idligne  => 2);
RETURN NULL;
END F_WS_GET_ATTESTATION;
/*********************************************************/

/*********************************************************/
FUNCTION F_WS_VERIFY_USER_ACCOUNT (
       P_NOM INDIVIDU.NOM%TYPE,
       P_PRENOM INDIVIDU.PRENOM%TYPE,
       P_DATE INDIVIDU.DATNAIS%TYPE,
       P_MAIL CONTACT.COORDONNEE%TYPE,
       P_NUM_ASSU ADHE_CNTRT.NUMADHE%TYPE
)
RETURN EXTR_TAB_REP_ACTION
IS
  REP_F_WS_VERIFY_USER_ACCOUNT EXTR_TAB_REP_ACTION;
  v_id_flux FLUX.id_flux%TYPE;
	v_cod_err NUMBER;
	v_porte NUMBER;
	v_deb NUMBER;
	v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
BEGIN
 	SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Nom",P_NOM),XMLELEMENT( "Prenom",P_PRENOM) ,
	XMLELEMENT( "DateNais",P_DATE),XMLELEMENT( "Mail",P_MAIL),XMLELEMENT( "Numassu",P_NUM_ASSU)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 41,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;
 REP_F_WS_VERIFY_USER_ACCOUNT := PK_WS_WEB_BACK.F_VERIFY_USER_ACCOUNT(P_NOM,P_PRENOM,P_DATE,P_MAIL,P_NUM_ASSU,v_porte);
 SELECT XMLROOT( XMLELEMENT( "Account",REP_F_WS_VERIFY_USER_ACCOUNT) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 42,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

 RETURN REP_F_WS_VERIFY_USER_ACCOUNT;
EXCEPTION
 WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_WS_VERIFY_USER_ACCOUNT',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => substr(sqlerrm,1,132),
      I_idligne  => 2);
      RETURN REP_F_WS_VERIFY_USER_ACCOUNT;
END F_WS_VERIFY_USER_ACCOUNT;
/*********************************************************/



/*************************************************************/
FUNCTION F_WS_COOR_BANQUE (
       P_NUMINDIV  INDIVIDU.NUMINDIV%TYPE
) RETURN EXTR_TAB_RIB
IS
  REP_F_WS_COOR_BANQUE EXTR_TAB_RIB;
  v_id_flux FLUX.id_flux%TYPE;
	v_cod_err NUMBER;
	v_porte NUMBER;
	v_deb NUMBER;
	v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;

BEGIN
  SELECT XMLROOT(XMLELEMENT ("question", XMLELEMENT( "Individu",P_NUMINDIV)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 45,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  REP_F_WS_COOR_BANQUE := PK_WS_WEB_BACK.F_COOR_BANQUE(P_NUMINDIV);

  SELECT XMLROOT( XMLELEMENT( "RIB",REP_F_WS_COOR_BANQUE) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 46,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_COOR_BANQUE;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'F_WS_COOR_BANQUE',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => substr(sqlerrm,1,132),
    I_idligne  => 2);

    RETURN REP_F_WS_COOR_BANQUE;
END F_WS_COOR_BANQUE;
/**************************************************************/
FUNCTION F_WS_COTISATION (
         P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
         P_IDADHESION ADHE_CNTRT.IDADHESION%TYPE,
         P_TYPE_QUERABLE NUMBER
) RETURN EXTR_TAB_COTISATION
IS
  REP_F_WS_COTISATION EXTR_TAB_COTISATION;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;


BEGIN
  SELECT XMLROOT(XMLELEMENT ("question", XMLELEMENT( "Individu",P_NUMINDIV),XMLELEMENT( "Adhesion",P_IDADHESION),XMLELEMENT( "Type_querable",P_TYPE_QUERABLE)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 47,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;
  REP_F_WS_COTISATION := PK_WS_WEB_BACK.F_COTISATION(P_NUMINDIV,P_IDADHESION,P_TYPE_QUERABLE,v_porte);



  SELECT XMLROOT( XMLELEMENT( "RIB",REP_F_WS_COTISATION) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 48,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_COTISATION;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'F_WS_COTISATION',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => substr(sqlerrm,1,132),
    I_idligne  => 2);
    RETURN REP_F_WS_COTISATION;
END F_WS_COTISATION;

/**************************************************************/

FUNCTION F_WS_DECOMPTE (
  P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
  P_ANNEE NUMBER,
  P_DEBUT    DATE,
  P_FIN      DATE
) RETURN EXTR_TAB_DECOMPTE
IS
  REP_F_WS_DECOMPTE EXTR_TAB_DECOMPTE;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;

BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Individu",P_NUMINDIV),XMLELEMENT( "Annee",P_ANNEE),XMLELEMENT( "Debut",P_DEBUT),XMLELEMENT( "Fin",P_FIN)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 49,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  REP_F_WS_DECOMPTE := PK_WS_WEB_BACK.F_DECOMPTE_V7(P_NUMINDIV,P_ANNEE,P_DEBUT,P_FIN,v_porte);

  SELECT XMLROOT( XMLELEMENT( "Decompte",REP_F_WS_DECOMPTE) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 50,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_DECOMPTE;
EXCEPTION
 WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'F_WS_DECOMPTE',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => substr(sqlerrm,1,132),
    I_idligne  => 2);
    RETURN REP_F_WS_DECOMPTE;
END F_WS_DECOMPTE;
/**************************************************************/

FUNCTION F_WS_PIECE (
        P_NUMINDIV INDIVIDU.NUMINDIV%TYPE,
        P_PARAMS IN EXTR_Q_PIECE   --RKO EA PREV LOT4 COMPLT
) RETURN EXTR_TAB_PIECE
IS
  REP_F_WS_PIECE EXTR_TAB_PIECE;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;

BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Individu",P_NUMINDIV),XMLELEMENT( "p_params",P_PARAMS)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 51,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  REP_F_WS_PIECE := PK_WS_WEB_BACK.F_PIECE(P_NUMINDIV,P_PARAMS);

  SELECT XMLROOT( XMLELEMENT( "Piece",REP_F_WS_PIECE) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 52,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_PIECE;
EXCEPTION
 WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'F_WS_PIECE',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => substr(sqlerrm,1,132),
    I_idligne  => 2);
    RETURN REP_F_WS_PIECE;
END F_WS_PIECE;/**************************************************************/

FUNCTION F_WS_CARTE_TPE (
        P_NUMINDIV INDIVIDU.NUMINDIV%TYPE
) RETURN EXTR_TAB_CARTE_TPE
IS
  REP_F_WS_CARTE EXTR_TAB_CARTE_TPE;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;

BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Individu",P_NUMINDIV)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 53,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  REP_F_WS_CARTE := PK_WS_WEB_BACK.F_CARTETPE(P_NUMINDIV);

  SELECT XMLROOT( XMLELEMENT( "Piece",REP_F_WS_CARTE) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 54,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_CARTE;
EXCEPTION
 WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'F_WS_CARTE_TPE',
    I_session  => SID,
    I_niv_msg  => 3,
    I_msg_adm  => substr(sqlerrm,1,132),
    I_idligne  => 2);
    RETURN REP_F_WS_CARTE;
END F_WS_CARTE_TPE;
/**************************************************************/
FUNCTION F_WS_CIRCUITS_INFO(
          I_NUMINDIV INDIVIDU.NUMINDIV%TYPE
          )
RETURN EXTR_TAB_CIRCUIT_INFO
IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  tab_circuits EXTR_TAB_CIRCUIT_INFO;
BEGIN
   SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Individu",I_NUMINDIV)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 65,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  tab_circuits := PK_WS_WEB_BACK.F_GET_CIRCUITS_INFO(I_NUMINDIV);

  SELECT XMLROOT( XMLELEMENT( "circuits",tab_circuits) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 66,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN  tab_circuits;
END F_WS_CIRCUITS_INFO;

/**************************************************************/

FUNCTION F_WS_PEC_HOSPI( I_QUESTION QUESTION_PEC_DEVIS )
RETURN  EXTR_TAB_PRCH IS
v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  tab_pec EXTR_TAB_PRCH;
BEGIN
   SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numAssu",I_QUESTION.NUMASSU),XMLELEMENT( "DATE_DEBUT",I_QUESTION.DATE_DEBUT),XMLELEMENT( "DATE_FIN",I_QUESTION.DATE_FIN)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 67,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  tab_pec := PK_WS_WEB_BACK.F_GET_PRCH(I_QUESTION.NUMASSU, I_QUESTION.DATE_DEBUT, I_QUESTION.DATE_FIN);

  SELECT XMLROOT( XMLELEMENT( "PECS" ,tab_pec) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 68,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN  tab_pec;

  END F_WS_PEC_HOSPI;

/********************************************************/
FUNCTION F_WS_DEVIS( I_QUESTION QUESTION_PEC_DEVIS )
  RETURN  EXTR_TAB_DEVIS_SANTE IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  tab_devis EXTR_TAB_DEVIS_SANTE;
BEGIN
    SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numAssu",I_QUESTION.NUMASSU),XMLELEMENT( "DATE_DEBUT",I_QUESTION.DATE_DEBUT),XMLELEMENT( "DATE_FIN",I_QUESTION.DATE_FIN)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 69,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  tab_devis := PK_WS_WEB_BACK.F_GET_DEVIS(I_QUESTION.NUMASSU, I_QUESTION.DATE_DEBUT, I_QUESTION.DATE_FIN);

  SELECT XMLROOT( XMLELEMENT( "devis" ,tab_devis) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 70,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN  tab_devis;

  END F_WS_DEVIS;


  /********************************************************/
FUNCTION F_WS_GET_SERVICES( I_NUMGAR NUMBER )
  RETURN  EXTR_TAB_SERVICE IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  tabs_service EXTR_TAB_SERVICE;
BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numgar",I_NUMGAR)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 91,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  tabs_service := PK_WS_WEB_BACK.F_GET_SERVICES(I_NUMGAR);

  SELECT XMLROOT( XMLELEMENT( "services" ,tabs_service) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 92,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN  tabs_service;

END F_WS_GET_SERVICES;
    /********************************************************/
FUNCTION F_WS_GET_DEMANDES( i_numindiv NUMBER,
                            i_params_facult  EXTR_GET_DEMANDE
                             )

RETURN  EXTR_TAB_DEMANDE
IS
 v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  tab_demande EXTR_TAB_DEMANDE;
BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numindiv",i_numindiv),XMLELEMENT( "params",i_params_facult)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 93,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  tab_demande := PK_WS_WEB_BACK.F_GET_DEMANDES( I_NUMINDIV
                                               ,i_params_facult.i_iddemande
                                               ,i_params_facult.i_debut
                                               ,i_params_facult.i_fin
                                               ,i_params_facult.i_numbene
                                               ,i_params_facult.i_etat );

  SELECT XMLROOT( XMLELEMENT( "deamndes" ,tab_demande) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 94,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN  tab_demande;

END F_WS_GET_DEMANDES ;

  /*************************************************/
FUNCTION F_GET_ACTS_INSURED(I_params EXTR_Q_ACT_INSURED)
  RETURN  EXTR_TAB_ACTS_INSURED
  IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  tab_acts EXTR_TAB_ACTS_INSURED;
BEGIN

  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "params", i_params)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 95,
                  						   p_id_flux_tiers => 0,
                  						   p_doc_xml       => xml_file,
                  						   p_cod_err       => v_cod_err,
                  						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  tab_acts := PK_WS_WEB_BACK.F_GET_ACTS_INSURED( I_params.NUMBENE
                                                ,I_params.NUMGAR
                                                ,I_params.DATSIN
                                                ,I_params.TYPE_FRAIS );

  SELECT XMLROOT( XMLELEMENT( "tab_acts" ,tab_acts) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME - v_deb;

	pk_ws.add_xml(p_id_type => 96,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN  tab_acts;
END F_GET_ACTS_INSURED ;
/***********************************************************/

FUNCTION F_WS_LIST_EMPLOYEE(I_params EXTR_Q_LIST_EMPLOYEE)
RETURN EXTR_R_LIST_EMPLOYEE
IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  o_response EXTR_R_LIST_EMPLOYEE;

BEGIN

 SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "params", i_params)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 101,
                  						   p_id_flux_tiers => 0,
                  						   p_doc_xml       => xml_file,
                  						   p_cod_err       => v_cod_err,
                  						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

      /**********Appel au back ************/
   o_response := pk_ws_web_back.F_LIST_EMPLOYEE_dev(I_params);


  SELECT XMLROOT( XMLELEMENT( "reponse" ,o_response) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME - v_deb;

	pk_ws.add_xml(p_id_type => 102,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
    return o_response;
END F_WS_LIST_EMPLOYEE ;

/******************************************************************************/

FUNCTION F_GET_IDENTIFIANT_RH(email VARCHAR2)
RETURN NUMBER
IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  o_response number;

BEGIN

 SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "email", email)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 119,
                  						   p_id_flux_tiers => 0,
                  						   p_doc_xml       => xml_file,
                  						   p_cod_err       => v_cod_err,
                  						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

      /**********Appel au back ************/
   o_response := pk_ws_web_back.F_GET_IDENTIFIANT_RH(email);


  SELECT XMLROOT( XMLELEMENT( "reponse" ,o_response) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME - v_deb;

	pk_ws.add_xml(p_id_type => 120,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
    return o_response;
END F_GET_IDENTIFIANT_RH ;

/*********************************************************************/

FUNCTION F_CONTRACT_LIST_BY_COMP_PREV(
         P_NUMINDIV EXTR_TAB_NUMINDIV,
         P_NUMGAR   CONTRAT.NUMGAR%TYPE
) RETURN EXTR_TAB_CONTRAT
IS
  REP_F_WS_CONTRACT_LIST_BY_COMP EXTR_TAB_CONTRAT;
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  loc_ref_cntrt CONTRAT.REFCIE%TYPE;


BEGIN
  SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "Indvidu",P_NUMINDIV),XMLELEMENT( "numgar",P_NUMGAR) ), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 121,
						   p_id_flux_tiers    =>0,
						   p_doc_xml       => xml_file,
						   p_cod_err       => v_cod_err,
						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

  REP_F_WS_CONTRACT_LIST_BY_COMP := PK_WS_WEB_BACK.F_CONTRACT_LIST_BY_COMP_PREV(P_NUMINDIV,P_NUMGAR,v_porte);

	SELECT XMLROOT( XMLELEMENT( "Contrats",REP_F_WS_CONTRACT_LIST_BY_COMP) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME- v_deb;

	pk_ws.add_xml(p_id_type => 122,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);

  RETURN REP_F_WS_CONTRACT_LIST_BY_COMP;
EXCEPTION
  WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm (
      I_nom_traitement => 'F_WS_CONTRACT_LIST_BY_COMP_PREV',
      I_session  => SID,
      I_niv_msg  => 3,
      I_msg_adm  => substr(sqlerrm,1,132),
      I_idligne  => 2);
      RETURN REP_F_WS_CONTRACT_LIST_BY_COMP;
END F_CONTRACT_LIST_BY_COMP_PREV;

/******************************************************************************/

FUNCTION F_WS_LIST_EVENT (numindiv INDIVIDU.NUMINDIV%TYPE, nosin SNTR_PREV.NOSIN%TYPE)
RETURN EXTR_TAB_LIST_EVENT
IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  o_response EXTR_TAB_LIST_EVENT;

BEGIN

	SELECT XMLROOT( XMLELEMENT ("ListEvent",XMLELEMENT( "numindiv", numindiv),XMLELEMENT( "nosin", nosin)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
    INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 123,
                  						   p_id_flux_tiers => 0,
                  						   p_doc_xml       => xml_file,
                  						   p_cod_err       => v_cod_err,
                  						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

      /**********Appel au back ************/
   o_response := pk_ws_web_back.F_WS_LIST_EVENT(numindiv, nosin );


    SELECT XMLROOT( XMLELEMENT( "reponse" ,o_response) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;


	v_delai:=DBMS_UTILITY.GET_TIME - v_deb;

	pk_ws.add_xml(p_id_type => 124,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
    return o_response;
END F_WS_LIST_EVENT ;

/******************************************************************************/
FUNCTION F_WS_LIST_PREV(i_params EXTR_Q_LIST_PREV)
  RETURN EXTR_TAB_LIST_PREV
IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  o_response EXTR_TAB_LIST_PREV;

BEGIN

 SELECT XMLROOT( XMLELEMENT ("fWsListPrev",XMLELEMENT("i_params", i_params)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 125,
                  						   p_id_flux_tiers => 0,
                  						   p_doc_xml       => xml_file,
                  						   p_cod_err       => v_cod_err,
                  						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

      /**********Appel au back ************/
   o_response := pk_ws_web_back.F_WS_LIST_PREV(i_params);


  /*SELECT XMLROOT( XMLELEMENT( "fWsListPrev" ,o_response) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;     */

    SELECT XMLROOT(  XMLELEMENT ("fWsListPrev", XMLELEMENT ("result",o_response )), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME - v_deb;

	pk_ws.add_xml(p_id_type => 126,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
    return o_response;
END F_WS_LIST_PREV ;

/******************************************************************************/
FUNCTION F_WS_LIST_PREV_INFO(i_params EXTR_Q_PREV_INFO)
  RETURN EXTR_TAB_LIST_PREV_INFO
IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  o_response EXTR_TAB_LIST_PREV_INFO;

BEGIN

 SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "i_params", i_params)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 127,
                  						   p_id_flux_tiers => 0,
                  						   p_doc_xml       => xml_file,
                  						   p_cod_err       => v_cod_err,
                  						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

      /**********Appel au back ************/
   o_response := pk_ws_web_back.F_WS_LIST_PREV_INFO(i_params);


  SELECT XMLROOT( XMLELEMENT( "reponse" ,o_response) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME - v_deb;

	pk_ws.add_xml(p_id_type => 128,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
    return o_response;
END F_WS_LIST_PREV_INFO ;

/******************************************************************************/
FUNCTION F_WS_LIST_DCPT_PREV(i_params EXTR_Q_DCPT_PREV)
  RETURN EXTR_TAB_LIST_DCPT_PREV
IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  o_response EXTR_TAB_LIST_DCPT_PREV;

BEGIN

 SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "i_params", i_params)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 129,
                  						   p_id_flux_tiers => 0,
                  						   p_doc_xml       => xml_file,
                  						   p_cod_err       => v_cod_err,
                  						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

      /**********Appel au back ************/
   o_response := pk_ws_web_back.F_WS_LIST_DCPT_PREV(i_params);


  SELECT XMLROOT( XMLELEMENT( "reponse" ,o_response) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME - v_deb;

	pk_ws.add_xml(p_id_type => 130,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
    return o_response;
END F_WS_LIST_DCPT_PREV ;


/******************************************************************************/
FUNCTION F_WS_BOARD_COUNTER(Numindiv individu.numindiv%TYPE, Type EXTR_Q_BC)
  RETURN EXTR_BOARD_COUNTER
IS
  v_id_flux FLUX.id_flux%TYPE;
  v_cod_err NUMBER;
  v_porte NUMBER;
  v_deb NUMBER;
  v_delai NUMBER;
  xml_file XMLTYPE;
  xml_file_rep XMLTYPE;
  o_response EXTR_BOARD_COUNTER;

BEGIN

 SELECT XMLROOT( XMLELEMENT ("question",XMLELEMENT( "numindiv", Numindiv),XMLELEMENT( "Type", Type)), VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO xml_file
	FROM dual;

	v_deb:=DBMS_UTILITY.GET_TIME;
	v_id_flux := pk_ws.insert_flux(p_id_type       => 135,
                  						   p_id_flux_tiers => 0,
                  						   p_doc_xml       => xml_file,
                  						   p_cod_err       => v_cod_err,
                  						   p_porte         => v_porte);

	IF v_cod_err <> 0 THEN
	 RAISE exc_flux_inconnue;
	END IF;

      /**********Appel au back ************/
   o_response := pk_ws_web_back.F_WS_BOARD_COUNTER(Numindiv, Type);


  SELECT XMLROOT( XMLELEMENT( "reponse" ,o_response) , VERSION '1.0" encoding="utf-8' , STANDALONE  NO)
	INTO  xml_file_rep
	FROM dual;

	v_delai:=DBMS_UTILITY.GET_TIME - v_deb;

	pk_ws.add_xml(p_id_type => 136,
				p_id_flux => v_id_flux,
				p_doc_xml => xml_file_rep,
				p_cod_err => v_cod_err);
	-- MAJ statut du flux OKa
	pk_ws.maj_statut(v_id_flux, 0,null,v_delai);
    return o_response;
END F_WS_BOARD_COUNTER ;

END PK_WS_WEB_FRONT;
/
