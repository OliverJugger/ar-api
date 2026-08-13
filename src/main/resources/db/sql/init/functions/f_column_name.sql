CREATE function ARTHUS.f_column_name (
				a_table_name 	in Varchar2,
				a_column_id 	in number
				)
Return VARCHAR2
As
loc_retour	VARCHAR2 (30);
BEGIN
	SELECT COLUMN_NAME
		INTO LOC_RETOUR
		FROM USER_TAB_COLUMNS
		WHERE USER_TAB_COLUMNS.TABLE_NAME = UPPER(a_table_name)
			AND USER_TAB_COLUMNS.COLUMN_ID = a_column_id;
	Return ( loc_retour );
EXCEPTION
	WHEN OTHERS THEN RETURN(NULL);
END	f_column_name;
