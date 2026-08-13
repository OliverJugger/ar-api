CREATE function ARTHUS.f_soc_assu (
				ref	In Number,
				typ_ref In Number default 1,
				Appel_pour In Number default 1
				)
Return Number
Is
loc_retour		Number;
loc_societe 	Number;
loc_assureur 	Number;
loc_assurgar 	Number;
loc_gestion		Number;
loc_gest_cotis  Number;
loc_gest_prest  Number;
BEGIN
loc_retour 		:= 1;
loc_societe 	:= 0;
loc_assureur 	:= 0;
loc_assurgar 	:= 0;
loc_gestion		:= 0;
loc_gest_cotis 	:= 0;
loc_gest_prest	:= 0;
IF typ_ref = 1 THEN
	Begin
-- Recherche de l'assureur dans le cas d'une garantie
-- soins de santé
		Select	numass
		Into	loc_assurgar
		From	gar_cntrt,
				formule
		Where	gar_cntrt.type = 1
		and		gar_cntrt.numfor = ref
		and 	decode(gar_cntrt.numgar,gar_cntrt.numgar_ref,gar_cntrt.numfor,gar_cntrt.numfor_ref) = formule.numfor
		Union all
		Select	numass
		From	gar_cntrt,
				garanties
		Where	gar_cntrt.type = 2
		and		gar_cntrt.numfor = ref
		and 	decode(gar_cntrt.numgar,gar_cntrt.numgar_ref,gar_cntrt.numfor,gar_cntrt.numfor_ref) = garanties.numfor;
		Exception When No_data_found then loc_assurgar := 0;
	End;
	Begin
-- Infos contrat à partir d'une garantie
		Select	numinterm, numorg
		Into	loc_societe, loc_assureur
		From	gar_cntrt,
				contrat
		Where	gar_cntrt.numfor 	= ref
		and		gar_cntrt.numgar	= contrat.numgar;
		Exception When No_data_found then loc_retour := 0;
	End;
ELSE -- (typ_ref # 1)
	begin
	-- Infos contrat à partir d'un contrat ou d'une adhésion
		Select	numinterm, numorg
		Into	loc_societe, loc_assureur
		From	contrat
		Where	contrat.numgar = ref;
		Exception When No_data_found then loc_retour := 0;
	end;
END IF;
IF (loc_retour > 0) THEN
	-- On privilégie l'assureur de la garantie
	IF (loc_assurgar > 0) THEN  loc_assureur 	:= loc_assurgar; END IF;
	-- Type d'info recherchée
	IF (Appel_pour = 1)   THEN 	loc_retour 		:= loc_societe; END IF;
	IF (Appel_pour = 2)   THEN 	loc_retour 		:= loc_assureur; END IF;
END IF;
RETURN ( loc_retour );
END	f_soc_assu;
