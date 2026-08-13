CREATE function ARTHUS.f_naydr(
			comm_idadhesion	IN NUMBER,
			a_numindiv	IN NUMBER,
			a_type1		IN NUMBER,
			a_type2		IN NUMBER,
			a_date		IN DATE,
			a_rang		IN NUMBER default 1,
			a_numfor	IN NUMBER default 0)
	RETURN NUMBER
	AS
		loc_naydr	NUMBER;
BEGIN
if ( comm_idadhesion = 0) then
	/* Recherche sur la fiche assure	*/
	begin
	SELECT	nvl(min(ayd.numindiv), 0)
	INTO	loc_naydr
	FROM	indvs ayd
	WHERE	ayd.numassu = (
			select 	numassu
			from 	indvs princ
			where 	princ.numindiv = a_numindiv
			and	princ.typadr between a_type1 and a_type2)
	and	ayd.typadr	between	a_type1
				and	a_type2
	and	( f_r_aydr(0, ayd.numindiv, a_type1, a_type2, a_date) = a_rang
		  or
		  a_rang = 0)
	;
	EXCEPTION
		WHEN NO_DATA_FOUND then loc_naydr := 0;
   end;
else
	/* Recherche sur l' adhesion	*/
	begin
	SELECT	nvl(min(affilie.numindiv), 0)
	INTO	loc_naydr
	FROM	indvs ayd,
		adhe_cntrt_membre affilie
	WHERE	( f_r_aydr(comm_idadhesion, ayd.numindiv, a_type1,
			 a_type2, a_date, a_numfor) = a_rang
		  or
		  a_rang = 0 )
	and	ayd.numindiv = affilie.numindiv
	and	affilie.typadr	between	a_type1
				and	a_type2
	and	affilie.idadhesion = comm_idadhesion
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
		)
	;
	EXCEPTION
		WHEN NO_DATA_FOUND then loc_naydr := 0;
	end;
end if;
RETURN loc_naydr;
END f_naydr;
