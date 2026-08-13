CREATE procedure ARTHUS.ins_histo_jours (
				a_idhisto in number,
				a_idcalcul in number,
				a_debut in date,
				a_fin in date,
				a_valeur in number,
				a_valeur_reval in number)
is
BEGIN
	Begin
	INSERT INTO HISTO_JOURS
   		(idhisto,
		idcalcul,
		debut,
		fin,
		montant)
	VALUES	(a_idhisto,
		a_idcalcul,
		a_debut,
		a_fin,
		a_valeur)
	;
	End;
	Begin
	INSERT INTO HISTO_REVAL
   		(idhisto,
		montant)
	VALUES	(a_idhisto,
  		a_valeur_reval)
	;
	End;
END;
/
