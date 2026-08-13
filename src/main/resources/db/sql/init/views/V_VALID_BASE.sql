CREATE FORCE VIEW ARTHUS.V_VALID_BASE AS
select	codope,
	numsoc,
	min(maxi) montant
from	valid_ope
where	numutil = 0
group by codope,numsoc
union
select	lble.code,
	compte.numsoc,
	999999999.99
from	lble,compte
where	lble.mnemo='OPE'
and	lble.sens = -1
and	lble.code >= 0
group by lble.code,compte.numsoc
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VALID_BASE FOR ARTHUS.V_VALID_BASE
