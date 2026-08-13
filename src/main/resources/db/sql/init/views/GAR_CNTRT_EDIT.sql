CREATE FORCE VIEW ARTHUS.GAR_CNTRT_EDIT AS
SELECT gc.numfor, gc.numfor_ref, gc.numgar, gc.numgar_ref, gc.nomgar, gc.datapli, gc.libelle, gc.type, gc.valide, gc.obligatoire, gc.datper, ind_edit, ind_option, num_ordre, lib_edit, img_dgar
	   FROM Gar_Cntrt gc
			inner join(SELECT numfor, ind_edit, ind_option, num_ordre, lib_edit, img_dgar FROM Garanties
					   UNION ALL
					   SELECT numfor, ind_edit, ind_option, num_ordre, lib_edit, img_dgar
					   FROM Formule) fg
			on gc.NUMFOR = fg.NUMFOR
GO
CREATE OR REPLACE PUBLIC SYNONYM GAR_CNTRT_EDIT FOR ARTHUS.GAR_CNTRT_EDIT
