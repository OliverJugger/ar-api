CREATE TRIGGER ARTHUS.TRG_LIBELLE
	before insert or update
	on libelle
	for each row








begin
	if ( :new.creation is null )
	then
	:new.creation := trunc(sysdate);
	:new.maj := trunc(sysdate);
	else
	:new.maj := trunc(sysdate);
	end if;
	end;