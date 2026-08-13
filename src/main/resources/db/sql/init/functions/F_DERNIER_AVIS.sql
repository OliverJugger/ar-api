CREATE FUNCTION ARTHUS.F_DERNIER_AVIS (
   a_codope    IN   NUMBER,
   a_numbene   IN   NUMBER,
   a_numgar    IN   NUMBER
)
   RETURN DATE
AS
   loc_retour   DATE;
   dummy        NUMBER;
   decais       decaismt%ROWTYPE;
BEGIN
   loc_retour := TO_DATE ('01/01/1901', 'dd/mm/yyyy');

   FOR decais IN (SELECT /*+ FIRST_ROWS(1) */ decaismt.numdecaismt, decaismt.datedit
                      FROM decaismt, affectation
                     WHERE decaismt.codope         = a_codope
                       AND affectation.numdecaismt = decaismt.numdecaismt
                       AND affectation.codope      = decaismt.codope
                       AND decaismt.numbene        = a_numbene
                       AND decaismt.numedit       != 0
                  ORDER BY decaismt.numedit DESC)
   LOOP
      IF (a_codope = 1)
      THEN
         BEGIN
            SELECT MIN (1)
              INTO dummy
              FROM affectation
             WHERE affectation.numdecaismt = decais.numdecaismt
               AND affectation.codope = 1
               AND EXISTS (
                      SELECT 1
                        FROM decompte
                       WHERE decompte.numgar + 0 = a_numgar
                         AND decompte.numdec = affectation.numaffec);

            IF (dummy = 1)
            THEN
               loc_retour := decais.datedit;
               EXIT;
            END IF;
         END;
      ELSIF (a_codope = 2)
      THEN
         BEGIN
            SELECT MIN (1)
              INTO dummy
              FROM decompte_prev, adhe_cntrt, affectation
             WHERE adhe_cntrt.numgar = a_numgar
               AND decompte_prev.numdec = affectation.numaffec
               AND decompte_prev.idadhesion = adhe_cntrt.idadhesion
               AND affectation.numdecaismt = decais.numdecaismt
               AND affectation.codope = 2;

            IF (dummy = 1)
            THEN
               loc_retour := decais.datedit;
               EXIT;
            END IF;
         END;
      END IF;
   END LOOP;

   RETURN (loc_retour);
END;
