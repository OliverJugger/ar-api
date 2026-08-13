CREATE FORCE VIEW ARTHUS.V_COMPTA_PREST AS
Select	contrat.numinterm 	numsoc,
	'decaismt' 		entite,
	decaismt.numdecaismt	cle,
	decaismt.idcompta,
	1 codope,
	contrat.numorg 		cie,
	decaismt.numbene 	indv,
	sinistre.numfor 	gar,
	0 			int,
	compte.cmpt_gene 	bqe,
	substr(to_char(decaismt.refpmt,'00000000'),2,8)	refpiece,
	affectation.dataffec 		dat_piece,
	'CHQ'||to_char(decaismt.refpmt,'00000000')||
		to_char(affectation.numaffec,'0000000')||
			' ASR'|| to_char(sinistre.numassu,'000000')
					lib_ecriture,
	sum(sinistre.mtreel) 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	sinistre,
	affectation,
	compte,
	decaismt,
	contrat
Where	sinistre.numdec		= affectation.numaffec
and	affectation.codope	= 1
and	compte.numcpte		= decaismt.numcpte
and 	affectation.numdecaismt	= decaismt.numdecaismt
and	decaismt.modpmt 	!= 2
and	decaismt.flagpay = 1
and	contrat.numgar 		= sinistre.numgar
group by
	contrat.numinterm,
	decaismt.idcompta,
	contrat.numorg,
	decaismt.numbene,
	sinistre.numfor,
	compte.cmpt_gene,
	substr(to_char(decaismt.refpmt,'00000000'),2,8),
	affectation.dataffec,
	'CHQ'||to_char(decaismt.refpmt,'00000000')||
		to_char(affectation.numaffec,'0000000')||
			' ASR'|| to_char(sinistre.numassu,'000000'),
	'decaismt',
	decaismt.numdecaismt
/*
	Montant des prestations payees par assure
	VIREMENT
*/
Union All
Select	contrat.numinterm 	numsoc,
	'decaismt' 		entite,
	decaismt.numdecaismt	cle,
	decaismt.idcompta,
	1 codope,
	contrat.numorg 		cie,
	0 			indv,
	sinistre.numfor 	gar,
	0 			int,
	compte.cmpt_gene 	bqe,
	substr(to_char(remise_vire_detail.numremise,'00000000'),2,8) refpiece,
	remise_vire.datrem 		dat_piece,
	'VIR'|| to_char(remise_vire_detail.numremise,'00000000')
					lib_ecriture,
	sum(sinistre.mtreel) 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	sinistre,
	affectation,
	compte,
	decaismt,
	remise_vire_detail,
	remise_vire,
	contrat
Where	sinistre.numdec		= affectation.numaffec
and	affectation.codope	= 1
and	compte.numcpte		= decaismt.numcpte
and 	affectation.numdecaismt	= decaismt.numdecaismt
and 	remise_vire_detail.numdecaismt	= decaismt.numdecaismt
and 	remise_vire.numremise	= remise_vire_detail.numremise
and	decaismt.modpmt 	= 2
and	decaismt.flagpay = 1
and	contrat.numgar 		= sinistre.numgar
group by
	contrat.numinterm,
	decaismt.idcompta,
	contrat.numorg,
	substr(to_char(remise_vire_detail.numremise,'00000000'),2,8),
	sinistre.numfor,
	compte.cmpt_gene,
	remise_vire.datrem,
	'VIR'|| to_char(remise_vire_detail.numremise,'00000000'),
	decaismt.numdecaismt,
	'decaismt'
Union All	/*		PRESTATIONS PREVOYANCE
			----------------------
	Montant des prestations payee
	Montant des prestations calculee
	Montant des deductions
	*/
Select	contrat.numinterm 	numsoc,
	'decaismt' 		entite,
	decaismt.numdecaismt	cle,
	decaismt.idcompta,
	2 			codope,
	contrat.numorg 		cie,
	decaismt.numbene 	indv,
	v_histo_calcul.numfor 	gar,
	0 			int,
	compte.cmpt_gene 	bqe,
	to_char(affectation.numaffec) 	refpiece,
	affectation.dataffec 		dat_piece,
	'SIN '||sin.nosin||' ASS '||
		sin.numindiv,
	sum(v_histo_calcul.montant),
	sum(v_histo_calcul.montant)+sum(nvl(v_histo_calcul.dedu,0)),
	sum(nvl(v_histo_calcul.dedu,0)),
	0 montant4,
	0 montant5,
	0 montant6
From
	compte,
	contrat,
	adhe_cntrt,
	sin,
	v_histo_calcul,
	affectation,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	contrat.numgar 		= adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= v_histo_calcul.idadhesion
and	sin.nosin		= v_histo_calcul.nosin
and	v_histo_calcul.numdec	= affectation.numaffec
and	affectation.codope	= 2
and 	affectation.numdecaismt	= decaismt.numdecaismt
and	decaismt.flagpay = 1
group by
	contrat.numinterm,
	decaismt.idcompta,
	contrat.numorg,
	decaismt.numbene,
	v_histo_calcul.numfor,
	compte.cmpt_gene,
	to_char(affectation.numaffec),
	affectation.dataffec,
	'SIN '||sin.nosin||' ASS '||
		sin.numindiv,
	decaismt.numdecaismt
Union All	/*		REMBOURSEMENT PRESTATIONS CIE
			-----------------------------
	Montant des prestations payees (maladie)
								*/
