CREATE FORCE VIEW ARTHUS.V_DCPTCIE02 AS
select	dcptcie.numdcptcie,
	dcptcie.numsoc,
	dcptcie.numorg,
	orgns.nom nomorg,
	dcptcie.datedeb,
	dcptcie.datefin,
	dcptcie.type,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yyyy') edatpay,
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
	indvs_cli.nom||' '||indvs_cli.prenom nomcli
from	orgns,
	indvs indvs_cli,
	contrat grnts,
	frmls,
	libelle lble_bran,
	sntr,
	dcpt,
	affectation affectation_prest,
	indvs indvs_bene,
	decaismt decaismt_prest,
	dcptcie
where	orgns.numorg=dcptcie.numorg +0
and	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = to_number(frmls.branche)
and	indvs_cli.numindiv=grnts.numcli
and	grnts.numgar = dcpt.numgar
and	frmls.numfor = sntr.numfor
and	sntr.numdec = dcpt.numdec
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	decaismt_prest.codope = 1
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
and	dcptcie.type = 1
and	dcptcie.numdcptcie = dcpt.numdcptcie
union all
select	dcptcie.numdcptcie,
	dcptcie.numsoc,
	dcptcie.numorg,
	orgns.nom nomorg,
	dcptcie.datedeb,
	dcptcie.datefin,
	dcptcie.type,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(pnul.datannul,'dd/mm/yyyy') edatpay,
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
	indvs_cli.nom||' '||indvs_cli.prenom nomcli
from	orgns,
	indvs indvs_cli,
	contrat grnts,
	frmls,
	libelle lble_bran,
	sinistre_annul sntr,
	decompte_annul dcpt,
	affectation_annul affectation_prest,
	indvs indvs_bene,
	pnul,
	decaismt decaismt_prest,
	dcptcie
where	orgns.numorg=dcptcie.numorg +0
and	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = to_number(frmls.branche)
and	indvs_cli.numindiv=grnts.numcli
and	grnts.numgar = dcpt.numgar
and	frmls.numfor = sntr.numfor
and	sntr.numdec = dcpt.numdec
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	decaismt_prest.codope = 9
and	decaismt_prest.numdecaismt = pnul.numdecaismt
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
and	dcptcie.type = 1
and	dcptcie.numdcptcie = dcpt.numdcptcie
union all
select	dcptcie.numdcptcie,
	dcptcie.numsoc,
	dcptcie.numorg,
	orgns.nom nomorg,
	dcptcie.datedeb,
	dcptcie.datefin,
	dcptcie.type,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yyyy') edatpay,
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
	indvs_cli.nom||' '||indvs_cli.prenom nomcli
from	orgns,
	indvs indvs_cli,
	contrat grnts,
	frmls,
	libelle lble_bran,
	sinistre_annul sntr,
	decompte_annul dcpt,
	affectation_annul affectation_prest,
	indvs indvs_bene,
	decaismt decaismt_prest,
	dcptcie
where	orgns.numorg=dcptcie.numorg +0
and	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = to_number(frmls.branche)
and	indvs_cli.numindiv=grnts.numcli
and	grnts.numgar = dcpt.numgar
and	frmls.numfor = sntr.numfor
and	sntr.numdec = dcpt.numdec
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	decaismt_prest.codope = 9
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
and	dcptcie.type = 1
and	dcptcie.numdcptcie = dcpt.numdcptcie
union all
select	dcptcie.numdcptcie,
	dcptcie.numsoc,
	dcptcie.numorg,
	orgns.nom nomorg,
	dcptcie.datedeb,
	dcptcie.datefin,
	dcptcie.type,
	to_char(sntr.datsin,'yyyy') exercice,
	grnts.refcie_chapeau,
	encaismt_prest.numencaismt,
	encaismt_prest.refpmt,
	to_char(encaismt_prest.datpay,'dd/mm/yyyy') edatpay,
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
	indvs_cli.nom||' '||indvs_cli.prenom nomcli
from	orgns,
	indvs indvs_cli,
	contrat grnts,
	frmls,
	libelle lble_bran,
	sntr,
	dcpt,
	affectation affectation_prest,
	indvs indvs_bene,
	compte_client,
	encaismt encaismt_prest,
	dcptcie
where	orgns.numorg=dcptcie.numorg +0
and	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = to_number(frmls.branche)
and	indvs_cli.numindiv=grnts.numcli
and	grnts.numgar = dcpt.numgar
and	frmls.numfor = sntr.numfor
and	sntr.numdec = dcpt.numdec
and	compte_client.codope = 1
and	compte_client.numfact = affectation_prest.numaffec
and	encaismt_prest.numencaismt = compte_client.numencaismt
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	indvs_bene.numindiv   = encaismt_prest.numcli
and	encaismt_prest.codope = 1
and	dcptcie.type = 1
and	dcptcie.numdcptcie = dcpt.numdcptcie
union all
select	dcptcie.numdcptcie,
	dcptcie.numsoc,
	dcptcie.numorg,
	orgns.nom nomorg,
	dcptcie.datedeb,
	dcptcie.datefin,
	dcptcie.type,
	to_char(sin.datesurv,'yyyy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yyyy') edatpay,
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
	'Prestations' lib_type,
	decompte_prev.numdec,
	decompte_prev.numdec nosin,
	v_histo_calcul.montant_remb		montant,
	decompte_prev.idadhesion idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli
