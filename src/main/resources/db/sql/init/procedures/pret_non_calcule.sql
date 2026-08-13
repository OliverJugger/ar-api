CREATE procedure ARTHUS.pret_non_calcule
IS
Cursor C_pret IS
	Select	numgar,
		idadhesion,
		debut,
		fin
	From	qttc_global
	Where	numgar in(149,160,161)
	and	comptant != 'R'
	Order By
		numgar,
		debut;
Rec_C_pret	C_pret%RowType;
L_idadhesion	Number := 0;
L_fin		Date;
BEGIN
Open C_pret;
Loop
	Fetch C_pret Into Rec_C_pret;
	Exit When C_pret%NotFound;
	If ( Rec_C_pret.idadhesion != L_idadhesion ) then
		L_idadhesion := Rec_C_pret.idadhesion;
	Else
		If ( Rec_C_pret.debut != L_fin + 1 ) then
			Dbms_output.put_line(
			'Idahesion ' || Rec_C_pret.idadhesion
			|| ' Fin ' || L_fin
			|| ' Debut ' || Rec_C_pret.debut);
		End if;
	End if;
	L_fin := Rec_C_pret.fin;
End Loop;
END;
/
