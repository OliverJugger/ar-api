CREATE function ARTHUS.f_cpta_type_dev_enc
					(
					I_numencaismt    In Number
					)
Return Number
Is
loc_retour		Number;
BEGIN
	begin
		Select	1
		Into		loc_retour
		From		encaismt
		Where		numencaismt= I_numencaismt
		and		encaismt.monnaie_d = pk_devise.Devise_ref;

		Exception When No_data_found then loc_retour := 1;
	end;

RETURN ( loc_retour );

END	f_cpta_type_dev_enc;
