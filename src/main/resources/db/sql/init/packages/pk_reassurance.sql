CREATE OR REPLACE PACKAGE ARTHUS.pk_reassurance AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --
-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --
-- -- TYPES PUBLIQUES ---------------------------------------------------------
Type t_number is table of number index by binary_integer;
-- ------------------------------------------------- Fin des types publiques --
-- -- VARIABLES PUBLIQUES -----------------------------------------------------
/* Parametres du traitement */
G_deb_eche	Date;
G_fin_eche	Date;
G_deb_numsoc	societe.numsoc%Type;
G_fin_numsoc	societe.numsoc%Type;
G_deb_numreass	traite.numreass%Type;
G_fin_numreass	traite.numreass%Type;
G_deb_numtr	traite.numtr%Type;
G_fin_numtr	traite.numtr%Type;
G_deb_typtr	traite.typtr%Type;
G_fin_typtr	traite.typtr%Type;
/* Variables en cours de traitement */
G_cur_numtr	traite.numtr%Type;
G_der_numtr	traite.numtr%Type := -1;
G_cur_numav	avenant.numav%Type;
G_der_numav	avenant.numav%Type := -1;
G_cur_fract	param_traite.fract%Type;
G_niveau_appel param_traite.typequit%Type;
G_nature_montant param_traite.nat_data%Type;
G_cur_debut	Date; -- Debut periode de calcul
G_cur_fin	Date; -- Fin periode de calcul
G_cur_numgar	avnt_cntrt_gart.numgar%Type;
G_cur_numfor	avnt_cntrt_gart.numfor%Type;
G_cur_datapli	cntrt_trait.debut%Type;
G_cur_datper	cntrt_trait.fin%Type;
-- @global
G_domaine	result_reass_detail.type_cle%Type := -1;
G_cle		result_reass_detail.cle%Type;
G_exercice	result_reass_detail.exercice%Type;
G_numindiv	result_reass_detail.numindiv%Type;
G_nregl		result_reass_detail.nregl%Type;
G_idglob	result_reass_detail.idglob%Type := -1;
G_montant_global result_reass.montant%Type := 0;
G_idadhesion	adhe_cntrt.idadhesion%Type;
G_dat_reass	Date;
G_tfc		frml_tfc_reass.tfc%Type;
G_type_tfc	frml_tfc_reass.type_tfc%Type;
-- Variables de Trace Servant au journal_adm
--
-- G_niv_msg prend 2 Valeurs 1 --> Message informatif(tout se passe bien)
--                           2 --> Message d'erreurs (Erreur ORACLE)
--
G_nom_traitement journal_adm.nom_traitement%TYPE;
G_msg_adm        journal_adm.msg_adm%TYPE;
G_session        journal_adm.id_session%TYPE;
G_niv_msg        journal_adm.niv_msg%TYPE;
G_idligne        journal_adm.idligne%TYPE := 0;
G_flag_test	Number;
--
-- --------------------------------------------- Fin des variables publiques --
-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--
-- Retourne les traites / avenants a traiter
--
Procedure P_SEL_traite (
		I_deb_eche	IN Date,
		I_fin_eche	IN Date,
		I_deb_numsoc	IN societe.numsoc%Type,
		I_fin_numsoc	IN societe.numsoc%Type,
		I_deb_numreass	IN traite.numreass%Type,
		I_fin_numreass	IN traite.numreass%Type,
		I_deb_numtr	IN traite.numtr%Type,
		I_fin_numtr	IN traite.numtr%Type,
		I_deb_typtr	IN traite.typtr%Type,
		I_fin_typtr	IN traite.typtr%Type,
		I_session	IN Number,
		I_flag_test	IN Number,
		O_idtraite	OUT avenant.numtr%Type,
		O_idavenant	OUT avenant.numav%Type,
		O_numavenant	OUT avenant.numero%Type
		);
--
-- Retourne les contrats / garanties a traiter
--
Procedure P_SEL_avenant (
		O_numgar	OUT avnt_cntrt_gart.numgar%Type,
		O_numfor	OUT avnt_cntrt_gart.numfor%Type,
		O_debut		OUT Number,
		O_fin		OUT Number,
		O_raise		OUT Number
		);
--
-- Retourne la formule a appliquer selon le domaine
--
Procedure P_SEL_frml (
		I_domaine	IN frml_reass.domaine%Type,
		O_idformule	OUT frml_reass.idformule%Type
		);
--
-- Retourne la formule de tfc a appliquer selon le domaine
--
Procedure P_SEL_frml_tfc (
		O_idformule_tfc	OUT frml_tfc_reass.idformule%Type,
		O_raise		OUT Number
		);
--
-- Traitement des cotisations
--
Procedure P_SEL_cotis (
		O_cle		OUT Number,
		O_numfor	OUT Number,
		O_numindiv	OUT Number,
		O_idadhesion	OUT Number,
		O_dat_reass	OUT Number,
		O_montant	OUT Number
		);
