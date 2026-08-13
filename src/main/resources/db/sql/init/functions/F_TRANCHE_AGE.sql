CREATE FUNCTION ARTHUS."F_TRANCHE_AGE" (
   a_age   IN   NUMBER,
   a_t1d   IN   NUMBER,
   a_t1f   IN   NUMBER,
   a_t2d   IN   NUMBER,
   a_t2f   IN   NUMBER,
   a_t3d   IN   NUMBER,
   a_t3f   IN   NUMBER,
   a_t4d   IN   NUMBER,
   a_t4f   IN   NUMBER
)
   RETURN NUMBER
AS
   loc_tranche_age   NUMBER;
BEGIN
   SELECT 1
     INTO loc_tranche_age
     FROM DUAL
    WHERE a_age BETWEEN a_t1d AND a_t1f
   UNION
   SELECT 2
     FROM DUAL
    WHERE a_age BETWEEN a_t2d AND a_t2f
   UNION
   SELECT 3
     FROM DUAL
    WHERE a_age BETWEEN a_t3d AND a_t3f
   UNION
   SELECT 4
     FROM DUAL
    WHERE a_age BETWEEN a_t4d AND a_t4f;

   RETURN loc_tranche_age;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      loc_tranche_age := 9;
      RETURN (loc_tranche_age);
END f_tranche_age;
