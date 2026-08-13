CREATE FORCE VIEW ARTHUS.V_ANNUL_ENCAIS AS
SELECT numsoc, numremise, lib_remise, numcpte, codope, numprelev, numcli,
          nom_querable, lib_prelev, numaffec, codapli, montant, montant_d,
          rib, lib_compte, lib_ope, motif_annul, domicil, rib_compte,
          rais_soc, numencaismt, numgar, idadhesion, debut, fin, numadhe,
          monnaie, monnaie_d
        , v_remise_prelev_detail.rib_SEPA
        , v_remise_prelev_detail.rib_compte_SEPA
     FROM v_remise_prelev_detail
   UNION
   SELECT compte.numsoc, TO_NUMBER (''), '', encaismt.numcpte, facture.codope,
          encaismt.refpmt numprelev, facture.numcli,
          indvs.nom || ' ' || indvs.prenom nom_querable,
             'Appel N° '
          || facture.numfact
          || ' Echéance '
          || TO_CHAR (qttc_global.debut, 'dd/mm/yyyy')
          || ' Contrat '
          || qttc_global.numgar lib_prelev,
          facture.numfact numaffec, 'qg03' codapli, facture.montant,
          facture.montant_d, '' rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte, '',
          TO_NUMBER ('') motif_annul, compte.domicil,
             compte.guichet
          || ' '
          || compte.compte
          || ' '
          || compte.clerib rib_compte,
          compte.rais_soc, v_compte_client.numencaismt, qttc_global.numgar,
          qttc_global.idadhesion, qttc_global.debut, qttc_global.fin,
          adhe_cntrt.numadhe, encaismt.monnaie, encaismt.monnaie_d
        , ''                                                                                                    rib_SEPA
        , ARTHUS.pk_sepa.f_afficher_compte(compte.bic, compte.clef_iban||compte.bban, NULL, 'BIC+IBAN+INTITULE LONG')  rib_compte_SEPA
     FROM encaismt,
          v_compte_client,
          compte,
          adhe_cntrt,
          qttc_global,
          indvs,
          facture
    WHERE adhe_cntrt.idadhesion = qttc_global.idadhesion
      AND facture.codope = v_compte_client.codope
      AND facture.numfact = v_compte_client.numfact
      AND v_compte_client.numencaismt = encaismt.numencaismt
      AND qttc_global.type_qttc = 2
      AND compte.numcpte = encaismt.numcpte
      AND qttc_global.numquit = facture.numfact
      AND indvs.numindiv = facture.numcli
      AND NOT EXISTS (
               SELECT 1
                 FROM v_remise_prelev_detail
                WHERE v_remise_prelev_detail.numencaismt =
                                                          encaismt.numencaismt)
   UNION
   SELECT compte.numsoc, TO_NUMBER (''), '', encaismt.numcpte, facture.codope,
          encaismt.refpmt numprelev, facture.numcli,
          indvs.nom || ' ' || indvs.prenom nom_querable,
             'Appel N° '
          || facture.numfact
          || ' Echéance '
          || TO_CHAR (qttc_global.debut, 'dd/mm/yyyy')
          || ' Contrat '
          || qttc_global.numgar lib_prelev,
          facture.numfact numaffec, 'qg03' codapli, facture.montant,
          facture.montant_d, '' rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte, '',
          TO_NUMBER ('') motif_annul, compte.domicil,
             compte.guichet
          || ' '
          || compte.compte
          || ' '
          || compte.clerib rib_compte,
          compte.rais_soc, v_compte_client.numencaismt, qttc_global.numgar,
          qttc_global.idadhesion, qttc_global.debut, qttc_global.fin,
          qttc_global.numquerable, encaismt.monnaie, encaismt.monnaie_d
        , ''                                                                                                    rib_SEPA
        , ARTHUS.pk_sepa.f_afficher_compte(compte.bic, compte.clef_iban||compte.bban, NULL, 'BIC+IBAN+INTITULE LONG')  rib_compte_SEPA
     FROM encaismt, v_compte_client, compte, qttc_global, indvs, facture
    WHERE compte.numcpte = encaismt.numcpte
      AND facture.codope = v_compte_client.codope
      AND facture.numfact = v_compte_client.numfact
      AND v_compte_client.numencaismt = encaismt.numencaismt
      AND qttc_global.numquit = facture.numfact
      AND qttc_global.type_qttc = 1
      AND indvs.numindiv = facture.numcli
      AND NOT EXISTS (
               SELECT 1
                 FROM v_remise_prelev_detail
                WHERE v_remise_prelev_detail.numencaismt =
                                                          encaismt.numencaismt)
   UNION
   SELECT compte.numsoc, TO_NUMBER (''), '', encaismt.numcpte,
          v_compte_client.codope, encaismt.refpmt numprelev,
          v_compte_client.numcli,
          indvs.nom || ' ' || indvs.prenom nom_querable,
             'En attente sur le compte client N° '
          || v_compte_client.numcli lib_prelev,
          v_compte_client.numfact, 'en12' codapli, v_compte_client.montant,
          v_compte_client.montant_d, '' rib, '', '',
          TO_NUMBER ('') motif_annul, '', '', '', encaismt.numencaismt,
          TO_NUMBER (''), TO_NUMBER (''), TO_DATE (''), TO_DATE (''),
          TO_NUMBER (''), encaismt.monnaie, encaismt.monnaie_d
        , ''                                                                                                    rib_SEPA
        , ARTHUS.pk_sepa.f_afficher_compte(compte.bic, compte.clef_iban||compte.bban, NULL, 'BIC+IBAN+INTITULE LONG')  rib_compte_SEPA
     FROM v_compte_client, compte, indvs, encaismt
    WHERE indvs.numindiv = v_compte_client.numcli
      AND compte.numcpte = encaismt.numcpte
      AND v_compte_client.numencaismt = encaismt.numencaismt
      AND v_compte_client.codope = 8
   UNION
   SELECT compte.numsoc, TO_NUMBER (''), '', encaismt.numcpte,
          v_compte_client.codope, encaismt.refpmt numprelev,
          v_compte_client.numcli,
          indvs.nom || ' ' || indvs.prenom nom_querable,
             'En attente sur le compte fournisseur N° '
          || v_compte_client.numcli lib_prelev,
          v_compte_client.numfact, 'en12' codapli, v_compte_client.montant,
          v_compte_client.montant_d, '' rib, '', '',
          TO_NUMBER ('') motif_annul, '', '', '', encaismt.numencaismt,
          TO_NUMBER (''), TO_NUMBER (''), TO_DATE (''), TO_DATE (''),
          TO_NUMBER (''), encaismt.monnaie, encaismt.monnaie_d
        , ''                                                                                                   rib_SEPA
        , ARTHUS.pk_sepa.f_afficher_compte(compte.bic, compte.clef_iban||compte.bban, NULL, 'BIC+IBAN+INTITULE LONG') rib_compte_SEPA
     FROM v_compte_client, compte, indvs, encaismt
    WHERE indvs.numindiv = v_compte_client.numcli
      AND compte.numcpte = encaismt.numcpte
      AND v_compte_client.numencaismt = encaismt.numencaismt
      AND v_compte_client.codope = 10
      AND NOT EXISTS (SELECT 1
                        FROM compensation
                       WHERE compensation.idmvt = v_compte_client.idaffec)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ANNUL_ENCAIS FOR ARTHUS.V_ANNUL_ENCAIS
