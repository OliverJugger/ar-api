CREATE FORCE VIEW ARTHUS.V_COMPTA_1 AS
Select	contrat.numinterm 	numsoc,
	'decaismt'			sur_entite,
	decaismt.numdecaismt		cle_unique,
	'decaismt' 		entite,
	decaismt.numdecaismt	cle,
	decaismt.idcompta,
	1 			codope,
	1 			type_ope,
	contrat.numorg 		cie,
	decaismt.numbene 	indv,
	sinistre.numfor 	gar,
	0 			int,
	compte.cmpt_gene 	bqe,
	substr(to_char(decaismt.refpmt,'00000000'),2,8)	refpiece,
	affectation.dataffec 		dat_piece,
	affectation.numaffec		lib_piece_1,
	sinistre.numassu		lib_piece_2,
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
	affectation.numaffec,
	sinistre.numassu,
	'decaismt',
	decaismt.numdecaismt
/*
	Montant des prestations payees par assure
	VIREMENT
*/
Union All
Select	contrat.numinterm 	numsoc,
	'virement'			sur_entite,
	remise_vire.numremise		cle_unique,
	'decaismt' 		entite,
	decaismt.numdecaismt	cle,
	decaismt.idcompta,
	1 			codope,
	2 			type_ope,
	contrat.numorg 		cie,
	0 			indv,
	sinistre.numfor 	gar,
	0 			int,
	compte.cmpt_gene 	bqe,
	substr(to_char(remise_vire_detail.numremise,'00000000'),2,8) refpiece,
	remise_vire.datrem 		dat_piece,
	remise_vire_detail.numremise	lib_piece_1,
	to_number('')			lib_piece_2,
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
	remise_vire.numremise,
	decaismt.idcompta,
	contrat.numorg,
	substr(to_char(remise_vire_detail.numremise,'00000000'),2,8),
	remise_vire_detail.numremise,
	sinistre.numfor,
	compte.cmpt_gene,
	remise_vire.datrem,
	decaismt.numdecaismt,
	'decaismt'
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_1 FOR ARTHUS.V_COMPTA_1
