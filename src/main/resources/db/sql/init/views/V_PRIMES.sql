CREATE FORCE VIEW ARTHUS.V_PRIMES AS
select
	contrat_ref.numinterm numsoc,
	contrat_ref.numgar,
	contrat_ref.refcie,
	ARTHUS.pk_cotis.f_idcotis (1,qttc_global.numquit)	num_cont_adhe,
	f_code_regroupement(ARTHUS.pk_cotis.f_idcotis (3,qttc_global.numquit),ARTHUS.pk_cotis.f_idcotis (1,qttc_global.numquit),2,1,qttc_global.debut)	Regroupement,
	qttc_global.numquit,
	qttc_global.numquerable	numquerable,
	emission.datemis,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.nat_calc,
	nvl(facture.montant_d,1) mt_fact_d,
	nvl(f_totaffec_d(facture.numfact,4),0) mt_affec_d,
	facture.monnaie_d		devise_d
from	contrat_ref,
	emission,
	facture,
	qttc_global
where	ARTHUS.pk_qttc.f_sel_numgar(qttc_global.numgar)	= contrat_ref.numgar
and	qttc_global.type_qttc	!=3
and	qttc_global.comptant	!='R'
and	emission.numfact		= facture.numfact
and	emission.codope		= facture.codope
and	emission.numrelance	= 0
and	facture.codope		= 4
and	facture.numfact		= qttc_global.numquit
and Not Exists (
	Select	1
	From	emission
	Where	emission.codope = 4
	and	emission.numfact = qttc_global.numquit
	and	emission.numrelance IN (4, 99) )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRIMES FOR ARTHUS.V_PRIMES
