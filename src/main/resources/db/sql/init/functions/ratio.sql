CREATE function ARTHUS.ratio(
			a_type		IN NUMBER,
			a_date1		IN DATE,
			a_date2		IN DATE)
	RETURN NUMBER
	AS
		loc_ratio number default 0;
		loc_date1 date;
		loc_date2 date;
BEGIN
	loc_date1 := a_date1;
	loc_date2 := a_date2;
/*
	if (comm_etendue != 5)
	then
   		SELECT	least(
				a_date1,
				decode(:comm_fin,
					       0,a_date2,
					       comm_fin)
				),
   			greatest(a_date2,
				comm_debut)
		INTO	loc_date1,
			loc_date2
		FROM	dual;
	end if;
*/
	begin
   		SELECT	(a.VALEUR / b.VALEUR) - 1
		INTO	loc_ratio
		FROM	INDICE a, INDICE b
		WHERE	a.INDICE = a_type
		AND	b.INDICE = a_type
		AND	a.DATAPLI != NVL(a.DATPER,a.DATAPLI+1)
		AND	b.DATAPLI != NVL(b.DATPER,b.DATAPLI+1)
		AND	loc_date1
				BETWEEN a.DATAPLI
		    		AND     NVL(a.DATPER,loc_date1)
		AND	loc_date2
				BETWEEN b.DATAPLI
		    		AND     NVL(b.DATPER,loc_date2);
		EXCEPTION
		WHEN NO_DATA_FOUND then loc_ratio := 0 ;
	end;
	RETURN loc_ratio;
END ratio;
