CREATE FORCE VIEW ARTHUS.V_ST01 AS
SELECT   util.numutil, util.nom, util.pseudo, trunc(sntr.datsai) DATSAI,
            TO_CHAR (trunc(sntr.datsai), 'dd/mm/yy') edatsai,
            COUNT (sntr.numsin) nbsin, COUNT (DISTINCT sntr.numdec) nbdec
       FROM util, sntr
      WHERE util.numutil = sntr.username
   GROUP BY util.numutil, util.nom, util.pseudo, trunc(sntr.datsai)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ST01 FOR ARTHUS.V_ST01
