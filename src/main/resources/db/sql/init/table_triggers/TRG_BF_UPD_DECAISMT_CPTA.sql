CREATE TRIGGER ARTHUS.TRG_BF_UPD_DECAISMT_CPTA
   BEFORE UPDATE Of Idcompta ON DECAISMT
   FOR EACH ROW
Begin
      UPDATE pnul
      SET Idcompta_init = :new.Idcompta
      WHERE Numdecaismt = :new.Numdecaismt
      ;
End;