CREATE procedure ARTHUS.P_MAJ_dateremb
AS
Cursor C_rbt IS
	Select	affectation.dataffec,
		rbtcptcli.idaffec,
		rbtcptcli.numaffec
	From	affectation,
		rbtcptcli
	Where	affectation.codope=8
	and	affectation.numaffec = rbtcptcli.numaffec
	Order By
		rbtcptcli.numaffec;
Rec_C_rbt	C_rbt%Rowtype;
BEGIN
Open C_rbt;
Loop
	Fetch C_rbt Into Rec_C_rbt;
	Exit When C_rbt%NotFound;
	--
	Dbms_output.put_line( 'Numaffec '||Rec_C_rbt.numaffec||
			' Idaffec '||Rec_C_rbt.idaffec||
			' Datope '||Rec_C_rbt.dataffec);
	--
	Update	compte_client
	Set	datope = Rec_C_rbt.dataffec
	Where	idaffec = Rec_C_rbt.idaffec;
	--
End Loop;
END P_MAJ_dateremb;
/
