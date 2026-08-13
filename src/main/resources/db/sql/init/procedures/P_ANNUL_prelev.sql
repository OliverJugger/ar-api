CREATE Procedure ARTHUS.P_ANNUL_prelev(
		I_numremise IN Number
		)
IS
Cursor C_prelev IS
	Select	numencaismt,
		numprelev
	From	prelevement
	Where	numremise = I_numremise;
Rec_C_prelev	C_prelev%Rowtype;
BEGIN
Open C_prelev;
Loop
	Fetch C_prelev Into Rec_C_prelev;
	Exit When C_prelev%NotFound;
	--
	P_ANNUL_encais( Rec_C_prelev.numencaismt );
	--
	Delete	prelevement_detail
	Where	numprelev = Rec_C_prelev.numprelev;
	--
	Delete	encaismt
	Where	numencaismt = Rec_C_prelev.numencaismt;
	--
End Loop;
Close C_prelev;
--
Delete	prelevement
Where	numremise = I_numremise;
--
Delete	remise_prelev
Where	numremise = I_numremise;
--
END;
/
