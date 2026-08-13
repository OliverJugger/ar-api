CREATE Function ARTHUS.F_code_reass(I_numgar  In number, I_numfor In number , I_DATE In date)
Return varchar2
AS
L_code_reass  avenant.refextav%type;
L_numfor      frmls.numfor%type;
L_numgar      contrat.numgar%type;

CURSOR C_REASS IS
		select refextav
		from avenant, cntrt_trait,avnt_cntrt_gart
		where avenant.numav=cntrt_trait.numav
		and   avenant.numtr=cntrt_trait.numtr
		and   avnt_cntrt_gart.NUMAV=cntrt_trait.NUMAV
		and   avnt_cntrt_gart.NUMGAR=L_NUMGAR
		and   avnt_cntrt_gart.NUMFOR= L_NUMFOR
		and   avenant.valideav='O'
		and   avenant.dateffav>= I_DATE
		and   I_date <= nvl(avenant.datfinav,I_date)
		and   cntrt_trait.debut>= I_DATE
		and   I_date <= nvl(cntrt_trait.fin,I_date)
		and   cntrt_trait.valide='O';

BEGIN

select 	 pk_qttc.F_SEL_numfor(I_numgar,I_numfor), pk_qttc.F_SEL_numgar(I_numgar)
into     L_numfor, L_numgar
from     dual;

OPEN C_REASS;
FETCH C_REASS into L_code_reass;
IF (C_REASS%NOTFOUND) then
	L_code_reass:=null;
end if;

CLOSE C_REASS;


     Return(L_code_reass);

END;
