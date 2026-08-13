CREATE function ARTHUS.f_info_tiers_payant(a_numporte in number,
						a_numgar in number,
						a_type in number)
Return varchar2
Is
loc_retour varchar2(5);
loc_numgar number;
loc_type1 varchar2(5);
loc_type2 varchar2(5);
loc_type3 varchar2(5);
loc_type4 varchar2(5);
loc_type5 varchar2(5);
loc_type6 varchar2(5);
loc_type7 varchar2(5);
loc_type8 varchar2(5);
loc_type9 varchar2(5);
loc_type10 varchar2(5);
loc_type11 varchar2(5);
loc_type12 varchar2(5);
loc_type13 varchar2(5);
loc_type14 varchar2(5);
loc_type15 varchar2(5);
loc_type16 varchar2(5);
loc_type17 varchar2(5);
loc_type18 varchar2(5);
loc_type19 varchar2(5);
Begin
	loc_numgar:= PK_QTTC.f_sel_numgar(a_numgar);
<<Debut>>
	Begin
	Select 	type_carte,
		mode_exp,
		numdest,
		code_lettre,
		''	code_encart,
		''	type_attes,
		''	type_carnet,
		'00'	nb_carnet,
		period,
		''	code_ad,
		calcul,
		famille,
		organisme,
		centre,
		''	taux,
		''	calc,
		'1'	etat,
		type_poch,
		renouv
	Into 	loc_type1,
		loc_type2,
		loc_type3,
		loc_type4,
		loc_type5,
		loc_type6,
		loc_type7,
		loc_type8,
		loc_type9,
		loc_type10,
		loc_type11,
		loc_type12,
		loc_type13,
		loc_type14,
		loc_type15,
		loc_type16,
		loc_type17,
		loc_type18,
		loc_type19
	From 	param_tiers_payant
	Where 	numporte=a_numporte
	And 	PK_QTTC.f_sel_numgar(numgar)=loc_numgar
	;
		Exception
		When no_data_found then loc_numgar:=0;
		Goto debut;
	End;
	If (a_type=1)
	Then
		loc_retour:=loc_type1;
	Elsif (a_type=2)
	Then
		loc_retour:=loc_type2;
	Elsif (a_type=3)
	Then
		loc_retour:=loc_type3;
	Elsif (a_type=4)
	Then
		loc_retour:=loc_type4;
	Elsif (a_type=5)
	Then
		loc_retour:=loc_type5;
	Elsif (a_type=6)
	Then
		loc_retour:=loc_type6;
	Elsif (a_type=7)
	Then
		loc_retour:=loc_type7;
	Elsif (a_type=8)
	Then
		loc_retour:=loc_type8;
	Elsif (a_type=9)
	Then
		loc_retour:=loc_type9;
	Elsif (a_type=10)
	Then
		loc_retour:=loc_type10;
	Elsif (a_type=11)
	Then
		loc_retour:=loc_type11;
	Elsif (a_type=12)
	Then
		loc_retour:=loc_type12;
	Elsif (a_type=13)
	Then
		loc_retour:=loc_type13;
	Elsif (a_type=14)
	Then
		loc_retour:=loc_type14;
	Elsif (a_type=15)
	Then
		loc_retour:=loc_type15;
	Elsif (a_type=16)
	Then
		loc_retour:=loc_type16;
	Elsif (a_type=17)
	Then
		loc_retour:=loc_type17;
	Elsif (a_type=18)
	Then
		loc_retour:=loc_type18;
	Elsif (a_type=19)
	Then
		loc_retour:=loc_type19;
	End if;
Return(loc_retour);
End;
