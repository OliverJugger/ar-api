CREATE function ARTHUS.f_type_rattach_cour
							(
							p_idtexte	in number
							)
return number
is
loc_type_rattach 	number(2);
loc_contexte		number(4);
begin
--
select distinct param_texte.contexte
into loc_contexte
from param_texte, valide_texte
where param_texte.idtexte = valide_texte.idtexte
and param_texte.idtexte = p_idtexte;
--
If (loc_contexte in (99,-99)) then
	loc_type_rattach:=1;
elsif	(loc_contexte in (2,7,10)) then
	loc_type_rattach:=2;
else
	loc_type_rattach:=3;
end if;
--
return loc_type_rattach;
--
Exception
		When no_data_found then
			loc_type_rattach:=3;
			return(loc_type_rattach);

END f_type_rattach_cour;
