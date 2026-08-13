CREATE procedure ARTHUS.ins_justif ( a_entite in number,
					 a_entite_ref in number)
is
BEGIN
	Begin
	INSERT INTO JUSTIF(
		contexte,
		entite,
		numfor,
		type_piece,
		nopiece,
		delai,
		period,
		bloc
		)
	Select
		2,
		a_entite,
		0,
		justif.type_piece,
		justif.nopiece,
		justif.delai,
		justif.period,
		justif.bloc
	From	justif
	Where	justif.contexte=7
	And	justif.entite=a_entite_ref
	And	justif.numfor=0
;
	End;
END;
/
