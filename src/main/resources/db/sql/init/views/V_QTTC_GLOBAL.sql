CREATE FORCE VIEW ARTHUS.V_QTTC_GLOBAL AS
SELECT qttc_global.numgar, qttc_global.numquit, qttc_global.numquerable,
          qttc_global.numindiv, qttc_global.nat_calc, qttc_global.type_qttc,
		  qttc_global.debut, qttc_global.fin, qttc_global.datemis,
		  qttc_global.idadhesion,
          DECODE (f_datemis (4, qttc_global.numquit, 1, 0),
                  'Non émis', DECODE (f_datemis (4, qttc_global.numquit, 1,
                                                 99),
                                      'Non annulé', f_datemis
                                                         (4,
                                                          qttc_global.numquit,
                                                          1,
                                                          0
                                                         ),
                                      f_datemis (4, qttc_global.numquit, 1,
                                                 99)
                                     ),
                  f_datemis (4, qttc_global.numquit, 1, 0)
                 ) edatemis,
          TO_CHAR (qttc_global.debut, 'dd/mm/yy') edebut,
          TO_CHAR (qttc_global.fin, 'dd/mm/yy') efin, facture.mregl,
          libelle.libelle || ' au ' || d2e (facture.echeance) libmregl,
          facture.echeance, TO_CHAR (facture.echeance, 'dd/mm/yy') eecheance,
          grnts.refcie, grnts.numcli,
          querable.nom || ' ' || querable.prenom nomquerable,
          sousc.nom || ' ' || sousc.prenom nomsousc,
          DECODE (qttc_global.numindiv,
                  0, DECODE (qttc_global.numgar,
                             grnts.numgar_ref, 'Le contrat ' || grnts.refcie,
                             'L''adhésion collective ' || grnts.refcie
                            ),
                     'L''adhérent '
                  || TO_CHAR (qttc_global.numindiv)
                  || ' '
                  || assu.nom
                  || ' '
                  || assu.prenom
                 ) nomassu,
          facture.montant montant, qttc_global.mt_net,
          qttc_global.mt_affec mt_regl,
          DECODE (qttc_global.comptant,
                  'R', 'Régularisée',
                  DECODE (f_datemis (4, qttc_global.numquit, 1, 99),
                          'Non annulé', NVL (TO_CHAR (qttc_global.mt_affec,
                                                      '9999999.99'
                                                     ),
                                             'Non réglé'
                                            ),
                          'Annulé'
                         )
                 ) mt_affec,
          facture.montant_d montant_d, qttc_global.mt_net_d,
          qttc_global.mt_affec_d mt_regl_d,
          DECODE (qttc_global.comptant,
                  'R', 'Régularisée',
                  DECODE (f_datemis (4, qttc_global.numquit, 1, 99),
                          'Non annulé', NVL (TO_CHAR (qttc_global.mt_affec_d,
                                                      '9999999.99'
                                                     ),
                                             'Non réglé'
                                            ),
                          'Annulé'
                         )
                 ) mt_affec_d,
          qttc_global.monnaie, qttc_global.monnaie_d
     FROM libelle,
          indvs querable,
          indvs assu,
          indvs sousc,
          grnts,
          facture,
          qttc_global
    WHERE libelle.mnemo = 'MREGL'
      AND libelle.code = facture.mregl
      AND facture.codope = 4
      AND facture.numfact = qttc_global.numquit
      AND querable.numindiv = qttc_global.numquerable
      AND qttc_global.type_qttc != 3
      AND sousc.numindiv = grnts.numcli
      AND assu.numindiv(+) = qttc_global.numindiv
      AND grnts.numgar = qttc_global.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_GLOBAL FOR ARTHUS.V_QTTC_GLOBAL
