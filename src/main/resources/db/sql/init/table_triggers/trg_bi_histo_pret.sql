CREATE TRIGGER ARTHUS.trg_bi_histo_pret
Before Insert
On histo_pret
For each row







Begin
:new.creation := trunc(sysdate);
:new.numutil := f_numutil;
End;