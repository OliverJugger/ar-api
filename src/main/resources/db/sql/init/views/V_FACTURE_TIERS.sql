CREATE FORCE VIEW ARTHUS.V_FACTURE_TIERS AS
SELECT
    ALL facture.codope,
    facture.numfact,
    facture.numcli,
    tiers.numindiv numtiers,
    qttc_global.type_qttc * 2 etendue,
    DECODE (qttc_global.type_qttc, 1, qttc_global.numgar, 2,
    qttc_global.idadhesion ) cle,
    qttc_global.numgar,
    qttc_global.numindiv,
    qttc_global.nat_calc,
    qttc_global.fin,
    facture.montant,
    facture.monnaie,
    facture.montant_d,
    facture.monnaie_d,
    facture.mregl,
    facture.echeance,
    qttc_global.debut datfact,
    f_totaffec (facture.numfact, facture.codope, NULL) mt_affec,
    f_totaffec_d (facture.numfact, facture.codope, NULL) mt_affec_d,
    contrat.refcie
    || ' - '
    || indvs.nom
    || ' '
    || indvs.prenom libelle,
    contrat.refcie,
    indvs.nom,
    indvs.prenom,
    'qg03' codapli
  FROM
    indvs,
    indvs tiers,
    facture,
    qttc_global,
    contrat
  WHERE
    facture.codope           = 4
  AND qttc_global.comptant  <> 'R'
  AND qttc_global.type_qttc <> 3
  AND contrat.gest_cotis     = 2
  AND contrat.numgar         = contrat.numgar_ref
  AND indvs.numindiv         = facture.numcli
  AND facture.numfact        = qttc_global.numquit
  AND qttc_global.numgar     = contrat.numgar
  AND tiers.numindiv         = contrat.delegataire
  AND NOT EXISTS
    (
      SELECT
        1
      FROM
        emission
      WHERE
        emission.numrelance IN (4, 99)
      AND
        (
          (
            emission.codope = facture.codope
          )
        AND
          (
            emission.numfact = facture.numfact
          )
        )
    )
  UNION
  SELECT
    ALL facture.codope,
    facture.numfact,
    facture.numcli,
    apporteur.numindiv numtiers,
    qttc_global.type_qttc * 2 etendue,
    DECODE (qttc_global.type_qttc, 1, qttc_global.numgar, 2,
    qttc_global.idadhesion ) cle,
    qttc_global.numgar,
    qttc_global.numindiv,
    qttc_global.nat_calc,
    qttc_global.fin,
    facture.montant,
    facture.monnaie,
    facture.montant_d,
    facture.monnaie_d,
    facture.mregl,
    facture.echeance,
    qttc_global.debut datfact,
    f_totaffec (facture.numfact, facture.codope, NULL) mt_affec,
    f_totaffec_d (facture.numfact, facture.codope, NULL) mt_affec_d,
    contrat.refcie
    || ' - '
    || indvs.nom
    || ' '
    || indvs.prenom libelle,
    contrat.refcie,
    indvs.nom,
    indvs.prenom,
    'qg03' codapli
  FROM
    indvs,
    facture,
    qttc_global,
    contrat,
    apporteur
  WHERE
    facture.codope           = 4
  AND qttc_global.comptant  <> 'R'
  AND qttc_global.type_qttc <> 3
  AND contrat.gest_cotis     = 2
  AND contrat.numgar        <> contrat.numgar_ref
  AND indvs.numindiv         = facture.numcli
  AND facture.numfact        = qttc_global.numquit
  AND qttc_global.numgar     = contrat.numgar
  AND apporteur.etendue      = 2
  AND apporteur.type_apport  = 2
  AND apporteur.cle          = contrat.numgar
  AND apporteur.numindiv     = contrat.numquerable
  AND NOT EXISTS
    (
      SELECT
        1
      FROM
        emission
      WHERE
        emission.numrelance IN (4, 99)
      AND
        (
          (
            emission.codope = facture.codope
          )
        AND
          (
            emission.numfact = facture.numfact
          )
        )
    )
  UNION
  SELECT
    compte_tiers.codope,
    compte_tiers.cle numfact,
    compte_tiers.numcli,
    compte_tiers.numcli numtiers,
    0 etendue,
    compte_tiers.idmvt cle,
    0 numgar,
    0 numindiv,
    0 nat_calc,
    TO_DATE ('') fin,
    compte_tiers.montant,
    compte_tiers.monnaie,
    compte_tiers.montant_d,
    compte_tiers.monnaie_d,
    1 mregl,
    TO_DATE ('') echeance,
    compte_tiers.datope datfact,
    f_contrepartie (compte_tiers.idmvt) mt_affec,
    f_contrepartie_d (compte_tiers.idmvt) mt_affec_d,
    DECODE (compte_tiers.codope, 14, ARTHUS.pk_trace.f_aff_mess_err (1001, 1,
    compte_tiers.cle), 16, ARTHUS.pk_trace.f_aff_mess_err (1002, 1, compte_tiers.cle),
    17, ARTHUS.pk_trace.f_aff_mess_err (1001, 1, compte_tiers.cle) ) libelle,
    DECODE (compte_tiers.codope, 14, ARTHUS.pk_trace.f_aff_mess_err (1001, 1,
    compte_tiers.cle), 16, ARTHUS.pk_trace.f_aff_mess_err (1002, 1, compte_tiers.cle),
    17, ARTHUS.pk_trace.f_aff_mess_err (1001, 1, compte_tiers.cle) ) refcie,
    indvs.nom,
    indvs.prenom,
    DECODE (compte_tiers.codope, 14, 'de21', 16, 'de42', 17, 'de81') codapli
  FROM
    indvs,
    compte_tiers
  WHERE
    indvs.numindiv         = compte_tiers.numcli
  AND compte_tiers.sens    = -1
  AND compte_tiers.codope   IN (14, 16, 17)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACTURE_TIERS FOR ARTHUS.V_FACTURE_TIERS
