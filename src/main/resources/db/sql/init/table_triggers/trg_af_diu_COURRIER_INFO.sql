CREATE TRIGGER ARTHUS.trg_af_diu_COURRIER_INFO
  AFTER DELETE OR INSERT OR UPDATE ON COURRIER_INFO
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
   INSERT INTO histo_COURRIER_INFO (
                NUMINDIV
              , TYPE_CRRR
              , MOYEN_INFO
              , ACTION_HISTO
              , NUMUTIL_HISTO
              , DATE_HISTO
    )
   VALUES (
                :old.NUMINDIV
              , :old.TYPE_CRRR
              , :old.MOYEN_INFO
              , l_action
              , f_numutil
              ,  SYSDATE
                );
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_COURRIER_INFO (
                NUMINDIV
              , TYPE_CRRR
              , MOYEN_INFO
              , ACTION_HISTO
              , NUMUTIL_HISTO
              , DATE_HISTO
                    )
   VALUES (
                :new.NUMINDIV
              , :new.TYPE_CRRR
              , :new.MOYEN_INFO
              , 'I'
              , f_numutil
              , SYSDATE
                );
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;