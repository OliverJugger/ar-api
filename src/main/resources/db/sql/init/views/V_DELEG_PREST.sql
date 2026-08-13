CREATE FORCE VIEW ARTHUS.V_DELEG_PREST AS
Select	apporteur.numindiv,
	apporteur.cle,
	apporteur.debut,
	apporteur.fin,
	ARTHUS.pk_histo_contrat.f_sel_etat( contrat.numgar )	etat_contrat,
	indvs.nom,
	indvs.prenom
From	indvs,
	contrat,
	apporteur
Where	indvs.numindiv = apporteur.numindiv
and	contrat.deleg_prest = apporteur.numindiv
and	contrat.numgar = apporteur.cle
and	apporteur.etendue = 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DELEG_PREST FOR ARTHUS.V_DELEG_PREST
