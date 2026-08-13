CREATE function ARTHUS.mens(a_date IN DATE)
	RETURN DATE
	IS
		loc_date DATE;
BEGIN
	SELECT	trunc( a_date, 'MM')
	 INTO	loc_date
	 FROM   DUAL;
	RETURN loc_date;
END;
