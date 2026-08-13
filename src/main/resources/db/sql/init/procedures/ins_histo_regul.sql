CREATE procedure ARTHUS.ins_histo_regul (
				a_idcalcul in number,
				a_new_idcalcul in number
				)
is
loc_idhisto	number;
Cursor fetch_histo is
	Select	histo_jours.idhisto,
		histo_jours.debut,
		histo_jours.fin,
		-1 * histo_jours.montant montant
	From	histo_jours
	Where	histo_jours.idcalcul = a_idcalcul
	And Not Exists (
		Select	1
		From	histo_regul
		Where	histo_regul.idhisto = histo_jours.idhisto)
	;
loc_histo	fetch_histo%Rowtype;
BEGIN
For loc_histo in fetch_histo
loop
	Begin
	Select	idhisto.nextval
	Into	loc_idhisto
	From 	dual;
	End;
	Begin
	INSERT INTO HISTO_JOURS
   		(idhisto,
		idcalcul,
		debut,
		fin,
		montant)
	Values	(loc_idhisto,
		a_new_idcalcul,
		loc_histo.debut,
		loc_histo.fin,
		loc_histo.montant)
	;
	End;
	Begin
	INSERT INTO HISTO_REVAL
   		(idhisto,
		montant)
	Select	loc_idhisto,
  		-1 * histo_reval.montant
	From	histo_reval
	Where	histo_reval.idhisto = loc_histo.idhisto
	;
	Exception When No_data_found then null;
	End;
	Begin
	INSERT INTO HISTO_DEDU
   		(idhisto,
		typdedu,
		numdec,
		montant)
	Select	loc_idhisto,
		histo_dedu.typdedu,
		0,
		-1 * histo_dedu.montant
	From	histo_dedu
	Where	histo_dedu.idhisto = loc_histo.idhisto
	;
	Exception When No_data_found then null;
	End;
	INSERT INTO HISTO_REGUL
   		(idhisto,
		idhisto_regul)
	Values	(loc_idhisto,
  		loc_histo.idhisto)
	;
end loop;
END;
/
