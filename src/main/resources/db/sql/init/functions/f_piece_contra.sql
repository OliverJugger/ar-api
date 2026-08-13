CREATE function ARTHUS.f_piece_contra(
			a_codope in number,
			a_numpiece in number)
	RETURN	number
is
	loc_numgar number;
BEGIN
	if (a_codope = 1)
	then
		select	numgar
		into	loc_numgar
		from	dcpt
		where	dcpt.numdec = a_numpiece;
	end if;
	if (a_codope = 4)
	then
		select	numgar
		into	loc_numgar
		from	qttc_global
		where	qttc_global.numquit = a_numpiece;
	end if;
	return (loc_numgar);
end;
