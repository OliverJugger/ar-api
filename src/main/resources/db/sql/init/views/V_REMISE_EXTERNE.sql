CREATE FORCE VIEW ARTHUS.V_REMISE_EXTERNE AS
select	remise_externe.numremise,
	remise_externe.numporte,
	porte_param.type_circuit,
	porte_param.nat_porte,
	remise_externe.date_remise,
	remise_externe.date_trans,
	substr (ARTHUS.pk_libelle.f_lib ('PORTE',remise_externe.numporte),1,45) libelle,
	substr (ARTHUS.pk_libelle.f_lib ('FIC_EXP',to_number(remise_externe.nature)) ||
	' du ' ||
	to_char(nvl(remise_externe.date_trans,remise_externe.date_remise),'DD/MM/YYYY'),1,75) edateremise,
	remise_externe.nature
from	remise_externe,
	porte_param
where	remise_externe.numporte = porte_param.numporte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_EXTERNE FOR ARTHUS.V_REMISE_EXTERNE
