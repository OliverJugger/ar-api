CREATE TRIGGER ARTHUS.TRG_BF_INS_VAL_VARIABLE BEFORE INSERT ON VAL_VARIABLE FOR EACH ROW
DECLARE
BEGIN
  IF :new.USERCREA IS NULL THEN
    :new.USERCREA := f_numutil;
  END IF;
  :new.DATECREA := sysdate;
EXCEPTION
  WHEN OTHERS THEN

      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'TRG_AF_INS_VAL_VARIABLE',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(SQLERRM,1,132),
          I_idligne  => 1);

END;