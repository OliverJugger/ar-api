CREATE FORCE VIEW ARTHUS.V_GC05 AS
select	grnts.numgar,
		grnts.refcie,
		grnts.numcli,
		grnts.numutil,
		util.nom nomutil,
		grnts.cellule,
		nvl(indvs.nom,'Client inconnu')||' '||
		indvs.prenom nomprenom
	from	grnts,indvs,util
	where	indvs.numindiv (+) = grnts.numcli
	and	util.numutil = f_numutil
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GC05 FOR ARTHUS.V_GC05
