CREATE FORCE VIEW ARTHUS.V_REVERSEMENT_TOT AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numcli,
	indvs.nom||' '||indvs.prenom nomcli,
	sum(
	qttc_affec.montant - ARTHUS.pk_cotis.comm_prelev(	qttc_global.numquit,
							qttc_affec.idrevers,
							qttc_affec.idaffec,
							qttc_affec.numfor,
							1,
							2))
				montant,
	reversement.idrevers
from	grnts,
	indvs,
	qttc_global,
	reversement,
	qttc_affec
where	grnts.numgar = qttc_global.numgar
and	indvs.numindiv = grnts.numcli
and	qttc_global.numquit = qttc_affec.numquit
and	reversement.idrevers=qttc_affec.idrevers
Group By
	grnts.refcie,
	grnts.numgar,
	grnts.numcli,
	indvs.nom||' '||indvs.prenom,
	reversement.idrevers
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REVERSEMENT_TOT FOR ARTHUS.V_REVERSEMENT_TOT
