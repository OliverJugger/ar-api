CREATE FORCE VIEW ARTHUS.V_ACTE_DELEG AS
Select	Distinct to_char(sysdate, 'yyyy')	exercice,
	'Ex. ' || to_char(sysdate, 'yyyy')	lib_exercice,
	gar_cntrt.numgar,
	gar_cntrt.numfor,
	calcul.codfrais,
	natfrais.libelle,
	gar_cntrt.libelle			lib_garantie
From	calcul,
	natfrais,
	gar_cntrt
Where	natfrais.codfrais = calcul.codfrais
and	calcul.numfor = gar_cntrt.numfor
and 	gar_cntrt.valide = 'O'
and	Least( nvl(gar_cntrt.datper, add_months(trunc(sysdate, 'yy'), +12)),
		add_months(trunc(sysdate, 'yy'), +12) )
	-
	Greatest( gar_cntrt.datapli, trunc(sysdate, 'yy') ) > 0
Union
Select	Distinct to_char(add_months(sysdate, -12), 'yyyy') 	exercice,
	'Ex. ' || to_char(add_months(sysdate, -12), 'yyyy') 	lib_exercice,
	gar_cntrt.numgar,
	gar_cntrt.numfor,
	calcul.codfrais,
	natfrais.libelle,
	gar_cntrt.libelle					lib_garantie
From	calcul,
	natfrais,
	gar_cntrt
Where	natfrais.codfrais = calcul.codfrais
and	calcul.numfor = gar_cntrt.numfor
and 	gar_cntrt.valide = 'O'
and	Least( nvl(gar_cntrt.datper, trunc(sysdate, 'yy')-1),
		trunc(sysdate, 'yy')-1 )
	-
	Greatest( gar_cntrt.datapli, add_months(trunc(sysdate, 'yy'), -12) ) > 0
Union
Select	Distinct to_char(add_months(sysdate, -24), 'yyyy') 	exercice,
	'Ex. antérieurs'					lib_exercice,
	gar_cntrt.numgar,
	gar_cntrt.numfor,
	calcul.codfrais,
	natfrais.libelle,
	gar_cntrt.libelle					lib_garantie
From	calcul,
	natfrais,
	gar_cntrt
Where	natfrais.codfrais = calcul.codfrais
and	calcul.numfor = gar_cntrt.numfor
and 	gar_cntrt.valide = 'O'
and	Least( nvl(gar_cntrt.datper, add_months(trunc(sysdate, 'yy')-1, -12)),
		add_months(trunc(sysdate, 'yy')-1, -12) )
	-
	Greatest( gar_cntrt.datapli, add_months(trunc(sysdate, 'yy'), -24) ) > 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ACTE_DELEG FOR ARTHUS.V_ACTE_DELEG
