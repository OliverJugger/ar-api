CREATE Procedure ARTHUS.control_extents(
			a_k in number,
			a_tablespace in varchar2 default null
			)
IS
Cursor fetch_free is
	Select 	bytes / 1024	bytes,
		tablespace_name,
		count(*)	nombre
	From	user_free_space
	Where	bytes >= a_k *1024
	And	tablespace_name = nvl(upper(a_tablespace), tablespace_name)
	Group by
		tablespace_name,
		bytes / 1024
	;
s_total	number := 0;
total	number := 0;
loc_nombre number := 0;
free	fetch_free%ROWTYPE;
objet	user_segments%ROWTYPE;
extent	user_extents%ROWTYPE;
BEGIN
dbms_output.put_line('Extents libres > '||a_k||' Kilobytes');
dbms_output.put_line('------------------------------------');
for free in fetch_free
loop
	s_total := free.nombre * free.bytes;
	total := total + s_total;
dbms_output.put_line(free.tablespace_name||' : '||free.nombre||' de '||free.bytes||' = '||s_total||' Ko');
	s_total := 0;
end loop;
dbms_output.put_line('------------------------------------');
dbms_output.put_line('Total libre : '||total / 1024||' Mo ');
dbms_output.put_line('              * * * *');
dbms_output.put_line('Objets susceptibles d''occuper ces extents');
dbms_output.put_line('-----------------------------------------');
For objet in (
	Select 	segment_name,
		tablespace_name,
		extents,
		next_extent / 1024	next_extent
	From	user_segments
	Where	next_extent >= a_k *1024
	And	tablespace_name = nvl(upper(a_tablespace), tablespace_name)
	Order by
		tablespace_name,
		next_extent desc,
		extents desc
	)
loop
dbms_output.put_line(objet.tablespace_name||' : '||objet.segment_name||' Next = '||objet.next_extent||' Ko. Nombre d''extents : '||objet.extents);
End loop;
dbms_output.put_line('              * * * *');
dbms_output.put_line('Objets occupant des extents >= '||a_k||' Ko');
dbms_output.put_line('-----------------------------------------');
For extent in (
	Select 	segment_name,
		tablespace_name,
		count(*)	nombre,
		bytes / 1024	bytes
	From	user_extents
	Where	bytes >= a_k *1024
	And	tablespace_name = nvl(upper(a_tablespace), tablespace_name)
	Group by
		tablespace_name,
		segment_name,
		bytes / 1024
	)
loop
Begin
Select	count(*)
Into	loc_nombre
From	user_extents
Where	segment_name = extent.segment_name
And	tablespace_name = extent.tablespace_name
and	bytes / 1024 = extent.bytes;
End;
	s_total := loc_nombre * extent.bytes;
dbms_output.put_line(extent.tablespace_name||' : '||extent.segment_name||' '||loc_nombre||' de '||extent.bytes||' = '||s_total);
	s_total := 0;
End loop;
END;
/
