CREATE PROCEDURE ARTHUS.P_KILL_SESSION(
  pn_sid NUMBER ,
  pn_serial NUMBER)
AS
  lv_user VARCHAR2(30);
  loc_sql VARCHAR2(100);

BEGIN
  SELECT username
  INTO lv_user
  FROM v$session
  WHERE sid = pn_sid
  AND serial# = pn_serial;
  dbms_output.put_line('01 - apres select') ;
  IF lv_user IS NOT NULL AND lv_user NOT IN ('SYS','SYSTEM') THEN
    dbms_output.put_line('02 - avant execute') ;
    loc_sql := q'[]' || 'alter system kill session ''' || pn_sid || ',' || pn_serial || '''' || q'[]' ;
    dbms_output.put_line(loc_sql) ;
    EXECUTE IMMEDIATE loc_sql ;

    --EXECUTE immediate 'alter system kill session '''||pn_sid||','||pn_serial||'''';
    --EXECUTE immediate 'alter system kill session '''||pn_sid||','||pn_serial||''' immediate ' ;

    dbms_output.put_line('03 - apres execute') ;
  ELSE
    dbms_output.put_line('04 - avant raise') ;
    raise_application_error(-20000,'Attempt to kill protected system session has been blocked.');
  END IF;
END;
/
