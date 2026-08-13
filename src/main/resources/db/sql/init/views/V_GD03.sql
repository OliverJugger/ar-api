CREATE FORCE VIEW ARTHUS.V_GD03 AS
SELECT DISTINCT dcpt.numgar numgar, sntr.idadhesion, dcpt.numindiv,
                   dcpt.montant, dcpt.monnaie, dcpt.montant_d, dcpt.monnaie_d,
                   dcpt.numdec, dcpt.datpay dataffec,
                   TO_CHAR (dcpt.datpay, 'DD/MM/YY') edataffec,
                   decaismt.datpay,
                   TO_CHAR (decaismt.datpay, 'DD/MM/YY') edatpay,
                   affectation.codope, decaismt.refpmt, decaismt.numdecaismt,
                   1 TYPE, decaismt.numedit
              FROM dcpt, affectation, decaismt, sntr
             WHERE dcpt.numdec = affectation.numaffec
               AND affectation.numdecaismt = decaismt.numdecaismt
               AND affectation.codope = 1
               AND sntr.numdec = dcpt.numdec
   UNION
   SELECT DISTINCT dcpt.numgar numgar, sntr.idadhesion, dcpt.numindiv,
                   dcpt.montant, dcpt.monnaie, dcpt.montant_d, dcpt.monnaie_d,
                   dcpt.numdec, dcpt.datpay dataffec,
                   TO_CHAR (dcpt.datpay, 'DD/MM/YY') edataffec,
                   encaismt.datpay,
                   TO_CHAR (encaismt.datpay, 'DD/MM/YY') edatpay,
                   affectation.codope, encaismt.refpmt, encaismt.numencaismt,
                   1 TYPE, -1
              FROM dcpt, affectation, compte_client, encaismt, sntr
             WHERE sntr.numdec = dcpt.numdec
               AND compte_client.codope = 1
               AND compte_client.numfact = affectation.numaffec
               AND affectation.numaffec = dcpt.numdec
               AND affectation.codope = 1
               AND encaismt.codope = 1
               AND encaismt.numencaismt = compte_client.numencaismt
   UNION
   SELECT DISTINCT adhe_cntrt.numgar numgar, decompte_prev.idadhesion,
                   f_numindiv_sin (decompte_prev.numdec) numindiv,
                   decompte_prev.montant, decompte_prev.monnaie,
                   decompte_prev.montant_d, decompte_prev.monnaie_d,
                   decompte_prev.numdec, decompte_prev.datpay dataffec,
                   TO_CHAR (decompte_prev.datpay, 'DD/MM/YY') edataffec,
                   decaismt.datpay,
                   TO_CHAR (decaismt.datpay, 'DD/MM/YY') edatpay,
                   affectation.codope, decaismt.refpmt, decaismt.numdecaismt,
                   2 TYPE, decaismt.numedit
              FROM adhe_cntrt, decompte_prev, affectation, decaismt
             WHERE adhe_cntrt.idadhesion = decompte_prev.idadhesion
               AND decompte_prev.numdec = affectation.numaffec
               AND affectation.numdecaismt = decaismt.numdecaismt
               AND affectation.codope = 2
   UNION
   SELECT DISTINCT adhe_cntrt.numgar numgar, decompte_prev.idadhesion,
                   f_numindiv_sin (decompte_prev.numdec) numindiv,
                   decompte_prev.montant, decompte_prev.monnaie,
                   decompte_prev.montant_d, decompte_prev.monnaie_d,
                   decompte_prev.numdec, decompte_prev.datpay dataffec,
                   TO_CHAR (decompte_prev.datpay, 'DD/MM/YY') edataffec,
                   encaismt.datpay,
                   TO_CHAR (encaismt.datpay, 'DD/MM/YY') edatpay,
                   affectation.codope, encaismt.refpmt, encaismt.numencaismt,
                   2 TYPE, -1
              FROM adhe_cntrt,
                   decompte_prev,
                   affectation,
                   compte_client,
                   encaismt
             WHERE adhe_cntrt.idadhesion = decompte_prev.idadhesion
               AND decompte_prev.numdec = affectation.numaffec
               AND affectation.codope = 2
               AND compte_client.codope = 2
               AND compte_client.numfact = affectation.numaffec
               AND encaismt.codope = 2
               AND encaismt.numencaismt = compte_client.numencaismt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GD03 FOR ARTHUS.V_GD03
