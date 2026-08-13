CREATE TRIGGER ARTHUS.trg_bd_remise_export
Before Delete
On remise_export
For each row







Begin
Update	histo_export
Set	numremise = 0
Where	numremise = :old.numremise;
End;