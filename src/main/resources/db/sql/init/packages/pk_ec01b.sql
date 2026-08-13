CREATE OR REPLACE PACKAGE ARTHUS.pk_ec01b AS
--
PROCEDURE P_ec01b(
			I_deb_numsoc IN vs_grnts.numinterm%type default NULL,
			I_fin_numsoc IN vs_grnts.numinterm%type default NULL,
			I_deb_numorg IN vs_grnts.numorg%type default NULL,
			I_fin_numorg IN vs_grnts.numorg%type default NULL,
			I_deb_refcie IN vs_grnts.refcie_chapeau%type default NULL,
			I_fin_refcie IN vs_grnts.refcie_chapeau%type default NULL,
			I_deb_numgar IN vs_grnts.numgar%type default NULL,
			I_fin_numgar IN vs_grnts.numgar%type default NULL,
			I_deb_datbut IN date default NULL,
			I_fin_datbut IN date default NULL,
			I_param1	 IN NUMBER			default 0,
		 	I_session	 IN	NUMBER			Default 1,
		 	I_niv_msg	 IN	NUMBER			Default 1,
		 	I_pause		 IN	NUMBER			Default 0,
		 	O_found		 OUT	NUMBER,
		 	O_erreur	 OUT	VARCHAR2
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_ec01b AS
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
PROCEDURE P_corps_traitement;
--
PROCEDURE P_entete_traitement;
--
PROCEDURE P_pied_montant;
--
PROCEDURE P_next_numbdx;
--
PROCEDURE P_insert_remise_EC;
--
PROCEDURE P_update_ECART_PIECE;
--
PROCEDURE P_INS_journal;
--
PROCEDURE P_fin_traitement;
--
-- ----------------------------- Fin des declarations des procedures privees --

-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
-- Aucune
-- ---------------------------------- Fin des corps des procedures publiques --
--
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --

-- Variables globales privées
--
G_numdcptcie 	NUMBER := 1;
G_numbdx        NUMBER :=1;
G_codope_cie 	NUMBER := 12;
G_codope_mala 	NUMBER := 1;
G_codope_prev 	NUMBER := 2;
--
-- parametres du traitement
G_numsoc_deb	vs_grnts.numinterm%type;
G_numsoc_fin	vs_grnts.numinterm%type;
G_numorg_deb	vs_grnts.numorg%type;
G_numorg_fin	vs_grnts.numorg%type;
G_refcie_deb	vs_grnts.refcie_chapeau%type;
G_refcie_fin	vs_grnts.refcie_chapeau%type;
G_numgar_deb	vs_grnts.numgar%type;
G_numgar_fin	vs_grnts.numgar%type;
--G_datbut_deb 	compte_client.datope%type;
--G_datbut_fin 	compte_client.datope%type;
G_date_butoir 	compte_client.datope%type;
G_param1	 	NUMBER;


-- variables traitement
G_INIT			Boolean := FALSE;
G_societe  	 	vs_grnts.numinterm%type;
G_garantie		v_assur_delegat.numfor%type;
G_ass_contrat   vs_grnts.numorg%type;
G_ass_garantie  v_assur_delegat.numass%type;
G_decompte   	dcpt.numdec%type;
G_montant  	 	dcpt.montant%type;
G_monnaie		dcpt.monnaie%type;
G_montant_d  	dcpt.montant_d%type;
G_monnaie_d		dcpt.monnaie_d%type;
G_mnt_total 	dcpt.montant%type;
G_mnt_tot_d 	dcpt.montant%type;
G_pre_numsoc   	vs_grnts.numinterm%type;
G_pre_gar		v_assur_delegat.numfor%type;
G_pre_numass   	v_assur_delegat.numass%type;
G_pre_decompte  dcpt.numdec%type;
G_pre_monnaie   dcpt.monnaie%type;
--G_pre_mon_dev   dcpt.monnaie_d%type;
G_numutil		utilisateurs.numutil%type := f_numutil;
G_numpiece      ECART_PIECE.numpiece%type;
--
-- Flag de commit ou rollback a retourner a Forms
G_commit		Boolean := FALSE;
G_rollback		Boolean := FALSE;
G_auto_valide	Boolean := FALSE;
--
G_flag_test		NUMBER;
G_proc			VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%Type default 'pk_gdp8b';
G_msg_adm		journal_adm.msg_adm%Type;
G_session		journal_adm.id_session%Type default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%Type;
G_rowcount		number := 0;
G_sens          ECART_PIECE.sens_ecart%type default 1;
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
-- CTT 31/03/2005

------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_ec01b(
			I_deb_numsoc IN vs_grnts.numinterm%type default NULL,
			I_fin_numsoc IN vs_grnts.numinterm%type default NULL,
			I_deb_numorg IN vs_grnts.numorg%type default NULL,
			I_fin_numorg IN vs_grnts.numorg%type default NULL,
			I_deb_refcie IN vs_grnts.refcie_chapeau%type default NULL,
			I_fin_refcie IN vs_grnts.refcie_chapeau%type default NULL,
			I_deb_numgar IN vs_grnts.numgar%type default NULL,
			I_fin_numgar IN vs_grnts.numgar%type default NULL,
			I_deb_datbut IN date default NULL,
			I_fin_datbut IN date default NULL,
			I_param1	 IN NUMBER			default 0,
		 	I_session	 IN	NUMBER			Default 1,
		 	I_niv_msg	 IN	NUMBER			Default 1,
		 	I_pause		 IN	NUMBER			Default 0,
		 	O_found	OUT	NUMBER,
		 	O_erreur	OUT	VARCHAR2
		)
IS
CURSOR C_sel_dcpt is
	SELECT	vs_grnts.numinterm 				societe,
			f_assureur_ct(sinistre.numfor)	ass_contrat,
			dcpt.numdec						decompte,
			f_assureur(sinistre.numfor)		ass_garantie,
			sinistre.numfor					garantie,
			ECART_PIECE.montant				montant,
			ECART_PIECE.monnaie				monnaie,
			ECART_PIECE.numpiece			numpiece
	FROM				dcpt,
			decaismt	decaismt_prest,
			affectation	affectation_prest,
						vs_grnts,
						sinistre, ECART_PIECE, pers_organisme
	where	dcpt.numgar	= vs_grnts.numgar
	and		dcpt.numdec = affectation_prest.numaffec
	and		affectation_prest.codope 	= G_codope_mala
	and		decaismt_prest.numdecaismt 	= affectation_prest.numdecaismt
	and		decaismt_prest.codope 		= G_codope_mala
	and		decaismt_prest.flagpay+0	= 1
	and		vs_grnts.numinterm
			between nvl(G_numsoc_deb,vs_grnts.numinterm)
			and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
	and		vs_grnts.refcie_chapeau||'-'
			between nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')
			and	nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
	and		vs_grnts.numgar
			between nvl(G_numgar_deb,vs_grnts.numgar)
			and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
	and		trunc(decaismt_prest.datpay) <= G_date_butoir
	and 	sinistre.NUMDEC 	= dcpt.numdec
	AND     SINISTRE.NUMSIN=ECART_PIECE.NUMPIECE
	AND     ECART_PIECE.CODOPE=1
	and 	ECART_PIECE.numbdx =0
	and 	f_assureur_ct(sinistre.numfor)
			between nvl(G_numorg_deb,f_assureur_ct(sinistre.numfor))
			and nvl(G_numorg_fin,nvl(G_numorg_deb,f_assureur_ct(sinistre.numfor)))
	and		G_param1=1
	and     f_assureur_ct(sinistre.numfor)=pers_organisme.numindiv
	and     pers_organisme.remb_prest=1
UNION all
	SELECT	vs_grnts.numinterm 					societe,
			f_assureur_ct(sinistre.numfor)		ass_contrat,
			dcpt.numdec							decompte,
			f_assureur(sinistre.numfor)			ass_garantie,
			sinistre.numfor						garantie,
			-ECART_PIECE.montant				montant,
			ECART_PIECE.monnaie					monnaie,
			ECART_PIECE.numpiece				numpiece
	FROM	decompte_annul		dcpt,
			decaismt			decaismt_prest,
			affectation_annul	affectation_prest,
								vs_grnts,
								sinistre, ECART_PIECE, pers_organisme
	where	dcpt.numgar		= vs_grnts.numgar
	and		dcpt.numdec     = affectation_prest.numaffec
	and		affectation_prest.codope 	= G_codope_mala
	and		decaismt_prest.numdecaismt 	= affectation_prest.numdecaismt
	and		decaismt_prest.codope 		= 9
	and		decaismt_prest.flagpay+0	= 1
	and		vs_grnts.numinterm
			between nvl(G_numsoc_deb,vs_grnts.numinterm)
			and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
	and		vs_grnts.refcie_chapeau||'-'
			between	nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')
			and nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
	and		vs_grnts.numgar
			between nvl(G_numgar_deb,vs_grnts.numgar)
			and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
	and 	sinistre.NUMDEC 	= dcpt.numdec
	AND     SINISTRE.NUMSIN=ECART_PIECE.NUMPIECE
	AND     ECART_PIECE.CODOPE=1
	and 	ECART_PIECE.numbdx =0
	and 	f_assureur_ct(sinistre.numfor)
			between nvl(G_numorg_deb,f_assureur_ct(sinistre.numfor))
			and nvl(G_numorg_fin,nvl(G_numorg_deb,f_assureur_ct(sinistre.numfor)))
	and		G_param1=1
	and     f_assureur_ct(sinistre.numfor)=pers_organisme.numindiv
	and     pers_organisme.remb_prest=1
UNION all
	SELECT	distinct
			vs_grnts.numinterm					societe,
			f_assureur_ct(sinistre.numfor)     	ass_contrat,
			dcpt.numdec              			decompte,
			f_assureur(sinistre.numfor)			ass_garantie,
			sinistre.numfor						garantie,
			-ECART_PIECE.montant  		        montant,
			ECART_PIECE.monnaie     			monnaie,
			ECART_PIECE.numpiece				numpiece
	FROM					dcpt,
							compte_client,
			affectation		affectation_prest,
							vs_grnts,
							sinistre, ECART_PIECE, pers_organisme
	where	dcpt.numgar	= vs_grnts.numgar
	and		dcpt.numdec     = affectation_prest.numaffec
	and		compte_client.numfact = affectation_prest.numaffec
	and		compte_client.codope = G_codope_mala
	and		affectation_prest.codope = G_codope_mala
	and		vs_grnts.numinterm
			between nvl(G_numsoc_deb,vs_grnts.numinterm)
			and nvl(G_numsoc_fin,nvl(G_numsoc_deb,vs_grnts.numinterm))
	and		vs_grnts.numorg
			between nvl(G_numorg_deb,vs_grnts.numorg)
			and nvl(G_numorg_fin,nvl(G_numorg_deb,vs_grnts.numorg))
	and		vs_grnts.refcie_chapeau||'-'
			between	nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-')
			and	nvl(G_refcie_fin,nvl(G_refcie_deb,vs_grnts.refcie_chapeau||'-'))
	and		vs_grnts.numgar
			between nvl(G_numgar_deb,vs_grnts.numgar)
			and nvl(G_numgar_fin,nvl(G_numgar_deb,vs_grnts.numgar))
	and		trunc(compte_client.datope)<= G_date_butoir
	and 	sinistre.NUMDEC 	= dcpt.numdec
	AND     SINISTRE.NUMSIN=ECART_PIECE.NUMPIECE
	AND     ECART_PIECE.CODOPE=1
	and 	ECART_PIECE.numbdx =0
	and 	f_assureur_ct(sinistre.numfor)
			between nvl(G_numorg_deb,f_assureur_ct(sinistre.numfor))
			and nvl(G_numorg_fin,nvl(G_numorg_deb,f_assureur_ct(sinistre.numfor)))
	and		G_param1=1
	and     f_assureur_ct(sinistre.numfor)=pers_organisme.numindiv
	and     pers_organisme.remb_prest=1
	ORDER
	   BY	1,2,7;
--
R_sel_dcpt 	C_sel_dcpt%ROWTYPE;

BEGIN
	--
	G_rowcount  := 0;
	O_found		:= 1;
	G_erreur	:= Null;
	--
	G_numsoc_deb    :=  I_deb_numsoc;
	G_numsoc_fin    :=  I_fin_numsoc;
	G_numorg_deb    :=  I_deb_numorg;
	G_numorg_fin    :=  I_fin_numorg;
	G_refcie_deb    :=  I_deb_refcie;
	G_refcie_fin    :=  I_fin_refcie;
	G_numgar_deb    :=  I_deb_numgar;
	G_numgar_fin    :=  I_fin_numgar;
--	G_datbut_deb    :=  NVL(I_deb_datbut, Sysdate);
--	G_datbut_fin    :=  NVL(I_fin_datbut, NVL(I_deb_datbut, Sysdate));
	G_date_butoir 	:=  NVL(I_fin_datbut, NVL(I_deb_datbut, Sysdate));
	G_param1		:=  I_param1;
	--
	G_max_msg		:= I_niv_msg;
	G_session		:= I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);
	G_niv_msg		:= 1;
	G_msg_adm		:= 'Debut de traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	G_msg_adm		:= 'Paramètres < '||TO_CHAR(G_numsoc_deb)||'>< '||to_char(G_numorg_deb)||'>< '||to_char(G_refcie_deb)||'>< '||to_char(G_numgar_deb)||'>< '||to_char(I_deb_datbut)||'>< '||to_char(I_fin_datbut)||'>';
	P_INS_journal;
	--
	FOR R_sel_dcpt in C_sel_dcpt LOOP
	--
		G_rowcount		:= C_sel_dcpt%ROWCOUNT;
		G_societe    	:= R_sel_dcpt.societe;
		G_ass_contrat   := R_sel_dcpt.ass_contrat;
		G_decompte  	:= R_sel_dcpt.decompte;
		G_ass_garantie  := R_sel_dcpt.ass_garantie;
		G_garantie      := R_sel_dcpt.garantie;
		G_montant   	:= R_sel_dcpt.montant;
		G_monnaie   	:= R_sel_dcpt.monnaie;
		G_montant_d   	:= R_sel_dcpt.montant;
		G_monnaie_d   	:= R_sel_dcpt.monnaie;
		G_numpiece      := R_sel_dcpt.numpiece;

		IF G_INIT = FALSE then
				G_INIT  := TRUE;
				P_entete_traitement;
		END IF;
	-- 	Détail du traitement
		P_corps_traitement;
		G_mnt_total := G_mnt_total + G_montant;
