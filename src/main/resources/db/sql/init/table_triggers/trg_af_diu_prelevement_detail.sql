CREATE TRIGGER ARTHUS.trg_af_diu_prelevement_detail
  AFTER DELETE OR INSERT OR UPDATE ON prelevement_detail
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
   INSERT INTO histo_prelevement_detail (
      numprelev,
      codope,
      numfact,
      montant,
      idaffec,
      valide,
      monnaie_d,
      montant_d,
      monnaie,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :old.numprelev,
      :old.codope,
      :old.numfact,
      :old.montant,
      :old.idaffec,
      :old.valide,
      :old.monnaie_d,
      :old.montant_d,
      :old.monnaie,
	  l_action,
	  f_numutil,
	  SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_prelevement_detail (
      numprelev,
      codope,
      numfact,
      montant,
      idaffec,
      valide,
      monnaie_d,
      montant_d,
      monnaie,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :new.numprelev,
      :new.codope,
      :new.numfact,
      :new.montant,
      :new.idaffec,
      :new.valide,
      :new.monnaie_d,
      :new.montant_d,
      :new.monnaie,
	  'I',
	  f_numutil,
	  SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;