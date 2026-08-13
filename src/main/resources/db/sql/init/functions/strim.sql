CREATE function ARTHUS.strim(a_date IN DATE)
	RETURN DATE
	IS
		loc_date DATE;
BEGIN
	SELECT	add_months( trim(a_date),3)
	INTO	loc_date
	FROM	DUAL;
	RETURN loc_date;
END;
