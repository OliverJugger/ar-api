CREATE FORCE VIEW ARTHUS.V_PIECE_CONTRAT AS
select	affectation.codope	codope,
	affectation.numaffec	numpiece,
	dcpt.numgar		numgar,
	contrat.numinterm	numsoc
from	affectation,
	dcpt,
	contrat
where	affectation.codope=1
and	dcpt.numdec	= affectation.numaffec
and	dcpt.numgar	= contrat.numgar
union
select	affectation.codope	codope,
	affectation.numaffec	numpiece,
	adhe_cntrt.numgar		numgar	,
	contrat.numinterm	numsoc
from	affectation,
	decompte_prev,
	adhe_cntrt,
	contrat
where	affectation.codope=2
and	decompte_prev.numdec	= affectation.numaffec
and	decompte_prev.idadhesion=adhe_cntrt.idadhesion
and	adhe_cntrt.numgar	= contrat.numgar
union
select	facture.codope		codope,
	facture.numfact		numpiece,
	qttc_global.numgar	numgar,
	contrat.numinterm	numsoc
from	facture,
	qttc_global,
	contrat
where	facture.codope=4
and	qttc_global.numquit	= facture.numfact
and	qttc_global.numgar	= contrat.numgar
union
select	affectation.codope,
	affectation.numaffec,
	0,
	0
from	affectation
where	affectation.codope not in (1,2)
union
select	facture.codope,
	facture.numfact,
	0,
	0
from	facture
where	facture.codope not in (4)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PIECE_CONTRAT FOR ARTHUS.V_PIECE_CONTRAT
