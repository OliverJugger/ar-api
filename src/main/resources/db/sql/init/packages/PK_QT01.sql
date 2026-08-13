CREATE OR REPLACE PACKAGE ARTHUS.PK_QT01 AS
--
PROCEDURE P_QT01(
		 I_deb_numsoc	IN	V_trav_revers_taxe.numsoc%TYPE		default NULL,
		 I_fin_numsoc	IN	V_trav_revers_taxe.numsoc%TYPE		default NULL,
		 I_deb_numorg	IN	V_trav_revers_taxe.numorg%TYPE		default NULL,
		 I_fin_numorg	IN	V_trav_revers_taxe.numorg%TYPE		default NULL,
		 I_deb_numgar	IN	V_trav_revers_taxe.numgar%TYPE		default NULL,
		 I_fin_numgar	IN	V_trav_revers_taxe.numgar%TYPE		default NULL,
		 I_dataffec	  IN	VARCHAR2 				                  default NULL,
		 I_dateche	  IN	VARCHAR2				                  default NULL,
		 I_session	  IN	NUMBER					                  Default 1,
		 I_niv_msg	  IN	NUMBER					                  Default 1,
		 I_pause	    IN	NUMBER					                  Default 0,
		 O_found	    OUT	NUMBER,
		 O_erreur	    OUT	VARCHAR2
		);
--

--
-- Chaine de reconnaissance SCCS
-- %W%	%E%

-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
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
-- Aucune
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_QT01 AS
-- Chaine de reconnaissance SCCS
-- %W%	%E%

-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --

-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
--
PROCEDURE P_traitement_principal;
--
PROCEDURE P_ENTETE_idaffec;
--
PROCEDURE P_CORPS_idaffec;
--
PROCEDURE P_PIED_idaffec;
--
PROCEDURE P_maj_qttc_affec_tfc;
--
PROCEDURE P_select_idrevers;
--
PROCEDURE P_ins_taxe;
--
PROCEDURE P_debut_traitement;
--
PROCEDURE P_fin_traitement;
--
PROCEDURE P_INS_journal;
--
-- ----------------------------- Fin des declarations des procedures privees --

-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
-- Aucune
-- ---------------------------------- Fin des corps des procedures publiques --
--
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --

-- Variables de sortie
--

G_dataffec		    DATE;
G_dateche		      DATE;

G_flag_test		    VARCHAR2(1);
G_idrevtax		    NUMBER(10);
G_montant_total		NUMBER(11,2);
G_montant_total_d	NUMBER(11,2);
G_pre_numsoc		  NUMBER(10);
G_pre_numorg		  NUMBER(10);
G_pre_monnaie_d		V_trav_revers_taxe.monnaie_d%TYPE;
G_trait_entete  	VARCHAR2(1);
--

-- Variables globales priv‚es
--
G_numsoc		      V_trav_revers_taxe.numsoc%TYPE;
G_numorg		      V_trav_revers_taxe.numorg%TYPE;
-- G_numquit		      V_trav_revers_taxe.numquit%TYPE;
-- G_numfor		      V_trav_revers_taxe.numfor%TYPE;
G_idaffec		      V_trav_revers_taxe.idaffec%TYPE;
G_montant		      V_trav_revers_taxe.montant%TYPE;
G_monnaie		      V_trav_revers_taxe.monnaie%TYPE;
G_montant_d		    V_trav_revers_taxe.montant_d%TYPE;
G_monnaie_d		    V_trav_revers_taxe.monnaie_d%TYPE;
--
--
G_numsoc_deb		  V_trav_revers_taxe.numsoc%TYPE;
G_numorg_deb		  V_trav_revers_taxe.numorg%TYPE;
-- G_ref_chap_deb		V_trav_revers_taxe.refcie_chapeau%TYPE;
G_numgar_deb		  V_trav_revers_taxe.numgar%TYPE;
G_numsoc_fin		  V_trav_revers_taxe.numsoc%TYPE;
G_numorg_fin		  V_trav_revers_taxe.numorg%TYPE;
-- G_ref_chap_fin		V_trav_revers_taxe.refcie_chapeau%TYPE;
G_numgar_fin		  V_trav_revers_taxe.numgar%TYPE;
--
-- Flag de commit ou rollback a retourner a Forms
G_commit		      Boolean := FALSE;
G_rollback		    Boolean := FALSE;
G_auto_valide		  Boolean := FALSE;
--
G_flag_test		    NUMBER;
G_proc			      VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'PK_QT01';
G_msg_adm		      journal_adm.msg_adm%TYPE;
G_session		      journal_adm.id_session%TYPE default 1;
G_niv_msg		      journal_adm.niv_msg%TYPE := 3;
G_max_msg		      journal_adm.niv_msg%TYPE := 3;
G_idligne		      journal_adm.idligne%TYPE := 0;
G_erreur		      journal_adm.msg_adm%TYPE;

