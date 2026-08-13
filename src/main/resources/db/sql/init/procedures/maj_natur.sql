CREATE procedure ARTHUS.maj_natur is
indiv		assu%rowtype;
begin
for indiv in	(select	numindiv,
			matorg,
			decode(typadr, '', 0, typadr)
		from	assu
		where	natur is null
		order by
			decode(typadr, '', 0, typadr)
		)
loop
	update	indvs
	set	natur = 1
	where	indvs.numindiv = indiv.numindiv
	and	not exists (
		select	1
		from	indvs b
		where	b.matorg = indiv.matorg
		and	b.numindiv != indiv.numindiv
	and	b.natur = 1);
	update	indvs
	set	natur = 2
	where	indvs.numindiv = indiv.numindiv
	and	natur is null
	and	exists (
		select	1
		from	indvs b
		where	b.matorg = indiv.matorg
	and	b.natur = 1);
	/* commit;
	Exception When no_data_found then null; */
end loop;
end;
/
