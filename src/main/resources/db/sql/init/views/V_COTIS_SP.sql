CREATE FORCE VIEW ARTHUS.V_COTIS_SP AS
SELECT contrat.refcie, contrat.numgar, qttc_global.idadhesion,
          contrat.numinterm numsoc, contrat.numorg, contrat.numcli,
          contrat.numprod, qttc_gar.debut, qttc_gar.fin,
            NVL (qttc_gar.mt_net, 0)
          - f_totcomm (qttc_gar.numquit, qttc_gar.numfor, qttc_gar.numindiv)
                                                                      montant,
          NVL (qttc_gar.mt_net, 0) mnet_comm, qttc_gar.numfor,
          f_totcomm (qttc_gar.numquit,
                     qttc_gar.numfor,
                     qttc_gar.numindiv
                    ) mt_comm,
          qttc_gar.numquit, qttc_global.debut debut_per,
          qttc_global.fin fin_per
     FROM contrat, qttc_gar, qttc_global
    WHERE contrat.numgar = qttc_global.numgar
      AND qttc_global.comptant != 'R'
      AND qttc_global.type_qttc != 3
      AND qttc_global.numquit = qttc_gar.numquit
      AND qttc_global.numquit NOT IN (SELECT NUMFACT FROM FACTURE_ANNUL)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COTIS_SP FOR ARTHUS.V_COTIS_SP
