CREATE FUNCTION ARTHUS."F_CPTA_TYPE_PMT" (i_type IN NUMBER, i_clef IN NUMBER)
   RETURN NUMBER
IS
   loc_retour   NUMBER;
BEGIN
   IF i_type = 1
   THEN
      BEGIN
         SELECT 1
           INTO loc_retour
           FROM decaismt, compte
          WHERE numdecaismt = i_clef
            AND decaismt.numcpte = compte.numcpte
            AND decaismt.monnaie_d = compte.monnaie;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 2;
      END;
   ELSE
      BEGIN
         SELECT 1
           INTO loc_retour
           FROM encaismt, compte
          WHERE numencaismt = i_clef
            AND encaismt.numcpte = compte.numcpte
            AND encaismt.monnaie_d = compte.monnaie;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 2;
      END;
   END IF;

   RETURN (loc_retour);
END f_cpta_type_pmt;
