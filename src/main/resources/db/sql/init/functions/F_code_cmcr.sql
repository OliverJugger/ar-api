CREATE Function ARTHUS.F_code_cmcr(I_numgar  In number, I_numfor In number )
Return Number
Is
L_code_cmcr      frmls.code_cmcr%type;
L_numfor      frmls.numfor%type;

BEGIN

select 	 pk_qttc.F_SEL_numfor(I_numgar,I_numfor)
into     L_numfor
from     dual;

Select code_cmcr
     Into L_code_cmcr
     From frmls
     Where numfor=L_numfor
     Union
     Select code_cmcr
	 from garanties
     Where numfor=L_numfor;

     If Sql%NotFound Then
		L_code_cmcr:=Null;
     End If;
     Return(L_code_cmcr);
END;
