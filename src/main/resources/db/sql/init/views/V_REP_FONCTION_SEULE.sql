CREATE FORCE VIEW ARTHUS.V_REP_FONCTION_SEULE AS
select	nom_fonction,
	lib_variable,
	1 contexte,
	seq,
	type,
	nbarg,
	d_date,
	0 idfonction
from	rep_fonction_tous
where	a is not null
union
select	nom_fonction,
	lib_variable,
	2 contexte,
	seq,
	type,
	nbarg,
	d_date,
	0
from	rep_fonction_tous
where	r is not null
union
select	nom_fonction,
	lib_variable,
	3 contexte,
	seq,
	type,
	nbarg,
	d_date,
	0
from	rep_fonction_tous
where	p is not null
union
select	nom_fonction,
	lib_variable,
	4 contexte,
	seq,
	type,
	nbarg,
	d_date,
	0
from	rep_fonction_tous
where	m is not null
union
select	nom_fonction,
	lib_variable,
	5 contexte,
	seq,
	type,
	nbarg,
	d_date,
	0
from	rep_fonction_tous
where	c is not null
union
select	nom_fonction,
	lib_variable,
	7 contexte,
	seq,
	type,
	nbarg,
	d_date,
	0
from	rep_fonction_tous
where	reass is not null
union
select	nom_fonction,
	lib_variable,
	8 contexte,
	seq,
	type,
	nbarg,
	d_date,
	0
from	rep_fonction_tous
where	reass is not null
union
select	nom_fonction,
	lib_variable,
	9 contexte,
	seq,
	type,
	nbarg,
	d_date,
	0
from	rep_fonction_tous
where	reass is not null
/* VCR 23/10/2006
ORA-01775: bouclage de chaînes de synonymes */
/* union
select	nom_fonction,
	lib_variable,
	6 contexte,
	seq,
	type,
	nbarg,
	''	d_date,
	0
from	rep_fonction_adhesion
union
select	nom_fonction,
	lib_variable,
	6 contexte,
	seq,
	type,
	nbarg,
	''	d_date,
	0
from	rep_fonction_souscription */
union
select	nom_fonction,
	lib_variable,
	0 contexte,
	0,
	type,
	nbarg,
	d_date,
	0
from	rep_fonction_tous
/* VCR 23/10/2006
ORA-01775: bouclage de chaînes de synonymes */
/*
union
select  nom_fonction,
	lib_variable,
	code,
	seq,
	type,
	0,
	''	d_date,
	0
from	rep_operateur,
	lble
where	mnemo='CONTE_FONC'
and	type=3
union
select	nom_variable,
	lib_variable,
	lble.code,
	0,
	4,
	0,
	''	d_date,
	idvariable
from	rep_variable,
	lble
where	mnemo='CONTE_FONC'
and code in(1,2,3,0)
and type=2 */
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REP_FONCTION_SEULE FOR ARTHUS.V_REP_FONCTION_SEULE
