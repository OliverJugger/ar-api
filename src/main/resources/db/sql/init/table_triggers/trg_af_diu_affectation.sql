CREATE TRIGGER ARTHUS.trg_af_diu_affectation
  AFTER DELETE OR INSERT OR UPDATE ON affectation
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
   INSERT INTO histo_affectation (
      codope,
	  numaffec,
	  numdecaismt,
	  montant,
	  monnaie,
	  nbfeuille,
	  dataffec,
	  numcli,
	  montant_d,
	  monnaie_d,
	  montant_ec,
	  type_ec,
	  sens_ec,
	  devise_ec,
	  montant_ct,
	  devise_ct,
	  idcompta,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :old.codope,
	  :old.numaffec,
	  :old.numdecaismt,
	  :old.montant,
	  :old.monnaie,
	  :old.nbfeuille,
	  :old.dataffec,
	  :old.numcli,
	  :old.montant_d,
	  :old.monnaie_d,
	  :old.montant_ec,
	  :old.type_ec,
	  :old.sens_ec,
	  :old.devise_ec,
	  :old.montant_ct,
	  :old.devise_ct,
	  :old.idcompta,
	  l_action,
	  f_numutil,
	  SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_affectation (
      codope,
	  numaffec,
	  numdecaismt,
	  montant,
	  monnaie,
	  nbfeuille,
	  dataffec,
	  numcli,
	  montant_d,
	  monnaie_d,
	  montant_ec,
	  type_ec,
	  sens_ec,
	  devise_ec,
	  montant_ct,
	  devise_ct,
	  idcompta,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :new.codope,
	  :new.numaffec,
	  :new.numdecaismt,
	  :new.montant,
	  :new.monnaie,
	  :new.nbfeuille,
	  :new.dataffec,
	  :new.numcli,
	  :new.montant_d,
	  :new.monnaie_d,
	  :new.montant_ec,
	  :new.type_ec,
	  :new.sens_ec,
	  :new.devise_ec,
	  :new.montant_ct,
	  :new.devise_ct,
	  :new.idcompta,
	  'I',
	  f_numutil,
	  SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;