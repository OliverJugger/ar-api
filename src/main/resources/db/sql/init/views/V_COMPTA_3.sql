CREATE FORCE VIEW ARTHUS.V_COMPTA_3 AS
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture.numfact			cle_unique,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	1				type_ope,
	contrat.numorg			cie,
	qttc_global.numquerable 	indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	qttc_global.debut 		dat_piece,
	qttc_global.numquit		lib_piece_1,
	qttc_global.numquerable		lib_piece_2,
	ARTHUS.pk_funct.f_arrondi(4, qttc_global.numquit, qttc_global.mt_ttc)
					montant1,
	0				montant2,
	0				montant3,
	0				montant4,
	0				montant5,
	ARTHUS.pk_funct.f_arrondi(4, qttc_global.numquit, qttc_global.mt_ttc)
		- qttc_global.mt_ttc 	montant6
From
	contrat,
	qttc_global,
	facture
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.numquit	= facture.numfact
and	facture.codope		= 4
and	Exists (
	Select	1
	from	emission
	Where	emission.codope = 4
	and	emission.numfact = qttc_global.numquit )
Union All
--			Emission - Par garantie
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture.numfact			cle_unique,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	1				type_ope,
	f_assureur(qttc_gar.numfor)	cie,
	qttc_global.numquerable 	indv,
	qttc_gar.numfor 		gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	qttc_global.debut 		dat_piece,
	qttc_global.numquit		lib_piece_1,
	qttc_global.numquerable		lib_piece_2,
	0				montant1,
	sum( ARTHUS.pk_cotis.totbrut(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant2,
	sum( ARTHUS.pk_cotis.tottaxe(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant3,
	sum( ARTHUS.pk_cotis.totfrais(qttc_gar.numquit, qttc_gar.numfor, '', 0) ) 							montant4,
	sum( ARTHUS.pk_cotis.totcomm(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant5,
	0 				montant6
From
	contrat,
	qttc_global,
	facture,
	qttc_gar
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.numquit	= facture.numfact
and	qttc_gar.numquit	= qttc_global.numquit
and	facture.codope		= 4
and	Exists (
	Select	1
	from	emission
	Where	emission.codope = 4
	and	emission.numfact = qttc_global.numquit )
group by
	contrat.numinterm,
	facture.idcompta,
	f_assureur(qttc_gar.numfor),
	qttc_global.numquerable,
	qttc_gar.numfor,
	qttc_global.numquit,
	qttc_global.debut,
	'facture',
	facture.numfact
Union All
--			Emission - Frais Niv global
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture.numfact			cle_unique,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	1				type_ope,
	contrat.numorg			cie,
	qttc_global.numquerable 	indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	qttc_global.debut 		dat_piece,
	qttc_global.numquit		lib_piece_1,
	qttc_global.numquerable		lib_piece_2,
	0				montant1,
	0 				montant2,
	0 				montant3,
	sum( ARTHUS.pk_cotis.totfrais(qttc_global.numquit, 0) ) 								montant4,
	0 				montant5,
	0 				montant6
From
	contrat,
	qttc_global,
	facture
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.numquit	= facture.numfact
and	facture.codope		= 4
and	Exists (
	Select	1
	from	emission
	Where	emission.codope = 4
	and	emission.numfact = qttc_global.numquit )
group by
	contrat.numinterm,
	facture.idcompta,
	contrat.numorg,
	qttc_global.numquerable,
	qttc_global.numquit,
	qttc_global.debut,
	'facture',
	facture.numfact
Union All
--			Regularisations - Mt total emis
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture.numfact			cle_unique,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	2				type_ope,
	contrat.numorg			cie,
	qttc_global.numquerable 	indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	qttc_global.debut 		dat_piece,
	facture.numfact			lib_piece_1,
	facture.numcli			lib_piece_2,
	-ARTHUS.pk_funct.f_arrondi(4, qttc_global.numquit, qttc_global.mt_ttc)
					montant1,
	0				montant2,
	0				montant3,
	0				montant4,
	0				montant5,
	-1 * (ARTHUS.pk_funct.f_arrondi(4, qttc_global.numquit, qttc_global.mt_ttc)
		- qttc_global.mt_ttc) 	montant6
From
	contrat,
	qttc_global,
	facture
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.comptant = 'R'
and	qttc_global.numquit	= facture.numfact
and	facture.codope		= 4
Union All
--			Regularisations - Par garantie
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture.numfact			cle_unique,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	2				type_ope,
	f_assureur(qttc_gar.numfor)	cie,
	qttc_global.numquerable 	indv,
	qttc_gar.numfor 		gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	qttc_global.debut 		dat_piece,
	facture.numfact			lib_piece_1,
	facture.numcli			lib_piece_2,
	0				montant1,
	-sum( ARTHUS.pk_cotis.totbrut(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant2,
	-sum( ARTHUS.pk_cotis.tottaxe(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant3,
	-sum( ARTHUS.pk_cotis.totfrais(qttc_gar.numquit, qttc_gar.numfor, '', 0) ) 							montant4,
	-sum( ARTHUS.pk_cotis.totcomm(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant5,
	0 				montant6
From
	contrat,
	qttc_global,
	facture,
	qttc_gar
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_gar.numquit	= qttc_global.numquit
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.comptant = 'R'
and	qttc_global.numquit	= facture.numfact
and	facture.codope		= 4
group by
	contrat.numinterm,
	facture.idcompta,
	f_assureur(qttc_gar.numfor),
	qttc_global.numquerable,
	qttc_gar.numfor,
	facture.numfact,
	qttc_global.debut,
	facture.numcli,
	'facture',
	facture.numfact
Union All
--			Regularisations - Frais Niv global
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture.numfact			cle_unique,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	2				type_ope,
	contrat.numorg			cie,
	qttc_global.numquerable 	indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	qttc_global.debut 		dat_piece,
	facture.numfact			lib_piece_1,
	facture.numcli			lib_piece_2,
	0				montant1,
	0 				montant2,
	0 				montant3,
	-sum( ARTHUS.pk_cotis.totfrais(qttc_global.numquit, 0) ) 								montant4,
	0 				montant5,
	0 				montant6
From
	contrat,
	qttc_global,
	facture
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.comptant = 'R'
and	qttc_global.numquit	= facture.numfact
and	facture.codope		= 4
group by
	contrat.numinterm,
	facture.idcompta,
	contrat.numorg,
	qttc_global.numquerable,
	facture.numfact,
	qttc_global.debut,
	facture.numcli,
	'facture',
	facture.numfact
Union All
--			Annulations - Mt total emis
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture_annul.numfact			cle_unique,
	'fact_annul'			entite,
	facture_annul.numfact			cle,
	facture_annul.idcompta		idcompta,
	3 				codope,
	3				type_ope,
	contrat.numorg			cie,
	qttc_global.numquerable 	indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture_annul.numfact, '00000000'), 2, 8 )
					refpiece,
	facture_annul.datope 		dat_piece,
	facture_annul.numfact			lib_piece_1,
	qttc_global.numquerable			lib_piece_2,
	-ARTHUS.pk_funct.f_arrondi(4, qttc_global.numquit, qttc_global.mt_ttc)
					montant1,
	0				montant2,
	0				montant3,
	0				montant4,
	0				montant5,
	-1 * (ARTHUS.pk_funct.f_arrondi(4, qttc_global.numquit, qttc_global.mt_ttc)
		- qttc_global.mt_ttc) 	montant6
From
	contrat,
	qttc_global,
	facture_annul
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.numquit	= facture_annul.numfact
and	facture_annul.codope		= 4
Union All
--			Annulations - Par garantie
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture_annul.numfact			cle_unique,
	'fact_annul'			entite,
	facture_annul.numfact			cle,
	facture_annul.idcompta		idcompta,
	3 				codope,
	3				type_ope,
	f_assureur(qttc_gar.numfor)	cie,
	qttc_global.numquerable 	indv,
	qttc_gar.numfor 		gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture_annul.numfact, '00000000'), 2, 8 )
					refpiece,
	facture_annul.datope 		dat_piece,
	facture_annul.numfact			lib_piece_1,
	qttc_global.numquerable			lib_piece_2,
	0				montant1,
	-sum( ARTHUS.pk_cotis.totbrut(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant2,
	-sum( ARTHUS.pk_cotis.tottaxe(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant3,
	-sum( ARTHUS.pk_cotis.totfrais(qttc_gar.numquit, qttc_gar.numfor, '', 0) ) 							montant4,
	-sum( ARTHUS.pk_cotis.totcomm(qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv) ) 							montant5,
	0 				montant6
From
	contrat,
	qttc_gar,
	qttc_global,
	facture_annul
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_gar.numquit	= qttc_global.numquit
and	qttc_global.numquit	= facture_annul.numfact
and	facture_annul.codope		= 4
group by
	contrat.numinterm,
	facture_annul.idcompta,
	f_assureur(qttc_gar.numfor),
	qttc_global.numquerable,
	qttc_gar.numfor,
	facture_annul.numfact,
	facture_annul.datope
Union All
--			Annulation - Frais Niv global
Select	contrat.numinterm 		numsoc,
	'qttc'				sur_entite,
	facture_annul.numfact			cle_unique,
	'fact_annul'			entite,
	facture_annul.numfact			cle,
	facture_annul.idcompta		idcompta,
	3 				codope,
	3				type_ope,
	contrat.numorg			cie,
	qttc_global.numquerable 	indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture_annul.numfact, '00000000'), 2, 8 )
					refpiece,
	facture_annul.datope 		dat_piece,
	facture_annul.numfact			lib_piece_1,
	qttc_global.numquerable			lib_piece_2,
	0				montant1,
	0 				montant2,
	0 				montant3,
	- ARTHUS.pk_cotis.totfrais(qttc_global.numquit, 0) 								montant4,
	0 				montant5,
	0 				montant6
From
	contrat,
	qttc_global,
	facture_annul
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.numquit	= facture_annul.numfact
and	facture_annul.codope		= 4
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_3 FOR ARTHUS.V_COMPTA_3
