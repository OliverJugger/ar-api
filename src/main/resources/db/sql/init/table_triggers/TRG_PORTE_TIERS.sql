CREATE TRIGGER ARTHUS.TRG_PORTE_TIERS
	before insert or update
	on porte_tiers
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