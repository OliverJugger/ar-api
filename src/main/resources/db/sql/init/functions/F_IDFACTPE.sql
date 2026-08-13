CREATE FUNCTION ARTHUS."F_IDFACTPE" (
   anumps       IN   NUMBER,
   anumfact     IN   VARCHAR2,
   adatfact     IN   VARCHAR2,
   acodinsee    IN   VARCHAR2,
   acleinsee    IN   NUMBER,
   adatnais     IN   VARCHAR2,
   arangbenef   IN   VARCHAR2,
   acomplt_titre IN NUMBER default null
)
   RETURN NUMBER
/******************************************************************************/
-- F_IDFACTPE -- Fonction de création d'identifiant TPE
/******************************************************************************/
-- ABO le 07/03/2012
/******************************************************************************/
-- Paramètres entrée
--             anumps : Identifiant adeli du PS
--             anumfact : numéro de la facture du PS
--             adatfact : date de la facture du PS
--             acodinsee : numéro de sécu du bénéfiaire
--             acleinsee : cle sécu du bénéficiaire
--             adatnais : date de naissance du bénéficiaire
--             arangbenef : rang du bénéficiaire
-- sortie
--             identifiant unique TPE
/******************************************************************************/
--ABO M0003606 retrait pour EPAI de la date de la facture à cause d'abus PS
--11/09/2014 SDA TPH GEREP ajout de a complt_titre
/******************************************************************************/
IS
   loc_retour   NUMBER;
BEGIN
   BEGIN
      SELECT DISTINCT idfactpe
                 INTO loc_retour
                 FROM suivi_fact_tpe
                WHERE codadeli = anumps
                  AND numfact = RTRIM (anumfact)
                --  AND datfact = f_siecle (adatfact, 'DDMMYY')
                  AND codbenefinsee = acodinsee
                  AND codbenefcle = acleinsee
                  AND datnaibenef = adatnais
                  AND rangbenef = arangbenef
                  AND NVL(complt_titre,-1) = nvl(acomplt_titre,-1) ;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         loc_retour := 0;
      WHEN TOO_MANY_ROWS
      THEN
         loc_retour := 0;
   END;

   IF (loc_retour = 0)
   THEN
      SELECT idfactpe.NEXTVAL
        INTO loc_retour
        FROM DUAL;
   END IF;

   RETURN (loc_retour);
END f_idfactpe;
