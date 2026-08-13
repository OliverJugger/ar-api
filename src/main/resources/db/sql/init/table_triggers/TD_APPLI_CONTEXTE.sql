CREATE TRIGGER ARTHUS.TD_APPLI_CONTEXTE
before delete
on appli_contexte
for each row





DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
begin
	delete	applications
	where	codapli = :old.codapli
	and	fonction = :old.fonction
	and	sec = :old.ordre
	;
end;