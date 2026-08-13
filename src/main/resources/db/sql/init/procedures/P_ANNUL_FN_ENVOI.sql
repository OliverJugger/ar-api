CREATE PROCEDURE ARTHUS."P_ANNUL_FN_ENVOI" (i_numbord IN NUMBER, i_numenvoi IN NUMBER)
IS
   l_numbord      NUMBER;
   l_sum_mtremb   NUMBER;
BEGIN
--
   SELECT SUM (mtremb)
     INTO l_sum_mtremb
     FROM sinistre_sante
    WHERE numenvoi = i_numenvoi AND num_bord = i_numbord;

   IF l_sum_mtremb IS NOT NULL
   THEN
      UPDATE remise_prest
         SET nombre = nombre - 1,
             montant = montant - l_sum_mtremb,
             montant_d = montant_d - l_sum_mtremb
       WHERE num_bord = i_numbord;

      UPDATE sinistre_sante
         SET num_bord = NULL,
             numenvoi = NULL
       WHERE numenvoi = i_numenvoi AND num_bord = i_numbord;
   END IF;
END;
/
