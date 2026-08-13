CREATE PROCEDURE ARTHUS.P_transfert_socotec_job (i_numgar IN NUMBER, i_numgar_old IN NUMBER, i_date DATE) IS
loc_numfor_g NUMBER;
loc_numfor_l NUMBER;

begin


PK_TRANSFERT.P_Transfert_adhe (
      a_idporte => 2, 
      a_type => 2,--transfert
      a_old_numgar => i_numgar_old,
      a_numgar => i_numgar,
      a_debut => i_date,
      a_motif => 42,
      a_numedit => 1
   );
   COMMIT;
  --sur mesure socotec 
  select f.numfor INTO loc_numfor_g
  from formule f ,gar_cntrt g 
  where f.obli_bene=8  
  and f.libelle like '%régime général%'
  and f.numfor = g.numfor
  and g.numgar=i_numgar;


  --sur mesure socotec 
  select f.numfor INTO loc_numfor_l
  from formule f ,gar_cntrt g 
  where f.obli_bene=8  
  and f.libelle like '%régime local%'
  and f.numfor = g.numfor
  and g.numgar=i_numgar;

  update adhesion set numfor = loc_numfor_g 
  where numgar = i_numgar 
  and numindiv in (select numindiv from adhe_cntrt_membre where typadr in(1,3,7) and idadhesion =adhesion.idadhesion)
  and numfor in (select numfor from gar_cntrt where libelle like '%régime général%'  and numgar =i_numgar );

  update adhesion set numfor = loc_numfor_l
  where numgar = i_numgar 
  and numindiv in (select numindiv from adhe_cntrt_membre where typadr in(1,3,7) and idadhesion =adhesion.idadhesion)
  and numfor in (select numfor from gar_cntrt where libelle like '%régime local%' and numgar =i_numgar );
  commit;
  EXCEPTION
    WHEN too_many_rows THEN 
      pk_trace.p_ins_journal_adm ('Job_transfert', 1, 0, 'garantie multiple contrat' ||i_numgar );
    WHEN no_data_found THEN
      pk_trace.p_ins_journal_adm ('Job_transfert', 1, 0, 'garantie inconnue contrat' ||i_numgar );
    WHEN OTHERS THEN 
      pk_trace.p_ins_journal_adm ('Job_transfert', 1, 0, 'Err Oracle' ||i_numgar ||' '|| SQLERRM);
END P_transfert_socotec_job;
/
