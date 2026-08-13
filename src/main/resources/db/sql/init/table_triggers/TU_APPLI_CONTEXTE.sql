CREATE TRIGGER ARTHUS.TU_APPLI_CONTEXTE
before update
on appli_contexte
for each row
   WHEN ( (new.codapli != old.codapli) Or (new.ordre != old.ordre) ) DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
begin
Update 	applications
Set 	codapli = :new.codapli,
	sec = :new.ordre
Where	codapli = :old.codapli
and	fonction = :old.fonction
and	sec = :old.ordre;
end;