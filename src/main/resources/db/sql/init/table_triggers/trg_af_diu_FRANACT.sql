CREATE TRIGGER ARTHUS.trg_af_diu_FRANACT AFTER
  DELETE OR
  INSERT OR
  UPDATE ON FRANACT REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_FRANACT
        (
          CODFRAIS,
          DATAPLI,
          DATPER,
          DATREF,
          DOMAINE,
          ETENDUE,
          FREQUENCE,
          INDICE,
          MONTANT,
          NBINDICE,
          NUMFOR,
          NUMMATH,
          NUMORG,
          TAUX,
          TYPFRAN,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.CODFRAIS,
          :old.DATAPLI,
          :old.DATPER,
          :old.DATREF,
          :old.DOMAINE,
          :old.ETENDUE,
          :old.FREQUENCE,
          :old.INDICE,
          :old.MONTANT,
          :old.NBINDICE,
          :old.NUMFOR,
          :old.NUMMATH,
          :old.NUMORG,
          :old.TAUX,
          :old.TYPFRAN,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_FRANACT
        (
          CODFRAIS,
          DATAPLI,
          DATPER,
          DATREF,
          DOMAINE,
          ETENDUE,
          FREQUENCE,
          INDICE,
          MONTANT,
          NBINDICE,
          NUMFOR,
          NUMMATH,
          NUMORG,
          TAUX,
          TYPFRAN,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.CODFRAIS,
          :new.DATAPLI,
          :new.DATPER,
          :new.DATREF,
          :new.DOMAINE,
          :new.ETENDUE,
          :new.FREQUENCE,
          :new.INDICE,
          :new.MONTANT,
          :new.NBINDICE,
          :new.NUMFOR,
          :new.NUMMATH,
          :new.NUMORG,
          :new.TAUX,
          :new.TYPFRAN,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;