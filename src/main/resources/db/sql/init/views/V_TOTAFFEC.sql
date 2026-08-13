CREATE FORCE VIEW ARTHUS.V_TOTAFFEC AS
select	codope,
	numfact,
	sum(montant) mt_affec,
	numencaismt
from 	compte_client
where	numencaismt != 0
group by codope, numfact,numencaismt
union
select	codope,
	numfact,
	to_number(''),
	to_number('')
from	facture
where	not exists (
		select	1
		from	compte_client
		where	compte_client.numencaismt != 0
		and	compte_client.codope = facture.codope
		and	compte_client.numfact= facture.numfact)
union
select	codope,
	numaffec,
	to_number(''),
	to_number('')
from	affectation
where	not exists (
		select	1
		from	compte_client
		where	compte_client.numencaismt != 0
		and	compte_client.codope = affectation.codope
		and	compte_client.numfact= affectation.numaffec)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TOTAFFEC FOR ARTHUS.V_TOTAFFEC
