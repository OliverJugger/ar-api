CREATE function ARTHUS.f_situ_pret (
				a_idpret in number,
				a_date in date default sysdate,
				a_type	in Number Default 1
				)
Return number
as
loc_retour	number := 0;
Cursor fetch_objet is
	Select	situ_pret.debut,
		situ_pret.etat,
		situ_pret.motif
	From	situ_pret
	Where	situ_pret.idpret = a_idpret
	Order by
		debut desc,
		creation asc;
loc_objet	fetch_objet%Rowtype;
BEGIN
For loc_objet in fetch_objet
loop
	If ( a_type = 1 ) then
		loc_retour := loc_objet.etat;
	Elsif ( a_type = 2 ) then
		loc_retour := loc_objet.motif;
	Elsif ( a_type = 3 ) then
		loc_retour := d2j(loc_objet.debut);
	End if;
Exit;
end loop;
Return ( loc_retour );
END	f_situ_pret;
