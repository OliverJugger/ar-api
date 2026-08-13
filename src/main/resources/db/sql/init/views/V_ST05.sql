CREATE FORCE VIEW ARTHUS.V_ST05 AS
select  contrat.numinterm 	numsoc,
	contrat.numorg,
	contrat.refcie,
	contrat.numgar,
	contrat.numcli,
	contrat.refcie_chapeau,
	contrat.numprod,
	to_char(sntr.datsin,'yyyy') exercice,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.datpay,
	decaismt_prest.numbene,
	'' datesurv,
	-1 typdedu,
	'Prestations' lib_type,
	sntr.numdec		idpmtint,
	sntr.numdec		nosin,
	sntr.mtreel 		montant,
	sntr.idadhesion,
	1 			type,
	gar_cntrt.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.numfor_ref,
	sntr.mtreel 		mt_base,
	0 			mt_reval,
	'' 		datedcpt
from	contrat,
	gar_cntrt,
	sntr,
	affectation 	affectation_prest,
	decaismt 	decaismt_prest
where	contrat.numgar		= gar_cntrt.numgar
and	gar_cntrt.numfor 	= sntr.numfor
and	sntr.numdec 		= affectation_prest.numaffec
and	affectation_prest.numdecaismt = decaismt_prest.numdecaismt
and	decaismt_prest.flagpay	= 1
and	decaismt_prest.codope 	= 1
Union All
select  contrat.numinterm 	numsoc,
	contrat.numorg,
	contrat.refcie,
	contrat.numgar,
	contrat.numcli,
	contrat.refcie_chapeau,
	contrat.numprod,
	to_char(sntr.datsin,'yyyy') exercice,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(pnul.datannul,'dd/mm/yy') edatpay,
	pnul.datannul		datpay,
	decaismt_prest.numbene,
	'' datesurv,
	-1 typdedu,
	'Annulation' lib_type,
	sntr.numdec		idpmtint,
	sntr.numdec		nosin,
	-sntr.mtreel 		montant,
	sntr.idadhesion,
	1 			type,
	gar_cntrt.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.numfor_ref,
	-sntr.mtreel 		mt_base,
	0 			mt_reval,
	'' 		datedcpt
from	contrat,
	gar_cntrt,
	sinistre_annul		sntr,
	affectation_annul 	affectation_prest,
	decaismt 		decaismt_prest,
	pnul
where	contrat.numgar		= gar_cntrt.numgar
and	gar_cntrt.numfor 	= sntr.numfor
and	sntr.numdec 		= affectation_prest.numaffec
and	affectation_prest.numdecaismt = decaismt_prest.numdecaismt
and	decaismt_prest.codope 	= 9
and	decaismt_prest.numdecaismt = pnul.numdecaismt
Union All
select  contrat.numinterm 	numsoc,
	contrat.numorg,
	contrat.refcie,
	contrat.numgar,
	contrat.numcli,
	contrat.refcie_chapeau,
	contrat.numprod,
	to_char(sntr.datsin,'yyyy') exercice,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(pnul.datpay,'dd/mm/yy') edatpay,
	pnul.datpay		datpay,
	decaismt_prest.numbene,
	'' datesurv,
	-1 typdedu,
	'Prestation' lib_type,
	sntr.numdec		idpmtint,
	sntr.numdec		nosin,
	sntr.mtreel 		montant,
	sntr.idadhesion,
	1 			type,
	gar_cntrt.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.numfor_ref,
	sntr.mtreel 		mt_base,
	0 			mt_reval,
	'' 		datedcpt
from	contrat,
	gar_cntrt,
	sinistre_annul		sntr,
	affectation_annul 	affectation_prest,
	decaismt 		decaismt_prest,
	pnul
where	contrat.numgar		= gar_cntrt.numgar
and	gar_cntrt.numfor 	= sntr.numfor
and	sntr.numdec 		= affectation_prest.numaffec
and	affectation_prest.numdecaismt = decaismt_prest.numdecaismt
and	decaismt_prest.codope 	= 9
and	decaismt_prest.numdecaismt = pnul.numdecaismt
Union All
select  contrat.numinterm 		numsoc,
	contrat.numorg,
	contrat.refcie,
	contrat.numgar,
	contrat.numcli,
	contrat.refcie_chapeau,
	contrat.numprod,
	to_char(sntr.datsin,'yyyy') 	exercice,
	decaismt_prest.numencaismt	numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.datpay,
	decaismt_prest.numcli		numbene,
	'' datesurv,
	-1 typdedu,
	'Remb Indû' 			lib_type,
	sntr.numdec			idpmtint,
	sntr.numdec			nosin,
	sntr.mtreel 			montant,
	sntr.idadhesion,
	1 				type,
	gar_cntrt.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.numfor_ref,
	sntr.mtreel 		mt_base,
	0 			mt_reval,
	'' 		datedcpt
from	contrat,
	gar_cntrt,
	sntr,
	affectation 	affectation_prest,
	compte_client,
	encaismt 	decaismt_prest
