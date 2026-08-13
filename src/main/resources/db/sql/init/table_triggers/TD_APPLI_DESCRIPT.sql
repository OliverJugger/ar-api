CREATE TRIGGER ARTHUS.TD_APPLI_DESCRIPT
before delete
on appli_descript
for each row








begin
	delete	applications
	where	codapli = :old.codapli
	;
end;