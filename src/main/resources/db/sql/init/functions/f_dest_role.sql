CREATE Function ARTHUS.f_dest_role 	(
		I_numindiv		In	Number
		)
Return Number
Is
L_role	Number;
BEGIN
Begin
Select 	type
Into   	L_role
From   	courr_dest
Where  	numindiv=I_numindiv;
Exception When No_data_found then L_role := 0;
End;
Return( L_role);
END;
