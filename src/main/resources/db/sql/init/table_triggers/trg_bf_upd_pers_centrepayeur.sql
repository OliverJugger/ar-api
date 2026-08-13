CREATE TRIGGER ARTHUS.trg_bf_upd_pers_centrepayeur
before update
on pers_centrepayeur
For each row






Begin
:new.maj := Sysdate;
:new.numutil := f_numutil;
End;