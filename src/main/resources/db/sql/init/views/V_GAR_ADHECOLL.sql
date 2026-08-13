CREATE FORCE VIEW ARTHUS.V_GAR_ADHECOLL AS
Select 	adhe_coll_gar.Numgar	numgar,
	adhe_coll_gar.Numfor	numfor,
	gar_cntrt.Nomgar	nomgar,
	adhe_coll_gar.Datapli,
	adhe_coll_gar.Datper,
	gar_cntrt.Libelle,
	adhe_coll_gar.Valide,
	adhe_coll_gar.obligatoire,
	1			Type
From	adhe_coll_gar,gar_cntrt
Where	Adhe_coll_gar.Numfor = gar_cntrt.Numfor and adhe_coll_gar.numfor Not In (
	Select	numfor
	from	grp_gar_def,
		grp_gar
	Where	grp_gar.numgrpgar = grp_gar_def.numgrpgar
	and	grp_gar.etendue = 2
	and	grp_gar.clef = adhe_coll_gar.numgar )
Union
Select	grp_gar.clef		numgar,
	grp_gar.numgrpgar	numfor,
	grp_gar.nomgrpgar	nomgar,
	grp_gar.datapli,
	grp_gar.datper,
	grp_gar.libelle,
	grp_gar.valide,
	grp_gar.obligatoire,
	2			Type
From	grp_gar
Where	grp_gar.etendue = 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR_ADHECOLL FOR ARTHUS.V_GAR_ADHECOLL
