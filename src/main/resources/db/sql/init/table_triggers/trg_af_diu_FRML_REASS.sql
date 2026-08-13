CREATE TRIGGER ARTHUS.trg_af_diu_FRML_REASS AFTER
  DELETE OR
  INSERT OR
  UPDATE ON FRML_REASS REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_FRML_REASS
        (
          DEBUT,
          DOMAINE,
          FIN,
          IDFORMULE,
          NUMAV,
          NUMTR,
          VALIDE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.DEBUT,
          :old.DOMAINE,
          :old.FIN,
          :old.IDFORMULE,
          :old.NUMAV,
          :old.NUMTR,
          :old.VALIDE,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_FRML_REASS
        (
          DEBUT,
          DOMAINE,
          FIN,
          IDFORMULE,
          NUMAV,
          NUMTR,
          VALIDE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.DEBUT,
          :new.DOMAINE,
          :new.FIN,
          :new.IDFORMULE,
          :new.NUMAV,
          :new.NUMTR,
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