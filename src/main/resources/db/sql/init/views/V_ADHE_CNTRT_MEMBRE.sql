CREATE FORCE VIEW ARTHUS.V_ADHE_CNTRT_MEMBRE AS
Select	idadhesion,
	numindiv,
	typadr
From	adhe_cntrt_membre
Union
Select	idadhesion,
	numadhe,
	-1
From	adhe_cntrt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ADHE_CNTRT_MEMBRE FOR ARTHUS.V_ADHE_CNTRT_MEMBRE
