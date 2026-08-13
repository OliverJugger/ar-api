CREATE function ARTHUS.age_mp(
			a_numindiv	IN NUMBER,
			a_date		IN DATE)
	RETURN NUMBER
	AS
		loc_age_mp NUMBER;
BEGIN
   begin
	SELECT	to_number(to_char(a_date,'YYYY')) -
		to_number(to_char(datnais,'YYYY'))
	INTO	loc_age_mp
	FROM	INDVS
	WHERE	numindiv = a_numindiv;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN loc_age_mp := 0 ;
   end;
   RETURN loc_age_mp;
END age_mp;
