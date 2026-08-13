CREATE FORCE VIEW ARTHUS.V_FACTURE_TEST AS
select 	facture.codope,
	facture.numfact,
	facture.numcli,
	facture.montant,
	facture.monnaie,
	facture.datfact,
	to_char(facture.datfact,'dd/mm/yy') edatfact,
	f_totaffec(numfact, codope) mt_affec,
	decode(facture.codope,
	4,
	'Police '||qttc_global.numgar||' Ech. '||to_char(qttc_global.debut,'dd/mm/yy') ,
	7,
	'Commissions à percevoir Bx '||reversement.idrevers||' '||
		indvs.nom||' - '||
		to_char(reversement.datrevers,'DD/MM/YY'),
	12,
	decode(dcptcie.type,1,'Mal. ',2,'Prev. ')||
		indvs.nom||' - '||
		to_char(dcptcie.datedeb,'DD/MM/YY')||
		' au '||to_char(dcptcie.datefin,'dd/mm/yy')
	) libelle,
	indvs.nom||' '||indvs.prenom nomcli,
	decode(facture.codope,
	4, 'qg03',
	12, 'gdr2',
	''
	) codapli
from	facture,
	qttc_global,
	indvs,
	reversement,
	dcptcie
where	qttc_global.numquit(+) = facture.numfact
and	reversement.idrevers(+) = facture.numfact
and	dcptcie.numdcptcie(+) = facture.numfact
and	indvs.numindiv = facture.numcli
and not exists 	(select 1
		 from 	facture_regul
		 where	facture_regul.codope = facture.codope
		 and	facture_regul.numfact_regul = facture.numfact)
union
select 	facture.codope,
	facture.numfact,
	facture.numcli,
	facture.montant,
	facture.monnaie,
	facture.datfact,
	to_char(facture.datfact,'dd/mm/yy') edatfact,
	facture.montant,
	'Régul° par pièce N° '||facture_regul.numfact||
		' le '||to_char(facture_regul.datope,'dd/mm/yy'),
	indvs.nom||' '||indvs.prenom nomcli,
	'qg03' codapli
from	facture,
	facture_regul,
	indvs
where	facture_regul.codope = facture.codope
and	facture_regul.numfact_regul = facture.numfact
and	indvs.numindiv = facture.numcli
union
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	-affectation.montant,
	affectation.monnaie,
	affectation.dataffec,
	to_char(affectation.dataffec,'dd/mm/yy') edatfact,
	f_totaffec(numaffec, codope) mt_affec,
	decode(affectation.codope,
	1,
	'Trop perçu decpte maladie'||' No '||
		affectation.numaffec||' du '||
		to_char(affectation.dataffec,'dd/mm/yy'),
	2,
	'Trop perçu decpte prevoyance No '||
		affectation.numaffec||' du '||
		to_char(affectation.dataffec,'dd/mm/yy')
	),
	indvs.nom||' '||indvs.prenom nomcli,
	decode(affectation.codope,
		1, 'gd01',
		2, 'gdp1')
from	indvs,
	affectation
where	affectation.montant < 0
and	indvs.numindiv = affectation.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACTURE_TEST FOR ARTHUS.V_FACTURE_TEST
