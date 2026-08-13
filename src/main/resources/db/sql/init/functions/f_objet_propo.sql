CREATE function ARTHUS.f_objet_propo(a_idobjet in number,a_objet in number)
Return Varchar2 as
	loc_libelle varchar2(30);
Begin
	Select produit.libelle
	Into loc_libelle
	From produit
	Where numprod=a_idobjet
	And a_objet=1
	Union
	Select contrat.refcie
	From contrat
	Where numgar=a_idobjet
	And a_objet=2;
	Return(loc_libelle);
	Exception
	When no_data_found then
		loc_libelle:='Indetermine';
		Return(loc_libelle);
End;
