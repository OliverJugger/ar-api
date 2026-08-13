CREATE FORCE VIEW ARTHUS.V_EXO_COTIS AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numinterm numsoc,
	gar.numass numorg,
	indvs.nom||' '||indvs.prenom nom_assu,
	qttc_global.numquerable numassu,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.numeche,
	to_char(qttc_global.debut,'yyyy') exercice,
	qttc_global.numquit,
	gar.nomgar,
	' * '||rpad(gar.nomgar,8, ' ') ||' - '||
	translate(gar.libelle,'.','@') libgar,
	qttc_affec.idaffec,
	qttc_affec.numfor,
	sum(qttc_affec.montant) - ARTHUS.pk_cotis.comm_prelev(	qttc_global.numquit,
							qttc_affec.idrevers,
							qttc_affec.idaffec,
							qttc_affec.numfor,
							1,
							2)
				montant,
	qttc_affec.idrevers,
	compte_client.datope dataffec,
	qttc_global.idadhesion,
	adhe_cntrt.ref_ext,
	adhe_cntrt.fract,
	grnts.numcli
from	adhe_cntrt,
	grnts,
	gar,
	indvs,
	compte_client,
	qttc_affec,
	qttc_global
where	gar.numfor = qttc_affec.numfor
and	grnts.numgar=adhe_cntrt.numgar
and	grnts.numgar = qttc_global.numgar
and	adhe_cntrt.idadhesion=qttc_global.idadhesion
and	indvs.numindiv = qttc_global.numquerable
and	qttc_global.numquit = qttc_affec.numquit
and	qttc_affec.idaffec = compte_client.idaffec
and	qttc_affec.numfor != 0
and	compte_client.codope+0 = 4
Group By
	grnts.refcie,
	grnts.numgar,
	grnts.numinterm,
	gar.numass,
	indvs.nom||' '||indvs.prenom,
	qttc_global.numquerable,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.numeche,
	qttc_global.numquit,
	gar.nomgar,
	gar.libelle,
	qttc_affec.idaffec,
	qttc_affec.numfor,
	qttc_affec.idrevers,
	compte_client.datope,
	qttc_global.idadhesion,
	adhe_cntrt.ref_ext,
	adhe_cntrt.fract,
	grnts.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EXO_COTIS FOR ARTHUS.V_EXO_COTIS
