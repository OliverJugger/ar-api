CREATE FORCE VIEW ARTHUS.V_COTIS_EXO_INDIV AS
select
	indvs.numindiv						numadhe,
	indvs.nom || ' '|| indvs.prenom				nom_adhe,
	qttc_global.idadhesion,
	adhe_cntrt.ref_ext,
	qttc_global.numgar,
	qttc_global.numindiv,
	to_char(qttc_global.debut,'yyyy')				exercice
from
	indvs,
	adhe_cntrt,
	qttc_global
Where	indvs.numindiv  	= adhe_cntrt.numadhe
and	adhe_cntrt.idadhesion  	= qttc_global.idadhesion
and	nvl(adhe_cntrt.date_fin_adhe,qttc_global.debut+1)>qttc_global.debut
and	qttc_global.comptant	!= 'R'
and	qttc_global.type_qttc	!= 3
Group by
	indvs.numindiv,
	indvs.nom || ' '|| indvs.prenom,
	qttc_global.idadhesion,
	adhe_cntrt.ref_ext,
	qttc_global.numindiv,
	qttc_global.numgar,
	to_char(qttc_global.debut,'yyyy')
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COTIS_EXO_INDIV FOR ARTHUS.V_COTIS_EXO_INDIV
