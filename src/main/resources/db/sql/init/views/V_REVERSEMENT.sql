CREATE FORCE VIEW ARTHUS.V_REVERSEMENT AS
select	grnts.refcie,
    grnts_ref.refcie refcie_ref,
	grnts.numgar,
	grnts.numgar_ref,
	grnts.numinterm numsoc,
	f_assureur( qttc_affec.numfor ) numorg,
	grnts.cellule,
	grnts.numutil,
	grnts.refcie_chapeau,
	indvs.nom||' '||indvs.prenom nomcli,
	grnts.numcli numcli,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.numeche,
	to_char(qttc_global.debut,'yyyy') exercice,
	qttc_global.numquit,
	gar_cntrt.nomgar,
	gar_cntrt.nomgar ||' - '||gar_cntrt.libelle libgar,
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
	grnts.typequit,
	v_branche.branche,
	qttc_global.idadhesion,
	adhe_cntrt.ref_ext
from	contrat		grnts,
	indvs,
	qttc_global,
	gar_cntrt,
	qttc_affec,
	compte_client,
	v_branche,
	contrat_ref grnts_ref,
	adhe_cntrt
where	grnts.numgar 		= qttc_global.numgar
and	indvs.numindiv 	    	= grnts.numcli
and	qttc_global.numquit 	= qttc_affec.numquit
and	gar_cntrt.numfor 	= qttc_affec.numfor
and	v_branche.numfor(+)	= gar_cntrt.numfor_ref
and	qttc_affec.idaffec 	= compte_client.idaffec
and	compte_client.codope + 0 = 4
and grnts_ref.numgar = grnts.numgar_ref
and qttc_global.idadhesion = adhe_cntrt.idadhesion (+)
Group by
	qttc_affec.idrevers,
	qttc_affec.idaffec,
	qttc_global.numquit,
	grnts.refcie,
	grnts_ref.refcie,
	grnts.numgar,
	grnts.numgar_ref,
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
	compte_client.datope,
	v_branche.branche,
	qttc_global.idadhesion,
	adhe_cntrt.ref_ext
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REVERSEMENT FOR ARTHUS.V_REVERSEMENT
