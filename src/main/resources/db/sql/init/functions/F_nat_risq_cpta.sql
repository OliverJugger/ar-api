CREATE Function ARTHUS.F_nat_risq_cpta(I_numgar  In number, I_numfor In number )
Return VARCHAR2
Is
L_nat_risq_cpta   frmls.risq_cpta%type;
L_numfor      frmls.numfor%type;

BEGIN

select 	 pk_qttc.F_SEL_numfor(I_numgar,I_numfor)
into     L_numfor
from     dual;

Select risq_cpta
     Into L_nat_risq_cpta
     From frmls
     Where numfor=L_numfor
     Union
     Select risq_cpta
	 from garanties
     Where numfor=L_numfor;

     If Sql%NotFound Then
		L_nat_risq_cpta:=Null;
     End If;
     Return(L_nat_risq_cpta);
END;
