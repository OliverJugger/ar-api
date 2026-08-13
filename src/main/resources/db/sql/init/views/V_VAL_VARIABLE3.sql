CREATE FORCE VIEW ARTHUS.V_VAL_VARIABLE3 AS
select	a.idvariable,
	a.etendue,
	a.clef,
	a.statique,
	a.debut,
	a.fin,
	to_char(a.debut,'dd/mm/yy') edebut,
	to_char(a.fin,'dd/mm/yy') efin,
	a.valeur,
	v_clef_corres2.numgar,
	a.rowid v_rowid
from	val_variable a,v_clef_corres2
where	a.valide='O'
and	a.numgar is null
and	v_clef_corres2.etendue = a.etendue
and	v_clef_corres2.clef    = a.clef
and	not exists (	select	1
			from	val_variable b
			where	b.numgar > 0
			and	a.idvariable = b.idvariable
	 		and	a.etendue	= b.etendue
	 		and	a.clef	= b.clef
	 		and	v_clef_corres2.numgar	= b.numgar
			and	b.valide='O')
union
select	val_variable.idvariable,
	val_variable.etendue,
	val_variable.clef,
	val_variable.statique,
	val_variable.debut,
	val_variable.fin,
	to_char(val_variable.debut,'dd/mm/yy') edebut,
	to_char(val_variable.fin,'dd/mm/yy') efin,
	val_variable.valeur,
	val_variable.numgar,
	val_variable.rowid v_rowid
from	val_variable
where	val_variable.valide='O'
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VAL_VARIABLE3 FOR ARTHUS.V_VAL_VARIABLE3
