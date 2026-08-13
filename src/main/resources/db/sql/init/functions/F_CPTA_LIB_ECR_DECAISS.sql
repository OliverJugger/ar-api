CREATE FUNCTION ARTHUS."F_CPTA_LIB_ECR_DECAISS" (i_numsoc IN NUMBER, i_code IN NUMBER)
   RETURN VARCHAR2
IS
   CURSOR c_cpta_ope_libelle
   IS
      SELECT libelle
        FROM compta_ope_compte
       WHERE numsoc = i_numsoc AND code = i_code;

   r_cpta_ope_libelle   c_cpta_ope_libelle%ROWTYPE;
BEGIN
   OPEN c_cpta_ope_libelle;

   FETCH c_cpta_ope_libelle
    INTO r_cpta_ope_libelle;

   IF (c_cpta_ope_libelle%FOUND)
   THEN
      RETURN r_cpta_ope_libelle.libelle;
   ELSE
      RETURN 'Inexistant';
   END IF;

   CLOSE c_cpta_ope_libelle;
END f_cpta_lib_ecr_decaiss;
