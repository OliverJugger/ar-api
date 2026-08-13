CREATE TRIGGER ARTHUS.trg_af_diu_NTFRS_TYP_VISION
  AFTER DELETE OR INSERT OR UPDATE ON NTFRS_TYP_VISION
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
   INSERT INTO histo_NTFRS_TYP_VISION (	CODFRAIS,
									NATURE,
									TYPE_VISION,
									action_histo,
									numutil_histo,
									date_histo)
   VALUES (	:old.CODFRAIS,
			:old.NATURE,
			:old.TYPE_VISION,
			l_action,
			f_numutil,
			SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_NTFRS_TYP_VISION (CODFRAIS,
									NATURE,
									TYPE_VISION,
									action_histo,
									numutil_histo,
									date_histo)
   VALUES ( :new.CODFRAIS,
			:new.NATURE,
			:new.TYPE_VISION,
			'I',
			f_numutil,
			SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;