-- G_niv_msg prend les Valeurs :
--	0 --> Message d'erreurs (Erreur ORACLE)
--	1 --> Message informatif(tout se passe bien)
--	2 et + Niveau de detail
---------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
--
-- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
--
----------------------------------------------------------------------------
CURSOR C_select_taxe IS
	SELECT
		V_trav_revers_taxe.numsoc,
		V_trav_revers_taxe.numorg,
--		V_trav_revers_taxe.numquit,
--		V_trav_revers_taxe.numfor,
		V_trav_revers_taxe.idaffec,
		V_trav_revers_taxe.montant,
		V_trav_revers_taxe.monnaie,
		V_trav_revers_taxe.montant_d,
		V_trav_revers_taxe.monnaie_d
	FROM	V_trav_revers_taxe
	WHERE	V_trav_revers_taxe.idrevers = 0
	AND   V_trav_revers_taxe.numsoc
        BETWEEN G_numsoc_deb AND NVL(G_numsoc_fin,G_numsoc_deb)
  AND   TRUNC(V_trav_revers_taxe.dataffec) <= NVL(G_dataffec,SYSDATE)
  AND   TRUNC(V_trav_revers_taxe.echeance) <= NVL(G_dateche,SYSDATE)
	AND		V_trav_revers_taxe.numorg
				BETWEEN nvl(to_number(G_numorg_deb),V_trav_revers_taxe.numorg)
				AND NVL(to_number(G_numorg_fin),nvl(to_number(G_numorg_deb),V_trav_revers_taxe.numorg))
	AND		V_trav_revers_taxe.numgar
				BETWEEN NVL(G_numgar_deb, V_trav_revers_taxe.numgar) AND NVL(G_numgar_fin,NVL(G_numgar_deb, V_trav_revers_taxe.numgar))
	ORDER BY
		V_trav_revers_taxe.numsoc,
    V_trav_revers_taxe.numorg,
    V_trav_revers_taxe.monnaie_d;
--

------------------------------------------------------------------
--
-- Le corps des diff‚rentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_QT01(
		 I_deb_numsoc	  IN	V_trav_revers_taxe.numsoc%TYPE		default NULL,
		 I_fin_numsoc	  IN	V_trav_revers_taxe.numsoc%TYPE		default NULL,
		 I_deb_numorg	  IN	V_trav_revers_taxe.numorg%TYPE		default NULL,
		 I_fin_numorg	  IN	V_trav_revers_taxe.numorg%TYPE		default NULL,
		 I_deb_numgar	  IN	V_trav_revers_taxe.numgar%TYPE		default NULL,
		 I_fin_numgar	  IN	V_trav_revers_taxe.numgar%TYPE		default NULL,
		 I_dataffec	    IN	VARCHAR2 				                  default NULL,
		 I_dateche	    IN	VARCHAR2				                  default NULL,
		 I_session	    IN	NUMBER					                  default 1,
		 I_niv_msg	    IN	NUMBER					                  default 1,
		 I_pause	      IN	NUMBER					                  default 0,
		 O_found	     OUT	NUMBER,
		 O_erreur	     OUT	VARCHAR2
		)
IS

R_select_taxe 	C_select_taxe%ROWTYPE;

BEGIN

