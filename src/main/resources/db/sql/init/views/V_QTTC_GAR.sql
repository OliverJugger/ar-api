CREATE FORCE VIEW ARTHUS.V_QTTC_GAR AS
select		qttc_gar.numquit,
		qttc_gar.numfor,
		sum(qttc_gar.mt_ttc) + f_totfrais_gar(numquit, numfor) mt_ttc,
		sum(qttc_gar.mt_net) mt_net,
		f_mt_affec(qttc_gar.numquit, qttc_gar.numfor) +
		nvl(f_mt_affec_tfc(numquit, numfor, 3), 0) mt_affec,
		sum(qttc_gar.mt_ttc_d) + f_totfrais_gar_d(numquit, numfor) mt_ttc_d,
		sum(qttc_gar.mt_net_d) mt_net_d,
		f_mt_affec_d(qttc_gar.numquit, qttc_gar.numfor) +
		nvl(f_mt_affec_tfc_d(numquit, numfor, 3), 0) mt_affec_d,
		monnaie,
		monnaie_d
from		qttc_gar
group by	qttc_gar.numquit,
		qttc_gar.numfor, qttc_gar.monnaie, qttc_gar.monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_GAR FOR ARTHUS.V_QTTC_GAR
