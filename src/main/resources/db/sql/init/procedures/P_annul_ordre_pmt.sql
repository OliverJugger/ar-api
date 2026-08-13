CREATE procedure ARTHUS.P_annul_ordre_pmt( I_numremise   IN Number,
                                               I_numvirement IN Number
		                              )
IS
Cursor C_ordre_op IS
	Select	numdecaismt,
                montant_d,
                montant
	From	remise_op_detail
	Where	numremise   = I_numremise
        And	numvirement = I_numvirement;
Rec_C_ordre_op	C_ordre_op%Rowtype;
BEGIN
Open C_ordre_op;
Loop
	Fetch C_ordre_op Into Rec_C_ordre_op;
	Exit When C_ordre_op%NotFound;
	--
        Update decaismt
        Set decaismt.refpmt='',
            decaismt.flagpay=-1,
            decaismt.datpay=''
        Where decaismt.numdecaismt=Rec_C_ordre_op.numdecaismt;
	--
        Update	remise_op
        Set     montant_d=(montant_d - Rec_C_ordre_op.montant_d),
                montant  =(montant - Rec_C_ordre_op.montant)
        Where	numremise =I_numremise;        --

End Loop;
Close C_ordre_op;
--
Update	remise_op
        Set     nombre =nombre-1
        Where	numremise =I_numremise;
--
Delete	remise_op_detail
Where	numremise   = I_numremise
And	numvirement = I_numvirement;
--
END;
/
