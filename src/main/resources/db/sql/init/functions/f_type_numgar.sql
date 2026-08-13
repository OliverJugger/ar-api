CREATE Function ARTHUS.f_type_numgar(
				I_numgar		IN	NUMBER
				)
Return	number
IS
Type_numgar		number;
Cursor C_type_numgar IS
SELECT
	2
FROM	contrat
where	contrat.numgar 	= I_numgar
AND	contrat.numgar	= contrat.numgar_ref
;

BEGIN
Open C_type_numgar;
fetch C_type_numgar into Type_numgar;
If (C_type_numgar%FOUND) then
   Return Type_numgar;
else
   Type_numgar := 24;
   Return Type_numgar;
end if;
close C_type_numgar;
END  F_type_numgar;