--
-- Traitement des prestations prevoyance
--
Procedure P_SEL_prevoyance (
		O_cle		OUT Number,
		O_numfor	OUT Number,
		O_numindiv	OUT Number,
		O_idadhesion	OUT Number,
		O_dat_reass	OUT Number,
		O_montant	OUT Number
		);
--
-- Traitement des prestations soins de sante
--
Procedure P_SEL_sante (
		O_cle		OUT Number,
		O_numfor	OUT Number,
		O_numindiv	OUT Number,
		O_idadhesion	OUT Number,
		O_dat_reass	OUT Number,
		O_montant	OUT Number
		);
--
-- Insertion lignes detail de resultat
--
Procedure P_INS_result_reass_detail (
		I_domaine	IN result_reass_detail.type_cle%Type,
		I_montant	IN result_reass_detail.montant%Type,
		O_montant_global OUT result_reass.montant%Type,
		O_flag_rupt	OUT Number
		);
--
-- Insertion lignes de chargement
--
Procedure P_INS_result_reass_tfc (
		I_montant	IN result_reass_tfc.montant%Type
		);
--
-- Mise a jour echeance de calcul
--
Procedure P_MAJ_echesuiv(
		I_idavenant	IN avenant.numav%Type
		);
--
-- Mise a jour echeance de calcul suite a annulation
--
Procedure P_DEL_result_reass (
		I_idglob	IN result_reass.idglob%Type,
		I_debut		IN result_reass.dtdebut%Type,
		I_fin		IN result_reass.dtfin%Type
		);
-- @
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_reassurance AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- -- CURSEURS PRIVES --------------------------------------------------------
--
-- Retourne les traites / avenants a traiter
--
Cursor C_SEL_traite IS
	Select	avenant.numtr,
		avenant.numav,
		avenant.numero,
		nvl(avenant.datfinav, G_fin_eche),
		nvl(avenant.procheche, avenant.dateffav) echesuiv
	From	traite,
		avenant
	Where	traite.numreass between nvl(G_deb_numreass, traite.numreass)
			and nvl( G_fin_numreass,
				nvl(G_deb_numreass, traite.numreass) )
	and	traite.typtr between nvl(G_deb_typtr, traite.typtr)
			and nvl( G_fin_typtr,
				nvl(G_deb_typtr, traite.typtr) )
	and	traite.numtr = avenant.numtr
	and	avenant.valideav = 'O'
	and	avenant.numtr between nvl(G_deb_numtr, avenant.numtr)
			and nvl( G_fin_numtr,
				nvl(G_deb_numtr, avenant.numtr) )
	and	nvl(avenant.datfinav, G_deb_eche) >= G_deb_eche
	and	nvl(avenant.procheche, avenant.dateffav)
			between G_deb_eche
			and nvl( G_fin_eche,
				nvl(avenant.procheche, avenant.dateffav) )
	Order by
		avenant.numtr
	;
--
-- Retourne les contrats / garanties a traiter pour l'avenant en cours
--
-- # Rajouter la selection sur numsoc
Cursor C_SEL_avenant IS
	Select	avnt_cntrt_gart.numgar,
		avnt_cntrt_gart.numfor,
		cntrt_trait.debut,
		cntrt_trait.fin
	From	avnt_cntrt_gart,
		cntrt_trait
	Where	avnt_cntrt_gart.numav = cntrt_trait.numav
	and	avnt_cntrt_gart.numgar = cntrt_trait.numgar
	and	cntrt_trait.numav = G_cur_numav
	and	cntrt_trait.valide = 'O'
	and	least( G_cur_fin, nvl(cntrt_trait.fin, G_cur_fin) )
		-
		greatest(G_cur_debut, cntrt_trait.debut) >= 0
	;
--
-- Retourne la cotisation concernee par l'avenant ( Emission )
--
Cursor C_SEL_cotis_emise IS
	Select	qttc_gar.numquit,
		qttc_gar.numfor,
		qttc_gar.numindiv,
		qttc_gar.mt_ttc,
		qttc_global.idadhesion,
		qttc_global.debut,
		to_char(qttc_global.debut, 'YY')	exercice
	From	qttc_global,
		qttc_gar
	Where	qttc_global.debut between G_cur_debut and G_cur_fin
	and	qttc_global.numgar = G_cur_numgar
	and	qttc_global.comptant != 'R'
	and	qttc_gar.numquit = qttc_global.numquit
	and	qttc_gar.numfor + 0 = G_cur_numfor
	and	pk_cotis.datemis(qttc_gar.numquit) is not null
	and NOT EXISTS (
		Select	1
		From	result_reass_detail
		Where	result_reass_detail.type_cle = 7
		and	result_reass_detail.cle = qttc_global.numquit
		and	result_reass_detail.numfor = qttc_gar.numfor
		and	result_reass_detail.numindiv = qttc_gar.numindiv
		and	result_reass_detail.numav = G_cur_numav
		)
	;
