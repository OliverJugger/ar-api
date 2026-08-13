CREATE FORCE VIEW ARTHUS.V_PRDG_DCS AS
SELECT DCS."GD_RISQUE",DCS."MONTANT",DCS."PR",DCS."CLE1",DCS."CLE2",DCS."CLE3",DCS."CLE4",DCS."CLE5",DCS."CLE6",DCS."CLE7",DCS."CLE8",DCS."CLE9",DCS."CLE10",DCS."DATOPE",DCS."NUMINDIV_DG",DCS."DECOMPTE",DCS."ASS_GARANTIE",DCS."GARANTIE",DCS."MONNAIE",DCS."NUMDECAISMT",DCS."NUMPNUL",DCS."NUMSIN" from
(
-- SANTE
-- Select 1
  SELECT
      '02'                                GD_RISQUE
     ,sinistre.mtreel                       MONTANT
     ,v_assur_delegat.numass                     PR
     ,TO_CHAR(vs_grnts.numgar)                 CLE1
     ,TO_CHAR(sinistre.datsin,'YYYY')          CLE2
     ,'02'                                     CLE3
     ,'022'                                    CLE4
     ,'SA'                                     CLE5
     ,'1'                                      CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(sinistre.monnaie),1) CLE7
     ,'NV'                                     CLE8
     ,'NV'                                     CLE9
     ,'NV'                                    CLE10
     ,TRUNC(decaismt_prest.datpay)           DATOPE
     ,vs_grnts.numinterm                numindiv_dg
     ,dcpt.numdec                          decompte
     ,v_assur_delegat.numass           ass_garantie
     ,v_assur_delegat.numfor               garantie
     ,sinistre.monnaie                      monnaie
     ,TO_CHAR(decaismt_prest.numdecaismt) numdecaismt
     ,'NV'                                  numpnul
     ,sinistre.numsin                        numsin
FROM        dcpt,
      decaismt  decaismt_prest,
      affectation  affectation_prest,
            vs_grnts,
            sinistre,
            v_assur_delegat
  where  dcpt.numgar  = vs_grnts.numgar
  and    dcpt.numdec = affectation_prest.numaffec
  and    affectation_prest.codope   = 1
  and    decaismt_prest.numdecaismt   = affectation_prest.numdecaismt
  and    decaismt_prest.codope     = 1
  and    decaismt_prest.flagpay+0  = 1
  and   sinistre.NUMDEC   = dcpt.numdec
  and   sinistre.numfor   = v_assur_delegat.numfor
UNION all
-- SANTE
-- Select 2
-- Annulations
  SELECT
      '02'                                GD_RISQUE
     ,-sinistre.mtreel                      MONTANT
     ,v_assur_delegat.numass                     PR
     ,TO_CHAR(vs_grnts.numgar)                 CLE1
     ,TO_CHAR(sinistre.datsin,'YYYY')          CLE2
     ,'02'                                     CLE3
     ,'022'                                    CLE4
     ,'SA'                                     CLE5
     ,'1'                                      CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(sinistre.monnaie),1) CLE7
     ,'NV'                                     CLE8
     ,'NV'                                     CLE9
     ,'NV'                                    CLE10
     ,TRUNC(pnul.datannul)                   DATOPE
     ,vs_grnts.numinterm                numindiv_dg
     ,dcpt.numdec                          decompte
     ,v_assur_delegat.numass           ass_garantie
     ,v_assur_delegat.numfor               garantie
     ,sinistre.monnaie                      monnaie
     ,'NV'                              numdecaismt
     ,TO_CHAR(decaismt_prest.numdecaismt)   numpnul
     ,sinistre.numsin                        numsin
  FROM  v_decompte_cpta    dcpt,
      decaismt                decaismt_prest,
      pnul,
      affectation_annul    affectation_prest,
                vs_grnts,
      v_sinistre_cpta2      sinistre,
                v_assur_delegat
  where  dcpt.numgar    = vs_grnts.numgar
  and    dcpt.numdec     = affectation_prest.numaffec
  and    affectation_prest.codope   = 1
  and    decaismt_prest.numdecaismt   = affectation_prest.numdecaismt
  and    pnul.numdecaismt   = affectation_prest.numdecaismt
  and    decaismt_prest.codope     = 1
  and    pnul.codope     = 1
  and    decaismt_prest.flagpay+0  = 1
  and   sinistre.NUMDEC   = dcpt.numdec
  and   sinistre.numfor   = v_assur_delegat.numfor
