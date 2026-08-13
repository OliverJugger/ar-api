CREATE procedure ARTHUS.P_INS_var_plein (
	I_numgar	IN	Number default Null
	)
AS
Cursor C_adhesion IS
Select	idadhesion,
	numgar,
	numadhe,
	date_adhe
From	adhe_cntrt
Where	numgar = nvl(I_numgar, numgar)
and	numgar in (120,121,122,123,128,130)
Order by
	numgar;
Cursor C_unmi(P_numgar IN Number, P_numadhe IN Number) IS
Select	debut,
	valeur
From	val_variable
Where	etendue = 4
and	clef = P_numadhe
and	numgar = Decode(P_numgar, 120,101, 121,102, 122,103,
					123,104, 130,118)
and	valide = 'O'
and	idvariable = Decode(P_numgar, 120,133, 121,131, 122,133,
					123,131, 128,133, 130,Null)
Order By
	debut Desc;
Rec_C_adhesion	C_adhesion%Rowtype;
Rec_C_unmi	C_unmi%Rowtype;
BEGIN
Open C_adhesion;
Loop
	Fetch C_adhesion Into Rec_C_adhesion;
	Exit When C_adhesion%NotFound;
	--
	Open C_unmi(Rec_C_adhesion.numgar, Rec_C_adhesion.numadhe);
	Fetch C_unmi Into Rec_C_unmi;
	If (C_unmi%Found) then
		Insert Into val_variable (
			Idvariable,
			Etendue,
			Clef,
			Statique,
			Debut,
			Fin,
			Valide,
			Valeur,
			Numgar )
		Values (
			413,
			13,
			Rec_C_adhesion.idadhesion,
			'O',
			Rec_C_unmi.debut,
			Null,
			'O',
			Rec_C_unmi.valeur,
			Rec_C_adhesion.numgar
			);
	Else
		Insert Into val_variable (
			Idvariable,
			Etendue,
			Clef,
			Statique,
			Debut,
			Fin,
			Valide,
			Valeur,
			Numgar )
		Values (
			413,
			13,
			Rec_C_adhesion.idadhesion,
			'O',
			Rec_C_adhesion.date_adhe,
			Null,
			'O',
			0,
			Rec_C_adhesion.numgar
			);
	End If;
	Close C_unmi;
End Loop;
Close C_adhesion;
END P_INS_var_plein;
/
