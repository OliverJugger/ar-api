CREATE Function ARTHUS.f_type_adresse 	(
		I_numindiv		In	Number
		)
Return Number
Is
L_type	Number;
BEGIN
Begin
Select 	type
Into   	L_type
From   	pers_adresse
Where  	numindiv=I_numindiv
And     defaut='O';
Exception When No_data_found then L_type := 0;
End;
Return( L_type);
END;
