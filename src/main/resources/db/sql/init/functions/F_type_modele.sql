CREATE Function ARTHUS.F_type_modele(I_numgar     In number,
                                         I_numfor     In number
		                        )
Return Number
Is
L_type_modele      frmls.mod_app%type;
L_numfor gar_cntrt.numfor%TYPE;
L_grpgar grp_gar.numgrpgar%TYPE;

BEGIN
/*     Select mod_app
     Into L_type_modele
     From frmls
     Where numfor=pk_qttc.F_SEL_numfor(I_numgar,I_numfor)
     Union
     Select mod_app from garanties
     Where numfor=pk_qttc.F_SEL_numfor(I_numgar,I_numfor)
     Union
     Select mod_app from grp_gar
     Where numgrpgar=pk_qttc.F_SEL_grpnumfor(I_numgar,I_numfor);*/ -- Avant 14/11/2005 JPF

-- Apres 14/11/2005 JPF

select 	 pk_qttc.F_SEL_numfor(I_numgar,I_numfor), pk_qttc.F_SEL_grpnumfor(I_numgar,I_numfor)
into     L_numfor, L_grpgar
from     dual;

Select mod_app
     Into L_type_modele
     From frmls
     Where numfor=L_numfor
     Union
     Select mod_app from garanties
     Where numfor=L_numfor
     Union
     Select mod_app from grp_gar
     Where numgrpgar=L_grpgar;

-- Apres 14/11/2005 JPF
     If Sql%NotFound Then
  	L_type_modele:=Null;
     End If;
     Return(L_type_modele);
END;
