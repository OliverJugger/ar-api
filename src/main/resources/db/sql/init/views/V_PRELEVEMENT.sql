CREATE FORCE VIEW ARTHUS.V_PRELEVEMENT AS
SELECT compte.numsoc, remise_prelev.numremise, remise_prelev.numcpte,
          prelevement.numprelev,
          remise_prelev.numcpte || ' ' || compte.libcompte lib_compte,
             remise_prelev.numremise
          || ' du '
          || TO_CHAR (remise_prelev.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_prelev.nombre
          || ' prélèvements' lib_remise,
             prelevement.codbque
          || ' '
          || prelevement.guichet
          || ' '
          || prelevement.compte
          || ' '
          || prelevement.clerib
          || ' '
          || prelevement.intitule rib,
          prelevement.montant, prelevement.monnaie, prelevement.montant_d,
          prelevement.monnaie_d, TO_DATE ('') date_annul,
          TO_NUMBER ('') motif_annul,
             prelevement.codbque
          || ' '
          || prelevement.guichet
          || ' '
          || prelevement.compte
          || ' '
          || prelevement.clerib
          || ' '
          || prelevement.intitule rib_orig,
          remise_prelev.dataccuse, remise_prelev.datdisk,
          prelevement.numencaismt
        , ARTHUS.pk_sepa.f_afficher_compte(prelevement.bic, prelevement.clef_iban||prelevement.bban, prelevement.intitule, 'BIC+IBAN+INTITULE LONG') rib_orig_SEPA
     FROM remise_prelev, prelevement, compte
    WHERE compte.numcpte = remise_prelev.numcpte
      AND prelevement.numremise = remise_prelev.numremise
      AND NOT EXISTS (
                      SELECT 1
                        FROM annul_encais
                       WHERE annul_encais.numencaismt =
                                                       prelevement.numencaismt)
   UNION
   SELECT compte.numsoc, remise_prelev.numremise, remise_prelev.numcpte,
          prelevement.numprelev,
          remise_prelev.numcpte || ' ' || compte.libcompte lib_compte,
             remise_prelev.numremise
          || ' du '
          || TO_CHAR (remise_prelev.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_prelev.nombre
          || ' prélèvements' lib_remise,
             'rejeté le '
          || TO_CHAR (annul_encais.date_annul, 'dd/mm/yyyy')
          || ' '
          || libelle.libelle rib,
          prelevement.montant, prelevement.monnaie, prelevement.montant_d,
          prelevement.monnaie_d, annul_encais.date_annul,
          annul_encais.motif motif_annul,
             prelevement.codbque
          || ' '
          || prelevement.guichet
          || ' '
          || prelevement.compte
          || ' '
          || prelevement.clerib
          || ' '
          || prelevement.intitule rib_orig,
          remise_prelev.dataccuse, remise_prelev.datdisk,
          prelevement.numencaismt
        , ARTHUS.pk_sepa.f_afficher_compte(prelevement.bic, prelevement.clef_iban||prelevement.bban, prelevement.intitule, 'BIC+IBAN+INTITULE LONG') rib_orig_SEPA
     FROM compte, libelle, remise_prelev, annul_encais, prelevement
    WHERE compte.numcpte = remise_prelev.numcpte
      AND libelle.mnemo = 'PREVANN'
      AND libelle.code = annul_encais.motif
      AND prelevement.numencaismt = annul_encais.numencaismt
      AND prelevement.numremise = remise_prelev.numremise
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRELEVEMENT FOR ARTHUS.V_PRELEVEMENT
