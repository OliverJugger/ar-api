CREATE FORCE VIEW ARTHUS.V_REPARTITION AS
select	repartition.idrepartition,
	repartition.NOSIN,
	adhe_cntrt.NUMGAR,
	repartition.NUMFOR,
	repartition.TYPE_CALC,
	repartition.VALIDE,
	repartition.PERIODE,
	repartition.IDADHESION,
	adhe_cntrt.ref_ext		lib_idadhesion,
	contrat.refcie			refcie,
	gar_cntrt.libelle		lib_numfor
from	repartition,
	contrat,
	adhe_cntrt,
	gar_cntrt
where	contrat.numgar		= adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= repartition.idadhesion
and	gar_cntrt.numfor	= repartition.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REPARTITION FOR ARTHUS.V_REPARTITION
