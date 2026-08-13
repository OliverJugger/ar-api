CREATE FORCE VIEW ARTHUS.V_QTTC_ANNEXE AS
Select	numquit,
	1					ordre,
	type_taxe				type,
	ARTHUS.pk_libelle.f_lib( 'TYPTAX', type_taxe )	libelle,
	Sum(montant)				montant,
	f_mt_affec_tfc_numquit(numquit, 1, type_taxe)		mt_affec,
	Sum(montant_d)				montant_d,
	f_mt_affec_tfc_numquit_d(numquit, 1, type_taxe)	mt_affec_d,
	monnaie,
	monnaie_d
From	qttc_taxe
Group By
	numquit,
	type_taxe,
	monnaie,
	monnaie_d
Union
Select	numquit,
	2					ordre,
	type_frais				type,
	ARTHUS.pk_libelle.f_lib( 'FRAISGAR', type_frais )	libelle,
	Sum(montant)				montant,
	f_mt_affec_tfc_numquit(numquit, 3, type_frais)		mt_affec,
	Sum(montant_d)				montant_d,
	f_mt_affec_tfc_numquit_d(numquit, 3, type_frais)	mt_affec_d,
	monnaie,
	monnaie_d
From	qttc_frais
Where	numfor != 0
Group By
	numquit,
	type_frais,
	monnaie,
	monnaie_d
Union
Select	numquit,
	3					ordre,
	type_comm				type,
	ARTHUS.pk_libelle.f_lib( 'TYPCOMM', type_comm )	libelle,
	Sum(montant)				montant,
	f_mt_affec_tfc_numquit(numquit, 2, type_comm)		mt_affec,
	Sum(montant_d)				montant_d,
	f_mt_affec_tfc_numquit_d(numquit, 2, type_comm)		mt_affec_d,
	monnaie,
	monnaie_d
From	qttc_comm
Group By
	numquit,
	type_comm,
	monnaie,
	monnaie_d
Union
Select	numquit,
	4					ordre,
	type_comm				type,
	ARTHUS.pk_libelle.f_lib( 'TYPRETRO', type_comm )	libelle,
	Sum(montant)				montant,
	f_mt_affec_tfc_numquit(numquit, 5, type_comm) mt_affec,
	Sum(montant_d)				montant_d,
	f_mt_affec_tfc_numquit_d(numquit, 5, type_comm)		mt_affec_d,
	monnaie,
	monnaie_d
From	qttc_retro
Group By
	numquit,
	type_comm,
	monnaie,
	monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_ANNEXE FOR ARTHUS.V_QTTC_ANNEXE
