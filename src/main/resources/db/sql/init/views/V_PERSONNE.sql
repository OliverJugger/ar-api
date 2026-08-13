CREATE FORCE VIEW ARTHUS.V_PERSONNE AS
SELECT   
    0 idadresse,
    i.codpos,
    i.numindiv,
    i.nom,     TRANSLATE(i.nom   ,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÇÔ-','AAEEEEIIaaaaeeeeiiouuUUCO ') nom_t,
    i.prenom,  TRANSLATE(i.prenom,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÇÔ-','AAEEEEIIaaaaeeeeiiouuUUCO ') prenom_t,
    i.nomjf,   TRANSLATE(i.nomjf ,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÇÔ-','AAEEEEIIaaaaeeeeiiouuUUCO ') nomjf_t,
    i.type,
    i.datnais,
    i.deces,
    i.refcie,
    i.n_insee,
    i.MATORG,
    i.creation,
    NVL (i.codcourrier1, 0) codc1,
    i.ville,
    i.codpays,
    ARTHUS.pk_libelle.f_lib('PAYS',i.codpays) pays
  FROM indvs i
  WHERE NVL(ARTHUS.PK_PERSONNE.F_IDADRESSE(i.numindiv),0) = 0
  UNION
  SELECT ad1.idadresse,
    DECODE (ad1.type, 3, adi.adr4, ad1.codpos ) codpos,
    i.numindiv,
    i.nom,     TRANSLATE(i.nom   ,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÇÔ-','AAEEEEIIaaaaeeeeiiouuUUCO ') nom_t,
    i.prenom,  TRANSLATE(i.prenom,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÇÔ-','AAEEEEIIaaaaeeeeiiouuUUCO ') prenom_t,
    i.nomjf,   TRANSLATE(i.nomjf ,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÇÔ-','AAEEEEIIaaaaeeeeiiouuUUCO ') nomjf_t,
    i.TYPE,
    i.datnais,
    i.deces,
    i.refcie,
    i.n_insee,
    i.MATORG,
    i.creation creation,
    NVL (i.codcourrier1, 0),
    DECODE (ad1.type, 3, adi.adr5, ad1.ville ) ville,
    i.codpays,
    ARTHUS.pk_libelle.f_lib('PAYS',i.codpays) pays
  FROM indvs i,
       pers_adresse ad1,
       adr_internationale adi
  WHERE ad1.idadresse = adi.idadresse(+)
    AND NVL(ARTHUS.PK_PERSONNE.F_IDADRESSE(i.numindiv),0)=ad1.idadresse
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PERSONNE FOR ARTHUS.V_PERSONNE
