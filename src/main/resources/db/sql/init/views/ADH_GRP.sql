CREATE FORCE VIEW ARTHUS.ADH_GRP AS
select adhesion.numindiv,
		  adhesion.numgar,
		  adhesion.numfor,
		  adhesion.datapli,
		  adhesion.datper,
		adhesion.rang,
		adhesion.etat,
		adhesion.uc,
		adhesion.flag_regime,
		adhesion.regime,
		adhesion.typfor,
		adhesion.numorg,
		adhesion.dis_carence,
		adhesion.dis_franchise,
		gar_cntrt.libelle,
		adhesion.idadhesion
	from adhesion,
		gar_cntrt
	where adhesion.typfor in (1,2)
	and	gar_cntrt.numfor = adhesion.numfor
union
	  select  adhesion.numindiv,
		  adhesion.numgar,
		  grp_gar.numgrpgar,
		  adhesion.datapli,
		  adhesion.datper,
		adhesion.rang,
		adhesion.etat,
		adhesion.uc,
		adhesion.flag_regime,
		adhesion.regime,
		adhesion.typfor,
		adhesion.numorg,
		adhesion.dis_carence,
		adhesion.dis_franchise,
		grp_gar.libelle,
		adhesion.idadhesion
	from adhesion,grp_gar_def,grp_gar
	where adhesion.typfor=3
	and grp_gar_def.numgrpgar=adhesion.numfor
	and grp_gar.numgrpgar=adhesion.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM ADH_GRP FOR ARTHUS.ADH_GRP
