CREATE FUNCTION ARTHUS."F_ARRET_CONTINU" (
   a_nosin     IN   NUMBER,
   a_debut     IN   DATE,
   a_continu   IN   VARCHAR2
)
   RETURN INTEGER
AS
   loc_nbjour    INTEGER         := 0;
   loc_debut     DATE            := a_debut;
   loc_continu   VARCHAR2 (1)    := a_continu;
   loc_arret     arret%ROWTYPE;
BEGIN
   FOR loc_arret IN (SELECT   debut, fin, continu
                         FROM arret
                        WHERE fin < a_debut AND nosin = a_nosin
                          AND traite NOT IN ('A', 'R')
                     ORDER BY debut DESC)
   LOOP
      IF ((loc_arret.fin = loc_debut - 1) OR (loc_continu = 'O'))
      THEN
         loc_nbjour := loc_nbjour + ((loc_arret.fin - loc_arret.debut) + 1);
      END IF;

      loc_debut := loc_arret.debut;
      loc_continu := loc_arret.continu;
   END LOOP;

   RETURN (loc_nbjour);

EXCEPTION
   WHEN OTHERS THEN RETURN NULL;
END f_arret_continu;
