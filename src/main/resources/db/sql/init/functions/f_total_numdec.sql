CREATE function ARTHUS.f_total_numdec 	(
						a_numdec in number,
						a_type in number
						)
Return number
as
loc_retour	number;
loc_prest	number;
loc_reval 	number;
loc_dedu 	number;
BEGIN

	Begin
	Select  round(sum (f_total_histo(histo_jours.idhisto,-1)),2) mtprest
	Into    loc_prest
	From    histo_jours,
		histo_calcul
	Where	histo_jours.idcalcul=histo_calcul.idcalcul
	And	histo_calcul.numdec=a_numdec
	group by histo_calcul.numdec;
	Exception When no_data_found then loc_prest:=0;
	End;

	Begin
	Select	round(sum (f_total_histo(histo_jours.idhisto,0)),2) mtreval
	Into 	loc_reval
	From 	histo_jours,
	     	histo_calcul
	Where	histo_jours.idcalcul=histo_calcul.idcalcul
	And	histo_calcul.numdec=a_numdec
	group by histo_calcul.numdec;
	Exception When no_data_found then loc_reval:=0;
	End;

	Begin
	Select	sum(round( (((histo_jours.fin-histo_jours.debut)+1) *
			 histo_dedu.montant), 2 ))
	Into 	loc_dedu
	From	histo_dedu,
		histo_jours,
		histo_calcul
	Where 	histo_dedu.idhisto=histo_jours.idhisto
	And	histo_jours.idcalcul=histo_calcul.idcalcul
	And	histo_calcul.numdec=a_numdec;
	Exception When no_data_found then loc_dedu:=0;
	End;

If      (a_type=0) then loc_retour := loc_prest;
elsif   (a_type=1) then loc_retour := loc_reval;
elsif   (a_type=2) then loc_retour := loc_dedu;
else    loc_retour := 0;
end if;

return(loc_retour);
END	f_total_numdec;
