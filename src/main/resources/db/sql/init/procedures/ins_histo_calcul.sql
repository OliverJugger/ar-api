CREATE procedure ARTHUS.ins_histo_calcul (
				a_idcalcul in number,
				a_idrepartition in number,
				a_numbene in number,
				a_debut in date,
				a_fin in date)
is
BEGIN
	Begin
	INSERT INTO HISTO_CALCUL
   		(idcalcul,
		idrepartition,
		numbene,
		numdec,
		debut,
		fin,
		creation)
	VALUES	(a_idcalcul,
		a_idrepartition,
		a_numbene,
		0,
		a_debut,
		a_fin,
		sysdate)
	;
	End;
END;
/
