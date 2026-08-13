CREATE function ARTHUS.f_mt_affec_tfc_numquit (
				a_numquit in number,
				a_tfc in integer,
				a_type in integer default null
				)
Return number
as
loc_retour	number;
BEGIN
	Begin
	Select	nvl(sum(montant), 0)
	Into	loc_retour
	From	qttc_affec_tfc
	Where 	numquit = a_numquit
	and	tfc = a_tfc
	and	type_tfc = nvl(a_type, type_tfc)
	;
	Exception When No_data_found then loc_retour := 0;
	End;
Return ( loc_retour );
END	f_mt_affec_tfc_numquit;
