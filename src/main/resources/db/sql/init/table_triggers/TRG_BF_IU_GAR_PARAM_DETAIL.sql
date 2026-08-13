CREATE TRIGGER ARTHUS."TRG_BF_IU_GAR_PARAM_DETAIL"
BEFORE UPDATE OR INSERT
   ON GAR_PARAM_DETAIL
    REFERENCING OLD AS old NEW AS new
FOR EACH ROW
DECLARE
 l_GAR_PARAM_DETAIL HISTO_GAR_PARAM_DETAIL%rowtype;
-- objet_courant GAR_PARAM_DETAIL;
 l_action       VARCHAR2(1);
BEGIN

  IF UPDATING THEN
    l_action:='U';
    l_GAR_PARAM_DETAIL.NUMFOR         := :old.NUMFOR;
    l_GAR_PARAM_DETAIL.SEQ            := :old.SEQ;
    l_GAR_PARAM_DETAIL.CODE_OPTION    := :old.CODE_OPTION;
    l_GAR_PARAM_DETAIL.DEBUT          := :old.DEBUT;
    l_GAR_PARAM_DETAIL.FIN            := :old.FIN;
    l_GAR_PARAM_DETAIL.USERCREA       := :old.USERCREA;
    l_GAR_PARAM_DETAIL.DATECREA       := :old.DATECREA;
    l_GAR_PARAM_DETAIL.USERMAJ        := :old.USERMAJ;
    l_GAR_PARAM_DETAIL.DATEMAJ        := :old.DATEMAJ;
    l_GAR_PARAM_DETAIL.LIB_OPTION     := :old.LIB_OPTION;
    :new.USERMAJ := f_numutil;
    :new.DATEMAJ := sysdate;
  ELSE
    l_action:='I';
    l_GAR_PARAM_DETAIL.NUMFOR         := :new.NUMFOR;
    l_GAR_PARAM_DETAIL.SEQ            := :new.SEQ;
    l_GAR_PARAM_DETAIL.CODE_OPTION    := :new.CODE_OPTION;
    l_GAR_PARAM_DETAIL.DEBUT          := :new.DEBUT;
    l_GAR_PARAM_DETAIL.FIN            := :new.FIN;
    l_GAR_PARAM_DETAIL.USERCREA       := :new.USERCREA;
    l_GAR_PARAM_DETAIL.DATECREA       := :new.DATECREA;
    l_GAR_PARAM_DETAIL.USERMAJ        := :new.USERMAJ;
    l_GAR_PARAM_DETAIL.DATEMAJ        := :new.DATEMAJ;
    l_GAR_PARAM_DETAIL.LIB_OPTION     := :new.LIB_OPTION;
    :new.USERCREA := f_numutil;
    :new.DATECREA := sysdate;
  END IF;

  -- Automatisation des fiches de paramétrages CLI 17/04/2018
    l_GAR_PARAM_DETAIL.ACTION_HISTO   := l_action;
    l_GAR_PARAM_DETAIL.NUMUTIL_HISTO  := F_NUMUTIL();
    l_GAR_PARAM_DETAIL.DATE_HISTO     := sysdate;

   insert into  HISTO_GAR_PARAM_DETAIL values l_GAR_PARAM_DETAIL;



EXCEPTION
   WHEN OTHERS THEN
   PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_BF_UPD_GAR_PARAM_DETAIL'
							  , I_session => SID
							  , I_niv_msg => 3
							  , I_msg_adm => SUBSTR(SQLERRM,1,132)
							  , I_idligne => 1);
END;