CREATE FORCE VIEW ARTHUS.V_TRAV_RETROCESSION AS
Select	qttc_affec_tfc.idrevers,
	qttc_affec_tfc.idaffec,
	contrat.numinterm		numsoc,
	qttc_affec_tfc.numbene		numindiv,
	contrat.refcie_chapeau		regroupement,
	contrat.numgar,
	decode (qttc_global.idadhesion,0,1,2) typgar,
	compte_client.datope		dataffec,
	qttc_global.debut		echeance,
	qttc_affec_tfc.type_tfc,
	qttc_affec_tfc.prelev_revers,
	qttc_affec_tfc.montant,
	qttc_affec_tfc.montant_d,
	qttc_affec_tfc.monnaie,
	qttc_affec_tfc.monnaie_d
From	contrat,
	qttc_global,
	qttc_affec_tfc,
	compte_client
Where	contrat.numgar = qttc_global.numgar
and	qttc_global.numquit = qttc_affec_tfc.numquit
and	compte_client.idaffec = qttc_affec_tfc.idaffec
and	compte_client.codope + 0 = 4
and	qttc_affec_tfc.tfc = 5
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRAV_RETROCESSION FOR ARTHUS.V_TRAV_RETROCESSION
