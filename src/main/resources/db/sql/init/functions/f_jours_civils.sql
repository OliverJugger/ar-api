CREATE function ARTHUS.f_jours_civils (
				a_debut 	in Date,
				a_periode 	in Number,
				a_civil		in Number default 0
				)
Return Number
As
loc_retour	Number;
BEGIN
If (a_civil=0)
Then
Begin
Select 	Add_months( trunc(a_debut, 'MM'), a_periode)
	-
      	Trunc( a_debut, 'MM' )
Into	loc_retour
From	Dual;
Return ( loc_retour );
End;
Elsif (a_civil=1) then
Begin
Select 	Add_months(
		trunc	(a_debut, decode(a_periode,
					1, 'MM',
					3, 'Q',
					12,'Y')
			),
	a_periode)
	-
      	trunc	(a_debut, decode(a_periode,
	      				1, 'MM',
	      				3, 'Q',
	      				12,'Y')
		)
Into	loc_retour
From	Dual;
Return ( loc_retour );
End;
End if;
END	f_jours_civils;