--		G_mnt_tot_d := G_mnt_tot_d + G_montant_d;
	--
	--
	END LOOP;
	--
    if G_rowcount>0 then
		P_fin_traitement;

	else
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Rowcount <'||TO_CHAR(G_rowcount)||'>';
	P_INS_journal;
	G_msg_adm	:= 'Aucun bordereau créé.';
	P_INS_journal;
	G_msg_adm	:= 'Fin Normale du traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;


	end if;
	O_erreur	:= G_erreur;
	--
	EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'pk_ec01b - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
END;
--
Procedure P_corps_traitement
IS
BEGIN
--
G_niv_msg	:= 1;
/* CTT 26/04/2005 : La demande de remboursement est basée sur société et assureur de la garantie */
G_msg_adm	:= 'montant <'||TO_CHAR(G_montant)||'> Totaux <'||to_char(G_mnt_total)||'><'||to_char(G_mnt_tot_d)||'>';
--P_INS_journal;
--
    IF G_societe <> G_pre_numsoc then
--	G_msg_adm	:= 'Rupture societe <'||TO_CHAR(G_societe)||'><'||to_char(G_pre_numsoc)||'>';
--	P_INS_journal;
			P_pied_montant;
			P_update_ECART_PIECE;
			G_pre_numsoc	:= G_societe;
	elsif  G_ass_contrat <> G_pre_numass then
