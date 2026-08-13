CREATE FORCE VIEW ARTHUS.V_COMM_RATIO AS
select	qttc_comm.numquit,
	qttc_comm.numfor,
	qttc_comm.numindiv,
	qttc_comm.montant,
	trunc(qttc_comm.montant*trunc(qttc_affec.montant/qttc_gar.mt_ttc,2),2) mt_affec
from	qttc_comm,
	qttc_affec,
	qttc_gar
where	qttc_comm.numquit = qttc_affec.numquit
and	qttc_comm.numfor = qttc_affec.numfor
and	qttc_comm.numindiv = qttc_affec.numindiv
and	qttc_gar.idgar = qttc_affec.idgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMM_RATIO FOR ARTHUS.V_COMM_RATIO
