CREATE function ARTHUS.f_terme_echu (
				a_debut in date,
				a_periode in integer
				)
Return date
as
loc_debut	date := a_debut;
loc_retour	date;
BEGIN
Loop
Select	add_months( trunc(loc_debut,
			  decode(a_periode,
				 1,'MM',
				 3,'Q',
				 12,'Y'
				)
			),
		     a_periode
		   )
Into	loc_debut
From 	dual;
exit when ( loc_debut >= sysdate );
loc_retour := loc_debut -1;
End loop;
Return ( loc_retour );
END	f_terme_echu;
