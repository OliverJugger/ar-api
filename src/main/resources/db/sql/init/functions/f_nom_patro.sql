CREATE function ARTHUS.f_nom_patro(a_numindiv in number)
Return Varchar2
Is
	loc_nom_patro varchar2(30);
Begin
	Begin
	Select decode(indvs.sexe,1,nom,
			nvl(nomjf,nom)
		     )
	Into loc_nom_patro
	From indvs
	Where numindiv=a_numindiv
	;
		Exception
		When no_data_found then
			loc_nom_patro:='Indéterminé';
			Return(loc_nom_patro);
	End;
Return(loc_nom_patro);
End;
