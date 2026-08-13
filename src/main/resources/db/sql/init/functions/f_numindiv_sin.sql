CREATE function ARTHUS.f_numindiv_sin (
				a_numdec in number
				)
Return number
as
loc_numindiv	number;
BEGIN
	Select 	numindiv
	Into 	loc_numindiv
	From 	sin_prev sin
	Where	sin.nosin = f_sin(a_numdec);
	return(loc_numindiv);
	Exception
	When no_data_found then loc_numindiv:=0;
	return(loc_numindiv);
END;
