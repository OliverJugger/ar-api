CREATE FORCE VIEW ARTHUS.V_A_PRELEVER AS
select	codope,
	numfact,
	mregl,
	numcli,
	echeance,
	montant
from	facture
	WHERE	NOT EXISTS
			(select	1
			from	prelevement_detail,
				prelevement
			where	prelevement_detail.codope   = facture.codope
			and	prelevement_detail.numfact = facture.numfact
			and	prelevement.numprelev =
					prelevement_detail.numprelev
			)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_A_PRELEVER FOR ARTHUS.V_A_PRELEVER
