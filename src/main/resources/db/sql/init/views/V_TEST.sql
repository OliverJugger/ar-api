CREATE FORCE VIEW ARTHUS.V_TEST AS
select	v_clef_corres.etendue,
	lble_conte.libelle		lib_entendue,
	v_clef_corres.numgar,
	v_clef_corres.clef		numindiv,
	contrat.refcie
from	v_clef_corres,
	contrat,
	libelle lble_conte
where	v_clef_corres.numgar = contrat.numgar
and	v_clef_corres.etendue in (3,4,9)
and	lble_conte.mnemo='CONTE'
and	v_clef_corres.etendue = lble_conte.code
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TEST FOR ARTHUS.V_TEST
