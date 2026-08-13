CREATE TRIGGER ARTHUS.trg_af_diu_encaismt
  AFTER DELETE OR INSERT OR UPDATE ON encaismt
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
   INSERT INTO histo_encaismt (
      codope,
      numencaismt,
      numcli,
      role,
      numcpte,
      numchq,
      modpmt,
      montant,
      monnaie,
      refpmt,
      datpay,
      debit,
      datcomp,
      datcompta,
      numutil,
      idcompta,
      creation,
      id_credit,
      date_credit,
      monnaie_d,
      montant_d,
      debit_d,
      modification,
      modificateur,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :old.codope,
      :old.numencaismt,
      :old.numcli,
      :old.role,
      :old.numcpte,
      :old.numchq,
      :old.modpmt,
      :old.montant,
      :old.monnaie,
      :old.refpmt,
      :old.datpay,
      :old.debit,
      :old.datcomp,
      :old.datcompta,
      :old.numutil,
      :old.idcompta,
      :old.creation,
      :old.id_credit,
      :old.date_credit,
      :old.monnaie_d,
      :old.montant_d,
      :old.debit_d,
      :old.modification,
      :old.modificateur,
	  l_action,
	  f_numutil,
	  SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_encaismt (
      codope,
      numencaismt,
      numcli,
      role,
      numcpte,
      numchq,
      modpmt,
      montant,
      monnaie,
      refpmt,
      datpay,
      debit,
      datcomp,
      datcompta,
      numutil,
      idcompta,
      creation,
      id_credit,
      date_credit,
      monnaie_d,
      montant_d,
      debit_d,
      modification,
      modificateur,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :new.codope,
      :new.numencaismt,
      :new.numcli,
      :new.role,
      :new.numcpte,
      :new.numchq,
      :new.modpmt,
      :new.montant,
      :new.monnaie,
      :new.refpmt,
      :new.datpay,
      :new.debit,
      :new.datcomp,
      :new.datcompta,
      :new.numutil,
      :new.idcompta,
      :new.creation,
      :new.id_credit,
      :new.date_credit,
      :new.monnaie_d,
      :new.montant_d,
      :new.debit_d,
      :new.modification,
      :new.modificateur,
	  'I',
	  f_numutil,
	  SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;