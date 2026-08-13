CREATE OR REPLACE PACKAGE ARTHUS.pk_rg10b AS
--
PROCEDURE P_rg10b(
					I_datebutoir_deb	IN	VARCHAR2	Default NULL,
					I_datebutoir_fin	IN	VARCHAR2	Default NULL,
					I_numbene			IN	VARCHAR2	Default NULL,
					I_session			IN	NUMBER		Default 1,
					I_niv_msg			IN	NUMBER		Default 1,
					I_pause				IN	NUMBER		Default 0,
					O_found				OUT	NUMBER,
					O_erreur			OUT	VARCHAR2
				);
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_rg10b AS
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
PROCEDURE P_Traitement_principal;
--
PROCEDURE P_sel_dates;
--
PROCEDURE P_entete_select_dedu;
--
PROCEDURE P_select_numdec;
--
PROCEDURE P_corps_select_dedu;
--
PROCEDURE P_pied_select_dedu;
--
PROCEDURE P_upd_histo_dedu;
--
PROCEDURE P_insert_dcptdedu;
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
--
-- Declaration des variables
--
G_trait_entete  		VARCHAR2(1);
--
-- Paramètres en entrée
G_datebutoir_deb		VARCHAR2(11);
G_datebutoir_fin		VARCHAR2(11);
G_numbene				Number(10);
--
G_type					Number(3);
G_old_type				Number(3);
G_numdecaismt			Number(10);
G_numdec				Number(10);
G_numgar				Number(10);
G_numcli				Number(10);
G_montant				Number(12,2);
G_montant_total			Number(12,2);
G_pre_idsoc				Number(3);
G_pre_idpmtint			Number(9);
G_idsoc					Number(3);
G_idcompte				Number(3);
G_modpmt				Number(3);
G_idpmtint				Number(9);
G_idcalcul				Number(9);
-- G_numutil				Number(9);
G_codope_dedu			Number(9);
G_codope_prev			Number(9);
G_dcpt_numdec			Number(10);
G_old_dcpt_numdec		Number(10);
G_monnaie				Number(3);
G_old_monnaie			Number(3);
G_val_debut				DATE;
G_val_fin				DATE;

--
-- Flag de commit ou rollback a retourner a Forms
G_commit			Boolean := FALSE;
G_rollback			Boolean := FALSE;
G_auto_valide		Boolean := FALSE;
--
G_flag_test			NUMBER;
G_proc				VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_rg10b';
G_msg_adm			journal_adm.msg_adm%TYPE;
G_session			journal_adm.id_session%TYPE default 1;
G_niv_msg			journal_adm.niv_msg%TYPE := 1;
G_max_msg			journal_adm.niv_msg%TYPE := 1;
G_idligne			journal_adm.idligne%TYPE := 0;
G_erreur			journal_adm.msg_adm%TYPE;

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
--
CURSOR C_select_dedu IS
	Select	sum(round( (((histo_jours.fin-histo_jours.debut)+1) *
			 histo_dedu.montant), 2 )) montant,
		grnts.numinterm idsoc,
		decaismt.monnaie monnaie,
		decompte_prev.numdec dcpt_numdec,
		histo_dedu.typdedu type
	From	histo_dedu,
		histo_jours,
		histo_calcul,
		decompte_prev,
		affectation,
		decaismt,
		adhe_cntrt,
		grnts
	WHERE histo_dedu.idhisto=histo_jours.idhisto
	AND histo_jours.idcalcul=histo_calcul.idcalcul
	AND histo_calcul.numdec=decompte_prev.numdec
	AND decompte_prev.numdec=affectation.numaffec
	AND affectation.codope=2
	AND affectation.numdecaismt=decaismt.numdecaismt
	AND decaismt.flagpay=1
	AND histo_dedu.numdec=0
	AND grnts.numgar=adhe_cntrt.numgar
	AND adhe_cntrt.idadhesion=decompte_prev.idadhesion
	AND	decaismt.datpay <= G_val_debut
	AND	histo_dedu.typdedu>0
	GROUP BY grnts.numinterm,
		decaismt.monnaie,
		decompte_prev.numdec,
		histo_dedu.typdedu
	UNION
	Select	-sum(round( (((histo_jours.fin-histo_jours.debut)+1) *
			 histo_dedu.montant), 2 )) montant,
		grnts.numinterm idsoc,
		encaismt.monnaie monnaie,
		decompte_prev.numdec dcpt_numdec,
		histo_dedu.typdedu type
	From	histo_dedu,
		histo_jours,
		histo_calcul,
		decompte_prev,
		affectation,
		encaismt,
		compte_client,
		adhe_cntrt,
		grnts
	WHERE histo_dedu.idhisto=histo_jours.idhisto
	AND histo_jours.idcalcul=histo_calcul.idcalcul
	AND histo_calcul.numdec=decompte_prev.numdec
	AND decompte_prev.numdec=compte_client.numfact
	AND decompte_prev.numdec=affectation.numaffec
	AND compte_client.numencaismt=encaismt.numencaismt
	AND affectation.codope=2
	AND compte_client.codope=2
	AND histo_dedu.numdec!=0
	AND grnts.numgar=adhe_cntrt.numgar
	AND adhe_cntrt.idadhesion=decompte_prev.idadhesion
	and	compte_client.datope <= G_val_debut
	AND	histo_dedu.typdedu>0
	GROUP BY grnts.numinterm,
		encaismt.monnaie,
		decompte_prev.numdec,
		histo_dedu.typdedu
	ORDER BY 2,3,5,4
	;