--
-- Retourne la cotisation concernee par l'avenant ( Reglement )
--
Cursor C_SEL_cotis_regle IS
	Select	qttc_affec.numquit,
		qttc_affec.numfor,
		qttc_affec.numindiv,
		qttc_affec.montant,
		qttc_affec.idaffec,
		qttc_global.idadhesion,
		compte_client.datope,
		to_char(compte_client.datope, 'YY')	exercice
	From	compte_client,
		qttc_affec,
		qttc_global
	Where	qttc_global.numquit = qttc_affec.numquit
	and	compte_client.datope between G_cur_debut and G_cur_fin
	and	compte_client.idaffec = qttc_affec.idaffec
	and	compte_client.codope + 0 = 4
	and	qttc_affec.numfor = G_cur_numfor
	and NOT EXISTS (
		Select	1
		From	result_reass_detail
		Where	result_reass_detail.type_cle = 7
		and	result_reass_detail.cle = qttc_affec.numquit
		and	result_reass_detail.nregl = qttc_affec.idaffec
		and	result_reass_detail.numfor = qttc_affec.numfor
		and	result_reass_detail.numindiv = qttc_affec.numindiv
		and	result_reass_detail.numav = G_cur_numav
		)
	;
--
-- Retourne la prestation prevoyance concernee par l'avenant
--
Cursor C_SEL_prevoyance IS
	Select	histo_calcul.idcalcul,
		repartition.numfor,
		dossier_sinistre.numindiv,
		decaismt.numdecaismt			nregl,
		repartition.idadhesion,
		decaismt.datpay,
		to_char(sntr_prev.survenance, 'YY')	exercice
	From	dossier_sinistre,
		sntr_prev,
		repartition,
		histo_calcul,
		affectation,
		decaismt
	Where	dossier_sinistre.iddossier = sntr_prev.iddossier
	and	sntr_prev.nosin = repartition.nosin
	and	repartition.idrepartition = histo_calcul.idrepartition
	and	repartition.numfor = G_cur_numfor
	and	affectation.codope = 2
	and	affectation.numaffec = histo_calcul.numdec
	and	affectation.numdecaismt = decaismt.numdecaismt + 0
	and	decaismt.flagpay = 1
	and	decaismt.datpay between G_cur_debut and G_cur_fin
	and NOT EXISTS (
		Select	1
		From	result_reass_detail
		Where	result_reass_detail.type_cle = 8
		and	result_reass_detail.cle = histo_calcul.idcalcul
		and	result_reass_detail.numav = G_cur_numav
		)
	;
--
-- Retourne la prestation soins de sante concernee par l'avenant
--
Cursor C_SEL_sante IS
	Select	sinistre.numsin,
		sinistre.numfor,
		sinistre.numindiv,
		sinistre.mtreel				montant,
		decaismt.numdecaismt			nregl,
		sinistre.idadhesion,
		decaismt.datpay,
		to_char(sinistre.datsin, 'YY')		exercice
	From	sinistre,
		affectation,
		decaismt
	Where	sinistre.numfor = G_cur_numfor
	and	affectation.codope = 1
	and	affectation.numaffec = sinistre.numdec
	and	affectation.numdecaismt = decaismt.numdecaismt + 0
	and	decaismt.flagpay = 1
	and	decaismt.datpay between G_cur_debut and G_cur_fin
	and NOT EXISTS (
		Select	1
		From	result_reass_detail
		Where	result_reass_detail.type_cle = 9
		and	result_reass_detail.cle = sinistre.numsin
		and	result_reass_detail.numav = G_cur_numav
		)
	;
--
-- Curseur des formules de chargement
--
Cursor C_frml_tfc IS
	Select	idformule,
		tfc,
		type_tfc
	From	frml_tfc_reass
	Where	numtr = G_cur_numtr
	and	G_cur_debut between debut and nvl(fin, G_cur_debut)
	and	valide = 'O'
	and 	domaine = G_domaine;
--
-- ------------------------------------------------ Fin des curseurs prives --
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
-- Retourne le montant de la prestation pour un calcul de prevoyance
--
Function F_mt_prest (
		I_idcalcul	IN histo_calcul.idcalcul%Type
		)
Return Number;
--
-- Determination de la date de fin de calcul
--
Procedure P_SEL_echesuiv (
		I_eche_anniv	IN param_traite.eche_anniv%Type
		);
--
-- Lecture de param_traite
--
Procedure P_SEL_param_traite;
--
-- Mise a jour montant global sur rupture
--
Procedure P_MAJ_result_reass;
--
-- Insertion dans result_reass ( gestion de la rupture )
--
Procedure P_INS_result_reass (
		I_domaine	IN result_reass_detail.type_cle%Type,
		O_flag_rupt	OUT Boolean
		);
