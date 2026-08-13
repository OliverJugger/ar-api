CREATE function ARTHUS.f_dynamique (
				a_valeur	In Varchar2,
				a_condition	In Varchar2
				)
Return Number
Is
loc_retour	Number := 0;
cursor_id	Binary_integer;
BEGIN
cursor_id := dbms_sql.open_cursor;
dbms_sql.close_cursor( cursor_id );
loc_retour := cursor_id;
Return ( loc_retour );
END	f_dynamique;
