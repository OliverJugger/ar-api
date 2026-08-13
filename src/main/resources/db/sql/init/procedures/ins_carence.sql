CREATE procedure ARTHUS.ins_carence(old_idvariable in number, new_idvariable in number) is
var	val_variable%rowtype;
adhe	adhesion%rowtype;
loc_debut	date;
loc_fin		date;
begin
for var in 	(select	clef,
			debut,
			fin,
			valeur
		from	val_variable
		where	idvariable = old_idvariable)
loop
	for adhe in	(select	distinct numindiv 	numindiv
			from	adhesion
			where	idadhesion = var.clef)
	loop
		select	min(datapli)
		into	loc_debut
		from	adhesion
		where	idadhesion = var.clef
		and	numindiv = adhe.numindiv
		and	nvl(datper, datapli+1) != datapli;
		select	max(nvl(datper, '01-jan-3000'))
		into	loc_fin
		from	adhesion
		where	idadhesion = var.clef
		and	numindiv = adhe.numindiv
		and	nvl(datper, datapli+1) != datapli;
	Insert into val_variable (
		idvariable,
		etendue,
		clef,
		statique,
		debut,
		fin,
		valide,
		valeur,
		numgar)
	Select	new_idvariable,
		12,
		adhe.numindiv,
		'O',
		greatest(var.debut, loc_debut),
		least(nvl(var.fin, '01-jan-3000'),
			decode(loc_fin, '01-jan-3000', '', loc_fin)
		   ),
		'O',
		var.valeur,
		1
	From	dual;
	end loop;
end loop;
END;
/
