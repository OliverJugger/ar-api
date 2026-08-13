CREATE FORCE VIEW ARTHUS.V_AFFEC_VALID AS
select	affectation.codope,
	affectation.numaffec,
	affectation.numcli,
	affectation.numdecaismt,
	affectation.dataffec,
	to_char(affectation.dataffec,'dd/mm/yyyy') edataffec,
	affectation.montant,
	monnaie.symbole,
	affectation.montant_d,
	monnaie_d.symbole symbole_d,
	valid_ope.numutil,
	decaismt.numcpte,
	vs_compte.numsoc,
	translate(vs_compte.libcompte||' '||vs_compte.compte,'.','@') lib_banq,
	decode(affectation.codope,1, 'gd01',2, 'gdp1', 10, 'de54') codapli
from	affectation, monnaie, monnaie monnaie_d, decaismt, vs_compte, valid_ope
where	monnaie.codmon		= affectation.monnaie
    and monnaie_d.codmon		= affectation.monnaie_d
and	decaismt.numdecaismt	= affectation.numdecaismt
and	decaismt.numutil	= -1
and	vs_compte.numcpte	= decaismt.numcpte
and	valid_ope.numsoc	= vs_compte.numsoc
and	valid_ope.codope	= affectation.codope
and	affectation.montant	between valid_ope.mini and valid_ope.maxi
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFEC_VALID FOR ARTHUS.V_AFFEC_VALID
