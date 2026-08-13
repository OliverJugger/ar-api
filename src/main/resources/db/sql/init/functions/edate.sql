CREATE function ARTHUS.edate(a_date IN VARCHAR2)
	RETURN DATE
	AS
		loc_date date;
	BEGIN
	SELECT	to_date(a_date,'dd/mm/yyyy')
	INTO	loc_date
	FROM	dual;
	RETURN loc_date;
END edate;
