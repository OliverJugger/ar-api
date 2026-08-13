CREATE OR REPLACE PACKAGE ARTHUS.pk_vr03b AS
--
PROCEDURE P_vr03b(
		 I_deb_numcpte	IN	vs_compte.numcpte%type	default NULL,
		 I_fin_numcpte	IN	vs_compte.numcpte%type	default NULL,
		 I_deb_codope	IN	decaismt.codope%type	default NULL,
		 I_fin_codope	IN	decaismt.codope%type	default NULL,
		 I_session	IN	NUMBER			Default 1,
		 I_niv_msg	IN	NUMBER			Default 1,
		 I_pause	IN	NUMBER			Default 0,
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_vr03b AS
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
PROCEDURE P_fin_traitement;
--
PROCEDURE P_CORPS_sel_numcpte;
--
PROCEDURE P_sel_decaismt;
--
PROCEDURE P_sel_piece_contrat;
--
PROCEDURE P_sel_remise_vire_detail;
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

-- Variables globales priv¿es
--
G_numcpte		vs_compte.numcpte%type;
G_libcompte		vs_compte.libcompte%type;
--
G_decaismt_numdecaismt	decaismt.numdecaismt%type;
G_decaismt_montant	decaismt.montant%type;
G_decaismt_numbene	decaismt.numbene%type;
G_decaismt_numdest	decaismt.numdest%type;
G_decaismt_codope	decaismt.codope%type;
G_decaismt_modpmt	decaismt.modpmt%type;
G_decaismt_nombene	VARCHAR2(60);
--
G_min_numgar		contrat.numgar%type;
G_numgar_pie		contrat.numgar%type;
G_nb_numgar		number(10);
--
G_idrib			rib.idrib%type;
--
G_pie_contrat_trouve	VARCHAR2(1);
G_rib_existe		VARCHAR2(1);
G_vire_detail_ins	VARCHAR2(1);
--
G_rib_codbque		rib.codbque%type;
G_rib_guichet		rib.guichet%type;
G_rib_compte		rib.compte%type;
G_rib_clerib		rib.clerib%type;
G_rib_intitule		rib.intitule%type;
G_rib_clef_iban		rib.clef_iban%type;
G_rib_bban		rib.bban%type;
G_rib_bic		rib.bic%type;
G_rib_codpays		rib.codpays%type;
--
G_premier_virement 	VARCHAR2(1);
--
G_rib_codbque_old	rib.codbque%type;
G_rib_guichet_old	rib.guichet%type;
G_rib_compte_old	rib.compte%type;
G_rib_clerib_old	rib.clerib%type;
G_rib_intitule_old	rib.intitule%type;
G_rib_clef_iban_old	rib.clef_iban%type;
G_rib_bban_old		rib.bban%type;
G_rib_bic_old		rib.bic%type;
G_rib_codpays_old	rib.codpays%type;
--
G_numremise		remise_vire.numremise%type;
G_numvirement		remise_vire_detail.numvirement%type;
G_datrem		remise_vire.datrem%type;
G_nombre		remise_vire.nombre%type;
G_valide		remise_vire.valide%type;
--
-- parametres du traitement
G_numcpte_deb	vs_compte.numcpte%type;
G_numcpte_fin	vs_compte.numcpte%type;
G_codope_deb	decaismt.codope%type;
G_codope_fin	decaismt.codope%type;
--
-- Flag de commit ou rollback a retourner a Forms
G_commit		Boolean := FALSE;
G_rollback		Boolean := FALSE;
G_auto_valide		Boolean := FALSE;
--
G_flag_test		NUMBER;
G_proc			VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%Type default 'pk_VR03B';
G_msg_adm		journal_adm.msg_adm%Type;
G_session		journal_adm.id_session%Type default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%Type;

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

CURSOR C_sel_numcpte is
	SELECT	vs_compte.numcpte, vs_compte.libcompte
	FROM	vs_compte
	WHERE	vs_compte.numcpte
			between	nvl(G_numcpte_deb,
				    vs_compte.numcpte)
			and	nvl(G_numcpte_fin,
				    nvl(G_numcpte_deb,
					vs_compte.numcpte)
				   );
--
CURSOR C_sel_decaismt is
	SELECT
		decaismt.numdecaismt,
		decaismt.montant,
		decaismt.numbene,
		decaismt.numdest,
		decaismt.codope,
		decaismt.modpmt,
		indvs.nom||indvs.prenom		nombene
	FROM	decaismt,
		indvs
	WHERE	decaismt.flagpay	= -1
	and	decaismt.numutil + 0 	>= 0
	and 	decaismt.montant + 0 	> 0
	and	decaismt.modpmt		= 2
	AND	decaismt.numcpte	= G_numcpte
	AND	decaismt.numbene	= indvs.numindiv
	AND	decaismt.codope
			between	nvl(G_codope_deb,
				    decaismt.codope)
			and	nvl(G_codope_fin,
				    nvl(G_codope_deb,
					decaismt.codope)
				   )
	AND	NOT EXISTS
			(select	1
			from	remise_vire_detail
			where	remise_vire_detail.numdecaismt	= decaismt.numdecaismt
			);
--
---- Curseur - pièces affectées à un décaissement
--
Cursor c_pie_contrat(I_numdecaismt number) IS
        SELECT  codope, numaffec
        FROM    affectation
        Where   affectation.numdecaismt=I_numdecaismt;
--
CURSOR C_sel_remise_vire_detail is
	SELECT	b.codbque,
		b.guichet,
		b.compte,
		b.clerib,
		b.intitule,
		b.clef_iban,
		b.bban,
		b.bic,
		b.codpays
	FROM	remise_vire_detail b
	WHERE	b.numremise = G_numremise
        FOR UPDATE OF numvirement
        ORDER
	BY	codbque,
                guichet,
                compte,
                clerib,
                intitule,
		clef_iban,
		bban,
		bic,
		codpays
		;
--
------------------------------------------------------------------
--
-- Le corps des diff¿rentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_vr03b(
		 I_deb_numcpte	IN	vs_compte.numcpte%type	default NULL,
		 I_fin_numcpte	IN	vs_compte.numcpte%type	default NULL,
		 I_deb_codope	IN	decaismt.codope%type 	default NULL,
		 I_fin_codope	IN	decaismt.codope%type	default NULL,
		 I_session	IN	NUMBER			Default 1,
		 I_niv_msg	IN	NUMBER			Default 1,
		 I_pause	IN	NUMBER			Default 0,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
		)
IS
R_sel_numcpte 	C_sel_numcpte%ROWTYPE;

BEGIN
	--
	O_found		:= 1;
	G_erreur	:= Null;
	--
	G_numcpte_deb	:= I_deb_numcpte;
	G_numcpte_fin	:= I_fin_numcpte;
	G_codope_deb	:= I_deb_codope;
	G_codope_fin	:= I_fin_codope;
	--
	G_max_msg	:= I_niv_msg;
	G_session	:= I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);
	--
