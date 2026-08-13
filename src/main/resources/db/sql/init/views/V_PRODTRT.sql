CREATE FORCE VIEW ARTHUS.V_PRODTRT AS
SELECT pro.numprod    numprod
  ,      pro.libelle    libelle
  ,      pro.numass     numass
  ,      1              numero
  ,      trp.numtr      numtr
  FROM   produit pro
  ,      trt_produit trp
  WHERE  pro.numprod = trp.numprod
  UNION
  SELECT numprod    numprod
  ,      libelle    libelle
  ,      numass     numass
  ,      2          numero
  ,      0          numtr
  FROM   produit
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRODTRT FOR ARTHUS.V_PRODTRT
