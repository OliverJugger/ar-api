CREATE FORCE VIEW ARTHUS.V_PORTE_REMISE AS
select	porte_remise.numremise,
	porte_remise.numporte,
	porte_param.type_circuit,
	porte_param.nat_porte,
	porte_remise.dateremise,
	porte_remise.dateporte,
	substr (ARTHUS.pk_libelle.f_lib ('PORTE',porte_remise.numporte),1,45) libelle,
	substr (
	ARTHUS.pk_libelle.f_lib ('FIC_IMP',porte_remise.nature) ||
	' du ' ||
	to_char(nvl(porte_remise.dateporte,
		porte_remise.dateremise),'DD/MM/YYYY'),1,75) edateremise,
	porte_remise.nature,
	'Fichier du ' ||
	to_char(nvl(porte_remise.dateporte,
		porte_remise.dateremise),'DD/MM/YYYY') libelle_2
from	porte_remise,
	porte_param
where	porte_remise.numporte = porte_param.numporte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PORTE_REMISE FOR ARTHUS.V_PORTE_REMISE
