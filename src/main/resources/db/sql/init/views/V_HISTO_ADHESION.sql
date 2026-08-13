CREATE FORCE VIEW ARTHUS.V_HISTO_ADHESION AS
select 	histo_adhesion.idadhesion,
	histo_adhesion.etat,
	histo_adhesion.motif,
	histo_adhesion.debut,
	trunc(histo_adhesion.datsai)	datsai,
	histo_adhesion.numutil
from 	histo_adhesion
where 	histo_adhesion.datsai in (
	select 	min(a.datsai)
		from histo_adhesion a
		where histo_adhesion.idadhesion = a.idadhesion
	)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_ADHESION FOR ARTHUS.V_HISTO_ADHESION
