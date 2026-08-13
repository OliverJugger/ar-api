CREATE TRIGGER ARTHUS.trg_af_upd_adr4_internationale
AFTER UPDATE OF ADR4 ON ADR_INTERNATIONALE
FOR EACH ROW
   WHEN ( New.ADR4 <> OLD.ADR4) DECLARE
  --
   CST_SCCS       CONSTANT VARCHAR2(120)          := '@(#)trg_af_upd_adr4_internationale.sql 1.1    14/02/05';
   W_old_adr4        adr_internationale.adr4%TYPE := :Old.adr4;
   W_new_adr4        adr_internationale.adr4%TYPE := :New.adr4;

BEGIN
     Update libelle_bis
     Set    code  = W_new_adr4
     Where  mnemo ='VILLE_INT'
     And    code  = W_old_adr4;
END;