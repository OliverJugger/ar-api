CREATE FORCE VIEW ARTHUS.V_QG21 AS
select	grnts.numinterm						numsoc,
	grnts.numorg,
	orgns.nom						nom_org,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom			nom_cli,
	indvs_assu.nom || ' '|| indvs_assu.prenom		nom_assu,
	nvl(grnts.refcie_chapeau,'Pas de regroupement')		refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	qttc_global.numquit,
	qttc_global.comptant					type,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YY')			qttc_efin,
	qttc_global.numindiv					numassu,
	qttc_global.mt_ttc,
	emission.datemis,
	to_char(emission.datemis,'dd/mm/yy')			edatemis,
	facture.mregl						mregl,
	facture.echeance,
	to_char(facture.echeance,'dd/mm/yy')			eecheance,
	mregl.libelle						lib_mregl
from	emission,
	facture,
	qttc_global,
	grnts,
	indvs indvs_assu,
	indvs indvs_cli,
	libelle mregl,
	orgns
where	emission.codope	= 4
and	emission.type_doc	= 1
and	emission.numrelance	= 0
and	emission.numfact	= qttc_global.numquit
and	facture.codope	= 4
and	facture.numfact	= qttc_global.numquit
and	qttc_global.comptant	!= 'R'
and	grnts.numgar = qttc_global.numgar
and	indvs_assu.numindiv  	= qttc_global.numindiv
and	indvs_cli.numindiv  	= grnts.numcli
and	mregl.mnemo		= 'MREGL'
and	mregl.code		= facture.mregl
and	orgns.numorg		= grnts.numorg
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QG21 FOR ARTHUS.V_QG21
