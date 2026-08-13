CREATE FORCE VIEW ARTHUS.QUALEA_V_DOSSIER_SIN_CONTRAT AS
select 	adhe_cntrt.numgar,
		dossier_sinistre.numindiv,
		dossier_sinistre.iddossier,
		dossier_sinistre.ref_ext,
		dossier_sinistre.numutil,
		dossier_sinistre.debut,
		dossier_sinistre.fin,
		dossier_sinistre.cloture
	from	dossier_sinistre,
		sntr_prev,
	        adhe_cntrt,repartition r
	where 	sntr_prev.iddossier=dossier_sinistre.iddossier
	and 	r.idadhesion= adhe_cntrt.idadhesion
	and 	sntr_prev.nosin= r.nosin
	and r.valide='O'
GO
CREATE OR REPLACE PUBLIC SYNONYM QUALEA_V_DOSSIER_SIN_CONTRAT FOR ARTHUS.QUALEA_V_DOSSIER_SIN_CONTRAT
