CREATE FORCE VIEW ARTHUS.V_STATS_MAL02 AS
select	grnts.numinterm numsoc,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.numbene,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	'' datesurv,
	frmls.nomgar nomgar,
	frmls.libelle libgar,
	to_number(frmls.branche) branche,
	lble_bran.libelle lib_branche,
	-1 typdedu,
	'Prestations' lib_type,
	dcpt.numdec idpmtint,
	dcpt.numdec nosin,
	(sntr.mtreel) montant,
	sntr.idadhesion,
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
	indvs indvs_bene,
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
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	decaismt_prest.refpmt is not null
and	decaismt_prest.codope = 1
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
union all
select	grnts.numinterm,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(pnul.datannul,'dd/mm/yy') edatpay,
	decaismt_prest.numbene,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	'' datesurv,
	frmls.nomgar nomgar,
	frmls.libelle libgar,
	to_number(frmls.branche) branche,
	lble_bran.libelle lib_branche,
	-1 typdedu,
	'Annulation' lib_type,
	dcpt.numdec idpmtint,
	dcpt.numdec nosin,
	-(sntr.mtreel) montant,
	sntr.idadhesion,
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
	indvs indvs_bene,
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
and	indvs_bene.numindiv   = decaismt_prest.numbene
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
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.numbene,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	'' datesurv,
	frmls.nomgar nomgar,
	frmls.libelle libgar,
	to_number(frmls.branche) branche,
	lble_bran.libelle lib_branche,
	-1 typdedu,
	'Prestations' lib_type,
	dcpt.numdec idpmtint,
	dcpt.numdec nosin,
	(sntr.mtreel) montant,
	sntr.idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	decaismt_prest.datpay,
	1 type
from	libelle lble_bran,
	orgns,
	indvs indvs_cli,
	contrat grnts,
	frmls,
	sinistre_annul sntr,
	decompte_annul dcpt,
	affectation_annul affectation_prest,
	indvs indvs_bene,
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
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	decaismt_prest.refpmt is not null
and	decaismt_prest.codope = 9
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
union all
select	grnts.numinterm numsoc,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	encaismt_prest.numencaismt,
	encaismt_prest.refpmt,
	to_char(encaismt_prest.datpay,'dd/mm/yy') edatpay,
	encaismt_prest.numcli,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	'' datesurv,
	frmls.nomgar nomgar,
	frmls.libelle libgar,
	to_number(frmls.branche) branche,
	lble_bran.libelle lib_branche,
	-1 typdedu,
	'Indus de Prestation' lib_type,
	dcpt.numdec idpmtint,
	dcpt.numdec nosin,
	sntr.mtreel montant,
	sntr.idadhesion,
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
	indvs indvs_bene,
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
and	indvs_bene.numindiv   = encaismt_prest.numcli
and	encaismt_prest.numencaismt = compte_client.numencaismt
and	encaismt_prest.refpmt is not null
and	encaismt_prest.codope = 1
union all
select	grnts.numinterm,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sin.datesurv,'yyyy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.numbene,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	to_char(sin.datesurv,'dd/mm/yy') datesurv,
	gar.nomgar,
	gar.libelle libgar,
	gar.classe_gar branche,
	lble_bran.libelle,
	-1 typdedu,
	'Prestations'lib_type,
	decompte_prev.numdec,
	decompte_prev.numdec,
	v_histo_calcul.montant,
	decompte_prev.idadhesion idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	decaismt_prest.datpay,
	2 type
from	grnts,
	adhe_cntrt,
	decaismt decaismt_prest,
	affectation affectation_prest,
	decompte_prev,
	v_histo_calcul,
	indvs indvs_bene,
	indvs indvs_cli,
	gar,
	sin,
	orgns,
	libelle lble_bran
where	affectation_prest.numaffec = decompte_prev.numdec
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
and	decaismt_prest.codope = 2
and	affectation_prest.codope = 2
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	indvs_cli.numindiv=grnts.numcli
and	gar.numfor = v_histo_calcul.numfor
and	grnts.numgar = adhe_cntrt.numgar
and	decompte_prev.idadhesion=adhe_cntrt.idadhesion
and	v_histo_calcul.nosin = sin.nosin
and	v_histo_calcul.numdec=decompte_prev.numdec
and	orgns.numorg = grnts.numorg
and	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = gar.classe_gar
union all
select	grnts.numinterm,
	grnts.numorg,
	orgns.nom nomorg,
	to_char(sin.datesurv,'yyyy') exercice,
	grnts.refcie_chapeau,
	encaismt_prest.numencaismt,
	encaismt_prest.refpmt,
	to_char(encaismt_prest.datpay,'dd/mm/yy') edatpay,
	encaismt_prest.numcli,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	to_char(sin.datesurv,'dd/mm/yy') datesurv,
	gar.nomgar,
	gar.libelle libgar,
	gar.classe_gar,
	lble_bran.libelle,
	-1 typdedu,
	'Indus de prestations' lib_type,
	decompte_prev.numdec,
	decompte_prev.numdec,
	-v_histo_calcul.montant,
	decompte_prev.idadhesion idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	encaismt_prest.datpay,
	2 type
from	grnts,
	adhe_cntrt,
	encaismt encaismt_prest,
	compte_client,
	affectation affectation_prest,
	decompte_prev,
	v_histo_calcul,
	indvs indvs_bene,
	indvs indvs_cli,
	gar,
	sin,
	orgns,
	libelle lble_bran
where	affectation_prest.numaffec = decompte_prev.numdec
and	compte_client.numfact = affectation_prest.numaffec
and	encaismt_prest.numencaismt = compte_client.numencaismt
and	affectation_prest.codope = 2
and	compte_client.codope = 2
and	indvs_bene.numindiv   = encaismt_prest.numcli
and	indvs_cli.numindiv=grnts.numcli
and	gar.numfor = v_histo_calcul.numfor
and	grnts.numgar = adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	v_histo_calcul.nosin = sin.nosin
and	v_histo_calcul.numdec=decompte_prev.numdec
and	orgns.numorg = grnts.numorg
and	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = gar.classe_gar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_STATS_MAL02 FOR ARTHUS.V_STATS_MAL02
