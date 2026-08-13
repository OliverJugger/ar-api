CREATE procedure ARTHUS.Ins_new_beneficiaire	(
			a_numbene	in Number,
			a_numassu	in Number,
			a_typadr	in Number
			)
Is
Cursor Fetch_cvrt Is
	Select	v_cvrt.idadhesion,
		v_cvrt.numfor,
		v_cvrt.numindiv,
		bene_gar.type_bene
	From	bene_gar,
		garanties,
		v_cvrt
	Where	bene_gar.type_bene = a_typadr
	and	bene_gar.numfor= garanties.numfor
	and	garanties.type_bene != 0
	and	garanties.numfor = v_cvrt.numfor
	and	v_cvrt.numindiv in (
		Select	numindiv
		From	indvs
		Where	indvs.creation between v_cvrt.datapli
					and nvl(v_cvrt.datper, indvs.creation)
		and	indvs.numassu = a_numassu
		and	indvs.numindiv != a_numbene);
Gar		Fetch_cvrt%Rowtype;
BEGIN
For Gar in Fetch_cvrt Loop
	Ins_bene( Gar.idadhesion, Gar.numfor, Gar.numindiv,
				  a_numbene, a_typadr );
End Loop;
END;
/
