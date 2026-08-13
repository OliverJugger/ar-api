CREATE FORCE VIEW ARTHUS.V_PRIMES_DUES AS
select	grnts.numinterm numsoc,
	grnts.numorg,
	grnts.numprod,
	grnts.numgar,
	grnts.cellule,
	grnts.numutil,
	translate(grnts.numgar||' '||grnts.refcie,'.','@') libcont,
	translate(orgns.nom,'.','@') liborg,
	translate(produit.libelle,'.','@') libprod,
	translate(indvs.nom||' '||indvs.prenom,'.','@') libcli,
	qttc_global.numquit,
	qttc_global.numquerable,
	qttc_global.datemis,
	qttc_global.debut,
	facture.montant mt_fact,
	nvl(f_totaffec(facture.numfact,4),0) mt_affec
from	facture,
	qttc_global,
	orgns,
	indvs,
	produit,
	grnts
where	grnts.numgar		= qttc_global.numgar+0
and	grnts.numprod		= produit.numprod
and	grnts.numorg		= orgns.numorg
and	qttc_global.numquerable+0	= indvs.numindiv
and	qttc_global.type_qttc!=3
and	facture.codope		= 4
and	facture.numfact		= qttc_global.numquit
and not exists 	(select 1
		 from 	facture_regul
		 where	facture_regul.codope = facture.codope
		 and	facture_regul.numfact_regul = facture.numfact)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PRIMES_DUES FOR ARTHUS.V_PRIMES_DUES
