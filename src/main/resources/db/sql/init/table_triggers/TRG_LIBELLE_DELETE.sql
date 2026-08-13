CREATE TRIGGER ARTHUS.TRG_LIBELLE_DELETE
before delete
on libelle
for each row








declare loc_nb_indcs number;
begin
	if ( (:old.mnemo='INDC') and (:old.code > 0 ) )
	then
		begin
			select distinct indice
			into   loc_nb_indcs
			from indice
			where indice = :old.code;
		raise_application_error(-20601,'Il existe des valeurs pour cet indice. Supression interdite.');
		exception
		when no_data_found then null;
		end;
	end if;
end;