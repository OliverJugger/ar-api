CREATE FORCE VIEW ARTHUS.V_COMPTA_COTIS AS
Select	contrat.numinterm 		numsoc,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	contrat.numorg 			cie,
	qttc_global.numquerable 	indv,
	qttc_gar.numfor 		gar,
	0 				int,
	'' 				bqe,
	to_char(qttc_global.numquit) 	refpiece,
	qttc_global.debut 		dat_piece,
	'CT '||contrat.numgar||' ECH '||
		to_char(qttc_global.numquit)
					lib_ecriture,
	sum( ARTHUS.pk_cotis.totappel(qttc_gar.numquit, qttc_gar.numfor) ) 							montant1,
	sum( ARTHUS.pk_cotis.totbrut(qttc_gar.numquit, qttc_gar.numfor) ) 							montant2,
	sum( ARTHUS.pk_cotis.tottaxe(qttc_gar.numquit, qttc_gar.numfor) ) 							montant3,
	sum( ARTHUS.pk_cotis.totfrais(qttc_gar.numquit, qttc_gar.numfor, '', 0) ) 							montant4,
	sum( ARTHUS.pk_cotis.totcomm(qttc_gar.numquit, qttc_gar.numfor) ) 							montant5,
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
and	ARTHUS.pk_cotis.datemis(qttc_global.numquit) Is Not Null
group by
	contrat.numinterm,
	facture.idcompta,
	contrat.numorg,
	qttc_global.numquerable,
	qttc_gar.numfor,
	qttc_global.numquit,
	qttc_global.debut,
	'CT '||contrat.numgar||' ECH '||
		to_char(qttc_global.numquit),
	'facture',
	facture.numfact
Union All
--			Emission - Frais Niv global
Select	contrat.numinterm 		numsoc,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	contrat.numorg 			cie,
	qttc_global.numquerable 	indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	to_char(qttc_global.numquit) 	refpiece,
	qttc_global.debut 		dat_piece,
	'CT '||contrat.numgar||' ECH '||
		to_char(qttc_global.numquit)
					lib_ecriture,
	sum( ARTHUS.pk_cotis.totfrais(qttc_global.numquit, 0) ) 								montant1,
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
and	ARTHUS.pk_cotis.datemis(qttc_global.numquit) Is Not Null
group by
	contrat.numinterm,
	facture.idcompta,
	contrat.numorg,
	qttc_global.numquerable,
	qttc_global.numquit,
	qttc_global.debut,
	'CT '||contrat.numgar||' ECH '||
		to_char(qttc_global.numquit),
	'facture',
	facture.numfact
Union All
--			Regularisations - Par garantie
Select	contrat.numinterm 		numsoc,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	contrat.numorg 			cie,
	qttc_global.numquerable 	indv,
	qttc_gar.numfor 		gar,
	0 				int,
	'' 				bqe,
	to_char(qttc_global.numquit) 	refpiece,
	qttc_global.debut 		dat_piece,
	'REGUL ECH '||facture_regul.numfact_regul
					lib_ecriture,
	-sum( ARTHUS.pk_cotis.totappel(qttc_gar.numquit, qttc_gar.numfor) ) 							montant1,
	-sum( ARTHUS.pk_cotis.totbrut(qttc_gar.numquit, qttc_gar.numfor) ) 							montant2,
	-sum( ARTHUS.pk_cotis.tottaxe(qttc_gar.numquit, qttc_gar.numfor) ) 							montant3,
	-sum( ARTHUS.pk_cotis.totfrais(qttc_gar.numquit, qttc_gar.numfor, '', 0) ) 							montant4,
	-sum( ARTHUS.pk_cotis.totcomm(qttc_gar.numquit, qttc_gar.numfor) ) 							montant5,
	0 				montant6