--
-- Insertion dans journal_adm
--
Procedure P_INS_journal;
--
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
Procedure P_SEL_traite (
		I_deb_eche	IN Date,
		I_fin_eche	IN Date,
		I_deb_numsoc	IN societe.numsoc%Type,
		I_fin_numsoc	IN societe.numsoc%Type,
		I_deb_numreass	IN traite.numreass%Type,
		I_fin_numreass	IN traite.numreass%Type,
		I_deb_numtr	IN traite.numtr%Type,
		I_fin_numtr	IN traite.numtr%Type,
		I_deb_typtr	IN traite.typtr%Type,
		I_fin_typtr	IN traite.typtr%Type,
		I_session	IN Number,
		I_flag_test	IN Number,
		O_idtraite	OUT avenant.numtr%Type,
		O_idavenant	OUT avenant.numav%Type,
		O_numavenant	OUT avenant.numero%Type
		)
IS
BEGIN
G_deb_eche	:= I_deb_eche;
G_fin_eche	:= I_fin_eche;
G_deb_numsoc	:= I_deb_numsoc;
G_fin_numsoc	:= I_fin_numsoc;
G_deb_numreass	:= I_deb_numreass;
G_fin_numreass	:= I_fin_numreass;
G_deb_numtr	:= I_deb_numtr;
G_fin_numtr	:= I_fin_numtr;
G_deb_typtr	:= I_deb_typtr;
G_fin_typtr	:= I_fin_typtr;
--
G_nom_traitement := 'PK_REASSURANCE.sql';
G_session        := I_session;
G_flag_test	:= I_flag_test;
--
G_niv_msg := 1;
--
If Not C_SEL_traite%ISOPEN then
	Open C_SEL_traite;
	--
	G_msg_adm := 'Début du traitement le ' ||
			to_char(sysdate,'dd/mm/yyyy HH24:MI:SS');
	P_INS_journal;
	--
End if;
--
Fetch C_SEL_traite Into
	G_cur_numtr,
	G_cur_numav,
	O_numavenant,
	G_cur_fin,
	G_cur_debut;
--
If ( C_SEL_traite%NotFound ) then
	Close C_SEL_traite;
	Raise No_Data_Found;
End if;
--
O_idtraite := G_cur_numtr;
O_idavenant := G_cur_numav;
--
P_SEL_param_traite;
--
If ( G_flag_test > 0 ) then
	G_msg_adm := 'Traité n° ' || to_char(G_cur_numtr) || ' avenant ' ||
		to_char(G_cur_numav) || ' Période du ' || d2e(G_cur_debut)
		|| ' au ' || d2e(G_cur_fin);
	P_INS_journal;
End if;
--
--
EXCEPTION
When No_Data_Found then Raise No_Data_Found;
WHEN OTHERS THEN
	ROLLBACK;
	G_msg_adm    := SUBSTR(SQLERRM(SQLCODE),1,128);
	G_niv_msg    := 2;
	--
	-- Insertion dans journal_adm du message d'erreur
	--
    	P_INS_journal;
    	--
    	COMMIT;
    	--
    	RAISE;
END P_SEL_traite;
--
-- Retourne les contrats / garanties a traiter
--
Procedure P_SEL_avenant (
		O_numgar	OUT avnt_cntrt_gart.numgar%Type,
		O_numfor	OUT avnt_cntrt_gart.numfor%Type,
		O_debut		OUT Number,
		O_fin		OUT Number,
		O_raise		OUT Number
		)
IS
l_found		Boolean := TRUE;
BEGIN
O_raise := 0;
If Not C_SEL_avenant%ISOPEN then
	Open C_SEL_avenant;
	l_found := FALSE;
End if;
--
Fetch C_SEL_avenant Into
	G_cur_numgar,
	G_cur_numfor,
	G_cur_datapli,
	G_cur_datper;
--
If ( C_SEL_avenant%NotFound ) then
	If ( G_montant_global != 0 ) then
		G_msg_adm := 'MAJ_result_reass';
		P_INS_journal;
		P_MAJ_result_reass;
	End if;
	Close C_SEL_avenant;
	O_raise := 1;
End if;
--
O_numgar := G_cur_numgar;
O_numfor := G_cur_numfor;
O_debut := d2j(G_cur_debut);
O_fin := d2j(G_cur_fin);
--
If ( G_flag_test > 2 ) then
	G_msg_adm := 'Contrat n° ' || to_char(G_cur_numgar) || ' garantie ' ||
		to_char(G_cur_numfor) || ' validité du ' ||
		d2e(G_cur_datapli) || ' au ' || d2e(G_cur_datper);
	P_INS_journal;
End if;
--
End P_SEL_avenant;
--
-- Retourne la formule a appliquer selon le domaine
--
Procedure P_SEL_frml (
		I_domaine	IN frml_reass.domaine%Type,
		O_idformule	OUT frml_reass.idformule%Type
		)
IS
Cursor C_frml IS
	Select	idformule
	From	frml_reass
	Where	numtr = G_cur_numtr
	and	G_cur_debut between debut and nvl(fin, G_cur_debut)
	and	valide = 'O'
	and 	domaine = I_domaine;
BEGIN
Open C_frml;
Fetch C_frml Into O_idformule;
If ( C_frml%NotFound ) then
	O_idformule := 0;
	--
	G_msg_adm := 'Domaine ' || to_char(I_domaine) ||
			' pas de formule de calcul';
	--
