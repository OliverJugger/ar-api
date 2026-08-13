CREATE FORCE VIEW ARTHUS.V_RETRO_EDITION_ADHESION AS
SELECT   retrocession.idrevers, qttc_global.numgar,
            qttc_affec_tfc.type_tfc type_retro,
            SUM (qttc_affec_tfc.montant) montant, qttc_global.mt_ttc,
            TO_CHAR (qttc_global.debut, 'yyyy') annee, qttc_global.debut,
            0 detail, contrat.refcie_chapeau regroup, contrat.refcie,
            qttc_global.numquerable numcli, retrocession.numindiv,
            retrocession.datrevers, qttc_global.idadhesion,
            adhe_cntrt.ref_ext
       FROM qttc_affec_tfc, contrat, qttc_global, retrocession, adhe_cntrt
      WHERE qttc_affec_tfc.tfc = 5
        AND contrat.numgar = qttc_global.numgar
        AND qttc_global.numquit = qttc_affec_tfc.numquit
        AND retrocession.idrevers = qttc_affec_tfc.idrevers
        AND qttc_global.idadhesion = adhe_cntrt.idadhesion(+)
   GROUP BY retrocession.idrevers,
            qttc_global.numgar,
            qttc_affec_tfc.type_tfc,
            qttc_global.debut,
            contrat.refcie_chapeau,
            contrat.refcie,
            qttc_global.numquerable,
            qttc_global.mt_ttc,
            retrocession.numindiv,
            retrocession.datrevers,
            qttc_global.idadhesion,
            adhe_cntrt.ref_ext
   UNION
   SELECT   retrocession.idrevers, qttc_global.numgar, -1 type_retro,
            SUM (qttc_affec_tfc.montant) montant, qttc_global.mt_ttc,
            TO_CHAR (qttc_global.debut, 'yyyy') annee, qttc_global.debut,
            1 detail, contrat.refcie_chapeau regroup, contrat.refcie,
            qttc_global.numquerable, retrocession.numindiv,
            retrocession.datrevers, qttc_global.idadhesion,
            adhe_cntrt.ref_ext
       FROM qttc_affec_tfc, contrat, qttc_global, retrocession, adhe_cntrt
      WHERE qttc_affec_tfc.tfc = 5
        AND contrat.numgar = qttc_global.numgar
        AND qttc_global.numquit = qttc_affec_tfc.numquit
        AND retrocession.idrevers = qttc_affec_tfc.idrevers
        AND qttc_global.idadhesion = adhe_cntrt.idadhesion(+)
   GROUP BY retrocession.idrevers,
            qttc_global.numgar,
            qttc_global.debut,
            contrat.refcie_chapeau,
            contrat.refcie,
            qttc_global.numquerable,
            qttc_global.mt_ttc,
            retrocession.numindiv,
            retrocession.datrevers,
            qttc_global.idadhesion,
            adhe_cntrt.ref_ext
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RETRO_EDITION_ADHESION FOR ARTHUS.V_RETRO_EDITION_ADHESION
