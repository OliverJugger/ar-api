CREATE FORCE VIEW ARTHUS.V_SITU_CONTRAT AS
Select
	contrat.numgar,
	contrat.refcie,
	libelle.code,
	libelle.libelle
From	libelle,contrat
Where	libelle.mnemo='ET_ADHE'
And	libelle.code >=0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SITU_CONTRAT FOR ARTHUS.V_SITU_CONTRAT
