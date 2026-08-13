CREATE FORCE VIEW ARTHUS.V_GC03 AS
select	grnts.numgar,
		grnts.refcie,
		grnts.numcli,
		grnts.numutil,
		util.nom nomutil,
		grnts.cellule,
		nvl(indvs.nom,'Client inconnu')||' '||
		indvs.prenom nomprenom,
		gar_cntrt.numfor,
		gar_cntrt.nomgar,
		gar_cntrt.libelle,
		gar_cntrt.valide
	from	grnts,indvs,util,gar_cntrt
	where	indvs.numindiv (+) = grnts.numcli
	and	util.numutil = f_numutil
	and	gar_cntrt.numgar = grnts.numgar
	and	grnts.cellule = decode(util.cellule,
					0,grnts.cellule,
					util.cellule)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GC03 FOR ARTHUS.V_GC03
