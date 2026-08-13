CREATE FORCE VIEW ARTHUS.V_CPTCLI_EXT AS
select	compte_client.IDAFFEC,
	compte_client.CODOPE,
	compte_client.NUMCLI,
	compte_client.NUMENCAISMT,
	compte_client.MONNAIE,
	compte_client.DATOPE,
	compte_client.MONTANT,
	compte_client.NUMFACT,
	compte_client.IDCOMPTA
from	compte_client
where not exists (select 1
		from	rbtcptcli
		where rbtcptcli.idaffec = compte_client.idaffec)
union
select	0,
	affectation.codope,
	decaismt.numbene,
	affectation.numdecaismt,
	decaismt.monnaie,
	decaismt.datpay,
	decaismt.montant,
	affectation.numaffec,
	0
from	affectation,
	decaismt
where	affectation.numdecaismt = decaismt.numdecaismt
and	decaismt.refpmt is not null
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CPTCLI_EXT FOR ARTHUS.V_CPTCLI_EXT
