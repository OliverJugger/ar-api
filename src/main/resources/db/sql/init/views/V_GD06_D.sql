CREATE FORCE VIEW ARTHUS.V_GD06_D AS
select
	sntr.username			gest,
	f_nomutil(sntr.username)			nom_gest,
	sntr.datsai,
	to_char(sntr.datsai,'DD/MM/YY')	edatsai,
	sntr.numassu,
	sntr.numindiv			bene,
	ARTHUS.pk_personne.f_nom (sntr.numindiv,30,0)	nom_bene,
	sntr.datsin,
	to_char(sntr.datsin,'DD/MM/YY') edatsin,
	sntr.codfrais,
	sntr.nbacte,
	sntr.mtfrais,
	sinistre_dev.mtfrais_out,
	sntr.mtremb,
	sinistre_dev.mtremb_out,
	sntr.mtprest,
	sinistre_dev.mtprest_out,
	sntr.monnaie monnaie,
	sinistre_dev.dev_out  monnaie_d
from	sntr,
		sinistre_dev
WHERE sntr.numsin = sinistre_dev.numsin
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GD06_D FOR ARTHUS.V_GD06_D
