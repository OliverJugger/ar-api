CREATE PROCEDURE ARTHUS."P_ANNUL_FN_ENVOI2" (i_numbord IN NUMBER, i_numenvoi IN NUMBER)
IS
   l_numbord      NUMBER;
   l_sum_mtremb   NUMBER;
   l_nb_envoi     NUMBER;
BEGIN
--
   SELECT COUNT (DISTINCT sinistre_sante.numenvoi),
          SUM (sinistre_sante.mtremb)
     INTO l_nb_envoi,
          l_sum_mtremb
     FROM sinistre_sante, dossier_sante
    WHERE sinistre_sante.num_bord = i_numbord
      AND sinistre_sante.num_dossier = dossier_sante.num_dossier
      AND dossier_sante.type_doss <> 4
      AND sinistre_sante.numenvoi ! = i_numenvoi;

   IF l_sum_mtremb IS NOT NULL
   THEN
      UPDATE remise_prest
         SET nombre = l_nb_envoi,
             montant = l_sum_mtremb,
             montant_d = l_sum_mtremb
       WHERE num_bord = i_numbord;

      UPDATE sinistre_sante
         SET num_bord = NULL,
             numenvoi = NULL
       WHERE numenvoi = i_numenvoi AND num_bord = i_numbord;
   END IF;
END;
/
