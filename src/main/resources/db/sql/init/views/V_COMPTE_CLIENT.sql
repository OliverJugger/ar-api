CREATE FORCE VIEW ARTHUS.V_COMPTE_CLIENT AS
SELECT cpt.idaffec
, cpt.codope
, cpt.numcli
, cpt.numencaismt
, cpt.datope
, cpt.montant
, cpt.montant_d
, cpt.numfact
, cpt.idcompta
, cpt.monnaie
, cpt.monnaie_d
, null numdecaismt
, null numaffec
, CASE WHEN cpt.datope < f_cpta_date_encaismt_operation(enc.numencaismt)
               THEN f_cpta_date_encaismt_operation(enc.numencaismt)
               ELSE cpt.datope
          END datope_compta
FROM compte_client cpt, encaismt enc
WHERE ((cpt.CODOPE != 8)
OR (cpt.CODOPE = 8 AND cpt.montant_d != 0))
     AND cpt.numencaismt = enc.numencaismt
UNION ALL
SELECT cpt.idmvt
, cpt.codope
, cpt.numcli
, cpt.cle
, cpt.datope
, cpt.montant + f_contrepartie (cpt.idmvt)
, cpt.montant_d + f_contrepartie_d (cpt.idmvt)
, TO_NUMBER ('') numfact
, cpt.idcompta
, cpt.monnaie
, cpt.monnaie_d
, null numdecaismt
, null numaffec
, CASE WHEN cpt.datope < f_cpta_date_encaismt_operation(enc.numencaismt)
               THEN f_cpta_date_encaismt_operation(enc.numencaismt)
               ELSE cpt.datope
          END datope_compta
FROM compte_tiers cpt, encaismt enc
WHERE cpt.sens = 1
  AND cpt.codope not in (2, 16)
  AND (cpt.montant_d + f_contrepartie_d (cpt.idmvt)) != 0
  AND cpt.cle = enc.numencaismt
  AND enc.numcli = cpt.numcli
UNION ALL
SELECT compte_tiers.idmvt
, compte_tiers.codope
, compte_tiers.numcli
, compte_tiers.cle
, compte_tiers.datope
, compte_tiers.montant + f_contrepartie (compte_tiers.idmvt)
, compte_tiers.montant_d + f_contrepartie_d (compte_tiers.idmvt)
, TO_NUMBER ('') numfact
, compte_tiers.idcompta
, compte_tiers.monnaie
, compte_tiers.monnaie_d
, null numdecaismt
, null numaffec
, CASE WHEN compte_tiers.datope < f_cpta_date_encaismt_operation(enc.numencaismt)
               THEN f_cpta_date_encaismt_operation(enc.numencaismt)
               ELSE compte_tiers.datope
          END datope_compta
FROM compte_tiers, compensation, encaismt enc
WHERE compte_tiers.sens = 1
  AND compte_tiers.codope = 16
  AND compte_tiers.idmvt = compensation.idmvt
  AND (compte_tiers.montant_d + f_contrepartie_d (compte_tiers.idmvt)) != 0
  AND (compensation.idcomp IN (SELECT idaffec FROM compte_client)
       OR
       compensation.idcomp IN (SELECT idmvt FROM compte_tiers)
       )
  AND enc.numencaismt =compte_tiers.cle
  AND enc.numcli = compte_tiers.numcli
UNION ALL -- M0005035
SELECT cpt.idmvt
, cpt.codope
, cpt.numcli
, cpt2.cle
, cpt.datope
, cpt.montant
, cpt.montant_d
, TO_NUMBER ('') numfact
, cpt.idcompta
, cpt.monnaie
, cpt.monnaie_d
, aff.numdecaismt
, aff.numaffec
, cpt.datope datope_compta
FROM compte_tiers cpt, compensation cop, compte_tiers cpt2, encaismt enc, affectation aff
   WHERE cop.idcomp = cpt.idmvt
     AND cop.idmvt = cpt2.idmvt
     AND cpt2.cle = enc.numencaismt
     AND cpt2.numcli = enc.numcli
     AND cpt2.codope = aff.codope
     AND cpt.cle = aff.numaffec
     AND aff.codope = cpt.codope
     AND cpt.numcli = cpt2.numcli
     AND cpt.sens = -1
     AND cpt.codope = 10
     AND NOT EXISTS(SELECT 1 FROM annul_encais WHERE annul_encais.numencaismt = enc.numencaismt)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTE_CLIENT FOR ARTHUS.V_COMPTE_CLIENT
