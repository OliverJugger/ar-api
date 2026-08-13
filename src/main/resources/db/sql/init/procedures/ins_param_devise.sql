CREATE procedure ARTHUS.ins_param_devise is
soc	societe%rowtype;
begin
for soc in	(select numsoc
		 from 	societe)
loop
	Insert into param_devise
	Select soc.numsoc,
		0,
		0,
		dfdev,
		'01-jan-01'
	From prmt;
end loop;
end;
/
