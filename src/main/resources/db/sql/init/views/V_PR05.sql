CREATE FORCE VIEW ARTHUS.V_PR05 AS
select
	contrat.numgar,
	contrat.refcie lib_numgar,
	adhe_cntrt.idadhesion,
	adhe_cntrt.ref_ext,
	adhe_cntrt.numadhe,
	indvs.nom||' '||indvs.prenom lib_numadhe,
	adhe_cntrt.dsous	date_adhe,
	max(histo_adhesion.datsai) datsai,
	adhe_cntrt.numutil,
	util.nom lib_numutil
from
	contrat,
	indvs,
	util,
	adhe_cntrt,
	histo_adhesion
where 	contrat.numgar=adhe_cntrt.numgar
and	adhe_cntrt.numadhe=indvs.numindiv
and	adhe_cntrt.numutil=util.numutil
and	adhe_cntrt.idadhesion=histo_adhesion.idadhesion
group by
	contrat.numgar,
	contrat.refcie,
	adhe_cntrt.idadhesion,
	adhe_cntrt.ref_ext,
	adhe_cntrt.numadhe,
	indvs.nom||' '||indvs.prenom,
	adhe_cntrt.dsous,
	adhe_cntrt.numutil,
	util.nom
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PR05 FOR ARTHUS.V_PR05
