CREATE FORCE VIEW ARTHUS.V_GAR_COTI_INDV AS
SELECT	grp_gar.clef numgar,
		grp_gar.datapli,
		grp_gar.datper,
		grp_gar.nomgrpgar nomgar,
		grp_gar.libelle,
		grp_gar.numgrpgar numfor,
		1 ordre,
                qttc_variable.monnaie,
                qttc_variable.monnaie_d,
        nat_calc,
		adhe_cntrt.numadhe
        FROM	grp_gar,grp_gar_def,gar_cntrt,adhesion,adhe_cntrt,qttc_variable, v_frmlgar
        Where   grp_gar.numgrpgar=grp_gar_def.numgrpgar
        And     grp_gar_def.numfor=gar_cntrt.numfor
        And     qttc_variable.numfor=gar_cntrt.numfor
		and     v_frmlgar.numfor = gar_cntrt.numfor_ref
	AND     grp_gar.numgrpgar=adhesion.numfor
	And	qttc_variable.numindiv=adhesion.numindiv
	and     adhesion.idadhesion = adhe_cntrt.idadhesion
	And	grp_gar.etendue = 2
        And	grp_gar.valide = 'O'
union
	SELECT	gar_cntrt.numgar,
		gar_cntrt.datapli,
		gar_cntrt.datper,
		gar_cntrt.nomgar,
		gar_cntrt.libelle,
		gar_cntrt.numfor,
		1+type,
                qttc_variable.monnaie,
                qttc_variable.monnaie_d,
         nat_calc,
		adhe_cntrt.numadhe
      FROM	gar_cntrt,adhesion,adhe_cntrt,qttc_variable, v_frmlgar
	WHERE	gar_cntrt.numfor=qttc_variable.numfor
        AND     gar_cntrt.valide = 'O'
	and	adhesion.numfor=gar_cntrt.numfor
	And	qttc_variable.numindiv=adhesion.numindiv
	and     adhesion.idadhesion = adhe_cntrt.idadhesion
	and     v_frmlgar.numfor = gar_cntrt.numfor_ref
        AND     not exists ( SELECT	1
				FROM	grp_gar_def
				where grp_gar_def.numfor=gar_cntrt.numfor)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR_COTI_INDV FOR ARTHUS.V_GAR_COTI_INDV
