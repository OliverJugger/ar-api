CREATE procedure ARTHUS.ins_porte_tiers(a_numporte in number, a_numcaisse in number) is
begin
insert into porte_tiers
(numporte, numindiv, type_modif, creation, maj)
select 	a_numporte,
	trpnt.numindiv,
	1,
	trunc(sysdate),
	trunc(sysdate)
from 	trpnt
where 	caisse = a_numcaisse
and 	type_tiers=1
and not exists	(
	select 	1
	from 	porte_tiers
	where 	numporte = a_numporte
	and 	numindiv = trpnt.numindiv
		);
end;
/
