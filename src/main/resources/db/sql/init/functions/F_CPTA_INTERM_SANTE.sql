CREATE FUNCTION ARTHUS."F_CPTA_INTERM_SANTE" (
   i_etendue   IN   NUMBER,
   i_cle       IN   NUMBER,
   i_numfor    IN   NUMBER,
   i_typbene   IN   NUMBER,
   i_numbene   IN   NUMBER,
   i_type      IN   NUMBER,
   i_date      IN   DATE DEFAULT SYSDATE
)
   RETURN NUMBER
IS
   loc_retour            NUMBER;
   loc_cpta_role_force   NUMBER;
BEGIN
   SELECT f_cpta_role_force (i_numfor, i_typbene)
     INTO loc_cpta_role_force
     FROM DUAL;

   IF (loc_cpta_role_force = 2 OR loc_cpta_role_force = 4)
   THEN
      IF i_typbene = 3
      THEN
         loc_retour := i_numbene;
      ELSE
         SELECT f_intermediaire (i_etendue, i_cle, i_type, i_date)
           INTO loc_retour
           FROM DUAL;
      END IF;
   ELSE
      loc_retour := 0;
   END IF;

   RETURN (loc_retour);
END f_cpta_interm_sante;
