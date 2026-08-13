CREATE FORCE VIEW ARTHUS.V_ADHE_CNTRT AS
select	adhe_cntrt.idadhesion,
	adhe_cntrt.ref_ext,
	adhe_cntrt.numgar,
	contrat.refcie,
	adhe_cntrt.numadhe,
	indvs.nom,
	indvs.prenom
from	indvs,
	contrat,
	adhe_cntrt
where	indvs.numindiv	= adhe_cntrt.numadhe
and	contrat.numgar	= adhe_cntrt.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ADHE_CNTRT FOR ARTHUS.V_ADHE_CNTRT
