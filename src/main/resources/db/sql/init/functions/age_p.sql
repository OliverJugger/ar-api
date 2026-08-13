CREATE function ARTHUS.age_p(
			a_numindiv	IN NUMBER,
			a_date		IN DATE)
	RETURN NUMBER
	AS
		loc_age_p NUMBER;
BEGIN
   begin
	SELECT floor(
			months_between(
				a_date,
				datnais)/12
		     )
	INTO	loc_age_p
	FROM	INDVS
	WHERE	numindiv = a_numindiv;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN loc_age_p := 0 ;
   end;
   RETURN loc_age_p;
END age_p;
