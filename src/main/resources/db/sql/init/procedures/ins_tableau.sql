CREATE procedure ARTHUS.ins_tableau	(a_idtableau in number,
					 a_idtableau_old in number,
					 a_tableau in varchar2,
					 a_type in number default 1)
is
begin
If (a_type=1)
Then
	Insert into tableau
		(idtableau,
		 tableau,
		 clef,
		 valeur)
	Select 	a_idtableau,
		a_tableau,
		clef,
		valeur
	From 	tableau
	Where	idtableau=a_idtableau_old;
Elsif (a_type=2)
Then
	Insert into tableau
		(idtableau,
		 tableau,
		 clef,
		 valeur)
	Select 	a_idtableau,
		a_tableau,
		clef,
		valeur
	From 	tableau
	Where	idtableau=a_idtableau_old;
	Insert into tableau_double
		(idtableau,
		clef1,
		clef2,
		valeur
		)
	Select 	a_idtableau,
		clef1,
		clef2,
		valeur
	From	tableau_double
	Where	idtableau=a_idtableau_old;
end if;
end;
/
