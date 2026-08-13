CREATE FORCE VIEW ARTHUS.V_ADHESION_N1 AS
select 	sum(sntr.mtreel) col51,
	11 long51,
	sntr.idadhesion,
	sntr.numfor
from	dcpt,
	affectation,
	decaismt,
	sntr
where	sntr.numdec=dcpt.numdec
and	dcpt.numdec=affectation.numaffec
and	affectation.numdecaismt=decaismt.numdecaismt
and	affectation.codope = 1
and	decaismt.refpmt is not null
and	to_char(decaismt.datpay,'yy')=to_char(sysdate,'yy')-1
and	decaismt.codope=1
group by sntr.idadhesion,sntr.numfor
union  all
select -sum(sntr.mtreel) col51,
	11 long51,
	sntr.idadhesion,
	sntr.numfor
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
and	decaismt.refpmt is not null
and	to_char(pnul.datannul,'yy')=to_char(sysdate,'yy')-1
and	decaismt.codope=9
group by sntr.idadhesion,sntr.numfor
union all
select sum(sntr.mtreel) col51,
	11 long51,
	sntr.idadhesion,
	sntr.numfor
from	decompte_annul dcpt,
	affectation_annul affectation,
	decaismt,
	sinistre_annul sntr
where	sntr.numdec=dcpt.numdec
and	dcpt.numdec=affectation.numaffec
and	affectation.numdecaismt=decaismt.numdecaismt
and	affectation.codope = 1
and	decaismt.refpmt is not null
and	to_char(decaismt.datpay,'yy')=to_char(sysdate,'yy')-1
and	decaismt.codope=9
group by sntr.idadhesion,sntr.numfor
union all
select sum(sntr.mtreel) col51,
	11 long51,
	sntr.idadhesion,
	sntr.numfor
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
group by sntr.idadhesion,sntr.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ADHESION_N1 FOR ARTHUS.V_ADHESION_N1
