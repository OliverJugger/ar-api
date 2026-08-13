CREATE FORCE VIEW ARTHUS.V_REP_FONCTION AS
select	nom_fonction,
	lib_variable,
	contexte,
	seq,
	type,
	nbarg,
	d_date,
	0 idfonction
from	v_rep_fonction_seule
union
select	nom_variable,
	lib_variable,
	code,
	0,
	4,
	0,
	''	d_date,
	idvariable
from	def_variable,
	lble
where	mnemo='CONTE_FONC'
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REP_FONCTION FOR ARTHUS.V_REP_FONCTION
