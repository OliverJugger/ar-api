CREATE FUNCTION ARTHUS."F_ETAT_GARANTIE" (
   a_numindiv     IN   NUMBER,
   a_idadhesion   IN   NUMBER,
   a_numfor       IN   NUMBER,
   a_type_for     IN   NUMBER,
   a_date         IN   DATE,
   a_type         IN   NUMBER DEFAULT 1
)
   RETURN NUMBER
AS
   loc_retour   NUMBER   DEFAULT 1;

   CURSOR c_couv
   IS
      SELECT adhesion.etat, d2j (adhesion.datapli) datapli,
             d2j (adhesion.datper) datper
        FROM adhesion
       WHERE adhesion.idadhesion = a_idadhesion
         AND adhesion.numindiv = a_numindiv
         AND adhesion.numfor = a_numfor
         AND a_date BETWEEN adhesion.datapli
                        AND NVL (adhesion.datper, a_date)
         AND adhesion.typfor = a_type_for;
   rec_c_couv   c_couv%ROWTYPE;

BEGIN
   BEGIN
      OPEN c_couv;

      FETCH c_couv INTO rec_c_couv;

      IF (c_couv%FOUND) THEN
         loc_retour := 1;
      ELSE
         loc_retour := 0;
      END IF;

      CLOSE c_couv;
   END;
   RETURN loc_retour;
END F_ETAT_GARANTIE;
