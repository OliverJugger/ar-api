CREATE FORCE VIEW ARTHUS.V_REMISE_EXPORT AS
Select	remise_export.numremise,
	remise_export.idporte,
	remise_export.nombre,
	d2e(remise_export.date_remise)	date_remise
From	remise_export
Union
Select	0,
	histo_export.idporte,
	count(*),
	'Non traité'
From	histo_export
Where numremise = 0
Group by
	histo_export.idporte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_EXPORT FOR ARTHUS.V_REMISE_EXPORT
