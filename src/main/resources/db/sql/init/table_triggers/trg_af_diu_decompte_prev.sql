CREATE TRIGGER ARTHUS.trg_af_diu_decompte_prev
  AFTER DELETE OR INSERT OR UPDATE ON decompte_prev
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
   INSERT INTO histo_decompte_prev (
      numdec,
      idadhesion,
      numdcptcie,
      datpay,
      montant,
      monnaie_d,
      montant_d,
      monnaie,
	  idcompta,
      numutil,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :old.numdec,
      :old.idadhesion,
      :old.numdcptcie,
      :old.datpay,
      :old.montant,
      :old.monnaie_d,
      :old.montant_d,
      :old.monnaie,
	  :old.idcompta,
      :old.numutil,
	  l_action,
	  f_numutil,
	  SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_decompte_prev (
      numdec,
      idadhesion,
      numdcptcie,
      datpay,
      montant,
      monnaie_d,
      montant_d,
      monnaie,
	  idcompta,
      numutil,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :new.numdec,
      :new.idadhesion,
      :new.numdcptcie,
      :new.datpay,
      :new.montant,
      :new.monnaie_d,
      :new.montant_d,
      :new.monnaie,
	  :new.idcompta,
      :new.numutil,
	  'I',
	  f_numutil,
	  SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;