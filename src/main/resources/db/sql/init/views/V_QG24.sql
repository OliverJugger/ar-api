CREATE FORCE VIEW ARTHUS.V_QG24 AS
select	grnts.numinterm						numsoc,
	grnts.numorg,
	orgns.nom						nom_org,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom			nom_cli,
	indvs_assu.nom || ' '|| indvs_assu.prenom		nom_assu,
	adhe_cntrt.ref_ext||' - '||qttc_global.numindiv||' - '
	||indvs_assu.nom || ' '|| indvs_assu.prenom		ref_assu,
	nvl(grnts.refcie_chapeau,'Pas de regroupement')		refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	adhe_cntrt.ref_ext,
	qttc_global.numquit,
	qttc_global.idadhesion,
	qttc_global.comptant					type,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YY')			qttc_efin,
	qttc_global.numindiv					numassu,
	qttc_global.mt_ttc - nvl(qttc_global.mt_affec, 0)	mt_ttc,
	qttc_global.datemis,
	to_char(qttc_global.datemis,'dd/mm/yy')			edatemis,
	facture.mregl						mregl,
	facture.echeance,
	to_char(facture.echeance,'dd/mm/yy')			eecheance,
	mregl.libelle						lib_mregl
from	libelle mregl,
	orgns,
	indvs indvs_assu,
	indvs indvs_cli,
	grnts,
	facture,
	adhe_cntrt,
	qttc_global
where	mregl.mnemo		= 'MREGL'
and	mregl.code		= facture.mregl
and	orgns.numorg		= grnts.numorg
and	indvs_assu.numindiv  	= qttc_global.numindiv
and	indvs_cli.numindiv  	= grnts.numcli
and	grnts.numgar = qttc_global.numgar
and	adhe_cntrt.idadhesion  = qttc_global.idadhesion
and	facture.codope	= 4
and	facture.numfact	= qttc_global.numquit
and	qttc_global.comptant	!= 'R'
and	qttc_global.type_qttc	!= 3
and not exists (
	select	1
	from	emission
	where	emission.codope	= 4
	and	emission.type_doc	= 1
	and	emission.numrelance	= 0
	and	emission.numfact	= qttc_global.numquit)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QG24 FOR ARTHUS.V_QG24
