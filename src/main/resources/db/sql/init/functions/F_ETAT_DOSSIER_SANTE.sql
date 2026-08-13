CREATE FUNCTION ARTHUS."F_ETAT_DOSSIER_SANTE" (
   a_num_dossier   IN   NUMBER,
   a_date          IN   DATE DEFAULT SYSDATE,
   a_type          IN   NUMBER DEFAULT 1
)
   RETURN NUMBER
IS
   loc_etat      NUMBER            DEFAULT 0;
   l_date        DATE;

   CURSOR c_histo
   IS
      SELECT   histo_dossier.etat, histo_dossier.motif,
               d2j (histo_dossier.debut) debut
          FROM histo_dossier
         WHERE num_dossier = TO_CHAR(a_num_dossier) AND debut <= l_date --AND etat != 0
      ORDER BY TRUNC (debut) DESC, datsai DESC;

   rec_c_histo   c_histo%ROWTYPE;
BEGIN
   loc_etat := 0;

--
   BEGIN
      SELECT GREATEST (dateouv, a_date)
        INTO l_date
        FROM dossier_sante
       WHERE num_dossier = TO_CHAR(a_num_dossier);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         l_date := a_date;
   END;

--
   OPEN c_histo;

   FETCH c_histo
    INTO rec_c_histo;

--
   IF c_histo%FOUND
   THEN
      IF (a_type = 1)
      THEN
         loc_etat := NVL (rec_c_histo.etat, 0);
      ELSIF (a_type = 2)
      THEN
         loc_etat := NVL (rec_c_histo.motif, 0);
      ELSIF (a_type = 3)
      THEN
         loc_etat := NVL (rec_c_histo.debut, 1);
      END IF;
   ELSE
      IF (a_type = 1)
      THEN
         loc_etat := 0;
      ELSIF (a_type = 2)
      THEN
         loc_etat := 0;
      ELSIF (a_type = 3)
      THEN
         loc_etat := 1;
      END IF;
   END IF;

   CLOSE c_histo;

--
   RETURN loc_etat;
--
END;
