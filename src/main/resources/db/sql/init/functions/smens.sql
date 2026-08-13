CREATE function ARTHUS.smens(a_date IN DATE)
	RETURN DATE
	IS
		loc_date DATE;
BEGIN
	SELECT	add_months( mens( a_date),1)
	 INTO	loc_date
	 FROM   DUAL;
	RETURN loc_date;
END;
