CREATE TRIGGER ARTHUS.trg_bd_rejet_noemie
Before 	Delete
On 	rejet_noemie
For each row
      WHEN ( 	old.mouvement = 'R' or old.mouvement = 'S' ) Declare
	loc_last_idporte 	binary_integer;
	loc_transmis 		binary_integer;
	porte 		porte_adhesion%Rowtype;
BEGIN
/* On recherche le dernier enregistrement rejete pour l'assure */
For porte in (
	Select	idporte,
		transmis,
		mouvement,
		type
	From	porte_adhesion
	Where	porte_adhesion.numporte = :old.numporte
	and	porte_adhesion.numindiv = :old.numindiv
	Order by
		idporte Desc)
Loop
	If ( porte.transmis in (7, 8) ) then
		Begin
		Update	porte_adhesion
		Set	transmis = 1
		Where	idporte = porte.idporte;
		End;
		Exit;
	Elsif ( porte.transmis = 2 and porte.type in (30, 31) ) then
		Begin
		Delete	porte_adhesion
		Where	idporte = porte.idporte;
		End;
	End if;
End loop;
END;