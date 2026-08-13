CREATE function ARTHUS.f_existe_bene_fisc (
				a_idrepartition 	in number,
				a_numbene 	in number,
				a_type_fisc	in number default null,
				a_debut		in date,
				a_valide	in varchar2
				)
Return Date
As
loc_retour	Date;
Cursor fetch_bene_fisc is
	Select	bene_fisc.debut
	From	bene_fisc
	Where	bene_fisc.idrepartition=a_idrepartition
	And	bene_fisc.numbene=a_numbene
	And	type_fisc=nvl(a_type_fisc,type_fisc)
	And	valide=a_valide
	and	debut=a_debut
	;
loc_bene_fisc	fetch_bene_fisc%Rowtype;
BEGIN
loc_retour := Null;
	For loc_bene_fisc in fetch_bene_fisc
	loop
		loc_retour := loc_bene_fisc.debut;
		Exit;
	end loop;
Return ( loc_retour );
END	f_existe_bene_fisc;
