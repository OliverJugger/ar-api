CREATE function ARTHUS.f_situ_propal (
				a_numpropo	In Number,
				a_type 		In number default 1
				)
Return Varchar2
Is
loc_retour	Varchar2(78);
loc_objet	Binary_integer;
loc_lib		Varchar2(45);
c_fabric	histo_proposition%Rowtype;
BEGIN
If (a_type=1)
Then
For c_fabric in (
	Select	etat
	From	histo_proposition
	Where	idpropo = a_numpropo
	Order by debut desc)
Loop
	loc_retour := pk_libelle.f_lib('PROP_ETAT', c_fabric.etat );
Exit;
End Loop;
Else
For c_fabric in (
	Select	to_char(debut,'dd/mm/yyyy') debut
	From	histo_proposition
	Where	idpropo = a_numpropo
	Order by debut desc)
Loop
	loc_retour := c_fabric.debut;
Exit;
End Loop;
End if;
Return ( loc_retour );
END	f_situ_propal;
