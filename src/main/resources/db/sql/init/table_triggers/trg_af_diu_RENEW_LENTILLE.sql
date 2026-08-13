CREATE TRIGGER ARTHUS.trg_af_diu_RENEW_LENTILLE
  AFTER DELETE OR INSERT OR UPDATE ON RENEW_LENTILLE
  REFERENCING OLD AS old NEW AS new
  FOR EACH ROW
DECLARE
      l_action       VARCHAR2(1);
BEGIN
-- DELETE OR UPDATE (old values)
IF DELETING OR UPDATING THEN
   IF DELETING THEN
      l_action := 'D';
   END IF;
   IF UPDATING THEN
      l_action := 'U';
   END IF;
   INSERT INTO histo_RENEW_LENTILLE (CODE,
CODFRAIS,
NATURE,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (:old.CODE,
:old.CODFRAIS,
:old.NATURE,
	  l_action,
	  f_numutil,
	  SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_RENEW_LENTILLE (CODE,
CODFRAIS,
NATURE,
      action_histo,
      numutil_histo,
      date_histo)
   VALUES (:new.CODE,
:new.CODFRAIS,
:new.NATURE,
	  'I',
	  f_numutil,
	  SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;