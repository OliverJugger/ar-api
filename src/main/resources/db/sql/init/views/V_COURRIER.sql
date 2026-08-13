CREATE FORCE VIEW ARTHUS.V_COURRIER AS
select	numdec,
	numsin,
	text||' '||decode(montant,0,'',to_char(montant,'99999999990.00')) text,
	type,
	seq
from	courrier
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COURRIER FOR ARTHUS.V_COURRIER
