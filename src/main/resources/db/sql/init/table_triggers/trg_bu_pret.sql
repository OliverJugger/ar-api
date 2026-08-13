CREATE TRIGGER ARTHUS.trg_bu_pret
Before Update
On pret
For each row







Begin
:new.maj := trunc(sysdate);
End;