CREATE function ARTHUS.f_siecle (
				a_date		In Varchar2,
				a_format	In Varchar2 Default 'ddmmyy'
				)
Return Date
Is
loc_retour	Date;
loc_date 	Varchar2(15);
loc_siecle 	Varchar2(2);
loc_annee 	Varchar2(2);
loc_jour 	Varchar2(7);
loc_bissext	Varchar2(6);
Seuil		Binary_integer;
Annee_courante Varchar2(2) := To_char( sysdate, 'yy' );
Siecle_courant Varchar2(2) := Substr( To_char(sysdate,'dd-mon-yyyy'), 8, 2 );
Begin
If ( Annee_courante < 50 ) then
	Seuil := 5;
Else
	Seuil := 95;
End if;
loc_date := to_char( to_date(a_date, a_format) );
loc_siecle := Siecle_courant;
loc_annee := To_char( to_date(loc_date, 'dd-mon-yyyy'), 'yy' );
loc_jour := To_char( to_date(loc_date, 'dd-mon-yyyy'), 'dd-mon-' );
loc_bissext := To_char( to_date(loc_date, 'dd-mon-yyyy'), 'ddmmyy' );
If ( abs( to_number(loc_annee) - to_number(Annee_courante) ) >= Seuil ) then
/* CTT 01/02/2006 : l'ann¿e 1900 n'est pas bissextile ... */
	if loc_bissext <> '290200' then
	If ( Annee_courante < 50 ) then
		loc_siecle := to_char( to_number(loc_siecle) -  1 );
	Else
		loc_siecle := to_char( to_number(loc_siecle) +  1 );
	End if;
	end if;
End if;
loc_date := loc_jour || loc_siecle || loc_annee;
loc_retour := to_date( loc_date, 'dd-mon-yyyy' );
Return ( loc_retour );
END	f_siecle;
