CREATE FORCE VIEW ARTHUS.V_BENE_JUSTIF_SIN_R AS
SELECT DISTINCT TO_NUMBER(r.nosin) NoSin,
    rb.numbene_dest NumIndiv,
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
  AND NOT EXISTS (SELECT 1 FROM CORRESPONDANT c
                            WHERE c.contexte      = 15
                              AND c.entite        = r.nosin
                              AND c.numcorres     IS NOT NULL
                              AND c.numcorres     = rb.numbene_dest
                 )
  UNION
  SELECT DISTINCT TO_NUMBER(s.nosin),
    c.numcorres,
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
CREATE OR REPLACE PUBLIC SYNONYM V_BENE_JUSTIF_SIN_R FOR ARTHUS.V_BENE_JUSTIF_SIN_R
