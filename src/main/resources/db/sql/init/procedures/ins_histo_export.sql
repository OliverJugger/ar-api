CREATE procedure ARTHUS.ins_histo_export (
				a_entite 	in Number,
				a_cle 		in Number
				)
Is
dummy			number;
loc_idporte		number := -1;
BEGIN
Begin
Select	idporte
Into	loc_idporte
From	def_porte,
	libelle
Where	def_porte.sens = 2
and	def_porte.entite_base = libelle.sens
and	libelle.mnemo = 'ENT_PHYS'
and	libelle.code = a_entite;
Exception When No_data_found then Null;
End;
If ( loc_idporte > -1 ) then
	Begin
	Select	1
	Into	Dummy
	From	Dual
	Where	Not Exists (
		Select	1
		From	porte_export
		Where	idporte = loc_idporte
		and	entite = a_entite);
	Exception When No_data_found then
		Begin
		Select	1
		Into	Dummy
		From	Dual
		Where	Exists (
			Select	1
			From	histo_export
			Where	idporte = loc_idporte
			and	numremise = 0
			and	cle = a_cle);
		Exception When No_data_found then
			Begin
			Insert into histo_export (
				idporte,
				cle,
				numremise)
			Values (
				loc_idporte,
				a_cle,
				0);
			End;
		End;
	End;
End if;
END;
/
