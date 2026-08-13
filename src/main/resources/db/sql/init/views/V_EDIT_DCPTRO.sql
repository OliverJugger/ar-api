CREATE FORCE VIEW ARTHUS.V_EDIT_DCPTRO AS
SELECT	sinistre.numassu_rc,
		max(decaismt.datpay) datpay,
		count(distinct sinistre.numdec) nbre_dcpt
        FROM    decaismt,affectation,dcpt,sinistre
        WHERE	decaismt.numdecaismt = affectation.numdecaismt
        AND	decaismt.refpmt Is not null
        AND     sinistre.numassu_rc Is Not null
        AND	decaismt.datpay Is not null
        AND     sinistre.numdec<>0
        AND     sinistre.numdec_rc Is Not Null
        AND     sinistre.datedit_rc Is Not Null
        AND	dcpt.numdec = affectation.numaffec
        AND     sinistre.numdec=dcpt.numdec
        AND     f_frmls_compl(dcpt.numgar,sinistre.numfor)=0
        Group By sinistre.numassu_rc
        HAving  count(distinct sinistre.numdec)<>0
        Order By sinistre.numassu_rc
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EDIT_DCPTRO FOR ARTHUS.V_EDIT_DCPTRO
