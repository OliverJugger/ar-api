CREATE procedure ARTHUS.ins_param_produit(a_numprod in number)
is
	Cursor fetch_prod is
	Select
		produit.numprod,
		to_char(produit.deffet,'yyyy') debut
	From	produit
	Where numprod in
		(10,11,12,13,14,15,17,18,19,20,21,23,26,27,28,29,30,
		9,16,22,31,32,33,34,35,36,37,38,39
		)
	And numprod=nvl(a_numprod,numprod)
	;
loc_prod fetch_prod%Rowtype;
Begin
	For loc_prod in fetch_prod
	Loop
	If loc_prod.numprod in(10,11,12,13,14,15,17,18,19,20,21,23,26,27,28,29,30)
	then
	Insert into param_produit
	(numprod,typgar,type_contrat,nat_calc,type_terme,typequit,type_calc,
	mode_calcul,fract,arrondi,mregl,eche_anniv,revision,delai)
	Select loc_prod.numprod,1,2,1,1,1,1,2,3,1,1,'01-jan-'||loc_prod.debut,
	12,10
	From dual
	;
	Else
	Insert into param_produit
	(numprod,typgar,type_contrat,nat_calc,type_terme,typequit,type_calc,
	mode_calcul,fract,arrondi,mregl,eche_anniv,revision,delai)
	Select loc_prod.numprod,1,1,1,1,1,1,2,3,1,1,'01-jan-'||loc_prod.debut,
	12,10
	From dual
	;
	End if;
End loop;
End;
/
