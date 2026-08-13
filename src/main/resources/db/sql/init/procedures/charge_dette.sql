CREATE procedure ARTHUS.charge_dette(a_iddette in number,
					   t_donnee out pk_texte.donnee)
is
Begin
	Select iddette,
		numcli,
		d2e(date_fact),
		montant,
		devise,
		ref_ext,
		d2e(debut),
		d2e(fin)
	Into	t_donnee(1),
		t_donnee(2),
		t_donnee(3),
		t_donnee(4),
		t_donnee(5),
		t_donnee(6),
		t_donnee(7),
		t_donnee(8)
	From	dette
	Where iddette=a_iddette
	;
End;
/
