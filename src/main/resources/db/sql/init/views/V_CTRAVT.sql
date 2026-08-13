CREATE FORCE VIEW ARTHUS.V_CTRAVT AS
SELECT 	distinct
       	contrat.numgar       	numgar
,      	contrat.refcie       	refcie
,      	avenant.numav         	numav
,      	avenant.libintav      	libintav
,      	avenant.dateffav      	dateffav
,      	avenant.datfinav      	datfinav
,      	avenant.numtr         	numtr
,      	avenant.valideav      	valideav
,      	cntrt_trait.debut 	datedeb
,      	cntrt_trait.fin      	datefin
,      	cntrt_trait.valide      valide
FROM   	contrat
,      	cntrt_trait
,      	avenant
WHERE  	contrat.numgar = cntrt_trait.numgar
AND 	avenant.numav = cntrt_trait.numav
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CTRAVT FOR ARTHUS.V_CTRAVT
