CREATE FORCE VIEW ARTHUS.V_TRTCTR AS
SELECT distinct
         tr.numtr    numtr
  ,      tr.libinttr libinttr
  ,      tr.typtr    typtr
  ,      tr.datefftr datefftr
  ,      tr.datfintr datfintr
  ,      tr.numreass numreass
  ,      ind.nom     nomreass
  ,      cntr.numgar numgar
  FROM   traite tr
  ,      cntrt_trait cntr
  ,      individu ind
  WHERE  tr.numtr = cntr.numtr
         AND
         ind.numindiv = tr.numreass
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRTCTR FOR ARTHUS.V_TRTCTR
