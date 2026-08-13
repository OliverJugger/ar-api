CREATE Procedure ARTHUS.P_INS_histo_export
IS
Cursor C_adhe IS
	Select 	idadhesion
	From	adhe_cntrt
	Where	Sysdate between date_adhe and nvl(date_fin_adhe, Sysdate);
Rec_C_adhe	C_adhe%Rowtype;
BEGIN
Open C_adhe;
Loop
	Fetch C_adhe Into Rec_C_adhe;
	Exit when C_adhe%NotFound;
	Ins_histo_export (
		a_entite	=> 31,
		a_cle		=> Rec_C_adhe.idadhesion );
End Loop;
Close C_adhe;
END P_INS_histo_export;
/
