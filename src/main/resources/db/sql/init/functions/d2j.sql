CREATE function ARTHUS.d2j(a_date	IN Date)
	RETURN Number
	AS
		loc_julian	Number;
BEGIN
	return( to_number(to_char(a_date, 'j')) );
END d2j;
