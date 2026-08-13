CREATE FORCE VIEW ARTHUS.V_TRTPRODUIT2 AS
SELECT  trt_prod.numtr  numtr,
          trt.libinttr     libinttr,
          trt_prod.numprod numprod
  FROM    trt_produit trt_prod,
          traite trt
  WHERE   trt_prod.numtr = trt.numtr
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRTPRODUIT2 FOR ARTHUS.V_TRTPRODUIT2
