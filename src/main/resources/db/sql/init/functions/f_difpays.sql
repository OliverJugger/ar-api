CREATE function ARTHUS.f_difpays (
				a_numindiv	In Number
				)
Return Number
Is
loc_retour	Number;
BEGIN
	begin
		loc_retour := 0;
		Select	1
		Into	loc_retour
		From	pers_adresse
		Where	pers_adresse.numindiv 	= a_numindiv
		and		pers_adresse.defaut 	= 'O'
		and 	pers_adresse.codpays not in (select codpays from societe where codpays = pers_adresse.codpays);
	Exception When No_data_found then loc_retour := 0;
	end;
Return ( loc_retour );
END	f_difpays;
