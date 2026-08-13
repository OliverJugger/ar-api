CREATE FORCE VIEW ARTHUS.V_VAL_VARIABLE4 AS
select	distinct
	val_variable.idvariable,
	val_variable.etendue,
	val_variable.clef,
	val_variable.statique,
	val_variable.debut,
	val_variable.fin,
	to_char(val_variable.debut,'dd/mm/yy') edebut,
	to_char(val_variable.fin,'dd/mm/yy') efin,
	val_variable.valeur,
	nvl(val_variable.numgar,v_clef_corres2.numgar) numgar,
	val_variable.rowid v_rowid
from	val_variable,v_clef_corres2
where	val_variable.valide='O'
and	v_clef_corres2.etendue = val_variable.etendue
and	v_clef_corres2.clef    = val_variable.clef
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VAL_VARIABLE4 FOR ARTHUS.V_VAL_VARIABLE4
