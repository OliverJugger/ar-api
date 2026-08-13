CREATE function ARTHUS.f_totfrais_gar (
				a_numquit in number,
				a_numfor in integer default null,
				a_numindiv integer default null,
				a_type_frais integer default null
				)
Return number
as
loc_retour	number;
BEGIN
	Begin
	Select	nvl(sum(montant), 0)
	Into	loc_retour
	From	qttc_frais
	Where 	numquit = a_numquit
	and	numfor = nvl(a_numfor, numfor)
	and	numfor != 0
	and	type_frais = nvl(a_type_frais, type_frais)
	and	numindiv = nvl(a_numindiv, numindiv)
	;
	Exception When No_data_found then loc_retour := 0;
	End;
Return ( loc_retour );
END	f_totfrais_gar;
