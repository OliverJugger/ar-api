CREATE TRIGGER ARTHUS.trg_bi_emprunteur
Before Insert
On emprunteur
For each row







Begin
:new.creation := trunc(sysdate);
:new.maj := trunc(sysdate);
:new.numutil := f_numutil;
End;