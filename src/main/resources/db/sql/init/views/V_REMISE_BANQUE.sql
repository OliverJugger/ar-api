CREATE FORCE VIEW ARTHUS.V_REMISE_BANQUE AS
Select	remise_banque.numremise,
	encaismt.numcpte,
	encaismt.monnaie,
	Count(*)			Nombre,
	Sum( encaismt.Montant )		Montant
From	encaismt,
	remise_banque
Where	encaismt.numencaismt	= remise_banque.numencaismt
Group by
	remise_banque.numremise,
	encaismt.numcpte,
	encaismt.monnaie
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_BANQUE FOR ARTHUS.V_REMISE_BANQUE
