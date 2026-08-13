CREATE FORCE VIEW ARTHUS.V_EMPRUNTEUR AS
Select	pret.idpret,
	pret.montant,
	emprunteur.numindiv,
	indvs.nom 				nom,
	indvs.prenom				prenom,
	emprunteur.type,
	ARTHUS.pk_pret.f_fin_pret( pret.idpret )	fin_pret,
	ARTHUS.pk_pret.f_situ_pret( pret.idpret, Sysdate, 1 )
						situation,
	ARTHUS.pk_pret.f_mt_assure( emprunteur.idpret, emprunteur.numindiv )
						mt_assure,
	ARTHUS.pk_pret.f_mt_restant( emprunteur.idpret, emprunteur.numindiv )
						mt_restant
From	indvs,
	emprunteur,
	pret
Where	indvs.numindiv = emprunteur.numindiv
and	emprunteur.idpret = pret.idpret
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EMPRUNTEUR FOR ARTHUS.V_EMPRUNTEUR
