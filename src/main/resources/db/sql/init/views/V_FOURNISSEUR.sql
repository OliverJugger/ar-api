CREATE FORCE VIEW ARTHUS.V_FOURNISSEUR AS
Select	indvs.numindiv,
	indvs.nom,
	indvs.prenom
From	indvs,
	pers_intermediaire
where	indvs.numindiv = pers_intermediaire.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FOURNISSEUR FOR ARTHUS.V_FOURNISSEUR
