CREATE function ARTHUS.f_desaccentue (
				a_chaine	In Varchar2
				)
Return Varchar2
Is
loc_retour	Varchar2(256);
loc_chaine	Varchar2(256) := a_chaine;
loc_accentue	Varchar2(30) := 'éèêëàâçîïôöùûü';
loc_desaccentue	Varchar2(30) := 'eeeeaaciioouuu';
BEGIN
loc_retour := translate( lower(a_chaine), loc_accentue, loc_desaccentue );
If ( loc_chaine = upper( a_chaine ) ) then
	loc_retour := upper( loc_retour );
End if;
Return ( loc_retour );
END	f_desaccentue;
