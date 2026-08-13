CREATE procedure ARTHUS.charge_prest_prev ( a_cle in number,
						a_debut in date,
						a_fin in date,
					   t_donnee out pk_texte.donnee)
is
BEGIN
	select 	sum(decaismt.montant),
		to_char(decaismt.datpay,'yyyy')
	Into
		t_donnee(1),
		t_donnee(2)
	From	decaismt,
		affectation,
		decompte_prev
	Where	decaismt.numdest=a_cle
	And	decaismt.numdecaismt=affectation.numdecaismt
	And	decaismt.refpmt is not null
	And	affectation.numaffec=decompte_prev.numdec
	And	affectation.codope=2
	And	decaismt.datpay between a_debut and a_fin
	Group by
		to_char(decaismt.datpay,'yyyy');
END;
/
