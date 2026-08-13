CREATE procedure ARTHUS.charge_sntrprt(a_numremise in number,
					  a_numsin in number,
				 	  t_donnee out pk_texte.donnee)
is
Begin
	Select  numremise,
		d2e(sntrprt.dattrait),
		numsin,
		d2e(sntrprt.datsin),
		refdec
	Into	t_donnee(1),
		t_donnee(2),
		t_donnee(3),
		t_donnee(4),
		t_donnee(5)
	From	sntrprt
	Where	sntrprt.numremise=a_numremise
	And	sntrprt.numsin=a_numsin;
End;
/
