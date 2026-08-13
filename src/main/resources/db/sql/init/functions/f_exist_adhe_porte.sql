CREATE function ARTHUS.f_exist_adhe_porte(
			a_idadhesion in number,
			a_numindiv in number,
			a_numporte in number)
	return number
is
	loc_retour	number;
	i		number;
	ret		pk_types.t_table;
begin
	loc_retour := 0;
	ret := f_adhesion_externe(a_idadhesion,a_numindiv,'N');
	i := 1;
	while ( ret(i) != 0)
	LOOP
		if ( ret(i) = a_numporte )
		then
			loc_retour := 1;
		end if;
		i := i + 1 ;
	end LOOP;

	return(loc_retour);

end f_exist_adhe_porte;
