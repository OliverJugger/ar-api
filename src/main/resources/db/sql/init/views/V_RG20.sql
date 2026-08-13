CREATE FORCE VIEW ARTHUS.V_RG20 AS
select	decaismt.codope,
	decaismt.numcpte,
	decaismt.modpmt,
	decaismt.datpay,
	sum(decaismt.montant)	montant,
	sum(decaismt.montant_d)	montant_d,
	compte.libcompte,
	modpmt.libelle		lib_modpmt,
	decode(decaismt.datpay, Null, 'Non émis',
	'Lot du '||to_char(decaismt.datpay, 'dd/mm/yy')) editlib,
	decaismt.monnaie,
	decaismt.monnaie_d
from	libelle modpmt,
	compte,
	decaismt
where	modpmt.mnemo = 'MOPM'
and	modpmt.code = decaismt.modpmt
and	compte.numcpte = decaismt.numcpte
and	decaismt.numutil >= 0
and	decaismt.idcompta = -1
and	decaismt.refpmt is null
group by
	decaismt.codope,
	decaismt.numcpte,
	decaismt.modpmt,
	decaismt.datpay,
	compte.libcompte,
	modpmt.libelle,
	'Lot du '||to_char(decaismt.datpay, 'dd/mm/yy'),
	decaismt.monnaie,
	decaismt.monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RG20 FOR ARTHUS.V_RG20
