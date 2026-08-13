CREATE FORCE VIEW ARTHUS.V_ANO_VARIABLE AS
Select	adhe_cntrt.numgar,
	adhe_cntrt.numadhe,
	adhe_cntrt.idadhesion,
	indvs.prenom||' '||indvs.nom nom,
	val_variable.idvariable,
	def_variable.lib_variable
From	def_variable,val_variable,indvs,adhe_cntrt
Where	def_variable.idvariable=val_variable.idvariable
And	val_variable.etendue in (4,12)
And	val_variable.clef=adhe_cntrt.numadhe
And	indvs.numindiv=adhe_cntrt.numadhe
And	val_variable.numgar=adhe_cntrt.numgar
And	val_variable.valeur is null
Union
Select	adhe_cntrt.numgar,
	adhe_cntrt.numadhe,
	adhe_cntrt.idadhesion,
	indvs.prenom||' '||indvs.nom nom,
	val_variable.idvariable,
	def_variable.lib_variable
From	def_variable,val_variable,indvs,adhe_cntrt
Where	def_variable.idvariable=val_variable.idvariable
And	val_variable.etendue=13
And	val_variable.clef=adhe_cntrt.idadhesion
And	indvs.numindiv=adhe_cntrt.numadhe
And	val_variable.numgar=adhe_cntrt.numgar
And	val_variable.valeur is null
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ANO_VARIABLE FOR ARTHUS.V_ANO_VARIABLE
