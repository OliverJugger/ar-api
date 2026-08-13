CREATE FORCE VIEW ARTHUS.V_PRDG_ADS AS
SELECT ADS."GD_RISQUE",ADS."MONTANT",ADS."PR",ADS."CLE1",ADS."CLE2",ADS."CLE3",ADS."CLE4",ADS."CLE5",ADS."CLE6",ADS."CLE7",ADS."CLE8",ADS."CLE9",ADS."CLE10",ADS."DATOPE",ADS."NUMINDIV_DG",ADS."DECOMPTE",ADS."ASS_GARANTIE",ADS."GARANTIE",ADS."MONNAIE",ADS."NUMDECAISMT",ADS."NUMPNUL",ADS."NOSIN" FROM
(
-- PREVOYANCE
-- Select 1
SELECT
      '01'                                  GD_RISQUE
     ,TO_CHAR(v_histo_calcul.montant)         MONTANT  -- TODO vérifier que c'est le bon montant
     ,v_assur_delegat.numass                       PR
     ,TO_CHAR(vs_grnts.numgar)                   CLE1
     ,TO_CHAR(sntr_prev.survenance,'YYYY')       CLE2
     ,'01'                                       CLE3
     ,'003'                                      CLE4
     ,'BA'                                       CLE5
     ,' '                                         CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(v_histo_calcul.monnaie),1) CLE7
     ,dossier_sinistre.iddossier                CLE8
     ,v_histo_calcul.nosin                      CLE9
     ,TO_CHAR(v_histo_calcul.idcalcul)          CLE10
     ,TRUNC(decaismt_prest.datpay)              DATOPE
     ,vs_grnts.numinterm                  numindiv_dg
     ,TO_CHAR(decompte_prev.numdec)          decompte
     ,v_assur_delegat.numass             ass_garantie
     ,v_assur_delegat.numfor                 garantie
     ,TO_CHAR(v_histo_calcul.monnaie)         monnaie
     ,TO_CHAR(decaismt_prest.numdecaismt) numdecaismt
     ,'NV'                                    numpnul
     ,v_histo_calcul.nosin                      nosin
FROM  decompte_prev
     ,decaismt     decaismt_prest
     ,affectation  affectation_prest
     ,vs_grnts
     ,v_histo_calcul
     ,v_assur_delegat
     ,repartition
     ,adhe_cntrt
     ,sntr_prev
     ,dossier_sinistre
  WHERE  adhe_cntrt.numgar          = vs_grnts.numgar
    AND  decompte_prev.numdec       = affectation_prest.numaffec
    AND  affectation_prest.codope   = 2
    AND  decaismt_prest.numdecaismt = affectation_prest.numdecaismt
    AND  decaismt_prest.codope      = 2
    AND  decaismt_prest.flagpay+0   = 1
    AND  v_histo_calcul.NUMDEC      = decompte_prev.numdec
    AND  v_histo_calcul.numfor      = v_assur_delegat.numfor
    AND  repartition.idrepartition  = v_histo_calcul.idrepartition
    AND  repartition.idadhesion     = adhe_cntrt.idadhesion
    AND  sntr_prev.nosin            = v_histo_calcul.nosin
    AND sntr_prev.IDDOSSIER = dossier_sinistre.iddossier
    AND (v_histo_calcul.fin >= NVL(sntr_prev.priscalc,sntr_prev.prischarge) OR v_histo_calcul.montant <>0) --hors franchise
UNION all
-- 
-- Select 2
-- Annulations
SELECT
      '01'                                  GD_RISQUE
     ,TO_CHAR(- v_histo_calcul.montant)       MONTANT  -- TODO vérifier que c'est le bon montant
     ,v_assur_delegat.numass                       PR
     ,TO_CHAR(vs_grnts.numgar)                   CLE1
     ,TO_CHAR(sntr_prev.survenance,'YYYY')       CLE2
     ,'01'                                       CLE3
     ,'003'                                      CLE4
     ,'BA'                                       CLE5
     ,' '                                         CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(v_histo_calcul.monnaie),1) CLE7
     ,dossier_sinistre.iddossier                CLE8
     ,v_histo_calcul.nosin                      CLE9
     ,TO_CHAR(v_histo_calcul.idcalcul)          CLE10
     ,TRUNC(pnul.datannul)                     DATOPE
     ,vs_grnts.numinterm                  numindiv_dg
     ,TO_CHAR(decompte_prev.numdec)          decompte
     ,v_assur_delegat.numass             ass_garantie
     ,v_assur_delegat.numfor                 garantie
     ,TO_CHAR(v_histo_calcul.monnaie)         monnaie
     ,'NV'                                numdecaismt
     ,TO_CHAR(decaismt_prest.numdecaismt)     numpnul
     ,v_histo_calcul.nosin                      nosin
