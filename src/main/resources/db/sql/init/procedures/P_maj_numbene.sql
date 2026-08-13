CREATE procedure ARTHUS.P_maj_numbene
AS
Cursor C_decompte IS
	Select	numindiv,
		numdec
	From	decompte
	Where Not Exists (
		Select	1
		From	indvs
		Where	indvs.numindiv = decompte.numbene);
Rec_C_decompte		C_decompte%Rowtype;
Nb_traite		Number := 0;
L_numdecaismt		Number;
BEGIN
Open C_decompte;
Loop
	Fetch C_decompte Into Rec_C_decompte;
	Exit When C_decompte%NotFound;
	--
	Dbms_output.put_line( 'Traitemen décompte '|| Rec_C_decompte.numdec
		|| ' assuré ' || Rec_C_decompte.numindiv );
	--
	Update	sinistre
	Set	numbene = Rec_C_decompte.numindiv
	Where	numdec = Rec_C_decompte.numdec;
	--
	Begin
	Select	numdecaismt
	Into	L_numdecaismt
	From	affectation
	Where	codope = 1
	and	numaffec = Rec_C_decompte.numdec;
	End;
	--
	Dbms_output.put_line( 'Traitement décaissement ' || L_numdecaismt );
	Update	decaismt
	Set	numbene = Rec_C_decompte.numindiv,
		numdest = Rec_C_decompte.numindiv
	Where	numdecaismt = L_numdecaismt;
	--
	Update	affectation
	Set	numcli = Rec_C_decompte.numindiv
	Where	codope = 1
	and	numaffec = Rec_C_decompte.numdec;
	--
	Update	decompte
	Set	numbene = Rec_C_decompte.numindiv
	Where	numdec = Rec_C_decompte.numdec;
	--
	Nb_traite := Nb_traite + 1;
End Loop;
Close C_decompte;
Dbms_output.put_line( Nb_traite || ' décomptes traités' );
END;
/
