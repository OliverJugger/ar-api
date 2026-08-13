CREATE TRIGGER ARTHUS.TRG_BF_UPD_VAL_VARIABLE BEFORE UPDATE ON VAL_VARIABLE FOR EACH ROW
DECLARE
BEGIN
  IF :new.USERMAJ IS NULL THEN
    :new.USERMAJ := f_numutil;
  END IF;
  :new.DATEMAJ := sysdate;
EXCEPTION
  WHEN OTHERS THEN

      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'TRG_BF_UPD_VAL_VARIABLE',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(SQLERRM,1,132),
          I_idligne  => 1);

END;