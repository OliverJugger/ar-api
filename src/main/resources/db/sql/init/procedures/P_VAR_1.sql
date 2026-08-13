CREATE procedure ARTHUS.P_VAR_1 (
	I_numgar	IN	Number default Null,
	I_var1		IN	Number default Null,
	I_var2		IN	Number default Null,
	I_date		IN	Date default Null
	)
AS
Cursor C_var1 IS
Select	clef
From	val_variable
Where	etendue = 13
and	numgar = I_numgar
and	idvariable = I_var1;
--
--
Cursor C_var2(P_idadhesion IN Number) IS
Select	count(*)	nombre
From	val_variable
Where	etendue = 13
and	clef = P_idadhesion
and	numgar = I_numgar
and	idvariable = I_var2
and	debut = I_date;
--
Rec_C_var1	C_var1%Rowtype;
Rec_C_var2	C_var2%Rowtype;
BEGIN
Open C_var1;
Loop
	Fetch C_var1 Into Rec_C_var1;
	Exit When C_var1%NotFound;
	--
	Open C_var2(Rec_C_var1.clef);
	Fetch C_var2 Into Rec_C_var2;
	If (C_var2%NotFound) then
		Dbms_output.put_line(
			'Idadhesion = '|| Rec_C_var1.clef
			|| ' Pas d''idvariable ' || I_var2
			|| ' à la date ' || I_date);
	End If;
	Close C_var2;
End Loop;
Close C_var1;
END P_VAR_1;
/
