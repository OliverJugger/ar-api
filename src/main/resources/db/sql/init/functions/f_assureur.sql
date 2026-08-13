CREATE function ARTHUS.f_assureur (a_numfor	In Number)
Return Number
Is
	loc_retour	Number;
BEGIN

	Begin
		Select
			numass
		Into	loc_retour
		From	gar_cntrt,
			formule
		Where	gar_cntrt.type = 1
		and 	gar_cntrt.numfor = a_numfor
		and 	gar_cntrt.numfor_ref = formule.numfor
		Union all
		Select
			numass
		From	gar_cntrt,
			garanties
		Where	gar_cntrt.type = 2
		and 	gar_cntrt.numfor = a_numfor
		and 	gar_cntrt.numfor_ref = garanties.numfor
		;

		Exception When No_data_found then loc_retour := NULL;

	End;

	If ( loc_retour is Null ) then
		Begin
			Select
				numorg
			Into	loc_retour
			From	contrat,
				gar_cntrt
			Where	contrat.numgar = gar_cntrt.numgar
			and	gar_cntrt.numfor = a_numfor;

			Exception When No_data_found then loc_retour := 0;

		End;
	End if;

	Return ( loc_retour );

END	f_assureur;
