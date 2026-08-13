CREATE procedure ARTHUS.ins_bene_fisc
Is
Cursor fetch_repartition_bene is
	Select 	repartition_bene.idrepartition,
		repartition_bene.numbene,
		repartition_bene.debut
	From	gar_prev,repartition,repartition_bene
	Where 	repartition_bene.valide='O'
	And 	repartition_bene.idrepartition=repartition.idrepartition
	And	repartition.numfor=gar_prev.numfor
	And	gar_prev.gar_fisc!=0
	;
loc_idadresse number;
loc_repartition_bene fetch_repartition_bene%Rowtype;
Begin
For loc_repartition_bene in fetch_repartition_bene
Loop
	Select
		pk_personne.f_idadresse(
				loc_repartition_bene.numbene,0,sysdate,'O',0,-1)
	Into loc_idadresse
	From dual
	;
	Insert into bene_fisc
		Select 	loc_repartition_bene.idrepartition,
			loc_repartition_bene.numbene,
			decode(pers_adresse.codpays,1,1,2),
			loc_repartition_bene.debut,'O'
		From	pers_adresse
		Where	pers_adresse.idadresse=loc_idadresse
		;
	Commit;
End loop;
End;
/
