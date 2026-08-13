CREATE Function ARTHUS.f_couv_jour
Return Number
Is
loc_retour 	Number Default 0;

Cursor C_parametres Is
	Select	couv_jour
	From	parametres;

Begin
         Open C_parametres;
         Fetch C_parametres Into loc_retour;
		if (C_parametres%NOTFOUND) then
				CLOSE C_parametres;
				return (0);
		else
				CLOSE C_parametres;
				if loc_retour is not null then
				    Return ( loc_retour );
				else
				    return (0);
				end if;
	    end if;
End;
