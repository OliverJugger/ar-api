CREATE FUNCTION ARTHUS.F_PARAM_OPE_VALIDE (
   a_numgar    IN   NUMBER,
   a_codope    IN   NUMBER,
   a_modpmt    IN   NUMBER,
   a_mode      IN   NUMBER,
   a_montant   IN   NUMBER,
   a_date      IN   DATE DEFAULT NULL
)
   RETURN NUMBER
AS
   loc_retour    NUMBER;
   loc_numbene   NUMBER;
   loc_deredit   DATE;
BEGIN
   loc_retour := 0;

   IF (a_mode = 1)
   THEN
      /* Delai de paiement */
      BEGIN
         SELECT 1
           INTO loc_retour
           FROM param_ope
          WHERE ROWID = f_param_ope (a_numgar, a_codope, a_modpmt)
            AND (   a_montant > param_ope.montant
                 OR a_date + param_ope.delai <= TRUNC (SYSDATE)
                );
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;
   ELSE
      /* Frequence d'edition  */
      loc_numbene := a_montant;

      IF (a_date IS NULL)
      THEN
         loc_deredit := f_dernier_avis(a_codope, loc_numbene, a_numgar);
      ELSE
         loc_deredit := NVL(a_date, TO_DATE ('01/01/1901', 'dd/mm/yyyy'));
      END IF;

      BEGIN
         SELECT 1
           INTO loc_retour
           FROM param_ope
          WHERE ROWID = f_param_ope (a_numgar, a_codope, a_modpmt)
            AND (   loc_deredit <= TRUNC (SYSDATE) - param_ope.frequence
                 OR param_ope.frequence = 0
                );
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;
   END IF;

   RETURN (loc_retour);
END;
