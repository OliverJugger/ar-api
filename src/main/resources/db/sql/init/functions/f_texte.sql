CREATE function ARTHUS.f_texte      (a_contexte in number,
					   a_numero in number,
					   a_code in number,
					   a_nom in varchar2,
 					   a_numrelance in number,
					   a_type in number default 0)
		RETURN	number
as
	idtexte number;
	loc_contexte number;
	old_contexte number;
	comm_contexte number;
	loc_code number;
	loc_nom varchar2(9);
	loc_numrelance number;
	loc_numero number;
BEGIN
	loc_contexte:=a_contexte;
	old_contexte:=a_contexte;
	comm_contexte:=a_contexte;
	loc_code:=a_code;
	loc_nom:=a_nom;
	loc_numrelance:=a_numrelance;
	loc_numero:=a_numero;
<<Debut>>
	begin
		SELECT param_texte.idtexte
		INTO idtexte
		FROM param_texte
		WHERE param_texte.contexte=loc_contexte
		AND param_texte.numero=loc_numero
		AND param_texte.code=loc_code
		AND param_texte.nom_crrr=nvl(loc_nom,param_texte.nom_crrr)
		AND param_texte.numrelance=
				nvl(loc_numrelance,param_texte.numrelance);
	exception
		when no_data_found then
			If (loc_contexte=10 and old_contexte=10) then
			begin
			Select  numfor_ref,
				10,
				''
			Into 	loc_numero,
				loc_contexte,
				old_contexte
			From	gar_cntrt
			Where	numfor=a_numero;
			Goto debut;
			Exception
			when no_data_found then old_contexte:='';
			Goto debut;
			End;
			Elsif (old_contexte is null and loc_contexte=10)
	/* On recupere le texte garantie au niveau general */
			Then
			begin
			loc_numero:=0;
			loc_contexte:=99;
			old_contexte:='';
			Goto debut;
			End;
			Elsif (old_contexte is null and loc_contexte=99)
	/* On recupere le texte du paragraphe au niveau general */
			Then
			begin
			loc_numero:=0;
			loc_contexte:=-99;
			old_contexte:='';
			Goto debut;
			End;
			Elsif (loc_contexte=2 and comm_contexte!=10) then
	/* On regarde s'il existe un texte particulier niveau produit */
			loc_contexte:=7;
			Select numprod
			Into loc_numero
			From contrat
			Where numgar=a_numero;
			Goto Debut;
			Elsif (loc_contexte=2 and comm_contexte=10) then
			loc_contexte:=7;
			Select numprod
			Into loc_numero
			From contrat,gar_cntrt
			Where contrat.numgar=gar_cntrt.numgar
			And numfor=a_numero;
			Goto Debut;
			Elsif (loc_contexte=7) then
	/* On regarde s'il existe un texte general */
			loc_contexte:=99;
			loc_numero:=0;
			Goto Debut;
			End if;
	End;
return idtexte;
END f_texte;
