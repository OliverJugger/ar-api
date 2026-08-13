CREATE TRIGGER ARTHUS.Trg_af_upd_gar_cntrt
   AFTER UPDATE OF Datapli ON Gar_cntrt_ref
   FOR EACH ROW
   WHEN ( New.datapli <> Old.datapli) DECLARE
   --
   CST_SCCS      CONSTANT VARCHAR2(120) := '@(#)trg_af_upd_gar_cntrt.sql 1.1    00/12/06';
   W_numgar      Gar_cntrt_ref.numgar%TYPE  := :Old.numgar;
   W_numfor      Gar_cntrt_ref.numfor%TYPE  := :Old.numfor;
   W_type      Gar_cntrt_ref.type%TYPE    := :Old.type;
   W_new_datapli Gar_cntrt_ref.datapli%TYPE := Trunc(:New.datapli);
   W_old_datapli Gar_cntrt_ref.datapli%TYPE := Trunc(:Old.datapli);
   --
BEGIN
  /* Appel du Package mettant a jour les differentes tables en relation avec
     la table Gar_cntrt */
  PK_contrat.P_UPD_relation_Gar_cntrt( I_numgar      => W_numgar,
                                       I_numfor      => W_numfor,
                                       I_type        => W_type,
                                       I_old_datapli => W_old_datapli,
                                       I_new_datapli => W_new_datapli);
END;