CREATE FORCE VIEW ARTHUS.V_ECHEANCIER AS
SELECT qttc_global.numgar, qttc_global.numquit, qttc_global.numquerable,
          qttc_global.numindiv, qttc_global.type_qttc, qttc_global.debut,
          qttc_global.fin, qttc_global.idadhesion, facture.echeance,
          facture.mregl,
             mregl.libelle
          || ' au '
          || TO_CHAR (facture.echeance, 'dd/mm/yyyy') libmregl,
          TO_CHAR (qttc_global.datemis, 'dd/mm/yyyy') edatemis,
          TO_CHAR (qttc_global.debut, 'dd/mm/yyyy') edebut,
          TO_CHAR (qttc_global.fin, 'dd/mm/yyyy') efin,
          TO_CHAR (facture.echeance, 'dd/mm/yyyy') eecheance,
          querable.nom || ' ' || querable.prenom nomquerable,
          qttc_global.mt_ttc montant, qttc_global.mt_net,
          qttc_global.mt_affec mt_regl,
          DECODE (qttc_global.comptant,
                  'R', 'Régularisée',
                  NVL (TO_CHAR (qttc_global.mt_affec, '9999990.90'),
                       'Non réglé'
                      )
                 ) mt_affec,
          qttc_global.mt_ttc_d montant_d, qttc_global.mt_net_d,
          qttc_global.mt_affec_d mt_regl_d,
          DECODE (qttc_global.comptant,
                  'R', 'Régularisée',
                  NVL (TO_CHAR (qttc_global.mt_affec_d, '9999990.90'),
                       'Non réglé'
                      )
                 ) mt_affec_d,
          qttc_global.monnaie, qttc_global.monnaie_d
     FROM libelle mregl, indvs querable, facture, qttc_global
    WHERE qttc_global.comptant != 'R'
      AND querable.numindiv = qttc_global.numquerable
      AND mregl.mnemo = 'MREGL'
      AND mregl.code = facture.mregl
      AND facture.codope = 4
      AND NOT EXISTS(SELECT 1 FROM facture_annul fa WHERE fa.numfact = facture.numfact)
      AND facture.numfact = qttc_global.numquit
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ECHEANCIER FOR ARTHUS.V_ECHEANCIER
