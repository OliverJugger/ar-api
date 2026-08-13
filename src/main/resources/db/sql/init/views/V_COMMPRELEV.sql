CREATE FORCE VIEW ARTHUS.V_COMMPRELEV AS
select	idaffec,
	numquit,
	numfor,
	numindiv,
	sum(decode(prelev_revers,1,montant,0)) montant
from	qttc_affec_tfc
group by	idaffec,
		numquit,
		numfor,
		numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMMPRELEV FOR ARTHUS.V_COMMPRELEV
