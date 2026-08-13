CREATE FORCE VIEW ARTHUS.V_VALID AS
select	v_valid_base.codope,
	v_valid_base.numsoc,
	compte.numcpte,
	min(montant) montant
from	v_valid_base,compte,type_ope
where	v_valid_base.numsoc=compte.numsoc
and	type_ope.numcpte = compte.numcpte
and	type_ope.numope  = v_valid_base.codope
group by v_valid_base.codope, v_valid_base.numsoc,compte.numcpte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VALID FOR ARTHUS.V_VALID
