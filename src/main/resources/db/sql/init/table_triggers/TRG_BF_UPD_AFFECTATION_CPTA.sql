CREATE TRIGGER ARTHUS.TRG_BF_UPD_AFFECTATION_CPTA
   BEFORE UPDATE Of Idcompta ON AFFECTATION
   FOR EACH ROW
Begin
      UPDATE AFFECTATION_ANNUL
      SET Idcompta_init = :new.Idcompta
      WHERE Numaffec    = :new.Numaffec
      AND   Codope      = :new.Codope
      ;
End;