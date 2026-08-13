CREATE function ARTHUS.f_remplace_texte (a_texte in varchar2,
						a_contexte in number,
						a_cle in number,
						t_tableau in pk_texte.donnee)
return varchar2
is
	loc_texte varchar2(100);
BEGIN
	loc_texte:=a_texte;
	If t_tableau(5) is not null
	Then
		loc_texte:=t_tableau(5);
		return(loc_texte);
	Else
	Select 	replace(loc_texte,
			substr(loc_texte,instr(loc_texte,pk_texte.t_tableau(1)),
				decode(pk_texte.t_tableau(1),'$',
				decode(pk_texte.t_tableau(2),1,40,15),
					  /* length(pk_texte.t_tableau(4)), */
					 pk_texte.t_tableau(3))),
			pk_texte.t_tableau(4))
	Into loc_texte
	From dual;
	End if;
Return(loc_texte);
END;
