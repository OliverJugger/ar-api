CREATE function ARTHUS.f_cle_phys (
				a_code	in	number
				)
Return number
AS
loc_cle_phys	number;
BEGIN
	Select	sens
	Into	loc_cle_phys
	From	libelle
	Where	mnemo='CLE_BASE'
	and	code=a_code
	and	tableau=0
	Union
	Select	to_number(codapli)
	From	libelle
	Where	mnemo='CLE_BASE'
	and	code=a_code
	and	tableau>0
	;
Return ( loc_cle_phys );
	Exception
	When no_data_found then null;
END;
