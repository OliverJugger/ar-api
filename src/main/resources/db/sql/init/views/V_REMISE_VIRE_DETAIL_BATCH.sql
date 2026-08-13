CREATE FORCE VIEW ARTHUS.V_REMISE_VIRE_DETAIL_BATCH AS
SELECT compte.numsoc, remise_vire.numremise,
             remise_vire.numremise
          || ' du '
          || TO_CHAR (remise_vire.datrem, 'dd/mm/yyyy')
          || ' - '
          || remise_vire.nombre
          || ' virements' lib_remise,
          remise_vire.numcpte, decaismt.codope,
          remise_vire_detail.numvirement, decaismt.numbene,
             DECODE (decaismt.codope,
                     1, 'Décompte maladie No:',
                     2, 'Décompte prévoyance No:'
                    )
          || affectation.numaffec lib_vire,
          remise_vire_detail.montant,
             remise_vire_detail.codbque
          || ' '
          || remise_vire_detail.guichet
          || ' '
          || remise_vire_detail.compte
          || ' '
          || remise_vire_detail.clerib
          || ' '
          || remise_vire_detail.intitule rib,
          compte.numcpte || ' - ' || compte.libcompte lib_compte,
          ope.code || ' - ' || ope.libelle lib_ope
        , ARTHUS.pk_sepa.f_afficher_compte(remise_vire_detail.bic, remise_vire_detail.clef_iban||remise_vire_detail.bban, remise_vire_detail.intitule, 'BIC+IBAN+INTITULE LONG') rib_SEPA
     FROM decaismt,
          affectation,
          remise_vire,
          remise_vire_detail,
          compte,
          libelle ope
    WHERE ope.code = decaismt.codope
      AND ope.mnemo = 'OPE'
      AND compte.numcpte = remise_vire.numcpte
      AND remise_vire_detail.numremise = remise_vire.numremise
      AND remise_vire_detail.numdecaismt = decaismt.numdecaismt
      AND affectation.numdecaismt = decaismt.numdecaismt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_VIRE_DETAIL_BATCH FOR ARTHUS.V_REMISE_VIRE_DETAIL_BATCH
