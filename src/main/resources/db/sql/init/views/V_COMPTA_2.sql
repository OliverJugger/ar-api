CREATE FORCE VIEW ARTHUS.V_COMPTA_2 AS
Select	compte.numsoc 			numsoc,
	'decaismt'			sur_entite,
	decaismt.numdecaismt		cle_unique,
	'decaismt' 		entite,
	decaismt.numdecaismt	cle,
	decaismt.idcompta,
	decaismt.codope		codope,
	1 			type_ope,
	f_assureur(repartition.numfor)
		 		cie,
	decaismt.numbene 	indv,
	repartition.numfor 	gar,
	0 			int,
	compte.cmpt_gene 	bqe,
	Substr(to_char(decaismt.numdecaismt, '00000000'), 2, 8)	refpiece,
	decaismt.datpay 		dat_piece,
	to_number(sin.nosin)		lib_piece_1,
	sin.numindiv			lib_piece_2,
	sum( f_total_histo(histo_jours.idhisto, -2) )	montant1,
	sum( f_total_histo(histo_jours.idhisto, -2) ) +
		sum( f_total_histo(histo_jours.idhisto, -3) )
							montant2,
	sum( f_total_histo(histo_jours.idhisto, -3) )
							montant3,
	0 montant4,
	0 montant5,
	0 montant6
From
	compte,
	sin,
	histo_jours,
	histo_calcul,
	repartition,
	affectation,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	sin.nosin		= repartition.nosin
and	repartition.idrepartition = histo_calcul.idrepartition
and	histo_jours.idcalcul	= histo_calcul.idcalcul
and	histo_calcul.numdec	= affectation.numaffec
and 	affectation.numdecaismt	= decaismt.numdecaismt
and	decaismt.modpmt != 2
and	decaismt.codope + 0 = 2
and	decaismt.flagpay = 1
group by
	compte.numsoc,
	decaismt.codope,
	decaismt.idcompta,
	decaismt.numbene,
	repartition.numfor,
	compte.cmpt_gene,
	decaismt.numdecaismt,
	decaismt.datpay,
	affectation.dataffec,
	sin.nosin,
	sin.numindiv
/*
	PRESTATIONS PREVOYANCE VIREMENTS
	--------------------------------
*/
Union All
Select	compte.numsoc 			numsoc,
	'virement'			sur_entite,
	remise_vire.numremise		cle_unique,
	'decaismt' 		entite,
	decaismt.numdecaismt	cle,
	decaismt.idcompta,
	decaismt.codope		codope,
	2 			type_ope,
	f_assureur(repartition.numfor)
		 		cie,
	0 			indv,
	repartition.numfor 	gar,
	0 			int,
	compte.cmpt_gene 	bqe,
	substr(to_char(remise_vire_detail.numremise,'00000000'),2,8) refpiece,
	remise_vire.datrem 		dat_piece,
	to_number(sin.nosin)		lib_piece_1,
	sin.numindiv			lib_piece_2,
	sum( f_total_histo(histo_jours.idhisto, -2) )	montant1,
	sum( f_total_histo(histo_jours.idhisto, -2) ) +
		sum( f_total_histo(histo_jours.idhisto, -3) )
							montant2,
	sum( f_total_histo(histo_jours.idhisto, -3) )
							montant3,
	0 				montant4,
	0 				montant5,
	0 				montant6
From
	compte,
	sin,
	histo_jours,
	histo_calcul,
	repartition,
	affectation,
	remise_vire,
	remise_vire_detail,
	decaismt
Where	compte.numcpte		= decaismt.numcpte
and	sin.nosin		= repartition.nosin
and	repartition.idrepartition = histo_calcul.idrepartition
and	histo_jours.idcalcul	= histo_calcul.idcalcul
and	histo_calcul.numdec	= affectation.numaffec
and 	affectation.numdecaismt	= decaismt.numdecaismt
and 	remise_vire.numremise	= remise_vire_detail.numremise
and 	remise_vire_detail.numdecaismt	= decaismt.numdecaismt
and	decaismt.codope + 0 = 2
and	decaismt.modpmt 	= 2
group by
	compte.numsoc,
	decaismt.codope,
	remise_vire.numremise,
	decaismt.idcompta,
	remise_vire_detail.numremise,
	compte.cmpt_gene,
	remise_vire.datrem,
	decaismt.numdecaismt,
	sin.nosin,
	sin.numindiv,
	repartition.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_2 FOR ARTHUS.V_COMPTA_2
