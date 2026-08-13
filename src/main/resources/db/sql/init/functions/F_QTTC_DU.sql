CREATE FUNCTION ARTHUS."F_QTTC_DU" (a_idadhesion IN NUMBER, a_debut IN DATE, a_NbAnnee IN NUMBER DEFAULT 0)
   RETURN NUMBER
AS
   loc_montant   NUMBER;
BEGIN
   SELECT SUM (qttc_global.mt_ttc) - SUM(NVL (qttc_global.mt_affec, 0))
     INTO loc_montant
     FROM qttc_global
    WHERE qttc_global.idadhesion = a_idadhesion
      AND NVL(qttc_global.mt_affec, 0) < qttc_global.mt_ttc
      AND qttc_global.comptant != 'R'
      AND NOT EXISTS (
             SELECT 1
               FROM emission
              WHERE emission.codope = 4
                AND emission.numfact = numquit
                AND emission.numrelance IN (4, 99))
      -- En fonction de a_NbAnnee :
      AND ((NVL(a_NbAnnee,0) = 0 AND debut < a_debut AND type_qttc != 3) OR -- avant la date de début
           (NVL(a_NbAnnee,0) > 0 AND debut >= ADD_MONTHS(TRUNC(a_debut, 'Y'), -12*(a_NbAnnee-1)) AND fin <= ADD_MONTHS(TRUNC(a_debut, 'Y'), 12) - 1) OR
           -- pour un nombre d'année (avant la date de début)
           (NVL(a_NbAnnee,0) < 0) -- pour toutes les cotisations calculées depuis le début de l'adhésion
          );

   RETURN (NVL (loc_montant, 0));
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      loc_montant := 0;
      RETURN (loc_montant);
END;
