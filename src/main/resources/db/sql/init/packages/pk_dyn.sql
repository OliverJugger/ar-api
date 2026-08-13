CREATE OR REPLACE package ARTHUS.pk_dyn IS
Procedure Exec_sql (
			a_statement	In Varchar2
			);
END pk_dyn;
/

CREATE OR REPLACE Package Body ARTHUS.pk_dyn
IS
Procedure Exec_sql (
			a_statement	In Varchar2
			)
Is
loc_retour	Number := 0;
cursor_id	Binary_integer;
BEGIN
cursor_id := sys.dbms_sql.open_cursor;
sys.dbms_sql.parse( cursor_id, a_statement, DBMS_SQL.V7 );
loc_retour := sys.dbms_sql.execute( cursor_id );
sys.dbms_sql.close_cursor( cursor_id );
END	Exec_sql;
END pk_dyn;
/
