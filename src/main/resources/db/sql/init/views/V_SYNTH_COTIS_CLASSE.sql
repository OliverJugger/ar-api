CREATE FORCE VIEW ARTHUS.V_SYNTH_COTIS_CLASSE AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numinterm numsoc,
	f_assureur(qttc_affec.numfor) numorg,
	nvl(grnts.refcie_chapeau,'N') refcie_chapeau,
	grnts.numcli numcli,
	to_char(qttc_global.debut,'yyyy') exercice,
	qttc_global.debut,
	gar_cntrt.nomgar,
	' * '||rpad(gar_cntrt.nomgar,8, ' ') ||' - '||
	translate(gar_cntrt.libelle,'.','@') libgar,
	qttc_affec.numfor,
	qttc_affec.montant - ARTHUS.pk_cotis.comm_prelev(	qttc_global.numquit,
							qttc_affec.idrevers,
							qttc_affec.idaffec,
							qttc_affec.numfor,
							1,
							2)
				montant,
	compte_client.datope dataffec,
	qttc_affec.idrevers numero,
	v_branche.branche
from	grnts,
	qttc_global,
	gar_cntrt,
	v_branche,
	qttc_affec,
	compte_client
Where	grnts.numgar 		= 	qttc_global.numgar
and	qttc_affec.idrevers	!= 	0
and	qttc_global.numquit 	= 	qttc_affec.numquit
and	v_branche.numfor	=	qttc_affec.numfor
and	gar_cntrt.numfor	=	qttc_affec.numfor
and	qttc_affec.idaffec 	= 	compte_client.idaffec
and	compte_client.codope + 0 =4
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SYNTH_COTIS_CLASSE FOR ARTHUS.V_SYNTH_COTIS_CLASSE
