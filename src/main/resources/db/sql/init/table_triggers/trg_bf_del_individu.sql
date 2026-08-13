CREATE TRIGGER ARTHUS.trg_bf_del_individu
Before delete
on individu
for each row







DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
begin
	Delete 	rib
	Where 	numindiv = :old.numindiv;
end;