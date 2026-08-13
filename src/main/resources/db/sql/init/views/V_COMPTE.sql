CREATE FORCE VIEW ARTHUS.V_COMPTE AS
select 	v_societe.refsoc,
	compte.numsoc,
	compte.numcpte,
	compte.libcompte,
	'so12' codapli
from 	compte, v_societe
where 	compte.numsoc = v_societe.numsoc
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTE FOR ARTHUS.V_COMPTE