--
-- OUVERTURE du Curseur
--
	IF NOT C_sel_numcpte%ISOPEN THEN
	   --
	   G_niv_msg	:= 1;
	   G_msg_adm	:= 'Debut de traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	   P_INS_journal;
  	   -- Fin ecriture dans le Journal
	   OPEN C_sel_numcpte;
	   --
	END IF;
   --
   -- LECTURE D'1 Ligne dans la table principale
   --

	FETCH C_sel_numcpte INTO R_sel_numcpte;
	--
	IF C_sel_numcpte%NOTFOUND THEN
		O_found	:= 0;
		-- FERMETURE du Curseur
        	P_fin_traitement;
	ELSE
		O_found	:= 1;
		G_numcpte	:= R_sel_numcpte.numcpte;
		G_libcompte	:= R_sel_numcpte.libcompte;
--
--*debogage debut
	G_niv_msg	:= 3;
	G_msg_adm	:= 'compte treso n° '||to_char(G_numcpte)||' - '||to_char(G_libcompte);
	P_INS_journal;
--*debogage fin
--
  		P_CORPS_sel_numcpte;
--
	END IF;
        --
	O_erreur	:= G_erreur;
	--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_VR03B - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
END;
--
--------------------------
PROCEDURE P_fin_traitement IS
BEGIN
--
G_proc := 'P_fin_traitement';
--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Fin Normale du traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
	CLOSE C_sel_numcpte;
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
-- -----------------------------
PROCEDURE P_CORPS_sel_numcpte IS
BEGIN
--
G_proc := 'P_CORPS_sel_numcpte';
--
	--
	SELECT	nvl(max(numremise),0) + 1
	INTO	G_numremise
	FROM	remise_vire;
	--
	G_vire_detail_ins	:= 'N';
	--
	P_sel_decaismt;
	--
	-- test si virement détail insérés parmi les décaissements pour ce G_numcpte !
	IF G_vire_detail_ins = 'O' THEN
		--
		P_sel_remise_vire_detail;
		--
		G_proc := G_proc||' - Ins remise_vire Bdx n° '||to_char(G_numremise);
		--
		INSERT INTO remise_vire
					(
					numremise,
					numcpte,
					datrem,
					nombre,
					montant,
					valide
					)
				SELECT	numremise,
					numcpte,
					trunc(sysdate),
					count(distinct numvirement),
					sum(montant),
					'N'
				FROM	remise_vire_detail
				WHERE	remise_vire_detail.numremise=G_numremise
				GROUP
				BY	numremise,
					numcpte;
	END IF;
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
-- ---------------------------------
PROCEDURE P_sel_remise_vire_detail  IS
R_sel_remise_vire_detail		C_sel_remise_vire_detail%ROWTYPE;
BEGIN
--
G_proc := 'P_sel_remise_vire_detail';
--
   OPEN C_sel_remise_vire_detail;
   --
   G_premier_virement := 'O';
   --
   -------- P_sel_numvirement_next;
   SELECT	numvirement.nextval
   INTO		G_numvirement
   FROM		dual;
   --
   --
   LOOP
	FETCH C_sel_remise_vire_detail INTO R_sel_remise_vire_detail;
	EXIT WHEN C_sel_remise_vire_detail%NOTFOUND;
	--
	G_rib_codbque	:= R_sel_remise_vire_detail.codbque;
	G_rib_guichet	:= R_sel_remise_vire_detail.guichet;
	G_rib_compte	:= R_sel_remise_vire_detail.compte;
	G_rib_clerib	:= R_sel_remise_vire_detail.clerib;
	G_rib_intitule	:= R_sel_remise_vire_detail.intitule;
	G_rib_clef_iban	:= R_sel_remise_vire_detail.clef_iban;
	G_rib_bban	:= R_sel_remise_vire_detail.bban;
	G_rib_bic	:= R_sel_remise_vire_detail.bic;
	G_rib_codpays	:= R_sel_remise_vire_detail.codpays;
	--
        G_rib_intitule	:= f_desaccentue(G_rib_intitule);
        G_rib_intitule	:= upper(G_rib_intitule);
	--
	--
	If G_premier_virement = 'O' Then
		--
		G_premier_virement	:= 'N';
		--
		G_rib_codbque_old	:= G_rib_codbque;
		G_rib_guichet_old	:= G_rib_guichet;
		G_rib_compte_old	:= G_rib_compte;
		G_rib_clerib_old	:= G_rib_clerib;
		G_rib_intitule_old	:= G_rib_intitule;
		G_rib_clef_iban_old	:= G_rib_clef_iban;
		G_rib_bban_old		:= G_rib_bban;
		G_rib_bic_old		:= G_rib_bic;
		G_rib_codpays_old	:= G_rib_codpays;
	--
	End if;
	--
	--
	IF G_rib_codbque	<> G_rib_codbque_old
	OR G_rib_guichet	<> G_rib_guichet_old
	OR G_rib_compte		<> G_rib_compte_old
	OR G_rib_clerib		<> G_rib_clerib_old
	OR G_rib_intitule	<> G_rib_intitule_old
	OR G_rib_clef_iban	<> G_rib_clef_iban_old
	OR G_rib_bban		<> G_rib_bban_old
	OR G_rib_bic		<> G_rib_bic_old
	OR G_rib_codpays	<> G_rib_codpays_old
	--
	THEN
	-------- P_sel_numvirement_next;
		SELECT	numvirement.nextval
		INTO	G_numvirement
		FROM	dual;
	--
	END IF;
	--
	--
	UPDATE	remise_vire_detail a
		SET a.numvirement = G_numvirement
	WHERE CURRENT OF C_sel_remise_vire_detail;
	--
	--
	--*debogage debut
		G_niv_msg	:= 3;
		G_msg_adm	:= 'upd remise_vire_detail n° '||to_char(G_numvirement)||' - '
				||'remise n° '||to_char(G_numremise);
		P_INS_journal;
	--*debogage fin
	--
	--
	G_rib_codbque_old	:= G_rib_codbque;
	G_rib_guichet_old	:= G_rib_guichet;
	G_rib_compte_old	:= G_rib_compte;
	G_rib_clerib_old	:= G_rib_clerib;
	G_rib_intitule_old	:= G_rib_intitule;
	G_rib_clef_iban_old	:= G_rib_clef_iban;
	G_rib_bban_old		:= G_rib_bban;
	G_rib_bic_old		:= G_rib_bic;
	G_rib_codpays_old	:= G_rib_codpays;
	--
   END LOOP;
   CLOSE C_sel_remise_vire_detail;
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
--------------------------
PROCEDURE P_sel_piece_contrat
IS

