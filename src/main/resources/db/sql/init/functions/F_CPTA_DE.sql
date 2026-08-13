CREATE FUNCTION ARTHUS."F_CPTA_DE" (i_numdecaismt IN NUMBER)
   RETURN NUMBER
IS
   loc_retour   NUMBER;
BEGIN
   BEGIN
      SELECT 2
        INTO loc_retour
        FROM DUAL
       WHERE i_numdecaismt IN (
                SELECT numdecaismt
                  FROM remise_vire_detail
                 WHERE numdecaismt = i_numdecaismt
                UNION
                SELECT numdecaismt
                  FROM remise_op_detail
                 WHERE numdecaismt = i_numdecaismt);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_retour := 1;
   END;

   RETURN (loc_retour);
END f_cpta_de;
