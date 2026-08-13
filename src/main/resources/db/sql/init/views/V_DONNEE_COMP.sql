CREATE FORCE VIEW ARTHUS.V_DONNEE_COMP AS
Select	val_variable.numgar		cle,
	def_variable.idvariable,
	def_variable.nom_variable,
	def_variable.lib_variable
From	def_variable,
	val_variable
Where	def_variable.etendue in (13, 4, 12)
and	def_variable.statique = 'O'
and	def_variable.idvariable = val_variable.idvariable
Group by
	val_variable.numgar,
	def_variable.idvariable,
	def_variable.nom_variable,
	def_variable.lib_variable
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DONNEE_COMP FOR ARTHUS.V_DONNEE_COMP
