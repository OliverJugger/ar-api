CREATE FORCE VIEW ARTHUS.V_REVERSEMENT_CONTRAT AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numinterm numsoc,
	f_assureur( qttc_affec.numfor ) numorg,
	grnts.cellule,
	grnts.numutil,
	grnts.refcie_chapeau,
	indvs.nom||' '||indvs.prenom nomcli,
	grnts.numcli,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.numeche,
	to_char(qttc_global.debut,'yyyy') exercice,
	qttc_global.numquit,
	gar_cntrt.nomgar,
	' * '||rpad(gar_cntrt.nomgar,8, ' ') ||' - '||
	translate(gar_cntrt.libelle,'.','@') libgar,
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
        grnts.nat_calc,
	grnts.typequit
from	contrat		grnts,
	indvs,
	qttc_global,
	gar_cntrt,
	qttc_affec,
	compte_client
where	grnts.numgar 		= qttc_global.numgar
and	indvs.numindiv 		= grnts.numcli
and	qttc_global.numquit 	= qttc_affec.numquit
and	gar_cntrt.numfor 	= qttc_affec.numfor
and	qttc_affec.idaffec 	= compte_client.idaffec
and	compte_client.codope + 0 = 4
Group by
	qttc_affec.idrevers,
	qttc_affec.idaffec,
	qttc_global.numquit,
	grnts.refcie,
	grnts.numgar,
	grnts.numinterm,
	f_assureur( qttc_affec.numfor ),
	grnts.cellule,
	grnts.numutil,
	grnts.refcie_chapeau,
        grnts.nat_calc,
        grnts.typequit,
	indvs.nom,
	indvs.prenom,
	grnts.numcli,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.numeche,
	qttc_affec.numfor,
	to_char(qttc_global.debut,'yyyy'),
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	compte_client.datope
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REVERSEMENT_CONTRAT FOR ARTHUS.V_REVERSEMENT_CONTRAT