FROM  decompte_prev
     ,decaismt     decaismt_prest
     ,pnul
     ,affectation_annul  affectation_prest
     ,vs_grnts
     ,v_histo_calcul
     ,v_assur_delegat
     ,repartition
     ,adhe_cntrt
     ,sntr_prev
     ,dossier_sinistre
  WHERE  adhe_cntrt.numgar          = vs_grnts.numgar
    AND  decompte_prev.numdec       = affectation_prest.numaffec
    AND  affectation_prest.codope   = 2
    AND  decaismt_prest.numdecaismt = affectation_prest.numdecaismt
    AND  decaismt_prest.codope      = 2
    AND  decaismt_prest.flagpay+0   = 1
    AND  v_histo_calcul.NUMDEC      = decompte_prev.numdec
    AND  v_histo_calcul.numfor      = v_assur_delegat.numfor
    AND  repartition.idrepartition  = v_histo_calcul.idrepartition
    AND  repartition.idadhesion     = adhe_cntrt.idadhesion
    AND  sntr_prev.nosin            = v_histo_calcul.nosin
    AND  decaismt_prest.numdecaismt = pnul.numdecaismt
    AND  pnul.codope                = 2
    AND sntr_prev.IDDOSSIER = dossier_sinistre.iddossier
    AND (v_histo_calcul.fin >= NVL(sntr_prev.priscalc,sntr_prev.prischarge) OR v_histo_calcul.montant <>0) --hors franchise
UNION all
-- SANTE
-- Select 3
-- Annulation concernant les décaissements désaffectés
SELECT
      '01'                                  GD_RISQUE
     ,TO_CHAR(v_histo_calcul.montant)         MONTANT  -- TODO vérifier que c'est le bon montant
     ,v_assur_delegat.numass                       PR
     ,TO_CHAR(vs_grnts.numgar)                   CLE1
     ,TO_CHAR(sntr_prev.survenance,'YYYY')       CLE2
     ,'01'                                       CLE3
     ,'003'                                      CLE4
     ,'BA'                                       CLE5
     , ' '                                        CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(v_histo_calcul.monnaie),1) CLE7
     ,dossier_sinistre.iddossier                 CLE8
     ,v_histo_calcul.nosin                       CLE9
     ,TO_CHAR(v_histo_calcul.idcalcul)          CLE10
     ,TRUNC(decaismt_prest.datpay)             DATOPE
     ,vs_grnts.numinterm                  numindiv_dg
     ,TO_CHAR(decompte_prev.numdec)          decompte
     ,v_assur_delegat.numass             ass_garantie
     ,v_assur_delegat.numfor                 garantie
     ,TO_CHAR(v_histo_calcul.monnaie)         monnaie
     ,'NV'                                numdecaismt
     ,TO_CHAR(decaismt_prest.numdecaismt)     numpnul
     ,v_histo_calcul.nosin                      nosin
FROM  decompte_prev
     ,decaismt     decaismt_prest
     ,pnul
     ,affectation_annul  affectation_prest
     ,vs_grnts
     ,v_histo_calcul
     ,v_assur_delegat
     ,repartition
     ,adhe_cntrt
     ,sntr_prev
     ,dossier_sinistre
  WHERE  adhe_cntrt.numgar          = vs_grnts.numgar
    AND  decompte_prev.numdec       = affectation_prest.numaffec
    AND  affectation_prest.codope   = 2
    AND  decaismt_prest.numdecaismt = affectation_prest.numdecaismt
    AND  decaismt_prest.codope      = 2
    AND  decaismt_prest.flagpay+0   = 1
    AND  v_histo_calcul.NUMDEC      = decompte_prev.numdec
    AND  v_histo_calcul.numfor      = v_assur_delegat.numfor
    AND  repartition.idrepartition  = v_histo_calcul.idrepartition
    AND  repartition.idadhesion     = adhe_cntrt.idadhesion
    AND  sntr_prev.nosin            = v_histo_calcul.nosin
    AND  decaismt_prest.numdecaismt = pnul.numdecaismt
    AND  pnul.codope                = 2
    AND sntr_prev.IDDOSSIER = dossier_sinistre.iddossier
    AND (v_histo_calcul.fin >= NVL(sntr_prev.priscalc,sntr_prev.prischarge) OR v_histo_calcul.montant <>0) --hors franchise
