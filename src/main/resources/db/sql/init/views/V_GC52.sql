CREATE FORCE VIEW ARTHUS.V_GC52 AS
select	distinct
	cvrt.numindiv			numindiv,
	cvrt.numgar			numgar,
	grnts.refcie			refcie,
	grnts.numcli			numcli,
	indvs.nom||' '||indvs.prenom	nomcli,
	gar_cntrt.numfor		numfor,
	gar_cntrt.libelle		libgar,
	cvrt.datapli			datapli,
	cvrt.datper			datper
from	cvrt,
	grnts,
	indvs,
	gar_cntrt
where	grnts.numgar	= cvrt.numgar
and	gar_cntrt.numfor= cvrt.numfor
and	gar_cntrt.numgar= grnts.numgar
and	indvs.numindiv	= grnts.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GC52 FOR ARTHUS.V_GC52
