CREATE function ARTHUS.f_ano_tiers_payant
			(a_numindiv in number,
			a_numporte in number,
			a_numgar in number,
			a_idadhesion in number)
Return Number
Is
loc_type number;
Begin
	begin
	select 21
	into loc_type
	from indvs
	where numindiv=a_numindiv
	and regime is null;
	exception
	when no_data_found then loc_type:=-1;
	end;

if (loc_type=-1) then
	begin
	select 22
	into loc_type
	from indvs
	where numindiv=a_numindiv
	and caisse is null;
	exception
	when no_data_found then loc_type:=-1;
	end;
end if;

if (loc_type=-1) then
	begin
	select 25
	into loc_type
	from indvs
	where numindiv=a_numindiv
	and matorg is null;
	exception
	when no_data_found then loc_type:=-1;
	end;
end if;

if (loc_type=-1) then
	begin
	select 26
	into loc_type
	from indvs
	where numindiv=a_numindiv
	and datnais is null;
	exception
	when no_data_found then loc_type:=-1;
	end;
end if;

if (loc_type=-1) then
	begin
	select 27
	into loc_type
	from indvs
	where numindiv=a_numindiv
	and prenom is null;
	exception
	when no_data_found then loc_type:=-1;
	end;
end if;

if (loc_type=-1) then
	begin
	select 26
	into loc_type
	from indvs
	where f_info_tiers_payant(a_numporte,a_numgar,10)=2
	and numindiv=a_numindiv
	and exists(select 1 from adhe_cntrt_membre b,adhe_cntrt_membre c,indvs a
		   where a.numindiv=b.numindiv
		   and b.typadr!=0
		   and b.idadhesion=c.idadhesion
		   and c.numindiv=a_numindiv
		   and c.typadr=0
		   and c.idadhesion=a_idadhesion
		   and a.datnais is null
		  );
	exception
	when no_data_found then loc_type:=-1;
	when too_many_rows then loc_type:=26;
	end;
end if;

if (loc_type=-1) then
	begin
	select 27
	into loc_type
	from indvs
	where f_info_tiers_payant(a_numporte,a_numgar,10)=2
	and numindiv=a_numindiv
	and exists(select 1 from adhe_cntrt_membre b,adhe_cntrt_membre c,indvs a
		   where a.numindiv=b.numindiv
		   and b.typadr!=0
		   and b.idadhesion=c.idadhesion
		   and c.numindiv=a_numindiv
		   and c.typadr=0
		   and c.idadhesion=a_idadhesion
		   and a.prenom is null
		  );
	exception
	when no_data_found then loc_type:=-1;
	when too_many_rows then loc_type:=27;
	end;
end if;

Return(loc_type);

End;
