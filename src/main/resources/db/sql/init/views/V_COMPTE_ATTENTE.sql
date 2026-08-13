CREATE FORCE VIEW ARTHUS.V_COMPTE_ATTENTE AS
select 	compte_client.idaffec,
	compte_client.codope,
	compte_client.numcli,
	compte_client.numencaismt,
	compte_client.datope,
	compte_client.montant,
	compte_client.monnaie,
	compte_client.montant_d,
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
Union
select 	compte_tiers.idmvt,
	compte_tiers.codope,
	compte_tiers.numcli,
	compte_tiers.cle,
	compte_tiers.datope,
	compte_tiers.montant,
	encaismt.monnaie,
	compte_tiers.montant_d,
	encaismt.monnaie_d,
	to_number(''),
	compte_tiers.idcompta,
	to_char(compte_tiers.datope,'DD/MM/YY') edatope,
	indvs.nom,
	encaismt.codope origine,
	'en12' codapli
from 	indvs,
	encaismt,
	compte_tiers
where 	indvs.numindiv = compte_tiers.numcli
and	encaismt.numencaismt = compte_tiers.cle
and	compte_tiers.codope = 10
and	not exists (
		select	1
		from	compensation
		where	compensation.idmvt = compte_tiers.idmvt)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTE_ATTENTE FOR ARTHUS.V_COMPTE_ATTENTE
