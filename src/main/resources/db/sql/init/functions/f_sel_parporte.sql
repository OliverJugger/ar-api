CREATE FUNCTION ARTHUS.f_sel_parporte (
   a_numreg      NUMBER,
   a_numsoc      NUMBER,
   a_numorg      NUMBER DEFAULT 0,
   a_numdpt      VARCHAR2 DEFAULT '00',
   a_numcaisse   VARCHAR2 DEFAULT '0',
   a_numporte    NUMBER
)
   RETURN NUMBER
IS
/*============================================================================*/
/* Fonction     : F_SEL_PARPORTE                                              */
/* Domaine      : Paramétrage                                                 */
/* Version      : V1.0                                                        */
/* Auteur       : ????                                                        */
/* Création     : ??/??/????                                                  */
/* Description  : fonction qui verifie qu'une porte de caisse est ouverte     */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       : SDA                                                         */
/* Date         : 09/02/2012                                                  */
/* Commentaire  : valeur par défaut de '0' a '00' pour a_numdpt (Mantis 3656) */
/*============================================================================*/
/* Evolution    : utilisation de la colonne sens pour la recherche de la porte*/
/* Auteur       : JBO                                                         */
/* Date         : 27/08/2014                                                  */
/* Commentaire  : Projet P201407002_P201203001_Tiers_Payant_Hospitalier_GEREP */
/*============================================================================*/
/* Correction   : JBO, 01/02/2013, M3656, Lors de la 1ère recherche, si aucune*/
/*                caisse ouverte n est trouvée on enlève le département en    */
/*                critère de recherche                                        */
/*============================================================================*/

  loc_sel_parporte   NUMBER;

BEGIN

  SELECT ouverte
    INTO loc_sel_parporte
    FROM parporte
   WHERE numreg = a_numreg
     AND numsoc = a_numsoc
     AND numorg = a_numorg
     AND numdpt = a_numdpt
     AND numcaisse = a_numcaisse
     AND numporte = NVL(F_SENS_LIBELLE('PORTE',a_numporte),a_numporte);

  IF loc_sel_parporte = 2
  THEN
     loc_sel_parporte := -1;
  END IF;

  RETURN (loc_sel_parporte);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    BEGIN
      SELECT ouverte
        INTO loc_sel_parporte
        FROM parporte
       WHERE numreg = a_numreg
         AND numsoc = a_numsoc
         AND numorg = a_numorg
         AND numcaisse = a_numcaisse
         AND numporte = NVL(F_SENS_LIBELLE('PORTE',a_numporte),a_numporte);

      IF loc_sel_parporte = 2
      THEN
         loc_sel_parporte := -1;
      END IF;

      RETURN (loc_sel_parporte);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN (0);
        WHEN TOO_MANY_ROWS THEN
          RETURN (0);
    END;
END f_sel_parporte;
