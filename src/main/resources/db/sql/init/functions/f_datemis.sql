CREATE function ARTHUS.f_datemis(f_codope IN NUMBER,
                                      f_numfact IN NUMBER,
									  f_type_doc IN NUMBER,
									  f_numrelance IN NUMBER)
	RETURN VARCHAR2
	AS
		edatemis varchar2(10);
	BEGIN
		If (f_numrelance=99)
		Then
			Begin
				select	'Annulé'
				into	edatemis
				from 	emission
				where	codope	= f_codope
				and	numfact		= f_numfact
				and	type_doc	= f_type_doc
				and	numrelance	= f_numrelance;
			RETURN edatemis;
			EXCEPTION
				when NO_DATA_FOUND	then 	RETURN 'Non annulé';
				when others	then 	RETURN 'Erreur Annulé - Non annulé';
			End;
		Else
			Begin
				select	d2e(datemis)
				into	edatemis
				from 	emission
				where	codope	= f_codope
				and	numfact		= f_numfact
				and	type_doc	= f_type_doc
				and	numrelance	= f_numrelance;
			RETURN edatemis;
			EXCEPTION
				when NO_DATA_FOUND	then 	RETURN 'Non émis';
				when others	then 	RETURN 'Erreur Emis - Non émis';
			End;
		End if;
END f_datemis;
