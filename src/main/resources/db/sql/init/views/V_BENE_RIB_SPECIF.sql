CREATE FORCE VIEW ARTHUS.V_BENE_RIB_SPECIF AS
SELECT numindiv, codope, modpmt, numgar, codbque, guichet, compte, clerib,
          intitule
        , rib.bban
        , rib.clef_iban
        , rib.bic
        , rib.codpays
     FROM rib
    WHERE rib.numgar != 0
   UNION
   SELECT rib_ope.numindiv, rib_ope.codope, rib_ope.modpmt, v_numgar.numgar,
          rib_ope.codbque, rib_ope.guichet, rib_ope.compte, rib_ope.clerib,
          rib_ope.intitule
        , rib_ope.bban
        , rib_ope.clef_iban
        , rib_ope.bic
        , rib_ope.codpays
     FROM rib rib_ope, v_numgar
    WHERE rib_ope.codope != 0
      AND rib_ope.modpmt != 0
      AND rib_ope.numgar = 0
      AND NOT EXISTS (
             SELECT 1
               FROM rib rib_contrat
              WHERE rib_contrat.numindiv = rib_ope.numindiv
                AND rib_contrat.codope = rib_ope.codope
                AND rib_contrat.modpmt = rib_ope.modpmt
                AND rib_contrat.numgar = v_numgar.numgar
                AND rib_contrat.numgar != 0)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_BENE_RIB_SPECIF FOR ARTHUS.V_BENE_RIB_SPECIF
