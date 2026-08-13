CREATE FUNCTION ARTHUS."F_ETAT_SINISTRE_SANTE" (
  a_num_dossier   IN   NUMBER,
  a_numligne      IN   NUMBER,
  a_date          IN   DATE DEFAULT SYSDATE,
  a_type          IN   NUMBER DEFAULT 1
)
   RETURN NUMBER
IS
  loc_etat      NUMBER            DEFAULT 0;
  l_date        DATE;

  CURSOR C_histo is
    SELECT etat,
           motif,
           datetat
    FROM histo_sinistre_sante
      WHERE num_dossier = TO_CHAR(a_num_dossier)
      AND   numligne = a_numligne
      AND datetat <= L_date
      AND etat != 0
    ORDER BY datetat desc ;

  Rec_C_histo C_histo%Rowtype;

BEGIN
   loc_etat := 0;
   l_date := a_date;

--
   OPEN c_histo;
   FETCH c_histo INTO rec_c_histo;
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
         loc_etat := NVL (d2j(rec_c_histo.datetat), 1);
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
