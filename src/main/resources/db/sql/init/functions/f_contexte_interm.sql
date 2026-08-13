CREATE function ARTHUS.f_contexte_interm (
				a_contexte	in number,
				a_contexte_base in number
				)
Return number
AS
loc_contexte_interm	number;
BEGIN
	Select	a_contexte_base
	Into	loc_contexte_interm
	From	libelle
	Where	mnemo='CLE_BASE'
	And	code=a_contexte
	And	sens=a_contexte_base
	And	tableau=0
	Union
	Select 	to_number(codapli)
	From	libelle
	Where	mnemo='CLE_BASE'
	And	code=a_contexte
	And	sens=a_contexte_base
	And	tableau>0
;
	Return ( loc_contexte_interm );
	Exception
		When no_data_found then loc_contexte_interm:=
						f_cle_phys(a_contexte);
		Return ( loc_contexte_interm );
		When too_many_rows then loc_contexte_interm:=
						f_cle_phys(a_contexte);
		Return ( loc_contexte_interm );
END;
