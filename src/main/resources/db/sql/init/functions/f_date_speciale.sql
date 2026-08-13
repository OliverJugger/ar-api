CREATE function ARTHUS.f_date_speciale (
				a_date		In Varchar2,
				a_format	In Varchar2 Default 'ddmmyy'
				)
Return varchar2
Is
    l_date DATE;
	loc_date Varchar2(15);
	date_ok boolean;
    e_mois_invalide EXCEPTION;
    e_jour_invalide EXCEPTION;
    PRAGMA EXCEPTION_INIT ( e_mois_invalide, -01843 );
    PRAGMA EXCEPTION_INIT ( e_jour_invalide, -01847 );
BEGIN
	loc_date := a_date;
	LOOP
		begin
			date_ok := FALSE;

		    SELECT TO_DATE( loc_date, 'DDMMYY' )
		    INTO l_date
		    FROM DUAL;

		    date_ok := TRUE;

		    EXCEPTION
		    	WHEN 	e_mois_invalide THEN loc_date := substr(loc_date,1,2)||'01'||substr(loc_date,5,2);
				WHEN	e_jour_invalide THEN loc_date := '01'||substr(loc_date,3,2)||substr(loc_date,5,2);
				WHEN	OTHERS			THEN loc_date := '010101';
		end;
		EXIT WHEN date_ok = TRUE;
	END LOOP;
--l_date := to_date( loc_date, 'ddmmyy' );
Return ( loc_date );
END	f_date_speciale;
