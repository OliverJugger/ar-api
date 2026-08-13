CREATE FORCE VIEW ARTHUS.V_PORTE_ADHESION_2110 AS
select	distinct(numindiv)
from	porte_adhesion,
		adhe_cntrt
where	porte_adhesion.idadhesion=adhe_cntrt.idadhesion
and		adhe_cntrt.numgar=2110
and 	porte_adhesion.numporte=1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PORTE_ADHESION_2110 FOR ARTHUS.V_PORTE_ADHESION_2110
