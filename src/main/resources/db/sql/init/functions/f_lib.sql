CREATE function ARTHUS.f_lib(
				a_mnemo 	in varchar2,
				a_code		in varchar2)
		RETURN	varchar2
is
	loc_lib	varchar2(45) := 'Indéterminée';
begin
   begin
	Begin
            select libelle
            into   loc_lib
            from   libelle_bis
            where  mnemo = a_mnemo
            and    code  = a_code;
	exception
	when no_data_found then
	Begin
            select libelle
            into   loc_lib
            from   v_libelle_bis
            where  mnemo = a_mnemo
            and    code  = a_code;
	exception
	when no_data_found then null;
	End;
	End ;
   end;
return(loc_lib);
end;
