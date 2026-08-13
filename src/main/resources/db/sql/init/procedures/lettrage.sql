CREATE procedure ARTHUS.lettrage is
Cursor c_credit Is
	           Select numremise
	           From v_avis_credit
	           Where numcpte=28;
v_credit v_avis_credit.numremise%type;
releve_numcpte v_avis_credit.numcpte%type;
L_result encaismt.numencaismt%type;
Begin
	Open c_credit;
	Fetch c_credit Into v_credit;
	If c_credit%found Then
	   Declare
	   		   Cursor c_encaismt(l_credit v_avis_credit.numremise%type) Is
	                            Select numencaismt
	                            From encaismt
	                            where numencaismt
	                            In
	                            (Select numencaismt
	                            From prelevement,remise_prelev
	                            Where prelevement.numremise=remise_prelev.numremise)
	                            --And   prelevement.numremise=v_credit
	                            And numcpte=releve_numcpte
	                            And id_credit is null;
	         v_encaismt encaismt.numencaismt%type;
	   Begin
	   	   Open c_encaismt(v_credit);
	   	   Fetch c_encaismt into v_encaismt;
	   	   If c_encaismt%found Then
	   	   	 L_result:=v_encaismt;
	   	   End If;
	   	   close c_encaismt;
	   End;
	End If;
	Close c_credit;
End;
/
