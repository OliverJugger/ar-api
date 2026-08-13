CREATE procedure ARTHUS.dup_tableau(a_tableau varchar2, a_new_tableau varchar2) is
loc_aidtableau number;
loc_idtableau number;
begin
select	max(idtableau)
into	loc_aidtableau
from	lib_tableau
where	tableau = a_tableau;
select	idtableau.nextval
into	loc_idtableau
from	dual;
insert into lib_tableau (
	idtableau,
	tableau,
	nom_tableau,
	type,
	debut)
select	loc_idtableau,
	a_new_tableau,
	nom_tableau,
	type,
	debut
from	lib_tableau
where	idtableau = loc_aidtableau;
insert into tableau (
	idtableau,
	tableau,
	clef,
	valeur)
select	loc_idtableau,
	a_new_tableau,
	clef,
	valeur
from	tableau
where	idtableau = loc_aidtableau;
end;
/
