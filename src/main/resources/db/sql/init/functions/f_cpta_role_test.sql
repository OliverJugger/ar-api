CREATE function ARTHUS.f_cpta_role_test (
				ref	In Number,
				typ_ref In Number default 1,
				typ_gest In Number default 1
				)
Return varchar2
Is
loc_retour		varchar2(32);
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
		Union
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
		Select	numinterm, numorg, gest_cotis, gest_prest
		Into	loc_societe, loc_assureur, loc_gest_cotis, loc_gest_prest
		From	gar_cntrt,
				contrat
		Where	gar_cntrt.numfor 	= ref
		and		gar_cntrt.numgar	= contrat.numgar;
		Exception When No_data_found then loc_retour := 0;
	End;
ELSE -- (typ_ref # 1)
	begin
	-- Infos contrat à partir d'un contrat ou d'une adhésion
		Select	numinterm, numorg, gest_cotis, gest_prest
		Into	loc_societe, loc_assureur, loc_gest_cotis, loc_gest_prest
		From	contrat
		Where	contrat.numgar = ref;
		Exception When No_data_found then loc_retour := 0;
	end;
END IF;
IF (loc_retour > 0) THEN
	-- Mode de gestion
	IF ((typ_gest = 1) and (loc_gest_prest = 1)) THEN 	loc_gestion := 1; END IF;
	IF ((typ_gest = 1) and (loc_gest_prest <> 1))THEN 	loc_gestion := 0; END IF;
	IF ((typ_gest = 2) and (loc_gest_cotis = 1)) THEN 	loc_gestion := 1; END IF;
	IF ((typ_gest = 2) and (loc_gest_cotis <> 1))THEN 	loc_gestion := 0; END IF;
	-- Détermination du rôle de la société
	IF (loc_assurgar > 0) THEN loc_assureur := loc_assurgar; END IF;
	IF ((loc_societe = loc_assureur) AND (loc_gestion = 1)) THEN	loc_retour := 1; END IF;
	IF ((loc_societe = loc_assureur) AND (loc_gestion = 0)) THEN	loc_retour := 2; END IF;
	IF ((loc_societe <> loc_assureur) AND (loc_gestion = 1))THEN	loc_retour := 3; END IF;
	IF ((loc_societe <> loc_assureur) AND (loc_gestion = 0))THEN	loc_retour := 4; END IF;
END IF;
loc_retour := to_char(loc_societe)||' '||to_char(loc_assureur)||' '||to_char(loc_gestion)||' '||to_char(loc_retour);
RETURN ( loc_retour );
END	f_cpta_role_test;
