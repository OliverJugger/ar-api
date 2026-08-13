CREATE FORCE VIEW ARTHUS.V_GA19 AS
select 	distinct
	adhesion.numindiv,
	adhesion.idadhesion,
	adhesion.numgar,
	indvs.nom||' '||prenom				nom_prenom,
	contrat.refcie					refcie_cntrt,
	adhe_cntrt.ref_ext				refcie_adhe,
	to_char(adhe_cntrt.date_adhe,'dd/mm/yyyy')	edate_adhe
from	adhesion,
	contrat,
	indvs,
	adhe_cntrt
where	adhesion.idadhesion = adhe_cntrt.idadhesion (+)
and	adhesion.numindiv = indvs.numindiv
and	contrat.numgar = adhesion.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GA19 FOR ARTHUS.V_GA19
