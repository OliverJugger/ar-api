CREATE FORCE VIEW ARTHUS.V_COMPTA_4 AS
Select	compte.numsoc,
	'encaismt'			sur_entite,
	encaismt.numencaismt		cle_unique,
	'encaismt'			entite,
	encaismt.numencaismt		cle,
	encaismt.idcompta		idcompta,
	encaismt.codope			codope,
	3				type_ope,
	0 				cie,
	encaismt.numcli			indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )
					refpiece,
	encaismt.datpay 		dat_piece,
	encaismt.refpmt 		lib_piece_1,
	encaismt.numcli 		lib_piece_2,
	encaismt.montant 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	encaismt.montant		montant6
From
	compte,
	encaismt
Where	compte.numcpte		= encaismt.numcpte
and 	Not Exists (
	Select	1
	From	prelevement
	Where	prelevement.numencaismt = encaismt.numencaismt)
and 	Not Exists (
	Select	1
	From	remise_banque
	Where	remise_banque.numencaismt = encaismt.numencaismt)
and	encaismt.codope + 0	= 4
Union All	/*
			Encaissement de cotisations
				PRELEVEMENT
			---------------------------			*/
Select	compte.numsoc,
	'prelevement'			sur_entite,
	remise_prelev.numremise		cle_unique,
	'encaismt'			entite,
	encaismt.numencaismt		cle,
	encaismt.idcompta		idcompta,
	encaismt.codope			codope,
	2				type_ope,
	0 				cie,
	0 				indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_prelev.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_prelev.datrem 		dat_piece,
	remise_prelev.numremise		lib_piece_1,
	remise_prelev.numcpte		lib_piece_2,
	encaismt.montant 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0				montant6
From	compte,
	remise_prelev,
	encaismt
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.codope	+ 0	= 4
and	encaismt.numencaismt in (
	Select	numencaismt
	From	prelevement
	Where	prelevement.numremise = remise_prelev.numremise
	)
Union All	/*
			Encaissement de cotisations
			Prelevement ->	Compte d'attente
			---------------------------			*/
Select	compte.numsoc,
	'encaismt'			sur_entite,
	encaismt.numencaismt		cle_unique,
	'encaismt'			entite,
	encaismt.numencaismt		cle,
	encaismt.idcompta		idcompta,
	encaismt.codope			codope,
	5				type_ope,
	0 				cie,
	encaismt.numcli			indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_prelev.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_prelev.datrem 		dat_piece,
	encaismt.numencaismt		lib_piece_1,
	encaismt.numcli			lib_piece_2,
	0 				montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	encaismt.montant		montant6
From	compte,
	remise_prelev,
	encaismt
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.codope	+ 0	= 4
and	encaismt.numencaismt in (
	Select	numencaismt
	From	prelevement
	Where	prelevement.numremise = remise_prelev.numremise
	)
Union All	/*
			 ANNULATION ENCAISSEMENT
			Desaffectation cotisation
			---------------------------			*/
Select	compte.numsoc,
	'encaismt'			sur_entite,
	compte_client.numencaismt	cle_unique,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	4				codope,
	8				type_ope,
	0 				cie,
	0 				indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )
					refpiece,
	annul_encais.date_annul		dat_piece,
	compte_client.numfact		lib_piece_1,
	compte_client.numcli		lib_piece_2,
	0		 		montant1,
	compte_client.montant		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	compte,
	annul_encais,
	encaismt,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	annul_encais.numencaismt = encaismt.numencaismt
and	encaismt.numencaismt = compte_client.numencaismt
and	compte_client.montant < 0
and	compte_client.codope in (4, 8)
Union All	/*
			 ANNULATION ENCAISSEMENT
				Banque
			---------------------------			*/
Select	compte.numsoc,
	'encaismt'			sur_entite,
	encaismt.numencaismt		cle_unique,
	'annul'				entite,
	annul_encais.numencaismt	cle,
	annul_encais.idcompta		idcompta,
	encaismt.codope			codope,
	7				type_ope,
	0 				cie,
	encaismt.numcli			indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )
					refpiece,
	annul_encais.date_annul		dat_piece,
	encaismt.refpmt			lib_piece_1,
	encaismt.numcli			lib_piece_2,
	-encaismt.montant 		montant1,
	0				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	compte,
	encaismt,
	annul_encais
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.numencaismt	= annul_encais.numencaismt
Union All	/*
			Encaissement de cotisations
				REMISE BANQUE
			---------------------------			*/
Select	compte.numsoc,
	'remise_banque'			sur_entite,
	remise_globale.numremise	cle_unique,
	'encaismt'			entite,
	encaismt.numencaismt		cle,
	encaismt.idcompta		idcompta,
	4				codope,
	1				type_ope,
	0 				cie,
	0				indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_globale.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_globale.daterem 		dat_piece,
	remise_globale.numremise	lib_piece_1,
	remise_globale.numcpte		lib_piece_2,
	encaismt.montant 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0				montant6
From	compte,
	remise_globale,
	encaismt
Where	compte.numcpte		= remise_globale.numcpte
and	encaismt.codope	+ 0	= 4
and	encaismt.numencaismt in (
	Select	numencaismt
	From	remise_banque
	Where	remise_banque.numremise = remise_globale.numremise)
