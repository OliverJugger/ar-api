CREATE PROCEDURE ARTHUS.P_M0007172_2 IS

-- attention : verifier heure de fin de traitement
--2700 adhesion / heure
  cursor c_cur is 
    select * from M0007172
	where traite = 'N'
  order by numprod
	--and numindiv = 124111 -- pour test
	; 
  cur c_cur%rowtype ; 

  loc_heure number;
  loc_minutes number;
  loc_nbre number ; 

begin
  loc_nbre := 0 ; 
  PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'M0007172',
          I_session  => 0,
          I_niv_msg  => 1,
          I_msg_adm  => 'debut trt ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') ,
          I_idligne  => 1);

  for cur in c_cur loop

	update M0007172
	set traite = 'O' 
	where numindiv = cur.numindiv and numgar = cur.numgar  and numfor =  cur.numfor;

	p_affil_prevoyance(cur.numindiv,cur.numgar,cur.numfor,to_char(cur.deb_couverture,'dd/mm/yyyy'),to_char(cur.datper_max,'dd/mm/yyyy')); -- commit dans procedure si pas d'ano


	loc_nbre := loc_nbre + 1 ;

    -- controle heure fin de traitement
	SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
    SELECT to_char(sysdate, 'mi') into loc_minutes FROM DUAL;

    IF loc_heure >=20 and loc_minutes >= 00 THEN
	  PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'M0007172',
          I_session  => 0,
          I_niv_msg  => 1,
          I_msg_adm  => 'fin traitement delai depassé  nbre ' || loc_nbre || ' ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') ,
          I_idligne  => 1);
      EXIT;  
    end if ; 

  end loop ;

    PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'M0007172',
          I_session  => 0,
          I_niv_msg  => 1,
          I_msg_adm  => 'fin trt nbre ' || loc_nbre || ' ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') ,
          I_idligne  => 1);
end P_M0007172_2;
/
