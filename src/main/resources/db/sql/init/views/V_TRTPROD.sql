CREATE FORCE VIEW ARTHUS.V_TRTPROD AS
SELECT pro.numprod    numprod
  ,      1              numero
  ,      trp.numtr      numtr
  ,      trt.libinttr   libinttr
  ,      trt.numreass   numreass
  FROM   produit pro
  ,      trt_produit trp
  ,      traite trt
  WHERE  pro.numprod = trp.numprod
         and
         trt.numtr = trp.numtr
  UNION
  SELECT 0          numprod
  ,      2          numero
  ,      numtr      numtr
  ,      libinttr   libinttr
  ,      numreass   numreass
  FROM   traite
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRTPROD FOR ARTHUS.V_TRTPROD