-- DBMS_OUTPUT.PUT_LINE( 'Debut' );
	--
	O_found       := 1;
	G_erreur      := Null;
	--
	G_numsoc_deb	:= I_deb_numsoc;
	G_numsoc_fin	:= I_fin_numsoc;
	G_numorg_deb	:= I_deb_numorg;
	G_numorg_fin	:= I_fin_numorg;
	G_numgar_deb	:= I_deb_numgar;
	G_numgar_fin	:= I_fin_numgar;
--	G_ref_chap_deb	:= I_deb_ref_chap;
--	G_ref_chap_fin	:= I_fin_ref_chap;
--	G_dataffec	  := NVL(I_dataffec, Sysdate);
  G_dataffec    := NVL(e2d(I_dataffec), Sysdate);
--	G_dateche	    := NVL(I_dateche, Sysdate);
	G_dateche	    := NVL(e2d(I_dateche), Sysdate);
	--
	G_session       := I_session;
	G_trait_entete	:= NULL;
	--
	-- OUVERTURE du Curseur
	--
	P_debut_traitement;
	--
	LOOP
		FETCH C_select_taxe INTO R_select_taxe;
		--
		EXIT WHEN C_select_taxe%NOTFOUND;
		--
		-- LECTURE D'1 Ligne dans la table principale
		--
		--*debut debogage
    G_niv_msg := 3;
    G_Msg_adm := 'Jalon lecture curseur ';
    P_INS_journal;
		--*fin debogage
		--
		O_found		:= 0;
		G_numsoc	:= R_select_taxe.numsoc;
		G_numorg	:= R_select_taxe.numorg;
--		G_numquit	:= R_select_taxe.numquit;
--		G_numfor	:= R_select_taxe.numfor;
		G_idaffec	:= R_select_taxe.idaffec;
		G_montant	:= R_select_taxe.montant;
    G_monnaie	:= R_select_taxe.monnaie;
    G_montant_d	:= R_select_taxe.montant_d;
    G_monnaie_d	:= R_select_taxe.monnaie_d;
		--
		P_traitement_principal;
		--
	END LOOP;

	P_fin_traitement;
    --
	O_erreur	:= G_erreur;
--	DBMS_OUTPUT.PUT_LINE( 'Fin' );
	--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_QT01 -
'||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
		Close C_select_taxe;
END;
--
-- -----------------------------
PROCEDURE P_traitement_principal
IS
BEGIN
--  DBMS_OUTPUT.PUT_LINE( 'P_traitement_principal' );

	IF G_trait_entete IS NULL
	   THEN
		--
  		P_ENTETE_idaffec;
		--
		G_trait_entete  := '1';
		--
	END IF;
  	P_CORPS_idaffec;
END;
--
-- -----------------------
PROCEDURE P_ENTETE_idaffec
IS
BEGIN
--  DBMS_OUTPUT.PUT_LINE( 'P_ENTETE_idaffec' );
   G_montant_total	   := 0;
   G_montant_total_d	 := 0;
   G_pre_numsoc		     := G_numsoc;
   G_pre_numorg		     := G_numorg;
   G_pre_monnaie_d     := G_monnaie_d;
   P_select_idrevers;
END;
--
-- ----------------------
PROCEDURE P_CORPS_idaffec
IS
BEGIN
--  DBMS_OUTPUT.PUT_LINE( 'P_CORPS_idaffec' );
  IF G_numsoc = G_pre_numsoc
    THEN
      IF G_numorg != G_pre_numorg
        THEN
          P_PIED_idaffec;
          P_select_idrevers;
        ELSE
          IF G_monnaie_d != G_pre_monnaie_d
            THEN
              P_PIED_idaffec;
              P_select_idrevers;
        END IF;
      END IF;
    ELSE
      P_PIED_idaffec;
      P_select_idrevers;
  END IF;
  G_montant_total   := G_montant_total   + G_montant;
  G_montant_total_d := G_montant_total_d + G_montant_d;
  P_maj_qttc_affec_tfc;
END;
--
-- ---------------------
PROCEDURE P_PIED_idaffec
IS
BEGIN
--*debut debogage
    G_niv_msg       := 3;
    G_Msg_adm       := 'Jalon insertion revers ';
    P_INS_journal;
--*fin debogage
    P_ins_taxe;
    G_montant_total := 0;
    G_montant_total_d := 0;
    G_pre_numsoc	  := G_numsoc;
    G_pre_numorg	  := G_numorg;
    G_pre_monnaie_d := G_monnaie_d;
