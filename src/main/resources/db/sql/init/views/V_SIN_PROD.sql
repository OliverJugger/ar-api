CREATE FORCE VIEW ARTHUS.V_SIN_PROD AS
select	contrat.numgar,
	contrat.numinterm numsoc,
	contrat.numorg,
	contrat.numcli,
	contrat.numprod,
	sntr.datsin debut,
	sntr.datsin fin,
	sntr.mtreel montant,
	sntr.numfor,
	''		nosin,
	sntr.codfrais,
	sntr.idadhesion,
	1 codope,
	gar_cntrt.numfor_ref
from	decaismt,
	affectation,
	sntr,
	dcpt,
	contrat,
	gar_cntrt
where	decaismt.refpmt is not null
and	decaismt.codope = 1
and	decaismt.numdecaismt = affectation.numdecaismt
and	affectation.numaffec = dcpt.numdec
and	sntr.numdec=dcpt.numdec
and	gar_cntrt.numfor=sntr.numfor
and	contrat.numgar=dcpt.numgar
and gar_cntrt.numgar=contrat.numgar
UNION
select	contrat.numgar,
	contrat.numinterm numsoc,
	contrat.numorg,
	contrat.numcli,
	contrat.numprod,
	sntr.datsin debut,
	sntr.datsin fin,
	-sntr.mtreel montant,
	sntr.numfor,
	'' 		nosin,
	sntr.codfrais,
	sntr.idadhesion,
	1 codope,
	gar_cntrt.numfor_ref
from	decaismt,
	affectation_annul affectation,
	sinistre_annul sntr,
	decompte_annul dcpt,
	contrat,
	gar_cntrt
where	decaismt.refpmt is not null
and	decaismt.codope = 9
and	decaismt.numdecaismt = affectation.numdecaismt
and	affectation.codope = 1
and	affectation.numaffec = dcpt.numdec
and	sntr.numdec=dcpt.numdec
and	gar_cntrt.numfor=sntr.numfor
and	contrat.numgar=dcpt.numgar
and	gar_cntrt.numgar=contrat.numgar
UNION
select	contrat.numgar,
	contrat.numinterm numsoc,
	contrat.numorg,
	contrat.numcli,
	contrat.numprod,
	sin.datesurv debut,
	sin.datefin fin,
	v_histo_calcul.montant montant,
	v_histo_calcul.numfor,
	sin.nosin,
	'' codfrais,
	0,
	2 codope,
	gar_cntrt.numfor_ref
from	contrat,
	decompte_prev,
	v_histo_calcul,
	sin,
	affectation,
	decaismt,
	adhe_cntrt,
	gar_cntrt
where	contrat.numgar=adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	decompte_prev.numdec=v_histo_calcul.numdec
and	affectation.numaffec=decompte_prev.numdec
and 	affectation.numdecaismt=decaismt.numdecaismt
and 	sin.nosin=f_sin(decompte_prev.numdec)
and 	affectation.codope=2
and 	decaismt.codope=2
and	gar_cntrt.numfor=v_histo_calcul.numfor
and	gar_cntrt.numgar=contrat.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SIN_PROD FOR ARTHUS.V_SIN_PROD
