CREATE FORCE VIEW ARTHUS.V_COMPTE_TIERS AS
Select 	credit.codope,
	dette.iddette,
	debit.cle numaffec,
	credit.montant				mt_fact,
	debit.montant				mt_regl,
	credit.montant_d			mt_fact_d,
	debit.montant_d				mt_regl_d,
	credit.monnaie,
	credit.monnaie_d,
	d2e(credit.datope) 			datope,
	d2e(dette.date_fact) 			date_fact,
	'Attribution de fonds de roulement' 	libelle,
	credit.cle
From	dette,
	compte_tiers	credit,
	compensation,
	compte_tiers 	debit
Where	dette.iddette	= credit.cle
and	credit.codope	= 15
and	credit.idmvt	= compensation.idmvt
and	compensation.idcomp = debit.idmvt
and	debit.codope	= 10
and	debit.sens	= -1
Union
Select 	credit.codope,
	dette.iddette,
	debit.cle				numaffec,
	dette.montant				mt_fact,
	debit.montant				mt_regl,
	dette.montant_d				mt_fact_d,
	debit.montant_d				mt_regl_d,
	debit.monnaie,
	debit.monnaie_d,
	d2e(credit.datope),
	d2e(dette.date_fact),
	decode(credit.sens,1,
		'Remboursement prestations santé',
		'Indu prestations santé') 	libelle,
	credit.cle
From	dette,
	decompte,
	compte_tiers	credit,
	compensation,
	compte_tiers	debit
Where	dette.iddette	= decompte.numdcptcie
and	decompte.numdec	= credit.cle
and	credit.idmvt	= compensation.idmvt
and	compensation.idcomp = debit.idmvt
and	debit.codope	= 10
and	debit.sens	= -1
Union
Select 	credit.codope,
	encaismt.numencaismt			iddette,
	debit.cle 				numaffec,
	credit.montant				mt_fact,
	debit.montant				mt_regl,
	credit.montant_d			mt_fact_d,
	debit.montant_d				mt_regl_d,
	credit.monnaie,
	credit.monnaie_d,
	d2e(credit.datope) 			datope,
	d2e(encaismt.datpay) 			date_fact,
	'Trop perçu' 			libelle,
	credit.cle
From	encaismt,
	compte_tiers	credit,
	compensation,
	compte_tiers 	debit
Where	encaismt.numencaismt = credit.cle
and	credit.sens	= 1
and	credit.codope	= 10
and	credit.idmvt 	= compensation.idmvt
and	compensation.idcomp = debit.idmvt
and	debit.sens	= -1
and	debit.codope = 10
Union
Select 	credit.codope,
	credit.cle				iddette,
	debit.cle 				numaffec,
	credit.montant				mt_fact,
	debit.montant				mt_regl,
	credit.montant_d			mt_fact_d,
	debit.montant_d				mt_regl_d,
    credit.monnaie,
    credit.monnaie_d,
	d2e(debit.datope) 			datope,
	d2e(retrocession.datrevers) 		date_fact,
	Decode( credit.sens,
		1, 'Reversement de commissions',
		-1, 'Trop versé de commissions ' )	libelle,
	credit.cle
From	retrocession,
	compte_tiers	credit,
	compensation,
	compte_tiers 	debit
Where	retrocession.idrevers = credit.cle
and	credit.codope	= 16
and	credit.idmvt 	= compensation.idmvt
and	compensation.idcomp = debit.idmvt
and	debit.sens	= -1
and	debit.codope = 10
Union
Select 	credit.codope,
	credit.cle				iddette,
	debit.cle 				numaffec,
	credit.montant				mt_fact,
	debit.montant				mt_regl,
	credit.montant_d			mt_fact_d,
	debit.montant_d				mt_regl_d,
    credit.monnaie,
    credit.monnaie_d,
	d2e(debit.datope) 			datope,
	d2e(decompte_prev.datpay) 		date_fact,
	decode(credit.sens,1,
		'Remboursement prestations prévoyance',
		'Indu prestations prévoyance') 	libelle,
	credit.cle
From	decompte_prev,
	compte_tiers	credit,
	compensation,
	compte_tiers 	debit
Where	decompte_prev.numdec = credit.cle
and	credit.codope	= 2
and	credit.idmvt 	= compensation.idmvt
and	compensation.idcomp = debit.idmvt
and	debit.sens	= -1
and	debit.codope = 10
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTE_TIERS FOR ARTHUS.V_COMPTE_TIERS