--	G_msg_adm	:= 'Rupture assureur garantie <'||TO_CHAR(G_ass_garantie)||'><'||to_char(G_pre_numass)||' < montant <'||TO_CHAR(G_montant)||'> Totaux <'||to_char(G_mnt_total)||'>';
--	P_INS_journal;

			P_pied_montant;
			P_update_ECART_PIECE;
			G_pre_numass	:= G_ass_contrat;
	elsif G_monnaie <> G_pre_monnaie then
--	G_msg_adm	:= 'Rupture monnaie <'||TO_CHAR(G_ass_garantie)||'><'||to_char(G_pre_numass)||' < montant <'||TO_CHAR(G_montant)||'> Totaux <'||to_char(G_mnt_total)||'>';
--	P_INS_journal;

			P_pied_montant;
			P_update_ECART_PIECE;
			G_pre_monnaie	:= G_monnaie;

	else

	    P_update_ECART_PIECE;

	END IF;

--
END P_corps_traitement;
--
PROCEDURE P_pied_montant
IS
BEGIN
--P_INS_journal;
--G_msg_adm	:= 'ecriture dcptcie <'||TO_CHAR(G_pre_numsoc)||'><'||to_char(G_pre_numass)||'><'||to_char(G_mnt_total)||'><'||to_char(G_monnaie)||'><'||to_char(G_mnt_tot_d)||'><'||to_char(G_monnaie_d)||'>';
--P_INS_journal;
	--IF G_mnt_total > 0 then
		P_insert_remise_EC;
		P_next_numbdx;
	--end if;
