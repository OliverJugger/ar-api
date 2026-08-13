CREATE FORCE VIEW ARTHUS.V_COMPTA_12 AS
Select	contrat.numinterm numsoc,
	'dcptcie1'			sur_entite,
	dcptcie.numdcptcie		cle_unique,
	'facture'			entite,
	facture.numfact			cle,
	facture.idcompta,
	12 				codope,
	1 				type_ope,
	dcptcie.numorg 			cie,
	dcptcie.numorg 			indv,
	sinistre.numfor 		gar,
	0 				int,
	'0' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	facture.datfact 		dat_piece,
	dcptcie.numdcptcie		lib_piece_1,
	dcptcie.numorg			lib_piece_2,
	sum(sinistre.mtreel) 		montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	sinistre,
	contrat,
	dcpt,
	dcptcie,
	facture
Where	sinistre.numdec		= dcpt.numdec
and	contrat.numgar 		= dcpt.numgar
and	dcpt.numdcptcie		= dcptcie.numdcptcie
and	dcptcie.numdcptcie	= facture.numfact
and	facture.codope		= 12
group by
	contrat.numinterm,
	facture.idcompta,
	dcptcie.numorg,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 ),
	facture.datfact,
	sinistre.numfor,
	'facture',
	dcptcie.numdcptcie,
	facture.numfact
Union All	/*
		Montant des prestations payees (prevoyance)
								*/
Select	contrat.numinterm numsoc,
	'dcptcie2'			sur_entite,
	facture.numfact			cle_unique,
	'facture',
	facture.numfact,
	facture.idcompta,
	12 				codope,
	2 				type_ope,
	dcptcie.numorg 			cie,
	dcptcie.numorg 			indv,
	v_histo_calcul.numfor 		gar,
	0 				int,
	'0' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	facture.datfact 		dat_piece,
	dcptcie.numdcptcie		lib_piece_1,
	dcptcie.numorg			lib_piece_2,
	sum(v_histo_calcul.montant_remb)
					montant1,
	0 				montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	contrat,
	adhe_cntrt,
	v_histo_calcul,
	decompte_prev,
	dcptcie,
	facture
Where	contrat.numgar		= adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= decompte_prev.idadhesion
and	v_histo_calcul.numdec	= decompte_prev.numdec
and 	decompte_prev.numdcptcie	= dcptcie.numdcptcie
and	facture.numfact		= dcptcie.numdcptcie
and	facture.codope		= 12
group by
	contrat.numinterm,
	facture.idcompta,
	dcptcie.numorg,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 ),
	facture.datfact,
	v_histo_calcul.numfor,
	'facture',
	dcptcie.numdcptcie,
	facture.numfact
Union All	/*
		Montant de la demande de remboursement	(Sante)
								*/
Select	dcptcie.numsoc 			numsoc,
	'dcptcie1'			sur_entite,
	facture.numfact			cle_unique,
	'facture',
	facture.numfact,
	facture.idcompta,
	12 				codope,
	3 				type_ope,
	dcptcie.numorg 			cie,
	dcptcie.numorg 			indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	facture.datfact dat_piece,
	dcptcie.numdcptcie		lib_piece_1,
	dcptcie.numorg			lib_piece_2,
	0 				montant1,
	facture.montant 		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	dcptcie,
	facture
Where	dcptcie.type		= 1
and	facture.numfact		= dcptcie.numdcptcie
and	facture.codope		= 12
Union All	/*
		Montant de la demande de remboursement	(Prevoyance)
								*/
Select	dcptcie.numsoc 			numsoc,
	'dcptcie2'			sur_entite,
	facture.numfact			cle_unique,
	'facture',
	facture.numfact,
	facture.idcompta,
	12 				codope,
	4 				type_ope,
	dcptcie.numorg 			cie,
	dcptcie.numorg 			indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(facture.numfact, '00000000'), 2, 8 )
					refpiece,
	facture.datfact dat_piece,
	dcptcie.numdcptcie		lib_piece_1,
	dcptcie.numorg			lib_piece_2,
	0 				montant1,
	facture.montant 		montant2,
	0 				montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	dcptcie,
	facture
Where	dcptcie.type		= 2
and	facture.numfact		= dcptcie.numdcptcie
and	facture.codope		= 12
Union All	/*
		Montant remboursement encaisse
							*/
Select	compte.numsoc,
	'encaismt'			sur_entite,
	encaismt.numencaismt		cle_unique,
	'encaismt',
	encaismt.numencaismt,
	encaismt.idcompta,
	12 				codope,
	5 				type_ope,
	0 				cie,
	encaismt.numcli 		indv,
	0 				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )
					refpiece,
	encaismt.datpay 		dat_piece,
	encaismt.refpmt			lib_piece_1,
	encaismt.numcli			lib_piece_2,
	0 				montant1,
	0 				montant2,
	encaismt.montant 		montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From	compte,
	encaismt
Where	compte.numcpte		= encaismt.numcpte
and	encaismt.codope		= 12
Union All	/*
		Montant remboursement affecte
							*/
Select	compte.numsoc,
	'encaismt'			sur_entite,
	encaismt.numencaismt		cle_unique,
	'compte_client',
	compte_client.idaffec,
	compte_client.idcompta,
	12 				codope,
	6 				type_ope,
	compte_client.numcli		cie,
	compte_client.numcli 		indv,
	0 				gar,
	0 				int,
	'' 				bqe,
	Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )
					refpiece,
	encaismt.datpay 		dat_piece,
	compte_client.numfact		lib_piece_1,
	compte_client.numcli		lib_piece_2,
	0 				montant1,
	0 				montant2,
	0 				montant3,
	compte_client.montant 		montant4,
	0 				montant5,
	0 				montant6
From	compte,
	compte_client,
	encaismt
Where	compte.numcpte		= encaismt.numcpte
and	compte_client.numencaismt = encaismt.numencaismt
and	compte_client.codope 	= encaismt.codope
and	encaismt.codope		= 12
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_12 FOR ARTHUS.V_COMPTA_12
