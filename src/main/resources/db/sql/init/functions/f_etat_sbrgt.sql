CREATE function ARTHUS.f_etat_sbrgt(
			a_et_carte in number,
			a_et_attes in number,
			a_et_chequ in number)
		return number
is
	retour		number;
	loc_et_carte	number;
	loc_et_attes	number;
	loc_et_chequ	number;
begin
	loc_et_carte := a_et_carte;
	loc_et_attes := a_et_attes;
	loc_et_chequ := a_et_chequ;
	-- on traite le renouvellement comme une construction
	if ( loc_et_attes = 6) then loc_et_attes := 4;
	end if;
	retour := 0 ;
	if (		loc_et_carte = 4
		and	loc_et_attes = 4
		and	loc_et_chequ = 1
	   ) then retour := 1;
	end if;
	if (		loc_et_carte = 4
		and	loc_et_attes = 4
		and	loc_et_chequ !=1
	   ) then retour := 2;
	end if;
	if (		loc_et_carte !=4
		and	loc_et_attes = 4
		and	loc_et_chequ = 1
	   ) then retour := 3;
	end if;
	if (		loc_et_carte = 4
		and	loc_et_attes !=4
		and	loc_et_chequ = 1
	   ) then retour := 4;
	end if;
	if (		loc_et_carte !=4
		and	loc_et_attes !=4
		and	loc_et_chequ = 1
	   ) then retour := 5;
	end if;
	if (		loc_et_carte !=4
		and	loc_et_attes = 4
		and	loc_et_chequ !=1
	   ) then retour := 6;
	end if;
	if (		loc_et_carte = 4
		and	loc_et_attes = 4
		and	loc_et_chequ !=1
	   ) then retour := 7;
	end if;
	return(retour);
end f_etat_sbrgt;
