CREATE FORCE VIEW ARTHUS.V_AFFEC_DETAIL AS
select
	facture.codope,
	facture.numfact,
	facture.numcli,
	facture.montant,
	facture.monnaie,
	facture.datfact,
	to_char(facture.datfact,'dd/mm/yy') edatfact,
	compte_client.numencaismt,
	compte_client.montant mt_affec,
	'Police '||qttc_global.numgar||' Ech. '||to_char(qttc_global.debut,'dd/mm/yy') libelle,
	'qg03' codapli
from	facture,
	compte_client,
	qttc_global,
	indvs
where	compte_client.codope = 4
and	compte_client.codope(+) = facture.codope
and	compte_client.numfact(+) = facture.numfact
and	qttc_global.numquit(+) = facture.numfact
and	indvs.numindiv = compte_client.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFEC_DETAIL FOR ARTHUS.V_AFFEC_DETAIL
