CREATE FORCE VIEW ARTHUS.V_FACTURE_SOLDE AS
select	v_totaffec.codope,
	v_totaffec.numfact
from	facture,
	v_totaffec
where	facture.codope = v_totaffec.codope
and	facture.numfact = v_totaffec.numfact
and	v_totaffec.mt_affec >= nvl(facture.montant, 0)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACTURE_SOLDE FOR ARTHUS.V_FACTURE_SOLDE
