CREATE FORCE VIEW ARTHUS.V_APPLI AS
SELECT "CODAPLI", "NOM", "TYPE", "FONCTION", "SEC", "CLE1", "CLE2"
     FROM appli
    WHERE codapli IN (SELECT codapli
                        FROM profil
                       WHERE profil = 'ADM')
    --AND TYPE != 5 : M0004551 : mise en commentaire pour ne pas exclure le nouveau type défini
GO
CREATE OR REPLACE PUBLIC SYNONYM V_APPLI FOR ARTHUS.V_APPLI
