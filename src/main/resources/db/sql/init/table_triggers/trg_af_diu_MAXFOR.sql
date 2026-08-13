CREATE TRIGGER ARTHUS.trg_af_diu_MAXFOR AFTER
  DELETE OR
  INSERT OR
  UPDATE ON MAXFOR REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_MAXFOR
        (
          DATAPLI,
          DATPER,
          DATREF,
          DOMAINE,
          ETENDUE,
          INDICE,
          MONTANT,
          NBINDICE,
          NUMFOR,
          NUMMATH,
          NUMMATH_C,
          NUMORG,
          TAUX,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.DATAPLI,
          :old.DATPER,
          :old.DATREF,
          :old.DOMAINE,
          :old.ETENDUE,
          :old.INDICE,
          :old.MONTANT,
          :old.NBINDICE,
          :old.NUMFOR,
          :old.NUMMATH,
          :old.NUMMATH_C,
          :old.NUMORG,
          :old.TAUX,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_MAXFOR
        (
          DATAPLI,
          DATPER,
          DATREF,
          DOMAINE,
          ETENDUE,
          INDICE,
          MONTANT,
          NBINDICE,
          NUMFOR,
          NUMMATH,
          NUMMATH_C,
          NUMORG,
          TAUX,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.DATAPLI,
          :new.DATPER,
          :new.DATREF,
          :new.DOMAINE,
          :new.ETENDUE,
          :new.INDICE,
          :new.MONTANT,
          :new.NBINDICE,
          :new.NUMFOR,
          :new.NUMMATH,
          :new.NUMMATH_C,
          :new.NUMORG,
          :new.TAUX,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;