CREATE TRIGGER ARTHUS.trg_af_diu_FRMLVAR AFTER
  DELETE OR
  INSERT OR
  UPDATE ON FRMLVAR REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_table_FRMLVAR
        (
          COND,
          FRML,
          IDFORMULE,
          SEQ,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.COND,
          :old.FRML,
          :old.IDFORMULE,
          :old.SEQ,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_table_FRMLVAR
        (
          COND,
          FRML,
          IDFORMULE,
          SEQ,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.COND,
          :new.FRML,
          :new.IDFORMULE,
          :new.SEQ,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;