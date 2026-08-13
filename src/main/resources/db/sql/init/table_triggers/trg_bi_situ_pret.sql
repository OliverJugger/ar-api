CREATE TRIGGER ARTHUS.trg_bi_situ_pret
Before Insert
On situ_pret
For each row







Begin
:new.creation := sysdate;
:new.numutil := f_numutil;
End;