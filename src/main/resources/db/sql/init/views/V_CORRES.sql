CREATE FORCE VIEW ARTHUS.V_CORRES AS
SELECT DISTINCT TO_NUMBER (repartition.nosin) entite,
    NULL interlocuteur,
    repartition_bene.numbene_dest numindiv,
    repartition.idadhesion cle,
--  2 contexte,
    6 contexte,
    NULL defaut_sntr
  FROM ARTHUS.repartition,
    ARTHUS.repartition_bene
  WHERE repartition.idrepartition = repartition_bene.idrepartition
  AND repartition_bene.valide     = 'O'
  AND repartition.valide          = 'O'
  UNION
  SELECT DISTINCT TO_NUMBER (repartition.nosin),
    NULL,
    sin_prev.numindiv_corres,
    repartition.idadhesion,
--  2,
    6,
    NULL
  FROM ARTHUS.repartition,
    ARTHUS.sin_prev
  WHERE repartition.nosin = sin_prev.nosin
  AND repartition.valide  = 'O'
  UNION
  SELECT DISTINCT TO_NUMBER (repartition.nosin) entite,
    NULL,
    repartition_bene.numbene numindiv,
    repartition.idadhesion cle,
--  2 contexte,
    6 contexte,
    NULL
  FROM ARTHUS.repartition,
    ARTHUS.repartition_bene
  WHERE repartition.idrepartition = repartition_bene.idrepartition
  AND repartition_bene.valide     = 'O'
  AND repartition.valide          = 'O'
  UNION
  SELECT adhe_cntrt.idadhesion,
    NULL,
    adhe_cntrt.numadhe,
    adhe_cntrt.idadhesion,
    4,
    NULL
  FROM ARTHUS.adhe_cntrt
  UNION
  SELECT adhe_cntrt.idadhesion,
    NULL,
    adhe_cntrt_membre.numindiv,
    adhe_cntrt.idadhesion,
    4,
    NULL
  FROM ARTHUS.adhe_cntrt,
    ARTHUS.adhe_cntrt_membre
  WHERE adhe_cntrt.idadhesion = adhe_cntrt_membre.idadhesion
  UNION
  SELECT adhe_cntrt.idadhesion,
    NULL,
    apporteur.numindiv,
    adhe_cntrt.idadhesion,
    4,
    NULL
  FROM ARTHUS.adhe_cntrt,
    ARTHUS.apporteur
  WHERE adhe_cntrt.idadhesion = apporteur.cle
  AND apporteur.etendue       = 4
  AND apporteur.debut BETWEEN ARTHUS.pk_histo_contrat.f_sel_date_debut (adhe_cntrt.numgar) AND NVL (apporteur.fin, apporteur.debut)
  /*   UNION
  SELECT contrat.numgar, NULL, contrat.numcli, contrat.numgar, 8
  FROM ARTHUS.contrat
  UNION
  SELECT contrat.numgar, NULL, apporteur.numindiv, contrat.numgar, 8
  FROM ARTHUS.contrat, ARTHUS.apporteur
  WHERE apporteur.cle = contrat.numgar
  AND apporteur.etendue = 2
  AND apporteur.debut
  BETWEEN ARTHUS.pk_histo_contrat.f_sel_date_debut (contrat.numgar)
  AND NVL (apporteur.fin, apporteur.debut)*/
  UNION
  SELECT proposition.idpropo,
    NULL,
    proposition.numindiv,
    DECODE (proposition.objet, 1, contrat.numprod, 2, contrat.numgar),
    14,
    NULL
  FROM ARTHUS.proposition,
    ARTHUS.contrat
  WHERE proposition.idobjet = DECODE (proposition.objet, 1, contrat.numprod, 2, contrat.numgar )
  UNION
  SELECT proposition.idpropo,
    NULL,
    apporteur.numindiv,
    DECODE (proposition.objet, 1, contrat.numprod, 2, contrat.numgar),
    14,
    NULL
  FROM ARTHUS.proposition,
    ARTHUS.contrat,
    ARTHUS.apporteur
  WHERE proposition.idpropo = apporteur.cle
  AND apporteur.etendue     = 14
  AND proposition.idobjet   = DECODE (proposition.objet, 1, contrat.numprod, 2, contrat.numgar )
  UNION
  SELECT entite,
    interlocuteur,
    numcorres,
    entite cle,
    6 contexte,
    DECODE (defaut_sntr, 'O', '*', NULL)
  FROM ARTHUS.correspondant
  WHERE contexte = 15
  UNION
  SELECT entite,
    interlocuteur,
    numcorres,
    entite cle,
    8 contexte,
    DECODE (defaut_sntr, 'O', '*', NULL)
  FROM ARTHUS.correspondant
  WHERE contexte = 2
  UNION
  SELECT adhe_cntrt.numadhe,
    NULL,
    adhe_cntrt.numadhe,
    adhe_cntrt.idadhesion,
    11,
    NULL
  FROM ARTHUS.adhe_cntrt
  UNION
  SELECT adhe_cntrt.numadhe,
    NULL,
    adhe_cntrt_membre.numindiv,
    adhe_cntrt.idadhesion,
    11,
    NULL
  FROM ARTHUS.adhe_cntrt,
    ARTHUS.adhe_cntrt_membre
  WHERE adhe_cntrt.idadhesion = adhe_cntrt_membre.idadhesion
  UNION
  SELECT adhe_cntrt.numadhe,
    NULL,
    apporteur.numindiv,
    adhe_cntrt.idadhesion,
    11,
    NULL
  FROM ARTHUS.adhe_cntrt,
    ARTHUS.apporteur
  WHERE adhe_cntrt.idadhesion = apporteur.cle
  AND apporteur.etendue       = 4
  AND apporteur.debut BETWEEN ARTHUS.pk_histo_contrat.f_sel_date_debut (adhe_cntrt.numgar) AND NVL (apporteur.fin, apporteur.debut)
  --SDA M3217
  UNION
  SELECT adhe_cntrt.numadhe,
    NULL,
    adhe_cntrt.numadhe,
    adhe_cntrt.idadhesion,
    13,
    NULL
  FROM ARTHUS.adhe_cntrt
  UNION
  SELECT adhe_cntrt.numadhe,
    NULL,
    adhe_cntrt_membre.numindiv,
    adhe_cntrt.idadhesion,
    13,
    NULL
  FROM ARTHUS.adhe_cntrt,
    ARTHUS.adhe_cntrt_membre
  WHERE adhe_cntrt.idadhesion = adhe_cntrt_membre.idadhesion
  UNION
  SELECT adhe_cntrt.numadhe,
    NULL,
    apporteur.numindiv,
    adhe_cntrt.idadhesion,
    13,
    NULL
  FROM ARTHUS.adhe_cntrt,
    ARTHUS.apporteur
  WHERE adhe_cntrt.idadhesion = apporteur.cle
  AND apporteur.etendue       = 4
  AND apporteur.debut BETWEEN ARTHUS.pk_histo_contrat.f_sel_date_debut (adhe_cntrt.numgar) AND NVL (apporteur.fin, apporteur.debut)
 UNION
  SELECT to_number(courr_dest.id),
    NULL,
    courr_dest.numindiv,
    to_number(courr_dest.id),
    9,
    NULL
  FROM ARTHUS.courr_dest
  WHERE valide =1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CORRES FOR ARTHUS.V_CORRES