where	contrat.numgar		= gar_cntrt.numgar
and	gar_cntrt.numfor 	= sntr.numfor
and	sntr.numdec 		= affectation_prest.numaffec
and	affectation_prest.codope	= 1
and	affectation_prest.numaffec	= compte_client.numfact
and	compte_client.numencaismt	= decaismt_prest.numencaismt
and	decaismt_prest.codope 	= 1
Union all
select	contrat.numinterm,
	contrat.numorg,
	contrat.refcie,
	contrat.numgar,
	contrat.numcli,
	contrat.refcie_chapeau,
	contrat.numprod,
	to_char(sin.datesurv,'yyyy') exercice,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.datpay,
	decaismt_prest.numbene,
	to_char(sin.datesurv,'dd/mm/yy') datesurv,
	-1 typdedu,
	 'Prestations' lib_type,
	decompte_prev.numdec			idpmtint,
	decompte_prev.numdec 			nosin,
	v_histo_calcul.montant_remb		montant,
	decompte_prev.idadhesion 		idadhesion,
	2 					type,
	gar_cntrt.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.numfor_ref,
	v_histo_calcul.mt_base,
	v_histo_calcul.reval,
	d2e(decompte_prev.datpay) datedcpt
from	contrat,
	gar_cntrt,
	sin,
	v_histo_calcul,
	decompte_prev,
	affectation 	affectation_prest,
	decaismt 	decaismt_prest
where	contrat.numgar		= gar_cntrt.numgar
and	gar_cntrt.numfor	= v_histo_calcul.numfor
and	sin.nosin		= v_histo_calcul.nosin
and	v_histo_calcul.numdec	= decompte_prev.numdec
and	decompte_prev.numdec	= affectation_prest.numaffec
and	affectation_prest.numdecaismt = decaismt_prest.numdecaismt
and	decaismt_prest.flagpay = 1
and	decaismt_prest.codope = 2
Union all
select	contrat.numinterm,
	contrat.numorg,
	contrat.refcie,
	contrat.numgar,
	contrat.numcli,
	contrat.refcie_chapeau,
	contrat.numprod,
	to_char(sin.datesurv,'yyyy') exercice,
	decaismt_prest.numdecaismt,
	decaismt_prest.refpmt,
	to_char(pnul.datannul,'dd/mm/yy') edatpay,
	pnul.datannul,
	decaismt_prest.numbene,
	to_char(sin.datesurv,'dd/mm/yy') datesurv,
	-1 typdedu,
	 'Annulation' lib_type,
	decompte_prev.numdec			idpmtint,
	decompte_prev.numdec 			nosin,
	-v_histo_calcul.montant_remb		montant,
	decompte_prev.idadhesion 		idadhesion,
	2 					type,
	gar_cntrt.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.numfor_ref,
	-v_histo_calcul.mt_base,
	-v_histo_calcul.reval,
	d2e(decompte_prev.datpay) datedcpt
from	contrat,
	gar_cntrt,
	sin,
	v_histo_calcul,
	decompte_prev,
	affectation 	affectation_prest,
	decaismt 	decaismt_prest,
	pnul
where	contrat.numgar		= gar_cntrt.numgar
and	gar_cntrt.numfor	= v_histo_calcul.numfor
and	sin.nosin		= v_histo_calcul.nosin
and	v_histo_calcul.numdec	= decompte_prev.numdec
and	decompte_prev.numdec	= affectation_prest.numaffec
and	affectation_prest.numdecaismt = decaismt_prest.numdecaismt
and	decaismt_prest.codope = 9
and	decaismt_prest.numdecaismt = pnul.numdecaismt
Union all
select	contrat.numinterm,
	contrat.numorg,
	contrat.refcie,
	contrat.numgar,
	contrat.numcli,
	contrat.refcie_chapeau,
	contrat.numprod,
	to_char(sin.datesurv,'yyyy') exercice,
	decaismt_prest.numencaismt		numdecaismt,
	decaismt_prest.refpmt,
	to_char(decaismt_prest.datpay,'dd/mm/yy') edatpay,
	decaismt_prest.datpay,
	decaismt_prest.numcli			numbene,
	to_char(sin.datesurv,'dd/mm/yy') datesurv,
	-1 typdedu,
	 'Remb Indus' lib_type,
	decompte_prev.numdec			idpmtint,
	decompte_prev.numdec 			nosin,
	v_histo_calcul.montant_remb		montant,
	decompte_prev.idadhesion 		idadhesion,
	2 					type,
	gar_cntrt.numfor,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.numfor_ref,
	v_histo_calcul.mt_base,
	v_histo_calcul.reval,
	d2e(decompte_prev.datpay) datedcpt
from	contrat,
	gar_cntrt,
	sin,
	v_histo_calcul,
	decompte_prev,
	affectation 	affectation_prest,
	compte_client,
	encaismt 	decaismt_prest
where	contrat.numgar		= gar_cntrt.numgar
and	gar_cntrt.numfor	= v_histo_calcul.numfor
and	sin.nosin		= v_histo_calcul.nosin
and	v_histo_calcul.numdec	= decompte_prev.numdec
and	decompte_prev.numdec	= affectation_prest.numaffec
and	affectation_prest.numaffec	= compte_client.numfact
and	compte_client.numencaismt	= decaismt_prest.numencaismt
and	decaismt_prest.codope = 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ST05 FOR ARTHUS.V_ST05
