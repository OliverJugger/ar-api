CREATE FORCE VIEW ARTHUS.V_QTTC_FRAIS AS
select	NUMQUIT,
	NUMFOR,
	TYPE_FRAIS,
	NUMBENE,
	sum(MONTANT) montant,
	sum(MONTANT_D)montant_D,
	f_mt_affec_tfc(numquit, numfor, 3, type_frais) +
	f_mt_affec_tfc(numquit, numfor, 4, type_frais) mt_affec,
	f_mt_affec_tfc_D(numquit, numfor, 3, type_frais) +
	f_mt_affec_tfc_D(numquit, numfor, 4, type_frais) mt_affec_D,
	monnaie,
	monnaie_D
from	qttc_frais
group
by	numquit,numfor,type_frais,numbene, monnaie, monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_FRAIS FOR ARTHUS.V_QTTC_FRAIS
