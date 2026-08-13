CREATE TRIGGER ARTHUS.TRG_BF_DEL_DECAISMT_CPTA
   BEFORE DELETE ON Decaismt
   FOR EACH ROW
Begin
   If (:old.Idcompta != -1 ) Then
      UPDATE Pnul
      SET Idcompta_init = :old.Idcompta
      Where Numdecaismt = :old.Numdecaismt;
   End if;
End;