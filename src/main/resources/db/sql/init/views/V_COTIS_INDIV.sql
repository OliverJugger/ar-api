CREATE FORCE VIEW ARTHUS.V_COTIS_INDIV AS
select	grnts.numinterm						numsoc,
	societe.nom						nom_soc,
	indvs.numindiv						numadhe,
	indvs.nom || ' '|| indvs.prenom				nom_adhe,
	nvl(grnts.refcie_chapeau,'N')				refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	adhe_cntrt.ref_ext,
	qttc_global.numquit,
	qttc_global.idadhesion,
	decode(qttc_global.comptant,'C','Comptant','N','Terme','A','Terme',
		qttc_global.comptant)					type,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YYYY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YYYY')			qttc_efin,
	qttc_global.mt_ttc 					mt_ttc,
	qttc_global.datemis,
	to_char(qttc_global.datemis,'dd/mm/yyyy')		edatemis,
	facture.mregl,
	mregl.libelle,
	qttc_global.comptant					type_appel
from	libelle mregl,
	societe,
	indvs,
	grnts,
	adhe_cntrt,
	facture,
	qttc_global
where	mregl.mnemo		= 'MREGL'
and	mregl.code		= facture.mregl
and	societe.numsoc		= grnts.numinterm
and	indvs.numindiv  	= adhe_cntrt.numadhe
and	grnts.numgar 		= adhe_cntrt.numgar
and	grnts.typequit		= 2
and	adhe_cntrt.idadhesion  	= qttc_global.idadhesion
and	nvl(adhe_cntrt.date_fin_adhe,qttc_global.debut+1)>qttc_global.debut
and	facture.codope		= 4
and	facture.numfact		= qttc_global.numquit
and	qttc_global.comptant	!= 'R'
and	qttc_global.type_qttc	!= 3
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COTIS_INDIV FOR ARTHUS.V_COTIS_INDIV
