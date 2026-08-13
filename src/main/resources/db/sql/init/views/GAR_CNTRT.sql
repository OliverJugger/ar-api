CREATE FORCE VIEW ARTHUS.GAR_CNTRT AS
SELECT gar_cntrt_ref.numfor, gar_cntrt_ref.numfor_ref,
          gar_cntrt_ref.numgar, gar_cntrt_ref.numgar numgar_ref,
          gar_cntrt_ref.nomgar, gar_cntrt_ref.datapli, gar_cntrt_ref.libelle,
          gar_cntrt_ref.TYPE, gar_cntrt_ref.valide, gar_cntrt_ref.obligatoire,
          gar_cntrt_ref.datper
     FROM gar_cntrt_ref
   UNION
   SELECT adhe_coll_gar.numfor, adhe_coll_gar.numfor_ref,
          adhe_coll_gar.numgar, adhe_coll_gar.numgar_ref,
          gar_cntrt_ref.nomgar, adhe_coll_gar.datapli, gar_cntrt_ref.libelle,
          gar_cntrt_ref.TYPE, adhe_coll_gar.valide, adhe_coll_gar.obligatoire,
          adhe_coll_gar.datper
     FROM adhe_coll_gar, gar_cntrt_ref
    WHERE adhe_coll_gar.numfor_ref = gar_cntrt_ref.numfor
          WITH CHECK OPTION
GO
CREATE OR REPLACE PUBLIC SYNONYM GAR_CNTRT FOR ARTHUS.GAR_CNTRT
