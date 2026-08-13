CREATE function ARTHUS.f_transmis (
		a_idporte	in number
				   )
return	number
is
	loc_transmis 	number;
begin
	Select	transmis
	Into	loc_transmis
	From	porte_adhesion
	Where	idporte = a_idporte
	;
	return(loc_transmis);
	EXCEPTION
	WHEN no_data_found then return(-1);
end;
