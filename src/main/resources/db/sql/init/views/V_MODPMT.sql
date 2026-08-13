CREATE FORCE VIEW ARTHUS.V_MODPMT AS
Select distinct
		papier_ope.codope,
		papier_ope.modpmt,
		compte.numsoc
From	papier_ope,
	compte
Where	papier_ope.numcpte=compte.numcpte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_MODPMT FOR ARTHUS.V_MODPMT
