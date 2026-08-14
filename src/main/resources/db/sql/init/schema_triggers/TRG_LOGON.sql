CREATE TRIGGER arthus.trg_logon
AFTER LOGON ON DATABASE
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') IN ('SYS','SYSTEM') THEN
    RETURN;
  END IF;
  EXECUTE IMMEDIATE q'[alter session set nls_date_format='DD-MON-RRRR']';
  EXECUTE IMMEDIATE q'[alter session set nls_date_language='AMERICAN']';
  EXECUTE IMMEDIATE q'[alter session set nls_numeric_characters='. ']';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;