CREATE TRIGGER ARTHUS.trg_af_upd_adhe_cntrt
AFTER UPDATE ON adhe_cntrt
FOR EACH ROW







DECLARE
  --
   W_idadhesion           Adhe_cntrt.idadhesion%TYPE := :Old.idadhesion;
   W_old_date_adhe        Adhe_cntrt.date_adhe%TYPE  := Trunc(:Old.date_adhe);
   W_new_date_adhe        Adhe_cntrt.date_adhe%TYPE  := Trunc(:New.date_adhe);
  --
   CST_SCCS   CONSTANT VARCHAR2(120) := '@(#)trg_af_upd_adhe_cntrt.sql	1.1    00/12/06';
  --
BEGIN
   -- Procedure "Ins_histo_export" provenant de l'eclatement du Script
   -- Trg_adhe_cntrt.sql en autant de Script que de trigger.
   Ins_histo_export( 31, :new.idadhesion );
   --
   IF (W_old_date_adhe <> W_new_date_adhe) THEN
      PK_Adhesion.P_Upd_adhesion( I_idadhesion    => W_idadhesion,
                                  I_old_date_adhe => W_old_date_adhe,
                                  I_new_date_adhe => W_new_date_adhe
                                );
   END IF;
END;