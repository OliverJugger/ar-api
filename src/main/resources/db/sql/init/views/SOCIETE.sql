CREATE FORCE VIEW ARTHUS.SOCIETE AS
select 	individu.numindiv,
	individu.refcie 	refsoc,
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
	pers_societe.numsoc,
	pers_societe.numinterm,
	pers_societe.entete,
	pers_societe.abrege,
	pers_societe.lieu,
	pers_societe.cloture
from 	individu,
	pers_societe
where 	pers_societe.numindiv = individu.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM SOCIETE FOR ARTHUS.SOCIETE
