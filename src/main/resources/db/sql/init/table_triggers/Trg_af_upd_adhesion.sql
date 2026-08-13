CREATE TRIGGER ARTHUS.Trg_af_upd_adhesion
   AFTER UPDATE OF Datapli ON Adhesion
   FOR EACH ROW
    WHEN ( New.datapli <> Old.datapli) DECLARE
   --
   CST_SCCS     CONSTANT VARCHAR2(120) := '@(#)trg_af_upd_adhesion.sql	1.1    00/12/06';
   W_idadhesion	 adhesion.idadhesion%TYPE := :Old.idadhesion;
   W_numindiv    adhesion.numindiv%TYPE   := :Old.numindiv;
   W_numgar      adhesion.numgar%TYPE     := :Old.numgar;
   W_new_datapli adhesion.datapli%TYPE    := Trunc(:New.datapli);
   W_old_datapli adhesion.datapli%TYPE    := Trunc(:Old.datapli);
   --
BEGIN
 /* Appel du Package mettant a jour la table Val_variable */
  PK_adhesion.P_UPD_val_variable( I_idadhesion  => W_idadhesion,
                                  I_numgar      => W_numgar,
                                  I_numindiv    => W_numindiv,
                                  I_old_datapli => W_old_datapli,
                                  I_new_datapli => W_new_datapli);
END;