CREATE FORCE VIEW ARTHUS.V_FICHE_TO_GEN AS
SELECT   cr.numgar_ref numgar ,
                  cr.numcli,
                  pc.creation date_modif,
                  'Ouverture de porte' modification,
                  SYSDATE date_effet
  FROM porte_contrat pc, contrat_ref cr
  WHERE pc.NUMGAR = cr.NUMGAR_REF
  AND numporte  = 20
  UNION
  --Modification du contrat
  SELECT  CONTRAT_REF.numgar_ref,
                  CONTRAT_REF.numcli,
                  HISTO_CONTRAT_REF.DATE_HISTO date_modif,
                  'Modification sur le contrat' modification,
                  SYSDATE date_effet
  FROM HISTO_CONTRAT_REF, CONTRAT_REF
  WHERE HISTO_CONTRAT_REF.NUMGAR_REF = CONTRAT_REF.NUMGAR_REF
  AND (  HISTO_CONTRAT_REF.REFCIE  <> CONTRAT_REF.REFCIE  -- De la référence assureur portée par le contrat (contrat_ref)
          OR HISTO_CONTRAT_REF.COLLEGE <> CONTRAT_REF.COLLEGE -- Modification du collège
          OR HISTO_CONTRAT_REF.FRACT   <> CONTRAT_REF.FRACT)  -- De la périodicité des cotisations (fractionnement)
  UNION
  --Modification du code option porté par la garantie
  SELECT DISTINCT c.numgar_ref,
                  c.NUMCLI,
                  gh.DATE_HISTO date_modif,
                  'Code option' modification,
                  SYSDATE date_effet
  FROM histo_GAR_PARAM_DETAIL gh, GAR_PARAM_DETAIL g, CONTRAT c, v_GAR_CNTRT gar
  WHERE c.numgar = gar.numgar
   AND gar.numfor = gh.numfor
   AND gh.NUMFOR = g.NUMFOR
  UNION
  -- modification ou ajout d'une ligne de calcul dans FRML_PRIME_SIMPLE
  SELECT  cr.NUMGAR_REF  numgar,
          cr.numcli,
          hfps.DATE_HISTO date_modif,
          'Ajout/modification formule de calcul' modification,
          hfps.debut date_effet
  FROM
    gar_cntrt gc ,
    frml_prime_simple fps,
    histo_frml_prime_simple hfps,
    contrat_ref cr
  WHERE gc.NUMFOR = fps.numfor
    AND cr.numgar = gc.NUMGAR_REF
    AND hfps.NUMFOR = fps.NUMFOR
    AND trunc(fps.debut,'YEAR') <= trunc(sysdate,'YEAR') -- ne pas pendre en compte les modifications sur l'avenir
  -- Ajout ou modification taux cotisation
  UNION
  SELECT cr.NUMGAR_REF numgar,
         cr.numcli,
         v.datecrea date_modif,
         'Ajout/modification taux cotisation' modification,
         v.debut date_effet
  FROM gar_cntrt gc,
       frml_prime_simple fps,
       val_variable v,
       def_variable d,
       contrat_ref cr
  WHERE gc.NUMFOR = fps.numfor
    AND cr.numgar = gc.NUMGAR_REF
    AND v.idvariable = fps.taux
    AND v.idvariable =d.idvariable
    AND v.valide ='O'
    AND v.clef= decode (d.etendue,2,cr.numgar,7,cr.numprod)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FICHE_TO_GEN FOR ARTHUS.V_FICHE_TO_GEN
