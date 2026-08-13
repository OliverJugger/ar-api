CREATE FORCE VIEW ARTHUS.V_CVRT AS
select	adhesion.idadhesion,
	adhesion.numindiv,
	adhesion.numgar,
	adhesion.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	adhesion.datapli,
	adhesion.datper,
	adhesion.rang,
	adhesion.uc,
	adhesion.typfor,
	adhesion.flag_regime,
	adhesion.numorg,
	adhesion.etat,
	adhesion.motif,
	0 numgrpgar
from	gar_cntrt,
	adhesion
where	gar_cntrt.numfor = adhesion.numfor
and	adhesion.typfor in (1,2)
and	((adhesion.datapli != nvl(adhesion.datper,adhesion.datapli+1)) or f_couv_jour=1)
union
select	adhesion.idadhesion,
	adhesion.numindiv,
	adhesion.numgar,
	grp_gar_def.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	adhesion.datapli,
	adhesion.datper,
	adhesion.rang,
	adhesion.uc,
	grp_gar_def.typfor,
	adhesion.flag_regime,
	adhesion.numorg,
	adhesion.etat,
	adhesion.motif,
	grp_gar_def.numgrpgar
from	gar_cntrt,
	grp_gar_def,
	adhesion
where	gar_cntrt.numfor = grp_gar_def.numfor
and	adhesion.numfor = grp_gar_def.numgrpgar
and	adhesion.typfor  = 3
and	((adhesion.datapli != nvl(adhesion.datper,adhesion.datapli+1)) or f_couv_jour=1)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CVRT FOR ARTHUS.V_CVRT
