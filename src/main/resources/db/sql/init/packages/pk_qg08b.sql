CREATE OR REPLACE PACKAGE ARTHUS.pk_qg08b AS
--
PROCEDURE P_QG08b(
		 I_deb_numsoc	IN	V_trav_reversement.numsoc%TYPE		default NULL,
		 I_fin_numsoc	IN	V_trav_reversement.numsoc%TYPE		default NULL,
		 I_deb_numorg	IN	V_trav_reversement.numorg%TYPE		default NULL,
		 I_fin_numorg	IN	V_trav_reversement.numorg%TYPE		default NULL,
		 I_deb_ref_chap	IN	V_trav_reversement.refcie_chapeau%TYPE 	default NULL,
		 I_fin_ref_chap	IN	V_trav_reversement.refcie_chapeau%TYPE	default NULL,
		 I_deb_numgar	IN	V_trav_reversement.numgar%TYPE		default NULL,
		 I_fin_numgar	IN	V_trav_reversement.numgar%TYPE		default NULL,
		 I_dataffec	IN	date 					default NULL,
		 I_dateche	IN	date					default NULL,
		 I_session	IN	NUMBER					Default 1,
		 I_niv_msg	IN	NUMBER					Default 1,
		 I_pause	IN	NUMBER					Default 0,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_qg08b AS
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
PROCEDURE P_maj_qttc_affec;
--
PROCEDURE P_maj_qttc_affec_tfc;
--
PROCEDURE P_select_idrevers;
--
PROCEDURE P_ins_revers;
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

G_dataffec		date;
G_dateche		date;
G_flag_test		VARCHAR2(1);
G_idrevers		NUMBER(10);
G_montant_total		NUMBER(10,2);
G_devise			NUMBER(3);
G_montant_total_d	NUMBER(10,2);
G_devise_d			NUMBER(3);
G_pre_numsoc		NUMBER(10);
G_pre_numorg		NUMBER(10);
G_trait_entete  	boolean := FALSE;
--

-- Variables globales privées
--
G_numsoc		V_trav_reversement.numsoc%TYPE;
G_numorg		V_trav_reversement.numorg%TYPE;
G_numquit		V_trav_reversement.numquit%TYPE;
G_numfor		V_trav_reversement.numfor%TYPE;
G_idaffec		V_trav_reversement.idaffec%TYPE;
G_montant		V_trav_reversement.montant%TYPE;
G_monnaie		V_trav_reversement.monnaie%TYPE;
--
--
G_numsoc_deb		V_trav_reversement.numsoc%TYPE;
G_numorg_deb		V_trav_reversement.numorg%TYPE;
G_ref_chap_deb		V_trav_reversement.refcie_chapeau%TYPE;
G_numgar_deb		V_trav_reversement.numgar%TYPE;
G_numsoc_fin		V_trav_reversement.numsoc%TYPE;
G_numorg_fin		V_trav_reversement.numorg%TYPE;
G_ref_chap_fin		V_trav_reversement.refcie_chapeau%TYPE;
G_numgar_fin		V_trav_reversement.numgar%TYPE;
--
-- Flag de commit ou rollback a retourner a Forms
G_commit		Boolean := FALSE;
G_rollback		Boolean := FALSE;
G_auto_valide	Boolean := FALSE;
--
G_flag_test		NUMBER;
G_proc			VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_QG08B';
G_msg_adm		journal_adm.msg_adm%TYPE;
G_session		journal_adm.id_session%TYPE default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%TYPE;

G_rowcount		number := 0;

-- G_niv_msg prend les Valeurs :
--	0 --> Message d'erreurs (Erreur ORACLE)
--	1 --> Message informatif(tout se passe bien)
--	2 et + Niveau de detail
---------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
--
-- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs

----------------------------------------------------------------------------

------------------------------------------------------------------
--
-- Le corps des diff¿rentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_qg08b(
		 I_deb_numsoc	IN	V_trav_reversement.numsoc%TYPE		default NULL,
		 I_fin_numsoc	IN	V_trav_reversement.numsoc%TYPE		default NULL,
		 I_deb_numorg	IN	V_trav_reversement.numorg%TYPE		default NULL,
		 I_fin_numorg	IN	V_trav_reversement.numorg%TYPE		default NULL,
		 I_deb_ref_chap	IN	V_trav_reversement.refcie_chapeau%TYPE	default NULL,
		 I_fin_ref_chap	IN	V_trav_reversement.refcie_chapeau%TYPE	default NULL,
		 I_deb_numgar	IN	V_trav_reversement.numgar%TYPE		default NULL,
		 I_fin_numgar	IN	V_trav_reversement.numgar%TYPE		default NULL,
		 I_dataffec	IN	date 				default NULL,
		 I_dateche	IN	date				default NULL,
		 I_session	IN	NUMBER					default 1,
		 I_niv_msg	IN	NUMBER					default 1,
		 I_pause	IN	NUMBER					default 0,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
		)
IS
CURSOR C_select_idaffec IS
	SELECT
		v_trav_reversement.numsoc,
		v_trav_reversement.numorg,
		v_trav_reversement.numquit,
		v_trav_reversement.numfor,
		v_trav_reversement.idaffec,
		v_trav_reversement.montant,
		v_trav_reversement.monnaie
        FROM	v_trav_reversement,
        		pers_organisme
	WHERE	v_trav_reversement.idrevers = 0
	AND		v_trav_reversement.numsoc+0 = nvl(G_numsoc_deb,v_trav_reversement.numsoc+0)
	AND		v_trav_reversement.dataffec <= G_dataffec
	AND		v_trav_reversement.numorg
			between nvl(to_number(G_numorg_deb), v_trav_reversement.numorg)
			and nvl(to_number(G_numorg_fin), nvl(to_number(G_numorg_deb), v_trav_reversement.numorg))
	AND		v_trav_reversement.refcie_chapeau||'-'
			between nvl(G_ref_chap_deb,	v_trav_reversement.refcie_chapeau||'-')
			and nvl(G_ref_chap_fin, nvl(G_ref_chap_deb,	v_trav_reversement.refcie_chapeau||'-'))
    AND     decode	(v_trav_reversement.nat_calc,1,(v_trav_reversement.fin + 1),v_trav_reversement.debut) <= G_dateche
	AND		v_trav_reversement.numgar
			between nvl(G_numgar_deb, v_trav_reversement.numgar)
			and nvl(G_numgar_fin, nvl(G_numgar_deb, v_trav_reversement.numgar))
	AND 	v_trav_reversement.numorg = pers_organisme.numindiv
	AND 	pers_organisme.revers_cotis = 1
	Order By
		v_trav_reversement.numsoc,
		v_trav_reversement.numorg;
--
R_select_idaffec 	C_select_idaffec%ROWTYPE;
--
BEGIN
	--
	G_rowcount  	:= 0;
	O_found         := 1;
	G_erreur        := Null;
	--
	G_numsoc_deb	:= I_deb_numsoc;
	G_numsoc_fin	:= I_fin_numsoc;
	G_numorg_deb	:= I_deb_numorg;
	G_numorg_fin	:= I_fin_numorg;
	G_numgar_deb	:= I_deb_numgar;
	G_numgar_fin	:= I_fin_numgar;
	G_ref_chap_deb	:= I_deb_ref_chap;
	G_ref_chap_fin	:= I_fin_ref_chap;
	G_dataffec		:= NVL(I_dataffec, trunc(Sysdate));
	G_dateche		:= NVL(I_dateche, trunc(Sysdate));
	--
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);
	--*debut debogage
	--
	FOR R_select_idaffec in C_select_idaffec LOOP

		IF G_trait_entete = FALSE THEN
				P_debut_traitement;
		END IF;

		G_rowcount	:= C_select_idaffec%ROWCOUNT;
		O_found		:= 1;
		G_numsoc	:= R_select_idaffec.numsoc;
		G_numorg	:= R_select_idaffec.numorg;
		G_numquit	:= R_select_idaffec.numquit;
		G_numfor	:= R_select_idaffec.numfor;
		G_idaffec	:= R_select_idaffec.idaffec;
		G_montant	:= R_select_idaffec.montant;
		G_monnaie	:= R_select_idaffec.monnaie;
		--
		P_traitement_principal;
		--
	END LOOP;
	--
 	g_niv_msg := 3;
    G_Msg_adm := 'Jalon fin curseur ';
    P_INS_journal;
	O_found	:= 0;
	--
	P_fin_traitement;
	--
	O_erreur	:= G_erreur;
	--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_QG08B -
