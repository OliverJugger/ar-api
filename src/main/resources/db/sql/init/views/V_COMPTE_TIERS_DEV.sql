CREATE FORCE VIEW ARTHUS.V_COMPTE_TIERS_DEV AS
select numcli, monnaie_d
from compte_tiers
where not exists
		( select 1 from compensation
			where compensation.idcomp = compte_tiers.idmvt)
group by numcli, monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTE_TIERS_DEV FOR ARTHUS.V_COMPTE_TIERS_DEV
