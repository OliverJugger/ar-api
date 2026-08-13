CREATE FUNCTION ARTHUS."F_CPTA_ROLE_FORCE" (i_numfor IN NUMBER, i_typbene IN NUMBER
         DEFAULT 1)
   RETURN NUMBER
IS
   loc_retour      NUMBER;
   loc_frcg_gest   NUMBER;
   loc_cpta_role   NUMBER;
   loc_test        NUMBER;
BEGIN
   SELECT f_force_gest (i_numfor)
     INTO loc_frcg_gest
     FROM DUAL;

   SELECT f_cpta_role (i_numfor, 1, 1)
     INTO loc_cpta_role
     FROM DUAL;

   IF loc_frcg_gest = 1
   THEN
      CASE loc_cpta_role
         WHEN 1
         THEN
            loc_retour := 1;
         WHEN 2
         THEN
            loc_retour := 2;
         WHEN 3
         THEN
            loc_retour := 1;
         WHEN 4
         THEN
            loc_retour := 2;
         ELSE
            loc_retour := loc_cpta_role;
      END CASE;
   ELSE
      loc_retour := loc_cpta_role;
   END IF;

   IF i_typbene = 3
   THEN
      CASE loc_retour
         WHEN 1
         THEN
            loc_retour := 2;
         WHEN 2
         THEN
            loc_retour := 2;
         WHEN 3
         THEN
            loc_retour := 4;
         WHEN 4
         THEN
            loc_retour := 4;
      END CASE;
   END IF;

   RETURN (loc_retour);
END f_cpta_role_force;