'||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
END;
--
-- -----------------------------
PROCEDURE P_traitement_principal
IS
BEGIN
	IF G_trait_entete = FALSE
	   THEN
		--
  		P_ENTETE_idaffec;
		--
		G_trait_entete  := TRUE;
		--
	END IF;
  	P_CORPS_idaffec;
END;
--
-- -----------------------
PROCEDURE P_ENTETE_idaffec
IS
BEGIN
   G_montant_total		:= 0;
   G_montant_total_d	:= 0;
   G_pre_numsoc			:= G_numsoc;
   G_pre_numorg			:= G_numorg;
   P_select_idrevers;
END;
--
-- ----------------------
PROCEDURE P_CORPS_idaffec
IS
BEGIN
  IF G_numsoc = G_pre_numsoc
     THEN
	IF G_numorg != G_pre_numorg
	   THEN
		P_PIED_idaffec;
		P_select_idrevers;
	END IF;
  ELSE
	P_PIED_idaffec;
	P_select_idrevers;
  END IF;
  G_montant_total 	:= G_montant_total + G_montant;
  G_montant_total_d	:= G_montant_total;
  G_devise			:= G_monnaie;
  G_devise_d		:= G_monnaie;
  P_maj_qttc_affec;
  P_maj_qttc_affec_tfc;
