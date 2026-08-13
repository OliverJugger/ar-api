CREATE function ARTHUS.f_reg(
			comm_idadhesion	IN NUMBER,
			a_numindiv	IN NUMBER,
			a_numfor	IN NUMBER,
			a_date		IN DATE)
	RETURN NUMBER
	AS
		loc_regime	NUMBER;
BEGIN
begin
   if ( a_numfor = 0 or comm_idadhesion = 0)
   then
	/* Recherche sur la fiche assure	*/
	SELECT	indvs.orgbase
	INTO	loc_regime
	FROM	indvs
	WHERE	indvs.numindiv = a_numindiv;
   else
	/* Recherche sur la couverture	*/
	SELECT	nvl(min(cvrt.numorg), 0)
	INTO	loc_regime
	FROM	cvrt
	WHERE	cvrt.numindiv = a_numindiv
	AND	cvrt.numfor   = a_numfor
	AND	cvrt.idadhesion   = comm_idadhesion
	AND	a_date 	between	cvrt.datapli
			and	nvl(cvrt.datper, a_date);
   end if;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN loc_regime := 0 ;
end;
   RETURN loc_regime;
END f_reg;
