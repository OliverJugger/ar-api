CREATE FORCE VIEW ARTHUS.INTERMEDIAIRE AS
select 	individu.numindiv,
		individu.refcie refinterm,
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
		pers_intermediaire.numinterm,
		pers_intermediaire.numsoc,
		pers_intermediaire.type
from 		individu,
		pers_intermediaire
where 	individu.numindiv = pers_intermediaire.numindiv
GO
CREATE OR REPLACE SYNONYM ARTHUS.INTERM FOR ARTHUS.INTERMEDIAIRE

GO
CREATE OR REPLACE PUBLIC SYNONYM INTERM FOR ARTHUS.INTERMEDIAIRE

GO
CREATE OR REPLACE PUBLIC SYNONYM INTERMEDIAIRE FOR ARTHUS.INTERMEDIAIRE
