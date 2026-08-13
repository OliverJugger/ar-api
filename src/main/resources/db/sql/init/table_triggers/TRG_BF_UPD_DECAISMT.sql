CREATE TRIGGER ARTHUS.TRG_BF_UPD_DECAISMT
before update of refpmt, numedit, datpay on decaismt
for each row
BEGIN
if :new.refpmt is not null then
	:new.flagpay := 1;
        if :old.flagpay = -1 then
            :new.dataffec := sysdate; -- ACA evolution compta
        end if;
else
	:new.flagpay := -1;
end if;
if ( :new.numedit != 0 and :old.numedit = 0 ) then
	:new.datedit := trunc(sysdate);
elsif ( :new.numedit = 0 ) then
	:new.datedit := null;
end if;
--
Begin
Update 	affectation
Set	dataffec = :new.datpay
Where	affectation.numdecaismt = :new.numdecaismt
and	affectation.dataffec <= :new.datpay;
End;
--
END;