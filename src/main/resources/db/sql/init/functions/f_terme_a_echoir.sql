CREATE function ARTHUS.f_terme_a_echoir (
				a_debut	 	in 	Date,
				a_fract	 	in 	Number,
				a_eche_anniv 	in 	Date
				)
Return Date
As
loc_terme	Date;
BEGIN
loc_terme := a_debut + 1;
While (mod( months_between( loc_terme, a_eche_anniv ), a_fract ) != 0)
Loop
	loc_terme := loc_terme + 1;
End loop;
Return ( loc_terme - 1 );
END	f_terme_a_echoir;
