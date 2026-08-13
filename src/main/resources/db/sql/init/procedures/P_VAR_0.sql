CREATE procedure ARTHUS.P_VAR_0 (
	I_idvariable	IN	Number default Null,
	I_numgar	IN	Number default Null,
	I_nombre	IN	Number default Null
	)
AS
Cursor C_adhesion IS
Select	idadhesion,
	numgar,
	numadhe,
	date_adhe
From	adhe_cntrt
Where	numgar = nvl(I_numgar, numgar);
--
Cursor C_var(P_idadhesion IN Number) IS
Select	count(*)	nombre
From	val_variable
Where	etendue = 13
and	clef = P_idadhesion
and	numgar = I_numgar
and	idvariable = I_idvariable;
--
Rec_C_adhesion	C_adhesion%Rowtype;
Rec_C_var	C_var%Rowtype;
BEGIN
Open C_adhesion;
Loop
	Fetch C_adhesion Into Rec_C_adhesion;
	Exit When C_adhesion%NotFound;
	--
	Open C_var(Rec_C_adhesion.idadhesion);
	Fetch C_var Into Rec_C_var;
	If (C_var%Found) then
		If ( Rec_C_var.nombre != I_nombre ) then
			Dbms_output.put_line(
			'Idadhesion = '|| Rec_C_adhesion.idadhesion					|| ' idvariable = ' || I_idvariable
			|| ' nombre = ' || Rec_C_var.nombre);
		End If;
	Else
			Dbms_output.put_line(
			'Idadhesion = '|| Rec_C_adhesion.idadhesion					|| ' idvariable = ' || I_idvariable
			|| ' nombre = ' || 0);
	End If;
	Close C_var;
End Loop;
Close C_adhesion;
END P_VAR_0;
/