UNION all
-- 
-- Select 4
-- Indus de prestations
  SELECT
      '01'                                  GD_RISQUE
     ,TO_CHAR(v_histo_calcul.montant)         MONTANT  -- TODO vérifier que c'est le bon montant
     ,v_assur_delegat.numass                       PR
     ,TO_CHAR(vs_grnts.numgar)                   CLE1
     ,TO_CHAR(sntr_prev.survenance,'YYYY')       CLE2
     ,'01'                                       CLE3
     ,'003'                                      CLE4
     ,'BA'                                       CLE5
     ,' '                                         CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(v_histo_calcul.monnaie),1) CLE7
     ,dossier_sinistre.iddossier                CLE8
     ,v_histo_calcul.nosin                      CLE9
     ,TO_CHAR(v_histo_calcul.idcalcul)          CLE10
     ,TRUNC(compte_client.datope)              DATOPE
     ,vs_grnts.numinterm                  numindiv_dg
     ,TO_CHAR(decompte_prev.numdec)          decompte
     ,v_assur_delegat.numass             ass_garantie
     ,v_assur_delegat.numfor                 garantie
     ,TO_CHAR(v_histo_calcul.monnaie)         monnaie
     ,'NV'                                numdecaismt
     ,'NV'                                    numpnul
     ,v_histo_calcul.nosin                      nosin
FROM  decompte_prev
     ,compte_client
     ,affectation  affectation_prest
     ,vs_grnts
     ,v_histo_calcul
     ,v_assur_delegat
     ,repartition
     ,adhe_cntrt
     ,sntr_prev
     ,dossier_sinistre
     ,garanties
  WHERE  adhe_cntrt.numgar          = vs_grnts.numgar
    AND  decompte_prev.numdec       = affectation_prest.numaffec
    AND  affectation_prest.codope   = 2
    AND  compte_client.numfact      = affectation_prest.numaffec
    AND  compte_client.codope       = 2
    AND  v_histo_calcul.NUMDEC      = decompte_prev.numdec
    AND  v_histo_calcul.numfor      = v_assur_delegat.numfor
    AND  repartition.idrepartition  = v_histo_calcul.idrepartition
    AND  repartition.idadhesion     = adhe_cntrt.idadhesion
    AND  sntr_prev.nosin            = v_histo_calcul.nosin
    AND  garanties.numfor           = v_assur_delegat.numfor
    AND  NVL(garanties.gest_calc, 0)= 1
    AND sntr_prev.IDDOSSIER = dossier_sinistre.iddossier
	--AND v_histo_calcul.fin >= NVL(sntr_prev.priscalc,sntr_prev.prischarge) --hors franchise  M5933
    AND (v_histo_calcul.fin >= NVL(sntr_prev.priscalc,sntr_prev.prischarge) OR v_histo_calcul.montant <>0) --hors franchise
