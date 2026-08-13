CREATE FUNCTION ARTHUS."F_NUMGAR_REF" (a_numgar IN NUMBER)
   RETURN NUMBER
IS
   loc_numgar_ref   NUMBER;
BEGIN
   SELECT numgar_ref
     INTO loc_numgar_ref
     FROM contrat
    WHERE numgar = a_numgar;

   RETURN (loc_numgar_ref);
END;
