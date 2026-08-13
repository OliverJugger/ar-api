CREATE FUNCTION ARTHUS."F_NUMAFFEC" (
   a_numdecaismt   IN   decaismt.numdecaismt%TYPE,
   a_codope        IN   decaismt.codope%TYPE
)
   RETURN NUMBER
IS
   loc_retour   NUMBER;
BEGIN
   BEGIN
      SELECT MIN (numaffec)
        INTO loc_retour
        FROM affectation
       WHERE numdecaismt = a_numdecaismt AND codope = a_codope;
   EXCEPTION
      WHEN OTHERS
      THEN
         loc_retour := 0;
   END;

   RETURN (loc_retour);
END f_numaffec;
