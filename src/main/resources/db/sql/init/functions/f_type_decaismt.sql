CREATE Function ARTHUS.f_type_decaismt(
				I_decaismt		IN	NUMBER
				)
Return	number
IS
Type_decaismt		number;
Cursor C_type_decaismt IS
SELECT
	1
FROM	decaismt,
	remise_vire_detail
where	decaismt.numdecaismt	= I_decaismt
AND	remise_vire_detail.numdecaismt	= decaismt.numdecaismt
union
SELECT
	2
FROM	decaismt,
	remise_op_detail
where	decaismt.numdecaismt	= I_decaismt
AND	remise_op_detail.numdecaismt	= decaismt.numdecaismt
union
select
	0
from	decaismt
where decaismt.numdecaismt	= I_decaismt
AND	decaismt.refpmt is null
;

BEGIN
Open C_type_decaismt;
fetch C_type_decaismt into Type_decaismt;
If (C_type_decaismt%FOUND) then
   Return Type_decaismt;
else
   Type_decaismt := 1;
   Return Type_decaismt;
end if;
close C_type_decaismt;
END  F_type_decaismt;
