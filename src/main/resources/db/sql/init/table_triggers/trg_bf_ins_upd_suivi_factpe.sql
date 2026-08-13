CREATE TRIGGER ARTHUS.trg_bf_ins_upd_suivi_factpe
before insert or update
on suivi_fact_tpe
for each row




DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
Begin
	:new.dattrait := sysdate;
End;