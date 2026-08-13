CREATE TRIGGER ARTHUS.maj_appli_descript
	before insert or update of nom,type,domaine,etat,prog
	on appli_descript
	for each row








begin
	if ( :new.creation is null )
	then
	:new.creation := trunc(sysdate);
	:new.maj := trunc(sysdate);
	else
	:new.maj := trunc(sysdate);
	Update 	applications
	Set 	nom = :new.nom,
		type = :new.type
	Where	codapli = :new.codapli;
	end if;
	end;