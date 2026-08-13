CREATE Function ARTHUS.F_nat_risq(I_numgar  In number, I_numfor In number )
Return Number
Is
L_nat_risq      frmls.nat_risq%type;
L_numfor      frmls.numfor%type;

BEGIN

select 	 pk_qttc.F_SEL_numfor(I_numgar,I_numfor)
into     L_numfor
from     dual;

Select nat_risq
     Into L_nat_risq
     From frmls
     Where numfor=L_numfor
     Union
     Select nat_risq
	 from garanties
     Where numfor=L_numfor;

     If Sql%NotFound Then
		L_nat_risq:=Null;
     End If;
     Return(L_nat_risq);
END;
