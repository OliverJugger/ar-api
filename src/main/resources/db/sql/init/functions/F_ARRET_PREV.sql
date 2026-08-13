CREATE FUNCTION ARTHUS."F_ARRET_PREV" (
   a_nosin     IN   NUMBER,
   a_debut     IN   DATE
)
   RETURN INTEGER
AS
   loc_nbjour    INTEGER         := 0;
   loc_arret     arret%ROWTYPE;
BEGIN
   FOR loc_arret IN (SELECT   debut, fin, continu
                         FROM arret
                        WHERE TRUNC(debut) <> TRUNC(a_debut) AND nosin LIKE SUBSTR(a_nosin,1,7)||'%'
                          AND traite NOT IN ('A', 'R')
                     ORDER BY debut DESC)
   LOOP
      loc_nbjour := loc_nbjour + ((loc_arret.fin - loc_arret.debut) + 1);
   END LOOP;

   RETURN (loc_nbjour);

EXCEPTION
   WHEN OTHERS THEN RETURN NULL;
END F_ARRET_PREV;
