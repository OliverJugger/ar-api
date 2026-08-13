CREATE TRIGGER ARTHUS."TRG_BU_PORTE_ADHESION"
Before update of
	idporte,
	numporte,
	numindiv,
	idadhesion,
	numremise,
	debut,
	mouvement,
	fin
On porte_adhesion
For each row
Declare
	loc_type_porte	number;
BEGIN
loc_type_porte := f_type_porte(:new.numporte);

If (loc_type_porte=1)
Then

/* Noemie */

Begin
Update 	noemie
Set	idporte = :new.idporte,
	numporte = :new.numporte,
	numindiv = :new.numindiv,
	idadhesion = :new.idadhesion,
	numremise = :new.numremise,
	debut = :new.debut,
	mouvement = :new.mouvement,
	fin = :new.fin
Where	idporte = :old.idporte;

Exception when No_data_found then null;

End;

Elsif (loc_type_porte in (2,4)) then

/* Tiers-payant */
	Begin
	Update	demande_tiers_payant
	Set	numremise = :new.numremise,
		idporte = :new.idporte,
		transmis=:new.transmis
	Where	idporte = :old.idporte;

	Exception when No_data_found then null;
	End;
End if;
END;