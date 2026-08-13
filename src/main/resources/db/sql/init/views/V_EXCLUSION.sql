CREATE FORCE VIEW ARTHUS.V_EXCLUSION AS
Select	adhesion.idadhesion,
	adhesion.numfor,
	''			libgar
From	adhesion
Union
Select	adhe_cntrt.idadhesion,
	0			numfor,
	'L''adhésion'		libgar
From	adhe_cntrt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EXCLUSION FOR ARTHUS.V_EXCLUSION