END;
--
-- ---------------------
PROCEDURE P_PIED_idaffec
IS
BEGIN
--*debut debogage
        G_niv_msg := 3;
        G_Msg_adm := 'Jalon insertion revers ';
        P_INS_journal;
--*fin debogage
   --
   P_ins_revers;
   --
   G_montant_total 		:= 0;
   G_montant_total_d 	:= 0;
   G_pre_numsoc			:= G_numsoc;
   G_pre_numorg			:= G_numorg;
END;
--
-- ---------------------
PROCEDURE P_maj_qttc_affec
IS
BEGIN
--
G_proc := 'P_maj_qttc_affec';
--
--*debut debogage
        G_niv_msg := 3;
        G_Msg_adm := 'Jalon maj qttc_affec ';
        P_INS_journal;
--*fin debogage
	UPDATE 	qttc_affec
	SET	idrevers = G_idrevers
	WHERE	qttc_affec.numquit = G_numquit
	AND	qttc_affec.numfor = G_numfor
	AND	qttc_affec.idaffec = G_idaffec
	AND	qttc_affec.idrevers=0;
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
-- -------------------------
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
	SET	idrevers = G_idrevers
	WHERE	qttc_affec_tfc.numquit = G_numquit
	AND	qttc_affec_tfc.numfor = decode(qttc_affec_tfc.tfc,
						4, qttc_affec_tfc.numfor,
						G_numfor)
	AND	qttc_affec_tfc.idaffec = G_idaffec
	AND	qttc_affec_tfc.idrevers=0;
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
	SELECT	nvl(max(idrevers),0) + 1
	INTO	G_idrevers
	FROM	reversement;
--*debut debogage
        G_niv_msg := 3;
        G_Msg_adm := 'Jalon idrevers + 1 = '||to_char(G_idrevers);
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
PROCEDURE P_ins_revers
IS
BEGIN
--
G_proc := 'P_ins_revers';
--
INSERT
	INTO	reversement (
		idrevers,
		numsoc,
		numorg,
		datrevers,
		debut,
		fin,
		montant,
		monnaie,
		montant_d,
		monnaie_d,
		valide)
	VALUES(
		nvl(G_idrevers,1),
		G_pre_numsoc,
		G_pre_numorg,
		trunc(sysdate),
		G_dataffec,
		G_dateche,
		G_montant_total,
		G_devise,
		G_montant_total_d,
		G_devise_d,
		'N'
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
		G_niv_msg		:= 1;
		G_msg_adm		:= 'Debut de traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
		P_INS_journal;
		G_msg_adm		:= 'Paramètres de < '||TO_CHAR(G_numsoc_deb)||'>< '||to_char(G_numorg_deb)||'>< '||to_char(G_ref_chap_deb)||'>< '||to_char(G_numgar_deb)||'>< '||to_char(G_dataffec)||'>< '||to_char(G_dateche)||'>';
		P_INS_journal;
		G_msg_adm		:= 'Paramètres à  < '||TO_CHAR(G_numsoc_fin)||'>< '||to_char(G_numorg_fin)||'>< '||to_char(G_ref_chap_fin)||'>< '||to_char(G_numgar_fin)||'>';
		P_INS_journal;
		-- Fin ecriture dans le Journal
		G_trait_entete	:= FALSE;
END;
--
-- -----------------------
PROCEDURE P_fin_traitement
IS
BEGIN
--
G_proc := 'P_fin_traitement';
--
  IF G_trait_entete = TRUE
	   THEN
  		P_PIED_idaffec;
	END IF;
	--
	INSERT 	INTO 		lib_edition 	(numedit, editlib)
		VALUES			(G_session, 'Constitution Bordereaux de reversement de primes');
	--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Rowcount <'||TO_CHAR(G_rowcount)||'>';
	P_INS_journal;
	G_msg_adm	:= 'Fin Normale du traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
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
		I_idligne	 => L_idligne);
End If;
END P_INS_journal;
---------------- Fin des corps des procedures privees --
END;
/
