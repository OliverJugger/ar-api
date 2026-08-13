CREATE procedure ARTHUS.annul_histo_calcul (
				a_idcalcul in number
				)
is
	dummy			number;
Cursor fetch_histo is
	Select	repartition.type_calc,
		repartition.periode,
		histo_jours.idhisto,
		histo_calcul.idrepartition,
		histo_calcul.numbene,
		histo_calcul.debut
	From	repartition,
		histo_jours,
		histo_calcul
	Where	repartition.idrepartition = histo_calcul.idrepartition
	and	histo_jours.idcalcul = histo_calcul.idcalcul
	and	histo_calcul.idcalcul = a_idcalcul
	;
loc_histo	fetch_histo%Rowtype;
BEGIN
For loc_histo in fetch_histo
loop
if (loc_histo.type_calc = 1) then
	Begin
	Update	arret
	Set	traite = 'N'
	Where	idarret = a_idcalcul;
	Exception When No_data_found then null;
	End;
elsif (loc_histo.type_calc = 3) then
	Begin
	Update	repartition_bene
	Set	traite = 'N',
		etat = 3
	Where	traite = 'O'
	and	idrepartition = loc_histo.idrepartition
	and	numbene = loc_histo.numbene;
	Exception When No_data_found then null;
	End;
elsif (loc_histo.type_calc = 2) then
	Begin
	Update	repartition_bene
	Set	echesuiv = decode(loc_histo.debut,
					repartition_bene.debut, null,
					loc_histo.debut)
	Where	idrepartition = loc_histo.idrepartition
	and	numbene = loc_histo.numbene;
	Exception When No_data_found then null;
	End;
end if;
Begin
Delete	histo_jours
Where	idhisto = loc_histo.idhisto;
Exception When No_data_found then null;
End;
Begin
Delete	histo_calcul
Where	idcalcul = a_idcalcul;
End;
end loop;
END;
/
