CREATE Function ARTHUS.F_GET_VALUE_IN_TABLE( info_name varchar2, tab T_ARRAY_OF_VARCHAR)
return VARCHAR2 IS 
  I number :=1;
  l_info_name Varchar2(100);
  --TYPE T_ARRAY_OF_VARCHAR IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  --MY_ARRAY T_ARRAY_OF_VARCHAR;
  
BEGIN
  --DBMS_OUTPUT.put_line(tab.count);
  WHILE I <= tab.count LOOP
    l_info_name := TRIM(substr(tab(i),1,instr(tab(i),':')-1));
    --DBMS_OUTPUT.put_line(l_info_name);
    IF UPPER(l_info_name) = UPPER(info_name) THEN
      RETURN TRIM(substr(tab(i),instr(tab(i),':')+1,length(tab(i))));
    END IF;
    i:=i+1;
  END LOOP;
  return  null;
END F_GET_VALUE_IN_TABLE;
