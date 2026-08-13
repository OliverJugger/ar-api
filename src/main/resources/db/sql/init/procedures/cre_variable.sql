CREATE procedure ARTHUS.cre_variable (
				a_idformule in number,
				a_etendue in number,
				a_clef in number,
				a_debut in date,
				a_numgar in number,
				a_fin in date default null)
is
	dummy			number;
Cursor fetch_frmlvar is
	Select	frmlvar_detail.idvariable
	From	def_variable,
		frmlvar_detail
	Where	def_variable.etendue = a_etendue
	and	def_variable.idvariable = frmlvar_detail.idvariable
	and	frmlvar_detail.idformule = a_idformule;
loc_frmlvar	fetch_frmlvar%Rowtype;
loc_idformule	number;
BEGIN
for loc_frmlvar in fetch_frmlvar
loop
loc_idformule := 0;
	Begin
	Select	idformule
	Into	loc_idformule
	From	histo_frmlvar
	Where	valide = 'O'
	and	a_debut between debut and nvl(fin, a_debut)
	and	idvariable = loc_frmlvar.idvariable;
	dbms_output.put_line('idformule = '||loc_idformule);
	cre_variable(loc_idformule, a_etendue, a_clef,
			a_debut, a_numgar, a_fin);
	Exception When No_data_found then
	ins_variable(loc_frmlvar.idvariable, a_clef,
			a_debut, a_numgar, a_fin);
	End;
end loop;
END;
/
