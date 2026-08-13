CREATE function ARTHUS.f_total_histo (
				a_idhisto in number,
				a_type in integer
				)
Return number
as
loc_retour	number;
loc_prest	number;
loc_reval	number;
loc_periode	number;
loc_dedu	number;
BEGIN
Begin
Select 	(fin - debut) +1,
	round(
		( ((histo_jours.fin - histo_jours.debut) + 1)
		* histo_jours.montant )
	, 2)
Into	loc_periode,
	loc_prest
From	histo_jours
Where	idhisto = a_idhisto;
Exception When No_data_found then loc_prest := 0;
End;
Begin
Select	round( (loc_periode * histo_reval.montant), 2 )
Into	loc_reval
From	histo_reval
Where	idhisto = a_idhisto;
Exception When No_data_found then loc_reval := 0;
End;
Begin
Select	Nvl(Sum( round( (loc_periode * nvl(histo_dedu.montant, 0)), 2 ) ), 0)
Into	loc_dedu
From	histo_dedu
Where	idhisto = a_idhisto;
Exception When No_data_found then loc_dedu := 0;
End;
if ( a_type = 0 ) then
	loc_retour := loc_reval;
elsif (a_type = -1 ) then
	loc_retour := loc_prest;
elsif (a_type = -2 ) then
	loc_retour := loc_prest + loc_reval - loc_dedu;
elsif (a_type = -3 ) then
	loc_retour := loc_dedu;
elsif (a_type=-4) then
	Begin
	Select
	Nvl(Sum( round( (loc_periode * nvl(histo_dedu.montant, 0)), 2 ) ), 0)
	Into	loc_retour
	From	histo_dedu
	Where	idhisto = a_idhisto
	and	typdedu  in(select code from lble
				where mnemo='DEDU'
				and tableau is null
				and code>0
				)
	;
	Exception When No_data_found then loc_retour := 0;
	End;
else
	Begin
	Select
	Nvl(Sum( round( (loc_periode * nvl(histo_dedu.montant, 0)), 2 ) ), 0)
	Into	loc_retour
	From	histo_dedu
	Where	idhisto = a_idhisto
	and	typdedu=a_type
	;
	Exception When No_data_found then loc_retour := 0;
	End;
end if;
Return ( loc_retour );
END	f_total_histo;
