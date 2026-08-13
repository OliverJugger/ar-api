CREATE FORCE VIEW ARTHUS.V_GAR_COTI2 AS
SELECT	grp_gar.clef numgar,
		grp_gar.datapli,
		grp_gar.datper,
		grp_gar.nomgrpgar nomgar,
		grp_gar.libelle,
		grp_gar.numgrpgar numfor,
		1 ordre,
                ARTHUS.pk_qttc.F_SEL_natcalc(ARTHUS.pk_qttc.F_SEL_numfor(gar_cntrt.numgar,gar_cntrt.numfor)) nat_calc
	FROM	grp_gar,grp_gar_def,gar_cntrt
        Where   grp_gar.numgrpgar=grp_gar_def.numgrpgar
        And     grp_gar_def.numfor=gar_cntrt.numfor
	And	grp_gar.etendue = 2
	--and	grp_gar.valide = 'O'
union
	SELECT	gar_cntrt.numgar,
		gar_cntrt.datapli,
		gar_cntrt.datper,
		gar_cntrt.nomgar,
		gar_cntrt.libelle,
		gar_cntrt.numfor,
		1+type,
                ARTHUS.pk_qttc.F_SEL_natcalc(ARTHUS.pk_qttc.F_SEL_numfor(gar_cntrt.numgar,gar_cntrt.numfor))
	FROM	gar_cntrt
	WHERE	gar_cntrt.numfor in (select numfor from frml_prime where base is not null)
        --And gar_cntrt.valide = 'O'
	and	not exists ( SELECT	1
				FROM	grp_gar_def
				where grp_gar_def.numfor=gar_cntrt.numfor)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR_COTI2 FOR ARTHUS.V_GAR_COTI2
