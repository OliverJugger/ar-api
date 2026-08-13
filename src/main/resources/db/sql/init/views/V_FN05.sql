CREATE FORCE VIEW ARTHUS.V_FN05 AS
SELECT DISTINCT COUNT (*) nbre, sinistre_sante.num_dossier,
                   sinistre_sante.numindiv, sinistre_sante.num_bord,
                   sinistre_sante.numenvoi, SUM (sinistre_sante.mtremb)
                                                                       mt_rbt,
                   sinistre_sante.devise_in
              FROM sinistre_sante
             WHERE sinistre_sante.num_bord IS NOT NULL
          GROUP BY sinistre_sante.num_bord,
                   sinistre_sante.numenvoi,
                   sinistre_sante.num_dossier,
                   sinistre_sante.numindiv,
                   sinistre_sante.devise_in
          ORDER BY sinistre_sante.num_dossier, sinistre_sante.numenvoi
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FN05 FOR ARTHUS.V_FN05
