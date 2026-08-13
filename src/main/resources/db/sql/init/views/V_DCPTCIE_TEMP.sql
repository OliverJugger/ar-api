CREATE FORCE VIEW ARTHUS.V_DCPTCIE_TEMP AS
select	dcptcie.numdcptcie,
		contrat.refcie,
		contrat.numgar,
		sum(sinistre.mtreel) montant,
		contrat.numcli,
		ARTHUS.pk_personne.f_nom (contrat.numcli,30,0) nomcli,
		dcptcie.type
from	contrat,
		sinistre,
		affectation,
		decompte,
		dcptcie
Where	dcptcie.type = 1
and		dcptcie.numdcptcie = sinistre.numdcptcie
and		sinistre.numdec = decompte.numdec
and		decompte.numdec = affectation.numaffec
and		affectation.codope = 1
and		sinistre.numgar = contrat.numgar
group by
		dcptcie.numdcptcie,
		contrat.refcie,
		contrat.numgar,
		contrat.numcli,
		dcptcie.type
union all
/*
Annulations : On prend les montants en négatif parce que l'annulation du décompte crée des lignes positives dans sinistre_annul
*/
select	dcptcie.numdcptcie,
		contrat.refcie,
		contrat.numgar,
		-sum(sinistre.mtreel) montant,
		contrat.numcli,
		ARTHUS.pk_personne.f_nom (contrat.numcli,30,0) nomcli,
		dcptcie.type
from	contrat,
		sinistre_annul sinistre,
		affectation_annul affectation,
		decompte_annul	decompte,
		dcptcie
Where	dcptcie.type = 1
and		dcptcie.numdcptcie = sinistre.numdcptcie
and		sinistre.numdec = decompte.numdec
and		decompte.numdec = affectation.numaffec
and		affectation.codope = 1
and		contrat.numgar = sinistre.numgar
group by
		dcptcie.numdcptcie,
		contrat.refcie,
		contrat.numgar,
		contrat.numcli,
		dcptcie.type
union all
/*
Indus : On prend les montants tels quels parce que le sinistre annulé donnant lieu à indu est en négatif dans sinistre, en négatif dans décompte mais par contre, il est en positif dans compte_client
*/
select	dcptcie.numdcptcie,
		contrat.refcie,
		contrat.numgar,
		sum(sinistre.mtreel) montant,
		contrat.numcli,
		ARTHUS.pk_personne.f_nom (contrat.numcli,30,0) nomcli,
		dcptcie.type
from	contrat,
		sinistre,
		compte_client,
		decompte,
		dcptcie
Where	dcptcie.type = 1
and		dcptcie.numdcptcie = sinistre.numdcptcie
and		sinistre.numdec = decompte.numdec
and		decompte.numdec = compte_client.numfact
and		compte_client.codope = 1
and		contrat.numgar = sinistre.numgar
group by
		dcptcie.numdcptcie,
		contrat.refcie,
		contrat.numgar,
		contrat.numcli,
		dcptcie.type
/*
Union all
select	dcptcie.numdcptcie,
	grnts.refcie,
	grnts.numgar,
	sum(f_dcptcie_remb(decompte_prev.numdec)) montant,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	dcptcie.type
from	dcptcie,
	decompte_prev,
	grnts,
	adhe_cntrt,
	indvs indvs_cli
where	dcptcie.numdcptcie = decompte_prev.numdcptcie
and	dcptcie.type = 2
and	indvs_cli.numindiv=grnts.numcli
and	grnts.numgar = adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	not exists (select 1 from affectation,decaismt
			where decaismt.numdecaismt=affectation.numdecaismt
			and affectation.numaffec=decompte_prev.numdec
			and decaismt.codope=9
		)
Group By
	dcptcie.numdcptcie,
	grnts.refcie,
	grnts.numgar,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom,
	dcptcie.type
union all
select	dcptcie.numdcptcie,
	grnts.refcie,
	grnts.numgar,
	-sum(f_dcptcie_remb(decompte_prev.numdec)) montant,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom nomcli,
	dcptcie.type
from	indvs indvs_cli,
	adhe_cntrt,
	contrat grnts,
	decompte_prev,
	affectation,
	pnul,
	decaismt,
	dcptcie
Where	indvs_cli.numindiv=grnts.numcli
and	grnts.numgar = adhe_cntrt.numgar
and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
and	affectation.numaffec = decompte_prev.numdec
and	decaismt.codope = 9
and	decaismt.numdecaismt = pnul.numdecaismt
and	decaismt.numdecaismt = affectation.numdecaismt
and	dcptcie.type = 2
and	dcptcie.numdcptcie = decompte_prev.numdcptcie
group by
	dcptcie.numdcptcie,
	grnts.refcie,
	grnts.numgar,
	grnts.numcli,
	indvs_cli.nom||' '||indvs_cli.prenom ,
	dcptcie.type
*/
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTCIE_TEMP FOR ARTHUS.V_DCPTCIE_TEMP
