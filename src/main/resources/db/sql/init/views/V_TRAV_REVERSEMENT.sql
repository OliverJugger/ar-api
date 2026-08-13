CREATE FORCE VIEW ARTHUS.V_TRAV_REVERSEMENT AS
select	qttc_affec.idrevers,
	grnts.numinterm 		numsoc,
	v_assur_revers.numass numorg,
	grnts.refcie_chapeau,
	grnts.numgar,
	qttc_affec.numquit,
	qttc_global.debut,
	qttc_global.fin,
	qttc_affec.numfor,
	qttc_affec.idaffec,
	compte_client.datope dataffec,
        grnts.nat_calc,
	sum(qttc_affec.montant) - ARTHUS.pk_cotis.comm_prelev(	qttc_affec.numquit,
							qttc_affec.idrevers,
							qttc_affec.idaffec,
							qttc_affec.numfor,
							1,
							2)
				montant,
	qttc_affec.monnaie,
	sum(qttc_affec.montant_d) - ARTHUS.pk_cotis.comm_prelev_d(	qttc_affec.numquit,
							qttc_affec.idrevers,
							qttc_affec.idaffec,
							qttc_affec.numfor,
							1,
							2)
				montant_d,
	qttc_affec.monnaie_d
from	contrat		grnts,
	qttc_global,
	qttc_affec,
	compte_client,
	v_assur_revers
where	grnts.numgar 		= qttc_global.numgar
and	qttc_global.numquit 	= qttc_affec.numquit
and	qttc_affec.idaffec 	= compte_client.idaffec
and	qttc_affec.numfor 	!= 0
and	qttc_affec.numfor	= v_assur_revers.numfor
and	compte_client.codope + 0 = 4
Group by
	grnts.numinterm,
	v_assur_revers.numass,
	grnts.refcie_chapeau,
	grnts.numgar,
	qttc_affec.numquit,
	qttc_affec.idaffec,
	qttc_affec.numfor,
	qttc_affec.idrevers,
        grnts.nat_calc,
	qttc_global.debut,
	qttc_global.fin,
	compte_client.datope,
	qttc_affec.monnaie,
	qttc_affec.monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRAV_REVERSEMENT FOR ARTHUS.V_TRAV_REVERSEMENT
