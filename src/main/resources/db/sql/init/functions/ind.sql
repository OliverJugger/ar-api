CREATE function ARTHUS.ind(a_type IN NUMBER,a_date IN DATE)
	RETURN NUMBER
	AS
		loc_ind number default 0;
BEGIN
   begin
	SELECT	VALEUR
	INTO	loc_ind
	FROM	INDICE
	WHERE	INDICE.DATAPLI != NVL(INDICE.DATPER,INDICE.DATAPLI+1)
	AND	INDICE.indice = a_type
	AND	a_date
			BETWEEN	INDICE.DATAPLI
		  	AND	NVL(INDICE.DATPER,a_date);
	EXCEPTION
		WHEN NO_DATA_FOUND then loc_ind := 0;
   end;
   return loc_ind;
END ind;
