CREATE FORCE VIEW ARTHUS.V_PRETEUR AS
Select	pret.idpret,
	pret.montant,
	pers_banque.numindiv banque,
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
	pers_banque,
	emprunteur,
	pret
Where	indvs.numindiv = emprunteur.numindiv
and	pers_banque.numindiv = pret.preteur
and	emprunteur.idpret = pret.idpret
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRETEUR FOR ARTHUS.V_PRETEUR
