CREATE function ARTHUS.e2d(a_edate		in 	Varchar2)
Return Date
As
loc_date	Date;
BEGIN
If ( Length( a_edate ) = 8 ) then
	Return( to_date(a_edate, 'dd/mm/yy') );
Elsif ( Length( a_edate ) = 10 ) then
	Return( to_date(a_edate, 'dd/mm/yyyy') );
End if;
Return( Null );
END e2d;
