CREATE function ARTHUS.f_prorata_jours (
				a_debut 	in Date,
				a_periode 	in Number,
				a_civil 	in Number default 0
				)
Return Number
As
loc_retour	Number;
BEGIN
Begin
Select 	( parametres.prorata_jours / (12 / a_periode) )	/ f_jours_civils( a_debut, a_periode,a_civil )
Into	loc_retour
From	parametres;
Return ( loc_retour );
End;
END	f_prorata_jours;
