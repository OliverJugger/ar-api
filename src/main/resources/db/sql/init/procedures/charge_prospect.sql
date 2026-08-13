CREATE procedure ARTHUS.charge_prospect ( a_numpropo in number,
					   t_donnee out pk_texte.donnee)
is
BEGIN
		Select 	proposition.idpropo,
			proposition.idobjet,
			proposition.numindiv,
			proposition.refext,
			proposition.mt_estim,
			substr(pk_libelle.f_lib('PROP_CIBLE',proposition.cible),
									1,15),
			substr(pk_libelle.f_lib('PROP_ORIGI',
						proposition.origine),1,15),
			substr(pk_libelle.f_lib('PROP_SCORE',
						proposition.score),1,15),
			substr(pk_libelle.f_lib('PROP_COMME',
						proposition.commercial),1,15),
			f_situ_propal(idpropo,1),
			f_situ_propal(idpropo,2)
		Into	t_donnee(1),
			t_donnee(2),
			t_donnee(3),
			t_donnee(4),
			t_donnee(5),
			t_donnee(6),
			t_donnee(7),
			t_donnee(8),
			t_donnee(9),
			t_donnee(10),
			t_donnee(11)
		From	proposition
		Where 	proposition.idpropo=a_numpropo;
END;
/
