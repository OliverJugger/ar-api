CREATE Function ARTHUS.F_dcpt_RembTotal(
 I_numdossier In varchar2,
 I_numligne   In Number
		)
Return Number
Is
L_ret	    Number;

BEGIN

select sum(sinistre_dev.mtreel_out)
Into   L_ret
from   sinistre_dev
where  numsin in (
				select numsin_sntr
				from   sntr_dossier
				where  num_dossier=I_numdossier
				and    numligne=I_numligne);


Return( L_ret);
END;
