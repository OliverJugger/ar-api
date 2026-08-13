CREATE procedure ARTHUS.charge_produit ( a_numprod in number,
					   t_donnee out pk_texte.donnee)
is
BEGIN
	Select 	produit.numprod,
		produit.libelle,
		d2e(produit.deffet),
		substr(pk_libelle.f_lib('TYPE_ASS',produit.type_ass),1,15),
		produit.numass
	Into	t_donnee(1),
		t_donnee(2),
		t_donnee(3),
		t_donnee(4),
		t_donnee(5)
	From	produit
	Where	produit.numprod=a_numprod;
END;
/
