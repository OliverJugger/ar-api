CREATE function ARTHUS.f_type_porte (
		a_numporte	in number
				   )
return	number
is
	loc_type_porte 	number default 1;
begin
	--Select	nvl(min(2), 1) -- XHUE le 04/08/2010 projet SEVEANE
	Select	type_circuit
	Into	loc_type_porte
	From	porte_param
	Where	numporte = a_numporte;
  return loc_type_porte;
  EXCEPTION
    when others then return 1;

end;
