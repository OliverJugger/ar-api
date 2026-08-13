CREATE FORCE VIEW ARTHUS.V_REP_FONCTION_EXT AS
select
	nom_fonction,
	lib_variable,
	contexte,
	seq,
	type,
	nbarg,
	d_date,
	nom_fonction ordre,
	idfonction
from v_rep_fonction
union
select distinct
	lib_tableau.tableau,
	nom_tableau,
	code,
	0,
	5,
	0,
	''	d_date,
	to_char(lib_tableau.tableau,'000000'),
	to_number(lib_tableau.tableau)		idfonction
from 	lib_tableau,
	lble
where mnemo='CONTE_FONC'
and code>=0
and type_tableau=1
union
select distinct
	lib_tableau.tableau,
	nom_tableau,
	code,
	0,
	7,
	0,
	''	d_date,
	to_char(lib_tableau.tableau,'000000'),
	to_number(lib_tableau.tableau)		idfonction
from 	lib_tableau,
	lble
where mnemo='CONTE_FONC'
and code>=0
and type_tableau=2
union
select
	to_char(indcs.indice),
	a.libelle,
	b.code,
	0,
	6,
	0,
	''	d_date,
	to_char(indcs.indice,'000000'),
	a.code					idfonction
from indcs,libelle a,libelle b
where a.mnemo='INDC'
and b.mnemo='CONTE_FONC'
and a.code>0
and b.code>=0
and indcs.indice=a.code
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REP_FONCTION_EXT FOR ARTHUS.V_REP_FONCTION_EXT
