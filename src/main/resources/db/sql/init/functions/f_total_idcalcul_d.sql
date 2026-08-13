CREATE function ARTHUS.f_total_idcalcul_d (
						a_idcalcul 	in number,
						a_type 		in number
						)
Return number
as
loc_retour	number;
loc_prest 	number;
loc_reval 	number;
loc_dedu 	number;
BEGIN
	Begin
	Select	round(sum (f_total_histo_d(histo_jours.idhisto,-1)),2) mtprest_d
	Into 	loc_prest
	From 	histo_jours
	Where	histo_jours.idcalcul=a_idcalcul
	group by histo_jours.idcalcul;
	Exception When no_data_found then loc_prest:=0;
	End;

	Begin
	Select	round(sum (f_total_histo_d(histo_jours.idhisto,0)),2) mtreval_d
	Into 	loc_reval
	From 	histo_jours
	Where	histo_jours.idcalcul=a_idcalcul
	group by histo_jours.idcalcul;
	Exception When no_data_found then loc_reval:=0;
	End;

	Begin
	Select	Nvl(sum( round( (((histo_jours.fin-histo_jours.debut)+1) *
			 nvl( histo_dedu.montant_d, 0) ), 2 ) ), 0)
	Into 	loc_dedu
	From	histo_dedu,
		histo_jours
	Where 	histo_dedu.idhisto=histo_jours.idhisto
	And	histo_jours.idcalcul=a_idcalcul;
	Exception When no_data_found then loc_dedu:=0;
	End;

if 	(a_type=0) then loc_retour := loc_prest;
elsif 	(a_type=1) then loc_retour := loc_reval;
elsif 	(a_type=2) then loc_retour := loc_dedu;
else 	loc_retour := 0;
end if;

Return(loc_retour);
END	f_total_idcalcul_d;
