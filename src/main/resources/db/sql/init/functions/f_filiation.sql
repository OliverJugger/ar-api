CREATE function ARTHUS.f_filiation (
				a_idrepartition in number,
				a_numbene in number
				)
Return number
as
loc_retour	number;
BEGIN
	Begin
	Select	beneficiaire.type_bene
	Into	loc_retour
	From	beneficiaire,
		repartition
	Where	beneficiaire.idadhesion = repartition.idadhesion
	And	beneficiaire.numfor = repartition.numfor
	and	beneficiaire.valide = 'O'
	and	beneficiaire.numbene = a_numbene
	and	repartition.idrepartition = a_idrepartition
	;
	Exception When No_data_found then loc_retour := 0;
	End;
Return ( loc_retour );
END	f_filiation;