R_piece_contrat 	C_pie_contrat%ROWTYPE;

BEGIN
--
G_proc := 'P_sel_piece_contrat';
--
--
Open c_pie_contrat(G_decaismt_numdecaismt);
--
G_min_numgar		:= 0;
G_numgar_pie		:= 0;
G_nb_numgar		:= 0;
--
G_pie_contrat_trouve 	:= 'N';
--
Loop
	Fetch c_pie_contrat into R_piece_contrat;
	--
	If c_pie_contrat%notfound then
		Close c_pie_contrat;
		Exit;
	Else
		--
		Begin
			G_numgar_pie := nvl(f_piece_contrat(R_piece_contrat.codope, R_piece_contrat.numaffec),0);
			G_pie_contrat_trouve := 'O';
			--
			If ((G_numgar_pie < G_min_numgar)
			and  G_numgar_pie <> 0) then
			    G_min_numgar := G_numgar_pie;
			    G_nb_numgar  := G_nb_numgar+1;
			elsif G_numgar_pie > G_min_numgar then
				G_nb_numgar := G_nb_numgar+1;
			End if;
			--
		Exception when others Then
			G_numgar_pie 		:= 0;
			G_pie_contrat_trouve 	:= 'N';
			--
			--*msg debut
			G_niv_msg	:= 2;
			G_msg_adm	:= 'Le decaismt n° '||to_char(G_decaismt_numdecaismt)
					||' a un probleme de référence pièce - contrat ';
			P_INS_journal;
			--*msg fin
			--
			Close c_pie_contrat;
			Exit;
		End;
		--
	End if;
	--
