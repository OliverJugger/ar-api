CREATE FORCE VIEW ARTHUS.V_DCPTDEDU_TOT AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numcli,
	indvs.nom||' '||indvs.prenom nomcli,
	sum(f_total_histo(histo_dedu.idhisto,histo_dedu.typdedu)) montant,
	sum(f_total_histo_d(histo_dedu.idhisto,histo_dedu.typdedu)) montant_d,
	dcptdedu.numdec
from indvs,
	grnts,
	adhe_cntrt,
	decompte_prev,
	histo_calcul,
	histo_jours,
	histo_dedu,
	dcptdedu
where	histo_dedu.idhisto = histo_jours.idhisto
and	histo_jours.idcalcul=histo_calcul.idcalcul
and	histo_calcul.numdec=decompte_prev.numdec
and	decompte_prev.idadhesion=adhe_cntrt.idadhesion
and	adhe_cntrt.numgar=grnts.numgar
and	indvs.numindiv = grnts.numcli
and	dcptdedu.numdec=histo_dedu.numdec
Group By
	grnts.refcie,
	grnts.numgar,
	grnts.numcli,
	indvs.nom||' '||indvs.prenom,
	dcptdedu.numdec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTDEDU_TOT FOR ARTHUS.V_DCPTDEDU_TOT
