CREATE FORCE VIEW ARTHUS.V_SINISTRE_PORTE AS
select	porte_remise.numremise,
	porte_remise.numporte,
	sinistre.numdec,
	sinistre.numsin,
	sinistre.numindiv,
	substr(indvs.prenom,1,11) prenom_adr,
	sinistre.datsin,
	to_char(sinistre.datsin,'dd/mm/yy') edatsin,
	sinistre.nbacte,
	sinistre.codfrais,
	sinistre.mtfrais,
	sinistre_dev.mtfrais_out mtfrais_d,
	sinistre.mtremb,
	sinistre_dev.mtremb_out mtremb_d,
	sinistre.autrb,
	sinistre_dev.autrb_out autrb_d,
	sinistre.mtprest,
	sinistre_dev.mtprest_out mtprest_d,
	sntr_ref.numremise ref,
	sntr_ref.numsin_porte,
	sinistre.numassu,
	sinistre.monnaie,
	sinistre_dev.dev_out monnaie_d
from	porte_remise,
	indvs,
	sinistre,
	sntr_ref, sinistre_dev
where	sinistre.numindiv = indvs.numindiv
and	porte_remise.numremise = sntr_ref.numremise
and	sinistre.numsin = sntr_ref.numsin
and sinistre.numsin = sinistre_dev.numsin
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SINISTRE_PORTE FOR ARTHUS.V_SINISTRE_PORTE
