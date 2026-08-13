CREATE FORCE VIEW ARTHUS.V_EDITION_DCPT AS
SELECT	decaismt.numedit,
        decaismt.codope,
        decaismt.numcpte,
		decaismt.modpmt,
		count(distinct dcpt.numdec) nbre_dcpt,
		decaismt.datedit,
            f_lib_edition(decaismt.numedit) editlib
FROM	decaismt,affectation,dcpt,prmt,
        sntr
WHERE	decaismt.numdecaismt	= affectation.numdecaismt
AND	decaismt.numutil	>= 0
AND	decaismt.flagpay	= decode(decaismt.modpmt,
						prmt.mdchq, -1,
						1)
AND	dcpt.numdec 		= affectation.numaffec
AND sntr.numdec = dcpt.numdec
AND sntr.edtdcpt=1
AND decaismt.codope=1
Group By decaismt.numcpte,decaismt.modpmt,decaismt.numedit,
        decaismt.codope,decaismt.datedit
HAving  count(distinct dcpt.numdec)<>0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EDITION_DCPT FOR ARTHUS.V_EDITION_DCPT
