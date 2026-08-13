CREATE FORCE VIEW ARTHUS.V_VAL_VARIABLE2 AS
select	val_variable.idvariable,
	val_variable.etendue,
	val_variable.clef,
	val_variable.statique,
	val_variable.debut,
	val_variable.fin,
	val_variable.valeur,
	nvl(val_variable.numgar,v_clef_corres2.numgar) numgar
from	val_variable,v_clef_corres2
where	val_variable.valide='O'
and	val_variable.numgar is null
and	v_clef_corres2.etendue = val_variable.etendue
and	v_clef_corres2.clef    = val_variable.clef
union
select	def_variable.idvariable,
	v_clef_corres2.etendue,
	v_clef_corres2.clef,
	def_variable.statique,
	to_date('01-jan-01') debut,
	to_date('') fin,
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
CREATE OR REPLACE PUBLIC SYNONYM V_VAL_VARIABLE2 FOR ARTHUS.V_VAL_VARIABLE2
