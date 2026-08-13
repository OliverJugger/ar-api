CREATE TRIGGER ARTHUS.trg_af_diu_SUP_LPP AFTER
  DELETE OR
  INSERT OR
  UPDATE ON SUP_LPP REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_SUP_LPP
        (
          CODE_LPP,
          CODFRAIS,
          NATURE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.CODE_LPP,
          :old.CODFRAIS,
          :old.NATURE,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_SUP_LPP
        (
          CODE_LPP,
          CODFRAIS,
          NATURE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.CODE_LPP,
          :new.CODFRAIS,
          :new.NATURE,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;