CREATE function ARTHUS.f_arrondi (
				a_codope 	in 	Number,
				a_montant 	in 	Number
				)
Return Number
As
loc_retour	Number;
BEGIN
Return ( Round(a_montant, 0) );
END	f_arrondi;
