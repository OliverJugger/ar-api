CREATE function ARTHUS.f_dcpt_d (
				a_numdec in number,
				a_type in number
				)
Return number
as
loc_nombre	number;
loc_reval number;
loc_dedu number;
BEGIN
	Begin
	Select
	round(sum (f_total_histo_d(histo_jours.idhisto,0)),2) mtreval_d
	Into loc_reval
	From histo_jours,
	     histo_calcul
	Where
	histo_jours.idcalcul=histo_calcul.idcalcul
	And
	histo_calcul.numdec=a_numdec
	group by histo_calcul.numdec;

	Exception
	When no_data_found then loc_reval:=0;
	End;

	Begin

	Select	sum(round( (((histo_jours.fin-histo_jours.debut)+1) *
			 histo_dedu.montant_d), 2 ))
	Into loc_dedu
	From	histo_dedu,
		histo_jours,
		histo_calcul
	Where histo_dedu.idhisto=histo_jours.idhisto
	And
	histo_jours.idcalcul=histo_calcul.idcalcul
	And
	histo_calcul.numdec=a_numdec;

	Exception
	When no_data_found then loc_dedu:=0;
	End;

if (a_type=1)
then
	loc_nombre:=loc_reval;
else
	loc_nombre:=loc_dedu;
end if;

return(loc_nombre);
END;
