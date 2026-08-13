CREATE FORCE VIEW ARTHUS.V_GAR_COTI AS
SELECT	grp_gar.clef numgar,
		grp_gar.datapli,
		grp_gar.datper,
		grp_gar.nomgrpgar nomgar,
		grp_gar.libelle,
		grp_gar.numgrpgar numfor,
		1 ordre,
                qttc_variable.monnaie,
                qttc_variable.monnaie_d,
        nat_calc
        FROM	grp_gar,grp_gar_def,gar_cntrt,qttc_variable, v_frmlgar
        Where   grp_gar.numgrpgar=grp_gar_def.numgrpgar
        And     grp_gar_def.numfor=gar_cntrt.numfor
        And     qttc_variable.numfor=gar_cntrt.numfor
        And     grp_gar_def.numfor=qttc_variable.numfor
		and     v_frmlgar.numfor = gar_cntrt.numfor_ref
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
        nat_calc
      FROM	gar_cntrt,qttc_variable, v_frmlgar
	WHERE	gar_cntrt.numfor=qttc_variable.numfor
        AND     gar_cntrt.valide = 'O'
		and     v_frmlgar.numfor = gar_cntrt.numfor_ref
        AND     not exists ( SELECT	1
				FROM	grp_gar_def
				where grp_gar_def.numfor=gar_cntrt.numfor)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR_COTI FOR ARTHUS.V_GAR_COTI
