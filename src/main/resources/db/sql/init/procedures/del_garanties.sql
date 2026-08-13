CREATE procedure ARTHUS.del_garanties(a_numfor in number,a_type in number)
is
loc_test	number;
loc_groupe	number;
gar		grp_gar_def%Rowtype;
Begin
	If (a_type=2) Then
	Delete frml_prime_simple
	Where numfor=a_numfor;
	Delete frml_tfc
	Where numfor=a_numfor;
	Delete frml_prest
	Where numfor=a_numfor;
	Delete frml_reval
	Where numfor=a_numfor;
	Delete frml_dedu
	Where numfor=a_numfor;
	Delete bene_gar
	Where numfor=a_numfor;
	Delete cond_adhesion_gar
	Where numfor=a_numfor;
	Delete param_pieces
	Where numfor=a_numfor;
	Delete libgar
	Where numfor=a_numfor;
	Delete gar_prev
	Where numfor=a_numfor;
	Delete garanties
	Where numfor=a_numfor;
	Elsif (a_type=1) Then
	Delete frml_prime_simple
	Where numfor=a_numfor;
	Delete frml_tfc
	Where numfor=a_numfor;
	Delete maxfor
	Where numfor=a_numfor;
	Delete maxact
	Where numfor=a_numfor;
	Delete franfor
	Where numfor=a_numfor;
	Delete franact
	Where numfor=a_numfor;
	Delete carence
	Where numfor=a_numfor;
	Delete seqrub
	Where numfor=a_numfor;
	Delete calcul
	Where numfor=a_numfor;
	Delete defrub
	Where numfor=a_numfor;
	Delete formule
	Where numfor=a_numfor;
	Delete cond_adhesion_gar
	Where numfor=a_numfor;
	Delete libgar
	Where numfor=a_numfor;
	Delete param_pieces
	Where numfor=a_numfor;
End if;
	For gar in
	(Select numgrpgar
	From grp_gar_def
	Where numfor=a_numfor
	)
	Loop
		Delete grp_gar_def
		Where numfor=a_numfor
		And numgrpgar=gar.numgrpgar
		;
	Begin
		Select 1
		Into loc_groupe
		From grp_gar
		Where not exists(select 1 from grp_gar_def
				where grp_gar_def.numgrpgar=grp_gar.numgrpgar
				and grp_gar.numgrpgar=gar.numgrpgar
				)
		and numgrpgar=gar.numgrpgar
		;
		Delete grp_gar
		Where numgrpgar=gar.numgrpgar
		;
		Exception
			When no_data_found then null;
	End;
	End loop;
End;
/
