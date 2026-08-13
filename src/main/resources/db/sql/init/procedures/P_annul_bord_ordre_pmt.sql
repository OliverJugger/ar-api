CREATE procedure ARTHUS.P_annul_bord_ordre_pmt( I_numremise   IN Number
                                                   )
Is
Begin
--
        Update decaismt
        Set decaismt.refpmt='',
            decaismt.flagpay=-1,
            decaismt.datpay=''
        Where decaismt.numdecaismt In (Select remise_op_detail.numdecaismt
                                       From remise_op_detail
                                       Where remise_op_detail.numremise=I_numremise);
        --
        Delete remise_op_detail
        Where numremise=I_numremise;
        --
        Delete remise_op
        Where numremise=I_numremise;
        --
End;
/
