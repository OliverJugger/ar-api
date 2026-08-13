CREATE FORCE VIEW ARTHUS.V_CRIT_SP_ADHE AS
select	contrat.refcie,
	contrat.numgar,
	contrat.numinterm numsoc,
	substr(translate(societe.nom,'.','@'),1,20) nomsoc,
	contrat.numorg,
	substr(replace(orgns.nom,'.','@'),1,20) nomorg,
	contrat.numcli,
	substr(translate(indvs.nom,'.','@'),1,20) nomcli,
	contrat.numprod,
	substr(translate(produit.libelle,'.','@'),1,20) libprod,
	contrat.dateff,
	gar_cntrt.numfor,
	substr(translate(gar_cntrt.libelle,'.','@'),1,35) libelle,
	gar_cntrt.type,
	adhe_cntrt.idadhesion,
	substr(translate(adhe_cntrt.ref_ext,'.','@'),1,35) lib_adhesion,
	adhe_cntrt.numadhe,
	substr(translate(a.nom,'.','@'),1,20)||' '||
		substr(translate(a.prenom,'.','@'),1,20) nomadhe,
	adhe_cntrt.date_adhe,
	adhe_cntrt.date_fin_adhe
from	contrat,
	indvs,
	indvs a,
	societe,
	produit,
	orgns,
	gar_cntrt,
	adhe_cntrt
where indvs.numindiv=contrat.numcli
and a.numindiv=adhe_cntrt.numadhe
and contrat.numgar=gar_cntrt.numgar
and societe.numsoc=contrat.numinterm
and produit.numprod=contrat.numprod
and orgns.numorg=contrat.numorg
and contrat.numgar=adhe_cntrt.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CRIT_SP_ADHE FOR ARTHUS.V_CRIT_SP_ADHE
