CREATE function ARTHUS.f_texte_variable   (a_texte in varchar2,
						a_contexte in number,
						a_cle in number)
		RETURN	varchar2
as
	loc_texte varchar2(78);
	loc_valeur varchar2(78);
	loc_variable varchar2(10);
	loc_type number;
BEGIN
	loc_texte:=a_texte;
	Loop
	Begin
	Select decode(
			instr(loc_texte,'$'),0,null,
			substr(loc_texte,instr(loc_texte,'$')+1,
			(instr(loc_texte,'(')-instr(loc_texte,'$')+1)-2))
	Into 	loc_variable
	From 	dual;
	If (loc_variable is null) then exit;
	End if;
	Select substr(loc_texte,instr(loc_texte,'(')+1,
				(instr(loc_texte,')')-instr(loc_texte,'(')+1)-2)
	Into 	loc_type
	From 	dual;
	loc_valeur:=
		pk_texte.f_eval_variable(loc_variable,a_contexte,a_cle,loc_type);
	Select 	replace(loc_texte,
			substr(loc_texte,instr(loc_texte,'$'),
				decode(loc_type,1,40,15)),
			loc_valeur)
	Into loc_texte
	From dual;
	End;
	End loop;
	Return loc_texte;
	Exception
	When no_data_found then loc_texte:='';
return loc_texte;
End f_texte_variable;
