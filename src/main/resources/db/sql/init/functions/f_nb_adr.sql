CREATE function ARTHUS.f_nb_adr(
			comm_idadhesion	IN NUMBER,
			a_numindiv	IN NUMBER,
			a_type1		IN NUMBER,
			a_type2		IN NUMBER,
			a_date		IN DATE,
			a_numfor	IN NUMBER default 0)
	RETURN NUMBER
	AS
		loc_nb_adr NUMBER;
BEGIN
if ( comm_idadhesion = 0) then
	/* Recherche sur la fiche assure	*/
	begin
		SELECT	nvl(COUNT(*),0)
		INTO	loc_nb_adr
		FROM	INDVS
		WHERE	indvs.numassu	= a_numindiv
		AND	indvs.typadr	between	a_type1
					and	a_type2
		AND	exists (select	1
				from	couverture
				where	couverture.numindiv = INDVS.numindiv
				and	a_date
					between	couverture.datapli
					and	nvl(couverture.datper, a_date)
				);
		EXCEPTION
		WHEN NO_DATA_FOUND THEN loc_nb_adr := 0 ;
	end;
else
	/* Recherche sur l' adhesion	*/
	begin
		SELECT	nvl(COUNT(*),0)
		INTO	loc_nb_adr
		FROM	adhe_cntrt_membre affilie
		WHERE	affilie.idadhesion	= comm_idadhesion
		AND	affilie.typadr	between	a_type1
					and	a_type2
		AND	exists (
			select	1
			from	couverture
			where	a_date
				between	couverture.datapli
				and	nvl(couverture.datper, a_date)
			and	couverture.numfor = decode(a_numfor,
							0, couverture.numfor,
							a_numfor)
			and	couverture.numindiv = affilie.numindiv
			and	couverture.idadhesion = comm_idadhesion
			);
		EXCEPTION
		WHEN NO_DATA_FOUND THEN loc_nb_adr := 0 ;
	end;
end if;
RETURN loc_nb_adr;
END f_nb_adr;
