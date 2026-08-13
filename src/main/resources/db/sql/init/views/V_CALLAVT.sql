CREATE FORCE VIEW ARTHUS.V_CALLAVT AS
SELECT result.idglob			idglob,
 	 result.numtr			numtr,
	 result.numav			numav,
         av.refextav			refextav,
         result.dtdebut			dtdebut,
         result.dtfin			dtfin,
         result.date_calcul		date_calcul,
         result.montant        		montant,
         result.type_calcul		type_calcul     -- ajout 30/04
  FROM	 result_reass result,
         avenant av
  where  result.numav = av.numav
  and	 result.type_calcul in (7,8,9)
  and    result.numav is not null
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CALLAVT FOR ARTHUS.V_CALLAVT
