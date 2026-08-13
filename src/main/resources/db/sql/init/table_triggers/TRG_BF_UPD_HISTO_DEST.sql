CREATE TRIGGER ARTHUS.TRG_BF_UPD_HISTO_DEST BEFORE UPDATE ON HISTO_DEST FOR EACH ROW
DECLARE
BEGIN
    :new.USERMAJ   := f_numutil;
    :new.DATEMAJ   := sysdate;
EXCEPTION
  WHEN OTHERS THEN

      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'TRG_BF_UPD_HISTO_DEST',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(SQLERRM,1,132),
          I_idligne  => 1);

END;