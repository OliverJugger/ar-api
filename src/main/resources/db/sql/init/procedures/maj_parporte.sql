CREATE procedure ARTHUS.maj_parporte
As
Cursor C_soc IS
Select	numsoc,
	numreg,
	numorg
From	parporte
Group By
	numsoc,
	numreg,
	numorg;
Cursor C_porte IS
Select	numsoc,
	numreg,
	numorg,
	numporte,
	numemetteur
From	parporte
Where	numporte > 0
Group By
	numsoc,
	numreg,
	numorg,
	numporte,
	numemetteur;
Rec_C_soc C_soc%Rowtype;
Rec_C_porte C_porte%Rowtype;
BEGIN
Open C_soc;
Loop
	Fetch C_soc Into Rec_C_soc;
	Exit When C_soc%NotFound;
	Insert Into parporte (
		numsoc,
		numreg,
		numorg,
		numporte
		)
	Values (
		Rec_C_soc.numsoc,
		Rec_C_soc.numreg,
		Rec_C_soc.numorg,
		-1
		);
End Loop;
Close C_soc;
Open C_porte;
Loop
	Fetch C_porte Into Rec_C_porte;
	Exit When C_porte%Notfound;
	Insert Into parporte (
		numsoc,
		numreg,
		numorg,
		numporte,
		numemetteur,
		numcaisse,
		numdpt
		)
	Values (
		Rec_C_porte.numsoc,
		Rec_C_porte.numreg,
		Rec_C_porte.numorg,
		Rec_C_porte.numporte,
		Rec_C_porte.numemetteur,
		0,
		0
		);
End Loop;
Close C_porte;
END;
/
