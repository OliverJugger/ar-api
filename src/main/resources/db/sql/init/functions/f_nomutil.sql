CREATE function ARTHUS.f_nomutil (
				a_numutil	In Number,
				type		In Number Default 1
				)
Return Varchar2
Is
loc_retour	Varchar2(30);
c_util		Utilisateurs%Rowtype;
BEGIN
For c_util in (
	Select	nom,
		pseudo,
		initiales,
		profil,
		cellule
	From	utilisateurs
	Where	numutil = a_numutil)
Loop
If ( type = 1 ) then
	loc_retour := c_util.nom;
ElsIf ( type = 2 ) then
	loc_retour := c_util.pseudo;
ElsIf ( type = 3 ) then
	loc_retour := c_util.initiales;
ElsIf ( type = 4 ) then
	loc_retour := c_util.profil;
ElsIf ( type = 5 ) then
	loc_retour := c_util.cellule;
End if;
Exit;
End Loop;
Return ( loc_retour );
END	f_nomutil;
