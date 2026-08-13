CREATE FORCE VIEW ARTHUS.V_COMPTA_5 AS
Select	compte.numsoc			numsoc,
	'qttc'				sur_entite,
	qttc_affec.numquit		cle_unique,
	'decaismt'			entite,
	decaismt.numdecaismt		cle,
	decaismt.idcompta		idcompta,
	decaismt.codope			codope,
	1				type_ope,
	reversement.numorg		cie,
	qttc_global.numquerable		indv,
	qttc_affec.numfor		gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr(to_char(decaismt.numdecaismt, '00000000'), 2, 8)
					refpiece,
	reversement.datrevers 		dat_piece,
	qttc_affec.numquit		lib_piece_1,
	qttc_global.numquerable		lib_piece_2,
	Sum(qttc_affec.montant)
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
				'',
				3)
		+ ARTHUS.pk_cotis.mt_affec_tfc(qttc_affec.numquit,
					qttc_affec.idrevers,
					qttc_affec.idaffec,
					qttc_affec.numfor,
					'',
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
	qttc_global,
	qttc_affec,
	reversement,
	affectation,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	qttc_global.numquit 	= qttc_affec.numquit
and	qttc_affec.idrevers 	= reversement.idrevers
and	reversement.idrevers	= affectation.numaffec
and	affectation.numdecaismt	= decaismt.numdecaismt
and	decaismt.codope		= 5
Group by
	compte.numsoc,
	qttc_affec.idrevers,
	qttc_affec.idaffec,
	qttc_global.numgar,
	qttc_affec.numquit,
	qttc_global.numquerable,
	decaismt.numdecaismt,
	decaismt.idcompta,
	decaismt.codope	,
	reversement.numorg,
	qttc_affec.numfor,
	compte.cmpt_gene ,
	reversement.idrevers,
	reversement.datrevers,
	reversement.debut
Union All	/*
			Reversement cotisations
			    Montant reverse
			-----------------------			*/
Select	compte.numsoc			numsoc,
	'decaismt'			sur_entite,
	decaismt.numdecaismt		cle_unique,
	'decaismt'			entite,
	decaismt.numdecaismt		cle,
	decaismt.idcompta		idcompta,
	decaismt.codope			codope,
	2				type_ope,
	reversement.numorg		cie,
	reversement.numorg		indv,
	0				gar,
	0 				int,
	compte.cmpt_gene 		bqe,
	Substr(to_char(decaismt.numdecaismt, '00000000'),2, 8)
					refpiece,
	reversement.datrevers 		dat_piece,
	reversement.idrevers		lib_piece_1,
	reversement.numorg		lib_piece_2,
        0                        	montant1,
        0                        	montant2,
        0                        	montant3,
        0                        	montant4,
	0 				montant5,
	decaismt.montant		montant6
From	compte,
	reversement,
	affectation,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	affectation.numaffec	= reversement.idrevers
and	affectation.numdecaismt = decaismt.numdecaismt
and	decaismt.codope		= 5
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_5 FOR ARTHUS.V_COMPTA_5
