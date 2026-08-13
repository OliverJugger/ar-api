CREATE function ARTHUS.f_chequier(a_numcpte in number,a_modaffec in number)
Return number
Is
	loc_nombre number;
Begin
	begin
		select numchq
		Into   loc_nombre
		From   v_chequier
		Where  numcpte = a_numcpte
		and    modaffec = a_modaffec;
		Exception
			When no_data_found then loc_nombre:=-1;
						Return(loc_nombre);
			When too_many_rows then loc_nombre:=-2;
						Return(loc_nombre);
	end;
Return(loc_nombre);
End;