--
------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_rg10b(
					I_datebutoir_deb	IN	VARCHAR2	Default NULL,
					I_datebutoir_fin	IN	VARCHAR2	Default NULL,
					I_numbene			IN	VARCHAR2	Default NULL,
					I_session			IN	NUMBER		Default 1,
					I_niv_msg			IN	NUMBER		Default 1,
					I_pause				IN	NUMBER		Default 0,
					O_found				OUT	NUMBER,
					O_erreur			OUT	VARCHAR2
				)
IS
R_select_dedu 	C_select_dedu%ROWTYPE;
BEGIN
	--
	O_found         := 1;
	G_erreur        := Null;
	--
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--
	G_datebutoir_deb	:= I_datebutoir_deb;
	G_datebutoir_fin	:= I_datebutoir_fin;
	--
	G_numbene := I_numbene;
	--
	G_niv_msg	:= 3;
	G_msg_adm	:= 'Acces p_rg10b';
	P_INS_journal;
--
	-- Initialisation de valeurs
	G_numdec := 1;
	G_codope_dedu := 11;
	G_codope_prev := 2;
	/* VCR 04/01/2007
	Variable G_montant_total initialisée à 0 pour éviter l'erreur Oracle :
	ORA - 1400 : impossible d'insérer NULL dans DCPTDEDU.MONTANT
	Erreur procédure p_insert_dcptdedu */
	G_montant_total := 0;
	-- Formatage des dates
	P_sel_dates;
--
	-- OUVERTURE du Curseur
	--
	IF NOT C_select_dedu%ISOPEN
   	   THEN
---------
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_deb_trt_1';
		P_INS_journal;
---------
		P_debut_traitement;
---------
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_deb_trt_2';
		P_INS_journal;
---------
	END IF;
	--
	-- LECTURE D'1 Ligne dans la table principale
	--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'Avant fetch';
		P_INS_journal;
---------
	LOOP
	FETCH C_select_dedu INTO R_select_dedu;
	EXIT WHEN C_select_dedu%NOTFOUND;
		--
		G_montant		:= R_select_dedu.montant;
		--
		G_idsoc			:= R_select_dedu.idsoc;
		--
		G_monnaie		:= R_select_dedu.monnaie;
		--
		G_dcpt_numdec	:= R_select_dedu.dcpt_numdec;
		--
		G_type			:= R_select_dedu.type;
		--
		-- Corps du traitement
		--
		P_Traitement_principal;
		--
	END LOOP;
    --
	IF (C_select_dedu%ROWCOUNT > 0) THEN
		-- Donnée trouvée
		G_niv_msg	:= 3;
		G_msg_adm	:= 'Jalon 1 - donnée trouvée';
		P_INS_journal;
		--
		O_found	:= 1;
		--
	ElSE
		--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'Jalon 0 - aucune donnée trouvée';
		P_INS_journal;
		--
		O_found	:= 0;
		--
	END IF;
	--
	P_fin_traitement;
	--
	O_erreur	:= G_erreur;
	--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_RG10B - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
		-- FERMETURE du Curseur
		IF C_select_dedu%ISOPEN THEN
			CLOSE C_select_dedu;
		End IF;
