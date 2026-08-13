CREATE FORCE VIEW ARTHUS.V_CORRES_BENE AS
Select
	envoi.numindiv_dest numindiv,
	envoi.numero entite,
	2 contexte
From	envoi
Union
Select
	envoi.numindiv_dest,
	envoi.numero entite,
	8 contexte
From	envoi
Union
Select
	envoi.numindiv_dest,
	envoi.numero entite,
	4 contexte
From	envoi
Union
Select
	envoi.numindiv_dest,
	envoi.numero entite,
	14 contexte
From	envoi
Union
Select
	envoi.numindiv_dest,
	envoi.numero entite,
	7 contexte
From	envoi
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CORRES_BENE FOR ARTHUS.V_CORRES_BENE
