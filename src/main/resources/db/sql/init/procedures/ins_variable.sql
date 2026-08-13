CREATE procedure ARTHUS.ins_variable (
				a_idvariable in number,
				a_clef in number,
				a_debut in date,
				a_numgar in number,
				a_fin in date default null)
is
	dummy			number;
BEGIN
Select	1
Into	dummy
From	val_variable
Where	idvariable = a_idvariable
and	clef	   = a_clef
and	a_debut between debut
		and	nvl(fin, a_debut)
and	valide = 'O'
and	nvl( numgar,nvl(a_numgar,0) ) = nvl(a_numgar, 0);
Exception When No_data_found then
	Begin
	Insert
	Into	val_variable (
		idvariable,
		etendue,
		clef,
		statique,
		debut,
		fin,
		valide,
		valeur,
		numgar)
	Select	a_idvariable,
		def_variable.etendue,
		a_clef,
		def_variable.statique,
		a_debut,
		a_fin,
		'O',
		'',
		a_numgar
	From	def_variable
	Where	def_variable.idvariable = a_idvariable;
	End;
END;
/
