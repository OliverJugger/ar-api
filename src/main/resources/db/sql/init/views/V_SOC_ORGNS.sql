CREATE FORCE VIEW ARTHUS.V_SOC_ORGNS AS
select 	societe.numsoc,
	societe.nom nom_soc,
	orgns.numorg,
	orgns.nom nom_org
from societe,orgns
where orgns.role=1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SOC_ORGNS FOR ARTHUS.V_SOC_ORGNS
