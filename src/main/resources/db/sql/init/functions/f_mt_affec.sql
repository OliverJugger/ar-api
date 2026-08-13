CREATE function ARTHUS.f_mt_affec (
				a_numquit in number,
				a_numfor in number
				)
Return number
as
loc_retour	number;
BEGIN
	Begin
	Select	nvl(sum(montant), 0)
	Into	loc_retour
	From	qttc_affec
	Where 	numquit = a_numquit
	and	numfor = a_numfor
	and	idgar != 0
	;
	Exception When No_data_found then loc_retour := 0;
	End;
Return ( loc_retour );
END	f_mt_affec;
