CREATE FORCE VIEW ARTHUS.V_PRIMES_GROUPE AS
select	grnts.numinterm numsoc,
	societe.nom nom_soc,
	grnts.numgar,
	grnts.refcie,
	nvl(grnts.refcie_chapeau,'N') refcie_chapeau,
	qttc_global.numquit,
	grnts.numcli,
	indvs.nom||' '||indvs.prenom nom_cli,
	emission.datemis,
	to_char(emission.datemis,'dd/mm/yyyy') edatemis,
	qttc_global.debut,
	qttc_global.nat_calc,
	to_char(qttc_global.debut,'dd/mm/yyyy') edebut,
	nvl(facture.montant,1) mt_fact,
	nvl(f_totaffec(facture.numfact,4),0) mt_affec
from	societe,
	indvs,
	grnts,
	emission,
	facture,
	qttc_global
where	societe.numsoc		= grnts.numinterm
and	indvs.numindiv		= grnts.numcli
and	grnts.typequit		= 1
and	qttc_global.numgar	= grnts.numgar
and	qttc_global.type_qttc	!=3
and	qttc_global.comptant	!='R'
and	emission.numfact	= facture.numfact
and	emission.codope		= facture.codope
and	emission.numrelance	= 0
and	facture.codope		= 4
and	facture.numfact		= qttc_global.numquit
and	ARTHUS.pk_histo_contrat.f_sel_etat(grnts.numgar,qttc_global.debut)=1
and Not Exists (
	Select	1
	From	emission
	Where	emission.codope = 4
	and	emission.numfact = qttc_global.numquit
	and	emission.numrelance IN (4, 99) )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRIMES_GROUPE FOR ARTHUS.V_PRIMES_GROUPE
