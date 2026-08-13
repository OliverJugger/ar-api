CREATE TRIGGER ARTHUS.trg_bd_reversement
before delete
on reversement
for each row







Begin
Update	qttc_affec
Set	idrevers = 0
Where	idrevers = :old.idrevers;
Update	qttc_affec_tfc
Set	idrevers = 0
Where	idrevers = :old.idrevers;
End;