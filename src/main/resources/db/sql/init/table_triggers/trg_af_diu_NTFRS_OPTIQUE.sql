CREATE TRIGGER ARTHUS.trg_af_diu_NTFRS_OPTIQUE
  AFTER DELETE OR INSERT OR UPDATE ON NTFRS_OPTIQUE
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
   INSERT INTO histo_NTFRS_OPTIQUE (ADDITION_DEB,
									ADDITION_FIN,
									AMINCI_DEB,
									AMINCI_FIN,
									CODFRAIS,
									CYLINDRE_DEB,
									CYLINDRE_FIN,
									FAMILLE,
									NATURE,
									SPHEREN_DEB,
									SPHEREN_FIN,
									SPHEREP_DEB,
									SPHEREP_FIN,
									TEINTE,
									action_histo,
									numutil_histo,
									date_histo)
   VALUES (	:old.ADDITION_DEB,
			:old.ADDITION_FIN,
			:old.AMINCI_DEB,
			:old.AMINCI_FIN,
			:old.CODFRAIS,
			:old.CYLINDRE_DEB,
			:old.CYLINDRE_FIN,
			:old.FAMILLE,
			:old.NATURE,
			:old.SPHEREN_DEB,
			:old.SPHEREN_FIN,
			:old.SPHEREP_DEB,
			:old.SPHEREP_FIN,
			:old.TEINTE,
			l_action,
			f_numutil,
			SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_NTFRS_OPTIQUE (ADDITION_DEB,
									ADDITION_FIN,
									AMINCI_DEB,
									AMINCI_FIN,
									CODFRAIS,
									CYLINDRE_DEB,
									CYLINDRE_FIN,
									FAMILLE,
									NATURE,
									SPHEREN_DEB,
									SPHEREN_FIN,
									SPHEREP_DEB,
									SPHEREP_FIN,
									TEINTE,
									action_histo,
									numutil_histo,
									date_histo)
   VALUES ( :new.ADDITION_DEB,
			:new.ADDITION_FIN,
			:new.AMINCI_DEB,
			:new.AMINCI_FIN,
			:new.CODFRAIS,
			:new.CYLINDRE_DEB,
			:new.CYLINDRE_FIN,
			:new.FAMILLE,
			:new.NATURE,
			:new.SPHEREN_DEB,
			:new.SPHEREN_FIN,
			:new.SPHEREP_DEB,
			:new.SPHEREP_FIN,
			:new.TEINTE,
			'I',
			f_numutil,
			SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;