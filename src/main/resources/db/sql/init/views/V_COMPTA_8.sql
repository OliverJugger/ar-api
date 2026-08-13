CREATE FORCE VIEW ARTHUS.V_COMPTA_8 AS
Select	compte.numsoc			numsoc,
	'decaismt'			sur_entite,
	decaismt.numdecaismt		cle_unique,
	'decaismt'			entite,
	decaismt.numdecaismt		cle,
	decaismt.idcompta		idcompta,
	decaismt.codope			codope,
	1				type_ope,
	0				cie,
	compte_client.numcli 		indv,
	0				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(decaismt.numdecaismt, '00000000'), 2, 8)
					refpiece,
	decaismt.datpay 		dat_piece,
	compte_client.numcli 		lib_piece_1,
	affectation.numaffec 		lib_piece_2,
	compte_client.montant 		montant1,
        0				montant2,
        0				montant3,
        0				montant4,
        0				montant5,
	0 				montant6
From
	compte,
	rbtcptcli,
	compte_client,
	affectation,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	compte_client.idaffec	= rbtcptcli.idaffec
and	rbtcptcli.numaffec	= affectation.numaffec
and	affectation.numdecaismt	= decaismt.numdecaismt
and	compte_client.codope		= 8
and	decaismt.codope		= 8
Union All
Select	compte.numsoc			numsoc,
	'decaismt'			sur_entite,
	decaismt.numdecaismt		cle_unique,
	'decaismt'			entite,
	decaismt.numdecaismt		cle,
	decaismt.idcompta		idcompta,
	decaismt.codope			codope,
	2				type_ope,
	0				cie,
	decaismt.numbene 		indv,
	0				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr( to_char(decaismt.numdecaismt, '00000000'), 2, 8)
					refpiece,
	decaismt.datpay 		dat_piece,
	decaismt.numbene 		lib_piece_1,
	to_number('')			lib_piece_2,
	0		 		montant1,
        decaismt.montant		montant2,
        0				montant3,
        0				montant4,
        0				montant5,
	0 				montant6
From
	compte,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	decaismt.codope		= 8
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_8 FOR ARTHUS.V_COMPTA_8
