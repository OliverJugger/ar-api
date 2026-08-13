CREATE FORCE VIEW ARTHUS.V_CRITERE_INDIV AS
select	grnts.numinterm						numsoc,
	societe.nom						nom_soc,
	adhe_cntrt.numadhe					numadhe,
	indvs.nom || ' '|| indvs.prenom				nom_adhe,
	nvl(grnts.refcie_chapeau,'N')				refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	adhe_cntrt.ref_ext,
	adhe_cntrt.idadhesion,
	adhe_cntrt.date_fin_adhe
from	societe,
	indvs,
	grnts,
	adhe_cntrt
where	societe.numsoc		= grnts.numinterm
and	indvs.numindiv  	= adhe_cntrt.numadhe
and	grnts.numgar 		= adhe_cntrt.numgar
and	grnts.typequit		= 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CRITERE_INDIV FOR ARTHUS.V_CRITERE_INDIV
