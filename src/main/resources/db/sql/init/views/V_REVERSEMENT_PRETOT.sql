CREATE FORCE VIEW ARTHUS.V_REVERSEMENT_PRETOT AS
SELECT   qttc_affec.idrevers, grnts.numinterm numsoc,
            v_assur_revers.numass numorg, grnts.refcie_chapeau, grnts.numgar,
            qttc_affec.numquit, qttc_global.debut, qttc_global.fin,
            qttc_affec.numfor, qttc_affec.idaffec,
            compte_client.datope dataffec, grnts.type_terme,
              SUM (qttc_affec.montant)
            - ARTHUS.pk_cotis.comm_prelev (qttc_affec.numquit,
                                    qttc_affec.idrevers,
                                    qttc_affec.idaffec,
                                    qttc_affec.numfor,
                                    1,
                                    2
                                   ) montant,
            qttc_affec.monnaie,
              SUM (qttc_affec.montant_d)
            - ARTHUS.pk_cotis.comm_prelev_d (qttc_affec.numquit,
                                      qttc_affec.idrevers,
                                      qttc_affec.idaffec,
                                      qttc_affec.numfor,
                                      1,
                                      2
                                     ) montant_d,
            qttc_affec.monnaie_d
       FROM contrat grnts,
            qttc_global,
            qttc_affec,
            compte_client,
            v_assur_revers
      WHERE qttc_affec.numfor = v_assur_revers.numfor
        AND qttc_affec.idrevers != 0
        AND qttc_affec.numfor != 0
        AND qttc_affec.idaffec = compte_client.idaffec
        AND compte_client.codope + 0 = 4
        AND qttc_global.numquit = qttc_affec.numquit
        AND grnts.numgar = qttc_global.numgar
   GROUP BY grnts.numinterm,
            v_assur_revers.numass,
            grnts.refcie_chapeau,
            grnts.numgar,
            qttc_affec.numquit,
            qttc_affec.idaffec,
            qttc_affec.numfor,
            qttc_affec.idrevers,
            grnts.type_terme,
            qttc_global.debut,
            qttc_global.fin,
            compte_client.datope,
            qttc_affec.monnaie,
            qttc_affec.monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REVERSEMENT_PRETOT FOR ARTHUS.V_REVERSEMENT_PRETOT
