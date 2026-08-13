CREATE Procedure ARTHUS.P_dedouble_texte IS
Cursor C_double IS
	Select 	distinct numero 	numgar
	from 	valide_texte
	where 	contexte=2
	and 	idtexte in(933, 934, 935, 951)
	and exists(
		select	1
		from	valide_texte coti03
		where	coti03.contexte = 2
		and	coti03.numero = valide_texte.numero
		and	coti03.idtexte in(936,937,938,952)
		);
--
Cursor C_deleg ( P_numgar IN contrat.numgar%Type ) IS
	Select	1
	From	contrat
	Where	numgar = P_numgar
	and	delegataire IS Not Null;
--
Dummy	Number;
Rec_C_double	C_double%Rowtype;
BEGIN
Open C_double;
Loop
	Fetch C_double Into Rec_C_double;
	Exit When C_double%NotFound;
	--
	Open C_deleg ( Rec_C_double.numgar );
	Fetch C_deleg Into Dummy;
	If ( C_deleg%Found ) then
		--
		Delete	valide_texte
		where	idtexte IN ( 933, 934, 935, 951, 936,937,938,952 )
		and	numero = Rec_C_double.numgar
		and	contexte = 2;
		--
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte
			)
		Values (
			2,
			Rec_C_double.numgar,
			936
			);
		--
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte
			)
		Values (
			2,
			Rec_C_double.numgar,
			937
			);
		--
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte
			)
		Values (
			2,
			Rec_C_double.numgar,
			938
			);
		--
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte
			)
		Values (
			2,
			Rec_C_double.numgar,
			952
			);
		--
	Else
		--
		Delete	valide_texte
		where	idtexte IN ( 933, 934, 935, 951, 936,937,938,952 )
		and	numero = Rec_C_double.numgar
		and	contexte = 2;
		--
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte
			)
		Values (
			2,
			Rec_C_double.numgar,
			933
			);
		--
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte
			)
		Values (
			2,
			Rec_C_double.numgar,
			934
			);
		--
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte
			)
		Values (
			2,
			Rec_C_double.numgar,
			935
			);
		--
		Insert Into valide_texte (
			contexte,
			numero,
			idtexte
			)
		Values (
			2,
			Rec_C_double.numgar,
			951
			);
		--
	End if;
	Close C_deleg;
End Loop;
Close C_double;
END P_dedouble_texte;
/
