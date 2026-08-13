CREATE FORCE VIEW ARTHUS.V_REPARTITION_BENE AS
select
	repartition.NOSIN,
	adhe_cntrt.NUMGAR,
	repartition.NUMFOR,
	repartition_bene.NUMBENE,
	repartition_bene.pourcent	POURC,
	''	NBUC,
	repartition.type_calc	TYPE,
	repartition_bene.debut	DATAPLI,
	repartition_bene.fin	DATPER,
	to_number('')	NUMFORBIS,
	repartition_bene.valide	VALID,
	0	TYPADR,
	0	NOGAR,
	0	NOGARBIS,
	repartition_bene.ECHESUIV,
	repartition.PERIODE,
	repartition_bene.traite	TRAIT,
	0	TYP_DEPEND,
	repartition.IDADHESION,
	repartition.IDREPARTITION
from	adhe_cntrt,
	repartition,
	repartition_bene
where	adhe_cntrt.idadhesion = repartition.idadhesion
and	repartition_bene.idrepartition = repartition.idrepartition
and	repartition.valide = 'O'
and	repartition_bene.valide = 'O'
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REPARTITION_BENE FOR ARTHUS.V_REPARTITION_BENE
