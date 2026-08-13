CREATE FORCE VIEW ARTHUS.V_CRIT_SP AS
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
	gar_cntrt.numfor_ref numfor_ref,
	substr(translate(gar_cntrt.libelle,'.','@'),1,35) libelle,
	substr(translate(frmls.libelle,'.','@'),1,35) libelle_ref,
	gar_cntrt.type
from	contrat,
	indvs,
	societe,
	produit,
	orgns,
	frmls,
	gar_cntrt
where indvs.numindiv=contrat.numcli
and contrat.numgar=gar_cntrt.numgar
and societe.numsoc=contrat.numinterm
and produit.numprod=contrat.numprod
and orgns.numorg=contrat.numorg
and gar_cntrt.numfor_ref=frmls.numfor
Union
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
	gar_cntrt.numfor_ref numfor_ref,
	substr(translate(gar_cntrt.libelle,'.','@'),1,35) libelle,
	substr(translate(garanties.libelle,'.','@'),1,35) libelle_ref,
	gar_cntrt.type
from	contrat,
	indvs,
	societe,
	produit,
	orgns,
	garanties,
	gar_cntrt
where indvs.numindiv=contrat.numcli
and contrat.numgar=gar_cntrt.numgar
and societe.numsoc=contrat.numinterm
and produit.numprod=contrat.numprod
and orgns.numorg=contrat.numorg
and gar_cntrt.numfor_ref=garanties.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CRIT_SP FOR ARTHUS.V_CRIT_SP
