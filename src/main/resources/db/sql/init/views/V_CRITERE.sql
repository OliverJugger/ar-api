CREATE FORCE VIEW ARTHUS.V_CRITERE AS
select	societe.numsoc						numsoc,
	societe.nom						nom_soc,
	nvl(grnts.refcie_chapeau,'N')				refcie_chapeau,
	grnts.numgar,
	grnts.refcie
from	societe,
	grnts
where	societe.numsoc		= grnts.numinterm
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CRITERE FOR ARTHUS.V_CRITERE
