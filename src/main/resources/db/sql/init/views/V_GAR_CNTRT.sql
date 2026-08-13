CREATE FORCE VIEW ARTHUS.V_GAR_CNTRT AS
Select	gar_cntrt.numfor,
	gar_cntrt.numfor	idgarantie,
	gar_cntrt.numgar,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.type		typfor,
	gar_cntrt.datapli	debut,
	gar_cntrt.datper	fin,
	gar_cntrt.valide,
	gar_cntrt.numfor_ref
From	gar_cntrt
Union
Select	grp_gar_def.numfor,
	grp_gar_def.numgrpgar,
	gar_cntrt.numgar,
	gar_cntrt.nomgar,
	gar_cntrt.libelle,
	gar_cntrt.type		typfor,
	gar_cntrt.datapli	debut,
	gar_cntrt.datper	fin,
	gar_cntrt.valide,
	gar_cntrt.numfor_ref
From	grp_gar,
	grp_gar_def,
	gar_cntrt
Where	grp_gar.numgrpgar = grp_gar_def.numgrpgar
and	gar_cntrt.numfor = grp_gar_def.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR_CNTRT FOR ARTHUS.V_GAR_CNTRT
