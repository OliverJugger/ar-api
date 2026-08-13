CREATE FORCE VIEW ARTHUS.V_PRIMES_INDIV AS
select	grnts.numinterm numsoc,
	societe.nom nom_soc,
	grnts.numgar,
	grnts.refcie,
	nvl(grnts.refcie_chapeau,'N') refcie_chapeau,
	qttc_global.numquit,
	adhe_cntrt.numadhe,
	indvs.nom||' '||indvs.prenom nom_adhe,
	emission.datemis,
	to_char(emission.datemis,'dd/mm/yyyy') edatemis,
	qttc_global.debut,
	to_char(qttc_global.debut,'dd/mm/yyyy') edebut,
	nvl(facture.montant,0) mt_fact,
	nvl(f_totaffec(facture.numfact,4),0) mt_affec,
	adhe_cntrt.idadhesion,
	adhe_cntrt.ref_ext
from	societe,
	indvs,
	adhe_cntrt,
	grnts,
	emission,
	facture,
	qttc_global
where	societe.numsoc		= grnts.numinterm
and	grnts.numgar		= adhe_cntrt.numgar
and	indvs.numindiv		= adhe_cntrt.numadhe
and	nvl(adhe_cntrt.date_fin_adhe,qttc_global.debut+1)>qttc_global.debut
and	emission.codope		= facture.codope
and	emission.numfact	= facture.numfact
and	emission.numrelance	= 0
and	qttc_global.idadhesion	= adhe_cntrt.idadhesion
and	qttc_global.type_qttc	!=3
and	qttc_global.comptant	!='R'
and	facture.codope		= 4
and	facture.numfact		= qttc_global.numquit
and Not Exists (
	Select	1
	From	emission
	Where	emission.codope = 4
	and	emission.numfact = qttc_global.numquit
	and	emission.numrelance IN (4, 99) )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRIMES_INDIV FOR ARTHUS.V_PRIMES_INDIV
