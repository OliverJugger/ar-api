CREATE FORCE VIEW ARTHUS.V_REVERS_BRANCHE AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numinterm numsoc,
	grnts.numorg,
	grnts.cellule,
	grnts.numutil,
	grnts.refcie_chapeau,
	grnts.numcli,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.numeche,
	to_char(qttc_global.debut,'yyyy') exercice,
	qttc_global.numquit,
	v_branche.branche,
	gar_cntrt.nomgar,
	' * '||rpad(gar_cntrt.nomgar,8, ' ') ||' - '||
	translate(gar_cntrt.libelle,'.','@') libgar,
	qttc_affec.idaffec,
	qttc_affec.numfor,
	qttc_affec.montant - nvl(v_commprelev.montant,0) montant,
	qttc_affec.idrevers,
	compte_client.datope dataffec
from	grnts,
	qttc_global,
	v_branche,
	gar_cntrt,
	qttc_affec,
	v_commprelev,
	compte_client
where	grnts.numgar = qttc_global.numgar
and	qttc_global.numquit = qttc_affec.numquit
and	v_branche.numfor = gar_cntrt.numfor_ref
and	gar_cntrt.numfor = qttc_affec.numfor
and	qttc_affec.idaffec = compte_client.idaffec
and	v_commprelev.idaffec (+) = qttc_affec.idaffec
and	v_commprelev.numquit (+) = qttc_affec.numquit
and	v_commprelev.numfor (+) = qttc_affec.numfor
and	v_commprelev.numindiv (+) = qttc_affec.numindiv
and	compte_client.codope = 4
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REVERS_BRANCHE FOR ARTHUS.V_REVERS_BRANCHE
