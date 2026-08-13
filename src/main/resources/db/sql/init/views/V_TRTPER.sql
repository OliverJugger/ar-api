CREATE FORCE VIEW ARTHUS.V_TRTPER AS
SELECT distinct
         traite.numtr    	numtr
  ,      traite.libinttr 	libinttr
  ,      traite.typtr    	typtr
  ,      traite.datefftr 	datefftr
  ,      traite.datfintr 	datfintr
  ,      cntrt_trait.numgar  	numgar
  ,      cntrt_trait.debut  	datedeb
  ,      cntrt_trait.fin  	datefin
  ,      cntrt_trait.valide  	valide
  FROM   traite
  ,      avenant
  ,      cntrt_trait
  WHERE  traite.numtr = avenant.numtr
  AND 	avenant.numav = cntrt_trait.numav
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRTPER FOR ARTHUS.V_TRTPER
