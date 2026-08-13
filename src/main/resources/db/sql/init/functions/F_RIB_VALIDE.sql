CREATE FUNCTION ARTHUS.F_RIB_VALIDE (a_idrib IN RIB.IDRIB%TYPE)
RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_RIB_VALIDE.sql                                           */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ???                                                        */
/* Création     : ???                                                        */
/* Description  : Permet de validé la cohérence des données pour un rib non  */
/*                normalisé et un rib normalisé(SEPA)                        */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    : Ajout du controle sur le rib normalisé(SEPA), Mise en place*/
/*                du cartouche,ajout du synonyme,modification typage variable*/
/* Auteur       : JBO                                                        */
/* Date         : 04/10/2012                                                 */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : JBN ABO / 03/2011 / Ajout de la devise et date de validité */
/*              : PHA    / 27/06/2012 / loc_date                             */
/*              : SEPA 1 si RIB SEPA ou chéque ou normalisé, 2 si non SEPA   */
/*              : PHA    / 28/11/2016 / Présence BIC plus obligatoire M5203  */
/*===========================================================================*/
   loc_valide   NUMBER := 0;
   loc_BIC		RIB.BIC%TYPE;
   loc_nature   RIB.NATURE%TYPE:=0;


BEGIN

  -- Vérification de la validation du rib en fonction de sa nature(2=normalisé, 3=non normalisé)
  SELECT DISTINCT r.NATURE
    INTO loc_nature
    FROM RIB r
   WHERE r.IDRIB=a_idrib;

  IF loc_nature IN (1,2) THEN

     BEGIN
      -- MODIF TLE/MUR 17/09/2013 : LOC_VALIDE =2 SI RIB NORMALISE, IBAN NON NULL ET BIC NULL
      -- BIC plus obligatoire au 28/11/2016 PHA

      SELECT
      case when (clef_iban  IS NOT NULL
                 AND bban   IS NOT NULL
                 AND modpmt = 2
                 AND nature = 2
                 AND bic    IS NOT NULL
                 AND length(NVL(BIC,' ')) not in (8,11)
                 )
            then 2
            else 1
      end
      INTO loc_valide
      FROM rib
      WHERE ((codbque IS NOT NULL
                  AND guichet IS NOT NULL
                  AND compte IS NOT NULL
                  AND modpmt = 2
                  AND nature = 2
              )
              OR (modpmt = 1 AND nature = 1)
              OR (modpmt = 1
                  AND nature =2
                  AND codpays = pk_devise.pays_ref
                 )
               OR ( clef_iban IS NOT NULL
                     AND bban IS NOT NULL
                     AND modpmt = 2
                     AND nature = 2
                   )
               )
               AND idrib = a_idrib;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          loc_valide := 0;
     END;

  ELSIF loc_nature= 3 THEN -- Rib non normalisé
     BEGIN
        SELECT 1
          INTO loc_valide
          FROM rib
         WHERE (   (    numindiv_etrg IS NOT NULL
                    AND compte_etrg IS NOT NULL
                    AND modpmt = 2
                   )
                OR (    modpmt = 1
                    AND codpays = pk_devise.pays_ref
                   )
               )
           AND idrib = a_idrib;
     EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
           loc_valide := 0;
     END;

  ELSE -- Aucun rib
    loc_valide:= 0;
  END IF;

   RETURN loc_valide;
EXCEPTION
  WHEN OTHERS THEN
    -- loc_valide:= 0; modif mur
    return 0 ;
END F_RIB_VALIDE;
