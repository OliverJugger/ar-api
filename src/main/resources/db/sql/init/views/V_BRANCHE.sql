CREATE FORCE VIEW ARTHUS.V_BRANCHE AS
select	numfor,
	classe_gar branche
from	garanties
where	etendue = 7
union
select	numfor,
	to_number(branche)
from	formule
where	numprod > 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_BRANCHE FOR ARTHUS.V_BRANCHE
