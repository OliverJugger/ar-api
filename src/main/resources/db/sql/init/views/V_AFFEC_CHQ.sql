CREATE FORCE VIEW ARTHUS.V_AFFEC_CHQ AS
select	/*+ RULE */ affectation.numaffec,
	affectation.numdecaismt,
	affectation.nbfeuille,
	decaismt.refpmt,
	decaismt.numedit
from	affectation, decaismt
where	decaismt.numdecaismt = affectation.numdecaismt
and	numedit > 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFEC_CHQ FOR ARTHUS.V_AFFEC_CHQ
