CREATE TRIGGER ARTHUS.trg_af_diu_NTFRS_DETAIL AFTER
  DELETE OR
  INSERT OR
  UPDATE ON NTFRS_DETAIL REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_NTFRS_DETAIL
        (
          AUDITIF,
          BASSE_VISION,
          CODFRAIS,
          CUMUL,
          DENTAIRE,
          LENTILLE,
          MONTURE,
          PRODUIT,
          SECU,
          VERRE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.AUDITIF,
          :old.BASSE_VISION,
          :old.CODFRAIS,
          :old.CUMUL,
          :old.DENTAIRE,
          :old.LENTILLE,
          :old.MONTURE,
          :old.PRODUIT,
          :old.SECU,
          :old.VERRE,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_NTFRS_DETAIL
        (
          AUDITIF,
          BASSE_VISION,
          CODFRAIS,
          CUMUL,
          DENTAIRE,
          LENTILLE,
          MONTURE,
          PRODUIT,
          SECU,
          VERRE,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.AUDITIF,
          :new.BASSE_VISION,
          :new.CODFRAIS,
          :new.CUMUL,
          :new.DENTAIRE,
          :new.LENTILLE,
          :new.MONTURE,
          :new.PRODUIT,
          :new.SECU,
          :new.VERRE,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;