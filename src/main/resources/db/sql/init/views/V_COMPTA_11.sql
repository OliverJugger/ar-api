CREATE FORCE VIEW ARTHUS.V_COMPTA_11 AS
Select	compte.numsoc			numsoc,
	'dcptdedu'			sur_entite,
	dcptdedu.numdec			cle_unique,
	'decaismt'			entite,
	decaismt.numdecaismt		cle,
	decaismt.idcompta		idcompta,
	11				codope,
	1				type_ope,
	f_assureur(repartition.numfor)	cie,
	dcptdedu.numbene		indv,
	repartition.numfor		gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr(to_char(decaismt.numdecaismt, '00000000'), 2, 8)
					refpiece,
	decaismt.datpay 		dat_piece,
	dcptdedu.numdec			lib_piece_1,
	dcptdedu.numbene		lib_piece_2,
	sum(round( (((histo_jours.fin-histo_jours.debut)+1) *
				 histo_dedu.montant), 2 ))
					montant1,
        0                        	montant2,
        0                        	montant3,
        0                        	montant4,
	0 				montant5,
	0 				montant6
From
	compte,
	repartition,
	histo_calcul,
	histo_jours,
	histo_dedu,
	dcptdedu,
	affectation,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	repartition.idrepartition = histo_calcul.idrepartition
and	histo_calcul.idcalcul 	= histo_jours.idcalcul
and	histo_jours.idhisto	= histo_dedu.idhisto
and	histo_dedu.numdec	= dcptdedu.numdec
and	dcptdedu.numdec		= affectation.numaffec
and	affectation.numdecaismt	= decaismt.numdecaismt
and	decaismt.codope		= 11
Group by
	compte.numsoc,
	dcptdedu.numdec,
	dcptdedu.numbene,
	decaismt.numdecaismt,
	decaismt.idcompta,
	decaismt.datpay,
	repartition.numfor,
	compte.cmpt_gene
Union All	/*
			Reversement deductions
			    Montant reverse
			-----------------------			*/
Select	compte.numsoc			numsoc,
	'decaismt'			sur_entite,
	decaismt.numdecaismt		cle_unique,
	'decaismt'			entite,
	decaismt.numdecaismt		cle,
	decaismt.idcompta		idcompta,
	11				codope,
	2				type_ope,
	0				cie,
	dcptdedu.numbene		indv,
	0				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr(to_char(decaismt.numdecaismt, '00000000'),2, 8)
					refpiece,
	decaismt.datpay 		dat_piece,
	dcptdedu.numdec			lib_piece_1,
	dcptdedu.numbene		lib_piece_2,
        0                        	montant1,
	affectation.montant		montant2,
        0                        	montant3,
        0                        	montant4,
	0 				montant5,
	0 				montant6
From	compte,
	dcptdedu,
	affectation,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	dcptdedu.numdec		= affectation.numaffec
and	affectation.numdecaismt = decaismt.numdecaismt
and	decaismt.codope		= 11
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_11 FOR ARTHUS.V_COMPTA_11