--
	G_mnt_total		:= 0;
--	G_mnt_tot_d		:= 0;
--	G_pre_monnaie	:= G_monnaie;
--	G_pre_mon_dev	:= G_monnaie_d;
END P_pied_montant;

--
PROCEDURE P_fin_traitement IS
BEGIN
--
G_proc := 'P_fin_traitement';
--G_msg_adm	:= 'Fin de traitement <'||TO_CHAR(G_pre_numass)||'><'||to_char(G_pre_gar)||'><'||to_char(G_numdcptcie)||'>';
--P_INS_journal;
--
	P_pied_montant;

--

	G_niv_msg	:= 1;
	G_msg_adm	:= 'Rowcount <'||TO_CHAR(G_rowcount)||'>';
	P_INS_journal;
	G_msg_adm	:= 'Fin Normale du traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
	G_INIT  := FALSE;
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
-------------------------------------------------------------------------------------------------------
--
PROCEDURE P_entete_traitement
IS
BEGIN
	G_pre_numsoc 	:= G_societe;
	G_pre_decompte  := G_decompte;
	G_pre_gar		:= G_garantie;
	G_pre_numass 	:= G_ass_contrat;
	G_pre_monnaie	:= G_monnaie;
--	G_pre_mon_dev	:= G_monnaie_d;
	G_mnt_total		:= 0;
