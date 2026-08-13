CREATE TRIGGER ARTHUS.trg_af_diu_NATFRAIS
  AFTER DELETE OR INSERT OR UPDATE ON NATFRAIS
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
   INSERT INTO histo_NATFRAIS (CNVTN,
								CODFRAIS,
								LIBELLE,
								NOMBRE,
								PRIXMAX,
								PRIXMIN,
								REMBTSSMAX,
								REMBTSSMIN,
								RUBRIQUE,
								SEL,
								TYPE,
								TYPE_ACTE,
								action_histo,
								numutil_histo,
								date_histo)
   VALUES (	:old.CNVTN,
			:old.CODFRAIS,
			:old.LIBELLE,
			:old.NOMBRE,
			:old.PRIXMAX,
			:old.PRIXMIN,
			:old.REMBTSSMAX,
			:old.REMBTSSMIN,
			:old.RUBRIQUE,
			:old.SEL,
			:old.TYPE,
			:old.TYPE_ACTE,
			l_action,
			f_numutil,
			SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_NATFRAIS (	CNVTN,
								CODFRAIS,
								LIBELLE,
								NOMBRE,
								PRIXMAX,
								PRIXMIN,
								REMBTSSMAX,
								REMBTSSMIN,
								RUBRIQUE,
								SEL,
								TYPE,
								TYPE_ACTE,
								action_histo,
								numutil_histo,
								date_histo)
   VALUES (	:new.CNVTN,
			:new.CODFRAIS,
			:new.LIBELLE,
			:new.NOMBRE,
			:new.PRIXMAX,
			:new.PRIXMIN,
			:new.REMBTSSMAX,
			:new.REMBTSSMIN,
			:new.RUBRIQUE,
			:new.SEL,
			:new.TYPE,
			:new.TYPE_ACTE,
			'I',
			f_numutil,
			SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;