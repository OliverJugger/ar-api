CREATE procedure ARTHUS.ins_bene	(
			a_idadhesion	in Number,
			a_numfor 	in Number,
			a_numindiv	in Number,
			a_numbene	in Number,
			a_type_bene	in Number
			)
Is
BEGIN
Insert into beneficiaire (
	idadhesion,
	numfor,
	numindiv,
	numbene,
	type_bene
	)
Select 	a_idadhesion,
	a_numfor,
	a_numindiv,
	a_numbene,
	a_type_bene
From 	Dual
Where Not Exists (
	Select 	1
	From 	Beneficiaire
	where 	idadhesion = a_idadhesion
	and 	numfor = a_numfor
	and 	numindiv = a_numindiv
	and	numbene = a_numbene)
;
END;
/
