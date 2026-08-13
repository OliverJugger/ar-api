CREATE TRIGGER ARTHUS.TI_BF_compte_tiers
   BEFORE INSERT
   ON compte_tiers
   FOR EACH ROW







DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
BEGIN
If ( :new.idmvt Is Null ) then
	Select	idmvt.nextval
	Into	:new.idmvt
	From 	Dual;
End if;
:new.numutil := f_numutil;
END;