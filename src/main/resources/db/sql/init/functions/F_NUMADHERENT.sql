CREATE FUNCTION ARTHUS."F_NUMADHERENT" (comm_numindiv IN NUMBER, comm_numfor IN NUMBER)
   RETURN NUMBER
AS
   loc_numadhe   NUMBER (9);
BEGIN
   BEGIN
      SELECT distinct adhe_cntrt.numadhe
        INTO loc_numadhe
        FROM adhe_cntrt, adhesion
       WHERE adhesion.numindiv = comm_numindiv
         AND adhesion.numfor = comm_numfor
         AND adhesion.idadhesion = adhe_cntrt.idadhesion;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_numadhe := comm_numindiv;
      WHEN TOO_MANY_ROWS
      THEN
         loc_numadhe := comm_numindiv;
   END;

   RETURN (loc_numadhe);
END f_numadherent;
