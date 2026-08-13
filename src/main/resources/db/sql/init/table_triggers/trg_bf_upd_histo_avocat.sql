CREATE TRIGGER ARTHUS.trg_bf_upd_histo_avocat
before update
on histo_avocat
For each row






Begin
:new.maj := Sysdate;
:new.numutil := f_numutil;
End;