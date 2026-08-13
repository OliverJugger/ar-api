CREATE FORCE VIEW ARTHUS.V_IEMIE AS
select	pers_societe.numsoc,
	pers_organisme.numorg,
	ARTHUS.pk_personne.f_nom(pers_societe.numindiv)	nom_soc,
	ARTHUS.pk_personne.f_nom(pers_organisme.numindiv)	nom_org
From	pers_societe,
	pers_organisme
Where	pers_societe.numsoc < 5
GO
CREATE OR REPLACE PUBLIC SYNONYM V_IEMIE FOR ARTHUS.V_IEMIE
