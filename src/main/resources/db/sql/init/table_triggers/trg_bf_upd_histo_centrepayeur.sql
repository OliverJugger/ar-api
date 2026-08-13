CREATE TRIGGER ARTHUS.trg_bf_upd_histo_centrepayeur
before update
on histo_centrepayeur
For each row






Begin
:new.maj := Sysdate;
:new.numutil := f_numutil;
End;