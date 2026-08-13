CREATE function ARTHUS.f_t_aydr(
			comm_idadhesion	IN NUMBER,
			a_numindiv	IN NUMBER)
	RETURN NUMBER
	AS
		loc_t_aydr	NUMBER;
BEGIN
if ( comm_idadhesion = 0) then
	/* Recherche sur la fiche assure	*/
	begin
	SELECT	nvl(indvs.typadr,0)
	INTO	loc_t_aydr
	FROM	indvs
	WHERE	indvs.numindiv = a_numindiv;
	EXCEPTION
		WHEN NO_DATA_FOUND then loc_t_aydr := 0;
   	end;
else
	/* Recherche sur l' adhesion	*/
	begin
	SELECT	nvl(affilie.typadr, 0)
	INTO	loc_t_aydr
	FROM	adhe_cntrt_membre affilie
	WHERE	affilie.numindiv = a_numindiv
	and	affilie.idadhesion = comm_idadhesion
	;
	EXCEPTION
		WHEN NO_DATA_FOUND then loc_t_aydr := 0;
	end;
end if;
RETURN loc_t_aydr;
END f_t_aydr;
