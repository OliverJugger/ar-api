CREATE FORCE VIEW ARTHUS.VD_COMPTE AS
select	compte.numsoc,
	compte.numcpte,
	type_ope.numope
from	compte,type_ope
where	compte.numcpte = type_ope.numcpte
and	type_ope.defaut ='O'
GO
CREATE OR REPLACE PUBLIC SYNONYM VD_COMPTE FOR ARTHUS.VD_COMPTE
