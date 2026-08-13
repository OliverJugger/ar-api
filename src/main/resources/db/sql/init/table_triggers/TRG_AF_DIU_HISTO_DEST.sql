CREATE TRIGGER ARTHUS.TRG_AF_DIU_HISTO_DEST
  AFTER DELETE OR INSERT OR UPDATE ON HISTO_DEST
  REFERENCING OLD AS old NEW AS new
  FOR EACH ROW
DECLARE
      l_action       VARCHAR2(1);
BEGIN
  -- DELETE OR UPDATE (old values)
  IF DELETING OR UPDATING THEN
    IF DELETING THEN
      l_action := 'D';
    END IF;
    IF UPDATING THEN
      l_action := 'U';
    END IF;

    INSERT INTO H_HISTO_DEST
           (DATECREA,
            DATEMAJ,
            DEBUT,
            FIN,
            IDREPARTITION,
            NUMBENE,
            NUMBENE_DEST,
            TYPE_DEST,
            USERCREA,
            USERMAJ,
            ACTION_HISTO,
            NUMUTIL_HISTO,
            DATE_HISTO
           )
    VALUES (:old.DATECREA,
            :old.DATEMAJ,
            :old.DEBUT,
            :old.FIN,
            :old.IDREPARTITION,
            :old.NUMBENE,
            :old.NUMBENE_DEST,
            :old.TYPE_DEST,
            :old.USERCREA,
            :old.USERMAJ,
            L_ACTION,
            F_NUMUTIL,
            SYSDATE
           );
  END IF;

  -- INSERT (new vlaues)
  IF INSERTING THEN
    INSERT INTO H_HISTO_DEST
           (DATECREA,
            DATEMAJ,
            DEBUT,
            FIN,
            IDREPARTITION,
            NUMBENE,
            NUMBENE_DEST,
            TYPE_DEST,
            USERCREA,
            USERMAJ,
            action_histo,
            numutil_histo,
            date_histo
           )
    VALUES (:new.DATECREA,
            :new.DATEMAJ,
            :new.DEBUT,
            :new.FIN,
            :new.IDREPARTITION,
            :new.NUMBENE,
            :new.NUMBENE_DEST,
            :new.TYPE_DEST,
            :new.USERCREA,
            :new.USERMAJ,
            'I',
            f_numutil,
            SYSDATE
           );
  END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;