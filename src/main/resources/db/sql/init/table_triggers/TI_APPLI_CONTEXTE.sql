CREATE TRIGGER ARTHUS.TI_APPLI_CONTEXTE
before insert
on appli_contexte
for each row
DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '@(#)trg_appli_contexte.sql	1.1    00/04/18';
begin
Insert into applications (
	codapli,
	nom,
	type,
	fonction,
	sec)
Select	:new.codapli,
	nvl( :new.libelle, appli_descript.nom ),
	2,
	:new.fonction,
	:new.ordre
From	appli_descript
Where	appli_descript.codapli = :new.codapli;
end;