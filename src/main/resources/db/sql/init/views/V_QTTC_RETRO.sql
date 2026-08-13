CREATE FORCE VIEW ARTHUS.V_QTTC_RETRO AS
select	NUMQUIT,
	NUMFOR,
	TYPE_COMM,
	sum(MONTANT) montant,
	f_mt_affec_tfc(numquit, numfor, 5, type_comm) mt_affec,
	sum(MONTANT_d) montant_d,
	f_mt_affec_tfc_d(numquit, numfor, 5, type_comm) mt_affec_d,
	monnaie,
	monnaie_D
from	qttc_retro
group by
	numquit,
	numfor,
	type_comm,
	monnaie,
	monnaie_D
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_RETRO FOR ARTHUS.V_QTTC_RETRO
