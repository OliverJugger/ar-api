CREATE TRIGGER ARTHUS.trg_af_diu_NTFRS_MATIERE
  AFTER DELETE OR INSERT OR UPDATE ON NTFRS_MATIERE
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
   INSERT INTO histo_NTFRS_MATIERE (CODFRAIS,
									MATIERE,
									NATURE,
									action_histo,
									numutil_histo,
									date_histo)
   VALUES (	:old.CODFRAIS,
			:old.MATIERE,
			:old.NATURE,
			l_action,
			f_numutil,
			SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_NTFRS_MATIERE (CODFRAIS,
									MATIERE,
									NATURE,
									action_histo,
									numutil_histo,
									date_histo)
   VALUES (	:new.CODFRAIS,
			:new.MATIERE,
			:new.NATURE,
			'I',
			f_numutil,
			SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;