CREATE FORCE VIEW ARTHUS.V_ENCAISMT AS
SELECT encaismt.codope, codope.libelle libope, encaismt.numencaismt,
          encaismt.numcli, indvs.nom || ' ' || indvs.prenom nomcli,
          encaismt.numcpte, compte.libcompte, encaismt.modpmt,
          modpmt.libelle libmodpmt, encaismt.refpmt, encaismt.monnaie,
          encaismt.monnaie_d, encaismt.datpay, encaismt.datcompta,
          encaismt.idcompta, encaismt.numutil, encaismt.creation,
          TO_CHAR (encaismt.datpay, 'dd/mm/yyyy') edatpay, encaismt.montant,
          encaismt.montant_d, encaismt.id_credit, encaismt.date_credit,
          remise_banque.ets_payeur, remise_banque.lieu_pmt,
          DECODE (NVL (annul_encais.motif, NULL),
                  NULL, NVL (remise_banque.nom_tireur,
                                prelevement.codbque
                             || ' '
                             || prelevement.guichet
                             || ' '
                             || prelevement.compte
                             || ' '
                             || prelevement.clerib
                             || ' '
                             || prelevement.intitule
                            ),
                     'Annulé le '
                  || TO_CHAR (annul_encais.date_annul, 'dd/mm/yyyy')
                  || ' : '
                  || prevann.libelle
                 ) nom_tireur,
          NVL (remise_banque.numremise, remise_prelev.numremise) numremise,
          TO_CHAR (NVL (remise_globale.daterem, remise_prelev.datrem),
                   'dd/mm/yyyy'
                  ) dateremise
        , DECODE( annul_encais.motif
                , NULL
                , NVL ( remise_banque.nom_tireur
                      , ARTHUS.pk_sepa.f_afficher_compte(prelevement.bic, prelevement.clef_iban||prelevement.bban, prelevement.intitule, 'BIC+IBAN+INTITULE LONG')
                      )
                , 'Annulé le '||TO_CHAR(annul_encais.date_annul, 'DD/MM/YYYY')|| ' : '||prevann.libelle
                ) nom_tireur_SEPA
     FROM libelle modpmt,
          libelle codope,
          libelle prevann,
          compte,
          indvs,
          remise_banque,
          remise_globale,
          remise_prelev,
          annul_encais,
          prelevement,
          encaismt
    WHERE modpmt.mnemo = 'MREGL'
      AND modpmt.code = encaismt.modpmt
      AND codope.mnemo = 'OPE'
      AND codope.code = encaismt.codope
      AND prevann.mnemo = 'PREVANN'
      AND prevann.code = NVL (annul_encais.motif, -2)
      AND compte.numcpte = encaismt.numcpte
      AND indvs.numindiv = encaismt.numcli
      AND annul_encais.numencaismt(+) = encaismt.numencaismt
      AND remise_banque.numencaismt(+) = encaismt.numencaismt
      AND remise_globale.numremise(+) = remise_banque.numremise
      AND prelevement.numencaismt(+) = encaismt.numencaismt
      AND remise_prelev.numremise(+) = prelevement.numremise
   UNION
   SELECT encaismt.codope, codope.libelle libope, encaismt.numencaismt,
          encaismt.numcli, indvs.nom || ' ' || indvs.prenom nomcli,
          encaismt.numcpte, compte.libcompte, encaismt.modpmt,
          modpmt.libelle libmodpmt, encaismt.refpmt, encaismt.monnaie,
          encaismt.monnaie_d, encaismt.datpay, encaismt.datcompta,
          encaismt.idcompta, encaismt.numutil, encaismt.creation,
          TO_CHAR (encaismt.datpay, 'dd/mm/yyyy') edatpay, encaismt.montant,
          encaismt.montant_d, encaismt.id_credit, encaismt.date_credit,
          remise_banque.ets_payeur, remise_banque.lieu_pmt,
          DECODE (NVL (annul_encais.motif, NULL),
                  NULL, NVL (remise_banque.nom_tireur,
                                prelevement.codbque
                             || ' '
                             || prelevement.guichet
                             || ' '
                             || prelevement.compte
                             || ' '
                             || prelevement.clerib
                             || ' '
                             || prelevement.intitule
                            ),
                     'Annulé le '
                  || TO_CHAR (annul_encais.date_annul, 'dd/mm/yyyy')
                  || ' : '
                  || prevann.libelle
                 ) nom_tireur,
          NVL (remise_banque.numremise, remise_prelev.numremise) numremise,
          TO_CHAR (NVL (remise_globale.daterem, remise_prelev.datrem),
                   'dd/mm/yyyy'
                  ) dateremise
        , DECODE( annul_encais.motif
                , NULL
                , NVL ( remise_banque.nom_tireur
                      , ARTHUS.pk_sepa.f_afficher_compte(prelevement.bic, prelevement.clef_iban||prelevement.bban, prelevement.intitule, 'BIC+IBAN+INTITULE LONG')
                      )
                , 'Annulé le '||TO_CHAR(annul_encais.date_annul, 'DD/MM/YYYY')|| ' : '||prevann.libelle
                ) nom_tireur_SEPA
     FROM libelle modpmt,
          libelle codope,
          libelle prevann,
          compte,
          indvs,
          remise_banque,
          remise_globale,
          remise_prelev,
          annul_encais,
          prelevement,
          encaismt
    WHERE modpmt.mnemo = 'MREGL'
      AND modpmt.code = encaismt.modpmt
      AND codope.mnemo = 'OPE'
      AND codope.code = encaismt.codope
      AND prevann.mnemo = 'ENC_ANN'
      AND prevann.code = NVL (annul_encais.motif, -2)
      AND compte.numcpte = encaismt.numcpte
      AND indvs.numindiv = encaismt.numcli
      AND annul_encais.numencaismt(+) = encaismt.numencaismt
      AND remise_banque.numencaismt(+) = encaismt.numencaismt
      AND remise_globale.numremise(+) = remise_banque.numremise
      AND prelevement.numencaismt(+) = encaismt.numencaismt
      AND remise_prelev.numremise(+) = prelevement.numremise
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ENCAISMT FOR ARTHUS.V_ENCAISMT
