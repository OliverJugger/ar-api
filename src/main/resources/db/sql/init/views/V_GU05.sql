CREATE FORCE VIEW ARTHUS.V_GU05 AS
SELECT
     utilisateurs.numutil                                          numutil
    ,utilisateurs.nom                                                  nom
    ,utilisateurs.pseudo                                            pseudo
    ,utilisateurs.profil                                            profil
    ,NVL(utilisateurs.date_creation,TO_DATE('01/01/1900','DD/MM/YYYY'))   date_creation
    ,utilisateurs.date_fin                                        date_fin
    ,DECODE(utilisateurs.date_fin, NULL, 0, 1)                    gu05_tri
  FROM utilisateurs
  WHERE utilisateurs.numuid IS NOT NULL -- On exclu les users techniques (DSN, extranet, TPE...)
  ORDER BY gu05_tri ASC, date_creation DESC, utilisateurs.date_fin DESC
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GU05 FOR ARTHUS.V_GU05
