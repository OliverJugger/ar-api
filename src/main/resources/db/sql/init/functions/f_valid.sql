CREATE function ARTHUS.f_valid (
		a_codope	in number,
		a_idcompte	in number,
		a_montant	in number
				   )
return	number
as
	loc_numutil	number;
begin
	begin
		select	nvl(min(valid_ope.numutil),0)
		into	loc_numutil
		from	valid_ope,compte
		where	valid_ope.codope = a_codope
		and	valid_ope.numsoc = compte.numsoc
		and	compte.numcpte   = a_idcompte
		and	a_montant	between valid_ope.mini
					and	valid_ope.maxi
		;

		exception
		when no_data_found then loc_numutil := 0;
	end;
    return (loc_numutil);
end f_valid;
