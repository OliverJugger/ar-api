CREATE FORCE VIEW ARTHUS.VS_TYPE_OPE AS
select "NUMOPE","NUMCPTE","PAPID","DEFAUT"
from	type_ope
where 	exists (select 	1
		from 	vs_compte, type_ope
		where	vs_compte.numcpte = type_ope.numcpte)
GO
CREATE OR REPLACE PUBLIC SYNONYM VS_TYPE_OPE FOR ARTHUS.VS_TYPE_OPE
