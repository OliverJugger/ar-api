CREATE procedure ARTHUS.test_qttc
AS
Cursor C_qttc_gar IS
	Select	rowid,
		numquit,
		idgar,
		mt_net,
		mt_ttc
	From	qttc_gar
	Where	numquit between 1000 and 1100
	Order by numquit;
Rec_C_qttc_gar	C_qttc_gar%Rowtype;
BEGIN
Open C_qttc_gar;
Loop
	Fetch C_qttc_gar Into Rec_C_qttc_gar;
	Exit When C_qttc_gar%NotFound;
	Dbms_output.put_line('Numquit '||Rec_C_qttc_gar.numquit||
		' Mt_net ' || Rec_C_qttc_gar.mt_net ||
		' Mt_ttc ' || Rec_C_qttc_gar.mt_ttc);
End Loop;
Dbms_output.put_line('Dernier numquit '||Rec_C_qttc_gar.numquit );
END;
/
