CREATE TRIGGER ARTHUS.trg_bf_upd_pers_avocat
before update
on pers_avocat
For each row






Begin
:new.maj := Sysdate;
:new.numutil := f_numutil;
End;