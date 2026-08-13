CREATE FORCE VIEW ARTHUS.V_TRAV_REVERS_TAXE AS
SELECT qttc_affec_tfc.idrevers, qttc_affec_tfc.idaffec,
          contrat.numinterm numsoc, contrat.numorg, qttc_affec_tfc.numbene numindiv,
          contrat.refcie_chapeau regroupement, contrat.numgar,
          compte_client.datope dataffec, qttc_global.debut echeance,
          qttc_affec_tfc.type_tfc, qttc_affec_tfc.prelev_revers,
          qttc_affec_tfc.montant, qttc_affec_tfc.montant_d,
          qttc_affec_tfc.monnaie, qttc_affec_tfc.monnaie_d
     FROM contrat, qttc_global, qttc_affec_tfc, compte_client
    WHERE contrat.numgar = qttc_global.numgar
      AND qttc_global.numquit = qttc_affec_tfc.numquit
      AND compte_client.idaffec = qttc_affec_tfc.idaffec
      AND compte_client.codope + 0 = 4
      AND qttc_affec_tfc.tfc = 1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRAV_REVERS_TAXE FOR ARTHUS.V_TRAV_REVERS_TAXE
