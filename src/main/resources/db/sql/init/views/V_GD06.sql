CREATE FORCE VIEW ARTHUS.V_GD06 AS
SELECT /*+ ALL_ROWS */
          sntr.username gest, f_nomutil (sntr.username) nom_gest, sntr.datsai,
          TO_CHAR (sntr.datsai, 'DD/MM/YY') edatsai, sntr.numassu,
          sntr.numindiv bene,
          ARTHUS.pk_personne.f_nom (sntr.numindiv, 30, 0) nom_bene, sntr.datsin,
          TO_CHAR (sntr.datsin, 'DD/MM/YYYY') edatsin, sntr.codfrais,
          sntr.nbacte, sntr.mtfrais, sntr.mtremb, sntr.mtprest, sntr.mtreel
     FROM sntr
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GD06 FOR ARTHUS.V_GD06
