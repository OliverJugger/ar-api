CREATE FORCE VIEW ARTHUS.V_FRMLGAR AS
Select	numfor, nat_calc, nat_risq, code_reass,code_cmcr
	From	formule
	UNION ALL
	Select	numfor, nat_calc, nat_risq, code_reass,code_cmcr
	From	garanties
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FRMLGAR FOR ARTHUS.V_FRMLGAR
