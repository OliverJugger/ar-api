CREATE FORCE VIEW ARTHUS.V_CNTRT_TRT_AVT AS
SELECT 	distinct
       	cntrt_trait.numgar 	numgar
,      	cntrt_trait.numtr      	numtr
,      	cntrt_trait.numav       numav
,      	cntrt_trait.valide     	valide
FROM   	cntrt_trait
WHERE  	cntrt_trait.valide = 'O'
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CNTRT_TRT_AVT FOR ARTHUS.V_CNTRT_TRT_AVT
