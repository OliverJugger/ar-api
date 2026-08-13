CREATE function ARTHUS.f_cot_gar (
			I_numquit IN qttc_gar.numquit%Type,
			I_numfor IN gar_cntrt.numfor%Type )
Return Varchar2
IS
Cursor C_gar IS
	Select	numfor
	From	gar_cntrt
	Where	numfor = I_numfor;
Cursor C_grp IS
	Select	grp_gar_def.numfor
	From	grp_gar,
		grp_gar_def
	Where	grp_gar.numgrpgar = I_numfor
	and	grp_gar_def.numgrpgar = grp_gar.numgrpgar;
L_cot_gar	Varchar2(80);
L_numfor	Number;
BEGIN
Open C_gar;
Fetch C_gar Into L_numfor;
If ( C_gar%Found ) then
	Select 	Sum(mt_ttc)
	Into	L_cot_gar
	From	qttc_gar
	Where 	numquit = I_numquit
	and	numfor +0 = I_numfor;
Else
	L_cot_gar := 0;
	Open C_grp;
	Loop
	Fetch C_grp Into L_numfor;
	Exit When ( C_grp%NotFound );
	--
	Select 	Nvl(Sum(mt_ttc), 0) + L_cot_gar
	Into	L_cot_gar
	From	qttc_gar
	Where 	numquit = I_numquit
	and	numfor +0 = L_numfor;
	--
	End Loop;
	Close C_grp;
End If;
Close C_gar;
--
Return ( L_cot_gar );
END;
