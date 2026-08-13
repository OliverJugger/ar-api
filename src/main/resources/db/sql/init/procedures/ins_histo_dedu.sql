CREATE procedure ARTHUS.ins_histo_dedu (
				a_idhisto in number,
				a_typdedu in number,
				a_valeur in number)
is
BEGIN
	Begin
	INSERT INTO HISTO_DEDU
   		(idhisto,
		typdedu,
		numdec,
		montant)
	VALUES	(a_idhisto,
		a_typdedu,
		0,
		a_valeur)
	;
	End;
END;
/
