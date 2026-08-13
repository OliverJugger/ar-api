CREATE FORCE VIEW ARTHUS.V_TRAV_AD01 AS
select 	trav_ad01.idadhesion,
			trav_ad01.numfor,
			trav_ad01.numindiv,
			trav_ad01.codfrais,
			initcap(natfrais.libelle) lib_codfrais,
			trav_ad01.type,
			trav_ad01.delai||' '||initcap(lble.libelle) lib_type,
			trav_ad01.delai,
			trav_ad01.numedit,
			decode(trav_ad01.type,2,
				to_char(add_months(adhesion.datapli,
						   trav_ad01.delai
						   ),'dd/mm/yy'
					),
				to_char(adhesion.datapli+trav_ad01.delai,
							'dd/mm/yy')
				) datapli
	from 	trav_ad01,
		natfrais,
		lble,
		adhesion
	where	nvl(natfrais.cnvtn,'O')='O'
	and	lble.mnemo='DELAI'
	and	lble.code=trav_ad01.type
	and	trav_ad01.numfor=adhesion.numfor
	and	trav_ad01.idadhesion=adhesion.idadhesion
	and	trav_ad01.numindiv=adhesion.numindiv
	and 	trav_ad01.codfrais=natfrais.codfrais
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRAV_AD01 FOR ARTHUS.V_TRAV_AD01
