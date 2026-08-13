CREATE Function ARTHUS.f_regime 	(I_numsin     In number,
                 I_numdossier In varchar2,
                 I_numligne   In Number
		)
Return Number
Is
L_numsin	Number;
BEGIN
Begin
select numsin_sntr
Into   	L_numsin
from   sntr_dossier
where  num_dossier=I_numdossier
and    numligne=I_numligne
and    numsin_sntr<>I_numsin;
Exception When No_data_found then L_numsin:= 0;
End;
Return( L_numsin);
END;