End loop;
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
-- ----------------------------
PROCEDURE P_sel_decaismt IS
R_sel_decaismt		C_sel_decaismt%ROWTYPE;

BEGIN
--
G_proc := 'P_sel_decaismt';
--
OPEN C_sel_decaismt;
LOOP
   FETCH C_sel_decaismt INTO R_sel_decaismt;
   EXIT WHEN  C_sel_decaismt%NOTFOUND;
   G_decaismt_numdecaismt	:= R_sel_decaismt.numdecaismt;
   G_decaismt_montant		:= R_sel_decaismt.montant;
   G_decaismt_numbene		:= R_sel_decaismt.numbene;
   G_decaismt_numdest		:= R_sel_decaismt.numdest;
   G_decaismt_codope		:= R_sel_decaismt.codope;
   G_decaismt_modpmt		:= R_sel_decaismt.modpmt;
   G_decaismt_nombene		:= R_sel_decaismt.nombene;
   --
   P_sel_piece_contrat;
   --
   --
   IF G_pie_contrat_trouve = 'N' THEN
--
--*msg debut
		G_niv_msg	:= 2;
		G_msg_adm	:= 'Le decaismt n° '||to_char(G_decaismt_numdecaismt)
				||' n"a pas de référence pièce - contrat ';
		P_INS_journal;
		G_niv_msg	:= 2;
		G_msg_adm	:= 'Les références bancaires générales de ce bénéficiaire ne sont pas définies';
		P_INS_journal;
