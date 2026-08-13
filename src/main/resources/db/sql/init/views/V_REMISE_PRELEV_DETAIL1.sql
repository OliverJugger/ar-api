CREATE FORCE VIEW ARTHUS.V_REMISE_PRELEV_DETAIL1 AS
SELECT compte.numsoc, remise_prelev.numremise,
             remise_prelev.numremise
          || ' du '
          || TO_CHAR (remise_prelev.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_prelev.nombre
          || ' prélèvements' lib_remise,
          remise_prelev.numcpte, facture.codope, prelevement_detail.numprelev,
          facture.numcli, indvs.nom || ' ' || indvs.prenom nom_querable,
             'Appel N° '
          || facture.numfact
          || ' Echéance '
          || TO_CHAR (qttc_global.debut, 'dd/mm/yyyy')
          || ' Contrat '
          || qttc_global.numgar lib_prelev,
          facture.numfact numaffec, 'qg03' codapli,
          prelevement_detail.montant, prelevement_detail.monnaie,
          prelevement_detail.montant_d, prelevement_detail.monnaie_d,
             DECODE (rib.nature,
                     2,  rib.codbque
                      || ' '
                      || rib.guichet
                      || ' '
                      || rib.compte
                      || ' '
                      || rib.clerib
                      || ' ',
                     3,  rib.codbque_etrg
                      || ' '
                      || rib.guichet_etrg
                      || ' '
                      || rib.compte_etrg
                      || ' '
                      || rib.clerib_etrg
                      || ' '
                    )
          || prelevement.intitule rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte,
          ope.code || ' - ' || ope.libelle lib_ope, TO_NUMBER ('')
                                                                  motif_annul,
          compte.domicil,
             compte.guichet
          || ' '
          || compte.compte
          || ' '
          || compte.clerib rib_compte,
          compte.rais_soc, prelevement.numencaismt, qttc_global.numgar,
          qttc_global.idadhesion, qttc_global.debut, qttc_global.fin,
          adhe_cntrt.numadhe
        , ARTHUS.pk_sepa.f_afficher_compte(rib.bic   , rib.clef_iban   ||rib.bban    , prelevement.intitule, 'BIC+IBAN+INTITULE LONG') rib_SEPA
        , ARTHUS.pk_sepa.f_afficher_compte(compte.bic, compte.clef_iban||compte.bban , NULL                , 'BIC+IBAN+INTITULE LONG') rib_compte_SEPA
     FROM libelle ope,
          compte,
          adhe_cntrt,
          qttc_global,
          indvs,
          facture,
          remise_prelev,
          prelevement,
          prelevement_detail,
          rib
    WHERE ope.mnemo = 'OPE'
      AND ope.code = prelevement_detail.codope
      AND adhe_cntrt.idadhesion = qttc_global.idadhesion
      AND compte.numcpte = remise_prelev.numcpte
      AND qttc_global.numquit = facture.numfact
      AND indvs.numindiv = facture.numcli
      AND facture.codope = prelevement_detail.codope
      AND facture.numfact = prelevement_detail.numfact
      AND prelevement.numremise = remise_prelev.numremise
      AND prelevement_detail.numprelev = prelevement.numprelev
      AND rib.idrib =
             ARTHUS.pk_treso.f_idrib (facture.numcli,
                               2,
                               facture.codope,
                               qttc_global.numgar,
                               SYSDATE,
                               adhe_cntrt.numadhe
                              )
   UNION
   SELECT compte.numsoc, remise_prelev.numremise,
             remise_prelev.numremise
          || ' du '
          || TO_CHAR (remise_prelev.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_prelev.nombre
          || ' prélèvements' lib_remise,
          remise_prelev.numcpte, facture.codope, prelevement_detail.numprelev,
          facture.numcli, indvs.nom || ' ' || indvs.prenom nom_querable,
             'Appel N° '
          || facture.numfact
          || ' Echéance '
          || TO_CHAR (qttc_global.debut, 'dd/mm/yyyy')
          || ' rejeté le '
          || TO_CHAR (annul_encais.date_annul, 'dd/mm/yyyy') lib_prelev,
          facture.numfact numaffec, 'qg03' codapli,
          -prelevement_detail.montant, prelevement_detail.monnaie,
          -prelevement_detail.montant_d, prelevement_detail.monnaie_d,
             DECODE (rib.nature,
                     2,  rib.codbque
                      || ' '
                      || rib.guichet
                      || ' '
                      || rib.compte
                      || ' '
                      || rib.clerib
                      || ' ',
                     3,  rib.codbque_etrg
                      || ' '
                      || rib.guichet_etrg
                      || ' '
                      || rib.compte_etrg
                      || ' '
                      || rib.clerib_etrg
                      || ' '
                    )
          || prelevement.intitule rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte,
          ope.code || ' - ' || ope.libelle lib_ope,
          annul_encais.motif motif_annul, compte.domicil,
             compte.guichet
          || ' '
          || compte.compte
          || ' '
          || compte.clerib rib_compte,
          compte.rais_soc, prelevement.numencaismt, qttc_global.numgar,
          qttc_global.idadhesion, qttc_global.debut, qttc_global.fin,
          adhe_cntrt.numadhe
        , ARTHUS.pk_sepa.f_afficher_compte(rib.bic   , rib.clef_iban   ||rib.bban    , prelevement.intitule, 'BIC+IBAN+INTITULE LONG') rib_SEPA
        , ARTHUS.pk_sepa.f_afficher_compte(compte.bic, compte.clef_iban||compte.bban , NULL                , 'BIC+IBAN+INTITULE LONG') rib_compte_SEPA
     FROM libelle ope,
          compte,
          adhe_cntrt,
          qttc_global,
          indvs,
          facture,
          remise_prelev,
          annul_encais,
          prelevement,
          prelevement_detail,
          rib
    WHERE ope.mnemo = 'OPE'
      AND ope.code = prelevement_detail.codope
      AND compte.numcpte = remise_prelev.numcpte
      AND adhe_cntrt.idadhesion = qttc_global.idadhesion
      AND qttc_global.numquit = facture.numfact
      AND indvs.numindiv = facture.numcli
      AND facture.codope = prelevement_detail.codope
      AND facture.numfact = prelevement_detail.numfact
      AND prelevement.numremise = remise_prelev.numremise
      AND prelevement_detail.numprelev = prelevement.numprelev
      AND prelevement.numencaismt = annul_encais.numencaismt
      AND rib.idrib =
             ARTHUS.pk_treso.f_idrib (facture.numcli,
                               2,
                               facture.codope,
                               qttc_global.numgar,
                               SYSDATE,
                               adhe_cntrt.numadhe
                              )
--
UNION
   SELECT compte.numsoc, remise_prelev.numremise,
             remise_prelev.numremise
          || ' du '
          || TO_CHAR (remise_prelev.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_prelev.nombre
          || ' prélèvements' lib_remise,
          remise_prelev.numcpte, facture.codope, prelevement_detail.numprelev,
          facture.numcli, indvs.nom || ' ' || indvs.prenom nom_querable,
             'Appel N° '
          || facture.numfact
          || ' Echéance '
          || TO_CHAR (qttc_global.debut, 'dd/mm/yyyy')
          || ' Contrat '
          || qttc_global.numgar lib_prelev,
          facture.numfact numaffec, 'qg03' codapli,
          prelevement_detail.montant, prelevement_detail.monnaie,
          prelevement_detail.montant_d, prelevement_detail.monnaie_d,
             DECODE (rib.nature,
                     2,  rib.codbque
                      || ' '
                      || rib.guichet
                      || ' '
                      || rib.compte
                      || ' '
                      || rib.clerib
                      || ' ',
                     3,  rib.codbque_etrg
                      || ' '
                      || rib.guichet_etrg
                      || ' '
                      || rib.compte_etrg
                      || ' '
                      || rib.clerib_etrg
                      || ' '
                    )
          || prelevement.intitule rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte,
          ope.code || ' - ' || ope.libelle lib_ope, TO_NUMBER ('')
                                                                  motif_annul,
          compte.domicil,
             compte.guichet
          || ' '
          || compte.compte
          || ' '
          || compte.clerib rib_compte,
          compte.rais_soc, prelevement.numencaismt, qttc_global.numgar,
          qttc_global.idadhesion, qttc_global.debut, qttc_global.fin,
          adhe_collective.numcli
        , ARTHUS.pk_sepa.f_afficher_compte(rib.bic   , rib.clef_iban   ||rib.bban    , prelevement.intitule, 'BIC+IBAN+INTITULE LONG') rib_SEPA
        , ARTHUS.pk_sepa.f_afficher_compte(compte.bic, compte.clef_iban||compte.bban , NULL                , 'BIC+IBAN+INTITULE LONG') rib_compte_SEPA
     FROM libelle ope,
          compte,
          adhe_collective,
          qttc_global,
          indvs,
          facture,
          remise_prelev,
          prelevement,
          prelevement_detail,
          rib
    WHERE ope.mnemo = 'OPE'
      AND ope.code = prelevement_detail.codope
      AND adhe_collective.numgar = qttc_global.numgar
      AND compte.numcpte = remise_prelev.numcpte
      AND qttc_global.numquit = facture.numfact
      AND indvs.numindiv = facture.numcli
      AND facture.codope = prelevement_detail.codope
      AND facture.numfact = prelevement_detail.numfact
      AND prelevement.numremise = remise_prelev.numremise
      AND prelevement_detail.numprelev = prelevement.numprelev
      AND rib.idrib =
             ARTHUS.pk_treso.f_idrib (facture.numcli,
                               2,
                               facture.codope,
                               qttc_global.numgar,
                               SYSDATE,
                               adhe_collective.numgar_ref
                              )
UNION
   SELECT compte.numsoc, remise_prelev.numremise,
             remise_prelev.numremise
          || ' du '
          || TO_CHAR (remise_prelev.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_prelev.nombre
          || ' prélèvements' lib_remise,
          remise_prelev.numcpte, facture.codope, prelevement_detail.numprelev,
          facture.numcli, indvs.nom || ' ' || indvs.prenom nom_querable,
             'Appel N° '
          || facture.numfact
          || ' Echéance '
          || TO_CHAR (qttc_global.debut, 'dd/mm/yyyy')
          || ' rejeté le '
          || TO_CHAR (annul_encais.date_annul, 'dd/mm/yyyy') lib_prelev,
          facture.numfact numaffec, 'qg03' codapli,
          -prelevement_detail.montant, prelevement_detail.monnaie,
          -prelevement_detail.montant_d, prelevement_detail.monnaie_d,
             DECODE (rib.nature,
                     2,  rib.codbque
                      || ' '
                      || rib.guichet
                      || ' '
                      || rib.compte
                      || ' '
                      || rib.clerib
                      || ' ',
                     3,  rib.codbque_etrg
                      || ' '
                      || rib.guichet_etrg
                      || ' '
                      || rib.compte_etrg
                      || ' '
                      || rib.clerib_etrg
                      || ' '
                    )
          || prelevement.intitule rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte,
          ope.code || ' - ' || ope.libelle lib_ope,
          annul_encais.motif motif_annul, compte.domicil,
             compte.guichet
          || ' '
          || compte.compte
          || ' '
          || compte.clerib rib_compte,
          compte.rais_soc, prelevement.numencaismt, qttc_global.numgar,
          qttc_global.idadhesion, qttc_global.debut, qttc_global.fin,
          adhe_collective.numcli
        , ARTHUS.pk_sepa.f_afficher_compte(rib.bic   , rib.clef_iban   ||rib.bban    , prelevement.intitule, 'BIC+IBAN+INTITULE LONG') rib_SEPA
        , ARTHUS.pk_sepa.f_afficher_compte(compte.bic, compte.clef_iban||compte.bban , NULL                , 'BIC+IBAN+INTITULE LONG') rib_compte_SEPA
     FROM libelle ope,
          compte,
          adhe_collective,
          qttc_global,
          indvs,
          facture,
          remise_prelev,
          annul_encais,
          prelevement,
          prelevement_detail,
          rib
    WHERE ope.mnemo = 'OPE'
      AND ope.code = prelevement_detail.codope
      AND compte.numcpte = remise_prelev.numcpte
      AND adhe_collective.numgar = qttc_global.numgar
      AND qttc_global.numquit = facture.numfact
      AND indvs.numindiv = facture.numcli
      AND facture.codope = prelevement_detail.codope
      AND facture.numfact = prelevement_detail.numfact
      AND prelevement.numremise = remise_prelev.numremise
      AND prelevement_detail.numprelev = prelevement.numprelev
      AND prelevement.numencaismt = annul_encais.numencaismt
      AND rib.idrib =
             ARTHUS.pk_treso.f_idrib (facture.numcli,
                               2,
                               facture.codope,
                               qttc_global.numgar,
                               SYSDATE,
                               adhe_collective.numgar_ref
                              )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_PRELEV_DETAIL1 FOR ARTHUS.V_REMISE_PRELEV_DETAIL1
