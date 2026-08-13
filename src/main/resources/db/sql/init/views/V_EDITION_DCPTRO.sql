CREATE FORCE VIEW ARTHUS.V_EDITION_DCPTRO AS
SELECT	sinistre.numassu_rc,
                  trunc(sinistre.datedit_rc) datedit_rc,
		      max(decaismt.datpay) datpay,
		      count(distinct sinistre.numdec) nbre_dcpt
        FROM    decaismt,affectation,dcpt,sinistre
        WHERE	decaismt.numdecaismt = affectation.numdecaismt
        AND	decaismt.refpmt Is not null
        AND     sinistre.numassu_rc Is Not null
        AND	decaismt.datpay Is not null
        AND     sinistre.numdec<>0
        AND	dcpt.numdec = affectation.numaffec
        AND     sinistre.numdec=dcpt.numdec
        AND     f_frmls_compl(dcpt.numgar,sinistre.numfor)=0
        Group By sinistre.numassu_rc,trunc(sinistre.datedit_rc)
        HAving  count(distinct sinistre.numdec)<>0
        Order By sinistre.numassu_rc
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EDITION_DCPTRO FOR ARTHUS.V_EDITION_DCPTRO