Else
	--
	G_msg_adm := 'Domaine ' || to_char(I_domaine) ||
	' formule de calcul n° ' || to_char(O_idformule);
	--
End if;
Close C_frml;
--
P_INS_journal;
--
END P_SEL_frml;
--
-- Retourne la formule de chargement a appliquer pour le domaine
--
Procedure P_SEL_frml_tfc (
		O_idformule_tfc	OUT frml_tfc_reass.idformule%Type,
		O_raise		OUT Number
		)
IS
Rec_C_frml_tfc	C_frml_tfc%RowType;
BEGIN
--
O_raise := 0;
--
If ( NOT C_frml_tfc%ISOPEN ) then
	Open C_frml_tfc;
End if;
--
Fetch C_frml_tfc Into Rec_C_frml_tfc;
--
If ( C_frml_tfc%NotFound ) then
	O_idformule_tfc := 0;
	O_raise := 1;
	--
	Close C_frml_tfc;
	--
	G_msg_adm := 'Domaine ' || to_char(G_domaine) ||
		' pas de formule de chargement';
	--
Else
	--
	O_idformule_tfc := Rec_C_frml_tfc.idformule;
	G_tfc := Rec_C_frml_tfc.tfc;
	G_type_tfc := Rec_C_frml_tfc.type_tfc;
	--
	G_msg_adm := 'Domaine ' || to_char(G_domaine) ||
		' formule de chargement n° ' || to_char(O_idformule_tfc) ||
		' type ' || to_char(G_type_tfc);
	--
End if;
--
P_INS_journal;
--
END P_SEL_frml_tfc;
--
-- Traitement des cotisations
--@
Procedure P_SEL_cotis (
		O_cle		OUT Number,
		O_numfor	OUT Number,
		O_numindiv	OUT Number,
		O_idadhesion	OUT Number,
		O_dat_reass	OUT Number,
		O_montant	OUT Number
		)
IS
Rec_C_cotis_emise	C_SEL_cotis_emise%Rowtype;
Rec_C_cotis_regle	C_SEL_cotis_regle%Rowtype;
BEGIN
--
If ( G_flag_test > 0 ) then
	G_msg_adm :=
	'Recherche cotisation nature montant ' || to_char(G_nature_montant) ||
	'Numgar ' || to_char(G_cur_numgar) ||
	' Numfor ' || to_char(G_cur_numfor) ||
	' Debut ' || d2e(G_cur_debut) ||
	' Fin ' || d2e(G_cur_fin);
	P_INS_journal;
End if;
--
If ( G_nature_montant = 1 ) then
	--
	If ( NOT C_SEL_cotis_emise%ISOPEN ) then
		Open C_SEL_cotis_emise;
	End if;
	--
	Fetch C_SEL_cotis_emise Into Rec_C_cotis_emise;
	--
	If ( C_SEL_cotis_emise%NotFound ) then
		--
		Close C_SEL_cotis_emise;
		Raise No_Data_Found;
		--
	Else
		--
		O_cle := Rec_C_cotis_emise.numquit;
		O_numfor := Rec_C_cotis_emise.numfor;
		O_numindiv := Rec_C_cotis_emise.numindiv;
		O_montant := Rec_C_cotis_emise.mt_ttc;
		O_idadhesion := Rec_C_cotis_emise.idadhesion;
		O_dat_reass := d2j(Rec_C_cotis_emise.debut);
		--
		G_cle := Rec_C_cotis_emise.numquit;
		G_exercice := Rec_C_cotis_emise.exercice;
		G_numindiv := Rec_C_cotis_emise.numindiv;
		G_nregl := 0;
		G_idadhesion := Rec_C_cotis_emise.idadhesion;
		G_dat_reass := Rec_C_cotis_emise.debut;
		--
		If ( G_flag_test > 0 ) then
			G_msg_adm :=
			'Numquit ' || to_char(Rec_C_cotis_emise.numquit) ||
			'Numgar ' || to_char(G_cur_numgar) ||
			' Numfor ' || to_char(Rec_C_cotis_emise.numfor) ||
			' Numindiv ' || to_char(Rec_C_cotis_emise.numindiv) ||
			' Montant ' || to_char(Rec_C_cotis_emise.mt_ttc);
			P_INS_journal;
		End if;
		--
	End if;