Union All	/*
			Encaissement de cotisations
			REMISE BANQUE -> Compte client
			---------------------------			*/
Select	compte.numsoc,
	'encaismt'			sur_entite,
	encaismt.numencaismt		cle_unique,
	'encaismt'			entite,
	encaismt.numencaismt		cle,
	encaismt.idcompta		idcompta,
	4				codope,
	4				type_ope,
	0 				cie,
	encaismt.numcli			indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(remise_globale.numremise, '00000000'), 2, 8 )
					refpiece,
	remise_globale.daterem 		dat_piece,
	encaismt.refpmt			lib_piece_1,
	encaismt.numcli			lib_piece_2,
	0 				montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	encaismt.montant		montant6
From	compte,
	remise_globale,
	encaismt
Where	compte.numcpte		= remise_globale.numcpte
and	encaismt.codope	+ 0	= 4
and	encaismt.numencaismt in (
	Select	numencaismt
	From	remise_banque
	Where	remise_banque.numremise = remise_globale.numremise)
Union All	/*
			Affectation de cotisations
				COMPTE CLIENT -> cotisations
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'qttc'				sur_entite,
	qttc_global.numquit		cle_unique,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	compte_client.codope		codope,
	9				type_ope,
	contrat.numorg 			cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )
					refpiece,
	encaismt.datpay 		dat_piece,
	qttc_global.numquit		lib_piece_1,
	qttc_global.numquerable		lib_piece_2,
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
and	compte_client.montant	> 0
and	compte_client.codope	= 4
/* and Not Exists (
	Select	1
	From	idaffec_attente
	Where	idaffec_attente.idaffec = compte_client.idaffec)	*/
and Not Exists (
	Select	1
	From	idaffec_regul
	Where	idaffec_regul.idaffec = compte_client.idaffec)
Union All	/*
			Desaffectation de cotisations
			---------------------------			*/
Select	compte.numsoc			numsoc,
	'qttc'				sur_entite,
	qttc_global.numquit		cle_unique,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	4 				codope,
	10				type_ope,
	contrat.numorg 			cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(compte_client.idaffec, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope		dat_piece,
	qttc_global.numquit 		lib_piece_1,
	qttc_global.numquerable		lib_piece_2,
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
	From	idaffec_attente,
		compte_client	attente
	Where	idaffec_attente.idaffec = compte_client.idaffec
	and	attente.idaffec = idaffec_attente.idaffec_attente
	and	attente.codope = 8)
Union All	/*
			Desaffectation de regul
			-----------------------			*/
Select	compte.numsoc			numsoc,
	'qttc'				sur_entite,
	compte_client.numfact		cle_unique,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	encaismt.codope			codope,
	11				type_ope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(compte_client.numfact, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope 		dat_piece,
	compte_client.numfact		lib_piece_1,
	compte_client.numcli		lib_piece_2,
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
and	regul.codope = 4
and Not Exists (
	Select	1
	From	idaffec_attente
	Where	idaffec_attente.idaffec = idaffec_regul.idaffec)
Union All	/*
			Reaffectation de regul
			----------------------			*/
Select	compte.numsoc			numsoc,
	'qttc'				sur_entite,
	compte_client.numfact		cle_unique,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	encaismt.codope			codope,
	12				type_ope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(regul.numfact, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope 		dat_piece,
	compte_client.numfact		lib_piece_1,
	compte_client.numcli		lib_piece_2,
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
and	regul.codope	= 4
Union All	/*
			Solde de regul
			--------------			*/
Select	compte.numsoc			numsoc,
	'qttc'				sur_entite,
	compte_client.numfact		cle_unique,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	encaismt.codope			codope,
	13				type_ope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(compte_client.numfact, '00000000'), 2, 8 )
					refpiece,
	compte_client.datope 		dat_piece,
	compte_client.numfact		lib_piece_1,
	compte_client.numcli		lib_piece_2,
	0 				montant1,
	0				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	compte_client.montant 		montant6
From
	compte,
	encaismt,
	facture_regul,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.numencaismt	= compte_client.numencaismt
and	facture_regul.numfact_regul = compte_client.numfact
and	compte_client.codope	= 8
Union All	/*
			Solde de regul (Re-affecte)
			--------------			*/
Select	compte.numsoc			numsoc,
	'qttc'				sur_entite,
	compte_client.numfact		cle_unique,
	'compte_client'			entite,
	compte_client.idaffec		cle,
	compte_client.idcompta		idcompta,
	compte_client.codope		codope,
	14				type_ope,
	0 				cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(regul.numfact, '00000000'), 2, 8 )
					refpiece,
	idaffec_regul.datope 		dat_piece,
	compte_client.numfact		lib_piece_1,
	compte_client.numcli		lib_piece_2,
	0 				montant1,
	compte_client.montant		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	compte,
	encaismt,
	idaffec_attente,
	idaffec_regul,
	compte_client	regul,
	compte_client
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.numencaismt	= compte_client.numencaismt
and	idaffec_attente.idaffec_attente = idaffec_regul.idaffec
and	regul.idaffec = idaffec_regul.idaffec_regul
and	compte_client.idaffec = idaffec_attente.idaffec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_4 FOR ARTHUS.V_COMPTA_4
