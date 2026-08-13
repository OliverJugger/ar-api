CREATE FORCE VIEW ARTHUS.V_BENE_JUSTIF_SIN AS
SELECT DISTINCT TO_NUMBER(r.nosin) NoSin,
    rb.numbene_dest NumIndiv,
    ac.numgar NumGar,
    rb.numbene NumBene,
    r.idadhesion IdAdhesion,
    2 Code,
    'Du : '||D2E(s.datesurv,1)|| ' Type : '|| l.libelle Libelle_Sin,
    16 Type_Bene,
    1 Nat_Corres,
    Null Interlocuteur
  FROM adhe_cntrt ac,
    libelle l,
    SIN s,
    repartition r,
    repartition_bene rb
  WHERE ac.idadhesion  = r.idadhesion
  AND l.mnemo          = 'RISQ'
  AND l.code           = s.norisq
  AND r.nosin          = s.nosin
  AND rb.idrepartition = r.idrepartition
  AND rb.valide        = 'O'
  AND r.valide         = 'O'
  UNION
  SELECT DISTINCT TO_NUMBER(s.nosin),
    c.numcorres,
    0,
    rb.numbene,
    0,
    2 code,
    'Du : '||D2E(s.datesurv,1)|| ' Type : '|| l.libelle libelle_sin,
    15,
    3,
    c.Interlocuteur
  FROM libelle l,
    SIN s,
    CORRESPONDANT c,
    repartition r,
    repartition_bene rb
  WHERE l.mnemo        = 'RISQ'
  AND l.code           = s.norisq
  AND r.nosin          = s.nosin
  AND rb.idrepartition = r.idrepartition
  AND rb.valide        = 'O'
  AND r.valide         = 'O'
  AND c.contexte       = 15
  AND c.entite         = s.nosin
  AND c.nat_corres     = 3
  AND c.numcorres     IS NOT NULL
  UNION
  SELECT DISTINCT TO_NUMBER(s.nosin),
    c.numcorres,
    0,
    rb.numbene,
    0,
    2 code,
    'Du : '||D2E(s.datesurv,1)|| ' Type : '|| l.libelle libelle_sin,
    17,
    1,
    c.Interlocuteur
  FROM libelle l,
    SIN s,
    CORRESPONDANT c,
    repartition r,
    repartition_bene rb
  WHERE l.mnemo        = 'RISQ'
  AND l.code           = s.norisq
  AND r.nosin          = s.nosin
  AND rb.idrepartition = r.idrepartition
  AND rb.valide        = 'O'
  AND r.valide         = 'O'
  AND c.contexte       = 15
  AND c.entite         = s.nosin
  AND c.nat_corres     = 1
  AND c.numcorres     IS NOT NULL
  UNION
  SELECT DISTINCT TO_NUMBER(s.nosin),
    c.numcorres,
    0,
    rb.numbene,
    0,
    2 code,
    'Du : '||D2E(s.datesurv,1)|| ' Type : '|| l.libelle libelle_sin,
    18,
    2,
    c.Interlocuteur
  FROM libelle l,
    SIN s,
    CORRESPONDANT c,
    repartition r,
    repartition_bene rb
  WHERE l.mnemo        = 'RISQ'
  AND l.code           = s.norisq
  AND r.nosin          = s.nosin
  AND rb.idrepartition = r.idrepartition
  AND rb.valide        = 'O'
  AND r.valide         = 'O'
  AND c.contexte       = 15
  AND c.entite         = s.nosin
  AND c.nat_corres     = 2
  AND c.numcorres     IS NOT NULL
  UNION
  SELECT DISTINCT TO_NUMBER(s.nosin),
    c.numcorres,
    0,
    rb.numbene,
    0,
    2 code,
    'Du : '||D2E(s.datesurv,1)|| ' Type : '|| l.libelle libelle_sin,
    15,
    6,
    c.Interlocuteur
  FROM libelle l,
    SIN s,
    CORRESPONDANT c,
    repartition r,
    repartition_bene rb
  WHERE l.mnemo        = 'RISQ'
  AND l.code           = s.norisq
  AND r.nosin          = s.nosin
  AND rb.idrepartition = r.idrepartition
  AND rb.valide        = 'O'
  AND r.valide         = 'O'
  AND c.contexte       = 15
  AND c.entite         = s.nosin
  AND c.nat_corres     = 6
  AND c.numcorres     IS NOT NULL
GO
CREATE OR REPLACE PUBLIC SYNONYM V_BENE_JUSTIF_SIN FOR ARTHUS.V_BENE_JUSTIF_SIN
