CREATE TRIGGER ARTHUS.trg_af_diu_LIBFORMATH AFTER
  DELETE OR
  INSERT OR
  UPDATE ON LIBFORMATH REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_LIBFORMATH
        (
          FORFAIT,
          FORMULE,
          LIBELLE,
          LIMITE,
          NUMMATH,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.FORFAIT,
          :old.FORMULE,
          :old.LIBELLE,
          :old.LIMITE,
          :old.NUMMATH,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_LIBFORMATH
        (
          FORFAIT,
          FORMULE,
          LIBELLE,
          LIMITE,
          NUMMATH,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.FORFAIT,
          :new.FORMULE,
          :new.LIBELLE,
          :new.LIMITE,
          :new.NUMMATH,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;