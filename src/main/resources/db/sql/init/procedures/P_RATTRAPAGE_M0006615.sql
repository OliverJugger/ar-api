CREATE PROCEDURE ARTHUS.P_RATTRAPAGE_M0006615
IS
  G_nbre_lignes         Number := 1;
  o_erreur              VARCHAR2(200):=NULL;
  
  CURSOR c_remise
      IS
		with extr as (select 
		  ap.numremise , ap.datrait , ap.entreprise , ap.etabli , ap.num_ordre , ap.numligne , ap.etat
		  , case when ap.etat = 2  then 1 else 0 end     nb_2
		  , case when ap.etat != 2 then 1 else 0 end     nb_autre
		from affil_porte ap 
		where ap.datrait >= e2d('07/05/2020')
        --and  ap.numremise =   63254
		)

		select
		  pr.dateremise, pr.numporte , 
		  ap.numremise , --ap.entreprise , ap.etabli , ap.num_ordre , 
		  sum(nb_2)  nb_2 , sum(nb_autre) nb_autre
		from extr ap
		inner join affil_fichier af on (    af.numremise  = ap.numremise
										and af.entreprise = ap.entreprise
										and af.etabli     = ap.etabli
										and af.num_ordre  = ap.num_ordre
										and af.NUM_ANNULANTE is null
										and af.nature = 1 )
		inner join porte_remise pr on (pr.numporte = 20 and pr.numremise = ap.numremise)
		group by pr.numporte , pr.dateremise,ap.numremise --, ap.entreprise , ap.etabli , ap.num_ordre
		having sum(nb_autre) = 0 and sum(nb_2) > 0  
		order by pr.numporte , pr.dateremise,ap.numremise desc --, ap.entreprise , ap.etabli , ap.num_ordre
		;
    
  loc_heure number;
  loc_minutes number;
  
BEGIN


  FOR rec_remise IN c_remise LOOP
    PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_IMPORT_FILES_DSN',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => 'debut integ fonct remise ' || rec_remise.numremise ,
          I_idligne  => 1);
          
    
    -- MUR M0006485
    SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
    SELECT to_char(sysdate, 'mi') into loc_minutes FROM DUAL;
    -- fin traitement 13h30
    IF loc_heure >=13 and loc_minutes >= 30 THEN
      PK_trace.P_INS_journal_adm (
          I_nom_traitement => 'P_IMPORT_FILES_DSN',
          I_session  => SID,
          I_niv_msg  => 1,
          I_msg_adm  => 'fin traitement delai depassé ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') ,
          I_idligne  => 1); 
      EXIT;  --dernier traitement à 13h30
    END IF ;

     
    ARTHUS.PK_GEST_AFFIL.P_GestAffiliation ( rec_remise.numremise
                                           , rec_remise.numporte
                                           , 7
                                           , 7
                                           , SID
                                           , 'AF04T'
                                           , G_nbre_lignes
                                           , NULL
                                           , NULL
                                           , o_erreur) ;
  END LOOP;

  
EXCEPTION
  WHEN OTHERS THEN
  PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'P_IMPORT_FILES_DSN',
        I_session  => SID,
        I_niv_msg  => 1,
        I_msg_adm  => substr(sqlerrm,1,132),
        I_idligne  => 1);
    ROLLBACK;
END P_RATTRAPAGE_M0006615;
/
