CREATE FORCE VIEW ARTHUS.V_RETRO_COTIS AS
select	qttc_retro.Numquit,
	qttc_retro.Numbene,
	qttc_retro.Type_comm,
	qttc_retro.Prelev_revers,
	Nvl(qttc_affec_tfc.Idrevers, 0)			idrevers,
--	sum(qttc_retro.MONTANT) 			montant,
	ARTHUS.pk_cotis.mt_affec_tfc(
			qttc_retro.numquit,
			Null,
			Null,
			Null,
			qttc_retro.prelev_revers,
			5,
			qttc_retro.type_comm) 	mt_affec
from	qttc_retro,
	qttc_affec_tfc
Where	qttc_affec_tfc.numquit (+) = qttc_retro.numquit
and	qttc_affec_tfc.numbene (+) = qttc_retro.numbene
and	qttc_affec_tfc.type_tfc (+) = qttc_retro.type_comm
and	qttc_affec_tfc.tfc (+) = 5
group by
	qttc_retro.numquit,
	qttc_retro.numbene,
	qttc_retro.type_comm,
	qttc_retro.prelev_revers,
	qttc_affec_tfc.idrevers
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RETRO_COTIS FOR ARTHUS.V_RETRO_COTIS
