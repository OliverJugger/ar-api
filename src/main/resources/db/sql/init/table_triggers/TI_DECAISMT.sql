CREATE TRIGGER ARTHUS.TI_DECAISMT
before insert on decaismt
for each row








begin
	if :new.refpmt is not null then
		:new.flagpay := 1;
	else
		:new.flagpay := -1;
	end if;
end;