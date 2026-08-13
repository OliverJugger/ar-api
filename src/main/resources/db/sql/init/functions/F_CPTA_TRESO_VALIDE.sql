CREATE FUNCTION ARTHUS."F_CPTA_TRESO_VALIDE" (i_numdecaismt IN NUMBER)
   RETURN NUMBER
AS
   CURSOR c_releve_compte
   IS
      SELECT valide
        FROM releve_compte
       WHERE idreleve_compte IN (
                     SELECT idreleve_compte
                       FROM remise_op_detail
                      WHERE numdecaismt IN (
                                            SELECT numdecaismt
                                              FROM decaismt
                                             WHERE numdecaismt =
                                                                i_numdecaismt));

   r_releve_compte   c_releve_compte%ROWTYPE;
   loc_retour        NUMBER;
   loc_type_dec      NUMBER;
   loc_valide        VARCHAR2 (1);
BEGIN
   BEGIN
      SELECT f_cpta_op (i_numdecaismt)
        INTO loc_type_dec
        FROM DUAL;
   END;

   IF loc_type_dec = 2
   THEN
      BEGIN
         OPEN c_releve_compte;

         FETCH c_releve_compte
          INTO r_releve_compte;

         IF c_releve_compte%FOUND
         THEN
            loc_valide := r_releve_compte.valide;
         ELSE
            loc_valide := 'N';
         END IF;

         CLOSE c_releve_compte;
      EXCEPTION
         WHEN OTHERS
         THEN
            loc_valide := 'N';

            CLOSE c_releve_compte;
      END;

      IF loc_valide = 'O'
      THEN
         loc_retour := 1;
      ELSE
         loc_retour := 0;
      END IF;
   ELSE
      loc_retour := 1;
   END IF;

   RETURN (loc_retour);
END f_cpta_treso_valide;
