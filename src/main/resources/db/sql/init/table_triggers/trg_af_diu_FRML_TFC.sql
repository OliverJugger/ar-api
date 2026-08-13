CREATE TRIGGER ARTHUS.trg_af_diu_FRML_TFC AFTER
  DELETE OR
  INSERT OR
  UPDATE ON FRML_TFC REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_FRML_TFC
        (
          DEBUT,
          FIN,
          IDFORMULE,
          MODE_CALC,
          NUMBENE,
          NUMFOR,
          PRELEV_REVERS,
          SEQ,
          TFC,
          TYPE_TFC,
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
          :old.MODE_CALC,
          :old.NUMBENE,
          :old.NUMFOR,
          :old.PRELEV_REVERS,
          :old.SEQ,
          :old.TFC,
          :old.TYPE_TFC,
          :old.VALIDE,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_FRML_TFC
        (
          DEBUT,
          FIN,
          IDFORMULE,
          MODE_CALC,
          NUMBENE,
          NUMFOR,
          PRELEV_REVERS,
          SEQ,
          TFC,
          TYPE_TFC,
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
          :new.MODE_CALC,
          :new.NUMBENE,
          :new.NUMFOR,
          :new.PRELEV_REVERS,
          :new.SEQ,
          :new.TFC,
          :new.TYPE_TFC,
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