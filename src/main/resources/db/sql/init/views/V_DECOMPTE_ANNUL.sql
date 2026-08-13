CREATE FORCE VIEW ARTHUS.V_DECOMPTE_ANNUL AS
SELECT da.NUMDEC
     , da.DATANNUL
     , da.MONTANT_D
     , da.NUMINDIV
     , da.REFPMT
     , da.MONNAIE
     , da.MONNAIE_D
     , da.MODPMT
     , da.numgar
     , da.datpay
  FROM decompte_annul da
 WHERE da.numdec NOT IN (SELECT numdec FROM decompte)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DECOMPTE_ANNUL FOR ARTHUS.V_DECOMPTE_ANNUL
