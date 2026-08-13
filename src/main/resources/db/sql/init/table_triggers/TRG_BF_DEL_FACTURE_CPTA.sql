CREATE TRIGGER ARTHUS.TRG_BF_DEL_FACTURE_CPTA
   BEFORE DELETE ON Facture
   FOR EACH ROW
Declare
--
   L_facture_annul NUMBER;
--
Begin
   If (:old.Idcompta != -1 ) Then -- Si on a comptabilisé la facture...
         -- ...ajout ou update dans facture_annul pour permettre
         -- l'annulation de la compta
         SELECT count(*)
         INTO L_facture_annul
         FROM Facture_annul
         WHERE Codope  = :old.Codope
         AND   Numfact = :old.Numfact;

         IF (L_facture_annul > 0) Then
            UPDATE Facture_annul
            SET   Idcompta_init = :old.Idcompta
            WHERE Codope        = :old.Codope
            AND   Numfact       = :old.Numfact;
         ELSE
            INSERT INTO Facture_annul (
			Codope,
			Numfact,
			Datope,
                        Idcompta_init)
            VALUES(:old.Codope,
		   :old.Numfact,
		   sysdate,
                   :old.Idcompta);
         END IF;
   End if;
End;