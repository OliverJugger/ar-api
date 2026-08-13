CREATE FORCE VIEW ARTHUS.V_CHEQUIER AS
select 	chequier.numcpte,
 	chequier.numsoc,
	compte.libcompte,
 	chequier.numchq,
 	nvl(chequier.derchq, chequier.premchq-1) derchq,
	to_char(chequier.debut, 'dd/mm/yy') debut,
	chequier.papid,
	decode(chequier.papid, 'Manuel', 1, 0) modaffec,
	'so18' codapli
from 	compte, chequier
where 	nvl(chequier.fin, sysdate+1) > sysdate
and	compte.numcpte = chequier.numcpte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CHEQUIER FOR ARTHUS.V_CHEQUIER
