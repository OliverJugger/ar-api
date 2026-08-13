CREATE function ARTHUS.f_evalue (
				a_val1	In Number,
				a_val2	In Number,
				a_operateur	In Varchar2
				)
Return Number
Is
loc_retour	Number(2) := 0;
BEGIN
If ( a_val1 is Null ) then
	Return( 1 );
End if;
If ( a_operateur = '<' ) then
	If ( a_val1 < a_val2 ) then
		loc_retour := 1;
	End if;
ElsIf ( a_operateur = '>' ) then
	If ( a_val1 > a_val2 ) then
		loc_retour := 1;
	End if;
ElsIf ( a_operateur = '=' ) then
	If ( a_val1 = a_val2 ) then
		loc_retour := 1;
	End if;
ElsIf ( a_operateur = '>=' ) then
	If ( a_val1 >= a_val2 ) then
		loc_retour := 1;
	End if;
ElsIf ( a_operateur = '<=' ) then
	If ( a_val1 <= a_val2 ) then
		loc_retour := 1;
	End if;
ElsIf ( a_operateur = '<>' ) then
	If ( a_val1 != a_val2 ) then
		loc_retour := 1;
	End if;
End if;
Return ( loc_retour );
END	f_evalue;
