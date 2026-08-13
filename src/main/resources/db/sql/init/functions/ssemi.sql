CREATE function ARTHUS.ssemi(a_date IN DATE)
	RETURN DATE
	IS
		loc_date DATE;
BEGIN
	SELECT	add_months(
			an( a_date ),
			decode(
				sign(6-to_number(to_char(a_date,'MM'))),
				-1,12,
				0,6,
				1,6
			      )
			  )
	 INTO	loc_date
	 FROM   DUAL;
	RETURN loc_date;
END;
