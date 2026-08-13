CREATE FORCE VIEW ARTHUS.V_NUMPIECE AS
select	idcompta,
	numsoc,
	codope,
	journal,
	refpiece,
	trunc(dat_piece) dat_piece
from	compta
group by
	idcompta,
	numsoc,
	codope,
	journal,
	refpiece,
	trunc(dat_piece)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_NUMPIECE FOR ARTHUS.V_NUMPIECE
