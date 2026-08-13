CREATE FORCE VIEW ARTHUS.V_VAL_VARIABLE AS
select	val_variable.idvariable,
	val_variable.etendue,
	val_variable.clef,
	val_variable.statique,
	val_variable.debut,
	val_variable.fin,
	to_char(val_variable.debut,'dd/mm/yy') edebut,
	to_char(val_variable.fin,'dd/mm/yy') efin,
	val_variable.valeur,
	v_clef_corres2.numgar
from	val_variable,v_clef_corres2
where	val_variable.valide='O'
and	val_variable.numgar is null
and	v_clef_corres2.etendue = val_variable.etendue
and	v_clef_corres2.clef    = val_variable.clef
and	(val_variable.idvariable,
	 val_variable.etendue,
	 val_variable.clef,
	 v_clef_corres2.numgar) not in (	select	val_variable.idvariable,
					val_variable.etendue,
					val_variable.clef,
					val_variable.numgar
				from	val_variable
				where	val_variable.numgar > 0
				and	val_variable.valide='O')
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
	val_variable.numgar
from	val_variable
where	val_variable.valide='O'
union
select	def_variable.idvariable,
	v_clef_corres2.etendue,
	v_clef_corres2.clef,
	def_variable.statique,
	to_date('01-jan-01') debut,
	to_date('') fin,
	'01/01/01',
	'',
	'' valeur,
	v_clef_corres2.numgar
from	def_variable,v_clef_corres2
where	v_clef_corres2.etendue = def_variable.etendue
and	not exists 	(select 1
			 from	val_variable
			 where	def_variable.idvariable=val_variable.idvariable
			 and	v_clef_corres2.etendue=val_variable.etendue
			 and	v_clef_corres2.clef=val_variable.clef
			 and	val_variable.valide='O')
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VAL_VARIABLE FOR ARTHUS.V_VAL_VARIABLE
