CREATE FUNCTION ARTHUS.f_param_compte(
			a_numgar in number,
			a_codope in number,
			a_modpmt in number)
RETURN number
AS
	loc_compte	number 	default 0;
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
	Exception when no_data_found then return(loc_compte);
	End;
	/* Parametrage global societe	*/
	Begin
	Select	numcpte
	Into	loc_compte
	From	param_compte
	Where	param_compte.numsoc = loc_numsoc
	and	param_compte.numorg = 0
	and	param_compte.numgar = 0
	and	param_compte.codope = a_codope
	and	param_compte.modpmt = a_modpmt;
	Exception when no_data_found then null;
	End;
	/* Parametrage specifique compagnie	*/
 	Begin
	Select	numcpte
	Into	loc_compte
	From	param_compte
	Where	param_compte.numsoc = loc_numsoc
	and	param_compte.numorg = loc_numorg
	and	param_compte.numgar = 0
	and	param_compte.codope = a_codope
	and	param_compte.modpmt = a_modpmt;
	Exception when no_data_found then null;
	End;
	/* Parametrage specifique contrat	*/
	Begin
	Select	numcpte
	Into	loc_compte
	From	param_compte
	Where	param_compte.numsoc = loc_numsoc
	and	param_compte.numorg = loc_numorg
	and	param_compte.numgar = a_numgar
	and	param_compte.codope = a_codope
	and	param_compte.modpmt = a_modpmt;
	Exception when no_data_found then null;
	End;
/* Si rien trouve et par soucis de compatibilite,
    on va chercher ds papier_ope */
if (loc_compte = 0 or loc_compte is null) then
	begin
	Select	nvl(min(papier_ope.numcpte), 0)
	Into	loc_compte
	From	papier_ope
	Where	papier_ope.defaut is not null
	and	papier_ope.modpmt = a_modpmt
	and	papier_ope.codope = a_codope
	and	papier_ope.numcpte in (
		select	numcpte
		from 	compte
		where	compte.numsoc = loc_numsoc)
	;
	end;
end if;
return(loc_compte);
END;
