CREATE FORCE VIEW ARTHUS.V_STATS_BRANCHE AS
select	grnts.numinterm numsoc,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	grnts.refcie,
	grnts.numgar,
	to_number(frmls.branche) branche,
	lble_bran.libelle lib_branche,
	(sntr.mtreel) montant,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	decaismt_prest.datpay,
	1 type
from	libelle lble_bran,
	orgns,
	indvs indvs_cli,
	contrat grnts,
	frmls,
	sntr,
	dcpt,
	affectation affectation_prest,
	decaismt decaismt_prest
where	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = to_number(frmls.branche)
and	orgns.numorg=grnts.numorg +0
and	indvs_cli.numindiv=grnts.numcli
and	frmls.numfor = sntr.numfor
and	sntr.numdec = dcpt.numdec
and	grnts.numgar = dcpt.numgar
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	decaismt_prest.flagpay = 1
and	decaismt_prest.codope = 1
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
union all
select	grnts.numinterm,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	grnts.refcie,
	grnts.numgar,
	to_number(frmls.branche) branche,
	lble_bran.libelle lib_branche,
	-(sntr.mtreel) montant,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	pnul.datannul,
	1 type
from	libelle lble_bran,
	orgns,
	indvs indvs_cli,
	contrat grnts,
	frmls,
	sinistre_annul sntr,
	decompte_annul dcpt,
	affectation_annul affectation_prest,
	pnul,
	decaismt decaismt_prest
where	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = to_number(frmls.branche)
and	orgns.numorg=grnts.numorg +0
and	indvs_cli.numindiv=grnts.numcli
and	frmls.numfor = sntr.numfor
and	sntr.numdec = dcpt.numdec
and	grnts.numgar = dcpt.numgar
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	decaismt_prest.refpmt is not null
and	decaismt_prest.codope = 9
and	decaismt_prest.numdecaismt = pnul.numdecaismt
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
union all
select	grnts.numinterm numsoc,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	grnts.refcie,
	grnts.numgar,
	to_number(frmls.branche) branche,
	lble_bran.libelle lib_branche,
	(sntr.mtreel) montant,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	decaismt_prest.datpay,
	1 type
from	libelle lble_bran,
	orgns,
	indvs 	indvs_cli,
	contrat grnts,
	frmls,
	sinistre_annul sntr,
	decompte_annul dcpt,
	affectation_annul affectation_prest,
	decaismt decaismt_prest
where	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = to_number(frmls.branche)
and	orgns.numorg=grnts.numorg +0
and	indvs_cli.numindiv=grnts.numcli
and	frmls.numfor = sntr.numfor
and	sntr.numdec = dcpt.numdec
and	grnts.numgar = dcpt.numgar
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	decaismt_prest.refpmt is not null
and	decaismt_prest.codope = 9
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
union all
select	grnts.numinterm numsoc,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	grnts.refcie,
	grnts.numgar,
	to_number(frmls.branche) branche,
	lble_bran.libelle lib_branche,
	sntr.mtreel montant,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	encaismt_prest.datpay,
	1 type
from	libelle lble_bran,
	orgns,
	indvs indvs_cli,
	contrat grnts,
	frmls,
	sntr,
	dcpt,
	compte_client,
	affectation affectation_prest,
	encaismt encaismt_prest
where	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = to_number(frmls.branche)
and	orgns.numorg=grnts.numorg +0
and	indvs_cli.numindiv=grnts.numcli
and	sntr.numdec = dcpt.numdec
and	frmls.numfor = sntr.numfor
and	grnts.numgar = dcpt.numgar
and	compte_client.codope = 1
and	compte_client.numfact = affectation_prest.numaffec
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	encaismt_prest.numencaismt = compte_client.numencaismt
and	encaismt_prest.refpmt is not null
and	encaismt_prest.codope = 1
union all
select	grnts.numinterm,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sin.survenance, 'yyyy') exercice,
	grnts.refcie_chapeau,
	grnts.refcie,
	grnts.numgar,
	gar.classe_gar branche,
	lble_bran.libelle,
	f_total_histo(histo_jours.idhisto, -1) +
		f_total_histo(histo_jours.idhisto, 0)	montant,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	decaismt_prest.datpay,
	2 type
from	indvs		orgns,
	pers_organisme,
	contrat 	grnts,
	adhe_cntrt,
	indvs indvs_cli,
	libelle lble_bran,
	gar,
	sntr_prev	sin,
	repartition,
	histo_jours,
	histo_calcul,
	affectation affectation_prest,
	decaismt decaismt_prest
Where	lble_bran.mnemo (+) 	= 'BRAN'
and	lble_bran.code  (+) 	= gar.classe_gar
and	orgns.numindiv  	= pers_organisme.numindiv
and	pers_organisme.numorg  	= grnts.numorg
and	indvs_cli.numindiv	= grnts.numcli
and	grnts.numgar 		= adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= repartition.idadhesion
and	sin.nosin 		= repartition.nosin
and	gar.numfor 		= repartition.numfor
and	repartition.idrepartition = histo_calcul.idrepartition
and	histo_jours.idcalcul	= histo_calcul.idcalcul
and	histo_calcul.numdec	= affectation_prest.numaffec
and	affectation_prest.numdecaismt = decaismt_prest.numdecaismt
and	decaismt_prest.flagpay = 1
union all
select	grnts.numinterm,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sin.survenance, 'yyyy') exercice,
	grnts.refcie_chapeau,
	grnts.refcie,
	grnts.numgar,
	gar.classe_gar,
	lble_bran.libelle,
	- ( f_total_histo(histo_jours.idhisto, -1) +
		f_total_histo(histo_jours.idhisto, 0) ) 	montant,
	grnts.numcli,
	indvs_cli.nom ||' '|| indvs_cli.prenom nomcli,
	encaismt_prest.datpay,
	2 type
From	indvs			orgns,
	pers_organisme,
	contrat			grnts,
	adhe_cntrt,
	indvs 			indvs_cli,
	libelle 		lble_bran,
	gar,
	sntr_prev		sin,
	repartition,
	histo_jours,
	histo_calcul,
	affectation 		affectation_prest,
	compte_client,
	encaismt 		encaismt_prest
Where	lble_bran.mnemo (+) 	= 'BRAN'
and	lble_bran.code  (+) 	= gar.classe_gar
and	orgns.numindiv		= pers_organisme.numindiv
and	pers_organisme.numorg	= grnts.numorg
and	indvs_cli.numindiv	= grnts.numcli
and	grnts.numgar 		= adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= repartition.idadhesion
and	sin.nosin		= repartition.nosin
and	gar.numfor 		= repartition.numfor
and	repartition.idrepartition = histo_calcul.idrepartition
and	histo_jours.idcalcul	= histo_calcul.idcalcul
and	histo_calcul.numdec	= affectation_prest.numaffec
and	encaismt_prest.codope 	= 2
and	encaismt_prest.numencaismt 	= compte_client.numencaismt
and	affectation_prest.codope = 2
and	affectation_prest.numaffec = compte_client.numfact
and	compte_client.codope 	= 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_STATS_BRANCHE FOR ARTHUS.V_STATS_BRANCHE
