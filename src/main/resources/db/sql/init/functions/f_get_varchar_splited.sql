CREATE Function ARTHUS.f_get_varchar_splited( split_car varchar2, chaine varchar2)
return T_ARRAY_OF_VARCHAR IS 
  I INTEGER;
  --TYPE T_ARRAY_OF_VARCHAR IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  MY_ARRAY T_ARRAY_OF_VARCHAR;
  MY_STRING VARCHAR2(2000) := chaine;
BEGIN
 MY_ARRAY := T_ARRAY_OF_VARCHAR();
  FOR CURRENT_ROW IN (
    with test as    
      (select MY_STRING from dual)
      select regexp_substr(MY_STRING, '[^'||split_car||/*;'||chr(10)||chr(13)||*/']+', 1, rownum) SPLIT
      from test
      connect by level <= length (regexp_replace(MY_STRING, '[^'||split_car||']+'))  + 1)
  LOOP
    --DBMS_OUTPUT.PUT_LINE('--'||TRIM(substr(CURRENT_ROW.SPLIT,instr(CURRENT_ROW.SPLIT,':')+1,length(current_row.split))));
    MY_ARRAY.extend;
    MY_ARRAY(MY_ARRAY.COUNT) := CURRENT_ROW.SPLIT;
  END LOOP;
  return  my_array;
END f_get_varchar_splited;
