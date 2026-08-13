CREATE TRIGGER ARTHUS.trg_af_diu_PORTE_NATFRAIS AFTER
  DELETE OR
  INSERT OR
  UPDATE ON PORTE_NATFRAIS REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
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
      INTO histo_PORTE_NATFRAIS
        (
          ACTION,
          CHAMP,
          CHAMP2,
          CODE_SPEC,
          CODE_ZONE,
          CODFRAIS,
          CODFRAIS_PORTE,
          CODFRAIS_PORTE_C,
          CODFRAIS_PORTE_NC,
          CREATION,
          MAJ,
          MOTIF,
          NUMPORTE,
          NUMUTIL,
          OPERATEUR,
          OPERATEUR2,
          REGIME,
          VALEUR,
          VALEUR2,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :old.ACTION,
          :old.CHAMP,
          :old.CHAMP2,
          :old.CODE_SPEC,
          :old.CODE_ZONE,
          :old.CODFRAIS,
          :old.CODFRAIS_PORTE,
          :old.CODFRAIS_PORTE_C,
          :old.CODFRAIS_PORTE_NC,
          :old.CREATION,
          :old.MAJ,
          :old.MOTIF,
          :old.NUMPORTE,
          :old.NUMUTIL,
          :old.OPERATEUR,
          :old.OPERATEUR2,
          :old.REGIME,
          :old.VALEUR,
          :old.VALEUR2,
          l_action,
          f_numutil,
          SYSDATE
        );
    END IF;
    -- INSERT (new vlaues)
    IF INSERTING THEN
      INSERT
      INTO histo_PORTE_NATFRAIS
        (
          ACTION,
          CHAMP,
          CHAMP2,
          CODE_SPEC,
          CODE_ZONE,
          CODFRAIS,
          CODFRAIS_PORTE,
          CODFRAIS_PORTE_C,
          CODFRAIS_PORTE_NC,
          CREATION,
          MAJ,
          MOTIF,
          NUMPORTE,
          NUMUTIL,
          OPERATEUR,
          OPERATEUR2,
          REGIME,
          VALEUR,
          VALEUR2,
          action_histo,
          numutil_histo,
          date_histo
        )
        VALUES
        (
          :new.ACTION,
          :new.CHAMP,
          :new.CHAMP2,
          :new.CODE_SPEC,
          :new.CODE_ZONE,
          :new.CODFRAIS,
          :new.CODFRAIS_PORTE,
          :new.CODFRAIS_PORTE_C,
          :new.CODFRAIS_PORTE_NC,
          :new.CREATION,
          :new.MAJ,
          :new.MOTIF,
          :new.NUMPORTE,
          :new.NUMUTIL,
          :new.OPERATEUR,
          :new.OPERATEUR2,
          :new.REGIME,
          :new.VALEUR,
          :new.VALEUR2,
          'I',
          f_numutil,
          SYSDATE
        );
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;