END;
--
-- -----------------------------
PROCEDURE P_Traitement_principal
IS
BEGIN
--
G_proc := 'P_Traitement_principal';
--
	G_niv_msg	:= 3;
	G_msg_adm	:= 'P_Traitement_principal';
	P_INS_journal;
--
	IF G_trait_entete IS NULL
	   THEN
---------
		/*G_niv_msg	:= 3;
		G_msg_adm	:= 'Jalon 2a';
		P_INS_journal;*/
---------
		--
  		P_entete_select_dedu;
		--
		G_trait_entete     := '1';
		--
	END IF;
---------
		/*G_niv_msg	:= 3;
		G_msg_adm	:= 'Jalon 2b';
		P_INS_journal;*/
---------
		P_corps_select_dedu;
--
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
		-- FERMETURE du Curseur
		IF C_select_dedu%ISOPEN THEN
			CLOSE C_select_dedu;
		End IF;
--
END P_Traitement_principal;
--
-- ----------------------
PROCEDURE P_sel_dates
IS
BEGIN
--
G_proc := 'P_sel_dates';
--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_sel_dates';
		P_INS_journal;
--
		Select	e2d(G_datebutoir_deb), e2d(G_datebutoir_fin)
		Into	G_val_debut, G_val_fin
		From	Dual;
--
Exception
		When Others then
		        G_niv_msg := 0;
		        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
		        P_INS_journal;
		        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
		        G_erreur := G_msg_adm;
		        P_INS_journal;
				-- FERMETURE du Curseur
				IF C_select_dedu%ISOPEN THEN
					CLOSE C_select_dedu;
				End IF;
--
END P_sel_dates;
--
-- ---------------------
--
PROCEDURE P_entete_select_dedu
IS
BEGIN
--
G_proc := 'P_entete_select_dedu';
--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_entete_select_dedu';
		P_INS_journal;
--
		G_pre_idsoc	:= G_idsoc;
		--
		G_old_type	:= G_type;
		--
		G_old_dcpt_numdec := G_dcpt_numdec;
		--
		G_old_monnaie := G_monnaie;
		--
		-- select_numdec
		P_select_numdec;
--
Exception
		When Others then
		        G_niv_msg := 0;
		        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
		        P_INS_journal;
		        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
		        G_erreur := G_msg_adm;
		        P_INS_journal;
				-- FERMETURE du Curseur
				IF C_select_dedu%ISOPEN THEN
					CLOSE C_select_dedu;
				End IF;
--
END P_entete_select_dedu;
--
-- ---------------------
--
PROCEDURE P_select_numdec
IS
BEGIN
--
G_proc := 'P_select_numdec';
--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_select_numdec';
		P_INS_journal;
--
		SELECT	max(nvl(numdec,0)) + 1
		INTO	G_numdec
		FROM	dcptdedu;
--
Exception
		When Others then
		        G_niv_msg := 0;
		        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
		        P_INS_journal;
		        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
		        G_erreur := G_msg_adm;
		        P_INS_journal;
				-- FERMETURE du Curseur
				IF C_select_dedu%ISOPEN THEN
					CLOSE C_select_dedu;
				End IF;
--
END P_select_numdec;
--
-- ---------------------
--
PROCEDURE P_corps_select_dedu
IS
BEGIN
--
G_proc := 'P_corps_select_dedu';
--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_corps_select_dedu';
		P_INS_journal;
--
If (( G_idsoc != G_pre_idsoc ) OR ( G_old_monnaie != G_monnaie ) OR ( G_old_type != G_type ))
	then
		P_pied_select_dedu;
		--
		P_select_numdec;
End if;
--
		G_montant_total := G_montant_total + G_montant;
		--
		P_upd_histo_dedu;
--
Exception
		When Others then
		        G_niv_msg := 0;
		        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
		        P_INS_journal;
		        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
		        G_erreur := G_msg_adm;
		        P_INS_journal;
				-- FERMETURE du Curseur
				IF C_select_dedu%ISOPEN THEN
					CLOSE C_select_dedu;
				End IF;
