CREATE function ARTHUS.d2e(a_date	IN Date, a_type In Number default 0)
	RETURN varchar2
	As loc_date varchar2(10);
BEGIN
If ( a_type = 0 ) then
	Return(to_char(a_date, 'dd/mm/yyyy') );
Else
	Return(to_char(a_date, 'dd/mm/yy') );
End if;
END d2e;