From
	contrat,
	qttc_global,
	facture_regul,
	facture,
	qttc_gar
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.numquit	= facture_regul.numfact_regul
and	qttc_gar.numquit	= qttc_global.numquit
and	facture_regul.numfact	= facture.numfact
and	facture_regul.codope	= 4
and	facture.codope		= 4
and	ARTHUS.pk_cotis.datemis(qttc_global.numquit) Is Not Null
group by
	contrat.numinterm,
	facture.idcompta,
	contrat.numorg,
	qttc_global.numquerable,
	qttc_gar.numfor,
	qttc_global.numquit,
	qttc_global.debut,
	'REGUL ECH '||facture_regul.numfact_regul,
	'facture',
	facture.numfact
Union All
--			Regularisations - Frais Niv global
Select	contrat.numinterm 		numsoc,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta		idcompta,
	3 				codope,
	contrat.numorg 			cie,
	qttc_global.numquerable 	indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	to_char(qttc_global.numquit) 	refpiece,
	qttc_global.debut 		dat_piece,
	'REGUL ECH '||facture_regul.numfact_regul
					lib_ecriture,
	-sum( ARTHUS.pk_cotis.totfrais(qttc_global.numquit, 0) ) 								montant1,
	0 				montant2,
	0 				montant3,
	-sum( ARTHUS.pk_cotis.totfrais(qttc_global.numquit, 0) ) 								montant4,
	0 				montant5,
	0 				montant6
From
	contrat,
	qttc_global,
	facture_regul,
	facture
Where	contrat.numgar 		= qttc_global.numgar
and	qttc_global.mt_ttc Is Not Null
and	qttc_global.numquit	= facture_regul.numfact
and	facture_regul.numfact	= facture.numfact
and	facture_regul.codope	= 4
and	facture.codope		= 4
and	ARTHUS.pk_cotis.datemis(qttc_global.numquit) Is Not Null
group by
	contrat.numinterm,
	facture.idcompta,
	contrat.numorg,
	qttc_global.numquerable,
	qttc_global.numquit,
	qttc_global.debut,
	'REGUL ECH '||facture_regul.numfact_regul,
	'facture',
	facture.numfact
Union All	/*
			Encaissement de cotisations
			---------------------------			*/
Select	compte.numsoc,
	'encaismt'			entite,
	encaismt.numencaismt		cle,
	encaismt.idcompta		idcompta,
	encaismt.codope			codope,
	0 				cie,
	0 				indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	to_char(encaismt.numencaismt) 	refpiece,
	encaismt.datpay 		dat_piece,
	mopm.libelle||' ref. '||encaismt.refpmt lib_ecriture,
	encaismt.montant 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	compte,
	libelle mopm,
	encaismt
Where	compte.numcpte		= encaismt.numcpte
and	mopm.code		= encaismt.modpmt
and	mopm.mnemo		= 'MREGL'
and 	Not Exists (
	Select	1
	From	prelevement
	Where	prelevement.numencaismt = encaismt.numencaismt)
and 	Not Exists (
	Select	1
	From	remise_banque
	Where	remise_banque.numencaismt = encaismt.numencaismt)
Union All	/*
			Encaissement de cotisations
				PRELEVEMENT
			---------------------------			*/
Select	compte.numsoc,
	'encaismt'			entite,
	encaismt.numencaismt		cle,
	encaismt.idcompta		idcompta,
	encaismt.codope			codope,
	0 				cie,
	0 				indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_prelev.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_prelev.datrem 		dat_piece,
	'PREL '||to_char(remise_prelev.numremise, '00000000')||' '||
	d2e(remise_prelev.datrem)	 lib_ecriture,
	encaismt.montant 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	compte,
	remise_prelev,
	encaismt
Where	compte.numcpte		= remise_prelev.numcpte
and	encaismt.codope		= 4
and	encaismt.numencaismt in (
	Select	numencaismt
	From	prelevement
	Where	prelevement.numremise = remise_prelev.numremise
	)
Union All	/*
			Encaissement de cotisations
			     REJET PRELEVEMENT
			---------------------------			*/
