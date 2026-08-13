CREATE FORCE VIEW ARTHUS.V_DOSSIER_PRET AS
Select	pret.idpret,
	pret.montant,
	emprunteur.numindiv,
	ARTHUS.pk_pret.f_situ_pret( pret.idpret, Sysdate, 1 )	situation,
	ARTHUS.pk_pret.f_situ_pret( pret.idpret, Sysdate, 2 )	motif,
	indvs.nom					nom,
	indvs.prenom					prenom
From	indvs,
	emprunteur,
	pret
Where	indvs.numindiv = emprunteur.numindiv
and	emprunteur.type = 1
and	emprunteur.idpret = pret.idpret
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DOSSIER_PRET FOR ARTHUS.V_DOSSIER_PRET