Else
	--
	If ( NOT C_SEL_cotis_regle%ISOPEN ) then
		Open C_SEL_cotis_regle;
	End if;
	--
	Fetch C_SEL_cotis_regle Into Rec_C_cotis_regle;
	--
	If ( C_SEL_cotis_regle%NotFound ) then
		--
		Close C_SEL_cotis_regle;
		Raise No_Data_Found;
		--
	Else
		--
		O_cle := Rec_C_cotis_regle.numquit;
		O_numfor := Rec_C_cotis_regle.numfor;
		O_numindiv := Rec_C_cotis_regle.numindiv;
		O_montant := Rec_C_cotis_regle.montant;
		O_idadhesion := Rec_C_cotis_regle.idadhesion;
		O_dat_reass := d2j(Rec_C_cotis_regle.datope);
		--
		G_cle := Rec_C_cotis_regle.numquit;
		G_exercice := Rec_C_cotis_regle.exercice;
		G_numindiv := Rec_C_cotis_regle.numindiv;
		G_nregl := Rec_C_cotis_regle.idaffec;
		G_idadhesion := Rec_C_cotis_regle.idadhesion;
		G_dat_reass := Rec_C_cotis_regle.datope;
		--
		If ( G_flag_test > 0 ) then
			G_msg_adm :=
			'Numquit ' || to_char(Rec_C_cotis_regle.numquit) ||
			' Numfor ' || to_char(Rec_C_cotis_regle.numfor) ||
			' Numindiv ' || to_char(Rec_C_cotis_regle.numindiv) ||
			' Idaffec ' || to_char(Rec_C_cotis_regle.idaffec) ||
			' Montant ' || to_char(Rec_C_cotis_regle.montant);
			P_INS_journal;
		End if;
		--
	End if;
End if;
END P_SEL_cotis;
--
-- Traitement des prestations prevoyance
--
Procedure P_SEL_prevoyance (
		O_cle		OUT Number,
		O_numfor	OUT Number,
		O_numindiv	OUT Number,
		O_idadhesion	OUT Number,
		O_dat_reass	OUT Number,
		O_montant	OUT Number
		)
IS
Rec_C_prevoyance	C_SEL_prevoyance%Rowtype;
BEGIN
If ( NOT C_SEL_prevoyance%ISOPEN ) then
	Open C_SEL_prevoyance;
End if;
--
Fetch C_SEL_prevoyance Into Rec_C_prevoyance;
--
If ( C_SEL_prevoyance%NotFound ) then
	--
	Close C_SEL_prevoyance;
	Raise No_Data_Found;
	--
Else
	--
	O_cle := Rec_C_prevoyance.idcalcul;
	O_numfor := Rec_C_prevoyance.numfor;
	O_numindiv := Rec_C_prevoyance.numindiv;
	O_montant := F_mt_prest(Rec_C_prevoyance.idcalcul);
	O_idadhesion := Rec_C_prevoyance.idadhesion;
	O_dat_reass := d2j(Rec_C_prevoyance.datpay);
	--
	G_cle := Rec_C_prevoyance.idcalcul;
	G_exercice := Rec_C_prevoyance.exercice;
	G_numindiv := Rec_C_prevoyance.numindiv;
	G_nregl := Rec_C_prevoyance.nregl;
	G_idadhesion := Rec_C_prevoyance.idadhesion;
	G_dat_reass := Rec_C_prevoyance.datpay;
	--
	If ( G_flag_test > 0 ) then
		G_msg_adm :=
		'Idcalcul ' || to_char(Rec_C_prevoyance.idcalcul) ||
		' Numfor ' || to_char(Rec_C_prevoyance.numfor) ||
		' Numindiv ' || to_char(Rec_C_prevoyance.numindiv) ||
		' Montant ' || to_char(O_montant);
		P_INS_journal;
	End if;
	--
End if;
END P_SEL_prevoyance;
--
-- Traitement des prestations soins de sante
--@
Procedure P_SEL_sante (
		O_cle		OUT Number,
		O_numfor	OUT Number,
		O_numindiv	OUT Number,
		O_idadhesion	OUT Number,
		O_dat_reass	OUT Number,
		O_montant	OUT Number
		)
IS
Rec_C_sante	C_SEL_sante%Rowtype;
BEGIN
If ( NOT C_SEL_sante%ISOPEN ) then
	Open C_SEL_sante;
End if;
--
Fetch C_SEL_sante Into Rec_C_sante;
--
If ( C_SEL_sante%NotFound ) then
	--
	Close C_SEL_sante;
	Raise No_Data_Found;
	--
Else
	--
	O_cle := Rec_C_sante.numsin;
	O_numfor := Rec_C_sante.numfor;
	O_numindiv := Rec_C_sante.numindiv;
	O_montant := Rec_C_sante.montant;
	O_idadhesion := Rec_C_sante.idadhesion;
	O_dat_reass := d2j(Rec_C_sante.datpay);
	--
	G_cle := Rec_C_sante.numsin;
	G_exercice := Rec_C_sante.exercice;
	G_numindiv := Rec_C_sante.numindiv;
	G_nregl := Rec_C_sante.nregl;
	G_idadhesion := Rec_C_sante.idadhesion;
	G_dat_reass := Rec_C_sante.datpay;
	--
	If ( G_flag_test > 0 ) then
		G_msg_adm :=
		'Numsin ' || to_char(Rec_C_sante.numsin) ||
		' Numfor ' || to_char(Rec_C_sante.numfor) ||
		' Numindiv ' || to_char(Rec_C_sante.numindiv) ||
		' Montant ' || to_char(O_montant);
		P_INS_journal;
	End if;
	--
