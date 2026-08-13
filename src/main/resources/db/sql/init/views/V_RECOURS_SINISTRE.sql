CREATE FORCE VIEW ARTHUS.V_RECOURS_SINISTRE AS
select	a.codfrais
		,	s.numassu
		,	s.numindiv
		,	s.datsin
		,	s.datsai
		,	s.mtreel
		,	s.numdec
		,	a.libelle
		,	s.numannul
		,	s.mtfrais
		,	s.mtremb
		,	s.numsin
	    from	sinistre s
		,	acte a
	   where	a.codfrais = s.codfrais
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RECOURS_SINISTRE FOR ARTHUS.V_RECOURS_SINISTRE
