CREATE FUNCTION ARTHUS.F_SNTR_PREV_FIN (a_NoSin IN NUMBER) RETURN DATE
AS
  d_Result DATE;
BEGIN
  BEGIN
    -- Date de Fin du Sinistre
    SELECT max(debut) INTO d_Result
      FROM HISTO_SNTR_PREV
     WHERE NOSIN = a_NoSin AND ETAT = 2;

    --SDA 22/01/2014
    IF d_Result < nvl(F_SNTR_PREV_DEBUT(a_NoSin),d_Result) THEN
      RETURN NULL;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Date de Cloture ou de Fin du Dossier Sinistre
      SELECT NVL(ds.Cloture,ds.Fin) INTO d_Result
        FROM SNTR_PREV sp, DOSSIER_SINISTRE ds
       WHERE sp.IdDossier = ds.IdDossier
         AND sp.NoSin=a_NoSin;
  END;
  RETURN TRUNC(d_Result);
EXCEPTION
   WHEN OTHERS THEN RETURN NULL;
END;
