CREATE TRIGGER ARTHUS.trg_bf_ins_upd_def_grp_libelle
Before Insert or Update
ON def_grp_libelle
FOR EACH ROW






DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
BEGIN
If INSERTING then
	:new.creation := Sysdate;
	:new.maj := Sysdate;
Else
	:new.maj := Sysdate;
End if;
END;