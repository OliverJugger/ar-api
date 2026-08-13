CREATE TRIGGER ARTHUS.trg_bd_dfrb
before delete
on "ARTHUS"."DEFRUB"
for each row








declare
begin
	Delete sqrb
	Where numfor = :old.numfor
	And codfrais = :old.codfrais;
end;