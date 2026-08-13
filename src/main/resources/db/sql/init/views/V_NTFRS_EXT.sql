CREATE FORCE VIEW ARTHUS.V_NTFRS_EXT AS
SELECT  natfrais.CODFRAIS
      , natfrais.LIBELLE
      , natfrais.TYPE
      , natfrais.RUBRIQUE
      , natfrais.PRIXMIN
      , natfrais.PRIXMAX
      , natfrais.REMBTSSMIN
      , natfrais.REMBTSSMAX
      , natfrais.CNVTN
      , natfrais.NOMBRE
      , natfrais.SEL
      , natfrais.TYPE_ACTE
FROM natfrais
WHERE natfrais.type = 2
UNION ALL
SELECT  ntfrs_origine.CODFRAIS
      , ntfrs_origine.LIBELLE
      , ntfrs_origine.TYPE
      , calcul.RUBRIQUE
      , ntfrs_origine.PRIXMIN
      , ntfrs_origine.PRIXMAX
      , ntfrs_origine.REMBTSSMIN
      , ntfrs_origine.REMBTSSMAX
      , ntfrs_origine.CNVTN
      , ntfrs_origine.NOMBRE
      , ntfrs_origine.SEL
      , ntfrs_origine.TYPE_ACTE
FROM calcul, natfrais, natfrais ntfrs_origine
WHERE calcul.codfrais = natfrais.codfrais
  AND calcul.rubrique != natfrais.rubrique
  AND calcul.rubrique != 'VIDE'
  AND calcul.codfrais = ntfrs_origine.codfrais
  AND natfrais.type = 2
  AND ntfrs_origine.type = 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_NTFRS_EXT FOR ARTHUS.V_NTFRS_EXT
