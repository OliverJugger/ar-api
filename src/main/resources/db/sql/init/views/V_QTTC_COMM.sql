CREATE FORCE VIEW ARTHUS.V_QTTC_COMM AS
select	NUMQUIT,
	NUMFOR,
	TYPE_COMM,
	NUMBENE,
	PRELEV_REVERS,
	sum(MONTANT) montant,
	f_mt_affec_tfc(numquit, numfor, 2, type_comm) mt_affec,
	sum(MONTANT_d) montant_d,
	f_mt_affec_tfc_d(numquit, numfor, 2, type_comm) mt_affec_d,
	monnaie,
	monnaie_D
from	qttc_comm
group
by	numquit,numfor,type_comm,numbene,prelev_revers,monnaie,
	monnaie_D
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_COMM FOR ARTHUS.V_QTTC_COMM
