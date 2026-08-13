CREATE FORCE VIEW ARTHUS.V_ASSUR_DELEGAT AS
Select	gar_cntrt.numfor,
		pers_organisme.numorg numass
From	gar_cntrt,
		formule,
		pers_organisme
Where	gar_cntrt.type = 1
and 	decode(gar_cntrt.numgar,gar_cntrt.numgar_ref,gar_cntrt.numfor,gar_cntrt.numfor_ref) = formule.numfor
and		pers_organisme.numindiv = formule.numass
and		pers_organisme.remb_prest = 1
group by pers_organisme.numorg, gar_cntrt.numfor
Union all
Select	gar_cntrt.numfor,
		pers_organisme.numorg numass
From	gar_cntrt,
		garanties,
		pers_organisme
Where	gar_cntrt.type = 2
and 	decode(gar_cntrt.numgar,gar_cntrt.numgar_ref,gar_cntrt.numfor,gar_cntrt.numfor_ref) = garanties.numfor
and		pers_organisme.numindiv = garanties.numass
and		pers_organisme.remb_prest = 1
group by pers_organisme.numorg, gar_cntrt.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ASSUR_DELEGAT FOR ARTHUS.V_ASSUR_DELEGAT
