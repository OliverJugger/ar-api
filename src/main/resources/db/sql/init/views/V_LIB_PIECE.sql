CREATE FORCE VIEW ARTHUS.V_LIB_PIECE AS
select
	facture.codope,
	facture.numfact,
	facture.numcli,
	facture.montant,
	facture.monnaie,
	facture.datfact,
	to_char(facture.datfact,'dd/mm/yy') edatfact,
	decode(facture.codope,
	4,
	'Appel n° ' ||facture.numfact|| ' éché.'||
                 ' du '||to_char(qttc_global.debut,'dd/mm/yyyy')||' Contrat '||
	qttc_global.numgar ,
	7,
	'Bdx comm. n° '||reversement.idrevers||
		' du '||to_char(reversement.datrevers,'dd/mm/yyyy'),
	12,
	'Bdx remb. prest. '
        ||decode(dcptcie.type,1,'santé ',2,'prévoyance')
   	|| ' n° '||dcptcie.numdcptcie
	||' du '||to_char(dcptcie.datcreat,'dd/mm/yyyy')
	) libelle,
	indvs.nom||' '||indvs.prenom nomcli,
	decode(facture.codope,
	4, 'qg03',
	12, decode(dcptcie.type,1,'gdr1',2,'gdr6'),
	''
	) codapli,
	indvs.prenom prenom,
	indvs.nom nom,
	indvs.numindiv,
	dcptcie.type
from	qttc_global,
	indvs,
	reversement,
	dcptcie,
	facture
where	qttc_global.numquit(+) = facture.numfact
and	reversement.idrevers(+) = facture.numfact
and	dcptcie.numdcptcie(+) = facture.numfact
and	indvs.numindiv = facture.numcli
union
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	-affectation.montant,
	affectation.monnaie,
	affectation.dataffec,
	to_char(affectation.dataffec,'dd/mm/yy') edatfact,
	decode(affectation.codope,
	1,
	'Indu décompte santé n° '||affectation.numaffec,
	2,
	'Indu décompte prévoyance n° '||affectation.numaffec,
	14,
	'Indu prest° délégataire n° '||affectation.numaffec
	),
	indvs.nom||' '||indvs.prenom nomcli,
	decode(affectation.codope,
		1, 'gd01',
		2, 'gdp1',
		14, 'de21'),
	indvs.prenom prenom,
	indvs.nom nom,
	indvs.numindiv,
	0
from	indvs,
	affectation
where	affectation.montant < 0
and	indvs.numindiv = affectation.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LIB_PIECE FOR ARTHUS.V_LIB_PIECE
