CREATE function ARTHUS.f_pmt_compte
				(a_codope in number,
				 a_numcpte in number,
				 a_modpmt in number)
Return number
Is
	loc_nombre number;
Begin
	Begin
		Select 0
		Into loc_nombre
		From papier_ope
		Where codope=a_codope
		And numcpte=a_numcpte
		And modpmt=a_modpmt
		;
		Exception
			When no_data_found then loc_nombre:=1;
						Return(loc_nombre);
			When too_many_rows then loc_nombre:=0;
						Return(loc_nombre);
	End;
Return(loc_nombre);
End;
