CREATE TRIGGER ARTHUS."TRG_AD_QTTC_GLOBAL"
BEFORE DELETE
ON QTTC_GLOBAL REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
begin
	Insert Into qttc_global_delete (NUMQUIT,NUMGAR,TYPE_QTTC,COMPTANT, PRELEV, NUMQUERABLE, ETENDUE,
  	 			 					NUMINDIV, DATEMIS, DEBUT, FIN, MT_NET, MT_TTC, MT_AFFEC, NAT_CALC,
									NUMECHE,IDADHESION,numutil,date_tt)
	Values (:old.NUMQUIT,:old.NUMGAR,:old.TYPE_QTTC,:old.COMPTANT, :old.PRELEV, :old.NUMQUERABLE,:old.ETENDUE,
  	 			 :old.NUMINDIV, :old.DATEMIS, :old.DEBUT, :old.FIN, :old.MT_NET, :old.MT_TTC, :old.MT_AFFEC, :old.NAT_CALC,
				:old.NUMECHE,:old.IDADHESION,f_numutil,sysdate);

	If ( :old.nat_calc = 1 and :old.comptant != 'R' ) then
		pk_qttc.P_DEL_variable_a_blanc (
			I_numquit	=>	:old.numquit,
			I_type_qttc	=>	:old.type_qttc,
			I_numgar	=>	:old.numgar,
			I_idadhesion	=>	:old.idadhesion,
			I_debut		=>	:old.debut,
			I_fin		=>	:old.fin
			);
	End if;
	DELETE	emission
	WHERE	emission.codope=4
	AND	emission.numfact = :old.numquit;
	DELETE	facture
	WHERE	facture.codope=4
	AND	facture.numfact = :old.numquit;
	DELETE	facture_regul
	WHERE	facture_regul.numfact = :old.numquit
	AND	facture_regul.codope = 4;
	DELETE	qttc_frais
	WHERE	qttc_frais.numquit = :old.numquit;
	DELETE	qttc_taxe
	WHERE	qttc_taxe.numquit = :old.numquit;
	DELETE	qttc_comm
	WHERE	qttc_comm.numquit = :old.numquit;
	DELETE	qttc_retro
	WHERE	qttc_retro.numquit = :old.numquit;
	DELETE	qttc_variable
	WHERE	qttc_variable.numquit = :old.numquit;
	DELETE	qttc_gar
	WHERE	qttc_gar.numquit = :old.numquit;
	DELETE	qttc_annuelle
	WHERE	numgar = :old.numgar
	AND	numindiv = :old.numindiv
	AND	trunc(debut,'yy') = trunc(:old.debut,'yy');
	Delete	compte_client
	Where	codope in( 4, 8 )
	and	numfact = :old.numquit
	and 	idaffec not in (
		select	idaffec
		from	rbtcptcli);
	Exception When No_data_found then null;
end;