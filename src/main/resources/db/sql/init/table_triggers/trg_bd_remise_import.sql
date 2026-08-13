CREATE TRIGGER ARTHUS.trg_bd_remise_import
Before Delete
On remise_import
For each row








Begin
Delete	histo_import
Where	numremise = :old.numremise;
End;