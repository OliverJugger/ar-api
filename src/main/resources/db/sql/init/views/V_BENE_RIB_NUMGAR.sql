CREATE FORCE VIEW ARTHUS.V_BENE_RIB_NUMGAR AS
SELECT numindiv, codope, modpmt, numgar, codbque, guichet, compte, clerib,
          intitule
        , rib.bban
        , rib.clef_iban
        , rib.bic
        ,rib.codpays
     FROM rib
    WHERE numgar != 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_BENE_RIB_NUMGAR FOR ARTHUS.V_BENE_RIB_NUMGAR
