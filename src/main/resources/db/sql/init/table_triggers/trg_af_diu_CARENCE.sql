CREATE TRIGGER ARTHUS.trg_af_diu_CARENCE AFTER
  DELETE OR
  INSERT OR
  UPDATE ON CARENCE REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
  BEGIN
    -- DELETE OR UPDATE (old values)
    IF DELETING OR UPDATING THEN
      IF DELETING THEN
        l_action := 'D';
      END IF;
      IF UPDATING THEN
        l_action := 'U';
      END IF;
      INSERT
      INTO histo_CARENCE
        (
          CODFRAIS,
          DATAPLI,
          DATPER,
          DELAI,
          NUMFOR,
          NUMMATH,
          TYPE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.CODFRAIS,
          :old.DATAPLI,
          :old.DATPER,
          :old.DELAI,
          :old.NUMFOR,
          :old.NUMMATH,
          :old.TYPE,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_CARENCE
        (
          CODFRAIS,
          DATAPLI,
          DATPER,
          DELAI,
          NUMFOR,
          NUMMATH,
          TYPE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.CODFRAIS,
          :new.DATAPLI,
          :new.DATPER,
          :new.DELAI,
          :new.NUMFOR,
          :new.NUMMATH,
          :new.TYPE,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;