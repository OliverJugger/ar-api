CREATE FORCE VIEW ARTHUS.V_SITU_ADHE AS
Select
	contrat.numgar,
	contrat.refcie,
	f_etat_adhe(adhe_cntrt.idadhesion,sysdate,1) etat,
	adhe_cntrt.idadhesion,
	adhe_cntrt.ref_ext,
	j2d(f_etat_adhe(adhe_cntrt.idadhesion,sysdate,3)) debut,
	adhe_cntrt.numadhe,
	indvs.nom
From	indvs,adhe_cntrt,contrat
Where	adhe_cntrt.numgar=contrat.numgar
And	adhe_cntrt.numadhe=indvs.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SITU_ADHE FOR ARTHUS.V_SITU_ADHE
