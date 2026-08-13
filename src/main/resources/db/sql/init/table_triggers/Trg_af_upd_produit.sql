CREATE TRIGGER ARTHUS.Trg_af_upd_produit
   AFTER UPDATE OF Deffet ON produit
   FOR EACH ROW
     WHEN ( New.deffet <> Old.deffet) DECLARE
   --
   CST_SCCS      CONSTANT VARCHAR2(120) := '@(#)trg_af_upd_produit.sql	1.1';
   W_numprod     Produit.numprod%TYPE := :Old.numprod;
   W_new_deffet  Produit.deffet%TYPE := Trunc(:New.deffet);
   W_old_deffet  Produit.deffet%TYPE := Trunc(:Old.deffet);
   --
BEGIN
 /* Appel du Package mettant a jour les differentes tables en relation avec
    produit*/
  PK_produit.P_UPD_relation_produit( I_numprod    => W_numprod,
                                     I_old_deffet => W_old_deffet,
                                     I_new_deffet => W_new_deffet);
END;