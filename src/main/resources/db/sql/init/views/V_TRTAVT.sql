CREATE FORCE VIEW ARTHUS.V_TRTAVT AS
SELECT tr.numtr       numtr
  ,      tr.libinttr    libinttr
  ,      tr.datefftr    datefftr
  ,      tr.datfintr    datfintr
  ,      tr.numreass    numreass
  ,      ind.nom        nomreass
  ,      av.numav       numav
  ,      av.numero      numero
  ,      av.libintav    libintav
  ,      av.dateffav    dateffav
  ,      av.datfinav    datfinav
  ,      av.avenant0    avenant0
  FROM   traite tr
  ,      avenant av
  ,      individu ind
  WHERE  av.numtr = tr.numtr
         AND
         av.valideav = 'O'
         AND
         ind.numindiv = tr.numreass
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRTAVT FOR ARTHUS.V_TRTAVT