--	G_mnt_tot_d		:= 0;
--
	P_next_numbdx;
END P_entete_traitement;

--
PROCEDURE P_next_numbdx
IS
BEGIN
	G_proc := 'select_numbdx';
	SELECT	nvl(max(numbdx) + 1,1)
	INTO	G_numbdx
	FROM	REMISE_EC;
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
END P_next_numbdx;
--
PROCEDURE P_insert_remise_EC
IS
BEGIN
	G_proc := 'insert_remise_ec';

	if G_mnt_total <0 then
		G_sens :=-1;
	else
		G_sens :=1;
	end if;

		INSERT INTO Remise_EC
					(codope,
					numbdx,
					sens,
					numsoc,
					numassureur,
					date_deb,
					date_fin,
					montant,
                    monnaie,
					numutil_crea,
					date_crea,
					numutil_valide,
                    valide,
					date_valide
					)
				SELECT
					1,
					G_numbdx,
					G_sens,
					G_pre_numsoc,
					G_pre_numass,
					G_date_butoir,
					G_date_butoir,
					G_mnt_total,
                    G_pre_monnaie,
					G_numutil,
					sysdate,
					null,
                    'N',
					null
				FROM DUAL;



Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
END P_insert_remise_EC;

--
PROCEDURE P_update_ECART_PIECE
IS
BEGIN
	G_proc := 'update_ecart_piece';
	UPDATE	ECART_PIECE
	SET	numbdx = nvl(G_numbdx,1)
	WHERE	ECART_PIECE.NUMPIECE = G_numpiece
	AND     ECART_PIECE.CODOPE=1;

Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
END P_update_ECART_PIECE;
--
-------------------------------------------------------------------------------------------------------
----------------------- Fin des procedures publiques ------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
PROCEDURE P_INS_journal
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
--
---------------- Fin des corps des procedures privees --
--
END;
/
