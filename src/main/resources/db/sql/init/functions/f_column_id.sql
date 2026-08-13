CREATE function ARTHUS.f_column_id (
				a_table_name 	in Varchar2,
				a_column_name 	in Varchar2
				)
Return Number
As
loc_retour	number;
BEGIN
	SELECT COLUMN_ID
		INTO LOC_RETOUR
		FROM USER_TAB_COLUMNS
		WHERE USER_TAB_COLUMNS.TABLE_NAME = UPPER(a_table_name)
			AND USER_TAB_COLUMNS.COLUMN_NAME = UPPER(a_column_name);
	Return ( loc_retour );
EXCEPTION
	WHEN OTHERS THEN RETURN(0);
END	f_column_id;
