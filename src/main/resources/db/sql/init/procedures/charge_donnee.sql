CREATE procedure ARTHUS.charge_donnee(a_texte in varchar2,
					  a_contexte_base in number,
					  a_cle in number,
					  t_tableau  out pk_texte.donnee)
as
	loc_valeur varchar2(78);
	loc_texte varchar2(78);
	loc_variable varchar2(10);
	loc_specif varchar2(4);
	type_donnee varchar2(1);
	loc_type number;
	loc_longueur number;
	loc_cle_logique number;
BEGIN
	loc_texte:=a_texte;
	Select decode(instr(loc_texte,'#'),0,
				decode(instr(loc_texte,'$'),0,null,'$'),'#')
	Into type_donnee
	From dual;
	Select decode(
			instr(loc_texte,type_donnee),0,null,
			substr(loc_texte,instr(loc_texte,type_donnee)+1,
			(instr(loc_texte,'(',instr(loc_texte,type_donnee),1)-
		instr(loc_texte,type_donnee)+1)-2))
	Into 	loc_variable
	From 	dual;
	If (loc_variable is null) then
		loc_valeur:='';
	Else
	Select substr(loc_texte,instr(loc_texte,'(',
					instr(loc_texte,type_donnee),1)+1,
				(instr(loc_texte,')',
					instr(loc_texte,type_donnee),1)-
			instr(loc_texte,'(',instr(loc_texte,type_donnee),1)+1)-2)
	Into 	loc_type
	From 	dual;
If (type_donnee='#')
Then
	Select 	c.sens,a.sens,c.tableau
	Into	loc_longueur,loc_cle_logique,loc_specif
	From	libelle c,
		libelle_bis a,
		libelle_bis b,
		libelle
	Where	c.mnemo='D_'||f_mnemo_donnee(libelle.code)
	And	c.code=loc_type
	And	a.code=loc_variable
	And	a.mnemo='DON_BASE'
	And	a.sens=libelle.code
	And	libelle.mnemo='CLE_BASE'
	And	libelle.sens=b.sens
	and 	b.mnemo='DON_BASE'
	and	libelle.tableau=0
	Union
	Select 	c.sens,to_number(libelle.codapli),c.tableau
	From	libelle c,
		libelle_bis a,
		libelle_bis b,
		libelle
	Where	c.mnemo='D_'||f_mnemo_donnee(libelle.code)
	And	c.code=loc_type
	And	a.code=loc_variable
	And	a.mnemo='DON_BASE'
	And	a.sens=libelle.code
	And	libelle.mnemo='CLE_BASE'
	And	libelle.sens=b.sens
	and 	b.mnemo='DON_BASE'
	and	libelle.tableau>0;
	If (loc_specif is not null)
	Then
		loc_texte:=loc_specif;
	Else
	loc_valeur:=
		pk_texte.f_eval_donnee
				(loc_cle_logique,loc_type,a_contexte_base,a_cle
				);
	End if;
Else
	loc_valeur:=
		pk_texte.f_eval_variable(loc_variable,a_contexte_base,a_cle,loc_type
					);
	End if;
End if;
/*
If (loc_valeur is not null)
Then
	While (length(loc_valeur)<loc_longueur)
	Loop
		loc_valeur:=f_complete_donnee(loc_valeur,loc_longueur);
	End loop;
End if;
*/
	t_tableau(1):=type_donnee;
	t_tableau(2):=loc_type;
	t_tableau(3):=loc_longueur;
	t_tableau(4):=nvl(loc_valeur,loc_specif);
	t_tableau(5):=loc_specif;
END;
/
