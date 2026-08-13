CREATE FORCE VIEW ARTHUS.V_CREANCE AS
select	affectation.codope,
	affectation.numaffec,
	affectation.dataffec,
	to_char(affectation.dataffec, 'dd/mm/yy') edataffec,
	affectation.numdecaismt,
	affectation.numcli,
	affectation.montant,
	affectation.montant_d,
	indvs.nom||' '||indvs.prenom nomcli,
	indvs.nom,
	decode(affectation.codope,
		1, 'Dcpte Mal ',
		2, 'Dcpte Prev ',
		5, 'Revers Cotis ',
		6, 'Revers Frais ',
		8, 'Rembt Client ',
		11, 'Dcpte Dedu ',
		10, 'Règl. fournisseur')
	|| to_char(affectation.dataffec,'dd/mm/yy')
	lib_affec,
	decode(affectation.codope,
		1, 'gd01',
		2, 'gdp1',
		5, 'qg12',
		6, '',
		8, 'en16',
		11, 'rg26',
		10, 'de54')
	codapli,
	affectation.monnaie,
	affectation.monnaie_d,
	affectation.devise_ct,
	affectation.montant_ct
from	affectation,
	indvs
where	indvs.numindiv (+)	= affectation.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CREANCE FOR ARTHUS.V_CREANCE
