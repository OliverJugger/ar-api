CREATE Function ARTHUS.f_numbord_decaismt(
				I_decaismt		IN	NUMBER
				)
Return	number
IS
numbord_decaismt		number;
Cursor C_numbord_decaismt IS
SELECT
	remise_vire_detail.numremise
FROM	decaismt,
	remise_vire_detail
where	decaismt.numdecaismt	= I_decaismt
AND	remise_vire_detail.numdecaismt	= decaismt.numdecaismt
union
SELECT
	remise_op_detail.numremise
FROM	decaismt,
	remise_op_detail
where	decaismt.numdecaismt	= I_decaismt
AND	remise_op_detail.numdecaismt	= decaismt.numdecaismt
union
select
	0
from	decaismt
where	decaismt.numdecaismt	= I_decaismt
and	decaismt.refpmt is null
;

BEGIN
Open C_numbord_decaismt;
fetch C_numbord_decaismt into numbord_decaismt;
If (C_numbord_decaismt%FOUND) then
   Return numbord_decaismt;
else
   numbord_decaismt := 0;
   Return numbord_decaismt;
end if;
close C_numbord_decaismt;
END  F_numbord_decaismt;
