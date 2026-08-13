CREATE function ARTHUS.semi(a_date IN DATE)
	RETURN DATE
	IS
		loc_date DATE;
BEGIN
	SELECT	add_months(
			an( a_date ),
			decode(
				sign(6-to_number(to_char(a_date,'MM'))),
				-1,6,
				0,0,
				1,0
			      )
			  )
	 INTO	loc_date
	 FROM   DUAL;
	RETURN loc_date;
END;
