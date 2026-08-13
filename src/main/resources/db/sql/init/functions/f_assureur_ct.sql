CREATE function ARTHUS.f_assureur_ct (a_numfor	In Number)
Return Number
Is
	loc_retour	Number;
BEGIN
		Begin
			Select
					numorg
			Into	loc_retour
			From	contrat,
					gar_cntrt
			Where	contrat.numgar 		= gar_cntrt.numgar
			and		gar_cntrt.numfor 	= a_numfor;

			Exception When No_data_found then loc_retour := 0;
		End;
	Return ( loc_retour );

END	f_assureur_ct;
