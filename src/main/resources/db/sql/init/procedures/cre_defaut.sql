CREATE procedure ARTHUS.cre_defaut
is
defaut			varchar2(80);
Cursor fetch_objet is
	Select	cols.table_name,
		cols.column_name,
		cols.data_default
	From	cols
	Where	cols.data_default is not null
	Order by
		cols.table_name
	;
loc_objet	fetch_objet%Rowtype;
BEGIN
For loc_objet in fetch_objet
loop
dbms_output.put_line(loc_objet.table_name||' '||loc_objet.column_name||' '||loc_objet.data_default);
end loop;
END;
/
