CREATE FORCE VIEW ARTHUS.COUVERTURE AS
select	distinct
	adhesion.idadhesion,
	adhesion.numindiv,
	adhesion.numgar,
	adhesion.numfor,
	adhesion.datapli,
	adhesion.datper,
	adhesion.rang,
	adhesion.uc,
	adhesion.dis_carence,
	adhesion.dis_franchise,
	adhesion.typfor numtype,
	adhesion.numfor numpopu,
	'' norisq,
	adhesion.flag_regime,
	adhesion.numorg,
	nvl(adhesion.numfor_carence,0) numfor_carence,
	adhe_cntrt_membre.numbene
from	adhesion,
	adhe_cntrt_membre
where	adhesion.typfor in (1,2)
and	((adhesion.datapli != nvl(adhesion.datper,adhesion.datapli+1))  or f_couv_jour=1)
and	adhe_cntrt_membre.idadhesion = adhesion.idadhesion
and	adhe_cntrt_membre.numindiv   = adhesion.numindiv
and	exists (select 1
		  from	 libelle
		  where	 mnemo='ETIN'
		  and	 sens=0
		  and libelle.code = adhesion.etat
		)
union
select	distinct
	adhesion.idadhesion,
	adhesion.numindiv,
	adhesion.numgar,
	grp_gar_def.numfor,
	adhesion.datapli,
	adhesion.datper,
	adhesion.rang,
	adhesion.uc,
	adhesion.dis_carence,
	adhesion.dis_franchise,
	grp_gar_def.typfor,
	grp_gar_def.numfor,
	'',
	adhesion.flag_regime,
	adhesion.numorg,
	nvl(adhesion.numfor_carence,0),
	adhe_cntrt_membre.numbene
from	adhesion,grp_gar_def,
	adhe_cntrt_membre
where	adhesion.typfor  = 3
and	adhesion.numfor = grp_gar_def.numgrpgar
and	((adhesion.datapli != nvl(adhesion.datper,adhesion.datapli+1))  or f_couv_jour=1)
and	adhe_cntrt_membre.idadhesion = adhesion.idadhesion
and	adhe_cntrt_membre.numindiv  = adhesion.numindiv
and	exists           (select 1
			  from	 libelle
			  where	 mnemo='ETIN'
			  and	 sens=0
			  and	 libelle.code = adhesion.etat)
union
select	distinct
	0,
	0,
	gar_cntrt.numgar,
	gar_cntrt.numfor,
	gar_cntrt.datapli,
	gar_cntrt.datper,
	1,
	0,
	'O',
	'O',
	gar_cntrt.type numtype,
	gar_cntrt.numfor numpopu,
	'' norisq,
	'C',
	0,
	0,
	0
from	gar_cntrt
where	gar_cntrt.valide='O'
GO
CREATE OR REPLACE SYNONYM ARTHUS.CVRT FOR ARTHUS.COUVERTURE

GO
CREATE OR REPLACE PUBLIC SYNONYM COUVERTURE FOR ARTHUS.COUVERTURE

GO
CREATE OR REPLACE PUBLIC SYNONYM CVRT FOR ARTHUS.COUVERTURE
