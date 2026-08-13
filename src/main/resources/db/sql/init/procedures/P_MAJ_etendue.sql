CREATE procedure ARTHUS.P_MAJ_etendue (
				I_idvariable	IN val_variable.idvariable%Type
				)
AS
Cursor C_var IS
	Select	clef,
		numgar
	From	val_variable
	Where	idvariable = I_idvariable
	and	etendue + 0 = 4;
--
Cursor C_idadhesion (
	P_clef	IN val_variable.clef%Type,
	P_numgar IN val_variable.numgar%Type
	) IS
	Select	idadhesion
	From	adhe_cntrt
	Where	numadhe = P_clef
	and	numgar = P_numgar
	Order By idadhesion Desc;
Rec_C_var	C_var%Rowtype;
L_idadhesion	adhe_cntrt.idadhesion%Type;
BEGIN
Open C_var;
Loop
	Fetch C_var Into Rec_C_var;
	Exit When C_var%NotFound;
	--
	Open C_idadhesion (
		Rec_C_var.clef,
		Rec_C_var.numgar
		);
	Fetch C_idadhesion Into L_idadhesion;
	If ( C_idadhesion%Found ) then
		Update	val_variable
		Set	etendue = 13,
			clef = L_idadhesion
		Where	idvariable + 0 = I_idvariable
		and	etendue = 4
		and	clef = Rec_C_var.clef;
	Else
		Dbms_output.put_line( 'Idadhesion non trouvé pour assuré '			|| Rec_C_var.clef || ' Contrat ' ||
			Rec_C_var.numgar );
	End if;
	Close C_idadhesion;
End Loop;
Close C_var;
END;
/
