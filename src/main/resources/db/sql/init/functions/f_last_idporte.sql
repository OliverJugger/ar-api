CREATE function ARTHUS.f_last_idporte (
		a_numporte	in number,
		a_numindiv	in number,
		a_idadhesion	in number,
		a_annul		in number default 0
				   )
return	number
is
	loc_last_idporte 	number;
begin
	Select	nvl(max(idporte), -1)
	Into	loc_last_idporte
	From	porte_adhesion
	Where	numporte = a_numporte
	and	idadhesion = a_idadhesion
	and	numindiv = a_numindiv
	and	(mouvement != 'A' or a_annul != 0)
	;
	return(loc_last_idporte);
end;