--*msg fin
--
   ELSE
   -- P_rech_idrib;
   	Begin
   		G_idrib		:= f_bene_rib	(
						G_decaismt_numdest,
						G_decaismt_codope,
						G_min_numgar,
						1
						);
		--
		Begin
			Select 	rib.codbque,
				rib.guichet,
				rib.compte,
				rib.clerib,
				rib.intitule,
				rib.clef_iban,
				rib.bban,
				rib.bic,
				rib.codpays
			Into 	G_rib_codbque,
				G_rib_guichet,
				G_rib_compte,
				G_rib_clerib,
				G_rib_intitule,
				G_rib_clef_iban,
				G_rib_bban,
				G_rib_bic,
				G_rib_codpays
			--
			From 	rib
			Where	idrib = G_idrib
			AND	clerib is not null
			;
			--
			G_rib_existe	:= 'O';
			--
		Exception when no_data_found then
			G_rib_existe	:= 'N';
		End;
		--
	Exception when no_data_found then
		G_rib_existe		:= 'N';
	End;
  --
	IF G_rib_existe = 'N'
		THEN
		--
		--*msg debut
		G_niv_msg	:= 2;
		G_msg_adm	:= 'Le RIB du decaismt n° '||to_char(G_decaismt_numdecaismt)
				||' destiné à '||G_decaismt_nombene||' n" est pas défini ';
		P_INS_journal;
		--*msg fin
		--
	ELSIF (G_nb_numgar > 1 and G_min_numgar != 0) Then
		--
		--*msg debut
		G_niv_msg	:= 2;
		G_msg_adm	:= 'Le decaismt n° '||to_char(G_decaismt_numdecaismt)
				||' concerne plusieurs contrats ';
		P_INS_journal;
		G_niv_msg	:= 2;
		G_msg_adm	:= 'Les références bancaires générales de ce bénéficiaire ne sont pas définies';
		P_INS_journal;
		--*msg fin
		--
	ELSE
		--
		G_vire_detail_ins	:= 'O';
		--
		--*debogage debut
		G_niv_msg	:= 3;
		G_msg_adm	:= 'ins remise_vire_detail decaismt n° '||to_char(G_decaismt_numdecaismt)
				||' - '||'G_idrib n° '||to_char(G_idrib);
		P_INS_journal;
		--*debogage fin
		--
		INSERT INTO remise_vire_detail
				(
				numremise,
				numcpte,
				numvirement,
				numdecaismt,
				montant,
				codbque,
				guichet,
				compte,
				clerib,
				intitule,
				clef_iban,
				bban,
				bic,
				codpays
				)
		--
			VALUES	(
				G_numremise,
				G_numcpte,
				0,
				G_decaismt_numdecaismt,
				G_decaismt_montant,
				G_rib_codbque,
				G_rib_guichet,
				G_rib_compte,
				G_rib_clerib,
				G_rib_intitule,
				G_rib_clef_iban,
				G_rib_bban,
				G_rib_bic,
				G_rib_codpays
				)
				;
		--
	END IF;
   END IF;
END LOOP;
CLOSE C_sel_decaismt;
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
