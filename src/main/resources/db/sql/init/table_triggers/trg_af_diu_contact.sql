CREATE TRIGGER ARTHUS.trg_af_diu_contact
  AFTER DELETE OR INSERT OR UPDATE ON contact
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
   INSERT INTO histo_contact (
                NUMINDIV
              , NATURE
              , TYPE
              , COORDONNEE
              , FLAG
              , CREATION
              , MAJ
              , NUMUTIL
              , IDCONTACT
              , ACTION_HISTO
              , NUMUTIL_HISTO
              , DATE_HISTO
    )
   VALUES (
                :old.NUMINDIV
              , :old.NATURE
              , :old.TYPE
              , :old.COORDONNEE
              , :old.FLAG
              , :old.CREATION
              , :old.MAJ
              , :old.NUMUTIL
              , :old.IDCONTACT
              , l_action
              , f_numutil
              ,  SYSDATE
                );
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_contact (
                NUMINDIV
              , NATURE
              , TYPE
              , COORDONNEE
              , FLAG
              , CREATION
              , MAJ
              , NUMUTIL
              , IDCONTACT
              , ACTION_HISTO
              , NUMUTIL_HISTO
              , DATE_HISTO

                    )
   VALUES (
                :new.NUMINDIV
              , :new.NATURE
              , :new.TYPE
              , :new.COORDONNEE
              , :new.FLAG
              , :new.CREATION
              , :new.MAJ
              , :new.NUMUTIL
              , :new.IDCONTACT
              , 'I'
              , f_numutil
              , SYSDATE
                );
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;