Select	contrat.numinterm numsoc,
	'facture',
	facture.numfact,
	facture.idcompta,
	12 codope,
	contrat.numorg cie,
	orgns.numindiv indv,
	sinistre.numfor gar,
	0 int,
	'0' bqe,
	to_char(facture.numfact) refpiece,
	facture.datfact dat_piece,
	'Prest Mal '|| to_char(dcptcie.datedeb, 'dd/mm/yy') || ' - '||
			to_char(dcptcie.datefin, 'dd/mm/yy'),
	sum(sinistre.mtreel) montant1,
	0 montant2,
	0 montant3,
	0 montant4,
	0 montant5,
	0 montant6
From	sinistre,
	orgns,
	contrat,
	dcpt,
	dcptcie,
	facture
Where	sinistre.numdec		= dcpt.numdec
and	orgns.numorg		= contrat.numorg
and	contrat.numgar 		= dcpt.numgar
and	dcpt.numdcptcie		= dcptcie.numdcptcie
and	facture.numfact		= dcptcie.numdcptcie
and	facture.codope		= 12
group by
	contrat.numinterm,
	facture.idcompta,
	contrat.numorg,
	orgns.numindiv,
	to_char(facture.numfact),
	facture.datfact,
	'Prest Mal '|| to_char(dcptcie.datedeb, 'dd/mm/yy') || ' - '||
			to_char(dcptcie.datefin, 'dd/mm/yy'),
	sinistre.numfor,
	'facture',
	facture.numfact
Union All	/*
		Montant des prestations payees (prevoyance)
								*/
Select	contrat.numinterm numsoc,
	'facture',
	facture.numfact,
	facture.idcompta,
	12 codope,
	contrat.numorg cie,
	orgns.numindiv indv,
	v_histo_calcul.numfor gar,
	0 int,
	'0' bqe,
	to_char(facture.numfact) refpiece,
	facture.datfact dat_piece,
	'Prest Prev '|| to_char(dcptcie.datedeb, 'dd/mm/yy') || ' - '||
			to_char(dcptcie.datefin, 'dd/mm/yy'),
	sum(v_histo_calcul.montant),
	0 montant2,
	0 montant3,
	0 montant4,
	0 montant5,
	0 montant6
From
	orgns,
	contrat,
	adhe_cntrt,
	v_histo_calcul,
	decompte_prev,
	dcptcie,
	facture
Where	orgns.numorg		= contrat.numorg
and	contrat.numgar		= adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= decompte_prev.idadhesion
and	v_histo_calcul.numdec	= decompte_prev.numdec
and 	decompte_prev.numdcptcie	= dcptcie.numdcptcie
and	facture.numfact		= dcptcie.numdcptcie
and	facture.codope		= 12
group by
	contrat.numinterm,
	facture.idcompta,
	contrat.numorg,
	orgns.numindiv,
	to_char(facture.numfact),
	facture.datfact,
	'Prest Prev '|| to_char(dcptcie.datedeb, 'dd/mm/yy') || ' - '||
			to_char(dcptcie.datefin, 'dd/mm/yy'),
	v_histo_calcul.numfor,
	'facture',
	facture.numfact
Union All	/*
		Montant de la demande de remboursement
								*/
Select	dcptcie.numsoc numsoc,
	'facture',
	facture.numfact,
	facture.idcompta,
	12 codope,
	dcptcie.numorg cie,
	facture.numcli indv,
	0 gar,
	0 int,
	'' bqe,
	to_char(facture.numfact) refpiece,
	facture.datfact dat_piece,
	'Dmnde Rbt Prest Cie '|| orgns.nom ||' N° '||facture.numfact,
	0 montant1,
	facture.montant montant2,
	0 montant3,
	0 montant4,
	0 montant5,
	0 montant6
From	orgns,
	dcptcie,
	facture
Where	orgns.numorg		= dcptcie.numorg
and	facture.numfact		= dcptcie.numdcptcie
and	facture.codope		= 12
Union All	/*
		Montant remboursement encaisse
							*/
Select	compte.numsoc,
	'encaismt',
	encaismt.numencaismt,
	encaismt.idcompta,
	12 codope,
	0 cie,
	encaismt.numcli indv,
	0 gar,
	0 int,
	compte.cmpt_gene bqe,
	to_char(encaismt.numencaismt) refpiece,
	encaismt.datpay dat_piece,
	mopm.libelle||' Cie '|| orgns.nom lib_ecriture,
	0 montant1,
	0 montant2,
	encaismt.montant montant3,
	0 montant4,
	0 montant5,
	0 montant6
From	compte,
	libelle mopm,
	orgns,
	encaismt
Where	compte.numcpte		= encaismt.numcpte
and	mopm.code		= encaismt.modpmt
and	mopm.mnemo		= 'MREGL'
and	orgns.numindiv		= encaismt.numcli
and	encaismt.codope		= 12
Union All	/*
		Montant remboursement affecte
							*/
Select	compte.numsoc,
	'compte_client',
	compte_client.idaffec,
	compte_client.idcompta,
	12 codope,
	dcptcie.numorg cie,
	compte_client.numcli indv,
	0 gar,
	0 int,
	'0' bqe,
	to_char(encaismt.numencaismt) refpiece,
	compte_client.datope dat_piece,
	'Rbt Prest Cie '|| orgns.nom || ' Bx N° ' || compte_client.numfact,
	0 montant1,
	0 montant2,
	0 montant3,
	compte_client.montant montant4,
	0 montant5,
	0 montant6
From	compte,
	orgns,
	dcptcie,
	compte_client,
	encaismt
Where	compte.numcpte		= encaismt.numcpte
and	orgns.numorg		= dcptcie.numorg
and	dcptcie.numdcptcie	= compte_client.numfact
and	compte_client.numencaismt = encaismt.numencaismt
and	compte_client.codope 	= encaismt.codope
and	encaismt.codope		= 12
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_PREST FOR ARTHUS.V_COMPTA_PREST
