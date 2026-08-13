CREATE FORCE VIEW ARTHUS.V_TAXES AS
select	sum(
	nvl(qttc_taxe.mt_affec,0)
	   )
	col15,
	11 long15,
	qttc_global.numgar,
	facture.datfact
from 	qttc_global,
	facture,
	qttc_taxe
where	qttc_taxe.numquit=qttc_global.numquit
and qttc_global.comptant!='R'
and qttc_global.type_qttc!=3
and qttc_global.numquit=facture.numfact
and facture.codope=4
group by qttc_global.numgar,facture.datfact
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TAXES FOR ARTHUS.V_TAXES
