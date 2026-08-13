CREATE procedure ARTHUS.maj_tfc (a_numprod in number)
Is
	Cursor fetch_gar is
	Select 	gar.numfor,
		gar.debut,
		gar.fin,
		2 type
	From	contrat,gar
	Where	gar.etendue=2
	And 	gar.cle =contrat.numgar
	And	contrat.numprod in (10,11,12,13,14,15,17,18,19,20,21,23,26,27,
					28,29,30)
	And	contrat.numprod=nvl(a_numprod,contrat.numprod)
	Union
	Select 	gar.numfor,
		gar.debut,
		gar.fin,
		2 type
	From	gar
	Where	gar.etendue=7
	And	gar.cle in (10,11,12,13,14,15,17,18,19,20,21,23,26,27,
					28,29,30)
	And	gar.cle=nvl(a_numprod,gar.cle)
	Union
	Select	gar_cntrt.numfor,
		gar_cntrt.datapli debut,
		gar_cntrt.datper fin,
		1 type
	From	contrat,gar_cntrt
	Where	type=1
	And 	gar_cntrt.numgar=contrat.numgar
	And	contrat.numprod in(9,16,22,31,32,33,34,35,36,37,38,39)
	And	contrat.numprod=nvl(a_numprod,contrat.numprod)
	Union
	Select	frmls.numfor,
		frmls.debut,
		frmls.fin,
		1 type
	From	frmls
	Where	numprod in(9,16,22,31,32,33,34,35,36,37,38,39)
	And	frmls.numprod=nvl(a_numprod,frmls.numprod)
	;
loc_gar fetch_gar%Rowtype;
loc_idformule number;
loc_seq number;
Begin
	For loc_gar in fetch_gar
	Loop
	Delete frml_tfc
	Where numfor=loc_gar.numfor
	And tfc=5
	;
		Select seq
		Into loc_seq
		From frmlvar
		Where idformule=99995
		;
		Insert into frml_tfc
		(numfor,tfc,type_tfc,debut,fin,idformule,seq,valide,numbene,
		prelev_revers,mode_calc)
		Select
			loc_gar.numfor,
			5,
			1,
			loc_gar.debut,
			loc_gar.fin,
			99995,
			loc_seq,
			'O',
			'',
			'',
			2
		From	dual
		;
		Insert into frml_tfc
		(numfor,tfc,type_tfc,debut,fin,idformule,seq,valide,numbene,
		prelev_revers,mode_calc)
		Select
			loc_gar.numfor,
			5,
			2,
			loc_gar.debut,
			loc_gar.fin,
			99995,
			loc_seq,
			'O',
			'',
			'',
			2
		From	dual
		;
	If (loc_gar.type=2)
	Then
		Select seq
		Into loc_seq
		From frmlvar
		Where idformule=99993
		;
		Insert into frml_tfc
		(numfor,tfc,type_tfc,debut,fin,idformule,seq,valide,numbene,
		prelev_revers,mode_calc)
		Select
			loc_gar.numfor,
			5,
			3,
			loc_gar.debut,
			loc_gar.fin,
			99995,
			loc_seq,
			'O',
			'',
			'',
			2
		From	dual
		;
	End if;
	End loop;
End;
/
