CREATE FORCE VIEW ARTHUS.TIERSPAYANT AS
SELECT individu.numindiv, individu.refcie, individu.qualite, individu.nom,
          individu.nomjf, individu.prenom, ARTHUS.PK_PERSONNE.f_adresse (V_PERSONNE.IDADRESSE,   1) adr1,  '' adr2,
          V_PERSONNE.codpos, V_PERSONNE.ville, V_PERSONNE.codpays, individu.tel,
          individu.fax, individu.creation, individu.maj,
          pers_tierspayant.numtp, pers_tierspayant.type_tiers,
          pers_tierspayant.regime, pers_tierspayant.caisse,
          pers_tierspayant.centre
     FROM individu, pers_tierspayant, V_PERSONNE
     LEFT OUTER JOIN PERS_ADRESSE ON PERS_ADRESSE.IDADRESSE = V_PERSONNE.IDADRESSE
    WHERE individu.numindiv = pers_tierspayant.numindiv
      AND V_PERSONNE.numindiv = pers_tierspayant.numindiv
GO
CREATE OR REPLACE SYNONYM ARTHUS.TRPNT FOR ARTHUS.TIERSPAYANT

GO
CREATE OR REPLACE PUBLIC SYNONYM TIERSPAYANT FOR ARTHUS.TIERSPAYANT

GO
CREATE OR REPLACE PUBLIC SYNONYM TRPNT FOR ARTHUS.TIERSPAYANT
