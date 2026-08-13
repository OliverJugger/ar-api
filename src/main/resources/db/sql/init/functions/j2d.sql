CREATE function ARTHUS.j2d(a_julian	IN NUMBER)
	RETURN DATE
	AS
		loc_date	DATE;
BEGIN
	loc_date := 	to_date(a_julian, 'j');
return(loc_date);
END j2d;
