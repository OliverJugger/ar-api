CREATE function ARTHUS.f_cie(a_contrat IN NUMBER)
	RETURN NUMBER
	AS
		loc_f_cie number default 0;
BEGIN
   begin
	SELECT	numorg
	INTO	loc_f_cie
	FROM	contrat
	WHERE	contrat.numgar = a_contrat;
	EXCEPTION
		WHEN NO_DATA_FOUND then loc_f_cie := 0;
   end;
   return loc_f_cie;
END f_cie;
