CREATE TRIGGER ARTHUS.TRG_BF_INS_CLAUSE BEFORE INSERT ON CLAUSE FOR EACH ROW
DECLARE
BEGIN
    :new.USERCREA := f_numutil;
    :new.DATECREA := sysdate;
EXCEPTION
  WHEN OTHERS THEN

      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'TRG_BF_INS_CLAUSE',
          I_session  => SID,
          I_niv_msg  => 3,
          I_msg_adm  => substr(SQLERRM,1,132),
          I_idligne  => 1);

END;