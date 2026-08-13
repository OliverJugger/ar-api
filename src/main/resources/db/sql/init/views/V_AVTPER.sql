CREATE FORCE VIEW ARTHUS.V_AVTPER AS
SELECT distinct
         avenant.numtr    	numtr
  ,      avenant.numav    	numav
  ,      avenant.numero    	numero
  ,      avenant.libintav 	libintav
  ,      avenant.typav    	typav
  ,      avenant.dateffav 	dateffav
  ,      avenant.datfinav 	datfinav
  ,      avenant.valideav 	valideav
  ,      cntrt_trait.numgar  	numgar
  ,      cntrt_trait.debut  	datedeb
  ,      cntrt_trait.fin  	datefin
  ,      cntrt_trait.valide  	valide
  FROM   avenant
  ,      cntrt_trait
  WHERE  avenant.numav = cntrt_trait.numav
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AVTPER FOR ARTHUS.V_AVTPER
