CREATE TRIGGER ARTHUS.trg_bf_ins_compte_client
   BEFORE INSERT
   ON compte_client
   FOR EACH ROW






DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
BEGIN
:new.numutil := f_numutil;
END;