CREATE FUNCTION ARTHUS.F_SNTR_RECHUTE(a_NoSin IN NUMBER,a_datecalcul IN DATE) RETURN NUMBER
AS
/*---------------------------------------------------------------------------*/
/* FONCTION     :  F_SNTR_RECHUTE                                            */
/* Nom          :  F_SNTR_RECHUTE                                            */
/* Description  :  Renvoi la date de reouverture pour le motif rechute       */
/* Entree       :  a_NoSin, numéro du sinistre prévoyance                    */
/* Retour       :  1 calcul autorise                                         */
/*                 0 pas de calcul                                           */
/* Modif.       :  SDA 04/03/2014 max(debut) au lieu de debut Evol GEREP PREV*/
/* Modif.       :  PHA la date de calcul est comparée aux périodes valides   */
/*---------------------------------------------------------------------------*/
  d_Result NUMBER;
BEGIN
    BEGIN

     SELECT MAX(1) INTO d_Result
            FROM (
                  SELECT a.DEBUT adebut , MIN(b.DEBUT) bfin  FROM HISTO_SNTR_PREV a
                                                              LEFT OUTER JOIN HISTO_SNTR_PREV b
                                                              ON  b.NOSIN = a_NoSin AND b.ETAT != 1 AND NVL(b.DEBUT, a.DEBUT) >= a.DEBUT
                                                                  WHERE a.NOSIN = a_NoSin AND a.ETAT = 1 GROUP BY a.DEBUT
                  )
                WHERE a_datecalcul BETWEEN adebut and NVL(bfin, a_datecalcul);

       RETURN 1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END;
EXCEPTION
  WHEN OTHERS THEN RETURN 0;
END;
