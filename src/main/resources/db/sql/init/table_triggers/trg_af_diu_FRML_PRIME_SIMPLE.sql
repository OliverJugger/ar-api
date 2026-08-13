CREATE TRIGGER ARTHUS.trg_af_diu_FRML_PRIME_SIMPLE AFTER
  DELETE OR
  INSERT OR
  UPDATE ON FRML_PRIME_SIMPLE REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_FRML_PRIME_SIMPLE
        (
          BASE,
          CLEF,
          CONTENU,
          DEBUT,
          ETENDUE,
          FIN,
          NOMGAR,
          NUMFOR,
          SEQ,
          TAUX,
          VALIDE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.BASE,
          :old.CLEF,
          :old.CONTENU,
          :old.DEBUT,
          :old.ETENDUE,
          :old.FIN,
          :old.NOMGAR,
          :old.NUMFOR,
          :old.SEQ,
          :old.TAUX,
          :old.VALIDE,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_FRML_PRIME_SIMPLE
        (
          BASE,
          CLEF,
          CONTENU,
          DEBUT,
          ETENDUE,
          FIN,
          NOMGAR,
          NUMFOR,
          SEQ,
          TAUX,
          VALIDE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.BASE,
          :new.CLEF,
          :new.CONTENU,
          :new.DEBUT,
          :new.ETENDUE,
          :new.FIN,
          :new.NOMGAR,
          :new.NUMFOR,
          :new.SEQ,
          :new.TAUX,
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