--
END P_corps_select_dedu;
--
-- ---------------------
--
PROCEDURE P_pied_select_dedu
IS
BEGIN
--
G_proc := 'P_pied_select_dedu';
--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_pied_select_dedu';
		P_INS_journal;
--
		P_insert_dcptdedu;
--

		G_montant_total		:= 0;
		G_pre_idsoc 		:= G_idsoc;
		G_old_type 			:= G_type;
		G_old_dcpt_numdec 	:= G_dcpt_numdec;
		G_old_monnaie 		:= G_monnaie;
--
Exception
		When Others then
		        G_niv_msg := 0;
		        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
		        P_INS_journal;
		        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
		        G_erreur := G_msg_adm;
		        P_INS_journal;
				-- FERMETURE du Curseur
				IF C_select_dedu%ISOPEN THEN
					CLOSE C_select_dedu;
				End IF;
--
END P_pied_select_dedu;
--
-- ---------------------
--
PROCEDURE P_upd_histo_dedu
IS
BEGIN
--
G_proc := 'P_upd_histo_dedu';
--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_upd_histo_dedu';
		P_INS_journal;
--
		UPDATE histo_dedu
		SET numdec=nvl(G_numdec,1)
		WHERE idhisto in (select histo_jours.idhisto
							from histo_jours,histo_calcul
							where histo_jours.idcalcul=histo_calcul.idcalcul
							and histo_calcul.numdec=G_dcpt_numdec)
		AND typdedu=G_type;
--
Exception
		When Others then
		        G_niv_msg := 0;
		        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
		        P_INS_journal;
		        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
		        G_erreur := G_msg_adm;
		        P_INS_journal;
				-- FERMETURE du Curseur
				IF C_select_dedu%ISOPEN THEN
					CLOSE C_select_dedu;
				End IF;
--
END P_upd_histo_dedu;
--
-- ---------------------
--
PROCEDURE P_insert_dcptdedu
IS
BEGIN
--
G_proc := 'P_insert_dcptdedu';
--
		G_niv_msg	:= 3;
		G_msg_adm	:= 'P_insert_dcptdedu';
		P_INS_journal;
--
		INSERT INTO dcptdedu
			(numdec,
			creation,
			debut,
			fin,
			numsoc,
			montant,
			typdedu,
			numbene,
			valide
			)
		SELECT
			nvl(G_numdec,1),
			trunc(sysdate),
			G_val_debut,
			G_val_debut,
			G_pre_idsoc,
			G_montant_total,
			G_old_type,
			G_numbene,
			'N'
		FROM dual;
--
Exception
		When Others then
		        G_niv_msg := 0;
		        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
		        P_INS_journal;
		        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
		        G_erreur := G_msg_adm;
		        P_INS_journal;
				-- FERMETURE du Curseur
				IF C_select_dedu%ISOPEN THEN
					CLOSE C_select_dedu;
				End IF;
--
END P_insert_dcptdedu;
--
-- ----------------------------------------------------------------------------------------
--
-- DEBUT ET FIN DU TRAITEMENT
--
-- ----------------------------------------------------------------------------------------
PROCEDURE P_debut_traitement
IS
BEGIN
--
	G_proc := 'P_debut_traitement';
--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Debut de traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
	OPEN C_select_dedu;
	--
	G_trait_entete	:= NULL;
--
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
		-- FERMETURE du Curseur
		IF C_select_dedu%ISOPEN THEN
			CLOSE C_select_dedu;
		End IF;
--
END P_debut_traitement;
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
  		P_pied_select_dedu;
	END IF;
--
	-- FERMETURE du Curseur
	CLOSE C_select_dedu;
	--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Fin Normale du traitement le '||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
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
		-- FERMETURE du Curseur
		IF C_select_dedu%ISOPEN THEN
			CLOSE C_select_dedu;
		End IF;
--
END P_fin_traitement;
--
----------------------- Fin des procedures publiques ------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
Procedure P_INS_journal
IS
L_idligne	Number;
BEGIN
--
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
--
END P_INS_journal;
---------------- Fin des corps des procedures privees --
END;
/
