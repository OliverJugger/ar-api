CREATE FORCE VIEW ARTHUS.V_COMM AS
select	sum(
	nvl(qttc_comm.mt_affec,0)
	   )
	col16,
	11 long16,
	qttc_global.numgar,
	facture.datfact
from 	qttc_global,
	facture,
	qttc_comm
where	qttc_comm.numquit=qttc_global.numquit
and qttc_global.comptant!='R'
and qttc_global.type_qttc!=3
and qttc_global.numquit=facture.numfact
and facture.codope=4
group by qttc_global.numgar,facture.datfact
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMM FOR ARTHUS.V_COMM
