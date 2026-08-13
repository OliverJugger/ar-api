CREATE TRIGGER ARTHUS."TRG_BD_REMISE_EXTERNE" 
Before delete on remise_externe
for each row
BEGIN
Begin
Update 	porte_adhesion
Set	numremise = 0, transmis =2
Where	numremise = :old.numremise;



Exception when No_data_found then null;
End;
END;