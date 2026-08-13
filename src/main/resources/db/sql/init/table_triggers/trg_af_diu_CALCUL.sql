CREATE TRIGGER ARTHUS.trg_af_diu_CALCUL AFTER
  DELETE OR
  INSERT OR
  UPDATE ON CALCUL REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_table_CALCUL
        (
          CODFRAIS,
          DATAPLI,
          DATECREA,
          DATEMAJ,
          DATPER,
          NUMFOR,
          NUMMATH,
          NUMORG,
          RUBRIQUE,
          TYPE_ACTE,
          USERCREA,
          USERMAJ,
          X,
          Y,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.CODFRAIS,
          :old.DATAPLI,
          :old.DATECREA,
          :old.DATEMAJ,
          :old.DATPER,
          :old.NUMFOR,
          :old.NUMMATH,
          :old.NUMORG,
          :old.RUBRIQUE,
          :old.TYPE_ACTE,
          :old.USERCREA,
          :old.USERMAJ,
          :old.X,
          :old.Y,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_table_CALCUL
        (
          CODFRAIS,
          DATAPLI,
          DATECREA,
          DATEMAJ,
          DATPER,
          NUMFOR,
          NUMMATH,
          NUMORG,
          RUBRIQUE,
          TYPE_ACTE,
          USERCREA,
          USERMAJ,
          X,
          Y,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.CODFRAIS,
          :new.DATAPLI,
          :new.DATECREA,
          :new.DATEMAJ,
          :new.DATPER,
          :new.NUMFOR,
          :new.NUMMATH,
          :new.NUMORG,
          :new.RUBRIQUE,
          :new.TYPE_ACTE,
          :new.USERCREA,
          :new.USERMAJ,
          :new.X,
          :new.Y,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;