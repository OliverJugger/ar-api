CREATE FUNCTION ARTHUS."F_CPTA_COMPTE" (i_numsoc IN NUMBER, i_code IN NUMBER)
   RETURN VARCHAR2
IS
   CURSOR c_cpta_compte
   IS
      SELECT compte
        FROM compta_ope_compte
       WHERE numsoc = i_numsoc AND code = i_code;

   r_cpta_compte   c_cpta_compte%ROWTYPE;
BEGIN
   OPEN c_cpta_compte;

   FETCH c_cpta_compte
    INTO r_cpta_compte;

   IF (c_cpta_compte%FOUND)
   THEN
      RETURN r_cpta_compte.compte;
   ELSE
      RETURN 'Inexistant';
   END IF;

   CLOSE c_cpta_compte;
END f_cpta_compte;
