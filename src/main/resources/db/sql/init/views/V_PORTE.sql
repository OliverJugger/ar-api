CREATE FORCE VIEW ARTHUS.V_PORTE AS
select 	societe.numsoc,
	societe.nom nom_soc,
	Regime.code	numorg,
	Regime.libelle	nom_org
from 	societe,
	libelle 	Regime
Where	Regime.mnemo = 'REGIME'
and	Regime.code > -1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PORTE FOR ARTHUS.V_PORTE
