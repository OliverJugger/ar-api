CREATE FORCE VIEW ARTHUS.V_SYNTH_COTIS_ADHE AS
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
	qttc_global.idadhesion,
	adhe_cntrt.numadhe,
	qttc_affec.idrevers numero,
	grnts.nat_calc
from	grnts,
	adhe_cntrt,
	qttc_global,
	gar_cntrt,
	qttc_affec,
	compte_client
Where	grnts.numgar 		= 	adhe_cntrt.numgar
and	grnts.nat_calc		= 	2
And	adhe_cntrt.idadhesion	=	qttc_global.idadhesion
and	qttc_affec.idrevers	!= 	0
and	qttc_global.numquit 	= 	qttc_affec.numquit
and	gar_cntrt.numfor 		= 	qttc_affec.numfor
and	qttc_affec.idaffec 	= 	compte_client.idaffec
Union
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
	qttc_global.idadhesion,
	grnts.numcli numadhe,
	qttc_affec.idrevers numero,
	grnts.nat_calc
from	grnts,
	qttc_global,
	gar_cntrt,
	qttc_affec,
	compte_client
Where	grnts.numgar 		= 	qttc_global.numgar
and	grnts.nat_calc		= 	1
and	qttc_affec.idrevers	!= 	0
and	qttc_global.numquit 	= 	qttc_affec.numquit
and	gar_cntrt.numfor 		= 	qttc_affec.numfor
and	qttc_affec.idaffec 	= 	compte_client.idaffec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SYNTH_COTIS_ADHE FOR ARTHUS.V_SYNTH_COTIS_ADHE
