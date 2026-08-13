CREATE FORCE VIEW ARTHUS.V_RETRO_BASE AS
Select	Contrat.refcie			ref_externe,
	Contrat.refcie_chapeau		regroupement,
	Qttc_global.numgar,
	Qttc_affec_tfc.numbene,
	Qttc_affec_tfc.idrevers,
	Qttc_affec_tfc.prelev_revers,
	Qttc_affec_tfc.type_tfc
From	contrat,
	qttc_global,
	qttc_affec_tfc
Where	contrat.numgar = qttc_global.numgar
And	qttc_global.numquit = qttc_affec_tfc.numquit
And	qttc_affec_tfc.tfc = 5
Group By
	Contrat.refcie_chapeau,
	Contrat.refcie,
	Qttc_global.numgar,
	Qttc_affec_tfc.numbene,
	Qttc_affec_tfc.idrevers,
	Qttc_affec_tfc.prelev_revers,
	Qttc_affec_tfc.type_tfc
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RETRO_BASE FOR ARTHUS.V_RETRO_BASE
