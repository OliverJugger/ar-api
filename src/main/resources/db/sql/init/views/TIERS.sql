CREATE FORCE VIEW ARTHUS.TIERS AS
select individu.numindiv,
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
	pers_tiers.numtiers,
	pers_tiers.type_tiers,
	pers_tiers.nomp,
	pers_tiers.numdpt,
	pers_tiers.numactv,
	pers_tiers.numinser,
	pers_tiers.numcle,
	pers_tiers.adr1p,
	pers_tiers.adr2p,
	pers_tiers.codposp,
	pers_tiers.villep,
	pers_tiers.codpaysp
from 	individu,
	pers_tiers
where individu.numindiv = pers_tiers.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM TIERS FOR ARTHUS.TIERS
