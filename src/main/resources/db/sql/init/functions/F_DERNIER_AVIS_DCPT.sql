CREATE FUNCTION ARTHUS.F_DERNIER_AVIS_DCPT (
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
      
  IF (a_codope = 1) THEN
    FOR decais IN (SELECT   decaismt.numdecaismt, decaismt.datedit
                       FROM decaismt, affectation, decompte
                      WHERE decaismt.codope      = a_codope
                        AND decaismt.numbene     = a_numbene
                        AND decaismt.numedit    != 0
                        AND decaismt.numdecaismt = affectation.numdecaismt
                        AND affectation.codope   = a_codope    
                        AND decompte.numdec      = affectation.numaffec
                        AND decompte.numgar + 0  = a_numgar
                   ORDER BY decaismt.numedit DESC)
    LOOP
      BEGIN
        loc_retour := decais.datedit;
        EXIT;
      END;   
    END LOOP;
  ELSIF (a_codope = 2) THEN  
    FOR decais IN (SELECT   decaismt.numdecaismt, decaismt.datedit
                       FROM decaismt, affectation, decompte_prev, adhe_cntrt
                      WHERE decaismt.codope      = a_codope
                        AND decaismt.numbene     = a_numbene
                        AND decaismt.numedit    != 0 
                        AND affectation.codope   = a_codope
                        AND adhe_cntrt.numgar    = a_numgar
                        AND decompte_prev.numdec = affectation.numaffec
                        AND decompte_prev.idadhesion = adhe_cntrt.idadhesion
                        AND affectation.numdecaismt  = decaismt.numdecaismt
                   ORDER BY decaismt.numedit DESC)
    LOOP
      BEGIN
        loc_retour := decais.datedit;
        EXIT;
      END;
    END LOOP;  
  END IF;

  RETURN (loc_retour);
END;
