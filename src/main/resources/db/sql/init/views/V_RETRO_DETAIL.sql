CREATE FORCE VIEW ARTHUS.V_RETRO_DETAIL AS
Select	qttc_affec_tfc.idrevers,
	qttc_global.numgar,
	qttc_affec_tfc.type_tfc		type_retro,
	Sum( qttc_affec_tfc.montant )	montant
From	qttc_global,
	qttc_affec_tfc
Where 	qttc_global.numquit = qttc_affec_tfc.numquit
and	qttc_affec_tfc.tfc = 5
Group by
	qttc_affec_tfc.idrevers,
	qttc_global.numgar,
	qttc_affec_tfc.type_tfc
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RETRO_DETAIL FOR ARTHUS.V_RETRO_DETAIL
