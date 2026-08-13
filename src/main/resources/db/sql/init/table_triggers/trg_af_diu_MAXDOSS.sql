CREATE TRIGGER ARTHUS.trg_af_diu_MAXDOSS AFTER
  DELETE OR
  INSERT OR
  UPDATE ON MAXDOSS REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_MAXDOSS
        (
          DATE_DEB,
          DATE_FIN,
          INDICE,
          MONNAIE,
          NBACTES,
          NBINDICE,
          NUMMATH,
          NUM_DOSSIER,
          PLAFOND,
          TAUX,
          TYPE_PLAFOND,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.DATE_DEB,
          :old.DATE_FIN,
          :old.INDICE,
          :old.MONNAIE,
          :old.NBACTES,
          :old.NBINDICE,
          :old.NUMMATH,
          :old.NUM_DOSSIER,
          :old.PLAFOND,
          :old.TAUX,
          :old.TYPE_PLAFOND,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_MAXDOSS
        (
          DATE_DEB,
          DATE_FIN,
          INDICE,
          MONNAIE,
          NBACTES,
          NBINDICE,
          NUMMATH,
          NUM_DOSSIER,
          PLAFOND,
          TAUX,
          TYPE_PLAFOND,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.DATE_DEB,
          :new.DATE_FIN,
          :new.INDICE,
          :new.MONNAIE,
          :new.NBACTES,
          :new.NBINDICE,
          :new.NUMMATH,
          :new.NUM_DOSSIER,
          :new.PLAFOND,
          :new.TAUX,
          :new.TYPE_PLAFOND,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;