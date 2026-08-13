CREATE FORCE VIEW ARTHUS.V_DOSSIER_SIN_CONTRAT AS
select 	distinct adhe_cntrt.numgar,
		dossier_sinistre.numindiv,
		dossier_sinistre.iddossier,
		dossier_sinistre.ref_ext,
		dossier_sinistre.numutil,
		dossier_sinistre.debut,
		dossier_sinistre.fin,
		dossier_sinistre.cloture
	from	dossier_sinistre,
		sntr_prev,
	        adhe_cntrt
	where 	sntr_prev.iddossier=dossier_sinistre.iddossier
	and 	f_idadhesion_prev(sntr_prev.nosin) = adhe_cntrt.idadhesion
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DOSSIER_SIN_CONTRAT FOR ARTHUS.V_DOSSIER_SIN_CONTRAT
