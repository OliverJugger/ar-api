CREATE procedure ARTHUS.ins_param_compte is
soc	societe%rowtype;
ope	libelle%rowtype;
modpmt	libelle%rowtype;
begin
for soc in	(select numsoc
		 from 	societe)
loop
	for ope in	(select code	codope,
				sign(sens)	sens
			 from	libelle
			 where	mnemo = 'OPE'
			 and	code > 0
			 and	sens in (1, -1))
	loop
		for modpmt in	(select code	modpmt
			 	from	libelle
			 	where	mnemo = 'MREGL'
			 	and	code > 0
			 	and	ope.sens = 1
				UNION
				select	code
				from	libelle
				where	mnemo = 'MOPM'
			 	and	code > 0
				and	ope.sens = -1)
		loop
		Insert into param_compte (
			numsoc,
			numorg,
			numgar,
			codope,
			modpmt)
		Select	soc.numsoc,
			0,
			0,
			ope.codope,
			modpmt.modpmt
		From	dual;
		end loop;
	end loop;
end loop;
end;
/
