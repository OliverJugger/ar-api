CREATE TRIGGER ARTHUS.trg_af_diu_FRML_DEDU AFTER
  DELETE OR
  INSERT OR
  UPDATE ON FRML_DEDU REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_FRML_DEDU
        (
          DEBUT,
          FIN,
          IDFORMULE,
          NUMFOR,
          TYPDEDU,
          VALIDE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.DEBUT,
          :old.FIN,
          :old.IDFORMULE,
          :old.NUMFOR,
          :old.TYPDEDU,
          :old.VALIDE,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_FRML_DEDU
        (
          DEBUT,
          FIN,
          IDFORMULE,
          NUMFOR,
          TYPDEDU,
          VALIDE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.DEBUT,
          :new.FIN,
          :new.IDFORMULE,
          :new.NUMFOR,
          :new.TYPDEDU,
          :new.VALIDE,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;