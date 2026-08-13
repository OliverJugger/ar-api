CREATE function ARTHUS.f_force_type_mt (
				I_numfor    In Number)
Return Number
Is
loc_retour		Number;
BEGIN
	begin
		Select	1
		Into	loc_retour
		From	gar_cntrt,
			formule,
			contrat_ref
		Where	gar_cntrt.type = 1
		and		gar_cntrt.numfor = I_numfor
		and 	decode(gar_cntrt.numgar,gar_cntrt.numgar_ref,gar_cntrt.numfor,gar_cntrt.numfor_ref) = formule.numfor
		and     gar_cntrt.numgar_ref= contrat_ref.numgar
		and     formule.flag_regime='O'
		and     formule.numass =103;
	Exception When No_data_found then loc_retour := 0;
	end;

RETURN ( loc_retour );

END	f_force_type_mt;
