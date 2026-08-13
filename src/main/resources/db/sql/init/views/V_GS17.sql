CREATE FORCE VIEW ARTHUS.V_GS17
  (CODFRAIS, NUMGAR, NBACTE, DATSAI, TYPE, NUMINDIV, MTFRAIS, DATSIN,
   MTREMB, DEV, USERNAME, NOM, LIB_FORCAGE, MTFRAIS_D, MTREMB_D, NUMSIN,
   DEV_D, NOM_NUMINDIV) AS
SELECT ALL forcage.codfrais, forcage.numgar, forcage.nbacte,
              trunc(forcage.datsai) DATSAI, forcage.TYPE, forcage.numindiv, forcage.mtfrais,
              sinistre.datsin, sinistre.mtremb, mone.symbole dev,
              forcage.username, util.nom, libelle.libelle lib_forcage,
              forcage.mtfrais_d, sinistre_dev.mtremb_ct mtremb_d,
              forcage.numsin, mone_d.symbole dev_d
              ,f_nom(forcage.numindiv)
         FROM sinistre,
              forcage,
              mone,
              libelle,
              util,
              sinistre_dev,
              mone mone_d
        WHERE libelle.mnemo = 'FORCAGE'
          AND (    (forcage.numsin = sinistre.numsin)
               AND (mone.codmon = forcage.codmon)
               AND (libelle.code = forcage.TYPE)
               AND (util.numutil = forcage.username)
               AND (forcage.numsin = sinistre_dev.numsin)
               AND (sinistre_dev.dev_ct = mone_d.codmon)
              )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GS17 FOR ARTHUS.V_GS17