from	libelle lble_bran,
	grnts,
	adhe_cntrt,
	indvs indvs_bene,
	indvs indvs_cli,
	gar,
	orgns,
	decaismt decaismt_prest,
	affectation affectation_prest,
	sin,
	v_histo_calcul,
	decompte_prev,
	dcptcie
where	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = gar.classe_gar
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	indvs_cli.numindiv=grnts.numcli
and	gar.numfor = v_histo_calcul.numfor
and	grnts.numgar = adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	orgns.numorg = dcptcie.numorg
and	affectation_prest.numaffec = decompte_prev.numdec
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
and	affectation_prest.codope = 2
and	v_histo_calcul.numdec=decompte_prev.numdec
and	v_histo_calcul.nosin=sin.nosin
and	dcptcie.numdcptcie = decompte_prev.numdcptcie
and	dcptcie.type = 2
union all
select	dcptcie.numdcptcie,
	dcptcie.numsoc,
	dcptcie.numorg,
	orgns.nom nomorg,
	dcptcie.datedeb,
	dcptcie.datefin,
	dcptcie.type,
	to_char(sin.datesurv,'yyyy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yyyy') edatpay,
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
	'Prestations' lib_type,
	decompte_prev.numdec,
	decompte_prev.numdec nosin,
	v_histo_calcul.montant_remb		montant,
	decompte_prev.idadhesion idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli
from	libelle lble_bran,
	grnts,
	adhe_cntrt,
	indvs indvs_bene,
	indvs indvs_cli,
	gar,
	orgns,
	decaismt decaismt_prest,
	affectation_annul affectation_prest,
	sin,
	v_histo_calcul,
	decompte_prev,
	dcptcie
where	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = gar.classe_gar
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	indvs_cli.numindiv=grnts.numcli
and	gar.numfor = v_histo_calcul.numfor
and	grnts.numgar = adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	affectation_prest.numaffec = decompte_prev.numdec
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
and	decaismt_prest.codope = 9
and	affectation_prest.codope = 2
and	v_histo_calcul.numdec=decompte_prev.numdec
and	v_histo_calcul.nosin=sin.nosin
and	orgns.numorg = dcptcie.numorg
and	dcptcie.numdcptcie = decompte_prev.numdcptcie
and	dcptcie.type = 2
union all
select	dcptcie.numdcptcie,
	dcptcie.numsoc,
	dcptcie.numorg,
	orgns.nom nomorg,
	dcptcie.datedeb,
	dcptcie.datefin,
	dcptcie.type,
	to_char(sin.datesurv,'yyyy') exercice,
	grnts.refcie_chapeau,
	encaismt_prest.numencaismt,
	encaismt_prest.refpmt,
	to_char(encaismt_prest.datpay,'dd/mm/yyyy') edatpay,
	encaismt_prest.numcli,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	to_char(sin.datesurv,'dd/mm/yy') datesurv,
	gar.nomgar,
	gar.libelle libgar,
	gar.classe_gar branche,
	lble_bran.libelle,
	-1 typdedu,
	'Indus de prestations' lib_type,
	decompte_prev.numdec,
	decompte_prev.numdec nosin,
	v_histo_calcul.montant_remb		montant,
	decompte_prev.idadhesion idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli
from
	libelle lble_bran,
	grnts,
	adhe_cntrt,
	indvs indvs_bene,
	indvs indvs_cli,
	gar,
	sin,
	orgns,
	encaismt encaismt_prest,
	compte_client,
	affectation affectation_prest,
	v_histo_calcul,
	decompte_prev,
	dcptcie
where	lble_bran.mnemo (+) ='BRAN'
and	lble_bran.code  (+) = gar.classe_gar
and	indvs_bene.numindiv   = encaismt_prest.numcli
and	indvs_cli.numindiv=grnts.numcli
and	gar.numfor = v_histo_calcul.numfor
and	grnts.numgar = adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	sin.nosin=v_histo_calcul.nosin
and	orgns.numorg = dcptcie.numorg
and	affectation_prest.numaffec = decompte_prev.numdec
and	compte_client.numfact = affectation_prest.numaffec
and	encaismt_prest.numencaismt = compte_client.numencaismt
and	v_histo_calcul.numdec=decompte_prev.numdec
and	affectation_prest.codope = 2
and	compte_client.codope = 2
and	dcptcie.numdcptcie = decompte_prev.numdcptcie
and	dcptcie.type = 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTCIE02 FOR ARTHUS.V_DCPTCIE02
