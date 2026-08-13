CREATE FUNCTION ARTHUS.f_param_ope(
			a_numgar in number,
			a_codope in number,
			a_modpmt in number)
RETURN rowid
AS
	loc_rowid	rowid 	default null;
	loc_numsoc 	number;
	loc_numorg 	number;
BEGIN
	begin
	Select	numinterm,
		numorg
	Into	loc_numsoc,
		loc_numorg
	From	contrat
	Where	numgar = a_numgar
	;
	Exception when no_data_found then return(loc_rowid);
	End;
	/* Parametrage global societe	*/
	Begin
	Select	rowid
	Into	loc_rowid
	From	param_ope
	Where	param_ope.numsoc = loc_numsoc
	and	param_ope.numorg = 0
	and	param_ope.numgar = 0
	and	param_ope.codope = a_codope
	and	param_ope.modpmt = a_modpmt;
	Exception when no_data_found then null;
	End;
	/* Parametrage specifique compagnie	*/
 	Begin
	Select	rowid
	Into	loc_rowid
	From	param_ope
	Where	param_ope.numsoc = loc_numsoc
	and	param_ope.numorg = loc_numorg
	and	param_ope.numgar = 0
	and	param_ope.codope = a_codope
	and	param_ope.modpmt = a_modpmt;
	Exception when no_data_found then null;
	End;
	/* Parametrage specifique contrat	*/
	Begin
	Select	rowid
	Into	loc_rowid
	From	param_ope
	Where	param_ope.numsoc = loc_numsoc
	and	param_ope.numorg = loc_numorg
	and	param_ope.numgar = a_numgar
	and	param_ope.codope = a_codope
	and	param_ope.modpmt = a_modpmt;
	Exception when no_data_found then null;
	End;
return(loc_rowid);
END;
