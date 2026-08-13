CREATE TRIGGER ARTHUS.trg_af_diu_remise_vire_detail
  AFTER DELETE OR INSERT OR UPDATE ON remise_vire_detail
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
   INSERT INTO histo_remise_vire_detail (
      numremise,
      numvirement,
      numcpte,
      numdecaismt,
      montant,
      codbque,
      guichet,
      compte,
      clerib,
      intitule,
      clef_iban,
      bban,
      bic,
      codpays,
      monnaie_d,
      montant_d,
      monnaie,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :old.numvirement,
      :old.numremise,
      :old.numcpte,
      :old.numdecaismt,
      :old.montant,
      :old.codbque,
      :old.guichet,
      :old.compte,
      :old.clerib,
      :old.intitule,
      :old.clef_iban,
      :old.bban,
      :old.bic,
      :old.codpays,
      :old.monnaie_d,
      :old.montant_d,
      :old.monnaie,
	  l_action,
	  f_numutil,
	  SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_remise_vire_detail (
      numremise,
      numvirement,
      numcpte,
      numdecaismt,
      montant,
      codbque,
      guichet,
      compte,
      clerib,
      intitule,
      clef_iban,
      bban,
      bic,
      codpays,
      monnaie_d,
      montant_d,
      monnaie,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :new.numvirement,
      :new.numremise,
      :new.numcpte,
      :new.numdecaismt,
      :new.montant,
      :new.codbque,
      :new.guichet,
      :new.compte,
      :new.clerib,
      :new.intitule,
      :new.clef_iban,
      :new.bban,
      :new.bic,
      :new.codpays,
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