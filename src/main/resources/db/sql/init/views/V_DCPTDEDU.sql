CREATE FORCE VIEW ARTHUS.V_DCPTDEDU AS
select	dcptdedu.numdec,
	dcptdedu.debut datedeb,
	dcptdedu.fin datefin,
	11 codope,
	'Bdx de'||' '||libelle.libelle||' '||'au'||' '||
	to_char(dcptdedu.debut,'dd/mm/yyyy') lib_dcptdedu,
	v_histo_dcptdedu.nosin nosin,
	decaismt.datpay,
	decaismt.refpmt,
	sum(v_histo_dcptdedu.montant) montant,
	v_histo_dcptdedu.numbene,
	indvs.nom||' '||indvs.prenom nombene,
	dcptdedu.numsoc,
	decompte_prev.numdec numaffec,
	contrat.numgar,
	contrat.refcie
from	adhe_cntrt,
	contrat,
	dcptdedu,
	v_histo_dcptdedu,
	decompte_prev,
	affectation,
	decaismt,
	indvs,
	libelle
Where	v_histo_dcptdedu.numdec   = dcptdedu.numdec
and	v_histo_dcptdedu.typdedu  = dcptdedu.typdedu
and	contrat.numgar=adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	indvs.numindiv=v_histo_dcptdedu.numbene
and 	libelle.mnemo='DEDU'
and	libelle.code=dcptdedu.typdedu
and	decompte_prev.numdec	  = v_histo_dcptdedu.numdec_calc
and	affectation.codope=2
and	affectation.numdecaismt=decaismt.numdecaismt
and	affectation.numaffec=decompte_prev.numdec
group by
	dcptdedu.numdec,
	dcptdedu.debut,
	dcptdedu.fin,
	libelle.libelle,
	dcptdedu.debut,
	dcptdedu.fin,
	v_histo_dcptdedu.nosin,
	decaismt.datpay,
	decaismt.refpmt,
	v_histo_dcptdedu.numbene,
	indvs.nom||' '||indvs.prenom,
	dcptdedu.numsoc,
	decompte_prev.numdec,
	contrat.numgar,
	contrat.refcie
UNION
select	dcptdedu.numdec,
	dcptdedu.debut datedeb,
	dcptdedu.fin datefin,
	11 codope,
	'Bdx de'||' '||libelle.libelle||' '||'au'||' '||
	to_char(dcptdedu.debut,'dd/mm/yy') lib_dcptdedu,
	v_histo_dcptdedu.nosin nosin,
	encaismt.datpay,
	encaismt.refpmt,
	-sum(v_histo_dcptdedu.montant) montant,
	v_histo_dcptdedu.numbene,
	indvs.nom||' '||indvs.prenom nombene,
	dcptdedu.numsoc,
	decompte_prev.numdec numaffec,
	contrat.numgar,
	contrat.refcie
from	adhe_cntrt,
	contrat,
	dcptdedu,
	v_histo_dcptdedu,
	encaismt,
	compte_client,
	decompte_prev,
	indvs,
	libelle
Where	compte_client.codope = 2
and	v_histo_dcptdedu.numdec   = dcptdedu.numdec
and	v_histo_dcptdedu.typdedu  = dcptdedu.typdedu
and	contrat.numgar=adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	compte_client.numfact = decompte_prev.numdec
and	encaismt.numencaismt = compte_client.numencaismt
and	decompte_prev.numdec=v_histo_dcptdedu.numdec_calc
and	indvs.numindiv=v_histo_dcptdedu.numbene
and 	libelle.mnemo='DEDU'
and	libelle.code=dcptdedu.typdedu
group by
	dcptdedu.numdec,
	dcptdedu.debut,
	dcptdedu.fin,
	libelle.libelle,
	dcptdedu.debut,
	dcptdedu.fin,
	v_histo_dcptdedu.nosin,
	encaismt.datpay,
	encaismt.refpmt,
	v_histo_dcptdedu.numbene,
	indvs.nom||' '||indvs.prenom,
	dcptdedu.numsoc,
	decompte_prev.numdec,
	contrat.numgar,
	contrat.refcie
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTDEDU FOR ARTHUS.V_DCPTDEDU
