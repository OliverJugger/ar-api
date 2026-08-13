CREATE Procedure ARTHUS.P_charge_variable (
		I_texte		IN texte.texte%Type
		)
IS
L_pos_$		Binary_integer := 0;
L_pos_#		Binary_integer := 0;
L_pos_debut	Binary_integer := 0;
L_par_ouverte	Binary_integer := 0;
L_par_fermee	Binary_integer := 0;
L_indice	Varchar2(100);
L_type		Number;
L_variable Varchar2(10);
L_fin_variable 		Number;
L_chaine	Varchar2(100);
L_len_chaine	Binary_integer;
L_nb_x		Number := 0;
O_indice	Number;
BEGIN
L_pos_# := Instr( I_texte, '#' );
If ( L_pos_# > 0 ) then
	L_type := 1;
	L_pos_debut := L_pos_#;
Else
	L_pos_$ := Instr( I_texte, '$' );
	If ( L_pos_$ > 0 ) then
		L_type := 2;
		L_pos_debut := L_pos_$;
	Else
		L_type := 0;
	End if;
End if;
If ( L_pos_debut > 0 ) then
	L_fin_variable := Instr( I_texte, ')', L_pos_debut ) - L_pos_debut;
	L_chaine := Substr( I_texte, L_pos_debut, L_fin_variable + 1 );
	Dbms_output.put_line( L_chaine );
	L_len_chaine := Length( L_chaine );
	L_par_ouverte := Instr( L_chaine, '(' );
	L_par_fermee := Instr( I_texte, ')' );
	L_variable := Substr( L_chaine,  2, L_par_ouverte -2 );
	Dbms_output.put_line( L_variable );
	L_indice := Substr( L_chaine, L_par_ouverte + 1, L_len_chaine - L_par_ouverte - 1 );
	Dbms_output.put_line( L_chaine||' '||L_variable||' '||L_indice );
	O_indice := to_number(L_indice);
	For L_nb_x IN L_pos_debut + L_fin_variable + 1 .. length(I_texte)
	Loop
		If ( Substr(I_texte, l_nb_x, 1 ) = 'x' ) then
			L_chaine := L_chaine || 'x';
		Else
			Exit;
		End if;
	End Loop;
	Dbms_output.put_line( L_chaine );
End if;
END P_charge_variable;
/
