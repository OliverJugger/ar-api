CREATE FORCE VIEW ARTHUS.V_DCPTCIE_TOT AS
SELECT   v_dcptcie.numdcptcie, v_dcptcie.refcie, v_dcptcie.numgar,
            SUM (v_dcptcie.montant) montant, v_dcptcie.numcli,
            v_dcptcie.nomcli, v_dcptcie.TYPE
       FROM v_dcptcie
   GROUP BY v_dcptcie.numdcptcie,
            v_dcptcie.refcie,
            v_dcptcie.numgar,
            v_dcptcie.numcli,
            v_dcptcie.nomcli,
            v_dcptcie.TYPE
	UNION ALL
	SELECT   DCPTCIE_PREV_DETAIL.numdcptcie, DCPTCIE_PREV_DETAIL.refcie, DCPTCIE_PREV_DETAIL.numgar,
            SUM (DCPTCIE_PREV_DETAIL.montant_remb) montant, DCPTCIE_PREV_DETAIL.numcli,
            DCPTCIE_PREV_DETAIL.nomcli, DCPTCIE_PREV_DETAIL.TYPE
       FROM DCPTCIE_PREV_DETAIL
	  WHERE DCPTCIE_PREV_DETAIL.etat = 1
   GROUP BY DCPTCIE_PREV_DETAIL.numdcptcie,
            DCPTCIE_PREV_DETAIL.refcie,
            DCPTCIE_PREV_DETAIL.numgar,
            DCPTCIE_PREV_DETAIL.numcli,
            DCPTCIE_PREV_DETAIL.nomcli,
            DCPTCIE_PREV_DETAIL.TYPE
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTCIE_TOT FOR ARTHUS.V_DCPTCIE_TOT
