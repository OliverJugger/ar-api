CREATE TRIGGER ARTHUS.trg_af_diu_prelevement
  AFTER DELETE OR INSERT OR UPDATE ON prelevement
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
   INSERT INTO histo_prelevement (
      numprelev,
      montant,
      codbque,
      guichet,
      compte,
      clerib,
      intitule,
      numencaismt,
      numremise,
      monnaie_d,
      montant_d,
      monnaie,
      eche_prelev,
      bban,
      clef_iban,
      bic,
      numquerable,
      idhistomandat,
      mandat,
      mvt,
      maj,
      statut,
      amdt_ics,
      amdt_mndt,
      amdt_acct,
      amdt_smnda,
      amdt_creancier,
      numremise_prec,
      create_mandat,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :old.numprelev,
      :old.montant,
      :old.codbque,
      :old.guichet,
      :old.compte,
      :old.clerib,
      :old.intitule,
      :old.numencaismt,
      :old.numremise,
      :old.monnaie_d,
      :old.montant_d,
      :old.monnaie,
      :old.eche_prelev,
      :old.bban,
      :old.clef_iban,
      :old.bic,
      :old.numquerable,
      :old.idhistomandat,
      :old.mandat,
      :old.mvt,
      :old.maj,
      :old.statut,
      :old.amdt_ics,
      :old.amdt_mndt,
      :old.amdt_acct,
      :old.amdt_smnda,
      :old.amdt_creancier,
      :old.numremise_prec,
      :old.create_mandat,
	  l_action,
	  f_numutil,
	  SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_prelevement (
      numprelev,
      montant,
      codbque,
      guichet,
      compte,
      clerib,
      intitule,
      numencaismt,
      numremise,
      monnaie_d,
      montant_d,
      monnaie,
      eche_prelev,
      bban,
      clef_iban,
      bic,
      numquerable,
      idhistomandat,
      mandat,
      mvt,
      maj,
      statut,
      amdt_ics,
      amdt_mndt,
      amdt_acct,
      amdt_smnda,
      amdt_creancier,
      numremise_prec,
      create_mandat,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :new.numprelev,
      :new.montant,
      :new.codbque,
      :new.guichet,
      :new.compte,
      :new.clerib,
      :new.intitule,
      :new.numencaismt,
      :new.numremise,
      :new.monnaie_d,
      :new.montant_d,
      :new.monnaie,
      :new.eche_prelev,
      :new.bban,
      :new.clef_iban,
      :new.bic,
      :new.numquerable,
      :new.idhistomandat,
      :new.mandat,
      :new.mvt,
      :new.maj,
      :new.statut,
      :new.amdt_ics,
      :new.amdt_mndt,
      :new.amdt_acct,
      :new.amdt_smnda,
      :new.amdt_creancier,
      :new.numremise_prec,
      :new.create_mandat,
	  'I',
	  f_numutil,
	  SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;