END;
--
-- ---------------------
PROCEDURE P_maj_qttc_affec_tfc
IS
BEGIN
--
G_proc := 'P_maj_qttc_affec_tfc';
--
--*debut debogage
    G_niv_msg := 3;
    G_Msg_adm := 'Jalon maj qttc_affec_tfc ';
    P_INS_journal;
--*fin debogage
	UPDATE 	qttc_affec_tfc
	SET	idrevers = G_idrevtax
	WHERE
--  qttc_affec_tfc.numquit = G_numquit
--	AND	qttc_affec_tfc.numfor = decode(qttc_affec_tfc.tfc,
--						4, qttc_affec_tfc.numfor,
--						G_numfor)
       qttc_affec_tfc.idaffec = G_idaffec
   AND qttc_affec_tfc.idrevers=0
   AND qttc_affec_tfc.tfc = 1;
--
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
--
END;
--
-- ------------------------
PROCEDURE P_select_idrevers
IS
BEGIN
--
	G_proc := 'P_select_idrevers';
--
/*
-- Mis en commentaire suite uniformisation des idrevers de reversements PHA 30/08/2010
	SELECT	nvl(max(idrevtax),0) + 1
	INTO	G_idrevtax
	FROM	REVERS_TAXE;
*/
select IDREVERS.nextval INTO G_idrevtax from dual;
--*debut debogage
        G_niv_msg := 3;
        G_Msg_adm := 'Jalon idrevers + 1 = '||to_char(G_idrevtax);
        P_INS_journal;
--*fin debogage
--
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
--
END;
--
-- -------------------
PROCEDURE P_ins_taxe
IS
BEGIN
--
G_proc := 'P_ins_taxe';
--
INSERT
	INTO REVERS_TAXE
    (
  	IDREVTAX,
    NUMSOC,
    NUMORG,
    DATREVERS,
    DEBUT,
    FIN,
    MONTANT,
    VALIDE,
    NUMUTIL,
    MONNAIE_D,
    MONTANT_D,
    MONNAIE
    )
	VALUES
    (
		nvl(G_idrevtax,1),
		G_pre_numsoc,
		G_pre_numorg,
		trunc(sysdate),
		G_dataffec,
		G_dateche,
		G_montant_total,
		'N',
		f_numutil,
		G_pre_monnaie_d,
		G_montant_total_d,
		G_monnaie
		);

--
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
--
END;
-- ----------------------------------------------------------------------------------------
--
-- DEBUT ET FIN DU TRAITEMENT
--
-- ----------------------------------------------------------------------------------------
PROCEDURE P_debut_traitement
IS
BEGIN
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Debut de traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
	OPEN C_select_taxe;
	G_trait_entete	:= NULL;
END;
--
-- -----------------------
PROCEDURE P_fin_traitement
IS
BEGIN
--
G_proc := 'P_fin_traitement';
--
  IF G_trait_entete IS NOT NULL
	   THEN
  		P_PIED_idaffec;
	END IF;
	--
	-- FERMETURE du Curseur
	--
	CLOSE C_select_taxe;
	--
	INSERT 	INTO 	lib_edition 	(numedit, editlib)
		VALUES			(G_session, 'Constitution Bordereaux de taxe');
	--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Fin Normale du traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
--
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
--
END;
--
----------------------- Fin des procedures publiques ------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
Procedure P_INS_journal
IS
L_idligne	Number;
BEGIN
If ( G_niv_msg <= G_max_msg ) then
	G_idligne := G_idligne + 1;
	If ( G_niv_msg = 0 ) then
		L_idligne := -1 * G_idligne;
	Else
		L_idligne := G_idligne;
	End If;
	PK_trace.P_INS_journal_adm (
		I_nom_traitement => G_nom_traitement,
		I_session	 => G_session,
		I_niv_msg	 => G_niv_msg,
		I_msg_adm	 => G_msg_adm,
		I_date		 => Sysdate,
		I_idligne	 => L_idligne);
End If;
END P_INS_journal;
---------------- Fin des corps des procedures privees --
END PK_QT01;
/
