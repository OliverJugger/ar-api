CREATE procedure ARTHUS.ins_cond(a_numgar in number,a_numprod in number,
					a_etendue in number)
Is
Begin
	Insert into cond_adhesion
	(etendue,cle,idformule,debut,valide,fin)
	Select
		a_etendue,
		decode(a_etendue,2,a_numgar,a_numprod),
		idformule,
		debut,
		valide,
		fin
	From	cond_adhesion
	Where	etendue=7
	And	cle=a_numprod
	;
	Insert into cond_proposition
	(etendue,cle,idformule,debut,valide,fin)
	Select
		a_etendue,
		decode(a_etendue,2,a_numgar,a_numprod),
		idformule,
		debut,
		valide,
		fin
	From	cond_proposition
	Where	etendue=7
	And	cle=a_numprod
	;
End;
/
