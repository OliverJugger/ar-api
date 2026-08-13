CREATE TRIGGER ARTHUS.trg_porte_natfrais
	before insert or update
	on porte_natfrais
	for each row








begin
	if ( :new.creation is null )
	then
	:new.creation := sysdate;
	:new.maj := sysdate;
	:new.numutil := f_numutil;
	else
	:new.maj := sysdate;
	end if;
	end;