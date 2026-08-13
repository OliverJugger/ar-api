CREATE FORCE VIEW ARTHUS.V_QTTC_TAXE AS
select	NUMQUIT,
	NUMFOR,
	TYPE_TAXE,
	NUMBENE,
	sum(MONTANT) montant,
	f_mt_affec_tfc(numquit, numfor, 1, type_taxe) mt_affec,
    sum(MONTANT_d) montant_d,
	f_mt_affec_tfc_d(numquit, numfor, 1, type_taxe) mt_affec_d,
	monnaie,
	monnaie_D
from	qttc_taxe
group
by	numquit,numfor,type_taxe,numbene,monnaie,
	monnaie_D
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_TAXE FOR ARTHUS.V_QTTC_TAXE
