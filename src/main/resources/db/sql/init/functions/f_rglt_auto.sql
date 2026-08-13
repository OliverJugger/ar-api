CREATE function ARTHUS.f_rglt_auto(p_modpmt	in number)
	return NUMBER
as
	loc_sens	number;
	loc_retour	number;
BEGIN

	Begin
	select	sens
	into	loc_sens
	from libelle where mnemo = 'MOPM' and code = p_modpmt;
	--
	if (loc_sens = 0) then
		loc_retour := 1;
	else
		loc_retour := 0;
	end if;
	--
	Exception when no_data_found then loc_retour := 0;
	End;
return (loc_retour);
END;
