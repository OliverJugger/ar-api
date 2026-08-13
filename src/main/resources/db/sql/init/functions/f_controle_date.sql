CREATE function ARTHUS.f_controle_date (
				a_date		In Varchar2,
				a_format	In Varchar2 Default 'DDMMYY'
				)
Return varchar2
Is
    l_date date;
	l_length number(2);
	loc_date varchar2(12);
	date_ok boolean;
    e_MM_invalide EXCEPTION;
    e_DD_invalide EXCEPTION;
    PRAGMA EXCEPTION_INIT ( e_MM_invalide, -01843 );
    PRAGMA EXCEPTION_INIT ( e_DD_invalide, -01847 );
BEGIN
	l_length	:= length(a_format);
	IF l_length > 6 THEN
			l_length := 8; -- forc¿e ¿ date avec heure format 24h
	END IF;

	loc_date 	:= replace(nvl(substr(a_date,1,l_length),to_char(sysdate,a_format)),' ','0');

	LOOP
		begin
			date_ok := FALSE;

		    SELECT TO_DATE(loc_date, a_format)
		    INTO l_date
		    FROM DUAL;

		    date_ok := TRUE;

		    EXCEPTION
				WHEN 	e_MM_invalide THEN loc_date := to_char(sysdate,a_format);
				WHEN	e_DD_invalide THEN loc_date := to_char(sysdate,a_format);
				WHEN	OTHERS		  THEN loc_date := to_char(sysdate,a_format);
		end;
		EXIT WHEN date_ok = TRUE;
	END LOOP;

Return ( loc_date );
END	f_controle_date;
