CREATE PROCEDURE ARTHUS.P_transfert_job (i_numgar IN NUMBER, i_numgar_old IN NUMBER, i_date DATE) IS
loc_numfor_g NUMBER;
loc_numfor_l NUMBER;

begin
pk_trace.p_ins_journal_adm ('Job_transfert', 1, 0, 'Début transfert :' ||i_numgar );

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
EXCEPTION
    WHEN too_many_rows THEN 
      pk_trace.p_ins_journal_adm ('Job_transfert', 1, 0, 'garantie multiple contrat' ||i_numgar );
    WHEN no_data_found THEN
      pk_trace.p_ins_journal_adm ('Job_transfert', 1, 0, 'garantie inconnue contrat' ||i_numgar );
    WHEN OTHERS THEN 
      pk_trace.p_ins_journal_adm ('Job_transfert', 1, 0, 'Err Oracle' ||i_numgar ||' '|| SQLERRM);
END P_transfert_job;
/