UNION all
-- SANTE
-- Select 3
-- Annulation concernant les décaissements désaffectés
  SELECT
      '02'                                GD_RISQUE
     ,sinistre.mtreel                       MONTANT
     ,v_assur_delegat.numass                     PR
     ,TO_CHAR(vs_grnts.numgar)                 CLE1
     ,TO_CHAR(sinistre.datsin,'YYYY')          CLE2
     ,'02'                                     CLE3
     ,'022'                                    CLE4
     ,'SA'                                     CLE5
     ,'1'                                      CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(sinistre.monnaie),1) CLE7
     ,'NV'                                     CLE8
     ,'NV'                                     CLE9
     ,'NV'                                    CLE10
     ,TRUNC(decaismt_prest.datpay)           DATOPE
     ,vs_grnts.numinterm                numindiv_dg
     ,dcpt.numdec                          decompte
     ,v_assur_delegat.numass           ass_garantie
     ,v_assur_delegat.numfor               garantie
     ,sinistre.monnaie                      monnaie
     ,'NV'                              numdecaismt
     ,TO_CHAR(decaismt_prest.numdecaismt)   numpnul
     ,sinistre.numsin                        numsin
  FROM  v_decompte_cpta     dcpt,
      decaismt        decaismt_prest,
      affectation_annul  affectation_prest,
      pnul,
      vs_grnts,
      v_sinistre_cpta2 sinistre,
      v_assur_delegat
  where  dcpt.numgar    = vs_grnts.numgar
  and    dcpt.numdec     = affectation_prest.numaffec
  and    affectation_prest.codope   = 1
  and    decaismt_prest.numdecaismt   = affectation_prest.numdecaismt
  and    decaismt_prest.codope     = 1
  and    decaismt_prest.flagpay+0  = 1
  and   sinistre.NUMDEC   = dcpt.numdec
  and   pnul.numdecaismt = decaismt_prest.numdecaismt
  and    pnul.codope     = 1
  and   sinistre.numfor   = v_assur_delegat.numfor
UNION all
-- SANTE
-- Select 4
-- Indus de prestations
  SELECT
      '02'                                GD_RISQUE
      ,CASE
       WHEN SUM(compte_client.montant) > 0 THEN ROUND(sinistre.mtreel*(SUM(compte_client.montant)/dcpt.montant),2)
       ELSE ROUND(-sinistre.mtreel*(SUM(compte_client.montant)/dcpt.montant),2)
      END    MONTANT
     ,v_assur_delegat.numass                     PR
     ,TO_CHAR(vs_grnts.numgar)                 CLE1
     ,TO_CHAR(sinistre.datsin,'YYYY')          CLE2
     ,'02'                                     CLE3
     ,'022'                                    CLE4
     ,'SA'                                     CLE5
     ,'1'                                      CLE6
     ,f_get_transco('PRDG','DEVISE',to_char(sinistre.monnaie),1) CLE7
     ,'NV'                                     CLE8
     ,'NV'                                     CLE9
     ,'NV'                                    CLE10
     ,TRUNC(compte_client.datope)            DATOPE
     ,vs_grnts.numinterm                numindiv_dg
     ,dcpt.numdec                          decompte
     ,v_assur_delegat.numass           ass_garantie
     ,v_assur_delegat.numfor               garantie
     ,sinistre.monnaie                      monnaie
     ,'NV'                              numdecaismt
     ,'NV'                                  numpnul
     ,sinistre.numsin                        numsin
  FROM  dcpt,
        compte_client,
        affectation    affectation_prest,
        vs_grnts,
        sinistre,
        v_assur_delegat
  where  dcpt.numgar  = vs_grnts.numgar
  and    dcpt.numdec     = affectation_prest.numaffec
  and    compte_client.numfact = affectation_prest.numaffec
  and    compte_client.codope = 1
  and    affectation_prest.codope = 1
  and   sinistre.NUMDEC   = dcpt.numdec
  and   sinistre.numfor   = v_assur_delegat.numfor
  group by
  sinistre.mtreel,
  dcpt.montant,
  v_assur_delegat.numass,
  TO_CHAR(vs_grnts.numgar),
  TO_CHAR(sinistre.datsin,'YYYY'),
  f_get_transco('PRDG','DEVISE',to_char(sinistre.monnaie),1),
  TRUNC(compte_client.datope),
  vs_grnts.numinterm,
  dcpt.numdec ,
  v_assur_delegat.numass,
  v_assur_delegat.numfor,
  sinistre.monnaie ,
  sinistre.numsin
