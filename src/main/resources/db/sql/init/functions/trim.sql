CREATE function ARTHUS.trim(a_date IN DATE)
	RETURN DATE
	IS
		loc_date date;
BEGIN
	SELECT	trunc(a_date,'Q')
	 INTO	loc_date
	 FROM   DUAL;
	RETURN loc_date;
END;