UNION all
-- SANTE
-- Select 5
-- Ouverture et Fermeture des sinistres
SELECT
      '01'                                  GD_RISQUE
     ,'0'                                     MONTANT
     ,v_assur_delegat.numass                       PR
     ,TO_CHAR(vs_grnts.numgar)                   CLE1
     ,TO_CHAR(sntr_prev.survenance,'YYYY')       CLE2
     ,'01'                                       CLE3
     ,'003'                                      CLE4
     ,'BA'                                       CLE5
     ,' '                                         CLE6
     ,'EUR'                                       CLE7
     ,dossier_sinistre.iddossier                CLE8
     ,sntr_prev.nosin                           CLE9
     ,'NV'/*TO_CHAR(histo_sntr_prev.etat)*/             CLE10  -- TODO ou mettre l'info ouverture / fermeture ?
     ,TRUNC(histo_sntr_prev.saisie)            DATOPE
     ,vs_grnts.numinterm                  numindiv_dg
     ,'NV'                                   decompte
     ,v_assur_delegat.numass             ass_garantie
     ,v_assur_delegat.numfor                 garantie
     ,'NV'                                    monnaie
     ,'NV'                                numdecaismt
     ,'NV'                                    numpnul
     ,sntr_prev.nosin                           nosin
 FROM sntr_prev
     ,dossier_sinistre
     ,histo_sntr_prev
     ,repartition
     ,adhe_cntrt
     ,vs_grnts
     ,v_assur_delegat
     ,garanties
  WHERE  adhe_cntrt.numgar          = vs_grnts.numgar
    AND  sntr_prev.nosin            = histo_sntr_prev.nosin
    AND  repartition.nosin          = sntr_prev.nosin
    AND  repartition.idadhesion     = adhe_cntrt.idadhesion
    AND  repartition.numfor         = v_assur_delegat.numfor
    AND  repartition.valide         = 'O'
    AND  garanties.numfor           = v_assur_delegat.numfor
    AND  NVL(garanties.gest_calc, 0)= 1
    AND sntr_prev.IDDOSSIER = dossier_sinistre.iddossier
    AND EXISTS (select 1 FROM histo_calcul where idrepartition = repartition.idrepartition)
-- MUR M0006689
-- select 6  annulation decompte - annulation calcul
union all 
SELECT 
      '01'                                  GD_RISQUE
     ,TO_CHAR(-histo_calcul_annul.montant)         MONTANT  
     ,v_assur_delegat.numass                       PR
     ,TO_CHAR(vs_grnts.numgar)                   CLE1
     ,TO_CHAR(sntr_prev.survenance,'YYYY')       CLE2
     ,'01'                                       CLE3
     ,'003'                                      CLE4
     ,'BA'                                       CLE5
     , ' '                                        CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(histo_calcul_annul.monnaie),1) CLE7
     ,dossier_sinistre.iddossier                 CLE8
     ,histo_calcul_annul.nosin                       CLE9
     ,TO_CHAR(histo_calcul_annul.idcalcul)          CLE10
     ,TRUNC(histo_calcul_annul.datannul)             DATOPE
     ,vs_grnts.numinterm                  numindiv_dg
     ,TO_CHAR(dcpt_prev_annul.numdec)          decompte
     ,v_assur_delegat.numass             ass_garantie
     ,v_assur_delegat.numfor                 garantie
     ,TO_CHAR(histo_calcul_annul.monnaie)         monnaie
     ,'NV'                                numdecaismt
     ,TO_CHAR(decaismt.numdecaismt)     numpnul
     ,histo_calcul_annul.nosin                      nosin
FROM  dcpt_prev_annul 
     ,decaismt     
     ,pnul
     ,affectation_annul  
     ,vs_grnts
     ,histo_calcul_annul 
     , histo_calcul
     ,v_assur_delegat
     ,repartition
     ,adhe_cntrt
     ,sntr_prev
     ,dossier_sinistre
  WHERE  adhe_cntrt.numgar          = vs_grnts.numgar
    AND  dcpt_prev_annul.numdec       = affectation_annul.numaffec
    AND  affectation_annul.codope   = 2
    AND  decaismt.numdecaismt = affectation_annul.numdecaismt
    AND  decaismt.codope      = 2
    AND  decaismt.flagpay+0   = 1
    AND  histo_calcul_annul.NUMDEC      = dcpt_prev_annul.numdec
    AND  histo_calcul_annul.numfor      = v_assur_delegat.numfor
    AND  repartition.idrepartition  = histo_calcul_annul.idrepartition
    AND  repartition.idadhesion     = adhe_cntrt.idadhesion
    AND  sntr_prev.nosin            = histo_calcul_annul.nosin
    AND  decaismt.numdecaismt = pnul.numdecaismt
    AND  pnul.codope                = 2
    AND sntr_prev.IDDOSSIER = dossier_sinistre.iddossier
    AND (histo_calcul_annul.fin >= NVL(sntr_prev.priscalc,sntr_prev.prischarge) OR histo_calcul_annul.montant <>0) --hors franchise 
    AND histo_calcul.idcalcul = histo_calcul_annul.idcalcul
    AND histo_calcul.creation <= histo_calcul_annul.datannul   -- ne prendre que les lignes annulées et non recalculées (régularisation)
) ADS
WHERE ads.datope > add_months( trunc(sysdate, 'Y'), -36 )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRDG_ADS FOR ARTHUS.V_PRDG_ADS