/*
UNION all
-- PREVOYANCE
-- Select 1
      SELECT
      '01'                                GD_RISQUE
     ,v_histo_calcul.montant                MONTANT --Pour Gerep : v_histo_calcul.montant_remb_d
     ,f_numorg (gar.numass)                      PR
     ,TO_CHAR(adhe_cntrt.numgar)               CLE1
     ,TO_CHAR(decaismt_prest.datpay,'YYYY')    CLE2 -- FAUX - Il faut prendre la colonne SURVENANCE de la table sntr_prev... liaison via la table REPARTITION - voir vue cmpta 211 chez MCD
     ,'01'                                     CLE3
     ,f_get_transco('PRDG','RISQ',to_char(gar.nat_risq),1) CLE4
     ,f_get_transco('PRDG','CAUS',to_char(sinistre.cause),1) CLE5
     ,to_char(gar.nat_risq)                    CLE6
     ,'EUR'                                    CLE7 -- La devise du montant dans v_histo_calcul n'est pas précisée
     ,'NV'                                     CLE8
     ,'NV'                                     CLE9
     ,'NV'                                    CLE10
     ,decaismt_prest.datpay                  DATOPE
     ,vs_grnts.numinterm                numindiv_dg
     ,decompte_prev.numdec                 decompte
     ,gar.numass                       ass_garantie
     ,v_histo_calcul.numfor                garantie
     ,1                                     monnaie -- Pour Gerep : v_histo_calcul.monnaie_d
     ,TO_CHAR(decaismt_prest.numdecaismt) numdecaismt
     ,'NV'                                  numpnul
     ,0                                      numsin
     FROM gar,
          v_histo_calcul,
          vs_grnts,
          adhe_cntrt,
          decaismt decaismt_prest,
          affectation affectation_prest,
          decompte_prev,
          sntr_prev sinistre
    WHERE  gar.numfor = v_histo_calcul.numfor
      AND v_histo_calcul.numdec = decompte_prev.numdec
      AND vs_grnts.numgar = adhe_cntrt.numgar
      AND adhe_cntrt.idadhesion = decompte_prev.idadhesion
      AND sntr_prev.nosin = v_histo_calcul.nosin
      AND decaismt_prest.flagpay + 0 = 1
      AND decaismt_prest.numdecaismt =
                                     affectation_prest.numdecaismt
      AND affectation_prest.codope = 2
      AND affectation_prest.numaffec = decompte_prev.numdec
UNION ALL
-- PREVOYANCE
-- Select 2
      SELECT
      '01'                                GD_RISQUE
     ,-v_histo_calcul.montant               MONTANT -- Pour Gerep : -v_histo_calcul.montant_remb_d
     ,f_numorg (gar.numass)                      PR
     ,TO_CHAR(adhe_cntrt.numgar)               CLE1
     ,TO_CHAR(compte_client.datope,'YYYY')     CLE2 -- FAUX - Il faut prendre la colonne SURVENANCE de la table sntr_prev... liaison via la table REPARTITION - voir vue cmpta 211 chez MCD
     ,'01'                                     CLE3
     ,f_get_transco('PRDG','RISQ',to_char(gar.nat_risq),1) CLE4
     ,f_get_transco('PRDG','CAUS',to_char(sinistre.cause),1) CLE5
     ,to_char(gar.nat_risq)                    CLE6
     ,'EUR'                                    CLE7 -- La devise du montant dans v_histo_calcul n'est pas précisée
     ,'NV'                                     CLE8
     ,'NV'                                     CLE9
     ,'NV'                                    CLE10
     ,compte_client.datope                   DATOPE
     ,vs_grnts.numinterm                numindiv_dg
     ,decompte_prev.numdec                 decompte
     ,gar.numass                       ass_garantie
     ,v_histo_calcul.numfor                garantie
     ,1                                     monnaie -- Pour Gerep : v_histo_calcul.monnaie_d
     ,TO_CHAR(affectation_prest.numdecaismt) numdecaismt
     ,'NV'                                  numpnul
     ,0                                      numsin
     FROM decompte_prev,
          compte_client,
          affectation affectation_prest,
          v_histo_calcul,
          gar,
          adhe_cntrt,
          vs_grnts,
          sntr_prev
    WHERE adhe_cntrt.numgar = vs_grnts.numgar
      AND adhe_cntrt.idadhesion = decompte_prev.idadhesion
      AND decompte_prev.numdec = affectation_prest.numaffec
      AND compte_client.numfact = affectation_prest.numaffec
      AND v_histo_calcul.numdec = decompte_prev.numdec
      AND sntr_prev.nosin = v_histo_calcul.nosin
      AND v_histo_calcul.numfor = gar.numfor
      AND compte_client.codope = 2
      AND affectation_prest.codope = 2
*/
) DCS
WHERE dcs.datope > add_months( trunc(sysdate, 'Y'), -36 )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRDG_DCS FOR ARTHUS.V_PRDG_DCS
