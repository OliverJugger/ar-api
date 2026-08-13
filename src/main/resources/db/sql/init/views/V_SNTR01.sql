CREATE FORCE VIEW ARTHUS.V_SNTR01 AS
select	sntr.numdec,
	sntr.numsin,
	sntr.numindiv,
	substr(indvs.prenom,1,11) prenom_adr,
	sntr.datsin,
	to_char(sntr.datsin,'dd/mm/yy') edatsin,
	sntr.nbacte,
	sntr.codfrais,
	sntr.mtfrais,
	sinistre_dev.mtfrais_out mtfrais_d,
	sntr.mtremb,
	sinistre_dev.mtremb_out mtremb_d,
	sntr.autrb,
	sinistre_dev.autrb_out autrb_d,
	sntr.mtreel,
	sinistre_dev.mtreel_out mtreel_d,
	sntr.monnaie,
	sinistre_dev.dev_out monnaie_d
from	sntr,indvs, sinistre_dev
where	sntr.numindiv = indvs.numindiv
	and sntr.numsin=sinistre_dev.numsin
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SNTR01 FOR ARTHUS.V_SNTR01
