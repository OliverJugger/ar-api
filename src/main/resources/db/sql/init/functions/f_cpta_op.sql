CREATE function ARTHUS.f_cpta_op (
				I_numdecaismt    In Number)
Return Number
Is
loc_retour		Number;
BEGIN
	begin
		Select	2
		Into	loc_retour
		From	remise_op_detail
		Where	numdecaismt= I_numdecaismt;

	Exception When No_data_found then loc_retour := 1;
	end;

RETURN ( loc_retour );

END	f_cpta_op;
