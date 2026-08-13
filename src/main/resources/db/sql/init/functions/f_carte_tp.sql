CREATE function ARTHUS.f_carte_tp (
		a_numindiv	in number,
		a_codfrais	in varchar2,
		a_datsin	in date,
		a_idadhesion	in number default 0
				   )
return	number
as
	Cursor fetch_param is
	select	nvl(porte_param.numbene,0) numbene
	from	porte_adhesion,
		rqsm,
		secteurtp,
		porte_param
	where	a_codfrais in (
		select	codfrais
		from	natfrais
		where	natfrais.rubrique	= rqsm.codfrais)
	and	rqsm.numsec	= secteurtp.numsec
	and	secteurtp.numtp = porte_param.numbene
	and	porte_adhesion.numporte=porte_param.numporte
	and	a_datsin 	between	porte_adhesion.debut
				and	nvl(porte_adhesion.fin, a_datsin)
	and	porte_adhesion.numindiv	= (
			select	indvs.numassu
			from	indvs
			where	indvs.numindiv = a_numindiv)
	;
	loc_param fetch_param%rowtype;
	loc_numtp	number:=0;
begin
If (a_idadhesion!=0) then
	begin
	select	nvl(porte_param.numbene,0)
	into	loc_numtp
	from	porte_adhesion,
		rqsm,
		secteurtp,
		porte_param
	where	a_codfrais in (
		select	codfrais
		from	natfrais
		where	natfrais.rubrique	= rqsm.codfrais)
	and	rqsm.numsec	= secteurtp.numsec
	and	secteurtp.numtp = porte_param.numbene
	and	porte_adhesion.numporte=porte_param.numporte
	and	porte_adhesion.idadhesion=a_idadhesion
	and	a_datsin 	between	porte_adhesion.debut
				and	nvl(porte_adhesion.fin, a_datsin)
	and	porte_adhesion.numindiv	= (
			select	indvs.numassu
			from	indvs
			where	indvs.numindiv = a_numindiv)
	and	exists	(
			select	1
			from	adhe_cntrt_membre
			where	adhe_cntrt_membre.numindiv = a_numindiv
			and	adhe_cntrt_membre.idadhesion =
						 porte_adhesion.idadhesion
			)
	;

	exception when no_data_found then loc_numtp := 0;

	end;
Else
	for loc_param in fetch_param
	loop
	loc_numtp:=loc_param.numbene;
	End loop;

End if;

	return (loc_numtp);
end;