End if;
END P_SEL_sante;
--
-- Insertion lignes detail de resultat
--
Procedure P_INS_result_reass_detail (
		I_domaine	IN result_reass_detail.type_cle%Type,
		I_montant	IN result_reass_detail.montant%Type,
		O_montant_global OUT result_reass.montant%Type,
		O_flag_rupt	OUT Number
		)
IS
l_flag_rupt	Boolean;
BEGIN
O_flag_rupt := 0;
O_montant_global := G_montant_global;
--
P_INS_result_reass (
		I_domaine	=> I_domaine,
		O_flag_rupt	=> l_flag_rupt
		);
If ( l_flag_rupt ) then
	O_flag_rupt := 1;
End if;
--
Insert Into result_reass_detail (
	Iddetail,
	Type_Cle,
	Cle,
	Exercice,
	Numgar,
	Numfor,
	Numindiv,
	Nregl,
	Montant,
	Idglob,
	Numav )
Values (
	seq_iddetail.nextval,
	I_domaine,
	G_cle,
	G_exercice,
	G_cur_numgar,
	G_cur_numfor,
	G_numindiv,
	G_nregl,
	I_montant,
	G_idglob,
	G_cur_numav );
--
G_montant_global := G_montant_global + I_montant;
--
If ( G_flag_test > 0 ) then
	G_msg_adm := 'Resultat detail Idglob ' || to_char(G_idglob) ||
		' Cle ' || to_char(G_cle) ||
		' Montant ' || to_char(I_montant) ||
		' Cumul ' || to_char(G_montant_global);
	P_INS_journal;
End if;
--
END P_INS_result_reass_detail;
--
-- Insertion lignes de chargement
--
Procedure P_INS_result_reass_tfc (
		I_montant	IN result_reass_tfc.montant%Type
		)
IS
Cursor C_test_tfc IS
	Select	1
	From	result_reass_tfc
	Where	idglob = G_idglob
	and	tfc = G_tfc
	and	Type_tfc = G_type_tfc;
Dummy	Binary_integer;
BEGIN
Open C_test_tfc;
Fetch C_test_tfc Into Dummy;
If ( C_test_tfc%NotFound ) then
	--
	Insert Into result_reass_tfc (
		Idtfc,
		Tfc,
		Type_Tfc,
		Montant,
		Idglob )
	Values (
		seq_idtfc.nextval,
		G_tfc,
		G_type_tfc,
		I_montant,
		G_idglob );
	--
	G_msg_adm := 'Insertion chargement type ' || to_char(G_type_tfc) ||
			' Idglob ' || to_char(G_idglob) ||
			' montant ' || to_char(I_montant);
	P_INS_journal;
	--
End if;
Close C_test_tfc;
END P_INS_result_reass_tfc;
--
-- Mise a jour echeance de calcul
--
Procedure P_MAJ_echesuiv(
		I_idavenant	IN avenant.numav%Type
		)
IS
BEGIN
Update 	avenant
Set	dereche = G_cur_debut,
	procheche = G_cur_fin + 1
Where	numav = I_idavenant;
--
G_msg_adm := 'Mise a jour echeance de calcul avenant '|| to_char(I_idavenant)
		|| ' Echeance ' || d2e(G_cur_fin + 1);
P_INS_journal;
--
END P_MAJ_echesuiv;
--
-- Mise a jour echeance de calcul suite a annulation
--@
Procedure P_DEL_result_reass (
		I_idglob	IN result_reass.idglob%Type,
		I_debut		IN result_reass.dtdebut%Type,
		I_fin		IN result_reass.dtfin%Type
		)
IS
Cursor C_avenant IS
	Select	avenant.numav,
		avenant.dateffav
	from	avenant,
		result_reass_detail
	Where	avenant.numav = result_reass_detail.numav
	and	result_reass_detail.idglob = I_idglob;
L_numav		avenant.numav%Type;
L_dateff	avenant.dateffav%Type;
L_dereche	avenant.dereche%Type;
L_procheche	avenant.procheche%Type := I_debut;
L_fract		Number;
BEGIN
L_fract := round( months_between(I_fin, I_debut), 0);
L_dereche := add_months( I_debut, - L_fract );
Open C_avenant;
Loop
	Fetch C_avenant Into
		L_numav,
		L_dateff;
	Exit When C_avenant%NotFound;
	--
	If ( I_debut <= L_dateff ) then
		L_dereche := Null;
		L_procheche := Null;
	End if;
	--
	Update	avenant
	Set	procheche = L_procheche,
		dereche = L_dereche
	Where	numav = L_numav;
	--
End Loop;
Close C_avenant;
END P_DEL_result_reass;
--
--
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--
-- Retourne le montant de la prestation pour un calcul de prevoyance
--
Function F_mt_prest (
		I_idcalcul	IN histo_calcul.idcalcul%Type
		)
