CREATE FORCE VIEW ARTHUS.V_STATS_MAL AS
select  grnts.numinterm numsoc,
	grnts.numorg,
	tmp_organisme.nom nomorg,
	to_char(sntr.datsin,'yy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.datpay,
	decaismt_prest.numbene,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	'' datesurv,
	-1 typdedu,
	'Prestations' lib_type,
	dcpt.numdec idpmtint,
	dcpt.numdec nosin,
	sntr.mtreel montant,
	sntr.idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	grnts.numprod,
	produit.libelle,
	societe.nom,
	1 type,
	gar_cntrt.nomgar,
	gar_cntrt.numfor_ref
from	tmp_organisme,
	produit,
	societe,
	indvs indvs_cli,
	indvs indvs_bene,
	contrat grnts,
	gar_cntrt,
	sntr,
	dcpt,
	affectation affectation_prest,
	decaismt decaismt_prest
where	tmp_organisme.numorg = grnts.numorg
and	produit.numprod= grnts.numprod
and	societe.numsoc = grnts.numinterm
and	indvs_cli.numindiv = grnts.numcli
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	grnts.numgar = gar_cntrt.numgar
and	gar_cntrt.numfor = sntr.numfor
and	sntr.numdec = dcpt.numdec
and	dcpt.numdec = affectation_prest.numaffec
and	affectation_prest.numdecaismt = decaismt_prest.numdecaismt
and	decaismt_prest.flagpay + 0 = 1
and	decaismt_prest.codope = 1
union all
select	grnts.numinterm,
	grnts.numorg,
	tmp_organisme.nom nomorg,
	to_char(sntr.datsin,'yy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(pnul.datannul,'dd/mm/yy') edatpay,
	pnul.datannul,
	decaismt_prest.numbene,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	'' datesurv,
	-1 typdedu,
	'Annulation' lib_type,
	dcpt.numdec idpmtint,
	dcpt.numdec nosin,
	-sntr.mtreel montant,
	sntr.idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	grnts.numprod,
	produit.libelle,
	societe.nom,
	1 type,
	gar_cntrt.nomgar,
	gar_cntrt.numfor_ref
from	tmp_organisme,
	produit,
	societe,
	indvs indvs_cli,
	contrat grnts,
	gar_cntrt,
	sinistre_annul sntr,
	decompte_annul dcpt,
	affectation_annul affectation_prest,
	indvs indvs_bene,
	pnul,
	decaismt decaismt_prest
where	tmp_organisme.numorg=grnts.numorg +0
and	produit.numprod=grnts.numprod +0
and	grnts.numinterm+0 =societe.numsoc
and	indvs_cli.numindiv=grnts.numcli
and	sntr.numdec = dcpt.numdec
and	sntr.numfor=gar_cntrt.numfor
and	grnts.numgar = dcpt.numgar
and	grnts.numgar = gar_cntrt.numgar
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	decaismt_prest.numdecaismt=pnul.numdecaismt
and	decaismt_prest.refpmt is not null
and	decaismt_prest.codope = 9
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
union all
select  grnts.numinterm numsoc,
	grnts.numorg,
	tmp_organisme.nom nomorg,
	to_char(sntr.datsin,'yy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.datpay,
	decaismt_prest.numbene,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	'' datesurv,
	-1 typdedu,
	'Prestations' lib_type,
	dcpt.numdec idpmtint,
	dcpt.numdec nosin,
	sntr.mtreel montant,
	sntr.idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	grnts.numprod,
	produit.libelle,
	societe.nom,
	1 type,
	gar_cntrt.nomgar,
	gar_cntrt.numfor_ref
from	tmp_organisme,
	produit,
	societe,
	indvs indvs_cli,
	contrat grnts,
	gar_cntrt,
	sinistre_annul sntr,
	decompte_annul dcpt,
	affectation_annul affectation_prest,
	indvs indvs_bene,
	decaismt decaismt_prest
where	tmp_organisme.numorg=grnts.numorg +0
and	produit.numprod=grnts.numprod +0
and	grnts.numinterm+0 =societe.numsoc
and	indvs_cli.numindiv=grnts.numcli
and	sntr.numdec = dcpt.numdec
and	sntr.numfor=gar_cntrt.numfor
and	grnts.numgar = dcpt.numgar
and	grnts.numgar = gar_cntrt.numgar
and	affectation_prest.numaffec = dcpt.numdec
and	affectation_prest.codope = 1
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	decaismt_prest.refpmt is not null
and	decaismt_prest.codope = 9
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
union all
select	grnts.numinterm,
	grnts.numorg,
	tmp_organisme.nom nomorg,
	to_char(sntr.datsin,'yy') exercice,
	grnts.refcie_chapeau,
	encaismt_prest.numencaismt,
	encaismt_prest.refpmt,
	to_char(encaismt_prest.datpay,'dd/mm/yy') edatpay,
	encaismt_prest.datpay,
	encaismt_prest.numcli,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	'' datesurv,
	-1 typdedu,
	'Indus de Prestation' lib_type,
	dcpt.numdec idpmtint,
	dcpt.numdec nosin,
	sntr.mtreel montant,
	sntr.idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	grnts.numprod,
	produit.libelle,
	societe.nom,
	1 type,
	gar_cntrt.nomgar,
	gar_cntrt.numfor_ref
from	tmp_organisme,
	produit,
	societe,
	indvs indvs_cli,
	contrat grnts,
	gar_cntrt,
	sntr,
	dcpt,
	compte_client,
	affectation affectation_prest,
	indvs indvs_bene,
	encaismt encaismt_prest
where	tmp_organisme.numorg=grnts.numorg +0
and	produit.numprod=grnts.numprod +0
and	grnts.numinterm+0 =societe.numsoc
and	indvs_cli.numindiv=grnts.numcli
and	sntr.numdec = dcpt.numdec
and	sntr.numfor=gar_cntrt.numfor
and	grnts.numgar = dcpt.numgar
and	grnts.numgar = gar_cntrt.numgar
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
	tmp_organisme.nom nomorg,
	to_char(sin.datesurv,'yy') exercice,
	grnts.refcie_chapeau,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.datpay,
	decaismt_prest.numbene,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	to_char(sin.datesurv,'dd/mm/yy') datesurv,
	-1 typdedu,
	 'Prestations' lib_type,
	decompte_prev.numdec,
	decompte_prev.numdec nosin,
	v_histo_calcul.montant,
	decompte_prev.idadhesion idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	grnts.numprod,
	produit.libelle,
	societe.nom,
	2 type,
	gar_cntrt.nomgar,
	gar_cntrt.numfor_ref
from	grnts,
	adhe_cntrt,
	gar_cntrt,
	decaismt decaismt_prest,
	affectation affectation_prest,
	decompte_prev,
	v_histo_calcul,
	indvs indvs_bene,
	indvs indvs_cli,
	sin,
	tmp_organisme,
	societe,
	produit
where	affectation_prest.numaffec = decompte_prev.numdec
and	decaismt_prest.numdecaismt = affectation_prest.numdecaismt
and	decaismt_prest.codope = 2
and	affectation_prest.codope = 2
and	indvs_bene.numindiv   = decaismt_prest.numbene
and	adhe_cntrt.numgar=grnts.numgar
and	decompte_prev.idadhesion=adhe_cntrt.idadhesion
and	indvs_cli.numindiv=grnts.numcli
and	grnts.numgar = gar_cntrt.numgar
and	v_histo_calcul.numfor=gar_cntrt.numfor
and	v_histo_calcul.nosin = sin.nosin
and	v_histo_calcul.numdec=decompte_prev.numdec
and	tmp_organisme.numorg = grnts.numorg
and	grnts.numinterm=societe.numsoc
and	produit.numprod=grnts.numprod
union all
select	grnts.numinterm,
	grnts.numorg,
	tmp_organisme.nom nomorg,
	to_char(sin.datesurv,'yy') exercice,
	grnts.refcie_chapeau,
	encaismt_prest.numencaismt,
	encaismt_prest.refpmt,
	to_char(encaismt_prest.datpay,'dd/mm/yy') edatpay,
	encaismt_prest.datpay,
	encaismt_prest.numcli,
	indvs_bene.nom||' '||indvs_bene.prenom nombene,
	grnts.refcie,
	grnts.numgar,
	to_char(sin.datesurv,'dd/mm/yy') datesurv,
	-1 typdedu,
	'Indus de prestations' lib_type,
	decompte_prev.numdec,
	decompte_prev.numdec,
	-v_histo_calcul.montant,
	decompte_prev.idadhesion idadhesion,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	grnts.numprod,
	produit.libelle,
	societe.nom,
	2 type,
	gar_cntrt.nomgar,
	gar_cntrt.numfor_ref
from	grnts,
	adhe_cntrt,
	gar_cntrt,
	encaismt encaismt_prest,
	compte_client,
	affectation affectation_prest,
	decompte_prev,
	v_histo_calcul,
	indvs indvs_bene,
	indvs indvs_cli,
	sin,
	tmp_organisme,
	societe,
	produit
where	affectation_prest.numaffec = decompte_prev.numdec
and	compte_client.numfact = affectation_prest.numaffec
and	encaismt_prest.numencaismt = compte_client.numencaismt
and	affectation_prest.codope = 2
and	compte_client.codope = 2
and	indvs_bene.numindiv   = encaismt_prest.numcli
and	indvs_cli.numindiv=grnts.numcli
and	v_histo_calcul.numfor=gar_cntrt.numfor
and	v_histo_calcul.nosin = sin.nosin
and	v_histo_calcul.numdec=decompte_prev.numdec
and	grnts.numgar = adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	grnts.numgar = gar_cntrt.numgar
and	tmp_organisme.numorg = grnts.numorg
and	grnts.numinterm=societe.numsoc
and	produit.numprod=grnts.numprod
GO
CREATE OR REPLACE PUBLIC SYNONYM V_STATS_MAL FOR ARTHUS.V_STATS_MAL
