CREATE FORCE VIEW ARTHUS.V_ASSU_DCPT AS
select	adhe_cntrt.numgar numgar,
	sin.numindiv,
	sin.nosin,
	decompte_prev.montant montant,
	decompte_prev.montant_d montant_d,
	decompte_prev.numdec,
	to_char(decompte_prev.datpay,'DD/MM/YYYY') dataffec,
	to_char(decaismt.datpay,'DD/MM/YYYY') datpay,
	affectation.codope,
	decaismt.refpmt,
	decaismt.numdecaismt,
	decaismt.numedit
from	adhe_cntrt,
	affectation,
	decaismt,
	decompte_prev,
	repartition,
	sin
where	adhe_cntrt.idadhesion = decompte_prev.idadhesion
and	affectation.codope=2
and	decaismt.numdecaismt = affectation.numdecaismt
and	decompte_prev.numdec=affectation.numaffec
and	repartition.idadhesion=adhe_cntrt.idadhesion
and	sin.nosin=repartition.nosin
and	exists(select 1 from histo_calcul
		where histo_calcul.idrepartition=repartition.idrepartition
		and histo_calcul.numdec=decompte_prev.numdec)
union
select	distinct adhe_cntrt.numgar numgar,
	sin.numindiv,
	sin.nosin,
 	sum( f_total_histo(histo_jours.idhisto, -2) ),
 	sum( f_total_histo_d(histo_jours.idhisto, -2) ),
	0,
	'' dataffec,
	'' datpay,
	0,
	0,
	0,
	-1
from	sin,
	adhe_cntrt,
	histo_jours,
	histo_calcul,
	repartition
where	histo_jours.idcalcul = histo_calcul.idcalcul
and	adhe_cntrt.idadhesion = repartition.idadhesion
And	repartition.idrepartition = histo_calcul.idrepartition
and	repartition.nosin = sin.nosin
and	histo_calcul.numdec = 0
group by
	adhe_cntrt.numgar ,
	sin.numindiv,
	sin.nosin
union
select 	dcpt.numgar,
	dcpt.numindiv,
	'',
	dcpt.montant,
	dcpt.montant_d,
	dcpt.numdec,
	to_char(dcpt.datpay,'DD/MM/YYYY') dataffec,
	to_char(decaismt.datpay,'DD/MM/YYYY') datpay,
	affectation.codope,
	decaismt.refpmt,
	decaismt.numdecaismt,
	decaismt.numedit
from	dcpt,affectation,decaismt
where	dcpt.numdec=affectation.numaffec
and	affectation.numdecaismt=decaismt.numdecaismt
and	affectation.codope=1
union
select	distinct sntr.numgar numgar,
	sntr.numindiv,
	'',
	sum(sntr.mtprest),
	sum(sinistre_dev.mtprest_out),
	0,
	'' dataffec,
	'' datpay,
	0,
	0,
	0,
	-1
from	sntr, sinistre_dev
where sntr.numsin = sinistre_dev.numsin
and nvl(sntr.numdec,0)=0
group by
	sntr.numgar ,
	sntr.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ASSU_DCPT FOR ARTHUS.V_ASSU_DCPT
