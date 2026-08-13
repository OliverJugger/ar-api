CREATE function ARTHUS.f_prorata(f_debut IN NUMBER,f_fin IN NUMBER)
	RETURN NUMBER
	AS
		loc_prorata number;
	BEGIN

	SELECT
	months_between(
		last_day( to_date(f_fin,'j') ) + 1 ,
		trunc( to_date(f_debut,'j') ,'MM')
			)
	-
	(
		(
			to_number(to_char(to_date(f_debut,'j'),'DD')) - 1
		) /
		to_number(to_char(last_day(to_date(f_debut,'j')),'DD'))
	)
	-
	(
		(
			to_number(to_char(last_day(to_date(f_fin,'j')),'DD')) -
			to_number(to_char(to_date(f_fin,'j'),'DD'))
		) /
		to_number(to_char(last_day(to_date(f_fin,'j')),'DD'))
	)
	INTO	loc_prorata
	FROM	dual
	;

	RETURN loc_prorata;
END f_prorata;
