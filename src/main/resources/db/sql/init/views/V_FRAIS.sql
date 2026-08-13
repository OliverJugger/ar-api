CREATE FORCE VIEW ARTHUS.V_FRAIS AS
select	sum(
	nvl(qttc_frais.mt_affec,0)
	   )
	col14,
	11 long14,
	qttc_global.numgar,
	facture.datfact
from 	qttc_global,
	facture,
	qttc_frais
where	qttc_frais.numquit=qttc_global.numquit
and qttc_global.comptant!='R'
and qttc_global.type_qttc!=3
and qttc_global.numquit=facture.numfact
and facture.codope=4
group by qttc_global.numgar,facture.datfact
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FRAIS FOR ARTHUS.V_FRAIS
