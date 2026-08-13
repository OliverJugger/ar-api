CREATE FORCE VIEW ARTHUS.V_PREST_N1 AS
select 	sum(sntr.mtreel) col53,
	11 long53,
	sntr.idadhesion
from	dcpt,
	affectation,
	decaismt,
	sntr
where	sntr.numdec=dcpt.numdec
and	dcpt.numdec=affectation.numaffec
and	affectation.numdecaismt=decaismt.numdecaismt
and	affectation.codope = 1
and	decaismt.flagpay +0=1
and	to_char(decaismt.datpay,'yy')=to_char(sysdate,'yy')-1
and	decaismt.codope=1
group by sntr.idadhesion
union all
select -sum(sntr.mtreel) col53,
	11 long53,
	sntr.idadhesion
from	decompte_annul dcpt,
	affectation_annul affectation,
	decaismt,
	pnul,
	sinistre_annul sntr
where	sntr.numdec=dcpt.numdec
and	dcpt.numdec=affectation.numaffec
and	affectation.numdecaismt=decaismt.numdecaismt
and	decaismt.numdecaismt=pnul.numdecaismt
and	affectation.codope = 1
and	decaismt.flagpay +0=1
and	to_char(pnul.datannul,'yy')=to_char(sysdate,'yy')-1
and	decaismt.codope=9
group by sntr.idadhesion
union all
select sum(sntr.mtreel) col53,
	11 long53,
	sntr.idadhesion
from	decompte_annul dcpt,
	affectation_annul affectation,
	decaismt,
	sinistre_annul sntr
where	sntr.numdec=dcpt.numdec
and	dcpt.numdec=affectation.numaffec
and	affectation.numdecaismt=decaismt.numdecaismt
and	affectation.codope = 1
and	decaismt.flagpay +0=1
and	to_char(decaismt.datpay,'yy')=to_char(sysdate,'yy')-1
and	decaismt.codope=9
group by sntr.idadhesion
union all
select sum(sntr.mtreel) col53,
	11 long53,
	sntr.idadhesion
from	dcpt,
	affectation,
	compte_client,
	encaismt,
	sntr
where	sntr.numdec=dcpt.numdec
and	compte_client.codope = 1
and	compte_client.numfact = affectation.numaffec
and	affectation.numaffec = dcpt.numdec
and	affectation.codope = 1
and	encaismt.numencaismt = compte_client.numencaismt
and	encaismt.refpmt is not null
and	encaismt.codope = 1
and	to_char(encaismt.datpay,'yy')=to_char(sysdate,'yy')-1
group by sntr.idadhesion
union
select	sum(v_histo_calcul.montant) col51,
	11 long51,
	decompte_prev.idadhesion
from	v_histo_calcul,
	decompte_prev,
	affectation,
	decaismt
where	decompte_prev.numdec=affectation.numaffec
and	affectation.codope=2
and	affectation.numdecaismt=decaismt.numdecaismt
and	decaismt.flagpay=1
and	v_histo_calcul.numdec=decompte_prev.numdec
and	to_char(decaismt.datpay,'yy')=to_char(sysdate,'yy')-1
group by
	decompte_prev.idadhesion
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PREST_N1 FOR ARTHUS.V_PREST_N1
