CREATE FORCE VIEW ARTHUS.V_APPLI_MENU AS
SELECT applications.codapli, applications.nom, applications.fonction,
          applications.TYPE, applications.sec, applications.cle1,
          applications.cle2, applications.creation, applications.maj,
          NVL (appli_descript.prog,
               DECODE (applications.TYPE,
                       8, 'ba25',
                       9, 'ba13',
                       LOWER (applications.codapli)
                      )
              ) prog,
          --2 acces  : M0004551 : MUR le 11/08/2014
          applications.type acces
     FROM appli_descript, applications
    WHERE applications.codapli = appli_descript.codapli(+)
      AND EXISTS (
             SELECT 1
               FROM profil
              WHERE applications.codapli = profil.codapli
                AND profil.profil = f_profil (f_numutil)
                -- M0004551 : ajout du 10/09/2014
                AND applications.type = profil.acces
                 )
      AND NOT EXISTS (
             SELECT 1
               FROM appli_client
              WHERE appli_client.codapli = applications.codapli
                AND (   appli_client.fonction = applications.fonction
                     OR appli_client.fonction = 'TOUS'
                    )
                AND appli_client.client = f_client)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_APPLI_MENU FOR ARTHUS.V_APPLI_MENU
