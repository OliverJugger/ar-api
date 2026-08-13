CREATE procedure ARTHUS.maj_cmcr
As
Cursor C_gar IS
	Select	numfor_ref,
		numfor
	From	garanties
	Where	etendue = 2;
Cursor C_gar_prod (P_numfor IN garanties.numfor%Type) IS
	Select	code_cmcr,
		nat_risq
	From	garanties
	Where	numfor = P_numfor
	and 	etendue = 7;
Rec_C_gar	C_gar%Rowtype;
Rec_C_gar_prod	C_gar_prod%Rowtype;
BEGIN
Open C_gar;
Loop
	Fetch C_gar Into Rec_C_gar;
	Exit When C_gar%NotFound;
	Open C_gar_prod( Rec_C_gar.numfor_ref );
	Fetch C_gar_prod Into Rec_C_gar_prod;
	Begin
	Update	garanties
	Set	code_cmcr = Rec_C_gar_prod.code_cmcr,
		nat_risq = Rec_C_gar_prod.nat_risq
	Where	numfor = Rec_C_gar.numfor;
	End;
	Dbms_output.put_line('Maj numfor '||Rec_C_gar.numfor ||
		' Cmcr '|| Rec_c_gar_prod.code_cmcr ||
		' Risque ' || Rec_C_gar_prod.nat_risq);
	Close C_gar_prod;
End Loop;
Close C_gar;
END;
/