Select	compte.numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	4 				codope,
	0 				cie,
	0 				indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(compte_client.idaffec, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope 		dat_piece,
	'REJ PREL '||to_char(prelevement.numprelev, '00000000')
					lib_ecriture,
	compte_client.montant 		montant1,
	compte_client.montant		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	compte,
	annul_encais,
	prelevement,
	encaismt,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	prelevement.numencaismt	= annul_encais.numencaismt
and	prelevement.numencaismt = encaismt.numencaismt
and	encaismt.codope		= 4
and	encaismt.numencaismt = compte_client.numencaismt
and	compte_client.montant < 0
Union All	/*
			Encaissement de cotisations
				REMISE BANQUE
			---------------------------			*/
Select	compte.numsoc,
	'encaismt'			entite,
	encaismt.numencaismt		cle,
	encaismt.idcompta		idcompta,
	4 				codope,
	0 				cie,
	0 				indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_globale.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_globale.daterem 		dat_piece,
	'REM CHQ '||to_char(remise_globale.numremise, '00000000')||' '
	||d2e(remise_globale.daterem)	lib_ecriture,
	encaismt.montant 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	compte,
	remise_globale,
	encaismt
Where	compte.numcpte		= remise_globale.numcpte
and	encaismt.codope		= 4
and	encaismt.numencaismt in (
	Select	numencaismt
	From	remise_banque
	Where	remise_banque.numremise = remise_globale.numremise)
Union All	/*
			Affectation de cotisations
				REMISE BANQUE
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	4 				codope,
	contrat.numorg 			cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_globale.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_globale.daterem 		dat_piece,
	'CT '||qttc_global.numgar||' ADH '||qttc_global.numquerable||
	' ECH '||qttc_global.numquit 	lib_ecriture,
	0 				montant1,
	compte_client.montant 		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	compte,
	contrat,
	qttc_global,
	remise_globale,
	encaismt,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	contrat.numgar		= qttc_global.numgar
and	qttc_global.numquit	= compte_client.numfact
and	encaismt.numencaismt	= compte_client.numencaismt
and	compte_client.montant	> 0
and	compte_client.codope	= 4
and	encaismt.numencaismt in (
	Select	numencaismt
	From	remise_banque
	Where	remise_banque.numremise = remise_globale.numremise)
and Not Exists (
	Select	1
	From	idaffec_attente
	Where	idaffec_attente.idaffec = compte_client.idaffec)
and Not Exists (
	Select	1
	From	idaffec_regul
	Where	idaffec_regul.idaffec = compte_client.idaffec)
Union All	/*
			Affectation de cotisations
				PRELEVEMENT
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	4 				codope,
	contrat.numorg 			cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_prelev.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_prelev.datrem 		dat_piece,
	'CT '||qttc_global.numgar||' ADH '||qttc_global.numquerable||
	' ECH '||qttc_global.numquit 	lib_ecriture,
	0 				montant1,
	compte_client.montant 		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	compte,
	contrat,
	qttc_global,
	remise_prelev,
	encaismt,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	contrat.numgar		= qttc_global.numgar
and	qttc_global.numquit	= compte_client.numfact
and	encaismt.numencaismt	= compte_client.numencaismt
and	compte_client.montant	> 0
and	compte_client.codope	= 4
and	encaismt.numencaismt in (
	Select	numencaismt
	From	prelevement
	Where	prelevement.numremise = remise_prelev.numremise)
and Not Exists (
	Select	1
	From	idaffec_attente
	Where	idaffec_attente.idaffec = compte_client.idaffec)
and Not Exists (
	Select	1
	From	idaffec_regul
	Where	idaffec_regul.idaffec = compte_client.idaffec)
Union All	/*
			Affectation de cotisations
				HORS REMISE
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	compte_client.codope		codope,
	contrat.numorg 			cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )
					refpiece,
	encaismt.datpay 		dat_piece,
	'CT '||qttc_global.numgar||' ADH '||qttc_global.numquerable||
	' ECH '||qttc_global.numquit 	lib_ecriture,
	0 				montant1,
	compte_client.montant 		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	compte,
	contrat,
	qttc_global,
	encaismt,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	contrat.numgar		= qttc_global.numgar
and	qttc_global.numquit	= compte_client.numfact
and	encaismt.numencaismt	= compte_client.numencaismt
and	compte_client.montant	> 0
and	compte_client.codope	= 4
and 	Not Exists (
	Select	1
	From	prelevement
	Where	prelevement.numencaismt = encaismt.numencaismt)
and 	Not Exists (
	Select	1
	From	remise_banque
	Where	remise_banque.numencaismt = encaismt.numencaismt)
and 	Not Exists (
	Select	1
	From	idaffec_attente
	Where	idaffec_attente.idaffec = compte_client.idaffec)
and 	Not Exists (
	Select	1
	From	idaffec_regul
	Where	idaffec_regul.idaffec = compte_client.idaffec)
Union All	/*
			Affectation compte client
				REMISE CHEQUE
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	encaismt.idcompta		idcompta,
	encaismt.codope			codope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_globale.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_globale.daterem 		dat_piece,
	'CPTE CLIENT '||compte_client.numcli
					lib_ecriture,
	0 				montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	compte_client.montant 		montant6
From
	compte,
	remise_globale,
	encaismt,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.numencaismt	= compte_client.numencaismt
and	encaismt.codope	in(4, 7, 12)
and	( (compte_client.codope	= 8 and	compte_client.numfact Is Null)
		Or
	  (Exists (
		select 	1 from idaffec_attente
		where 	idaffec_attente.idaffec_attente = compte_client.idaffec)
	  )
	)
and	encaismt.numencaismt in (
	Select	numencaismt
	From	remise_banque
	Where	remise_banque.numremise = remise_globale.numremise)
Union All	/*
			Desaffectation de cotisations
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	4 				codope,
	contrat.numorg 			cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(compte_client.idaffec, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope		dat_piece,
	'ANNUL '||
	' FACT '||qttc_global.numquit 	lib_ecriture,
	0 				montant1,
	compte_client.montant 		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	-compte_client.montant		montant6
From
	compte,
	contrat,
	qttc_global,
	encaismt,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	contrat.numgar		= qttc_global.numgar
and	qttc_global.numquit	= compte_client.numfact
and	encaismt.numencaismt	= compte_client.numencaismt
and	compte_client.montant	< 0
and	compte_client.codope	= 4
and Exists (
	Select	1
	From	idaffec_attente
	Where	idaffec_attente.idaffec = compte_client.idaffec)
Union All	/*
			Affectation hors encaissement
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	encaismt.codope			codope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(compte_client.idaffec, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope 		dat_piece,
	' AFF FACT '||compte_client.numfact
					lib_ecriture,
	0 				montant1,
	compte_client.montant		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	-compte_client.montant 		montant6
From
	compte,
	encaismt,
	compte_client,
	idaffec_attente
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.numencaismt	= compte_client.numencaismt
and	encaismt.codope	in(4, 7, 12)
and	compte_client.montant > 0
and	compte_client.idaffec = idaffec_attente.idaffec
Union All	/*
			Affectation compte client
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	encaismt.codope			codope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(compte_client.numfact, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope 		dat_piece,
	'CPTE CLIENT '||compte_client.numcli
					lib_ecriture,
	0 				montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	compte_client.montant 		montant6
From
	compte,
	encaismt,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.numencaismt	= compte_client.numencaismt
and	encaismt.codope	in(7, 12)
and	compte_client.codope	= 8
and	compte_client.numfact Is Not Null
Union All	/*
			Desaffectation de regul
			-----------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	encaismt.codope			codope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(regul.idaffec, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope 		dat_piece,
	'REGUL ECH '||to_char(regul.numfact)
					lib_ecriture,
	0 				montant1,
	compte_client.montant		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0		 		montant6
From
	compte,
	encaismt,
	compte_client	regul,
	idaffec_regul,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.numencaismt	= compte_client.numencaismt
and	regul.idaffec		= idaffec_regul.idaffec
and	idaffec_regul.idaffec_regul = compte_client.idaffec
and	compte_client.codope	= 4
Union All	/*
			Reaffectation de regul
			----------------------			*/
Select	compte.numsoc			numsoc,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	encaismt.codope			codope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(compte_client.idaffec, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope 		dat_piece,
	'REPORT ECH '||to_char(regul.numfact)
					lib_ecriture,
	0 				montant1,
	compte_client.montant		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0		 		montant6
From
	compte,
	encaismt,
	compte_client	regul,
	idaffec_regul,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.numencaismt	= compte_client.numencaismt
and	regul.idaffec		= idaffec_regul.idaffec_regul
and	idaffec_regul.idaffec = compte_client.idaffec
and	compte_client.codope	= 4
Union All	/*
			Reversement cotisations
			      Ventilation
			-----------------------			*/
Select	compte.numsoc			numsoc,
	'decaismt'			entite,
	decaismt.numdecaismt		cle,
	decaismt.idcompta		idcompta,
	decaismt.codope			codope,
	reversement.numorg		cie,
	0		 		indv,
	qttc_affec.numfor		gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	to_char(reversement.idrevers, '00000000')
					refpiece,
	reversement.datrevers 		dat_piece,
	'REV CIE '||reversement.numorg ||' '||d2e(reversement.debut)
	||' '||d2e(reversement.fin)
					lib_ecriture,
	qttc_affec.montant
		- ARTHUS.pk_cotis.comm_prelev(	qttc_affec.numquit,
					qttc_affec.idrevers,
					qttc_affec.idaffec,
					qttc_affec.numfor,
					1,
					2)
		- ARTHUS.pk_cotis.mt_affec_tfc(qttc_affec.numquit,
					qttc_affec.idrevers,
					qttc_affec.idaffec,
					qttc_affec.numfor,
					'',
					1)
                                	montant1,
	ARTHUS.pk_cotis.comm_prelev(	qttc_affec.numquit,
				qttc_affec.idrevers,
				qttc_affec.idaffec,
				qttc_affec.numfor,
				1,
				2)
                                	montant2,
	ARTHUS.pk_cotis.mt_affec_tfc(	qttc_affec.numquit,
				qttc_affec.idrevers,
				qttc_affec.idaffec,
				qttc_affec.numfor,
				2,
				2)
                                	montant3,
	ARTHUS.pk_cotis.mt_affec_tfc(	qttc_affec.numquit,
				qttc_affec.idrevers,
				qttc_affec.idaffec,
				qttc_affec.numfor,
				1,
				3)
		+ ARTHUS.pk_cotis.mt_affec_tfc(qttc_affec.numquit,
					qttc_affec.idrevers,
					qttc_affec.idaffec,
					qttc_affec.numfor,
					1,
					4)
                                	montant4,
	ARTHUS.pk_cotis.mt_affec_tfc(	qttc_affec.numquit,
				qttc_affec.idrevers,
				qttc_affec.idaffec,
				qttc_affec.numfor,
				'',
				1)
	 				montant5,
	0 				montant6
From
	compte,
	decaismt,
	affectation,
	reversement,
	qttc_affec
Where	compte.numcpte		= decaismt.numcpte
and	decaismt.numdecaismt	= affectation.numdecaismt
and	affectation.numaffec	= reversement.idrevers
and	affectation.codope	= 5
and	reversement.idrevers 	= qttc_affec.idrevers
Union All	/*
			Reversement cotisations
			    Montant reverse
			-----------------------			*/
Select	compte.numsoc			numsoc,
	'decaismt'			entite,
	decaismt.numdecaismt		cle,
	decaismt.idcompta		idcompta,
	decaismt.codope			codope,
	reversement.numorg		cie,
	0		 		indv,
	0				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	to_char(reversement.idrevers, '00000000')
					refpiece,
	reversement.datrevers 		dat_piece,
	'REV CIE '||reversement.numorg ||' '||d2e(reversement.debut)
	||' '||d2e(reversement.fin)
					lib_ecriture,
        0                        	montant1,
        0                        	montant2,
        0                        	montant3,
        0                        	montant4,
	0 				montant5,
	decaismt.montant		montant6
From
	compte,
	decaismt,
	affectation,
	reversement
Where	compte.numcpte		= decaismt.numcpte
and	decaismt.numdecaismt	= affectation.numdecaismt
and	affectation.numaffec	= reversement.idrevers
and	affectation.codope	= 5
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_COTIS FOR ARTHUS.V_COMPTA_COTIS
