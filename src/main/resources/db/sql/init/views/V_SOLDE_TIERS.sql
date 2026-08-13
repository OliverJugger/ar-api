CREATE FORCE VIEW ARTHUS.V_SOLDE_TIERS AS
Select	compte_tiers.numcli,
	nvl( sum(montant * sens), 0 ) 	solde,
	0				debit,
	0				credit
From 	compte_tiers
Group by
	compte_tiers.numcli
Union
Select	compte_tiers.numcli,
	0				solde,
	nvl( sum(montant), 0 ) 		debit,
	0				credit
From 	compte_tiers
Where	sens = -1
Group by
	compte_tiers.numcli
Union
Select	compte_tiers.numcli,
	0				solde,
	0				debit,
	nvl( sum(montant), 0 ) 		credit
From 	compte_tiers
Where	sens = 1
Group by
	compte_tiers.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SOLDE_TIERS FOR ARTHUS.V_SOLDE_TIERS
