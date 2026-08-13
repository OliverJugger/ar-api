CREATE FORCE VIEW ARTHUS.V_CORRES_MAIL AS
SELECT DISTINCT TO_NUMBER (repartition.nosin) entite,
    NULL interlocuteur,
    repartition_bene.numbene_dest numindiv,
    repartition.idadhesion cle,
--  2 contexte,
    6 contexte,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM repartition,
    repartition_bene
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
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM repartition,
    sin_prev
  WHERE repartition.nosin = sin_prev.nosin
  AND repartition.valide  = 'O'
  UNION
  SELECT DISTINCT TO_NUMBER (repartition.nosin) entite,
    NULL,
    repartition_bene.numbene numindiv,
    repartition.idadhesion cle,
--  2 contexte,
    6 contexte,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM repartition,
    repartition_bene
  WHERE repartition.idrepartition = repartition_bene.idrepartition
  AND repartition_bene.valide     = 'O'
  AND repartition.valide          = 'O'
  UNION
  SELECT distinct adhe_cntrt.idadhesion,
    NULL,
    adhe_cntrt.numadhe,
    adhe_cntrt.idadhesion,
    4,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt
  UNION
  SELECT distinct adhe_cntrt.idadhesion,
    NULL,
    adhe_cntrt_membre.numindiv,
    adhe_cntrt.idadhesion,
    4,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt,
    adhe_cntrt_membre
  WHERE adhe_cntrt.idadhesion = adhe_cntrt_membre.idadhesion
  UNION
  SELECT distinct adhe_cntrt.idadhesion,
    NULL,
    apporteur.numindiv,
    adhe_cntrt.idadhesion,
    4,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt,
    apporteur
  WHERE adhe_cntrt.idadhesion = apporteur.cle
  AND apporteur.etendue       = 4
  AND apporteur.debut BETWEEN ARTHUS.pk_histo_contrat.f_sel_date_debut (adhe_cntrt.numgar) AND NVL (apporteur.fin, apporteur.debut)
  /*   UNION
  SELECT contrat.numgar, NULL, contrat.numcli, contrat.numgar, 8
  FROM contrat
  UNION
  SELECT contrat.numgar, NULL, apporteur.numindiv, contrat.numgar, 8
  FROM contrat, apporteur
  WHERE apporteur.cle = contrat.numgar
  AND apporteur.etendue = 2
  AND apporteur.debut
  BETWEEN ARTHUS.pk_histo_contrat.f_sel_date_debut (contrat.numgar)
  AND NVL (apporteur.fin, apporteur.debut)*/
  UNION
  SELECT distinct proposition.idpropo,
    NULL,
    proposition.numindiv,
    DECODE (proposition.objet, 1, contrat.numprod, 2, contrat.numgar),
    14,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM proposition,
    contrat
  WHERE proposition.idobjet = DECODE (proposition.objet, 1, contrat.numprod, 2, contrat.numgar )
  UNION
  SELECT distinct proposition.idpropo,
    NULL,
    apporteur.numindiv,
    DECODE (proposition.objet, 1, contrat.numprod, 2, contrat.numgar),
    14,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM proposition,
    contrat,
    apporteur
  WHERE proposition.idpropo = apporteur.cle
  AND apporteur.etendue     = 14
  AND proposition.idobjet   = DECODE (proposition.objet, 1, contrat.numprod, 2, contrat.numgar )
  UNION
  SELECT distinct entite,
    interlocuteur,
    numcorres,
    entite cle,
    6 contexte,
    DECODE (defaut_sntr, 'O', '*', NULL) DEFAUT,
    NULL OPE_CRRR
  FROM correspondant
  WHERE contexte = 15
  UNION
  SELECT distinct entite,
    interlocuteur,
    numcorres,
    entite cle,
    8 contexte,
    DECODE (defaut_sntr, 'O', '*', NULL) DEFAUT,
    NULL OPE_CRRR
  FROM correspondant
  WHERE contexte = 2
  UNION  -- CLI AJout par rapport a v_corres
  SELECT distinct null entite,
     interlocuteur,
    numindiv numcorres,
    null cle,
    null contexte,
    null DEFAUT,
    OPE_CRRR OPE_CRRR
  FROM interlocuteur
  UNION-- CLI AJout par rapport a v_corres
  SELECT distinct null entite,
    numindiv interlocuteur,
    numindiv numcorres,
    null cle,
    null contexte,
    null DEFAUT,
    NULL OPE_CRRR
  FROM individu
  UNION
  SELECT distinct adhe_cntrt.numadhe,
    NULL,
    adhe_cntrt.numadhe,
    adhe_cntrt.idadhesion,
    11,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt
  UNION
  SELECT distinct adhe_cntrt.numadhe,
    NULL,
    adhe_cntrt_membre.numindiv,
    adhe_cntrt.idadhesion,
    11,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt,
    adhe_cntrt_membre
  WHERE adhe_cntrt.idadhesion = adhe_cntrt_membre.idadhesion
  UNION
  SELECT distinct  adhe_cntrt.numadhe,
    NULL,
    apporteur.numindiv,
    adhe_cntrt.idadhesion,
    11,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt,
    apporteur
  WHERE adhe_cntrt.idadhesion = apporteur.cle
  AND apporteur.etendue       = 4
  AND apporteur.debut BETWEEN ARTHUS.pk_histo_contrat.f_sel_date_debut (adhe_cntrt.numgar) AND NVL (apporteur.fin, apporteur.debut)
  --SDA M3217
  UNION
  SELECT distinct adhe_cntrt.numadhe,
    NULL,
    adhe_cntrt.numadhe,
    adhe_cntrt.idadhesion,
    13,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt
  UNION
  SELECT distinct adhe_cntrt.numadhe,
    NULL,
    adhe_cntrt_membre.numindiv,
    adhe_cntrt.idadhesion,
    13,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt,
    adhe_cntrt_membre
  WHERE adhe_cntrt.idadhesion = adhe_cntrt_membre.idadhesion
  UNION
  SELECT distinct adhe_cntrt.numadhe,
    NULL,
    apporteur.numindiv,
    adhe_cntrt.idadhesion,
    13,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM adhe_cntrt,
    apporteur
  WHERE adhe_cntrt.idadhesion = apporteur.cle
  AND apporteur.etendue       = 4
  AND apporteur.debut BETWEEN ARTHUS.pk_histo_contrat.f_sel_date_debut (adhe_cntrt.numgar) AND NVL (apporteur.fin, apporteur.debut)
 UNION
  SELECT distinct to_number(courr_dest.id),
    NULL,
    courr_dest.numindiv,
    to_number(courr_dest.id),
    9,
    NULL DEFAUT,
    NULL OPE_CRRR
  FROM courr_dest
  WHERE valide =1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CORRES_MAIL FOR ARTHUS.V_CORRES_MAIL
