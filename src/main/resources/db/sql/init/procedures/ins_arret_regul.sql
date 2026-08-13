CREATE procedure ARTHUS.ins_arret_regul (
				a_new_idcalcul	In Number,
				a_idrepartition	In Number,
				a_numbene 	In Number,
				a_debut 	In Date,
				a_fin 		In Date
				)
As
-- Variable de reconnaissance SCCS
-- %W% Regularisation d'un calcul sur arrets   %E%
loc_idcalcul	number;
Cursor fetch_histo is
	Select	histo_calcul.idcalcul
	From	histo_calcul
	Where	histo_calcul.idcalcul + 0 != a_new_idcalcul
	and	histo_calcul.idrepartition = a_idrepartition
	and	histo_calcul.numbene = a_numbene
	and	least( a_fin, histo_calcul.fin )
		- greatest( a_debut, histo_calcul.debut ) >= 0
	;
loc_histo	fetch_histo%Rowtype;
BEGIN
For loc_histo in fetch_histo
Loop
	Begin
	Ins_histo_regul( loc_histo.idcalcul, a_new_idcalcul );
	End;
	Begin
	Update	arret
	Set	traite = 'R',
		maj = trunc(Sysdate)
	Where	idarret = loc_histo.idcalcul;
	End;
End loop;
END;
/
