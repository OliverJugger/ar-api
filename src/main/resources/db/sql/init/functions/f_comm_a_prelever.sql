CREATE function ARTHUS.f_comm_a_prelever (
				I_numgar	IN contrat.numgar%Type,
				I_numbene	IN contrat.delegataire%Type
				)
Return Number
AS
Cursor C_retro IS
	Select	numquit
	From	qttc_retro
	Where	numquit IN (
		select	numquit
		from	qttc_global
		where	numgar = I_numgar
		and	comptant != 'R')
	and	numbene = I_numbene
	and	prelev_revers = 1
	Group By
		numquit
	Having sum(montant) != 0;
Cursor C_prelev ( P_numquit qttc_global.numquit%Type ) IS
	Select	1
	From	qttc_affec_tfc
	Where	numquit = P_numquit
	and	tfc =5
	and	numbene = I_numbene
	and	prelev_revers = 1;
Rec_C_retro	C_retro%Rowtype;
Dummy		Number;
L_retour	Number := 0;
BEGIN
Open C_retro;
Loop
	Fetch C_retro Into Rec_C_retro;
	Exit When C_retro%NotFound;
	Open C_prelev( Rec_C_retro.numquit );
	Fetch C_prelev Into Dummy;
	If ( C_prelev%NotFound ) then
		L_retour := Rec_C_retro.numquit;
		Close C_prelev;
		Exit;
        Else
		Close C_prelev;
	End if;
End Loop;
Close C_retro;
Return( L_retour );
END;
