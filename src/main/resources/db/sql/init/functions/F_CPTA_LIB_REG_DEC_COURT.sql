CREATE FUNCTION ARTHUS."F_CPTA_LIB_REG_DEC_COURT" (
   i_codope        IN   NUMBER
)
   RETURN VARCHAR2
IS
   loc_code        NUMBER;
   loc_libelle     LIBELLE.libelle%TYPE;
BEGIN
   BEGIN
      SELECT libelle
        INTO loc_libelle
        FROM LIBELLE
       WHERE MNEMO ='MOPM'
         AND CODE= i_codope;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 'INC';
      WHEN TOO_MANY_ROWS
      THEN
         RETURN 'ERR';
   END;

   RETURN UPPER(SUBSTR(loc_libelle,1,3));

END f_cpta_lib_reg_dec_court;
