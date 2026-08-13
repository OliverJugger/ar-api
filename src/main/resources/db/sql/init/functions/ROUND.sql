CREATE FUNCTION ARTHUS."ROUND" (a_montant IN NUMBER, a_niveau IN NUMBER)
   RETURN NUMBER
AS
   loc_round   NUMBER DEFAULT 0;
BEGIN
   loc_round :=
        FLOOR ((a_montant + (POWER (10, a_niveau) / 2))
               / POWER (10, a_niveau))
      * POWER (10, a_niveau);
   RETURN loc_round;
END ROUND;
