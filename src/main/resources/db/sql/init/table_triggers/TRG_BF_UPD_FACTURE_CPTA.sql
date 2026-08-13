CREATE TRIGGER ARTHUS.TRG_BF_UPD_FACTURE_CPTA
   BEFORE UPDATE Of Idcompta ON FACTURE
   FOR EACH ROW
Begin
      UPDATE FACTURE_ANNUL
      SET Idcompta_init = :new.Idcompta
      WHERE Numfact     = :new.Numfact
      AND   Codope      = :new.Codope
      ;
End;