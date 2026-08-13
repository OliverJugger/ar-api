CREATE FUNCTION ARTHUS."F_SEL_INTERLOCUTEUR"(
         a_numcorres IN CORRESPONDANT.NUMCORRES%TYPE, -- NÂ° de la societe
         a_entite    IN CORRESPONDANT.ENTITE%TYPE)    -- NÂ° du sinistre
      RETURN NUMBER                                   -- NÂ° d'interlocuteur  (CORRESPONDANT.INTERLOCUTEUR)
   AS
      loc_retour NUMBER DEFAULT 0;
      CURSOR c_interlocuteur
      IS
         SELECT INTERLOCUTEUR
         FROM CORRESPONDANT
         WHERE CORRESPONDANT.NUMCORRES = a_numcorres
         AND CORRESPONDANT.ENTITE      = a_entite;
      rec_c_interlocuteur c_interlocuteur%ROWTYPE;
   BEGIN
      BEGIN
         OPEN c_interlocuteur;
         FETCH c_interlocuteur INTO rec_c_interlocuteur;
         IF (c_interlocuteur%FOUND) THEN
            loc_retour := rec_c_interlocuteur.INTERLOCUTEUR;
         ELSE
            loc_retour := 0;
         END IF;
         CLOSE c_interlocuteur;
      END;
      RETURN loc_retour;
   EXCEPTION
   WHEN OTHERS THEN
      RETURN loc_retour;
   END F_SEL_INTERLOCUTEUR;
