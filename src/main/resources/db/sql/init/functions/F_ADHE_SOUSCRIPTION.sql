CREATE FUNCTION ARTHUS.F_ADHE_SOUSCRIPTION
(
   i_numgar       IN   NUMBER,
   i_idadhesion   IN   NUMBER
)
   RETURN DATE
AS
   datesous  DATE DEFAULT NULL;

   CURSOR c1
   IS
      SELECT   adhe_cntrt.dsous
          FROM adhe_cntrt
         WHERE idadhesion = i_idadhesion
           AND numgar = i_numgar;
BEGIN
   OPEN c1;
   FETCH c1
    INTO datesous;

   IF (c1%NOTFOUND)
   THEN
    datesous := NULL;
   END IF;

   CLOSE c1;

   RETURN datesous;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END f_adhe_souscription;
