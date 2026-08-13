CREATE function ARTHUS.f_existe_variable (
				a_idvariable 	in number,
				a_etendue 	in number,
				a_clef 		in number,
				a_debut 	in date,
				a_numgar	in number
				)
Return Date
As
loc_retour	Date;
Cursor fetch_objet is
	Select	val_variable.debut
	From	val_variable
	Where	val_variable.etendue = a_etendue
	and	val_variable.clef = a_clef
	and	val_variable.idvariable = a_idvariable
	and	a_debut between val_variable.debut
			and nvl(val_variable.fin, a_debut)
	and	val_variable.valide = 'O'
	and	nvl(numgar, 0) = nvl(a_numgar, 0);
loc_objet	fetch_objet%Rowtype;
BEGIN
loc_retour := Null;
For loc_objet in fetch_objet
loop
	loc_retour := loc_objet.debut;
	Exit;
end loop;
Return ( loc_retour );
END	f_existe_variable;
