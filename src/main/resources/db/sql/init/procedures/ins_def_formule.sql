CREATE procedure ARTHUS.ins_def_formule is
frmlvar	libelle%rowtype;
begin
for frmlvar in	(select code,
			libelle
		 from 	libelle
		 where	mnemo = 'FRMLVAR'
		 and	code > 0)
loop
		Insert into def_formule (
			idformule,
			etendue,
			libelle)
		Select	frmlvar.code,
			5,
			frmlvar.libelle
		From	dual;
end loop;
end;
/
