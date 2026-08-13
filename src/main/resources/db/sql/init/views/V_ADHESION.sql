CREATE FORCE VIEW ARTHUS.V_ADHESION AS
select	distinct
	adhesion.idadhesion,
	adhesion.numindiv,
	adhesion.numgar,
	adhesion.numfor,
	adhesion.datapli,
	adhesion.datper,
	adhesion.rang,
	adhesion.uc,
	adhesion.typfor numtype,
	adhesion.numfor numpopu,
	'' norisq,
	adhesion.flag_regime,
	adhesion.numorg
from	adhesion
where	adhesion.typfor in (1,2)
and	adhesion.datapli != nvl(adhesion.datper,adhesion.datapli+1)
and	exists (select 1
		  from	 libelle
		  where	 mnemo='ETIN'
		  and	 sens=0
		)
union
select	distinct
	adhesion.idadhesion,
	adhesion.numindiv,
	adhesion.numgar,
	grp_gar_def.numfor,
	adhesion.datapli,
	adhesion.datper,
	adhesion.rang,
	adhesion.uc,
	grp_gar_def.typfor,
	grp_gar_def.numfor,
	'',
	adhesion.flag_regime,
	adhesion.numorg
from	adhesion,grp_gar_def
where	adhesion.typfor  = 3
and	adhesion.numfor = grp_gar_def.numgrpgar
and	adhesion.datapli != nvl(adhesion.datper,adhesion.datapli+1)
and	exists           (select 1
			  from	 libelle
			  where	 mnemo='ETIN'
			  and	 sens=0
			  and	 libelle.code = adhesion.etat)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ADHESION FOR ARTHUS.V_ADHESION
