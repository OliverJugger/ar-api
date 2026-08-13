CREATE function ARTHUS.f_idvariable (
				a_nom 	in varchar2,
				a_type	in number Default 1
				)
Return number
As
loc_retour	number;
loc_idvariable	number;
loc_etendue	number;
BEGIN
Begin
Select	idvariable,
	etendue
Into	loc_idvariable,
	loc_etendue
From	def_variable
Where	nom_variable = a_nom;
Exception When No_data_found then loc_idvariable := 0;
End;
If ( a_type = 1 ) then
	loc_retour := loc_idvariable;
Else
	loc_retour := loc_etendue;
End if;
Return ( loc_retour );
END	f_idvariable;
