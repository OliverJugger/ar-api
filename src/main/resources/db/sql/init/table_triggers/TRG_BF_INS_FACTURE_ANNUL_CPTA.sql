CREATE TRIGGER ARTHUS.TRG_BF_INS_FACTURE_ANNUL_CPTA
BEFORE INSERT ON Facture_annul
for each row
Declare
   L_facture_idcompta NUMBER(9);
Begin
   Select Idcompta
   Into   L_facture_idcompta
   From   Facture
   Where  Codope  = :new.Codope
   And    Numfact = :new.Numfact;

   :new.Idcompta_init := L_facture_idcompta;
End;