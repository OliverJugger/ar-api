CREATE procedure ARTHUS.ins_appli_client(a_codapli in varchar2, a_fonction in varchar2) is
begin
insert into appli_client (
	codapli,
	fonction,
	client
	)
select	a_codapli,
	a_fonction,
	libelle.code
from	libelle
where	libelle.mnemo = 'CLIENT'
and	libelle.code  != 0
and 	libelle.sens  = 1
and not exists (
	select	1
	from	appli_client
	where	codapli = a_codapli
	and	fonction = a_fonction
	and	client = libelle.code)
;
end;
/
