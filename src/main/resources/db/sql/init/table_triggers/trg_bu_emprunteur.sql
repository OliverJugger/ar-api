CREATE TRIGGER ARTHUS.trg_bu_emprunteur
Before Update
On emprunteur
For each row







Begin
:new.maj := trunc(sysdate);
:new.numutil := f_numutil;
End;