CREATE FORCE VIEW ARTHUS.V_PORTE1 AS
select 	societe.numsoc,
	societe.nom 	nom_soc,
	orgns.numorg	numorg_comple,
	orgns.nom 	nomorg_comple,
	Regime.code	numorg,
	Regime.libelle	nom_org
from 	societe,
	orgns,
	libelle 	Regime
Where 	orgns.role = 2
and	Regime.mnemo = 'REGIME'
and	Regime.code > -1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PORTE1 FOR ARTHUS.V_PORTE1
