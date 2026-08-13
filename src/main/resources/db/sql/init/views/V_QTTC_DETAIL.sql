CREATE FORCE VIEW ARTHUS.V_QTTC_DETAIL AS
select	grnts.numinterm						numsoc,
	grnts.numorg,
	orgns.nom						nom_org,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom			nom_cli,
	nvl(grnts.refcie_chapeau,'Pas de regroupement')		refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	qttc_gar.numquit,
	to_char(qttc_gar.debut,'DD/MM/YY')			qttc_edebut,
	to_char(qttc_gar.fin  ,'DD/MM/YY')			qttc_efin,
	qttc_gar.numindiv,
	indvs_bene.nom ||' '|| indvs_bene.prenom		bene_nom,
	adhe_cntrt.ref_ext 					ref_adhesion,
	qttc_gar.numfor,
	gar_cntrt.libelle					lib_gar,
	qttc_gar.mt_ttc
from	orgns,
	indvs indvs_cli,
	indvs indvs_bene,
	contrat grnts,
	adhe_cntrt,
	gar_cntrt,
	qttc_global,
	qttc_gar
Where	orgns.numorg		= grnts.numorg + 0
and	indvs_cli.numindiv  (+)	= grnts.numcli + 0
and	grnts.numgar		= qttc_global.numgar
and	qttc_global.etendue	> 1
and	qttc_global.comptant	!= 'R'
and	qttc_global.type_qttc	!= 3
and	qttc_global.numquit	= qttc_gar.numquit
and	gar_cntrt.numfor	= qttc_gar.numfor
and	qttc_gar.debut between adhe_cntrt.date_adhe
		and	nvl(adhe_cntrt.date_fin_adhe, qttc_gar.debut)
and	adhe_cntrt.date_adhe != nvl(adhe_cntrt.date_fin_adhe, adhe_cntrt.date_adhe + 1)
and	adhe_cntrt.numgar	= grnts.numgar
and	adhe_cntrt.numadhe	= indvs_bene.numassu
and	indvs_bene.numindiv 	= qttc_gar.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_DETAIL FOR ARTHUS.V_QTTC_DETAIL
