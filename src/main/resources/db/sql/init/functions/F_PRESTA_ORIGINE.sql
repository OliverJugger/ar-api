CREATE FUNCTION ARTHUS."F_PRESTA_ORIGINE" (a_numsin IN NUMBER)
   RETURN VARCHAR2
IS
   loc_retour   VARCHAR2 (2);

   CURSOR ligned
   IS
      SELECT sinistre.numsin, sinistre_sante.numannul,
             sinistre_sante.numfact, sinistre_sante.numorg,
             sinistre_sante.numorigine, sinistre_sante.numligne,
             sinistre_sante.num_dossier,
             f_frmls_compl (sinistre.numgar, sinistre.numfor) tg
        FROM sinistre, sntr_dossier, sinistre_sante
       WHERE sinistre_sante.num_dossier = sntr_dossier.num_dossier
         AND sinistre_sante.numligne = sntr_dossier.numligne
         AND sntr_dossier.numsin_sntr = sinistre.numsin
         AND sinistre.numsin = a_numsin;

   l_ligned     ligned%ROWTYPE;
BEGIN
   OPEN ligned;

   FETCH ligned
    INTO l_ligned;

   IF l_ligned.numannul IS NOT NULL
   THEN
      loc_retour := 'A';
   ELSIF l_ligned.numorigine IS NOT NULL
   THEN
      loc_retour := 'F';
   ELSE
      BEGIN
         SELECT 'O'
           INTO loc_retour
           FROM sinistre_sante
          WHERE num_dossier = l_ligned.num_dossier
            AND numannul = l_ligned.numligne
            AND EXISTS (
                   SELECT 1
                     FROM sinistre_sante
                    WHERE num_dossier = l_ligned.num_dossier
                      AND numorigine = l_ligned.numligne);
      EXCEPTION
         WHEN OTHERS
         THEN
            IF l_ligned.numorg = 103
            THEN
               loc_retour := 'I';
            ELSE
               loc_retour := 'X';
            END IF;
      END;
   END IF;

   IF l_ligned.tg = 1
   THEN
      loc_retour := 'C' || loc_retour;
   END IF;

   CLOSE ligned;

   RETURN loc_retour;
END f_presta_origine;
