CREATE FUNCTION ARTHUS."F_QTTC_ANNUELLE" (
   a_idadhesion   IN   NUMBER,
   a_date         IN   DATE,
   a_tarif        IN   NUMBER DEFAULT 1
)
   RETURN NUMBER
AS
   loc_fin       DATE;
   loc_debut     DATE;
   loc_montant   NUMBER;
   loc_retour    NUMBER;
   loc_fract     NUMBER;
BEGIN
   IF (a_tarif = 1)
   THEN
      BEGIN
         SELECT   NVL (SUM (mt_ttc), 0), MIN (debut), MAX (fin)
             INTO loc_montant, loc_debut, loc_fin
             FROM qttc_global
            WHERE idadhesion = a_idadhesion
              AND debut BETWEEN TRUNC (a_date, 'Y')
                            AND ADD_MONTHS (TRUNC (a_date, 'Y'), 12) - 1
              AND comptant != 'R'
         GROUP BY idadhesion;

         loc_retour :=
                  loc_montant / f_prorata (d2j (loc_debut), d2j (loc_fin))
                  * 12;
         RETURN (loc_retour);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
            RETURN (loc_retour);
      END;
   ELSE
      BEGIN
         SELECT   SUM (NVL (mt_ttc, 0)), MIN (debut), MAX (fin)
             INTO loc_montant, loc_debut, loc_fin
             FROM qttc_global
            WHERE idadhesion = a_idadhesion
              AND a_date BETWEEN debut AND fin
              AND comptant != 'R'
         GROUP BY idadhesion;

         loc_retour :=
               (loc_montant / f_prorata (d2j (loc_debut), d2j (loc_fin))
               ) * 12;
         RETURN (loc_retour);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT   NVL (SUM (mt_ttc), 0), MIN (debut), MAX (fin)
                   INTO loc_montant, loc_debut, loc_fin
                   FROM qttc_global
                  WHERE idadhesion = a_idadhesion
                    AND debut BETWEEN TRUNC (a_date, 'Y')
                                  AND ADD_MONTHS (TRUNC (a_date, 'Y'), 12) - 1
                    AND comptant != 'R'
               GROUP BY idadhesion;

               loc_retour :=
                  loc_montant / f_prorata (d2j (loc_debut), d2j (loc_fin))
                  * 12;
               RETURN (loc_retour);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  loc_retour := 0;
                  RETURN (loc_retour);
            END;
      END;
   END IF;
END f_qttc_annuelle;
