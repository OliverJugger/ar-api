CREATE FORCE VIEW ARTHUS.V_CPTCLI AS
select 	compte_client.idaffec,
	compte_client.codope,
	compte_client.numcli,
	compte_client.numencaismt,
	compte_client.datope,
	compte_client.montant,
	compte_client.montant_d,
	compte_client.monnaie,
	compte_client.monnaie_d,
	compte_client.numfact,
	compte_client.idcompta,
	to_char(compte_client.datope,'DD/MM/YY') edatope,
	indvs.nom,
	encaismt.codope origine,
	'en12' codapli
from 	indvs,
	encaismt,
	compte_client
where 	indvs.numindiv = compte_client.numcli
and	encaismt.numencaismt = compte_client.numencaismt
and	compte_client.codope = 8
and	not exists (
		select	1
		from	rbtcptcli
		where	rbtcptcli.idaffec = compte_client.idaffec)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CPTCLI FOR ARTHUS.V_CPTCLI
