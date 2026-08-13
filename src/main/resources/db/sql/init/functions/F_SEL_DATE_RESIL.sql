CREATE FUNCTION ARTHUS."F_SEL_DATE_RESIL" (
   i_numgar   IN   histo_contrat.numgar%TYPE,
   i_debut    IN   DATE DEFAULT SYSDATE
)
   RETURN DATE
IS
   CURSOR c_histo_contrat
   IS
      /* MUR M0006541
      SELECT   debut
          FROM histo_contrat
         WHERE numgar = i_numgar
           AND etat = 3
           AND NOT EXISTS (
                  SELECT 1
                    FROM histo_contrat a
                   WHERE a.numgar = histo_contrat.numgar
                     AND a.debut = histo_contrat.debut
                     AND a.etat = 1)
      ORDER BY debut DESC, datsai DESC;
      */
      SELECT   debut
          FROM histo_contrat
         WHERE numgar = i_numgar
           AND etat = 3
           AND annul = 'N'
      ORDER BY debut DESC, datsai DESC;

--
   l_debut   histo_contrat.debut%TYPE;
--
BEGIN
   OPEN c_histo_contrat;

   FETCH c_histo_contrat
    INTO l_debut;

   IF (c_histo_contrat%NOTFOUND)
   THEN
      l_debut := '01-jan-3000';
   END IF;

   CLOSE c_histo_contrat;

   RETURN l_debut;
END;
