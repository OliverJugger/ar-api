CREATE Function ARTHUS.f_typ_edition (
				I_editid	IN	varchar2,
				I_type	IN	number
			)
Return	varchar2
IS
L_typ_edition 		varchar2(80);
Cursor 	C_typ_edition IS
SELECT 	batchid,
		editlib
FROM		typ_edition
where		typ_edition.editid	=	I_editid
and		rownum			=	1
;
Rec_C_typ_edition 	C_typ_edition%Rowtype;
BEGIN
Open C_typ_edition;
fetch C_typ_edition into Rec_C_typ_edition;
If (C_typ_edition%FOUND) then
	If (I_type=1) Then
		L_typ_edition := Rec_C_typ_edition.batchid;
	Elsif (I_type=2) Then
		L_typ_edition := Rec_C_typ_edition.editlib;
	End if;
   Return L_typ_edition;
else
   L_typ_edition := 'Inconnu';
   Return L_typ_edition;
end if;
close C_typ_edition;
END  F_typ_edition;
