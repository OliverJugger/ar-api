CREATE FORCE VIEW ARTHUS.V_BENE_RIB_CODE AS
SELECT a.numindiv, a.codope, a.modpmt, contrat.numgar, a.codbque,
          a.guichet, a.compte, a.clerib, a.intitule
        , a.bban
        , a.clef_iban
        , a.bic
        , a.codpays
     FROM rib a, contrat
    WHERE a.numgar = 0
      AND a.codope != 0
      AND a.modpmt != 0
      AND NOT EXISTS (
             SELECT 1
               FROM rib b
              WHERE b.numindiv = a.numindiv
                AND b.codope = a.codope
                AND b.modpmt = a.modpmt
                AND b.numgar = contrat.numgar)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_BENE_RIB_CODE FOR ARTHUS.V_BENE_RIB_CODE
