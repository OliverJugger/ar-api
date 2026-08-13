CREATE function ARTHUS.f_compte_ope(a_codope in number,a_numcpte in number)
Return number
Is
	loc_nombre number;
Begin
	Begin
	Select 0
	Into loc_nombre
	From type_ope
	Where numope=a_codope
	And numcpte=a_numcpte
	;
		Exception
			When no_data_found then loc_nombre:=1;
						Return(loc_nombre);
			When too_many_rows then loc_nombre:=0;
						Return(loc_nombre);
	End;
Return(loc_nombre);
End;
