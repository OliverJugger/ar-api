CREATE PROCEDURE ARTHUS.mimi
                     ( I_idrevers      IN qttc_affec_tfc.idrevers%TYPE,
                       I_date_deb      IN DATE DEFAULT NULL,
                       I_date_Fin      IN DATE DEFAULT NULL,
                       I_idaffec       IN qttc_affec_tfc.idaffec%TYPE,
                       I_tfc           IN qttc_affec_tfc.tfc%TYPE,
                       I_type_tfc      IN qttc_affec_tfc.type_tfc%TYPE,
                       I_prelev_revers IN qttc_affec_tfc.prelev_revers%TYPE
			              			           DEFAULT NULL)
IS
  G_nom_traitement varchar2(10) := 'MIN';
  G_session number := 1;
  G_niv_msg number :=1;
  G_msg_adm Varchar2(132);
BEGIN
  G_msg_adm := to_char(I_idrevers)||'  '|| to_char(I_idaffec)||'  '||
               to_char(I_tfc)||'  '||to_char(I_type_tfc)||'  '||
               to_char(I_prelev_revers)||'    '||
               NVL(I_date_deb,to_char(SYSDATE,'DD/Mon/YYYY'))||' '||
               NVL(I_date_fin,to_char(SYSDATE,'DD/mon/YYYY'));
  --
   PK_trace.P_INS_journal_adm(I_nom_traitement => G_nom_traitement,
                             I_session        => G_session,
                             I_niv_msg        => G_niv_msg,
                             I_msg_adm        => G_msg_adm);
  /*  UPDATE qttc_affec_tfc
   SET    idrevers      = I_idrevers
   WHERE  idaffec       = I_idaffec
   AND    tfc           = I_tfc
   AND    type_tfc      = I_type_tfc
   AND    NVL(prelev_revers,-1) = NVL(I_prelev_revers,-1); */
--
COMMIT;
END;
/
