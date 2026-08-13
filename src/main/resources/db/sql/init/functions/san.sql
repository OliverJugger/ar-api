CREATE function ARTHUS.san(a_date IN DATE)
	RETURN DATE
	IS
		loc_date DATE;
BEGIN
	SELECT	add_months(
			an( a_date ),
			12)
	 INTO	loc_date
	 FROM   DUAL;
	RETURN loc_date;
END;
