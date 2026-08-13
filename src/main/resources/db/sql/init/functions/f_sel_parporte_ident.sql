CREATE function ARTHUS.f_sel_parporte_ident(
			a_numreg  in	number,
			a_numsoc in	number,
			a_numorg  in 	number		default 0,
			a_numdpt in	varchar2	default '0',
			a_numcaisse in 	varchar2	default '0',
			a_numporte  in	number)
	return ROWID
is
	loc_sel_parporte_ident rowid;
begin
	select	rowid
	into	loc_sel_parporte_ident
	from	parporte
	where	numreg		= a_numreg
	and	numsoc		= a_numsoc
	and	numorg		= a_numorg
	and	numdpt		= a_numdpt
	and	numcaisse	= a_numcaisse
	and	numporte	= a_numporte
	and	ouverte		= 1;

	return(loc_sel_parporte_ident);

	EXCEPTION
		when no_data_found then return ('');
end f_sel_parporte_ident;
