CREATE procedure ARTHUS.valide_compta (
				a_datcompta 	in Date
				)
Is
loc_idcompta	Number;
BEGIN
Begin
Select  nvl( max(idcompta), 0 ) + 1
Into	loc_idcompta
From	remise_compta;
End;
Begin
Update	decaismt
Set	idcompta = loc_idcompta,
	datcompta = a_datcompta
Where	idcompta = 0;
Update	encaismt
Set	idcompta = loc_idcompta,
	datcompta = a_datcompta
Where	idcompta = 0;
Update	facture
Set	idcompta = loc_idcompta,
	datcompta = a_datcompta
Where	idcompta = 0;
Update	compte_client
Set	idcompta = loc_idcompta
Where	idcompta = 0;
Update	compta
Set	idcompta	= loc_idcompta
Where	idcompta	= 0;
Update	remise_compta
Set	idcompta	= loc_idcompta,
	datcompta 	= a_datcompta
Where	idcompta	= 0;
End;
END;
/
