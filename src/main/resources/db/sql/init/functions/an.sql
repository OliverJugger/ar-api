CREATE function ARTHUS.an(a_date IN DATE)
	RETURN DATE
	IS
		loc_date DATE;
BEGIN
	SELECT	trunc( a_date, 'YYYY')
	 INTO	loc_date
	 FROM   DUAL;
	RETURN loc_date;
END;
