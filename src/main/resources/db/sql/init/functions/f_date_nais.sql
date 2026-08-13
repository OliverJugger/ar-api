CREATE function ARTHUS.f_date_nais (
				a_date		In Varchar2,
				a_format	In Varchar2 Default 'ddmmyy'
				)
Return Date
Is
date_naissance		Date;
loc_date 			Varchar2(15);
Siecle_naissance	Varchar2(2);
Annee_naissance		Varchar2(2);
Annee_courante  	Varchar2(2) := To_char( sysdate, 'yy' );
jj_mm_naissance		Varchar2(7);
loc_bissext			Varchar2(6);
BEGIN
	loc_date 			:= To_char( to_date(a_date, a_format) );
	Siecle_naissance 	:= substr(To_char( to_date(loc_date, 'dd-mon-yyyy')), 8, 2 );
	Annee_naissance		:= To_char( to_date(loc_date, 'dd-mon-yyyy'), 'yy' );
	jj_mm_naissance		:= To_char( to_date(loc_date, 'dd-mon-yyyy'), 'dd-mon-' );
	loc_bissext 		:= To_char( to_date(loc_date, 'dd-mon-yyyy'), 'ddmmyy' );
--	If to_number(Annee_naissance) > to_number(Annee_courante) then
	If to_date(loc_date, 'dd-mon-yyyy') > sysdate then
	/* L'ann¿e 1900 n'¿tant pas bissextile ... */
		if loc_bissext <> '290200' then
				Siecle_naissance := to_char( to_number(Siecle_naissance) -  1 );
		end if;
	End if;
	loc_date := jj_mm_naissance || Siecle_naissance || Annee_naissance;
	date_naissance := to_date( loc_date, 'dd-mon-yyyy' );
	Return ( date_naissance );
END	f_date_nais;
