CREATE FUNCTION ARTHUS."F_NUMGRPGAR" (a_numfor IN NUMBER)
   RETURN NUMBER
IS
   loc_numgrpgar   NUMBER;
BEGIN
   SELECT numgrpgar
     INTO loc_numgrpgar
     FROM grp_gar_def
    WHERE numfor = a_numfor;

   RETURN (loc_numgrpgar);
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      loc_numgrpgar := a_numfor;
      RETURN (loc_numgrpgar);
END;
