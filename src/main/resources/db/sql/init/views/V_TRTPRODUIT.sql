CREATE FORCE VIEW ARTHUS.V_TRTPRODUIT AS
SELECT  distinct trt_prod.numprod  numprod,
          prod.libelle      libelle
  FROM    trt_produit trt_prod,
          produit prod
  WHERE   trt_prod.numprod = prod.numprod
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRTPRODUIT FOR ARTHUS.V_TRTPRODUIT
