CREATE function ARTHUS.f_piece_contrat(
			a_codope in number,
			a_numpiece in number)
	RETURN	number
is
	loc_numgar number;
BEGIN
	if (a_codope = 1)
	then
	   begin
		select	numgar
		into	loc_numgar
		from	dcpt
		where	dcpt.numdec = a_numpiece;
		exception
		when no_data_found then loc_numgar := 0 ;
	   end;
	elsif (a_codope = 4)
	then
	   begin
		select	numgar
		into	loc_numgar
		from	qttc_global
		where	qttc_global.numquit = a_numpiece;
		exception
		when no_data_found then loc_numgar := 0 ;
	   end;
	else
		loc_numgar := 0;
	end if;
	return (loc_numgar);
end;
