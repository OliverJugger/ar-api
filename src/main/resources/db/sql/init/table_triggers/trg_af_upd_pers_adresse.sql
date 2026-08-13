CREATE TRIGGER ARTHUS.trg_af_upd_pers_adresse
AFTER UPDATE OF Type ON PERS_ADRESSE
FOR EACH ROW
   WHEN ( New.type in(1,2) and Old.type=3 ) DECLARE
  --
   CST_SCCS       CONSTANT VARCHAR2(120)          := '@(#)trg_af_upd_pers_adresse.sql 1.1    14/02/05';
   W_old_type         pers_adresse.type%TYPE      := :Old.type;
   W_new_type         pers_adresse.type%TYPE      := :new.type;
   W_old_idadresse    pers_adresse.idadresse%TYPE := :old.idadresse;

BEGIN
     Delete from adr_internationale
     where idadresse=W_old_idadresse;
END;