Return Number
IS
L_montant	Number;
BEGIN
Select	Sum( f_total_histo(histo_jours.idhisto, -2) )
Into	L_montant
From	histo_jours
Where	idcalcul = I_idcalcul;
--
Return( L_montant );
--
END F_mt_prest;
--
-- Mise a jour montant global sur rupture
--
Procedure P_MAJ_result_reass
IS
BEGIN
If ( G_idglob != -1 ) then
	--
	Update	result_reass
	Set	montant = G_montant_global
	Where	idglob = G_idglob
	and	montant = 0;
	--
	If ( G_flag_test > 0 ) then
		G_msg_adm := 'Maj montant Idglob ' || to_char(G_idglob) ||
			' Cumul ' || to_char(G_montant_global);
		P_INS_journal;
	End if;
	--
	G_montant_global := 0;
	--
End if;
--
END P_MAJ_result_reass;
--
-- Insertion dans result_reass ( gestion de la rupture )
--
Procedure P_INS_result_reass (
		I_domaine	IN result_reass_detail.type_cle%Type,
		O_flag_rupt	OUT Boolean
		)
IS
flag_rupt	Boolean := FALSE;
L_cur_numav	result_reass.numav%Type := G_cur_numav;
BEGIN
O_flag_rupt := FALSE;
--
If ( G_niveau_appel = 1 ) then
	L_cur_numav := Null;
End if;
--
If ( I_domaine != G_domaine ) then
	flag_rupt := TRUE;
	G_domaine := I_domaine;
End if;
--
If ( G_cur_numtr != G_der_numtr ) then
	G_der_numtr := G_cur_numtr;
	If ( G_niveau_appel = 1 ) then
		flag_rupt := TRUE;
	End if;
End if;
--
If ( G_cur_numav != G_der_numav ) then
	G_der_numav := G_cur_numav;
	If ( G_niveau_appel = 2 ) then
		flag_rupt := TRUE;
	End if;
End if;
--
If ( flag_rupt ) then
	--
	If ( G_idglob != -1 ) then
		O_flag_rupt := TRUE;
		P_MAJ_result_reass;
	End if;
	--
	Select	nvl( max(idglob), 0 ) + 1
	Into	G_idglob
	From	result_reass;
	--
	If ( G_flag_test > 0 ) then
		G_msg_adm := 'Insertion resultat Idglob ' ||
			to_char(G_idglob) ||
			' Domaine ' || to_char(G_domaine) ||
			' Traité ' || to_char(G_cur_numtr) ||
			' avenant ' || to_char(G_cur_numav);
		P_INS_journal;
	End if;
	--
	Insert Into result_reass (
		Idglob,
		Numtr,
		Numav,
		Dtdebut,
		Dtfin,
		Date_Calcul,
		Type_Calcul,
		Montant )
	Values (
		G_idglob,
		G_cur_numtr,
		L_cur_numav,
		G_cur_debut,
		G_cur_fin,
		Sysdate,
		G_domaine,
		0 );
End if;
--
END P_INS_result_reass;
--
-- Lecture de param_traite
--
Procedure P_SEL_param_traite
IS
Cursor C_param_traite IS
	Select	Numtr,
		Nat_Calc,
		Type_Terme,
		Typequit,
		Type_Calc,
		Mode_Calcul,
		Fract,
		Arrondi,
		Mregl,
		Eche_Anniv,
		Revision,
		Delai,
		Nat_Data
	From	param_traite
	Where	numtr = G_cur_numtr;
Rec_C_param_traite	C_param_traite%Rowtype;
BEGIN
Open C_param_traite;
Fetch C_param_traite Into Rec_C_param_traite;
If ( C_param_traite%NotFound ) then
	--
	G_msg_adm := 'Pas de paramétrage pour le traité n° ' ||
			to_char(G_cur_numtr);
	P_INS_journal;
	-- Raiser quelque chose ...
Else
	G_cur_fract := Rec_C_param_traite.fract;
	G_niveau_appel := Rec_C_param_traite.typequit;
	G_nature_montant := Rec_C_param_traite.nat_data;
	P_SEL_echesuiv (
		I_eche_anniv	=> Rec_C_param_traite.eche_anniv
		);
End if;
Close C_param_traite;
END P_SEL_param_traite;
--
-- Determination de la date de fin de calcul
--
Procedure P_SEL_echesuiv (
		I_eche_anniv	IN param_traite.eche_anniv%Type
		)
IS
L_echesuiv 	Date := G_cur_debut + 1;
BEGIN
While (mod(months_between(L_echesuiv, I_eche_anniv), G_cur_fract) != 0)
Loop
	L_echesuiv := L_echesuiv + 1;
End Loop;
If ( nvl(G_cur_fin, L_echesuiv) >= L_echesuiv ) then
		G_cur_fin := L_echesuiv - 1;
	End if;
END P_SEL_echesuiv;
--
Procedure P_INS_journal
IS
BEGIN
G_idligne := G_idligne + 1;
PK_trace.P_INS_journal_adm (
		I_nom_traitement => G_nom_traitement,
		I_session        => G_session,
		I_niv_msg        => G_niv_msg,
		I_msg_adm        => G_msg_adm,
		I_idligne	 => G_idligne);
END;
--
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
