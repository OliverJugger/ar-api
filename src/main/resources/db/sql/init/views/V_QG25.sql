CREATE FORCE VIEW ARTHUS.V_QG25 AS
select	distinct grnts.numinterm				numsoc,
	grnts.numorg,
	orgns.nom						nom_org,
	grnts.numprod,
	produit.libelle						nomprod,
	grnts.numcli,
	indvs_cli.nom || ' '|| indvs_cli.prenom			nom_cli,
	nvl(ltrim(indvs_assu.nom || ' '|| indvs_assu.prenom),
		 indvs_cli.nom || ' '|| indvs_cli.prenom)	nom_assu,
	nvl(grnts.refcie_chapeau,'Pas de regroupement')		refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	to_char(qttc_global.debut,'yy')				exercice,
	qttc_global.numindiv					numassu,
	qttc_global.idadhesion					,
	adhe_cntrt.ref_ext
from	grnts,
	adhe_cntrt,
	qttc_global,
	indvs indvs_assu,
	indvs indvs_cli,
	orgns,
	produit
where	grnts.numgar 		= qttc_global.numgar
and	indvs_assu.numindiv (+)  	= qttc_global.numindiv
and	grnts.numgar		= adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= qttc_global.idadhesion
and	indvs_cli.numindiv  	= grnts.numcli
and	produit.numprod		= grnts.numprod
and	orgns.numorg		= grnts.numorg
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QG25 FOR ARTHUS.V_QG25
