CREATE FORCE VIEW ARTHUS.V_ADHE_QUER AS
select distinct adhe_cntrt.numadhe,
                   adhe_cntrt.numquerable
from 	adhe_cntrt,
	indvs
where	adhe_cntrt.numadhe=indvs.numindiv
and	adhe_cntrt.numquerable=indvs.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ADHE_QUER FOR ARTHUS.V_ADHE_QUER
