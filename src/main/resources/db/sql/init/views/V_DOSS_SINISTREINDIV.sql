CREATE FORCE VIEW ARTHUS.V_DOSS_SINISTREINDIV AS
(select iddossier,ref_ext
,dossier_sinistre.numindiv, anterieur, nom, prenom , debut,
fin, dossier_sinistre.numutil, cloture from dossier_sinistre,
individu
where individu.numindiv = dossier_sinistre.numindiv)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DOSS_SINISTREINDIV FOR ARTHUS.V_DOSS_SINISTREINDIV
