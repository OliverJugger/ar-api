CREATE function ARTHUS.f_affiche_texte(a_texte in varchar2,
				a_contexte in number,
				a_contexte_base in number,
				a_cle in number,
				a_niveau in number,
				a_nombre in number default 1,
				a_test in number default 1,
				a_cle1 in number default 0,
				a_debut in date default sysdate,
				a_fin in date default sysdate,
				a_cle2 in number default 0,
				a_idtexte in number default 0,
				a_numenvoi in number default 0)
return varchar2
is loc_texte varchar2(80);
Begin
	loc_texte:=pk_texte.f_decode_texte(a_texte,a_contexte,a_contexte_base,
			a_cle,a_niveau,a_nombre,a_test,a_cle1,a_debut,
			a_fin,a_cle2,a_idtexte,a_numenvoi);
	return(loc_texte);
	Exception
	When no_data_found then loc_texte:='';
	Return(loc_texte);
end;
