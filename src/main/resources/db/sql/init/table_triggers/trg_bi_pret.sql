CREATE TRIGGER ARTHUS.trg_bi_pret
Before Insert
On pret
For each row







Begin
:new.creation := trunc(sysdate);
:new.maj := trunc(sysdate);
End;