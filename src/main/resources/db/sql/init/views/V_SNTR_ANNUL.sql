CREATE FORCE VIEW ARTHUS.V_SNTR_ANNUL AS
select  sinistre_annul.numdec,
  sinistre_annul.numsin,
  sinistre_annul.numindiv,
  substr(indvs.prenom,1,11) prenom_adr,
  sinistre_annul.datsin,
  to_char(sinistre_annul.datsin,'dd/mm/yy') edatsin,
  sinistre_annul.nbacte,
  sinistre_annul.codfrais,
  sinistre_annul.mtfrais,
  sinistre_dev_annul.mtfrais_out mtfrais_d,
  sinistre_annul.mtremb,
  sinistre_dev_annul.mtremb_out mtremb_d,
  sinistre_annul.autrb,
  sinistre_dev_annul.autrb_out autrb_d,
  sinistre_annul.mtreel,
  sinistre_dev_annul.mtreel_out mtreel_d,
  sinistre_annul.monnaie,
  sinistre_dev_annul.dev_out monnaie_d
from  sinistre_annul,indvs, sinistre_dev_annul
where  sinistre_annul.numindiv = indvs.numindiv
  and sinistre_annul.numsin=sinistre_dev_annul.numsin
  and sinistre_annul.numdec=sinistre_dev_annul.numdec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SNTR_ANNUL FOR ARTHUS.V_SNTR_ANNUL
