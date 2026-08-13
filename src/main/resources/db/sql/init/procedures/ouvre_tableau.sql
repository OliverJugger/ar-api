CREATE procedure ARTHUS.ouvre_tableau(
			a_tableau in varchar2,
			a_old_date in date,
			a_new_date in date)
IS
loc_aidtableau number;
loc_idtableau number;
begin
select	idtableau
into	loc_aidtableau
from	lib_tableau
where	tableau = a_tableau
and	debut = a_old_date;
select	idtableau.nextval
into	loc_idtableau
from	dual;
insert into lib_tableau (
	idtableau,
	tableau,
	nom_tableau,
	type,
	debut,
	mnemo_tab)
select	loc_idtableau,
	tableau,
	nom_tableau,
	type,
	a_new_date,
	mnemo_tab
from	lib_tableau
where	idtableau = loc_aidtableau;
insert into tableau (
	idtableau,
	tableau,
	clef,
	valeur)
select	loc_idtableau,
	tableau,
	clef,
	valeur
from	tableau
where	idtableau = loc_aidtableau;
Update	lib_tableau
Set	fin = a_new_date - 1
where	idtableau = loc_aidtableau;
Exception When No_data_found then Null;
end;
/
