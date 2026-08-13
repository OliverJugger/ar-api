CREATE function ARTHUS.f_nom_marital(a_numindiv in number)
Return Varchar2
Is
	loc_nom_marital varchar2(30);
Begin
	Begin
	Select decode(indvs.sexe,1,'',decode(nomjf,'','',nom))
	Into loc_nom_marital
	From indvs
	Where numindiv=a_numindiv
	;
		Exception
		When no_data_found then
			loc_nom_marital:='Indéterminé';
			Return(loc_nom_marital);
	End;
Return(loc_nom_marital);
End;
