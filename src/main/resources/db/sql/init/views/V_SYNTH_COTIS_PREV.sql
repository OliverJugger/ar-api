CREATE FORCE VIEW ARTHUS.V_SYNTH_COTIS_PREV AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numinterm numsoc,
	gar.numass numorg,
	nvl(grnts.refcie_chapeau,'N') refcie_chapeau,
	grnts.numcli numcli,
	to_char(qttc_global.debut,'yyyy') exercice,
	qttc_global.debut,
	gar.nomgar,
	' * '||rpad(gar.nomgar,8, ' ') ||' - '||
	translate(gar.libelle,'.','@') libgar,
	qttc_affec.numfor,
	qttc_affec.montant - ARTHUS.pk_cotis.comm_prelev(	qttc_global.numquit,
							qttc_affec.idrevers,
							qttc_affec.idaffec,
							qttc_affec.numfor,
							1,
							2)
				montant,
	compte_client.datope dataffec
from	grnts,
	compte_client,
	gar,
	qttc_affec,
	qttc_global
Where	grnts.numgar 		= 	qttc_global.numgar
and	qttc_affec.idrevers	!= 	0
and	qttc_global.numquit 	= 	qttc_affec.numquit
and	gar.numfor 		= 	qttc_affec.numfor
and	qttc_affec.idaffec 	= 	compte_client.idaffec
and	compte_client.codope 	= 	4
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SYNTH_COTIS_PREV FOR ARTHUS.V_SYNTH_COTIS_PREV
