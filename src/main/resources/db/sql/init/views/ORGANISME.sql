CREATE FORCE VIEW ARTHUS.ORGANISME AS
select 	individu.numindiv,
	individu.refcie,
	individu.qualite,
	individu.nom,
	individu.nomjf,
	individu.prenom,
	individu.adr1,
	individu.adr2,
	individu.codpos,
	individu.ville,
	individu.codpays,
	individu.tel,
	individu.fax,
	individu.creation,
	individu.maj,
	pers_organisme.numorg,
	pers_organisme.role,
	pers_organisme.prescr,
	pers_organisme.entete1,
	pers_organisme.entete2,
	pers_organisme.entete3
from 	individu,
	pers_organisme
Where	pers_organisme.role = 2
and	individu.numindiv = pers_organisme.numindiv
Union
Select	0,
	Null,
	0,
	tmp_organisme.nom,
	Null,
	Null,
	tmp_organisme.adr1,
	tmp_organisme.adr2,
	tmp_organisme.codpos,
	tmp_organisme.ville,
	tmp_organisme.codpays,
	Null,
	Null,
	to_date(''),
	to_date(''),
	tmp_organisme.numorg,
	tmp_organisme.role,
	tmp_organisme.prescr,
	Null,
	Null,
	Null
from 	tmp_organisme
Where	tmp_organisme.role = 1
GO
CREATE OR REPLACE SYNONYM ARTHUS.ORGNS FOR ARTHUS.ORGANISME

GO
CREATE OR REPLACE PUBLIC SYNONYM ORGANISME FOR ARTHUS.ORGANISME

GO
CREATE OR REPLACE PUBLIC SYNONYM ORGNS FOR ARTHUS.ORGANISME
