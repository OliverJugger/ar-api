CREATE FORCE VIEW ARTHUS.V_PR04 AS
select
	produit.numprod,
	produit.libelle lib_numprod,
	orgns.numorg,
	orgns.nom lib_numorg,
	contrat.numgar,
	contrat.refcie lib_numgar,
	histo_adhesion.idadhesion,
	adhe_cntrt.ref_ext,
	adhe_cntrt.numadhe,
	indvs.nom||' '||indvs.prenom lib_numadhe,
	adhe_cntrt.numutil,
	util.nom lib_numutil,
	adhe_cntrt.date_adhe,
	adhe_cntrt.dsous,
	histo_adhesion.debut,
	histo_adhesion.datsai,
	histo_adhesion.etat,
	libetat.libelle lib_etat,
	histo_adhesion.motif,
	libmotif.libelle lib_motif,
	decode(contrat.typgar,2,contrat.refcie,
				adhe_cntrt.ref_ext) lib_adhesion
from
	produit,
	orgns,
	contrat,
	indvs,
	util,
	adhe_cntrt,
	histo_adhesion,
	libelle	libetat,
	libelle	libmotif
where
	produit.numprod=contrat.numprod +0
and	contrat.numorg +0 =orgns.numorg
and	contrat.numgar=adhe_cntrt.numgar
and	adhe_cntrt.numadhe=indvs.numindiv
and	adhe_cntrt.numutil=util.numutil
and	adhe_cntrt.idadhesion=histo_adhesion.idadhesion
and	libetat.mnemo='ET_ADHE'
and	libetat.code=histo_adhesion.etat
and	libmotif.mnemo='HISTO_ADHE'
and	libmotif.code=histo_adhesion.motif
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PR04 FOR ARTHUS.V_PR04
