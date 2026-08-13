CREATE TRIGGER ARTHUS.trg_af_upd_adr5_internationale
AFTER UPDATE OF ADR5 ON ADR_INTERNATIONALE
FOR EACH ROW
   WHEN ( New.ADR5 <> OLD.ADR5) DECLARE
  --
   CST_SCCS       CONSTANT VARCHAR2(120)          := '@(#)trg_af_upd_adr5_internationale.sql 1.1    14/02/05';
   W_old_adr5        adr_internationale.adr5%TYPE := :Old.adr5;
   W_new_adr5        adr_internationale.adr5%TYPE := :New.adr5;

BEGIN
     Update libelle_bis
     Set    libelle = W_new_adr5
     Where  mnemo   ='VILLE_INT'
     And    libelle = W_old_adr5;
END;