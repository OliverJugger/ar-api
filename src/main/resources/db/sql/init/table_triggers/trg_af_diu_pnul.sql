CREATE TRIGGER ARTHUS.trg_af_diu_pnul
  AFTER DELETE OR INSERT OR UPDATE ON pnul
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
   INSERT INTO histo_pnul (
      numcpte,
      numchq,
      modpmt,
      datpay,
      datannul,
      motif,
      userid,
      refpmt,
      codope,
      numdecaismt,
      numaffec,
      numdcptcie,
      idcompta,
      remb,
      numdcptcie_init,
      idcompta_init,
      numdcptcie_sin,
      numdcptcie_sin_init,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :old.numcpte,
      :old.numchq,
      :old.modpmt,
      :old.datpay,
      :old.datannul,
      :old.motif,
      :old.userid,
      :old.refpmt,
      :old.codope,
      :old.numdecaismt,
      :old.numaffec,
      :old.numdcptcie,
      :old.idcompta,
      :old.remb,
      :old.numdcptcie_init,
      :old.idcompta_init,
      :old.numdcptcie_sin,
      :old.numdcptcie_sin_init,
	  l_action,
	  f_numutil,
	  SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_pnul (
      numcpte,
      numchq,
      modpmt,
      datpay,
      datannul,
      motif,
      userid,
      refpmt,
      codope,
      numdecaismt,
      numaffec,
      numdcptcie,
      idcompta,
      remb,
      numdcptcie_init,
      idcompta_init,
      numdcptcie_sin,
      numdcptcie_sin_init,
	  action_histo,
	  numutil_histo,
	  date_histo)
   VALUES (
      :new.numcpte,
      :new.numchq,
      :new.modpmt,
      :new.datpay,
      :new.datannul,
      :new.motif,
      :new.userid,
      :new.refpmt,
      :new.codope,
      :new.numdecaismt,
      :new.numaffec,
      :new.numdcptcie,
      :new.idcompta,
      :new.remb,
      :new.numdcptcie_init,
      :new.idcompta_init,
      :new.numdcptcie_sin,
      :new.numdcptcie_sin_init,
	  'I',
	  f_numutil,
	  SYSDATE);
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;