CREATE function ARTHUS.f_valide_texte      (a_contexte in number,
					   a_numero in number,
					   a_code in number,
					   a_nom in varchar2,
 					   a_numrelance in number,
					   a_type in number default 0)
		RETURN	number
as
	idtexte number;
BEGIN
begin
	begin
	SELECT param_texte.idtexte
	INTO idtexte
	FROM valide_texte,param_texte
	WHERE valide_texte.contexte=a_contexte
	AND valide_texte.numero=a_numero
	AND param_texte.code=a_code
	AND param_texte.nom_crrr=a_nom
	AND param_texte.numrelance=a_numrelance
	AND param_texte.idtexte=valide_texte.idtexte;
	end;
	Exception
		When no_data_found then
	if (a_contexte=10)
	then
	begin
	SELECT param_texte.idtexte
	INTO idtexte
	FROM param_texte,valide_texte
	WHERE valide_texte.contexte=2
	AND param_texte.code=a_code
	AND param_texte.nom_crrr=a_nom
	AND param_texte.numrelance=a_numrelance
	AND param_texte.idtexte=valide_texte.idtexte
	AND param_texte.contexte=valide_texte.contexte
	AND param_texte.numero=valide_texte.numero
	AND param_texte.numero=(select numgar from gar_cntrt
				where gar_cntrt.numfor=a_numero);
	Exception
		When no_data_found then
	Begin
	SELECT param_texte.idtexte
	INTO idtexte
	FROM valide_texte,param_texte
	WHERE valide_texte.contexte=7
	AND param_texte.code=a_code
	AND param_texte.nom_crrr=a_nom
	AND param_texte.numrelance=a_numrelance
	AND param_texte.idtexte=valide_texte.idtexte
	AND param_texte.contexte=valide_texte.contexte
	AND param_texte.numero=valide_texte.numero
	AND param_texte.numero=(select numprod from grnts,gar_cntrt
				where grnts.numgar=gar_cntrt.numgar
				and gar_cntrt.numfor=a_numero);
	Exception
		When no_data_found then
			Begin
				SELECT param_texte.idtexte
				INTO idtexte
				FROM valide_texte,param_texte
				WHERE param_texte.contexte=99
				AND param_texte.code=a_code
				AND param_texte.nom_crrr=a_nom
				AND param_texte.numrelance=a_numrelance
				AND param_texte.idtexte=valide_texte.idtexte
				AND param_texte.contexte=valide_texte.contexte
				AND param_texte.numero=valide_texte.numero
				AND param_texte.numero=0;
			Exception
			When no_data_found then idtexte:=0;
		End;
	end;
	end;
	else
	if (a_contexte=2)
	then
	Begin
	SELECT param_texte.idtexte
	INTO idtexte
	FROM valide_texte,param_texte
	WHERE valide_texte.contexte=7
	AND param_texte.code=a_code
	AND param_texte.nom_crrr=a_nom
	AND param_texte.numrelance=a_numrelance
	AND param_texte.idtexte=valide_texte.idtexte
	AND param_texte.contexte=valide_texte.contexte
	AND param_texte.numero=valide_texte.numero
	AND param_texte.numero=(select numprod from grnts
				where grnts.numgar=a_numero);
	Exception
		When no_data_found then
	Begin
	SELECT param_texte.idtexte
	INTO idtexte
	FROM valide_texte,param_texte
	WHERE param_texte.contexte=99
	AND param_texte.code=a_code
	AND param_texte.nom_crrr=a_nom
	AND param_texte.numrelance=a_numrelance
	AND param_texte.idtexte=valide_texte.idtexte
	AND param_texte.contexte=valide_texte.contexte
	AND param_texte.numero=valide_texte.numero
	AND param_texte.numero=0;
	Exception
		when no_data_found then idtexte:=0;
	end;
	end;
	else
	begin
	SELECT param_texte.idtexte
	INTO idtexte
	FROM valide_texte,param_texte
	WHERE param_texte.contexte=99
	AND param_texte.code=a_code
	AND param_texte.nom_crrr=a_nom
	AND param_texte.numrelance=a_numrelance
	AND param_texte.idtexte=valide_texte.idtexte
	AND param_texte.contexte=valide_texte.contexte
	AND param_texte.numero=valide_texte.numero
	AND param_texte.numero=0;
	Exception
		when no_data_found then idtexte:=0;
	end;
end if;
end if;
end;
return idtexte;
END f_valide_texte;
