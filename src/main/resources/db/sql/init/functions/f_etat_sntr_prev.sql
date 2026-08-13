CREATE Function ARTHUS.f_etat_sntr_prev (
				I_nosin		IN	NUMBER,
				I_fin		IN	DATE)
Return	varchar2
IS
L_etat_sinistre 		varchar2(45);
Cursor C_etat IS
SELECT 	'En cours'
FROM	sntr_prev
where	sntr_prev.nosin= I_nosin
AND	sntr_prev.fin is null or sntr_prev.fin > I_fin
;

BEGIN
Open C_etat;
fetch C_etat into L_etat_sinistre;
If (C_etat%FOUND) then
   Return L_etat_sinistre;
else
   L_etat_sinistre := 'Terminé';
   Return L_etat_sinistre;
end if;
close C_etat;
END  F_etat_sntr_prev;
